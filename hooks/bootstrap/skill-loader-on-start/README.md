# skill-loader-on-start

This hook runs at the very beginning of every session to load the orchestrator's skill definitions into the Claude Code context. Skills are reusable prompt modules stored on disk; loading them at session start means they are available for the agent to invoke throughout the session without needing to be explicitly referenced each time.

## When it fires

Fires on the `SessionStart` event, which Claude Code triggers once immediately when a new session begins, before any user messages are processed.

## What it runs

```
orchestrator/run.sh local load-skills
```

The script scans the configured skills directory, reads each skill definition file, and outputs them in a format that Claude Code injects into the session context.

## Optional environment variables

| Variable | Description |
|---|---|
| `LOCAL_SKILLS_DIR` | Absolute path to the directory containing skill definition files. Defaults to `$LOCAL_DATA_DIR/skills`, which itself defaults to `~/.orchestrator/data/skills`. Each skill must live in `<dir>/<name>/SKILL.md`. |
| `LOCAL_DATA_DIR` | Base directory for orchestrator data (transcripts, skills). Default: `~/.orchestrator/data`. |
