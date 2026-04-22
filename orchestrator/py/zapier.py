#!/usr/bin/env python3
# zapier.py — fire a Zapier webhook
# Docs: https://zapier.com/help/create/code-webhooks/trigger-zaps-from-webhooks
# Actions: fire

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

    webhook_url = os.environ.get("ZAPIER_WEBHOOK_URL", "")
    dry_run = os.environ.get("DRY_RUN", "")

    if dry_run:
        print(f"DRY_RUN: POST {webhook_url}", file=sys.stderr)
        print(f"PAYLOAD: {raw}", file=sys.stderr)
        sys.exit(0)

    if not webhook_url:
        print("ERROR: ZAPIER_WEBHOOK_URL is required", file=sys.stderr)
        sys.exit(1)

    action = payload.get("action", "fire")
    print(f"INFO: zapier action={action}", file=sys.stderr)

    if action == "fire":
        data = payload.get("data", payload)
        resp = requests.post(webhook_url, json=data, timeout=15)
        if resp.status_code not in (200, 201, 202):
            print(f"ERROR: Zapier webhook returned HTTP {resp.status_code}: {resp.text}", file=sys.stderr)
            sys.exit(1)
        print(resp.text)
        print(f"INFO: zapier fire succeeded (HTTP {resp.status_code})", file=sys.stderr)

    else:
        print(f"ERROR: unknown action '{action}'", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
