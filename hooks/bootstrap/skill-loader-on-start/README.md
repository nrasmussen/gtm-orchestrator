# skill-loader-on-start

This hook runs at the very beginning of every session to load the orchestrator's skill definitions into the Claude Code context. Skills are reusable prompt modules stored on disk; loading them at session start means they are available for the agent to invoke throughout the session without needing to be explicitly referenced each time.

## When it fires

Fires on the `SessionStart` event, which Claude Code triggers once immediately when a new session begins, before any user messages are processed.

## What it runs

```
orchestrator/sh/local.sh load-skills
```

The script scans the configured skills directory, reads each skill definition file, and outputs them in a format that Claude Code injects into the session context.

## Required environment variables

| Variable | Description |
|---|---|
| `SKILLS_DIR` | Absolute path to the directory containing skill definition files (e.g. `/path/to/montgomery/skills`) |

## Optional environment variables

| Variable | Description |
|---|---|
| `SKILLS_GLOB` | Glob pattern for skill files within `SKILLS_DIR` (default: `**/*.md`) |
| `SKILLS_MAX_TOKENS` | Maximum total tokens to load from skills before truncating (default: no limit) |
