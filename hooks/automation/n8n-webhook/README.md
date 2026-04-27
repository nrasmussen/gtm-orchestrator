# n8n-webhook

This hook fires an n8n webhook trigger when Claude Code stops, sending the session context as JSON. It connects Claude Code to any n8n workflow that starts with a Webhook node, letting you route agent outputs through n8n's no-code automation graph.

## When it fires

Fires on the `Stop` event by default. You can change the event in `hook.json` to `SessionEnd`, `PostToolUse`, or any other valid Claude Code hook event to match the trigger logic of your n8n workflow.

## What it runs

```
orchestrator/run.sh n8n fire
```

The script reads the session context from stdin and sends an HTTP POST to the configured n8n webhook URL.

## Required environment variables

| Variable | Description |
|---|---|
| `N8N_WEBHOOK_URL` | The webhook URL from your n8n Webhook node (production or test URL) |

## Optional environment variables

| Variable | Description |
|---|---|
| `N8N_WEBHOOK_AUTH_HEADER` | Value of the `Authorization` header if your n8n webhook uses header auth |
| `N8N_PAYLOAD_FILTER` | Comma-separated list of session context keys to include in the payload (defaults to sending everything) |
