---
name: dd:rust:performance
description: Rust performance — iterators, release profiles, inlining, cache layout, bounds checks, allocation profiling. Use whenever optimizing Rust code, choosing between iterators and loops, configuring release profiles, adding inline hints, profiling allocations, or when the user asks about performance patterns, benchmarking, or hot-path optimization in Rust.
---

# Rust Performance Rules

- Prefer iterators over manual indexing — enables bounds check elimination and SIMD
- Keep iterators lazy: chain `.filter()`, `.map()`, `.take()` — collect once at the end
- Use `.find()`, `.any()`, `.count()` instead of `.collect().first()` / `.collect().is_empty()`
- Avoid `chain()` in hot loops — branch prediction overhead on every `.next()`
- Use `extend()` / `extend_from_slice()` over repeated `push()`
- Use entry API for maps — single lookup instead of `contains_key` + `insert`
- `#[inline]` for small, frequently-called cross-crate functions
- `#[inline(always)]` only with profiling evidence
- `#[inline(never)]` for error handlers and cold paths
- Prefer Struct of Arrays over Array of Structs for hot loops
- Use contiguous `Vec` over linked structures — avoid pointer chasing
- Use `#[must_use]` on functions returning values that should not be ignored
- Profile allocations with DHAT (`dhat` crate) for unit-test-style profiling or `heaptrack` for full-program analysis
- Use `cargo bench` with `criterion` for reliable microbenchmarks — statistical analysis, outlier detection

## Release profile

```toml
[profile.release]
opt-level = 3
debug = false
lto = "fat"
codegen-units = 1
panic = "abort"
strip = true
overflow-checks = false
incremental = false
```
