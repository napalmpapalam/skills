---
name: dd:rust:linting
description: Rust workspace lint configuration, clippy enforcement, and formatting rules. Use whenever setting up or modifying Cargo.toml lint configuration, configuring clippy or rustfmt, adding CI checks for Rust, or when the user asks about lint rules, formatting settings, or workspace-level lint inheritance.
---

# Rust Linting Rules

## Workspace lints (Rust 1.74+)

Configure once in root `Cargo.toml`, inherit everywhere. Each sub-crate adds `[lints] workspace = true`.

```toml
[workspace.lints.rust]
unsafe_code = "deny"
unused_must_use = "deny"
missing_docs = "warn"

[workspace.lints.clippy]
unwrap_used = "deny"
expect_used = "deny"
panic = "deny"
indexing_slicing = "deny"
cast_possible_truncation = "deny"
cast_sign_loss = "deny"
wildcard_imports = "deny"
needless_return = "deny"
semicolon_if_nothing_returned = "deny"
manual_flatten = "deny"
explicit_into_iter_loop = "deny"
cognitive_complexity = "warn"
needless_pass_by_value = "warn"
redundant_clone = "warn"
needless_collect = "warn"

[workspace.lints.rustdoc]
broken_intra_doc_links = "deny"
```

## Formatting (`rustfmt.toml`)

```toml
edition = "2021"
max_width = 100
tab_spaces = 4
imports_granularity = "Module"
group_imports = "StdExternalCrate"
```

- Use `#[rustfmt::skip]` only for generated code
- Run `cargo fmt --all` before committing

## CI checks

```sh
cargo fmt --all --check
cargo clippy --workspace --all-targets -- -D warnings
RUSTDOCFLAGS="-D warnings" cargo doc --workspace --no-deps
```
