#!/usr/bin/env bash
# test_hooks.sh — assert every hook.json and starter pack matches the
# Claude Code hook schema.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

python3 "$ROOT/scripts/lib/validate-hook-json.py" \
  "$ROOT"/hooks/*/*/hook.json \
  "$ROOT"/examples/full-settings-*.json
