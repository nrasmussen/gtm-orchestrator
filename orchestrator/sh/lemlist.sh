#!/usr/bin/env bash
# lemlist.sh — manage leads and sequences in Lemlist via REST API
# Docs: https://developer.lemlist.com/
# Endpoint: https://api.lemlist.com/api
# Actions: add-lead, push-sequence
set -euo pipefail

PAYLOAD="$(cat)"

if [[ -n "${DRY_RUN:-}" ]]; then
  echo "DRY_RUN: lemlist REST API call" >&2
  echo "PAYLOAD: $PAYLOAD" >&2
  exit 0
fi

ACTION="$(echo "$PAYLOAD" | python3 -c "import sys,json; print(json.load(sys.stdin).get('action','add-lead'))")"
echo "INFO: lemlist action=$ACTION" >&2

AUTH_HEADER="Authorization: Basic $(echo -n ":${LEMLIST_API_KEY:?LEMLIST_API_KEY is required}" | base64)"

case "$ACTION" in
  add-lead)
    CAMPAIGN_ID="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('campaign_id',''))")"
    EMAIL="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('email',''))")"
    FIRST_NAME="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('first_name',''))")"
    LAST_NAME="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('last_name',''))")"
    COMPANY="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('company',''))")"

    BODY="$(python3 -c "
import json
print(json.dumps({
  'email': '''$EMAIL''',
  'firstName': '''$FIRST_NAME''',
  'lastName': '''$LAST_NAME''',
  'companyName': '''$COMPANY'''
}))
")"

    HTTP_STATUS=$(curl -s -o /tmp/lemlist_response.json -w "%{http_code}" \
      -X POST \
      -H "$AUTH_HEADER" \
      -H "Content-Type: application/json" \
      -d "$BODY" \
      "https://api.lemlist.com/api/campaigns/${CAMPAIGN_ID:?campaign_id is required}/leads/${EMAIL:?email is required}")

    if [[ "$HTTP_STATUS" != "200" && "$HTTP_STATUS" != "201" ]]; then
      echo "ERROR: Lemlist API returned HTTP $HTTP_STATUS" >&2
      cat /tmp/lemlist_response.json >&2
      exit 1
    fi

    cat /tmp/lemlist_response.json
    echo "INFO: lemlist add-lead succeeded (HTTP $HTTP_STATUS)" >&2
    ;;
  push-sequence)
    CAMPAIGN_ID="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('campaign_id',''))")"
    EMAIL="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('email',''))")"
    DEDUPLICATE="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(str(d.get('deduplicate',True)).lower())")"

    HTTP_STATUS=$(curl -s -o /tmp/lemlist_response.json -w "%{http_code}" \
      -X POST \
      -H "$AUTH_HEADER" \
      -H "Content-Type: application/json" \
      -d "{\"email\": \"$EMAIL\", \"deduplicate\": $DEDUPLICATE}" \
      "https://api.lemlist.com/api/campaigns/${CAMPAIGN_ID:?campaign_id is required}/leads/${EMAIL:?email is required}/start")

    if [[ "$HTTP_STATUS" != "200" && "$HTTP_STATUS" != "201" ]]; then
      echo "ERROR: Lemlist API returned HTTP $HTTP_STATUS" >&2
      cat /tmp/lemlist_response.json >&2
      exit 1
    fi

    cat /tmp/lemlist_response.json
    echo "INFO: lemlist push-sequence succeeded (HTTP $HTTP_STATUS)" >&2
    ;;
  *)
    echo "ERROR: unknown action '$ACTION'" >&2
    exit 1
    ;;
esac
