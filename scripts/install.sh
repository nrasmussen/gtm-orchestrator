#!/usr/bin/env bash
# install.sh — Install Montgomery GTM hooks, skills, agents, and commands
# into your local Claude Code configuration.
#
# Usage:
#   ./scripts/install.sh                 # interactive, copies everything
#   ./scripts/install.sh --copy          # copy files (default)
#   ./scripts/install.sh --symlink       # symlink instead of copy
#   ./scripts/install.sh --skills-only   # install only the skills layer
#   ./scripts/install.sh --agents-only   # install only agents + commands
#   ./scripts/install.sh --hooks-only    # merge hooks into settings.json only
#   ./scripts/install.sh --hooks=slack-ping-on-stop,attio-upsert-company  # cherry-pick
#   ./scripts/install.sh --yes           # non-interactive
#
# What it does:
#   1. Ensures CLAUDE_GTM_DIR is set in ~/.zshrc or ~/.bashrc.
#   2. Copies (or symlinks) skills/<name>/SKILL.md → ~/.claude/skills/<name>/SKILL.md.
#   3. Copies (or symlinks) agents/*.md → ~/.claude/agents/.
#   4. Copies (or symlinks) agents/commands/*.md → ~/.claude/commands/.
#   5. Merges every hook.json into ~/.claude/settings.json (with backup).
#   6. Records what was installed in ~/.claude/.gtm-installed.json.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
SETTINGS_FILE="$CLAUDE_HOME/settings.json"
MARKER_FILE="$CLAUDE_HOME/.gtm-installed.json"

MODE=copy
DO_SKILLS=1
DO_AGENTS=1
DO_HOOKS=1
ASSUME_YES=0
HOOK_FILTER=""

for arg in "$@"; do
  case "$arg" in
    --copy)         MODE=copy ;;
    --symlink)      MODE=symlink ;;
    --skills-only)  DO_AGENTS=0; DO_HOOKS=0 ;;
    --agents-only)  DO_SKILLS=0; DO_HOOKS=0 ;;
    --hooks-only)   DO_SKILLS=0; DO_AGENTS=0 ;;
    --hooks=*)      HOOK_FILTER="${arg#--hooks=}" ;;
    --yes|-y)       ASSUME_YES=1 ;;
    -h|--help)
      sed -n '2,25p' "$0"; exit 0 ;;
    *) echo "Unknown arg: $arg" >&2; exit 2 ;;
  esac
done

confirm() {
  [ "$ASSUME_YES" = "1" ] && return 0
  printf "%s [y/N] " "$1"
  local ans
  read -r ans </dev/tty || return 1
  [[ "$ans" =~ ^[Yy]$ ]]
}

place() {
  # place <src> <dest>: copy or symlink, removing any existing entry first.
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  rm -rf "$dest"
  if [ "$MODE" = "symlink" ]; then
    ln -s "$src" "$dest"
  else
    cp "$src" "$dest"
  fi
}

echo "=== Montgomery GTM Installer ==="
echo "Mode: $MODE"
echo "Target: $CLAUDE_HOME"
echo ""

mkdir -p "$CLAUDE_HOME"

# ---------------------------------------------------------------------------
# 1. CLAUDE_GTM_DIR in shell profile
# ---------------------------------------------------------------------------
PROFILE="$HOME/.zshrc"
[[ "${SHELL:-}" == */bash ]] && PROFILE="$HOME/.bashrc"

if ! grep -qF "CLAUDE_GTM_DIR" "$PROFILE" 2>/dev/null; then
  if confirm "Add CLAUDE_GTM_DIR=\"$ROOT\" to $PROFILE?"; then
    {
      echo ""
      echo "# Added by montgomery/scripts/install.sh"
      echo "export CLAUDE_GTM_DIR=\"$ROOT\""
    } >> "$PROFILE"
    echo "  added to $PROFILE"
  else
    echo "  skipped (you must export CLAUDE_GTM_DIR manually)"
  fi
fi
export CLAUDE_GTM_DIR="$ROOT"

# ---------------------------------------------------------------------------
# 2. Skills
# ---------------------------------------------------------------------------
SKILLS_INSTALLED=()
if [ "$DO_SKILLS" = "1" ]; then
  echo ""
  echo "=== Installing skills ==="
  shopt -s nullglob
  for skill_dir in "$ROOT"/skills/*/SKILL.md; do
    name="$(basename "$(dirname "$skill_dir")")"
    dest="$CLAUDE_HOME/skills/$name/SKILL.md"
    place "$skill_dir" "$dest"
    SKILLS_INSTALLED+=("$name")
    echo "  $name"
  done
  shopt -u nullglob
fi

# ---------------------------------------------------------------------------
# 3. Agents + commands
# ---------------------------------------------------------------------------
AGENTS_INSTALLED=()
COMMANDS_INSTALLED=()
if [ "$DO_AGENTS" = "1" ]; then
  echo ""
  echo "=== Installing agents ==="
  shopt -s nullglob
  for agent in "$ROOT"/agents/*.md; do
    name="$(basename "$agent")"
    dest="$CLAUDE_HOME/agents/$name"
    place "$agent" "$dest"
    AGENTS_INSTALLED+=("$name")
    echo "  $name"
  done
  echo ""
  echo "=== Installing commands ==="
  for cmd in "$ROOT"/agents/commands/*.md; do
    name="$(basename "$cmd")"
    dest="$CLAUDE_HOME/commands/$name"
    place "$cmd" "$dest"
    COMMANDS_INSTALLED+=("$name")
    echo "  $name"
  done
  shopt -u nullglob
fi

# ---------------------------------------------------------------------------
# 4. Hooks → merge into settings.json
# ---------------------------------------------------------------------------
HOOKS_INSTALLED=()
if [ "$DO_HOOKS" = "1" ]; then
  echo ""
  echo "=== Merging hooks into $SETTINGS_FILE ==="

  # Backup existing settings.json
  if [ -f "$SETTINGS_FILE" ]; then
    BACKUP="$SETTINGS_FILE.bak.$(date +%Y%m%d%H%M%S)"
    cp "$SETTINGS_FILE" "$BACKUP"
    echo "  backed up existing settings.json → $BACKUP"
  fi

  # Build space-separated list of hook.json paths to merge
  HOOK_PATHS=()
  if [ -n "$HOOK_FILTER" ]; then
    IFS=',' read -ra wanted <<< "$HOOK_FILTER"
    shopt -s nullglob
    for w in "${wanted[@]}"; do
      for found in "$ROOT"/hooks/*/"$w"/hook.json; do
        HOOK_PATHS+=("$found")
      done
    done
    shopt -u nullglob
  else
    shopt -s nullglob
    for f in "$ROOT"/hooks/*/*/hook.json; do
      HOOK_PATHS+=("$f")
    done
    shopt -u nullglob
  fi

  if [ "${#HOOK_PATHS[@]}" -eq 0 ]; then
    echo "  no hooks matched filter"
  else
    python3 "$ROOT/scripts/lib/merge-hooks.py" "$SETTINGS_FILE" "${HOOK_PATHS[@]}"
    for p in "${HOOK_PATHS[@]}"; do
      HOOKS_INSTALLED+=("$(basename "$(dirname "$p")")")
      echo "  merged: $(basename "$(dirname "$p")")"
    done
  fi
fi

# ---------------------------------------------------------------------------
# 5. Marker file (so uninstall can find what we touched)
# ---------------------------------------------------------------------------
python3 - "$MARKER_FILE" "$ROOT" \
  "${SKILLS_INSTALLED[*]:-}" \
  "${AGENTS_INSTALLED[*]:-}" \
  "${COMMANDS_INSTALLED[*]:-}" \
  "${HOOKS_INSTALLED[*]:-}" \
  "$MODE" <<'PY'
import json, os, sys
marker, root, skills, agents, commands, hooks, mode = sys.argv[1:8]
data = {
  "root": root,
  "mode": mode,
  "skills": skills.split() if skills else [],
  "agents": agents.split() if agents else [],
  "commands": commands.split() if commands else [],
  "hooks": hooks.split() if hooks else [],
}
os.makedirs(os.path.dirname(marker), exist_ok=True)
with open(marker, "w") as f:
    json.dump(data, f, indent=2)
PY

echo ""
echo "=== Done ==="
echo "  ${#SKILLS_INSTALLED[@]} skills, ${#AGENTS_INSTALLED[@]} agents, ${#COMMANDS_INSTALLED[@]} commands, ${#HOOKS_INSTALLED[@]} hooks installed."
echo ""
echo "Restart Claude Code to pick up changes."
echo "Run ./scripts/validate.sh to verify."
