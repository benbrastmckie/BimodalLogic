# Phase 6C Interval Guard Implementation Handoff

## Summary

Restructured the `succ k'` case of `nf_2var_existence_characterizable` to use a proper interval guard formula instead of `sf_top`. The original sorry was on a FALSE backward direction (sf_top guard is provably too weak). The new sorries are on a CORRECT bridge lemma (GHR93 Proposition 7/12.8.18).

## What Was Done

1. **Defined `interval_guard_sf`**: Disjunction of `char_k nf_u` for ALL depth-k 1-var NFs. Always satisfiable (proved in `interval_guard_sf_true`).

2. **Defined `nf_exist_sf_guarded`**: Same structure as `nf_exist_sf` but uses `interval_guard_sf` instead of `sf_top` as the guard in Until/Since formulas.

3. **Proved `nf_exist_sf_guarded_forward`**: Forward direction (nf_eval -> formula truth). Sorry-free. The guard obligation is discharged by `interval_guard_sf_true`.

4. **Defined bridge lemma `nf_2var_from_interval_data`**: States that the 2-var depth-k NF of (x,t) is determined by depth-k 1-var NFs of x and t, their ordering, interval type sets, and outside-interval type existence. Sorry'd.

5. **Defined `nf_2var_transfer`**: Corollary of the bridge lemma for transferring nf_eval between models with matching data.

6. **Defined `nf_2var_exist_sf_classical`**: Combines forward + backward to produce the existence witness. Used by `nf_2var_existence_characterizable` at `succ k'`.

7. **`nf_exist_sf_guarded_backward`**: Backward direction (formula truth -> nf_eval). Sorry'd pending bridge lemma.

## Current Sorry Sites

1. **Line 1873**: `nf_2var_from_interval_data` -- the bridge lemma
   - Statement: If (x,t) in M and (x',t') in M' have same 1-var NFs, same ordering, same interval type sets, and same outside-interval type existence, then nf_characteristic at 2 vars is equal.
   - This is GHR93 Proposition 7 + Lemma 11 applied to NFs.

2. **Line 2152**: `nf_exist_sf_guarded_backward` -- application of bridge
   - Once the bridge is proved, this needs: extract witness from temporal formula, build interval data, apply bridge. Non-trivial but mechanical.

## Immediate Next Action

Prove `nf_2var_from_interval_data` by induction on k:
- k=0: The 2-var NF is purely atomic. Atoms are determined by 1-var NFs (for predicates at x and t) and the ordering. No quant part. Direct.
- k+1: The 2-var NF is (atoms, quant_part). Atoms: same as k=0. Quant part: for each sub3 : NF k 3, need to show existence of y with 3-var NF sub3 transfers. This requires the IH at depth k applied to all sub-intervals.

## Key Insight

The bridge lemma's difficulty is in the quant part at depth k+1. For a given sub3 : NF k 3 and y in position relative to x and t (say t < y < x), the 3-var NF of (y,x,t) at depth k is determined by:
- 1-var depth-k NFs of y, x, t (available from interval data + endpoint NFs)
- Orderings among y, x, t (known from position)
- Interval type sets between consecutive pairs (sub-intervals of the original interval)

By IH at depth k, these determine the 2-var NFs of all pairs, hence the 3-var NF. So the existence of y with 3-var NF sub3 transfers.

## Build Status

- `lake build` passes
- 2 sorry sites in StaviCompleteness.lean (down from 1, but on CORRECT statements)
- `nf_exist_sf_guarded_forward` is sorry-free (verified via `lean_verify`)

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- main changes
- `specs/155_reynolds_pipeline_activation/plans/35_reynolds-pipeline-plan.md` -- status updates
