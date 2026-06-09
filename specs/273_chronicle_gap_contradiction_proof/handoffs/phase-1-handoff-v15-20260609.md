# Phase 1 Handoff: nvar_nf_agreement_from_pointwise [BLOCKED]

## Session
- Session ID: sess_1781041262_9e760a
- Date: 2026-06-09
- Phase: 1 of 4
- Status: BLOCKED

## Summary

Phase 1 is blocked by a fundamental circularity in the proposed proof approach. The plan's `nvar_nf_agreement_from_pointwise` lemma cannot be proved using the existing infrastructure (`nf_fraisse_compression` + `existential_transfer_from_nf`) because these two lemmas create an irreducible circularity at each positive depth level.

## Circularity Analysis

The sorry sites at StaviCompleteness.lean lines 2405 and 2487 require:
```
(exists w, nf_eval_nf M' j' 4 (w::u'::x'::t') sub_nf) <->
(exists w, nf_eval_nf M j' 4 (w::u::x::t) sub_nf)
```

This is 4-var existential transfer at depth j' for the 3-point context (u,x,t)/(u',x',t').

To prove this via `existential_transfer_from_nf`, we need depth-(j'+1) 3-var NF agreement. To prove THAT via `nf_fraisse_compression`, we need 4-var existential transfer at depth j' -- the very thing we're proving. This circularity holds for ALL positive depths.

### Approaches Tried (All Failed)

1. **Simple induction on d**: Circular at quantifier step
2. **Strong induction (Nat.strongRecOn)**: Same circularity -- IH covers m < d'+1, but transfer at d' needs NF at d'+1
3. **nf_agreement_monotone bootstrap**: Requires depth-k n-var NF agreement as INPUT
4. **Chain approach** (1-var -> 2-var -> 3-var -> 4-var): Loses too many depth levels (3 for 4-var)
5. **Direct construction**: Zone_match for (x,t) doesn't control orderings relative to u'

### Root Cause

The code's own comments (lines 2258-2261) describe the resolution: "interval-splitting zone match" where Duplicator's response point is chosen to SPLIT the interval types consistently. This preserves sub-interval structure at the cost of one depth level, enabling depth-recursive application. This is GHR93 Proposition 7's game strategy.

## What Is Needed to Unblock

A new lemma (estimated 200-300 lines): "interval-splitting zone match" that given u in interval(x,t) finds u' in interval(x',t') preserving:
- (a) depth-k 1-var NF type
- (b) orderings relative to x',t'
- (c) interval_nf_types M (k-1) x u = interval_nf_types M' (k-1) x' u'
- (d) interval_nf_types M (k-1) u t = interval_nf_types M' (k-1) u' t'

With this lemma, the sorry sites can be closed by strong induction on depth j, using interval-splitting at each step (cost: -1 depth) and bottoming out at depth 0 where atoms suffice.

## Key Signatures Verified

- `existential_transfer_from_nf`: requires depth-(d+1) n-var NF agreement, produces depth-d (n+1)-var existential transfer (NFGameBridge.lean:719, NOT imported by StaviCompleteness.lean)
- `nf_fraisse_compression`: requires atoms + transfer at all j < k, produces depth-k NF agreement (StaviCompleteness.lean:2006)
- `nf_agreement_monotone`: depth-k n-var -> depth-m n-var for m <= k (NormalForm.lean:339)
- `nf_agreement_from_shared_nf`: shared NF -> full NF agreement (NormalForm.lean:291)
- `interval_nf_types_depth_decrease`: depth-(k+1) interval agreement -> depth-k (StaviCompleteness.lean:1904)

## Next Action

A new research cycle is needed to design the interval-splitting zone match proof. The mathematical content is well-understood (GHR93 Proposition 7), but the Lean formalization requires careful design to avoid the circularity. The key insight is that interval-splitting reduces depth by 1 at each arity step, enabling well-founded recursion on depth.
