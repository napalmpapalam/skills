# rust

Rust conventions and best practices. Six convention skills auto-trigger while you write Rust; a seventh is an explicit review command. Two hooks nudge Claude toward the conventions, both gated on the project being Rust: a `SessionStart` hook, and a `UserPromptSubmit` hook that re-injects the reminder every turn.

## Skills

Auto-triggered (loaded on demand when the task matches):

- `dd:rust:core` — the default: types, error handling, ownership, async, module layout, code style, naming.
- `dd:rust:comments` — concise comments and doc comments, short module headers.
- `dd:rust:linting` — workspace lints, clippy enforcement, formatting.
- `dd:rust:performance` — iterators, release profiles, inlining, allocation profiling.
- `dd:rust:serde` — derive patterns, snake_case defaults, enum representations, zero-copy.
- `dd:rust:testing` — unit/integration layout, mocking, property/snapshot testing.

`core` carries what applies to almost every Rust edit; the other five are conditional and stack on top. It was merged out of five skills (`async`, `code-structure`, `error-handling`, `ownership`, `type-system`) because the nudge hook goes quiet after the *first* skill loads — so that one skill has to be the one that covers the edit. Five 20-line skills meant a session could load `async`, fall silent, and write a whole new module with no layout, naming, or error rules in context.

Command-only (`disable-model-invocation`):

- `/dd:rust:review` — run cargo checks, load every convention skill, review the diff, emit a structured report.

## Hooks

- `SessionStart` (`startup|clear|compact`): when the session opens in a Rust project (a `Cargo.toml` in cwd or any ancestor), injects a one-line note that the `dd:rust:*` conventions govern all Rust — including reasoning about hypothetical changes, not just edits.
- `UserPromptSubmit`: in a Rust project, tells the model that no `dd:rust:*` skill is loaded and it must call one. It greps the live transcript (`transcript_path`, a common hook input) for a real `Skill` call and **goes silent once one lands** — so it costs nothing for the rest of the session.

  The message states the fact rather than making a request: the skill bodies are not in context until `Skill` is called, so the model does *not* know these conventions. An earlier version politely asked to "load the matching skill" and was ignored 20 times in one session while 18 `.rs` files were edited.

Both write plain stdout, which `SessionStart` and `UserPromptSubmit` add as context the model reads. They never gate or auto-approve a tool call.

> This was previously a `PreToolUse` hook on `Write|Edit` emitting `{"systemMessage": …}`. That never reached Claude: `systemMessage` is only shown to the user, and `PreToolUse` cannot return `additionalContext` at all.
