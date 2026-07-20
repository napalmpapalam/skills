---
name: dd:ts:error-handling
description: TypeScript error handling — custom error class hierarchies, throwing vs returning, assertions, instanceof narrowing, and mapping transport errors to domain errors. Use whenever writing code that can fail, designing error classes, adding try/catch, replacing bare throws, narrowing caught errors, or when the user asks about error types, error propagation, assertions, or how to surface failures from a library.
---

# TypeScript Error Handling

**Throw. No `Result<T, E>` type.** `async`/`await` + `try`/`catch` is the ecosystem's failure channel; a `Result` type fights every library you call and every consumer you have. The discipline comes from *typed error classes*, not from the return type.

## The class shape

Every package ships its own errors. The identifying idiom:

```ts
export class RuntimeError extends Error {
  public name = 'RuntimeError'
  public originalError?: Error

  constructor(message: string, originalError?: Error) {
    super(message)
    this.originalError = originalError
  }
}
```

**`public name = 'X'` as a field, not `this.name = 'X'` in the constructor.** With `useDefineForClassFields: true` the field initializer runs after `super()`, so it reliably wins — and it's one line instead of two.

## Hierarchy: one rich base, thin leaves

The base carries the data. Subclasses carry only identity.

```ts
export class JsonApiError extends Error {
  private readonly original: FetcherError<JsonApiResponseErrors>
  private readonly meta: JsonApiErrorMeta
  // getters expose them read-only
}

export class NotFoundError extends JsonApiError {
  public name = 'NotFoundError'
  constructor(originalError: FetcherError<JsonApiResponseErrors>) {
    super(originalError)
  }
}
```

Consumers get `catch (e) { if (e instanceof NotFoundError) … }` without a status-code lookup table. That's the whole reason the leaves exist.

## Map transport errors to domain errors in one place

One `switch` with a `default`, at the boundary — not scattered `if (status === 404)` checks:

```ts
export const parseJsonApiError = (error: FetcherError<JsonApiResponseErrors>): JsonApiError => {
  switch (error.httpStatus) {
    case HTTP_STATUS_CODES.NOT_FOUND: return new errors.NotFoundError(error)
    case HTTP_STATUS_CODES.CONFLICT:  return new errors.ConflictError(error)
    default:                          return new errors.InternalServerError(error)
  }
}
```

## Narrow, then rethrow

Handle what you recognize; pass the rest through untouched.

```ts
} catch (e) {
  if (e instanceof FetcherError) {
    throw parseJsonApiError(e as FetcherError<JsonApiResponseErrors>)
  }
  throw e
}
```

**`catch (e)` is `unknown`.** Never assume `e.message` — narrow with `instanceof` first. Never `catch (e: any)`.

Preserve the cause. Either a dedicated field (`originalError`) or the standard `new Error(msg, { cause: e })`. **Losing the original error is the single most expensive mistake in this file.**

## Built-in `TypeError` for programmer errors

Bad arguments, malformed input from the caller, unsupported shapes — these are bugs in the calling code, not domain failures. Use `TypeError` rather than minting a class:

```ts
throw new TypeError("Fetcher: query parameters can't have nested objects.")
```

**Prefix every message with the package name.** `Fetcher: …`, `JsonApi: …`, `Time: …`. When it surfaces in a consumer's console three layers deep, the prefix is what makes it actionable.

## `assert()` over `if (…) throw`

A shared assertion keeps guards to one line and narrows the caller:

```ts
export function assert(expression: boolean, message: string): asserts expression {
  if (!expression) throw new RuntimeError(message)
}

assert(decimals >= 0, 'BN: decimals must be non-negative')
```

Domain-specific assertions live in their own module (`assertDecimals`, `assertDecimalsInteger`) rather than as inline conditions repeated across files.

## Never swallow

No empty `catch {}`. Deliberate suppression must be visible and justified:

- Return an explicit `false` from a parser that's expected to fail — with a comment saying why.
- `console.warn(e)` when degrading is correct. `no-console` allows `warn` and `error` only, so this is the ceiling.

Anything else propagates.

## Async

- **Every promise is awaited or explicitly handled.** A floating promise loses its rejection.
- Don't `try`/`catch` around a whole function body to "add context" — wrap the one call that can fail.
- `Promise.all` rejects on the first failure; use `Promise.allSettled` when partial success is meaningful.
