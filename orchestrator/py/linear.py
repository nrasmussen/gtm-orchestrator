#!/usr/bin/env python3
# linear.py — create issues and projects in Linear via the GraphQL API
# Docs: https://developers.linear.app/docs/graphql/working-with-the-graphql-api
# Endpoint: https://api.linear.app/graphql
# Actions: create-ticket, version

import json
import os
import sys
import requests

GRAPHQL_URL = "https://api.linear.app/graphql"

CREATE_ISSUE_MUTATION = """
mutation CreateIssue($input: IssueCreateInput!) {
  issueCreate(input: $input) {
    success
    issue { id identifier title url }
  }
}
"""

CREATE_PROJECT_MUTATION = """
mutation CreateProject($input: ProjectCreateInput!) {
  projectCreate(input: $input) {
    success
    project { id name url targetDate }
  }
}
"""


def _post(api_key: str, query: str, variables: dict) -> dict:
    resp = requests.post(
        GRAPHQL_URL,
        json={"query": query, "variables": variables},
        headers={"Authorization": api_key, "Content-Type": "application/json"},
        timeout=20,
    )
    if resp.status_code != 200:
        print(f"ERROR: Linear API HTTP {resp.status_code}: {resp.text}", file=sys.stderr)
        sys.exit(1)
    body = resp.json()
    if body.get("errors"):
        print(f"ERROR: Linear GraphQL errors: {json.dumps(body['errors'])}", file=sys.stderr)
        sys.exit(1)
    return body.get("data", {})


def main():
    raw = sys.stdin.read()
    try:
        payload = json.loads(raw) if raw.strip() else {}
    except json.JSONDecodeError as e:
        print(f"ERROR: invalid JSON on stdin: {e}", file=sys.stderr)
        sys.exit(1)

    dry_run = os.environ.get("DRY_RUN", "")
    action = payload.get("action", "create-ticket")

    if dry_run:
        print(f"DRY_RUN: linear {action}", file=sys.stderr)
        print(f"PAYLOAD: {raw}", file=sys.stderr)
        sys.exit(0)

    api_key = os.environ.get("LINEAR_API_KEY", "")
    if not api_key:
        print("ERROR: LINEAR_API_KEY is required", file=sys.stderr)
        sys.exit(1)

    team_id = payload.get("team_id") or os.environ.get("LINEAR_TEAM_ID", "")
    if not team_id:
        print("ERROR: team_id (or env LINEAR_TEAM_ID) is required", file=sys.stderr)
        sys.exit(1)

    print(f"INFO: linear action={action}", file=sys.stderr)

    if action == "create-ticket":
        variables = {
            "input": {
                "teamId": team_id,
                "title": payload.get("title", "Untitled"),
                "description": payload.get("description", ""),
                "priority": int(payload.get("priority", 0) or 0),
            }
        }
        if payload.get("label_ids"):
            variables["input"]["labelIds"] = payload["label_ids"]
        data = _post(api_key, CREATE_ISSUE_MUTATION, variables)
        print(json.dumps(data))

    elif action == "version":
        variables = {
            "input": {
                "teamIds": [team_id],
                "name": payload.get("name", "Untitled Version"),
                "description": payload.get("description", ""),
            }
        }
        if payload.get("target_date"):
            variables["input"]["targetDate"] = payload["target_date"]
        data = _post(api_key, CREATE_PROJECT_MUTATION, variables)
        print(json.dumps(data))

    else:
        print(f"ERROR: unknown action '{action}'", file=sys.stderr)
        sys.exit(1)

    print(f"INFO: linear {action} complete", file=sys.stderr)


if __name__ == "__main__":
    main()
