# cost-tracker-notion

This hook logs token usage and estimated API cost for the session to a Notion database when the session ends. Over time the database becomes a cost dashboard you can query to understand spending patterns across projects, users, or time periods.

## When it fires

Fires on the `SessionEnd` event, which Claude Code triggers once when the session is fully closed.

## What it runs

```
orchestrator/sh/notion.sh cost-log
```

The script extracts token counts and cost estimates from the session context and appends a row to the configured Notion cost-tracking database.

## Required environment variables

| Variable | Description |
|---|---|
| `NOTION_API_KEY` | Internal integration token from your Notion integration settings |
| `NOTION_COST_LOG_DB` | ID of the Notion database that stores cost entries |

## Optional environment variables

| Variable | Description |
|---|---|
| `COST_CURRENCY` | Currency code for cost display (default: `USD`) |
| `COST_MODEL_RATE_OVERRIDE` | JSON string mapping model IDs to per-token rates, overriding built-in defaults |
