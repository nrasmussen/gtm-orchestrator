#!/usr/bin/env bash
# gmail.sh — interact with Gmail via claude mcp call (Gmail MCP)
# Docs: https://developers.google.com/gmail/api/reference/rest
# Actions: digest, draft
set -euo pipefail

PAYLOAD="$(cat)"

if [[ -n "${DRY_RUN:-}" ]]; then
  echo "DRY_RUN: claude mcp call gmail" >&2
  echo "PAYLOAD: $PAYLOAD" >&2
  exit 0
fi

ACTION="$(echo "$PAYLOAD" | python3 -c "import sys,json; print(json.load(sys.stdin).get('action','digest'))")"
echo "INFO: gmail action=$ACTION" >&2

case "$ACTION" in
  digest)
    QUERY="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('query','is:unread'))")"
    MAX_RESULTS="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('max_results',10))")"
    TOOL_INPUT="$(python3 -c "import json; print(json.dumps({'query': '''$QUERY''', 'maxResults': $MAX_RESULTS}))")"
    RESULT="$(echo "$TOOL_INPUT" | claude mcp call gmail search_threads 2>&1)"
    if [[ $? -ne 0 ]]; then
      echo "ERROR: gmail mcp call failed: $RESULT" >&2
      exit 1
    fi
    echo "$RESULT"
    ;;
  draft)
    TO="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('to',''))")"
    SUBJECT="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('subject',''))")"
    BODY_TEXT="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('body',''))")"
    TOOL_INPUT="$(python3 -c "
import json
print(json.dumps({
  'to': '''$TO''',
  'subject': '''$SUBJECT''',
  'body': '''$BODY_TEXT'''
}))
")"
    RESULT="$(echo "$TOOL_INPUT" | claude mcp call gmail create_draft 2>&1)"
    if [[ $? -ne 0 ]]; then
      echo "ERROR: gmail mcp call failed: $RESULT" >&2
      exit 1
    fi
    echo "$RESULT"
    ;;
  *)
    echo "ERROR: unknown action '$ACTION'" >&2
    exit 1
    ;;
esac

echo "INFO: gmail $ACTION complete" >&2
