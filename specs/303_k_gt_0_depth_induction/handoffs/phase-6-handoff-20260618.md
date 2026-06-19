# Phase 6 Handoff: PriorComposition Sorry Analysis

## Current State
- PriorComposition.lean: 4 sorry (lines 264, 285, 336, 354)
- KampBypass.lean: 0 sorry
- Build passes

## Key Finding: Circularity in Decomposition Approach

The natural approach of "prove depth-1 2-var at [x,t]/[x',t'] first, then use its quantifier part for the depth-1 3-var transfer" is **circular**:

1. Depth-2 2-var at [x,t]/[x',t'] requires depth-1 3-var existential transfer (the sorry goal)
2. Depth-1 3-var transfer can be obtained from depth-1 2-var quantifier part
3. Depth-1 2-var at [x,t]/[x',t'] requires depth-0 3-var existential transfer
4. Depth-0 3-var existential transfer for zone 3 (between-zone) is **NOT independently provable** from endpoint 1-var agreements

### Why Zone 3 at Depth 0 Fails Independently

The between-zone condition `exists w in (t,x) with predicates P` does NOT transfer between Prior structures from h_x and h_t alone:

- From h_x: `exists u < x with P` transfers to `exists u' < x' with P`
- From h_t: `exists u > t with P` transfers to `exists u' > t' with P`
- But `exists w in (t,x) with P` requires BOTH conditions at a SINGLE point
- The conjunction is NOT guaranteed by Prior-UZ/SZ squeeze because:
  - The P-points above t' might all be >= x'
  - The P-points below x' might all be <= t'
  - This is compatible with the hypotheses (counterexample on Z with endpoints 0,1)

## Correct Approach

The depth-2 2-var agreement must be proved **all at once**, not decomposed into lower-depth steps.

### For K=0 (line 264): Depth-1 3-var transfer

The goal after `rw [<- h_N_quant sub_nf]` is:
```
(exists w, nf_eval_nf M 1 3 [w,x,t] sub_nf) <-> (exists w', nf_eval_nf N 1 3 [w',x',t'] sub_nf)
```

sub_nf is a depth-1 3-var NF = atoms + depth-0 4-var quantifiers.

**Proposed proof strategy**: Prove by STRONG induction on depth d simultaneously with the 2-var agreement, parametrized by arity n. Specifically, prove:

```
P(d) := forall n, forall matching-envs of arity n,
  (exists w, eval M d (n+1) [w, env_M] sub_nf) <-> (exists w', eval N d (n+1) [w', env_N] sub_nf)
```

with P(d) following from P(d-1) at higher arity.

At d=0: the existential is purely atomic. The transfer follows from:
- Boundary zones (w = ref point): determined by ref point predicates (which match)
- Extreme zones (w < all or w > all): from the nearest ref point's depth-1 1-var quantifier part
- Interior zones (w between adjacent ref points): **requires the depth-1 2-var agreement at the two adjacent ref points**, which IS the full theorem applied at lower depth. This is NOT circular if we do strong induction on the TOTAL depth D = K+2: at D=2, the quantifier at depth 1 needs P(0), which requires the theorem at depth 1 (D=1), which is weaker.

So the correct proof structure is:

1. Restructure `prior_nonconstenv_2var_agree_until` to use strong induction on D = K+2 rather than simple induction on K
2. At D, the quantifier part asks about depth-(D-1) 3-var transfers
3. The depth-(D-1) 3-var transfer uses cross_extend to get candidates
4. The depth-(D-2) quantifier conditions at the candidate transfer via P(D-2)
5. P(D-2) is available from the IH (strong induction on D)

### For K=succ K' (line 285): Same structure but with IH

The IH at K' gives depth-(K'+2) 2-var agreement. The goal needs depth-(K'+2) 3-var transfer (one arity higher). The approach is the same: use the IH's 2-var agreement to transfer the lower-depth components, and cross_extend + zone analysis for the witness construction.

## Available Infrastructure

- `cross_extend_bwd_1var`: From depth-(K+1) 1-var, get depth-K 2-var for any witness
- `nf_skipIdx_cross`: Project from (n+1)-var to n-var agreement
- `cross_2nd_1var_from_2var`: Extract 1-var from 2-var
- `nonconstenv_atom_agree_until/since`: Atom part (sorry-free)
- `depth0_3var_witness_check`: Verify depth-0 3-var NF match (sorry-free)
- `semantic_prior_UZ/SZ`: Prior axioms
- `char_fn/char_correct`: Temporal formula characterization at depth d <= K+1
- `nf_characteristic/nf_characteristic_satisfies/nf_agreement_from_shared_nf`: NF matching

## Immediate Next Action

Restructure the induction in `prior_nonconstenv_2var_agree_until` to use strong induction on the total depth D = K+2, replacing `induction K` with a stronger scheme that provides the theorem at all lower depths. This eliminates the circularity because the depth-0 between-zone transfer becomes provable from the theorem at depth 1 (available from the IH).

## Sorry Inventory

All 4 sorry unchanged from dispatch start:
1. Line 264: K=0 Until quantifier part
2. Line 285: K=succ K' Until quantifier part  
3. Line 336: K=0 Since quantifier part (mirror of 264)
4. Line 354: K=succ K' Since quantifier part (mirror of 285)
