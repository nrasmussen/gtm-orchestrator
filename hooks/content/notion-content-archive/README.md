# notion-content-archive

This hook archives any content outputs from the session into a Notion database when Claude Code stops. Blog drafts, copy variations, email bodies, and other written outputs are each stored as Notion pages, keeping a permanent, searchable content library.

## When it fires

Fires on the `Stop` event, which Claude Code triggers whenever the agent stops generating output and returns control to the user.

## What it runs

```
orchestrator/run.sh notion save-content
```

The script scans the session output for content blocks and creates one Notion page per content piece in the configured archive database.

## Required environment variables

| Variable | Description |
|---|---|
| `NOTION_API_KEY` | Internal integration token from your Notion integration settings |
| `NOTION_PARENT_PAGE_ID` | Page ID under which new content pages are created |

To route content into a specific Notion database instead, override `parent_id` in the hook command's stdin payload (e.g. via a small wrapper script) or bridge through Zapier/Make.
