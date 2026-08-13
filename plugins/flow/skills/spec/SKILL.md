---
name: spec
description: Write or update the repo's design spec — how a domain works and why it was built that way. This is the durable half of the flow's memory, the part that outlives the context doc. Use when a decision is settled and worth keeping, when closing a slice that changed a domain's shape, or when the user says "document this decision", "update the spec", "write it down so we don't re-litigate it".
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
version: 0.1.0
---

# Spec

The repo's durable memory: how each domain works, and why it was built that way.
Two readers — a teammate a year from now, and a fresh session starting the next
feature. Both arrive with no context and no way to ask.

The context doc (`/dd:flow:go`) holds what's **in flight**; this holds what's
**settled**. A decision moves here when the slice that made it ships, and the
context doc is deleted with nothing lost.

**Voice:** plain sentences, technical register, no marketing. Written to be read
on the first pass — but structured, because half the readers arrive by grepping
a heading rather than reading top to bottom.

## Layout

```
docs/design/
  README.md      index — one line per domain, what it covers
  <domain>.md    one per domain
```

A **domain** is a bounded piece of the system with its own vocabulary — match
how the code is already grouped (crate, module, service). Don't invent a domain
before the code has one.

A repo with code and no spec at all doesn't need this file written by hand —
`/dd:flow:backfill` bootstraps `docs/design/` from the code and git history.

Register `docs/design/README.md` in the repo's `CLAUDE.md` on first write. A
spec nothing links to is a spec nothing loads, and an unread doc rots silently.

## What goes in

Only what the code can't say for itself:

- **How it works** — the shape: parts, and what flows between them. Gist plus a
  pointer (`path`, `file:line`), never pasted code.
- **Invariants** — what must stay true, and what breaks if it doesn't.
- **Decisions** — the choice, why, and what was rejected. The rejected option is
  the load-bearing half: it's what stops the next person re-litigating it.
- **Known gaps** — what's deliberately unbuilt or unsound, so nobody reads a
  hole as an oversight.

Leave out anything a reader gets faster from the code: signatures, field lists,
call sequences, file inventories. A spec that restates the code drifts away from
it and then lies.

Describe the **built state**, never the plan. No planning vocabulary — slices,
go numbers, "next up", context-doc references. A reader of this file has never
seen the plan and never will.

## Rules

- **Same commit as the code.** A spec written later is a spec nobody checks; in
  the PR, the reviewer verifies it against the diff.
- **Edit in place when a decision is reversed** — replace the entry and say what
  changed the answer. Never append a contradiction; two live answers are worse
  than none.
- **A decision spanning two domains** goes where the invariant lives, and the
  other file links to it. Never copy it into both.
- **Nothing in flight.** Unfinished work, open questions, and dead ends belong
  in the planning doc, not here.

## Per-file shape

```markdown
# <domain>

<one paragraph: what this domain is responsible for>

## How it works
## Invariants
## Decisions
- <choice> — <why>; rejected <alternative> because <reason>.
## Known gaps
```

Drop a heading that has nothing under it. Keep the ones that do in this order,
so a session knows where to look without reading the whole file.
