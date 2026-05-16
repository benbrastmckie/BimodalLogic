# Phase 2 Handoff: sum_nf_agree Bootstrap Approach

**Date**: 2026-05-15
**Session**: sess_1778894121_969219
**Status**: BLOCKED at lifting step (4 sorries remain)
**File Modified**: `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean`

## What Was Done

1. Replaced the original `sum_nf_agree` (arbitrary n, with `h_atoms`/`h_elem` hypotheses) and `sum_preservation_proof` with:
   - `atomKind_zero_elim`: helper proving `AtomKind sig 0` is empty
   - `sum_nf_agree_sentence`: sentence-level (n=0) bootstrap proof by induction on k
   - Simplified `sum_preservation_proof`: now delegates directly to `sum_nf_agree_sentence`

2. The file builds successfully with 4 sorries (down from 4 sorries + elaboration errors in the original).

3. All 4 sorries are at the same logical location: after finding `a` and `b` with matching depth-k 1-var component NFs via the component (k+1)-equivalence transfer, we need to show the ordered-sum 1-var NF transfer.

## Current State

### Goal at each sorry
```
sig : MonadicSignature
k : Nat
ih_k : ordered-sum sentence-level agreement at depth k (from IH)
h_comp : component agreement at depths <= k+1
i : I
a : (ms i).carrier
b : (ms' i).carrier
h_agree_comp : component depth-k 1-var NF agreement between a and b
hb_eval : nf_eval_nf (orderedSum ms') k (0+1) (Fin.cons ⟨i,b⟩ Fin.elim0) sub_nf
|- exists x, nf_eval_nf (orderedSum ms) k (0+1) (Fin.cons x Fin.elim0) sub_nf
```

The natural witness is `⟨i,a⟩`. To show it satisfies `sub_nf`, we need to show the ordered-sum depth-k 1-var NFs of `⟨i,a⟩` (in orderedSum ms) and `⟨i,b⟩` (in orderedSum ms') are equal.

### The Blocker: 2-var Transfer Gap

The lifting lemma (showing `⟨i,a⟩` and `⟨i,b⟩` have the same ordered-sum 1-var NF) works at depth 0 (pred-only atoms at n=1). But at depth k+1, the quantifier step requires showing 2-var existential transfer at depth k. This requires finding witnesses that preserve not just individual NFs but JOINT 2-var NFs including order atoms.

The fundamental issue: 1-var component NF matching doesn't determine relative order between specific elements. Two elements with the same 1-var NF can be in either relative order.

## Proposed Solution Path

A well-founded recursive proof by induction on depth `d`, simultaneously handling all variable counts:

1. At depth 0 with any n vars: verify atoms directly (pred from component matching, cross-component order from index comparison, same-component order from component multi-var transfer at depth 0).

2. At depth d+1: verify atoms (same as depth 0), then for the quantifier part, find witnesses using INDEX-PRESERVING component transfer (not ordered-sum transfer). For same-component witnesses, use the component's multi-var quantifier transfer (derived by chaining from the component's equivalence). Apply the IH at depth d with n+1 vars.

3. The chain: from component (K+1)-equivalence, extract 1-var transfer at depth K. Given element `a`, find `b` with same 1-var NF. From shared 1-var NF, extract 2-var transfer at depth K-1. Given pair `(a, c)`, find `(b, c')` with same 2-var NF. Continue: at each step, depth decreases by 1, vars increase by 1. After K steps, reach depth 0 where atoms (including order) can be verified.

4. The key is finding witnesses via component MULTI-var transfer (preserving the index and order relative to all previously-chosen same-component elements), not 1-var transfer.

## Immediate Next Action

Implement the well-founded recursive lifting function `sum_nf_lift` that proves ordered-sum NF agreement for environments constructed by iterated component multi-var transfer, by induction on the NF depth. The function should:

1. Take depth `d`, var count `n`, environments, index matching, and component matching hypotheses.
2. At d=0: verify atoms directly (pred + order).
3. At d+1: verify atoms, then for the quantifier step, find witnesses via component multi-var transfer and apply the IH at depth d.

The main formalization challenge is encoding the "component multi-var transfer" condition in Lean's type system (variable-length sub-environments restricted to a single component).

## Key Decisions Made

1. Dropped the original `sum_nf_agree` approach (arbitrary n with `h_atoms`/`h_elem` hypotheses) in favor of the sentence-level bootstrap.
2. The bootstrap avoids order atoms at the TOP level (n=0) but encounters them at the quantifier step level (n=2).
3. The order atom problem is fundamental to the NF approach and requires multi-var component transfer, not just 1-var.

## Files Changed

- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean`: Replaced `sum_nf_agree` + `sum_preservation_proof` with `atomKind_zero_elim` + `sum_nf_agree_sentence` + simplified `sum_preservation_proof`. 4 sorries remain at the lifting step.
