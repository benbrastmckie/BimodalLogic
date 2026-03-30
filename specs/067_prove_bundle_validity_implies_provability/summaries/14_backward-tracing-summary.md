# Implementation Summary: Plan 14 - Backward Tracing Completion

**Task**: 67 - prove_bundle_validity_implies_provability
**Plan**: 14_backward-tracing-completion.md
**Status**: PARTIAL
**Date**: 2026-03-30

## Overview

This implementation attempted to complete the `boundary_implies_k_lt_B` proof using the backward tracing strategy identified in Report 39. Partial progress was made with a refactored proof structure.

## Changes Made

### File Modified
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

### New Lemma Added
Added `boundary_implies_k_plus_d_bounded` helper lemma (lines 2777-2916):
```lean
theorem boundary_implies_k_plus_d_bounded (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k d : Nat) (theta : Formula)
    (h_d_ge : d >= 1)
    (h_iter_in : iter_F d theta ∈ restricted_forward_chain phi M0 k)
    (h_iter_not : iter_F (d + 1) theta ∉ restricted_forward_chain phi M0 k) :
    k + d <= max (Bimodal.Syntax.max_F_depth_in_closure phi) 1
```

This stronger lemma proves `k + d` is bounded, which directly implies `k < B` when combined with `d >= 1`.

### Main Theorem Refactored
`boundary_implies_k_lt_B` (lines 2927-2964) now delegates to the helper lemma:
```lean
theorem boundary_implies_k_lt_B ... :=
  have h_bound := boundary_implies_k_plus_d_bounded phi M0 k d theta h_d_ge h_iter_in h_iter_not
  unfold closure_F_bound
  omega
```

## Remaining Sorries

Two sorries remain in `boundary_implies_k_plus_d_bounded`:

### 1. f_content Backward Trace (line 2824)
**Location**: Case 1 of the inductive step
**Issue**: Need to prove `iter_F n (iter_F d theta) = iter_F (n + d) theta` composition lemma and apply IH
**Required**: Technical proof of iter_F composition with correct arithmetic

### 2. g_content Entry Case (line 2915)
**Location**: Case 2 of the inductive step
**Issue**: When formula enters via g_content (G-wrapper) rather than f_content
**Required**: Bound on chain position for G-formula entry, likely requires analyzing G-nesting depth in deferralClosure

## Build Status

- `lake build` passes successfully
- No new axioms introduced
- Total sorries in SuccChainFMCS.lean: 20 (2 new in helper lemma)

## Phase Summary

| Phase | Status | Notes |
|-------|--------|-------|
| Phase 1: Helper Lemma | PARTIAL | Structure complete, 2 sorries in helper |
| Phase 2: Main Theorem | COMPLETED | Delegates to helper, no direct sorry |
| Phase 3: Verification | PARTIAL | Build passes, sorries remain |

## Next Steps

To complete the proof:

1. **Fix iter_F composition**: Implement the compose lemma properly using `iter_F_succ` rewriting
2. **Handle g_content case**: Prove that G-formula entry bounds chain position via G-nesting depth analysis
3. **Alternative**: Consider proving the stronger statement `k + d <= max_F_depth` directly by tracking cumulative depth increase through backward trace

## Mathematical Insight

The proof strategy is sound:
- For f_content path: Each backward step increases depth by at least 1, so `d + k <= max_F_depth`
- For g_content path: G-nesting depth in deferralClosure is bounded, limiting how many G-wrapper entries are possible

The technical challenge is formalizing these bounds in Lean 4.
