# daily-digest-slack

This hook contributes the current session's summary to a running daily digest and posts or updates a Slack message with the accumulated summary at session end. When multiple sessions run in a day, the digest message is updated in place so the channel does not get spammed.

## When it fires

Fires on the `SessionEnd` event, which Claude Code triggers once when the session is fully closed.

## What it runs

```
orchestrator/sh/slack.sh daily-digest
```

The script appends the current session summary to a local daily accumulator file and either creates a new Slack message or updates the existing day's message via the Slack API.

## Required environment variables

| Variable | Description |
|---|---|
| `SLACK_BOT_TOKEN` | OAuth bot token for your Slack app (`xoxb-...`) |
| `SLACK_DIGEST_CHANNEL` | Channel ID or name where the daily digest is posted |

## Optional environment variables

| Variable | Description |
|---|---|
| `DIGEST_ACCUMULATOR_DIR` | Directory for the local accumulator files (default: `/tmp/claude-digests`) |
| `SLACK_DIGEST_POST_HOUR` | Hour (0-23) at which the final digest is pinned (default: first session past midnight flushes the previous day) |
