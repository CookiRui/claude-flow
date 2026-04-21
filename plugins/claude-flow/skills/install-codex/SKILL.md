---
name: install-codex
description: "Install OpenAI codex-plugin-cc to use Codex (code review / task delegation) inside Claude Code"
argument-hint:
---

# /install-codex

Installs [OpenAI's official codex-plugin-cc](https://github.com/openai/codex-plugin-cc) into Claude Code. The plugin lets you delegate code review and tasks to Codex without leaving Claude Code.

## Step 1 — Verify the current install commands

Use **WebFetch** against `https://github.com/openai/codex-plugin-cc` to read the latest README. Extract the install commands. If the README's commands differ from the defaults below, use the README's version and note the difference.

**Defaults (fallback)**:

```
/plugin marketplace add openai/codex-plugin-cc
/plugin install codex-plugin-cc
```

If WebFetch fails (no network / private repo / timeout), fall back to the defaults and tell the user to double-check the repo README.

## Step 2 — Present the commands to the user

`/plugin marketplace add` and `/plugin install` are **Claude Code built-in slash commands** — Claude cannot execute them on the user's behalf. Print them for the user to run themselves, in order:

```
Run these inside Claude Code:

1. /plugin marketplace add openai/codex-plugin-cc
2. /plugin install codex-plugin-cc

After install, restart Claude Code if prompted.
```

If the user has already added the `openai/codex-plugin-cc` marketplace, only step 2 is required.

## Step 3 — Summarize what the plugin provides (optional)

If the fetched README lists the plugin's slash commands, tools, or usage examples, summarize them in ≤ 5 bullets so the user knows what's available post-install. Do not fabricate — only include what the README actually documents.

## Troubleshooting

- **Marketplace add fails** → run `/plugin marketplace list` to confirm whether it's already registered.
- **Install fails with "plugin not found"** → the marketplace wasn't added, or the plugin name has changed — re-check the README.
- **Plugin installed but commands not available** → restart Claude Code.

## Notes

- This command only outputs instructions; it does not modify any files in the project.
- The plugin runs inside Claude Code and does not require Codex CLI to be installed separately.
