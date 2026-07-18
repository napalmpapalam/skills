---
name: dd:rust:testing
description: Rust testing — unit/integration layout, mocking with mockall, async test patterns, property testing, snapshot testing. Use whenever writing or reviewing Rust tests, setting up test infrastructure, choosing mocking strategies, organizing test modules, debugging test failures, or when the user asks about testing patterns, coverage, or test utilities in Rust projects.
---

# Rust Testing Rules

- Unit tests: `#[cfg(test)] mod tests` inside each source module
- Allow `unwrap()`/`expect()` in test modules: `#[allow(clippy::unwrap_used, clippy::expect_used)]`
- Integration tests: `tests/` directory at crate root — each file is a separate binary, public API only
- Shared test utilities go in `tests/helpers/mod.rs`
- Descriptive names that explain behavior: `parse_returns_error_for_empty_input`
- Follow Arrange-Act-Assert — one assertion focus per test
- Use `#[tokio::test]` for async tests
- Extract dependencies behind traits for testability
- Use `mockall` with `#[automock]` to generate mock implementations

## Property-based testing
- Use `proptest` for input-space exploration — catches edge cases manual tests miss
- Define strategies for custom types: `prop_compose!` for complex generators
- Start with `proptest!` macro, not manual `TestRunner` — simpler and sufficient for most cases
- Combine with `assert!` / `assert_eq!` inside the closure — same assertion style as unit tests

## Snapshot testing
- Use `insta` for output-heavy assertions — serialized structs, CLI output, rendered templates
- `assert_snapshot!` for strings, `assert_json_snapshot!` / `assert_yaml_snapshot!` for structured data
- Review snapshots with `cargo insta review` — never commit without reviewing
- Use `#[with_settings(snapshot_suffix => "case_name")]` to distinguish parameterized snapshots

## Test fixtures and builders
- Use builder pattern for complex test data — `TestUser::builder().name("x").build()`
- Share setup via helper functions, not inheritance — Rust has no test base class
- `#[should_panic(expected = "message")]` for expected panics — match on substring
- `#[ignore]` for slow tests — run with `cargo test -- --ignored`

## Coverage
- Use `cargo-llvm-cov` for source-based coverage: `cargo llvm-cov --html`
- Aim for meaningful coverage, not 100% — untested error paths > tested trivial getters
