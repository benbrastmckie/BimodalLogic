# Implementation Summary: Task 69 - Phase 1 Partial

**Task**: 69 - close_z_chain_forward_f
**Date**: 2026-03-30
**Status**: Partial (Phase 1 of 6)
**Session**: sess_1774903815_c91e2b

## Summary

Restructured `f_preserving_seed_consistent` proof with significant progress but 2 sorries remain in edge cases requiring strong induction. Build passes. Downstream `temporal_theory_witness_F_preserving` compiles with inherited sorries.

## Changes Made

### File Modified
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`
  - Lines 1447-2111: Restructured `f_preserving_seed_consistent` proof

### Proof Structure

The proof now handles multiple cases:

1. **Case 1: All L in standard seed** - Handled by `temporal_theory_witness_consistent` (COMPLETE)

2. **Case 2: Some F(psi) from F_unresolved_theory**
   - Sub-case 2a: phi in M - All seed elements in M, derive contradiction (COMPLETE)
   - Sub-case 2b: phi not in M
     - Sub-sub-case: phi not in L_no_F - L_no_F subset of M, derive contradiction (COMPLETE)
     - Sub-sub-case: phi in L_no_F, L_no_phi subset of temporal_box_seed
       - G(phi) in M: Use T-axiom to derive G(neg psi) in M, contradiction (COMPLETE)
       - G(phi) not in M: **SORRY** - requires different approach
     - Sub-sub-case: L_no_phi has more F-formulas - **SORRY** - requires strong induction

## Remaining Sorries

| Line | Context | Reason |
|------|---------|--------|
| 2068 | `G(phi) not in M` subcase | Derived `G(phi -> G(neg psi)) in M` but cannot directly derive contradiction |
| 2073 | `L_no_phi has F-formulas` | Requires strong induction on F-formula count |

## Technical Analysis

### Why G(phi) not in M case is difficult

When `G(phi) not in M`:
1. We have `F(neg phi) in M` (by MCS negation completeness)
2. We derived `G(phi -> G(neg psi)) in M` via G-lift
3. We can construct `{F(psi), phi, G(...)} subset seed` with derivation to bot
4. But this only shows inconsistency propagates, not that M is inconsistent

The fundamental issue: `neg(phi)` may not be in the seed, so `{phi, neg(phi)}` doesn't witness seed inconsistency even though `neg(phi) in M`.

### Why strong induction is needed

When `L_no_phi` contains additional F-formulas from `F_unresolved_theory M`:
1. These F-formulas are in M but not G-liftable
2. Need to extract them iteratively
3. Track that each extraction maintains the invariant
4. Base case: all remaining elements are G-liftable

## Build Status

- `lake build`: PASSES
- Sorries: 2 in `f_preserving_seed_consistent`
- Downstream impact: `temporal_theory_witness_F_preserving` and chain construction inherit sorries

## Next Steps

To complete Phase 1:
1. Develop strong induction helper lemma for F-formula extraction
2. Handle `G(phi) not in M` case - may need semantic argument or different approach
3. Consider if the theorem statement itself needs refinement

## Phases Remaining

| Phase | Status | Description |
|-------|--------|-------------|
| 1 | PARTIAL | Close f_preserving_seed_consistent (2 sorries remain) |
| 2 | NOT STARTED | Add omega_chain_F_preserving_forward_G_monotone |
| 3 | NOT STARTED | Redefine Z_chain for Forward Direction |
| 4 | NOT STARTED | Update Z_chain Property Lemmas |
| 5 | NOT STARTED | Close Z_chain_forward_F Sorries |
| 6 | NOT STARTED | Verify Downstream and Document Gaps |

## Code References

| Location | Description |
|----------|-------------|
| Lines 1447-2111 | `f_preserving_seed_consistent` proof |
| Line 2068 | First sorry (G(phi) not in M case) |
| Line 2073 | Second sorry (strong induction case) |
| Line 2114 | `temporal_theory_witness_F_preserving` (uses f_preserving_seed_consistent) |
