#!/usr/bin/env bash
# clay.sh — sync data to Clay via webhook
# Docs: https://docs.clay.com/
# Actions: sync
set -euo pipefail

PAYLOAD="$(cat)"

if [[ -n "${DRY_RUN:-}" ]]; then
  echo "DRY_RUN: POST $CLAY_WEBHOOK_URL" >&2
  echo "PAYLOAD: $PAYLOAD" >&2
  exit 0
fi

ACTION="$(echo "$PAYLOAD" | python3 -c "import sys,json; print(json.load(sys.stdin).get('action','sync'))")"
echo "INFO: clay action=$ACTION" >&2

case "$ACTION" in
  sync)
    DATA="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(json.dumps(d.get('data',d)))")"

    HTTP_STATUS=$(curl -s -o /tmp/clay_response.json -w "%{http_code}" \
      -X POST \
      -H "Content-Type: application/json" \
      -d "$DATA" \
      "${CLAY_WEBHOOK_URL:?CLAY_WEBHOOK_URL is required}")

    if [[ "$HTTP_STATUS" != "200" && "$HTTP_STATUS" != "201" && "$HTTP_STATUS" != "202" ]]; then
      echo "ERROR: Clay webhook returned HTTP $HTTP_STATUS" >&2
      cat /tmp/clay_response.json >&2
      exit 1
    fi

    cat /tmp/clay_response.json
    echo "INFO: clay sync succeeded (HTTP $HTTP_STATUS)" >&2
    ;;
  *)
    echo "ERROR: unknown action '$ACTION'" >&2
    exit 1
    ;;
esac
