# Phase 4C-W2: M_r Fix Disproved -- All Three Evaluation Regimes Fail

**Session**: sess_1779372081_6c2d4c
**Date**: 2026-05-21
**Status**: BLOCKED -- theorem is mathematically false in ALL evaluation regimes

## Executive Summary

The previous analysis (phase-4CW2-counterexample-20260521.md) identified that
`left_formula_gap_detection` is false with mu-relativized evaluation and proposed
changing the LHS to standard M_r evaluation. This session proves that the M_r fix
ALSO fails: the counterexample applies identically to all three evaluation regimes.

The fundamental issue is NOT the evaluation regime but the structure of U'(top, D)
in the left_formula definition for neg. U'(top, D)(m) requires U(top, D)(m) to be
False, but the D-between condition ensures D is continuously True at actual points
between m and the gap, making U(top, D)(m) True regardless of evaluation regime.

## Detailed Analysis

### The Three Evaluation Regimes

For `left_formula (.neg (.base .bot)) D` at `m = extendPoint 0`:

**Regime 1: Mu-relativized in M_r** (current statement)
- `stavi_temporal_truth_mu M atomMap r (extendPoint 0) (left_formula A D)`
- By `stavi_truth_mu_at_point`: equals standard evaluation in M
- U(top, D)(0) in M: witness s = 1, D continuous on (0,1) (all q < sqrt(2))
- U'(top, D)(0) = False. LHS = False.

**Regime 2: Standard in M**
- `stavi_temporal_truth M atomMap 0 (left_formula A D)`
- Same as Regime 1 (mu-relativized at actual point = standard in M)
- LHS = False.

**Regime 3: Standard in M_r** (proposed fix)
- `stavi_temporal_truth (extendedStructure M atomMap 0) atomMap (extendPoint 0) (left_formula A D)`
- Quantifiers range over ExtendedCarrier M atomMap 0 = Q + {gap_at_sqrt2}
- U(top, D)(0) in M_r: witness s = Sum.inr gap_at_sqrt2
  - extendPoint 0 < Sum.inr gap: 0 in gap.cut = True (since 0 < sqrt(2))
  - top(gap) = True (imp bot bot at gap = True)
  - D continuous on (extendPoint 0, Sum.inr gap): This interval in M_0 contains
    exactly the actual points x with 0 < x and x in gap.cut (i.e., x < sqrt(2)).
    There are NO intermediate gaps because:
    - The only 0-definable gap in Q with interp a = (x < sqrt(2)) is at sqrt(2)
    - The gap at sqrt(2) is the UPPER endpoint of this interval, not inside it
    - For any other gap to exist in (0, sqrt(2)), it would need to be 0-definable
      by some formula of stavi_depth 0, but the only such formulas are Boolean
      combinations of atom(a), all of which define the same gap at sqrt(2) or no gap
  - At all actual points x in (0, sqrt(2)): D(x) = atom(a)(x) = True
  - Since no gaps are in the interval, D holds at all elements. D IS continuous.
- U(top, D)(0) = True. U'(top, D)(0) = False. LHS = False.

**RHS in all three regimes**: gap at sqrt(2) exists with (neg bot)^mu(gamma) = True.
gap_definable_on_left holds, D-between holds. RHS = True.

**Result**: False <-> True = FALSE in all three regimes.

### Why the M_r Fix Was Expected to Work (and Why It Doesn't)

The prior analysis claimed: "In M_r, U'(top, D)(m) is True because D fails at gaps
between m and s, preventing continuous D on any (m, s) in M_r."

This is wrong because:
1. The gap at sqrt(2) is at the BOUNDARY, not between m and s (when s = gap)
2. For s below the gap (e.g., s = extendPoint 1), the interval (m, s) in M_r
   contains no gaps at all (the gap at sqrt(2) is above s since 1 < sqrt(2))
3. For the "gap breaks continuity" argument to work, there would need to be gaps
   INSIDE every interval (m, s), not just at the boundary

### The Fundamental Mathematical Issue

U'(top, D)(m) means: "D is cofinal above m AND D is never continuously True
on any interval above m." When there is a D-defined gap at gamma:

- D IS cofinal (actual points with D exist arbitrarily close to gamma)
- BUT D IS continuously True on intervals (m, s) for s < gamma (when there
  are no intermediate gaps)
- So U(top, D)(m) IS True (witnessed by any s < gamma where D is continuous)
- So U'(top, D)(m) IS False

The D-between condition (D holds at all actual points between m and gamma) is
PRECISELY what makes U(top, D)(m) True. The conditions of Lemma 9's RHS
directly imply the LHS is False.

### Impact on the Main Theorem (GHR93 Theorem 6)

Case III of Theorem 6 uses Lemma 9's backward direction:
1. Gap g_n exists in N_r, left-defined by D, with B^mu(g_n)
2. Backward direction: left(B, D)(m_N) holds
3. Formula agreement transfers to M: left(B, D)(m_M) holds
4. Forward direction: extract matching gap in M

Step 2 FAILS because:
- B = rank_type at gap = conjunction of depth-0 formulas true at the gap
- At a gap, atoms are False, so B includes neg(base(atom a)) for each atom
- left(neg(base(atom a)), D) = conj(U'(top, D), neg(left(base(atom a), D)))
  = conj(U'(top, D), neg(base bot)) = U'(top, D)
- U'(top, D) is False (by the analysis above)
- So left(B, D)(m_N) is False
- The formula can't be transferred to M

This means Case III of GHR93 Theorem 6 cannot work with the current left_formula
definition and Lemma 9 statement.

## Possible Resolutions

### Resolution 1: Re-read GHR93 Source Text

The most likely resolution is that our extraction from GHR93 (in report 08) is
missing something. Possibilities:
- GHR93 may use a different definition of gap_definable_on_left that prevents
  the counterexample
- GHR93 may have additional hypotheses on A or D
- GHR93 may use a different encoding of left_formula
- The proof of Case III may work differently from what report 14 describes

**Action**: Carefully re-read the actual GHR93 book (Chapter 9, Definition 8.5,
Lemma 9, Theorem 6 Case III) and compare word-by-word with our formalization.

### Resolution 2: Forward-Only Implication

State only the forward direction:
```
left_formula(A, D)(m) -> exists gap gamma, conditions
```
This is vacuously True when left_formula is False. But it doesn't help with
Case III (which needs the backward direction to establish that left_formula holds).

### Resolution 3: Alternative left_formula for neg

Redesign left_formula so the neg case doesn't use U'(top, D). For example:
```
left(neg A, D) = neg left(A, D) AND [some alternative gap-existence formula]
```
where the gap-existence formula uses a different encoding. This deviates from GHR93.

### Resolution 4: Enriched Extended Structure

Add ALL Dedekind gaps to the structure (not just r-definable ones), so every
interval contains gaps where D fails. Then U(top, D)(m) would be False because
every interval (m, s) in the enriched structure contains a gap where D(gap) = False
(for atomic D). This changes M_r substantially and may affect other parts of the proof.

### Resolution 5: Bypass Lemma 9 Entirely

Find an alternative proof for Cases III/IV that doesn't use left_formula_gap_detection.
For example, use type formulas directly to construct matching gaps without going
through the left_formula encoding.

## Recommended Immediate Action

**Resolution 1 (re-read GHR93)** is the highest priority. The counterexample is
simple and specific. If GHR93 correctly handles this case, our formalization must
differ in some way that we haven't identified. A word-by-word comparison of
Definition 8.5 and Lemma 9 with our code is needed.

Key questions for the re-reading:
1. Does GHR93 define gap_definable_on_left with M evaluation or M_r evaluation?
2. Does GHR93's left_formula for neg use standard U' or some modified version?
3. Does GHR93 have implicit hypotheses on A or D (e.g., D must distinguish
   the gap in a specific way)?
4. How does GHR93's Case III proof actually use Lemma 9? Does it go through
   the backward direction or use a different argument?

## Files Modified

None (analysis only, no code changes).

## Key Files

- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- theorem at line 1618
- `specs/155_reynolds_pipeline_activation/plans/10_reynolds-pipeline-plan.md` -- BLOCKER updated
- `specs/155_reynolds_pipeline_activation/handoffs/phase-4CW2-counterexample-20260521.md` -- prior analysis
