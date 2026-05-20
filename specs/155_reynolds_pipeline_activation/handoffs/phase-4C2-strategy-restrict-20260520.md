# Phase 4C.2 Handoff: Strategy Restriction + obtain_split_point_props

**Date**: 2026-05-20T23:50Z
**Session**: sess_1779304083_f28ee0
**Status**: Phase 4C.2 enhanced (not a new phase -- augmenting existing 4C.2 work)

## What Was Done

### 1. Strategy Restriction Lemmas (EFGames.lean, ~180 lines added)

Added three declarations after `ghr93_duplicator_wins_round_mono`:

- `response_containment_left` (sorry'd): The hard sub-lemma. States that when Duplicator plays the (n+1)-round game with c as the last selection, all responses land in [x',d] and Round 2 responses land in [x,c]. This is the core difficulty.

- `ghr93_strategy_restrict_left`: Restricts an (n+1)-round winning strategy from [x,y] to [x,c] when c and d are compatible (same rank_type, same gap/point). Proof structure complete; depends on `response_containment_left` (sorry'd).

- `ghr93_strategy_restrict_right`: Dual for [c,y] vs [d,y']. Proof structure symmetric, sorry'd.

### 2. Generalized IH (ExpressivenessGeneral.lean)

Refactored `ghr93_forward_to_backward` to use `revert x y x' y'` before `induction n`, giving:
```
ih_gen : forall {x y x' y'}, x <= y -> x' <= y' -> (exists p, ...) ->
         duplicator_wins M N (1+3*n) r x y x' y' ->
         duplicator_wins N M n r x' y' x y
```
This universally-quantified IH can be applied to sub-intervals. The `ghr93_inductive_step` and `obtain_split_point_props` signatures updated accordingly.

### 3. Revised obtain_split_point_props (ExpressivenessGeneral.lean)

Complete structural rewrite:
1. **d = a_bwd(n)** (Spoiler's last pick). hd_le_an = le_refl (trivial).
2. **Point case for c** (d is a point): Uses forward game's 1-round strategy + Round 2 to find matching point b in [x,y]. Formula agreement and gap/point agreement extracted from winning condition at index 2. Fully proved except for the sorry in strategy restriction.
3. **Gap case for c** (d is a gap): sorry'd. Requires Lemma 9 (gap detection correctness).
4. **sigma/tau construction**: Applies strategy_restrict_left/right to get (1+3n)-round strategies on sub-intervals, then applies IH. Sub-interval point witnesses (h_pt_left, h_pt_right) sorry'd.

## Remaining Sorries (6 in obtain_split_point_props chain)

| Sorry | Location | What's Needed | Difficulty |
|-------|----------|---------------|-----------|
| response_containment_left | EFGames.lean | Show responses to selections <= c land in [x',d] | Hard |
| response_containment_right (implicit) | EFGames.lean | Dual of above | Hard |
| h_pt_left | ExpressivenessGeneral.lean | Point witness in [x',d] | Medium |
| h_pt_right | ExpressivenessGeneral.lean | Point witness in [d,y'] | Medium |
| Gap case for c | ExpressivenessGeneral.lean | Find compatible gap in M (uses Lemma 9) | Hard |
| Winning condition transfer | EFGames.lean (strategy_restrict_left) | Transfer game_tuple winning condition across index sets | Medium |

## Next Actions

1. **Immediate next**: Implement Cases I-IV (tasks 4C.3-4C.6) which consume SplitPointProps
2. **Medium-term**: Close response_containment_left (may require reformulating strategy restriction with infimum)
3. **Long-term**: Close gap case for c (requires Lemma 9)

## Key Decisions

- **d = a_bwd(n)**: Simplest split point that makes hd_le_an trivial. GHR93 uses a more complex infimum construction, but our approach is sufficient for the type structure.
- **Generalized IH**: Reverting endpoints before induction is the cleanest way to get the IH for sub-intervals. This required touching the induction structure of ghr93_forward_to_backward but did NOT change the base case or case structure.
- **Strategy restriction consumes 1 round**: Adding c/d to the selection set uses one extra round. We have (4+3n) rounds and need (1+3n) for the IH, leaving 3 rounds of margin. We use 1 for restriction and have 2 spare.
