---
name: backfill
description: One-time bootstrap of `docs/design/` for a repo that has code but no spec — plan the domains as slices, then write them one per session. Invoked explicitly with /dd:flow:backfill.
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Agent, AskUserQuestion
disable-model-invocation: true
version: 0.1.0
---

# Backfill

Bootstrap `docs/design/` for a repo that already has the code and none of the
writing. Runs once per repo; after that `/dd:flow:spec` keeps it current.

A backfill is a feature like any other — a domain per slice, one per session,
each its own reviewable PR. So this skill does the framing, and `/dd:flow:go`
runs the loop. Load `/dd:flow:spec` too: it holds the layout and the per-file
shape.

## The one hard rule

You can read *what* is true from a codebase. You cannot read *why* it was
chosen. A spec whose reasons are reconstructed guesses is worse than no spec —
it reads as authoritative, and nobody can tell which half was invented.

Every line is one of two kinds, and they never blur:

- **Observed** — read from code. State it as fact, with a pointer. Goes under
  *How it works*, *Invariants*, *Known gaps*.
- **Sourced** — the reason is written down somewhere real: a **context doc's
  Decisions** (the user settled those at the time — the strongest source there
  is), a commit message, a PR body (`gh pr view`), an issue, a comment that
  explains rather than restates. Only these become **Decisions**, each citing
  where it came from.

A reason you can infer but not cite is not a decision. Leave it out and hand it
to the user — they may remember it, and that's the one thing they can supply
that you can't.

## Frame it

1. **Collect the context docs first.** List `~/.context/<project>/` and **ask
   the user** whether any others exist — an archived one, one under a different
   project name, a feature that shipped months ago. Their **Decisions** sections
   are rationale the user already confirmed, so they beat anything reconstructed
   from git. Pass the relevant ones to each domain's agent.
2. **Propose the domains.** Read the repo's own grouping — crates, packages,
   services, top-level modules. Show the list and what each covers, and have the
   user confirm or redraw it before anything is written. Their model of the
   system is the one the spec has to match.
3. **Write the context doc** at `~/.context/<project>/spec-backfill.md`, per
   `go`'s structure. One domain per slice; the first also creates the
   `docs/design/README.md` index and links it from `CLAUDE.md`. Order by what a
   newcomer needs first, not by size.
4. **Hand over** — `go` Step 2.5. The user `/clear`s and comes back with the
   seed block.

## Per domain (inside `go`)

One agent reads that domain's code, `git log -- <path>`, and the PR bodies
behind the commits that shaped it. It returns observed and sourced material
separately, plus the reasons it could see but couldn't cite.

Closing the slice differs from a code slice in two ways:

- **Nothing to run.** There's no build to go green; the check is the rules above
  — every Decision cites a source, nothing else claims to be one.
- **The gaps are the handover.** List the uncitable reasons for that domain.
  That list is what the user's review is actually for; without their answers the
  file stays observation-only, which is honest but thin.
