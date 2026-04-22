#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo ""
echo "=== Montgomery GTM Orchestrator - Setup ==="
echo ""

# ---------------------------------------------------------------------------
# 1. Create .env from .env.example if missing
# ---------------------------------------------------------------------------

if [ -f "$REPO_ROOT/.env" ]; then
  echo "[OK] .env already exists, skipping copy."
else
  if [ ! -f "$REPO_ROOT/.env.example" ]; then
    echo "[ERROR] .env.example not found in $REPO_ROOT. Cannot continue."
    exit 1
  fi
  cp "$REPO_ROOT/.env.example" "$REPO_ROOT/.env"
  echo "[OK] Created .env from .env.example"
fi

# ---------------------------------------------------------------------------
# 2. Export CLAUDE_GTM_DIR to shell profile
# ---------------------------------------------------------------------------

echo ""
echo "=== Shell Profile ==="

EXPORT_LINE="export CLAUDE_GTM_DIR=\"$REPO_ROOT\""

# Determine profile file
if [ -n "${SHELL:-}" ] && [[ "$SHELL" == */zsh ]]; then
  PROFILE="$HOME/.zshrc"
else
  PROFILE="$HOME/.bashrc"
fi

# Check if already configured
already_set=false
if [ -f "$PROFILE" ] && grep -qF "CLAUDE_GTM_DIR" "$PROFILE" 2>/dev/null; then
  already_set=true
fi

if [ "$already_set" = true ]; then
  echo "[OK] CLAUDE_GTM_DIR is already set in $PROFILE, skipping."
else
  echo "This will add the following line to $PROFILE:"
  echo ""
  echo "  $EXPORT_LINE"
  echo ""
  printf "Proceed? [y/N] "
  read -r answer </dev/tty

  if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "" >> "$PROFILE"
    echo "# Added by montgomery/scripts/setup.sh" >> "$PROFILE"
    echo "$EXPORT_LINE" >> "$PROFILE"
    echo "[OK] Added CLAUDE_GTM_DIR to $PROFILE"
    echo ""
    echo "To apply immediately in your current shell, run:"
    echo "  source $PROFILE"
  else
    echo "[SKIP] No changes made to $PROFILE."
    echo "       You can add this manually:"
    echo "  $EXPORT_LINE"
  fi
fi

# ---------------------------------------------------------------------------
# 3. Next steps
# ---------------------------------------------------------------------------

echo ""
echo "=== Next Steps ==="
echo ""
echo "1. Fill in your API keys in $REPO_ROOT/.env"
echo "2. Run ./scripts/validate.sh to check which integrations are ready"
echo ""
