#!/usr/bin/env bash
# sync-skills.sh — Pulls shared assets from two upstream repos:
#
#   janskuba/claude-md-repo  →  cloned to /tmp/cmr
#     skills/*               →  ./skills/
#     modules/               →  ./skills/modules/
#     templates/             →  ./skills/templates/
#     examples/              →  ./skills/examples/
#
#   janskuba/outbound-agents →  cloned to /tmp/oa
#     .claude/agents/*       →  ./agents/
#     .claude/commands/*     →  ./agents/commands/
#     examples/              →  ./agents/examples/
#     input/                 →  ./agents/input/
#
# Temporary clones are removed on completion.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

CMR_TMP=/tmp/cmr
OA_TMP=/tmp/oa

cleanup() {
  rm -rf "$CMR_TMP" "$OA_TMP"
}
trap cleanup EXIT

echo "==> Cloning janskuba/claude-md-repo ..."
rm -rf "$CMR_TMP"
gh repo clone janskuba/claude-md-repo "$CMR_TMP"

echo "==> Syncing skills from claude-md-repo ..."
mkdir -p "$ROOT/skills"

if [ -d "$CMR_TMP/skills" ]; then
  rsync -a --delete "$CMR_TMP/skills/" "$ROOT/skills/"
fi

if [ -d "$CMR_TMP/modules" ]; then
  mkdir -p "$ROOT/skills/modules"
  rsync -a --delete "$CMR_TMP/modules/" "$ROOT/skills/modules/"
fi

if [ -d "$CMR_TMP/templates" ]; then
  mkdir -p "$ROOT/skills/templates"
  rsync -a --delete "$CMR_TMP/templates/" "$ROOT/skills/templates/"
fi

if [ -d "$CMR_TMP/examples" ]; then
  mkdir -p "$ROOT/skills/examples"
  rsync -a --delete "$CMR_TMP/examples/" "$ROOT/skills/examples/"
fi

echo "==> Cloning janskuba/outbound-agents ..."
rm -rf "$OA_TMP"
gh repo clone janskuba/outbound-agents "$OA_TMP"

echo "==> Syncing agents from outbound-agents ..."
mkdir -p "$ROOT/agents"

if [ -d "$OA_TMP/.claude/agents" ]; then
  rsync -a --delete "$OA_TMP/.claude/agents/" "$ROOT/agents/"
fi

if [ -d "$OA_TMP/.claude/commands" ]; then
  mkdir -p "$ROOT/agents/commands"
  rsync -a --delete "$OA_TMP/.claude/commands/" "$ROOT/agents/commands/"
fi

if [ -d "$OA_TMP/examples" ]; then
  mkdir -p "$ROOT/agents/examples"
  rsync -a --delete "$OA_TMP/examples/" "$ROOT/agents/examples/"
fi

if [ -d "$OA_TMP/input" ]; then
  mkdir -p "$ROOT/agents/input"
  rsync -a --delete "$OA_TMP/input/" "$ROOT/agents/input/"
fi

echo "==> Done. Temporary clones cleaned up."
