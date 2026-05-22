# Phase 2 Handoff (Round 5): base.snce Forward Direction Complete

## Summary

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
