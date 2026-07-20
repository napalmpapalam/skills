#!/bin/sh
# PreToolUse (Write|Edit) nudge: when the edited file is TypeScript, remind the
# model to apply the dd:ts:* convention skills. Emits only `systemMessage` — no
# permissionDecision — so it never auto-approves the write, just adds context.

input=$(cat)

# Pull tool_input.file_path out of the hook's stdin JSON. jq if available,
# else a portable sed fallback.
if command -v jq >/dev/null 2>&1; then
  path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
else
  path=$(printf '%s' "$input" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
fi

case "$path" in
  *.ts|*.tsx|*.mts|*.cts)
    printf '{"systemMessage":"Editing TypeScript (%s) — apply the dd:ts:* conventions (code-style: no else, no for, max 2 nesting; type-system: type not interface, branded aliases, never any; classes: private not #; error-handling; comments: keep them concise). Load the relevant skill if unsure."}' "$path"
    ;;
esac

exit 0
