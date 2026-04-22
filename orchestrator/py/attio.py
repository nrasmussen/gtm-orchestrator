#!/usr/bin/env python3
# attio.py — upsert records in Attio; tries MCP first, falls back to REST
# Docs: https://developers.attio.com/reference
# Actions: upsert

import json
import os
import subprocess
import sys
import requests

def try_mcp(object_type: str, matching_attribute: str, attributes: dict) -> tuple[bool, str]:
    tool_input = {
        "object_type": object_type,
        "matching_attribute": matching_attribute,
        "attributes": attributes,
    }
    result = subprocess.run(
        ["claude", "mcp", "call", "attio", "upsert_record"],
        input=json.dumps(tool_input).encode(),
        capture_output=True,
    )
    if result.returncode == 0:
        return True, result.stdout.decode()
    return False, result.stderr.decode()

def main():
    raw = sys.stdin.read()
    try:
        payload = json.loads(raw)
    except json.JSONDecodeError as e:
        print(f"ERROR: invalid JSON on stdin: {e}", file=sys.stderr)
        sys.exit(1)

    dry_run = os.environ.get("DRY_RUN", "")

    if dry_run:
        print("DRY_RUN: attio upsert", file=sys.stderr)
        print(f"PAYLOAD: {raw}", file=sys.stderr)
        sys.exit(0)

    action = payload.get("action", "upsert")
    print(f"INFO: attio action={action}", file=sys.stderr)

    if action == "upsert":
        object_type = payload.get("object_type", "people")
        attributes = payload.get("attributes", {})
        matching_attribute = payload.get("matching_attribute", "email_addresses")

        ok, result = try_mcp(object_type, matching_attribute, attributes)
        if ok:
            print("INFO: attio upsert via MCP succeeded", file=sys.stderr)
            print(result)
        else:
            print(f"INFO: MCP failed ({result.strip()}), falling back to REST API", file=sys.stderr)
            api_key = os.environ.get("ATTIO_API_KEY", "")
            if not api_key:
                print("ERROR: ATTIO_API_KEY is required for REST fallback", file=sys.stderr)
                sys.exit(1)

            body = {"data": {"values": attributes}}
            url = f"https://api.attio.com/v2/objects/{object_type}/records"
            params = {"matching_attribute": matching_attribute}
            resp = requests.put(
                url,
                params=params,
                json=body,
                headers={"Authorization": f"Bearer {api_key}"},
                timeout=15,
            )
            if resp.status_code not in (200, 201):
                print(f"ERROR: Attio REST API returned HTTP {resp.status_code}: {resp.text}", file=sys.stderr)
                sys.exit(1)
            print(resp.text)
            print(f"INFO: attio upsert via REST succeeded (HTTP {resp.status_code})", file=sys.stderr)

    else:
        print(f"ERROR: unknown action '{action}'", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
