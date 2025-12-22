# Implementation Plan: Allow /task to run without linked plan when none exists

**Project**: #116  
**Version**: implementation-001  
**Date**: 2025-12-22  
**Complexity**: Moderate  
**Effort**: 2–3 hours

## Overview
Enable `/task` to execute when a TODO entry lacks a linked plan by allowing direct execution while preserving lazy directory creation, numbering/state synchronization, and plan reuse when present. Update standards, schema references, and regression coverage to reflect the new behavior without breaking existing plan-present flows.

## Goals
- Permit `/task` execution when no plan link is present, with no failures.
- Preserve lazy directory creation and existing numbering/state sync rules.
- Keep plan-present behavior unchanged (reuse and update attached plan link).
- Update standards and schema documentation to codify the new behavior and guardrails.
- Add regression coverage for plan-present and plan-absent execution paths.

## Non-Goals
- Changing `/implement` or `/plan` contracts beyond consistency notes.
- Altering task numbering or status marker semantics.
- Introducing new artifact types or directory structures.

## Scope
- Update `/task` command contract and flow to allow plan-absent execution while retaining lazy creation safeguards.
- Align documentation (tasks.md, state-schema references, task command doc/snippets) with the new contract.
- Ensure TODO/state synchronization rules stay consistent for both plan-present and plan-absent runs.
- Add regression tests covering plan-present vs plan-absent paths, including numbering/state sync and lazy directory creation.

## Assumptions
- No research inputs are linked for this task.
- Current numbering/state sync rules and status markers remain authoritative.
- Global state updates are coordinated externally; project state is maintained alongside artifacts when produced.

## Research Inputs
- None linked (per TODO entry).

## Risks & Mitigations
- **Regression in plan-present path**: Add explicit tests to assert reuse of existing plan link and unchanged behavior.
- **Accidental eager directory creation**: Keep explicit guard clauses and tests for absence of project dirs when no artifacts are written.
- **State/TODO drift**: Mirror updates in both documents during flow changes; include verification steps.

## Acceptance Criteria Mapping
- AC1: Plan-absent execution path implemented in `/task`; flow enforces lazy creation (no project dirs unless artifacts are written) and passes regression tests.
- AC2: State/TODO updates reuse numbering rules; pending/active status markers and timestamps stay in sync across TODO/state.
- AC3: Plan-present path continues reusing the existing plan link unchanged; regression tests cover this.
- AC4: Documentation updated (tasks.md, state-schema references, task command doc/snippets) describing new behavior and guardrails.
- AC5: Regression coverage added for plan-present and plan-absent paths, including lazy directory creation and numbering/state sync.

## Work Plan (phased, with estimates & verification)
- **Phase 0 – Orientation [COMPLETED]** (Started: 2025-12-23T00:08:00Z, Completed: 2025-12-23T00:10:00Z)
  - Review current `/task` contract and standards (tasks.md, task.md command doc, artifact-management, state-schema, TODO entry #116).
  - Verification: Notes compiled; no file changes.

- **Phase 1 – Contract & Docs Update [COMPLETED]** (Started: 2025-12-23T00:10:00Z, Completed: 2025-12-23T00:20:00Z)
  - Update `tasks.md` command integration section to allow plan-absent execution while retaining plan reuse when linked and lazy creation rules.
  - Add guardrails and guidance for numbering/state sync and status marker mirroring.
  - Verification: Text reflects new behavior; plan-present reuse preserved in wording.

- **Phase 2 – Command Flow Adjustment [COMPLETED]** (Started: 2025-12-23T00:20:00Z, Completed: 2025-12-23T00:30:00Z)
  - Modify `/task` flow in `.opencode/command/task.md` to remove fail-fast on missing plan link and define direct execution path with lazy creation checks.
  - Ensure plan-present path continues to reuse attached plan; enforce no directory creation unless writing artifacts.
  - Verification: Flow steps updated; references to plan requirement adjusted; lazy creation steps explicit.

- **Phase 3 – State/Schema Alignment [COMPLETED]** (Started: 2025-12-23T00:30:00Z, Completed: 2025-12-23T00:35:00Z)
  - Update `.opencode/context/common/system/state-schema.md` references (if needed) to clarify plan-absent `/task` execution and state sync expectations.
  - Ensure any examples/TODO snippets remain numbering-rule compliant.
  - Verification: Schema notes consistent with new contract; numbering/state sync language intact.

- **Phase 4 – Regression Coverage [COMPLETED]** (Started: 2025-12-23T00:35:00Z, Completed: 2025-12-23T00:45:00Z)
  - Add/adjust tests to cover: (a) plan-present execution reuses existing plan link, updates statuses; (b) plan-absent execution proceeds, no project dirs created when no artifacts are written, numbering/state sync maintained.
  - Include lazy directory creation checks and status marker mirror checks.
  - Verification: Tests present and scoped to both paths.

- **Phase 5 – Validation & Polish [COMPLETED]** (Started: 2025-12-23T00:45:00Z, Completed: 2025-12-23T00:50:00Z)
  - Cross-check TODO/state update rules and acceptance criteria mapping.
  - Quick read-through for consistency and no-emojis compliance.
  - Verification: Checklist completed; ACs traced.

_Total estimated effort: ~2–3 hours._

## Testing & Regression Strategy
- Add tests for `/task` plan-present path: ensures attached plan path is reused, status markers mirrored, numbering/state updates consistent, no unintended directory creation beyond required artifacts.
- Add tests for `/task` plan-absent path: task executes, no failure; no project directory or subdirs created when no artifacts are produced; state/TODO updates remain in sync.
- Validate lazy directory creation guards in both paths (no root/subdir creation until artifact writes occur).
- Validate numbering/state sync: task IDs drawn from TODO/state entries; pending/active markers mirrored.
- If applicable, update any command help or workflow specs to reference new behavior without altering unrelated commands.

## Rollout & Backward Compatibility
- Plan-present behavior remains unchanged; existing users with linked plans see no flow change.
- Plan-absent behavior now executes instead of failing, with safeguards to prevent unintended directory creation.
- No changes to numbering, status markers, or artifact naming conventions.

## Documentation Updates
- `.opencode/context/common/standards/tasks.md`: Revise `/task` contract to allow plan-absent execution, note lazy creation and plan reuse.
- `.opencode/command/task.md`: Update workflow steps and usage notes to reflect new behavior and guardrails.
- `.opencode/context/common/system/state-schema.md`: Clarify state/TODO sync expectations for plan-absent executions (if needed) and numbering rules.
- `.opencode/specs/TODO.md`: Ensure examples/snippets remain accurate if referenced in docs.

## Open Questions
- Should `/task` emit explicit guidance when running plan-absent (e.g., recommending `/plan` for complex tasks), or stay silent? (Default: brief informational note only.)
- Are there existing test harness utilities for lazy directory creation checks to reuse, or should lightweight new checks be added?

## Success Criteria
- Plan-absent `/task` execution works without failures and without premature directory creation.
- Plan-present flow continues to reuse and update the existing plan link.
- Documentation reflects the new contract and guardrails.
- Regression tests cover both plan-present and plan-absent paths, including lazy directory creation and numbering/state sync.
