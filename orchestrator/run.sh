#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="${CLAUDE_GTM_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"

if [ -f "$REPO_ROOT/.env" ]; then
  set -a
  source "$REPO_ROOT/.env"
  set +a
fi

SCRIPT="$REPO_ROOT/orchestrator/sh/$1.sh"
shift
exec "$SCRIPT" "$@"
