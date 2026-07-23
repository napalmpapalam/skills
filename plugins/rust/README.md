# rust

Rust conventions and best practices. Nine convention skills auto-trigger while you write Rust; a tenth is an explicit review command. Two hooks nudge Claude toward the conventions: a `SessionStart` hook when the project is Rust, and a `PreToolUse` hook whenever it edits a `.rs` file.

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
- `PreToolUse` on `Write|Edit`: when the target file ends in `.rs`, injects a one-line reminder to apply the `dd:rust:*` conventions.

Both emit only a `systemMessage` — they never auto-approve anything.
