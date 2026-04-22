#!/usr/bin/env bash
# instantly.sh — push leads to Instantly.ai via REST API
# Docs: https://developer.instantly.ai/
# Endpoint: https://api.instantly.ai/api/v1
# Actions: push
set -euo pipefail

PAYLOAD="$(cat)"

if [[ -n "${DRY_RUN:-}" ]]; then
  echo "DRY_RUN: POST https://api.instantly.ai/api/v1/lead/add" >&2
  echo "PAYLOAD: $PAYLOAD" >&2
  exit 0
fi

ACTION="$(echo "$PAYLOAD" | python3 -c "import sys,json; print(json.load(sys.stdin).get('action','push'))")"
echo "INFO: instantly action=$ACTION" >&2

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
  'api_key': '${INSTANTLY_API_KEY:?INSTANTLY_API_KEY is required}',
  'campaign_id': '''$CAMPAIGN_ID''',
  'leads': [{
    'email': '''$EMAIL''',
    'first_name': '''$FIRST_NAME''',
    'last_name': '''$LAST_NAME''',
    'company_name': '''$COMPANY'''
  }],
  'skip_if_in_workspace': True
}))
")"

    HTTP_STATUS=$(curl -s -o /tmp/instantly_response.json -w "%{http_code}" \
      -X POST \
      -H "Content-Type: application/json" \
      -d "$BODY" \
      "https://api.instantly.ai/api/v1/lead/add")

    if [[ "$HTTP_STATUS" != "200" && "$HTTP_STATUS" != "201" ]]; then
      echo "ERROR: Instantly API returned HTTP $HTTP_STATUS" >&2
      cat /tmp/instantly_response.json >&2
      exit 1
    fi

    cat /tmp/instantly_response.json
    echo "INFO: instantly push succeeded (HTTP $HTTP_STATUS)" >&2
    ;;
  *)
    echo "ERROR: unknown action '$ACTION'" >&2
    exit 1
    ;;
esac
