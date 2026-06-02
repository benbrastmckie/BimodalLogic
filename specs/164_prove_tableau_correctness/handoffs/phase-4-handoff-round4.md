# Phase 4 Handoff: Round 4 Progress

## Session
- Session: sess_1780361777_843697
- Date: 2026-06-01

## Current State
- 5 sorry sites remain (same count as round 3)
- Build passes with no errors
- Infrastructure improvements made

## Root Cause Analysis

The fundamental blocker for `sat_untl_neg` and `sat_snce_neg` is a **filter predicate form mismatch** in the `applyRule` function:

### The Problem

1. `applyRule .untlNeg` internally uses `!(a || b)` in its filter predicate
2. After `unfold applyRule; simp only [asUntil?, hg', ite_false]`, Lean's `simp` normalizes `!(a || b)` to `!a && !b` (De Morgan's law)
3. The hypothesis `h_in_filter` (constructed from `List.mem_filter`) uses `!(a || b)` form
4. `generalize` can't match the same filter expression in both `hfst` (which has `!a && !b`) and `h_in_filter` (which has `!(a || b)`)
5. `rw [hxs]` and `simp only [hxs]` fail because `hxs` (derived from `h_in_filter`) has `!(a || b)` while the goal has `!a && !b`

### Additionally
- The `cons` case of `generalize; cases` requires showing `branching ≠ notApplicable`, but the `let` bindings inside the match arm prevent `nofun`/`nomatch` from seeing the constructor mismatch
- Even with `@[simp]` lemmas for `branching_ne_notApplicable`, `simp` can't close because `let` bindings aren't reduced

## What Was Done in Round 4

### Infrastructure Added (Tableau.lean)
- `@[simp] RuleResult.branching_ne_notApplicable`
- `@[simp] RuleResult.linear_ne_notApplicable`
- `@[simp] RuleResult.persistent_ne_notApplicable`

### Bug Fixes
- Fixed `set_option ... in` placement: must come BEFORE docstring, not after (`/-- ... -/ set_option` fails in Lean 4; `set_option /-- ... -/ theorem` works)

### Proof Structure Established
For `sat_untl_neg`:
1. Extract `hUntlNeg` via `findSome?_eq_none_iff` -- WORKS
2. Extract `hfst : (applyRule ...).1 = .notApplicable` via `set result_pair; cases result` -- WORKS (the non-notApplicable cases close with `simp [hresult_def] at hUntlNeg`)
3. `unfold applyRule at hfst; simp only [asUntil?, hg', ite_false] at hfst` -- WORKS
4. Show the filter is non-empty (from `h_in_filter` and `hxs`) -- conceptually clear but BLOCKED by form mismatch
5. Derive contradiction (filter non-empty but applyRule returned notApplicable) -- BLOCKED

## Suggested Approaches for Round 5

### Approach A: Refactor `applyRule` to use `!a && !b` natively
Change the `untlNeg`/`snceNeg` cases in `applyRule` to use `!a && !b` instead of `!(a || b)`. This eliminates the normalization mismatch at the source.

### Approach B: Add a `filter_bool_not_or` lemma
Prove: `List.filter (fun x => !(f x || g x)) l = List.filter (fun x => !f x && !g x) l`
Then use this to convert between forms.

### Approach C: Use `native_decide` on the constructor inequality
Add `DecidableEq` to `RuleResult` and use `decide` for the `cons` case. But note: `DecidableEq` on `RuleResult` breaks existing `simp` proofs (like `sncePos_not_expanded`) by changing the simp set.

### Approach D: Direct `Eq.rec` proof term
Construct the proof term directly without tactics, using pattern matching on the filter result.

## Files Modified
- `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` -- Added simp lemmas, fixed set_option placement
- `Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean` -- Proof structure for sat_untl_neg/sat_snce_neg

## Sorry Sites (5 total, same as round 3)
1. `sat_untl_neg` (CountermodelExtraction.lean:657) -- BLOCKED by filter form mismatch
2. `sat_snce_neg` (CountermodelExtraction.lean:693) -- Mirror of #1
3. `truthLemma_neg` untl case (CountermodelExtraction.lean:802) -- Depends on #1
4. `truthLemma_neg` snce case (CountermodelExtraction.lean:806) -- Depends on #2
5. `blocking_terminates` (Saturation.lean:663) -- Independent, needs generalized subformula property
