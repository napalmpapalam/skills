---
name: dd:docs:changelog
description: Generate or update a CHANGELOG.md by analyzing git diffs to understand what actually changed in the codebase. Use this skill whenever the user asks to create, update, generate, or add to a changelog, write release notes from recent changes, document what changed between versions, or says things like "update the changelog", "what changed since last release", "add changelog entry".
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Agent, AskUserQuestion
version: 0.1.0
effort: medium
---

# Update Changelog

Generate or update a CHANGELOG.md from git diffs. Language-agnostic. Commit messages are often vague; the diff is the source of truth — read the actual code changes.

**Voice:** follow `${CLAUDE_PLUGIN_ROOT}/references/voice.md` — read it before writing.

## Step 1: Detect Version

Use the version the user gave. Otherwise auto-detect, picking the best default without blocking:

1. **Git tags** — `git tag --list --sort=-v:refname`, take the latest semver tag (`v?[0-9]+.[0-9]+.[0-9]+`), strip any `v`. Bump the patch by default — that's the version you're writing for.
2. **Version files** (if no tags), in order: `package.json`, `Cargo.toml` `[package]`, `go.mod`, `VERSION`/`version.txt`, `marketplace.json`/`plugin.json`.
3. **Ask, with a default** — if nothing's found, propose a version (e.g. `0.1.0` for a first release) and let the user confirm or override. Continue diff analysis while waiting.

## Step 2: Determine Change Range

Use the user's range if given (e.g. `v1.0.0..HEAD`). Otherwise use `<latest-tag>..HEAD`, or full history if there are no tags. If the diff is huge (500+ files), suggest narrowing before proceeding.

## Step 3: Analyze Changes

The core step. Run `git diff <range> --stat` (cheap) to size the change, then pick where to read:

- **Small (≲40 files / ≲2000 lines)** — analyze inline, in this thread.
- **Large** — dispatch a subagent (Agent tool, `general-purpose`); pass it the range and ask for a **compact categorized entry list**, not the raw diff.

Thresholds are a guideline — use judgment. Either way:

1. `git diff <range> --no-color` for the full diff (per-file if very large). `git log --oneline <range>` for intent.
2. Categorize into [Keep a Changelog](https://keepachangelog.com/) categories:

| Signal in diff | Category |
| --- | --- |
| New files/exports/functions/endpoints/CLI flags | **Added** |
| Fixes to incorrect behavior, error handling, null/bounds checks | **Fixed** |
| Renames, restructures, changed internals, dependency updates | **Changed** |
| Removed files/exports/public API/features | **Removed** |
| `@deprecated`, deprecation warnings, sunset notices | **Deprecated** |
| Auth/crypto changes, input validation, CVE dependency bumps | **Security** |

3. **Breaking changes** — removed/renamed public API, changed signatures, removed config, or a major bump: prefix the entry with **BREAKING:**.

### Writing good entries

- One line each, from the **user's perspective** — functional impact, not file names. Good: "Rate limiting for API endpoints". Bad: "Update handler.go".
- Don't repeat the category as a verb: under `### Added` write "Rate limiting…", not "Add rate limiting…".
- Group related changes into one entry. Skip internal-only refactors unless they're the only changes.

## Step 4: Write CHANGELOG.md

If the file doesn't exist, create it with the standard [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) + [SemVer](https://semver.org/spec/v2.0.0.html) header.

If it exists: merge into an existing version section (dedupe by semantic similarity; when unsure keep both for review), or add a new section right after the header. Format:

```markdown
## [1.2.0] - YYYY-MM-DD

### Added
- Entry description
```

Category order: **Added, Changed, Deprecated, Removed, Fixed, Security**. Only include non-empty categories. Use today's date.

## Step 5: Update Version Files

If Step 1 detected the version from a file, that file still holds the *old* version — update every version source that already exists (same list as Step 1) so tooling and changelog agree. Don't create new ones. Skip if the file already matches.

## Step 6: Add Version Diff Links

Easy to forget, but half the value of a changelog. At the bottom of the file, add a reference link per version.

1. `git remote get-url origin`; convert to an HTTPS base URL (SSH `git@host:org/repo.git` → `https://host/org/repo`; HTTPS → strip `.git`). If it can't be parsed, skip and note it.
2. **Match the repo's tag prefix** — check `git tag` output: if tags use `v` (`v1.0.0`), prefix URLs with `v`; if bare, omit it. No tags / mixed → follow the version the user gave, else default to no prefix.
3. Compare-URL path by host: GitHub `{base}/compare/{prev}...{cur}`, GitLab `{base}/-/compare/{prev}...{cur}`, Bitbucket `{base}/compare/{cur}..{prev}` (apply the prefix to each version).

```markdown
[1.2.0]: https://github.com/org/repo/compare/v1.1.0...v1.2.0
[1.0.0]: https://github.com/org/repo/releases/tag/v1.0.0   # oldest: link the tag
[Unreleased]: https://github.com/org/repo/compare/v1.2.0...HEAD
```

## Step 7: Report

Short summary: version + date, entry count per category, breaking changes flagged, version files updated, links added (+ base URL), file path. End with: "Generated from code diffs — review before publishing."
