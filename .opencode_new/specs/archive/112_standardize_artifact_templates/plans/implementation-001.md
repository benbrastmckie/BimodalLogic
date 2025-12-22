# Implementation Plan: Standardize plan/report/summary artifact templates with status markers
- **Task**: 112 - Standardize plan/report/summary artifact templates with status markers
- **Status**: [COMPLETED]
- **Started**: 2025-12-22T21:05:00Z
- **Completed**: 2025-12-22T21:25:00Z
- **Effort**: 3 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: None (no prior templates in repository)
- **Artifacts**: plans/implementation-001.md, summaries/implementation-summary-20251222.md, standards/plan.md, standards/report.md, standards/summary.md
- **Standards**: status-markers.md, artifact-management.md, tasks.md

## Overview
Create authoritative standards for plan, report, and summary artifacts so all commands and agents load consistent templates that include status markers and align with lazy directory creation and no-emoji guidance.

## Goals & Non-Goals
- **Goals**: Add template standards with required metadata and status marker usage; wire references into artifact-management; ensure phases under `## Implementation Phases` use `###` with markers; keep templates text-only.
- **Non-Goals**: Modify runtime command code beyond documentation; add new commands.

## Risks & Mitigations
- **Risk**: Templates drift from status-markers. **Mitigation:** Link templates to status-markers.md and specify marker requirements explicitly.
- **Risk**: Commands ignore templates. **Mitigation:** Document loading expectations in artifact-management.md.

## Implementation Phases
### Phase 1: Template drafting [COMPLETED]
- **Goal:** Define plan, report, and summary structures with metadata requirements.
- **Tasks:**
  - Draft plan standard including status marker usage for phases.
  - Draft report standard with metadata and structured sections.
  - Draft summary standard with concise bullet structure.
- **Started:** 2025-12-22T21:05:00Z
- **Completed:** 2025-12-22T21:17:00Z

### Phase 2: Standards integration [COMPLETED]
- **Goal:** Connect templates to system standards and guardrails.
- **Tasks:**
  - Reference templates and status markers from artifact-management.md.
  - Ensure templates include lazy directory creation and no-emoji notes.
- **Started:** 2025-12-22T21:17:00Z
- **Completed:** 2025-12-22T21:22:00Z

### Phase 3: Validation [COMPLETED]
- **Goal:** Verify templates satisfy acceptance criteria.
- **Tasks:**
  - Confirm headings and status marker locations.
  - Check metadata completeness and examples.
  - Ensure text-only language.
- **Started:** 2025-12-22T21:22:00Z
- **Completed:** 2025-12-22T21:25:00Z

## Testing & Validation
- Spot-check templates for required sections and marker placement.
- Confirm artifact-management references the new standards.
- Verify examples avoid emojis and respect lazy directory creation.

## Artifacts & Outputs
- Plan, report, and summary standards under `.opencode/context/common/standards/`.
- This plan and implementation summary.

## Rollback/Contingency
Revert the new standard files and references if template approach changes.
