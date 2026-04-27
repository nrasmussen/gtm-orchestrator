# typefully-draft-queue

This hook pushes any social media content produced during a session into Typefully's draft queue when Claude Code stops. It is designed for content-creation workflows where the agent writes threads, posts, or captions and you want them staged for scheduling without manual copy-paste.

## When it fires

Fires on the `Stop` event, which Claude Code triggers whenever the agent stops generating output and returns control to the user.

## What it runs

```
orchestrator/run.sh typefully draft
```

The script inspects the session output for content marked for social publishing and creates draft entries in Typefully via its API.

## Required environment variables

| Variable | Description |
|---|---|
| `TYPEFULLY_API_KEY` | API key from your Typefully account settings |

## Optional environment variables

| Variable | Description |
|---|---|
| `TYPEFULLY_DEFAULT_PROFILE` | Twitter/X profile handle to assign drafts to when not specified in the content |
| `TYPEFULLY_AUTO_SCHEDULE` | Set to `true` to let Typefully auto-schedule the draft rather than leaving it unscheduled (default: `false`) |
