#!/usr/bin/env python3
# instantly.py — push leads to Instantly.ai via REST API
# Docs: https://developer.instantly.ai/
# Endpoint: https://api.instantly.ai/api/v1
# Actions: push

import json
import os
import sys
import requests

ADD_LEAD_URL = "https://api.instantly.ai/api/v1/lead/add"

def main():
    raw = sys.stdin.read()
    try:
        payload = json.loads(raw)
    except json.JSONDecodeError as e:
        print(f"ERROR: invalid JSON on stdin: {e}", file=sys.stderr)
        sys.exit(1)

    api_key = os.environ.get("INSTANTLY_API_KEY", "")
    dry_run = os.environ.get("DRY_RUN", "")

    if dry_run:
        print(f"DRY_RUN: POST {ADD_LEAD_URL}", file=sys.stderr)
        print(f"PAYLOAD: {raw}", file=sys.stderr)
        sys.exit(0)

    if not api_key:
        print("ERROR: INSTANTLY_API_KEY is required", file=sys.stderr)
        sys.exit(1)

    action = payload.get("action", "push")
    print(f"INFO: instantly action={action}", file=sys.stderr)

    if action == "push":
        campaign_id = payload.get("campaign_id", "")
        email = payload.get("email", "")
        if not campaign_id or not email:
            print("ERROR: 'campaign_id' and 'email' are required", file=sys.stderr)
            sys.exit(1)

        body = {
            "api_key": api_key,
            "campaign_id": campaign_id,
            "leads": [{
                "email": email,
                "first_name": payload.get("first_name", ""),
                "last_name": payload.get("last_name", ""),
                "company_name": payload.get("company", ""),
            }],
            "skip_if_in_workspace": True,
        }

        resp = requests.post(ADD_LEAD_URL, json=body, timeout=15)
        if resp.status_code not in (200, 201):
            print(f"ERROR: Instantly API returned HTTP {resp.status_code}: {resp.text}", file=sys.stderr)
            sys.exit(1)

        print(resp.text)
        print(f"INFO: instantly push succeeded (HTTP {resp.status_code})", file=sys.stderr)

    else:
        print(f"ERROR: unknown action '{action}'", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
