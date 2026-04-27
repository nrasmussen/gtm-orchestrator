#!/usr/bin/env bash
# run.sh — orchestrator entrypoint invoked by Claude Code hook commands.
#
# Usage: run.sh <service> [<action>]
#   <service>  Required. Name of a handler in orchestrator/py/<service>.py
#   <action>   Optional. Injected into stdin payload as payload["action"].
#
# stdin: JSON payload from the Claude Code hook (may be empty or malformed).
#
# Behavior:
#   1. Loads .env if present.
#   2. Delegates to dispatch.py, which merges <action> into the stdin JSON
#      and execs the Python handler.
#
# Exit code mirrors the handler.

set -euo pipefail

REPO_ROOT="${CLAUDE_GTM_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"

if [ -f "$REPO_ROOT/.env" ]; then
  set -a
  # shellcheck disable=SC1091
  source "$REPO_ROOT/.env"
  set +a
fi

SERVICE="${1:-}"
if [ -z "$SERVICE" ]; then
  echo "Usage: run.sh <service> [<action>]" >&2
  exit 2
fi
shift

ACTION=""
if [ $# -gt 0 ]; then
  ACTION="$1"
  shift
fi

exec python3 "$REPO_ROOT/orchestrator/dispatch.py" "$SERVICE" "$ACTION" "$@"
