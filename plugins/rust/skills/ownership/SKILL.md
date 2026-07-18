---
name: dd:rust:ownership
description: Rust ownership, borrowing, lifetimes, and smart pointer rules. Use whenever dealing with borrow checker errors, choosing between Clone and references, picking smart pointers (Rc/Arc/Box), working with lifetimes, or when the user asks about ownership patterns, Cow, interior mutability, or memory management in Rust.
---

# Rust Ownership Rules

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
