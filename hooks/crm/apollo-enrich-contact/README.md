# apollo-enrich-contact

This hook enriches contact records via the Apollo.io people-match API after every tool use. When the agent encounters an email address or company domain — for example while reading a CRM export, processing inbound leads, or researching prospects — this hook sends that signal to Apollo.io and returns enriched person data including job title, seniority, LinkedIn URL, phone number, and company firmographics.

## When it fires

Fires on the `PostToolUse` event, which triggers after every tool the agent uses successfully.

## What it runs

```
bash "$CLAUDE_GTM_DIR/orchestrator/run.sh" apollo enrich
```

The script reads a JSON payload from stdin containing `email` and/or `domain`, then calls `POST /api/v1/people/match` on the Apollo.io REST API and writes the enriched person object to stdout.

## Required environment variables

| Variable | Description |
|---|---|
| `APOLLO_API_KEY` | API key from your Apollo.io account (Settings > API) |

## Optional environment variables

| Variable | Description |
|---|---|
| `DRY_RUN` | Set to `1` to log the payload and skip the API call |
