---
name: dd:ts:async
description: TypeScript async patterns — parallel vs sequential awaits, cancellation with AbortController, timeouts, floating promises, and async class design. Use whenever writing async/await code, deciding between Promise.all and a sequential loop, adding cancellation or timeouts to requests, debugging unhandled rejections, or when the user asks about concurrency, aborting in-flight work, or async pitfalls in TypeScript.
---

# TypeScript Async

## Parallel by default

Independent work runs concurrently. Sequential `await` in a loop is a bug unless the order matters.

```ts
// No — serializes N round trips
const users = []
for (const id of ids) users.push(await fetchUser(id))

// Yes
const users = await Promise.all(ids.map(id => fetchUser(id)))
```

**`for…of` with `await` is correct only when each step depends on the previous one** — an interceptor chain that threads the request through, a paginated cursor walk:

```ts
for (const interceptor of this.interceptors) {
  if (interceptor.request) req = await interceptor.request(req)
}
```

| Situation                        | Use                   |
| -------------------------------- | --------------------- |
| independent, all must succeed    | `Promise.all`         |
| independent, partial ok          | `Promise.allSettled`  |
| first to finish wins             | `Promise.race`        |
| each step feeds the next         | `for…of` + `await`    |

## No floating promises

Every promise is `await`ed, `return`ed, or explicitly `.catch()`ed. A dropped promise turns a rejection into an unhandled crash with no stack pointing at your code.

- `return promise` — don't `return await promise` except inside `try`/`catch`, where you need the rejection caught locally.
- Fire-and-forget needs a visible `void promise.catch(handleIt)`, never a bare call.

## Cancellation

**Anything that does I/O takes an `AbortSignal`.** Not optional in a library — consumers can't add cancellation you didn't expose.

Keep controllers in a small manager keyed by request id rather than scattering them:

```ts
export class FetcherAbortManager {
  private readonly controllers = new Map<string, AbortController>()

  public setSafe(requestId?: string): AbortSignal | null {
    if (!requestId) return null
    return this.set(requestId).signal
  }

  public abort(requestId?: string): boolean {
    const id = requestId ?? ''
    if (!id || !this.has(id)) return false
    …
  }
}
```

Note the `setSafe` shape — tolerating an absent id at the boundary keeps `if (opts.requestId)` branches out of the caller.

**Always clear the entry after the request settles**, in a `finally`. A manager that only grows is a leak.

## Timeout is abort-on-timer

Don't race a `setTimeout` promise against the work — that leaves the work running.

```ts
const timeoutId = setTimeout(() => this.abortManager.abort(id), this.cfg.timeout)
try {
  return await fetch(config.url, config)
} finally {
  clearTimeout(timeoutId)
}
```

`clearTimeout` in `finally`, always — a dangling timer keeps the process alive in Node.

## Async and classes

- **No async constructors.** Construction is synchronous; use a `static async create(…)` factory when setup needs I/O.
- **No async getters.** A getter that returns a promise reads like a value and isn't one — make it a method.
- Async methods declare `Promise<T>` explicitly, like every other return type.

## Pitfalls

- **`.forEach` with an async callback doesn't await anything.** Use `Promise.all(xs.map(…))` or `for…of`.
- **`await` inside `.filter`** doesn't work — the predicate gets a promise, which is truthy. Map to `[item, ok]` pairs first, then filter.
- **Don't mix `.then()` and `await`** in one function. Pick `await`.
- **`Promise.all` on a huge array** opens every connection at once. Chunk it, or use a concurrency limiter.
- **A rejected promise created before it's awaited** can fire an unhandled-rejection warning in the gap. Create and await in the same expression.
