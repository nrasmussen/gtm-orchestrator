#!/usr/bin/env bash
# notion.sh — interact with Notion via claude mcp call (Notion MCP)
# Docs: https://developers.notion.com/reference
# Actions: log-session, cost-log, save-content, save-design, design-doc
set -euo pipefail

PAYLOAD="$(cat)"

if [[ -n "${DRY_RUN:-}" ]]; then
  echo "DRY_RUN: claude mcp call notion" >&2
  echo "PAYLOAD: $PAYLOAD" >&2
  exit 0
fi

ACTION="$(echo "$PAYLOAD" | python3 -c "import sys,json; print(json.load(sys.stdin).get('action','log-session'))")"
echo "INFO: notion action=$ACTION" >&2

run_mcp() {
  local tool_name="$1"
  local tool_input="$2"
  local result
  result="$(echo "$tool_input" | claude mcp call notion "$tool_name" 2>&1)"
  local exit_code=$?
  if [[ $exit_code -ne 0 ]]; then
    echo "ERROR: notion mcp call ($tool_name) failed: $result" >&2
    exit 1
  fi
  echo "$result"
}

case "$ACTION" in
  log-session)
    PARENT_ID="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('parent_id',''))")"
    TITLE="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('title','Session Log'))")"
    CONTENT="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('content',''))")"
    TOOL_INPUT="$(python3 -c "
import json
print(json.dumps({
  'parent': {'page_id': '''$PARENT_ID'''},
  'properties': {'title': {'title': [{'text': {'content': '''$TITLE'''}}]}},
  'children': [{'object':'block','type':'paragraph','paragraph':{'rich_text':[{'text':{'content':'''$CONTENT'''}}]}}]
}))
")"
    run_mcp "notion-create-pages" "$TOOL_INPUT"
    ;;
  cost-log)
    PARENT_ID="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('parent_id',''))")"
    AMOUNT="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('amount','0'))")"
    DESCRIPTION="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('description',''))")"
    TOOL_INPUT="$(python3 -c "
import json
print(json.dumps({
  'parent': {'database_id': '''$PARENT_ID'''},
  'properties': {
    'Description': {'title': [{'text': {'content': '''$DESCRIPTION'''}}]},
    'Amount': {'number': float('''$AMOUNT''')}
  }
}))
")"
    run_mcp "notion-create-pages" "$TOOL_INPUT"
    ;;
  save-content)
    PARENT_ID="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('parent_id',''))")"
    TITLE="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('title','Content'))")"
    CONTENT="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('content',''))")"
    TOOL_INPUT="$(python3 -c "
import json
print(json.dumps({
  'parent': {'page_id': '''$PARENT_ID'''},
  'properties': {'title': {'title': [{'text': {'content': '''$TITLE'''}}]}},
  'children': [{'object':'block','type':'paragraph','paragraph':{'rich_text':[{'text':{'content':'''$CONTENT'''}}]}}]
}))
")"
    run_mcp "notion-create-pages" "$TOOL_INPUT"
    ;;
  save-design)
    PARENT_ID="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('parent_id',''))")"
    TITLE="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('title','Design'))")"
    CONTENT="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('content',''))")"
    FIGMA_URL="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('figma_url',''))")"
    TOOL_INPUT="$(python3 -c "
import json
children = [{'object':'block','type':'paragraph','paragraph':{'rich_text':[{'text':{'content':'''$CONTENT'''}}]}}]
if '''$FIGMA_URL''':
    children.append({'object':'block','type':'bookmark','bookmark':{'url':'''$FIGMA_URL'''}})
print(json.dumps({
  'parent': {'page_id': '''$PARENT_ID'''},
  'properties': {'title': {'title': [{'text': {'content': '''$TITLE'''}}]}},
  'children': children
}))
")"
    run_mcp "notion-create-pages" "$TOOL_INPUT"
    ;;
  design-doc)
    PARENT_ID="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('parent_id',''))")"
    TITLE="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('title','Design Doc'))")"
    SECTIONS="$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(json.dumps(d.get('sections',[])))")"
    TOOL_INPUT="$(python3 -c "
import json
sections = json.loads('''$SECTIONS''')
children = []
for s in sections:
    children.append({'object':'block','type':'heading_2','heading_2':{'rich_text':[{'text':{'content':s.get('heading','')}}]}})
    children.append({'object':'block','type':'paragraph','paragraph':{'rich_text':[{'text':{'content':s.get('body','')}}]}})
print(json.dumps({
  'parent': {'page_id': '''$PARENT_ID'''},
  'properties': {'title': {'title': [{'text': {'content': '''$TITLE'''}}]}},
  'children': children
}))
")"
    run_mcp "notion-create-pages" "$TOOL_INPUT"
    ;;
  *)
    echo "ERROR: unknown action '$ACTION'" >&2
    exit 1
    ;;
esac

echo "INFO: notion $ACTION complete" >&2
