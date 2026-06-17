# Task 303 Cycle 4 Handoff: Depth-k Until/Since Backward — Architectural Blocker

## Current State
- Phase 1: [COMPLETED] (mutual induction scaffold)
- Phase 2: [BLOCKED] (Until/Since backward at k > 0)
- Phases 3-6: [NOT STARTED] (dependent on Phase 2)
- 2 critical-path sorries: KampBypass.lean:356, 368
- 1 dependent sorry: KampMutualInduction.lean:310 (n >= 2 case)

## What Was Done This Cycle

Exhaustive depth-first analysis of the NF transfer chain to determine whether
the existing infrastructure can close the Until/Since backward sorries.

### Key Finding: Depth Gap is Unavoidable

The `nf_extend_fwd` theorem transfers depth-(K+1) r-var NF agreement to
depth-K (r+1)-var NF agreement. Each application LOSES one depth level.

For the Until backward proof, we need:
- `nf_eval_nf M (k'+1+1) 2 [x, t] sub_nf` (depth k'+1+1 = k'+2)

Starting from depth-(k'+2) 1-var agreement at [t] (from char_kp1 + parent_atoms):
1. nf_extend_fwd gives depth-(k'+1) 2-var agreement at [x, t]
2. From depth-(k'+1) 2-var agreement, nf_extend gives depth-k' 3-var agreement

But sub_nf.2 records depth-(k'+1) 3-var NF satisfiability, and we only have
depth-k' 3-var agreement. Off by one.

The chain extends recursively (depth-k' 3-var → depth-(k'-1) 4-var → ...),
terminating at depth 0. At each level, the agreement is one depth short of
what's needed for the evaluation transfer. The final level (depth 0) only
verifies atoms (no quantifier conditions), so depth-0 agreement suffices.
But the FIRST level is always one short, and this propagates.

### Why Previous Approaches Were Revisited and Confirmed Failed

1. **Compositionality** (1-var types + ordering → multi-var NF): FALSE.
   Counterexample: (Z,<) at depth 1, env (0,2) vs (0,1). Confirmed.

2. **ih_exist at constant parent**: ExistPart uses env `(fun _ => t)`.
   Until zone needs `[y, x, t]` where x ≠ t. Architectural limitation.

3. **NF transfer (nf_extend_fwd + nf_extend_bwd)**: Loses one depth level
   per extension. Cannot close the gap.

4. **nf_agreement_monotone**: Goes DOWNWARD (depth k → depth m for m ≤ k),
   not upward. Cannot bridge from depth-K agreement to depth-(K+1).

5. **exist_transfer_const_env**: Transfers depth-K 2-var existentials from
   depth-(K+1) 1-var agreement. We need depth-(K+1) 2-var transfer, requiring
   depth-(K+2) 1-var agreement — one more level than available.

### Root Cause

The ExistPart definition uses constant-parent environments `(fun _ => t)`.
This means all non-first variables in the existential are set to t.

For the Until zone at depth k'+1+1:
- Need `∃ y, nf_eval_nf M (k'+1) 3 [y, x, t] ssn` where x ≠ t
- ExistPart at n=2 gives `∃ y, nf_eval_nf M (k'+1) 3 [y, t, t] ssn`
- These are DIFFERENT environments (non-constant vs constant parent)

The eq zone (x = t) closes because `[y, x, t] = [y, t, t]` is constant-parent.
The Until/Since zones (x ≠ t) cannot use ExistPart directly.

## Proposed Resolution Paths

### Path A: Strengthen ExistPart to ExistPart_r (Recommended)

Replace the constant-parent ExistPart with a version that handles general parents:

```
ExistPart_r(k) := ∀ n ≥ 1, r ≥ 0,
  char_k_correct, parent_env : Fin r → NormalForm sig (k+1) 1,
  sub_nf : NormalForm sig k (n + r),
  ∃ A, ∀ M h_UZ h_SZ t,
    (∀ i, nf_eval_nf M (k+1) 1 (fun _ => t) (parent_env i)) →
    (temporal_truth M atomMap t A ↔
     ∃ x₁...xₙ, nf_eval_nf M k (n+r) (Fin.cons_many [x₁,...,xₙ] (fun _ => t)) sub_nf)
```

The parent env is STILL `(fun _ => t)` but the NF types of the parent elements
are constrained by `parent_env`. The formula A depends on these NF types.

This approach works because at depth k+1, the quantifier conditions involve
depth-k NFs with one more variable. The recursive call to ExistPart_r(k-1)
at r+1 parent variables handles the non-constant parent case by carrying
the NF types of ALL previously-quantified variables.

**Estimated scope**: ~500 lines restructuring of KampMutualInduction.lean and KampBypass.lean.

### Path B: Feferman-Vaught Composition Theorem

Prove directly: if two structures agree on interval types (via VecEA2-style
encoding), then they agree on multi-var NF evaluations.

Uses the existing NEquivalence.lean CompData/BiCompat infrastructure
reformulated for single-structure interval decomposition.

**Estimated scope**: ~1000+ lines, requires adapting ordered-sum machinery.

### Path C: Direct Formula Construction via Depth Recursion

Build the enriched formula by recursing on depth. At each depth level:
1. Decompose the 3-var existential by zone of y
2. Use char_k for y's 1-var type
3. For quantifier conditions at depth k', recurse to build formulas
   for the 4-var existentials at depth k'-1

The base case (depth 0) uses the existing k=0 infrastructure.

**Estimated scope**: ~800 lines new code, ~200 lines adaptation.

## Sorry Inventory

| File | Line | Statement | Why Deferred | Next Dispatch |
|------|------|-----------|-------------|---------------|
| KampBypass.lean | 356 | Until backward (k > 0) | Constant-parent limitation of ExistPart; NF transfer depth gap | Implement Path A, B, or C |
| KampBypass.lean | 368 | Since backward (k > 0) | Symmetric to Until | Resolved with Until |
| KampMutualInduction.lean | 310 | ExistPart(k+1) n >= 2 | Depends on n=1 being sorry-free | Auto-resolved |

## Immediate Next Action

Run `/revise 303` to create plan v4 implementing Path A (Strengthen ExistPart).
The key insight for Path A: keep the constant-parent env `(fun _ => t)` but
parameterize by the NF TYPES of the parent variables. The mutual induction
then carries these NF types through the recursion, enabling non-constant
parent handling without changing the evaluation point.

## Key Files
- KampBypass.lean:352-375 — Until/Since zone code with sorries
- KampBypass.lean:376-515 — Eq zone proof (sorry-free, reference for constant-parent approach)
- KampBypassUntil.lean — k=0 VecEA2 template (sorry-free)
- KampMutualInduction.lean — Mutual induction scaffold
- NormalForm.lean:339 — nf_agreement_monotone
- NormalForm.lean:33-51 — nf_extend_fwd/bwd

## Technical Constraints
- nf_extend_fwd/bwd: depth loss of 1 per application (unavoidable)
- nf_agreement_monotone: downward only (depth k → depth m for m ≤ k)
- exist_transfer_const_env: requires K+1 depth for K-depth transfer
- Compositionality: FALSE on Prior structures (counterexample confirmed)
