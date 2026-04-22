#!/usr/bin/env bash
# install-mcps.sh — Registers MCP servers with Claude via `claude mcp add`.
#
# Servers configured: gmail, notion, slack, figma, linear, airtable, attio
#
# Set DRY_RUN=1 to print commands without executing them.

set -euo pipefail

DRY_RUN="${DRY_RUN:-0}"

run() {
  if [ "$DRY_RUN" = "1" ]; then
    echo "[DRY RUN] $*"
  else
    "$@"
  fi
}

echo "==> Installing MCP servers (DRY_RUN=${DRY_RUN}) ..."

# Gmail — Google OAuth MCP via npx
run claude mcp add gmail \
  --transport stdio \
  -- npx -y @gptscript-ai/mcp-server-gmail

# Notion — official Notion MCP via npx
run claude mcp add notion \
  --transport stdio \
  -e NOTION_API_KEY="${NOTION_API_KEY:-}" \
  -- npx -y @notionhq/notion-mcp-server

# Slack — official Slack MCP via npx
run claude mcp add slack \
  --transport stdio \
  -e SLACK_BOT_TOKEN="${SLACK_BOT_TOKEN:-}" \
  -e SLACK_TEAM_ID="${SLACK_TEAM_ID:-}" \
  -- npx -y @modelcontextprotocol/server-slack

# Figma — Figma MCP via npx
run claude mcp add figma \
  --transport stdio \
  -e FIGMA_API_KEY="${FIGMA_API_KEY:-}" \
  -- npx -y figma-mcp

# Linear — official Linear MCP via npx
run claude mcp add linear \
  --transport stdio \
  -e LINEAR_API_KEY="${LINEAR_API_KEY:-}" \
  -- npx -y @linear/mcp-server

# Airtable — community Airtable MCP via npx
run claude mcp add airtable \
  --transport stdio \
  -e AIRTABLE_TOKEN="${AIRTABLE_TOKEN:-}" \
  -e AIRTABLE_BASE_ID="${AIRTABLE_BASE_ID:-}" \
  -- npx -y airtable-mcp-server

# Attio — Attio MCP via npx
run claude mcp add attio \
  --transport stdio \
  -e ATTIO_API_KEY="${ATTIO_API_KEY:-}" \
  -- npx -y attio-mcp-server

echo "==> Done."
