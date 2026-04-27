#!/usr/bin/env python3
"""dispatch.py — single contract between hooks and handlers.

Reads stdin (Claude Code hook payload — may be empty, non-JSON, or any shape),
merges the CLI-provided action into payload["action"], and execs the
handler at orchestrator/py/<service>.py.

Action precedence: argv action > stdin payload action > handler default.

Usage:
    dispatch.py <service> <action> [<extra>...]

Extra args are forwarded as argv to the handler. Handlers should not rely on
them today, but the path stays open.
"""

import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))


def _read_stdin() -> bytes:
    if sys.stdin.isatty():
        return b""
    try:
        return sys.stdin.buffer.read()
    except Exception:
        return b""


def _build_payload(raw: bytes, action: str) -> dict:
    payload: dict = {}
    if raw.strip():
        try:
            decoded = json.loads(raw.decode("utf-8", errors="replace"))
            if isinstance(decoded, dict):
                payload = decoded
            else:
                payload = {"raw": decoded}
        except json.JSONDecodeError:
            payload = {"raw_text": raw.decode("utf-8", errors="replace")}
    if action:
        payload["action"] = action
    return payload


def main() -> int:
    if len(sys.argv) < 2:
        print("Usage: dispatch.py <service> <action> [<extra>...]", file=sys.stderr)
        return 2

    service = sys.argv[1]
    action = sys.argv[2] if len(sys.argv) > 2 else ""
    extra = sys.argv[3:]

    handler = os.path.join(HERE, "py", f"{service}.py")
    if not os.path.isfile(handler):
        print(f"ERROR: handler not found: {handler}", file=sys.stderr)
        return 2

    raw = _read_stdin()
    payload = _build_payload(raw, action)
    merged = json.dumps(payload).encode("utf-8")

    # Pipe merged JSON into the handler on stdin via a shell-free fork/exec.
    import subprocess
    result = subprocess.run(
        [sys.executable, handler] + extra,
        input=merged,
    )
    return result.returncode


if __name__ == "__main__":
    sys.exit(main())
