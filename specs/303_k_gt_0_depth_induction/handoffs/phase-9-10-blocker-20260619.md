# Phase 9-10 Blocker: Depth Gap Is Irreducible

## Immediate Next Action
Research and design a new proof technique to bridge the zone-3 depth gap.
The gap is: need depth-(K+1) 3-var existential transfer, have only depth-K 3-var.

## Current State
- Phase 8 completed (3 sorry-free theorems: reconstruction_depth_agree, exist_transfer_from_full_agree, depth0_agree_from_higher).
- Sorry count: 4 (unchanged at lines 449, 454, 505, 509).
- Build: `lake build PriorComposition` passes.
- Phase 9-10 BLOCKED: the depth gap cannot be bridged by existing infrastructure.

## Key Finding

**The Phase 8 handoff claim that "reconstruction_depth_agree upgrades depth-K to depth-(K+1)" is INCORRECT.** Detailed type-level analysis confirms:

- `reconstruction_depth_agree` takes depth-(K+1) as INPUT and produces d <= K+1 at SAME arity. It cannot produce depth-(K+1) from depth-K.
- `exist_transfer_from_full_agree` takes depth-(k+1) (n+1)-var agreement and produces depth-d (n+2)-var existential transfer for d <= k. With ih_strong giving depth-(K+1) 2-var: d <= K at arity 3. Goal needs d = K+1.
- `generalExistPart_from_classical` needs the CONCLUSION (depth-(K+2) 2-var) as precondition. Circular.
- The cascade structure (depth K -> K-1 -> ... -> 0) terminates at depth 0 (atomic) but we cannot build back up because each step of nf_extend_bwd drops exactly 1 depth.

## The Exact Obstacle

In the forward direction of the Until case (line 449):

```
Context:
  ih_strong : forall m < K, forall nf : NF (m+2) 2, M [x,t] nf <-> N [x',t'] nf
  sub_nf : NF (K+1) 3
  w : M.carrier
  hw : nf_eval_nf M (K+1) 3 [w,x,t] sub_nf
  
Goal: exists w', nf_eval_nf N (K+1) 3 [w',x',t'] sub_nf
```

From ih_strong at m=K-1: depth-(K+1) 2-var at [x,t]/[x',t'].
Quantifier condition -> depth-K 3-var existential transfer at [_,x,t]/[_,x',t'].
Take nf_char M K 3 [w,x,t] -> get w_nf with depth-K 3-var full agreement.
w_nf is in zone 3 (t' < w_nf < x') by atom preservation.

To prove `nf_eval_nf N (K+1) 3 [w_nf,x',t'] sub_nf`:
- Atoms: OK (from depth-K 3-var agreement).
- Quantifiers: for chi4 : NF K 4, need `(exists v, M K 4 [v,w,x,t] chi4) <-> (exists v', N K 4 [v',w_nf,x',t'] chi4)`.

This requires `exist_transfer_from_full_agree` with depth-(K+1) 3-var at [w,x,t]/[w_nf,x',t'] — which is EXACTLY what we're trying to prove.

## Five Approaches Exhausted

1. **exist_transfer_from_full_agree with ih_strong**: Gives d<=K at arity 3. Need K+1.
2. **reconstruction_depth_agree with depth-K 3-var**: K_param=K-1, output d<=K. Identity.
3. **reconstruction_depth_agree with depth-(K+1) 2-var**: Wrong arity (output stays 2-var).
4. **generalExistPart_from_classical**: Needs depth-(K+2) 2-var (the conclusion). Circular.
5. **Compose hw2 + ih_strong**: Different environments, cannot produce 3-var at needed env.

## Recommended Resolution Paths (from Report 18, Section 12)

### Path A: Inner Depth Induction (Most Promising)
Write `zone3_inner_cascade` proving existential transfer at each depth level 0..K+1 by induction on d, with arity increasing as (K+4-d):
- Base (d=0, arity K+4): Purely atomic. Prior-UZ/SZ density for finding points with specific predicates+orders in each zone.
- Step (d+1 from d): Atoms from component-wise 1-var agreement. Quantifiers from inner IH at level d.

Challenge: at each step, the "nf_extend_bwd" from higher depth to lower depth at higher arity provides MATCHED WITNESSES at one lower depth. The inner IH then handles the lower depth. But establishing matched witnesses at arbitrary arity requires extending from the 2-var ih_strong hypothesis repeatedly, which may need the cascade itself.

Estimated difficulty: 600-1200 lines.

### Path B: Joint Depth+Arity Induction
Restructure the theorem to prove `forall d r, [conditions] -> depth-d r-var agreement` by well-founded induction on (d, r) with lexicographic order.

Challenge: requires significant restructuring of existing code.

### Path C: Prior Uplift Theorem
Prove: on Prior structures, depth-K r-var + depth-(K+1) 1-var per component + Prior-UZ/SZ implies depth-(K+1) r-var.

Challenge: this IS the theorem being proved (at r=2) and the generalization (at r=3) has the same circular structure.

## References
- Report 18, Sections 3-12: Full analysis of depth gap structure
- Report 19, Section 7.8: Corrected proof strategy (w_nf in zone 3 via atom preservation)
- Phase 8 handoff: reconstruction_depth_agree infrastructure
