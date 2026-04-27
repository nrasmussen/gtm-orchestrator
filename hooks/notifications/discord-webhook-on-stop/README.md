# discord-webhook-on-stop

This hook posts a message to a Discord channel via an incoming webhook every time Claude Code stops. It mirrors the Slack stop-ping for teams who operate primarily in Discord instead of Slack.

## When it fires

Fires on the `Stop` event, which Claude Code triggers whenever the agent stops generating output and returns control to the user.

## What it runs

```
orchestrator/run.sh discord notify
```

The script reads session context from stdin and sends a POST request to the configured Discord webhook URL.

## Required environment variables

| Variable | Description |
|---|---|
| `DISCORD_WEBHOOK_URL` | Full incoming webhook URL from your Discord server settings |

## Optional environment variables

| Variable | Description |
|---|---|
| `DISCORD_NOTIFY_USERNAME` | Override display name for the webhook bot (defaults to the webhook's configured name) |
| `DISCORD_NOTIFY_AVATAR_URL` | Override avatar URL for the webhook message |
