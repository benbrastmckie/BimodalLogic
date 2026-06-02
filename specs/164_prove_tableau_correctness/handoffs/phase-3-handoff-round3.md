# Phase 3 Handoff (Round 3) - TimeOrdering Threading

## What Was Done

### Architectural Change (COMPLETED)
Threaded `TimeOrdering` through `ExpandedTableau.hasOpen` so the saturation proof uses the real time ordering from expansion rather than the default `TimeOrdering.empty`.

**Files modified:**
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` - Reordered `ExpandedTableau.hasOpen` and `BranchListResult.foundOpen` fields; updated `buildTableau` and `expandBranchesWithFuel`
- `Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean` - Updated all saturation invariants, truth lemmas, and downstream code to use the real `TimeOrdering`
- `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean` - Updated pattern match
- `Theories/Bimodal/Automation/DatasetGenerator.lean` - Updated pattern match

### Signature Changes
- `findUnexpanded_none_all_expanded` takes `(timeOrd : TimeOrdering)` parameter
- All `sat_*` theorems take `(timeOrd : TimeOrdering)` and `(hSat : findUnexpanded b (timeOrd := timeOrd) = none)`
- `sat_untl_neg` now quantifies over `timeOrd.futureOf t` instead of `b.knownTimes`
- `sat_snce_neg` now quantifies over `timeOrd.pastOf t` instead of `b.knownTimes`
- `truthLemma_neg` takes additional `(hOrd : cm.timeOrdering = timeOrd)` parameter
- `branchTruthLemma` takes additional `(hOrd : cm.timeOrdering = timeOrd)` parameter
- Helper lemmas (impNeg/impPos/boxNeg/untlPos/sncePos_not_expanded) generalized with `(timeOrd : TimeOrdering := .empty)` default

## Immediate Next Action

Prove `sat_untl_neg`. The architectural blocker is resolved. The proof approach:

1. Use `findUnexpanded_none_all_expanded` to get `isExpanded` for the formula
2. Unfold to `findApplicableRule = none`, extract `untlNeg` rule via `List.findSome?_eq_none_iff`
3. Unfold `isApplicable` (true since guard != top) and `applyRule`
4. `cases h_ar : applyRule .untlNeg ...` to case split on the result
5. For `notApplicable` case: show the filter list is non-empty (t' passes the filter since both `Branch.contains` are false), contradiction. KEY CHALLENGE: after `simp only [applyRule, ...]`, the match on the filter list needs to be resolved. Try `split at h_ar` in the notApplicable case after simp.
6. For other cases (linear, branching, persistent): `simp at hRule` derives contradiction since the lambda returns `some`.

## Remaining Sorry Sites (5)

| File | Line | Theorem | Status |
|------|------|---------|--------|
| CountermodelExtraction.lean | 634 | `sat_untl_neg` | Unblocked by TimeOrdering threading |
| CountermodelExtraction.lean | 649 | `sat_snce_neg` | Mirror of sat_untl_neg |
| CountermodelExtraction.lean | 758 | `truthLemma_neg` untl | Depends on sat_untl_neg |
| CountermodelExtraction.lean | 762 | `truthLemma_neg` snce | Depends on sat_snce_neg |
| Saturation.lean | 663 | `blocking_terminates` | Independent, hard |

## Build Status
Full `lake build` passes (excluding pre-existing errors in ChronicleToCountermodel and Mathlib).

## Key Decision
Changed `sat_untl_neg` conclusion from `forall t' in b.knownTimes` to `forall t' in timeOrd.futureOf t`. This is the correct statement because:
- The `untlNeg` rule decomposes `F(U(event, guard))` at known FUTURE times (via `timeOrd.futureOf l.time`)
- Saturation means all those future times are processed
- The branch may contain times not in `futureOf t` (e.g., past times, times at other labels)
- The truth lemma only needs future times for the Until negation semantics
