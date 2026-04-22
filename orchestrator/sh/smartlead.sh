#!/usr/bin/env bash
# smartlead.sh — push leads to Smartlead via REST API
# Docs: https://documenter.getpostman.com/view/22873767/2s9YsNdpTw
# Endpoint: https://server.smartlead.ai/api/v1
# Actions: push
set -euo pipefail

PAYLOAD="$(cat)"

if [[ -n "${DRY_RUN:-}" ]]; then
  echo "DRY_RUN: POST https://server.smartlead.ai/api/v1/campaigns/<id>/leads" >&2
  echo "PAYLOAD: $PAYLOAD" >&2
  exit 0
fi

ACTION="$(echo "$PAYLOAD" | python3 -c "import sys,json; print(json.load(sys.stdin).get('action','push'))")"
echo "INFO: smartlead action=$ACTION" >&2

case "$ACTION" in
  push)
    CAMPAIGN_ID="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('campaign_id',''))")"
    EMAIL="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('email',''))")"
    FIRST_NAME="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('first_name',''))")"
    LAST_NAME="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('last_name',''))")"
    COMPANY="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('company',''))")"

    BODY="$(python3 -c "
import json
print(json.dumps({
  'lead_list': [{
    'email': '''$EMAIL''',
    'first_name': '''$FIRST_NAME''',
    'last_name': '''$LAST_NAME''',
    'company_name': '''$COMPANY'''
  }],
  'settings': {
    'ignore_global_block_list': False,
    'ignore_unsubscribe_list': False,
    'ignore_community_bounce_list': False
  }
}))
")"

    HTTP_STATUS=$(curl -s -o /tmp/smartlead_response.json -w "%{http_code}" \
      -X POST \
      -H "Content-Type: application/json" \
      -d "$BODY" \
      "https://server.smartlead.ai/api/v1/campaigns/${CAMPAIGN_ID:?campaign_id is required}/leads?api_key=${SMARTLEAD_API_KEY:?SMARTLEAD_API_KEY is required}")

    if [[ "$HTTP_STATUS" != "200" && "$HTTP_STATUS" != "201" ]]; then
      echo "ERROR: Smartlead API returned HTTP $HTTP_STATUS" >&2
      cat /tmp/smartlead_response.json >&2
      exit 1
    fi

    cat /tmp/smartlead_response.json
    echo "INFO: smartlead push succeeded (HTTP $HTTP_STATUS)" >&2
    ;;
  *)
    echo "ERROR: unknown action '$ACTION'" >&2
    exit 1
    ;;
esac
