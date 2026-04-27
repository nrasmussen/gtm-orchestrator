#!/usr/bin/env bash
# test_handlers.sh — run every handler with DRY_RUN=1 against each
# Claude Code event fixture. Exits non-zero if any combination fails.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

export DRY_RUN=1

fail=0
for fixture in "$SCRIPT_DIR"/fixtures/*.json; do
  fname="$(basename "$fixture")"
  echo "=== fixture: $fname ==="
  for handler in "$ROOT"/orchestrator/py/*.py; do
    name="$(basename "$handler" .py)"
    if "$ROOT/orchestrator/run.sh" "$name" smoke < "$fixture" >/dev/null 2>&1; then
      echo "  [OK]      $name"
    else
      echo "  [FAIL]    $name (fixture=$fname)"
      fail=1
    fi
  done
done

if [ "$fail" = "0" ]; then
  echo "test_handlers: PASS"
else
  echo "test_handlers: FAIL"
  exit 1
fi
