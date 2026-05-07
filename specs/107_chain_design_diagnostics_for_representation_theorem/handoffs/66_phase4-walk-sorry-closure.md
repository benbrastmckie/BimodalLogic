# Phase 4 Handoff: Walk Sorry Closure Progress

## Status: PARTIAL (splitting case closed, termination WF issue remains)

## Session: sess_1778114001_749277

## Changes Made

### 1. Uncommented and fixed the not-condition(i) splitting case (was line 959)

The full splitting case implementation was in a block comment (lines 960-1169). Changes:
- Removed the `exact sorry` and block comment delimiters
- Fixed all `pt` references in `show`/`simp` tactics that broke due to Lean 4 WF elaborator renaming `pt` to `a` in the not-condition(i) branch
- Replaced explicit `show BurgessR3Maximal (if pt = z ...)` with `dsimp only [val, g']` + `simp only [...]` approach
- Fixed `f_agrees` proof: used `dsimp only [val]` + explicit `hx_ne_z` construction
- Fixed `g_agrees` proof: kept `show g' a b = χ.g a b` approach (works in this context)
- Fixed `witness_guard` proof: destructured `h_adj_ab` first with `obtain`, then `simp only [val, Finset.mem_insert]` on individual hypotheses instead of the conjunction
- Fixed `g_sub_f_insert` and `g_sub_g_new`: replaced `_` placeholders with `pt` (available in that context), replaced `show ... pt ...` with `dsimp + simp` approach for `g_sub_g_new` second case
- Fixed `dom_new_unique` and `new_point_after`: added `simp only [val, Finset.mem_insert]`

### 2. Changed T_succ definition to match termination measure

Changed `set T_succ := χ.dom.filter (fun v => decide (pt < v))` to `let T_succ := χ.dom.filter (fun v => v > pt)`. This aligns with the `termination_by (χ.dom.filter (fun v => v > pt)).card` measure, avoiding the `decide` wrapper mismatch. Also changed `set` to `let` to make the binding transparent.

### 3. Termination proof: 1 of 3 goals closed

- Goal 1 (direct recursive call): `exact h_term` closes it
- Goals 2-3 (inside `witness_guard` proof of the condition (i) result): WF elaborator duplicates let-bindings as `T_succ✝`/`hT_ne✝` (caller) vs `T_succ`/`hT_ne` (callee). The callee's `h_term` references `x'` (callee's `T_succ.min' hT_ne`) but the goal uses `T_succ✝.min' hT_ne✝` (caller's copy). These are propositionally equal but not definitionally equal, and neither `assumption`, `exact h_term`, `subst ha_eq; exact h_term`, `convert`, nor `simp` can bridge the gap.

### Root Cause of Remaining Sorry

Lean 4 well-founded recursion elaborator duplicates the entire proof context (including `let` bindings) with daggers for the caller/callee distinction. When a recursive call's result `r` is used in a nested proof (like `witness_guard`), the WF elaborator needs termination at the USE site, not just the CALL site. The duplicated let-bindings `T_succ`/`T_succ✝` are propositionally but not definitionally equal, preventing `exact h_term`.

### Recommended Fix

**Option A (restructure)**: Move the `witness_guard` proof out of the structure literal, so it doesn't capture the recursive call `r` in its closure. Define `witness_guard` as a separate `have` before constructing the result. This might change where the WF obligations appear.

**Option B (WellFounded.fix)**: Replace `termination_by`/`decreasing_by` with explicit `WellFounded.fix` in term mode. This gives full control over the termination argument and avoids the dagger duplication issue.

**Option C (defunctionalize)**: Extract the termination measure into a top-level function and prove termination via `Nat.lt_wfRel`.

## Build Status

- Forward C5 errors: 0 (all fixed)
- Backward C5 errors: 6 (pre-existing, Phase 5)
- Sorry in c5_forward_walk: 1 line (2 goals) -- WF termination variable mismatch
- Total sorry in CounterexampleElimination.lean: 1

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`
