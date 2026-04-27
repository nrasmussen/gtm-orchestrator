# lemlist-push-sequence

This hook pushes a batch of leads and their personalisation data to a Lemlist sequence when Claude Code stops. It is designed for end-of-session batch submissions where the agent has assembled a full list of prospects and crafted personalised copy that should be loaded into a Lemlist sequence in one go.

## When it fires

Fires on the `Stop` event, which Claude Code triggers whenever the agent stops generating output and returns control to the user.

## What it runs

```
orchestrator/run.sh lemlist push-sequence
```

The script collects any staged lead records from the session context and submits them as a batch to the configured Lemlist sequence.

## Required environment variables

| Variable | Description |
|---|---|
| `LEMLIST_API_KEY` | API key from your Lemlist account settings |
| `LEMLIST_SEQUENCE_CAMPAIGN_ID` | ID of the Lemlist campaign/sequence for batch pushes |

## Optional environment variables

| Variable | Description |
|---|---|
| `LEMLIST_SCHEDULE_DATE` | ISO 8601 date-time to schedule the first email send (defaults to campaign schedule) |
| `LEMLIST_PAUSE_ON_PUSH` | Set to `true` to pause the campaign after pushing the batch for manual review (default: `false`) |
