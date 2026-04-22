# slack-approval-alert

This hook posts a Slack message whenever Claude Code emits a Notification event, which typically happens when the agent needs human approval or wants to surface something important mid-session. It lets your team react to agent requests in real time without watching the terminal.

## When it fires

Fires on the `Notification` event, which Claude Code emits when it wants to surface an alert or approval request to the user.

## What it runs

```
orchestrator/sh/slack.sh approval
```

The script formats the notification payload from stdin into a Slack message, optionally with an action button if the notification type is an approval request.

## Required environment variables

| Variable | Description |
|---|---|
| `SLACK_BOT_TOKEN` | OAuth bot token for your Slack app (`xoxb-...`) |
| `SLACK_APPROVAL_CHANNEL` | Channel ID or name where approval alerts are posted |

## Optional environment variables

| Variable | Description |
|---|---|
| `SLACK_APPROVAL_MENTION` | User or group ID to `@mention` in the alert (e.g. `@here` or a user ID) |
