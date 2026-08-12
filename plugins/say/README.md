# say

Manual commands that re-steer how Claude explains something. Nothing here is
model-invoked — the trigger is a state in your head, not a signal in the text,
so you press it yourself.

`/dd:say:what` — "say what?". The last message did not land. Claude finds the
step it assumed you already had, starts from there instead, gives one concrete
example with real values, and writes in ASD-STE100 Simplified Technical English
(short active sentences, one meaning per word, no idioms) — while keeping every
technical term exact.

Complements the `rules` plugin: `rules` sets the default register on every
session, `say` overrides it on demand.
