# Quickstart

Get your first hook running in three steps.

## Step 1: Clone and install

```bash
git clone https://github.com/janskuba/go-to-market-orchestrator.git
cd go-to-market-orchestrator
./scripts/install.sh
```

`install.sh` does four things in one shot:

1. Creates your `.env` from the template (if one doesn't exist) and exports `CLAUDE_GTM_DIR` in your shell profile.
2. Copies all skills from `skills/<name>/SKILL.md` into `~/.claude/skills/<name>/SKILL.md`.
3. Copies all subagents and slash commands into `~/.claude/agents/` and `~/.claude/commands/`.
4. Merges every `hooks/*/*/hook.json` into `~/.claude/settings.json`, taking a timestamped backup first.

You can re-run it any time. To install only part of the system:

```bash
./scripts/install.sh --skills-only
./scripts/install.sh --agents-only
./scripts/install.sh --hooks-only
./scripts/install.sh --hooks=slack-ping-on-stop,attio-upsert-company   # cherry-pick
./scripts/install.sh --symlink                                          # for repo developers
```

To remove everything later: `./scripts/uninstall.sh`.

## Step 2: Add at least one API key

Open `.env` and fill in `SLACK_WEBHOOK_URL`. You can grab one from your Slack workspace settings: *Apps → Incoming Webhooks → Add to channel*.

## Step 3: Verify and run

```bash
./scripts/validate.sh
```

This validates every hook.json against the Claude Code schema, compiles every Python handler, runs every handler under `DRY_RUN=1`, and reports which integrations are configured.

Then start Claude Code:

```bash
claude
```

Give Claude any task (`summarize this README`, `list files`, anything). When Claude finishes, the Slack hook fires and your channel gets a message.

---

## Dry-run mode

Set `DRY_RUN=1` in `.env` to test any hook without sending real requests. Every handler prints what it *would* have sent and exits cleanly.

## Adding more integrations

Fill in additional API keys in `.env` and re-run `./scripts/validate.sh` to confirm they're picked up. Most hooks fire automatically once their env vars are set — no settings.json edits needed.

## Troubleshooting

- **Hook didn't fire**: confirm Claude Code picked up the new settings (restart your session). Check `~/.claude/settings.json` actually contains the hook by running `./scripts/validate.sh`.
- **Hook ran but failed silently**: hook stderr is suppressed by default in Claude Code. Run the command manually with the same payload to see the error: `echo '{"action":"notify","text":"hi"}' | bash orchestrator/run.sh slack notify`.
- **`CLAUDE_GTM_DIR` not set**: `install.sh` adds the export to your shell profile but does not source it for the current shell. Run `source ~/.zshrc` (or `.bashrc`) or open a new terminal.
