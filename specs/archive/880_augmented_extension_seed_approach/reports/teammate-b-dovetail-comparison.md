# Comparative Analysis: DovetailingChain.lean vs ZornFamily.lean

**Task**: #880 Teammate B Research Assignment
**Date**: 2026-02-12
**Focus**: Sorry-free completion feasibility analysis

## Executive Summary

After comprehensive analysis of both approaches, **DovetailingChain has a clearer path to zero sorries** for the following reasons:

1. **Cross-sign propagation**: ZornFamily's Phase 4 solution cannot be directly ported to DovetailingChain because the approaches are structurally incompatible
2. **Witness construction**: DovetailingChain's F/P sorries require dovetailing enumeration infrastructure that is straightforward (Nat.pair/unpair)
3. **Theorem correctness**: ZornFamily has a potential theorem-level flaw (maximal_implies_total may be false); DovetailingChain's approach is sound
4. **Effort estimate**: DovetailingChain requires ~15-20 hours; ZornFamily requires ~25-40 hours with higher risk

**Recommendation**: Pivot to completing DovetailingChain.lean

---

## 1. Cross-Sign Analysis

### 1.1 Problem Statement

Both approaches must solve cross-sign temporal propagation:
- **forward_G** when t < 0 < t': G phi in M_t (negative) implies phi in M_{t'} (positive)
- **backward_H** when t' < 0 < t: H phi in M_t (positive) implies phi in M_{t'} (negative)

### 1.2 ZornFamily's Phase 4 Solution (extensionSeed_consistent)

ZornFamily proves extensionSeed is consistent for cross-sign cases (lines 694-773):

```lean
-- Cross-sign case: Both past and future times exist
-- Strategy: Show all elements of L land in a single MCS (s_future).
-- - GContent elements: By forward_G, phi in mcs(s_future)
-- - HContent elements: By backward propagation + T-axiom, phi in mcs(s_future)
```

**Key mechanism**: Given domain elements s_past < t < s_future:
1. GContent from s_past propagates forward via `GContent_propagates_forward` to s_future
2. HContent from s_future is already at s_future
3. Both land in mcs(s_future), which is consistent

### 1.3 Why ZornFamily's Solution Cannot Port to DovetailingChain

**Architectural incompatibility**: The two approaches have fundamentally different structures:

| Aspect | ZornFamily | DovetailingChain |
|--------|-----------|-----------------|
| Construction | Zorn's lemma on partial families | Step-by-step chain building |
| Domain | Arbitrary subset of Int | Always full Int (by construction) |
| Cross-sign | Implicit via coherence structure | Must be explicit in seed propagation |
| Witness access | Domain elements exist by hypothesis | Must prove elements exist at construction time |

**The core issue**: ZornFamily's proof relies on `F.forward_G` and `F.backward_H` being available for arbitrary domain pairs. In DovetailingChain, at construction step n, only indices with rank < n have been constructed. When building M_t for t < 0, the positive indices M_1, M_2, ... may not exist yet.

**Dovetailing order**:
```
Step 0 -> M_0
Step 1 -> M_1      (positive)
Step 2 -> M_{-1}   (negative)
Step 3 -> M_2      (positive)
Step 4 -> M_{-2}   (negative)
...
```

When constructing M_{-1} (step 2), M_1 exists but M_2, M_3, ... do not. To prove forward_G from M_{-1} to M_5, we cannot use the ZornFamily pattern because M_5 is not yet constructed.

### 1.4 DovetailingChain Cross-Sign Requirements

DovetailingChain needs a different approach for cross-sign propagation:

**Option A (Interleaved chain with unified seed)**:
- Build single chain with dovetailing order
- Each seed includes both GContent from constructed past AND HContent from constructed future
- Requires bidirectional Lindenbaum extension (complex)

**Option B (Post-construction global argument)**:
- Build chain as currently done (forward chain + backward chain)
- Prove global G-propagation across all indices after both chains are complete
- Uses the shared base MCS at index 0 as the bridge

**Option B is more tractable** because:
1. The chain construction is already complete
2. The shared base ensures GContent(M_0) is in all positive indices
3. For t < 0: G phi in M_t means G phi was added via some backward step's HContent(M_0) inclusion, and the forward chain has G phi in M_0 which propagates forward

### 1.5 Cross-Sign Estimated Effort

| Approach | Cross-Sign Resolution | Effort |
|----------|----------------------|--------|
| DovetailingChain Option B | Global post-construction lemma | 6-8 hours |
| ZornFamily | Already solved but has other blockers | N/A |

---

## 2. Witness Construction Assessment

### 2.1 DovetailingChain F/P Witnesses

The current sorries at lines 633 and 640:

```lean
lemma buildDovetailingChainFamily_forward_F (Gamma : List Formula) ...
    Formula.some_future phi in mcs t ->
    exists s, t < s and phi in mcs s := by
  sorry

lemma buildDovetailingChainFamily_backward_P (Gamma : List Formula) ...
    Formula.some_past phi in mcs t ->
    exists s, s < t and phi in mcs s := by
  sorry
```

### 2.2 Required Infrastructure

**Already exists**:
- `temporal_witness_seed_consistent`: {psi} union GContent(M) is consistent when F psi in M
- `past_temporal_witness_seed_consistent`: {psi} union HContent(M) is consistent when P psi in M

**Missing** (straightforward to implement):
- Dovetailing enumeration of (time, formula) pairs
- Inclusion of witness obligations in seed at appropriate construction steps
- Proof that all F/P obligations are eventually satisfied

### 2.3 Dovetailing Enumeration Pattern

The pattern is well-established:

```lean
-- Use Nat.pair/unpair for dovetailing enumeration
-- At step n, process pair (s, idx) = Nat.unpair n
-- If s < dovetailIndex n and F(formula_idx) in M_s, include formula in seed
```

This requires:
1. `Encodable Formula` instance (exists via `Countable Formula`)
2. `Nat.pair`/`Nat.unpair` bijection (in Mathlib)
3. Well-foundedness argument for completeness

### 2.4 ZornFamily F/P Witnesses

ZornFamily has 2 sorries for F/P (lines 1774, 1790):

```lean
lemma total_family_FObligations_satisfied ...
    phi in F.mcs t := by
  sorry

lemma total_family_PObligations_satisfied ...
    phi in F.mcs t := by
  sorry
```

**The problem**: These cannot be proven from Zorn maximality alone. The metadata analysis (Phase 5) correctly identifies:

> "Maximality alone is insufficient. The partial order is domain extension with agreement. When domain = Set.univ, any G with F <= G must satisfy G = F, making maximality vacuously true."

### 2.5 Witness Construction Effort Comparison

| Approach | F/P Resolution Strategy | Effort | Risk |
|----------|------------------------|--------|------|
| DovetailingChain | Dovetailing enumeration | 8-10 hours | Low |
| ZornFamily | Controlled Lindenbaum OR seed pre-placement | 15-25 hours | High |

---

## 3. Past Struggles (DovetailingChain History)

### 3.1 Task 843 Research Summary

From research-017 (Section 5: "Why Cross-Sign Propagation Fails"):

> "The fundamental issue: The two-chain construction is inherently asymmetric by direction. GContent flows forward-only, HContent flows backward-only. Cross-sign transfer requires GContent to somehow cross the 0-boundary, but the construction order prevents this."

### 3.2 Why Previous Attempts Failed

1. **Two-chain architecture**: Forward and backward chains are built independently
2. **Shared base is "frozen"**: M_0 is constructed once; later backward steps don't update it
3. **No bidirectional seed**: Each chain only seeds from one direction

### 3.3 What Changed (Insight for Resolution)

The key insight from research-016 Section 5.2:

> "For G phi in M_t (t < 0) to reach M_1: If G phi were in M_0 (the shared base), the forward chain has it."

**The solution**: Ensure that GContent of backward chain MCS propagates through the shared base M_0 to the forward chain. This requires:

1. Backward chain includes GContent(M_0) in all seeds (already done via HContent propagation)
2. Forward chain construction respects GContent from M_0
3. Global lemma: G phi in any M_t => G phi in M_0 => phi in all M_{t'} for t' > 0

---

## 4. Comparative Effort Estimate

### 4.1 DovetailingChain Resolution Path

| Phase | Work | Hours | Risk |
|-------|------|-------|------|
| Cross-sign forward_G (t < 0) | Global propagation lemma | 3-4 | Low |
| Cross-sign backward_H (t >= 0) | Symmetric lemma | 2-3 | Low |
| Dovetailing enumeration infrastructure | Nat.pair, Encodable | 4-5 | Low |
| forward_F proof | Include witnesses in seed | 3-4 | Medium |
| backward_P proof | Symmetric | 2-3 | Medium |
| Testing and integration | Build verification | 1-2 | Low |
| **Total** | | **15-21 hours** | **Low-Medium** |

### 4.2 ZornFamily Resolution Path

| Phase | Work | Hours | Risk |
|-------|------|-------|------|
| Fix build errors | List.mem_cons_self issues | 1-2 | Low |
| non_total_has_boundary internal gap | Domain interval proof | 4-6 | Medium |
| h_G_from_new sorry | Controlled Lindenbaum OR theorem refactoring | 8-12 | High |
| h_H_from_new sorry | Symmetric | 6-10 | High |
| F/P obligations | Alternative proof strategy | 8-12 | High |
| Testing and integration | Build verification | 2-3 | Low |
| **Total** | | **29-45 hours** | **High** |

### 4.3 Comparison Summary

| Metric | DovetailingChain | ZornFamily |
|--------|-----------------|-----------|
| Estimated hours | 15-21 | 29-45 |
| Risk level | Low-Medium | High |
| Blocking issues | None | maximal_implies_total flaw |
| Infrastructure needed | Dovetailing enum | Controlled Lindenbaum |
| Path clarity | Clear | Requires theorem redesign |

---

## 5. Zero-Sorry Path Analysis

### 5.1 DovetailingChain Path to Zero Sorries

**Clear path exists**:

1. **Cross-sign G/H** (2 sorries): Prove global propagation through shared base
   - G phi in M_t for t < 0 => G phi in M_0 (via backward chain construction)
   - G phi in M_0 => G phi in all M_{t'} for t' > 0 (via forward chain construction)
   - This uses the existing `dovetailForwardChain_G_propagates` lemma structure

2. **F/P witnesses** (2 sorries): Implement dovetailing enumeration
   - Add witness obligations to seeds at appropriate steps
   - Prove all obligations eventually satisfied by completeness of enumeration

**Confidence**: High. The mathematical structure is sound; only engineering remains.

### 5.2 ZornFamily Path to Zero Sorries

**Path is unclear due to theorem-level issues**:

1. **maximal_implies_total flaw** (documented in metadata):
   > "Lindenbaum extension can create MCS containing formulas like {H p, neg p} that block extension at upper boundaries"

2. **Resolution requires either**:
   - Controlled Lindenbaum that avoids adding blocking formulas (significant infrastructure)
   - Proof that domains are intervals (eliminates internal gap sorry but doesn't address F/P)
   - Alternative totality proof that doesn't require boundary extension

3. **F/P recovery is unresolved**:
   > "The h_G_from_new and h_H_from_new sorries in maximal_implies_total cannot be filled because the underlying theorem may be false."

**Confidence**: Low. Fundamental theorem redesign may be required.

---

## 6. Recommendation

**Pivot to completing DovetailingChain.lean**

### 6.1 Rationale

1. **Mathematical soundness**: DovetailingChain's approach is sound; it just needs engineering
2. **Lower effort**: 15-21 hours vs 29-45 hours
3. **Lower risk**: Clear path vs potential theorem-level flaws
4. **Existing infrastructure**: `temporal_witness_seed_consistent` and `past_temporal_witness_seed_consistent` already proven

### 6.2 Suggested Approach

1. **Phase 1** (6-8h): Prove cross-sign propagation using global shared-base argument
2. **Phase 2** (4-5h): Implement dovetailing enumeration infrastructure
3. **Phase 3** (6-8h): Prove forward_F and backward_P with witness inclusion

### 6.3 Fallback

If DovetailingChain proves harder than expected, the ZornFamily approach could be revisited with a redesigned totality argument. However, this should be a last resort given the identified theorem-level issues.

---

## 7. Confidence Level

| Assessment | Confidence |
|------------|------------|
| Cross-sign analysis accuracy | High |
| Effort estimates (DovetailingChain) | Medium-High |
| Effort estimates (ZornFamily) | Medium (high uncertainty) |
| Zero-sorry path existence | High (DovetailingChain), Low (ZornFamily) |
| Overall recommendation | High |

**Key uncertainties**:
- DovetailingChain cross-sign proof may require subtle shared-base arguments
- ZornFamily may have undiscovered issues beyond the documented flaw

---

## References

- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`
- `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean`
- `specs/843_remove_singleFamily_modal_backward_axiom/reports/research-016.md`
- `specs/843_remove_singleFamily_modal_backward_axiom/reports/research-017.md`
- `specs/843_remove_singleFamily_modal_backward_axiom/reports/research-018.md`
- `specs/880_augmented_extension_seed_approach/.return-meta.json` (Phase 5 analysis)
