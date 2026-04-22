#!/usr/bin/env bash
# figma.sh — export assets from Figma via claude mcp call
# Docs: https://www.figma.com/developers/api
# Actions: export
set -euo pipefail

PAYLOAD="$(cat)"

if [[ -n "${DRY_RUN:-}" ]]; then
  echo "DRY_RUN: claude mcp call figma" >&2
  echo "PAYLOAD: $PAYLOAD" >&2
  exit 0
fi

ACTION="$(echo "$PAYLOAD" | python3 -c "import sys,json; print(json.load(sys.stdin).get('action','export'))")"
echo "INFO: figma action=$ACTION" >&2

run_mcp() {
  local tool_name="$1"
  local tool_input="$2"
  local result
  result="$(echo "$tool_input" | claude mcp call figma "$tool_name" 2>&1)"
  local exit_code=$?
  if [[ $exit_code -ne 0 ]]; then
    echo "ERROR: figma mcp call ($tool_name) failed: $result" >&2
    exit 1
  fi
  echo "$result"
}

case "$ACTION" in
  export)
    FILE_KEY="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('file_key',''))")"
    NODE_ID="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('node_id',''))")"
    FORMAT="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('format','png'))")"
    SCALE="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('scale',2))")"

    TOOL_INPUT="$(python3 -c "
import json
print(json.dumps({
  'fileKey': '''$FILE_KEY''',
  'nodeId': '''$NODE_ID''',
  'format': '''$FORMAT''',
  'scale': $SCALE
}))
")"
    run_mcp "get_screenshot" "$TOOL_INPUT"
    ;;
  *)
    echo "ERROR: unknown action '$ACTION'" >&2
    exit 1
    ;;
esac

echo "INFO: figma $ACTION complete" >&2
