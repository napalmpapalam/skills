#!/usr/bin/env bash
# A plugin's files changed but its version didn't → the install cache (keyed by
# version) won't re-sync on `/plugin` update. Bump the version in the same change.
# Primarily a local pre-push guard: it compares the working tree against
# origin/master. Skips cleanly when that baseline isn't available.
set -euo pipefail

MARKETPLACE=".claude-plugin/marketplace.json"
BASE="origin/master"

echo "Validating plugin versions were bumped on change..."

if ! git rev-parse --verify --quiet "$BASE" >/dev/null; then
  echo "⏭  No $BASE ref to compare against — skipping version-bump check"
  exit 0
fi

plugins=$(jq -r '.plugins[] | select(.source | type == "string") | .source' "$MARKETPLACE")
fail=0

for plugin_path in $plugins; do
  plugin_json="$plugin_path/.claude-plugin/plugin.json"

  # No changes vs baseline → nothing to check.
  if git diff --quiet "$BASE" -- "$plugin_path"; then
    continue
  fi

  new_version=$(jq -r '.version // empty' "$plugin_json")
  # Version at the baseline. If the file didn't exist there, this is a new
  # plugin — no bump needed.
  old_version=$(git show "$BASE:$plugin_json" 2>/dev/null | jq -r '.version // empty' 2>/dev/null || true)

  if [ -z "$old_version" ]; then
    echo "  ✓ $(basename "$plugin_path") is new (v$new_version)"
    continue
  fi

  if [ "$new_version" = "$old_version" ]; then
    echo "✗ $(basename "$plugin_path") changed but version is still $new_version — bump it in .claude-plugin/plugin.json"
    fail=1
  else
    echo "  ✓ $(basename "$plugin_path") bumped $old_version → $new_version"
  fi
done

[ "$fail" -eq 0 ] || exit 1

echo ""
echo "✅ Changed plugins have bumped versions"
