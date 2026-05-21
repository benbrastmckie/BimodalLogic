# Phase 4C-W2: Lemma 9 Counterexample Analysis

**Session**: sess_1779370545_7dc7e6
**Date**: 2026-05-21
**Status**: BLOCKED -- theorem statement is mathematically false

## Executive Summary

The theorem `left_formula_gap_detection` (EFGames.lean line 1618) is **mathematically false** as stated. The backward direction of the IFF fails for the `.neg A` case. A concrete counterexample on Q (rationals) demonstrates the failure. The root cause is that the LHS uses `stavi_temporal_truth_mu` (mu-relativized truth, quantifying only over actual points) when GHR93 Lemma 9 requires standard truth in M_r (quantifying over all elements including gaps).

## The Counterexample

**Structures**: M = Q (rationals as a linear order), sig with one predicate a.

**Setup**:
- `atomMap(.atom a)` maps to the predicate `a`
- `M.interp a x` = True iff x < sqrt(2) (for x in Q)
- D = `.base (.atom a)` (the atomic formula for predicate a)
- A = `.neg (.base .bot)` (negation of bottom = always True)
- m = 0, r = 0

**LHS computation**:
- `left_formula (.neg (.base .bot)) D` = `.conj (.stavi_untl (.base Formula.top) D) (.neg (.base .bot))`
- At extendPoint 0: `stavi_temporal_truth_mu Q atomMap 0 (extendPoint 0) (...)` 
  = `U'^mu(top, D)(0) AND NOT False` = `U'^mu(top, D)(0)`
- By `stavi_truth_mu_at_point`: = `stavi_temporal_truth Q atomMap 0 (.stavi_untl (.base Formula.top) D)`
- This is U'(top, D)(0) in Q:
  - Condition 1 (D cofinal): For all s > 0 in Q, exists r in (0,s] with r < sqrt(2). TRUE.
  - Condition 2 (neg standard Until): neg(exists s > 0, D continuous on (0,s)). But for s = 1, D holds on (0,1) since all rationals in (0,1) are < sqrt(2). So standard Until U(top,D)(0) = TRUE. Condition 2 = FALSE.
- U'(top, D)(0) = TRUE AND FALSE = **FALSE**
- LHS = **FALSE**

**RHS computation**:
- Gap gamma at sqrt(2): cut = {x in Q | x < sqrt(2)}
  - nonempty: 0 in cut. proper: 2 not in cut. downward_closed: clear.
  - no_sup: LUB is sqrt(2) which is irrational, not in Q, hence not in cut.
  - complement_no_min: complement = {x in Q | x >= sqrt(2)}, no rational minimum (can always find a smaller rational >= sqrt(2)).
- D-definable on left: D holds throughout final segment of cut (take t=0, D(u) for all u >= 0 in cut). D does not hold in any initial segment of complement (D = "x < sqrt(2)" = False for all complement elements).
- RDefinableGap: D = base(atom a) has stavi_depth 0 <= 0 = r. So gamma is 0-definable.
- extendPoint 0 < Sum.inr gamma: 0 in gamma.cut = TRUE
- D between 0 and gamma: D(u) for all u in Q with 0 < u and u < sqrt(2). TRUE (u < sqrt(2) = D(u)).
- A^mu at gamma: stavi_temporal_truth_mu Q atomMap 0 (Sum.inr gamma) (.neg (.base .bot)) = NOT (temporal_truth_mu ... (Sum.inr gamma) .bot) = NOT False = TRUE
- RHS = **TRUE**

**Result**: LHS = FALSE, RHS = TRUE. The IFF is **FALSE**.

## Root Cause Analysis

### Why the backward direction fails

For the `.neg A` case, `left_formula (.neg A) D = conj (stavi_untl (base top) D) (neg (left_formula A D))`. The backward direction requires:

Given gamma with gap conditions and (neg A)^mu(gamma):
1. Show `stavi_temporal_truth_mu ... (extendPoint m) (.stavi_untl (.base Formula.top) D)` = U'^mu(top,D)(m)
2. Show `neg left_formula(A,D)(m)`

Part 2 works (via IH + gap_detection_unique). Part 1 FAILS because:

- "D between m and gamma" means D holds at all actual points u with m < u and u in gamma.cut
- By no_sup, gamma.cut contains elements above m
- By downward_closed, if s in gamma.cut and s > m, all u in (m,s) are in gamma.cut
- D holds at all u in (m,s) (by D-between condition)
- So D is continuous on (m,s) in M
- So standard Until U(top,D)(m) holds in M
- So neg U(top,D)(m) = FALSE
- So U'(top,D)(m) in M = FALSE (condition 2 of U' fails)

### The mu-relativized vs standard M_r truth distinction

- `stavi_temporal_truth_mu M atomMap r (extendPoint m) A` (codebase) = mu-relativized truth = standard truth in M (by stavi_truth_mu_at_point)
- `stavi_temporal_truth (extendedStructure M atomMap r) atomMap (extendPoint m) A` = standard truth in M_r
- These are DIFFERENT for formulas containing U'/S' because:
  - Mu-relativized: quantifiers range over actual points only
  - Standard M_r: quantifiers range over all of M_r (points AND gaps)
  - Gaps have `interp p (Sum.inr _) = False` for all predicates
  - So for atomic D, D(gap) = False, preventing "D continuous on (m,s)" in M_r even when D holds at all actual points in (m,s)

### GHR93's intended evaluation

GHR93 Lemma 9 states: "M_r |= left(A, D)(m)" where the evaluation is STANDARD in M_r. The codebase incorrectly uses mu-relativized evaluation.

In M_r with standard evaluation, U'(top, D)(m) at m:
- Condition 1 (D cofinal in M_r): For any s > m in M_r, exists r in (m,s] with D(r). Actual points with D serve as witnesses.
- Condition 2 (neg standard Until in M_r): For any s > m in M_r, D fails somewhere on (m,s) in M_r. Since (m,s) in M_r contains gaps where D(gap) = False (for atomic D), this condition HOLDS even when D is continuous among actual points.

So U'(top, D)(m) in M_r (standard) can be TRUE while U'(top, D)(m) in M (= mu-relativized in M_r) is FALSE.

## Proposed Fix

### Option A: Change LHS to standard M_r truth (correct per GHR93)

```lean
theorem left_formula_gap_detection ...
    stavi_temporal_truth (extendedStructure M atomMap r) atomMap 
      (extendPoint m : ExtendedCarrier M atomMap r) (left_formula A D) ↔
    (exists gamma : RDefinableGap M atomMap r, ...)
```

**Pros**: Matches GHR93. Makes the IFF correct.
**Cons**: Downstream usage needs a bridge lemma connecting mu-relativized truth (from game winning condition) to standard M_r truth for left_formula. This bridge is non-trivial.

### Option B: Forward direction only (implication, not IFF)

```lean
theorem left_formula_gap_detection_forward ...
    stavi_temporal_truth_mu M atomMap r (extendPoint m) (left_formula A D) →
    (exists gamma : RDefinableGap M atomMap r, ...)
```

**Pros**: Forward direction may be vacuously true in many cases (when mu-relativized U'(top,D) is False, the implication is trivially True). Simpler. May suffice for downstream Cases III/IV which only use the forward direction.
**Cons**: Does not capture the full Lemma 9 equivalence. Backward direction needed for complete proof.

### Option C: Parametric evaluation (most general)

Add a parameter controlling whether evaluation is mu-relativized or standard, and prove the IFF for standard evaluation with a separate bridge lemma for the game context.

### Recommended path

Option A with a separate bridge lemma. The bridge lemma would show: for left_formula A D specifically, mu-relativized truth at actual points equals standard M_r truth at actual points. This requires analyzing the specific structure of left_formula.

## Impact on Downstream

- `left_formula_gap_detection` (EFGames.lean line 1618): Must be fixed
- `right_formula_gap_detection` (EFGames.lean line 1637): Same fix needed (symmetric)
- Cases III/IV in ExpressivenessGeneral.lean (line 551): Need bridge lemma to connect game winning condition to corrected Lemma 9
- No impact on Cases I/II (don't use Lemma 9)
- No impact on infrastructure lemmas (stavi_truth_mu_at_point, etc.)

## Immediate Next Action

1. Research whether the bridge lemma (mu-relativized = standard M_r for left_formula at actual points) holds
2. If yes, implement Option A
3. If no, determine which direction is needed downstream and implement Option B
