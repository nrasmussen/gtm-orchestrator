# clay-table-sync

This hook syncs leads and enrichment data produced during the session to a Clay table when Claude Code stops. It allows the agent's research outputs to flow directly into Clay, where Clay's enrichment waterfall can augment the data further before it moves to outbound tools.

## When it fires

Fires on the `Stop` event, which Claude Code triggers whenever the agent stops generating output and returns control to the user.

## What it runs

```
orchestrator/run.sh clay sync
```

The script collects lead records and any structured data from the session context and upserts them into the target Clay table via the Clay API.

## Required environment variables

| Variable | Description |
|---|---|
| `CLAY_API_KEY` | API key from your Clay workspace settings |
| `CLAY_TABLE_ID` | ID of the Clay table to sync records into |

## Optional environment variables

| Variable | Description |
|---|---|
| `CLAY_UPSERT_KEY` | Field name used to match existing rows for upsert (default: `email`) |
| `CLAY_RUN_ENRICHMENT` | Set to `true` to trigger Clay's enrichment waterfall on newly added rows (default: `false`) |
