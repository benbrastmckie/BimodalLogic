# Phase 4B Handoff: Tasks 4B.5-4B.6 Complete

## Status

Tasks 4B.5 (Custom Game G_{n;r}) and 4B.6 (Decomposition Formulas + Lemma 11) are complete. Phase 4B is now fully done except for Task 4B.7 (build verification, trivially done).

## What Was Done

### Task 4B.5: Custom Game G_{n;r} (GHR93 Def 8.7)
- Defined `ghr93_duplicator_wins` -- Duplicator's winning strategy as a Prop
- Defined helper predicates: `inClosedInterval`, `game_tuple`, `same_order_type`, `formula_agreement`, `gap_point_agreement`, `ghr93_winning_condition`
- Stated `ghr93_duplicator_wins_round_mono` (Lemma 10, sorry'd)

### Task 4B.6: Decomposition Formulas + Lemma 11
- Defined `decomposition_agreement` -- semantic content of (n;r)-decomposition formula agreement
- Stated `ghr93_game_implies_decomposition` (Lemma 11 forward, sorry'd)
- Stated `ghr93_decomposition_implies_game` (Lemma 11 backward, sorry'd)
- Proved `ghr93_game_iff_decomposition` (iff combining both directions)

### Rank Bound Fixes (Phase 4B.4 sorry elimination)
- Fixed `stavi_depth_left_formula_base` snce case (was sorry'd, now proved)
- Fixed `stavi_depth_left_formula` stavi_snce case (was sorry'd, now proved)
- Fixed `stavi_depth_right_formula` all cases (was sorry'd, now proved via induction)
- Corrected rank bound from +2 to +4 (GHR93 counts +1 per connective; our depth counts +2)

## Remaining Sorry's in EFGames.lean (6 total)
1. `left_formula_gap_detection` (Lemma 9 left) -- Phase 4C
2. `right_formula_gap_detection` (Lemma 9 right) -- Phase 4C
3. `ghr93_duplicator_wins_round_mono` (Lemma 10) -- Phase 4C
4. `ghr93_game_implies_decomposition` (Lemma 11 forward) -- Phase 4C
5. `ghr93_decomposition_implies_game` (Lemma 11 backward) -- Phase 4C
6. `stavi_expressive_completeness` (main theorem) -- Phase 4C

## Key Design Decisions
1. Rank monotonicity across different r values not formalized (requires coercion between ExtendedCarrier M atomMap r and ExtendedCarrier M atomMap r')
2. Decomposition formulas defined semantically rather than as syntactic FO formulas
3. Round monotonicity takes boundary ordering hypotheses (hxy, hx'y')
4. game_tuple uses convention: index 0=x, 1..n=a_i, n+1=b, n+2=y

## Immediate Next Action
Phase 4C: Begin GHR93 Theorem 6 proof in new file ExpressivenessGeneral.lean (Task 4C.1).

## File State
- `EFGames.lean`: 1528 lines (was 1160), build passes
- Full project build passes (1646 jobs)
