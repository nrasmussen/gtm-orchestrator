#!/usr/bin/env bash
# discord.sh — post messages to Discord via incoming webhook
# Docs: https://discord.com/developers/docs/resources/webhook#execute-webhook
# Actions: notify
set -euo pipefail

PAYLOAD="$(cat)"

if [[ -n "${DRY_RUN:-}" ]]; then
  echo "DRY_RUN: POST $DISCORD_WEBHOOK_URL" >&2
  echo "PAYLOAD: $PAYLOAD" >&2
  exit 0
fi

ACTION="$(echo "$PAYLOAD" | python3 -c "import sys,json; print(json.load(sys.stdin).get('action','notify'))")"
echo "INFO: discord action=$ACTION" >&2

case "$ACTION" in
  notify)
    CONTENT="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('text', d.get('content','')))")"
    USERNAME="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('username','Orchestrator'))")"
    BODY="$(python3 -c "
import json
print(json.dumps({'content': '''$CONTENT''', 'username': '''$USERNAME'''}))
")"
    ;;
  *)
    echo "ERROR: unknown action '$ACTION'" >&2
    exit 1
    ;;
esac

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
  -X POST \
  -H "Content-Type: application/json" \
  -d "$BODY" \
  "${DISCORD_WEBHOOK_URL:?DISCORD_WEBHOOK_URL is required}")

if [[ "$HTTP_STATUS" != "204" && "$HTTP_STATUS" != "200" ]]; then
  echo "ERROR: Discord webhook returned HTTP $HTTP_STATUS" >&2
  exit 1
fi

echo "INFO: discord $ACTION sent (HTTP $HTTP_STATUS)" >&2
