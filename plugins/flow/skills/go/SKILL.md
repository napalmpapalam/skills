---
name: dd:flow:go
description: Plan and ship a feature as vertical slices driven by one living doc, one slice ("go") at a time. Use when the user starts a new feature or project, asks how to build or approach something, wants to break scope into tasks or slices, says "let's plan this", "how should I build X", "do a go", "next slice", "what do I do next", or wants to update/continue from a feature context doc. Also use to run the close-slice ritual after finishing a piece of work.
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, WebSearch, WebFetch, AskUserQuestion
version: 0.1.0
effort: medium
---

# Go

Plan and ship a feature as **vertical slices** driven by **one living doc** — one slice ("a go") at a time. This encodes a fixed method so it never has to be re-explained per feature.

The method is depth-first and just-in-time: build one complete, working layer at a time, fold what you learned back into the doc, then the user clears the chat and starts the next slice from that doc.

## Principles (non-negotiable)

- **Every slice compiles and runs.** A slice is a complete thin path through all the layers it touches — never a horizontal spec fragment. After each slice the project is green: it builds, runs, and the new behavior works.
- **A slice is one reviewable PR.** Target **≤1000 lines changed**, hard cap **1500**, lock files excluded. A big feature is several slices, each mergeable on its own, so cross-review stays sane.
- **No dead code.** Build only what this slice needs. No config, interface, or scaffold for a future slice that hasn't arrived. If it isn't used now, it isn't in scope.
- **One slice per session.** After a slice lands, the user runs `/clear` and starts the next one fresh from the doc. Don't try to do two slices in one go.
- **What before how.** The user often knows the end state, not the path. Settle *how the slice will work* before writing code (see Step 1).

## The living doc

Each feature has one markdown doc in `~/Projects/adi-ctx/` (per the user's rule: context/planning docs live only there, never in the project repo). It is the seed a fresh session reads — written for Claude, not for reading cover to cover.

**Index, not store.** Each finished decision is a one-line gist plus a pointer (`file:line`, a path, a link) — never pasted code or detail. This is what keeps the doc from bloating into slop as the feature grows.

Structure:

```markdown
# <feature name>

## Destination
What "done" looks like — the end state, in a few lines. Re-read every session.

## Notes
Domain terms, constraints, preferences, key file/paths. Gist + pointer only.

## Decisions
- <one-line gist of a settled decision> — <pointer>
(the index of what's already chosen; grows as slices close)

## Slices
- [x] <slice that shipped> — <PR / commit / pointer>
- [ ] <next takeable slice — blockers all closed>
- [ ] <later slice>

## Not yet specified
Loose notes for things that can't be phrased as a sharp task yet (fog of war).

## Out of scope
Explicitly not doing.
```

## Flow

### Step 1 — Frame (before any code)

Settle *what this slice does and how it will work*. Grill one question at a time:

- **Look up facts yourself** — read the code, run a command, `WebSearch`/`WebFetch` the docs. Don't ask the user what you can verify.
- **Put decisions to the user** — anything that shapes the design. Ask one at a time, and **recommend an answer** each time so it's a yes/no, not an essay.
- **Don't write code until the shape is confirmed.**
- **Fog-of-war test:** something becomes a slice/task only if you can phrase its question sharply *now*. If you can't, park it under "Not yet specified" — don't invent structure for it.

### Step 2 — Slice

Turn the framed scope into vertical slices:

- Each slice = a complete thin path, leaves the project green, sized to one reviewable PR (≤1k lines).
- A feature too big for one PR → **split into several slices**, sequenced so each builds on a shipped one.
- Order by frontier: the next slice is one whose blockers are all done.
- Write the slice list into the doc's **## Slices** (checklist). Sharp ones only; vague ones go to **## Not yet specified**.

### Step 3 — Build one slice

Build the current slice end to end. Keep the change minimal and within the PR-size budget. If it's growing past ~1k lines, stop and re-slice — tell the user it needs splitting rather than shipping an unreviewable PR.

### Step 4 — Close the slice

When the slice is built, wrap it up so it's ready for the user's review. Reviewing, committing, and clearing the chat are the user's to do — don't do them for the user or tell the user to do them.

1. **Verify green.** Run the build/tests/run command and show the output. No "done" without fresh evidence in the same message.
2. **Update the doc** — index, not store: mark the slice `[x]` with a pointer to the change, add any new settled **Decisions** (gist + pointer), fold new facts into **Notes**, move anything now-sharp out of **Not yet specified**.
3. **Report completion for review.** State plainly that the slice's implementation is finished, and summarize what changed so the user can review the diff. The user reviews and commits it — never commit for the user. Have the next slice picked (the next takeable item on the frontier) and the **one-line seed** (which doc + which slice) ready for when the user wants to continue — offer it, don't direct.

## Starting a feature from scratch

If there's no doc yet, do Step 1 first, then create the doc in `~/Projects/adi-ctx/` with the structure above, then Step 2. The very first slice of a new project is usually the scaffold (init, README, CLAUDE.md, CI, lint/fmt) — small, green, runnable.
