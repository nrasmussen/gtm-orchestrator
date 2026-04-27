# linear-ticket-from-brief

This hook creates a Linear ticket whenever the agent uses the Write tool, treating written output as a brief or task specification. It is intended for product and design workflows where the agent writes specs, briefs, or task descriptions that should immediately become tracked work items in Linear.

## When it fires

Fires on the `PostToolUse` event with a matcher of `Write`, meaning it triggers after every successful call to the Write tool.

## What it runs

```
orchestrator/run.sh linear create-ticket
```

The script reads the file path and content written by the tool from the hook payload and creates a corresponding Linear issue.

## Required environment variables

| Variable | Description |
|---|---|
| `LINEAR_API_KEY` | API key from Settings > API in Linear |
| `LINEAR_TEAM_ID` | Default team ID for new tickets (also overridable via stdin payload) |
