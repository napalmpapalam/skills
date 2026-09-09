# rules

Global house rules injected into every session.

Hooks only, no skill or command to invoke — the rules are just always active:

| Hook | File | Why |
| --- | --- | --- |
| `SessionStart` | `rules.md` | The full rule set, once per session. |
| `UserPromptSubmit` | `brevity.md` | A short length check, re-injected every turn — a one-shot `SessionStart` rule gets buried by the transcript in a long session. |
| `UserPromptSubmit` | `ste.md` | Simplified Technical English (ASD-STE100) sentence shape. Style has to hold on every sentence, so it rides the same per-turn channel as brevity. |

Add rules by editing `rules.md`. Keep `brevity.md` and `ste.md` under ~15 lines each; they cost tokens on every prompt.

`ste.md` is the always-on version of the `/dd:say:what` skill. That skill stays a one-shot corrective — invoke it to re-write a message that did not land.
