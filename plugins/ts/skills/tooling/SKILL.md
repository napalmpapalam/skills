---
name: tooling
description: TypeScript project tooling on Bun — bun as package manager, runtime and test runner, bun fmt for formatting and import order, bun lint for lint rules, bun check for types, bunfig.toml, tsconfig strictness flags, workspaces, and git hooks. Use whenever setting up or changing a TypeScript project's config, editing bunfig.toml or tsconfig.json, choosing format or lint settings, adding dependencies or scripts, configuring a monorepo workspace, setting up CI checks, or when the user asks about strict flags, lint rules, formatting, or which tools to use.
---

# TypeScript Tooling

## Bun does it all

**Bun is the package manager, runtime, test runner, formatter, linter and type checker.** No
prettier, no eslint, no `tsc --noEmit`, no jest.

| Job | Command | Replaces |
|---|---|---|
| install | `bun install`, `bun add zod`, `bun add -d @types/bun` | npm, yarn, pnpm |
| format | `bun fmt` | prettier |
| lint | `bun lint` | eslint + typescript-eslint |
| types | `bun check` | `tsc --noEmit` |
| test | `bun test` | jest, vitest |

- **These commands need a recent Bun** — the docs describe them for Bun 1.4.4. On an older Bun,
  `bun fmt` and `bun lint` fail with `error: Script not found`. Run `bun upgrade`, and pin a CI
  image that has them.
- **`bun.lock` is committed.** Never a `package-lock.json`, `yarn.lock` or `pnpm-lock.yaml`
  next to it.
- **`tsc` stays only to emit `.d.ts`** in a published package (`dd:ts:library`). `bun check`
  only checks.
- **A `package.json` script with the same name wins** over the built-in command. Do not add
  `fmt`, `lint` or `check` scripts — call the commands directly.

## bunfig.toml

**All tool config lives in `bunfig.toml`** — `[fmt]` and `[lint]`. No `.prettierrc`, no
`eslint.config.js`. `bun fmt` does not read the `prettier` key in `package.json`.

**List only the options that differ from the default.** A config that restates defaults hides
the few choices that matter.

```toml
[fmt]
semi = false
singleQuote = true
arrowParens = "avoid"
printWidth = 100
sortImports = true

[lint]
typeAware = true
maxWarnings = 0

[lint.rules]
"@typescript-eslint/no-explicit-any" = "error"
"@typescript-eslint/no-non-null-assertion" = "error"
"@typescript-eslint/consistent-type-definitions" = ["error", "type"]
"@typescript-eslint/consistent-type-imports" = "error"
"@typescript-eslint/no-floating-promises" = "error"
"@typescript-eslint/no-misused-promises" = "error"
"@typescript-eslint/no-unsafe-enum-comparison" = "error"
"no-console" = ["warn", { allow = ["warn", "error"] }]
```

## Format — `bun fmt`

- **Same output as prettier, same option names.** `bun fmt --init` writes the `[fmt]` section.
- **`sortImports = true`** orders the imports in groups — built-ins, packages, `@/`, relative —
  with a blank line between them, and merges duplicate imports.
- **`semi = false`** — a line that starts with `(` or `[` gets a leading `;`. The formatter adds
  it.
- **The formatter does not wrap comments.** Wrap them at 100 by hand.
- **CI runs `bun fmt --check`** — it writes nothing and exits `1` when a file needs formatting.

## Lint — `bun lint`

- **The defaults are ESLint and typescript-eslint recommended.** `[lint.rules]` adds the rules
  that carry the `dd:ts:core` conventions.
- **`typeAware = true`** turns on the rules that need types, such as `no-floating-promises`. It
  type-checks first, so it is slower.
- **`maxWarnings = 0`** — a warning fails the run.
- **After a rule change, run `bun lint --print-config`** and confirm every rule is active.
  `no-unsafe-enum-comparison` (it catches `state === 'done'`) is not confirmed in Bun's docs —
  check it with `bun lint --explain @typescript-eslint/no-unsafe-enum-comparison`.
- **`bun lint --fix`** applies safe fixes; `--fix-suggestions` also applies fixes that can change
  behavior — review those.

## Types — `bun check`

- **Reads the nearest `tsconfig.json`** and reports the same errors as `tsc`.
- **`bun test --check`** type-checks, then runs the tests.
- **No cache:** every run checks the whole project.

## tsconfig

```jsonc
{
  "compilerOptions": {
    "target": "ESNext",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "types": ["bun"],

    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,

    "verbatimModuleSyntax": true,
    "isolatedModules": true,
    "noEmit": true,
    "skipLibCheck": true,

    "paths": { "@/*": ["./src/*"] }
  }
}
```

The flags that do the most work:

- **`noUncheckedIndexedAccess`** — `arr[i]` is `T | undefined`. A silent `undefined` becomes a
  compile error. It pairs with the ban on `!`.
- **`exactOptionalPropertyTypes`** — `foo?: string` no longer accepts an explicit `undefined`.
  Do not assign `undefined` to an optional property; leave it out.
- **`verbatimModuleSyntax`** — makes `import type` mandatory.

**Never `erasableSyntaxOnly`.** It bans `enum` (TS1294). The flag only matters when Node runs
`.ts` files in strip-only mode, which cannot compile an enum. Bun compiles enums itself.

## Workspaces

A monorepo uses `packages/*`, declared in the root `package.json`:

```json
"workspaces": ["packages/*"]
```

- **Cross-package deps use the workspace protocol:** `"@scope/fetcher": "workspace:*"`.
- **Shared config lives at the root.** Each package extends the root `tsconfig.json` and adds
  only its `paths` and `include`.

## CI and git hooks

The check is four commands, in this order — the cheap ones first:

```bash
bun fmt --check
bun lint
bun check
bun test
```

- **`pre-commit`:** `bun fmt --check` and `bun lint --staged`.
- **`pre-push`:** `bun check` and `bun test`.
- **Keep hooks fast** — a hook slower than a few seconds gets bypassed with `--no-verify` and
  protects nothing.
