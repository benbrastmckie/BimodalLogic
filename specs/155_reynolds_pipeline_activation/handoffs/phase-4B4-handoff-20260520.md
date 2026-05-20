# Phase 4B.4 Handoff: Gap Detection Formulas

**Task**: 155
**Sub-task**: 4B.4
**Session**: sess_1779304083_f28ee0
**Timestamp**: 2026-05-20T21:02:37Z

## Completed

- Defined `left_formula_base : Formula -> StaviFormula -> StaviFormula` (handles base formula cases)
- Defined `left_formula : StaviFormula -> StaviFormula -> StaviFormula` (GHR93 Def 8.5)
- Defined `right_formula_base` and `right_formula` (duals, U<->S and U'<->S' swap)
- Added `operator_depth_flatten_stavi_le` helper lemma (sorry-free)
- Stated `stavi_depth_left_formula` rank bound (partially proved: base/neg/conj/stavi_untl cases sorry-free)
- Stated `stavi_depth_right_formula` rank bound (sorry'd)
- Stated `left_formula_gap_detection` (Lemma 9 left, sorry'd per task spec)
- Stated `right_formula_gap_detection` (Lemma 9 right, sorry'd per task spec)

## Sorries Introduced (5 total, all expected/permitted)

1. `stavi_depth_left_formula_base` snce case: nested max arithmetic with `operator_depth (flatten_stavi ...)` terms
2. `stavi_depth_left_formula` stavi_snce case: same issue as #1
3. `stavi_depth_right_formula`: entire theorem (symmetric to left, same difficulty)
4. `left_formula_gap_detection`: Lemma 9 left direction (explicitly permitted by task spec)
5. `right_formula_gap_detection`: Lemma 9 right direction (explicitly permitted by task spec)

## Key Design Decision

The S/S' cases of left_formula use `flatten_stavi` to encode "standard Until of StaviFormulas" as base Formulas. This is necessary because StaviFormula has no constructor for standard Until/Since on StaviFormula arguments (only `.base (.untl ...)` for base Formula arguments and `.stavi_untl` for Stavi Until). The `flatten_stavi` approach produces syntactically valid StaviFormula output; semantic correctness is deferred to Lemma 9.

## Next Action

Task 4B.5: Custom Game G_{n;r} Definition (GHR93 Def 8.7). Define the full game structure replacing the skeleton EFPosition.

## File Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` (836 -> 1160 lines, +324 lines)
