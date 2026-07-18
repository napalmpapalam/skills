---
name: dd:rust:review
description: Comprehensive Rust code review — runs cargo checks, loads all Rust convention skills, reviews changes, and generates a structured report. Invoke explicitly with /dd:rust:review when reviewing Rust changes, preparing a PR for merge, or auditing Rust code quality.
disable-model-invocation: true
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

1. `dd:rust:error-handling` — Result/? patterns, thiserror vs anyhow, error chains
2. `dd:rust:ownership` — borrowing, lifetimes, smart pointers, Copy/Clone
3. `dd:rust:async` — tokio runtime, concurrency, channels, async pitfalls
4. `dd:rust:type-system` — newtypes, enums, generics, type safety
5. `dd:rust:code-structure` — project layout, modules, visibility, naming
6. `dd:rust:testing` — unit/integration tests, mocking, async tests
7. `dd:rust:performance` — iterators, release profiles, inlining, bounds checks
8. `dd:rust:linting` — workspace lints, clippy enforcement, formatting
9. `dd:rust:serde` — serde attributes, snake_case defaults, enum representations
10. `dd:rust:comments` — concise comments and doc comments, short module headers

## Step 4: Review changed files

Review each changed `.rs` file against ALL criteria from the skills loaded in Step 3: error handling, ownership, async, type safety, naming, structure, testing, performance, linting.

For each issue record:
- **Severity**: CRITICAL / HIGH / MEDIUM
- **File and line**: exact location
- **Issue**: what's wrong
- **Fix**: concrete code suggestion

## Step 5: Generate report

Output the review using the exact structure in `references/report-template.md` (files table, static-analysis table, issues grouped by severity with blockquotes, summary table, and recommendation).

## Approval criteria

| Decision    | Condition                               |
| ----------- | --------------------------------------- |
| **Approve** | No CRITICAL or HIGH issues              |
| **Warning** | Only MEDIUM issues — merge with caution |
| **Block**   | Any CRITICAL or HIGH issues found       |
