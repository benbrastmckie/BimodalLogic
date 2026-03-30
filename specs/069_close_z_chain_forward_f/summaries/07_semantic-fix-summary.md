# Implementation Summary: Semantic Fix for Temporal Coherence

**Task**: 69 - close_z_chain_forward_f
**Session**: sess_1774901855_f67aff
**Status**: Partial (4/6 phases fully completed, 2 partial)
**Date**: 2026-03-30

## Summary

This implementation aligned temporal coherence definitions with reflexive semantics by weakening the inequality constraints from strict (`t < s`) to weak (`t <= s`). This closes the edge case where `F(phi)` is semantically satisfied at `t` itself (when `phi` is already in `chain(t)`).

## Changes Made

### 1. TemporalCoherence.lean (Fully Closed)
- **Line 144**: Fixed comment from "irreflexive semantics" to "reflexive semantics"
- **Line 149**: Changed `t < s` to `t <= s` in `forward_F`
- **Line 152**: Changed `s < t` to `s <= t` in `backward_P`
- **Lines 166, 192**: Updated `temporal_backward_G/H` signatures to use weak inequality
- **Lines 218-219**: Updated `BFMCS.temporally_coherent` to use weak inequality

All sorries removed from this file.

### 2. ParametricTruthLemma.lean (Fully Closed)
- Updated backward direction of G/H cases in `parametric_canonical_truth_lemma`
- Updated backward direction of G/H cases in `parametric_shifted_truth_lemma`
- Now uses `h_all s hts` directly instead of `h_all s (le_of_lt hts)`

No new sorries introduced.

### 3. CanonicalConstruction.lean (Fully Closed)
- Updated `canonical_truth_lemma` backward G/H cases
- Updated `shifted_truth_lemma` backward G/H cases

No new sorries introduced.

### 4. UltrafilterChain.lean (Partial)
Key theorem closed:
- **`omega_F_preserving_forward_F_resolution`**: FULLY CLOSED
  - When `phi` is in `chain(t)`, returns `s = t` with `le_refl`
  - When `phi` is NOT in `chain(t)`, uses F-persistence and dovetailing (unchanged)

Other theorems partially updated:
- **`shifted_temporal_forward_F`**: Changed to use `t <= s`
- **`shifted_temporal_backward_P`**: Changed to use `s <= t`
- **`Z_chain_forward_F`**: Handles `phi` in `chain(t)` case; other case still sorry
- **`Z_chain_forward_F'`**: Handles `phi` in `chain(t)` case; other case still sorry
- **`Z_chain_backward_P`**: Handles `phi` in `chain(t)` case; other case still sorry
- **`omega_forward_F_bounded_persistence`**: Handles `phi` in `chain(t)` case; other case still sorry

## Technical Details

### The Semantic Mismatch (Resolved)
- **G semantics** (Truth.lean:125): `forall s, t <= s -> truth_at s phi`
- **Old temporal coherence**: `F(phi) at t -> exists s, t < s and phi at s` (too strong)
- **New temporal coherence**: `F(phi) at t -> exists s, t <= s and phi at s` (matches semantics)

### Why Weak Coherence is Correct
1. F(phi) is semantically satisfied when phi holds at some s >= t (including s = t)
2. The T-axiom `G(phi) -> phi` depends on reflexive semantics
3. With weak coherence, when phi is already in chain(t), returning s = t is valid

### Key Closed Theorem
```lean
theorem omega_F_preserving_forward_F_resolution (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (t : Nat) (phi : Formula) (h_F : Formula.some_future phi in chain(t)) :
    exists s, t <= s and phi in chain(s)
```
Previously had sorry for edge case; now fully closed.

## Remaining Work

The following sorries remain and require the F-preserving chain infrastructure:
1. `Z_chain_forward_F` (when phi not in chain(t))
2. `Z_chain_backward_P` (when phi not in chain(t))
3. `omega_forward_F_bounded_persistence` (when phi not in chain(t))

These could be resolved by:
- Using `omega_chain_F_preserving_forward` instead of `omega_chain_forward` in Z_chain
- Or proving the regular omega_chain_forward has equivalent resolution properties

## Verification Results

- **Build**: Passes successfully (938 jobs)
- **Sorry count**: 310 in entire Theories/ directory (no increase from baseline)
- **Axiom count**: 0 new axioms introduced
- **Key improvement**: `omega_F_preserving_forward_F_resolution` now fully closed

## Files Modified

| File | Changes | Status |
|------|---------|--------|
| TemporalCoherence.lean | Definition + signature updates | Fully closed |
| ParametricTruthLemma.lean | Proof alignment | Fully closed |
| CanonicalConstruction.lean | Proof alignment | Fully closed |
| UltrafilterChain.lean | Partial updates | Key theorem closed |

## Impact on Downstream Theorems

With weak coherence:
- `temporal_backward_G` and `temporal_backward_H` work correctly
- Truth lemmas align with semantic definitions
- `omega_F_preserving_forward_F_resolution` unblocks F-preserving chain completeness
- The edge case where F(phi) is satisfied at t itself no longer requires sorry
