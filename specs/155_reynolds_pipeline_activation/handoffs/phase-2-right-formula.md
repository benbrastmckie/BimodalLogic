# Phase 2 Handoff: right_formula_gap_detection

## Summary

`right_formula_gap_detection` skeleton is in place. `gap_detection_unique_right` helper proved. Neg, conj, and trivial base cases (atom/bot/box) fully proved. 7 remaining sorry'd cases scaffolded with structure.

## Proved Cases

| Case | Status | Lines | Approach |
|------|--------|-------|----------|
| base.atom | PROVED | 4 | Both sides False |
| base.bot | PROVED | 4 | Both sides False |
| base.box | PROVED | 4 | Both sides False |
| neg A | PROVED | 60 | stavi_snce_gap_detection + gap_detection_unique_right |
| conj A B | PROVED | 30 | IH + gap_detection_unique_right |

## Remaining Cases (7 sorry sites)

Each mirrors a left_formula_gap_detection case with direction reversed:

| Case | Right Formula | Left Dual | Estimated Lines |
|------|--------------|-----------|-----------------|
| base.imp | S'(⊤,D) ∧ ¬(...) | left base.imp | ~60 |
| base.untl | std_snce compound D | left base.snce (compound decomp) | ~300 |
| base.snce | S'(B∧S(A,B), D) | left base.untl (stavi bridge) | ~50 |
| stavi_untl | std_snce compound D | left stavi_snce (compound decomp) | ~300 |
| stavi_snce | S'(B∧S'(A,B), D) | left stavi_untl (direct) | ~200 |
| std_untl | std_snce compound D | left base.snce/std_snce (compound decomp) | ~300 |
| std_snce | S'(B∧S(A,B), D) | left std_untl (stavi bridge) | ~50 |

## Helper: gap_detection_unique_right

Proved as dual of `gap_detection_unique`. Key difference: uses `gap_definable_on_right` condition 2 (no initial D in cut) and `h₂_bet` (D at complement points) to derive contradiction with `h₁_def`.

## Commits
- `c4acee379` — skeleton + neg/conj/trivial
- `69d7a3b9c` — scaffolded stavi_snce/std_snce structure
