# sheets-append-row

This hook appends a row to a Google Sheet after every tool use. Use it to maintain a running log of agent activity — tool calls, outputs, timestamps, or any structured data the agent produces — directly in a spreadsheet that stakeholders can view without any additional setup.

## When it fires

Fires on the `PostToolUse` event, which triggers after every tool the agent uses successfully.

## What it runs

```
bash "$CLAUDE_GTM_DIR/orchestrator/run.sh" sheets append
```

The script reads a JSON payload from stdin containing `range` and `values` fields, then calls `POST /v4/spreadsheets/{spreadsheetId}/values/{range}:append` on the Google Sheets API and confirms the number of rows written.

## Required environment variables

| Variable | Description |
|---|---|
| `GOOGLE_SHEETS_SPREADSHEET_ID` | ID of the target spreadsheet, found in its URL between `/d/` and `/edit` |
| `GOOGLE_SHEETS_API_KEY` | Google API key with Sheets API access enabled (Google Cloud Console > APIs & Services > Credentials) |

## Optional environment variables

| Variable | Description |
|---|---|
| `DRY_RUN` | Set to `1` to log the payload and skip the API call |
