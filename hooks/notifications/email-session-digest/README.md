# email-session-digest

This hook sends an email digest via Gmail at the end of every session. The digest summarises what the agent did, which tools were used, and any notable outputs, giving you a persistent record in your inbox that you can search and forward.

## When it fires

Fires on the `SessionEnd` event, which Claude Code triggers once when the session is fully closed.

## What it runs

```
orchestrator/sh/gmail.sh digest
```

The script assembles a structured digest from the session context passed via stdin and sends it to the configured recipient using the Gmail API.

## Required environment variables

| Variable | Description |
|---|---|
| `GMAIL_CREDENTIALS_FILE` | Path to your OAuth 2.0 credentials JSON file for the Gmail API |
| `GMAIL_TOKEN_FILE` | Path to the stored OAuth token file |
| `DIGEST_RECIPIENT_EMAIL` | Email address that receives the session digest |

## Optional environment variables

| Variable | Description |
|---|---|
| `DIGEST_SUBJECT_PREFIX` | String prepended to the email subject line (default: `[Claude Session]`) |
| `DIGEST_CC_EMAIL` | Additional CC recipient |
