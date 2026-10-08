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

**The description is an index, not the documentation.** A reviewer reads it to learn what changed and why — then they read the diff. Anything that *explains the code* belongs in the code as a comment, not here. A long description is not thorough; nobody reads it.

**Two sections, nothing else: `## Summary` and `## Changes`. Budget: ~150 words.** Over that, **cut whole bullets** — never compress them into denser prose or abbreviations.

| Section | Budget | What goes in |
|---|---|---|
| `## Summary` | **≤4 sentences + optional visual** | The problem, its effect, and what this does about it. The only place prose is allowed. |
| `## Changes` | **≤6 bullets, one line each** | Grouped by intent, never a file list. |

- **A visual, when the shape of the change is the point.** At most one, in Summary, under the sentence it supports. It sits outside the word budget, but keep it to ~12 lines and only the nodes the point needs.

| The change… | Visual |
|---|---|
| moves a flow between services or components | Mermaid `sequenceDiagram` / `flowchart` |
| changes the control flow inside one service | call tree in a `text` block |
| adds a module layout or is a broad refactor | shallow file tree, one `# role` comment per entry |
| adds an algorithm or state logic | pseudocode in a `text` block |

Skip it when it repeats the Summary or the change sits in one function. **Never** a `diff`-shaped tree (`+`/`-` lines on a tree), and never a full code block — the diff already shows the code.

- **No Test plan, no Notes for reviewer, no Risks.** CI already shows tests, clippy, and fmt. Rejected alternatives, deliberate omissions, and invariants go in code comments next to the code they explain.
- **One exception — a one-way door.** If a revert cannot undo the change (a destructive migration, a public API removal, a changed on-disk or wire format, deleted data), add one line after Changes: `**One-way door:** <what a revert cannot bring back>`. A two-way door gets no line.
- **One line per bullet — no paragraph under a bold lead.** That shape is the main way a description doubles in size. If a bullet needs a paragraph, the explanation belongs in a code comment.
- **Every line carries a fact the reader can't get from the diff.** Background on how the system works, a walkthrough of code you didn't touch, and self-narration ("the thing to watch here is…") pad a description most.
- **Link only what reviewers can open** — a ticket/issue id, a related MR/PR. **Never** reference local flow docs, `~/.context/` paths, or internal slice/task numbers that live only on your machine — they're useless to other devs.

## Step 4 — Hand off

Print the title and description in a code block so the user can copy it. If the description holds a visual, fence the outer block with four backticks so the inner fence does not close it. Then offer — don't do it — to open it (`gh pr create` / `glab mr create`). Opening a PR/MR is an outward-facing action: get an explicit yes first.

## Step 5 — If you opened it, print the URL

The first thing the user does next is open the PR, so **always end with the full URL on its own line** — never just "PR created" or a bare number.

- `gh pr create` / `glab mr create` print the URL as the last line of their output — reuse it.
- If it scrolled past or the PR already existed, ask the tool: `gh pr view --json url -q .url` / `glab mr view -F json | jq -r .web_url`.
- Same when you only pushed and the remote printed a "create a pull request" link — surface that URL too.
