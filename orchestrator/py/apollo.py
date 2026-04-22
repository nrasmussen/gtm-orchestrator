#!/usr/bin/env python3
# apollo.py — enrich contacts and search leads via Apollo.io REST API
# Docs: https://apolloio.github.io/apollo-api-docs/
# Endpoint: https://api.apollo.io/api/v1
# Actions: enrich, search

import json
import os
import sys
import requests

BASE_URL = "https://api.apollo.io/api/v1"


def main():
    raw = sys.stdin.read()
    try:
        payload = json.loads(raw)
    except json.JSONDecodeError as e:
        print(f"ERROR: invalid JSON on stdin: {e}", file=sys.stderr)
        sys.exit(1)

    dry_run = os.environ.get("DRY_RUN", "")
    action = payload.get("action", "enrich")

    if dry_run:
        print(f"DRY_RUN: apollo {action}", file=sys.stderr)
        print(f"PAYLOAD: {raw}", file=sys.stderr)
        sys.exit(0)

    print(f"INFO: apollo action={action}", file=sys.stderr)

    api_key = os.environ.get("APOLLO_API_KEY", "")
    if not api_key:
        print("ERROR: APOLLO_API_KEY is required", file=sys.stderr)
        sys.exit(1)

    headers = {
        "Content-Type": "application/json",
        "Cache-Control": "no-cache",
        "X-Api-Key": api_key,
    }

    if action == "enrich":
        body = {}
        if payload.get("email"):
            body["email"] = payload["email"]
        if payload.get("domain"):
            body["domain"] = payload["domain"]

        resp = requests.post(
            f"{BASE_URL}/people/match",
            json=body,
            headers=headers,
            timeout=15,
        )
        if resp.status_code not in (200, 201):
            print(
                f"ERROR: Apollo API returned HTTP {resp.status_code}: {resp.text}",
                file=sys.stderr,
            )
            sys.exit(1)
        print(resp.text)
        print(f"INFO: apollo enrich succeeded (HTTP {resp.status_code})", file=sys.stderr)

    elif action == "search":
        query = payload.get("query", {})

        resp = requests.post(
            f"{BASE_URL}/mixed_people/search",
            json=query,
            headers=headers,
            timeout=15,
        )
        if resp.status_code not in (200, 201):
            print(
                f"ERROR: Apollo API returned HTTP {resp.status_code}: {resp.text}",
                file=sys.stderr,
            )
            sys.exit(1)
        print(resp.text)
        print(f"INFO: apollo search succeeded (HTTP {resp.status_code})", file=sys.stderr)

    else:
        print(f"ERROR: unknown action '{action}'", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
