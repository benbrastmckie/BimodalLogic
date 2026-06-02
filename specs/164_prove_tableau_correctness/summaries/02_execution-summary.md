# Execution Summary: Tableau Correctness (Task 164, Round 2)

- **Task**: 164 - Prove tableau correctness theorem
- **Status**: PARTIAL (2 of 3 sorry sites resolved, 1 blocked)
- **Duration**: ~1.5 hours
- **Session**: sess_1780376119_ad7b68

## Results

### Sorry Sites Resolved (2 of 3)

1. **truthLemma_neg untl case** (CountermodelExtraction.lean L838): RESOLVED
   - Modified `branchTruth` for `untl` to use direct-successor semantics (`futureOf`) with conjunction (`event AND guard` at witness time) instead of transitive-closure semantics (`isTimeOrderedBefore`) with `timesBetween`
   - Added `sat_some_future_neg` saturation lemma for the `guard = top` case
   - Proof uses `sat_untl_neg` (guard != top) or `sat_some_future_neg` (guard = top) to derive `F(event)` or `F(guard)` at each direct successor, then applies IH

2. **truthLemma_neg snce case** (CountermodelExtraction.lean L842): RESOLVED
   - Mirror of untl case using `pastOf` and `sat_snce_neg`/`sat_some_past_neg`

3. **blocking_terminates** (Saturation.lean L663): BLOCKED
   - Original statement was over-general (quantified over ALL branches, which is false)
   - Restated to correct formulation: `(buildTableau phi (soundFuel phi)).isSome`
   - Proof requires generalized subformula property (case analysis over 25+ tableau rules) + pigeonhole argument

### Key Design Decision

The plan envisioned proving `sat_untl_neg_strong` (a strengthened saturation invariant) and `untl_neg_propagates` (a propagation lemma). Analysis showed both are unprovable from the saturated branch alone:

- **sat_untl_neg_strong** requires distinguishing which branch was taken during untlNeg decomposition, but the filter condition (`!contains(F(event)) && !contains(F(guard))`) only gives a disjunction
- **untl_neg_propagates** assumes F(U(e,g)) propagates to all reachable times, but auto-propagation only happens in `untlPos` (not in `allFutureNeg` or `someFuturePos`)

The modified `branchTruth` approach works because:
- `T(U(event,guard))` is ALWAYS consumed in saturated branches (by `untlPos`/`someFuturePos`)
- So the positive truth lemma for `untl` is vacuously true
- The definition only needs to support the negative case, where the conjunction semantics perfectly matches the disjunctive saturation invariant from `sat_untl_neg`

### Files Modified

- `Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean`:
  - Modified `branchTruth` for `untl`/`snce` (direct-successor semantics)
  - Added `sat_some_future_neg`, `sat_some_past_neg` saturation lemmas
  - Closed truthLemma_neg untl/snce sorry sites
  - 0 sorry sites (down from 2)

- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean`:
  - Restated `blocking_terminates` from over-general to correct formulation
  - 1 sorry site remains (blocking_terminates)

### Build Status

Full `lake build` passes (1680 jobs, no errors).

## Plan Deviations

- **Phase 1**: Skipped -- Phase 3 approach (modified branchTruth) eliminated the need for strengthened saturation invariants
- **Phase 2**: Skipped -- Phase 3 approach solved truth lemma directly without propagation lemma
- **Phase 3 Task 3.1**: Skipped -- used Task 3.2 approach (modified branchTruth) directly
- **Phase 3 Task 3.2**: Altered -- used as primary approach rather than fallback
- **Phase 4**: Blocked -- requires generalized subformula property (25+ rule case analysis)

## Remaining Work

The sole remaining sorry (`blocking_terminates`) requires:
1. Prove `subformula_property_general`: all formulas in expanded branches remain within `subformulaClosure(phi)` (case analysis over 25+ rules in `applyRule`)
2. Pigeonhole argument: with bounded time types, blocking fires within `soundFuel` steps
3. Compose into `blocking_terminates` proof

This work is self-contained and does not affect other sorry sites or theorems. The theorem is unused by any other result in the codebase.
