#!/bin/sh
# UserPromptSubmit: in a Rust project, re-inject a one-line reminder every turn.
#
# This used to be a PreToolUse (Write|Edit) hook emitting {"systemMessage":...}.
# Two things were wrong with that: systemMessage is only shown to the user, so
# the model never saw it; and PreToolUse cannot return additionalContext at all
# (per the hooks reference, only PostToolUse/Stop/SubagentStop can). UserPrompt-
# Submit stdout IS added as context, and firing per-turn also covers questions
# about Rust, not just edits.

dir=$PWD
while [ -n "$dir" ]; do
  if [ -f "$dir/Cargo.toml" ]; then
    echo "Rust project: before writing Rust or answering about it, load the matching dd:rust:* skill (error-handling, ownership, async, type-system, code-structure, testing, comments)."
    break
  fi
  [ "$dir" = "/" ] && break
  dir=$(dirname "$dir")
done

exit 0
