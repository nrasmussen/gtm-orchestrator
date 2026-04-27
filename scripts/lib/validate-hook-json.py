#!/usr/bin/env python3
"""Validate hook.json files against the Claude Code hook schema.

Required shape:

    {
      "hooks": {
        "<EventName>": [
          { "matcher": "*"?, "hooks": [ { "type": "command", "command": "..." } ] }
        ]
      }
    }

Exits non-zero if any file fails. Prints a single PASS/FAIL line per file.
"""

from __future__ import annotations

import json
import sys

VALID_EVENTS = {
    "PreToolUse",
    "PostToolUse",
    "UserPromptSubmit",
    "Notification",
    "Stop",
    "SubagentStop",
    "SessionStart",
    "SessionEnd",
    "PreCompact",
}
MATCHER_REQUIRED = {"PreToolUse", "PostToolUse"}


def validate(path: str) -> list[str]:
    errors: list[str] = []
    try:
        with open(path, encoding="utf-8") as f:
            data = json.load(f)
    except (OSError, json.JSONDecodeError) as e:
        return [f"could not read or parse: {e}"]

    if not isinstance(data, dict):
        return ["root must be an object"]

    hooks = data.get("hooks")
    if not isinstance(hooks, dict):
        return ["missing 'hooks' object at root"]

    for event_name, entries in hooks.items():
        if event_name not in VALID_EVENTS:
            errors.append(f"unknown event: {event_name}")
        if not isinstance(entries, list):
            errors.append(f"{event_name}: expected list of entries")
            continue
        for i, entry in enumerate(entries):
            if not isinstance(entry, dict):
                errors.append(f"{event_name}[{i}]: not an object")
                continue
            inner = entry.get("hooks")
            if not isinstance(inner, list) or not inner:
                errors.append(f"{event_name}[{i}]: missing nested 'hooks' array")
                continue
            if event_name in MATCHER_REQUIRED and "matcher" not in entry:
                errors.append(f"{event_name}[{i}]: missing 'matcher' for tool event")
            for j, h in enumerate(inner):
                if not isinstance(h, dict):
                    errors.append(f"{event_name}[{i}].hooks[{j}]: not an object")
                    continue
                if h.get("type") != "command":
                    errors.append(f"{event_name}[{i}].hooks[{j}]: type must be 'command'")
                if not h.get("command"):
                    errors.append(f"{event_name}[{i}].hooks[{j}]: empty 'command'")
    return errors


def main(paths):
    failed = 0
    for p in paths:
        errs = validate(p)
        if errs:
            failed += 1
            print(f"FAIL {p}")
            for e in errs:
                print(f"     - {e}")
        else:
            print(f"PASS {p}")
    return 1 if failed else 0


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__, file=sys.stderr)
        sys.exit(2)
    sys.exit(main(sys.argv[1:]))
