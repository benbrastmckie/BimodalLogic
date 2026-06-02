# Phase 3 Completion Handoff (Round 5)

**Timestamp**: 2026-06-02T03:20:04Z
**Session**: sess_1780361777_843697

## What Was Done

1. **Refactored filter predicates in Tableau.lean**: Changed `!(a || b)` to `!a && !b` in the `untlNeg` and `snceNeg` cases of `applyRule` (lines 747, 772). This is semantically identical but eliminates the De Morgan normalization mismatch that blocked proofs in rounds 3-4.

2. **Proved `sat_untl_neg`**: Complete proof using:
   - Extract rule from `findApplicableRule = none` via `List.findSome?_eq_none_iff`
   - Simplify `isApplicable` for `.untlNeg`
   - Extract `applyRule` must return `.notApplicable` via match on `RuleResult` constructors
   - Unfold `applyRule` to get filter/match structure
   - Show filter list non-empty (t' passes predicate) via `List.mem_filter`
   - Rewrite filter cons case, get `branching = notApplicable` contradiction

3. **Proved `sat_snce_neg`**: Mirror proof using `asSince?`/`pastOf`.

4. **Cleaned lint warnings**: Removed unused simp arguments from new proofs.

## Current State

- **Sorry count in CountermodelExtraction.lean**: 2 (truthLemma_neg untl, truthLemma_neg snce)
- **Sorry count in Saturation.lean**: 1 (blocking_terminates)
- **Total in decidability modules**: 3 (down from 5 at start of round 5)
- **Build**: Passes (1680 jobs)

## Remaining Blockers

### truthLemma_neg untl/snce (Phase 4 blocker)

`sat_untl_neg` gives `F(event) OR F(guard)` at each immediate successor. But `branchTruth` for `untl` uses `isTimeOrderedBefore` (transitive closure). For a direct successor with only `F(guard)`, the Until could still hold (event could be true at that time). The structural IH on formula structure cannot be applied to `untl event guard` at a different time point.

**Possible approaches**:
- (a) Auxiliary induction over time ordering with `F(U(event,guard))` membership tracking
- (b) Stronger saturation invariant: `F(event) OR (F(guard) AND F(U(event,guard)))` at each future time
- (c) Modify `branchTruth` for `untl` to use `futureOf` instead of `isTimeOrderedBefore`
- (d) Add `F(event)` to branch 2 of `untlNeg` rule in `applyRule`

### blocking_terminates (Phase 5 blocker)
Requires pigeonhole argument over time types. Deferred.

## Files Modified

- `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` (filter predicate refactor)
- `Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean` (sat_untl_neg, sat_snce_neg proofs)
