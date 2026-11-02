---
name: tooling
description: TypeScript project tooling — bun as package manager, runtime and test runner, tsconfig strictness flags, prettier and eslint config, workspaces, and git hooks. Use whenever setting up or changing a TypeScript project's config, editing tsconfig.json, prettier or eslint settings, adding dependencies or scripts, configuring a monorepo workspace, or when the user asks about strict flags, lint rules, formatting, or which package manager to use.
---

# TypeScript Tooling

## Bun

**Bun is the package manager, the runtime, the script runner and the test runner.** One tool
instead of npm + tsx + jest.

```bash
bun install              # not npm/yarn/pnpm install
bun add zod              # bun add -d for dev deps
bun run typecheck        # a package.json script
bun test                 # built in, jest-compatible
bun x tsc --noEmit       # a one-off binary
```

- **`bun.lock` is committed.** Never a `package-lock.json`, `yarn.lock` or `pnpm-lock.yaml`
  next to it.
- **pnpm is the fallback** for a repo that cannot move. Never npm or yarn.

## Config files

**Tool config goes in `package.json` when the tool reads it there** — `prettier`, `workspaces`.
One file less per tool. A separate file only when the tool cannot read `package.json`
(`tsconfig.json`, `eslint.config.js`).

**List only the options that differ from the default.** A config that restates defaults hides
the few choices that matter.

## Prettier

```json
"prettier": {
  "semi": false,
  "singleQuote": true,
  "arrowParens": "avoid",
  "printWidth": 100
}
```

- `semi: false` means a line that starts with `(` or `[` needs a leading `;`. Prettier adds it.
- Prettier does not wrap comments. Wrap them at 100 by hand.
- Scripts: `"format": "prettier --write ."` and `"format:check": "prettier --check ."`.

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

## ESLint

Flat config (`eslint.config.js`), typescript-eslint with type-aware rules:

- extends: `eslint:recommended`, typescript-eslint `strictTypeChecked` + `stylisticTypeChecked`,
  `eslint-config-prettier` last.
- plugins: `simple-import-sort`.

| Rule | Setting |
|---|---|
| `@typescript-eslint/no-explicit-any` | `error` |
| `@typescript-eslint/no-non-null-assertion` | `error` |
| `@typescript-eslint/consistent-type-definitions` | `['error', 'type']` |
| `@typescript-eslint/consistent-type-imports` | `error` |
| `@typescript-eslint/no-floating-promises` | `error` |
| `@typescript-eslint/no-misused-promises` | `error` |
| `@typescript-eslint/no-unsafe-enum-comparison` | `error` — catches `state === 'done'` |
| `no-restricted-syntax` | ban `ForStatement` |
| `simple-import-sort/imports`, `/exports` | `error` |
| `no-console` | `['warn', { allow: ['warn', 'error'] }]` |

**The lint script has zero tolerance:** `eslint . --max-warnings=0`, then `tsc --noEmit`.

## Workspaces

A monorepo uses `packages/*`, declared in the root `package.json`:

```json
"workspaces": ["packages/*"]
```

- **Cross-package deps use the workspace protocol:** `"@scope/fetcher": "workspace:*"`.
- **Shared config lives at the root.** Each package extends it and adds only its `paths` and
  `include`.

## Git hooks

`pre-commit`: format check, lint, typecheck. `pre-push`: `bun test`. Keep them fast — a hook
slower than a few seconds gets bypassed with `--no-verify` and protects nothing.
