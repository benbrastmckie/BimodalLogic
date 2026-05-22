# Phase 2 Handoff (Round 4): Lemma 9 Gap Detection

## Summary

Closed 3 additional sorry sites this round (5 total across rounds 1-4):
- **stavi_untl backward** (was line 3164): FO-table shift from U'(A,B)^mu(gamma)
- **std_untl backward** (was line 3215): Complement-point truth from U(A,B)^mu(gamma)
- **stavi_snce_gap_detection** (was line 3241): Full ~200 line dual of stavi_untl_gap_detection

Also refactored stavi_snce_gap_detection RHS and cleaned up base.snce compilation.

## Completed Proofs (All Rounds)

| # | Case | Round | Technique |
|---|------|-------|-----------|
| 1 | base.imp | 1 | gap_detection_unique + IH |
| 2 | base.untl | 1 | stavi_untl_gap_detection bridge |
| 3 | stavi_untl backward | 4 | FO-table shift with min(wf_pt, wi_pt) bound |
| 4 | std_untl backward | 4 | Complement-point U(A,B) construction |
| 5 | stavi_snce_gap_detection | 4 | Dual gap construction with reversed direction |

## Key Techniques

### FO-Table Shift (Backward Directions)
Pick s_bound = min(wf_pt, wi_pt) to ensure complement points u below the bound have
both witnesses in the interval (u, s_pt). The right-disjunct case v'_pt <= u becomes
provably impossible: v'_pt < wi_pt (since v'_pt <= u < wi_pt), so B(v'_pt) from
condition (3), contradicting not-B(v'_pt).

### stavi_snce_gap_detection Dual
- Cut = {x | x not in compl} where compl = {x | D cofinal from x toward m}
- Classical conversion helper needed for double negation: cut = not-compl
- gap_definable_on_right: D on initial complement, not-D on final cut
- X at cut points from body right disjunct

### Changed Theorem Statement
stavi_snce_gap_detection RHS uses "X at cut points above s_bound" instead of
"X^mu at Sum.inr gamma", matching the stavi_untl_gap_detection pattern.

## Remaining Sorry Sites in EFGames.lean (6)

| # | Line | Identifier | Phase | Approach |
|---|------|-----------|-------|----------|
| 1 | 2890 | base.snce | 2 | Direct proof via stavi_untl_gap_detection on U'(top, D) from compound |
| 2 | 3262 | stavi_snce case | 2 | Direct proof; left_formula = .std_untl compound D |
| 3 | 3342 | std_snce case | 2 | Direct proof; same pattern as stavi_snce |
| 4 | 3624 | right_formula_gap_detection | 2 | Full dual of left_formula_gap_detection |
| 5 | 4685 | ghr93_decomposition_implies_game | 4 | Not in scope |
| 6 | 5987 | stavi_expressive_completeness | 4 | Not in scope |

## Approach for Remaining Phase 2 Sorries

### base.snce, stavi_snce, std_snce (Lines 2890, 3262, 3342)
All three have left_formula = .std_untl compound D where compound includes U'(top, B and D).

Strategy:
1. From U(compound, D)(m): extract s with compound(s) and D on (m,s)
2. From compound(s): extract U'(top, B and D)(s) and not-U'(D, B and D)(s)
3. Derive D fails above s (from not-U'(D, B and D))
4. Construct U'(top, D)(m) using D on (m,s) + D fails above s + body from U'(top, B and D)
5. Apply stavi_untl_gap_detection to get D-gap
6. Show target formula at gamma from compound's remaining components

~100-150 lines per case, some infrastructure sharable.

### right_formula_gap_detection (Line 3624)
Full dual of left_formula_gap_detection using stavi_snce_gap_detection (now proved).
~300 lines, mostly mechanical dualization.

## Commits
- 00893bd71: close stavi_untl and std_untl backward directions
- 741c94e3a: prove stavi_snce_gap_detection, fix base.snce compilation

## Next Action
Prove base.snce forward direction by constructing U'(top, D)(m) from the compound's data.
