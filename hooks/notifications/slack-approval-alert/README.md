# slack-approval-alert

This hook posts a Slack message whenever Claude Code emits a Notification event, which typically happens when the agent needs human approval or wants to surface something important mid-session. It lets your team react to agent requests in real time without watching the terminal.

## When it fires

Fires on the `Notification` event, which Claude Code emits when it wants to surface an alert or approval request to the user.

## What it runs

```
orchestrator/run.sh slack approval
```

The script formats the notification payload from stdin into a Slack message, optionally with an action button if the notification type is an approval request.

## Required environment variables

| Variable | Description |
|---|---|
| `SLACK_WEBHOOK_URL` | Incoming webhook URL for the channel where approval alerts are posted |

The webhook URL already encodes the destination channel; no separate channel/token vars are needed. Mentions can be embedded in the notification text emitted by Claude Code (e.g. include `<!here>` in the message text).
