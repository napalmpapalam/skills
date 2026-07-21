---
name: dd:flow:go
description: Plan and ship a feature as vertical slices driven by one living doc, one slice ("go") at a time. Use when the user starts a new feature or project, asks how to build or approach something, wants to break scope into tasks or slices, says "let's plan this", "how should I build X", "do a go", "next slice", "what do I do next", or wants to update/continue from a feature context doc. Also use to run the close-slice ritual after finishing a piece of work.
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, WebSearch, WebFetch, AskUserQuestion
version: 0.1.2
effort: medium
---

# Go

Plan and ship a feature as **vertical slices** driven by **one living doc** — one slice ("a go") at a time. This encodes a fixed method so it never has to be re-explained per feature.

The method is depth-first and just-in-time: build one complete, working layer at a time, fold what you learned back into the doc, then the user clears the chat and starts the next slice from that doc.

## Principles (non-negotiable)

- **Every slice compiles and runs.** A slice is a complete thin path through all the layers it touches — never a horizontal spec fragment. After each slice the project is green: it builds, runs, and the new behavior works.
- **A slice is one reviewable PR.** Target **≤1000 lines changed**, hard cap **1500**, lock files excluded. A big feature is several slices, each mergeable on its own, so cross-review stays sane.
- **No dead code.** Build only what this slice needs. No config, interface, or scaffold for a future slice that hasn't arrived. If it isn't used now, it isn't in scope.
- **One slice per session.** Planning and building are separate sessions too — a new doc is handed over, not built on (Step 2.5). After a slice lands, the user runs `/clear` and starts the next one fresh from the doc. Don't try to do two slices in one go.
- **What before how.** The user often knows the end state, not the path. Settle *how the slice will work* before writing code (see Step 1).

## The living doc

Each feature has one markdown doc in `~/.context/` — a dedicated directory outside the project repo. Planning docs live there, never in the project itself. It is the seed a fresh session reads — written for Claude, not for reading cover to cover.

**Keep the directory lean:** one dir per project, one file per active feature — `~/.context/<project>/<feature>.md`. Delete a doc once its feature ships; the merged code and git history are the record, so finished docs are just clutter.

**Index, not store.** Each finished decision is a one-line gist plus a pointer (`file:line`, a path, a link) — never pasted code or detail. This is what keeps the doc from bloating into slop as the feature grows.

Structure:

```markdown
# <feature name>

> **This doc drives the `/dd:flow:go` flow. If you're reading it to do work, invoke that skill first — it holds the method this doc assumes.**

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

Working from an older doc that has no banner? Add it — one line, no other edits.

## Flow

### Step 1 — Frame (before any code)

Settle *what this slice does and how it will work*. Grill one question at a time:

- **Scope-check before questioning.** If the request is really several independent subsystems ("a platform with chat, billing, and analytics"), say so now — don't burn questions refining details of something that has to be split into separate features first. Each gets its own doc.
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

### Step 2.5 — Hand over the doc (new doc only)

**When the doc is created for the first time, stop here. Do not start building in this session.**

Framing is exploration-heavy — rejected proposals, refuted guesses, dead ends. Building on top of that context means the doc never gets used as what it is: the seed a fresh session reads. Handing over tests the seed while it's still cheap to fix.

1. **Re-read the doc with fresh eyes** — the same check as Step 4.3 (placeholders, contradictions, ambiguity, stale scope). Fix what's broken inline.
2. **Print the TL;DR** (below) so the user can judge the plan without opening the file.
3. **Hand over.** Say the doc is ready and give the seed block (below). The user `/clear`s and re-enters this skill to build. Don't run the clear for the user, and don't start Step 3.

If the doc already exists (a continuing session), skip this step — go straight to Step 3.

**The TL;DR.** The user should get the **whole picture in one scan** — never have to open the file to know what was decided and what's about to be built. So it covers everything the doc covers; what gets cut is the prose, not the items.

- **Destination** — one line.
- **Decisions** — every settled one, one line each. This is the core: it's what the user is really reviewing.
- **Gotchas** — corner cases, constraints, and surprises found while framing. One line each; these are what a reader would otherwise miss.
- **Slices** — the checklist, one line each, next-takeable one marked.
- **Needs your call** — anything still open or assumed. Empty is a valid answer; say so.

Cut: rationale, the path you took to a decision, pointers and `file:line` refs, verification output, alternatives you rejected. Keep the *what*, drop the *how you got there* — the doc holds that for the next session.

**The seed block.** The user copy-pastes this straight into the fresh chat, so it has to stand alone there — one line is the floor, not a cap. Include:

- **The seed line** — `/dd:flow:go` + `<doc path>` + which slice. Always, and always with the command: pasted text alone won't pull this skill in, and a fresh session without it builds off-method. The doc's header banner is the backstop for docs opened some other way, not a substitute — it only fires once the file is already open.
- **Live session state the doc can't hold** — running port-forwards and their ports, a started service, a temp file, an open tunnel, a chosen kube context. Say whether it survives a `/clear`, and where the restart command lives if it doesn't. This is the part that saves the next session real time; a doc records the plan, not what's running right now.

Keep it to those. Anything a fresh session can find by reading the doc doesn't belong in the block.

### Step 3 — Build one slice

Build the current slice end to end. Keep the change minimal and within the PR-size budget. If it's growing past ~1k lines, stop and re-slice — tell the user it needs splitting rather than shipping an unreviewable PR.

For logic-heavy slices (clear inputs/outputs — parsers, calculations, rules), drive it with a failing test first. For scaffold, wiring, and config slices, skip it — there's nothing to red-test.

### Step 4 — Close the slice

When the slice is built, wrap it up so it's ready for the user's review. Reviewing, committing, and clearing the chat are the user's to do — don't do them for the user or tell the user to do them.

1. **Verify green.** Run the build/tests/run command and show the output. No "done" without fresh evidence in the same message.
2. **Update the doc** — index, not store: mark the slice `[x]` with a pointer to the change, add any new settled **Decisions** (gist + pointer), fold new facts into **Notes**, move anything now-sharp out of **Not yet specified**.
3. **Re-read the doc with fresh eyes.** It's the seed for a session that has none of this context, so check it as that reader would and fix what's broken inline — no second pass needed:
   - **Placeholders** — any `TBD`, `TODO`, or requirement too vague to act on?
   - **Contradictions** — does a new Decision cut against an older one, or against Destination?
   - **Ambiguity** — could a line be read two ways? Pick one and say it outright.
   - **Stale scope** — do the remaining slices still match what the last one taught you?
4. **Report completion for review.** State plainly that the slice's implementation is finished, then hand over what the diff won't tell them. **Lead with anything needing the user's decision** — an interim posture, a shortcut taken, a risk accepted, a surprise found on the way. Then the shape of the change and any *why* that isn't visible in the code. Don't re-narrate the diff module by module; they're about to read it. The user reviews and commits it — never commit for the user. Have the next slice picked (the next takeable item on the frontier) and the **seed block** (Step 2.5) ready for when the user wants to continue — offer it, don't direct.

## Starting a feature from scratch

If there's no doc yet, do Step 1 first, then create the doc in `~/.context/` with the structure above, then Step 2. The very first slice of a new project is usually the scaffold (init, README, CLAUDE.md, CI, lint/fmt) — small, green, runnable.
