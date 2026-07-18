---
name: dd:rust:error-handling
description: Rust error handling — Result/? patterns, thiserror vs anyhow, error chains, combinators. Use whenever writing Rust code that can fail, designing error types, choosing between thiserror and anyhow, replacing unwrap/expect calls, adding error context, or when the user asks about error propagation, custom error types, or Result combinators.
---

# Rust Error Handling Rules

- Return `Result<T, E>` for all fallible operations — propagate with `?`
- No `unwrap()`, `expect()`, or `panic!()` — enable `clippy::unwrap_used` and `clippy::expect_used`
- Libraries: `#[derive(thiserror::Error)]` enums for typed, matchable errors
- Applications: `anyhow::Result` with `.context()` / `.with_context()` for flexible error chains
- Use `#[from]` for automatic `From` impl + source chain
- Use `#[source]` when you need extra context fields alongside the cause
- Always add `.context()` / `.with_context()` at call sites for runtime context
- Prefer combinators (`map`, `map_err`, `and_then`, `unwrap_or_default`) over nested `match` on `Option`/`Result`
- Convert error types with `.map_err(Error::from)` or `?` (via `#[from]`), not a `match` that rewraps each variant
- Log errors at the handling site, not the creation site — use `tracing::error!` where you decide what to do with the error, not where you propagate it with `?`
- For custom context on errors: `.with_context(|| format!("failed to process {id}"))` — lazy formatting avoids cost on success path
