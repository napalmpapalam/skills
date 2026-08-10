---
name: pr
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

**The description is an index, not the documentation.** A reviewer reads it to learn where to look and what to be suspicious of — then they read the diff. Anything that *explains the code* belongs in the code as a comment, not here. A long description is not thorough; it's work pushed onto every reviewer.

**Budget: ~200 words total, one screen.** Over that, cut — don't ask for an exception.

| Section | Budget | What goes in |
|---|---|---|
| `## Summary` | **2–3 lines** | The problem, and what this does about it. The only place prose is allowed. |
| `## Changes` | **≤6 bullets, one line each** | Grouped by area or intent, never a file list. |
| `## Test plan` | **≤4 bullets, one line each** | Only what was actually run. |
| `## Notes for reviewer` | **≤3 bullets, one line each** | Only what stops a reviewer filing a wrong comment. |

Drop any section that would be empty.

- **One line per bullet — no paragraph under a bold lead.** That shape is the main way a description doubles in size. If a bullet truly needs a paragraph, the explanation belongs in a code comment: put it there and leave a pointer here.

```markdown
<!-- Four lines of ABI reasoning nobody asked for -->
**`CudaError` was deliberately not touched.** A `Cancelled` variant there would have
ridden the existing `CudaResult` path, but that enum is `#[repr(u32)]` in
`cudart-sys/src/bindings.rs` and bindgen-generated: a synthetic variant misrepresents
the C ABI and would be lost on the next regeneration.

<!-- One line, and the reasoning now lives where the next person will hit it -->
- No `Cancelled` variant on `CudaError` — it's bindgen `#[repr(u32)]`; see the comment there.
```

- **Notes for reviewer is not a design doc.** Rejected alternatives, ABI reasoning, and invariants live next to the code that depends on them. Keep this section for a **known follow-up**, a **deliberate omission**, or a **trade-off the diff can't show** — three at most, and if there are more, that's a sign the code needs the comments.
- **Group changes by intent**, not by file. The diff shows *what*; the description explains *why*.
- **Link only what reviewers can open** — a ticket/issue id, a related MR/PR. **Never** reference local flow docs, `~/.context/` paths, or internal slice/task numbers that live only on your machine — they're useless to other devs.

## Step 4 — Be honest about testing

- Only list a check under **Test plan** if it was actually run — cite the command/output. Follows the "no 'done' without proof" rule.
- If nothing was run, write `Not yet verified` and say what *should* be run — don't fabricate a passing test plan.

## Step 5 — Hand off

Print the title and description in a code block so the user can copy it. Then offer — don't do it — to open it (`gh pr create` / `glab mr create`). Opening a PR/MR is an outward-facing action: get an explicit yes first.
