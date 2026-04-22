#!/usr/bin/env bash
# zapier.sh — fire a Zapier webhook
# Docs: https://zapier.com/help/create/code-webhooks/trigger-zaps-from-webhooks
# Actions: fire
set -euo pipefail

PAYLOAD="$(cat)"

if [[ -n "${DRY_RUN:-}" ]]; then
  echo "DRY_RUN: POST $ZAPIER_WEBHOOK_URL" >&2
  echo "PAYLOAD: $PAYLOAD" >&2
  exit 0
fi

ACTION="$(echo "$PAYLOAD" | python3 -c "import sys,json; print(json.load(sys.stdin).get('action','fire'))")"
echo "INFO: zapier action=$ACTION" >&2

case "$ACTION" in
  fire)
    DATA="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(json.dumps(d.get('data',d)))")"

    HTTP_STATUS=$(curl -s -o /tmp/zapier_response.json -w "%{http_code}" \
      -X POST \
      -H "Content-Type: application/json" \
      -d "$DATA" \
      "${ZAPIER_WEBHOOK_URL:?ZAPIER_WEBHOOK_URL is required}")

    if [[ "$HTTP_STATUS" != "200" && "$HTTP_STATUS" != "201" && "$HTTP_STATUS" != "202" ]]; then
      echo "ERROR: Zapier webhook returned HTTP $HTTP_STATUS" >&2
      cat /tmp/zapier_response.json >&2
      exit 1
    fi

    cat /tmp/zapier_response.json
    echo "INFO: zapier fire succeeded (HTTP $HTTP_STATUS)" >&2
    ;;
  *)
    echo "ERROR: unknown action '$ACTION'" >&2
    exit 1
    ;;
esac
