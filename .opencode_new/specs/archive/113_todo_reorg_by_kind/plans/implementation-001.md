# Implementation Plan: Enhance /todo to reorganize pending tasks by kind while preserving numbering
- **Task**: 113 - Enhance /todo to reorganize pending tasks by kind while preserving numbering
- **Status**: [COMPLETED]
- **Started**: 2025-12-22T21:25:00Z
- **Completed**: 2025-12-22T21:45:00Z
- **Effort**: 3 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: None (reuses existing TODO/task standards)
- **Artifacts**: plans/implementation-001.md, summaries/implementation-summary-20251222.md
- **Standards**: status-markers.md, tasks.md, artifact-management.md, plan/report/summary standards

## Overview
Update /todo behavior and task standards so pending tasks can be grouped by kind (feature, documentation, maintenance, research) without changing task numbers or creating project directories during reorganization.

## Goals & Non-Goals
- **Goals**: Define grouping rules, protect numbering, and add guidance to tasks standards. Ensure no artifacts/directories are created during reordering and cleanup flows remain intact.
- **Non-Goals**: Implement new command code beyond documentation-level guidance.

## Risks & Mitigations
- **Risk**: Numbering disrupted by reordering. **Mitigation:** Explicitly state numbering preservation and no renumbering.
- **Risk**: Command creates directories during maintenance. **Mitigation:** Document that reorg is metadata-only and directory creation is disallowed.

## Implementation Phases
### Phase 1: Requirements capture [COMPLETED]
- **Goal:** Clarify reorganization constraints and outputs.
- **Tasks:**
  - Confirm grouping by kind while keeping priorities and numbering intact.
  - Note prohibition on directory creation during reorg.
- **Started:** 2025-12-22T21:25:00Z
- **Completed:** 2025-12-22T21:32:00Z

### Phase 2: Standards update [COMPLETED]
- **Goal:** Document behavior in task standards.
- **Tasks:**
  - Update tasks.md to describe /todo regrouping rules and no-directory-creation guardrail.
  - Align status wording with status markers and lazy creation practices.
- **Started:** 2025-12-22T21:32:00Z
- **Completed:** 2025-12-22T21:40:00Z

### Phase 3: Validation [COMPLETED]
- **Goal:** Ensure guidance is clear and actionable.
- **Tasks:**
  - Check that numbering preservation is explicit.
  - Confirm no emojis are present.
- **Started:** 2025-12-22T21:40:00Z
- **Completed:** 2025-12-22T21:45:00Z

## Testing & Validation
- Verify tasks.md states regrouping rules and numbering preservation.
- Confirm guidance forbids project directory creation during /todo reorg.
- Ensure status markers and timestamps remain standard.

## Artifacts & Outputs
- Updated tasks standard capturing reorg rules.
- This plan and the implementation summary.

## Rollback/Contingency
Revert documentation changes if regrouping behavior changes.
