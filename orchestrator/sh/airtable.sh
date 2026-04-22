#!/usr/bin/env bash
# airtable.sh — append records to Airtable via REST API
# Docs: https://airtable.com/developers/web/api/introduction
# Endpoint: https://api.airtable.com/v0/{baseId}/{tableId}
# Actions: append
set -euo pipefail

PAYLOAD="$(cat)"

if [[ -n "${DRY_RUN:-}" ]]; then
  echo "DRY_RUN: POST https://api.airtable.com/v0/\$AIRTABLE_BASE_ID/<table>" >&2
  echo "PAYLOAD: $PAYLOAD" >&2
  exit 0
fi

ACTION="$(echo "$PAYLOAD" | python3 -c "import sys,json; print(json.load(sys.stdin).get('action','append'))")"
echo "INFO: airtable action=$ACTION" >&2

case "$ACTION" in
  append)
    TABLE_ID="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('table',''))")"
    FIELDS="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(json.dumps(d.get('fields',{})))")"

    BODY="$(python3 -c "
import json
print(json.dumps({'fields': json.loads('''$FIELDS''')}))
")"

    HTTP_STATUS=$(curl -s -o /tmp/airtable_response.json -w "%{http_code}" \
      -X POST \
      -H "Authorization: Bearer ${AIRTABLE_TOKEN:?AIRTABLE_TOKEN is required}" \
      -H "Content-Type: application/json" \
      -d "$BODY" \
      "https://api.airtable.com/v0/${AIRTABLE_BASE_ID:?AIRTABLE_BASE_ID is required}/${TABLE_ID:?table field is required}")

    if [[ "$HTTP_STATUS" != "200" && "$HTTP_STATUS" != "201" ]]; then
      echo "ERROR: Airtable API returned HTTP $HTTP_STATUS" >&2
      cat /tmp/airtable_response.json >&2
      exit 1
    fi

    cat /tmp/airtable_response.json
    echo "INFO: airtable append succeeded (HTTP $HTTP_STATUS)" >&2
    ;;
  *)
    echo "ERROR: unknown action '$ACTION'" >&2
    exit 1
    ;;
esac
