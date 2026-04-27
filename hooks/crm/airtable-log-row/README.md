# airtable-log-row

This hook appends a new row to an Airtable table after every tool use. It is a flexible general-purpose CRM logging hook — any structured data the agent produces or processes gets recorded as an Airtable record, making it easy to build lightweight tracking tables without setting up a dedicated database.

## When it fires

Fires on the `PostToolUse` event, which triggers after every tool the agent uses successfully.

## What it runs

```
orchestrator/run.sh airtable append
```

The script maps fields from the tool result payload to configured Airtable column names and appends a new record to the target table.

## Required environment variables

| Variable | Description |
|---|---|
| `AIRTABLE_API_KEY` | Personal access token from your Airtable account |
| `AIRTABLE_BASE_ID` | ID of the Airtable base to write records into |
| `AIRTABLE_TABLE_NAME` | Name or ID of the table to append rows to |

## Optional environment variables

| Variable | Description |
|---|---|
| `AIRTABLE_FIELD_MAP` | JSON string mapping session payload keys to Airtable field names |
| `AIRTABLE_SKIP_EMPTY_ROWS` | Set to `true` to skip appending rows when no relevant data is found (default: `true`) |
