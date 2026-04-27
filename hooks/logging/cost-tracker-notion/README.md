# cost-tracker-notion

This hook logs token usage and estimated API cost for the session to a Notion database when the session ends. Over time the database becomes a cost dashboard you can query to understand spending patterns across projects, users, or time periods.

## When it fires

Fires on the `SessionEnd` event, which Claude Code triggers once when the session is fully closed.

## What it runs

```
orchestrator/run.sh notion cost-log
```

The script extracts token counts and cost estimates from the session context and appends a row to the configured Notion cost-tracking database.

## Required environment variables

| Variable | Description |
|---|---|
| `NOTION_API_KEY` | Internal integration token from your Notion integration settings |
| `NOTION_COST_DATABASE_ID` | Database ID for cost entries (must have `Description` title and `Amount` number properties) |
