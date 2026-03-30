# Implementation Summary: Plan 14 - Backward Tracing Completion (v2)

**Task**: 67 - prove_bundle_validity_implies_provability
**Plan**: 14_backward-tracing-completion.md
**Status**: PARTIAL
**Date**: 2026-03-30
**Session**: sess_1774888312_2a0744

## Overview

This implementation progressed on the `boundary_implies_k_lt_B` proof using the backward tracing strategy identified in Report 39. The f_content backward trace case was completed. The g_content case remains blocked on G-depth infrastructure.

## Changes Made

### File Modified
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

### New Lemma Added: iter_F_add (line 641-655)
```lean
theorem iter_F_add (a b : Nat) (phi : Formula) :
    iter_F a (iter_F b phi) = iter_F (a + b) phi
```
This composition lemma enables backward tracing through f_content.

### f_content Case Completed (lines 2850-2858)
The f_content backward trace case in `boundary_implies_k_plus_d_bounded` is now complete:
```lean
-- Rewrite using iter_F_add: iter_F d' (iter_F d theta) = iter_F (d' + d) theta
rw [iter_F_add] at h_d'_in h_d'_not
-- h_d'_not has type iter_F (d' + 1 + d) theta, need to convert to (d' + d + 1)
have h_eq : d' + 1 + d = d' + d + 1 := by omega
rw [h_eq] at h_d'_not
-- Apply IH on k' with depth (d' + d)
have h_d'_d_ge : d' + d >= 1 := by omega
have h_bound := ih k' (Nat.lt_succ_self k') (d' + d) theta h_d'_d_ge h_d'_in h_d'_not
omega
```

### Documentation Enhanced (lines 2938-2948)
The g_content sorry now includes clear documentation of required infrastructure:
```
-- REQUIRED INFRASTRUCTURE (not yet implemented):
-- 1. Define g_nesting_depth : Formula -> Nat (analogous to f_nesting_depth)
-- 2. Define max_G_depth_in_closure phi := deferralClosure.sup g_nesting_depth
-- 3. Prove: formulas entering via g_content propagation are bounded by max_G_depth
-- 4. Use: k'+1 <= max_G_depth_in_closure phi
```

## Remaining Sorries

### g_content Entry Case (line 2949)
**Location**: Case 2 (neg case) of the inductive step in `boundary_implies_k_plus_d_bounded`
**Issue**: When `iter_F d theta` enters chain(k'+1) via g_content (not via f_content from chain(k'))
**Current State**: Formula `iter_F d theta` is in chain(k'+1) but `iter_F (d+1) theta` NOT in chain(k')

**Why Blocking**: The f_content backward trace fails. The formula must have entered via:
- g_content: `G(iter_F d theta)` was in chain(k')
- boundary_resolution_set
- Lindenbaum extension

**Required Infrastructure**:
1. `g_nesting_depth : Formula -> Nat` analogous to `f_nesting_depth`
2. `max_G_depth_in_closure phi := deferralClosure.sup g_nesting_depth`
3. Lemma: G-formula propagation through g_content is bounded by max_G_depth
4. Bound derivation: `k' + 1 <= max_G_depth_in_closure phi`

**Mathematical Soundness**: The theorem IS true because:
- deferralClosure(phi) is finite (based on phi's structure)
- G-nesting depth in deferralClosure is bounded by phi's G-depth
- G-content propagation can only occur for bounded chain positions

## Build Status

- `lake build` passes successfully
- No new axioms introduced (axiom count: 3, unchanged)
- Total sorries in SuccChainFMCS.lean: 8 (1 in boundary_implies_k_plus_d_bounded)

## Phase Summary

| Phase | Status | Notes |
|-------|--------|-------|
| Phase 1: f_content case | COMPLETED | iter_F_add lemma added, IH application fixed |
| Phase 1: g_content case | BLOCKED | Requires G-depth infrastructure |
| Phase 2: Main theorem | COMPLETED | Delegates to helper, no direct sorry |
| Phase 3: Verification | PARTIAL | Build passes, 1 sorry remains |

## Verification Results

```
sorry_count: 1 (in boundary_implies_k_plus_d_bounded)
axiom_count: 3 (unchanged)
build_passed: true
verification_passed: false (due to remaining sorry)
```

## Next Steps

To complete the proof, create a follow-up task to:

1. **Add G-depth infrastructure**:
   - Define `g_nesting_depth : Formula -> Nat`
   - Define `max_G_depth_in_closure phi`
   - Prove depth bounds for G-formulas in deferralClosure

2. **Prove G-propagation bound**:
   - Lemma: if psi enters chain(k) purely via g_content propagation, k <= max_G_depth
   - This requires tracking first-appearance or backward G-trace

3. **Complete g_content case**:
   - Use G-propagation bound to show k'+1 is bounded
   - Combine with existing depth bound for final inequality

## Mathematical Analysis

The proof strategy is sound:

**f_content path (COMPLETED)**:
- If `iter_F d theta` came from f_content, then `iter_F (d+1) theta` was in chain(k')
- Recursive IH application on k' with composed depth d' + d
- Bound derivation: k' + (d' + d) <= max_F_depth, so k' + 1 + d <= max_F_depth

**g_content path (BLOCKED)**:
- If `iter_F d theta` came from g_content, then `G(iter_F d theta)` was in chain(k')
- G-formulas propagate via g_content: G^m(iter_F d theta) in chain(k'+1-m)
- Tracing back to chain(0): G^(k'+1)(iter_F d theta) in M0.world
- But G^(k'+1) has G-nesting >= k'+1, bounded by max_G_depth
- Hence k'+1 <= max_G_depth, giving the required bound

The technical challenge is formalizing G-depth bounds, which requires new infrastructure.
