---
name: library
description: Extra TypeScript rules for a published package — the public API surface, package-prefixed names, private over #, static factories, immutable values, use*/with* builders, TSDoc on every export, error messages, ESM build and the exports map. Use whenever writing or reviewing a TypeScript library or SDK that other projects install, designing its public API, adding a class or builder to it, documenting exports, or setting up its build, package.json exports, or publishing. Not for applications, CLIs or test harnesses — dd:ts:core covers those alone.
---

# TypeScript Library Rules

These stack on `dd:ts:core` when the code ships as a package that other projects install. An
application, a CLI or a test harness does not need them.

## Public surface

- **Anything not in the root barrel is free to change.** Keep the exported surface minimal.
- **Hide implementation classes.** Export functions, a type and a type predicate; the class stays
  module-private. Consumers depend on the shape, not on the constructor.

  ```ts
  export const ref: RefFunction = (value?: unknown) => new RefImpl(value)
  export const isRef = <T>(v: unknown): v is Ref<T> => v instanceof RefImpl
  ```

- **Options objects over positional arguments** in every public signature.
- **A barrel may re-export a dependency's API** to give consumers one import site.

## Names carry the package prefix

`FetcherConfig`, not `Config`. Consumers import many packages into one file; unprefixed names
collide and read as ambiguous. This holds for classes, types and enums.

## `private`, not `#`

A `Proxy` cannot forward `#field` access, so an instance with `#` fields inside a Proxy-based
store throws `TypeError: Cannot read private member`. Vue `reactive()`, MobX and Valtio all do
this, and consumers put library instances there. See
[tc39/proposal-class-fields#106](https://github.com/tc39/proposal-class-fields/issues/106).

- **Use `private readonly`.** A private field and a getter cannot share a name: the field takes
  the short form (`cfg`, `raw`), the getter the public one (`config`, `value`).
- **No `_` prefix** on private members. `private` already says it.

## Construction

- **Static factories over a public constructor** when construction validates, parses or has
  several entry points. The constructor is `protected`.

  ```ts
  export class BN {
    protected constructor(value: bigint, cfg: BnConfig) { … }

    public static fromBigInt(value: BnLike, cfg?: BnConfigLike): BN { … }
    public static fromRaw(value: BnLike, cfg?: BnConfigLike): BN { … }
  }
  ```

- **Value objects never mutate.** Every operation returns a new instance. `build()` returns a
  copy, never the internal object.

## `use*` mutates, `with*` clones

A stateful class that supports reconfiguration exposes `clone()` and both variants:

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

**Never write a `with*` that mutates.** Fluent setters return `this`; type the return as `this`
when subclasses must keep the chain.

## Errors

- **Ship the package's own error classes:** one base that carries the data, thin leaves that
  carry only identity. Consumers narrow with `instanceof`, without a status-code table.
- **Map transport errors to domain errors in one place** — one `switch` with a `default`.
- **Prefix every message with the package name:** `Fetcher: query parameters can't be nested`.
- **A bad argument from the caller is a `TypeError`**, not a new class.
- **A library does not log.** It throws, and the application decides.

## TSDoc

**Every export and every public member gets one** — TSDoc is the API docs. The `dd:ts:core`
budget still holds: one line by default.

- `{@link OtherType}` for cross-references.
- `@throws` when the failure is not obvious — consumers cannot see your `catch`.
- `@example` with a fenced `ts` block for a non-obvious call shape: a builder, a factory with
  overloads, an options object.

## Build and publish

- **ESM only.** Node 22.12+ can `require()` ESM.
- **`.d.ts` from `tsc`:** `tsc -p tsconfig.build.json --emitDeclarationOnly --outDir dist/types`.
  Bun does not generate declarations.
- **JS from `bun build`** with `--packages external`, so dependencies are not bundled in.
- **`"sideEffects": false`**, so consumers can tree-shake.
- **An `exports` map with `types` first** — resolution reads the conditions in order.

```json
{
  "type": "module",
  "sideEffects": false,
  "exports": {
    ".": { "types": "./dist/types/index.d.ts", "import": "./dist/index.js" }
  },
  "files": ["dist"]
}
```
