# local-markdown-transcript

This hook saves a full Markdown transcript of the session to a local file when the session ends. The file includes every message exchanged, tool calls and their results, and a summary header. It gives you an offline, version-controllable record that does not depend on any external service.

## When it fires

Fires on the `SessionEnd` event, which Claude Code triggers once when the session is fully closed.

## What it runs

```
orchestrator/run.sh local save-transcript
```

The script reads the session context from stdin and writes a `.md` file to the configured output directory, naming the file with the session ID and a timestamp.

## Required environment variables

| Variable | Description |
|---|---|
| `LOCAL_TRANSCRIPT_DIR` | Absolute path to the directory where transcript files are written |

## Optional environment variables

| Variable | Description |
|---|---|
| `LOCAL_TRANSCRIPT_FILENAME_FORMAT` | strftime-style format for the filename (default: `%Y-%m-%d_%H-%M-%S_{session_id}.md`) |
| `LOCAL_TRANSCRIPT_INCLUDE_TOOL_RESULTS` | Set to `false` to omit verbose tool output from the transcript (default: `true`) |
