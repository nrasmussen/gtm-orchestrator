#!/usr/bin/env bash
# typefully.sh — create draft tweets/threads in Typefully via REST API
# Docs: https://typefully.com/developer
# Endpoint: https://api.typefully.com/v1
# Actions: draft
set -euo pipefail

PAYLOAD="$(cat)"

if [[ -n "${DRY_RUN:-}" ]]; then
  echo "DRY_RUN: POST https://api.typefully.com/v1/drafts/" >&2
  echo "PAYLOAD: $PAYLOAD" >&2
  exit 0
fi

ACTION="$(echo "$PAYLOAD" | python3 -c "import sys,json; print(json.load(sys.stdin).get('action','draft'))")"
echo "INFO: typefully action=$ACTION" >&2

case "$ACTION" in
  draft)
    CONTENT="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('content',''))")"
    SCHEDULE_DATE="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('schedule_date',''))")"
    AUTO_RETWEET="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(str(d.get('auto_retweet',False)).lower())")"
    AUTO_PLUG="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(str(d.get('auto_plug',False)).lower())")"

    BODY="$(python3 -c "
import json
body = {
  'content': '''$CONTENT''',
  'auto-retweet-enabled': $AUTO_RETWEET == 'true',
  'auto-plug-enabled': $AUTO_PLUG == 'true'
}
schedule = '''$SCHEDULE_DATE'''
if schedule:
    body['schedule-date'] = schedule
print(json.dumps(body))
")"

    HTTP_STATUS=$(curl -s -o /tmp/typefully_response.json -w "%{http_code}" \
      -X POST \
      -H "X-API-KEY: ${TYPEFULLY_API_KEY:?TYPEFULLY_API_KEY is required}" \
      -H "Content-Type: application/json" \
      -d "$BODY" \
      "https://api.typefully.com/v1/drafts/")

    if [[ "$HTTP_STATUS" != "200" && "$HTTP_STATUS" != "201" ]]; then
      echo "ERROR: Typefully API returned HTTP $HTTP_STATUS" >&2
      cat /tmp/typefully_response.json >&2
      exit 1
    fi

    cat /tmp/typefully_response.json
    echo "INFO: typefully draft succeeded (HTTP $HTTP_STATUS)" >&2
    ;;
  *)
    echo "ERROR: unknown action '$ACTION'" >&2
    exit 1
    ;;
esac
