#!/usr/bin/env bash
# attio.sh — upsert records in Attio; tries MCP first, falls back to REST
# Docs: https://developers.attio.com/reference
# Actions: upsert
set -euo pipefail

PAYLOAD="$(cat)"

if [[ -n "${DRY_RUN:-}" ]]; then
  echo "DRY_RUN: attio upsert" >&2
  echo "PAYLOAD: $PAYLOAD" >&2
  exit 0
fi

ACTION="$(echo "$PAYLOAD" | python3 -c "import sys,json; print(json.load(sys.stdin).get('action','upsert'))")"
echo "INFO: attio action=$ACTION" >&2

case "$ACTION" in
  upsert)
    OBJECT_TYPE="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('object_type','people'))")"
    ATTRIBUTES="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(json.dumps(d.get('attributes',{})))")"
    MATCHING_ATTRIBUTE="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('matching_attribute','email_addresses'))")"

    # Try MCP first
    MCP_INPUT="$(python3 -c "
import json
print(json.dumps({
  'object_type': '''$OBJECT_TYPE''',
  'matching_attribute': '''$MATCHING_ATTRIBUTE''',
  'attributes': json.loads('''$ATTRIBUTES''')
}))
")"
    if MCP_RESULT="$(echo "$MCP_INPUT" | claude mcp call attio upsert_record 2>&1)"; then
      echo "INFO: attio upsert via MCP succeeded" >&2
      echo "$MCP_RESULT"
    else
      echo "INFO: MCP failed, falling back to REST API" >&2
      BODY="$(python3 -c "
import json
print(json.dumps({
  'data': {
    'values': json.loads('''$ATTRIBUTES''')
  }
}))
")"
      HTTP_STATUS=$(curl -s -o /tmp/attio_response.json -w "%{http_code}" \
        -X PUT \
        -H "Authorization: Bearer ${ATTIO_API_KEY:?ATTIO_API_KEY is required}" \
        -H "Content-Type: application/json" \
        -d "$BODY" \
        "https://api.attio.com/v2/objects/${OBJECT_TYPE}/records?matching_attribute=${MATCHING_ATTRIBUTE}")

      if [[ "$HTTP_STATUS" != "200" && "$HTTP_STATUS" != "201" ]]; then
        echo "ERROR: Attio REST API returned HTTP $HTTP_STATUS" >&2
        cat /tmp/attio_response.json >&2
        exit 1
      fi
      cat /tmp/attio_response.json
      echo "INFO: attio upsert via REST succeeded (HTTP $HTTP_STATUS)" >&2
    fi
    ;;
  *)
    echo "ERROR: unknown action '$ACTION'" >&2
    exit 1
    ;;
esac
