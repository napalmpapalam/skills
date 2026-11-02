# ts

TypeScript conventions and best practices. Four convention skills auto-trigger while you write TypeScript; a fifth is an explicit review command. Two hooks nudge Claude toward the conventions, both gated on the project being TypeScript (a `tsconfig.json` in cwd or any ancestor).

The style follows [`distributed-lab/web-kit`](https://github.com/distributed-lab/web-kit/tree/main/packages/tools/src): paragraphs of code with blank lines between steps, small focused modules, guard clauses, arrow helpers, `enum` for states.

## Skills

Auto-triggered (loaded on demand when the task matches):

- `dd:ts:core` — the default: layout and blank lines, DRY, control flow, functions, types and enums, zod at boundaries, errors, async, module state, logging, classes, files and imports, comments, naming.
- `dd:ts:testing` — `bun test`, layout, arrange-act-assert, what to assert, mocking.
- `dd:ts:tooling` — Bun for everything: `bun fmt`, `bun lint`, `bun check`, `bun test`, one `bunfig.toml`, tsconfig flags, workspaces, CI and git hooks.
- `dd:ts:library` — only for published packages: public surface, package-prefixed names, `private` over `#`, factories, `use*`/`with*`, TSDoc on every export, the build and `exports` map.

`core` carries what applies to almost every edit; the other three are conditional and stack on top. One big `core`, not nine small skills, for the reason the `rust` plugin found: the nudge hook goes quiet after the first skill loads, so that one skill must cover the edit. A separate `comments` skill also never self-triggers — the model does not see "I am about to write a comment" as its own task.

Command-only:

- `/dd:ts:review` — run format, typecheck, lint and tests, load the convention skills, review the diff with mandatory layout/DRY and comment passes, emit a structured report.

## Hooks

- `SessionStart` (`startup|clear|compact`): in a TypeScript project, injects a note that the `dd:ts:*` conventions govern all TypeScript, including answers about hypothetical changes.
- `UserPromptSubmit`: in a TypeScript project, tells the model that no `dd:ts:*` skill is loaded and it must call one. It greps the live transcript (`transcript_path`) for a real `Skill` call and **goes silent once one lands**.

Both write plain stdout, which these two events add as context the model reads. Neither gates a tool call.

> An earlier version was a `PreToolUse` hook on `Write|Edit` that emitted `{"systemMessage": …}`. The model never saw it: `systemMessage` reaches only the user, and `PreToolUse` cannot return `additionalContext`.
