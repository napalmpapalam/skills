#!/usr/bin/env bash
set -euo pipefail

MARKETPLACE=".claude-plugin/marketplace.json"

echo "Validating plugin files..."

plugins=$(jq -r '.plugins[] | select(.source | type == "string") | .source' "$MARKETPLACE")

if [ -z "$plugins" ]; then
  echo "No local plugins to validate — skipping"
  exit 0
fi

for plugin_path in $plugins; do
  plugin_name=$(basename "$plugin_path")
  echo ""
  echo "Checking plugin: $plugin_name"
  echo "================================"

  if [ ! -d "$plugin_path" ]; then
    echo "✗ Directory not found: $plugin_path"
    exit 1
  fi
  echo "✓ Directory exists"

  plugin_json="$plugin_path/.claude-plugin/plugin.json"
  if [ ! -f "$plugin_json" ]; then
    echo "✗ plugin.json not found at $plugin_json"
    exit 1
  fi
  echo "✓ plugin.json exists"

  if ! jq empty "$plugin_json" 2>/dev/null; then
    echo "✗ Invalid JSON in $plugin_json"
    exit 1
  fi
  echo "✓ plugin.json is valid JSON"

  if ! jq -e ".name" "$plugin_json" > /dev/null; then
    echo "✗ Missing required field: name"
    exit 1
  fi
  echo "✓ Required field 'name' present"

  if jq -e ".author" "$plugin_json" > /dev/null 2>&1; then
    if ! jq -e '.author | type == "object"' "$plugin_json" > /dev/null; then
      echo "✗ Field 'author' must be an object with 'name' field"
      exit 1
    fi
    if ! jq -e ".author.name" "$plugin_json" > /dev/null; then
      echo "✗ Field 'author.name' is required when 'author' is present"
      exit 1
    fi
    echo "✓ Field 'author' is properly formatted"
  fi

  if jq -e ".repository" "$plugin_json" > /dev/null 2>&1; then
    if ! jq -e '.repository | type == "string"' "$plugin_json" > /dev/null; then
      echo "✗ Field 'repository' must be a string URL, not an object"
      exit 1
    fi
    echo "✓ Field 'repository' is properly formatted"
  fi

  if [ ! -f "$plugin_path/README.md" ]; then
    echo "⚠️  Warning: README.md not found (recommended)"
  else
    echo "✓ README.md exists"
  fi

  if [ -d "$plugin_path/commands" ]; then
    echo "✓ Commands directory exists"

    while IFS= read -r cmd_file; do
      [ -z "$cmd_file" ] && continue
      cmd_name=$(basename "$cmd_file")

      if head -n 1 "$cmd_file" | grep -q "^---$"; then
        echo "✓ Command '$cmd_name' has frontmatter"
      else
        echo "⚠️  Warning: Command '$cmd_name' missing frontmatter (recommended)"
      fi
    done < <(find "$plugin_path/commands" -name "*.md" 2>/dev/null)
  fi

  echo "✓ Plugin $plugin_name is valid"
done

echo ""
echo "================================"
echo "✅ All plugins validated successfully!"
