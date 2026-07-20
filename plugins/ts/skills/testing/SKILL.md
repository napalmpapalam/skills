---
name: dd:ts:testing
description: TypeScript testing with bun test — file layout, describe/test naming, fixtures and mocks, testing private state and error classes. Use whenever writing or reviewing TypeScript tests, setting up a test runner, organizing test files or fixtures, mocking dependencies, asserting on thrown errors, or when the user asks about test structure, coverage, or testing patterns in a TypeScript package.
---

# TypeScript Testing

## Runner

`bun test` — built in, jest-compatible API, no config file for the common case.

```ts
import { describe, expect, mock, test } from 'bun:test'
```

Path aliases come from `tsconfig.json` `paths`; bun resolves them natively, so there's no `moduleNameMapper` equivalent to maintain.

Vitest is the fallback if a project needs browser-mode or a plugin ecosystem bun lacks. Never jest in a new project.

## Layout

- **Colocate**: `foo.ts` and `foo.test.ts` side by side.
- **Import the unit under test relatively** (`./fetcher`), not through `@/` — a test should exercise the module, not the alias resolution.
- **Shared fixtures live in `src/tests/`** behind a barrel, excluded from the build via `tsconfig.build.json`.
- JSON mocks go in `src/tests/mocks/*.json` and are re-exported as SCREAMING_SNAKE consts:
  ```ts
  export { default as RAW_RESPONSE } from './mocks/json-api-response-raw.json'
  ```
- Mock builders are static-only classes: `MockWrapper.makeFetcherResponse<T>(data)`.

## Naming

Nested `describe`, outer names the unit, inner names the member:

```ts
describe('performs Fetcher unit test', () => {
  describe('performs constructor', () => {
    test('should set config', () => { … })
  })
})
```

`describe('performs …')` / `test('should …')`. The consistency matters more than the wording — a failing test name should read as a sentence in the runner output.

## What to test

- **The public surface only.** With `private` fields you *can* reach in via `obj['field']` — don't. A test that asserts on private state locks in the implementation and breaks on every refactor.
- **Every error path.** Assert the class, not the message:
  ```ts
  expect(() => parseUser(bad)).toThrow(TypeError)
  await expect(client.get('/missing')).rejects.toBeInstanceOf(NotFoundError)
  ```
  Messages are copy; classes are the contract.
- **Boundary parsing.** Every zod schema gets one valid and one invalid case — that's where untrusted data actually enters.
- **`use*` vs `with*`.** Assert that `with*` left the original untouched and `use*` returned the same instance. It's the easiest contract in the API to break silently.

## Mocking

- `mock(() => …)` for functions, `spyOn(obj, 'method')` for methods.
- **Mock at the boundary** — the `fetch` call, the clock, the filesystem. Don't mock your own classes; construct them with test doubles injected through the constructor. That's what composition-over-inheritance buys you.
- No global mock state leaking between files. Reset in `beforeEach` if you set anything up.

## Types in tests

Tests are type-checked with the same strict config as source. No `any` in a test to make a mock fit — build a correctly-typed fixture factory instead. If a type is awkward to construct in a test, that's information about the type.
