# Implementation v7 Handoff — Team Implement Attempt

**Task**: 154 - sum_preservation_ef_games
**Session**: sess_1778914245_27004e
**Date**: 2026-05-16
**Status**: PARTIAL — extensive debugging, no net code changes committed

## Summary

5 agents spawned across 2 waves. All 15 build errors stem from the same root cause (`show T from e` creating opaque `have` bindings) but fixing them requires coordinated ~80-line changes across two functions with cascading tactic interactions.

## Verified Fix Patterns (each works in isolation)

### Category 1: h_idx' in build_bicompat (6 errors)

**Root cause**: `(Fin.cons (show (orderedSum sig I ms).carrier from ⟨j, c⟩) env_M p).1` — the `.1` projection fails because `show T from e` elaborates to `have this := e; this`, opaque to dot notation.

**Verified fix**: Provide h_idx' proof inline avoiding `.1` in TYPE:
```lean
fun p => by cases p using Fin.cases; show j = j; rfl; exact h_idx k
```
This avoids stating the problematic type — Lean infers it from usage.

### Category 1b: cd' eM/eN fields (latent, exposed after h_idx' fix)

**Root cause**: `sz` uses `ite` (non-dependent) while `eM` uses `dite` (dependent), and Lean can't link the proof from `dite` to reduce `ite` in `sz`.

**Verified fix**:
```lean
eM := fun j' => by
  show Fin (if j' = j then cd.sz j + 1 else cd.sz j') → (ms j').carrier
  split
  case isTrue h => subst h; exact Fin.cons c (cd.eM j)
  case isFalse h => exact cd.eM j'
```

### Category 2: sum_lift_one_var (9 errors)

**Fix 2A - k case-split** (verified):
```lean
rcases Nat.eq_zero_or_pos k with rfl | hk_pos
· exact sum_nf_lift_gen sig 0 1 I ms ms'
    (fun m hm => h_comp m (by omega)) envM envN h_atoms_1 trivial sub_nf
· -- k > 0 case with CompData
```

**Fix 2B - bound field** (verified, k>0 branch):
```lean
bound := fun j' => by
  show (if j' = i then 1 else 0) < k + 1
  split <;> omega
```

**Fix 2C - eM/eN** (partially verified): The opaque `show Fin (if ...) → ... from by rw ...` can be replaced with `h ▸ Fin.cons a Fin.elim0` BUT `DecidableEq` from `LinearOrder I` doesn't reduce definitionally for free variables. Need `cast`-based proof for agree field.

**Fix 2D - agree negative case** (verified):
```lean
exact h_comp (k + 1 - (if j' = i then 1 else 0)) (by omega) j' nf
```

## Why It Didn't Complete

1. Each fix pattern works in isolation but combining them triggers cascading elaboration issues
2. `subst` in `refine`/`split` contexts can leak across goals
3. ~3-minute `lake build` per iteration makes trial-and-error slow
4. eM/eN fields in build_bicompat expose LATENT type mismatches once h_idx' is fixed (these weren't visible before because h_idx' failure masked them)
5. Total changes: ~80 lines across `build_bicompat` (×2 oracles) and `sum_lift_one_var`

## Approaches Tried and Failed

| Approach | Why it failed |
|----------|--------------|
| `let envM_ext` bindings | Changes CompData parameterization, breaks eM/eN/consistent field types |
| Type ascription `(⟨j,c⟩ : T)` | Still opaque to `.1` — same as `show T from` |
| `@[reducible] orderedSum` | Helps some cases but causes 20+ simp/typeclass failures elsewhere |
| `h ▸ Fin.cons a Fin.elim0` for eM/eN | `DecidableEq` non-reduction blocks `simp [dif_pos rfl]` in downstream proofs |
| `sumElem` abbrev | Works for h_idx' but breaks cd' field elaboration |

## Recommended Next Approach

The correct path (from final agent's findings):
1. Fix h_idx' using the `by cases p using Fin.cases; show j = j; rfl; exact h_idx k` pattern
2. Fix eM/eN using `by show ...; split; case isTrue => subst; ...; case isFalse => ...`
3. Fix bound using `by show ...; split <;> omega`
4. Apply all three SIMULTANEOUSLY (they cascade — can't be applied independently)
5. Then fix `agree` and `consistent` fields
6. Then add k-split to sum_lift_one_var and fix its fields

The key insight: ALL changes to a single CompData construction must be applied atomically. You can't fix one field and verify — you must fix ALL fields before the structure compiles.

## Worktree Branches (stale, can be deleted)

- `worktree-agent-ac684e0979780c3bd` — Phase 1 tactic approach (works in LSP, not full build)
- `worktree-agent-a86ee3f498a4be570` — Phase 2 partial (k-split + bound)
- `worktree-agent-a6a8249cb644504fb` — Phase 2 debugger (transparent eM/eN + cast agree)
