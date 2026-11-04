# Scope breakdown

Turn a scope source — a board export, a plan doc, meeting notes — into Jira epics and tasks. One iteration creates one epic and its tasks.

## 1. Write the plan doc first

Write `~/.context/<project>/jira-<scope>.md`. Nothing goes to Jira before the user reads it.

The plan doc is **not** a `/dd:flow:go` doc. It maps a scope to Jira keys; it does not plan slices, so it gets no flow banner. When the work of one ticket starts later, `/dd:flow:go` frames it in its own doc.

The source can be thin, for example a few board stickers or the user's memory of a meeting. Ask the user for the missing parts before you write the drafts.

```markdown
# <Scope> → Jira

Source: <where the scope came from, with the export date>.
Target: project **KEY**, parent **KEY-N "<title>"**.

## Rules

- **Jira:** cloudId `<id>`. Epic type `<name>`, Task type `<name>`.
  A new epic gets parent `KEY-N`. A task gets its epic as parent.
- **Title:** `[Component] Title`, the same prefix style as the existing tickets.
- **Description body:** 2–3 sentences, then a `Definition of Done` checklist.
- **Priority (new tasks only):** <source mark → Jira priority>, or none. Ask the user
  for the mapping; a skip → no priority field. Existing tickets keep their priority
  unless the plan says otherwise.
- **Status:** To Do, except where a task says otherwise.
- **Assignees:** none. The user sets them by hand.
- **Skip:** <each source item that is not a ticket, with its reason>.
- ⚠ = an open question. Resolve it before its iteration runs.

## Iterations

| # | Epic | Work | State |
|---|---|---|---|
| 1 | <Epic> (new / existing KEY-N) | 3 new tasks + epic description | todo |

---

## 1. <Epic> — new

Epic: <1–2 sentences: what the epic covers>.
Key:

### [Component] Title
Key: · Priority: Low · Status: To Do

<2–3 sentences: what, why, and what it unblocks or depends on.>

Definition of Done:
- <a checkable end state>

---

## N. Clean up <epic> (KEY-M)

Move to <epic>:
- KEY-1 <title> → priority <P>

Cancel:
- KEY-2 <title> → status Cancelled

---

## Already in Jira — not created

Open:
- <source item> = "<title of the existing ticket>"

Done (the source is behind Jira):
- <source item> = "<title of the existing ticket>"
```

## 2. Map the source

- **Every source item lands in exactly one place:** a draft, a Skip rule, a cleanup line, or "Already in Jira". Never drop an item silently.
- **Dedupe against Jira** with JQL, by text and inside the target epics. The drift goes both ways: the source can list done work, and Jira can show Done for work that did not finish. Reopen a Done epic before new work goes in — ask first.
- **Group into epics.** A new epic needs 1–2 sentences only.
- **Short form for backlog tasks:** 2–3 sentences, then 2–4 checkable DoD bullets. The full form in `SKILL.md` is for work that starts now.
- **Voice:** write every draft as `${CLAUDE_PLUGIN_ROOT}/references/voice.md` says, and run its checklist before the user reads the doc.
- **An existing ticket the scope touches:** write its action — a description, a priority, a parent move, a cancel. Its priority and status stay unless the plan says otherwise.
- **Order the iterations by dependency.** An epic that other tickets move into goes first.

## 3. Run one iteration

1. **Gate:** every ⚠ in this iteration is resolved. Else stop and ask.
2. **Delegate** to one subagent. Give it the Rules block and the iteration's section verbatim. Tell it to:
   - create the epic if it is new, then the tasks under it, with the drafted text unchanged;
   - set each status that is not To Do with a transition;
   - apply the moves, priorities and cancels of a cleanup section;
   - return a table: title → key.

   The create calls return big payloads; the subagent keeps them out of this session.
3. **Write each key** into its `Key:` field, and set the iteration's State to done.
4. **Report** the epic links (`https://<site>/browse/<KEY>`) and the task titles with their keys — not keys alone.
5. **Stop.** The user checks Jira before the next iteration.

A re-run of an iteration skips each draft that already has a key.
