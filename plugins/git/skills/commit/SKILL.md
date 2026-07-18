---
name: dd:git:commit
description: Use when about to create a git commit — composing the commit message, choosing the conventional-commit type prefix, or staging changes for a commit
---

# Writing Git Commits

Format: **`type: subject`** (or `type(scope): subject`). Imperative, ≤72 chars, lowercase after the colon, no trailing period, no ticket IDs unless asked. Optional body after a blank line explains **why**, not what the diff shows.

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

## Workflow

1. Run `git status` + `git diff` + `git log -5 --oneline` to see state and recent style.
2. Choose the type; split if needed.
3. Stage and commit in one command (single approval). Stage by explicit path — never `git add -A` / bare `git add .`. Keep the HEREDOC so multi-line bodies survive:
   ```bash
   git add path/to/file another/file &&
   git commit -m "$(cat <<'EOF'
   type(scope): subject in imperative, lowercase

   Optional body explaining why.
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
