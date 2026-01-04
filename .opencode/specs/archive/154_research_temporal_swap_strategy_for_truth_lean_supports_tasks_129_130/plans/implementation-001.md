# Implementation Plan: Branch B guidance for temporal swap tasks 129/130
- **Task**: 154 - Produce Branch B implementation plan to add guiding instructions into TODO tasks 129 and 130 per research-002 (Lean)
- **Status**: [NOT STARTED]
- **Effort**: 1-2 hours
- **Priority**: High
- **Dependencies**: TODO tasks 129 & 130 entries; `Logos/Core/Semantics/Truth.lean` (TemporalDuality section, `truth_swap_of_valid_at_triple`, `valid_swap_of_valid`, time-shift helpers); `Logos/Core/Metalogic/Soundness.lean` (temporal_duality consumption of `derivable_implies_swap_valid`); existing `TimeShift.time_shift_preserves_truth` transport lemmas
- **Research Inputs**: `.opencode/specs/154_research_temporal_swap_strategy_for_truth_lean_supports_tasks_129_130/reports/research-001.md`, `.opencode/specs/154_research_temporal_swap_strategy_for_truth_lean_supports_tasks_129_130/reports/research-002.md`
- **Artifacts**: `.opencode/specs/154_research_temporal_swap_strategy_for_truth_lean_supports_tasks_129_130/plans/implementation-001.md` (this plan)
- **Standards**:
  - `.opencode/context/core/standards/plan.md`
  - `.opencode/context/core/system/status-markers.md`
  - `.opencode/context/core/system/artifact-management.md`
  - `.opencode/context/core/standards/tasks.md`
- **Language**: markdown
- **Lean Intent**: true

## Overview
Branch B only: avoid any global swap-validity axiom and instead guide Tasks 129 and 130 to use derivation-indexed induction (or mutual IH) and domain-witnessed transport lemmas. This plan produces actionable TODO guidance and a proof-adjustment outline for `Truth.lean` and `Soundness.lean`, ensuring testing and state synchronization steps are included. Success means TODO entries 129/130 instruct contributors to refactor `derivable_implies_swap_valid` using IH (no semantics change) and to add only local transport helpers, with test and status updates specified.

## Research Inputs
- `.opencode/specs/154_research_temporal_swap_strategy_for_truth_lean_supports_tasks_129_130/reports/research-001.md` (primary Branch B recommendation)
- `.opencode/specs/154_research_temporal_swap_strategy_for_truth_lean_supports_tasks_129_130/reports/research-002.md` (Branch A/B comparison; Branch B endorsed)

## Goals & Non-Goals
- **Goals**: Update TODO tasks 129/130 with precise Branch B guidance; outline proof refactor steps for `Truth.lean` (temporal_duality) and `Soundness.lean` consumers; include testing and state/TODO alignment steps; preserve current semantics (no new axioms).
- **Non-Goals**: Do not introduce or rely on a global `is_valid ↔ is_valid ∘ swap_past_future` lemma; do not add bi-infinite domain axioms; do not restructure semantics beyond the derivation-level refactor; do not create reports/summaries in this step.

## Risks & Mitigations
- Risk: Hidden reliance on swapped-validity in downstream proofs. **Mitigation**: Audit temporal_duality case consumers in `Soundness.lean`; keep refactor scoped and rerun Soundness/Truth tests.
- Risk: Mutual IH design could complicate proof obligations. **Mitigation**: Keep the IH paired only where needed (returning `is_valid φ` and `is_valid φ.swap`) and reuse existing `swap_axiom_*_valid` and `time_shift_preserves_truth` helpers.
- Risk: TODO/state drift. **Mitigation**: After updating tasks 129/130, sync status markers and research links in TODO/state.

## Implementation Phases
### Phase 1: Capture Branch B guidance for TODO tasks 129 & 130 [NOT STARTED]
- **Goal:** Ensure TODO entries direct contributors to the Branch B path (IH/mutual IH, local transport only) with explicit research links.
- **Tasks:**
  - [ ] Locate or create TODO entries 129 and 130; ensure numbering and headings match existing TODO format.
  - [ ] Add guidance: “Branch B only — refactor `derivable_implies_swap_valid` temporal_duality case to use IH (or mutual IH producing swapped/unswapped validity); remove reliance on `valid_swap_of_valid` / `truth_swap_of_valid_at_triple`; no global swap axiom.”
  - [ ] Add guidance for Task 130: “Add narrowly scoped, domain-witnessed transport lemmas using `TimeShift.time_shift_preserves_truth`; no bi-infinite domain assumption.”
  - [ ] Link both research inputs (research-001.md, research-002.md) in each task and mark Lean intent true; keep status markers consistent with TODO conventions.
- **Timing:** 0.5 hour
- **Verification:** TODO.md shows updated entries 129/130 with Branch B guidance and research links; numbering and status markers remain valid.

### Phase 2: Outline `Truth.lean` temporal-duality refactor steps [NOT STARTED]
- **Goal:** Define the refactor approach for `derivable_implies_swap_valid` without global swap validity.
- **Tasks:**
  - [ ] Plan to rewrite the temporal_duality case to use the IH result directly for `is_valid ψ.swap`, eliminating the detour through `valid_swap_of_valid` / `truth_swap_of_valid_at_triple`.
  - [ ] If necessary, design a mutual/paired induction lemma that returns both `is_valid φ` and `is_valid φ.swap` to close double-swap steps by involution.
  - [ ] Identify where local transport lemmas are needed (past/future cases) and note reuse of `TimeShift.time_shift_preserves_truth`, `truth_history_eq`, `truth_double_shift_cancel`.
- **Timing:** 0.5 hour
- **Verification:** Refactor steps are captured and align with Branch B (no new axioms); targeted helper lemmas stay domain-witnessed.

### Phase 3: Plan `Soundness.lean` alignment and test impact [NOT STARTED]
- **Goal:** Ensure downstream soundness proofs consume the refactored lemma without semantic changes.
- **Tasks:**
  - [ ] Identify the temporal_duality branch in `Soundness.lean` that consumes `derivable_implies_swap_valid`; confirm it can call the refactored lemma without global swap assumptions.
  - [ ] Note any proof adjustments needed (e.g., changed return type if mutual IH is introduced).
  - [ ] List regression tests to run after implementation: `lake test LogosTest/Core/Semantics/TruthTest`, `lake test LogosTest/Core/Metalogic/SoundnessTest` (and any suite covering temporal duality).
- **Timing:** 0.5 hour
- **Verification:** Soundness consumption path is documented; planned tests cover temporal_duality after refactor.

### Phase 4: State/TODO synchronization and readiness checks [NOT STARTED]
- **Goal:** Prevent drift between TODO and project state once guidance is added.
- **Tasks:**
  - [ ] After updating TODO entries, outline updates to any project state file if required by local workflow (do not create new reports/summaries here).
  - [ ] Ensure Lean intent is flagged in the tasks; confirm artifacts and research links are present.
  - [ ] Add a readiness checklist for the eventual implementer (e.g., ensure no global swap axiom is introduced; keep transport lemmas local with domain witnesses).
- **Timing:** 0.5 hour
- **Verification:** State/TODO instructions are clear; readiness checklist captured; no new artifacts beyond this plan are created.

## Testing & Validation
- [ ] Re-run `lake test LogosTest/Core/Semantics/TruthTest` after the refactor.
- [ ] Re-run `lake test LogosTest/Core/Metalogic/SoundnessTest` after the refactor.
- [ ] If new transport lemmas are added, include targeted unit tests under `LogosTest/Core/Semantics/TaskFrameTest` or equivalent.
- [ ] Confirm no global swap-validity lemma or bi-infinite domain axiom was added.

## Artifacts & Outputs
- `.opencode/specs/154_research_temporal_swap_strategy_for_truth_lean_supports_tasks_129_130/plans/implementation-001.md` (this plan)
- TODO entries 129 and 130 updated with Branch B guidance and research links (no new reports/summaries created at this stage)

## Rollback/Contingency
- If guidance proves incorrect or implementation chooses Branch A, revert TODO updates for tasks 129/130 to prior text and reassess with a new research/plan cycle before altering semantics. Keep transport lemmas optional and local so removal is straightforward if they are not needed.
