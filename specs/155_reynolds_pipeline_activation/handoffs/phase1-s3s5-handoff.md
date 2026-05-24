# Handoff: Phase 1 Complete — S3 and S5 Closed

**Date**: 2026-05-24
**Session**: sess_1779640471_03278b
**Phase**: 1 (Mechanical Sorry Closure S3 + S5)
**Status**: COMPLETED

## Immediate Next Action

Start Phase 2: Formula C Case-Split Resolution (S1 + S2).

The sorry sites S1 and S2 are at lines 3901 and 3935 in
`Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean`.
Read the plan Phase 2 description and the mechanical strategy report
`specs/155_reynolds_pipeline_activation/reports/30_mechanical-strategy.md`
before starting.

## Current State

Phase 1 is fully complete. Both S3 and S5 gap case are sorry-free:

- **S3** (`h_cont_transfer_mr`, was lines ~4407-4520): Fixed 9 omega failures
  and 1 type mismatch. The proof now compiles clean. Commit: `db347c62f`.

- **S5** (`h_mr_resp_ge_d` gap case, was line 4581): Closed by adapting the
  1-round proof (lines 3994-4248) using direct `ha'_mr_in` bound derivation
  instead of game-tuple order agreement. Same commit.

Remaining sorries in the 4000s lines:
- Line 4537: `h_mr_resp_le_d` (S4, the K^-(¬D_M) direction for multi-round game)
- Lines 4715, 4740: position-tracking in `h_interior_left`/`h_interior_right`
  (pre-existing, tracked in Phase 4)

## Key Decisions Made

1. **S3 fix strategy**: The `simp only [game_tuple]; split_ifs; omega` approach
   fails because omega cannot see through `Fin.val` of `⟨expr, proof⟩` after
   split_ifs. The correct pattern (matching the 1-round proof at lines 3264-3369)
   is: `simp only [game_tuple, show (k : Nat) = (n_sel+1) from by omega, ..., dite_true/false]`.
   All branch conditions must be provided as inline `show ... from by omega` terms.

2. **S5 gap strategy**: Boundary sub-cases (c_inf=y, x=c_inf) from the 1-round
   proof are NOT needed in S5. The direct bound `ha'_mr_in ⟨1+3*n,...⟩.1` gives
   `rank_embed x' ≤ mr_resp` from which `x' < d` follows immediately. The rest
   of the gap proof structure is identical to the 1-round version.

3. **h_mr_resp_le_d (S4) remains sorry**: This requires the K^-(¬D_M) argument
   for the multi-round game (mirroring lines 3335-3937). It depends on Phase 2
   (formula C resolution) completing S1+S2 first.

## What NOT to Try

- Do NOT use `split_ifs` after `simp only [game_tuple]` for game_tuple index
  proofs. The resulting conditions on `↑↑⟨expr, proof⟩` are opaque to omega.
- Do NOT attempt `hfin_2n`/`hfin_3n`/`hfin_4n` Fin equality precomputation —
  it doesn't help because simp sees the val through these.
- Do NOT use `game_tuple_b_eq` / `game_tuple_y_eq` for non-literal indices
  (they only work when the index literally equals `n+1` or `n+2` in Lean's
  kernel, not when it's `3+3*n`).

## Critical Context

The `game_tuple` definition (EFGames.lean line 6745) is:
```lean
fun i => if i.val = 0 then x
         else if i.val = n_sel + 1 then extendPoint b
         else if i.val = n_sel + 2 then y
         else a ⟨i.val - 1, ...⟩
```
where `n_sel = 1 + 3 * n + 1` (the number of selection slots).

For index `3+3*n` (= n_sel+1 = b slot): need
```
simp only [game_tuple, show (3+3*n : Nat) = (1+3*n+1)+1 from by omega,
           show (1+3*n+1+1 : Nat) ≠ 0 from by omega, dite_true, dite_false]
```
For index `4+3*n` (= n_sel+2 = y slot): need
```
simp only [game_tuple, show (4+3*n : Nat) = (1+3*n+1)+2 from by omega,
           show ¬((1+3*n+1+2 : Nat) = (1+3*n+1)+1) from by omega,
           show (1+3*n+1+2 : Nat) ≠ 0 from by omega, dite_true, dite_false]
```
For index `2+3*n` (selection slot): need
```
simp only [game_tuple, show (2+3*n : Nat) ≠ 0 from by omega,
           show ¬((2+3*n : Nat) = (1+3*n+1)+1) from by omega,
           show ¬((2+3*n : Nat) = (1+3*n+1)+2) from by omega,
           dite_false, show 2+3*n-1 = 1+3*n from by omega]
```
The last form leaves `rank_embed ... (a_pad ⟨1+3*n, ...⟩) = rank_embed ... c_inf`
which simp closes automatically using `hc_last` in context.

## References

- Plan: `specs/155_reynolds_pipeline_activation/plans/28_reynolds-pipeline-plan.md`
- Phase 1 complete at line 117 of plan
- Modified file: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean`
- Key commit: `db347c62f` (task 155 phase 1: close S3 h_cont_transfer_mr and S5 gap case)
- 1-round analogues: lines 3240-3330 (S3 model), 3994-4248 (S5 model)
