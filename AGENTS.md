# AGENTS.md

This file provides guidance to AI coding agents when working with code in this repository.

## Overview

This is a plugin marketplace — a registry of plugins (skills, commands, agents, hooks) that can be installed via the `/plugin marketplace add` command.

## Repository Structure

- `.claude-plugin/marketplace.json` — The marketplace manifest. Contains the marketplace name, owner info, and the `plugins` array where plugin entries are registered.
- `plugins/` — Local plugin sources. Each plugin lives in its own directory with a `.claude-plugin/plugin.json` manifest and component directories (`skills/`, `commands/`, `agents/`, `hooks/`).
- `scripts/` — Validation scripts run by CI (also runnable locally).
- `.github/workflows/validate.yml` — CI pipeline validating the marketplace and plugin manifests.

## Adding a Plugin

1. Create `plugins/<plugin-name>/.claude-plugin/plugin.json` with at least a `name` field (kebab-case).
2. Add components at the plugin root: `skills/<skill-name>/SKILL.md`, `commands/*.md`, `agents/*.md`, etc.
3. Register the plugin in the `plugins` array in `.claude-plugin/marketplace.json` with `name`, `source` (e.g. `./plugins/<plugin-name>`), and `description`.
4. Run the validation scripts locally before pushing:
   ```
   bash scripts/validate-marketplace.sh
   bash scripts/validate-plugin-entries.sh
   bash scripts/validate-plugins.sh
   bash scripts/check-duplicates.sh
   ```
