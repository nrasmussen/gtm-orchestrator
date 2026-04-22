# Quickstart

Get your first hook running in five steps.

## Step 1: Clone and set up

```bash
git clone https://github.com/janskuba/claude-code-hooks-gtm.git
cd claude-code-hooks-gtm
./scripts/setup.sh
```

This creates your `.env` file from the template and adds `CLAUDE_GTM_DIR` to your shell profile so hooks can find the repo scripts from anywhere.

## Step 2: Add one API key

Open `.env` and fill in `SLACK_WEBHOOK_URL` with your Slack incoming webhook URL. If you do not have one, go to your Slack workspace settings, create an incoming webhook for the channel you want, and paste the URL.

## Step 3: Verify the setup

```bash
./scripts/validate.sh
```

You should see `[OK]` next to Slack. Everything else can be `[MISSING]` for now.

## Step 4: Install the hook

Open `hooks/notifications/slack-ping-on-stop/hook.json` and copy its contents into `~/.claude/settings.json`. If you already have hooks in your settings file, merge the entries under the `"hooks"` key.

Or skip the manual step and use a starter pack -- copy the whole file for your role:

```bash
cp examples/full-settings-founder.json ~/.claude/settings.json
```

## Step 5: Run Claude Code

Open your terminal and start a Claude Code session:

```bash
claude
```

Give Claude any task ("summarize this README", "list files in this directory", anything). When Claude finishes the task, the hook fires and you will see a message appear in your Slack channel within a few seconds.

---

You just ran your first hook. To add more, browse the `hooks/` directory and paste additional entries into your `settings.json`. To test hooks without sending real requests, add `DRY_RUN=1` to your `.env` file.
