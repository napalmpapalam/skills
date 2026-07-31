# rules

Global house rules injected into every session.

Two hooks, no skill or command to invoke — the rules are just always active:

| Hook | File | Why |
| --- | --- | --- |
| `SessionStart` | `rules.md` | The full rule set, once per session. |
| `UserPromptSubmit` | `brevity.md` | A short length check, re-injected every turn — a one-shot `SessionStart` rule gets buried by the transcript in a long session. |

Add rules by editing `rules.md`. Keep `brevity.md` under ~10 lines; it costs tokens on every prompt.
