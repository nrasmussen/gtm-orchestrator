# smartlead-push-campaign

This hook pushes leads and email sequences to Smartlead when Claude Code stops. It connects agent-driven prospect research and copy generation directly to a Smartlead campaign, eliminating the manual step of uploading CSV files or copy-pasting sequences.

## When it fires

Fires on the `Stop` event, which Claude Code triggers whenever the agent stops generating output and returns control to the user.

## What it runs

```
orchestrator/run.sh smartlead push
```

The script reads staged leads and sequence copy from the session context and submits them to the Smartlead API for the configured campaign.

## Required environment variables

| Variable | Description |
|---|---|
| `SMARTLEAD_API_KEY` | API key from your Smartlead account settings |
| `SMARTLEAD_CAMPAIGN_ID` | ID of the Smartlead campaign to push leads and sequences into |

## Optional environment variables

| Variable | Description |
|---|---|
| `SMARTLEAD_CLIENT_ID` | Client ID if using Smartlead in agency mode to scope the campaign |
| `SMARTLEAD_SEQUENCE_DELAY_DAYS` | Number of days between sequence steps when creating a new sequence (default: `2`) |
