#!/usr/bin/env bash
set -euo pipefail

MARKETPLACE=".claude-plugin/marketplace.json"

echo "Validating marketplace plugin entries..."

plugin_count=$(jq '.plugins | length' "$MARKETPLACE")

if [ "$plugin_count" -eq 0 ]; then
  echo "No plugins registered — skipping entry validation"
  exit 0
fi

for ((i=0; i<plugin_count; i++)); do
  echo ""
  echo "Checking marketplace entry $((i+1))..."

  if ! jq -e ".plugins[$i].name" "$MARKETPLACE" > /dev/null; then
    echo "✗ Plugin entry $((i+1)): Missing required field 'name'"
    exit 1
  fi

  if ! jq -e ".plugins[$i].source" "$MARKETPLACE" > /dev/null; then
    echo "✗ Plugin entry $((i+1)): Missing required field 'source'"
    exit 1
  fi

  if jq -e ".plugins[$i].author" "$MARKETPLACE" > /dev/null 2>&1; then
    if ! jq -e ".plugins[$i].author | type == \"object\"" "$MARKETPLACE" > /dev/null; then
      echo "✗ Plugin entry $((i+1)): Field 'author' must be an object"
      exit 1
    fi
    if ! jq -e ".plugins[$i].author.name" "$MARKETPLACE" > /dev/null; then
      echo "✗ Plugin entry $((i+1)): Field 'author.name' is required when 'author' is present"
      exit 1
    fi
    echo "✓ Plugin entry $((i+1)): Field 'author' is properly formatted"
  fi

  plugin_name=$(jq -r ".plugins[$i].name" "$MARKETPLACE")
  echo "✓ Marketplace entry for '$plugin_name' is valid"
done

echo ""
echo "✅ All marketplace plugin entries are valid"
