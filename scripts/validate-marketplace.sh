#!/usr/bin/env bash
set -euo pipefail

MARKETPLACE=".claude-plugin/marketplace.json"

echo "Validating marketplace.json..."

# Validate JSON syntax
if ! jq empty "$MARKETPLACE" 2>/dev/null; then
  echo "✗ Invalid JSON in $MARKETPLACE"
  exit 1
fi
echo "✓ Marketplace JSON is valid"

echo "Checking required marketplace fields..."

if ! jq -e ".name" "$MARKETPLACE" > /dev/null; then
  echo "✗ Missing required field: name"
  exit 1
fi
echo "✓ Field 'name' present"

if ! jq -e ".owner" "$MARKETPLACE" > /dev/null; then
  echo "✗ Missing required field: owner"
  exit 1
fi
echo "✓ Field 'owner' present"

if ! jq -e ".owner.name" "$MARKETPLACE" > /dev/null; then
  echo "✗ Missing required field: owner.name"
  exit 1
fi
echo "✓ Field 'owner.name' present"

if ! jq -e ".plugins" "$MARKETPLACE" > /dev/null; then
  echo "✗ Missing required field: plugins"
  exit 1
fi
echo "✓ Field 'plugins' present"

if ! jq -e '.plugins | type == "array"' "$MARKETPLACE" > /dev/null; then
  echo "✗ Field 'plugins' must be an array"
  exit 1
fi
echo "✓ Field 'plugins' is an array"

echo ""
echo "✅ Marketplace structure is valid"
