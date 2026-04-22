# Claude Code Hooks for GTM

Claude Code hooks for GTM teams. Trigger real actions in Slack, Apollo, Lemlist, Notion, Google Sheets, and 15+ other tools when Claude finishes work.

---

## The 3-layer system

```
┌─────────────────────────────────────────────────────────┐
│  CLAUDE CODE SESSION                                    │
│                                                         │
│  1. SKILLS (from claude-md-repo, copied into /skills/)  │
│     Pre-written instruction files that tell Claude      │
│     HOW to do GTM work (enrichment, outreach, etc.)     │
│           ↓                                             │
│  2. HOOKS (settings.json snippets in /hooks/)           │
│     Fire on Claude Code lifecycle events (Stop,         │
│     PostToolUse, SessionEnd, Notification, etc.)        │
│           ↓                                             │
│  3. ORCHESTRATOR (/orchestrator/)                       │
│     Shell and Python scripts that read the hook's       │
│     JSON payload via stdin and execute against real     │
│     APIs or MCP servers (Slack, Apollo, Lemlist, etc.)  │
└─────────────────────────────────────────────────────────┘
```

Skills = what to do. Hooks = when to act. Orchestrator = how to actually send it somewhere.

---

## What this repo gives you

- **32 hooks** across 8 categories (notifications, logging, content, CRM, outbound, design-ops, automation, bootstrap)
- **15 integrations** (Slack, Discord, Gmail, Notion, Apollo, HubSpot, Attio, Airtable, Google Sheets, Lemlist, Instantly, Smartlead, Clay, Typefully, Zapier/n8n/Make) with both shell and Python implementations
- **17 content prompts** for pitch decks, one-pagers, carousels, case studies, and proposals
- **Skill library** synced from [claude-md-repo](https://github.com/janskuba/claude-md-repo) and [outbound-agents](https://github.com/janskuba/outbound-agents)
- **5 role-based starter packs** (founder, sales, marketing, ops, design) -- paste-ready settings files
- **Setup and validation scripts** to get running without debugging

---

## Quickstart

```bash
git clone https://github.com/janskuba/claude-code-hooks-gtm.git
cd claude-code-hooks-gtm
./scripts/setup.sh
# Fill in at least SLACK_WEBHOOK_URL in .env
./scripts/validate.sh
```

Then copy the contents of `hooks/notifications/slack-ping-on-stop/hook.json` into your `~/.claude/settings.json`. Start a Claude Code session, finish any task, and you will get a Slack message.

For the full walkthrough, see [QUICKSTART.md](QUICKSTART.md).

---

## Hook index

Every hook lives in `hooks/<category>/<hook-name>/` with a `hook.json` snippet and a plain-English `README.md`. Hooks are organized by what they do for your team.

### Team notifications

| # | Hook | Event | What it does |
|---|------|-------|--------------|
| 1 | slack-ping-on-stop | Stop | Sends a Slack message when Claude finishes |
| 2 | slack-approval-alert | Notification | Pings Slack when Claude needs approval |
| 3 | discord-webhook-on-stop | Stop | Posts to Discord when Claude finishes |
| 4 | email-session-digest | SessionEnd | Emails a session summary via Gmail |

### Reporting and logging

| # | Hook | Event | What it does |
|---|------|-------|--------------|
| 5 | notion-session-log | SessionEnd | Logs session details to a Notion database |
| 6 | local-markdown-transcript | SessionEnd | Saves session transcript to a local .md file |
| 7 | cost-tracker-notion | SessionEnd | Logs token usage and cost to Notion |
| 8 | daily-digest-slack | SessionEnd | Posts a daily work summary to Slack |
| 9 | sheets-append-row | PostToolUse | Appends activity data to a Google Sheet |

### Content production

| # | Hook | Event | What it does |
|---|------|-------|--------------|
| 10 | typefully-draft-queue | Stop | Queues a Typefully draft from Claude's output |
| 11 | notion-content-archive | Stop | Archives generated content to Notion |
| 12 | gmail-drafts-save | Stop | Saves content as a Gmail draft |
| 13 | linear-ticket-from-brief | PostToolUse | Creates a Linear ticket when Claude writes a file |
| 14 | claude-design-output-to-notion | Stop | Saves design output to Notion |

### Prospecting and CRM

| # | Hook | Event | What it does |
|---|------|-------|--------------|
| 15 | apollo-enrich-contact | PostToolUse | Enriches a contact via Apollo.io |
| 16 | attio-upsert-company | PostToolUse | Creates or updates a company in Attio |
| 17 | hubspot-upsert-contact | PostToolUse | Creates or updates a contact in HubSpot |
| 18 | airtable-log-row | PostToolUse | Appends a row to an Airtable base |
| 19 | sheets-log-enrichment | Stop | Logs enrichment results to Google Sheets |

### Outbound and sequencing

| # | Hook | Event | What it does |
|---|------|-------|--------------|
| 20 | apollo-search-leads | Stop | Searches Apollo.io for leads matching criteria |
| 21 | lemlist-add-lead | PostToolUse | Adds a lead to a Lemlist campaign |
| 22 | lemlist-push-sequence | Stop | Pushes a full sequence to Lemlist |
| 23 | instantly-push-campaign | Stop | Pushes a campaign to Instantly |
| 24 | smartlead-push-campaign | Stop | Pushes a campaign to Smartlead |
| 25 | clay-table-sync | Stop | Syncs data to a Clay table via webhook |

### Design ops

| # | Hook | Event | What it does |
|---|------|-------|--------------|
| 26 | figma-export-frame | Stop | Exports a Figma frame via MCP |
| 27 | notion-design-doc | Stop | Creates a design doc in Notion |
| 28 | linear-design-version | PostToolUse | Logs a design version to Linear |

### Automation bridges

| # | Hook | Event | What it does |
|---|------|-------|--------------|
| 29 | zapier-webhook | Stop | Fires a Zapier webhook (configurable event) |
| 30 | n8n-webhook | Stop | Fires an n8n webhook (configurable event) |
| 31 | make-webhook | Stop | Fires a Make webhook (configurable event) |

### Bootstrap

| # | Hook | Event | What it does |
|---|------|-------|--------------|
| 32 | skill-loader-on-start | SessionStart | Loads skill files when a session begins |

---

## Integration index

Every integration has both a shell (`orchestrator/sh/`) and Python (`orchestrator/py/`) implementation. Both read JSON from stdin and respect `DRY_RUN=1`.

| Tool | Method | Auth | Required env vars |
|------|--------|------|-------------------|
| Slack | Incoming webhook | Webhook URL | `SLACK_WEBHOOK_URL` |
| Discord | Incoming webhook | Webhook URL | `DISCORD_WEBHOOK_URL` |
| Gmail | MCP | OAuth via MCP | (via `claude mcp`) |
| Notion | MCP | MCP token | (via `claude mcp`) |
| Apollo.io | REST API | API key | `APOLLO_API_KEY` |
| Attio | MCP + REST fallback | API key | `ATTIO_API_KEY` |
| HubSpot | REST API | Private app token | `HUBSPOT_TOKEN` |
| Airtable | REST API | Personal access token | `AIRTABLE_TOKEN`, `AIRTABLE_BASE_ID` |
| Google Sheets | REST API | API key | `GOOGLE_SHEETS_API_KEY`, `GOOGLE_SHEETS_SPREADSHEET_ID` |
| Lemlist | REST API | API key | `LEMLIST_API_KEY` |
| Instantly | REST API | API key | `INSTANTLY_API_KEY` |
| Smartlead | REST API | API key | `SMARTLEAD_API_KEY` |
| Clay | Webhook | Webhook URL | `CLAY_WEBHOOK_URL` |
| Typefully | REST API | API key | `TYPEFULLY_API_KEY` |
| Zapier / n8n / Make | Webhook | Webhook URL | `*_WEBHOOK_URL` |

---

## Skills and agents

The `/skills/` and `/agents/` directories are synced from two companion repos:

- **[claude-md-repo](https://github.com/janskuba/claude-md-repo)** -- Skills, modules, and templates for GTM workflows (lead enrichment, campaign building, personalization, and more).
- **[outbound-agents](https://github.com/janskuba/outbound-agents)** -- Agent definitions for outbound tasks (prospect profiling, sequence building, reply classification, meeting prep).

Re-run `./scripts/sync-skills.sh` to pull the latest versions.

---

## Content prompts

The `/gtm-content-prompts/` directory contains 17 ready-to-use prompts for generating pitch decks, one-pagers, LinkedIn carousels, case studies, ICP cards, and proposals. Each prompt includes a suggested pairing hook so you can automatically save the output to Notion, Linear, or another tool. See the [prompt index](gtm-content-prompts/README.md) for the full list.

---

## Role-based starter packs

Instead of assembling hooks one by one, grab a pre-built settings file for your role. Each file is a complete `~/.claude/settings.json` you can paste directly.

| Role | File | Hooks included |
|------|------|----------------|
| Founder | [full-settings-founder.json](examples/full-settings-founder.json) | Slack ping, Notion session log, Typefully draft, daily digest, Zapier |
| Sales | [full-settings-sales.json](examples/full-settings-sales.json) | Attio upsert, HubSpot upsert, Lemlist push, Slack approval, Airtable log |
| Marketing | [full-settings-marketing.json](examples/full-settings-marketing.json) | Typefully draft, Notion archive, design-to-Notion, Linear ticket, Slack ping |
| Ops | [full-settings-ops.json](examples/full-settings-ops.json) | Cost tracker, Notion session log, daily digest, Zapier, n8n |
| Design | [full-settings-design.json](examples/full-settings-design.json) | Figma export, design-to-Notion, Linear version, Notion design doc, Slack ping |

---

## Setup and validation

```bash
./scripts/setup.sh      # Creates .env, sets CLAUDE_GTM_DIR in your shell profile
./scripts/validate.sh    # Checks which integrations are configured and ready
```

`validate.sh` will tell you exactly which hooks will work based on the env vars you have filled in. Run it after editing `.env` to confirm your setup before pasting hooks into `settings.json`.

---

## Dry-run mode

Set `DRY_RUN=1` in your `.env` file (or export it in your shell) to test any hook without actually sending data anywhere. Every orchestrator script will print the request it would have made, then exit cleanly. This lets you verify your hooks are wired correctly before connecting to live APIs.

---

## FAQ

**Do I need to use every tool?**
No. Start with one hook and add more as needed. Each hook is independent.

**Can I swap one tool for another?**
Yes. If you use Instantly instead of Lemlist, just point the hook at the Instantly script.

**What if I don't have an API key for a tool?**
Use the webhook-based integrations (Zapier, n8n, Make) as a fallback. They accept any JSON payload and can route it to almost any tool.

**How do I verify my setup?**
Run `./scripts/validate.sh`.

---

## The other two repos

- **[claude-md-repo](https://github.com/janskuba/claude-md-repo)** -- A library of Claude Code skills and templates for GTM workflows. The brain behind the outreach.
- **[outbound-agents](https://github.com/janskuba/outbound-agents)** -- Pre-built Claude Code agents for outbound sales tasks. The autopilot for your pipeline.
