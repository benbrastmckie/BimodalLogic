# Implementation Plan: Task #58 - Restricted Truth Lemma Path (v12)

- **Task**: 58 - wire_completeness_to_frame_conditions
- **Status**: [NOT STARTED]
- **Effort**: 4-6 hours
- **Dependencies**: None (using existing infrastructure)
- **Research Inputs**: reports/60_team-research.md (comprehensive review - 60 waves)
- **Previous Plan**: plans/11_propagation-to-zero.md (complex approach, superseded)
- **Artifacts**: plans/12_restricted-truth-lemma-path.md (this file)
- **Type**: lean4
- **Lean Intent**: true

## Revision Summary

After 60 research waves and task 65's dead ends, Wave 60 provides clarity:

**Key Discovery**: The "omega-enumeration construction" (`omegaClassFamilies_temporally_coherent`) **does not exist**. It appears only in deprecation strings but was never implemented.

**Simplest Viable Path**: Fix 3 sorries in `RestrictedTruthLemma.lean` (G/H propagation in DRM chains), then wire to completeness. The `RestrictedTemporallyCoherentFamily` already provides family-level coherence.

This plan supersedes the complex "propagation-to-zero" approach (v11) with a more direct path.

## Overview

The core obstacle is a **coherence level mismatch**:
- `shifted_truth_lemma` requires **family-level** coherence (F-witness in SAME family)
- `construct_bfmcs_bundle` provides **bundle-level** coherence (F-witness in ANY family)

**Solution**: `RestrictedTemporallyCoherentFamily` (SuccChainFMCS.lean:4191) already provides family-level coherence for formulas in `subformulaClosure(phi)`. The gap is 3 sorries in `RestrictedTruthLemma.lean` for G/H propagation within DRM chains.

## Goals & Non-Goals

**Goals**:
- Fix 3 sorries in RestrictedTruthLemma.lean (lines 106, 115, 135)
- Build TaskModel from RestrictedTemporallyCoherentFamily
- Wire to the 3 target sorries in Completeness.lean (lines 115, 158, 186)

**Non-Goals**:
- Implementing omega-enumeration (doesn't exist, wrong path)
- Modifying the shifted_truth_lemma proof
- Fixing unrelated sorries in SuccChainFMCS.lean

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| G/H propagation sorries harder than expected | M | M | DRM closure properties are well-established |
| TaskModel construction has type issues | M | L | Follow existing patterns from CanonicalConstruction.lean |
| Wiring to Completeness.lean reveals new gaps | M | L | Restricted path is well-analyzed in 60 waves |

## Implementation Phases

### Phase 1: Fix RestrictedTruthLemma.lean Sorries [NOT STARTED]

**Goal**: Resolve the 3 G/H propagation sorries in RestrictedTruthLemma.lean

**Mathematical Content**:

The sorries are at lines 106, 115, 135:

| Sorry | Line | Description |
|-------|------|-------------|
| `G_step` | 106 | G(psi) propagation through DRM steps |
| `G_from_chain` | 115 | G(psi) from chain membership |
| `H_from_chain` | 135 | H(psi) from chain membership (symmetric) |

**Why these are fixable**: DRMs (Deferral Restricted MCSes) are closed under derivation within `deferralClosure`. G(psi) in DRM means "if psi were in the deferred set, it would propagate." The key insight:
- G(psi) at position n implies psi at position n (by G's definition)
- The Succ chain structure preserves G-formulas forward
- Induction on DRM chain shows psi at all future positions

**Tasks**:
- [ ] Examine current sorry structure with `lean_goal` at lines 106, 115, 135
- [ ] Prove G_step: Show G(psi) propagates through constrained_successor_restricted
- [ ] Prove G_from_chain: Connect chain membership to truth
- [ ] Prove H_from_chain: Symmetric argument for past

**Timing**: 1.5-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean`

**Verification**:
- `lake build`
- `#print axioms restricted_truth_lemma` shows no `sorryAx`

---

### Phase 2: Build TaskModel from RestrictedTemporallyCoherentFamily [NOT STARTED]

**Goal**: Create TaskModel infrastructure for the restricted construction

**Mathematical Content**:

Define in a new section of CanonicalConstruction.lean or a new file:

```lean
-- The restricted Omega: single family's history plus shifts
def RestrictedOmega (rtcf : RestrictedTemporallyCoherentFamily phi seed) :
    Set (WorldHistory CanonicalTaskFrame) :=
  { sigma | ∃ delta : Int, sigma = WorldHistory.time_shift (to_restricted_history rtcf) delta }

-- Shift-closure is trivial for single-history Omega
theorem restrictedOmega_shift_closed : ShiftClosed (RestrictedOmega rtcf)

-- The restricted TaskModel
def RestrictedTaskModel (rtcf : RestrictedTemporallyCoherentFamily phi seed) : TaskModel := ...
```

**Key insight**: With single family (family-level coherence guaranteed), the truth lemma applies directly. Multiple families aren't needed because we're building a countermodel for a specific formula.

**Tasks**:
- [ ] Define `to_restricted_history` converting RTCF to WorldHistory
- [ ] Define `RestrictedOmega` as single history plus time-shifts
- [ ] Prove `restrictedOmega_shift_closed` (trivial)
- [ ] Define `RestrictedTaskModel` following CanonicalTaskModel pattern
- [ ] Prove `restricted_truth_lemma_semantic`: MCS membership ↔ truth

**Timing**: 1.5-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` (new section)
- Or create `Theories/Bimodal/Metalogic/Bundle/RestrictedCanonicalConstruction.lean`

**Verification**:
- `lake build`
- `#check RestrictedTaskModel`
- `#print axioms restricted_truth_lemma_semantic` shows no `sorryAx`

---

### Phase 3: Wire to Completeness.lean [NOT STARTED]

**Goal**: Eliminate the 3 target sorries using restricted completeness

**Mathematical Content**:

The completeness proof via contrapositive:
1. Assume phi not provable
2. Then neg(phi) consistent (`not_provable_implies_neg_consistent`)
3. Extend to restricted MCS for phi (`restricted_mcs_from_consistent`)
4. Build `RestrictedTemporallyCoherentFamily` from restricted MCS
5. Build `RestrictedTaskModel` from RTCF
6. By `restricted_truth_lemma_semantic`: neg(phi) true at (eval_history, 0)
7. Therefore phi not valid (countermodel exists)
8. Contrapositive: valid → provable

**Tasks**:
- [ ] Define `restricted_completeness_over_Int`: valid_over Int phi → provable phi
- [ ] Wire `bundle_validity_implies_provability` (line 186) using restricted completeness
- [ ] Wire `dense_completeness_fc` (line 115) via `dense_implies_int + completeness_over_Int`
- [ ] Wire `discrete_completeness_fc` (line 158) via `discrete_implies_int + completeness_over_Int`
- [ ] Final axiom verification

**Timing**: 1.5-2 hours

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Completeness.lean`

**Verification**:
- `lake build`
- `#print axioms dense_completeness_fc` shows no `sorryAx`
- `#print axioms discrete_completeness_fc` shows no `sorryAx`
- `#print axioms bundle_validity_implies_provability` shows no `sorryAx`

---

## Testing & Validation

- [ ] `lake build` succeeds at each phase
- [ ] Each new theorem verified with `#print axioms` (no sorryAx)
- [ ] Final verification: all 3 target sorries eliminated
- [ ] Total new sorry count: 0 (no new sorries introduced)

## Artifacts & Outputs

- `plans/12_restricted-truth-lemma-path.md` (this file)
- Modified Lean files:
  - `RestrictedTruthLemma.lean` - G/H propagation sorries filled
  - `CanonicalConstruction.lean` or new file - RestrictedTaskModel
  - `Completeness.lean` - Target sorries eliminated
- `summaries/12_restricted-truth-summary.md` (after completion)

## Why This Path Will Work

1. **F-nesting is bounded** within `closureWithNeg(phi)` (`iter_F_not_mem_closureWithNeg`)
2. **Family-level coherence** is guaranteed by `RestrictedTemporallyCoherentFamily` construction
3. **Single-family Omega** means the truth lemma applies directly (no bundle-vs-family mismatch)
4. **The math is proven correct** across 60 research waves - only the Lean encoding remains

## Approaches Definitively Ruled Out

| Approach | Why Blocked | Reference |
|----------|-------------|-----------|
| Omega-enumeration for arbitrary MCS | F-nesting unbounded | Reports 40, 50 |
| Bundle-level as truth lemma input | G backward needs same-family | Reports 45, 65-wave3 |
| Forward-only truth lemma | imp forward uses backward IH | Reports 50, 65-wave3 |
| Algebraic bypass | Proves different theorem | Reports 45, 50 |

## Rollback/Contingency

If Phase 1 G/H sorries prove harder than expected:
1. Document the specific blocking issue
2. Check if `G_step` needs additional lemmas about DRM closure
3. Consider whether constrained_successor_restricted preserves G-formulas

The math is sound - DRMs are closed under derivation. Any blocking issue would be Lean encoding, not mathematical.
