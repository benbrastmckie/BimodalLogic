# Phase 4 Handoff: WF Termination Progress via simp_all

## Status: PARTIAL (2 of 3 WF goals closed, 1 sorry remains)

## Session: sess_1778114001_749277

## Changes Made

### 1. Fixed unused simp arg warning

Removed `ite_true` from `simp only [ha_ne, hb_ne, ite_false, ite_true]` at line ~1254 (base case, n=0).

### 2. Improved decreasing_by proof: 2 of 3 goals now closed

Previous state: `all_goals (first | exact h_term | sorry)` — closed 1 of 3 goals.

New state:
```lean
decreasing_by
  all_goals simp_all only [gt_iff_lt]
  all_goals (first | exact h_term | sorry)
```

The `simp_all only [gt_iff_lt]` normalizes `v > pt` to `pt < v` across all goals and hypotheses. This allows `exact h_term` to close goals 1 and 3 (where the callee's `pt` happens to be the same fvar as the caller's `pt`). Goal 2 remains unsolved because:

- The WF elaborator creates two copies of `pt`: `pt✝` (caller) and `pt` (callee)
- These are propositionally equal but NOT definitionally equal
- No hypothesis in context connects `pt✝` to `pt`
- `h_term` (callee) has type `... < {v ∈ χ.dom | pt < v}.card` but goal needs `... < {v ∈ χ.dom | pt✝ < v}.card`
- The caller's `h_term✝` would close the goal but cannot be referenced by name in Lean 4 syntax

### 3. Option A (have extraction) was attempted and does NOT help

Extracting `h_witness_guard` as a `have` statement before the structure literal still causes the WF elaborator to generate obligations inside the `have` body. The same `pt✝ ≠ pt` mismatch occurs.

## Root Cause Analysis

This is a confirmed Lean 4 WF elaborator limitation (not a bug in our proof):

1. `c5_forward_walk` recurses at `x'` (condition (i) case)
2. The recursive result `r` is used in `witness_guard` proof (inside the result structure literal)
3. The WF elaborator sees `r` used in a nested proof and generates WF obligations there
4. For nested proofs, the WF elaborator duplicates the entire context with daggers
5. `let` bindings like `T_succ := ...` and `x' := T_succ.min' hT_ne` lose their definitions in the duplicated context
6. The function parameter `pt` is duplicated as `pt✝` (caller) and `pt` (callee) with no connecting hypothesis

## Recommended Next Steps

### Option B: Explicit WellFounded.fix (RECOMMENDED)

Replace the `by` tactic proof + `termination_by` + `decreasing_by` with explicit `WellFounded.fix` in term mode. This gives full control over the termination argument and avoids the WF elaborator entirely.

Pattern:
```lean
private noncomputable def c5_forward_walk ... : C5ForwardWalkResult χ ξ η pt :=
  WellFounded.fix
    (InvImage.wf (fun ⟨pt, h_mem, _, _⟩ => (χ.dom.filter (fun v => v > pt)).card) Nat.lt_wfRel.wf)
    (fun ⟨pt, h_mem, h_untl, h_no_wit⟩ rec => ...)
    ⟨pt, h_start_mem, h_until_start, h_no_wit⟩
```

### Option C: Defunctionalize termination

Extract the termination proof as a separate lemma that takes all needed arguments explicitly. This separates the termination argument from the proof body.

## Build Status

- Forward C5 errors: 0
- Backward C5 errors: 6 (pre-existing, Phase 5)
- Sorry in c5_forward_walk: 1 line (1 WF goal) — down from 2 goals in previous handoff
- Total sorry in CounterexampleElimination.lean: 1

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`
