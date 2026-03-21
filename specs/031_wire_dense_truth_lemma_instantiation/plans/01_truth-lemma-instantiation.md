# Implementation Plan: Wire Dense Truth Lemma Instantiation

- **Task**: 31 - wire_dense_truth_lemma_instantiation
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: Task 30 (COMPLETED - provides dovetailedTimelineQuotBFMCS with temporal coherence)
- **Research Inputs**: specs/018_dense_representation_theorem_completion/reports/14_spawn-analysis.md
- **Artifacts**: plans/01_truth-lemma-instantiation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This task instantiates the parametric truth lemma infrastructure at D = DovetailedTimelineQuot to close the sorry in `timelineQuot_not_valid_of_neg_consistent` at TimelineQuotCompleteness.lean:127. The implementation follows the pattern established in DiscreteInstantiation.lean for the discrete case (D = Int).

The key insight is that Task 30 has already built `dovetailedTimelineQuotBFMCS` with proven `temporally_coherent`, which satisfies the requirements of `parametric_shifted_truth_lemma`. The remaining work is:
1. Construct the canonical model structures (TaskFrame, TaskModel) for DovetailedTimelineQuot
2. Construct the BFMCS wrapper that provides MCS containment
3. Connect root MCS membership to semantic falsity via the truth lemma
4. Close the sorry by constructing the countermodel

### Research Integration

From the spawn analysis (14_spawn-analysis.md):
- The existing `dovetailedTimelineQuotBFMCS` provides temporal coherence (no sorries)
- Modal backward has 1 sorry (known limitation, same as DirectMultiFamilyBFMCS)
- The truth lemma requires `temporally_coherent` which is fully proven

## Goals & Non-Goals

**Goals**:
- Instantiate `ParametricCanonicalTaskFrame` and `ParametricCanonicalTaskModel` at D = DovetailedTimelineQuot
- Construct a BFMCS wrapper that connects the root MCS to the canonical model
- Prove `timelineQuot_not_valid_of_neg_consistent` using the parametric truth lemma
- Unblock `dense_completeness_theorem` by closing the sorry at line 127

**Non-Goals**:
- Fixing the modal_backward sorry in dovetailedTimelineQuotBFMCS (known limitation)
- Building new temporal coherence proofs (already done in Task 30)
- Modifying the parametric truth lemma infrastructure

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Typeclass instance conflicts between DovetailedTimelineQuot and parametric structures | H | M | Study DiscreteInstantiation.lean pattern carefully; use explicit instance provision |
| The root MCS connection requires additional wiring | M | M | Task 30 provides `dovetailedTimelineQuotBFMCS_root_at_time`; verify it connects correctly |
| Modal coherence sorry propagates to truth lemma | H | L | The truth lemma only requires temporal_coherent which has no sorries |

## Implementation Phases

### Phase 1: Typeclass Instantiation [COMPLETED]

**Goal**: Verify and document that DovetailedTimelineQuot satisfies all required typeclasses for the D-parametric construction.

**Tasks**:
- [ ] Create `DenseInstantiation.lean` in `Theories/Bimodal/Metalogic/Algebraic/`
- [ ] Import necessary modules (ParametricRepresentation, DovetailedTimelineQuotBFMCS, etc.)
- [ ] Add example statements verifying `AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid` for DovetailedTimelineQuot
- [ ] Define `DenseCanonicalTaskFrame` as abbreviation for `ParametricCanonicalTaskFrame (DovetailedTimelineQuot root_mcs h)`
- [ ] Define `DenseCanonicalTaskModel` as abbreviation for `ParametricCanonicalTaskModel (DovetailedTimelineQuot root_mcs h)`
- [ ] Verify `lake build` succeeds

**Timing**: 45 minutes

**Files to create**:
- `Theories/Bimodal/Metalogic/Algebraic/DenseInstantiation.lean`

**Verification**:
- All typeclass examples pass without errors
- `lake build Bimodal.Metalogic.Algebraic.DenseInstantiation` succeeds

---

### Phase 2: BFMCS Wrapper Construction [COMPLETED]

**Goal**: Create a wrapper function `construct_bfmcs_from_mcs_Dense` that takes an MCS and returns a BFMCS containing it at time 0.

**Tasks**:
- [ ] Study `construct_bfmcs_from_mcs_Int_v3` in ClosedFlagIntBFMCS.lean for the pattern
- [ ] Define `construct_bfmcs_from_mcs_Dense` that wraps `dovetailedTimelineQuotBFMCS`
- [ ] The wrapper should return `PSigma` containing: BFMCS, temporal_coherent proof, family, membership proof, time, equality proof
- [ ] Use `dovetailedTimelineQuotBFMCS_root_at_time` to connect root MCS to time 0
- [ ] Prove the returned family contains the original MCS at the returned time
- [ ] Verify `lake build` succeeds

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/DenseInstantiation.lean`

**Verification**:
- `construct_bfmcs_from_mcs_Dense` type-checks with correct signature
- The construction uses existing proofs (no new sorries introduced)

---

### Phase 3: Representation Theorems [COMPLETED]

**Goal**: Prove dense analogs of the representation theorems from DiscreteInstantiation.lean.

**Tasks**:
- [ ] Prove `dense_not_provable_implies_neg_extends_to_mcs` (specialization of generic theorem)
- [ ] Prove `dense_representation_from_neg_membership` using `parametric_representation_from_neg_membership`
- [ ] Prove `dense_countermodel_implies_not_provable` using `countermodel_implies_not_provable`
- [ ] Prove `dense_representation_conditional` using `parametric_algebraic_representation_conditional`
- [ ] Prove `dense_representation_unconditional` using `construct_bfmcs_from_mcs_Dense`
- [ ] Verify `lake build` succeeds with no new sorries in DenseInstantiation.lean

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/DenseInstantiation.lean`

**Verification**:
- All representation theorems compile
- `#check` confirms correct types
- `#print axioms dense_representation_unconditional` shows only expected sorries

---

### Phase 4: TimelineQuotCompleteness Wiring [COMPLETED]

**Goal**: Close the sorry in `timelineQuot_not_valid_of_neg_consistent` using the dense instantiation.

**Tasks**:
- [ ] Import `DenseInstantiation` in `TimelineQuotCompleteness.lean`
- [ ] In `timelineQuot_not_valid_of_neg_consistent`, construct the TaskFrame and TaskModel
- [ ] Use `lindenbaumMCS` to get the root MCS containing `phi.neg`
- [ ] Apply `construct_bfmcs_from_mcs_Dense` or equivalent to get the BFMCS
- [ ] Use `parametric_shifted_truth_lemma` to connect MCS membership to semantic truth
- [ ] Show `phi.neg` in root MCS implies `phi` is false at the canonical model
- [ ] Construct the `valid_over` negation by exhibiting the countermodel
- [ ] Remove the sorry and verify the proof compiles
- [ ] Run `lake build` to verify no regressions

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean`

**Verification**:
- `timelineQuot_not_valid_of_neg_consistent` compiles without sorry
- `dense_completeness_theorem` compiles without new sorry
- `lake build` succeeds

## Testing & Validation

- [ ] `lake build` succeeds with no new sorries in DenseInstantiation.lean
- [ ] `lake build` succeeds with no new sorries in TimelineQuotCompleteness.lean
- [ ] `#print axioms dense_completeness_theorem` shows only pre-existing sorries
- [ ] The sorry at line 127 of TimelineQuotCompleteness.lean is removed
- [ ] Module docstrings updated to reflect completed status

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Algebraic/DenseInstantiation.lean` - New file with dense instantiation
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean` - Modified to close sorry
- `specs/031_wire_dense_truth_lemma_instantiation/summaries/01_implementation-summary.md` - Execution summary

## Rollback/Contingency

If the implementation encounters blocking issues:
1. The existing sorry remains in place (no regression)
2. Document any newly discovered gaps in the implementation summary
3. If typeclass issues arise, fall back to explicit instance passing instead of inference
4. If the modal_backward sorry causes issues with the truth lemma, document the interaction and potentially use the CanonicalMCS-based BFMCS from Phases 4.1-4.4 of DovetailedTimelineQuotBFMCS.lean instead
