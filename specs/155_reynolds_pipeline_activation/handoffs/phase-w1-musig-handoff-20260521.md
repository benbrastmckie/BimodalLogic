# Phase W1.muSig Handoff

## What was done
- Fixed sign error in `stavi_untl_fo` and `stavi_snce_fo` FO encoding: removed spurious `MonadicFormula.not` wrapper around the disjunction conjunction `(not D1, not D2)`
- Proved both `stavi_untl` and `stavi_snce` cases in `stavi_table_mu_correct` (~150 lines each)
- Verified `lean_verify stavi_table_mu_correct` shows no `sorryAx`
- Build passes with 0 new errors

## Key insight
The FO encoding had `not(and(guard, not(and(not D1, not D2))))` which evaluates to `guard -> not(D1 or D2)` instead of the intended `guard -> D1 or D2`. The fix was to use `not(and(guard, and(not D1, not D2)))` which evaluates to `guard -> not(not D1 and not D2) = guard -> D1 or D2`.

## Proof technique
- Forward: `not_and_or.mp` + `Classical.not_not.mp` to convert `not(not D1 and not D2)` to `D1 or D2`
- Backward: direct conjunction destruction + contradiction via lift lemma conversions
- All Fin.cons depth-3/4 terms handled via definitional equality (no simp reduction needed)

## Immediate next action
Sub-phase W1.2d-remainder (pigeonhole): now that `stavi_table_mu_correct` is sorry-free, `pigeonhole_definable_formula` at ExpressivenessGeneral.lean:639 becomes closeable via `nf_determines_stavi_truth` + `Fintype.card_le_of_injective`.

## Current sorry state (EFGames.lean)
- Line 2432: `left_formula_gap_detection` (Phase 4C-W2)
- Line 2451: `right_formula_gap_detection` (Phase 4C-W2)
- Line 3521: `ghr93_decomposition_implies_game` (Phase 4C-W4)
- Line 4809: `stavi_expressive_completeness` (Phase 4C-W4)

## Session
sess_1779404133_554863
