---
name: dd:git:pr
description: Use when opening or preparing a pull request or merge request — writing the PR/MR title and description from the branch diff, summarizing changes for review, or when the user says "write a PR description", "open a PR", "prepare an MR", or "get this ready for review".
---

# Writing PR / MR Descriptions

Generate a review-ready **title + description** from the branch diff. Output it for the user to review — **never open or push it** unless the user explicitly asks.

## Step 1 — Gather the diff

- **Base branch:** the default branch. Detect it: `git rev-parse --abbrev-ref origin/HEAD` (falls back to `main`, then `master`).
- **Changes:** `git diff <base>...HEAD --stat` for the shape, `git diff <base>...HEAD` for detail.
- **Commits:** `git log <base>..HEAD --format='%s'` — the commit subjects are the outline of the story.
- If a `~/.context/<project>/*.md` flow doc covers this work, read it to understand the **"why"** — but it's a private, local note. Fold that understanding into the Summary prose; never cite its path or slice numbers in the output (see Step 3).

## Step 2 — Detect the host

`git remote get-url origin`:
- contains `github.com` → it's a **PR** (open with `gh pr create` only if asked).
- contains `gitlab` → it's an **MR** (open with `glab mr create` only if asked).
- neither / unknown → still write the description; just say which tool to paste it into.

## Step 3 — Write it

**Title:** one line, conventional-commit style (`type(scope): subject`) — reuse the `dd:git:commit` rules. Imperative, ≤72 chars.

**Description:** scannable, keypoints first. Default structure — drop any section that would be empty:

```markdown
## Summary
<1–3 sentences: what this changes and why. The reviewer reads this first.>

## Changes
- <grouped by area — the meaningful changes, not a file list>

## Test plan
- <how it was verified: commands run, cases covered. See rule below.>

## Notes for reviewer
- <anything non-obvious: a trade-off, a follow-up, a deliberate omission>
```

- **Group changes by intent**, not by file. The diff shows *what*; the description explains *why*.
- **Link only what reviewers can open** — a ticket/issue id, a related MR/PR. **Never** reference local flow docs, `~/.context/` paths, or internal slice/task numbers that live only on your machine — they're useless to other devs.

## Step 4 — Be honest about testing

- Only list a check under **Test plan** if it was actually run — cite the command/output. Follows the "no 'done' without proof" rule.
- If nothing was run, write `Not yet verified` and say what *should* be run — don't fabricate a passing test plan.

## Step 5 — Hand off

Print the title and description in a code block so the user can copy it. Then offer — don't do it — to open it (`gh pr create` / `glab mr create`). Opening a PR/MR is an outward-facing action: get an explicit yes first.
