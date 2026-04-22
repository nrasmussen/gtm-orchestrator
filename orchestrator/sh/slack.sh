#!/usr/bin/env bash
# slack.sh — post messages to Slack via incoming webhook
# Docs: https://api.slack.com/messaging/webhooks
# Actions: notify, approval, daily-digest
set -euo pipefail

PAYLOAD="$(cat)"

if [[ -n "${DRY_RUN:-}" ]]; then
  echo "DRY_RUN: POST $SLACK_WEBHOOK_URL" >&2
  echo "PAYLOAD: $PAYLOAD" >&2
  exit 0
fi

ACTION="$(echo "$PAYLOAD" | python3 -c "import sys,json; print(json.load(sys.stdin).get('action','notify'))")"
echo "INFO: slack action=$ACTION" >&2

case "$ACTION" in
  notify)
    TEXT="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('text',''))")"
    CHANNEL="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('channel',''))")"
    BODY="{\"text\": $(echo "$TEXT" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read().rstrip()))")}"
    if [[ -n "$CHANNEL" ]]; then
      BODY="$(echo "$BODY" | python3 -c "import sys,json; d=json.load(sys.stdin); d['channel']='$CHANNEL'; print(json.dumps(d))")"
    fi
    ;;
  approval)
    TEXT="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('text','Approval required'))")"
    BODY="$(python3 -c "
import json, sys
text = '''$TEXT'''
body = {
  'text': text,
  'attachments': [{
    'fallback': text,
    'callback_id': 'approval_request',
    'color': 'warning',
    'actions': [
      {'name': 'approve', 'text': 'Approve', 'type': 'button', 'value': 'approve', 'style': 'primary'},
      {'name': 'deny',    'text': 'Deny',    'type': 'button', 'value': 'deny',    'style': 'danger'}
    ]
  }]
}
print(json.dumps(body))
")"
    ;;
  daily-digest)
    ITEMS="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print('\n'.join(d.get('items',[])))")"
    TITLE="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('title','Daily Digest'))")"
    BODY="$(python3 -c "
import json
title = '''$TITLE'''
items = '''$ITEMS'''
blocks = [{'type':'section','text':{'type':'mrkdwn','text':'*' + title + '*'}}]
for item in items.splitlines():
    if item.strip():
        blocks.append({'type':'section','text':{'type':'mrkdwn','text': item.strip()}})
print(json.dumps({'blocks': blocks}))
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
  "${SLACK_WEBHOOK_URL:?SLACK_WEBHOOK_URL is required}")

if [[ "$HTTP_STATUS" != "200" ]]; then
  echo "ERROR: Slack webhook returned HTTP $HTTP_STATUS" >&2
  exit 1
fi

echo "INFO: slack $ACTION sent (HTTP $HTTP_STATUS)" >&2
