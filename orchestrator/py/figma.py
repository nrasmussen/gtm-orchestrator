#!/usr/bin/env python3
# figma.py — export assets from Figma via claude mcp call
# Docs: https://www.figma.com/developers/api
# Actions: export

import json
import os
import subprocess
import sys

def run_mcp(tool_name: str, tool_input: dict) -> str:
    result = subprocess.run(
        ["claude", "mcp", "call", "figma", tool_name],
        input=json.dumps(tool_input).encode(),
        capture_output=True,
    )
    if result.returncode != 0:
        stderr = result.stderr.decode()
        stdout = result.stdout.decode()
        raise RuntimeError(f"MCP call failed (rc={result.returncode}): {stderr or stdout}")
    return result.stdout.decode()

def main():
    raw = sys.stdin.read()
    try:
        payload = json.loads(raw)
    except json.JSONDecodeError as e:
        print(f"ERROR: invalid JSON on stdin: {e}", file=sys.stderr)
        sys.exit(1)

    dry_run = os.environ.get("DRY_RUN", "")

    if dry_run:
        print("DRY_RUN: claude mcp call figma", file=sys.stderr)
        print(f"PAYLOAD: {raw}", file=sys.stderr)
        sys.exit(0)

    action = payload.get("action", "export")
    print(f"INFO: figma action={action}", file=sys.stderr)

    try:
        if action == "export":
            tool_input = {
                "fileKey": payload.get("file_key", ""),
                "nodeId": payload.get("node_id", ""),
                "format": payload.get("format", "png"),
                "scale": payload.get("scale", 2),
            }
            result = run_mcp("get_screenshot", tool_input)
            print(result)

        else:
            print(f"ERROR: unknown action '{action}'", file=sys.stderr)
            sys.exit(1)

    except RuntimeError as e:
        print(f"ERROR: figma mcp call failed: {e}", file=sys.stderr)
        sys.exit(1)

    print(f"INFO: figma {action} complete", file=sys.stderr)

if __name__ == "__main__":
    main()
