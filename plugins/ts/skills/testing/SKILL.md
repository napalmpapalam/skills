---
name: testing
description: TypeScript testing with bun test — file layout, describe/test naming, arrange-act-assert, fixtures and mocks, asserting errors. Use whenever writing or reviewing TypeScript tests, setting up a test runner, organizing test files or fixtures, mocking dependencies, asserting on thrown errors, or when the user asks about test structure, coverage, or testing patterns in a TypeScript project.
---

# TypeScript Testing

The `dd:ts:core` rules hold in tests too: paragraphs, DRY, no `any`, no `!`.

## Runner

`bun test` — built in, jest-compatible, no config file for the common case. It resolves the
tsconfig `paths`, so `@/` works in tests.

```ts
import { describe, expect, mock, test } from 'bun:test'
```

Vitest is the fallback when a project needs browser mode. Never jest in a new project.

## Layout

- **Colocate:** `foo.ts` and `foo.test.ts` side by side.
- **Shared fixtures live in `src/tests/`** behind a barrel, excluded from the build.
- **JSON mocks** go in `src/tests/mocks/*.json`, re-exported as SCREAMING_SNAKE constants.

## Shape

- **Nested `describe`:** the outer one names the unit, the inner one names the member.
  `test('should …')` reads as a sentence in the runner output.
- **Arrange, act, assert are three paragraphs** — a blank line between them.
- **One behavior per test.** Two behaviors are two tests.
- **A table of cases is `test.each`**, not a copy of the test per input.

```ts
describe('serverFiles', () => {
  test('should override the L1 RPC URL', () => {
    const params = { ...PARAMS, l1_provider_rpc_url: 'http://localhost:8545' }

    const { env } = serverFiles(params, 'http://host.docker.internal:8545')

    expect(env).toContain('l1_provider_rpc_url=http://host.docker.internal:8545\n')
  })

  test.each([
    [75, '1m15s'],
    [5, '0m05s'],
  ])('should format %d seconds as %s', (seconds, text) => {
    expect(duration(seconds)).toBe(text)
  })
})
```

## What to test

- **The public surface only.** A test that reads private state locks in the implementation.
- **Every error path — assert the class, not the message.** Messages are copy; classes are the
  contract.

  ```ts
  expect(() => parseServerParams('{}')).toThrow(ZodError)
  await expect(runCommand('false', [])).rejects.toBeInstanceOf(CommandFailed)
  ```

- **Every zod schema:** one valid and one invalid case. That is where untrusted data enters.

## Mocking

- `mock(() => …)` for functions, `spyOn(obj, 'method')` for methods.
- **Mock at the boundary** — the process, the network, the clock, the filesystem. Do not mock
  your own modules; pass a test double in through the options or the constructor.
- **No mock state leaks between files.** Reset in `beforeEach` what you set up.

## Types in tests

Tests are type-checked with the same strict config as the source. No `any` to make a mock fit —
write a typed fixture factory. A type that is hard to build in a test tells you something about
the type.
