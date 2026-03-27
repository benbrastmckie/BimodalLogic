# Implementation Summary: Fix A1 BRS Mutual Exclusion (Partial)

**Task**: 58 - wire_completeness_to_frame_conditions
**Plan**: v14 - Fix A1: BRS Mutual Exclusion
**Session**: sess_1774632254_17a71e
**Status**: PARTIAL

## Progress

### Phase 1: COMPLETED
- Implemented Fix A1 on `boundary_resolution_set` in SuccExistence.lean
- Added mutual exclusion condition: `Formula.some_future chi.neg not in u`
- Updated `mem_boundary_resolution_set_iff` to include 3-way conjunction
- Build passes with no errors

### Phase 2: PARTIAL
- Proven `brs_mutual_exclusion`: If chi is in BRS, then chi.neg cannot be in BRS
- `neg_not_in_boundary_resolution_set` still has sorry (blocking)

### Phases 3-4: NOT STARTED

## Blocker Analysis

**Theorem**: `neg_not_in_boundary_resolution_set`

**Issue**: The theorem has hypothesis `F(chi) in u` (not `chi in BRS`). The proof requires showing that `F(chi) in u` implies `chi.neg not in BRS`.

The attempted proof path:
1. `F(chi) in u` implies (via G_dne contraposition) that `F(chi.neg.neg) in u`
2. Apply `drm_closed_under_derivation` to derive this

But `drm_closed_under_derivation` requires the conclusion `F(chi.neg.neg)` to be in `deferralClosure phi`. However:
- deferralClosure is finite (bounded)
- It is NOT closed under arbitrary double negation
- `chi.neg.neg` may not be in deferralClosure even when `chi` is

## Potential Fixes

1. **Change theorem signature**: Require `chi in BRS` instead of `F(chi) in u`, then `brs_mutual_exclusion` applies directly

2. **Extend deferralClosure**: Include necessary double negations of boundary formulas

3. **Alternative proof**: Find strategy that doesn't require closure under derivation

## Files Modified

| File | Change |
|------|--------|
| SuccExistence.lean | Fix A1: BRS definition with mutual exclusion |
| SuccChainFMCS.lean | `brs_mutual_exclusion` lemma (proven), partial `neg_not_in_boundary_resolution_set` |

## Build Status

- Lake build: SUCCESS
- Sorries remaining: 18 (project-wide)

## Next Steps

1. Resolve `neg_not_in_boundary_resolution_set` blocker using one of the potential fixes
2. Continue to Phase 3 (seed consistency)
3. Wire to Completeness.lean sorries (Phase 4)

## Recommendation

The most direct fix is **Option 1**: Change `neg_not_in_boundary_resolution_set` to require `chi in BRS` as hypothesis. Then the proven `brs_mutual_exclusion` lemma applies directly. This may require updating call sites.
