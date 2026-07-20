---
name: dd:ts:code-structure
description: TypeScript package layout, module organization, barrel files, import style, and naming rules. Use whenever creating or organizing TypeScript files and directories, setting up a package or monorepo workspace, writing index.ts barrels, choosing import paths or aliases, deciding where types/enums/constants/errors live, or when the user asks about project structure, file naming, or naming conventions for types, classes, functions, or constants.
---

# TypeScript Structure & Naming

## Package layout

Every package looks the same:

```
package.json  tsconfig.json  tsconfig.build.json  README.md  src/
```

`src/` uses a **fixed directory vocabulary** — always plural, always kebab-case:

| dir            | holds                                            |
| -------------- | ------------------------------------------------ |
| `types/`       | type aliases only                                |
| `enums/`       | enums only                                       |
| `const/`       | module constants                                 |
| `helpers/`     | pure free functions, one per file                |
| `errors/`      | error classes (or a flat `errors.ts` if only one)|
| `utils/`       | stateful builder-ish classes                     |
| `middlewares/` | pipeline steps                                   |
| `tests/`       | shared fixtures and mocks, excluded from build   |

**Top-level domain classes live directly in `src/`**, not in a folder — `src/fetcher.ts`, `src/json-api.ts`, `src/response.ts`.

## File rules

- **One concept per file, named after it**: `is-object.ts`, `normalize-header-case.ts`, `validate-base-url.ts`.
- **kebab-case filenames**, always. No `snake_case`, no `PascalCase.ts`.
- **Keep files under 200 lines.** A class that outgrows it is doing two jobs — split it.
- **Tests colocate**: `foo.ts` next to `foo.test.ts`. Shared fixtures go in `src/tests/` behind a barrel.
- **Never a `utils.ts` dumping ground** — `utils/` holds named classes, `helpers/` holds one function per file.

## Barrels

Every directory gets an `index.ts` that is **only re-exports**, alphabetically sorted (enforced by `simple-import-sort/exports`).

- **Root barrel uses the `@/` alias**: `export * from '@/hooks'`
- **Nested barrels use relative**: `export * from './computed'`
- Use **named re-exports** (`export { flatJsonApiQuery } from './flat-json-api-query'`) when a file has private helpers to hide; `export *` otherwise.
- A barrel may re-export a dependency's public API to give consumers one import site.

## Imports

- **`@/` alias across directories, `./` for same-directory siblings.**
- **`import type` for every type-only import.** `verbatimModuleSyntax: true` makes this mandatory, not stylistic.
- Import order is enforced by `simple-import-sort/imports` — don't hand-sort, let `--fix` do it.

## No default exports

Named exports only. Default exports break rename-refactoring, auto-import, and barrel re-export ergonomics. The one exception is re-exporting a JSON fixture: `export { default as RAW_RESPONSE } from './mocks/raw.json'`.

## Naming

| Kind                | Convention                          | Example                                          |
| ------------------- | ----------------------------------- | ------------------------------------------------ |
| Files, dirs         | kebab-case                          | `parse-json-api-error.ts`                        |
| Classes             | PascalCase, **package-prefixed**    | `FetcherError`, `JsonApiClient`, `BnFormatConfig`|
| Type aliases        | PascalCase, **package-prefixed**    | `FetcherConfig`, `TimeUnitLongPlural`            |
| Enums *and members* | SCREAMING_SNAKE_CASE both           | `HTTP_METHODS.GET`, `BN_ROUNDING.HALF_UP`        |
| Constants           | SCREAMING_SNAKE_CASE                | `DEFAULT_BN_PRECISION`, `HEADER_CONTENT_TYPE`    |
| Functions, vars     | camelCase                           | `buildRequestURL`, `flatJsonApiQuery`            |
| Type params         | `T`, `U`, `K`, `V`                  | `JsonApiResponse<T, U = DefaultMeta>`            |

**The package prefix is the point** — `FetcherConfig` not `Config`. Consumers import many packages into one file; unprefixed names collide and read ambiguously.

### Verb prefixes

| Prefix                | Means                                        |
| --------------------- | -------------------------------------------- |
| `isX` / `hasX`        | boolean or type predicate — `isZero`, `isRef`|
| `buildX`              | constructs a value from parts                |
| `parseX`              | string/raw → typed, throws on bad input      |
| `validateX`           | throws on invalid, returns void              |
| `assertX`             | assertion signature, narrows the caller      |
| `useX` / `withX`      | **`use*` mutates and returns `this`; `with*` clones first** |

`use*`/`with*` is a contract, not a preference. `useBaseUrl(u)` mutates; `withBaseUrl(u)` is `this.clone().useBaseUrl(u)`. Never write a `with*` that mutates.

### Params

Terse abbreviations are fine and idiomatic here: `cfg`, `opts`, `req`/`resp`, `q`, `acc`, `k`/`v`, `e` in catch. Prefix with `_` only to dodge a shadow: `parseNumberString(_value: string)`.
