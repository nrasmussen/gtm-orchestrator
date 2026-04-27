#!/usr/bin/env python3
# attio.py — upsert records in Attio via REST API
# Docs: https://developers.attio.com/reference/put_v2-objects-object-records
# Endpoint: https://api.attio.com/v2/objects/{object_type}/records
# Actions: upsert

import json
import os
import sys
from urllib.parse import quote

import requests


def main():
    raw = sys.stdin.read()
    try:
        payload = json.loads(raw) if raw.strip() else {}
    except json.JSONDecodeError as e:
        print(f"ERROR: invalid JSON on stdin: {e}", file=sys.stderr)
        sys.exit(1)

    dry_run = os.environ.get("DRY_RUN", "")
    action = payload.get("action", "upsert")

    if dry_run:
        print(f"DRY_RUN: attio {action}", file=sys.stderr)
        print(f"PAYLOAD: {raw}", file=sys.stderr)
        sys.exit(0)

    api_key = os.environ.get("ATTIO_API_KEY", "")
    if not api_key:
        print("ERROR: ATTIO_API_KEY is required", file=sys.stderr)
        sys.exit(1)

    print(f"INFO: attio action={action}", file=sys.stderr)

    if action == "upsert":
        object_type = payload.get("object_type", "people")
        attributes = payload.get("attributes", {})
        matching_attribute = payload.get("matching_attribute", "email_addresses")

        url = f"https://api.attio.com/v2/objects/{quote(object_type, safe='')}/records"
        body = {"data": {"values": attributes}}
        resp = requests.put(
            url,
            params={"matching_attribute": matching_attribute},
            json=body,
            headers={"Authorization": f"Bearer {api_key}"},
            timeout=20,
        )
        if resp.status_code not in (200, 201):
            print(f"ERROR: Attio API HTTP {resp.status_code}: {resp.text}", file=sys.stderr)
            sys.exit(1)
        print(resp.text)
        print(f"INFO: attio upsert succeeded (HTTP {resp.status_code})", file=sys.stderr)

    else:
        print(f"ERROR: unknown action '{action}'", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
