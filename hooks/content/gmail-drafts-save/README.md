# gmail-drafts-save

This hook saves any email content produced during a session as Gmail drafts when Claude Code stops. It is useful for outreach or communication workflows where the agent writes emails that you want to review and send manually rather than sending automatically.

## When it fires

Fires on the `Stop` event, which Claude Code triggers whenever the agent stops generating output and returns control to the user.

## What it runs

```
orchestrator/sh/gmail.sh draft
```

The script detects email content blocks in the session output and creates Gmail drafts via the Gmail API for each one.

## Required environment variables

| Variable | Description |
|---|---|
| `GMAIL_CREDENTIALS_FILE` | Path to your OAuth 2.0 credentials JSON file for the Gmail API |
| `GMAIL_TOKEN_FILE` | Path to the stored OAuth token file |

## Optional environment variables

| Variable | Description |
|---|---|
| `GMAIL_DRAFT_LABEL` | Gmail label to apply to newly created drafts for easy filtering |
| `GMAIL_DRAFT_DEFAULT_FROM` | Sender address to use when the content does not specify one |
