#!/bin/bash
# Context Reference Update Script
# Task 327 - Fix broken context file references
# Created: 2026-01-06

set -e

echo "=== Context Reference Update Script ==="
echo "Task 327: Fix broken context file references"
echo ""

# Count initial broken references
echo "Counting initial broken references..."
INITIAL_COUNT=$(grep -r "core/system/" .opencode/command .opencode/agent 2>/dev/null | grep -v "status-markers.md" | wc -l)
echo "Initial broken references (excluding status-markers.md): $INITIAL_COUNT"
echo ""

# Fix 1: core/system/state-management.md → core/orchestration/state-management.md
echo "Fix 1: Updating core/system/state-management.md → core/orchestration/state-management.md"
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/system/state-management\.md|core/orchestration/state-management.md|g' {} +

# Fix 2: core/system/routing-guide.md → core/orchestration/routing.md
echo "Fix 2: Updating core/system/routing-guide.md → core/orchestration/routing.md"
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/system/routing-guide\.md|core/orchestration/routing.md|g' {} +

# Fix 3: core/system/artifact-management.md → core/orchestration/state-management.md
echo "Fix 3: Updating core/system/artifact-management.md → core/orchestration/state-management.md"
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/system/artifact-management\.md|core/orchestration/state-management.md|g' {} +

# Fix 4: core/system/git-commits.md → core/standards/git-safety.md
echo "Fix 4: Updating core/system/git-commits.md → core/standards/git-safety.md"
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/system/git-commits\.md|core/standards/git-safety.md|g' {} +

# Fix 5: core/system/state-lookup.md → core/orchestration/state-lookup.md
echo "Fix 5: Updating core/system/state-lookup.md → core/orchestration/state-lookup.md"
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/system/state-lookup\.md|core/orchestration/state-lookup.md|g' {} +

# Fix 6: core/standards/command-argument-handling.md → DELETE
echo "Fix 6: Deleting references to core/standards/command-argument-handling.md"
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  '/core\/standards\/command-argument-handling\.md/d' {} +

# Fix 7: core/standards/plan.md → core/formats/plan-format.md
echo "Fix 7: Updating core/standards/plan.md → core/formats/plan-format.md"
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/standards/plan\.md|core/formats/plan-format.md|g' {} +

# Fix 8: core/standards/subagent-return-format.md → core/formats/subagent-return.md
echo "Fix 8: Updating core/standards/subagent-return-format.md → core/formats/subagent-return.md"
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/standards/subagent-return-format\.md|core/formats/subagent-return.md|g' {} +

# Fix 9: core/standards/architecture-principles.md → project/meta/architecture-principles.md
echo "Fix 9: Updating core/standards/architecture-principles.md → project/meta/architecture-principles.md"
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/standards/architecture-principles\.md|project/meta/architecture-principles.md|g' {} +

# Fix 10: core/standards/domain-patterns.md → project/meta/domain-patterns.md
echo "Fix 10: Updating core/standards/domain-patterns.md → project/meta/domain-patterns.md"
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/standards/domain-patterns\.md|project/meta/domain-patterns.md|g' {} +

# Fix 11: core/workflows/interview-patterns.md → project/meta/interview-patterns.md
echo "Fix 11: Updating core/workflows/interview-patterns.md → project/meta/interview-patterns.md"
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/workflows/interview-patterns\.md|project/meta/interview-patterns.md|g' {} +

# Fix 12: core/templates/agent-templates.md → core/templates/agent-template.md
echo "Fix 12: Updating core/templates/agent-templates.md → core/templates/agent-template.md"
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/templates/agent-templates\.md|core/templates/agent-template.md|g' {} +

# Fix 13: core/workflow/postflight-pattern.md → core/workflows/postflight-pattern.md
echo "Fix 13: Updating core/workflow/postflight-pattern.md → core/workflows/postflight-pattern.md"
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/workflow/postflight-pattern\.md|core/workflows/postflight-pattern.md|g' {} +

echo ""
echo "=== Update Complete ==="
echo ""

# Count remaining broken references
echo "Counting remaining broken references..."
FINAL_COUNT=$(grep -r "core/system/" .opencode/command .opencode/agent 2>/dev/null | grep -v "status-markers.md" | wc -l)
echo "Remaining broken references (excluding status-markers.md): $FINAL_COUNT"
echo ""

if [ "$FINAL_COUNT" -eq 0 ]; then
  echo "✓ SUCCESS: All broken references fixed!"
else
  echo "⚠ WARNING: $FINAL_COUNT broken references remain"
  echo ""
  echo "Remaining references:"
  grep -r "core/system/" .opencode/command .opencode/agent 2>/dev/null | grep -v "status-markers.md"
fi

echo ""
echo "Files updated: $INITIAL_COUNT → $FINAL_COUNT broken references"
