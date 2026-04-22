#!/usr/bin/env python3
# sheets.py — read from and append rows to Google Sheets via the Sheets API v4
# Docs: https://developers.google.com/sheets/api/reference/rest
# Endpoint: https://sheets.googleapis.com/v4/spreadsheets
# Actions: append, read

import json
import os
import sys
from urllib.parse import quote
import requests

BASE_URL = "https://sheets.googleapis.com/v4/spreadsheets"


def main():
    raw = sys.stdin.read()
    try:
        payload = json.loads(raw)
    except json.JSONDecodeError as e:
        print(f"ERROR: invalid JSON on stdin: {e}", file=sys.stderr)
        sys.exit(1)

    dry_run = os.environ.get("DRY_RUN", "")
    action = payload.get("action", "append")

    if dry_run:
        print(f"DRY_RUN: sheets {action}", file=sys.stderr)
        print(f"PAYLOAD: {raw}", file=sys.stderr)
        sys.exit(0)

    print(f"INFO: sheets action={action}", file=sys.stderr)

    spreadsheet_id = os.environ.get("GOOGLE_SHEETS_SPREADSHEET_ID", "")
    if not spreadsheet_id:
        print("ERROR: GOOGLE_SHEETS_SPREADSHEET_ID is required", file=sys.stderr)
        sys.exit(1)

    api_key = os.environ.get("GOOGLE_SHEETS_API_KEY", "")
    if not api_key:
        print("ERROR: GOOGLE_SHEETS_API_KEY is required", file=sys.stderr)
        sys.exit(1)

    if action == "append":
        range_ = payload.get("range", "Sheet1")
        values = payload.get("values", [])
        encoded_range = quote(range_, safe="")

        url = f"{BASE_URL}/{spreadsheet_id}/values/{encoded_range}:append"
        resp = requests.post(
            url,
            params={"valueInputOption": "USER_ENTERED", "key": api_key},
            json={"values": values},
            headers={"Content-Type": "application/json"},
            timeout=15,
        )
        if resp.status_code not in (200, 201):
            print(
                f"ERROR: Google Sheets API returned HTTP {resp.status_code}: {resp.text}",
                file=sys.stderr,
            )
            sys.exit(1)
        print(resp.text)
        print(f"INFO: sheets append succeeded (HTTP {resp.status_code})", file=sys.stderr)

    elif action == "read":
        range_ = payload.get("range", "Sheet1")
        encoded_range = quote(range_, safe="")

        url = f"{BASE_URL}/{spreadsheet_id}/values/{encoded_range}"
        resp = requests.get(
            url,
            params={"key": api_key},
            timeout=15,
        )
        if resp.status_code != 200:
            print(
                f"ERROR: Google Sheets API returned HTTP {resp.status_code}: {resp.text}",
                file=sys.stderr,
            )
            sys.exit(1)
        print(resp.text)
        print(f"INFO: sheets read succeeded (HTTP {resp.status_code})", file=sys.stderr)

    else:
        print(f"ERROR: unknown action '{action}'", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
