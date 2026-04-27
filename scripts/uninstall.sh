#!/usr/bin/env bash
# uninstall.sh — Remove everything that scripts/install.sh added.
#
# Reads ~/.claude/.gtm-installed.json to know what to remove.
# Hooks are removed from settings.json by command-string match (any command
# referencing $CLAUDE_GTM_DIR/orchestrator/run.sh).
#
# Backups are taken before mutation. CLAUDE_GTM_DIR export in your shell
# profile is NOT removed automatically (we don't want to mangle your dotfiles).

set -euo pipefail

CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
SETTINGS_FILE="$CLAUDE_HOME/settings.json"
MARKER_FILE="$CLAUDE_HOME/.gtm-installed.json"

if [ ! -f "$MARKER_FILE" ]; then
  echo "No install marker at $MARKER_FILE. Nothing to uninstall."
  exit 0
fi

echo "=== Montgomery GTM Uninstaller ==="

python3 - "$MARKER_FILE" "$CLAUDE_HOME" <<'PY'
import json, os, shutil, sys
marker_path, claude_home = sys.argv[1:3]
marker = json.load(open(marker_path))

for name in marker.get("skills", []):
    target = os.path.join(claude_home, "skills", name)
    if os.path.lexists(target):
        shutil.rmtree(target, ignore_errors=True) if os.path.isdir(target) and not os.path.islink(target) else os.remove(target)
        print(f"  removed skill: {name}")

for name in marker.get("agents", []):
    target = os.path.join(claude_home, "agents", name)
    if os.path.lexists(target):
        os.remove(target)
        print(f"  removed agent: {name}")

for name in marker.get("commands", []):
    target = os.path.join(claude_home, "commands", name)
    if os.path.lexists(target):
        os.remove(target)
        print(f"  removed command: {name}")
PY

if [ -f "$SETTINGS_FILE" ]; then
  BACKUP="$SETTINGS_FILE.bak.$(date +%Y%m%d%H%M%S)"
  cp "$SETTINGS_FILE" "$BACKUP"
  echo "  backed up settings.json → $BACKUP"
  python3 - "$SETTINGS_FILE" <<'PY'
import json, sys
path = sys.argv[1]
data = json.load(open(path))
hooks = data.get("hooks", {})
empty_events = []
for event_name, entries in list(hooks.items()):
    if not isinstance(entries, list):
        continue
    kept = []
    for entry in entries:
        if not isinstance(entry, dict):
            kept.append(entry); continue
        inner = entry.get("hooks", [])
        keep_inner = [
            h for h in inner
            if not (isinstance(h, dict) and "$CLAUDE_GTM_DIR" in h.get("command", ""))
        ]
        if keep_inner:
            new_entry = dict(entry); new_entry["hooks"] = keep_inner
            kept.append(new_entry)
    if kept:
        hooks[event_name] = kept
    else:
        empty_events.append(event_name)
for e in empty_events:
    hooks.pop(e, None)
data["hooks"] = hooks
json.dump(data, open(path, "w"), indent=2)
print(f"  cleaned hooks from {path}")
PY
fi

rm -f "$MARKER_FILE"
echo "=== Done ==="
echo "Note: CLAUDE_GTM_DIR remains in your shell profile. Remove it manually if desired."
