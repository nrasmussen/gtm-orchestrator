# figma-export-frame

This hook exports specified Figma frames to local files when Claude Code stops. It is designed for design-ops workflows where the agent references or generates Figma frame IDs and those frames should be exported automatically as PNGs or SVGs for use in presentations, docs, or handoff packages.

## When it fires

Fires on the `Stop` event, which Claude Code triggers whenever the agent stops generating output and returns control to the user.

## What it runs

```
orchestrator/sh/figma.sh export
```

The script reads any Figma frame IDs surfaced during the session, calls the Figma Export API, and writes the resulting image files to the configured output directory.

## Required environment variables

| Variable | Description |
|---|---|
| `FIGMA_ACCESS_TOKEN` | Personal access token from your Figma account settings |
| `FIGMA_FILE_KEY` | Key of the Figma file containing the frames to export |
| `FIGMA_EXPORT_DIR` | Local directory path where exported images are saved |

## Optional environment variables

| Variable | Description |
|---|---|
| `FIGMA_EXPORT_FORMAT` | Image format for exports: `png`, `svg`, `jpg`, or `pdf` (default: `png`) |
| `FIGMA_EXPORT_SCALE` | Scale multiplier for raster exports (default: `2` for 2x resolution) |
