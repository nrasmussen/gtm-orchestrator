#!/usr/bin/env bash
# sync-skills.sh — Optionally pulls shared assets from two upstream repos.
#
#   janskuba/claude-md-repo  →  /tmp/cmr
#     skills/*               →  ./skills/<name>/SKILL.md  (transformed if flat)
#     modules/               →  ./skills/modules/
#     templates/             →  ./skills/templates/
#     examples/              →  ./skills/examples/
#
#   janskuba/outbound-agents →  /tmp/oa
#     .claude/agents/*       →  ./agents/
#     .claude/commands/*     →  ./agents/commands/
#     examples/              →  ./agents/examples/
#     input/                 →  ./agents/input/
#
# This is OPTIONAL. The repo ships with vendored copies of skills/ and agents/,
# so a fresh clone works without running this script. Use --no-upstream to
# skip cloning; the script will still normalize any flat skills/*.md files
# already present in the working tree to skills/<name>/SKILL.md.
#
# Requires `gh` CLI for upstream cloning.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

NO_UPSTREAM=0
for arg in "$@"; do
  case "$arg" in
    --no-upstream) NO_UPSTREAM=1 ;;
    -h|--help)
      sed -n '2,20p' "$0"; exit 0 ;;
    *) echo "Unknown arg: $arg" >&2; exit 2 ;;
  esac
done

normalize_skills_layout() {
  # Convert any flat skills/<name>.md into skills/<name>/SKILL.md.
  local skills_dir="$ROOT/skills"
  [ -d "$skills_dir" ] || return 0
  shopt -s nullglob
  for f in "$skills_dir"/*.md; do
    local name
    name="$(basename "$f" .md)"
    [ "$name" = "SKILL" ] && continue
    mkdir -p "$skills_dir/$name"
    mv "$f" "$skills_dir/$name/SKILL.md"
    echo "  normalized: $name.md → $name/SKILL.md"
  done
  shopt -u nullglob
}

if [ "$NO_UPSTREAM" -eq 1 ]; then
  echo "==> --no-upstream: normalizing local skills layout only ..."
  normalize_skills_layout
  echo "==> Done."
  exit 0
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "ERROR: gh CLI not found. Install it or run with --no-upstream." >&2
  exit 1
fi

CMR_TMP=/tmp/cmr
OA_TMP=/tmp/oa

cleanup() { rm -rf "$CMR_TMP" "$OA_TMP"; }
trap cleanup EXIT

echo "==> Cloning janskuba/claude-md-repo ..."
rm -rf "$CMR_TMP"
gh repo clone janskuba/claude-md-repo "$CMR_TMP"

echo "==> Syncing skills ..."
mkdir -p "$ROOT/skills"
if [ -d "$CMR_TMP/skills" ]; then
  rsync -a --delete --exclude=modules --exclude=templates --exclude=examples "$CMR_TMP/skills/" "$ROOT/skills/"
fi
for sub in modules templates examples; do
  if [ -d "$CMR_TMP/$sub" ]; then
    mkdir -p "$ROOT/skills/$sub"
    rsync -a --delete "$CMR_TMP/$sub/" "$ROOT/skills/$sub/"
  fi
done

normalize_skills_layout

echo "==> Cloning janskuba/outbound-agents ..."
rm -rf "$OA_TMP"
gh repo clone janskuba/outbound-agents "$OA_TMP"

echo "==> Syncing agents ..."
mkdir -p "$ROOT/agents"
if [ -d "$OA_TMP/.claude/agents" ]; then
  rsync -a --delete --exclude=commands "$OA_TMP/.claude/agents/" "$ROOT/agents/"
fi
if [ -d "$OA_TMP/.claude/commands" ]; then
  mkdir -p "$ROOT/agents/commands"
  rsync -a --delete "$OA_TMP/.claude/commands/" "$ROOT/agents/commands/"
fi
for sub in examples input; do
  if [ -d "$OA_TMP/$sub" ]; then
    mkdir -p "$ROOT/agents/$sub"
    rsync -a --delete "$OA_TMP/$sub/" "$ROOT/agents/$sub/"
  fi
done

echo "==> Done."
