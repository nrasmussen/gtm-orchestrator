#!/usr/bin/env bash
# install-mcps.sh — OPTIONAL: registers MCP servers with Claude Code.
#
# This script is NOT required for the hooks in this repo. Every hook handler
# uses direct REST APIs (Slack/Discord webhooks, Notion REST, Figma REST,
# Linear GraphQL, etc.) and only needs the matching API token in .env.
#
# Use this only if you separately want Claude Code to be able to *interact*
# with these services from inside a session (search Slack, browse Notion,
# read Figma comments, etc.) — i.e. as a tool surface, not as a hook target.
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
echo "    Note: hooks in this repo do NOT need these MCPs — they hit REST APIs directly."

# Notion — official MCP
run claude mcp add notion \
  --transport stdio \
  -e NOTION_API_KEY="${NOTION_API_KEY:-}" \
  -- npx -y @notionhq/notion-mcp-server

# Slack — official MCP (requires bot token, not webhook)
run claude mcp add slack \
  --transport stdio \
  -e SLACK_BOT_TOKEN="${SLACK_BOT_TOKEN:-}" \
  -e SLACK_TEAM_ID="${SLACK_TEAM_ID:-}" \
  -- npx -y @modelcontextprotocol/server-slack

# Linear — official MCP
run claude mcp add linear \
  --transport stdio \
  -e LINEAR_API_KEY="${LINEAR_API_KEY:-}" \
  -- npx -y @linear/mcp-server

# Airtable — community MCP
run claude mcp add airtable \
  --transport stdio \
  -e AIRTABLE_TOKEN="${AIRTABLE_TOKEN:-}" \
  -e AIRTABLE_BASE_ID="${AIRTABLE_BASE_ID:-}" \
  -- npx -y airtable-mcp-server

# Attio — MCP
run claude mcp add attio \
  --transport stdio \
  -e ATTIO_API_KEY="${ATTIO_API_KEY:-}" \
  -- npx -y attio-mcp-server

# Figma — official MCP
run claude mcp add figma \
  --transport stdio \
  -e FIGMA_API_KEY="${FIGMA_API_KEY:-}" \
  -- npx -y figma-mcp

echo "==> Done."
