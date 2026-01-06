#!/bin/bash
# update-context-refs.sh
# Update all @ references to new context paths

echo "Updating context references..."

# Define reference mappings (old_path → new_path)
declare -A ref_map=(
  # Orchestration files
  ["standards/delegation.md"]="orchestration/delegation.md"
  ["workflows/delegation-guide.md"]="orchestration/delegation.md"
  ["system/orchestrator-design.md"]="orchestration/orchestrator.md"
  ["system/orchestrator-guide.md"]="orchestration/orchestrator.md"
  ["system/routing-guide.md"]="orchestration/routing.md"
  ["system/routing-logic.md"]="orchestration/routing.md"
  ["system/validation-strategy.md"]="orchestration/validation.md"
  ["system/validation-rules.md"]="orchestration/validation.md"
  ["system/state-management.md"]="orchestration/state-management.md"
  ["system/artifact-management.md"]="orchestration/state-management.md"
  ["system/state-lookup.md"]="orchestration/state-lookup.md"
  ["workflows/sessions.md"]="orchestration/sessions.md"
  
  # Format files
  ["standards/subagent-return-format.md"]="formats/subagent-return.md"
  ["standards/command-output.md"]="formats/command-output.md"
  ["standards/plan.md"]="formats/plan-format.md"
  ["standards/report.md"]="formats/report-format.md"
  ["standards/summary.md"]="formats/summary-format.md"
  ["standards/frontmatter-standard.md"]="formats/frontmatter.md"
  
  # Standards files
  ["standards/code.md"]="standards/code-patterns.md"
  ["standards/patterns.md"]="standards/code-patterns.md"
  ["standards/tests.md"]="standards/testing.md"
  ["standards/xml-patterns.md"]="standards/xml-structure.md"
  ["standards/tasks.md"]="standards/task-management.md"
  ["standards/analysis.md"]="standards/analysis-framework.md"
  
  # Workflow files
  ["workflows/review.md"]="workflows/review-process.md"
  
  # Template files
  ["templates/agent-templates.md"]="templates/agent-template.md"
  ["templates/delegation-context-template.md"]="templates/delegation-context.md"
  ["templates/subagent-frontmatter-template.yaml"]="schemas/subagent-frontmatter.yaml"
)

# Update references in agent files
echo "Updating agent files..."
for old_path in "${!ref_map[@]}"; do
  new_path="${ref_map[$old_path]}"
  echo "  $old_path → $new_path"
  
  find .opencode/agent -name "*.md" -type f -exec sed -i \
    "s|@.opencode/context/core/$old_path|@.opencode/context/core/$new_path|g" {} \;
done

# Update references in command files
echo "Updating command files..."
for old_path in "${!ref_map[@]}"; do
  new_path="${ref_map[$old_path]}"
  
  find .opencode/command -name "*.md" -type f -exec sed -i \
    "s|@.opencode/context/core/$old_path|@.opencode/context/core/$new_path|g" {} \;
done

# Update references in context files
echo "Updating context files..."
for old_path in "${!ref_map[@]}"; do
  new_path="${ref_map[$old_path]}"
  
  find .opencode/context -name "*.md" -type f -exec sed -i \
    "s|@.opencode/context/core/$old_path|@.opencode/context/core/$new_path|g" {} \;
done

echo "Reference updates complete!"
echo ""
echo "Verifying no old references remain..."
old_ref_count=$(grep -r "@.opencode/context/core/system/" .opencode/agent .opencode/command .opencode/context 2>/dev/null | wc -l)
echo "Old system/ references remaining: $old_ref_count"

old_standards_count=$(grep -r "@.opencode/context/core/standards/delegation.md" .opencode/agent .opencode/command .opencode/context 2>/dev/null | wc -l)
echo "Old standards/delegation.md references remaining: $old_standards_count"

echo ""
echo "Done!"
