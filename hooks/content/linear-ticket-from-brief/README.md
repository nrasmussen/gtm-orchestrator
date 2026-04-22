# linear-ticket-from-brief

This hook creates a Linear ticket whenever the agent uses the Write tool, treating written output as a brief or task specification. It is intended for product and design workflows where the agent writes specs, briefs, or task descriptions that should immediately become tracked work items in Linear.

## When it fires

Fires on the `PostToolUse` event with a matcher of `Write`, meaning it triggers after every successful call to the Write tool.

## What it runs

```
orchestrator/sh/linear.sh create-ticket
```

The script reads the file path and content written by the tool from the hook payload and creates a corresponding Linear issue.

## Required environment variables

| Variable | Description |
|---|---|
| `LINEAR_API_KEY` | Personal API key from your Linear account settings |
| `LINEAR_TEAM_ID` | ID of the Linear team where tickets are created |

## Optional environment variables

| Variable | Description |
|---|---|
| `LINEAR_DEFAULT_PROJECT_ID` | Project to assign new tickets to when not inferred from context |
| `LINEAR_DEFAULT_ASSIGNEE_ID` | User ID to assign tickets to by default |
| `LINEAR_TICKET_LABEL_IDS` | Comma-separated list of label IDs to apply to created tickets |
