# Claude Code Hooks for GTM

Claude Code hooks, skills, and subagents for go-to-market teams. Trigger real actions in Slack, Apollo, Lemlist, Notion, Linear, Figma, Google Sheets, and 14+ other tools when Claude finishes work — and use a curated library of GTM skills and outbound agents from inside any session.

---

## The three-layer system

```
┌─────────────────────────────────────────────────────────────┐
│  CLAUDE CODE SESSION                                        │
│                                                             │
│  1. SKILLS  (skills/<name>/SKILL.md → ~/.claude/skills/)    │
│     Pre-written instruction modules that tell Claude        │
│     HOW to do GTM work — campaign building, lead            │
│     enrichment, personalization, signal monitoring.         │
│           ↓                                                 │
│  2. AGENTS + COMMANDS (agents/*.md, agents/commands/*.md)   │
│     Subagents (lead-prioritizer, prospect-profiler, etc.)   │
│     and the /outbound-pipeline slash command that chains    │
│     them into a 5-stage outbound workflow.                  │
│           ↓                                                 │
│  3. HOOKS + ORCHESTRATOR (hooks/, orchestrator/)            │
│     settings.json fragments that fire on Claude Code        │
│     lifecycle events (Stop, PostToolUse, SessionStart…)     │
│     and Python handlers that hit real REST APIs.            │
└─────────────────────────────────────────────────────────────┘
```

Skills = what to do. Agents = who does it. Hooks = when to act. Orchestrator = how to actually send it somewhere.

---

## What you get

- **30 hooks** across 8 categories (notifications, logging, content, CRM, outbound, design-ops, automation, bootstrap)
- **17 integrations** (Slack, Discord, Notion, Apollo, HubSpot, Attio, Airtable, Google Sheets, Lemlist, Instantly, Smartlead, Clay, Typefully, Linear, Figma, Zapier/n8n/Make) — all direct REST, no MCP dependency required for hooks
- **6 GTM skills** (campaign-builder, lead-enrichment, personalization-writer, pipeline-reviewer, reply-classifier, signal-monitor)
- **7 subagents** + the `/outbound-pipeline` slash command that orchestrates them
- **17 content prompts** for pitch decks, one-pagers, carousels, case studies, ICP cards, proposals
- **5 role-based starter packs** (founder, sales, marketing, ops, design) — paste-ready settings files
- **One-shot installer**, validator, and uninstaller

---

## Quickstart

```bash
git clone https://github.com/janskuba/go-to-market-orchestrator.git
cd go-to-market-orchestrator
./scripts/install.sh
# Fill in at least SLACK_WEBHOOK_URL in .env
./scripts/validate.sh
```

Start Claude Code, give it any task, and watch your Slack channel light up when it finishes. Full walkthrough: [QUICKSTART.md](QUICKSTART.md).

---

## How a hook fires

```
Claude Code event (Stop / PostToolUse / SessionStart / Notification / SessionEnd)
   └──→ ~/.claude/settings.json hook entry
         └──→ bash $CLAUDE_GTM_DIR/orchestrator/run.sh <service> <action>
               └──→ orchestrator/dispatch.py
                     - reads stdin (Claude's hook payload)
                     - merges <action> into payload["action"]
                     - exec orchestrator/py/<service>.py
                       └──→ POST to Slack / Apollo / Notion / …
```

`dispatch.py` exists so a single contract — `payload["action"]` — drives every handler. The CLI action overrides any value in stdin; handlers fall back to a sensible default if neither is present.

---

## Hook index

Every hook lives in `hooks/<category>/<hook-name>/` with a `hook.json` snippet and a plain-English `README.md`.

### Team notifications

| Hook | Event | What it does |
|------|-------|--------------|
| slack-ping-on-stop | Stop | Sends a Slack message when Claude finishes |
| slack-approval-alert | Notification | Pings Slack when Claude needs approval |
| discord-webhook-on-stop | Stop | Posts to Discord when Claude finishes |

### Reporting and logging

| Hook | Event | What it does |
|------|-------|--------------|
| notion-session-log | SessionEnd | Logs session details to Notion |
| local-markdown-transcript | SessionEnd | Saves session transcript locally |
| cost-tracker-notion | SessionEnd | Logs token usage and cost to Notion |
| daily-digest-slack | SessionEnd | Posts a session summary to Slack |
| sheets-append-row | PostToolUse | Appends activity to Google Sheets |

### Content production

| Hook | Event | What it does |
|------|-------|--------------|
| typefully-draft-queue | Stop | Queues a Typefully draft from Claude's output |
| notion-content-archive | Stop | Archives generated content to Notion |
| linear-ticket-from-brief | PostToolUse | Creates a Linear ticket when Claude writes a file |
| claude-design-output-to-notion | Stop | Saves design output to Notion |

### Prospecting and CRM

| Hook | Event | What it does |
|------|-------|--------------|
| apollo-enrich-contact | PostToolUse | Enriches a contact via Apollo.io |
| attio-upsert-company | PostToolUse | Creates or updates a company in Attio |
| hubspot-upsert-contact | PostToolUse | Creates or updates a contact in HubSpot |
| airtable-log-row | PostToolUse | Appends a row to Airtable |
| sheets-log-enrichment | Stop | Logs enrichment results to Google Sheets |

### Outbound and sequencing

| Hook | Event | What it does |
|------|-------|--------------|
| apollo-search-leads | Stop | Searches Apollo for leads matching criteria |
| lemlist-add-lead | PostToolUse | Adds a lead to a Lemlist campaign |
| lemlist-push-sequence | Stop | Starts a Lemlist sequence for a lead |
| instantly-push-campaign | Stop | Pushes a lead to Instantly |
| smartlead-push-campaign | Stop | Pushes a lead to Smartlead |
| clay-table-sync | Stop | Syncs data to a Clay table via webhook |

### Design ops

| Hook | Event | What it does |
|------|-------|--------------|
| figma-export-frame | Stop | Exports a Figma frame via REST |
| notion-design-doc | Stop | Creates a design doc in Notion |
| linear-design-version | PostToolUse | Logs a design version to Linear |

### Automation bridges

| Hook | Event | What it does |
|------|-------|--------------|
| zapier-webhook | Stop | Fires a Zapier webhook (configurable downstream) |
| n8n-webhook | Stop | Fires an n8n webhook |
| make-webhook | Stop | Fires a Make webhook |

### Bootstrap

| Hook | Event | What it does |
|------|-------|--------------|
| skill-loader-on-start | SessionStart | Lists available local skills at session start |

---

## Integration index

Every integration is a Python handler in `orchestrator/py/<service>.py`. Handlers read JSON from stdin, respect `DRY_RUN=1`, and call REST APIs directly. No MCP server is required for hooks to work.

| Tool | Auth | Required env vars |
|------|------|-------------------|
| Slack | Webhook | `SLACK_WEBHOOK_URL` |
| Discord | Webhook | `DISCORD_WEBHOOK_URL` |
| Notion | API token | `NOTION_API_KEY`, `NOTION_PARENT_PAGE_ID` (or `NOTION_COST_DATABASE_ID` for cost log) |
| Figma | API token | `FIGMA_API_KEY` |
| Linear | API token | `LINEAR_API_KEY`, `LINEAR_TEAM_ID` |
| Apollo.io | API key | `APOLLO_API_KEY` |
| Attio | API key | `ATTIO_API_KEY` |
| HubSpot | Private app token | `HUBSPOT_TOKEN` |
| Airtable | Personal access token | `AIRTABLE_TOKEN`, `AIRTABLE_BASE_ID` |
| Google Sheets | API key | `GOOGLE_SHEETS_API_KEY`, `GOOGLE_SHEETS_SPREADSHEET_ID` |
| Lemlist | API key | `LEMLIST_API_KEY` |
| Instantly | API key | `INSTANTLY_API_KEY` |
| Smartlead | API key | `SMARTLEAD_API_KEY` |
| Clay | Webhook | `CLAY_WEBHOOK_URL` |
| Typefully | API key | `TYPEFULLY_API_KEY` |
| Zapier / n8n / Make | Webhook | `*_WEBHOOK_URL` |

---

## Skills, agents, and commands

| Path | Installs to | Purpose |
|------|-------------|---------|
| `skills/<name>/SKILL.md` | `~/.claude/skills/<name>/SKILL.md` | Auto-invoked skill that teaches Claude how to do a GTM task |
| `agents/*.md` | `~/.claude/agents/` | Subagents Claude can dispatch via the Task tool |
| `agents/commands/*.md` | `~/.claude/commands/` | Slash commands (e.g. `/outbound-pipeline`) |
| `skills/modules/`, `skills/templates/`, `skills/examples/` | (reference, not installed) | Vendored reference material for skill authors |

The `/outbound-pipeline` command chains 5 subagents (signal-scraper → lead-prioritizer → prospect-profiler → hook-writer → sequence-builder) into a single end-to-end workflow with checkpoint files in `agents/output/`.

To pull the latest skills/agents from upstream repos: `./scripts/sync-skills.sh`. The repo ships with vendored copies, so this is optional.

---

## Content prompts

The `/gtm-content-prompts/` directory contains 17 ready-to-use prompts for pitch decks, one-pagers, LinkedIn carousels, case studies, ICP cards, and proposals. Each prompt suggests a hook to pair it with so the output goes to Notion, Linear, or your tool of choice. See [gtm-content-prompts/README.md](gtm-content-prompts/README.md).

---

## Role-based starter packs

Skip assembling hooks one by one. Each file is a complete `~/.claude/settings.json`:

| Role | File | Hooks included |
|------|------|----------------|
| Founder | [full-settings-founder.json](examples/full-settings-founder.json) | Slack ping, Notion log, Typefully draft, daily digest, Zapier |
| Sales | [full-settings-sales.json](examples/full-settings-sales.json) | Attio upsert, HubSpot upsert, Lemlist push, Slack approval, Airtable log |
| Marketing | [full-settings-marketing.json](examples/full-settings-marketing.json) | Typefully draft, Notion archive, design-to-Notion, Linear ticket, Slack ping |
| Ops | [full-settings-ops.json](examples/full-settings-ops.json) | Cost tracker, Notion session log, daily digest, Zapier, n8n |
| Design | [full-settings-design.json](examples/full-settings-design.json) | Figma export, design-to-Notion, Linear version, Notion design doc, Slack ping |

Or just run `./scripts/install.sh` to install everything.

---

## Scripts reference

```bash
./scripts/install.sh          # full install (skills + agents + commands + hooks)
./scripts/install.sh --help   # all flags
./scripts/uninstall.sh        # remove everything install.sh added
./scripts/validate.sh         # schema-validate hooks, compile + dry-run handlers, report env state
./scripts/sync-skills.sh      # pull latest skills/agents from upstream repos (optional)
./scripts/install-mcps.sh     # OPTIONAL: register MCP servers for Claude to *use* (not for hooks)
```

---

## Dry-run mode

Set `DRY_RUN=1` in `.env` (or export it) to make every handler print what it would have sent and exit cleanly. Combine with `validate.sh` for an end-to-end smoke test.

---

## FAQ

**Do I need to use every tool?** No. Each hook is independent. Start with one, add more as needed.

**What if I don't have an API key for X?** Use the Zapier/n8n/Make webhook bridges as a fallback. They accept any JSON payload and route it anywhere.

**Why no Gmail integration?** Gmail OAuth setup is heavier than the other integrations. Use Zapier/Make to bridge to Gmail, or contribute a PR.

**How do I verify my setup?** `./scripts/validate.sh`.

**How do I uninstall?** `./scripts/uninstall.sh`. Backups of your previous `settings.json` are preserved as `settings.json.bak.*`.

---

## The other two repos

- **[claude-md-repo](https://github.com/janskuba/claude-md-repo)** — A library of Claude Code skills and templates for GTM workflows.
- **[outbound-agents](https://github.com/janskuba/outbound-agents)** — Pre-built Claude Code agents for outbound sales tasks.

`./scripts/sync-skills.sh` pulls the latest copies into `skills/` and `agents/`. Use `--no-upstream` if you don't have access — the repo ships with vendored copies.
