# english

Light English-grammar coaching on every prompt. A `UserPromptSubmit` hook injects `coach.md` into each turn; Claude appends a short `✍️ English:` correction **only when your prompt has a real mistake**, always after the actual answer.

- **No extra cost** — the check happens inside the normal turn, no second model call.
- **Low noise** — silent when your prompt is clean or just casual shorthand (`u`, `gimme`, `coz`).
- **Brief** — one corrected line plus a ≤6-word note on what changed.

## Hook

`UserPromptSubmit` (matcher `*`) → `cat coach.md`. Edit `coach.md` to change the coaching style (e.g. switch from brief notes to explained corrections).
