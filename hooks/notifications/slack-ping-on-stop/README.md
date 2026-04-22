# slack-ping-on-stop

This hook sends a Slack message every time Claude Code stops responding (the Stop event). It is useful for staying informed when a long-running agent session finishes or pauses waiting for the next prompt. The message can include a brief status summary from the orchestrator.

## When it fires

Fires on the `Stop` event, which Claude Code triggers whenever the agent stops generating output and returns control to the user.

## What it runs

```
orchestrator/sh/slack.sh notify
```

The script reads session context from stdin (JSON provided by Claude Code) and posts a notification to the configured Slack channel.

## Required environment variables

| Variable | Description |
|---|---|
| `SLACK_BOT_TOKEN` | OAuth bot token for your Slack app (`xoxb-...`) |
| `SLACK_NOTIFY_CHANNEL` | Channel ID or name to post the notification into |

## Optional environment variables

| Variable | Description |
|---|---|
| `SLACK_NOTIFY_TEMPLATE` | Path to a custom message template file |
