# Handoff: Task 67 - Phase 1 Partial Progress

## Session: sess_1774767258_fdd40e
## Date: 2026-03-29

## Summary

Phase 1 of Plan 05 has been partially completed. The deferralClosure has been extended with seriality formulas, but there are downstream issues with depth bounds.

## Completed Work

### SubformulaClosure.lean Changes

1. **Added seriality abbreviations** (lines 651-669):
   - `F_top : Formula` - F(neg bot)
   - `P_top : Formula` - P(neg bot)
   - `neg_neg_bot : Formula` - neg(neg bot)
   - `G_neg_neg_bot : Formula` - G(neg neg bot)
   - `H_neg_neg_bot : Formula` - H(neg neg bot)

2. **Extended serialityFormulas** (line 670):
   ```lean
   def serialityFormulas : Finset Formula :=
     {F_top, P_top, Formula.neg Formula.bot, neg_neg_bot, G_neg_neg_bot, H_neg_neg_bot}
   ```

3. **Updated deferralClosure definition** (line 680):
   ```lean
   def deferralClosure (phi : Formula) : Finset Formula :=
     closureWithNeg phi ∪ deferralDisjunctionSet phi ∪ backwardDeferralSet phi ∪ serialityFormulas
   ```

4. **Added membership theorems**:
   - `F_top_mem_deferralClosure`
   - `P_top_mem_deferralClosure`
   - `neg_bot_mem_deferralClosure`
   - `neg_neg_bot_mem_deferralClosure`
   - `G_neg_neg_bot_mem_deferralClosure`
   - `H_neg_neg_bot_mem_deferralClosure`

5. **Updated depth bound theorems**:
   - `max_F_depth_deferralClosure_eq` now returns `max (max_F_depth_in_closure phi) 1`
   - `max_P_depth_deferralClosure_eq` now returns `max (max_P_depth_in_closure phi) 1`

6. **Created new case-based theorems**:
   - `some_future_in_deferralClosure_cases` - returns `... ∈ closureWithNeg ∨ ... = F_top`
   - `some_past_in_deferralClosure_cases` - returns `... ∈ closureWithNeg ∨ ... = P_top`
   - `all_future_in_deferralClosure_cases` - returns `... ∈ closureWithNeg ∨ ... = G_neg_neg_bot`
   - `all_past_in_deferralClosure_cases` - returns `... ∈ closureWithNeg ∨ ... = H_neg_neg_bot`

7. **Added key inner formula theorems**:
   - `F_inner_in_deferralClosure` - if F(chi) ∈ deferralClosure, then chi ∈ deferralClosure
   - `P_inner_in_deferralClosure` - if P(chi) ∈ deferralClosure, then chi ∈ deferralClosure

### SuccExistence.lean Changes

1. **Fixed `boundary_resolution_set_subset_deferralClosure`** - now uses `F_inner_in_deferralClosure` directly

2. **Fixed `p_step_blocking_restricted_subset_deferralClosure`** - handles P_top case using `H_neg_neg_bot_mem_deferralClosure`

### RestrictedMCS.lean Changes

1. **Fixed `p_step_blocking_restricted_subset`** - uses `some_past_in_deferralClosure_cases`

## Blocking Issues

### Depth Bound Changes

The change to `max_F_depth_deferralClosure_eq` breaks several proofs that use omega:

1. **RestrictedMCS.lean**:
   - Line ~1108: `iter_F_not_mem_deferralClosure` proof fails
   - Lines ~1152, ~1195, ~1221: Similar omega failures

The issue is that the old bound was `max_F_depth_in_closure phi`, but the new bound is `max (max_F_depth_in_closure phi) 1`. This affects:
- When `max_F_depth_in_closure phi = 0`, the new bound is 1 (not 0)
- Proofs that use `closure_F_bound = max_F_depth_in_closure + 1` now need `closure_F_bound = max (max_F_depth_in_closure phi) 1 + 1`

### Suggested Fix

Update `closure_F_bound` definition in `CanonicalTaskRelation.lean`:
```lean
def closure_F_bound (phi : Formula) : Nat :=
  max (Bimodal.Syntax.max_F_depth_in_closure phi) 1 + 1
```

Or alternatively, update `iter_F_exceeds_max_depth` to prove:
```lean
lemma iter_F_exceeds_max_depth (phi : Formula) (n : Nat) (h : n ≥ closure_F_bound phi) :
    Bimodal.Syntax.f_nesting_depth (iter_F n phi) > max (Bimodal.Syntax.max_F_depth_in_closure phi) 1
```

## Files Modified

1. `Theories/Bimodal/Syntax/SubformulaClosure.lean` - BUILDS OK
2. `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - BUILDS OK
3. `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` - BUILD FAILS (omega issues)

## Files Not Yet Modified

Per Plan 05:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - 13+ call sites
- `Theories/Bimodal/FrameConditions/Completeness.lean` - main sorry at line 176

## Next Steps

1. Fix depth bound issues in RestrictedMCS.lean by updating `closure_F_bound`
2. Update SuccChainFMCS.lean call sites (Phase 3)
3. Complete SuccExistence.lean fixes (Phase 4)
4. Continue with Phases 5-7

## Plan Status

- Phase 1: [PARTIAL] - deferralClosure extended, depth bound needs fix
- Phase 2: [COMPLETED] - F/P theorems updated to cases
- Phase 3: [NOT STARTED]
- Phase 4: [PARTIAL] - SuccExistence.lean done, RestrictedMCS.lean has issues
- Phase 5: [NOT STARTED]
- Phase 6: [NOT STARTED]
- Phase 7: [NOT STARTED]
