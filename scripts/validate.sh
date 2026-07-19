#!/usr/bin/env bash
# Runs every marketplace/plugin validation script. Stops on the first failure.
set -euo pipefail

cd "$(dirname "$0")/.."

for s in \
  validate-marketplace.sh \
  validate-plugin-entries.sh \
  validate-plugins.sh \
  check-duplicates.sh \
  validate-naming.sh \
  validate-readme-skills.sh \
  validate-versions.sh
do
  echo "▶ scripts/$s"
  bash "scripts/$s"
  echo
done

echo "✅ All validations passed"
