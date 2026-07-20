---
name: dd:ts:code-style
description: TypeScript control flow and function style — flat code, guard clauses, no else, no for loops, functional array methods. Use whenever writing or refactoring TypeScript functions, reducing nesting, replacing if/else chains or loops, choosing between switch and ternary, handling defaults, or when the user asks about control flow, functional style, code readability, or flattening deeply nested code.
---

# TypeScript Control Flow & Functions

Three rules carry most of the weight: **max 2 nesting levels**, **no `else`**, **no `for`**.

## Flat over nested

**Two levels of nesting is the ceiling.** Past that, extract a function. Deep nesting is always a sign that one function is doing several jobs.

Invert conditions and return early. Guard clauses go at the top, one line each, no braces when the body is a single statement:

```ts
public setSafe(requestId?: string): AbortSignal | null {
  if (!requestId) return null
  return this.set(requestId).signal
}
```

Three consecutive one-line guards beats one nested `if` tree.

## No `else`

`else` and `else if` are effectively banned. Every `else` is a nesting level you didn't need.

```ts
// No
function classify(n: number): string {
  if (n < 0) {
    return 'negative'
  } else if (n === 0) {
    return 'zero'
  } else {
    return 'positive'
  }
}

// Yes
function classify(n: number): string {
  if (n < 0) return 'negative'
  if (n === 0) return 'zero'
  return 'positive'
}
```

For a closed set of cases, use **`switch` with `return` per case** and a mandatory `default` — `noFallthroughCasesInSwitch` and `noImplicitReturns` enforce both:

```ts
switch (error.httpStatus) {
  case HTTP_STATUS_CODES.NOT_FOUND:
    return new errors.NotFoundError(error)
  case HTTP_STATUS_CODES.CONFLICT:
    return new errors.ConflictError(error)
  default:
    return new errors.InternalServerError(error)
}
```

For picking a **value** (not branching control flow), use a ternary. One level only — nested ternaries are as bad as `else`.

The rare legitimate `else`: dispatching a constructor overload where both branches assign the same variables. If you reach for it elsewhere, restructure.

## No `for` loops

No `for (let i = 0; ...)`. Ever. Use array methods:

| Task                     | Use                          |
| ------------------------ | ---------------------------- |
| transform                | `.map()`                     |
| select                   | `.filter()`                  |
| build an object          | `.reduce()`                  |
| flatten one level        | `.flatMap()`                 |
| min / max / aggregate    | `.reduce()`                  |
| side effect over entries | `Object.entries(x).forEach()`|

```ts
const normalizeHeadersCase = (headers: Record<string, string>) =>
  Object.entries(headers).reduce<Record<string, string>>(
    (acc, [k, v]) => ({ ...acc, [normalizeHeaderCase(k)]: v }),
    {},
  )
```

**`for…of` is allowed in exactly two cases**, because array methods can't express them:

1. **Sequential `await`** — where `.map()` + `Promise.all` would wrongly parallelize:
   ```ts
   for (const interceptor of this.#interceptors) {
     if (interceptor.request) req = await interceptor.request(req)
   }
   ```
2. **Early `break`** — take the first success and stop.

`while` is for genuine algorithms (Newton's method, prototype-chain walks), not for iterating collections.

## Defaults over branches

`??` and `||` replace whole `if` blocks:

```ts
const id = requestId ?? ''
return this.request<T>({ endpoint, method: HTTP_METHODS.GET, ...(opts || {}) })
```

Prefer `??` — it only catches `null`/`undefined`. Reach for `||` only when empty string and `0` should also fall through.

## Functions

- **Bodies are 1–10 lines.** Longer means extract.
- **Free functions are `export const fn = (…) => …` arrow consts with an explicit return type.** Use a `function` declaration only when you need hoisting, an assertion signature (`asserts x is T`), or a generic that reads badly as an arrow.
- **Module-private helpers are non-exported consts at the bottom of the file** — public surface first, machinery below.
- **More than 2 params → one options object.** Name it `opts` or `cfg`.
- **No side effects in a function named like a query.** `parseX` returns; it doesn't also write.
