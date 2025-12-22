# Implementation Plan (Revised): Propose ModelBuilder architecture deltas based on Frame learnings

**Project**: #106  
**Version**: 002  
**Status**: [NOT STARTED]  
**Revision Prompt**: Draw on learnings from research-001 to improve the 106 plan.  
**Date**: 2025-12-22  
**Complexity**: Moderate (3 hours)

## Delta Summary (vs v001)
- Pulled concrete phase-wise deltas and effort/impact/risk from research-001 (even while Task 105 insights are pending) to tighten Step 2 outputs.
- Added explicit integration table to map deltas to tasks 91–104 with placeholders to replace once task scopes are confirmed.
- Strengthened validation/logging/provenance gates as cross-cutting requirements per research.
- Clarified assumptions and follow-up actions once Task 105 lands; kept directory creation lazy.

## Task Description
Translate Frame-derived insights (Task 105, pending) into concrete architecture deltas for ModelBuilder, using research-001 interim findings. Define structural changes, module interfaces, sequencing, and risk/effort/impact per phase (FLF, SRS, SMS, SCP, SRI). Deliver an architecture delta document and integration mapping to related tasks (91–104).

## Scope
- Apply research-001 deltas per phase and update with Task 105 outputs when available.
- Produce `architecture/architecture-delta-from-frame.md` with effort/impact/risk, rationale, dependencies, and provenance links.
- Add integration mapping to tasks 91–104 (update once scopes are confirmed).
- Update `docs/guides/pipeline_overview.md` references to the delta doc.
- Preserve lazy directory creation; do not create new project directories unless writing artifacts.

Out of scope: Implementing code changes; deep refactors beyond documented deltas.

## Assumptions
- Task 105 insights are pending; current deltas use research-001 assumptions and will be refreshed when Task 105 is available.
- Tasks 91–104 scopes are as listed in TODO.md; any mismatch will be called out.
- No runtime dependencies required (documentation-only deliverables).

## Dependencies
- **Primary**: Task 105 (Frame insights) — integrate when available.
- **Related**: Tasks 91–104 — integration mapping and sequencing dependencies.
- **Standards**: `task-breakdown.md`, `artifact-management.md`, `state-schema.md`, `patterns.md`, `tasks.md`, `status-markers.md`.

## Complexity Assessment
- Level: Moderate
- Estimated Effort: 3 hours
- Required Knowledge: Architecture design, ModelBuilder phase flow, research-001 deltas, tasks 91–104 scopes.
- Risks: Task 105 gaps (assumptions may shift); ambiguous scopes for 91–104; keeping provenance consistent.
- Mitigations: Flag assumptions, add follow-up actions, and keep delta doc structured for quick updates.

## Implementation Steps
### Step 1: Confirm inputs and assumptions
- **Action**: Re-read research-001; note any gaps due to missing Task 105 insights. Capture assumptions explicitly in the delta doc intro.
- **Files**: `reports/research-001.md`, (future) Task 105 artifacts.
- **Verification**: Assumptions list present; links to research-001 cited.

### Step 2: Draft phased architecture deltas (FLF, SRS, SMS, SCP, SRI) using research-001
- **Action**: For each phase, document current-state placeholder, proposed delta, rationale (Frame insight from research-001), effort (hrs), impact, risk + mitigation, and dependencies.
- **Files**: `architecture/architecture-delta-from-frame.md`.
- **Verification**: Each phase has effort/impact/risk/mitigation and a cited research-001 bullet.

### Step 3: Add integration mapping table to tasks 91–104
- **Action**: Create a table/bullets mapping each delta to relevant tasks 91–104; mark assumed mappings that need confirmation once scopes are validated.
- **Files**: `architecture/architecture-delta-from-frame.md`.
- **Verification**: Each phase lists at least one task link or explicitly says “none”; assumptions tagged.

### Step 4: Cross-cutting quality gates
- **Action**: Add section for validation gates, structured logging, provenance links, and lazy directory creation guardrails; propose middleware/utilities to reuse across phases.
- **Files**: `architecture/architecture-delta-from-frame.md`.
- **Verification**: Cross-cutting section present with ≥3 actionable gates tied to research-001.

### Step 5: Update pipeline overview references
- **Action**: Insert concise references in `docs/guides/pipeline_overview.md` pointing to `architecture/architecture-delta-from-frame.md` for phased deltas; avoid rewriting the guide.
- **Files**: `docs/guides/pipeline_overview.md`.
- **Verification**: Guide links to delta doc where phased changes are summarized.

### Step 6: Verification and gaps
- **Action**: Run acceptance checklist; note remaining gaps pending Task 105; ensure no directories are pre-created beyond artifact writes.
- **Files**: N/A (review).
- **Verification**: Checklist updated; assumptions and TODOs for Task 105 alignment captured.

## File Structure
```
architecture/
  architecture-delta-from-frame.md   # updated with phased deltas, effort/impact/risk, integration mapping, cross-cutting gates
docs/guides/
  pipeline_overview.md               # references delta doc
.opencode/specs/106_propose_modelbuilder_architecture_deltas_based_on_frame_learnings/
  plans/
    implementation-002.md            # this revised plan
    implementation-001.md            # prior plan (reference)
  reports/
    research-001.md
```

## Testing / Verification
- Content review against acceptance criteria and this plan’s verification bullets.
- Traceability: Each delta cites research-001 (and later Task 105) and maps to tasks 91–104 or states “none”.
- Guardrails: Confirm no new directories are created unless writing artifacts; paths remain within project directory.

## Verification Checkpoints
- [ ] Assumptions captured; research-001 cited; Task 105 gap noted.
- [ ] Phased deltas include effort/impact/risk/mitigation per research-001.
- [ ] Integration mapping to tasks 91–104 present with assumptions tagged.
- [ ] Cross-cutting gates documented (validation, logging, provenance, lazy dir creation).
- [ ] `architecture/architecture-delta-from-frame.md` updated.
- [ ] `docs/guides/pipeline_overview.md` references delta doc.
- [ ] Acceptance checklist completed; remaining gaps noted.

## Success Criteria
- Actionable, research-backed delta doc with phase-wise recommendations, effort/impact/risk, and mapped integration to tasks 91–104.
- Clear assumptions and follow-ups once Task 105 is available.
- Pipeline overview references the delta doc; guardrails on directory creation preserved.
