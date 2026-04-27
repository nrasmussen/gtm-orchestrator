#!/usr/bin/env python3
# notion.py — interact with Notion via REST API
# Docs: https://developers.notion.com/reference
# Actions: log-session, cost-log, save-content, save-design, design-doc

from __future__ import annotations

import json
import os
import sys
from typing import Optional

import requests

NOTION_VERSION = "2022-06-28"
PAGES_URL = "https://api.notion.com/v1/pages"


def _headers() -> dict:
    return {
        "Authorization": f"Bearer {os.environ['NOTION_API_KEY']}",
        "Content-Type": "application/json",
        "Notion-Version": NOTION_VERSION,
    }


def _paragraph(text: str) -> dict:
    return {
        "object": "block",
        "type": "paragraph",
        "paragraph": {"rich_text": [{"text": {"content": text or ""}}]},
    }


def _heading(text: str, level: int = 2) -> dict:
    htype = f"heading_{level}"
    return {
        "object": "block",
        "type": htype,
        htype: {"rich_text": [{"text": {"content": text or ""}}]},
    }


def _bookmark(url: str) -> dict:
    return {"object": "block", "type": "bookmark", "bookmark": {"url": url}}


def _create_page(parent_id: str, title: str, children: list, parent_type: str = "page_id", extra_props: Optional[dict] = None) -> dict:
    properties = {"title": {"title": [{"text": {"content": title}}]}}
    if extra_props:
        properties.update(extra_props)
    body = {
        "parent": {parent_type: parent_id},
        "properties": properties,
        "children": children,
    }
    resp = requests.post(PAGES_URL, json=body, headers=_headers(), timeout=20)
    if resp.status_code not in (200, 201):
        print(f"ERROR: Notion API HTTP {resp.status_code}: {resp.text}", file=sys.stderr)
        sys.exit(1)
    return resp.json()


def _resolve_parent(payload: dict, env_var: str = "NOTION_PARENT_PAGE_ID") -> tuple[str, str]:
    """Return (parent_id, parent_type). Database IDs override page IDs."""
    db_id = payload.get("database_id") or os.environ.get("NOTION_COST_DATABASE_ID", "")
    if db_id and payload.get("action") == "cost-log":
        return db_id, "database_id"
    page_id = payload.get("parent_id") or os.environ.get(env_var, "")
    if not page_id:
        print(f"ERROR: parent_id (or env {env_var}) required", file=sys.stderr)
        sys.exit(1)
    return page_id, "page_id"


def main():
    raw = sys.stdin.read()
    try:
        payload = json.loads(raw) if raw.strip() else {}
    except json.JSONDecodeError as e:
        print(f"ERROR: invalid JSON on stdin: {e}", file=sys.stderr)
        sys.exit(1)

    dry_run = os.environ.get("DRY_RUN", "")
    action = payload.get("action", "log-session")

    if dry_run:
        print(f"DRY_RUN: notion {action}", file=sys.stderr)
        print(f"PAYLOAD: {raw}", file=sys.stderr)
        sys.exit(0)

    if not os.environ.get("NOTION_API_KEY"):
        print("ERROR: NOTION_API_KEY is required", file=sys.stderr)
        sys.exit(1)

    print(f"INFO: notion action={action}", file=sys.stderr)

    if action == "log-session":
        parent_id, parent_type = _resolve_parent(payload)
        children = [_paragraph(payload.get("content", payload.get("raw_text", "")))]
        result = _create_page(parent_id, payload.get("title", "Session Log"), children, parent_type)
        print(json.dumps(result))

    elif action == "cost-log":
        parent_id, parent_type = _resolve_parent(payload)
        if parent_type != "database_id":
            print("ERROR: cost-log requires database_id (or NOTION_COST_DATABASE_ID)", file=sys.stderr)
            sys.exit(1)
        try:
            amount = float(payload.get("amount", 0) or 0)
        except (TypeError, ValueError):
            print(f"WARNING: non-numeric amount {payload.get('amount')!r}, defaulting to 0", file=sys.stderr)
            amount = 0.0
        body = {
            "parent": {"database_id": parent_id},
            "properties": {
                "Description": {"title": [{"text": {"content": payload.get("description", "")}}]},
                "Amount": {"number": amount},
            },
        }
        resp = requests.post(PAGES_URL, json=body, headers=_headers(), timeout=20)
        if resp.status_code not in (200, 201):
            print(f"ERROR: Notion API HTTP {resp.status_code}: {resp.text}", file=sys.stderr)
            sys.exit(1)
        print(resp.text)

    elif action == "save-content":
        parent_id, parent_type = _resolve_parent(payload)
        children = [_paragraph(payload.get("content", payload.get("raw_text", "")))]
        result = _create_page(parent_id, payload.get("title", "Content"), children, parent_type)
        print(json.dumps(result))

    elif action == "save-design":
        parent_id, parent_type = _resolve_parent(payload)
        children = [_paragraph(payload.get("content", ""))]
        if payload.get("figma_url"):
            children.append(_bookmark(payload["figma_url"]))
        result = _create_page(parent_id, payload.get("title", "Design"), children, parent_type)
        print(json.dumps(result))

    elif action == "design-doc":
        parent_id, parent_type = _resolve_parent(payload)
        sections = payload.get("sections", [])
        children = []
        for section in sections:
            children.append(_heading(section.get("heading", "")))
            children.append(_paragraph(section.get("body", "")))
        if not children:
            children = [_paragraph(payload.get("content", ""))]
        result = _create_page(parent_id, payload.get("title", "Design Doc"), children, parent_type)
        print(json.dumps(result))

    else:
        print(f"ERROR: unknown action '{action}'", file=sys.stderr)
        sys.exit(1)

    print(f"INFO: notion {action} complete", file=sys.stderr)


if __name__ == "__main__":
    main()
