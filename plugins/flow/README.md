# flow

Plan and ship features as vertical slices through one living doc.

`/dd:flow:go` carries a fixed method so you don't re-explain it every feature:
build one complete, working layer ("a go") at a time (each a reviewable ≤1k-line
PR), fold what you learned back into a single doc in `~/.context/` (outside the
project repo), then `/clear` and start the next slice from that doc.
