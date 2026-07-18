---
name: dd:rust:async
description: Rust async rules with tokio — runtime, concurrency, channels, and pitfalls. Use whenever writing async Rust code, choosing between concurrency primitives, working with tokio tasks/channels/select, debugging deadlocks or cancellation issues, or when the user asks about async patterns, spawning tasks, or concurrent execution in Rust.
---

# Rust Async Rules

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
