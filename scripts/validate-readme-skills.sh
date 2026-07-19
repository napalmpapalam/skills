#!/usr/bin/env bash
# Every skill must be listed in its plugin's README.md by its command
# (`<plugin.json name>:<skill-dir>`). Catches a skill added without a doc update.
set -euo pipefail

MARKETPLACE=".claude-plugin/marketplace.json"

ROOT_README="README.md"

echo "Validating the root README lists every plugin..."

# Every plugin (incl. hook-only ones with no skills) must appear in the root
# README's plugin table, by its backtick-wrapped marketplace name.
for name in $(jq -r '.plugins[].name' "$MARKETPLACE"); do
  if ! grep -qF "\`$name\`" "$ROOT_README"; then
    echo "✗ $ROOT_README is missing plugin '$name' — add it to the Available Plugins table"
    exit 1
  fi
  echo "  ✓ plugin '$name' listed in root README"
done

echo ""
echo "Validating each plugin README lists every skill..."

plugins=$(jq -r '.plugins[] | select(.source | type == "string") | .source' "$MARKETPLACE")

for plugin_path in $plugins; do
  skills_dir="$plugin_path/skills"
  [ -d "$skills_dir" ] || continue   # hook-only / command-only plugins: nothing to list

  plugin_json="$plugin_path/.claude-plugin/plugin.json"
  plugin_name=$(jq -r '.name' "$plugin_json")
  readme="$plugin_path/README.md"

  if [ ! -f "$readme" ]; then
    echo "✗ $plugin_path has skills but no README.md to list them"
    exit 1
  fi

  for skill_md in "$skills_dir"/*/SKILL.md; do
    [ -e "$skill_md" ] || continue
    dir=$(basename "$(dirname "$skill_md")")
    cmd="$plugin_name:$dir"
    if ! grep -qF "$cmd" "$readme"; then
      echo "✗ $readme is missing skill '$cmd' — add it to the skills list"
      exit 1
    fi
    echo "  ✓ $cmd listed in README"
  done
done

echo ""
echo "✅ Every skill is documented in its README"
