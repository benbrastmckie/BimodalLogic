# Implementation Summary: Task #979 (Partial)

**Task**: 979 - remove_discrete_icc_finite_axiom_prove_stage_bounding
**Status**: PARTIAL (Phase 3 BLOCKED)
**Date**: 2026-03-16
**Session**: sess_1773698234_dfbb66
**Plan**: specs/979_remove_discrete_icc_finite_axiom_prove_stage_bounding/plans/implementation-002.md

## Summary

Task 979 attempted to remove the `discrete_Icc_finite_axiom` from DiscreteTimeline.lean by proving interval finiteness via a covering lemma approach. The implementation was blocked at Phase 3 when the core covering lemma proof could not be completed.

## Phases Completed

### Phase 1: Infrastructure Audit [COMPLETED]
- Verified task 980 MCS Richness lemmas are accessible
- Documented DF soundness infrastructure in Soundness.lean
- Verified CanonicalR infrastructure and canonicalR_strict theorem
- Confirmed baseline compiles with `lake build`

### Phase 2: State Covering Lemma [COMPLETED]
- Added `MCS.Covers` definition: covering predicate for MCS pairs
- Added `mcs_has_immediate_successor` theorem statement
- Documented proof strategy in docstring

### Phase 3: Prove Covering Lemma [BLOCKED]
- Started proof using canonical_forward_F and seriality
- Obtained forward witness W for F(neg bot) formula
- Set up contradiction goal: given K strictly between M and W, prove False
- BLOCKED: Cannot derive contradiction using DF axiom membership

## Technical Details

### What Was Added

1. **MCS.Covers definition** (DiscreteTimeline.lean):
   ```lean
   def MCS.Covers (M W : Set Formula) : Prop :=
     CanonicalR M W ∧ forall K, SetMaximalConsistent K ->
       CanonicalR M K -> CanonicalR K W -> K = M or K = W
   ```

2. **mcs_has_immediate_successor** (with sorry):
   - Proof structure established
   - Forward witness obtained via canonical_forward_F
   - Contradiction case set up but cannot be discharged

### The Blocking Gap

The covering lemma requires proving: if K is strictly between M and W (with CanonicalR M K, CanonicalR K W, K != M, K != W), then we get a contradiction.

**What we have**:
- h_MK: g_content(M) subset K
- h_KW: g_content(K) subset W
- DF axiom in every MCS: (F top and phi and H phi) -> F(H phi)
- g_content_subset_implies_h_content_reverse

**What we cannot bridge**:
- DF membership is a SYNTACTIC property (certain formulas are in M)
- Covering is a STRUCTURAL property (no MCS between M and W)
- The gap is connecting these two domains

**Approaches tried**:
1. Using F(H(phi)) in M from DF - propagates backwards, doesn't constrain K
2. Finding distinguishing formula for K != W - formula may be outside g_content
3. Using h_content reversal - doesn't give contradiction for intermediate K

## Current State

- **Axiom still present**: `discrete_Icc_finite_axiom` (line 303)
- **Sorries**: 1 in `mcs_has_immediate_successor`
- **Build**: passes (930 jobs, 1 sorry warning)

## Files Modified

- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`
  - Added `open Bimodal.ProofSystem`
  - Added `MCS.Covers` definition and documentation
  - Added `mcs_has_immediate_successor` theorem with proof structure

## Recommendations

1. **Option A**: Seek alternative proof strategy for covering lemma
   - Perhaps a different forward witness construction?
   - Perhaps a different use of DF axiom?

2. **Option B**: Accept axiom as documented debt for now
   - The axiom is correctly located in discrete-specific code
   - Task 978 can proceed with typeclass architecture
   - Proof can be completed in future with new insights

3. **Option C**: Research alternative interval finiteness proof
   - Perhaps direct stage-bounding is possible after all?
   - Or a different characterization of discreteness?

## References

- research-003.md: Post-980 analysis identifying covering as hard
- CanonicalFrame.lean: canonical_forward_F construction
- WitnessSeed.lean: g_content_subset_implies_h_content_reverse
- Soundness.lean: discreteness_forward_valid (DF frame condition)
