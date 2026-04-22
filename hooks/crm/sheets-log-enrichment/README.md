# sheets-log-enrichment

This hook writes enrichment results to a Google Sheet when the agent finishes its turn. Use it to keep a persistent record of every contact or company the agent enriched during a session — name, title, company, domain, and any other fields returned by the enrichment API — so your team has a full audit trail without leaving their spreadsheet workflow.

## When it fires

Fires on the `Stop` event, which triggers once when the agent completes its final response for the turn.

## What it runs

```
bash "$CLAUDE_GTM_DIR/orchestrator/run.sh" sheets append
```

The script reads a JSON payload from stdin containing `range` and `values` fields, then calls `POST /v4/spreadsheets/{spreadsheetId}/values/{range}:append` on the Google Sheets API and confirms the rows written.

## Required environment variables

| Variable | Description |
|---|---|
| `GOOGLE_SHEETS_SPREADSHEET_ID` | ID of the target spreadsheet, found in its URL between `/d/` and `/edit` |
| `GOOGLE_SHEETS_API_KEY` | Google API key with Sheets API access enabled (Google Cloud Console > APIs & Services > Credentials) |

## Optional environment variables

| Variable | Description |
|---|---|
| `DRY_RUN` | Set to `1` to log the payload and skip the API call |
