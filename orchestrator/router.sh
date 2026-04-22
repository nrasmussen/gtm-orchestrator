#!/usr/bin/env bash
# router.sh — accepts a tool name as $1, pipes stdin to orchestrator/sh/$1.sh
set -euo pipefail

TOOL="${1:-}"
if [[ -z "$TOOL" ]]; then
  echo "Usage: router.sh <tool-name>" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$SCRIPT_DIR/sh/${TOOL}.sh"

if [[ ! -f "$TARGET" ]]; then
  echo "ERROR: no handler found at $TARGET" >&2
  exit 1
fi

if [[ ! -x "$TARGET" ]]; then
  echo "ERROR: $TARGET is not executable" >&2
  exit 1
fi

exec "$TARGET" "${@:2}"
