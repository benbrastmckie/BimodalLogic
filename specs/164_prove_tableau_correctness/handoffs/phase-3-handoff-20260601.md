# Phase 3 Handoff: Close truthLemma_neg via Modified branchTruth

## What Was Done
- Modified `branchTruth` definition for `untl`/`snce` in CountermodelExtraction.lean
- Changed from transitive-closure semantics (isTimeOrderedBefore) to direct-successor semantics (futureOf/pastOf) with conjunction (event AND guard at witness time)
- Added `sat_some_future_neg` and `sat_some_past_neg` saturation lemmas for the `guard = top` case
- Closed both sorry sites in `truthLemma_neg` (untl and snce cases)
- CountermodelExtraction.lean now has 0 sorry sites

## Key Decisions
- Phases 1 and 2 were skipped because analysis showed:
  - `sat_untl_neg_strong` is not provable from saturation alone (the filter condition `!contains(F(event)) && !contains(F(guard))` doesn't distinguish which branch was taken)
  - Propagation of `F(U(e,g))` to all reachable times is not guaranteed (auto-propagation only happens in `untlPos`, not in `allFutureNeg` or `someFuturePos`)
- The modified `branchTruth` approach works because `T(U(e,g))` is ALWAYS consumed in saturated branches (by `untlPos`/`someFuturePos`), making the positive case vacuous

## Current State
- CountermodelExtraction.lean: 0 sorry sites (down from 2)
- Saturation.lean: 1 sorry site (blocking_terminates at L663)

## Next Action
- Phase 4: Prove `blocking_terminates` in Saturation.lean
