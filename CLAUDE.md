# CLAUDE.md

This file provides guidance to AI coding agents when working with code in this repository. `AGENTS.md` is a symlink to this file.

## Overview

This is a plugin marketplace — a registry of plugins (skills, commands, agents, hooks) that can be installed via the `/plugin marketplace add` command.

## Repository Structure

- `.claude-plugin/marketplace.json` — The marketplace manifest. Contains the marketplace name, owner info, and the `plugins` array where plugin entries are registered.
- `plugins/` — Local plugin sources. Each plugin lives in its own directory with a `.claude-plugin/plugin.json` manifest and component directories (`skills/`, `commands/`, `agents/`, `hooks/`).
- `scripts/` — Validation scripts run by CI (also runnable locally).
- `.github/workflows/validate.yml` — CI pipeline validating the marketplace and plugin manifests.

## Naming Convention

Skills are namespaced under the `dd:` prefix so they're easy to find via `/dd:…`. The trick is to put the `dd:` prefix **only in `plugin.json`'s `name`**, and keep the marketplace-facing names plain kebab-case — a colon in an install identifier breaks Claude Code's `plugin list`/install parsing.

The slash command is derived as **`<plugin.json name>:<skill-dir>`** (the skill's `name:` frontmatter does *not* affect it).

| Field | Value | Why |
|---|---|---|
| Marketplace `.name` | kebab — `napalmpapalam-skills` | install identifier — must be colon-free |
| Marketplace plugin-entry `.name` | kebab — `git` | this is the install key (`git@napalmpapalam-skills`) — must be colon-free |
| Plugin `plugin.json` `.name` | `dd:<domain>` — `dd:git` | drives the command prefix; the colon is safe here (not an install key) |
| Skill directory | kebab — `commit` | becomes the command suffix |
| Skill `SKILL.md` `name:` | `dd:<domain>:<skill-dir>` — `dd:git:commit` | documents the command; keep it in sync |

Result: `plugins/git/skills/commit/SKILL.md` → `/dd:git:commit`. Enforced by `scripts/validate-naming.sh`.

> **Caveat:** the colon in `plugin.json`'s `name` works in Claude Code and with git/directory marketplaces, but **claude.ai marketplace sync requires kebab-case** and would reject it. Fine for local/personal use; drop the `dd:` from `plugin.json` if you ever publish to the claude.ai marketplace.

## Adding a Plugin

1. Create `plugins/<domain>/.claude-plugin/plugin.json` with `name` = `dd:<domain>` (e.g. `dd:git`).
2. Add components at the plugin root: `skills/<skill-dir>/SKILL.md` (with `name: dd:<domain>:<skill-dir>`), `commands/*.md`, `agents/*.md`, etc.
3. Register the plugin in the `plugins` array in `.claude-plugin/marketplace.json` with a **kebab-case** `name` (e.g. `git`, matching the `dd:` suffix), `source` (e.g. `./plugins/<domain>`), and `description`.
4. Run the validation suite locally before pushing:
   ```
   bash scripts/validate.sh
   ```
   (runs all the individual `scripts/validate-*.sh` / `check-duplicates.sh` checks; CI runs the same script)

## Hooks

A plugin's `hooks/hooks.json` must wrap the event map under a top-level `"hooks"` key — otherwise auto-discovery silently finds zero hooks:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      { "hooks": [ { "type": "command", "command": "sh \"${CLAUDE_PLUGIN_ROOT}/hooks/scripts/foo.sh\"", "timeout": 10 } ] }
    ]
  }
}
```

Reference scripts with `${CLAUDE_PLUGIN_ROOT}` (not absolute paths). It's an **environment variable**, so wrap it in **double** quotes — single quotes pass it to the shell literally and the path won't resolve. Verify with `claude plugin details <plugin>@<marketplace>` — it should report the expected `Hooks (N)`.
