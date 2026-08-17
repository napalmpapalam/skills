---
name: review
description: Comprehensive Rust code review — runs cargo checks, loads all Rust convention skills, reviews changes, and generates a structured report. Use when reviewing finished Rust changes, closing a slice that touched Rust, preparing a PR for merge, or auditing Rust code quality — not while writing the code.
---

# Rust Code Review

Comprehensive Rust review via automated checks and manual inspection against all Rust conventions. This skill is invoked explicitly (`/dd:rust:review`), not auto-triggered.

## Step 1: Automated checks

Run these first. Stop and report failures before manual review.

```bash
cargo fmt --all --check                              # formatting
cargo clippy --workspace --all-targets -- -D warnings # lints
cargo test                                            # tests
```

If any check fails, report the failure and fix it before continuing.

## Step 2: Identify changes

```bash
git diff HEAD~1 --name-only -- '*.rs'    # for commits
git diff main...HEAD --name-only -- '*.rs' # for PRs
```

## Step 3: Load convention skills

Before reviewing, invoke each of these with the Skill tool to load the full criteria:

1. `dd:rust:core` — types, error handling, ownership, async, layout, comments, style, naming
2. `dd:rust:testing` — unit/integration tests, mocking, async tests
3. `dd:rust:performance` — iterators, release profiles, inlining, bounds checks
4. `dd:rust:linting` — workspace lints, clippy enforcement, formatting
5. `dd:rust:serde` — serde attributes, snake_case defaults, enum representations

## Step 4: Review changed files

Review each changed `.rs` file against ALL criteria from the skills loaded in Step 3: error handling, ownership, async, type safety, naming, structure, **comment and doc-comment budget** (Step 5 — its own pass), testing, performance, linting.

For each issue record:
- **Severity**: CRITICAL / HIGH / MEDIUM
- **File and line**: exact location
- **Issue**: what's wrong
- **Fix**: concrete code suggestion

## Step 5: Comment budget pass — mandatory

Comment bloat is the convention a diff breaks most often and the one a reviewer most often lets through: it compiles, clippy is silent, and it reads as thoroughness. So it gets its own pass, and the report answers it for **every** changed file — including the ones that are within budget.

Locate the candidates, then judge them:

```bash
# every doc line with a line number — consecutive numbers = a multi-line run
grep -nE '^[[:space:]]*(///|//!)' <file>
# sections that restate the signature
grep -nE '# (Arguments|Returns)' <file>
```

Read each run against the **Comments** budget in `dd:rust:core` — `//!` 1 line, `///` 1 line, `//` 1–3 — and flag:

- a `//!` header past one line, or one narrating other modules;
- a `///` past one line whose extra text records no real invariant, precondition, or rationale — rationale that merely *sounds* insightful is still a poem;
- any comment longer than the code it describes;
- a `//` that restates what the code does, rather than a non-obvious *why*;
- `# Arguments` / `# Returns` sections. (`# Errors` / `# Panics` / `# Safety` stay when the behavior is non-obvious.)

**Grade these HIGH** — comment bloat blocks the merge, it does not warn. Being cosmetic is why it survives review; treating it as cosmetic is the failure this pass exists to stop.

Every fix collapses, never deletes: a public item stripped to no doc breaks the `missing_docs` gate. One line that says what the name doesn't.

## Step 6: Generate report

Output the review using the exact structure in `references/report-template.md` (files table, static-analysis table, comment-budget table, issues grouped by severity with blockquotes, summary table, and recommendation).

## Approval criteria

| Decision    | Condition                                            |
| ----------- | ---------------------------------------------------- |
| **Approve** | No CRITICAL or HIGH issues, comment budget clean      |
| **Warning** | Only MEDIUM issues — merge with caution              |
| **Block**   | Any CRITICAL or HIGH issues, incl. comment overruns  |
