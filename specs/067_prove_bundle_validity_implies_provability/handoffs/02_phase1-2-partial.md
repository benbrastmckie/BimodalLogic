# Handoff: Task 67 - Phases 1-2 Partial Progress

## Session: sess_1774767258_fdd40e
## Date: 2026-03-29

## Summary

Phases 1-2 of Plan 05 are substantially complete. The deferralClosure has been extended with seriality formulas including their deferral disjunctions. Depth bound issues have been resolved. However, 13 call sites in SuccChainFMCS.lean still reference the old theorem name.

## Completed Work

### 1. SubformulaClosure.lean - Extended Seriality Formulas

**Added formulas**:
- `F_top_deferral : Formula` - `Formula.or (Formula.neg Formula.bot) F_top`
- `P_top_deferral : Formula` - `Formula.or (Formula.neg Formula.bot) P_top`

**Extended serialityFormulas** (now 8 elements):
```lean
def serialityFormulas : Finset Formula :=
  {F_top, P_top, Formula.neg Formula.bot, neg_neg_bot, G_neg_neg_bot, H_neg_neg_bot,
   F_top_deferral, P_top_deferral}
```

**Added membership theorems**:
- `F_top_deferral_mem_serialityFormulas`
- `P_top_deferral_mem_serialityFormulas`
- `F_top_deferral_mem_deferralClosure`
- `P_top_deferral_mem_deferralClosure`

**Added comprehensive deferral theorems**:
- `deferral_of_F_in_deferralClosure` - if F(chi) ∈ deferralClosure, then chi ∨ F(chi) ∈ deferralClosure
- `deferral_of_P_in_deferralClosure` - symmetric for P

**Updated all case analysis** to handle 8 serialityFormulas elements instead of 6:
- `max_F_depth_deferralClosure_eq`
- `max_P_depth_deferralClosure_eq`
- `non_imp_in_deferralClosure_is_in_closureWithNeg`
- `some_future_in_deferralClosure_cases`
- `some_past_in_deferralClosure_cases`
- `all_future_in_deferralClosure_cases`
- `all_past_in_deferralClosure_cases`

### 2. CanonicalTaskRelation.lean - Fixed Depth Bounds

Changed `closure_F_bound` and `closure_P_bound` to account for F_top/P_top depth 1:
```lean
def closure_F_bound (phi : Formula) : Nat :=
  max (Bimodal.Syntax.max_F_depth_in_closure phi) 1 + 1

def closure_P_bound (phi : Formula) : Nat :=
  max (Bimodal.Syntax.max_P_depth_in_closure phi) 1 + 1
```

Updated `iter_F_exceeds_max_depth` and `iter_P_exceeds_max_depth` lemmas to prove:
```lean
f_nesting_depth (iter_F n phi) > max (max_F_depth_in_closure phi) 1
```

### 3. RestrictedMCS.lean - Fixed omega Proofs

Fixed argument order in `iter_F_f_nesting_depth` call at line 1095-1096.

### Build Status

| File | Status |
|------|--------|
| SubformulaClosure.lean | ✅ BUILDS |
| CanonicalTaskRelation.lean | ✅ BUILDS |
| RestrictedMCS.lean | ✅ BUILDS |
| SuccChainFMCS.lean | ❌ 13 errors |

## Remaining Work

### Phase 3: SuccChainFMCS.lean Call Sites (13 errors)

The old theorem `some_future_in_deferralClosure_is_in_closureWithNeg` no longer exists. It was replaced with:
- `some_future_in_deferralClosure_cases` - returns `∈ closureWithNeg ∨ = F_top`
- `deferral_of_F_in_deferralClosure` - directly proves deferral ∈ deferralClosure

**Broken call sites**:
- Line 1020: `deferralDisjunctions_subset_deferralClosure`
- Line 1040: `pastDeferralDisjunctions_subset_deferralClosure`
- Line 1244: F-formula deferral membership
- Line 1493, 1568: G(neg psi) extraction
- Line 1868: F(psi) inner
- Line 2098: psi in deferralClosure from F(psi)
- Line 2423: F_top inner (neg bot) in deferralClosure
- Line 3145: F(chi) inner extraction
- Line 3305: P-formula membership
- Line 3578: P-formula extraction
- Line 3782: F-formula membership
- Line 3854: P_top inner

**Fix pattern for deferral membership**:
```lean
-- Old:
have h_F_in_cwn := some_future_in_deferralClosure_is_in_closureWithNeg phi chi (h_u h_F_chi)
exact deferral_of_F_in_closure phi chi h_F_in_cwn

-- New:
exact deferral_of_F_in_deferralClosure phi chi (h_u h_F_chi)
```

**Fix pattern for inner membership**:
```lean
-- Old:
have h_F_in_cwn := some_future_in_deferralClosure_is_in_closureWithNeg ...
have h_chi_in_sub := some_future_in_closureWithNeg_inner_in_subformulaClosure ...
-- chain to deferralClosure

-- New:
exact F_inner_in_deferralClosure phi chi h_F_in_dc
```

### Phases 4-7 (Not Yet Started)

- Phase 4: SuccExistence.lean call sites
- Phase 5: DeferralRestrictedSerialMCS construction
- Phase 6: Complete bundle_validity_implies_provability
- Phase 7: Verification and cleanup

## Files Modified

| File | Changes |
|------|---------|
| SubformulaClosure.lean | Extended serialityFormulas, added deferral theorems |
| CanonicalTaskRelation.lean | Fixed depth bounds |
| RestrictedMCS.lean | Fixed omega proof, argument order |

## Next Steps

1. Fix 13 call sites in SuccChainFMCS.lean using new theorems
2. Build and verify
3. Continue with Phases 4-7
