#!/usr/bin/env bash
# hubspot.sh — upsert contacts in HubSpot via REST API
# Docs: https://developers.hubspot.com/docs/api/crm/contacts
# Endpoint: https://api.hubapi.com/crm/v3/objects/contacts
# Actions: upsert
set -euo pipefail

PAYLOAD="$(cat)"

if [[ -n "${DRY_RUN:-}" ]]; then
  echo "DRY_RUN: POST https://api.hubapi.com/crm/v3/objects/contacts/batch/upsert" >&2
  echo "PAYLOAD: $PAYLOAD" >&2
  exit 0
fi

ACTION="$(echo "$PAYLOAD" | python3 -c "import sys,json; print(json.load(sys.stdin).get('action','upsert'))")"
echo "INFO: hubspot action=$ACTION" >&2

case "$ACTION" in
  upsert)
    EMAIL="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('email',''))")"
    PROPERTIES="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(json.dumps(d.get('properties',{})))")"

    BODY="$(python3 -c "
import json
email = '''$EMAIL'''
props = json.loads('''$PROPERTIES''')
if email and 'email' not in props:
    props['email'] = email
print(json.dumps({
  'inputs': [{
    'idProperty': 'email',
    'id': email,
    'properties': props
  }]
}))
")"

    HTTP_STATUS=$(curl -s -o /tmp/hubspot_response.json -w "%{http_code}" \
      -X POST \
      -H "Authorization: Bearer ${HUBSPOT_TOKEN:?HUBSPOT_TOKEN is required}" \
      -H "Content-Type: application/json" \
      -d "$BODY" \
      "https://api.hubapi.com/crm/v3/objects/contacts/batch/upsert")

    if [[ "$HTTP_STATUS" != "200" && "$HTTP_STATUS" != "201" ]]; then
      echo "ERROR: HubSpot API returned HTTP $HTTP_STATUS" >&2
      cat /tmp/hubspot_response.json >&2
      exit 1
    fi

    cat /tmp/hubspot_response.json
    echo "INFO: hubspot upsert succeeded (HTTP $HTTP_STATUS)" >&2
    ;;
  *)
    echo "ERROR: unknown action '$ACTION'" >&2
    exit 1
    ;;
esac
