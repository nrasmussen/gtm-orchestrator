#!/usr/bin/env python3
# gmail.py — interact with Gmail via claude mcp call (Gmail MCP)
# Docs: https://developers.google.com/gmail/api/reference/rest
# Actions: digest, draft

import json
import os
import subprocess
import sys

def run_mcp(tool_name: str, tool_input: dict) -> str:
    result = subprocess.run(
        ["claude", "mcp", "call", "gmail", tool_name],
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
        print("DRY_RUN: claude mcp call gmail", file=sys.stderr)
        print(f"PAYLOAD: {raw}", file=sys.stderr)
        sys.exit(0)

    action = payload.get("action", "digest")
    print(f"INFO: gmail action={action}", file=sys.stderr)

    try:
        if action == "digest":
            tool_input = {
                "query": payload.get("query", "is:unread"),
                "maxResults": payload.get("max_results", 10),
            }
            result = run_mcp("search_threads", tool_input)
            print(result)

        elif action == "draft":
            tool_input = {
                "to": payload.get("to", ""),
                "subject": payload.get("subject", ""),
                "body": payload.get("body", ""),
            }
            result = run_mcp("create_draft", tool_input)
            print(result)

        else:
            print(f"ERROR: unknown action '{action}'", file=sys.stderr)
            sys.exit(1)

    except RuntimeError as e:
        print(f"ERROR: gmail mcp call failed: {e}", file=sys.stderr)
        sys.exit(1)

    print(f"INFO: gmail {action} complete", file=sys.stderr)

if __name__ == "__main__":
    main()
