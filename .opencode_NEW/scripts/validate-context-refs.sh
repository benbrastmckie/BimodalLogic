#!/usr/bin/env bash
# Context Reference Validation Script
# Task 327 - Validate all context file references
# Created: 2026-01-06

set -e

echo "=== Context Reference Validation Script ==="
echo "Task 327: Validate all context file references"
echo ""

# Find all context references in commands and agents
echo "Scanning for context references..."
REFS=$(grep -rh '"core/[^"]*\.md"' .opencode/command .opencode/agent 2>/dev/null | \
       sed 's/.*"\(core\/[^"]*\.md\)".*/\1/' | sort -u)

TOTAL=0
VALID=0
BROKEN=0

echo "Validating references..."
echo ""

while IFS= read -r ref; do
  TOTAL=$((TOTAL + 1))
  if [ -f ".opencode/context/$ref" ]; then
    VALID=$((VALID + 1))
    echo "✓ $ref"
  else
    BROKEN=$((BROKEN + 1))
    echo "✗ $ref (MISSING)"
  fi
done <<< "$REFS"

echo ""
echo "=== Validation Summary ==="
echo "Total references: $TOTAL"
echo "Valid references: $VALID"
echo "Broken references: $BROKEN"
echo ""

if [ "$BROKEN" -eq 0 ]; then
  echo "✓ SUCCESS: All context references are valid!"
  exit 0
else
  echo "✗ FAILURE: $BROKEN broken references found"
  exit 1
fi
