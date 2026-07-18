---
name: dd:rust:comments
description: Rust comment and doc-comment style — keep them concise, explain why not what, short module headers. Use whenever writing or reviewing comments or doc comments in Rust, adding module headers (//!), documenting public items or functions, or when the user asks about comment style, doc-comment length, rustdoc, or reducing comment noise.
---

# Rust Comment Rules

Default to **less**. Well-named code beats a comment. But note: this workspace sets `missing_docs = "warn"` and CI runs rustdoc with `-D warnings`, so **every public item must keep a doc comment** — make it concise, never delete it.

## Doc comments (`///`)

- **One line by default** — say *what it is* / *what it returns*, not how it works. The signature already shows the types; don't restate them.
- Add a second paragraph **only** for a non-obvious invariant, precondition, or rationale that a reader genuinely needs. If it's obvious from the name, cut it.
- **No `# Arguments` / `# Returns` sections** that just restate the signature. Keep `# Errors` / `# Panics` / `# Safety` only when the behavior is non-obvious.
- Don't narrate cross-module architecture in an item's doc — that belongs in a design doc, not the code.

```rust
// Too much — restates the type, over-explains an internal alias
/// A boxed, thread-safe error cause — what a [`PolicyStoreError`] carries as its
/// source, kept whole so the backend's error chain survives to the log site.
type BoxError = Box<dyn StdError + Send + Sync + 'static>;

// Enough
/// Boxed error cause carried by [`PolicyStoreError`], kept whole for the log site.
type BoxError = Box<dyn StdError + Send + Sync + 'static>;
```

## Module headers (`//!`) — the "head" comment

- **One line: what the module is.** No architecture essays, no cross-module design narration, no seam-by-seam walkthroughs.
- If the design rationale is worth recording, it lives in a design doc (`~/.context/` or `docs/`), not the file head.

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

## Inline comments (`//`)

- **Delete comments that restate the code.** `// increment the counter` above `count += 1` is noise.
- Keep a `//` only for a non-obvious **why**: a workaround, a subtle ordering requirement, a spec/RFC reference, a deliberate deviation.
- If a comment is needed to explain *what* a block does, prefer extracting it into a well-named function instead.

## When reviewing existing code

- Collapse multi-paragraph docs to one line unless the extra text records a real invariant.
- Shrink `//!` headers to a single line.
- Strip restating `//` comments; keep the "why" ones.
- Never strip a public item's doc to nothing — that breaks the `missing_docs` / `-D warnings` CI gate.
