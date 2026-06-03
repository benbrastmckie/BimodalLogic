# Research Report: Extend Structural Pre-Filter with Recursive Unsatisfiability and Consequent Validity

**Task**: 270
**Date**: 2026-06-03
**Status**: Research complete

## Executive Summary

Task 270 requires two extensions to the structural pre-filter in `DatasetGenerator.lean`:
1. Make `isUnsatBotTemporal` recursive so it catches nested unsatisfiable events like `U(box(bot), X)`
2. Add a consequent validity check: `X -> valid_formula` is always valid regardless of antecedent

Both changes are localized to ~30 lines in a single file. The implementation is straightforward with no soundness risks, since the pre-filter only classifies formulas as "known valid" (never "known invalid"), and both extensions preserve this conservative invariant.

## 1. Current Implementation Analysis

### 1.1 `isUnsatBotTemporal` (DatasetGenerator.lean:401-405)

```lean
def isUnsatBotTemporal : Formula -> Bool
  | .untl .bot _ => true
  | .snce .bot _ => true
  | .box a => isUnsatBotTemporal a
  | _ => false
```

**Bug**: The Until/Since cases match only the *literal* `.bot` as the event component. They do not recurse into the event. However, the `.box` case already recurses — so `box(bot)` is correctly identified as unsatisfiable, but `U(box(bot), X)` is not, because the Until case requires `.bot` literally rather than calling `isUnsatBotTemporal` on the event.

**Consequence**: Formulas like `U(box(bot), X) -> Y` are not caught by the pre-filter and fall through to the full tableau decision procedure, which may time out.

### 1.2 `structuralPrefilter` (DatasetGenerator.lean:420-429)

```lean
def structuralPrefilter : Formula -> Option Bool
  | .imp antecedent consequent =>
    if isUnsatBotTemporal antecedent then some true
    else match antecedent, consequent with
    | .box (.box .bot), _ => some true
    | .box (.box inner), consequent => if inner == consequent then some true else none
    | .box inner, .imp _ rhs => if inner == rhs then some true else none
    | _, _ => none
  | .box inner => structuralPrefilter inner
  | _ => none
```

**Gap**: The pre-filter only checks the *antecedent* for unsatisfiability. It does not check whether the *consequent* is a tautology. For example, `X -> (p -> p)` is always valid because `p -> p` is always true, but the pre-filter returns `none` for this pattern.

## 2. Proposed Modifications

### 2.1 Fix: Recursive `isUnsatBotTemporal`

Change the Until/Since cases to recurse into the event component:

```lean
def isUnsatBotTemporal : Formula -> Bool
  | .bot => true                              -- NEW: bot itself is unsatisfiable
  | .untl event _ => isUnsatBotTemporal event -- CHANGED: recurse into event
  | .snce event _ => isUnsatBotTemporal event -- CHANGED: recurse into event
  | .box a => isUnsatBotTemporal a            -- UNCHANGED: box(unsat) is unsat
  | _ => false
```

**Soundness argument**: `U(event, guard)` requires that `event` eventually becomes true. If `event` is unsatisfiable (never true at any time), then `U(event, guard)` is always false. This holds recursively:
- `U(bot, X)` = false (bot never true)
- `U(box(bot), X)` = false (box(bot) is false in non-degenerate S5 frames, so never true)
- `U(U(bot, Y), X)` = false (inner Until is always false, so outer event is never true)
- `U(S(bot, Y), X)` = false (Since with bot event is always false)

Adding `.bot => true` as a base case simplifies the recursion. The existing `.box a => recurse` case already handles box, and the new Until/Since cases recurse into the event argument.

**Note on the guard component**: The guard argument is irrelevant to unsatisfiability of Until/Since. Whether `guard` is `bot` or `top` or anything else, if the event is unsatisfiable, the Until/Since formula is always false. The semantics `U(event, guard)` = "guard holds until event becomes true" requires event to eventually become true; if event cannot ever be true, the formula is false.

### 2.2 Add: Consequent Validity Check

Add a `isStructurallyValid` function that detects tautological consequents, and integrate it into `structuralPrefilter`:

```lean
/-- Check if a formula is structurally valid (tautology by inspection).
    Returns true for patterns like (p -> p), (bot -> X), box(valid). -/
def isStructurallyValid : Formula -> Bool
  | .imp (.imp _ .bot) _ => false   -- Don't recurse into complex neg patterns
  | .imp a b => a == b              -- phi -> phi is a tautology
  | .box inner => isStructurallyValid inner  -- box(valid) is valid
  | .imp .bot _ => true             -- bot -> X (ex falso) is valid
  | _ => false
```

Wait -- we need to be careful with the Formula encoding. In this project, negation is `A -> bot`, conjunction is `not(A -> not B)`, disjunction is `not A -> B`. So `p -> p` is literally `.imp (.atom p) (.atom p)`. The simple `a == b` check on an `imp` will correctly catch this.

A more robust check:

```lean
def isStructurallyValid : Formula -> Bool
  | .imp a b => a == b || isUnsatBotTemporal a || isStructurallyValid b
  | .box inner => isStructurallyValid inner
  | _ => false
```

This captures:
- `A -> A` (identity, any formula)
- `unsat -> X` (vacuous truth from unsatisfiable antecedent -- but this is already caught by `isUnsatBotTemporal` in the pre-filter)
- `X -> valid` (valid consequent makes implication valid)
- `box(valid)` (necessitation of valid = valid)

Actually, for the `imp` case, we should be careful. `a == b` works for literal equality. But `isUnsatBotTemporal a` is redundant with what the pre-filter already does. The novel part is `isStructurallyValid b` which checks if the consequent is itself a tautology.

**Revised approach**: Integrate into `structuralPrefilter` directly:

```lean
def structuralPrefilter : Formula -> Option Bool
  | .imp antecedent consequent =>
    if isUnsatBotTemporal antecedent then some true
    else if isStructurallyValid consequent then some true  -- NEW
    else match antecedent, consequent with
    | .box (.box .bot), _ => some true
    | .box (.box inner), consequent => if inner == consequent then some true else none
    | .box inner, .imp _ rhs => if inner == rhs then some true else none
    | _, _ => none
  | .box inner => structuralPrefilter inner
  | _ => none
```

Where `isStructurallyValid` is defined as:

```lean
def isStructurallyValid : Formula -> Bool
  | .imp a b => a == b || isStructurallyValid b
  | .box inner => isStructurallyValid inner
  | _ => false
```

This catches:
- `X -> (p -> p)` because `isStructurallyValid (p -> p)` = true (since `p == p`)
- `X -> (Y -> (q -> q))` because `isStructurallyValid (Y -> (q -> q))` = true (recurse on consequent)
- `X -> box(p -> p)` because `isStructurallyValid (box(p -> p))` = true

**Soundness**: `A -> B` is valid when `B` is valid (regardless of `A`). This holds for any `A`. Recursing into consequents is safe because if `B` is a tautology, `A -> B` is a tautology.

### 2.3 Integration: Where `isUnsatBotTemporal` and `isStructurallyValid` interact

After both fixes, some patterns currently caught by the explicit match cases in `structuralPrefilter` become redundant:

- `box(box(bot)) -> Y` is now caught by `isUnsatBotTemporal` since `box(box(bot))` is recursively unsatisfiable (box recurses into box(bot), which recurses into bot).
- So the explicit `| .box (.box .bot), _ => some true` case becomes redundant but is harmless to keep for clarity.

## 3. File Paths and Line Numbers

All changes are in a single file:

| File | Lines | What |
|------|-------|------|
| `Theories/Bimodal/Automation/DatasetGenerator.lean` | 401-405 | `isUnsatBotTemporal` definition |
| `Theories/Bimodal/Automation/DatasetGenerator.lean` | 420-429 | `structuralPrefilter` definition |

No other files need modification. The pre-filter is called from `labelFormula` (line 452) which is the only consumer.

## 4. Soundness Considerations

### 4.1 Conservative Classification

The pre-filter ONLY returns `some true` (formula is valid) or `none` (unknown). It never returns `some false`. Both extensions maintain this invariant:

- **Recursive unsatisfiability**: If `isUnsatBotTemporal` returns `true`, the formula genuinely cannot be satisfied at any world/time. The antecedent of an implication being unsatisfiable makes the implication vacuously valid.
- **Consequent validity**: If `isStructurallyValid` returns `true`, the consequent is a tautology. An implication with a tautological consequent is itself a tautology.

### 4.2 No Impact on Tableau

The pre-filter runs BEFORE the decision procedure (`labelFormula` line 452-472). When it returns `some true`, the tableau is never invoked. This means:
- No change to tableau rules
- No change to countermodel extraction
- No change to proof extraction
- No change to soundness/correctness proofs in `CountermodelExtraction.lean`

### 4.3 Regression Safety

Since the pre-filter only adds new "known valid" classifications (never reclassifies valid -> invalid or invalid -> valid):
- Previously valid formulas: No change (may be caught faster by pre-filter)
- Previously invalid formulas: No change (pre-filter only marks things valid)
- Previously timed-out formulas: Some may now be correctly classified as valid

## 5. Risk Assessment

### Risk Level: LOW

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| `isUnsatBotTemporal` returns true for satisfiable formula | Very Low | High (false positive validity) | Semantic argument is airtight; Until/Since with unsat event are always false |
| `isStructurallyValid` returns true for non-tautology | Low | High (false positive validity) | Only checks `a == b` (structural equality) and recurses on consequent; both are sound |
| Performance regression from deeper recursion | Very Low | Low | Recursion depth bounded by formula complexity; pre-filter is O(n) |
| Breaking existing tests | Very Low | Low | Pre-filter is additive; existing valid/invalid labels unchanged |

### Key Constraint

The `isStructurallyValid` check must NOT be applied to formulas that are NOT in the consequent position. For example, checking `isStructurallyValid` on the formula being labeled (not just the consequent of an implication) would incorrectly label `p -> p` without generating a proof trace. The pre-filter correctly returns `some true` for this (the whole formula is an implication with `a == b`), but we should ensure `isStructurallyValid` is only used as a subroutine inside `structuralPrefilter`, not as a standalone classification.

## 6. Testing Strategy

### 6.1 Unit Tests

Add `#eval` tests in `DatasetGenerator.lean` to verify:

```
-- Recursive unsatisfiability
isUnsatBotTemporal (Formula.untl (Formula.box .bot) p) == true
isUnsatBotTemporal (Formula.snce (Formula.untl .bot q) p) == true
isUnsatBotTemporal (Formula.untl p q) == false
isUnsatBotTemporal (Formula.box (Formula.untl .bot p)) == true

-- Consequent validity
isStructurallyValid (Formula.imp p p) == true
isStructurallyValid (Formula.imp q (Formula.imp p p)) == true
isStructurallyValid (Formula.box (Formula.imp p p)) == true
isStructurallyValid p == false
isStructurallyValid (Formula.imp p q) == false  -- p != q
```

### 6.2 Integration Tests

Run `lake build` to verify compilation. Run the existing `#eval` test battery in `Saturation.lean` to verify no regressions in tableau behavior.

### 6.3 Dataset Regeneration

After implementation, regenerate c5 and c7 datasets and compare:
- Timeout count (should decrease)
- Valid count (should increase by the number of previously-timed-out formulas now caught by pre-filter)
- Invalid count (should be unchanged)
- No previously-valid formula should change to invalid or timeout
- No previously-invalid formula should change to valid

## 7. Estimated Impact

Based on the task description's claim of ~22% timeout reduction:
- Current c7 timeout rate: ~4.8% (per task 271 description)
- Expected reduction: ~22% of timeouts eliminated by these two extensions
- Post-fix c7 timeout rate: ~3.7% (rough estimate)

The remaining ~78% of timeouts are likely due to the deeper issue described in task 271 (untlNeg rule not creating fresh intermediate time points for dense countermodel construction).

## 8. Implementation Plan Recommendation

### Phase 1: Recursive `isUnsatBotTemporal` (15 minutes)
1. Modify `isUnsatBotTemporal` in DatasetGenerator.lean:401-405
2. Add `.bot => true` base case
3. Change `.untl .bot _` to `.untl event _ => isUnsatBotTemporal event`
4. Change `.snce .bot _` to `.snce event _ => isUnsatBotTemporal event`
5. Add `#eval` tests

### Phase 2: Consequent Validity Check (30 minutes)
1. Add `isStructurallyValid` function after `isUnsatBotTemporal`
2. Integrate into `structuralPrefilter` as an additional guard
3. Add `#eval` tests

### Phase 3: Verification (15 minutes)
1. `lake build` to verify compilation
2. Run existing test battery
3. Verify no sorry or axiom regressions

Total estimated time: ~1 hour (well within the 2-4 hour estimate).
