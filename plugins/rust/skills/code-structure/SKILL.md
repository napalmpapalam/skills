---
name: dd:rust:code-structure
description: Rust project structure, code style, visibility, function design, and naming rules. Use whenever organizing Rust modules, deciding on file layout, setting up workspaces, choosing visibility modifiers, refactoring functions to be shorter or flatter, naming functions/types/modules/traits/constants, choosing between as_/to_/into_ prefixes, or when the user asks about project structure, module organization, idiomatic Rust code style, or naming conventions.
---

# Rust Code Structure & Naming Rules

## Project layout
- Organize by feature/domain, not by type (no `controllers/`, `models/` dirs)
- `main.rs` is a thin entry point — all logic in `lib.rs` for testability
- Use workspaces for multi-crate projects (shared `Cargo.lock`, build cache)
- All dependencies in root `[workspace.dependencies]`, sub-crates use `{ workspace = true }`

## File and module rules
- Keep files <200 lines, focused on one concern
- Re-export key types from module root with `pub use`
- Default to private — expose only what's needed. Minimal `pub` surface
- Use `pub(crate)` for internal sharing, `pub(super)` for parent-only access
- Prefer file-per-module (`foo.rs`) over `foo/mod.rs` — cleaner, less nesting
- Use `foo/mod.rs` only when the module has submodules
- Module names are `snake_case` — match the file name exactly

## Code style
- **No `match` when combinators work** — prefer `.map()`, `.and_then()`, `.unwrap_or()`, `?` over match blocks
- **Functional over imperative** — prefer `.filter()`, `.map()`, `.fold()` over `for` loops
- **Flat over nested** — invert conditions with early `return`/`continue`/`break` (guard clauses). Less nesting = easier to read
- **Avoid `else`** — almost never needed. Use early `return`/`continue` instead. `else` adds nesting and cognitive load. Rare exceptions are fine, but default to no `else`
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
