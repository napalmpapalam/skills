#!/usr/bin/env bash
set -euo pipefail

MARKETPLACE=".claude-plugin/marketplace.json"

echo "Validating dd: naming convention..."

# Marketplace name: kebab-case (install identifier — no colons)
mp_name=$(jq -r '.name' "$MARKETPLACE")
if [[ ! "$mp_name" =~ ^[a-z0-9-]+$ ]]; then
  echo "✗ Marketplace name '$mp_name' must be lowercase kebab-case (no colons — it's an install id)"
  exit 1
fi
echo "✓ Marketplace name '$mp_name'"

plugin_count=$(jq '.plugins | length' "$MARKETPLACE")

for ((i=0; i<plugin_count; i++)); do
  entry_name=$(jq -r ".plugins[$i].name" "$MARKETPLACE")
  source=$(jq -r ".plugins[$i].source" "$MARKETPLACE")

  # Marketplace entry name: kebab-case (this is the install key — no colons)
  if [[ ! "$entry_name" =~ ^[a-z0-9-]+$ ]]; then
    echo "✗ Plugin entry '$entry_name': name must be lowercase kebab-case (it's the install key)"
    exit 1
  fi

  # plugin.json name must be dd:<entry_name> (colon here is safe; drives the command prefix)
  plugin_name="$entry_name"
  if [[ "$source" == /* || "$source" == ./* ]]; then
    plugin_json="$source/.claude-plugin/plugin.json"
    if [ -f "$plugin_json" ]; then
      pj_name=$(jq -r '.name' "$plugin_json")
      if [ "$pj_name" != "dd:$entry_name" ]; then
        echo "✗ Plugin '$entry_name': plugin.json name '$pj_name' must be 'dd:$entry_name'"
        exit 1
      fi
      plugin_name="$pj_name"
    fi
  fi
  echo "✓ Plugin entry '$entry_name' (plugin.json '$plugin_name')"

  # Each skill: dir kebab-case, and frontmatter name == <plugin.json name>:<dir>
  if [ -d "$source/skills" ]; then
    for skill_md in "$source"/skills/*/SKILL.md; do
      [ -e "$skill_md" ] || continue
      dir=$(basename "$(dirname "$skill_md")")
      if [[ ! "$dir" =~ ^[a-z0-9-]+$ ]]; then
        echo "✗ Skill dir '$dir': must be lowercase kebab-case"
        exit 1
      fi
      expected="$plugin_name:$dir"
      actual=$(sed -n 's/^name:[[:space:]]*//p' "$skill_md" | head -1 | tr -d '\r')
      if [ "$actual" != "$expected" ]; then
        echo "✗ Skill '$skill_md': name '$actual' must be '$expected'"
        exit 1
      fi
      echo "  ✓ Skill '$actual'"
    done
  fi
done

echo ""
echo "✅ Naming convention is valid"
