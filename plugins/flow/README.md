# flow

Plan and ship features as vertical slices through one living doc.

`/dd:flow:look` goes ahead of the work: background agents read the primary
sources — official docs, specs, the code itself — and come back with cited
findings, or a menu of options and their costs. A bounded check lands in the
chat; groundwork for a feature lands in `~/.context/` as the doc's first notes.

`/dd:flow:spec` keeps the durable half: `docs/design/<domain>.md` in the repo —
how a domain works, why, and what was rejected. Decisions get promoted there
when a slice ships, so the context doc can be deleted and the next feature's
session starts from what's already settled.

`/dd:flow:backfill` bootstraps that spec for a repo that already has the code
and none of the writing. It frames the domains as slices and hands them to
`go` — one domain per session, one PR each. Agents read the code and git
history, and write only what they can observe or cite; the reasons they can't
source come back to you as questions. Explicit invocation only.

`/dd:flow:seed` hands the session off before a `/clear`: it audits the doc
against the chat, folds in whatever got settled after the last write, and prints
the seed block for the next session.

`/dd:flow:go` carries a fixed method so you don't re-explain it every feature:
frame the work into a single doc in `~/.context/` (outside the project repo),
`/clear`, then build one complete, working layer ("a go") at a time — each a
reviewable ≤1k-line PR, folded back into the doc, `/clear` again for the next.
