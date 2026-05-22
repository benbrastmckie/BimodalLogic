# Phase 4C-W2 Handoff: Lemma 9 Structural Decomposition

**Session**: sess_1779413458_ce29e1
**Date**: 2026-05-21
**Phase**: 4C-W2 (Lemma 9 Gap Detection Correctness)
**Status**: PARTIAL - structure established, core helpers sorry'd

## What Was Accomplished

### Architecture Established

1. **`left_formula_gap_detection`** (line 2469): Full structural induction on `A : StaviFormula` with all 7 cases handled:
   - `base.atom`, `base.bot`, `base.box`: CLOSED (both sides False at gaps)
   - `conj`: CLOSED (gap_detection_unique + IH)
   - `neg`: CLOSED (using stavi_untl_gap_detection helper + gap_detection_unique)
   - `stavi_untl` forward: CLOSED (drop B from (B AND U'(A,B))^mu(gamma))
   - `std_untl` forward: CLOSED (same pattern)
   - Remaining sorries: backward temporal cases + base.imp/untl/snce

2. **Helper lemmas** extracted before main theorem:
   - `stavi_untl_gap_detection` (line 2407): U'(X, D)(m) <-> gap exists -- SORRY
   - `std_untl_gap_detection` (line 2423): U(X, D)(m) <-> gap exists -- SORRY
   - `stavi_snce_gap_detection` (line 2658): S'(X, D)(m) <-> gap exists (right) -- SORRY
   - `std_snce_gap_detection` (line 2673): S(X, D)(m) <-> gap exists (right) -- SORRY

3. **`right_formula_gap_detection`** (line 2697): SORRY (needs same treatment as left using snce helpers)

### Sorry Inventory (EFGames.lean, this theorem group only)

| Line | Context | Difficulty |
|------|---------|------------|
| 2418 | stavi_untl_gap_detection | HARD (core helper, ~200 lines) |
| 2434 | std_untl_gap_detection | HARD (similar to above) |
| 2511 | base.imp sub-case | MEDIUM (mirrors neg+conj pattern) |
| 2515 | base.untl sub-case | MEDIUM (mirrors stavi_untl pattern) |
| 2519 | base.snce sub-case | MEDIUM (mirrors stavi_snce pattern) |
| 2626 | stavi_untl backward | HARD (needs B^mu(gamma) from U'(A,B)^mu(gamma)) |
| 2630 | stavi_snce full | HARD (compound std_untl formula) |
| 2644 | std_untl backward | HARD (needs B^mu(gamma) from U(A,B)^mu(gamma)) |
| 2648 | std_snce full | HARD (compound std_untl formula) |
| 2669 | stavi_snce_gap_detection | HARD (past dual) |
| 2684 | std_snce_gap_detection | HARD (past dual) |
| 2697 | right_formula_gap_detection | MEDIUM (structural, uses snce helpers) |

### Key Decisions Made

1. Used `stavi_truth_mu_at_point` bridge to convert between mu-relativized and standard evaluation at actual points (needed for gap_detection_unique arguments)
2. Extracted 4 standalone helper lemmas (one per temporal connective) rather than inlining the gap construction in each case
3. Forward temporal cases work by applying helper then dropping the B conjunct from (B AND temporal(A,B))^mu(gamma)
4. Backward temporal cases are the genuinely hard part -- require extracting B^mu(gamma) from the FO table structure of temporal(A,B)^mu(gamma)

## Immediate Next Action

**Priority 1**: Prove `stavi_untl_gap_detection` (the linchpin). Strategy:
- Convert LHS to stavi_temporal_truth via stavi_truth_mu_at_point
- Forward: construct gap from FO table (cut = {x | D holds on (m,x)})
- Backward: construct FO table witness s from gap complement

**Priority 2**: Once stavi_untl_gap_detection is done, the backward temporal cases become tractable (extract B from condition (3) of U'(A,B)^mu(gamma) FO table)

**Priority 3**: right_formula_gap_detection follows by symmetry using stavi_snce_gap_detection

## Build Status

`lake build` passes with only warnings (no errors). The sorry warnings are expected.

## Key Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` (lines 2388-2700 region)
