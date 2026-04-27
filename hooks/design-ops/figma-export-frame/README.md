# figma-export-frame

This hook exports specified Figma frames to local files when Claude Code stops. It is designed for design-ops workflows where the agent references or generates Figma frame IDs and those frames should be exported automatically as PNGs or SVGs for use in presentations, docs, or handoff packages.

## When it fires

Fires on the `Stop` event, which Claude Code triggers whenever the agent stops generating output and returns control to the user.

## What it runs

```
orchestrator/run.sh figma export
```

The script reads any Figma frame IDs surfaced during the session, calls the Figma Export API, and writes the resulting image files to the configured output directory.

## Required environment variables

| Variable | Description |
|---|---|
| `FIGMA_API_KEY` | Personal access token from your Figma account settings |

The Stop event payload should include `file_key` and `node_id` so the handler knows which frame to export. The handler returns the Figma-hosted image URL on stdout — pipe to a downstream hook (e.g. Notion or Slack) to persist or share.
