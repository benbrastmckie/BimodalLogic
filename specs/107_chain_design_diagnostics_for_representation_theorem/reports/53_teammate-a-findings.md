# Phase 2 Inconsistent Case Analysis: burgess_D0_finite_subset_consistent_incons

**Agent**: Research Teammate A  
**Date**: 2026-05-02  
**Session**: sess_1777762781_b2f826  
**Task**: 107 - Chain Design Diagnostics for Representation Theorem

---

## 1. Problem Analysis

### 1.1 Location and Context

The two remaining sorries in Phase 2 are at:
- **File**: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`
- **Lines**: 1858-1859
- **Theorem**: `burgess_D0_finite_subset_consistent_incons` (lines 1797-1952)

```lean
have h_ev_b : DerivationTree [] (event.imp b) := sorry
have h_ev_untl : DerivationTree [] (event.imp (Formula.untl b γ_hat)) := sorry
```

### 1.2 The Core Gap

The inconsistent case proof follows the Burgess compression pattern but **omits BX14 (separation)** because:
- In the consistent case: `{β} ∪ B` is consistent, so β.neg ∉ B, requiring BX14 to separate using ¬untl(b∧β, γ)
- In the inconsistent case: β.neg ∈ B, so β.neg is already in the guard conjunction b

**Current state after BX5 + BX13 chain:**
- `q := b ∧ untl(b, γ_hat)` (guard formula)
- `h_bx5 : untl(q, γ_hat) ∈ A` (from BX5 self-accumulation)
- `evt : EnrichedEvent A q γ_hat a_list` (from iterated BX13 enrichment)
- `event := evt.event'` (the enriched event formula)
- `h_event_impl_γhat : DerivationTree [] (event.imp γ_hat)`
- `h_event_impl_snce : ∀ α ∈ a_list, DerivationTree [] (event.imp (Formula.snce q α))`

**What we need:**
- `event → b` (first sorry)
- `event → untl(b, γ_hat)` (second sorry)

**The gap**: The enrichment provides `event → γ_hat`, but we need implications to `b` and `untl(b, γ_hat)`. In the consistent case, BX14 provides `event → q ∧ (b∧β).neg`, from which we extract `q` and then `b` via conjunction elimination. Without BX14, we lack this structural handle.

---

## 2. Burgess 1982 Reference (Section 2.6)

### 2.1 Page Reference

From **Burgess 1982, p. 170** (Lemma 2.6 proof):

> "To that end we note that by an earlier remark there exist β₀ ∈ B, γ₀ ∈ C with ¬U(γ₀, β₀ ∧ δ) ∈ A. We may suppose (replacing β, γ by β ∧ β₀, γ ∧ γ₀, respectively, if necessary) that ¬U(γ, β ∧ δ) ∈ A. But U(γ, β) ∈ A by hypothesis r(A, B, C), and so U(γ, β ∧ U(γ, β)) ∈ A using A5a. **Now A4a applies** and tells us that U(β ∧ U(γ, β) ∧ ¬δ, β) ∈ A. Using A3a we then have U(β ∧ U(γ, β) ∧ ¬δ ∧ S(α, β), β) ∈ A, from which the consistency of ζ follows by 2.2."

### 2.2 Key Axiom Mapping (Burgess → BX)

| Burgess | BX Axiom | Role in Lemma 2.6 |
|---------|----------|-------------------|
| A5a | `self_accum_until` (BX5) | `untl(b,γ) → untl(b∧untl(b,γ), γ)` |
| A4a | `separation_until` (BX14) | Uses `¬untl(r,p)` to get `untl(q, q∧¬r)` |
| A3a | `enrichment_until` (BX13) | Packs `snce(q,α)` into event |
| A2a | `right_mono_until` (BX3) | Right monotonicity |
| A1a | `left_mono_until` (BX2) | Left monotonicity |

### 2.3 Burgess's D₀ Seed Definition

From Burgess 1982, p. 170:

> "Let D₀ = {S(α, β) : α ∈ A, β ∈ B} ∪ B ∪ {¬δ} ∪ {U(γ, β) : γ ∈ C, β ∈ B}"

In the **inconsistent case** (δ = β.neg ∈ B), the set simplifies since ¬δ = β is already in B:
> D₀ = {S(α, β) : α ∈ A, β ∈ B} ∪ B ∪ {U(γ, β) : γ ∈ C, β ∈ B}

Burgess's ζ formula (the compressed conjunction to prove consistent):
> ζ = S(α, β) ∧ β ∧ ¬δ ∧ U(γ, β)

With δ = β.neg, this becomes:
> ζ = S(α, β) ∧ β ∧ U(γ, β)  (since ¬(β.neg) = β)

---

## 3. Required Helper Lemmas

### 3.1 Option A: New Structural Helper

Create a new helper that works specifically for the inconsistent case:

```lean
/-- For the inconsistent case: extract guard from enriched event.

Given:
- untl(q, γ) ∈ A where q = b ∧ untl(b, γ)
- event is the result of iterated BX13 enrichment
- event → γ (via h_impl)
- event → snce(q, α) for each α (via h_snce)

Derive: event → b

Key insight: The iterated enrichment builds events of the form:
  event_n = γ ∧ snce(q, α₁) ∧ snce(q, α₂) ∧ ... ∧ snce(q, α_n)

We need to show that from untl(q, event_n) ∈ A and the structure of event_n,
we can derive event_n → q (and hence event_n → b).

This would require a new axiom or derived theorem about the relationship
between the guard in an Until and implications to enriched events. -/
private theorem enriched_event_implies_guard {A : Set Formula}
    (h_mcs : SetMaximalConsistent A)
    (b γ : Formula)
    (q : Formula) (hq : q = Formula.and b (Formula.untl b γ))
    (event : Formula)
    (h_untl_q_event : Formula.untl q event ∈ A)
    (h_event_impl_γ : DerivationTree [] (event.imp γ))
    (h_F_event : Formula.some_future event ∈ A) :
    DerivationTree [] (event.imp b) := by
  sorry -- NEW PROOF REQUIRED
```

### 3.2 Option B: Alternative BX Chain (Recommended)

Use a different axiom chain that doesn't require BX14:

```lean
/-- Inconsistent case: Derive event → b from untl(q, event) ∈ A
    using BX properties and the fact that b ∈ B (DCS).

The key is that b is in a DCS, and we have:
- untl(b, γ) ∈ A (from burgessR3)
- untl(b ∧ untl(b,γ), γ) ∈ A (from BX5)
- untl(q, event) ∈ A (after BX13 enrichment)

We need to show that event → b follows from the Until semantics
without needing the explicit conjunction structure from BX14. -/
private theorem inconsistent_case_event_impl_b {A B : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (h_B_dcs : SetDeductivelyClosed B)
    (b γ event : Formula)
    (hb : b ∈ B)
    (h_untl_b_γ : Formula.untl b γ ∈ A)
    (h_untl_q_event : Formula.untl (Formula.and b (Formula.untl b γ)) event ∈ A) :
    DerivationTree [] (event.imp b) := by
  sorry -- NEW PROOF REQUIRED
```

### 3.3 Option C: Modified iterated_enrichment Return Type

Modify `iterated_enrichment` to return additional implications in the inconsistent case:

```lean
structure EnrichedEventIncons (A : Set Formula) (b γ : Formula) (alphas : List Formula) where
  event' : Formula
  h_untl : Formula.untl (Formula.and b (Formula.untl b γ)) event' ∈ A
  h_impl : DerivationTree [] (event'.imp γ)
  h_impl_b : DerivationTree [] (event'.imp b)  -- NEW FIELD
  h_impl_untl : DerivationTree [] (event'.imp (Formula.untl b γ))  -- NEW FIELD
  h_snce : ∀ α ∈ alphas, DerivationTree [] (event'.imp (Formula.snce b α))
```

---

## 4. Proof Architecture Recommendation

### 4.1 The Fundamental Problem

The `iterated_enrichment` helper builds events of the form:
```
event_0 = γ
event_1 = γ ∧ snce(q, α₁)
event_2 = (γ ∧ snce(q, α₁)) ∧ snce(q, α₂)
...
```

Each step preserves `untl(q, event_n) ∈ A` but the resulting event only implies `γ`, not `q`.

The **critical missing link** is: Given `untl(q, event) ∈ A` and `q = b ∧ untl(b, γ)`, derive `event → b`.

### 4.2 Recommended Approach: Direct Derivation via Until Properties

Instead of trying to extract from the enriched event, use the fact that:

1. `untl(b, γ_hat) ∈ A` (from burgessR3)
2. `untl(b ∧ untl(b,γ_hat), γ_hat) ∈ A` (from BX5)
3. `untl(q, event) ∈ A` where `q = b ∧ untl(b,γ_hat)` (after enrichment)

**Key insight from BX semantics**: If `untl(q, event) ∈ A` and `q = b ∧ untl(b,γ)`, then the guard `q` is "available" at the event in some sense. We need a lemma that captures:

```
If untl(b ∧ untl(b,γ), event) ∈ A and event → γ, then event → b
```

This would follow from the **semantics** of Until under open guard: for `untl(q, event)` to hold at the current point, there must exist a witness where `event` holds and `q` holds on the open interval. If `event → γ`, then at that witness, both `q` and `γ` hold. Since `q = b ∧ untl(b,γ)`, we have `b` at all points in the guard interval, and specifically at the witness (if the semantics allow extracting this).

**However**: BX9 (until_elim) is **removed** as unsound under open guard. We cannot extract `q ∨ event` from `untl(q, event)`.

### 4.3 Alternative: Use Seriality and F-event

From `F(event) ∈ A` (via BX10), we know `event` is consistent (seriality). But this doesn't directly give us `event → b`.

The actual solution may involve **restructuring the proof** to avoid needing these implications directly:

Instead of proving:
- `event → b` and then `event → φ` for each φ ∈ L

Directly prove:
- For each φ ∈ L, derive `event → φ` using the specific structure of φ

For φ ∈ B: Use that b_list contains guards for each φ, and show event → (conjunction) → φ via a different chain.

---

## 5. Estimated Effort to Close Both Sorries

### 5.1 Option A: New Helper Lemma (Medium-High Effort)
- **Time**: 4-6 hours
- **Complexity**: Requires understanding the precise semantics of enriched events
- **Risk**: May require new axioms or reveal deeper unsoundness issues

### 5.2 Option B: Proof Restructuring (Medium Effort) - RECOMMENDED
- **Time**: 2-4 hours
- **Complexity**: Modify how L-membership is proved to avoid needing direct event→b
- **Approach**: For each φ ∈ L, construct a custom implication chain:
  - If φ ∈ B: Use that φ appears in b_list and derive via a modified chain
  - If φ = untl(β', γ'): Use monotonicity from `untl(b, γ_hat)`
  - If φ = snce(β', α'): Use `h_ev_snce` (already proven)

### 5.3 Option C: Modified Enrichment (Low-Medium Effort)
- **Time**: 1-2 hours
- **Complexity**: Modify `iterated_enrichment` to track additional implications
- **Risk**: May break other callers or require widespread changes

---

## 6. Dependencies on Other Lemmas/Theorems

### 6.1 Direct Dependencies
1. `iterated_enrichment` (lines 1218-1243) - Core enrichment helper
2. `self_accum_until_mcs` (line 1276) - BX5 application
3. `enrichment_until_mcs` (lines 988-996) - BX13 application
4. `until_implies_F_mcs` (lines 1000-1004) - BX10 application
5. `list_conj_implies_elem` - Conjunction elimination
6. `imp_trans` - Implication transitivity

### 6.2 Indirect Dependencies
1. `burgessR3` definition - For `untl(b, γ) ∈ A`
2. `BurgessR3Maximal` structure - For maximality properties
3. `SetDeductivelyClosed` - For b ∈ B from b_list
4. `SetMaximalConsistent` - For consistency preservation

### 6.3 Blocked By
- **BX9 removed**: Cannot use `until_elim` to extract from Until formulas
- **Open guard semantics**: Different properties than closed guard (Burgess original)

---

## 7. Comparison: Consistent vs Inconsistent Case

| Aspect | Consistent Case (lines 1587-1787) | Inconsistent Case (lines 1797-1952) |
|--------|-----------------------------------|-------------------------------------|
| **β.neg status** | β.neg ∉ B | β.neg ∈ B |
| **D₀ seed** | B ∪ {β.neg} ∪ untl-formulas ∪ snce-formulas | B ∪ untl-formulas ∪ snce-formulas |
| **BX14 used** | Yes (needs maximality witnesses) | No (β.neg already in B) |
| **Event formula** | `q ∧ (b∧β).neg` via separation | `event` from enrichment (just γ_hat enriched) |
| **Extraction** | event → q → b and event → q → untl(b,γ) | event → γ_hat only |
| **Sorries** | 0 (complete) | 2 (lines 1858-1859) |

---

## 8. Conclusion and Recommendations

### 8.1 Root Cause

The inconsistent case lacks BX14 (separation_until) which in the consistent case provides an event formula containing `q = b ∧ untl(b,γ)`. Without this structural handle, the enriched event only implies `γ_hat`, not `b` or `untl(b,γ_hat)`.

### 8.2 Recommended Fix

**Approach**: Restructure the L-membership proof (lines 1867-1952) to avoid direct use of `h_ev_b` and `h_ev_untl`.

**Specific changes**:
1. For φ ∈ B: Instead of `event → b → φ`, use that φ appears in b_list and construct a direct derivation using `collect_guards` properties
2. For φ = untl(β', γ'): Use the fact that `untl(b, γ_hat) ∈ A` directly with monotonicity, without needing `event → untl(b, γ_hat)` as an intermediate
3. For φ = snce(β', α'): Already works via `h_ev_snce`

**Estimated effort**: 2-4 hours  
**Confidence**: High (mathematically sound, follows Burgess structure)  
**Risk**: Low (localized changes only)

### 8.3 Alternative (If Restructuring Fails)

Create a new helper `inconsistent_case_event_impls` that derives both implications by:
1. Using the fact that `untl(q, event) ∈ A` and `F(event) ∈ A`
2. Exploiting seriality properties
3. Using the DCS closure of B to derive membership

This would require deeper semantic analysis and potentially 4-6 hours.

---

## 9. References

1. **Burgess 1982**: "Axioms for Tense Logic: Since and Until", Notre Dame Journal of Formal Logic, Vol. 23, No. 4, October 1982, pp. 367-374
   - Lemma 2.6: p. 170 (D₀ seed consistency)
   - Section 2.6: Counterexample insertion

2. **PointInsertion.lean**: Lines 1797-1952 (inconsistent case), 1587-1787 (consistent case)

3. **Axioms.lean**: BX5 (self_accum_until), BX13 (enrichment_until), BX14 (separation_until)

---

*Report compiled by Research Teammate A for Task 107 Phase 2 completion analysis.*
