# Implementation Plan: Task #981 - TimelineQuot Truth Lemma Completion

- **Task**: 981 - remove_axiom_technical_debt_from_task_979
- **Status**: [PARTIAL]
- **Effort**: 4-6 hours
- **Dependencies**: None (all prerequisites already implemented and sorry-free)
- **Research Inputs**: specs/981_remove_axiom_technical_debt_from_task_979/reports/research-010.md
- **Artifacts**: plans/07_timelinequot-truth-lemma.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan pivots from the failed W=D discrete covering approach (plans v1-v6) to completing the FMCS TimelineQuot truth lemma. Research-010 identified that the correct W/D-separated architecture already exists (sorry-free in `Algebraic/ParametricCanonical.lean`), and the remaining gap is purely mechanization: proving the truth lemma for FMCS over `TimelineQuot` to wire the dense completeness theorem.

**Strategy**: The `timelineQuot_not_valid_of_neg_consistent` theorem in `TimelineQuotCompleteness.lean` has a single `sorry`. This plan completes it by building the countermodel components over TimelineQuot, following the existing Int-based truth lemma pattern.

### Research Integration

From research-010:
- W = `ParametricCanonicalWorldState` (ALL MCSs) is correct and sorry-free
- D = `TimelineQuot` (via Cantor isomorphism) is correct and sorry-free
- `timelineQuotFMCS` already exists in `TimelineQuotCanonical.lean`
- The gap is completing the countermodel construction in `TimelineQuotCompleteness.lean`

## Goals & Non-Goals

**Goals**:
- Complete `timelineQuot_not_valid_of_neg_consistent` in `TimelineQuotCompleteness.lean`
- Remove or deprecate `discrete_Icc_finite_axiom` (original task objective)
- Add ROAD_MAP.md Dead End entry for W=D approach
- Deprecate W=D constructions in `DurationTransfer.lean`, `CanonicalDomain.lean`, `DiscreteTimeline.lean`

**Non-Goals**:
- Proving discrete completeness (dense completeness is sufficient)
- Redesigning the `ParametricCanonical` architecture (already correct)
- Building new FMCS infrastructure (already exists)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Truth lemma requires new structure | Medium | Low | Research-010 confirms template exists in Int-based code |
| Type unification issues | Medium | Medium | Follow exact patterns from `CanonicalConstruction.lean` |
| Omega construction complexity | High | Low | Use `timelineQuotFMCS` coherence properties directly |

## Implementation Phases

### Phase 1: Documentation and Deprecation [COMPLETED]

**Goal**: Mark W=D approach as abandoned, update ROAD_MAP.md, deprecate incorrect constructions.

**Tasks**:
- [x] Add Dead End entry to `specs/ROAD_MAP.md` for W=D canonical construction
- [x] Add `@[deprecated]` attribute to `canonicalTaskFrame` in `DurationTransfer.lean` with warning comment
- [x] Add `@[deprecated]` attribute to `denseCanonicalTaskFrame` in `CanonicalDomain.lean`
- [x] Add `@[deprecated]` attribute to `discreteCanonicalTaskFrame` in `DiscreteTimeline.lean`
- [x] Update docstrings to point to `ParametricCanonicalTaskFrame` as replacement

**Note**: `CanonicalDomain.lean` has pre-existing build errors (LinearOrder instance not synthesized) unrelated to deprecation changes. `DurationTransfer.lean` and `DiscreteTimeline.lean` build successfully with deprecation warnings as expected.

**Timing**: 30-45 minutes

**Files to modify**:
- `specs/ROAD_MAP.md` - Add Dead End entry
- `Theories/Bimodal/Metalogic/Domain/DurationTransfer.lean` - Deprecate `canonicalTaskFrame`
- `Theories/Bimodal/Metalogic/Domain/CanonicalDomain.lean` - Deprecate `denseCanonicalTaskFrame`
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` - Deprecate `discreteCanonicalTaskFrame`

**Verification**:
- `lake build` passes
- grep for deprecated constructs shows warnings in docstrings

---

### Phase 2: TaskFrame over TimelineQuot [COMPLETED]

**Goal**: Instantiate `ParametricCanonicalTaskFrame` at `D = TimelineQuot` and verify it satisfies completeness requirements.

**Tasks**:
- [x] Create `timelineQuotParametricTaskFrame` definition in `TimelineQuotCanonical.lean`
- [x] Prove `timelineQuotParametricTaskFrame` has the correct `WorldState` type (MCSs)
- [x] Verify `task_rel` is `parametric_canonical_task_rel` (uses `CanonicalR`)
- [x] Confirm all 3 TaskFrame axioms are satisfied (inherited from ParametricCanonicalTaskFrame)

**Timing**: 45-60 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCanonical.lean` - Add TaskFrame instantiation

**Verification**:
- `lake build Bimodal.Metalogic.StagedConstruction.TimelineQuotCanonical`
- No new sorries introduced

---

### Phase 3: WorldHistory and Omega Construction [COMPLETED]

**Goal**: Build the countermodel components (WorldHistory, shift-closed Omega set) over TimelineQuot.

**Tasks**:
- [x] Define `timelineQuotWorldHistory` type using `SeparatedHistory` pattern
- [x] Define `timelineQuotOmega` as the set of histories containing the root MCS
- [x] Prove `timelineQuotOmega_shift_closed` (shift-closure property)
- [x] Prove `timelineQuotOmega_nonempty` (contains witness history)

**Note**: Phase 3 infrastructure already exists in `SeparatedHistory.lean`:
- `separatedHistory` = WorldHistory over TimelineQuot
- `ShiftClosedSeparatedOmega` = shift-closed Omega set
- `shiftClosedSeparatedOmega_is_shift_closed` = shift-closure proof
- `separatedHistory_in_shiftClosed` = nonemptiness proof

**Timing**: 1-1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCanonical.lean` - Add WorldHistory, Omega

**Verification**:
- `lake build` passes
- No new sorries in WorldHistory or Omega constructions

---

### Phase 4: Truth Lemma Bridge [PARTIAL]

**Goal**: Connect `timelineQuotFMCS` truth (MCS membership) to semantic truth in the TaskModel.

**Tasks**:
- [x] Define `timelineQuotValuation` - already exists as `ParametricCanonicalTaskModel` with valuation = MCS membership
- [x] Define `timelineQuotTaskModel` - use `ParametricCanonicalTaskModel (TimelineQuot ...)`
- [ ] Prove `timelineQuotMCS_at_zero_eq_root` - root MCS is at time 0 (stub with sorry)
- [ ] Prove forward truth lemma linking MCS membership to `truth_at` (blocked)

**Blocking Issue**: The forward truth lemma requires adapting the `parametric_shifted_truth_lemma` from `ParametricTruthLemma.lean` to the separated construction. The key challenge is that the existing truth lemma uses BFMCS infrastructure with `modal_forward` and `modal_backward`, but the singleton BFMCS has a sorry in `modal_backward`. A forward-only version is needed.

**Timing**: 1.5-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean` - Add truth lemma

**Verification**:
- `lake build` passes
- `timelineQuotTruthLemma` is sorry-free

---

### Phase 5: Complete Countermodel Theorem [NOT STARTED]

**Goal**: Fill the `sorry` in `timelineQuot_not_valid_of_neg_consistent`.

**Tasks**:
- [ ] Construct the countermodel using components from Phase 2-4
- [ ] Extract witness history τ from `timelineQuotOmega`
- [ ] Use truth lemma to show φ evaluates to false at τ, 0
- [ ] Remove the `sorry` statement

**Timing**: 30-45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean` - Complete theorem

**Verification**:
- `lake build Bimodal.Metalogic.StagedConstruction.TimelineQuotCompleteness`
- `grep -c "sorry" TimelineQuotCompleteness.lean` returns 0

---

### Phase 6: Axiom Removal and Verification [NOT STARTED]

**Goal**: Remove or document as unused the `discrete_Icc_finite_axiom`.

**Tasks**:
- [ ] Verify `discrete_Icc_finite_axiom` is no longer reachable from main completeness path
- [ ] Add comment marking axiom as legacy (for discrete completeness only)
- [ ] Update `Completeness.lean` docstring to reflect dense completeness is now complete
- [ ] Run full `lake build` to verify clean compilation
- [ ] Update state.json/TODO.md for task completion

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` - Document axiom status
- `Theories/Bimodal/FrameConditions/Completeness.lean` - Update docstring
- `specs/state.json` - Task completion
- `specs/TODO.md` - Task completion

**Verification**:
- `lake build` clean
- Dense completeness path has no dependencies on `discrete_Icc_finite_axiom`
- `#print axioms dense_completeness_theorem` shows no custom axioms

## Testing & Validation

- [ ] `lake build` passes with no new sorries
- [ ] `#print axioms dense_completeness_theorem` shows only standard axioms (propext, quot.sound, Classical.choice)
- [ ] grep confirms no `sorry` in `TimelineQuotCompleteness.lean`
- [ ] grep confirms `discrete_Icc_finite_axiom` is documented as legacy
- [ ] ROAD_MAP.md contains Dead End entry for W=D approach

## Artifacts & Outputs

- `specs/981_remove_axiom_technical_debt_from_task_979/plans/07_timelinequot-truth-lemma.md` (this file)
- Modified: `TimelineQuotCanonical.lean` - TaskFrame, WorldHistory, Omega, truth lemma
- Modified: `TimelineQuotCompleteness.lean` - Completed countermodel theorem
- Modified: `ROAD_MAP.md` - Dead End entry
- Modified: `DurationTransfer.lean`, `CanonicalDomain.lean`, `DiscreteTimeline.lean` - Deprecation markers
- `specs/981_remove_axiom_technical_debt_from_task_979/summaries/08_implementation-summary.md` - Execution summary

## Rollback/Contingency

If the truth lemma approach proves intractable:
1. Revert changes to `TimelineQuotCompleteness.lean`
2. Document the gap in ROAD_MAP.md as "Wiring Gap: TimelineQuot Truth Lemma"
3. Consider Option B from research-010: domain-isomorphism transfer theorem
4. The `discrete_Icc_finite_axiom` remains as documented technical debt

**Note**: This is unlikely given research-010 confirms the mathematical content is correct and the pattern exists in Int-based code. The gap is purely mechanization.
