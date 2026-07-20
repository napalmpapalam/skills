---
name: dd:ts:classes
description: TypeScript class and API design — private fields, getters, static factories, immutability, fluent builders, composition over inheritance, and options objects. Use whenever writing or reviewing a TypeScript class, choosing between a class and plain functions, designing a public library API, adding constructors or factory methods, building chainable/fluent interfaces, or when the user asks about encapsulation, OO style, or object and data-structure design.
---

# TypeScript Classes & API Design

## Class or function?

- **Class** — anything with lifecycle or state: clients, managers, builders, response wrappers, value objects.
- **Arrow-function const** — anything that transforms input to output. Helpers, parsers, validators, middlewares.

Don't wrap stateless functions in a class just to group them. A barrel already groups them.

## Privacy: `private`, not `#`

**Use `private readonly`, not `#`.** This is deliberate and it costs something, so here's the reason:

`Proxy` cannot forward private-field access — the brand check runs against the raw target. Any class instance stored in a `Proxy`-based reactive store throws:

```
TypeError: Cannot read private member #x from an object whose class did not declare it
```

That hits Vue's `reactive()`, MobX, and Valtio. It is a JavaScript limitation, not a framework bug ([tc39/proposal-class-fields#106](https://github.com/tc39/proposal-class-fields/issues/106)); Vue closed it won't-fix. For a **published library**, whose instances land in consumers' stores, `#` is a compatibility hazard you ship to them.

`#` also breaks `structuredClone` and spread, and downlevels to `WeakMap` lookups below ES2022.

```ts
export class Fetcher {
  private readonly abortManager: FetcherAbortManager
  private cfg: FetcherConfig
```

A `private` field and a getter can't share a name, so the field takes the terse form (`cfg`, `raw`) and the getter takes the public one (`config`, `value`). With `#` the two could collide-free; that's the one ergonomic loss, and it's cheap.

**Use `#` only when** the class is app-internal (never published), never enters reactive state, and you specifically need runtime-enforced hiding. Private methods follow the same rule — `private extractData()`, not `#extractData()`.

Don't prefix private members with `_`. `private` already says it.

## Explicit `public`

Write `public` on public members. It reads as a deliberate API decision rather than an omission, and it makes the surface greppable.

## Getters over `getX()`

Anything derived or read-only is a getter with an explicit return type:

```ts
public get config(): FetcherConfig { return this.cfg }
public get baseUrl(): string { return this.cfg.baseUrl }
public get isLinksExist(): boolean { … }
```

Boolean getters are named `isX` / `hasX`. Reserve methods for things that *do* work or can fail.

## Static factories over public constructors

When construction needs validation, parsing, or several entry points, make the constructor `protected` and expose named factories:

```ts
export class BN {
  protected constructor(value: bigint, config: BnConfig) { … }

  public static fromBigInt(value: BnLike, decimalsOrConfig?: BnConfigLike): BN { … }
  public static fromRaw(value: BnLike, decimals?: number): BN { … }
  public static min(...args: BN[]): BN { … }
}
```

Named factories document intent at the call site — `BN.fromRaw(x)` beats `new BN(x, { raw: true })`.

**Constructors taking more than 2 params take a single options object instead:**

```ts
constructor(opts: { raw: JsonApiResponseRaw; isNeedRaw: boolean; apiClient: JsonApiClient })
```

## Immutability

**Value objects return new instances; they never mutate.** Every arithmetic op on `BN` returns `new BN(…)`. Same for anything that models a value rather than a connection.

`build()` returns a copy, not the internal object:

```ts
public build(): JsonApiRecord {
  return { ...this.body }
}
```

Don't mutate function parameters. Don't hand out internal arrays or maps — return a copy or a readonly view.

## `use*` mutates, `with*` clones

The single most important naming contract in the API surface:

```ts
public useBaseUrl(baseUrl: string): Fetcher {
  validateBaseUrl(baseUrl)
  this.cfg.baseUrl = baseUrl
  return this
}

public withBaseUrl(baseUrl: string): Fetcher {
  return this.clone().useBaseUrl(baseUrl)
}
```

Every stateful class that supports reconfiguration exposes `clone()` and both variants. **Never write a `with*` that mutates.**

## Fluent builders

Chainable setters return `this`; a terminal `build()` produces the value.

```ts
new JsonApiBodyBuilder()
  .setType('users')
  .setID('1')
  .setAttributes({ name: 'x' })
  .build()
```

Type the return as `this` (not the class name) when subclasses should keep chaining.

## Composition over inheritance

Wrap and delegate rather than extend. `JsonApiClient` holds a `Fetcher` and forwards `abort`, `addInterceptor`, and the HTTP verbs — it does not `extends Fetcher`. `Fetcher` composes an abort manager and an interceptor manager.

**Inheritance is for error hierarchies and nothing else.** `implements` is not part of the vocabulary here — structural typing already gives you the contract.

Split collaborators by single responsibility: an abort manager owns `Map<string, AbortController>`, an interceptor manager owns the interceptor list. Neither knows about HTTP.

## Hide implementation classes

When the public API is functional, keep the class private to the module and export functions plus a type predicate:

```ts
// public surface
export const ref: RefFunction = (value?: unknown) => new RefIml(value)
export const isRef = <T>(v: unknown): v is Ref<T> => v instanceof RefIml

// Ref<T> is structurally just { value: T } — consumers never see RefIml
```

Consumers depend on the shape, not the constructor. You keep the freedom to change it.

## Objects and data structures

- **Encapsulate.** Public fields become part of your API the moment someone assigns to one. Expose getters, take changes through methods.
- **No getter/setter pairs that just proxy a field** — if it's freely readable and writable with no invariant, question whether it belongs in the class at all.
- **Options objects over positional booleans.** `parse(input, { strict: true })` beats `parse(input, true)`.
- **Keep the exported surface minimal.** Anything not in a barrel is free to change.
