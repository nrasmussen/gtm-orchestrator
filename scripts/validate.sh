#!/usr/bin/env bash
# validate.sh — Verify the repo is in a working state and report which
# integrations are configured.
#
# Checks:
#   1. Every hook.json (and starter pack) is valid against the Claude Code schema.
#   2. Every Python handler compiles cleanly.
#   3. Every handler runs successfully with DRY_RUN=1 and a fixture payload.
#   4. Per-integration env-var readiness.
#   5. ~/.claude/settings.json hook introspection.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ -f "$ROOT/.env" ]; then
  set +u
  # shellcheck disable=SC1091
  source "$ROOT/.env"
  set -u
fi

fail=0

echo "=== 1. Hook schema validation ==="
if ! python3 "$ROOT/scripts/lib/validate-hook-json.py" \
       "$ROOT"/hooks/*/*/hook.json "$ROOT"/examples/full-settings-*.json | tail -n 0; then
  fail=1
fi
python3 "$ROOT/scripts/lib/validate-hook-json.py" \
       "$ROOT"/hooks/*/*/hook.json "$ROOT"/examples/full-settings-*.json \
  | grep -E "^FAIL|^     " || echo "  all hook.json files pass schema."

echo ""
echo "=== 2. Python handler syntax ==="
if python3 -m py_compile "$ROOT"/orchestrator/dispatch.py "$ROOT"/orchestrator/py/*.py 2>/dev/null; then
  echo "  all handlers compile."
else
  echo "  FAILED: see errors above"
  fail=1
fi

echo ""
echo "=== 3. Dry-run smoke tests ==="
export DRY_RUN=1
fixture='{"action":"smoke","email":"test@example.com","content":"smoke","title":"smoke","file_key":"abc","node_id":"1:1","campaign_id":"c","table":"t","fields":{},"team_id":"t","query":"is:unread","data":{}}'
for handler in "$ROOT"/orchestrator/py/*.py; do
  name="$(basename "$handler" .py)"
  if echo "$fixture" | python3 "$handler" >/dev/null 2>&1; then
    echo "  [OK]      $name"
  else
    echo "  [FAIL]    $name"
    fail=1
  fi
done
unset DRY_RUN

# ---------------------------------------------------------------------------
# 4. Env vars
# ---------------------------------------------------------------------------
configured=0
total=0
check_integration() {
  local name="$1"
  total=$((total + 1))
  local value="${!name:-}"
  if [ -n "$value" ]; then
    configured=$((configured + 1))
    echo "  [OK]      $name"
  else
    echo "  [MISSING] $name"
  fi
}

echo ""
echo "=== 4. Integration env vars ==="
echo "--- Notifications ---"
check_integration SLACK_WEBHOOK_URL
check_integration DISCORD_WEBHOOK_URL
echo "--- CRM ---"
check_integration ATTIO_API_KEY
check_integration HUBSPOT_TOKEN
check_integration AIRTABLE_TOKEN
check_integration AIRTABLE_BASE_ID
check_integration APOLLO_API_KEY
echo "--- Outbound ---"
check_integration LEMLIST_API_KEY
check_integration INSTANTLY_API_KEY
check_integration SMARTLEAD_API_KEY
check_integration CLAY_WEBHOOK_URL
echo "--- Content / Design ---"
check_integration TYPEFULLY_API_KEY
check_integration NOTION_API_KEY
check_integration FIGMA_API_KEY
check_integration LINEAR_API_KEY
echo "--- Automation ---"
check_integration ZAPIER_WEBHOOK_URL
check_integration N8N_WEBHOOK_URL
check_integration MAKE_WEBHOOK_URL
echo "--- Data / Sheets ---"
check_integration GOOGLE_SHEETS_API_KEY
check_integration GOOGLE_SHEETS_SPREADSHEET_ID

echo ""
echo "=== 5. CLAUDE_GTM_DIR ==="
if [ -n "${CLAUDE_GTM_DIR:-}" ]; then
  echo "  [OK]      CLAUDE_GTM_DIR=$CLAUDE_GTM_DIR"
else
  echo "  [MISSING] CLAUDE_GTM_DIR (run ./scripts/install.sh or export manually)"
fi

echo ""
echo "=== 6. Claude settings.json hooks ==="
SETTINGS_FILE="$HOME/.claude/settings.json"
if [ ! -f "$SETTINGS_FILE" ]; then
  echo "  [INFO]    $SETTINGS_FILE not found; run ./scripts/install.sh to install hooks"
else
  python3 - "$SETTINGS_FILE" <<'PY' || true
import json, sys
data = json.load(open(sys.argv[1]))
hooks = data.get("hooks", {})
n = 0
for ev, entries in hooks.items():
    if isinstance(entries, list):
        for entry in entries:
            if isinstance(entry, dict):
                for h in entry.get("hooks", []):
                    if isinstance(h, dict) and "$CLAUDE_GTM_DIR" in h.get("command", ""):
                        print(f"  [OK]      {ev}: {h['command'][:80]}")
                        n += 1
if n == 0:
    print("  [INFO]    no GTM hooks installed in settings.json")
PY
fi

echo ""
echo "=============================="
echo "$configured of $total integrations configured."
[ "$fail" = "0" ] && echo "validate: PASS" || { echo "validate: FAIL"; exit 1; }
