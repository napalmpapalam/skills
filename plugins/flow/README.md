# flow

Plan and ship features as vertical slices through one living doc.

`/dd:flow:seed` hands the session off before a `/clear`: it audits the doc
against the chat, folds in whatever got settled after the last write, and prints
the seed block for the next session.

`/dd:flow:go` carries a fixed method so you don't re-explain it every feature:
frame the work into a single doc in `~/.context/` (outside the project repo),
`/clear`, then build one complete, working layer ("a go") at a time — each a
reviewable ≤1k-line PR, folded back into the doc, `/clear` again for the next.
