# Phase 2 Partial Handoff — NfDepth0Generalized

## Immediate Next Action

Prove the `succ n` case of `nf_nvar_exist_depth0_tl` at line 121 of
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfDepth0Generalized.lean`.

## Current State

- **Phase 2 status**: PARTIAL (1 sorry remaining)
- **Sorry count in new file**: 1 (line 121, inductive step n+1)
- **Build status**: PASSES (1699 jobs, zero errors)
- **No regressions**: VecEA_m.lean, NfToVecEA.lean, VecEADecomp.lean, KampPrior.lean all untouched

## What Was Accomplished

1. Created `NfDepth0Generalized.lean` (~140 lines)
2. Defined `insertEnv` and proved `insertEnv_last`, `insertEnv_init`, `insertEnv_zero` (sorry-free)
3. Proved `nf_nvar_exist_depth0_tl` for n=0 (zero existentials, characteristic formula)
4. Defined `nf_nvar_exist_depth0_tl_fn` and `nf_nvar_exist_depth0_tl_fn_correct` wrappers
5. Type signature matches Phase 3 interface requirements

## What Remains: The n+1 Inductive Step

### The Problem

The multi-variable existential at depth 0:
```
∃ env : Fin (n+1) → M.carrier, nf_eval_nf M 0 (n+2) (insertEnv env t) sub_nf
```
needs to be expressed as a temporal formula about the single point t.

At depth 0, this is a conjunction of predicate conditions (at each variable) and
order conditions (between all pairs). The challenge is that the existential
quantifies over n+1 points whose positions relative to each other AND to t
are all constrained by the NF's order booleans.

### Why the IH Doesn't Directly Apply

The IH gives: for `NormalForm sig 0 (n+1)`, convert n existentials to temporal.
But peeling off one existential from the (n+1)-variable case produces an
n-variable existential where the peeled variable has CROSS-CONDITIONS with the
remaining variables. These cross-conditions couple the peeled variable with the
inner existential witnesses, preventing clean separation into IH + temporal quantifier.

### Recommended Approach for Next Dispatch

**Nested Since/Until chains**: Build the temporal formula DIRECTLY (without IH)
using nested Since and Until operators. The construction:

1. Determine the consistent ordering from `sub_nf`'s order booleans
2. If inconsistent (any pair has both order booleans true): `Formula.bot`
3. If consistent: identify t's position p in the total ordering
4. Build `pred_t ∧ sinceChain(vars_left) ∧ untilChain(vars_right)` where:
   - `sinceChain [P_1,...,P_k]` = `S(P_k ∧ S(P_{k-1} ∧ ..., ⊤), ⊤)`
   - `untilChain [P_1,...,P_m]` = `U(P_1 ∧ U(P_2 ∧ ..., ⊤), ⊤)`
5. Handle equality cases (where variables must be equal) by substitution

**Correctness proof**: The sinceChain places k witnesses z_1 < ... < z_k < t, and
untilChain places m witnesses t < w_1 < ... < w_m. The NF's order booleans determine
which variables go left/right of t. The predicate at each variable is given by
`nfPred atomMap h_surj (nf_proj_var sub_nf i)`.

### Key Definitions Available

- `nfPred` (NfToVecEA.lean): Build TemporalPred from 1-var depth-0 NF
- `nfPred_correct`: Correctness of nfPred evaluation
- `sinceWitnessPred`, `untilWitnessPred` (VecEADecomp.lean): Temporal preds with Since/Until existentials
- `nf_proj_var` (this file, defined but commented out): Project to 1-var NF

## Key Decisions

- Used `theorem` (not `def`) for `nf_nvar_exist_depth0_tl` because it returns
  an existential `∃ A, ...` rather than a constructive Subtype
- Used `insertEnv` convention: env at positions 0..n-1, t at position n
- This matches the recursion in `nf_eval_nf` where `Fin.cons x env` prepends
  the newest existential variable

## Sorry Inventory

| File | Line | Statement | Assumption | Why Deferred | Next Dispatch |
|------|------|-----------|------------|--------------|---------------|
| NfDepth0Generalized.lean | 121 | nf_nvar_exist_depth0_tl (n+1 case) | That the n+1 multi-variable existential at depth 0 is TL-definable | Cross-conditions between peeled variable and inner existentials prevent clean IH application; requires direct nested temporal chain construction | Build sinceChain/untilChain infrastructure, enumerate orderings, prove correctness |

## References

- Plan: `specs/305_rabinovich_ea_formula_implementation/plans/33_nf-strong-induction.md` (Phase 2)
- Phase 1 output: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEA_m.lean` (490 lines, sorry-free)
- Arity-2 template: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfToVecEA.lean` (nf_2var_exist_depth0_tl)
- Arity-3 template: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEADecomp.lean` (zone decomposition)
