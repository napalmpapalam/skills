#!/bin/sh
# SessionStart: if the session opened in a Rust project (a Cargo.toml in cwd or
# any ancestor), prime the model once that the dd:rust:* conventions govern all
# Rust — not only edits, but also any reasoning about what a Rust change would
# do. Catches hypotheticals ("if I changed this, what happens?").
#
# Emits PLAIN STDOUT, not {"systemMessage":...}: for SessionStart stdout is added
# as context the model sees, whereas systemMessage is only a warning shown to the
# user — the model never reads it.

dir=$PWD
while [ -n "$dir" ]; do
  if [ -f "$dir/Cargo.toml" ]; then
    cat <<'EOF'
This is a Rust project — the dd:rust:* conventions govern all Rust you write AND
any answer about what a Rust change would do (error-handling, ownership, async,
type-system, code-structure, comments: keep comments and doc-comments concise).
Load the relevant skill when reasoning about Rust, not only when editing.
EOF
    break
  fi
  [ "$dir" = "/" ] && break
  dir=$(dirname "$dir")
done

exit 0
