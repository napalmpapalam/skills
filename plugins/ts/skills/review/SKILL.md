---
name: dd:ts:review
description: Comprehensive TypeScript code review — runs typecheck, lint and tests, loads all TypeScript convention skills, reviews changes, and generates a structured report. Invoke explicitly with /dd:ts:review when reviewing TypeScript changes, preparing a PR for merge, or auditing TypeScript code quality.
disable-model-invocation: true
---

# TypeScript Code Review

Comprehensive review via automated checks and manual inspection against all TypeScript conventions. Invoked explicitly (`/dd:ts:review`), not auto-triggered.

## Step 1: Automated checks

Run these first. Stop and report failures before manual review.

```bash
bun x prettier --check .          # formatting
bun x tsc --noEmit                # types
bun x eslint . --max-warnings=0   # lints
bun test                          # tests
```

Use the repo's own scripts if they exist (`bun run lint`, `bun run typecheck`). If any check fails, report it and fix before continuing.

## Step 2: Identify changes

```bash
git diff HEAD~1 --name-only -- '*.ts' '*.tsx'    # for commits
git diff main...HEAD --name-only -- '*.ts' '*.tsx' # for PRs
```

## Step 3: Load convention skills

Before reviewing, invoke each with the Skill tool to load the full criteria:

1. `dd:ts:code-structure` — layout, barrels, imports, naming
2. `dd:ts:code-style` — nesting, guard clauses, no `else`, no `for`, functions
3. `dd:ts:classes` — privacy, getters, factories, immutability, `use*`/`with*`
4. `dd:ts:type-system` — `type` over `interface`, brands, unions, `unknown`, zod
5. `dd:ts:error-handling` — error classes, narrowing, assertions, causes
6. `dd:ts:async` — parallel vs sequential, cancellation, floating promises
7. `dd:ts:tooling` — tsconfig flags, eslint, prettier, build and exports
8. `dd:ts:testing` — layout, naming, fixtures, what to assert
9. `dd:ts:comments` — TSDoc length, why-not-what

## Step 4: Review changed files

Review each changed file against ALL criteria from Step 3. Check these first — they're the highest-frequency violations:

- `interface` instead of `type`
- nesting past 2 levels, an `else`, or a `for` loop
- `any`, a non-null `!`, or an unnarrowed `catch (e)`
- `#` private fields (should be `private`)
- a `with*` method that mutates
- a bare primitive where a branded type belongs
- a swallowed error or a lost `cause`
- a floating promise, or sequential `await` that should be `Promise.all`
- a default export
- TSDoc that restates the signature

For each issue record:

- **Severity**: CRITICAL / HIGH / MEDIUM
- **File and line**: exact location
- **Issue**: what's wrong
- **Fix**: concrete code suggestion

## Step 5: Generate report

Output the review using the exact structure in `references/report-template.md`.

## Approval criteria

| Decision    | Condition                               |
| ----------- | --------------------------------------- |
| **Approve** | No CRITICAL or HIGH issues              |
| **Warning** | Only MEDIUM issues — merge with caution |
| **Block**   | Any CRITICAL or HIGH issues found       |
