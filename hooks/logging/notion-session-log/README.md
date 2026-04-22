# notion-session-log

This hook creates a new page in a Notion database at the end of every session. Each page captures the session ID, start and end timestamps, a summary of agent actions, tools used, and any significant outputs. It builds a searchable, browsable history of all agent sessions inside Notion.

## When it fires

Fires on the `SessionEnd` event, which Claude Code triggers once when the session is fully closed.

## What it runs

```
orchestrator/sh/notion.sh log-session
```

The script reads the full session summary from stdin and creates or updates a Notion database entry via the Notion API.

## Required environment variables

| Variable | Description |
|---|---|
| `NOTION_API_KEY` | Internal integration token from your Notion integration settings |
| `NOTION_SESSION_LOG_DB` | ID of the Notion database that stores session log entries |

## Optional environment variables

| Variable | Description |
|---|---|
| `NOTION_SESSION_LOG_ICON` | Emoji or external URL to use as the page icon |
| `NOTION_SESSION_LOG_COVER` | External image URL to use as the page cover |
