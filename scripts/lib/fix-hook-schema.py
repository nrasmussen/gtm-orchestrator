#!/usr/bin/env python3
"""Rewrite a hook.json (or starter-pack settings.json) into the correct
Claude Code hook schema.

Claude Code expects:

    {
      "hooks": {
        "<EventName>": [
          { "matcher": "*", "hooks": [ { "type": "command", "command": "..." } ] }
        ]
      }
    }

The legacy shape in this repo placed the inner {"type","command"} object
directly under the event array. This script normalizes either shape into
the correct one in place. Idempotent.

Usage:
    fix-hook-schema.py <path>...
"""

import json
import sys

MATCHER_REQUIRED = {"PreToolUse", "PostToolUse"}


def _normalize_event_entries(event_name: str, entries):
    """Return a list of correctly-shaped entries for a single event."""
    if not isinstance(entries, list):
        return entries

    out = []
    for entry in entries:
        if not isinstance(entry, dict):
            continue

        # Already-correct shape: { "matcher": ..., "hooks": [ ... ] }
        if "hooks" in entry and isinstance(entry["hooks"], list):
            normalized = {"hooks": [h for h in entry["hooks"] if isinstance(h, dict)]}
            if event_name in MATCHER_REQUIRED:
                normalized = {"matcher": entry.get("matcher", "*"), **normalized}
            elif "matcher" in entry:
                normalized["matcher"] = entry["matcher"]
            out.append(normalized)
            continue

        # Legacy: { "type": "command", "command": "...", "description": "..." }
        if entry.get("type") == "command" and "command" in entry:
            inner = {"type": "command", "command": entry["command"]}
            wrapper = {"hooks": [inner]}
            if event_name in MATCHER_REQUIRED:
                wrapper = {"matcher": entry.get("matcher", "*"), **wrapper}
            out.append(wrapper)
            continue

    return out


def transform(data: dict) -> dict:
    if not isinstance(data, dict) or "hooks" not in data:
        return data
    new_hooks = {}
    for event_name, entries in data["hooks"].items():
        new_hooks[event_name] = _normalize_event_entries(event_name, entries)
    data["hooks"] = new_hooks
    return data


def main(paths):
    for p in paths:
        with open(p, encoding="utf-8") as f:
            data = json.load(f)
        new_data = transform(data)
        with open(p, "w", encoding="utf-8") as f:
            json.dump(new_data, f, indent=2)
            f.write("\n")
        print(f"OK  {p}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__, file=sys.stderr)
        sys.exit(2)
    main(sys.argv[1:])
