#!/bin/bash
# Script to update library source paths to new subdirectory structure

cd /home/benjamin/.config

find .claude/commands .claude/agents .claude/tests .claude/lib -type f \( -name "*.md" -o -name "*.sh" \) | while read file; do
  # Core libraries
  sed -i 's|\.claude/lib/state-persistence\.sh|.claude/lib/core/state-persistence.sh|g' "$file"
  sed -i 's|\.claude/lib/error-handling\.sh|.claude/lib/core/error-handling.sh|g' "$file"
  sed -i 's|\.claude/lib/unified-location-detection\.sh|.claude/lib/core/unified-location-detection.sh|g' "$file"
  sed -i 's|\.claude/lib/detect-project-dir\.sh|.claude/lib/core/detect-project-dir.sh|g' "$file"
  sed -i 's|\.claude/lib/base-utils\.sh|.claude/lib/core/base-utils.sh|g' "$file"
  sed -i 's|\.claude/lib/library-sourcing\.sh|.claude/lib/core/library-sourcing.sh|g' "$file"
  sed -i 's|\.claude/lib/library-version-check\.sh|.claude/lib/core/library-version-check.sh|g' "$file"
  sed -i 's|\.claude/lib/unified-logger\.sh|.claude/lib/core/unified-logger.sh|g' "$file"

  # Workflow libraries
  sed -i 's|\.claude/lib/workflow-state-machine\.sh|.claude/lib/workflow/workflow-state-machine.sh|g' "$file"
  sed -i 's|\.claude/lib/workflow-initialization\.sh|.claude/lib/workflow/workflow-initialization.sh|g' "$file"
  sed -i 's|\.claude/lib/workflow-init\.sh|.claude/lib/workflow/workflow-init.sh|g' "$file"
  sed -i 's|\.claude/lib/workflow-scope-detection\.sh|.claude/lib/workflow/workflow-scope-detection.sh|g' "$file"
  sed -i 's|\.claude/lib/workflow-detection\.sh|.claude/lib/workflow/workflow-detection.sh|g' "$file"
  sed -i 's|\.claude/lib/workflow-llm-classifier\.sh|.claude/lib/workflow/workflow-llm-classifier.sh|g' "$file"
  sed -i 's|\.claude/lib/checkpoint-utils\.sh|.claude/lib/workflow/checkpoint-utils.sh|g' "$file"
  sed -i 's|\.claude/lib/argument-capture\.sh|.claude/lib/workflow/argument-capture.sh|g' "$file"
  sed -i 's|\.claude/lib/metadata-extraction\.sh|.claude/lib/workflow/metadata-extraction.sh|g' "$file"

  # Plan libraries
  sed -i 's|\.claude/lib/plan-core-bundle\.sh|.claude/lib/plan/plan-core-bundle.sh|g' "$file"
  sed -i 's|\.claude/lib/topic-utils\.sh|.claude/lib/plan/topic-utils.sh|g' "$file"
  sed -i 's|\.claude/lib/topic-decomposition\.sh|.claude/lib/plan/topic-decomposition.sh|g' "$file"
  sed -i 's|\.claude/lib/checkbox-utils\.sh|.claude/lib/plan/checkbox-utils.sh|g' "$file"
  sed -i 's|\.claude/lib/complexity-utils\.sh|.claude/lib/plan/complexity-utils.sh|g' "$file"
  sed -i 's|\.claude/lib/auto-analysis-utils\.sh|.claude/lib/plan/auto-analysis-utils.sh|g' "$file"
  sed -i 's|\.claude/lib/parse-template\.sh|.claude/lib/plan/parse-template.sh|g' "$file"

  # Artifact libraries
  sed -i 's|\.claude/lib/artifact-creation\.sh|.claude/lib/artifact/artifact-creation.sh|g' "$file"
  sed -i 's|\.claude/lib/artifact-registry\.sh|.claude/lib/artifact/artifact-registry.sh|g' "$file"
  sed -i 's|\.claude/lib/overview-synthesis\.sh|.claude/lib/artifact/overview-synthesis.sh|g' "$file"
  sed -i 's|\.claude/lib/substitute-variables\.sh|.claude/lib/artifact/substitute-variables.sh|g' "$file"
  sed -i 's|\.claude/lib/template-integration\.sh|.claude/lib/artifact/template-integration.sh|g' "$file"

  # Convert libraries
  sed -i 's|\.claude/lib/convert-core\.sh|.claude/lib/convert/convert-core.sh|g' "$file"
  sed -i 's|\.claude/lib/convert-docx\.sh|.claude/lib/convert/convert-docx.sh|g' "$file"
  sed -i 's|\.claude/lib/convert-pdf\.sh|.claude/lib/convert/convert-pdf.sh|g' "$file"
  sed -i 's|\.claude/lib/convert-markdown\.sh|.claude/lib/convert/convert-markdown.sh|g' "$file"

  # Util libraries
  sed -i 's|\.claude/lib/git-commit-utils\.sh|.claude/lib/util/git-commit-utils.sh|g' "$file"
  sed -i 's|\.claude/lib/optimize-claude-md\.sh|.claude/lib/util/optimize-claude-md.sh|g' "$file"
  sed -i 's|\.claude/lib/progress-dashboard\.sh|.claude/lib/util/progress-dashboard.sh|g' "$file"
  sed -i 's|\.claude/lib/detect-testing\.sh|.claude/lib/util/detect-testing.sh|g' "$file"
  sed -i 's|\.claude/lib/generate-testing-protocols\.sh|.claude/lib/util/generate-testing-protocols.sh|g' "$file"
  sed -i 's|\.claude/lib/backup-command-file\.sh|.claude/lib/util/backup-command-file.sh|g' "$file"
  sed -i 's|\.claude/lib/rollback-command-file\.sh|.claude/lib/util/rollback-command-file.sh|g' "$file"
  sed -i 's|\.claude/lib/validate-agent-invocation-pattern\.sh|.claude/lib/util/validate-agent-invocation-pattern.sh|g' "$file"
  sed -i 's|\.claude/lib/dependency-analyzer\.sh|.claude/lib/util/dependency-analyzer.sh|g' "$file"
done

echo "Completed source path updates"
