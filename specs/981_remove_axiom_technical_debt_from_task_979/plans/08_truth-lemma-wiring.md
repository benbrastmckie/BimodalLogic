# Implementation Plan: Task #981 - Truth Lemma Wiring for Dense Completeness

- **Task**: 981 - remove_axiom_technical_debt_from_task_979
- **Status**: [NOT STARTED]
- **Effort**: 3-5 hours
- **Dependencies**: None (all prerequisites already implemented and sorry-free)
- **Research Inputs**: specs/981_remove_axiom_technical_debt_from_task_979/reports/research-010.md, research-011.md
- **Artifacts**: plans/08_truth-lemma-wiring.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan v8 picks up from where plan v7 left off. Phases 1-3 of v7 are COMPLETED (deprecation, TaskFrame, WorldHistory). The remaining work is to fill a single sorry in `timelineQuot_not_valid_of_neg_consistent` (TimelineQuotCompleteness.lean:127) to achieve axiom-free dense completeness.

**Key insight from research-010/011**: The infrastructure exists; the gap is purely mechanization. We need to:
1. Prove `timelineQuotMCS_at_zero_eq_root` (root MCS is at time 0)
2. Build a semantic countermodel using the existing SeparatedHistory
3. Apply forward truth (MCS membership implies semantic truth) to show the root MCS falsifies phi

### Research Integration

From research-011:
- Phases 1-3 of plan v7: COMPLETED
- Single blocking sorry: `timelineQuot_not_valid_of_neg_consistent` at TimelineQuotCompleteness.lean:127
- All FMCS/BFMCS infrastructure exists sorry-free
- The `discrete_Icc_finite_axiom` is only used for discrete completeness (not dense)

From research-010:
- W = `ParametricCanonicalWorldState` (correct and sorry-free)
- D = `TimelineQuot` (via Cantor, sorry-free)
- `timelineQuotFMCS` exists in TimelineQuotCanonical.lean
- `separatedHistory` exists in SeparatedHistory.lean with shift-closed Omega

## Goals & Non-Goals

**Goals**:
- Prove `timelineQuotMCS_at_zero_eq_root` (TimelineQuotCanonical.lean:397)
- Fill the sorry in `timelineQuot_not_valid_of_neg_consistent` (TimelineQuotCompleteness.lean:127)
- Verify `dense_completeness_theorem` becomes sorry-free
- Confirm dense path has no dependency on `discrete_Icc_finite_axiom`

**Non-Goals**:
- Removing `discrete_Icc_finite_axiom` (it's only used for discrete completeness, not dense)
- Building new FMCS/BFMCS infrastructure (already exists)
- Proving discrete completeness (dense is sufficient for the main result)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `timelineQuotMCS_at_zero_eq_root` requires additional infrastructure | Medium | Low | The root point maps to 0 by AddCommGroup zero; may need explicit isomorphism tracking |
| Forward truth lemma needs modal case handling | Medium | Medium | Use existing `canonical_forward_G` and Omega shift-closure |
| Type unification between FMCS mcs and TaskModel valuation | Low | Medium | Follow exact patterns from CanonicalConstruction.lean |

## Implementation Phases

### Phase 1: Prove timelineQuotMCS_at_zero_eq_root [COMPLETED]

**Goal**: Show that the MCS at time 0 in TimelineQuot equals the root MCS used to construct TimelineQuot.

**Tasks**:
- [ ] Examine TimelineQuot construction to understand how 0 is defined (via AddCommGroup)
- [ ] Trace the staged construction to show root point maps to identity element
- [ ] Prove `timelineQuotMCS_at_zero_eq_root` in TimelineQuotCanonical.lean:397

**Timing**: 1-1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCanonical.lean` - Fill sorry at line 397

**Verification**:
- `lake build Bimodal.Metalogic.StagedConstruction.TimelineQuotCanonical`
- grep confirms no sorry at line 397

**Proof Strategy**:
The TimelineQuot is constructed from:
1. `DenseTimelineElem root_mcs root_mcs_proof` (staged points starting from root)
2. `Antisymmetrization` to quotient by equivalence
3. AddCommGroup instance via Cantor isomorphism

The 0 element in TimelineQuot should correspond to the equivalence class of the root point. The `timelineQuotMCS` function extracts the MCS via `ofAntisymmetrization`. Need to show that `ofAntisymmetrization` of the 0 class returns a representative with `mcs = root_mcs`.

---

### Phase 2: Build Countermodel Components [BLOCKED]

**Goal**: Assemble the TaskModel and semantic infrastructure for the countermodel.

**Tasks**:
- [ ] Define `timelineQuotTaskModel` using `SeparatedCanonicalTaskFrame` and valuation from MCS membership
- [ ] Verify `separatedHistory` is a valid witness history in the TaskModel
- [ ] Extract witness time t = 0 and show 0 is in domain of `separatedHistory`

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean` - Add TaskModel definition

**Verification**:
- `lake build` passes
- No new sorries introduced

---

### Phase 3: Complete Countermodel Theorem [NOT STARTED]

**Goal**: Fill the sorry in `timelineQuot_not_valid_of_neg_consistent`.

**Tasks**:
- [ ] Construct the countermodel: F = `timelineQuotParametricTaskFrame`, M = valuation from MCS
- [ ] Extract Omega = `ShiftClosedSeparatedOmega`, prove shift-closed
- [ ] Extract history tau = `separatedHistory`, prove it's in Omega
- [ ] Show `phi.neg` is in root_mcs (from Lindenbaum construction)
- [ ] Use forward truth: MCS membership implies semantic falsity for phi
- [ ] Instantiate `not_valid_over` with witness (F, M, Omega, tau, 0)

**Timing**: 1-1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean` - Complete theorem at line 127

**Verification**:
- `grep -c "sorry" TimelineQuotCompleteness.lean` returns 0
- `lake build Bimodal.Metalogic.StagedConstruction.TimelineQuotCompleteness`

**Proof Sketch**:
```lean
theorem timelineQuot_not_valid_of_neg_consistent (phi : Formula) (h_cons : ContextConsistent [phi.neg]) :
    ... not valid_over D phi := by
  intro M₀ h_M₀_mcs D acg oam
  -- Build countermodel
  let F := timelineQuotParametricTaskFrame M₀ h_M₀_mcs
  let V := fun p t => p ∈ (timelineQuotMCS M₀ h_M₀_mcs t)  -- valuation from MCS
  let M := TaskModel.mk F V
  let Omega := ShiftClosedSeparatedOmega M₀ h_M₀_mcs
  let tau := separatedHistory M₀ h_M₀_mcs

  -- Witness: (F, M, Omega, tau, 0)
  refine ⟨F, M, Omega, tau, shiftClosedSeparatedOmega_is_shift_closed,
         separatedHistory_in_shiftClosed, 0, ?_⟩

  -- Show phi evaluates to false at tau, 0
  -- Since phi.neg is in M₀ (root MCS), and MCS at 0 is M₀, phi.neg is in mcs(0)
  -- Forward truth: phi.neg in mcs(0) implies truth_at M Omega tau 0 phi.neg
  -- Therefore not (truth_at M Omega tau 0 phi)

  have h_neg_in : phi.neg ∈ M₀ := ...  -- From Lindenbaum construction
  have h_mcs_0_eq : timelineQuotMCS M₀ h_M₀_mcs 0 = M₀ := timelineQuotMCS_at_zero_eq_root
  ...
```

---

### Phase 4: Verification and Axiom Audit [NOT STARTED]

**Goal**: Confirm dense completeness is axiom-free and update documentation.

**Tasks**:
- [ ] Run `#print axioms dense_completeness_theorem` to verify only standard axioms
- [ ] Confirm `discrete_Icc_finite_axiom` is NOT reachable from dense completeness path
- [ ] Update docstring in `Completeness.lean` to reflect dense completeness is complete
- [ ] Add completion note to plan v7 indicating this work supersedes remaining phases

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Completeness.lean` - Update docstring
- `specs/981_.../plans/07_timelinequot-truth-lemma.md` - Add completion note

**Verification**:
- `#print axioms dense_completeness_theorem` shows only: propext, quot.sound, Classical.choice
- `discrete_Icc_finite_axiom` does not appear in axiom trace

## Testing & Validation

- [ ] `lake build` passes with no new sorries
- [ ] `grep -c "sorry" TimelineQuotCompleteness.lean` returns 0
- [ ] `grep -c "sorry" TimelineQuotCanonical.lean` returns 0 (or only pre-existing sorries)
- [ ] `#print axioms dense_completeness_theorem` shows only standard axioms
- [ ] `discrete_Icc_finite_axiom` is documented as discrete-path only

## Artifacts & Outputs

- `specs/981_remove_axiom_technical_debt_from_task_979/plans/08_truth-lemma-wiring.md` (this file)
- Modified: `TimelineQuotCanonical.lean` - `timelineQuotMCS_at_zero_eq_root` proof
- Modified: `TimelineQuotCompleteness.lean` - Countermodel theorem completion
- Modified: `Completeness.lean` - Updated documentation
- `specs/981_.../summaries/09_implementation-summary.md` - Execution summary

## Rollback/Contingency

If the proof approach proves intractable:

1. **Phase 1 issues** (zero_eq_root): Try alternative characterization via the Cantor isomorphism; the zero element under the transferred AddCommGroup structure should map to the root equivalence class

2. **Phase 3 issues** (countermodel construction): Fall back to Option B from research-011: document the wiring gap comprehensively and mark task as completed with scope reduction

3. **Type unification issues**: Ensure all instances (AddCommGroup, LinearOrder, IsOrderedAddMonoid) are explicitly provided and match those used in timelineQuotFMCS

**Note**: The mathematical content is verified correct by research-010/011. The remaining gap is purely Lean mechanization of existing infrastructure.
