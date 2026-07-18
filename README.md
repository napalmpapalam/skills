# skills

A personal [Claude Code](https://docs.claude.com/en/docs/claude-code) plugin marketplace — a registry of plugins bundling skills, commands, and agents, installable via `/plugin`.

## Prerequisites

- **Claude Code** — [Install](https://docs.claude.com/en/docs/claude-code/setup)

## Installation

Add the marketplace, then install a plugin:

```
/plugin marketplace add napalmpapalam/skills
/plugin install git@napalmpapalam-skills
```

Run these as slash commands inside Claude Code. To install from a local checkout instead of GitHub:

```
/plugin marketplace add /path/to/skills
```

## Available Plugins

| Plugin | Description | Skills |
| --- | --- | --- |
| `git` | Git conventions and workflows | `dd:git:commit` |

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
bash scripts/validate-marketplace.sh
bash scripts/validate-plugin-entries.sh
bash scripts/validate-plugins.sh
bash scripts/check-duplicates.sh
bash scripts/validate-naming.sh
```

All five run in CI on pull requests and pushes to `master`.

## License

[MIT](LICENSE)
