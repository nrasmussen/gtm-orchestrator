#!/usr/bin/env python3
# linear.py — create tickets and versions in Linear via claude mcp call
# Docs: https://developers.linear.app/docs
# Actions: create-ticket, version

import json
import os
import subprocess
import sys

def run_mcp(tool_name: str, tool_input: dict) -> str:
    result = subprocess.run(
        ["claude", "mcp", "call", "linear", tool_name],
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
        print("DRY_RUN: claude mcp call linear", file=sys.stderr)
        print(f"PAYLOAD: {raw}", file=sys.stderr)
        sys.exit(0)

    action = payload.get("action", "create-ticket")
    print(f"INFO: linear action={action}", file=sys.stderr)

    try:
        if action == "create-ticket":
            tool_input = {
                "title": payload.get("title", ""),
                "description": payload.get("description", ""),
                "teamId": payload.get("team_id", ""),
                "priority": payload.get("priority", 0),
                "labelIds": payload.get("label_ids", []),
            }
            result = run_mcp("create_issue", tool_input)
            print(result)

        elif action == "version":
            tool_input = {
                "teamId": payload.get("team_id", ""),
                "name": payload.get("name", ""),
                "targetDate": payload.get("target_date", ""),
                "description": payload.get("description", ""),
            }
            result = run_mcp("create_project", tool_input)
            print(result)

        else:
            print(f"ERROR: unknown action '{action}'", file=sys.stderr)
            sys.exit(1)

    except RuntimeError as e:
        print(f"ERROR: linear mcp call failed: {e}", file=sys.stderr)
        sys.exit(1)

    print(f"INFO: linear {action} complete", file=sys.stderr)

if __name__ == "__main__":
    main()
