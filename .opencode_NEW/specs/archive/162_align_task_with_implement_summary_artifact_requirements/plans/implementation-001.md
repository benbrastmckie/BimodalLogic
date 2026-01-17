# Plan: Align /task with /implement summary artifact requirements (Task 162)

- **Status**: [PLANNED]
- **Started**: 2025-12-24
- **Completed**: 2025-12-24
- **lean**: false
- **Language**: markdown
- **Effort**: 2 hours
- **Priority**: Medium
- **Task ID**: 162

## Research Inputs
- [specs/162_align_task_with_implement_summary_artifact_requirements/reports/research-001.md](../reports/research-001.md)

## Overview
Ensure /task enforces implementation summary artifact parity with /implement while preserving lazy directory creation, atomic status synchronization, and registry updates only when implementation work occurs.

## Goals and Non-Goals
- **Goals**:
  - Require summaries for /task implementation paths when artifacts are produced.
  - Preserve lazy directory creation and avoid summaries during status-only or dry-run paths.
  - Keep TODO/state/plan in sync with summary links and registry updates when implementation status changes.
- **Non-Goals**:
  - Changing summary format or naming conventions.
  - Modifying /implement behavior (use as reference only).

## Risks and Constraints
- Avoid summary creation when no artifacts are produced (status-only or dry-run).
- Maintain atomic TODO/state/plan updates to prevent divergence.
- Respect Language metadata routing (non-Lean here).

## Phases and Tasks

### Phase 1: Define parity rules and triggers [NOT STARTED]
(Goal: Specify when summaries are required and when they are not)
- [ ] Document summary emission triggers for /task (implementation work only; skip status-only/dry-run).
- [ ] Align naming/location with artifact-management (`summaries/implementation-summary-YYYYMMDD.md`).
- [ ] Add guidance on Language metadata routing and lazy-creation guards.

### Phase 2: Wire executor/orchestrator hooks [NOT STARTED]
(Goal: Enforce summary creation in /task implementation paths)
- [ ] In `task-executor`, add post-implementation hook to require summary emission when artifacts are produced; pass Language/summary-needed flags to implementation-orchestrator.
- [ ] In `implementation-orchestrator`, expose reusable summary writer for /task delegations; ensure no summary on dry-run/status-only paths.
- [ ] Ensure summary path is captured and returned for TODO/state linking.

### Phase 3: Status/registry synchronization [NOT STARTED]
(Goal: Keep markers and registries consistent)
- [ ] Update TODO/state/plan flows to record summary links atomically when summaries are produced.
- [ ] Trigger IMPLEMENTATION_STATUS / SORRY_REGISTRY / TACTIC_REGISTRY updates only when implementation status or sorry/tactic counts change.
- [ ] Preserve lazy directory creation (no new roots/subdirs unless writing summary).

### Phase 4: Documentation and tests [NOT STARTED]
(Goal: Cover the new parity behavior)
- [ ] Update docs: `/command/task.md`, `task-executor.md`, `implementation-orchestrator.md`, and relevant standards (commands/tasks/artifact-management) to state summary parity and guardrails.
- [ ] Add routing-check/tests: implementation with artifacts → summary created and linked; status-only/dry-run → no summary; lazy creation respected.
- [ ] Capture regression checks for Language metadata handling and summary naming.

## Testing Strategy
- Unit/flow tests for executor/orchestrator summary hook triggering conditions.
- Routing-check or dry-run coverage to confirm no summaries/directories on preview paths.
- Verification of TODO/state/plan updates containing summary links after implementation with artifacts.

## Success Criteria
- /task implementation paths produce implementation summaries whenever artifacts are written, using standard naming.
- No summaries are created for status-only or dry-run flows; lazy-creation is preserved.
- TODO/state/plan (and registries when applicable) are updated atomically with summary links.
- Documentation and tests reflect the new parity behavior.
