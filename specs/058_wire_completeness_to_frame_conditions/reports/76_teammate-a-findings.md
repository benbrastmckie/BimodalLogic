# Teammate A Findings: BRS Cardinality Analysis

**Task**: 58 - Multi-BRS Consistency Problem
**Focus**: Prove/disprove that boundary_resolution_set is singleton or bounded
**Date**: 2026-03-27
**Session**: teammate_a_brs_cardinality

---

## Executive Summary

**BRS is NOT provably singleton**. Multiple BRS elements can exist simultaneously, bounded only by the number of F-formulas in `closureWithNeg(phi)`. However, I identified a **structural property** that may enable an alternative proof approach: BRS elements share a common "F-witness" structure in the MCS.

---

## Key Findings

### 1. BRS Definition Analysis

From `SuccExistence.lean` lines 284-287:

```lean
def boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
  {chi | Formula.some_future chi ∈ u ∧
         Formula.some_future (Formula.some_future chi) ∉ (deferralClosure phi : Set Formula) ∧
         Formula.some_future chi.neg ∉ u}
```

**Membership conditions**:
1. `F(chi) ∈ u` - u contains the F-obligation for chi
2. `F(F(chi)) ∉ deferralClosure(phi)` - chi is at the F-depth boundary
3. `F(chi.neg) ∉ u` - mutual exclusion (Fix A1)

### 2. BRS is NOT Provably Singleton

**Counterexample construction**:

Consider phi = F(p) ∧ F(q) for distinct atoms p, q.

- closureWithNeg(phi) contains: {phi, F(p), F(q), p, q, p.neg, q.neg, ...}
- F(p) and F(q) are both in closureWithNeg(phi)
- F(F(p)) and F(F(q)) are NOT in subformulaClosure(phi) - they weren't subformulas of phi
- Since deferralClosure = closureWithNeg ∪ deferralDisjunctions ∪ backwardDeferralSet:
  - F(F(p)) is not a deferral disjunction (wrong structure)
  - F(F(p)) ∉ deferralClosure(phi)
  - Similarly F(F(q)) ∉ deferralClosure(phi)

For a DeferralRestrictedMCS u that contains:
- F(p) but not F(p.neg)
- F(q) but not F(q.neg)

Both p and q satisfy the BRS membership conditions:
- F(p) ∈ u and F(q) ∈ u (condition 1)
- F(F(p)) ∉ deferralClosure and F(F(q)) ∉ deferralClosure (condition 2)
- F(p.neg) ∉ u and F(q.neg) ∉ u (condition 3)

Therefore: BRS(phi, u) = {p, q} - **two elements**.

**Confidence**: High. The construction is straightforward from definitions.

### 3. BRS Cardinality Upper Bound

BRS IS bounded, though not singleton:

**Bound**: |BRS(phi, u)| <= |{F(chi) : F(chi) ∈ closureWithNeg(phi), F(F(chi)) ∉ deferralClosure(phi)}|

This is bounded by the number of F-formulas at the "boundary" of closureWithNeg(phi), which is finite (bounded by |subformulaClosure(phi)|).

**Evidence** (`SubformulaClosure.lean`):
- `subformulaClosure` is a Finset (line 55)
- `closureWithNeg` is a Finset (line 90)
- `boundary_resolution_set_subset_deferralClosure` (lines 308-321) proves BRS ⊆ deferralClosure

### 4. Structural Property: F-Witness Coherence

Each BRS element chi has a **common structure** with respect to u:
- F(chi) ∈ u (positive F-obligation)
- G(chi.neg) ∉ u (since F(chi) = neg(G(chi.neg)) and u is consistent)

This means for ALL psi ∈ BRS:
- The implication `F(psi) → psi ∨ F(F(psi))` is a theorem
- But `psi ∨ F(psi)` (the deferral disjunction) IS in u by construction

**Key insight**: `psi ∨ F(psi) ∈ u` for each BRS element psi.

### 5. Alternative Proof Path: Deferral Disjunction Substitution

Instead of G-wrapping multiple BRS elements directly, consider:

For any derivation `L ⊢ ⊥` where L contains BRS elements {psi_1, ..., psi_k}:

1. Replace each BRS element psi_i with its deferral disjunction `psi_i ∨ F(psi_i)`
2. The deferral disjunctions are ALL in u
3. Use disjunction elimination: for each position, case split on psi_i vs F(psi_i)
4. In the F(psi_i) case, we have F(psi_i) ∈ u - continue derivation
5. This transforms the derivation to use only u-elements

**Challenge**: The case split creates 2^k branches. Need to show all branches lead to contradiction.

### 6. Why G-Wrapping Fails for Multi-BRS

From summary `17_g-wrapping-partial.md`:

The single-BRS proof works because:
- Deduction gives `L_filtered ⊢ psi.neg`
- G-wrapping gives `G(L_filtered) ⊢ G(psi.neg)`
- `G(psi.neg) ∈ deferralClosure` by subformula structure

The multi-BRS case fails because:
- Iterated deduction produces nested implications: `L_gc ⊢ psi_k → ... → psi_1 → ⊥`
- G-distribution produces: `G(L_gc) ⊢ G(psi_k → ...)`
- The nested G-implications `G(psi_k → G(...))` EXIT deferralClosure
- We cannot derive contradiction because these don't land in u

---

## Recommendations

### Option A: Prove BRS Cardinality Bound Directly

If we can prove |BRS| <= 1 or |BRS| <= 2 for specific formula structures, the multi-BRS problem simplifies.

**Investigation**: Check if there's a constraint from DeferralRestrictedMCS or deferralClosure structure that limits how many F-obligations can simultaneously be at the boundary.

**Status**: Initial analysis shows this is unlikely - the counterexample above is generic.

### Option B: Deferral Disjunction Replacement Strategy

**Approach**:
1. For L ⊆ seed with L ⊢ ⊥, partition L = L_u ∪ L_brs
2. For each psi ∈ L_brs, we have `psi ∨ F(psi) ∈ u`
3. Use proof by cases on each disjunction
4. In the psi-case: continue original derivation
5. In the F(psi)-case: F(psi) ∈ u, so accumulate into L_u part

**Challenge**: This produces an exponential case split (2^|L_brs| cases). Need to show all cases lead to ⊥.

### Option C: Re-examine F-depth Structure

The BRS boundary condition `F(F(chi)) ∉ deferralClosure` might have unexplored consequences.

**Investigation**: If F(chi) ∈ u with F(F(chi)) ∉ deferralClosure, then:
- chi ∈ subformulaClosure(phi) by `some_future_in_closureWithNeg_inner_in_subformulaClosure`
- F(chi) ∈ closureWithNeg(phi) by `some_future_in_deferralClosure_is_in_closureWithNeg`
- The set of such chi is exactly the "F-boundary" of closureWithNeg

Can we characterize this F-boundary set more precisely?

---

## File References

| File | Lines | Content |
|------|-------|---------|
| SuccExistence.lean | 284-287 | `boundary_resolution_set` definition |
| SuccExistence.lean | 289-300 | `mem_boundary_resolution_set_iff` |
| SuccExistence.lean | 308-321 | `boundary_resolution_set_subset_deferralClosure` |
| SubformulaClosure.lean | 649-650 | `deferralClosure` definition |
| SubformulaClosure.lean | 353-369 | `some_future_in_closureWithNeg_inner_in_subformulaClosure` |
| SubformulaClosure.lean | 919-936 | `some_future_in_deferralClosure_is_in_closureWithNeg` |
| SuccChainFMCS.lean | 1427-1575 | `single_brs_element_with_g_content_consistent` (Phase 1 proven) |

---

## Conclusion

**BRS is NOT provably singleton**. Multiple BRS elements can exist, bounded by the number of F-formulas at the depth boundary of closureWithNeg(phi). The multi-BRS consistency proof requires either:

1. A more sophisticated proof technique than direct G-wrapping
2. Leveraging the deferral disjunction structure (`psi ∨ F(psi) ∈ u` for each BRS element)
3. Finding an unexplored structural constraint that limits BRS cardinality

**Confidence Level**: High for the negative result (BRS is not singleton). Medium for the alternative approaches (need further investigation).
