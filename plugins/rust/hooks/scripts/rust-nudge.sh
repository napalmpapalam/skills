#!/bin/sh
# UserPromptSubmit: in a Rust project, tell the model to load a dd:rust:* skill —
# and keep telling it until the transcript shows one was actually loaded.
#
# History: this was a PreToolUse (Write|Edit) hook emitting {"systemMessage":...}.
# systemMessage only reaches the user, and PreToolUse cannot return
# additionalContext at all, so the model never saw it. UserPromptSubmit stdout IS
# added as context, and firing per-turn also covers questions about Rust.
#
# That fixed delivery but not compliance: session 29e07441 received this nudge 20
# times and made 18 .rs edits without loading a single skill — "load the skill"
# loses to the model's belief that it already knows Rust. So the message now
# states the fact it is wrong about (the conventions are not in its context) and
# the hook goes silent once a skill is genuinely loaded, which also drops the
# per-turn token cost to zero for the rest of the session.

input=$(cat)

# Only in a Rust project — Cargo.toml in cwd or any ancestor.
dir=$PWD
while :; do
  [ -f "$dir/Cargo.toml" ] && break
  [ "$dir" = "/" ] || [ -z "$dir" ] && exit 0
  dir=$(dirname "$dir")
done

if command -v jq >/dev/null 2>&1; then
  transcript=$(printf '%s' "$input" | jq -r '.transcript_path // empty')
else
  transcript=$(printf '%s' "$input" | sed -n 's/.*"transcript_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
fi

# Match the Skill tool's own input, not prose. This script's message says
# `Skill(dd:rust:<area>)`, which deliberately does not match — otherwise the hook
# would read its own output back and silence itself on turn two.
if [ -n "$transcript" ] && grep -q '"skill":"dd:rust:' "$transcript" 2>/dev/null; then
  exit 0
fi

echo "No dd:rust:* skill has been loaded this session, so the Rust conventions are NOT in your context — you do not know them, and your defaults are not them. Call Skill(dd:rust:core) before the next Rust edit or answer about Rust — it carries types, error handling, ownership, async, module layout, style, and naming. Stack a topic skill on top when the task calls for it: comments, testing, serde, performance, linting."

exit 0
