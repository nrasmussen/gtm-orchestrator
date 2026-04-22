#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# ---------------------------------------------------------------------------
# .env handling
# ---------------------------------------------------------------------------

if [ ! -f "$REPO_ROOT/.env" ]; then
  echo "[WARN] .env not found. Run: cp .env.example .env"
  echo "       Then fill in your API keys before running this script again."
else
  # Source without executing expansions for unset vars
  set +u
  # shellcheck disable=SC1090
  source "$REPO_ROOT/.env"
  set -u
fi

# ---------------------------------------------------------------------------
# Helper
# ---------------------------------------------------------------------------

check_var() {
  local name="$1"
  local value="${!name:-}"
  if [ -n "$value" ]; then
    echo "  [OK]      $name"
    return 0
  else
    echo "  [MISSING] $name"
    return 1
  fi
}

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

# ---------------------------------------------------------------------------
# Integrations by category
# ---------------------------------------------------------------------------

echo ""
echo "=== Notifications ==="
check_integration SLACK_WEBHOOK_URL
check_integration DISCORD_WEBHOOK_URL

echo ""
echo "=== CRM ==="
check_integration ATTIO_API_KEY
check_integration HUBSPOT_TOKEN
check_integration AIRTABLE_TOKEN
check_integration AIRTABLE_BASE_ID

echo ""
echo "=== Outbound ==="
check_integration LEMLIST_API_KEY
check_integration INSTANTLY_API_KEY
check_integration SMARTLEAD_API_KEY
check_integration CLAY_WEBHOOK_URL

echo ""
echo "=== Content ==="
check_integration TYPEFULLY_API_KEY

echo ""
echo "=== Automation ==="
check_integration ZAPIER_WEBHOOK_URL
check_integration N8N_WEBHOOK_URL
check_integration MAKE_WEBHOOK_URL

# ---------------------------------------------------------------------------
# CLAUDE_GTM_DIR
# ---------------------------------------------------------------------------

echo ""
echo "=== Environment ==="

CLAUDE_GTM_DIR_VALUE="${CLAUDE_GTM_DIR:-}"
if [ -z "$CLAUDE_GTM_DIR_VALUE" ]; then
  # Attempt auto-detection: use repo root if it looks right
  if [ -f "$REPO_ROOT/.env.example" ]; then
    echo "  [OK]      CLAUDE_GTM_DIR (auto-detected: $REPO_ROOT)"
    CLAUDE_GTM_DIR_VALUE="$REPO_ROOT"
  else
    echo "  [MISSING] CLAUDE_GTM_DIR (run scripts/setup.sh to configure)"
  fi
else
  echo "  [OK]      CLAUDE_GTM_DIR=$CLAUDE_GTM_DIR_VALUE"
fi

# ---------------------------------------------------------------------------
# ~/.claude/settings.json hooks check
# ---------------------------------------------------------------------------

echo ""
echo "=== Claude Hooks ==="

SETTINGS_FILE="$HOME/.claude/settings.json"
hooks_found=()

if [ ! -f "$SETTINGS_FILE" ]; then
  echo "  [MISSING] ~/.claude/settings.json not found"
else
  if command -v python3 &>/dev/null; then
    hooks_raw=$(python3 -c "
import json, sys
try:
    data = json.load(open('$SETTINGS_FILE'))
    hooks = data.get('hooks', {})
    names = []
    for event, entries in hooks.items():
        if isinstance(entries, list):
            for entry in entries:
                if isinstance(entry, dict):
                    for matcher in entry.get('hooks', []):
                        cmd = matcher.get('command', '')
                        if cmd:
                            names.append(event + ':' + cmd[:60])
                elif isinstance(entry, str):
                    names.append(event + ':' + entry[:60])
        elif isinstance(entries, dict):
            names.append(event + ':' + str(entries)[:60])
    print('\n'.join(names) if names else '')
except Exception as e:
    print('')
" 2>/dev/null || true)
    if [ -n "$hooks_raw" ]; then
      echo "  [OK]      ~/.claude/settings.json contains hooks:"
      while IFS= read -r line; do
        [ -n "$line" ] && echo "            - $line"
        hooks_found+=("$line")
      done <<< "$hooks_raw"
    else
      echo "  [OK]      ~/.claude/settings.json exists but no hooks configured"
    fi
  else
    if grep -q '"hooks"' "$SETTINGS_FILE" 2>/dev/null; then
      echo "  [OK]      ~/.claude/settings.json exists and contains a 'hooks' key"
    else
      echo "  [OK]      ~/.claude/settings.json exists but no hooks key found"
    fi
  fi
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

echo ""
echo "=============================="
echo "Summary"
echo "=============================="
echo "$configured of $total integrations configured."

if [ "$configured" -eq 0 ]; then
  echo "No integrations are ready. Fill in .env to get started."
else
  echo ""
  echo "Ready to use:"

  # Notifications
  [ -n "${SLACK_WEBHOOK_URL:-}" ]    && echo "  - Slack notifications (hooks/notifications/slack-*)"
  [ -n "${DISCORD_WEBHOOK_URL:-}" ]  && echo "  - Discord notifications (hooks/notifications/discord-*)"

  # CRM
  [ -n "${ATTIO_API_KEY:-}" ]        && echo "  - Attio CRM sync (hooks/crm/attio-*)"
  [ -n "${HUBSPOT_TOKEN:-}" ]        && echo "  - HubSpot CRM sync (hooks/crm/hubspot-*)"
  if [ -n "${AIRTABLE_TOKEN:-}" ] && [ -n "${AIRTABLE_BASE_ID:-}" ]; then
    echo "  - Airtable logging (hooks/crm/airtable-*)"
  fi

  # Outbound
  [ -n "${LEMLIST_API_KEY:-}" ]      && echo "  - Lemlist outbound (hooks/outbound/lemlist-*)"
  [ -n "${INSTANTLY_API_KEY:-}" ]    && echo "  - Instantly campaigns (hooks/outbound/instantly-*)"
  [ -n "${SMARTLEAD_API_KEY:-}" ]    && echo "  - Smartlead campaigns (hooks/outbound/smartlead-*)"
  [ -n "${CLAY_WEBHOOK_URL:-}" ]     && echo "  - Clay table sync (hooks/outbound/clay-*)"

  # Content
  [ -n "${TYPEFULLY_API_KEY:-}" ]    && echo "  - Typefully draft queue (hooks/content/typefully-*)"

  # Automation
  [ -n "${ZAPIER_WEBHOOK_URL:-}" ]   && echo "  - Zapier automation (hooks/automation/zapier-*)"
  [ -n "${N8N_WEBHOOK_URL:-}" ]      && echo "  - n8n automation (hooks/automation/n8n-*)"
  [ -n "${MAKE_WEBHOOK_URL:-}" ]     && echo "  - Make automation (hooks/automation/make-*)"
fi

echo ""
