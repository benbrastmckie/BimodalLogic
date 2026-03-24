# Implementation Plan: Task #55

- **Task**: 55 - Prove SuccChain Temporal Coherence Directly
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: None (supersedes tasks 36, 37, 53)
- **Research Inputs**: specs/055_prove_succchain_temporal_coherence_directly/reports/01_temporal-coherence-direct.md
- **Artifacts**: plans/01_temporal-coherence-implementation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Replace the sorry chain (f_nesting_is_bounded -> f_nesting_boundary -> succ_chain_forward_F -> SuccChainTemporalCoherent) with a direct proof using Succ obligation resolution via the restricted chain approach. The research identified that `f_nesting_is_bounded` is mathematically FALSE for arbitrary MCS, but provable for the restricted chain where deferralClosure is finite. The fix requires: (1) proving a formula membership lemma that GG(neg psi) is in deferralClosure when FF(psi) is, (2) adapting neg_FF_implies_GG_neg for DeferralRestrictedMCS, (3) fixing the 4-6 boundary case sorries in SuccChainFMCS.lean, and (4) wiring the restricted chain into the completeness proof.

### Research Integration

- Research report: 01_temporal-coherence-direct.md
- Key finding: f_nesting_is_bounded FALSE for arbitrary MCS but restricted chain approach is sound
- Boundary case sorries at lines 3072, 3104, 3118, 3189 in SuccChainFMCS.lean need fixing
- Formula membership lemma (FF in closure implies GG(neg) in closure) is the foundation

## Goals & Non-Goals

**Goals**:
- Prove SuccChainTemporalCoherent without using f_nesting_is_bounded
- Fix boundary case sorries in restricted chain (lines 3072, 3104, 3118, 3189)
- Establish formula membership lemma for deferralClosure
- Wire restricted chain results to completeness theorem
- Remove deprecated sorries (f_nesting_is_bounded, p_nesting_is_bounded)

**Non-Goals**:
- Proving f_nesting_is_bounded for arbitrary MCS (mathematically impossible)
- Restructuring the entire completeness proof
- Modifying the Succ relation definition

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Formula membership lemma fails (GG(neg psi) NOT in deferralClosure when FF(psi) is) | High | Low | Research suggests structure of closureWithNeg should guarantee this; if fails, enlarge deferralClosure definition |
| DRM closure under derivation insufficient | Medium | Low | Can strengthen DRM closure properties if needed |
| Completeness wiring breaks other proofs | Medium | Low | Test incrementally, preserve old theorems until verified |
| Symmetric P-direction has different issues | Medium | Low | Apply same pattern; structure is symmetric |

## Implementation Phases

### Phase 1: Formula Membership Lemma [NOT STARTED]

**Goal**: Prove that FF(psi) in closureWithNeg(phi) implies GG(neg(psi)) in closureWithNeg(phi)

**Tasks**:
- [ ] Analyze closureWithNeg structure in SubformulaClosure.lean
- [ ] Trace the formula encoding: F(A) = neg(G(neg(A))) to understand subformula relationships
- [ ] Prove lemma `ff_in_closure_implies_gg_neg_in_closure`: If some_future(some_future(psi)) in closureWithNeg(phi), then all_future(all_future(psi.neg)) in closureWithNeg(phi)
- [ ] Verify the intermediate formulas G(neg(F(psi))) are also in closure

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Syntax/SubformulaClosure.lean` - Add membership lemma

**Verification**:
- `lake build` succeeds
- Lemma `ff_in_closure_implies_gg_neg_in_closure` compiles without sorry

---

### Phase 2: DRM neg_FF_implies_GG_neg [NOT STARTED]

**Goal**: Adapt the full MCS theorem neg_FF_implies_GG_neg_in_mcs for DeferralRestrictedMCS

**Tasks**:
- [ ] Review neg_FF_implies_GG_neg_in_mcs in CanonicalTaskRelation.lean (or similar)
- [ ] Identify DRM closure properties needed (closed under derivation within deferralClosure)
- [ ] Prove `neg_FF_implies_GG_neg_in_drm`: For DeferralRestrictedMCS, neg(FF(psi)) in DRM implies GG(neg(psi)) in DRM
- [ ] Use Phase 1 lemma to ensure GG(neg(psi)) is in deferralClosure
- [ ] Verify DRM closure under derivation is sufficient for the proof steps

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` - Add DRM version of neg_FF_implies_GG_neg

**Verification**:
- `lake build` succeeds
- Theorem `neg_FF_implies_GG_neg_in_drm` compiles without sorry

---

### Phase 3: Fix Boundary Case Sorries [NOT STARTED]

**Goal**: Resolve the 4 boundary case sorries in restricted chain (lines 3072, 3104, 3118, 3189)

**Tasks**:
- [ ] Fix `restricted_single_step_forcing` boundary sorry (line 3072)
  - Apply GG argument using Phase 2's neg_FF_implies_GG_neg_in_drm
- [ ] Fix `restricted_succ_propagates_F_not` sorry (line 3104) - case FF(psi) in deferralClosure
  - Use negation completeness: neg(FF(psi)) in DRM
  - Apply neg_FF_implies_GG_neg_in_drm to get GG(neg(psi)) in DRM
- [ ] Fix `restricted_succ_propagates_F_not` sorry (line 3118) - second case
  - Similar pattern using GG argument
- [ ] Fix `restricted_succ_propagates_F_not'` sorry (line 3189)
  - Handle the case split: GF(psi) in vs out of deferralClosure
  - When GF(psi) not in deferralClosure, use strengthened theorem directly
  - When GF(psi) in deferralClosure, apply negation completeness

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Fix boundary sorries

**Verification**:
- `lake build` succeeds
- No sorries remain at lines 3072, 3104, 3118, 3189

---

### Phase 4: Wire Restricted Chain to Completeness [NOT STARTED]

**Goal**: Connect restricted chain forward_F to SuccChainTemporalCoherent and completeness

**Tasks**:
- [ ] Replace `succ_chain_forward_F` implementation to use restricted chain
  - Option A: Build restricted chain from M0, prove forward_F, transfer to unrestricted
  - Option B: Restructure to use restricted chain throughout
- [ ] Update `succ_chain_forward_F_neg` to use same restricted approach
- [ ] Verify `SuccChainTemporalCoherent` builds on the fixed forward_F
- [ ] Apply symmetric pattern for P-direction (backward_P, p_nesting_boundary)
- [ ] Test that `succ_chain_truth_lemma` still compiles

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Wire restricted chain
- `Theories/Bimodal/Metalogic/Bundle/SuccChainTruth.lean` - Verify compatibility
- `Theories/Bimodal/Metalogic/Completeness/SuccChainCompleteness.lean` - Verify completeness

**Verification**:
- `lake build` succeeds
- `SuccChainTemporalCoherent` instance compiles without sorry
- `succ_chain_completeness` compiles without sorry

---

### Phase 5: Cleanup Deprecated Sorries [NOT STARTED]

**Goal**: Remove deprecated theorems and clean up the codebase

**Tasks**:
- [ ] Mark or delete `f_nesting_is_bounded` (line 731) - confirmed FALSE for arbitrary MCS
- [ ] Mark or delete `p_nesting_is_bounded` (line 966) - symmetric FALSE
- [ ] Remove or deprecate `f_nesting_boundary` (line 755) if no longer used
- [ ] Remove or deprecate `p_nesting_boundary` (line 978) if no longer used
- [ ] Update any callers that referenced the deprecated theorems
- [ ] Run full test suite to verify no regressions
- [ ] Add documentation comments explaining the restricted chain approach

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Cleanup

**Verification**:
- `lake build` succeeds
- No references to deprecated theorems
- Full test suite passes

## Testing & Validation

- [ ] `lake build` succeeds with no sorries in SuccChainFMCS.lean (boundary cases)
- [ ] `lake build` succeeds with no sorries in SuccChainTruth.lean
- [ ] `lake build` succeeds with no sorries in SuccChainCompleteness.lean
- [ ] The sorry count in relevant files decreases by 4-6 (the boundary sorries)
- [ ] The f_nesting_is_bounded and p_nesting_is_bounded are removed or marked deprecated
- [ ] Existing tests continue to pass

## Artifacts & Outputs

- `Theories/Bimodal/Syntax/SubformulaClosure.lean` - ff_in_closure_implies_gg_neg_in_closure lemma
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` - neg_FF_implies_GG_neg_in_drm theorem
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Fixed boundary sorries, deprecated cleanup

## Rollback/Contingency

- If Phase 1 formula membership lemma fails, investigate enlarging deferralClosure definition to include GG forms when FF forms are present
- If Phase 3 boundary fixes break existing proofs, preserve old theorems and add new ones with suffix `_direct`
- Git branch can be created for experimental changes before merging to main
- Prior commits can be reverted if completeness theorem breaks
