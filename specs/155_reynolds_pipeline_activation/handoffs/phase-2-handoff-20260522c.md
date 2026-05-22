# Phase 2 Handoff (Round 5): base.snce Backward Direction Analysis

## Summary

The base.snce backward direction (line ~3172) is partially scaffolded: witness s (cut point above max(m, t_pt)) verified for D(s), g(s), S(f,g)(s), D-between(m,s). Remaining: U'(⊤, g∧D)(s) (~60-80 lines, constructible) and ¬U'(D, g∧D)(s) (~80-120 lines, requires verifying that gap_definable_on_left condition 2 gives ¬D at complement points arbitrarily far above the gap).

## Proven Conjuncts at Witness s

1. **D(s)**: from hγ_bet (D-between at cut points above m) ✓
2. **g(s)**: from hg_mu (S(f,g)^mu gives g at cut points above t_pt) ✓
3. **S(f,g)(s)**: constructed with t_pt as sub-witness, f(t_pt) from S(f,g)^mu, g on (t_pt,s) from all intermediate cut points having g ✓
4. **D-between(m,s)**: all points in (m,s) are cut points (downward closure), D from hγ_bet ✓

## Blocked: U'(⊤, g∧D)(s)

Constructible with complement point c₀ as bound:
- condition (1) at cut u: left disjunct with next cut point, g∧D on (s,v) since all intermediate are cut ✓
- condition (1) at complement u: right disjunct, ⊤ always true, ¬(g∧D) below u from gap condition 2 ✓
- condition (2): ¬D at complement point from gap condition 2 ✓
- condition (3): g∧D on (s, next_cut_point) ✓

## Blocked: ¬U'(D, g∧D)(s)

Key question: does gap_definable_on_left condition 2 give ¬D at complement points ABOVE any given complement point? If yes, ¬U'(D, g∧D)(s) follows because condition (1) fails at complement points (both disjuncts fail). If condition 2 only gives ¬D BELOW a given complement point, the proof needs a different approach.

## Remaining Phase 2 Sorry Sites (4 in Lemma 9, 2 in Phase 4)

| Line | Case | Status |
|------|------|--------|
| ~3172 | base.snce backward | PARTIALLY SCAFFOLDED |
| ~3490 | stavi_snce | SAME compound pattern |
| ~3570 | std_snce | SAME compound pattern |
| ~3852 | right_formula_gap_detection | Dual of all left cases |

## Original summary below

Closed the FORWARD direction of base.snce in left_formula_gap_detection. Backward direction still sorry'd. Sorry count: 6 (was 7).

## What Was Done

**Forward direction** (~220 lines): Construct B∧D-cofinal gap from U'(⊤, g∧D)(s) FO table data (inlining stavi_untl_gap_detection's cut construction), then prove gap is D-definable-on-left.

Key proof steps:
1. **Cut construction** (~100 lines): Mirror stavi_untl_gap_detection with gD = g∧D as cofinality formula. Base point = s.
2. **D-cofinal in cut**: From gD cofinal → D cofinal (gD → D).
3. **No initial complement gD** (~25 lines): Same argument as stavi_untl_gap_detection's h_no_init_compl.
4. **D-failure** (~15 lines): By contradiction from ¬U'(D, g∧D)(s). If D held everywhere in (s, s₁), replace ⊤ with D in condition (1) right branch to get U'(D, g∧D)(s).
5. **No initial complement D** (~25 lines): By contradiction. Assume ∃ t ∉ cut, D at complement ≤ t. Show t < u_D < s₁ (D-failure point). Construct U'(D, g∧D)(s) with bound t: condition (1) at complement u < t uses D on (u, t) (all complement ≤ t have D) + gD-failure from h_no_init_compl_gD; conditions (2), (3) from u_init < t. Contradicts ¬U'(D, g∧D)(s).
6. **RDefinableGap wrapping**: Use D (depth ≤ r) as defining formula.
7. **S(f,g)^mu at gap** (~15 lines): Use q from S(f,g)(s) as witness. g at cut points above s from h_gD_at_cut.

## Backward Direction (TODO)

Need: D-gap γ with S(f,g)^mu(γ) → std_untl(compound, D)(m).

**Approach**: From S(f,g)^mu(γ), get witness t < γ with f(t) and g between t and γ. Pick a complement point s_b near γ (from complement_no_min). Use the stavi_untl_gap_detection BACKWARD direction pattern to construct U'(⊤, g∧D)(s) for some cut point s near the gap boundary.

**Detailed plan**:
1. From S(f,g)^mu(γ): get carrier point t in cut with f(t) and g at carriers in (t, γ)
2. Pick s in the cut with s > t (exists since cut has no sup). D(s) from D-between. g(s) from S-witness.
3. S(f,g)(s): use t as witness, f(t) and g on (t, s) ✓
4. U'(⊤, g∧D)(s): use stavi_untl_gap_detection BACKWARD to construct from gap data
   - gap_definable_on_left γ D → gap_definable_on_left γ (g∧D)? NOT directly (D ⊃ g∧D)
   - Alternative: construct the FO table directly from gap structure + g at cut points
5. ¬U'(D, g∧D)(s): D fails at complement points (from gap_definable_on_left D). So no U'(D, g∧D) can hold (right branch needs D at complement).

**Subtlety**: Step 4 is the hardest. The gap is D-defined, not g∧D-defined. But g holds at cut points near the gap (from S(f,g)^mu). So g∧D = g ∧ D holds at cut points near the gap. The gD-cofinality from s follows. The gD-failure at complement follows from D-failure at complement. The gD-initial from s follows from g and D both holding near s.

## Current Sorry Sites (6)

| # | Line | Location | Status |
|---|------|----------|--------|
| 1 | ~3108 | base.snce backward | Forward done, backward TODO |
| 2 | ~3480 | stavi_snce case | Blocked on stavi_snce_gap_detection |
| 3 | ~3560 | std_snce case | Same pattern as base.snce |
| 4 | ~3842 | stavi_snce_gap_detection | Needs RHS refactoring |
| 5 | ~4903 | ghr93_decomposition_implies_game | Phase 4 |
| 6 | ~6205 | stavi_expressive_completeness | Phase 4 |
