# Research Summary: Update /review Command to Create Summary Artifacts

- **Task**: 206 - Update /review command to create summaries in new project directories
- **Status**: [COMPLETED]
- **Started**: 2025-12-28
- **Completed**: 2025-12-28
- **Effort**: 2 hours
- **Priority**: Medium
- **Dependencies**: None
- **Artifacts**: 
  - reports/research-001.md
  - summaries/research-summary.md (this file)
- **Standards**: status-markers.md, artifact-management.md, summary.md, subagent-return-format.md

---

## Overview

The /review command currently updates registries and creates tasks but lacks artifact management and has no documented reviewer subagent. Implementation requires creating reviewer subagent specification, adding lazy project directory creation, generating review summary artifacts in summaries/ subdirectory, and standardizing return format to protect context window.

## What Changed

Research identified the following gaps and requirements:
- Reviewer subagent does not exist as documented agent (critical blocker)
- No project directory creation in current /review workflow
- No review summary artifact generation
- Verbose return format bloats orchestrator context window
- state.json lacks review artifact tracking

## Decisions

Key decisions for implementation:
- Create reviewer subagent specification following subagent-return-format.md
- Use lazy directory creation (project root + summaries/ only when writing)
- Follow summary.md standard (3-5 sentences, <100 tokens)
- Return only brief summary + artifact path (not full content)
- Track review artifacts in state.json repository_health section (not TODO.md)
- Project naming: NNN_codebase_review

## Impacts

Implementation will:
- Provide persistent review summaries in standardized project directories
- Enable historical tracking of repository reviews
- Protect orchestrator context window from verbose review output (90-95% reduction)
- Align /review with artifact management standards
- Require state.json schema update (backward compatible)

## Follow-ups

Implementation tasks (4-5 hours total):
- Phase 1: Create reviewer subagent specification (1.5 hours)
- Phase 2: Update /review command with artifact creation (1.5 hours)
- Phase 3: Update state.json schema with review_artifacts (0.5 hours)
- Phase 4: Testing and validation (0.5 hours)
- Phase 5: Documentation updates (1 hour)

Main risk: Reviewer subagent behavior undefined, requires specification from scratch.

## References

- Research Report: .opencode/specs/206_update_review_command_summaries/reports/research-001.md
- Current /review Command: .opencode/command/review.md
- Artifact Management: .opencode/context/core/system/artifact-management.md
- Return Format Standard: .opencode/context/core/standards/subagent-return-format.md
- Summary Standard: .opencode/context/core/standards/summary.md
- Reference Implementation: .opencode/command/research.md
