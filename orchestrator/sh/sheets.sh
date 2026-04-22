#!/usr/bin/env bash
# sheets.sh — read from and append rows to Google Sheets via the Sheets API v4
# Docs: https://developers.google.com/sheets/api/reference/rest
# Endpoint: https://sheets.googleapis.com/v4/spreadsheets
# Actions: append, read
set -euo pipefail

PAYLOAD="$(cat)"

if [[ -n "${DRY_RUN:-}" ]]; then
  echo "DRY_RUN: sheets $(echo "$PAYLOAD" | python3 -c "import sys,json; print(json.load(sys.stdin).get('action','append'))")" >&2
  echo "PAYLOAD: $PAYLOAD" >&2
  exit 0
fi

ACTION="$(echo "$PAYLOAD" | python3 -c "import sys,json; print(json.load(sys.stdin).get('action','append'))")"
echo "INFO: sheets action=$ACTION" >&2

SPREADSHEET_ID="${GOOGLE_SHEETS_SPREADSHEET_ID:?GOOGLE_SHEETS_SPREADSHEET_ID is required}"
API_KEY="${GOOGLE_SHEETS_API_KEY:?GOOGLE_SHEETS_API_KEY is required}"
BASE_URL="https://sheets.googleapis.com/v4/spreadsheets"

case "$ACTION" in
  append)
    RANGE="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('range','Sheet1'))")"
    VALUES="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(json.dumps(d.get('values',[])))")"

    BODY="$(python3 -c "
import json
print(json.dumps({
  'values': json.loads('''$VALUES''')
}))
")"

    ENCODED_RANGE="$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote('''$RANGE''', safe=''))")"

    HTTP_STATUS=$(curl -s -o /tmp/sheets_response.json -w "%{http_code}" \
      -X POST \
      -H "Content-Type: application/json" \
      -d "$BODY" \
      "${BASE_URL}/${SPREADSHEET_ID}/values/${ENCODED_RANGE}:append?valueInputOption=USER_ENTERED&key=${API_KEY}")

    if [[ "$HTTP_STATUS" != "200" && "$HTTP_STATUS" != "201" ]]; then
      echo "ERROR: Google Sheets API returned HTTP $HTTP_STATUS" >&2
      cat /tmp/sheets_response.json >&2
      exit 1
    fi

    cat /tmp/sheets_response.json
    echo "INFO: sheets append succeeded (HTTP $HTTP_STATUS)" >&2
    ;;

  read)
    RANGE="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('range','Sheet1'))")"

    ENCODED_RANGE="$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote('''$RANGE''', safe=''))")"

    HTTP_STATUS=$(curl -s -o /tmp/sheets_response.json -w "%{http_code}" \
      -X GET \
      "${BASE_URL}/${SPREADSHEET_ID}/values/${ENCODED_RANGE}?key=${API_KEY}")

    if [[ "$HTTP_STATUS" != "200" ]]; then
      echo "ERROR: Google Sheets API returned HTTP $HTTP_STATUS" >&2
      cat /tmp/sheets_response.json >&2
      exit 1
    fi

    cat /tmp/sheets_response.json
    echo "INFO: sheets read succeeded (HTTP $HTTP_STATUS)" >&2
    ;;

  *)
    echo "ERROR: unknown action '$ACTION'" >&2
    exit 1
    ;;
esac
