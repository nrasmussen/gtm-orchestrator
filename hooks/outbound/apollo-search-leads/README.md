# apollo-search-leads

This hook runs a people search against Apollo.io when the agent finishes its turn. Use it to automatically pull a fresh list of matching prospects at the end of a session — for example after the agent has refined an ideal customer profile, drafted targeting criteria, or identified a new market segment. The results can be piped into a downstream sequencing or CRM hook.

## When it fires

Fires on the `Stop` event, which triggers once when the agent completes its final response for the turn.

## What it runs

```
bash "$CLAUDE_GTM_DIR/orchestrator/run.sh" apollo search
```

The script reads a JSON payload from stdin with a `query` object matching the Apollo.io mixed-people search schema, then calls `POST /api/v1/mixed_people/search` and writes the results to stdout.

## Required environment variables

| Variable | Description |
|---|---|
| `APOLLO_API_KEY` | API key from your Apollo.io account (Settings > API) |

## Optional environment variables

| Variable | Description |
|---|---|
| `DRY_RUN` | Set to `1` to log the payload and skip the API call |
