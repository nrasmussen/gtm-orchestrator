#!/usr/bin/env python3
# hubspot.py — upsert contacts in HubSpot via REST API
# Docs: https://developers.hubspot.com/docs/api/crm/contacts
# Endpoint: https://api.hubapi.com/crm/v3/objects/contacts
# Actions: upsert

import json
import os
import sys
import requests

UPSERT_URL = "https://api.hubapi.com/crm/v3/objects/contacts/batch/upsert"

def main():
    raw = sys.stdin.read()
    try:
        payload = json.loads(raw)
    except json.JSONDecodeError as e:
        print(f"ERROR: invalid JSON on stdin: {e}", file=sys.stderr)
        sys.exit(1)

    token = os.environ.get("HUBSPOT_TOKEN", "")
    dry_run = os.environ.get("DRY_RUN", "")

    if dry_run:
        print(f"DRY_RUN: POST {UPSERT_URL}", file=sys.stderr)
        print(f"PAYLOAD: {raw}", file=sys.stderr)
        sys.exit(0)

    if not token:
        print("ERROR: HUBSPOT_TOKEN is required", file=sys.stderr)
        sys.exit(1)

    action = payload.get("action", "upsert")
    print(f"INFO: hubspot action={action}", file=sys.stderr)

    if action == "upsert":
        email = payload.get("email", "")
        properties = payload.get("properties", {})
        if email and "email" not in properties:
            properties["email"] = email

        body = {
            "inputs": [{
                "idProperty": "email",
                "id": email,
                "properties": properties,
            }]
        }

        resp = requests.post(
            UPSERT_URL,
            json=body,
            headers={"Authorization": f"Bearer {token}"},
            timeout=15,
        )
        if resp.status_code not in (200, 201):
            print(f"ERROR: HubSpot API returned HTTP {resp.status_code}: {resp.text}", file=sys.stderr)
            sys.exit(1)

        print(resp.text)
        print(f"INFO: hubspot upsert succeeded (HTTP {resp.status_code})", file=sys.stderr)

    else:
        print(f"ERROR: unknown action '{action}'", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
