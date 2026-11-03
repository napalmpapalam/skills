#!/bin/sh
# UserPromptSubmit: in a TypeScript project, tell the model to load a dd:ts:* skill
# until the transcript shows a real Skill call — then go silent for the session.
# The message states a fact (the conventions are not in context), because a polite
# "load the skill" loses to the model's belief that it already knows the language.

input=$(cat)

# Only in a TypeScript project — tsconfig.json in cwd or any ancestor.
dir=$PWD
while :; do
  [ -f "$dir/tsconfig.json" ] && break
  [ "$dir" = "/" ] || [ -z "$dir" ] && exit 0
  dir=$(dirname "$dir")
done

if command -v jq >/dev/null 2>&1; then
  transcript=$(printf '%s' "$input" | jq -r '.transcript_path // empty')
else
  transcript=$(printf '%s' "$input" | sed -n 's/.*"transcript_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
fi

# Match the Skill tool's own input, not prose: this message says `Skill(dd:ts:core)`,
# which does not match, so the hook does not silence itself on turn two.
if [ -n "$transcript" ] && grep -q '"skill":"dd:ts:' "$transcript" 2>/dev/null; then
  exit 0
fi

echo "No dd:ts:* skill has been loaded this session, so the TypeScript conventions are NOT in your context — you do not know them, and your defaults are not them (your defaults put blank lines in the wrong places — a wall with none, or one after every statement — copy code instead of extracting it, and use as-const objects instead of enums). Call Skill(dd:ts:core) before the next TypeScript edit or answer about TypeScript. Stack a topic skill on top when the task calls for it: testing, tooling, library."

exit 0
