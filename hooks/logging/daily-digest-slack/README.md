# daily-digest-slack

This hook contributes the current session's summary to a running daily digest and posts or updates a Slack message with the accumulated summary at session end. When multiple sessions run in a day, the digest message is updated in place so the channel does not get spammed.

## When it fires

Fires on the `SessionEnd` event, which Claude Code triggers once when the session is fully closed.

## What it runs

```
orchestrator/run.sh slack daily-digest
```

The script appends the current session summary to a local daily accumulator file and either creates a new Slack message or updates the existing day's message via the Slack API.

## Required environment variables

| Variable | Description |
|---|---|
| `SLACK_WEBHOOK_URL` | Incoming webhook URL for the channel where the daily digest is posted |

The current implementation posts a fresh message per `SessionEnd`. Aggregating multiple sessions into a single updated message requires a Slack bot token (`chat.update`); use Zapier/n8n as a bridge if you need that behavior.
