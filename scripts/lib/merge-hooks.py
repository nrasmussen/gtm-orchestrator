#!/usr/bin/env python3
"""Merge a list of hook.json fragments into a Claude Code settings.json.

Usage:
    merge-hooks.py <settings.json> <hook.json>...

Behavior:
- Reads existing settings.json if present (creates it if not).
- Deep-merges each hook.json under the "hooks" key, by event name.
- Deduplicates by exact command string within each event.
- Preserves any non-hook keys already in settings.json (model, theme, etc.).
- Writes pretty-printed output back to <settings.json>.
"""

from __future__ import annotations

import json
import os
import sys


def load_json(path: str) -> dict:
    if not os.path.exists(path):
        return {}
    try:
        with open(path, encoding="utf-8") as f:
            data = json.load(f)
        return data if isinstance(data, dict) else {}
    except (OSError, json.JSONDecodeError):
        return {}


def commands_in_entry(entry: dict) -> list[str]:
    return [
        h.get("command", "")
        for h in entry.get("hooks", [])
        if isinstance(h, dict)
    ]


def merge_event(existing: list, additions: list) -> list:
    out = list(existing)
    existing_cmds: set[str] = set()
    for e in out:
        if isinstance(e, dict):
            existing_cmds.update(commands_in_entry(e))
    for entry in additions:
        if not isinstance(entry, dict):
            continue
        new_cmds = set(commands_in_entry(entry))
        if new_cmds and new_cmds.issubset(existing_cmds):
            continue
        out.append(entry)
        existing_cmds.update(new_cmds)
    return out


def main(settings_path: str, hook_paths: list[str]) -> int:
    settings = load_json(settings_path)
    if "hooks" not in settings or not isinstance(settings["hooks"], dict):
        settings["hooks"] = {}

    for hp in hook_paths:
        with open(hp, encoding="utf-8") as f:
            fragment = json.load(f)
        for event_name, entries in fragment.get("hooks", {}).items():
            if not isinstance(entries, list):
                continue
            existing = settings["hooks"].get(event_name, [])
            settings["hooks"][event_name] = merge_event(existing, entries)

    os.makedirs(os.path.dirname(settings_path) or ".", exist_ok=True)
    with open(settings_path, "w", encoding="utf-8") as f:
        json.dump(settings, f, indent=2)
        f.write("\n")
    return 0


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(__doc__, file=sys.stderr)
        sys.exit(2)
    sys.exit(main(sys.argv[1], sys.argv[2:]))
