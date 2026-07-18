# skills

[![Validate](https://github.com/napalmpapalam/skills/actions/workflows/validate.yml/badge.svg)](https://github.com/napalmpapalam/skills/actions/workflows/validate.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A personal [Claude Code](https://docs.claude.com/en/docs/claude-code) plugin marketplace — a registry of plugins bundling skills, commands, and agents, installable via `/plugin`.

## Prerequisites

- **Claude Code** — [Install](https://docs.claude.com/en/docs/claude-code/setup)

## Installation

Inside Claude Code, add the marketplace, then install any plugin:

```
/plugin marketplace add napalmpapalam/skills
/plugin install flow@napalmpapalam-skills
```

Install any plugin by name — `git`, `docs`, `flow`, `rules`, `herdr` (e.g. `/plugin install rules@napalmpapalam-skills`).

The marketplace also accepts a full git URL:

```
/plugin marketplace add https://github.com/napalmpapalam/skills.git   # or git@github.com:napalmpapalam/skills.git
```

## Available Plugins

| Plugin | Description | Skills |
| --- | --- | --- |
| `git` | Git conventions and workflows | `dd:git:commit` |
| `docs` | Documentation generation with a shared voice | `dd:docs:readme`, `dd:docs:changelog` |
| `flow` | Plan and ship features as vertical slices via one living doc | `dd:flow:go` |
| `rules` | Global house rules injected every session | — (session hook) |
| `herdr` | Names the herdr pane after Claude's chat title | — (pane hook) |

Skills are invoked with their namespaced slash command, e.g. `/dd:git:commit` to compose a conventional-commit message.

## Repository Structure

- `.claude-plugin/marketplace.json` — marketplace manifest; the `plugins` array registers each plugin.
- `plugins/<domain>/` — plugin sources, each with a `.claude-plugin/plugin.json` and component dirs (`skills/`, `commands/`, `agents/`, `hooks/`).
- `scripts/` — validation scripts run locally and in CI.
- `.github/workflows/validate.yml` — CI validating manifests and naming.

## Adding a Plugin

1. Create `plugins/<domain>/.claude-plugin/plugin.json` with `name` = `dd:<domain>`.
2. Add a skill at `plugins/<domain>/skills/<skill>/SKILL.md` with `name: dd:<domain>:<skill>`.
3. Register it in `.claude-plugin/marketplace.json` with a kebab-case `name` (e.g. `git`), `source`, and `description`.
4. Run the validation scripts (below).

See [CLAUDE.md](CLAUDE.md) for the full naming convention.

> [!NOTE]
> The `dd:` prefix goes in `plugin.json`'s `name` (driving the `/dd:…` command), not the marketplace-facing names — a colon in an install identifier breaks Claude Code's plugin parsing.

## Validation

```bash
bash scripts/validate.sh
```

Runs every check (the individual `scripts/validate-*.sh` / `check-duplicates.sh`). CI runs the same script on pull requests and pushes to `master`.

## License

[MIT](LICENSE)
