# Implementation Summary: Task #270

- **Task**: 270 - Extend structural pre-filter with recursive unsatisfiability and consequent validity
- **Status**: Implemented
- **Date**: 2026-06-03
- **Session**: sess_1780506032_b1ddce

## Changes Made

### File Modified

`Theories/Bimodal/Automation/DatasetGenerator.lean` (~30 lines changed)

### 1. Recursive `isUnsatBotTemporal` (lines 401-416)

Changed from matching only literal `.bot` in Until/Since event positions to recursing into the event argument:

- Added `.bot => true` base case
- Changed `.untl .bot _ => true` to `.untl event _ => isUnsatBotTemporal event`
- Changed `.snce .bot _ => true` to `.snce event _ => isUnsatBotTemporal event`
- Updated docstring documenting the recursive behavior

This now catches nested unsatisfiable patterns like `U(box(bot), X)`, `U(U(bot, Y), X)`, `S(U(bot, Y), X)`, etc.

### 2. New `isStructurallyValid` function (lines 418-432)

Added function detecting tautological consequents:

- `.imp a b => a == b || isStructurallyValid b` (identity or valid consequent)
- `.box inner => isStructurallyValid inner` (necessitation of valid)
- `_ => false`

Catches patterns like `p -> p`, `X -> (q -> q)`, `X -> box(p -> p)`.

### 3. Integrated into `structuralPrefilter` (line 451)

Added `else if isStructurallyValid consequent then some true` after the existing `isUnsatBotTemporal antecedent` check. The conservative invariant is preserved: the pre-filter only returns `some true` or `none`, never `some false`.

### 4. Unit tests (lines 460-485)

Added 16 `#eval` tests covering:
- 6 tests for `isUnsatBotTemporal` (4 positive, 2 negative)
- 5 tests for `isStructurallyValid` (3 positive, 2 negative)
- 4 tests for `structuralPrefilter` integration (3 positive, 1 negative)

## Verification Results

- `lake build Bimodal.Automation.DatasetGenerator`: passed (all 16 #eval tests produce expected results)
- `lake build` (full project): passed (1682 jobs, no errors)
- No new `sorry` in modified file (0 matches)
- No new `axiom` declarations in modified file (0 matches)
- No vacuous definitions introduced

## Plan Deviations

- Phase 2 Task 2.1: Used `lake build Bimodal.Automation.DatasetGenerator` instead of `Theories.Bimodal.Automation.DatasetGenerator` (plan had wrong module path prefix per lakefile.lean configuration)

## Soundness Argument

Both extensions preserve the conservative pre-filter invariant:

1. **Recursive unsatisfiability**: `U(event, guard)` requires `event` to eventually become true. If `event` is recursively unsatisfiable (never true at any world/time), the Until formula is always false. Same argument for Since. An implication with an unsatisfiable antecedent is vacuously valid.

2. **Consequent validity**: `A -> B` is valid whenever `B` is valid, since `B` holds at every world/time regardless of `A`. The `a == b` check uses structural equality (BEq), which is sound: syntactically identical formulas are logically equivalent. Recursion into consequents and box preserves validity.

## Impact

- No changes to tableau rules, countermodel extraction, or soundness/completeness proofs
- Pre-filter catches more valid formulas before the decision procedure runs
- Expected to reduce dataset timeout rates by catching previously-missed valid patterns
