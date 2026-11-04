---
name: ticket
description: Draft and create Jira tickets — one ticket for a piece of work, or a batch of epics and tasks from a scope source (a board, a plan doc, meeting notes). Use when the user asks to "create a Jira ticket", "write a task for this", "make tickets from this board", "break this scope into Jira", "add tasks to epic X", or to update, move or cancel existing tickets as part of that work.
---

# Jira tickets

Draft the text first, get the user's yes, then create it in Jira. A new ticket is an outward-facing action: the team sees it at once.

**Voice:** follow `${CLAUDE_PLUGIN_ROOT}/references/voice.md` — ASD-STE100 sentences in a technical tone. Read it before you write a draft.

Two modes:
- **One ticket** — work that starts now. The **full form**. This file covers it.
- **A scope breakdown** — many epics and tasks from a board, a plan or notes. The **short form**, created in iterations. Read `references/scope.md` for it; Steps 2–3 and the rules below still apply.

## Step 1 — Collect the input

The input can come from:
- **a `~/.context` doc** — a `/dd:flow:go` doc maps well: Destination → TLDR and DoD, Decisions → Info, Out of scope → Not in this task;
- **this chat**;
- **the user** — what they know, meeting notes, a pasted thread.

Ask the user for each part the input does not give: the problem, the end state, the cuts. Ask for the **priority** too; the user can skip it. Put all the questions in one message, not one per turn.

## Step 2 — Find the target

- **Site:** call `getAccessibleAtlassianResources` once and reuse its `cloudId`.
- **Project and parent:** the project key and the parent — an epic for a task, an initiative for an epic, a task for a sub-task. Ask when the input does not say.
- **Issue types:** list the project's issue-type metadata and use its names. Never guess a type.
- **Record it:** write the `cloudId`, the project key, the type names and the parent keys into the context doc, so the next session does not look them up again.

## Step 3 — Read the neighbours

Run JQL on the parent epic, or on the project for the last 30 days. Read 10–20 tickets:
- **Title prefixes** — reuse the team's set (`[Prover]`, `[E2E]`, …). Add a new prefix only when none fits.
- **Duplicates** — a ticket for the same work exists → do not create one. Tell the user and offer to update it.
- **Depth** — match how much the team writes.

## Step 4 — Write the draft

**Title:** `[Component] <verb phrase for the outcome>`, ≤70 chars, no period. Example: `[E2E] Port the e2e harness to Bun + TypeScript`.

**Body, full form** — these four headings, in this order:

```markdown
## TLDR

<3–4 sentences: what changes, the shape of the change, and when it ends.>

## Info

* <the state today, with a pointer the team can open>
* <one design choice per bullet>
* <how the change is proven or rolled out>
* Plan, one MR each:
    1. <step>

## Definition of Done

* <a checkable end state>

## Not in this task

* <a cut someone would expect> — <where it goes, when that is not obvious>
```

- **DoD = end states, not activities.** ✅ "The devnet runs protocol v0.31.1." ❌ "Upgrade the devnet." A reviewer must be able to answer yes or no.
- **DoD patterns that recur:**
  - research → "A document lists the options, their cost, and a recommendation." · "The document is presented to the team." · "Follow-up tasks exist in this epic."
  - a test or a rollout → "Each problem found has its own task."
  - a release → "A tagged release and its image are published."
- **Blockers go in the body:** "Blocked: …", "Depends on …". Name earlier work by its key or its title in quotes.
- **Info is an index.** No pasted code, no logs.
- **Link only what the team can open** — a repo, an MR or PR, a ticket, a Confluence page. Never a `~/.context` path, a slice number, or a local branch.

**Fields:**

| Field | Value |
|---|---|
| Type | Task under an epic · Epic under an initiative · Sub-task under a task |
| Parent | set on create |
| Priority | the user's answer from Step 1; a skip → omit it, and Jira uses the project default |
| Status | To Do on create; any other status is a transition after the create |
| Assignee | none — the user sets it by hand |

## Step 5 — Show, then create

1. **Check** the draft against the checklist at the end of the voice file. Then **show** the title, a fields line and the body in a code block. Wait for an explicit yes. A yes for one ticket does not cover the next one.
2. **Create** with `createJiraIssue`: `contentFormat: markdown`, `parent`, and `priority` when the user gave one.
3. **Transition** when the status is not To Do — Jira ignores a status on create. List the transitions, then use `transitionJiraIssue`.
4. **Write the key back** into the context doc, when there is one (`Key: PROJ-123`). A re-run sees the key and does not create a duplicate.
5. **Report** a clickable link, `https://<site>/browse/<KEY>`, with the title — never a bare key.

## Edit an existing ticket

- **Read it first** with `getJiraIssue`. Other people can change it after you wrote it.
- **Media in the description** (images, mentions, panels) → read and write with `contentFormat: html`. Markdown drops them.
- **`editJiraIssue` replaces, it does not append.** Send the full description and the full label list.
- **Status is a transition**, not an edit. A parent move is an edit of `parent`.
- **Check the type.** An old ticket can be a Design or a Story, not a Task. Never change a type silently.
- **Live work** — when the user asks, keep a "Changes so far" list in Info current.

## Connector gotchas

- **Two Atlassian connectors** can be installed (Atlassian MCP and Rovo). A 403 on one → retry the same operation on the other before you call it a permissions problem.
- **A rejected create** returns `repairHint` and `allowedValues`. Fix the call from them and retry once.
- **A create that returned a key succeeded.** A later step can fail (a transition, a sprint) — retry that step only, never the create.
