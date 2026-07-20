---
name: dd:ts:tooling
description: TypeScript project tooling — bun as package manager and runtime, tsconfig strictness flags, eslint rules, prettier settings, workspaces, build output, and package.json exports. Use whenever setting up or changing a TypeScript project's config, editing tsconfig.json/eslint/prettier, adding dependencies or scripts, configuring a monorepo workspace, setting up a package build or exports map, or when the user asks about strict flags, lint rules, formatting, or which package manager to use.
---

# TypeScript Tooling

## Bun

**Bun is the package manager, script runner, and test runner.** One tool instead of npm + tsx + jest.

```bash
bun install              # not npm/yarn/pnpm install
bun add zod              # bun add -d for dev deps
bun run build            # or just `bun build:types`
bun test                 # built-in, jest-compatible
bun x tsc --noEmit       # one-off binaries
```

`bun.lock` is committed. Never commit `package-lock.json`, `yarn.lock`, or `pnpm-lock.yaml` alongside it.

**pnpm is the fallback** for a repo that can't move (CI images without bun, a build step depending on npm lifecycle semantics). If so: `pnpm install`, `pnpm-workspace.yaml`, `pnpm --filter <pkg>`. Never npm or yarn.

## Workspaces

Monorepo layout is `packages/*`, declared in the root `package.json`:

```json
{
  "workspaces": ["packages/*"],
  "packageManager": "bun@1.2.0"
}
```

Cross-package deps use the workspace protocol: `"@scope/fetcher": "workspace:*"`. Shared config (tsconfig base, eslint, prettier) lives at the root; each package extends it and adds only its `paths` and `include`.

## tsconfig

Root config, every flag on purpose:

```jsonc
{
  "compilerOptions": {
    "target": "ESNext",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "lib": ["ESNext", "DOM", "DOM.Iterable"],

    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,

    "verbatimModuleSyntax": true,
    "useDefineForClassFields": true,
    "isolatedModules": true,
    "esModuleInterop": true,
    "resolveJsonModule": true,
    "skipLibCheck": true,
    "sourceMap": true,
    "newLine": "lf"
  }
}
```

The four that do the most work:

- **`noUncheckedIndexedAccess`** — `arr[i]` is `T | undefined`. Turns silent `undefined` propagation into a compile error. Pairs with the ban on `!`.
- **`exactOptionalPropertyTypes`** — `foo?: string` no longer accepts an explicit `undefined`. Watch the `...(opts || {})` spread idiom: prefer `...opts` with `opts` defaulted, and don't assign `undefined` to optional props.
- **`verbatimModuleSyntax`** — makes `import type` mandatory rather than stylistic.
- **`useDefineForClassFields`** — makes `public name = 'X'` in error subclasses reliably override the base.

Per-package config adds only:

```jsonc
{
  "extends": "../../tsconfig.json",
  "compilerOptions": { "baseUrl": ".", "paths": { "@/*": ["src/*"] } },
  "include": ["src/**/*.ts"]
}
```

`tsconfig.build.json` adds `"exclude": ["src/tests", "**/*.test.ts"]`.

## ESLint

Flat config, typescript-eslint with type-aware rules:

- extends: `eslint:recommended`, `typescript-eslint` strict + stylistic (type-checked), `eslint-config-prettier` last.
- plugins: `@typescript-eslint`, `simple-import-sort`.

Rules that carry the conventions:

| Rule                                          | Setting                                    |
| --------------------------------------------- | ------------------------------------------ |
| `@typescript-eslint/no-explicit-any`          | `error` — escape hatch is a line-disable   |
| `@typescript-eslint/no-non-null-assertion`    | **`error`** — no `!`                       |
| `@typescript-eslint/consistent-type-definitions` | `['error', 'type']` — bans `interface`  |
| `@typescript-eslint/consistent-type-imports`  | `error`                                    |
| `@typescript-eslint/no-floating-promises`     | `error`                                    |
| `@typescript-eslint/no-misused-promises`      | `error`                                    |
| `no-restricted-syntax`                        | ban `ForStatement`                         |
| `simple-import-sort/imports` + `/exports`     | `error`                                    |
| `no-var`                                      | `error`                                    |
| `no-console`                                  | `['warn', { allow: ['warn', 'error'] }]`   |
| `no-warning-comments`                         | `['warn', { terms: ['hardcoded'] }]`       |

`parserOptions.project` must list the root and every package tsconfig, or type-aware rules silently don't run.

**The lint script is zero-tolerance**: `eslint . --fix --cache --max-warnings=0`, then `tsc --noEmit`.

## Prettier

```json
{
  "semi": false,
  "singleQuote": true,
  "arrowParens": "avoid",
  "trailingComma": "all",
  "printWidth": 80,
  "tabWidth": 2,
  "bracketSpacing": true,
  "endOfLine": "lf"
}
```

`semi: false` means a line starting with `(` or `[` needs a leading `;`. That's the cost; take it.

## Build and publish

**ESM-only by default.** Node 22.12+ can `require()` ESM, so dual-format is legacy support you probably don't owe anyone. Bun's CJS output format is documented as experimental — if you genuinely need CJS, reach for `tsdown`/`bunup` rather than hand-rolling it.

- **`.d.ts` from `tsc`**: `tsc -p tsconfig.build.json --declaration --emitDeclarationOnly --outDir dist/types`. Bun does not generate declarations.
- **JS from `bun build`** with `--packages external` so dependencies aren't inlined into a library bundle.
- `"sideEffects": false` — lets consumers tree-shake.
- **`exports` map with `types` first**, since resolution is order-sensitive:

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

## Git hooks

`pre-commit: bun run lint` — `pre-push: bun test`. Keep them fast; anything slower than a few seconds gets bypassed with `--no-verify` and stops protecting anything.

Sources: [Bun bundler docs](https://bun.com/docs/bundler), [Publishing dual ESM+CJS packages](https://mayank.co/blog/dual-packages/)
