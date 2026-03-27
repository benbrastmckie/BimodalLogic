# Implementation Summary: Task 67 - Prove bundle_validity_implies_provability

- **Task**: 67 - prove_bundle_validity_implies_provability
- **Status**: BLOCKED - Fundamental gap identified
- **Session**: sess_1774655172_0f6f43
- **Date**: 2026-03-27

## Executive Summary

Deep analysis of the `bundle_validity_implies_provability` sorry revealed a fundamental architectural gap that cannot be resolved by filling the identified sorries. The gap is in connecting semantic validity (`valid_over Int phi`) to syntactic provability through the truth lemma infrastructure.

## Analysis Findings

### The Goal
Prove: `valid_over Int phi -> Nonempty ([] ⊢ phi)`

### Current Proof Structure
```
by_contra h_not_prov
have h_cons := not_provable_implies_neg_consistent phi h_not_prov
have _h := bundle_completeness_contradiction phi h_cons
sorry -- Need to derive False
```

We have:
- `h_valid : valid_over Int phi` (semantic: phi true at all points in all Int models)
- `h_cons : SetConsistent {phi.neg}` (syntactic: neg(phi) is consistent)
- `_h : not (forall M, SetMaximalConsistent M -> phi in M)` (syntactic: some MCS lacks phi)

### The Gap

To derive `False`, we need to connect:
1. `valid_over Int phi` (semantic truth everywhere)
2. `phi in M` for all MCS M (syntactic membership)

This requires the **truth lemma**: `phi in fam.mcs t <-> truth_at model Omega tau t phi`

### Why the Plan's Approach is Blocked

The plan identified filling sorries in `restricted_tc_family_to_fmcs`:
- `forward_G`: G(psi) in extended MCS at t -> psi in extended MCS at t'
- `backward_H`: H(psi) in extended MCS at t -> psi in extended MCS at t'

**Fundamental Blocker**: The extended MCSes at different positions are independent Lindenbaum extensions. They do NOT preserve the Succ relation between adjacent positions.

Specifically:
- `restricted_chain_ext phi fam n` = `lindenbaumMCS_set (restricted_chain n) ...`
- Each Lindenbaum extension is constructed independently
- G(psi) at position t does NOT imply G(psi) (or psi) at position t'
- The independent extensions can make arbitrary choices outside deferralClosure

### Architectural Issues Identified

1. **Two Coherence Levels**:
   - `BFMCS.temporally_coherent`: Family-level (F/P witnesses in SAME family)
   - `BundleTemporallyCoherent`: Bundle-level (F/P witnesses in ANY family)

2. **Truth Lemma Requirements**:
   - `shifted_truth_lemma` requires `BFMCS.temporally_coherent` (family-level)
   - `construct_bfmcs_bundle` only provides `BundleTemporallyCoherent` (bundle-level)

3. **Imp Case Circularity**:
   - Forward direction of truth lemma for Imp case requires backward direction
   - This blocks a pure "forward-only" truth lemma approach

## Alternative Paths Not Pursued

1. **FMP-based completeness** (`fmp_contrapositive`): Works with ClosureMCS membership, not semantic validity
2. **Succ-chain completeness** (`succ_chain_completeness`): Has own sorry via `succ_chain_truth_forward`
3. **Single-family BFMCS**: Would need to prove same-family F/P coherence, blocked by same Lindenbaum issue

## What Would Be Needed

To complete this proof, one would need:

1. **Coordinated Lindenbaum Extensions**: A construction where extensions at all positions are made coherently, preserving G/H propagation. This is non-trivial because:
   - The restricted chain is infinite (indexed by Int)
   - Independent choices at each position break coherence

2. **Alternative**: A new "bundle-level truth lemma" that works with `BundleTemporallyCoherent` instead of `BFMCS.temporally_coherent`. This would require redesigning the truth lemma proof.

3. **Alternative**: Prove completeness via a different path (e.g., FMP + semantic connection) that avoids the FMCS construction entirely.

## Files Modified

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`: Updated documentation in `restricted_tc_family_to_fmcs` sorries to explain the fundamental blocker.

## Recommendations

1. **Create New Task**: Design a coordinated Lindenbaum extension that preserves temporal coherence
2. **Alternative Approach**: Investigate FMP-based semantic completeness as a workaround
3. **Research**: Check modal logic literature for techniques to handle this gap (possibly "step-by-step" canonical model construction)

## Verification Results

- `lake build`: Passes (no new sorries introduced, original sorry remains)
- Sorry count in Completeness.lean: 2 (unchanged: `bundle_validity_implies_provability`, `dense_completeness_fc`)
- No axioms introduced

## Conclusion

The sorry in `bundle_validity_implies_provability` cannot be eliminated by the planned approach. The fundamental issue is that independent Lindenbaum extensions at each position break the G/H propagation required for the FMCS structure. A different architectural approach is needed.
