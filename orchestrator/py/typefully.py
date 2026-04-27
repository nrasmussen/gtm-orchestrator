#!/usr/bin/env python3
# typefully.py — create draft tweets/threads in Typefully via REST API
# Docs: https://typefully.com/developer
# Endpoint: https://api.typefully.com/v1
# Actions: draft

import json
import os
import sys
import requests

DRAFTS_URL = "https://api.typefully.com/v1/drafts/"

def main():
    raw = sys.stdin.read()
    try:
        payload = json.loads(raw)
    except json.JSONDecodeError as e:
        print(f"ERROR: invalid JSON on stdin: {e}", file=sys.stderr)
        sys.exit(1)

    api_key = os.environ.get("TYPEFULLY_API_KEY", "")
    dry_run = os.environ.get("DRY_RUN", "")

    if dry_run:
        print(f"DRY_RUN: POST {DRAFTS_URL}", file=sys.stderr)
        print(f"PAYLOAD: {raw}", file=sys.stderr)
        sys.exit(0)

    if not api_key:
        print("ERROR: TYPEFULLY_API_KEY is required", file=sys.stderr)
        sys.exit(1)

    action = payload.get("action", "draft")
    print(f"INFO: typefully action={action}", file=sys.stderr)

    if action == "draft":
        body = {
            "content": payload.get("content", ""),
            "auto-retweet-enabled": payload.get("auto_retweet", False),
            "auto-plug-enabled": payload.get("auto_plug", False),
        }
        if payload.get("schedule_date"):
            body["schedule-date"] = payload["schedule_date"]

        resp = requests.post(
            DRAFTS_URL,
            json=body,
            headers={"X-API-KEY": api_key},
            timeout=15,
        )
        if resp.status_code not in (200, 201):
            print(f"ERROR: Typefully API returned HTTP {resp.status_code}: {resp.text}", file=sys.stderr)
            sys.exit(1)

        print(resp.text)
        print(f"INFO: typefully draft succeeded (HTTP {resp.status_code})", file=sys.stderr)

    else:
        print(f"ERROR: unknown action '{action}'", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
