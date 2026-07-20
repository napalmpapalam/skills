# ts

TypeScript conventions for framework-agnostic libraries. Nine convention skills auto-trigger while you write TypeScript; a tenth is an explicit review command. A `PreToolUse` hook nudges Claude toward the conventions whenever it edits a `.ts` file.

The rules are reverse-engineered from [`distributed-lab/web-kit`](https://github.com/distributed-lab/web-kit) (`tools`, `jac`, `fetcher`, `reactivity`), with four deliberate departures from that codebase: **branded types** instead of plain aliases, **zod** at boundaries, **bun** instead of yarn, and **`private` instead of `#`**.

## Skills

Auto-triggered (loaded on demand when the task matches):

- `dd:ts:code-structure` — package layout, `src/` taxonomy, barrels, imports, naming.
- `dd:ts:code-style` — max 2 nesting levels, no `else`, no `for`, functional array methods, function design.
- `dd:ts:classes` — `private` over `#`, getters, static factories, immutability, `use*`/`with*`, composition.
- `dd:ts:type-system` — `type` not `interface`, branded types, unions vs enums, `unknown` never `any`, zod at boundaries.
- `dd:ts:error-handling` — error class hierarchies, `instanceof` narrowing, `assert()`, preserving causes.
- `dd:ts:async` — parallel vs sequential, `AbortController`, timeouts, floating promises.
- `dd:ts:tooling` — bun, tsconfig strict flags, eslint, prettier, workspaces, build and `exports`.
- `dd:ts:testing` — `bun test`, colocated files, fixtures, what to assert.
- `dd:ts:comments` — short TSDoc, why-not-what, no design essays in source.

Command-only (`disable-model-invocation`):

- `/dd:ts:review` — run typecheck/lint/tests, load every convention skill, review the diff, emit a structured report.

## Hook

`PreToolUse` on `Write|Edit`: when the target file ends in `.ts`, `.tsx`, `.mts`, or `.cts`, injects a one-line reminder to apply the `dd:ts:*` conventions. Emits only a `systemMessage` — it never auto-approves the edit.

## Why `private` and not `#`

`Proxy` cannot forward ECMAScript private-field access, so any class instance stored in a Proxy-based reactive store (Vue `reactive()`, MobX, Valtio) throws `TypeError: Cannot read private member #x…`. It's a JavaScript limitation, not a framework bug — see [tc39/proposal-class-fields#106](https://github.com/tc39/proposal-class-fields/issues/106) and [vuejs/core#7240](https://github.com/vuejs/core/issues/7240). For a published library, `#` is a compatibility hazard shipped to consumers. `#` stays available for app-internal classes that never enter reactive state.
