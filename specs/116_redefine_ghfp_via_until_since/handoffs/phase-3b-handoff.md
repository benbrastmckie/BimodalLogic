# Phase 3b Handoff — Task 116

**Session**: sess_1779159757_8a4784
**Timestamp**: 2026-05-18

## Current Build Status

**10 errors across 3 files**:
- `ParametricTruthLemma.lean` (4 errors): `| all_future` / `| all_past` induction arms in truth lemma proof
- `SuccRelation.lean` (4 errors): `rfl`-based equalities `some_future = neg(all_future(neg _))`
- `BXCanonical/Frame.lean` (2 errors): same `rfl` pattern

## Summary of Session Progress

Fixed 13 files total (from 4-5 originally failing + cascading):

| File | Fix Type | Errors Fixed |
|------|----------|-------------|
| Soundness.lean | simp + proof rewrites | 42 |
| Principles.lean | swap_temporal simp additions | 5 |
| Bridge.lean | swap_temporal simp additions | 2 |
| TemporalContent.lean | DNI/DNE + BX3 duality proofs | 4 |
| SubformulaClosure.lean | depth defs, extractors, decidable instances, noConfusion | 40+ |
| SuccessPatterns.lean | remove match arms | 2 |
| LindenbaumQuotient.lean | swap_temporal simp | 2 |
| TemporalCoherence.lean | DNE-based duality | 2 |
| WitnessSeed.lean | helper lemmas + 8 rfl replacements | 8 |
| ProofSearch.lean | untl pattern match | 2 |
| Total fixed | | ~110 |

## Remaining Work (10 errors, 3 files)

### 1. ParametricTruthLemma.lean (4 errors)
Lines 301, 319: `| all_future psi ih =>` and `| all_past psi ih =>` in induction proof of truth lemma. Since these are no longer constructors, the induction has 6 arms (atom, bot, imp, box, untl, snce), not 8. The G and H truth lemma needs to be proved through the `imp` arm (since `all_future phi` is structurally an `imp`). The `simp only [truth_at, Truth.future_iff, Truth.past_iff]` should handle the simplification.

### 2. SuccRelation.lean (4 errors)
Lines 123, 185, 290, 315: Same `some_future psi = neg(all_future(neg psi))` rfl pattern as WitnessSeed.lean. Fix with `some_future_all_future_neg_absurd` / `some_past_all_past_neg_absurd` helper lemmas (already defined in WitnessSeed.lean -- consider moving to a shared utility).

### 3. BXCanonical/Frame.lean (2 errors)
Lines 162, 195: Same pattern. Need the same helper lemmas.

## Key Design Decisions

1. **Truth characterization theorems**: All `simp only [truth_at]` calls that handle `all_future`/`all_past`/`some_future`/`some_past` formulas need `Truth.future_iff`, `Truth.past_iff`, `Truth.some_future_iff`, `Truth.some_past_iff`.

2. **swap_temporal**: All `simp only [Formula.swap_temporal, Formula.swap_temporal_involution]` calls need `Formula.swap_temporal_all_future`, `Formula.swap_temporal_all_past`.

3. **MCS duality**: `some_future psi != neg(all_future(neg psi))` syntactically. Contradictions between `F(psi) in M` and `G(neg psi) in M` use the helper `some_future_all_future_neg_absurd` (bridges via BX3 + DNI).

4. **SubformulaClosure patterns**: `f_nesting_depth` matches `.untl inner (.imp .bot .bot)`, `extractFutureInner` matches `.untl inner (.imp .bot .bot)`, not the old `.imp (.all_future ...)` form.

## Immediate Next Action

1. Move `some_future_all_future_neg_absurd` / `some_past_all_past_neg_absurd` to a shared location (e.g., TemporalContent.lean or a new utility file)
2. Fix SuccRelation.lean and Frame.lean using those helpers
3. Fix ParametricTruthLemma.lean by removing `| all_future`/`| all_past` induction arms and handling through `imp` arm with Truth characterization theorems
4. Run full build to check for further cascading
