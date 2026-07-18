---
name: dd:rust:type-system
description: Rust type system — newtypes, enums, generics, and type safety rules. Use whenever designing Rust types, creating newtypes or validated wrappers, modeling states with enums, adding trait bounds, replacing stringly-typed APIs, or when the user asks about type-level design, parse-don't-validate, generics, or making invalid states unrepresentable.
---

# Rust Type System Rules

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
