#!/usr/bin/env python3
# airtable.py — append records to Airtable via REST API
# Docs: https://airtable.com/developers/web/api/introduction
# Endpoint: https://api.airtable.com/v0/{baseId}/{tableId}
# Actions: append

import json
import os
import sys
from urllib.parse import quote

import requests

def main():
    raw = sys.stdin.read()
    try:
        payload = json.loads(raw)
    except json.JSONDecodeError as e:
        print(f"ERROR: invalid JSON on stdin: {e}", file=sys.stderr)
        sys.exit(1)

    token = os.environ.get("AIRTABLE_TOKEN", "")
    base_id = os.environ.get("AIRTABLE_BASE_ID", "")
    dry_run = os.environ.get("DRY_RUN", "")

    if dry_run:
        print(f"DRY_RUN: POST https://api.airtable.com/v0/{base_id}/<table>", file=sys.stderr)
        print(f"PAYLOAD: {raw}", file=sys.stderr)
        sys.exit(0)

    if not token:
        print("ERROR: AIRTABLE_TOKEN is required", file=sys.stderr)
        sys.exit(1)
    if not base_id:
        print("ERROR: AIRTABLE_BASE_ID is required", file=sys.stderr)
        sys.exit(1)

    action = payload.get("action", "append")
    print(f"INFO: airtable action={action}", file=sys.stderr)

    if action == "append":
        table = payload.get("table", "")
        if not table:
            print("ERROR: 'table' field is required", file=sys.stderr)
            sys.exit(1)
        fields = payload.get("fields", {})

        url = f"https://api.airtable.com/v0/{base_id}/{quote(table, safe='')}"
        body = {"fields": fields}

        resp = requests.post(
            url,
            json=body,
            headers={"Authorization": f"Bearer {token}"},
            timeout=15,
        )
        if resp.status_code not in (200, 201):
            print(f"ERROR: Airtable API returned HTTP {resp.status_code}: {resp.text}", file=sys.stderr)
            sys.exit(1)

        print(resp.text)
        print(f"INFO: airtable append succeeded (HTTP {resp.status_code})", file=sys.stderr)

    else:
        print(f"ERROR: unknown action '{action}'", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
