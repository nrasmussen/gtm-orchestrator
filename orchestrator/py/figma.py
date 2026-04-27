#!/usr/bin/env python3
# figma.py — export node images from Figma via REST API
# Docs: https://www.figma.com/developers/api#get-images-endpoint
# Endpoint: https://api.figma.com/v1/images/{file_key}
# Actions: export

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
    action = payload.get("action", "export")

    if dry_run:
        print(f"DRY_RUN: figma {action}", file=sys.stderr)
        print(f"PAYLOAD: {raw}", file=sys.stderr)
        sys.exit(0)

    api_key = os.environ.get("FIGMA_API_KEY", "")
    if not api_key:
        print("ERROR: FIGMA_API_KEY is required", file=sys.stderr)
        sys.exit(1)

    print(f"INFO: figma action={action}", file=sys.stderr)

    if action == "export":
        file_key = payload.get("file_key", "")
        node_id = payload.get("node_id", "")
        if not file_key or not node_id:
            print("ERROR: 'file_key' and 'node_id' are required", file=sys.stderr)
            sys.exit(1)

        url = f"https://api.figma.com/v1/images/{quote(file_key, safe='')}"
        params = {
            "ids": node_id,
            "format": payload.get("format", "png"),
            "scale": payload.get("scale", 2),
        }
        resp = requests.get(
            url,
            params=params,
            headers={"X-Figma-Token": api_key},
            timeout=20,
        )
        if resp.status_code != 200:
            print(f"ERROR: Figma API HTTP {resp.status_code}: {resp.text}", file=sys.stderr)
            sys.exit(1)
        print(resp.text)
        print(f"INFO: figma export succeeded (HTTP {resp.status_code})", file=sys.stderr)

    else:
        print(f"ERROR: unknown action '{action}'", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
