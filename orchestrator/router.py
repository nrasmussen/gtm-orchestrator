#!/usr/bin/env python3
"""router.py — accepts a tool name as sys.argv[1], pipes stdin to orchestrator/py/<tool>.py"""

import sys
import os
import subprocess

def main():
    if len(sys.argv) < 2:
        print("Usage: router.py <tool-name> [args...]", file=sys.stderr)
        sys.exit(1)

    tool = sys.argv[1]
    script_dir = os.path.dirname(os.path.abspath(__file__))
    target = os.path.join(script_dir, "py", f"{tool}.py")

    if not os.path.isfile(target):
        print(f"ERROR: no handler found at {target}", file=sys.stderr)
        sys.exit(1)

    stdin_data = sys.stdin.buffer.read()

    result = subprocess.run(
        [sys.executable, target] + sys.argv[2:],
        input=stdin_data,
    )
    sys.exit(result.returncode)

if __name__ == "__main__":
    main()
