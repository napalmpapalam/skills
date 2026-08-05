---
name: dd:rust:core
description: The Rust conventions that apply to almost every edit — type design, error handling, ownership, async/tokio, module layout, comments and doc comments, code style, and naming. Use whenever writing, changing, or reviewing Rust code, designing types or error enums, dealing with borrows and lifetimes, writing async/tokio code, organizing modules or workspaces, choosing visibility, writing or shortening comments, doc comments, and module headers, refactoring functions to be shorter or flatter, naming anything, or when the user asks about idiomatic Rust. This is the default Rust skill — load it first; reach for serde, testing, linting, or performance on top of it when the task calls for them.
---

# Rust Core Rules

The conventions that govern essentially every Rust edit. Topic skills stack on top:
`dd:rust:serde`, `dd:rust:testing`, `dd:rust:linting`, `dd:rust:performance`.

## Type system

- Wrap IDs in newtypes to prevent parameter confusion: `struct UserId(u64)`
- Validated newtypes: enforce invariants at construction — "parse, don't validate"
- `#[repr(transparent)]` for FFI-safe newtypes
- Use enums for mutually exclusive states — make invalid states unrepresentable
- Use `Option<T>` for nullable values — compiler forces `None` handling
- Add trait bounds on `impl` blocks, not struct definitions
- Use `where` clauses for complex multi-bound signatures
- No stringly-typed APIs — replace string params with enums, newtypes, or validated types
- Parse strings at boundaries (`FromStr`), work with types internally
- Implement `From`/`TryFrom` for type conversions instead of ad-hoc `fn convert_x_to_y()` / transformer helpers — you get `Into`/`TryInto` for free and standard call sites (`.into()`, `x.try_into()?`)
- Use `From` for infallible conversions, `TryFrom` (with an error type) when conversion can fail — never a bespoke function returning `Result` for what `TryFrom` models
- Add `#[must_use]` on builder methods and functions returning values that should not be ignored
- Use sealed traits to prevent external implementations: public trait + private supertrait in a `private` module
- Use marker types (zero-sized structs) for type-state patterns: `struct Locked;` `struct Unlocked;` — encode state transitions in the type system

## Error handling

- Return `Result<T, E>` for all fallible operations — propagate with `?`
- No `unwrap()`, `expect()`, or `panic!()` — enable `clippy::unwrap_used` and `clippy::expect_used`
- Libraries: `#[derive(thiserror::Error)]` enums for typed, matchable errors
- Applications: `anyhow::Result` with `.context()` / `.with_context()` for flexible error chains
- Use `#[from]` for automatic `From` impl + source chain
- Use `#[source]` when you need extra context fields alongside the cause
- Always add `.context()` / `.with_context()` at call sites for runtime context
- Convert error types with `.map_err(Error::from)` or `?` (via `#[from]`), not a `match` that rewraps each variant
- Log errors at the handling site, not the creation site — use `tracing::error!` where you decide what to do with the error, not where you propagate it with `?`
- For custom context on errors: `.with_context(|| format!("failed to process {id}"))` — lazy formatting avoids cost on success path

## Ownership

- Borrow `&T` over `.clone()` — clone only when storing data or sending across threads
- Accept `&str` not `&String`, `&[T]` not `&Vec<T>`, `&Path` not `&PathBuf`
- Rely on lifetime elision; add explicit lifetimes only when ambiguous. Use `'_` for inferred
- Use `Rc` in single-thread code, `Arc` only when crossing thread boundaries
- Use `Cow<'_, T>` when mutation is rare — zero-cost when no modification needed
- `RefCell<T>` single-thread, `Mutex<T>` multi-thread. Consider `parking_lot::Mutex` for no poisoning
- `RwLock` for read-heavy workloads; switch to `Mutex` if writes >20%
- Derive `Copy` on small types (≤16 bytes) with no `Drop`
- Use `clone_from()` to reuse existing allocations
- Keep `.clone()` calls explicit and visible — they signal heap allocation cost
- Beware temporary lifetime extension — `let x = &temp().field;` may not live long enough. Bind the temporary first: `let tmp = temp(); let x = &tmp.field;`
- Reborrowing: `&*ref` or `&mut *ref` reborrows instead of moving — useful for passing `&mut` to functions without losing ownership of the mutable reference

## Async

- Use `tokio` runtime: multi-thread for servers, `current_thread` for CLIs
- `spawn_blocking()` for CPU-heavy or sync I/O operations (>1ms)
- Use `tokio::fs` not `std::fs` in async code
- `join!` / `try_join!` for independent futures — fail-fast on first error
- `JoinSet` for dynamic task collections — auto-aborts remaining on drop
- `select!` for racing futures: timeouts, cancellation, fallbacks
- `CancellationToken` from `tokio_util` for hierarchical graceful shutdown
- Limit concurrency with `Semaphore` or `buffer_unordered()`
- Always use bounded `mpsc` — unbounded grows without limit
- Embed `oneshot::Sender` in request structs for reply patterns
- Use `watch` channel for config/status where slow receivers skip to latest
- **Never hold locks across `.await`** — clone data out, release lock, then await
- Use `tokio::sync::Mutex` in async code, not `std::sync::Mutex`
- Handle `JoinHandle` errors — `spawn` returns `JoinHandle<T>`, `.await` returns `Result<T, JoinError>`. Always handle the `JoinError` (task panicked or was cancelled)
- Use `tokio_stream::StreamExt` for async iteration — `.next().await`, `.map()`, `.filter()`, `.take()`
- For trait objects returning futures: `-> Pin<Box<dyn Future<Output = T> + Send>>` — required because async fn in traits is not yet fully stable in all contexts

## Project layout

- Organize by feature/domain, not by type (no `controllers/`, `models/` dirs)
- `main.rs` is a thin entry point — all logic in `lib.rs` for testability
- Use workspaces for multi-crate projects (shared `Cargo.lock`, build cache)
- All dependencies in root `[workspace.dependencies]`, sub-crates use `{ workspace = true }`

## Files and modules

- Keep files <200 lines, focused on one concern
- Re-export key types from module root with `pub use`
- Default to private — expose only what's needed. Minimal `pub` surface
- Use `pub(crate)` for internal sharing, `pub(super)` for parent-only access
- Prefer file-per-module (`foo.rs`) over `foo/mod.rs` — cleaner, less nesting
- Use `foo/mod.rs` only when the module has submodules
- Module names are `snake_case` — match the file name exactly

## Comments

Default to **less** — well-named code beats a comment. But a workspace with `missing_docs = "warn"` and rustdoc under `-D warnings` needs a doc on every public item, so shorten them, never delete them.

The failure to avoid is the **comment poem**: a prose block above a file or function, explaining the design to nobody.

- **Budget:** `//!` module header — 1 line. `///` item doc — 1 line. `//` inline — 1–3 lines.
- **Never write a comment longer than the code it describes.**
- **Obvious → omit.** `/// Returns the config.` on `fn config()` is noise. A public item still needs one line, so make it say what the name doesn't.
- **`///`, one line by default** — say *what it is* / *what it returns*, not how it works. The signature already shows the types; don't restate them. Struct fields get a short line each, not a paragraph.
- Add a second paragraph **only** for a non-obvious invariant, precondition, or rationale. Rationale that merely sounds insightful is still a poem — cut it.
- **No `# Arguments` / `# Returns`** sections restating the signature. Keep `# Errors` / `# Panics` / `# Safety` only when the behavior is non-obvious.
- **`//!` is one line: what the module is.** No architecture essays, no cross-module narration. Design rationale lives in a design doc (`~/.context/`, `docs/`), not the file head. A thin module the name already explains (a CLI subcommand, a re-exporting `mod.rs`) can skip it.
- **Delete `//` that restate the code.** `// increment the counter` above `count += 1` is noise. Keep a `//` only for a non-obvious *why*: a workaround, a subtle ordering requirement, a spec reference, a deliberate deviation. If it explains *what* a block does, extract a well-named function instead.
- **Reviewing existing code:** collapse multi-paragraph docs to one line unless the extra text records a real invariant, shrink `//!` headers to one line, strip restating `//`. Never strip a public item's doc to nothing — that breaks the `missing_docs` gate.

```rust
// Too much — restates the type, over-explains an internal alias
/// A boxed, thread-safe error cause — what a [`PolicyStoreError`] carries as its
/// source, kept whole so the backend's error chain survives to the log site.
type BoxError = Box<dyn StdError + Send + Sync + 'static>;

// Enough
/// Boxed error cause carried by [`PolicyStoreError`], kept whole for the log site.
type BoxError = Box<dyn StdError + Send + Sync + 'static>;
```

```rust
// Too much — a 4-line doc on a 3-line function
/// The centered, capped column text renders into — CSS `max-width` + `margin: 0 auto`.
///
/// An odd gutter's remainder goes right, so the column doesn't jitter as the pane resizes.
/// Highlights live inside this rect; chrome (border, footer) spans the pane.
pub fn content_column(area: Rect) -> Rect {

// Enough — the jitter rule is the one thing the signature can't show
/// Centered, width-capped column for text. An odd gutter's remainder goes right, so the
/// column doesn't jitter on resize.
pub fn content_column(area: Rect) -> Rect {
```

```rust
// Too much — a 9-line design essay at the top of every file
//! The policy persistence contract.
//!
//! [`PolicyStore`] is the seam between the engine and durable storage: the crate
//! only *defines* it, the binary implements it over the Postgres pool ...
//! (six more lines)

// Enough
//! Policy persistence contract — [`PolicyStore`], implemented over Postgres by the binary.
```

## Code style

- **No `match` when combinators work** — prefer `.map()`, `.and_then()`, `.unwrap_or()`, `?` over match blocks. A `match` whose arms only log and return the same value is the most common offender: `.inspect_err()` logs the error, `.ok()?` drops it, `.or_else()` logs the empty case. If the function returns `()` and `?` is unavailable, use `let ... else` — not a `match`.

```rust
// Nested — three arms, two of them just log
match ctx.upstream.pick_snark().await {
    Ok(Some(payload)) => Some(payload),
    Ok(None) => {
        tracing::debug!("no SNARK job upstream");
        None
    }
    Err(err) => {
        tracing::warn!(error = %format_args!("{err:#}"), "failed to collect a SNARK job");
        None
    }
}

// Flat — same three cases, no nesting
ctx.upstream
    .pick_snark()
    .await
    .inspect_err(|err| {
        tracing::warn!(error = %format_args!("{err:#}"), "failed to collect a SNARK job");
    })
    .ok()?
    .or_else(|| {
        tracing::debug!("no SNARK job upstream");
        None
    })
```

Keep the `match` when arms do real work, bind different variables, or the compiler's exhaustiveness check is the point (matching a state enum).
- **Functional over imperative** — prefer `.filter()`, `.map()`, `.fold()` over `for` loops
- **Flat over nested** — invert conditions with early `return`/`continue`/`break` (guard clauses). Less nesting = easier to read
- **Avoid `else`** — almost never needed. Use early `return`/`continue` instead. `else` adds nesting and cognitive load. Rare exceptions are fine, but default to no `else`
- **One `use` per crate** — merge everything from the same crate into a single braced import, then group `std` / external / local with a blank line between. Stable `rustfmt` cannot do this (`imports_granularity` is nightly-only), so write it merged by hand and keep it that way when adding an import.

```rust
// Scattered — four lines, two crates
use std::future::Future;
use std::sync::Arc;
use jobs::SnarkRun;
use jobs::dto::SnarkJobPayload;

// Merged — one use per crate, grouped std / external / local
use std::{future::Future, sync::Arc};

use jobs::{SnarkRun, dto::SnarkJobPayload};
use tokio_util::sync::CancellationToken;

use crate::context::Context;
```

- **Short functions** — extract into smaller fns even if used once. Reduce cognitive load
- **Max 3-4 function arguments** — group into a config/params struct. Never `#[allow(clippy::too_many_arguments)]`

## Modularity

- Rule of three before generalizing — don't over-abstract
- No speculative generics — start concrete, generalize when justified
- Three similar lines > premature abstraction

## Naming

- Treat acronyms as single words: `HttpServer`, `JsonParser` — not `HTTPServer`
- `as_` = free borrow (O(1)), `to_` = allocates/computes, `into_` = consumes self
- No `get_` prefix for simple field accessors — use `fn name(&self) -> &str`
- Reserve `get_` for lookups, bounds checks, fallible operations
- Implement the iterator trio: `iter()` → `&T`, `iter_mut()` → `&mut T`, `into_iter()` → `T`
- Name iterator types to match source method: `iter()` → `Iter`, `keys()` → `Keys`

### Traits

- Trait names are `CamelCase` — describe capability, not implementation
- Prefer `-able` suffix for capabilities: `Readable`, `Parseable`, `Connectable`
- Use `Is-`/`Has-` only for marker traits: `IsEmpty`, `HasId`
- Avoid generic names like `Handler` or `Processor` — be specific: `RequestHandler`, `EventProcessor`

### Constants and type aliases

- Constants and statics use `SCREAMING_SNAKE_CASE`: `const MAX_RETRIES: u32 = 3`
- Type aliases use `CamelCase`: `type Result<T> = std::result::Result<T, MyError>`

### Feature flags

- Feature names use `kebab-case` in `Cargo.toml`: `my-feature`
- Prefix optional dependency features: `serde`, `tokio-runtime`
- Group related features: `full` = enables everything, `default` = minimal useful set
