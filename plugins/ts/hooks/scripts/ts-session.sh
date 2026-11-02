#!/bin/sh
# SessionStart: in a TypeScript project (a tsconfig.json in cwd or any ancestor),
# tell the model once that the dd:ts:* conventions govern all TypeScript.
# Plain stdout: SessionStart adds it as context, systemMessage would reach only the user.

dir=$PWD
while [ -n "$dir" ]; do
  if [ -f "$dir/tsconfig.json" ]; then
    cat <<'MSG'
This is a TypeScript project — the dd:ts:* conventions govern all TypeScript you write AND
any answer about what a TypeScript change would do. dd:ts:core is the default: blank-line
layout, DRY, control flow, types and enums, zod at boundaries, errors, async, module state,
logging, files and imports, comments, naming. Testing, tooling, and library (published
packages only) stack on top. Load the relevant skill when reasoning about TypeScript, not
only when editing.
MSG
    break
  fi
  [ "$dir" = "/" ] && break
  dir=$(dirname "$dir")
done

exit 0
