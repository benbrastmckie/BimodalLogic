# Phase 8 Handoff: Reconstruction Depth Infrastructure

## Immediate Next Action
Phase 9: Make `nf_extend_bwd` accessible from PriorComposition.lean, then use it with
`reconstruction_depth_agree` to close the zone-3 sorry.

## Current State
- Phase 8 completed. 3 new sorry-free theorems in PriorComposition.lean.
- Sorry count: 4 (lines 449, 454, 505, 509) -- pre-existing, unchanged.
- Build: `lake build PriorComposition` succeeds (988 jobs).
- KampBypass: still 0 sorry.

## Key Decisions

### Deviation from plan: depth-0 density lemma is FALSE
The planned `depth0_exist_transfer` (depth-0 Prior density lemma with 1-var agreements
at endpoints + order matching) is FALSE as a standalone lemma. Confirmed by report 15
counterexample (Z with P=evens, t=-1, x=4, t'=-1, x'=0). The UZ/SZ squeeze fails when
both cross_extend witnesses are outside the target zone.

### Correct mechanism: exist_transfer_from_full_agree
Instead, existential transfer follows from the quantifier condition of depth-(K+1) full
agreement + monotonicity. No Prior-UZ/SZ needed for the algebraic transfer. This subsumes
the planned depth-0 density for K >= 1.

### Impact on Phase 9
`reconstruction_depth_agree` REPLACES the planned Phase 9 "inner reconstruction induction."
The inner induction is already proved. Phase 9 now simplifies to:
1. Make `nf_extend_bwd` accessible (visibility change or local reproduction)
2. Use ih_strong at m=K-1 to get depth-(K+1) 2-var at [x,t]/[x',t']
3. Quantifier unfolding gives w_nf with depth-K 3-var full agreement
4. Apply `reconstruction_depth_agree` to upgrade to depth-(K+1) 3-var
5. Extract nf_eval_nf N (K+1) 3 [w_nf,x',t'] sub_nf

### K=0 edge case
At K=0, ih_strong is vacuous. `reconstruction_depth_agree` requires K >= 1 (needs quantifier
condition of depth-(K+1) agreement, which at K=0 means depth-1, requiring depth-0 existential
transfer that IS the density problem). K=0 needs separate treatment in Phase 10.

## Sorry Inventory
| File | Line | Statement | Assumption | Why Deferred | Next Dispatch |
|------|------|-----------|------------|--------------|---------------|
| PriorComposition.lean | 449 | prior_nonconstenv_2var_agree_until (fwd) | w₂ satisfies sub_nf at [w₂,x',t'] | Zone-3 requires ih_strong + reconstruction | Phase 9-10: apply reconstruction_depth_agree |
| PriorComposition.lean | 454 | prior_nonconstenv_2var_agree_until (bwd) | w₂ satisfies sub_nf at [w₂,x,t] | Symmetric to fwd | Phase 9-10 |
| PriorComposition.lean | 505 | prior_nonconstenv_2var_agree_since (fwd) | w₂ satisfies sub_nf at [w₂,x',t'] | Since mirror | Phase 9-10 |
| PriorComposition.lean | 509 | prior_nonconstenv_2var_agree_since (bwd) | w₂ satisfies sub_nf at [w₂,x,t] | Symmetric | Phase 9-10 |

## Theorems Proved
| Name | File | Lines | Purpose |
|------|------|-------|---------|
| exist_transfer_from_full_agree | PriorComposition.lean | ~40 | Existential transfer at depth d ≤ k from depth-(k+1) full agreement |
| depth0_agree_from_higher | PriorComposition.lean | ~8 | Depth-0 agreement from higher depth (monotonicity) |
| reconstruction_depth_agree | PriorComposition.lean | ~40 | Full reconstruction induction: d ≤ K+1 agreement from depth-(K+1) |
