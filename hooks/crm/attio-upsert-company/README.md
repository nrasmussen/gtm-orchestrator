# attio-upsert-company

This hook upserts company records in Attio after every tool use. When the agent reads, writes, or processes data that contains company information — domain names, company names, firmographics — this hook extracts that data and creates or updates the corresponding Attio company record, keeping your CRM in sync with what the agent discovers.

## When it fires

Fires on the `PostToolUse` event, which triggers after every tool the agent uses successfully.

## What it runs

```
orchestrator/run.sh attio upsert
```

The script parses the tool result from the hook payload, extracts any company signals, and calls the Attio API to upsert a company record.

## Required environment variables

| Variable | Description |
|---|---|
| `ATTIO_API_KEY` | API key from your Attio workspace settings |

## Optional environment variables

| Variable | Description |
|---|---|
| `ATTIO_COMPANY_LIST_ID` | ID of the Attio list to add upserted companies to |
| `ATTIO_UPSERT_MATCH_FIELD` | Field used to match existing records (default: `domains`) |
