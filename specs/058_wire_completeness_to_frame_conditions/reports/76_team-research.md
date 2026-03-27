# Team Research Report: Task #58 - Multi-BRS Consistency Problem

**Task**: 58 - wire_completeness_to_frame_conditions
**Date**: 2026-03-27
**Mode**: Team Research (4 teammates)
**Session**: sess_1774643329_dc0940
**Focus**: Alternative approaches for multi-BRS consistency when G-wrapping fails

---

## Executive Summary

All four teammates converge on a critical finding: **naive multi-BRS approaches are fundamentally blocked** by the gap between `F(psi) ∈ u` and `G(psi) ∈ u`. However, two promising alternative paths emerge:

1. **Greedy Extension (Approach 5)**: Build MCS incrementally, prove BRS elements always compatible with u-extensions
2. **Deferral Disjunction Replacement**: Replace bare `psi` with `psi ∨ F(psi)` which IS in u

**Recommendation**: Pursue the Greedy Extension approach first (requires compatibility lemma), with Deferral Disjunction as fallback.

---

## Key Findings

### Primary Finding: BRS is NOT Singleton (Teammate A)

**Evidence**: Counterexample construction
- For `phi = F(p) ∧ F(q)` with distinct atoms p, q
- BRS can contain both p and q simultaneously
- BRS bounded by |{F-formulas at depth boundary of closureWithNeg(phi)}|

**Implication**: Cannot avoid multi-BRS case by proving BRS is singleton.

### Fundamental Gap (All Teammates)

**The Core Problem**:
- For `psi ∈ BRS`: `F(psi) ∈ u` (given by BRS membership)
- We need `G(psi) ∈ u` for multi-BRS G-wrapping to work
- But `F(psi) = ¬G(¬psi)` tells us `G(¬psi) ∉ u`, NOT that `G(psi) ∈ u`
- These are independent claims

**Why G-Wrapping Fails for Multi-BRS**:
```
L = L_gc ∪ {psi_1, psi_2} where L_gc ⊆ g_content(u), psi_i ∈ BRS

1. Apply deduction to psi_2: L_gc ∪ {psi_1} ⊢ psi_2.neg
2. G-wrap: G(L_gc ∪ {psi_1}) ⊢ G(psi_2.neg)
3. BLOCKED: G(psi_1) ∉ u in general!
```

### Approaches Definitively Blocked (Teammate B, C)

| Approach | Why Blocked |
|----------|-------------|
| Subset Consistency | BRS ⊄ u by definition |
| Semantic (build model) | Circular - needs consistency to build model |
| Compactness | Just restates the problem |
| `proof_by_cases_bot` | Second branch `(psi.neg :: L_rest) ⊢ ⊥` is FALSE (psi.neg ∈ u) |
| Naive induction | G-wrapping breaks when L contains other BRS elements |
| Order independence | Structural issue, not ordering |
| Simultaneous G-wrapping | G(psi_i) ∈ u not derivable from F(psi_i) ∈ u |

### Promising Path 1: Greedy Extension (Teammate B)

**Key Insight**: BRS elements are DEFINED to be compatible via F-witnesses.

**Construction**:
```lean
def greedy_extension (u : Set Formula) (BRS : Finset Formula) : Set Formula :=
  BRS.fold (fun acc psi => if SetConsistent (acc ∪ {psi}) then acc ∪ {psi} else acc) u
```

**Required Lemma**:
```lean
lemma brs_element_compatible_with_extension (phi : Formula) (u : Set Formula)
    (h_mcs : DeferralRestrictedMCS phi u)
    (acc : Set Formula) (h_acc_ext : u ⊆ acc) (h_acc_cons : SetConsistent acc)
    (psi : Formula) (h_psi_brs : psi ∈ boundary_resolution_set phi u) :
    SetConsistent (acc ∪ {psi})
```

**Why This Should Work**:
- Any consistent extension of u is compatible with any BRS element
- Because: if adding psi would cause inconsistency, we could derive psi.neg from the extension
- But the extension is "G-closed" (contains g_content(u))
- G-wrapping would give G(psi.neg) ∈ u, contradicting F(psi) ∈ u

**Confidence**: MEDIUM-HIGH

### Promising Path 2: Deferral Disjunction Replacement (Teammates A, D)

**Key Insight**: For each BRS element psi, we have `psi ∨ F(psi) ∈ u`.

**Approach**:
1. Replace seed BRS component with deferral disjunctions: use `psi ∨ F(psi)` instead of bare `psi`
2. Since `psi ∨ F(psi) ∈ u`, consistency follows from u's consistency
3. Analyze whether successor construction still works with disjunctions

**Infrastructure Available**:
- `deferralDisjunctions_subset_deferral_restricted_mcs`: proves these are in u
- `or_elim_neg_neg` (Propositional.lean:1686): case analysis tool

**Challenge**: Does successor construction work if seed contains `psi ∨ F(psi)` rather than `psi`?

**Confidence**: MEDIUM

### Strong Induction Variant (Teammate C)

**IH**: For any L ⊆ seed with |L ∩ BRS| = k, if L ⊢ ⊥, then ∃L' ⊆ u with L' ⊢ ⊥.

**Gap**: The step case requires "hypothesis substitution" lemma:
```lean
-- If (psi :: Γ) ⊢ ⊥ and psi.neg ∈ u, show Γ ∪ {psi.neg} ⊢ ⊥
```

This is NOT trivially true. From `(psi :: Γ) ⊢ ⊥`, deduction gives `Γ ⊢ psi.neg`, but this doesn't give `Γ ∪ {psi.neg} ⊢ ⊥`.

**Confidence**: LOW (missing lemma)

---

## Synthesis

### Conflicts Resolved

No direct conflicts between teammates. Findings are complementary:
- Teammate A establishes BRS is not singleton
- Teammates B, C identify blocked approaches and viable alternatives
- Teammate D provides disjunctive reasoning infrastructure analysis

### Gaps Identified

1. **Compatibility lemma not proven**: Required for Greedy Extension approach
2. **Successor construction with disjunctions not analyzed**: Required for Deferral Disjunction approach
3. **Hypothesis substitution lemma missing**: Blocks Strong Induction approach

### Recommended Path Forward

**Primary (Greedy Extension)**:
1. Prove `brs_element_compatible_with_extension` lemma
2. Use greedy fold to build consistent seed
3. Apply Lindenbaum to get MCS

**Fallback (Deferral Disjunction)**:
1. Reformulate seed to use `psi ∨ F(psi)` instead of `psi`
2. Prove seed ⊆ u (automatic since disjunctions are in u)
3. Adapt successor construction to work with disjunctions

**Path C (Major Refactoring)**:
If both paths blocked, consider restructuring the Lindenbaum construction entirely:
- Start with u (consistent)
- Greedily add seed elements while maintaining consistency AND required properties
- Avoid proving seed consistency a priori

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Finding |
|----------|-------|--------|------------|-------------|
| A | BRS Cardinality | completed | high | BRS not singleton; `psi ∨ F(psi) ∈ u` for all BRS |
| B | Alternative Approaches | completed | medium | Greedy Extension most promising |
| C | Induction Strategies | completed | high | All naive schemes blocked; structural gap |
| D | Disjunctive Reasoning | completed | medium-high | `or_elim_neg_neg` available; combined approach 65% |

---

## Implementation Recommendation

### Immediate Next Steps

1. **Attempt Compatibility Lemma** (2-3 hours)
   ```lean
   lemma brs_element_compatible_with_extension (phi : Formula) (u : Set Formula)
       (h_mcs : DeferralRestrictedMCS phi u)
       (acc : Set Formula) (h_acc_ext : u ⊆ acc) (h_acc_cons : SetConsistent acc)
       (psi : Formula) (h_psi_brs : psi ∈ boundary_resolution_set phi u) :
       SetConsistent (acc ∪ {psi})
   ```

   **Proof sketch**:
   - Suppose L ⊆ acc ∪ {psi} with L ⊢ ⊥
   - If psi ∉ L: L ⊆ acc, contradicts acc's consistency
   - If psi ∈ L: L \ {psi} ⊢ psi.neg via deduction
   - G-wrap: G(L \ {psi}) ⊢ G(psi.neg)
   - Key: L \ {psi} ⊆ acc, and acc extends u, so "G-content" relationship should propagate
   - Need: G(chi) ∈ u for chi ∈ L \ {psi}

2. **If blocked**: Analyze deferral disjunction seed reformulation
   - Can successor construction use `psi ∨ F(psi)` instead of `psi`?
   - The successor needs to satisfy `psi` at next state - does disjunction suffice?

### Plan Update Recommendation

Create **Plan v17** with:
- Phase 1: Prove compatibility lemma
- Phase 2: Build seed via greedy extension
- Phase 3: Apply Lindenbaum and wire to completeness

OR

Create **Plan v17** with:
- Phase 1: Reformulate seed using deferral disjunctions
- Phase 2: Prove reformulated seed ⊆ u
- Phase 3: Adapt successor construction
- Phase 4: Wire to completeness

---

## References

### Codebase Files
| File | Lines | Content |
|------|-------|---------|
| SuccChainFMCS.lean | 1427-1575 | `single_brs_element_with_g_content_consistent` (Phase 1 PROVEN) |
| SuccChainFMCS.lean | 1646-1921 | `constrained_successor_seed_restricted_consistent` (TARGET) |
| SuccExistence.lean | 284-287 | `boundary_resolution_set` definition |
| WitnessSeed.lean | 79-177 | `forward_temporal_witness_seed_consistent` (template) |
| Propositional.lean | 1686 | `or_elim_neg_neg` (disjunction elimination) |
| RestrictedMCS.lean | 714 | `deferral_restricted_lindenbaum` |

### External Literature
- CMU Modal Logic Lectures - Completeness
- Open Logic Project - Completeness in Modal Logic
- Blackburn, de Rijke, Venema - Modal Logic (2001)

---

## Conclusion

The multi-BRS consistency problem is non-trivial but solvable. The fundamental gap (`F(psi) ∈ u` ≠ `G(psi) ∈ u`) blocks naive approaches, but two viable paths exist:

1. **Greedy Extension**: Prove BRS elements are always compatible with u-extensions
2. **Deferral Disjunction**: Reformulate seed to avoid needing bare BRS elements

Both paths require additional lemmas but are mathematically sound in principle. The team recommends pursuing Greedy Extension first due to its cleaner integration with existing infrastructure.
