#!/usr/bin/env python3
# lemlist.py — manage leads and sequences in Lemlist via REST API
# Docs: https://developer.lemlist.com/
# Endpoint: https://api.lemlist.com/api
# Actions: add-lead, push-sequence

import base64
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

    api_key = os.environ.get("LEMLIST_API_KEY", "")
    dry_run = os.environ.get("DRY_RUN", "")

    if dry_run:
        print("DRY_RUN: lemlist REST API call", file=sys.stderr)
        print(f"PAYLOAD: {raw}", file=sys.stderr)
        sys.exit(0)

    if not api_key:
        print("ERROR: LEMLIST_API_KEY is required", file=sys.stderr)
        sys.exit(1)

    auth = base64.b64encode(f":{api_key}".encode()).decode()
    headers = {
        "Authorization": f"Basic {auth}",
        "Content-Type": "application/json",
    }

    action = payload.get("action", "add-lead")
    print(f"INFO: lemlist action={action}", file=sys.stderr)

    if action == "add-lead":
        campaign_id = payload.get("campaign_id", "")
        email = payload.get("email", "")
        if not campaign_id or not email:
            print("ERROR: 'campaign_id' and 'email' are required", file=sys.stderr)
            sys.exit(1)

        body = {
            "email": email,
            "firstName": payload.get("first_name", ""),
            "lastName": payload.get("last_name", ""),
            "companyName": payload.get("company", ""),
        }
        url = f"https://api.lemlist.com/api/campaigns/{campaign_id}/leads/{email}"
        resp = requests.post(url, json=body, headers=headers, timeout=15)
        if resp.status_code not in (200, 201):
            print(f"ERROR: Lemlist API returned HTTP {resp.status_code}: {resp.text}", file=sys.stderr)
            sys.exit(1)
        print(resp.text)
        print(f"INFO: lemlist add-lead succeeded (HTTP {resp.status_code})", file=sys.stderr)

    elif action == "push-sequence":
        campaign_id = payload.get("campaign_id", "")
        email = payload.get("email", "")
        if not campaign_id or not email:
            print("ERROR: 'campaign_id' and 'email' are required", file=sys.stderr)
            sys.exit(1)

        body = {
            "email": email,
            "deduplicate": payload.get("deduplicate", True),
        }
        url = f"https://api.lemlist.com/api/campaigns/{campaign_id}/leads/{email}/start"
        resp = requests.post(url, json=body, headers=headers, timeout=15)
        if resp.status_code not in (200, 201):
            print(f"ERROR: Lemlist API returned HTTP {resp.status_code}: {resp.text}", file=sys.stderr)
            sys.exit(1)
        print(resp.text)
        print(f"INFO: lemlist push-sequence succeeded (HTTP {resp.status_code})", file=sys.stderr)

    else:
        print(f"ERROR: unknown action '{action}'", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
