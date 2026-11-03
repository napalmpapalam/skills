---
name: core
description: The TypeScript conventions that apply to almost every edit — code layout and blank lines, DRY, control flow, functions, types and enums, zod at boundaries, errors, async, module state, logging, classes, files and imports, comments, and naming. Use whenever writing, changing, or reviewing TypeScript, declaring types or enums, parsing external data, adding try/catch or error classes, writing async code, organizing files, barrels and imports, writing comments or TSDoc, refactoring code to be shorter, flatter or less repetitive, naming anything, or when the user asks about idiomatic TypeScript. This is the default TypeScript skill — load it first; reach for testing, tooling, or library on top of it when the task calls for them.
---

# TypeScript Core Rules

The conventions that govern essentially every TypeScript edit. Topic skills stack on top:
`dd:ts:testing`, `dd:ts:tooling`, `dd:ts:library` (published packages only).

`bun fmt` owns quotes, semicolons, wrapping and import order: no semicolons, single quotes,
100 columns (`dd:ts:tooling`). Write that way from the start. `bun fmt` does **not** add blank
lines, merge copies, or split a long function. Those three are the rules a review flags most, and only you
can follow them.

## Layout: paragraphs, not walls

A function body is a run of paragraphs. Twenty lines with no blank line are unreadable even when
each line is fine.

- **One step = one paragraph.** Lines that do one step — bind the inputs, start a process, build
  one value — stay together. A blank line goes between steps.
- **A block statement is its own paragraph.** A blank line goes before and after every `if`,
  `switch`, `try`, `for` and `while`, a one-line `if (x) return y` too. Exceptions: the first and
  the last statement of a body, and the next three rules.
- **Consecutive guard clauses are one paragraph** — no blank lines between them.
- **A one-line check stays with the line that binds its value.** `const x = …`, then
  `if (!x.ok) return …`, then the line that uses `x`: one step, one paragraph. A check of a value
  bound earlier is a guard, and a blank line goes after it — even when the next line uses that
  value.
- **A short body stays tight.** The whole body has up to ~4 simple statements, at most one of
  them a one-line `if`, and no braced block: no blank lines. The last lines of a long body are
  not a short body.
- **One-line declarations of one group stay together** — `const`s, class fields. A blank line
  goes between groups.
- **A multi-line declaration is its own paragraph** — a function, a class, a `type`, an `enum`,
  an object on several lines. A blank line goes before and after it.
- **A declaration with a comment above it starts a new paragraph.**
- **Blank line between class methods**, always. One after the imports, one between import
  groups.

```ts
// One blank line per const — the file reads as a list of unrelated facts
const ANVIL_CONTAINER = 'adi-e2e-anvil'

const SERVER_CONTAINER = 'adi-e2e-server'

const ANVIL_PORT = 8545

const SERVER_PORT = 3050

// Groups — names, then ports
const ANVIL_CONTAINER = 'adi-e2e-anvil'
const SERVER_CONTAINER = 'adi-e2e-server'

const ANVIL_PORT = 8545
const SERVER_PORT = 3050
```

```ts
// Wall — five steps, no breaks
export const runCommand = async (command: string, args: string[]): Promise<string> => {
  const start = performance.now()
  log.command([command, ...args].map(quote).join(' '))
  const proc = spawn(command, args)
  const stdout = await collect(proc)
  const code = await proc.exited
  if (stop.signal.aborted) throw new Interrupted()
  const took = duration(secondsSince(start))
  if (code) {
    log.fail(`✗ exit ${code} after ${took}`)
    throw new Error(`${command} exited with ${code}`)
  }
  log.ok(`✓ ${took}`)
  return stdout
}

// Paragraphs — announce, run, check, report
export const runCommand = async (command: string, args: string[]): Promise<string> => {
  const start = performance.now()
  log.command([command, ...args].map(quote).join(' '))

  const proc = spawn(command, args)
  const stdout = await collect(proc)
  const code = await proc.exited

  if (stop.signal.aborted) throw new Interrupted()

  const took = duration(secondsSince(start))

  if (code) {
    log.fail(`✗ exit ${code} after ${took}`)
    throw new Error(`${command} exited with ${code}`)
  }

  log.ok(`✓ ${took}`)
  return stdout
}
```

```ts
// A blank line around every one-line if — the check is cut off from its value
const loadConfig = async (path: string): Promise<Config | ConfigError> => {
  if (!path) return DEFAULT_CONFIG

  const text = await readText(path)

  if (text instanceof ReadError) return new ConfigError(path, { cause: text })

  return parseConfig(text)
}

// text: bind, check, use. path is bound earlier, so its guard keeps the blank line
const loadConfig = async (path: string): Promise<Config | ConfigError> => {
  if (!path) return DEFAULT_CONFIG

  const text = await readText(path)
  if (text instanceof ReadError) return new ConfigError(path, { cause: text })
  return parseConfig(text)
}

// Short body — three statements, one check: no blank lines
const parseCount = (raw: string): number | ParseError => {
  if (!raw) return 0
  const count = Number(raw)
  return Number.isInteger(count) ? count : new ParseError(raw)
}
```

### Long calls

When the arguments do not fit on one line, put **one logical unit per line**. A flag and its
value are one unit. `bun fmt` puts each string of a wrapped array on its own line, so it splits a
flag from its value — keep them as `[flag, value]` pairs and `.flat()` them at the call.

```ts
// Wall — which value belongs to which flag?
await runCommand('docker', [
  'run', '-d', '--name', SERVER_CONTAINER, '--user', '0:0',
  '--add-host', 'host.docker.internal:host-gateway', '-p', '3050:3050',
  '--env-file', 'server/server.env', image,
])

// One pair per line, a comment sits next to its flag
await dockerRun(
  [
    ['--name', SERVER_CONTAINER],
    ['--user', '0:0'], // the image runs as app, a new volume belongs to root
    ['--add-host', 'host.docker.internal:host-gateway'],
    ['-p', '3050:3050'],
    ['--env-file', 'server/server.env'],
  ],
  image,
)
```

## DRY

The usual advice — "three similar lines beat a premature abstraction" — **does not apply here**.
In this codebase that default produced copy-paste. **The second copy is the signal**, not the
third.

- **Search before you write.** Look in `helpers/`, in the module you are in, and in the module
  that owns the concern. Use what exists; add an option to it if it lacks one.
- **Copies to catch:**

| Copy | Fix |
|---|---|
| the same expression twice — `Object.keys(scenarios).join(', ')` | a `const` |
| the same call prefix — `runQuiet('docker', …)` four times | a wrapper — `docker(...args)` |
| the same cleanup in two branches | one `finally` |
| the same type check in two modules — `typeof v === 'number'` | one helper in `helpers/`, or a zod schema |
| a second way to do what a module already does — a raw `Bun.spawn` next to `runCommand` | the module, extended |
| two error values for one failure — `new Error('interrupted')` and `new Interrupted()` | one error class |
| the same literal in two files | one constant |

- **DRY is about knowledge, not look.** Two blocks that look alike but change for different
  reasons stay separate. Extract the concrete repeated thing — a function, a constant — never a
  generic framework for it.

## Control flow

- **Max 2 levels of nesting.** Past that, extract a function.
- **Guard clauses, no `else`.** Invert the condition and return early. A one-line guard has no
  braces: `if (!id) return null`. A ternary that hides an `else` inside a return is the same
  thing — sink the special case into an early `return`.
- **`switch` for a closed set** — a `return` per `case`, a `default` that throws.
- **A ternary picks a value**, one level. Never nested.
- **No C-style `for`.** Use `map`, `filter`, `reduce`, `flatMap`, and `forEach` for side effects.
  `for…of` only for a sequential `await` or an early `break`. `while` only for an algorithm.
- **Defaults over branches:** `??` for `null`/`undefined`. `||` only when `''` and `0` must fall
  through too.
- **Truthiness when every empty value means the same:** `if (code)`, not `if (code !== 0)`;
  `if (!bin)`, not `if (bin === undefined || bin === '')`. Compare explicitly only when `0` or
  `''` is a valid value.

## Functions

- **Arrow consts with an explicit return type:** `export const parseX = (raw: string): X => …`.
  `function` only for an assertion signature (`asserts x`).
- **An expression body fits on the signature line, or it becomes a block.** When the arrow and
  its expression do not fit in 100 columns, `bun fmt` moves the expression to the next line.
  Write `{ return … }` instead — and do not forget the `return`.

  ```ts
  // Hanging body
  export const adi = (run: Run, args: string[], opts: AdiOpts = {}): Promise<string> =>
    runCommand(run.adiBin, args, { ...opts, display: 'adi', signal: run.signal })

  // Block
  export const adi = (run: Run, args: string[], opts: AdiOpts = {}): Promise<string> => {
    return runCommand(run.adiBin, args, { ...opts, display: 'adi', signal: run.signal })
  }
  ```

- **Short bodies — ~15 lines.** Longer: extract a named step. The name replaces a comment.
- **At most 3 parameters.** More: one options object, `opts`.
- **No positional booleans.** `parse(input, true)` → an options object or an enum argument.
- **A query has no side effects.** `parseX`, `isX`, `toX` return a value and write nothing.
- **Private helpers go below the exports** that use them.

## Types

- **`type`, never `interface`.** One form for every shape, and nobody can reopen a `type` from
  another file by declaration merging.
- **`unknown`, never `any`.** No `!` non-null assertion — use `?.`, `??`, or `assert()`.
- **No `as` casts** except `as const` and a brand constructor. Narrow with a type predicate
  (`isX(v): v is X`) or `assert()`.
- **Derive, don't restate:** `Omit`, `Pick`, `Partial`, `Exclude`, `ReturnType`, `z.infer`.
- **A brand for a confusable primitive:** `type ChainId = Brand<bigint, 'ChainId'>`, minted in
  one constructor or by zod `.brand()`. An `as ChainId` anywhere else means the brand does
  nothing.
- `readonly` on fields that never change. `satisfies` checks a literal without widening it.

### Enums

`enum` in PascalCase, members in PascalCase, string values:

```ts
export enum CheckState {
  Done = 'done',
  Waiting = 'waiting',
  Failed = 'failed',
}

export type Check =
  | { state: CheckState.Done; value: string }
  | { state: CheckState.Waiting }
  | { state: CheckState.Failed; reason: string }
```

- **Not an `as const` object, not a bare string union** for the program's own states. A string
  enum rejects `'done'` where a `CheckState` is expected (TS2322); `as const` and a union accept
  it.
- **Never compare a state to a raw string:** `state === CheckState.Done`, never
  `state === 'done'`.
- **Plain `enum`, not `const enum`** — `isolatedModules` cannot inline it across files.
- **Numeric values only when the number is an external format.** Strings read well in a log.
- `enum` needs `erasableSyntaxOnly` off (`dd:ts:tooling`).
- A string union stays only for strings a caller types by hand at an API boundary:
  `type TimeUnitShort = 'd' | 'h' | 'm'`.

## Validation at boundaries

External data — command output, HTTP bodies, env vars, files — is `unknown` until a zod schema
parses it. Parse once at the edge; inside, trust the type.

```ts
const ServerParamsSchema = z.object({
  genesis: z.string(),
  genesis_chain_id: z.number().int(),
  genesis_bridgehub_address: z.string(),
})

export type ServerParams = z.infer<typeof ServerParamsSchema>

export const parseServerParams = (json: string): ServerParams => {
  return ServerParamsSchema.parse(JSON.parse(json))
}
```

- **Derive the type with `z.infer`.** Never hand-write a type next to a schema.
- **No hand-written `isNumber`/`isString` chains on external data** — the schema is the check.
- **Internal invariants use `assert()`**, not zod.

## Errors

- **Throw when the failure ends the operation** — a failed command, a broken step. A caller
  higher up handles it.
- **Return the error when the caller handles it on the spot and goes on.** The error is part of
  the type: `Promise<string | ReadError>`. The caller narrows with `instanceof`, and the
  compiler does not let it use the value before that.
- **`T | E`, not a `Result<T, E>` wrapper.** `instanceof` is the type guard. Use a wrapper only
  when `T` itself can be an `Error`.
- **No magic values.** `'?'`, `-1`, `''` or `null` that mean "it failed" look like a real
  value, and the signature hides the failure. A display such as `'?'` belongs to the output
  edge only.
- **One class per failure a caller handles differently.** `public name = 'X'` as a field; the
  caller narrows with `instanceof`.
- **Keep the cause:** `throw new Error('deploy failed', { cause: e })`.
- **`catch (e)` is `unknown`.** Narrow with `instanceof`; format through one `errorMessage(e)`
  helper.
- **`assert(cond, msg)` over `if (!cond) throw`** — one line, and it narrows. One shared
  `assert` in `helpers/`.
- **Cleanup goes in one `finally`**, not in each branch.
- **Never swallow.** No empty `catch {}`. A deliberate ignore says why.
- **A catch handles only the failure it expects.** Narrow with `instanceof` and rethrow the
  rest. A catch-all also hides your own bugs: a wrong ABI or a `TypeError` looks the same as a
  failed request.
- **Log where you decide**, not where you rethrow.

```ts
// Magic value — the signature says string, and a failure is a string too
const read = async (value: () => Promise<bigint>): Promise<string> => {
  try {
    return String(await value())
  } catch {
    return '?'
  }
}

// The error is in the type — a narrow catch, and the reason stays in the error
const read = async (value: () => Promise<bigint>): Promise<string | ReadError> => {
  try {
    return String(await value())
  } catch (e) {
    if (!(e instanceof BaseError)) throw e
    return new ReadError(e.shortMessage, { cause: e })
  }
}

// The output edge is the only place that knows about '?'
const show = (value: string | ReadError): string => {
  return value instanceof ReadError ? '?' : value
}
```

```ts
export class Interrupted extends Error {
  public name = 'Interrupted'
}

export function assert(condition: unknown, message: string): asserts condition {
  if (!condition) throw new Error(message)
}
```

## Async

- **Independent work runs together:** `Promise.all`; `Promise.allSettled` when partial success
  counts.
- **Sequential `for…of` + `await`** only when a step needs the previous one or the order is the
  point.
- **No floating promises.** Every promise is awaited, returned, or `void p.catch(handle)`.
- **`.forEach(async …)` awaits nothing** — use `Promise.all(xs.map(…))` or `for…of`.
- **`await`, not `.then()` chains.** An inline `.catch()` stays for a fallback.
- **I/O takes an `AbortSignal`.** A timeout aborts on a timer; `clearTimeout` goes in `finally`.
- **No async constructors or async getters** — a `static async create()` factory, a method.

## Module state and side effects

- **No scattered `let` at module scope.** Several top-level `let`s that several functions
  change are hidden global state.
- **State a module owns lives in one private object behind an API:** a class instance
  (`export const log = new Logger()`), or one private config object that only one exported
  setter changes.
- **No work at import time** — no listeners, timers or promises when the module loads. Put it in
  a function that the entry point calls. A library's own plugin setup (`dayjs.extend(utc)`) is
  the exception.

## Output and logging

- **All output goes through one logger module** with a method per kind of line: `log.info`,
  `log.title`, `log.error`. No `console.log`, no `process.stdout.write`.
- **The logger owns the format.** No color codes, `FAILED:` prefixes or padding at call sites.
- A library does not log; it throws (`dd:ts:library`).

## Classes

- **A class when there is state or a lifecycle**; arrow functions for transforms. No class of
  static methods to group functions — a module groups them.
- **`#field` for private state.** The `private` keyword only in a published library
  (`dd:ts:library`).
- **Write `public`** on public members.
- **Getters over `getX()`** for derived or read-only values. Boolean getters: `isX`, `hasX`.
- **Member order:** static members, fields, constructor, getters, public methods, private
  methods.
- **Composition over inheritance.** Inheritance is for error classes.

## Files, modules, imports

- **One concern per file, under 200 lines.** A domain that outgrows one file becomes a folder:
  the main module plus focused siblings (`bn/` → `bn.ts`, `parsers.ts`, `format.ts`,
  `round.ts`).
- **kebab-case** file and directory names.
- **Shared vocabulary dirs:** `types/`, `enums/`, `const/`, `helpers/` (pure functions),
  `errors.ts`. Domain code goes by feature, not by kind.
- **`@/` alias across directories, `./` inside one directory.** Never `../`.
- **`import type`** for type-only imports.
- **Four import groups** — built-ins (`node:`), packages, `@/`, relative — with a blank line
  between them. `bun fmt` with `sortImports` keeps this order.
- **Named exports only.** No default export.
- **Every directory has a barrel `index.ts`**, and it holds only re-exports:
  `export * from './check-state'`.
- **Import from the module, not from a file inside it.** Across directories, import the barrel
  (`@/enums`), never a file behind it (`@/enums/check-state`). Moving or splitting a file then
  changes one barrel, not every import.
- **Inside a directory, import a sibling by `./file`**, never through the own barrel. That
  makes a cycle, and a cycle can give `undefined` at load time.
- **Exports first, private helpers below.**

```ts
// File paths — every import knows the layout of enums/ and lib/
import { CheckState } from '@/enums/check-state'
import { log } from '@/lib/logger'

// Modules
import { CheckState } from '@/enums'
import { log } from '@/lib'
```

## Comments

Default to less. The failure to avoid is the **comment poem**: a prose block that explains the
design to nobody.

- **Budget:** a module header `//` — 1 line or none. A TSDoc `/** … */` — 1 line. An inline
  `//` — 1–3 lines.
- **Never a comment longer than the code it describes.**
- **A function doc starts with a third-person verb** — `Returns…`, `Starts…` — and says what the
  name and the types do not.
- **No `@param` / `@returns`** that restate the signature. `@throws` only when the failure is
  not obvious.
- **A `//` is for a why** the code cannot show: a workaround, an ordering rule, a spec link. A
  `//` that says *what* a block does means: extract a named function.
- **Design rationale lives in a design doc**, not in a file header.

```ts
// Too much — restates the signature, narrates the body
/**
 * Runs the command, streams its stdout and stderr to the log, waits for the exit,
 * and prints a check mark with the duration.
 * @param command The command
 * @param args The arguments
 * @returns The stdout
 */

// Enough
/** Runs a logged command and fails on a non-zero exit. */
```

## Naming

| Kind | Convention | Example |
|---|---|---|
| files, dirs | kebab-case | `server-params.ts` |
| types, classes, enums, enum members | PascalCase | `CheckState.Done` |
| constants | SCREAMING_SNAKE_CASE | `FOUNDRY_IMAGE` |
| functions, variables | camelCase | `parseServerParams` |
| type parameters | `T`, `U`, `K`, `V` | `Brand<T, B>` |

- **Acronyms are words:** `rpcUrl`, `HttpClient`, `parseJson` — not `RPCURL`.
- **A verb prefix is a contract:** `isX`/`hasX` — a boolean or a predicate; `parseX` — raw to
  typed, throws; `assertX` — narrows or throws; `buildX` — builds from parts; `toX` — converts.
- **No `get` prefix on a plain accessor** — use a getter.
- **Short names in a short scope:** `cfg`, `opts`, `e`, `acc`.
