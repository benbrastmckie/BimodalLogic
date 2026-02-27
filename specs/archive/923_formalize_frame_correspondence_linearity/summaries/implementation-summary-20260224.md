# Implementation Summary: Task #923

**Completed**: 2026-02-24
**Duration**: ~1 hour (all 4 phases completed in single session)
**Session**: sess_1771966977_fa35b6

## Changes Made

Proved the `canonical_reachable_linear` theorem in `CanonicalEmbedding.lean`, eliminating the last sorry in the canonical frame linearity proof. This is a key prerequisite for the Canonical Quotient approach to bimodal completeness (Task 922).

### Proof Strategy: Compound-Formula Linearity with Cross-Propagation

The proof assumes NOT(CanonicalR M1 M2) and NOT(CanonicalR M2 M1) and derives a contradiction using the linearity axiom applied to carefully chosen compound formulas.

**Key insight**: Use BOTH non-comparability witnesses simultaneously. Given:
- alpha: G(alpha) in M1, neg(alpha) in M2 (from NOT CanonicalR M1 M2)
- beta: G(beta) in M2, neg(beta) in M1 (from NOT CanonicalR M2 M1)

Construct compound formulas:
- phi_c = G(alpha) AND neg(beta) (in M1)
- psi_c = G(beta) AND neg(alpha) (in M2)

Apply `mcs_F_linearity` with phi_c and psi_c. All three cases yield contradiction:
- Case 1: World has G(alpha) and neg(alpha) -- direct contradiction via T-axiom
- Case 2: Outer world has G(alpha), propagates to inner world where neg(alpha) lives
- Case 3: Outer world has G(beta), propagates to inner world where neg(beta) lives

This avoids the infinite regress problem identified in the research report (Section 9-14) that occurs when using a single witness formula. The dual-witness compound formula ensures that in both Cases 2 and 3, the G-component from one formula propagates through CanonicalR to create a contradiction with the neg-component of the other formula.

### Why This Works When Single-Witness Approaches Failed

Prior approaches using phi = G(alpha) and psi = neg(alpha) failed at Case 3 because:
- Case 3 gives a world W with F(G(alpha)) and neg(alpha)
- G(alpha) is at a successor W' of W, but neg(alpha) is at W
- There is no propagation from W' back to W

The compound-formula approach works because in Case 3:
- The outer world W has G(beta) (from psi_c) and F(phi_c)
- The inner world W' has neg(beta) (from phi_c)
- G(beta) propagates FORWARD from W to W' via CanonicalR, contradicting neg(beta) at W'

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/CanonicalEmbedding.lean`
  - Replaced sorry with complete proof of `canonical_reachable_linear`
  - Updated theorem docstring with actual proof strategy
  - No new helper lemmas needed (existing infrastructure sufficient)

## Sorry Delta

- Before: 1 sorry in `canonical_reachable_linear`
- After: 0 sorries in `CanonicalEmbedding.lean`

## Verification

- `lake build` succeeds with no errors (full project, 1001 jobs)
- `canonical_reachable_linear` compiles without sorry
- No new axioms introduced
- Theorem docstring accurately describes the compound-formula proof strategy

## Dependencies Used (No New Lemmas)

All of the following existed prior to this implementation:
- `mcs_F_linearity` (linearity axiom in MCS)
- `canonical_forward_F` (F-witness construction via Lindenbaum)
- `canonical_F_of_mem_successor` (existence lemma: phi in successor implies F(phi) in root)
- `canonical_forward_G` (G-propagation through CanonicalR)
- `set_mcs_conjunction_intro` / `set_mcs_conjunction_elim` (MCS conjunction properties)
- `set_consistent_not_both` (MCS consistency: phi and neg(phi) cannot coexist)
- `set_mcs_negation_complete` (MCS: either phi or neg(phi) in MCS)

## Impact

This proof unblocks the Canonical Quotient approach (Task 922) by establishing that the canonical frame's reachable fragment is linearly ordered. Combined with the existing `canonical_forward_F`, `canonical_backward_P`, `canonicalR_reflexive`, and `canonicalR_transitive`, the canonical frame now has all the structural properties needed for embedding into the integers.
