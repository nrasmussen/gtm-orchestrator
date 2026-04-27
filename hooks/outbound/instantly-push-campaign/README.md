# instantly-push-campaign

This hook pushes leads and campaign copy to Instantly when Claude Code stops. It is built for outbound workflows where the agent researches prospects and writes personalised email sequences that should be loaded directly into an Instantly campaign for sending.

## When it fires

Fires on the `Stop` event, which Claude Code triggers whenever the agent stops generating output and returns control to the user.

## What it runs

```
orchestrator/run.sh instantly push
```

The script collects staged leads and copy from the session context and calls the Instantly API to add them to the configured campaign.

## Required environment variables

| Variable | Description |
|---|---|
| `INSTANTLY_API_KEY` | API key from your Instantly account |
| `INSTANTLY_CAMPAIGN_ID` | ID of the Instantly campaign to push leads into |

## Optional environment variables

| Variable | Description |
|---|---|
| `INSTANTLY_VERIFY_EMAILS` | Set to `true` to trigger Instantly email verification before adding leads (default: `false`) |
| `INSTANTLY_SKIP_IF_UNSUBSCRIBED` | Set to `true` to skip leads who are on the global unsubscribe list (default: `true`) |
