#!/usr/bin/env python3
# smartlead.py — push leads to Smartlead via REST API
# Docs: https://documenter.getpostman.com/view/22873767/2s9YsNdpTw
# Endpoint: https://server.smartlead.ai/api/v1
# Actions: push

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

    api_key = os.environ.get("SMARTLEAD_API_KEY", "")
    dry_run = os.environ.get("DRY_RUN", "")

    if dry_run:
        print("DRY_RUN: POST https://server.smartlead.ai/api/v1/campaigns/<id>/leads", file=sys.stderr)
        print(f"PAYLOAD: {raw}", file=sys.stderr)
        sys.exit(0)

    if not api_key:
        print("ERROR: SMARTLEAD_API_KEY is required", file=sys.stderr)
        sys.exit(1)

    action = payload.get("action", "push")
    print(f"INFO: smartlead action={action}", file=sys.stderr)

    if action == "push":
        campaign_id = payload.get("campaign_id", "")
        email = payload.get("email", "")
        if not campaign_id or not email:
            print("ERROR: 'campaign_id' and 'email' are required", file=sys.stderr)
            sys.exit(1)

        body = {
            "lead_list": [{
                "email": email,
                "first_name": payload.get("first_name", ""),
                "last_name": payload.get("last_name", ""),
                "company_name": payload.get("company", ""),
            }],
            "settings": {
                "ignore_global_block_list": False,
                "ignore_unsubscribe_list": False,
                "ignore_community_bounce_list": False,
            },
        }

        url = f"https://server.smartlead.ai/api/v1/campaigns/{campaign_id}/leads"
        resp = requests.post(url, json=body, params={"api_key": api_key}, timeout=15)
        if resp.status_code not in (200, 201):
            print(f"ERROR: Smartlead API returned HTTP {resp.status_code}: {resp.text}", file=sys.stderr)
            sys.exit(1)

        print(resp.text)
        print(f"INFO: smartlead push succeeded (HTTP {resp.status_code})", file=sys.stderr)

    else:
        print(f"ERROR: unknown action '{action}'", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
