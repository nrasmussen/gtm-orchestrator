#!/usr/bin/env bash
# linear.sh — create tickets and versions in Linear via claude mcp call
# Docs: https://developers.linear.app/docs
# Actions: create-ticket, version
set -euo pipefail

PAYLOAD="$(cat)"

if [[ -n "${DRY_RUN:-}" ]]; then
  echo "DRY_RUN: claude mcp call linear" >&2
  echo "PAYLOAD: $PAYLOAD" >&2
  exit 0
fi

ACTION="$(echo "$PAYLOAD" | python3 -c "import sys,json; print(json.load(sys.stdin).get('action','create-ticket'))")"
echo "INFO: linear action=$ACTION" >&2

run_mcp() {
  local tool_name="$1"
  local tool_input="$2"
  local result
  result="$(echo "$tool_input" | claude mcp call linear "$tool_name" 2>&1)"
  local exit_code=$?
  if [[ $exit_code -ne 0 ]]; then
    echo "ERROR: linear mcp call ($tool_name) failed: $result" >&2
    exit 1
  fi
  echo "$result"
}

case "$ACTION" in
  create-ticket)
    TITLE="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('title',''))")"
    DESCRIPTION="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('description',''))")"
    TEAM_ID="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('team_id',''))")"
    PRIORITY="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('priority',0))")"
    LABEL_IDS="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(json.dumps(d.get('label_ids',[])))")"

    TOOL_INPUT="$(python3 -c "
import json
print(json.dumps({
  'title': '''$TITLE''',
  'description': '''$DESCRIPTION''',
  'teamId': '''$TEAM_ID''',
  'priority': $PRIORITY,
  'labelIds': json.loads('''$LABEL_IDS''')
}))
")"
    run_mcp "create_issue" "$TOOL_INPUT"
    ;;
  version)
    TEAM_ID="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('team_id',''))")"
    NAME="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('name',''))")"
    TARGET_DATE="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('target_date',''))")"
    DESCRIPTION="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('description',''))")"

    TOOL_INPUT="$(python3 -c "
import json
print(json.dumps({
  'teamId': '''$TEAM_ID''',
  'name': '''$NAME''',
  'targetDate': '''$TARGET_DATE''',
  'description': '''$DESCRIPTION'''
}))
")"
    run_mcp "create_project" "$TOOL_INPUT"
    ;;
  *)
    echo "ERROR: unknown action '$ACTION'" >&2
    exit 1
    ;;
esac

echo "INFO: linear $ACTION complete" >&2
