# linear-design-version

This hook records a design version entry in Linear after every tool use. When the agent writes or modifies design files, this hook creates a comment or sub-issue on the relevant Linear ticket capturing which version was produced, what changed, and a reference to the asset, building a versioned audit trail inside your issue tracker.

## When it fires

Fires on the `PostToolUse` event, which triggers after every tool the agent uses successfully.

## What it runs

```
orchestrator/sh/linear.sh version
```

The script reads the tool result from the hook payload and posts a version comment or creates a version sub-issue on the configured Linear ticket.

## Required environment variables

| Variable | Description |
|---|---|
| `LINEAR_API_KEY` | Personal API key from your Linear account settings |
| `LINEAR_DESIGN_ISSUE_ID` | ID of the Linear issue to attach version records to |

## Optional environment variables

| Variable | Description |
|---|---|
| `LINEAR_VERSION_PREFIX` | String prefix for version labels (default: `v`) |
| `LINEAR_VERSION_LABEL_ID` | Label ID to apply to version sub-issues for easy filtering |
