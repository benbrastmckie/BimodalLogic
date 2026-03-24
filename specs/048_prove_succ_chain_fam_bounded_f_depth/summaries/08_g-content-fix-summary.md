# Implementation Summary: Task #48 v8 (G-Content Fix)

**Task**: 48 - prove_succ_chain_fam_bounded_f_depth
**Plan Version**: 8 (g-content-fix)
**Session**: sess_1774307545_c7ec7f
**Date**: 2026-03-23
**Status**: BLOCKED

## Summary

Attempted to implement the g-content path fix as outlined in plan v8. Analysis during implementation revealed that the primed theorems (`restricted_succ_propagates_F_not'` and `restricted_single_step_forcing'`) are NOT provable with just the `h_GF_not` hypothesis as originally planned.

## What Was Done

### Added Primed Theorems (Lines 3241-4250)

Added two strengthened theorem declarations with `h_GF_not : GF(psi) ∉ chain(k)` hypothesis:
- `restricted_succ_propagates_F_not'`
- `restricted_single_step_forcing'`

### Discovery: Additional Path via Negation Completeness

During proof attempts, discovered that when `GF(psi) ∉ chain(k)` but `GF(psi) ∈ dc`:
1. Negation completeness for restricted MCS gives `neg(GF(psi)) ∈ chain(k)`
2. `neg(GF(psi))` is provably equivalent to `FG(psi.neg)` (modal duality)
3. So `FG(psi.neg) ∈ chain(k)`, meaning `G(psi.neg) ∈ f_content(chain(k))`
4. By f_step: `G(psi.neg) ∈ chain(k+1) ∪ f_content(chain(k+1))`
5. If `G(psi.neg)` is deferred (not in chain(k+1)), then `F(psi)` can still be in chain(k+1) by MCS maximality

This means the hypothesis `h_GF_not` alone does NOT block all paths.

## Current State

### Sorry Count
- **Before**: 4 sorries (lines 736, 971, 3077, 3236)
- **After**: 7 sorries (lines 736, 971, 3077, 3236, 3984, 4212, 4224)

The new sorries are in the primed theorems for cases that proved unprovable.

### Build Status
- `lake build` PASSES (928 jobs)

## Blocking Issue

The plan assumed that adding `h_GF_not : GF(psi) ∉ chain(k)` would be sufficient to block the g_content path. Analysis shows this is insufficient when `GF(psi) ∈ dc` because:
1. Negation completeness in restricted MCS applies to formulas in `subformulaClosure`
2. `GF(psi) ∈ dc` implies `GF(psi) ∈ closureWithNeg`, which means `GF(psi) ∈ subformulaClosure` (since G-formulas are not neg-images)
3. So either `GF(psi) ∈ u` or `neg(GF(psi)) ∈ u`
4. The negation path leads to `FG(psi.neg) ∈ u`, which can allow `F(psi) ∈ v`

## Recommended Next Steps

### Option A: Further Strengthen Hypotheses
Add hypothesis `GF(psi) ∉ dc` to completely block all paths. This makes the theorem weaker but provable.

### Option B: Direct Bounded Witness Approach
Skip the primed theorems entirely. Prove `restricted_bounded_witness'` directly using:
1. Case analysis on whether `F(psi)` enters chain(k+1)
2. If yes via g_content: track `g_depth` decrease
3. Use lexicographic termination on `(f_depth, g_depth)`
4. Finite `dc` ensures both measures are bounded

### Option C: Alternative Chain Construction
Modify the chain construction to prioritize F-resolution over F-deferral when at the boundary. This would make the theorems true by construction.

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
  - Added primed theorems with sorries (lines 3241-4250)
  - Added detailed analysis comments explaining the blocking

## Artifacts

- Plan: `specs/048_prove_succ_chain_fam_bounded_f_depth/plans/08_g-content-fix.md` (updated to BLOCKED)
- Summary: This file
