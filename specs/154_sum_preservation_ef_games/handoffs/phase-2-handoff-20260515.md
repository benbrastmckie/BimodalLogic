# Phase 2 Handoff: BiCompat Construction Analysis

**Task**: 154 - sum_preservation_ef_games
**Session**: sess_1778902351_5b9a77
**Phase**: 2 (PARTIAL)
**Date**: 2026-05-15

## Summary

Phase 2 is partial. Added `extend_atoms` helper (sorry-free, ~30 lines) that derives ordered-sum atom agreement for extended environments. The main blocker remains: constructing `BiCompat sig k 1 I ms ms' (![<i,a>]) (![<i,b>])`.

## What Was Completed

### `extend_atoms` helper (sorry-free, ~line 228)

Derives ordered-sum atom agreement at n+1 vars from:
- h_atoms (existing atom agreement at n vars)
- h_pred (predicate agreement for new element c/c')
- h_ord_fwd (forward order: c < env_M k iff c' < env_N k)
- h_ord_bwd (backward order: env_M k < c iff env_N k < c')
- h_idx (index matching for existing elements)

Key finding: BOTH order directions (h_ord_fwd AND h_ord_bwd) are required. In a linear order, `a < b <-> a' < b'` does NOT imply `b < a <-> b' < a'` due to equality cases.

## What Remains: BiCompat Construction

### Core Problem

Need `BiCompat sig k 1 I ms ms' (![<i,a>]) (![<i,b>])`. BiCompat at depth d+1 with n vars requires forward and backward oracle producing witnesses c/c' with:
1. Atom agreement at n+1 vars (use extend_atoms)
2. Recursive BiCompat at depth d with n+1 vars

The atom agreement requires same-component order atoms, which need multi-var component NF agreement. This agreement comes from `component_extend_fwd/bwd` (already proved sorry-free). But applying it requires knowing the per-component NF state -- which elements of env are in each component and their current NF agreement level.

### Recommended Approach: build_bicompat with CompNFState

Define a per-component NF state predicate:
```
CompNFState j := exists (r : Nat) (eM : Fin r -> (ms j).carrier) (eN : Fin r -> (ms' j).carrier),
  (projection_consistency) /\
  (forall nf : NormalForm sig (budget - r) r, nf_eval_nf (ms j) ... eM nf <-> nf_eval_nf (ms' j) ... eN nf)
```

Budget invariant: d + n is constant through recursion. For component j with r elements: NF depth = budget - r.

Prove `build_bicompat : forall d n, h_comp -> h_idx -> h_atoms -> (forall j, CompNFState j) -> BiCompat sig d n ...` by induction on d.

At each oracle call for component j:
1. Extract CompNFState j to get current NF agreement
2. Use component_extend_fwd/bwd to find witness c/c' with extended NF agreement
3. Derive h_pred from extended NF via atom_agreement_from_nf
4. Derive h_ord_fwd, h_ord_bwd from extended NF (same-component: from NF; cross-component: from h_idx)
5. Apply extend_atoms to get atom agreement at n+1 vars
6. Update CompNFState for the extended environment
7. Apply IH with updated CompNFState

### Initial CompNFState at sorry sites

For the initial call (d=k, n=1, env = ![<i,a>], ![<i,b>]):
- Component i: r=1, eM = ![a], eN = ![b], NF agreement from h_agree_comp (depth k, 1 var)
- Other components j != i: r=0, eM = eN = Fin.elim0, NF agreement from h_comp at depth k+1 (sentence equiv)

### Implementation Challenges

1. Projection formalization: dependent type casts between (ms (env_M k).1).carrier and (ms j).carrier
2. Fin reindexing when building projected environments
3. Maintaining projection consistency through Fin.cons extensions

## File State

- NEquivalence.lean: 4 sorries in sum_nf_agree_sentence (unchanged locations). New extend_atoms (sorry-free).
- lake build passes.

## Key Files

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/WeakCanonical/NormalForm.lean`
