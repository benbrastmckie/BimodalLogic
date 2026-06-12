# Phase 5 Handoff: Backward Direction -- Filter Fix and Composition Blocker

**Date**: 2026-06-11
**Session**: sess_1781193902_83bc5c
**Phase**: 5d (Backward Direction -- decisive cycle)
**Status**: IN PROGRESS (blocked on composition lemma)

## Changes Made

### 1. Filter Fix (committed: 68c80dd5f)

Strengthened `nf_full_compat_right` and `nf_full_compat_left` to check atom
compatibility (var-1/var-2 predicates and x-t order) for interval ssn's.

**Why needed**: Proved a semantic counterexample showing the formula was
incomplete without this check:
- Model: M = (Z, <), 1 predicate p holding at even integers
- t = 0, parent_atoms: p = true (0 is even)
- sub_nf with sub_nf.1 requiring x has p, t < x
- ssn_bad: interval ssn with var-0 preds = true (y has p), var-1 preds = false (x doesn't have p), var-2 preds = true (t has p)
- sub_nf.2 ssn_bad = true
- Formula IS true at t=0 (Since finds y=0 with matching var-0 preds) but no x satisfies nf_eval_nf (ssn_bad's var-1 preds conflict with x having p)

**Fix**: Changed `if ssn_in_interval_right ssn then true` to also check
`ssn_x_pred_compat ssn nf_x && ssn_t_pred_compat ssn parent_atoms && ssn_xt_order_compat ssn sub_nf`.
Symmetrically for `nf_full_compat_left`.

**Forward proofs**: Rewritten with cleaner `by_cases hsub : sub_nf.2 ssn = true`
strategy. All sorry-free. Build passes.

### 2. Backward Proof Analysis

Identified the mathematical structure needed for the backward proof:

**What the formula provides** (after filter fix):
1. x with nf_eval_nf M (k+1) 1 (fun _ => x) nf_x (from char_kp1_correct)
2. For each positive interval ssn: y < x with nf_eval_nf M (k+1) 1 (fun _ => y) nf_y (from char_kp1)
3. Atom compatibility: ssn's var-0,1,2 preds match y,x,t respectively (filter + ssn_compat_var0')
4. nf_y.2 encodes depth-k 2-var NFs at (z,y) for all z

**What the backward proof needs** (h_quant for backward_2var_nf_agreement):
For each ssn : NormalForm sig k 3:
`(exists y, nf_eval_nf M k 3 (y,x,t) ssn) <-> sub_nf.2 ssn = true`

**The gap**: nf_eval_nf M k 3 (y,x,t) ssn at depth k >= 1 requires:
- Atoms at (y,x,t) match ssn.1 -- PROVABLE from items 1-3 above
- Quantifier part: for each sub4, (exists z, nf_eval_nf M (k-1) 4 (z,y,x,t) sub4) <-> ssn.2 sub4 = true -- REQUIRES COMPOSITION LEMMA

**Additionally**: the backward direction (exists y -> sub_nf.2 ssn = true) is unprovable because x (from the formula) might differ from x_0 (where sub_nf is the characteristic NF).

## BLOCKER: Composition Lemma (Feferman-Vaught for Linear Orders)

### Statement

For all k, the depth-k n-var NF of an environment is determined by all pairwise
depth-k 2-var NFs. Specialized to arity 3:

```
nf_characteristic M k 3 (y,x,t) is a pure function of:
  nf_characteristic M k 2 (y,x)
  nf_characteristic M k 2 (y,t)
  nf_characteristic M k 2 (x,t)
```

### Proof Strategy

By induction on k:
- k = 0: Atoms at (y,x,t) split into per-variable predicates (from any 2-var NF containing that variable) and order pairs (from the corresponding 2-var NF). Proven as `nf_composition_depth0`.
- k+1: Atoms same. Quantifiers: exists z with depth-k 4-var NF sub4 at (z,y,x,t). By IH at depth k for arity 4, the 4-var NF is determined by pairwise 2-var NFs. The 2-var NFs involving z are (z,y), (z,x), (z,t) -- which are recorded in nf_y.2, nf_x.2, and nf_t.2 respectively. The 2-var NFs among y,x,t are fixed. So exists z iff exists z' with matching pairwise NFs.

### References
- Doets 1989, Lemma 1.4/1.5 (composition preserves n-equivalence, no rank drop for named variables)
- Thomas 1997 (Feferman-Vaught theorem for linear orders)
- Rabinovich 2014, Section 5 (interval decomposition using composition)

### Why It's Hard

1. The induction on k requires a statement for ALL arities (k=0 for arity 3 needs composition at arity 3; k+1 for arity 3 needs composition at arity 4, etc.)
2. The "determined by" relationship requires defining a composition function that maps pairwise NFs to the n-var NF
3. The proof requires showing this function is correct (the composed NF is the actual characteristic NF)
4. In Lean, the type-level recursion (NormalForm sig k n at varying k and n) adds complexity

### Estimated Effort

The composition lemma is a substantial independent result requiring 200-500 lines of Lean code. It should be placed in a separate file (e.g., `NfComposition.lean`) and proven by induction on k with the arity-general statement.

## Current Sorry Inventory

1. **NegationClosure.lean:1364** -- `nf_exist_formula_nested_backward` sorry (the target)
2. **NfCharFormula.lean:572** -- downstream (closes when master_induction is sorry-free)
3. **KampPrior.lean:149** -- downstream (closes when master_induction is sorry-free)

## Immediate Next Action

1. State and prove the composition lemma in NfComposition.lean
2. Use it to complete the backward proof:
   - Forward direction of h_quant: extract y from Since, use composition to verify nf_eval_nf M k 3 (y,x,t) ssn
   - Backward direction of h_quant: show sub_nf.2 ssn matches the characteristic NF by using composition + the formula's encoding of all 2-var NFs via char_kp1

## Key Files

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean` (main file)
- `Theories/Bimodal/Metalogic/WeakCanonical/NormalForm.lean` (NF definitions, nf_eval_unique)
