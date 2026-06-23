# Phase 2 Blocker: Arity Growth in Depth Induction

## Status
Phase 2 (Depth-k Existential-to-Temporal Translation) is BLOCKED.

## What Was Attempted

The plan called for implementing `nf_2var_exist_tl` by induction on depth k:
- Base (k=0): handled by `nf_2var_exist_depth0_tl` (sorry-free)
- Step (k -> k+1): translate `exists x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf`

## The Obstruction

At depth k+1, `nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf` decomposes into:
1. Atom predicates at (x, t) -- handled
2. Quantifier conditions: for each `sub_sub_nf : NormalForm sig k 3`,
   `exists y, nf_eval_nf M k 3 (Fin.cons y (Fin.cons x (fun _ => t))) sub_sub_nf`

The environment `(y, x, t)` is NOT a constenv (x and t can differ), so
`constenv_2var_determines` does not apply. The IH at depth k for arity 2
cannot handle arity-3 existentials.

This creates an "arity growth" problem: depth-k arity-2 needs depth-(k-1) arity-3,
which needs depth-(k-2) arity-4, etc. The mutual induction does not close.

## Approaches Tried

1. **Direct depth induction**: Fails (arity grows 2 -> 3 -> 4 -> ...)
2. **Mutual induction on (k, arity)**: Fails (each arity step needs the next)
3. **Using constenv_2var_determines**: Only applies to constenvs (z, c, c, ..., c),
   not general envs (y, x, t) with x != t
4. **Using nf_to_formula + kamp_prior_expressive_completeness recursively**: Circular
5. **doets_lemma_1_1 for 1-var to 2-var reduction**: 1-var NFs of x and t individually
   do NOT determine their 2-var NF
6. **VVecEA2 negation closure**: Model-dependent (gives different VVecEA2 for each M),
   cannot produce model-independent temporal formula

## Root Cause

Rabinovich's proof of Prop 4.3 uses structural induction on FO formulas (all arities
simultaneously), not NF depth induction at a fixed arity. The structural induction:
- Atoms: trivially V-EA
- Disjunction: V-EA closed under disjunction
- Negation: Prop 4.2 (negation closure for 2-free-var V-EA)
- Existential: Lemma 3.4 (V-EA closed under existential)

This works because the induction handles ALL arities at once. Our NF-based approach
packages formula structure into a depth index but loses the structural induction's
ability to handle arity growth.

## Resolution Options

### Option A: Structural induction on MonadicFormula
Prove `fo_to_vea : MonadicFormula sig n -> VVecEA2` by structural induction.
Requires model-independent VVecEA2 construction for negation, which the current
`neg_2var_vec_ea` does NOT provide (it's model-dependent).

### Option B: Generalized constenv composition
Prove a version of `constenv_2var_determines` for non-constenvs `(y, x, t)`.
This would reduce arity-3 to arity-2, closing the mutual induction.

### Option C: Different induction measure
Find a well-founded measure that decreases at each step despite arity growth.
E.g., total quantifier complexity summed across all arities.

### Option D: Re-route critical path
Find an alternative proof of `completeness_discrete` that avoids
`nf_characterizable_temporal_prior` entirely. E.g., use the integer model
surgery chain (`US_expressively_complete_over_Z`, which is sorry-free).

## Key Decisions Made
- None (Phase 2 was not started, only analyzed)

## Sorry Inventory
1. KampPrior.lean:136 - CRITICAL PATH (unchanged, still the target)
2. EndpointNegation.lean:160 - NOT critical
3. EANegation.lean:1084 - permanent
4. EANegation.lean:1235 - permanent

## Immediate Next Action
Research which of Options A-D is most feasible. Option D (re-routing via
integer expressive completeness) may be simplest if a transfer theorem
from integer to Prior structures can be established.

Session: sess_1782213664_11fe36
