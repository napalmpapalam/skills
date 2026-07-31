# rust

Rust conventions and best practices. Nine convention skills auto-trigger while you write Rust; a tenth is an explicit review command. Two hooks nudge Claude toward the conventions, both gated on the project being Rust: a `SessionStart` hook, and a `UserPromptSubmit` hook that re-injects the reminder every turn.

## Skills

Auto-triggered (loaded on demand when the task matches):

- `dd:rust:async` — tokio runtime, concurrency, channels, async pitfalls.
- `dd:rust:code-structure` — project layout, modules, visibility, function design, naming.
- `dd:rust:comments` — concise comments and doc comments, short module headers.
- `dd:rust:error-handling` — Result/? patterns, thiserror vs anyhow, error chains.
- `dd:rust:linting` — workspace lints, clippy enforcement, formatting.
- `dd:rust:ownership` — borrowing, lifetimes, smart pointers, Cow.
- `dd:rust:performance` — iterators, release profiles, inlining, allocation profiling.
- `dd:rust:serde` — derive patterns, snake_case defaults, enum representations, zero-copy.
- `dd:rust:testing` — unit/integration layout, mocking, property/snapshot testing.
- `dd:rust:type-system` — newtypes, enums, generics, parse-don't-validate.

Command-only (`disable-model-invocation`):

- `/dd:rust:review` — run cargo checks, load every convention skill, review the diff, emit a structured report.

## Hooks

- `SessionStart` (`startup|clear|compact`): when the session opens in a Rust project (a `Cargo.toml` in cwd or any ancestor), injects a one-line note that the `dd:rust:*` conventions govern all Rust — including reasoning about hypothetical changes, not just edits.
- `UserPromptSubmit`: in a Rust project, re-injects a one-line reminder to load the matching `dd:rust:*` skill — every turn, so it still holds late in a long session.

Both write plain stdout, which `SessionStart` and `UserPromptSubmit` add as context the model reads. They never gate or auto-approve a tool call.

> This was previously a `PreToolUse` hook on `Write|Edit` emitting `{"systemMessage": …}`. That never reached Claude: `systemMessage` is only shown to the user, and `PreToolUse` cannot return `additionalContext` at all.
