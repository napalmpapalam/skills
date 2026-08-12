---
name: seed
description: Audit the living doc against this chat, fold in what's missing, and print the seed block for the next session. Use when the user is about to /clear, asks for "the seed", "a seed block", "how do I continue this", or wants to check the context doc captured everything before starting fresh.
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# Seed

Hand this session off to the next one. Run before a `/clear`.

Load `/dd:flow:go` first if it isn't in context — it holds the doc structure and
the seed block definition this skill assumes.

**Audit the doc against this chat.** What's missing is whatever got settled
after the last write: decisions, facts worth a pointer, slices that shipped or
changed shape, fog that cleared. Fold each in as index-not-store — one-line gist
plus pointer — then run the fresh-eyes check from `go` Step 4.3.

**Report the doc edits**, one line each. "Nothing missing" is a valid answer.

**Print the seed block** (`go` Step 2.5): the seed line, plus live state the doc
can't hold — ports, running services, kube context — and whether each survives
the `/clear`. Don't run the `/clear` for the user.
