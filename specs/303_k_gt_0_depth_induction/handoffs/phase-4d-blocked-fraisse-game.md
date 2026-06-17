# Phase 4d Handoff: Blocked — Fraisse Game Argument Required

## Status

Phase 4d BLOCKED. The 4 remaining sorry in PriorComposition.lean require fundamental new
infrastructure (Fraisse game argument) estimated at 400-600 lines.

## Current State

- KampBypass.lean: 0 sorry (sorry-free since Phase 4b)
- PriorComposition.lean: 4 sorry (unchanged from Phase 4c)
- Full `lake build` passes

## Analysis Summary

### The Core Problem

`exist_transfer_3var_nonconstenv` must prove: given depth-(K+2) 1-var agreement at x/x' and
t/t', plus depth-(K+1) 2-var agreement at [x,t]/[x',t'], derive depth-(K+1) 3-var existential
transfer at [_,x,t]/[_,x',t'].

### Why It's Hard

1. **Depth-boost circularity**: To prove depth-(K+1) 3-var, need depth-K 4-var existential
   transfer. To get depth-K 4-var, need depth-(K+1) 3-var agreement. Circular.

2. **Between-zone order transfer**: The proof finds witness c with depth-(K+1) 2-var at
   [y,x]/[c,x'] (from h_x's quantifier part) and c_K with depth-K 3-var at
   [y,x,t]/[c_K,x',t'] (from h_xt's quantifier part). Cannot prove c < t' iff y < t
   because same 1-var NF type does NOT determine relative order to a third point.

3. **Counterexample context**: The theorem IS false on general linear orders (confirmed by
   NfComposition.lean counterexample at env [0,2] vs [0,1] in Z). It is TRUE on Prior
   structures, so the proof MUST use Prior axioms explicitly.

### Why Prior Axioms Are Needed

On general linear orders, two points with the same 1-var NF type can be on different sides
of a third point. The Prior axioms (UZ/SZ = Dedekind completeness for NF types) guarantee:
if a point with a certain NF type exists in an interval in M, then a matching point exists
in the corresponding interval in N.

The connection mechanism:
- `atomMap` maps Formula -> sig.preds (connects formulas to predicates)
- `temporal_truth M atomMap s (.atom a) = M.interp (atomMap (.atom a)) s`
- `char_kp1_correct`: temporal_truth of characteristic formula iff NF type matches
- Prior-UZ/SZ: if temporal_truth holds somewhere above t, there's a FIRST occurrence

### Recommended Approach for Next Dispatch

**Option A** (Preferred — minimal structural change):
1. Add `atomMap`, `h_UZ_M/N`, `h_SZ_M/N`, `h_order_M/N` to `exist_transfer_3var_nonconstenv`
2. Restructure proof by STRONG INDUCTION on K within the theorem
3. At K=0 (depth-1 3-var): atoms from h_3var_K (depth-0). Quantifiers at depth 0 are
   purely-atomic (n+1)-var existentials. Transfer by zone decomposition:
   - Outside zones: cross_extend_bwd_1var + order transitivity
   - Between-zone: use char_kp1_correct to express w's type as temporal formula.
     Apply Prior-UZ on N with that formula at t'. Get first occurrence s0 > t'.
     Show s0 < x' using h_x quantifier info (x' satisfies a formula whose first
     occurrence must be at or before x').
4. At K>0: use IH at K-1 for the quantifier boost (depth-K (n+1)-var transfer from
   depth-K n-var + depth-(K+1) 1-var)

**Option B** (More general — enables future reuse):
1. Prove a general `fraisse_game_transfer` lemma that simultaneously establishes n-var
   existential transfer for all n, by strong induction on K
2. Use this in prior_nonconstenv_2var_agree_until/since directly

### Key Files

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` — target file
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampComposition.lean` — cross_extend_bwd_1var
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` — char_kp1_correct usage
- `Theories/Bimodal/Metalogic/WeakCanonical/PriorDefs.lean` — semantic_prior_UZ/SZ
- `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean` — temporal_truth definition

### Key Lemmas Available

- `cross_extend_bwd_1var`: from depth-(K+1) 1-var, find witness with depth-K 2-var
- `nf_extend_bwd/fwd`: from depth-(K+1) r-var, find witness with depth-K (r+1)-var
- `nf_agreement_from_shared_nf`: shared NF implies full agreement at that depth
- `nf_agreement_monotone`: depth-k agreement from depth-m (m >= k) agreement
- `pred_agree_cross`: predicate agreement from 1-var NF agreement
- `nf_skipIdx_cross`: (n+1)-var agreement projects to n-var along any skipIdx j

## Immediate Next Action

Read this handoff, then implement Option A starting with adding Prior hypotheses to
`exist_transfer_3var_nonconstenv` and restructuring as induction on K.
