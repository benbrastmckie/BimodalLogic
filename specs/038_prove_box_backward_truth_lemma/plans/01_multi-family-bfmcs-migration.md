# Implementation Plan: Task #38

- **Task**: 38 - prove_box_backward_truth_lemma
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (existing infrastructure sufficient)
- **Research Inputs**: specs/038_prove_box_backward_truth_lemma/reports/01_team-research.md
- **Artifacts**: plans/01_multi-family-bfmcs-migration.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Migrate the SuccChain construction to use the multi-family BFMCS pattern with modal saturation, eliminating the sorry at `SuccChainTruth.lean:254`. The current singleton-Omega model cannot prove Box backward (`psi in MCS -> Box psi in MCS`) because this is the converse of the T-axiom, which is mathematically false for arbitrary formulas. The multi-family BFMCS pattern in `ModalSaturation.lean` provides a sorry-free `saturated_modal_backward` via contraposition using modal saturation.

### Research Integration

The research report confirms:
1. The sorry is mathematically unprovable for singleton-Omega (converse of T-axiom)
2. `ModalSaturation.lean` provides `saturated_modal_backward` (sorry-free)
3. `ParametricTruthLemma.lean` demonstrates the working Box backward proof using `B.modal_backward`
4. Migration requires replacing `succ_chain_omega` (singleton) with a proper `BFMCS Int` structure
5. `DirectMultiFamilyBFMCS.lean` has 4+ sorries in modal_forward/backward at t!=0

## Goals & Non-Goals

**Goals**:
- Eliminate the sorry at `SuccChainTruth.lean:254` (Box backward direction)
- Migrate SuccChain to use multi-family BFMCS with modal saturation
- Preserve completeness path through `succ_chain_truth_forward`
- Maintain or improve the overall sorry count

**Non-Goals**:
- Eliminating sorries in `DirectMultiFamilyBFMCS.lean` (separate architectural issue)
- Changing the underlying Succ-chain construction logic
- Modifying the temporal coherence proofs (G/H cases)
- Achieving full D-parametric generalization (Int-specific is acceptable)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Modal saturation at t!=0 fails | H | M | Use discreteClosedMCS saturation at t=0, propagate via TF axiom |
| New architecture introduces more sorries than it removes | H | M | Audit existing sorry patterns in DirectMultiFamilyBFMCS before starting |
| BFMCS integration breaks existing completeness proof | H | L | Keep original SuccChainTruth as fallback, test incrementally |
| Temporal coherence (F/P) sorries persist | M | H | Document these are separate from Box backward issue |

## Implementation Phases

### Phase 1: Audit Existing Infrastructure [COMPLETED]

**Goal**: Map the existing sorry landscape and identify reusable components

**Tasks**:
- [ ] Audit sorries in `DirectMultiFamilyBFMCS.lean` - document exact locations and causes
- [ ] Verify `saturated_modal_backward` in `ModalSaturation.lean` is truly sorry-free
- [ ] Review `SaturatedBFMCSConstruction.lean` for patterns we can reuse
- [ ] Document which sorries relate to t=0 vs t!=0 cases
- [ ] Create a sorry inventory spreadsheet for the migration

**Timing**: 1.5 hours

**Files to analyze**:
- `Theories/Bimodal/Metalogic/Bundle/DirectMultiFamilyBFMCS.lean` - current BFMCS attempt
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` - saturation infrastructure
- `Theories/Bimodal/Metalogic/Bundle/SaturatedBFMCSConstruction.lean` - construction patterns
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` - working Box backward

**Verification**:
- Sorry inventory document produced
- Clear understanding of which patterns are sorry-free

---

### Phase 2: Define SuccChain-based SaturatedBFMCS [BLOCKED]

**Goal**: Create a BFMCS Int structure based on succ_chain families with saturation proof

**Tasks**:
- [ ] Define `SuccChainBFMCS : BFMCS Int` structure using `discreteClosedMCS` families
- [ ] Each family is a succ_chain_fam rooted at a closed MCS
- [ ] Prove `SuccChainBFMCS` nonempty (M0 is in closed set)
- [ ] Prove `is_modally_saturated SuccChainBFMCS` at t=0 using `closedFlags_union_modally_saturated`
- [ ] Define `SuccChainSaturatedBFMCS : SaturatedBFMCS Int` wrapping the above

**Timing**: 2 hours

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainBFMCS.lean` - new file

**Verification**:
- `SuccChainSaturatedBFMCS` compiles without sorries in saturation proof
- `lake build Bimodal.Metalogic.Bundle.SuccChainBFMCS` succeeds

---

### Phase 3: Implement modal_forward and modal_backward [BLOCKED]

**Goal**: Prove modal coherence conditions for SuccChainBFMCS

**Tasks**:
- [ ] Implement `modal_forward` using T-axiom (trivial for BFMCS)
- [ ] Implement `modal_backward` via `saturated_modal_backward`
- [ ] Handle the t=0 case where saturation is complete
- [ ] For t!=0 case: use `parametric_box_persistent` to transfer Box phi from t to 0
- [ ] Integrate with existing `discreteMCS_modal_backward` from `ModallyCoherentBFMCS.lean`

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainBFMCS.lean` - add proofs

**Key insight**: Box phi persists to all times via TF axiom (`parametric_box_persistent`), so modal_backward at t reduces to modal_backward at t=0 where saturation holds.

**Verification**:
- `modal_forward` and `modal_backward` fields compile without sorries
- `BFMCS Int` structure complete

---

### Phase 4: Update SuccChainTruth to use BFMCS [BLOCKED]

**Goal**: Replace singleton-Omega with BFMCS-based Omega, eliminating the Box backward sorry

**Tasks**:
- [ ] Import `SuccChainBFMCS` into `SuccChainTruth.lean`
- [ ] Define `succ_chain_bfmcs_omega` as `ParametricCanonicalOmega SuccChainBFMCS`
- [ ] Update `succ_chain_truth_lemma` to use the new Omega
- [ ] Replace the Box backward sorry with `B.modal_backward` call (following ParametricTruthLemma pattern)
- [ ] Verify Box forward still works with new structure
- [ ] Keep `succ_chain_truth_forward` unchanged in signature

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainTruth.lean` - main changes

**Verification**:
- Line 254 sorry eliminated
- `succ_chain_truth_lemma` compiles
- `succ_chain_truth_forward` still works for completeness

---

### Phase 5: Verify Completeness Path [BLOCKED]

**Goal**: Ensure the completeness proof still works with updated truth lemma

**Tasks**:
- [ ] Run `lake build Bimodal.Metalogic.Completeness.SuccChainCompleteness`
- [ ] Verify `succ_chain_truth_forward` integration is unaffected
- [ ] Run full `lake build` to check for regressions
- [ ] Document any new sorries introduced and their justification
- [ ] Update module docstrings to reflect new architecture

**Timing**: 1 hour

**Files to verify**:
- `Theories/Bimodal/Metalogic/Completeness/SuccChainCompleteness.lean`
- All dependent modules

**Verification**:
- Full build succeeds
- Completeness theorem still provable
- Sorry count documented

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Bundle.SuccChainBFMCS` succeeds
- [ ] `lake build Bimodal.Metalogic.Bundle.SuccChainTruth` succeeds with no sorry at line 254
- [ ] `lake build Bimodal.Metalogic.Completeness.SuccChainCompleteness` succeeds
- [ ] Full `lake build` succeeds with no new errors
- [ ] Grep for `sorry` in modified files shows net reduction

## Artifacts & Outputs

- `specs/038_prove_box_backward_truth_lemma/plans/01_multi-family-bfmcs-migration.md` (this file)
- `Theories/Bimodal/Metalogic/Bundle/SuccChainBFMCS.lean` (new file)
- `Theories/Bimodal/Metalogic/Bundle/SuccChainTruth.lean` (modified)
- `specs/038_prove_box_backward_truth_lemma/summaries/01_implementation-summary.md` (on completion)

## Rollback/Contingency

If the migration introduces more problems than it solves:
1. Revert `SuccChainTruth.lean` to its original state with the sorry
2. Archive `SuccChainBFMCS.lean` to `Boneyard/Metalogic_v7/Bundle/`
3. Document the failed approach in the research report
4. The original completeness path via `succ_chain_truth_forward` remains intact

The sorry at line 254 is non-blocking for completeness (only forward direction is used), so rollback preserves all functionality while documenting the limitation.
