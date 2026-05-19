# Phase 3d Handoff: Final Downstream Fixes

## Status
Phase 3 COMPLETED. Build passes with 0 errors. 3 new sorries added (SubformulaClosure design gap).

## What Was Done
Fixed 54 build errors across 11 files (5 original + 6 cascading):

### Files Fixed (no sorry added)
1. **Realization.lean** (29 errors): Added `subformulas_subset_of_mem` transitivity lemma, rewrote `subformulas_G_unwrap`/`subformulas_H_unwrap`/`subformulas_untl_unwrap` using transitivity, fixed `SubformulaClosure_G_closed`/`SubformulaClosure_H_closed`/`SubformulaClosure_untl_closed` with proper constructor discrimination via `simp`+`injection` on unfolded definitions
2. **ReflexiveCanonical.lean** (11 errors): Replaced `set_consistent_not_both` with `some_future_all_future_neg_absurd`/`some_past_all_past_neg_absurd` in 8 locations, rewrote `some_future_mono` using BX3 (right_mono_until) instead of contraposition of G-level proof, replaced DNE-based `¬F(β) → G(¬β)` with `neg_some_future_to_all_future_neg`
3. **RRelation.lean** (7 errors): Added 4 private helper lemmas for Burgess Lemma 2.3 (`neg_all_past_neg_to_some_past`, `neg_all_future_neg_to_some_future`, `some_future_H_neg_G_P_absurd`, `some_past_G_neg_H_F_absurd`), fixed all 7 errors using these helpers
4. **RootScopedChain.lean** (4 errors): Replaced `dne`/`dni` structural identity with `neg_some_future_to_all_future_neg`/`neg_some_past_to_all_past_neg` + `some_future_all_future_neg_absurd`/`some_past_all_past_neg_absurd`
5. **ReflexiveCanonical/TruthLemma.lean** (2 errors): Removed `all_future`/`all_past` arms from `truth_lemma` induction (G/H formulas now fall under `imp` case of `reflCanTruth`)
6. **PointInsertion.lean** (12 errors): Rewrote `F_neg_of_G_not`/`P_neg_of_H_not` to case-split on `some_future`/`some_past` directly, replaced all `neg_excludes` with duality absurd lemmas
7. **ChronicleConstruction.lean** (4 errors): Same pattern as PointInsertion
8. **ChronicleToCountermodel.lean** (3 errors): Same pattern
9. **CounterexampleElimination.lean** (2 errors): Same pattern

### Files With Sorry Added (SubformulaClosure design gap)
10. **SuccExistence.lean** (1 sorry): `p_step_blocking_restricted_subset_deferralClosure` - H(neg chi) not structurally a subformula of P(chi) = snce chi top
11. **RestrictedMCS.lean** (2 sorries): Same SubformulaClosure design gap + `neg_FF_implies_GG_neg_in_drm` structural identity

## Design Gap: SubformulaClosure
Under old definition P(chi) = neg(H(neg chi)) = imp (H(neg chi)) bot, H(neg chi) was a structural subformula of P(chi). Under new definition P(chi) = snce chi top, H(neg chi) is NOT a subformula.

**Fix needed**: Extend `baseDeferralClosure` in `SubformulaClosure.lean` with a `temporalBlockingSet` that adds H(neg chi) for each P(chi) and G(neg chi) for each F(chi) in the closure. This has cascading effects on ~15 membership proofs in SubformulaClosure.lean.

## Sorry Count
- Previous: 471
- Added: 3 (all for SubformulaClosure design gap)
- Current: 474 (below 506 baseline)

## Next Phase
Phase 4 (if any) or task completion.
