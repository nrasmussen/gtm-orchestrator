# notion-content-archive

This hook archives any content outputs from the session into a Notion database when Claude Code stops. Blog drafts, copy variations, email bodies, and other written outputs are each stored as Notion pages, keeping a permanent, searchable content library.

## When it fires

Fires on the `Stop` event, which Claude Code triggers whenever the agent stops generating output and returns control to the user.

## What it runs

```
orchestrator/sh/notion.sh save-content
```

The script scans the session output for content blocks and creates one Notion page per content piece in the configured archive database.

## Required environment variables

| Variable | Description |
|---|---|
| `NOTION_API_KEY` | Internal integration token from your Notion integration settings |
| `NOTION_CONTENT_ARCHIVE_DB` | ID of the Notion database used as the content archive |

## Optional environment variables

| Variable | Description |
|---|---|
| `NOTION_CONTENT_TAG_PROPERTY` | Name of the multi-select property used to tag content type (default: `Tags`) |
| `NOTION_CONTENT_STATUS_PROPERTY` | Name of the status property to set on new entries (default: `Status`) |
