#!/usr/bin/env python3
# discord.py — post messages to Discord via incoming webhook
# Docs: https://discord.com/developers/docs/resources/webhook#execute-webhook
# Actions: notify

import json
import os
import sys
import requests

def main():
    raw = sys.stdin.read()
    try:
        payload = json.loads(raw)
    except json.JSONDecodeError as e:
        print(f"ERROR: invalid JSON on stdin: {e}", file=sys.stderr)
        sys.exit(1)

    webhook_url = os.environ.get("DISCORD_WEBHOOK_URL", "")
    dry_run = os.environ.get("DRY_RUN", "")

    if dry_run:
        print(f"DRY_RUN: POST {webhook_url}", file=sys.stderr)
        print(f"PAYLOAD: {raw}", file=sys.stderr)
        sys.exit(0)

    if not webhook_url:
        print("ERROR: DISCORD_WEBHOOK_URL is required", file=sys.stderr)
        sys.exit(1)

    action = payload.get("action", "notify")
    print(f"INFO: discord action={action}", file=sys.stderr)

    if action == "notify":
        content = payload.get("text", payload.get("content", ""))
        username = payload.get("username", "Orchestrator")
        body = {"content": content, "username": username}
    else:
        print(f"ERROR: unknown action '{action}'", file=sys.stderr)
        sys.exit(1)

    resp = requests.post(webhook_url, json=body, timeout=15)
    if resp.status_code not in (200, 204):
        print(f"ERROR: Discord webhook returned HTTP {resp.status_code}: {resp.text}", file=sys.stderr)
        sys.exit(1)

    print(f"INFO: discord {action} sent (HTTP {resp.status_code})", file=sys.stderr)

if __name__ == "__main__":
    main()
