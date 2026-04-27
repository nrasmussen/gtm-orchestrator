# slack-ping-on-stop

This hook sends a Slack message every time Claude Code stops responding (the Stop event). It is useful for staying informed when a long-running agent session finishes or pauses waiting for the next prompt. The message can include a brief status summary from the orchestrator.

## When it fires

Fires on the `Stop` event, which Claude Code triggers whenever the agent stops generating output and returns control to the user.

## What it runs

```
orchestrator/run.sh slack notify
```

The script reads session context from stdin (JSON provided by Claude Code) and posts a notification to the configured Slack channel.

## Required environment variables

| Variable | Description |
|---|---|
| `SLACK_WEBHOOK_URL` | Incoming webhook URL for the channel you want messages posted to |

The webhook URL already encodes the destination channel; no separate channel/token vars are needed.
