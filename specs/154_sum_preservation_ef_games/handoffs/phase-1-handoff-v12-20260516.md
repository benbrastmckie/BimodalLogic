# Phase 1 Handoff: Function.update Approach BLOCKED (v12)

**Date**: 2026-05-16
**Session**: sess_1778947691_8318ca
**Status**: BLOCKED
**File**: `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean`

## Immediate Next Action

A fundamentally different approach is needed. Function.update does NOT solve the ite-in-types problem. The file was reverted to its original state (same as git HEAD).

## Key Discovery

Function.update hides DecidableEq inside its body, but when `Function.update f a v a'` appears in TYPE positions (as arguments to NormalForm or nf_eval_nf), no tactic can reduce it:

- `Function.update_self` IS `@[simp]` but `simp only [Function.update_self]` only reduces the dif inside the lambda bodies (eM/eN), NOT the Function.update in NormalForm type parameters
- `Function.update_of_ne` is NOT `@[simp]` and neither `rw` nor `simp` can apply it in dependent positions
- `subst h; rw/simp [Function.update_self]` in positive branch: simp reduces the dif in eM/eN but the NormalForm type still has the opaque Function.update term

## What Partially Works

For the **negative branch** of `agree`:
```lean
have hsz_eq : Function.update cd.sz j (cd.sz j + 1) j' = cd.sz j' := by
  simp [Function.update, dif_neg h]
exact hsz_eq ▸ (cd.agree j')
```
This works because `simp [Function.update, dif_neg h]` unfolds Function.update and reduces the dif, giving rfl. Then `rfl ▸ X` is a no-op.

For the **positive branch** of `agree`, nothing works after `subst h` because `Function.update cd.sz j' (cd.sz j'+1) j'` in NormalForm type params is STILL opaque.

## Root Cause Analysis

The problem is NOT the choice of ite vs Function.update vs dite. The problem is that ALL of these ultimately depend on `DecidableEq I` (from `LinearOrder I`) which is OPAQUE. When this opaque term appears inside a type (like `NormalForm sig (budget - <opaque>) <opaque>`), no tactic can reduce it because:

1. `rw` creates an invalid motive (the dependent type prevents abstraction)
2. `simp` can't find the pattern when it's under dependent binders
3. `subst` only works on free variables, not complex expressions
4. `▸` fails to compute the motive

## Approaches NOT Yet Tried

1. **Refactor CompData** to parameterize by the j-component size directly: `(sz_j : Nat) (sz_rest : (j' : I) -> j' ≠ j -> Nat)` — avoids decision in types entirely
2. **Define nf_eval_nf_cast**: a lemma that says `nf_eval_nf M k n env nf ↔ nf_eval_nf M k' n' env' nf'` when `k = k'`, `n = n'`, and environments are extensionally equal
3. **Use Classical.dec** which might behave differently (unlikely to help)
4. **Restructure proof to avoid CompData**: prove BiCompat directly by well-founded recursion

## Current File State

The file is at git HEAD (5bf03bb76). 24 build errors, zero sorries.
