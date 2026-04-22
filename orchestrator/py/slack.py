#!/usr/bin/env python3
# slack.py — post messages to Slack via incoming webhook
# Docs: https://api.slack.com/messaging/webhooks
# Actions: notify, approval, daily-digest

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

    webhook_url = os.environ.get("SLACK_WEBHOOK_URL", "")
    dry_run = os.environ.get("DRY_RUN", "")

    if dry_run:
        print(f"DRY_RUN: POST {webhook_url}", file=sys.stderr)
        print(f"PAYLOAD: {raw}", file=sys.stderr)
        sys.exit(0)

    if not webhook_url:
        print("ERROR: SLACK_WEBHOOK_URL is required", file=sys.stderr)
        sys.exit(1)

    action = payload.get("action", "notify")
    print(f"INFO: slack action={action}", file=sys.stderr)

    if action == "notify":
        body = {"text": payload.get("text", "")}
        if payload.get("channel"):
            body["channel"] = payload["channel"]

    elif action == "approval":
        text = payload.get("text", "Approval required")
        body = {
            "text": text,
            "attachments": [{
                "fallback": text,
                "callback_id": "approval_request",
                "color": "warning",
                "actions": [
                    {"name": "approve", "text": "Approve", "type": "button", "value": "approve", "style": "primary"},
                    {"name": "deny",    "text": "Deny",    "type": "button", "value": "deny",    "style": "danger"},
                ]
            }]
        }

    elif action == "daily-digest":
        title = payload.get("title", "Daily Digest")
        items = payload.get("items", [])
        blocks = [{"type": "section", "text": {"type": "mrkdwn", "text": f"*{title}*"}}]
        for item in items:
            blocks.append({"type": "section", "text": {"type": "mrkdwn", "text": item}})
        body = {"blocks": blocks}

    else:
        print(f"ERROR: unknown action '{action}'", file=sys.stderr)
        sys.exit(1)

    resp = requests.post(webhook_url, json=body, timeout=15)
    if resp.status_code != 200:
        print(f"ERROR: Slack webhook returned HTTP {resp.status_code}: {resp.text}", file=sys.stderr)
        sys.exit(1)

    print(f"INFO: slack {action} sent (HTTP {resp.status_code})", file=sys.stderr)

if __name__ == "__main__":
    main()
