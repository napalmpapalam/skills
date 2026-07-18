#!/usr/bin/env bash
set -euo pipefail

MARKETPLACE=".claude-plugin/marketplace.json"

echo "Checking for duplicate plugin names..."

plugin_count=$(jq '.plugins | length' "$MARKETPLACE")

if [ "$plugin_count" -eq 0 ]; then
  echo "No plugins registered — skipping duplicate check"
  exit 0
fi

duplicates=$(jq -r '.plugins[].name' "$MARKETPLACE" | sort | uniq -d)

if [ -n "$duplicates" ]; then
  echo "✗ Duplicate plugin names found:"
  echo "$duplicates"
  exit 1
fi

echo "✓ No duplicate plugin names"
