---
name: look
description: Send background agents at the primary sources and come back with cited findings — facts, or a menu of options with their costs. Use before framing a feature, or any time the user says "look into X", "research X", "check whether X", "what are my options for X", "I need to start but don't know where".
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, WebSearch, WebFetch, Agent
---

# Look

Go ahead of the work and report back.

## Brief the agents

Spin up **background agents** — the raw material stays in their context, not in
the one that has to frame the work next. Independent branches of a question →
one agent each.

Every brief carries:

- **The question, sharply phrased.** Sharpen it with the user first if it's
  really three questions.
- **Primary sources only** — official docs, source code, specs, first-party
  APIs, this repo.
- **Cite every claim** — URL, `file:line`, or the command that produced it.
- **Return findings as text**, and say what couldn't be established rather than
  filling the gap by inference. The agents don't write files; this session does.

When the question is *"where do I start"*, the brief asks for the **option
space** — what approaches exist, what each costs, what the repo already leans
toward — not a single answer.

## Land it

| The ask | Where it goes |
|---|---|
| a bounded check | this chat, cited. No doc. |
| groundwork for a feature | `~/.context/<project>/<feature>.md` |

Writing the doc follows `/dd:flow:go` — load it if it isn't in context. Index,
not store: gist plus pointer, never a pasted listing.

- **Notes** — the findings.
- **Not yet specified** — questions this opened and didn't close, and every
  option the user still has to pick between.
- **Decisions** — only what the sources *force* ("v1 has no streaming endpoint —
  so v2"). Options are not decisions; choosing is `go` Step 1's job.
- **Slices** — leave empty. Slicing is `go` Step 2.

Flag anything unverified. When two sources disagree, say which wins and why.

## Hand over

Print what's established (one line each, with the pointer), then what stayed
open — "nothing" is a valid answer. If a doc was written, give its path and the
next step: `/dd:flow:go` on it, in a fresh session.

Don't frame, slice, or build here.
