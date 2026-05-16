# Phase 1 Results: Fix Type-Position Opacity in build_bicompat

**Task**: 154 - sum_preservation_ef_games
**Phase**: 1
**Status**: COMPLETED
**Session**: sess_1778914245_27004e

## Changes Made

### File Modified
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean`

### Forward Oracle (lines ~547-590)

**Problem**: `h_idx'` used `(Fin.cons (show (orderedSum sig I ms).carrier from ⟨j, c⟩) env_M p).1` which failed because `.1` (Sigma first-projection) couldn't see through the opaque `show T from x` binding that Lean elaborates to `have this := ⟨j,c⟩; this`.

**Fix**: Changed `h_idx'` from a term-mode `Fin.cases rfl (fun k => h_idx k)` to a tactic-mode proof using `simp [Fin.cons_zero]` and `simp [Fin.cons_succ]` which can reduce through the `have` binding. The `cd'` CompData type annotation was also updated to use `show _ from ⟨j, c⟩` explicitly (matching the goal form) instead of `envM_ext`/`envN_ext` let-bindings.

### Backward Oracle (lines ~629-673)

Identical fix applied (symmetric structure).

### Key Insight

The `show _ from ⟨j, c⟩` pattern in Lean 4 elaborates to `have this := ⟨j, c⟩; this`, which creates an opaque let-binding. Term-mode `.1` projection doesn't reduce through this binding. Tactic-mode `simp [Fin.cons_zero]` / `simp [Fin.cons_succ]` can handle it because they normalize the term first.

## Errors Resolved

All 6 type-position opacity errors in `build_bicompat`:
- 3 errors in forward oracle (lines ~547-550)
- 3 errors in backward oracle (lines ~628-631)

## Remaining Errors in Region

None in `build_bicompat` (lines 474-673). The function compiles cleanly (verified via lean_goal showing empty goals past the function definition).

## Verification

- `lean_goal` at line 675 (docstring after `build_bicompat`): empty goals = function compiled
- `lean_goal` at line 590 (`refine ⟨oracle_step, ...⟩`): `oracle_step` in context = forward oracle complete
- Phase 2 errors in `sum_lift_one_var` (lines 772+) still present as expected
