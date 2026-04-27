# notion-design-doc

This hook creates or updates a structured design document in Notion when Claude Code stops. It is intended for design-ops workflows where the agent produces design rationale, component specifications, or system documentation that belongs in a Notion design wiki alongside the rest of the project's knowledge base.

## When it fires

Fires on the `Stop` event, which Claude Code triggers whenever the agent stops generating output and returns control to the user.

## What it runs

```
orchestrator/run.sh notion design-doc
```

The script formats the design outputs from the session into a structured Notion page and creates or updates the relevant page in the configured database.

## Required environment variables

| Variable | Description |
|---|---|
| `NOTION_API_KEY` | Internal integration token from your Notion integration settings |
| `NOTION_PARENT_PAGE_ID` | Page ID under which new design doc pages are created |
