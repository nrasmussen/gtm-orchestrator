#!/usr/bin/env python3
# notion.py — interact with Notion via claude mcp call (Notion MCP)
# Docs: https://developers.notion.com/reference
# Actions: log-session, cost-log, save-content, save-design, design-doc

import json
import os
import subprocess
import sys

def run_mcp(tool_name: str, tool_input: dict) -> str:
    result = subprocess.run(
        ["claude", "mcp", "call", "notion", tool_name],
        input=json.dumps(tool_input).encode(),
        capture_output=True,
    )
    if result.returncode != 0:
        stderr = result.stderr.decode()
        stdout = result.stdout.decode()
        raise RuntimeError(f"MCP call failed (rc={result.returncode}): {stderr or stdout}")
    return result.stdout.decode()

def make_page(parent_id: str, title: str, children: list, parent_type: str = "page_id") -> dict:
    return {
        "parent": {parent_type: parent_id},
        "properties": {"title": {"title": [{"text": {"content": title}}]}},
        "children": children,
    }

def paragraph_block(text: str) -> dict:
    return {
        "object": "block",
        "type": "paragraph",
        "paragraph": {"rich_text": [{"text": {"content": text}}]},
    }

def heading_block(text: str, level: int = 2) -> dict:
    htype = f"heading_{level}"
    return {
        "object": "block",
        "type": htype,
        htype: {"rich_text": [{"text": {"content": text}}]},
    }

def main():
    raw = sys.stdin.read()
    try:
        payload = json.loads(raw)
    except json.JSONDecodeError as e:
        print(f"ERROR: invalid JSON on stdin: {e}", file=sys.stderr)
        sys.exit(1)

    dry_run = os.environ.get("DRY_RUN", "")

    if dry_run:
        print("DRY_RUN: claude mcp call notion", file=sys.stderr)
        print(f"PAYLOAD: {raw}", file=sys.stderr)
        sys.exit(0)

    action = payload.get("action", "log-session")
    print(f"INFO: notion action={action}", file=sys.stderr)

    try:
        if action == "log-session":
            children = [paragraph_block(payload.get("content", ""))]
            tool_input = make_page(payload["parent_id"], payload.get("title", "Session Log"), children)
            result = run_mcp("notion-create-pages", tool_input)
            print(result)

        elif action == "cost-log":
            tool_input = {
                "parent": {"database_id": payload["parent_id"]},
                "properties": {
                    "Description": {"title": [{"text": {"content": payload.get("description", "")}}]},
                    "Amount": {"number": float(payload.get("amount", 0))},
                },
            }
            result = run_mcp("notion-create-pages", tool_input)
            print(result)

        elif action == "save-content":
            children = [paragraph_block(payload.get("content", ""))]
            tool_input = make_page(payload["parent_id"], payload.get("title", "Content"), children)
            result = run_mcp("notion-create-pages", tool_input)
            print(result)

        elif action == "save-design":
            children = [paragraph_block(payload.get("content", ""))]
            figma_url = payload.get("figma_url", "")
            if figma_url:
                children.append({"object": "block", "type": "bookmark", "bookmark": {"url": figma_url}})
            tool_input = make_page(payload["parent_id"], payload.get("title", "Design"), children)
            result = run_mcp("notion-create-pages", tool_input)
            print(result)

        elif action == "design-doc":
            sections = payload.get("sections", [])
            children = []
            for section in sections:
                children.append(heading_block(section.get("heading", "")))
                children.append(paragraph_block(section.get("body", "")))
            tool_input = make_page(payload["parent_id"], payload.get("title", "Design Doc"), children)
            result = run_mcp("notion-create-pages", tool_input)
            print(result)

        else:
            print(f"ERROR: unknown action '{action}'", file=sys.stderr)
            sys.exit(1)

    except RuntimeError as e:
        print(f"ERROR: notion mcp call failed: {e}", file=sys.stderr)
        sys.exit(1)
    except KeyError as e:
        print(f"ERROR: missing required field {e}", file=sys.stderr)
        sys.exit(1)

    print(f"INFO: notion {action} complete", file=sys.stderr)

if __name__ == "__main__":
    main()
