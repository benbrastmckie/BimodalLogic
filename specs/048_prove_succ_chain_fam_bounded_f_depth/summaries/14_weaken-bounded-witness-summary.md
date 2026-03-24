# Implementation Summary: Task #48 - Prove succ_chain_fam bounded F-depth (v13)

**Task**: 48 - prove_succ_chain_fam_bounded_f_depth
**Plan Version**: 13
**Status**: PARTIAL
**Date**: 2026-03-23

## Overview

This implementation attempt addressed the two sorries in `SuccChainFMCS.lean` (originally at lines 2360 and 3012) using the "weaken hypothesis" approach from plan v13.

## Progress Made

### Phase 1: Caller Analysis and Hypothesis Design [COMPLETED]

- Traced the call chain from `restricted_forward_chain_iter_F_witness` through `restricted_bounded_witness` to `restricted_single_step_forcing`
- Identified that `restricted_forward_chain_F_bounded` provides bound `d` where `iter_F d psi` is in chain and `iter_F (d+1) psi` is not
- Discovered that the plan's hypothesis `h_iter_in_dc` doesn't directly cover the `FF(psi)` case needed for `restricted_single_step_forcing`

### Phase 2: Modify restricted_single_step_forcing [PARTIAL]

**Successfully completed:**
- Proved the case where `FF(psi) in deferralClosure` (approximately lines 2355-2450)
- Key insight: When `FF(psi) in closureWithNeg`, the intermediate formula `G(F(psi).neg) in subformulaClosure` in both subcases:
  - If `FF(psi) in subformulaClosure`: by `closure_imp_left`
  - If `FF(psi) = g.neg` for `g in subformulaClosure`: then `g = G(F(psi).neg)` directly
- Used `drm_closed_under_derivation` to derive `G(F(psi).neg) in chain(k)`
- Applied g_persistence to get `F(psi).neg in chain(k+1)`
- Used DRM consistency to conclude `F(psi) not in chain(k+1)`
- Combined with f_step to prove `psi in chain(k+1)`

**Not completed:**
- The case where `FF(psi) not in deferralClosure` remains as sorry (line 3070)
- This case is fundamentally harder because:
  - Cannot use negation completeness for `FF(psi)` (it's outside deferralClosure)
  - Cannot derive `G(F(psi).neg) in chain(k)` via the modal duality argument
  - The f_step only gives `psi in v OR F(psi) in v`, cannot force the first disjunct

## Key Technical Findings

1. **closureWithNeg has two-case structure for F-formulas**: When `FF(psi) in closureWithNeg`:
   - Either `FF(psi) in subformulaClosure` (directly a subformula of phi)
   - Or `FF(psi) = g.neg` where `g in subformulaClosure` (in the negation image)
   - In both cases, `G(F(psi).neg) in subformulaClosure`

2. **The boundary case is real**: When `F(psi) in deferralClosure` but `FF(psi) not in deferralClosure`:
   - This can happen when `F(psi)` is at the edge of subformulaClosure
   - No modal duality argument is available
   - The theorem statement may be too strong for this case

3. **Plan v13's hypothesis doesn't suffice**: The hypothesis `h_iter_in_dc : forall i <= d, iter_F i psi in deferralClosure` only covers iterations up to `d`, but `restricted_single_step_forcing` needs `FF(psi) = iter_F (d+1) psi in deferralClosure`.

## Remaining Sorries in SuccChainFMCS.lean

| Line | Theorem | Issue |
|------|---------|-------|
| 3070 | restricted_single_step_forcing | FF(psi) not in deferralClosure case |
| 3102 | restricted_succ_propagates_F_not | FF(psi) in deferralClosure case (same as fixed above, needs porting) |
| 3116 | restricted_succ_propagates_F_not | F(psi) in dc but FF(psi) not in dc boundary case |
| 3187 | restricted_succ_propagates_F_not' | FF(psi) in deferralClosure case (same pattern) |
| 3765 | restricted_succ_propagates_F_not' | Complex derivation in boundary case |
| 3993 | restricted_succ_propagates_F_not' | g_depth tracking for boundary |
| 4005 | restricted_succ_propagates_F_not' | Additional boundary case |

## Recommendations for Next Attempt

1. **Port the successful proof**: The proof for `FF(psi) in deferralClosure` in `restricted_single_step_forcing` can be directly applied to `restricted_succ_propagates_F_not` (line 3102) and `restricted_succ_propagates_F_not'` (line 3187).

2. **Strengthen hypothesis further**: Consider adding `h_FF_dc : FF(psi) in deferralClosure` as an explicit hypothesis to `restricted_single_step_forcing`, making the problematic case unreachable. Then propagate this requirement to callers.

3. **Consider alternative theorem statement**: Instead of `psi in chain(k+1)`, prove `psi in chain(k+1) OR F(psi) in chain(k+1)` and adjust `restricted_bounded_witness` to handle the disjunction with termination reasoning.

4. **Investigate filtration approach**: If the hypothesis strengthening doesn't work for all callers, the filtration-based approach (Fallback A from research) may be necessary.

## Build Status

- `lake build` passes with no errors
- All existing sorries preserved (no regressions)
- New proof code compiles correctly

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (partial proof for one case)
