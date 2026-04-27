# lemlist-add-lead

This hook adds a lead to a Lemlist campaign after every tool use. When the agent identifies or researches a prospect, their contact details are immediately pushed to Lemlist so they enter the outbound sequence without manual importing.

## When it fires

Fires on the `PostToolUse` event, which triggers after every tool the agent uses successfully.

## What it runs

```
orchestrator/run.sh lemlist add-lead
```

The script extracts contact information from the tool result payload and calls the Lemlist API to add or update the lead in the target campaign.

## Required environment variables

| Variable | Description |
|---|---|
| `LEMLIST_API_KEY` | API key from your Lemlist account settings |
| `LEMLIST_CAMPAIGN_ID` | ID of the Lemlist campaign to add leads to |

## Optional environment variables

| Variable | Description |
|---|---|
| `LEMLIST_DEDUPLICATE` | Set to `true` to skip adding leads that already exist in the campaign (default: `true`) |
| `LEMLIST_CUSTOM_VARS` | JSON string of custom variable mappings to include in the lead payload |
