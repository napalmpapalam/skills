#!/bin/sh
# PreToolUse (Write|Edit) nudge: when the edited file is Rust, remind the model
# to apply the dd:rust:* convention skills. Emits only `systemMessage` — no
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
  *.rs)
    printf '{"systemMessage":"Editing Rust (%s) — apply the dd:rust:* conventions (error-handling, ownership, async, type-system, code-structure, comments: keep comments/doc-comments concise). Load the relevant skill if unsure."}' "$path"
    ;;
esac

exit 0
