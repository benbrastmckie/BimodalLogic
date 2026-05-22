# Phase W1.2d Handoff (Pigeonhole Complete)

**Date**: 2026-05-21
**Session**: sess_1779406602_f09bcf
**Status**: Sub-phase W1.2d-remainder COMPLETED

## What Was Done

1. **Added `stavi_fo_depth_le_twice_depth`** (EFGames.lean, ~line 4015): Proved `stavi_fo_depth A <= 2 * stavi_depth A` by structural induction. This bridges the gap between the syntactic depth bound (`stavi_depth <= r`) and the FO translation depth needed for the NormalForm bridge.

2. **Added `nf_determines_stavi_truth_depth`** (ExpressivenessGeneral.lean, ~line 570): Variant of `nf_determines_stavi_truth` that uses NormalForm at depth `2*r` instead of `r`. This allows applying the NF bridge to formulas with `stavi_depth <= r` (whose `stavi_fo_depth` can be up to `2*r`).

3. **Proved `pigeonhole_definable_formula`** (ExpressivenessGeneral.lean, ~line 640-796): Full sorry-free proof via:
   - `choose_witness` function using `Classical.indefiniteDescription` to pick chain data
   - `state` sequence of floor points built by `Nat.rec` on a subtype
   - `output` function computing (u, A, t) from each state
   - Monotonicity chain: `u_mono`, `u_mono_le`, `bound_le`
   - `holds_later`: A_i holds at u_j for j > i (key for distinguishability)
   - `Fintype.exists_ne_map_eq_of_card_lt` for pigeonhole
   - Final contradiction via `nf_determines_stavi_truth_depth`

## Key Insight

The `stavi_fo_depth` can exceed `stavi_depth` by up to a factor of 2 (Stavi operators add +4 to FO depth but only +2 to syntactic depth). This means formulas with `stavi_depth <= r` can have `stavi_fo_depth` up to `2*r`. The NormalForm bridge at depth `r` is insufficient; using depth `2*r` resolves this while keeping the pigeonhole finite (the bound is `Fintype.card (NormalForm (muSig sig) (2*r) 1)`).

## Remaining Work in Phase 4C-W1

### Sub-phase W1.2e: D-Consistency (lines 1098, 1131)
- `d_consistency_left` and `d_consistency_right`
- GHR93 Claim 1 infimum argument
- Very complex: ~150-200 lines each
- Requires understanding of `ghr93_duplicator_wins` backward strategy semantics

### Sub-phase W1.4: M-side Degenerate (lines 1461, 1478)
- Both occur when `x = c` (or `c = y`) is a gap, making `[x,c]` (or `[c,y]`) point-free
- Fix requires either restructuring `SplitPointProps` or proving the degenerate branches unreachable
- `SplitPointProps.h_pt_xc` and `.h_pt_cy` are used at lines 2279, 2785, 3137, 1845, 2766
- More self-contained than d_consistency but requires careful analysis of downstream impact

## Immediate Next Action

Start sub-phase W1.2e (d-consistency) since it's on the critical path and unblocks Case I/II proofs.
