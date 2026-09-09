---
name: commit
description: Use when about to create a git commit — composing the commit message, choosing the conventional-commit type prefix, or staging changes for a commit
---

# Writing Git Commits

Format: **`type: subject`** (or `type(scope): subject`). Imperative, ≤72 chars, lowercase after the colon, no trailing period, no ticket IDs unless asked. A body is optional and usually unnecessary — see [Body](#body).

Overrides any default commit style. Does **not** override safety rules: no `--no-verify`, force-push, amending published commits, or committing without an explicit request.

## Types

| Type | When |
|---|---|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Code change, same external behavior |
| `docs` | Docs / comments only (`*.md`) |
| `test` | Tests only (`*.test.*`, `*.spec.*`, `*.feature`) |
| `style` | Formatting only, no meaning change |
| `ci` | CI config (`.github/workflows/`, `.gitlab-ci.yml`) |
| `build` | Build system or dependencies (`package.json`, lockfile, `Dockerfile`) |
| `chore` | Anything else that doesn't touch code |

Pick by the **dominant** change. If the diff spans unrelated types, don't invent a hybrid — propose splitting into separate commits.

## Body

**Default: no body.** The subject is the commit message. A body exists for a fact the reader
cannot get from the diff — write one only when you can name that fact.

**Budget: ≤3 lines**, one fact per line. Over budget, cut whole facts — never compress them
into denser prose or abbreviations. Plain sentences; if the line only fits abbreviated, it
wasn't worth a line.

Earns a line:

- A **dependency or ordering constraint** — `Merge after !762.`
- A **trade-off the diff can't show** — `Each half now has one FRI prover, so losing it stalls that chain.`
- A **non-obvious reason for the choice** — why this fix and not the one the reader expects.

Never a line:

- **How the system works.** The reader has the codebase.
- **What the diff shows.** They're about to read it.
- **The subject, restated.**
- **Mechanism in code you didn't touch** (`resolve()` returned X, `pick_job` picks Y) — if that
  needs explaining, it needs a comment in that file.
- **Self-narration** — "The cost, stated so it is not a surprise:", "which is the thing to watch".

### Cutting a body

A config change split one devnet across two prover pools. The draft ran five paragraphs:
background on what a pool is, a walkthrough of `resolve()` / `assign()` / `pick_job`, the
trade-off, and the merge order. Only the last two are facts the diff can't show; the rest is
the codebase explaining itself to someone who already has it.

```
feat: split devnet7 across two mux chains so the pools partition

Each half now holds one FRI and one SNARK prover, so losing either stalls
that chain instead of halving throughput.
Merge after !762 — until it lands, pool b has no live prover.
```

## Workflow

1. Run `git status` + `git diff` + `git log -5 --oneline` to see state and recent style.
2. Choose the type; split if needed.
3. Stage and commit in one command (single approval). Stage by explicit path — never `git add -A` / bare `git add .`. Keep the HEREDOC so multi-line bodies survive:
   ```bash
   git add path/to/file another/file &&
   git commit -m "$(cat <<'EOF'
   type(scope): subject in imperative, lowercase

   Body only if it carries a fact the diff can't show. Usually: drop it and the blank line.
   EOF
   )"
   ```
4. Don't push, amend, or `--no-verify` unless explicitly asked.

## Examples

- ✅ `feat(bridge): support custom L1 RPC override`
- ✅ `fix: strip trailing slash from explorer URL`
- ✅ `build: bump zksync-ethers to 6.18.0`
- ❌ `Fixed bug.` — no type, past tense, capitalized, period
- ❌ `chore: update package.json to bump ethers` — should be `build`
- ❌ `feat: PROJ-123 add ramp` — ticket noise in subject
