---
name: dd:docs:readme
description: Generate or update a README.md for a project by analyzing its codebase, dependencies, and structure. Use this skill whenever the user asks to write, create, generate, update, refresh, or fix a README, document a project, or wants project documentation — even if they just say "write me a readme", "update the readme", or "the readme is outdated".
allowed-tools: Read, Glob, Grep, Write, Bash, Agent, AskUserQuestion
version: 0.1.0
effort: medium
---

# Generate README

Generate a clear, technical, user-friendly README.md by analyzing the project.

**Voice:** follow `${CLAUDE_PLUGIN_ROOT}/references/voice.md` — read it before writing.

## Step 1: Scan the Project (subagent)

The codebase scan is read-heavy and its raw output doesn't need to live in this thread — dispatch a subagent for it. Use the Agent tool (`general-purpose`) with a prompt asking it to explore the project and return a **compact structured report**, not file dumps:

- Project type: language/framework (`package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`), build system (`Makefile`, `Taskfile`, `justfile`, `docker-compose`), CI (`.gitlab-ci.yml`, `.github/workflows/`).
- What it does: read main entry point(s) — `src/main.rs`, `main.go`, `index.ts`, `app.py`, package-manifest bin entries, Dockerfile `CMD`/`ENTRYPOINT` — and summarize in 1–2 sentences.
- Prerequisites: runtime deps, system deps, external services.
- Install methods available: install script, package-manager entry, docker, from-source build command.
- Env vars: from `.env.example` / config files — variable + purpose.
- Primary commands / API surface.
- Existing `docs/` files worth linking.
- Monorepo/workspace layout, if any: top-level structure + one line per package/crate/module.

**Read the existing `README.md` yourself in this thread** (don't rely on the subagent's paraphrase) — you need it verbatim to preserve human-written content. Only rewrite sections that are outdated or missing; keep custom sections, acknowledgements, and project-specific context.

## Step 2: Write the README

Follow this structure. **Skip sections that don't apply** — an empty section signals neglect, not thoroughness.

```markdown
# project-name

One-line description of what the project does. No fluff.

## Prerequisites

- **Tool** — [Install link](url)
- **Tool** — [Install link](url)

## Installation

### Quick Install (recommended)

\`\`\`bash
oneliner here
\`\`\`

### From Source

\`\`\`bash
git clone ...
cd ...
build command
\`\`\`

### Verify

\`\`\`bash
command --version
\`\`\`

## Usage

Show the primary workflow or most common commands.
Keep examples copy-pasteable.

## Configuration

Minimal config example inline.
Full config → [docs/configuration.md](docs/configuration.md)

## [Domain-specific sections]

Only what the user needs. Command reference, API surface, state management, etc.

## Contributing

Short instructions or link to CONTRIBUTING.md.

## License

One line with link.
```

### Installation guidance

Lead with the simplest install method — the first thing a reader sees determines whether they try or bounce.

**Priority order:**
1. **Oneliner** (curl | bash, npx, pip install, cargo install) — always first if available
2. **Package manager** (brew, apt, npm, cargo)
3. **From source** (git clone + build)

If the project has no install script, suggest creating one and note it as a recommendation.

### Section Rules

| Rule                      | Details                                                                                                                               |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| **Prerequisites**         | Short bullet list. One line per tool with install link. No explanations — the link is the explanation.                                |
| **Installation**          | Oneliner first. Every install path ends with a verify command.                                                                        |
| **Configuration**         | Show minimal working config inline. If config is complex (>30 lines), extract full version to `docs/configuration.md` and link to it. |
| **Usage**                 | Real commands, real output. Show the happy path first.                                                                                |
| **Complex sections**      | If any section exceeds ~50 lines, extract to `docs/<topic>.md` and reference: `See [docs/topic.md](docs/topic.md) for details.`       |
| **Environment variables** | Table format: Variable / Purpose. No defaults column unless defaults are non-obvious.                                                 |

## Step 3: Extract Complex Content

If the README would become too long or has sections with deep detail:

1. Create `docs/` directory if it doesn't exist
2. Extract the detailed content to a dedicated file (e.g., `docs/configuration.md`, `docs/architecture.md`, `docs/api.md`)
3. Replace the README section with a brief summary + link

> [!IMPORTANT]
> The README is the entry point, not the encyclopedia. Keep it scannable. Link out for depth.

## Step 4: Self-Review

After writing, verify the README against this checklist:

| #   | Check                                                                        | Fail action                    |
| --- | ---------------------------------------------------------------------------- | ------------------------------ |
| 1   | Can a new developer understand what this project does within 30 seconds?     | Rewrite the description        |
| 2   | Can they install it by copy-pasting commands?                                | Fix install section            |
| 3   | Are prerequisites just short links, not paragraphs?                          | Trim to bullet + link          |
| 4   | Is installation within the first 3 sections?                                 | Move it up                     |
| 5   | Does any section exceed ~50 lines?                                           | Extract to docs/               |
| 6   | Are there marketing words (revolutionary, powerful, seamless, blazing fast)? | Remove them                    |
| 7   | Are callout blocks used appropriately (not decoratively)?                    | Remove unnecessary ones        |
| 8   | Do all commands actually work if copy-pasted?                                | Fix paths, flags, placeholders |
| 9   | Is there a verify step after install?                                        | Add one                        |
| 10  | Are relative links correct?                                                  | Test each path                 |

Report the review results to the user. If any check fails, fix it before finalizing.
