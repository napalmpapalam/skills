---
name: dd:docs:changelog
description: Generate or update a CHANGELOG.md by analyzing git diffs to understand what actually changed in the codebase. Use this skill whenever the user asks to create, update, generate, or add to a changelog, write release notes from recent changes, document what changed between versions, or says things like "update the changelog", "what changed since last release", "add changelog entry".
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Agent, AskUserQuestion
version: 0.1.0
effort: medium
---

# Update Changelog

Generate or update a CHANGELOG.md by analyzing git diffs. Language-agnostic — works with any project.

The core idea: commit messages are often vague or inaccurate, but diffs never lie. Read the actual code changes and write meaningful, user-facing descriptions of what changed.

**Voice:** follow `${CLAUDE_PLUGIN_ROOT}/references/voice.md` — read it before writing.

## Step 1: Detect Version

If the user provided a version, use it. Otherwise, auto-detect — and pick the best default without blocking:

1. **Git tags** — run `git tag --list --sort=-v:refname` and pick the latest semver tag (matching `v?[0-9]+.[0-9]+.[0-9]+`). Strip `v` prefix if present. The *next* version is what we're writing the changelog for — bump the patch by default.
2. **Version files** — if no semver tags exist, check in order:
   - `package.json` → `version` field
   - `Cargo.toml` → `version` under `[package]`
   - `go.mod` → version from module path
   - `VERSION` or `version.txt` → file contents
   - `marketplace.json`, `plugin.json` - for the Claude Code plugins
3. **Ask with a suggestion** — if nothing found, ask the user what version to use but always propose a sensible default (e.g. `0.1.0` for a first release). Don't just ask an open-ended question — suggest a version and let the user confirm or override. While waiting for the answer, continue with the diff analysis (Steps 2–3) so no time is wasted.

## Step 2: Determine Change Range

If the user provided a range (e.g. `v1.0.0..HEAD`), use it. Otherwise:

1. Find the latest semver git tag. Use `<tag>..HEAD`.
2. If no tags exist, use the full history. If the diff is large (500+ changed files), inform the user and suggest narrowing the range before proceeding.

## Step 3: Analyze Changes (subagent)

This is the core step, and the raw `git diff` is large and disposable — dispatch a subagent for it. Use the Agent tool (`general-purpose`), pass it the change range from Step 2, and ask it to return a **compact categorized list of entries**, not the diff itself. Instruct the subagent to:

1. Run `git diff <range> --stat` to see which files changed and how much.
2. Run `git diff <range> --no-color` for the full diff. If the diff is very large, process per-file: iterate over changed files from `--stat` and run `git diff <range> -- <file>` for each.
3. Run `git log --oneline <range>` as supplementary context — commit messages help understand *intent*, but the diff is the source of truth.
4. Categorize changes into [Keep a Changelog](https://keepachangelog.com/) categories:

| Signal in diff                                                                                               | Category       |
| ------------------------------------------------------------------------------------------------------------ | -------------- |
| New files, new exports, new public functions/methods, new endpoints, new CLI flags                           | **Added**      |
| Changes to existing logic that fix incorrect behavior, error handling improvements, null/bounds checks added | **Fixed**      |
| Renamed/restructured code, changed internal implementation, moved files, updated dependencies                | **Changed**    |
| Removed files, removed exports, removed public API surface, deleted features                                 | **Removed**    |
| `@deprecated` annotations, deprecation warnings, sunset notices in code or docs                              | **Deprecated** |
| Auth changes, crypto updates, input validation, dependency bumps for CVEs                                    | **Security**   |

5. **Detect breaking changes**: if the diff shows removed or renamed public API, changed function signatures, removed config options, or a major version bump — prefix the entry with **BREAKING:** in its category.

6. Return entries as clear, human-readable descriptions of what changed **from a user's perspective** (per the voice rules). Describe functional impact, not file names. Good: "Rate limiting for API endpoints". Bad: "Update handler.go".

### Writing good entries (apply when reviewing the subagent's output)

- Each entry should be one line. Don't repeat the category as a verb — the heading already says what kind of change it is. Under `### Added`, write "Rate limiting for API endpoints", not "Add rate limiting for API endpoints". Under `### Fixed`, write "Crash when uploading empty files", not "Fix crash when uploading empty files".
- Group related file changes into a single entry when they represent one logical change.
- Skip purely internal refactors that have zero user-facing impact (unless they're the only changes).
- When a diff is ambiguous, use the commit message to clarify intent.

## Step 4: Write CHANGELOG.md

If `CHANGELOG.md` does not exist, create it with this header:

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
```

If `CHANGELOG.md` exists, read it and check for an existing section for this version.

- **Version section exists** — merge new entries into existing categories. To detect duplicates, compare by semantic similarity (same change described differently). When in doubt, keep both and let the user review.
- **Version section does not exist** — add a new section after the header, before any existing version sections.

Format:

```markdown
## [1.2.0] - YYYY-MM-DD

### Added
- Entry description

### Fixed
- Entry description
```

Category order follows Keep a Changelog spec: **Added**, **Changed**, **Deprecated**, **Removed**, **Fixed**, **Security**. Only include categories that have entries. Use today's date.

## Step 5: Update Version Files

If Step 1 auto-detected the version from a file, that file still contains the *old* version. Update it to match the new version you just wrote the changelog for.

1. Check which version sources exist in the project (same list as Step 1):
   - `package.json` → update the `"version"` field
   - `Cargo.toml` → update `version` under `[package]`
   - `VERSION` or `version.txt` → replace file contents
   - `marketplace.json`, `plugin.json`, `.claude-plugin/plugin.json` → update the `"version"` field
2. Only update files that already contain a version field — don't create new ones.
3. If multiple version files exist, update all of them so they stay in sync.
4. If the user provided the version explicitly and it matches what's already in the file, skip this step.

The reason this matters: a changelog entry for v0.2.0 while package.json still says v0.1.0 is inconsistent and confusing. The version file is the source of truth for tooling (npm, cargo, installers), and it should agree with the changelog.

## Step 6: Add Version Diff Links

This step is separate from writing entries because it's easy to forget — and a changelog without diff links loses half its value. The links let readers click through to see the actual code changes behind each version.

1. Run `git remote get-url origin` to get the remote URL.
2. Convert the remote URL to a web-browsable HTTPS base URL:
   - **SSH format** `git@host:org/repo.git` → `https://host/org/repo`
   - **HTTPS format** `https://host/org/repo.git` → strip `.git` suffix
3. **Detect the tag prefix** used in this repo — this matters because some projects tag as `v1.0.0` while others use `1.0.0`, and the links must match the actual tags:
   - Run `git tag --list --sort=-v:refname` and examine existing tags.
   - If tags use a `v` prefix (e.g. `v1.0.0`, `v0.2.1`), use `v` in all generated URLs.
   - If tags have no prefix (e.g. `1.0.0`, `0.2.1`), omit the `v` in all generated URLs.
   - If the repo has mixed conventions or no tags yet, check if the user provided a version with or without `v`. If still ambiguous, default to no prefix — it's safer to link to `1.0.0` (which the user can verify) than to guess `v1.0.0` and produce broken links.
   - Store the detected prefix (either `"v"` or `""`) and apply it consistently to every URL generated below.
4. Build comparison URLs based on the hosting platform (using `{prefix}` for the detected tag prefix):
   - **GitHub**: `{base_url}/compare/{prefix}{previous}...{prefix}{current}`
   - **GitLab**: `{base_url}/-/compare/{prefix}{previous}...{prefix}{current}`
   - **Bitbucket**: `{base_url}/compare/{prefix}{current}..{prefix}{previous}`
   - Detect the platform from the hostname (github.com, gitlab, bitbucket.org)
5. At the very bottom of the CHANGELOG file (after all version sections), add or update link references for every version listed in the changelog:

```markdown
[1.2.0]: https://github.com/org/repo/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/org/repo/compare/v1.0.0...v1.1.0
```

For the oldest version (no previous tag to compare against), link to the tag itself:
```markdown
[1.0.0]: https://github.com/org/repo/releases/tag/v1.0.0
```

If the version is `Unreleased`, compare against the latest tag:
```markdown
[Unreleased]: https://github.com/org/repo/compare/v1.2.0...HEAD
```

6. If the remote URL can't be parsed or doesn't exist, skip links and note it in the report.

## Step 7: Report

Output a short summary:
- Version number and date
- Number of entries per category
- Whether breaking changes were detected
- Which version files were updated (if any)
- Whether version diff links were added (and the base URL used)
- File path
- Reminder: "These entries were generated from code diffs — please review before publishing."
