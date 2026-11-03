---
name: review
description: Comprehensive TypeScript code review — runs format, typecheck, lint and tests, loads the TypeScript convention skills, reviews the changes, and writes a structured report. Use when reviewing finished TypeScript changes, closing a slice that touched TypeScript, preparing a PR for merge, or auditing TypeScript code quality — not while writing the code.
---

# TypeScript Code Review

A review through automated checks and a manual pass against every TypeScript convention. This
skill is invoked explicitly (`/dd:ts:review`), not auto-triggered.

## Step 1: Automated checks

Run these first, cheap ones first. Report a failure and fix it before the manual review.

```bash
bun fmt --check   # formatting and import order
bun lint          # lints, type-aware per bunfig.toml
bun check         # types
bun test          # tests
```

On an old Bun, `bun fmt` and `bun lint` fail with `Script not found`. Then the repo is still on
prettier and eslint — run its own scripts, and report the missing Bun tooling as a MEDIUM issue.

## Step 2: Identify changes

```bash
git diff HEAD~1 --name-only -- '*.ts' '*.tsx'      # for commits
git diff main...HEAD --name-only -- '*.ts' '*.tsx' # for PRs
git status --short -- '*.ts' '*.tsx'               # for uncommitted work
```

## Step 3: Load convention skills

Invoke each with the Skill tool to load the full criteria:

1. `dd:ts:core` — layout, DRY, control flow, functions, types, enums, errors, async, module
   state, logging, classes, files, comments, naming
2. `dd:ts:testing` — layout, shape, what to assert, mocking
3. `dd:ts:tooling` — bun, `bun fmt`, `bun lint`, `bun check`, bunfig.toml, tsconfig flags
4. `dd:ts:library` — only when the code ships as a package

## Step 4: Review changed files

Review each changed file against all the criteria from Step 3. Check these first — they are the
violations that slip through most:

- `interface` instead of `type`
- an `as const` object or a string union for the program's own states, or a comparison with a
  raw string — instead of an `enum`
- a scattered module-level `let`, or work at import time
- `any`, a `!` non-null assertion, an `as` cast, an unnarrowed `catch (e)`
- nesting past 2 levels, an `else`, a C-style `for`
- a magic value (`'?'`, `-1`, `null`) for a failure the caller handles — instead of the error
  in the return type; a catch-all `catch` that does not narrow
- `if (!x) throw` where `assert()` fits; cleanup repeated in two branches instead of `finally`
- `console.log` or a raw `process.stdout.write` outside the logger
- hand-written type checks on external data instead of a zod schema
- a floating promise, or a sequential `await` that should be `Promise.all`
- a `function` declaration where an arrow const fits; a default export; a `../` import

For each issue record:

- **Severity**: CRITICAL / HIGH / MEDIUM
- **File and line**: the exact location
- **Issue**: what is wrong
- **Fix**: a concrete code suggestion

## Step 5: Layout and DRY pass — mandatory

Walls of code and copies are what a diff breaks most often and what a reviewer lets through
most often: the code compiles, `bun fmt` is silent, and each line looks fine. So they get their
own pass, and the report answers it for **every** changed file.

Find the candidates, then judge them against **Layout** and **DRY** in `dd:ts:core`:

```bash
# runs of 8+ lines with no blank line — wall candidates
awk 'FNR == 1 { n = 0 } NF { n++; if (n == 8) print FILENAME ":" FNR - 7 } !NF { n = 0 }' <files>

# lines that appear more than once across the changed files — copy candidates
sed 's/^[[:space:]]*//' <files> | grep -v '^import' | awk 'length > 25' |
  sort | uniq -c | awk '$1 > 1' | sort -rn
```

Flag:

- a body with several steps and no blank line between them;
- a block statement (`if`, `switch`, `try`, a loop) glued to the lines around it — except a
  one-line check next to its value, and a short body;
- a blank line inside a short body, or between a value and the one-line check of it;
- a wrapped call that splits a flag from its value, or packs several units on one line;
- the same expression, call prefix, check or literal written twice;
- a second implementation of what a module already does;
- the same cleanup in two branches.

**Grade these HIGH.** A wall or a copy blocks the merge; it does not warn. Being cosmetic is
why it survives review — treating it as cosmetic is the failure this pass exists to stop.

## Step 6: Comment budget pass — mandatory

Read every comment run against the **Comments** budget in `dd:ts:core` — a module header 1 line
or none, a TSDoc 1 line, an inline `//` 1–3 lines.

```bash
grep -nE '^[[:space:]]*(//|/\*\*|\*)' <file>
grep -nE '@(param|returns)' <file>
```

Flag a header past one line, a TSDoc past one line whose extra text records no real invariant,
any comment longer than its code, a `//` that restates the code, and `@param` / `@returns` that
restate the signature. **Grade these HIGH.** Every fix shortens; it never strips a public doc to
nothing.

## Step 7: Generate report

Output the review in the exact structure of `references/report-template.md`.

## Approval criteria

| Decision | Condition |
|---|---|
| **Approve** | No CRITICAL or HIGH issues; layout, DRY and comment passes clean |
| **Warning** | Only MEDIUM issues — merge with caution |
| **Block** | Any CRITICAL or HIGH issue, a wall, a copy or a comment overrun included |
