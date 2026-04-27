# linear-design-version

This hook records a design version entry in Linear after every tool use. When the agent writes or modifies design files, this hook creates a comment or sub-issue on the relevant Linear ticket capturing which version was produced, what changed, and a reference to the asset, building a versioned audit trail inside your issue tracker.

## When it fires

Fires on the `PostToolUse` event, which triggers after every tool the agent uses successfully.

## What it runs

```
orchestrator/run.sh linear version
```

The script reads the tool result from the hook payload and posts a version comment or creates a version sub-issue on the configured Linear ticket.

## Required environment variables

| Variable | Description |
|---|---|
| `LINEAR_API_KEY` | API key from Settings > API in Linear |
| `LINEAR_TEAM_ID` | Default team ID for new versions / projects |
