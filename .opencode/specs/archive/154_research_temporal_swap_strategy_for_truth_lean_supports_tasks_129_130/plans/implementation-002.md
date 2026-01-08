# Implementation Plan: Branch B execution to obsolete tasks 129/130 (Lean)
- **Task**: 154 - Execute Branch B implementation to complete temporal swap work and retire tasks 129/130 via code changes
- **Status**: [IN PROGRESS]
- **Effort**: 3-4 hours
- **Started**: 2025-12-23T00:00:00Z
- **Priority**: High
- **Dependencies**: TODO tasks 129 & 130 entries; `Logos/Core/Semantics/Truth.lean` (TemporalDuality, `derivable_implies_swap_valid`, `truth_swap_of_valid_at_triple`, `valid_swap_of_valid`, time-shift helpers); `Logos/Core/Metalogic/Soundness.lean` (temporal_duality consumer of `derivable_implies_swap_valid`); tests in `LogosTest/Core/Semantics/TruthTest` and `LogosTest/Core/Metalogic/SoundnessTest`
- **Research Inputs**: `.opencode/specs/154_research_temporal_swap_strategy_for_truth_lean_supports_tasks_129_130/reports/research-001.md`, `.opencode/specs/154_research_temporal_swap_strategy_for_truth_lean_supports_tasks_129_130/reports/research-002.md`
- **Artifacts**: `.opencode/specs/154_research_temporal_swap_strategy_for_truth_lean_supports_tasks_129_130/plans/implementation-002.md` (this plan)
- **Standards**:
  - `.opencode/context/core/standards/plan.md`
  - `.opencode/context/core/standards/status-markers.md`
  - `.opencode/context/core/system/artifact-management.md`
  - `.opencode/context/core/standards/tasks.md`
- **Language**: lean
- **Lean Intent**: true
- **Revision Note**: Supersedes implementation-001.md. This version performs the Lean refactor and transport-lemma additions so tasks 129/130 can be abandoned after completion, instead of merely revising their TODO text.

## Overview
Implement Branch B directly in Lean: refactor `derivable_implies_swap_valid` to use IH/mutual IH (no global swap-validity axiom), add only domain-witnessed transport lemmas, and update `Soundness.lean` consumers. Deliver passing tests, then mark TODO tasks 129 and 130 as abandoned (fulfilled by task 154 implementation), with state/TODO sync.

## Research Inputs
- `.opencode/specs/154_research_temporal_swap_strategy_for_truth_lean_supports_tasks_129_130/reports/research-001.md`
- `.opencode/specs/154_research_temporal_swap_strategy_for_truth_lean_supports_tasks_129_130/reports/research-002.md`

## Goals & Non-Goals
- **Goals**: (1) Refactor temporal_duality proof to remove `valid_swap_of_valid`/`truth_swap_of_valid_at_triple` reliance using IH/mutual IH; (2) add local, domain-witnessed transport lemmas (reuse `TimeShift.time_shift_preserves_truth` family); (3) align `Soundness.lean` caller; (4) green tests; (5) update TODO/state to abandon tasks 129/130 as satisfied by this work.
- **Non-Goals**: No global `is_valid ↔ is_valid ∘ swap_past_future` lemma; no bi-infinite/translation-closed domain axioms; no semantics changes beyond the derivation-level refactor.

## Risks & Mitigations
- Hidden reliance on global swap validity: audit `Soundness.lean` temporal_duality branch and any downstream consumers; keep refactor minimal.
- Mutual IH complexity: keep paired IH returning both `is_valid φ` and `is_valid φ.swap` only where needed.
- Transport lemma scope creep: restrict to domain-witnessed helpers; avoid new frame axioms.

## Implementation Phases
### Phase 1: Refactor `Truth.lean` temporal_duality [NOT STARTED]
- **Goal:** Replace reliance on `valid_swap_of_valid` / `truth_swap_of_valid_at_triple` with IH/mutual IH and local transports.
- **Tasks:**
  - [ ] Rework the temporal_duality case of `derivable_implies_swap_valid` to consume IH (or a mutual lemma) yielding swapped validity directly.
  - [ ] Introduce minimal mutual/paired IH only if needed; ensure involutive swap closes the cycle.
  - [ ] Add narrowly scoped transport lemmas (past/future) with explicit domain witnesses, reusing `TimeShift.time_shift_preserves_truth`, `truth_history_eq`, `truth_double_shift_cancel`.
  - [ ] Remove remaining sorries tied to swap validity in `Truth.lean`.
- **Timing:** 1.5–2h
- **Verification:** `Truth.lean` builds; no new axioms; swap sorries removed.

### Phase 2: Align `Soundness.lean` consumer [NOT STARTED]
- **Goal:** Ensure soundness uses the refactored lemma without global swap assumptions.
- **Tasks:**
  - [ ] Update the temporal_duality branch to call the refactored lemma (adjust types if mutual IH used).
  - [ ] Confirm no hidden dependency on a global swap lemma remains.
- **Timing:** 0.5–1h
- **Verification:** `Soundness.lean` builds; no added axioms.

### Phase 3: Tests and validation [NOT STARTED]
- **Goal:** Prove refactor correctness via tests.
- **Tasks:**
  - [ ] Run `lake test LogosTest/Core/Semantics/TruthTest`.
  - [ ] Run `lake test LogosTest/Core/Metalogic/SoundnessTest`.
  - [ ] Add/adjust targeted transport-lemma tests if new helpers were added (e.g., in TaskFrameTest or a focused semantics test).
- **Timing:** 0.5h
- **Verification:** Tests pass; no regressions.

### Phase 4: TODO/state sync and retire tasks 129/130 [NOT STARTED]
- **Goal:** Mark tasks 129 and 130 as abandoned after this implementation delivers their outcomes.
- **Tasks:**
  - [ ] Update `.opencode/specs/TODO.md` to note that task 154 implementation supersedes tasks 129/130; set 129/130 status to [ABANDONED] with rationale and link to this plan and research.
  - [ ] Update `.opencode/specs/state.json` pending_tasks entries for 129/130 to `abandoned` with reasons; do not create new projects.
  - [ ] If a project state file exists for 154, append plan v2 and refresh timestamps; otherwise, keep state minimal per artifact-management.
- **Timing:** 0.5h
- **Verification:** TODO/state show 129/130 abandoned with rationale; task 154 remains tracked as the implementing work.

### Phase 5: Documentation touchpoints [NOT STARTED]
- **Goal:** Record the /revise outcome and swap-lemma resolution in project docs.
- **Tasks:**
  - [ ] Add a short note to `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md` about task 154 plan v2 executing Branch B and retiring 129/130.
  - [ ] Add a guardrail note to `Documentation/ProjectInfo/FEATURE_REGISTRY.md` under /revise plan versioning about plan v2 for task 154.
- **Timing:** 0.25h
- **Verification:** Notes present; no format drift.

## Testing & Validation
- [ ] `lake test LogosTest/Core/Semantics/TruthTest`
- [ ] `lake test LogosTest/Core/Metalogic/SoundnessTest`
- [ ] Targeted transport-lemma tests if new helpers added
- [ ] Confirm no global swap-validity lemma or new frame axioms introduced

## Artifacts & Outputs
- `.opencode/specs/154_research_temporal_swap_strategy_for_truth_lean_supports_tasks_129_130/plans/implementation-002.md`
- Updated TODO/state entries for tasks 129, 130 (abandoned after implementation), and task 154 plan link

## Rollback/Contingency
- If the refactor stalls, revert to implementation-001 guidance and keep 129/130 active; do not add global swap axioms. If mutual IH complicates proofs, fall back to single IH plus explicit transport lemmas and keep scope minimal.
