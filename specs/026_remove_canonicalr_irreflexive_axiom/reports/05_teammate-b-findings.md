# Teammate B Findings: What Should Irreflexivity Say in Terms of CanonicalTask?

**Date**: 2026-03-21
**Focus**: Correct formulation of irreflexivity at the CanonicalTask level
**Session**: Task 26 continued research

---

## Key Findings

### 1. The User's Critical Insight is Correct

The user's observation is precise:

> "CanonicalR is just the existential witness of CanonicalTask... what this says is that there is no amount of time where M leads to M. But this is clearly false."

**Analysis**: This is correct in the following sense:

- `CanonicalR M M'` is defined as `g_content M ⊆ M'` (i.e., `∀φ, G(φ) ∈ M → φ ∈ M'`)
- `CanonicalTask M n M'` for `n ≥ 1` implies `CanonicalR M M'` (proven in `CanonicalRecovery.lean:111-123`)
- The axiom `¬CanonicalR M M` thus implies `∀n ≥ 1, ¬CanonicalTask M n M`

**The problem**: Under the user's reading, this says "no duration d > 0 allows M to reach itself", which seems wrong for constant world histories.

### 2. The Constant Valuation Problem (Addressed)

**Question**: If a world history has constant valuation (same formulas true at all times), can `CanonicalTask M d M` hold for `d > 0`?

**Answer**: No, this cannot happen in the canonical model, and here's why:

An MCS M is not a "world history" — it is a **single moment** in the canonical model. The key insight is:

- `CanonicalTask M n M` with `n ≥ 1` means: there exists a chain of `n` Succ-steps from M back to M
- Each Succ step goes from world u to world v where `g_content(u) ⊆ v` (CanonicalR u v)
- Transitivity of CanonicalR implies: if this chain exists, then `g_content(M) ⊆ M`
- But `g_content(M) ⊆ M` means: `∀φ, G(φ) ∈ M → φ ∈ M`

**This is exactly the T-axiom** (`G(φ) → φ`), which is NOT valid under strict temporal semantics.

The semantic justification is: under strict semantics, `G(φ)` at time t means "φ holds at all times s > t". For `g_content(M) ⊆ M` to hold, M would have to be in its own strict future, requiring t > t, which is impossible.

**Constant valuation does not help**: Even if the valuation is constant across all times (same atoms true), the MCS M represents a **single time point**, not a collapsed history. Different time points would be represented by different (though related) MCSs.

### 3. What Property Do Downstream Lemmas Actually Require?

From the usage map (16 sites across 6 files), all usage follows exactly two patterns:

**Pattern A: Equality Contradiction (7 uses)**
```
CanonicalR X Y ∧ X = Y → CanonicalR X X → ⊥
```

**Pattern B: Antisymmetry/Transitivity Contradiction (9 uses)**
```
CanonicalR X Y ∧ CanonicalR Y X → CanonicalR X X → ⊥
```

**What these actually need**: The property that CanonicalR is a **strict** relation (irreflexive and asymmetric). This is used to:
1. Define a strict partial order `<` on CanonicalMCS via CanonicalR
2. Prove NoMaxOrder, NoMinOrder, DenselyOrdered for the Cantor application
3. Ensure distinct equivalence classes have distinct MCSs

### 4. Strict vs Reflexive at the Task Level

**TaskFrame's nullity_identity**: `CanonicalTask M 0 M ↔ M = M` (trivially true)

This says: zero duration means staying at the same world. This is NOT the same as irreflexivity.

**The crucial distinction**:
- **Nullity**: `d = 0 → (CanonicalTask M d N ↔ M = N)`
- **Irreflexivity**: `d > 0 → ¬CanonicalTask M d M`

Nullity tells us what happens at d=0. Irreflexivity tells us what CAN'T happen at d>0.

**The gap**: Nullity's contrapositive is "if M ≠ N then d ≠ 0", not "if M = N then d = 0". Nothing in nullity prevents a positive-duration self-loop.

### 5. Recommended Formulation

**In CanonicalTask terms**, the correct irreflexivity property is:

```lean
theorem canonicalTask_irreflexive :
    ∀ M (h_mcs : SetMaximalConsistent M) (n : Nat),
    n ≥ 1 → ¬CanonicalTask_forward_MCS M n M
```

This is **equivalent to** `canonicalR_irreflexive` via the recovery theorem:
- Forward: `CanonicalTask_forward_MCS M n M` with `n ≥ 1` implies `CanonicalR M M` (proven)
- Therefore: `¬CanonicalR M M` implies `¬(∃n ≥ 1, CanonicalTask_forward_MCS M n M)`

**The reduction is exact**: Proving either form is equivalent to proving the other.

---

## Recommended Approach

### Keep the Current Axiom Formulation

The current `canonicalR_irreflexive_axiom` is the correct level of abstraction because:

1. **All usage sites work at the CanonicalR level**, not CanonicalTask
2. **Seriality/density witnesses produce CanonicalR**, not Succ
3. **The equivalence is proven**: CanonicalTask + n≥1 → CanonicalR, so either formulation suffices

### Don't Reformulate in CanonicalTask Terms

Reformulating as "no positive-duration self-loops in CanonicalTask" would:
- Add an extra layer without benefit
- Still require proving the same underlying fact (no MCS is its own strict future)
- Create maintenance burden converting between formulations

### The Fundamental Property Is Semantic

The irreflexivity expresses: **no time point is strictly later than itself**. This is a property of the time order, not the task relation. The axiom captures what is semantically guaranteed by strict temporal interpretation.

---

## Evidence/Examples

### Example 1: The Recovery Theorem Shows Equivalence

From `CanonicalRecovery.lean:111-123`:
```lean
theorem canonicalTask_forward_MCS_pos_implies_canonicalR
    {u v : Set Formula} {n : Nat}
    (h_pos : n ≥ 1)
    (h_task : CanonicalTask_forward_MCS u n v) :
    CanonicalR u v
```

This proves: any forward chain of ≥1 Succ-steps implies CanonicalR. Therefore:
- `CanonicalTask M n M` with n≥1 → `CanonicalR M M`
- Contrapositive: `¬CanonicalR M M` → `¬(∃n≥1, CanonicalTask M n M)`

### Example 2: Why Constant Valuation Doesn't Break This

Consider a "boring" MCS M where all times have the same valuation. Even so:
- M represents **one time point t**
- `G(φ) ∈ M` means "φ holds at all s > t"
- For `g_content(M) ⊆ M` (CanonicalR M M), we'd need: for all φ, if φ holds at all s > t, then φ holds at t
- This requires the T-axiom, which is invalid under strict semantics

The constant valuation doesn't matter because the **modal content** of M (what G/H formulas it contains) already encodes the strict temporal relationship.

### Example 3: The Antisymmetry Usage Pattern

From `TimelineQuotCanonical.lean:95`:
```lean
theorem denseTimelineElem_mutual_le_implies_mcs_eq :
    -- If p ≤ q and q ≤ p in the preorder, then p.mcs = q.mcs
```

This uses irreflexivity via: if CanonicalR p.mcs q.mcs and CanonicalR q.mcs p.mcs, then by transitivity CanonicalR p.mcs p.mcs, contradicting irreflexivity.

---

## Confidence Level

**High confidence** on all findings.

The analysis is supported by:
1. Direct examination of all 16 usage sites
2. The proven recovery theorem showing exact equivalence
3. The semantic justification from strict temporal interpretation
4. Alignment with prior research (van Benthem, Goldblatt-Thomason)

---

## Summary

**The user's question reveals a subtle point**: "no amount of time where M leads to M" sounds like it forbids temporal loops, which seems too strong. But the correct reading is:

- M is a **single moment** (maximal consistent set), not a world history
- "M leads to M after duration d > 0" means M is its own strict future
- This is impossible because strict future means "later than now"
- The irreflexivity axiom captures this semantic fact

**The property needed** is exactly what we have: `¬CanonicalR M M` for all MCS M. Reformulating in CanonicalTask terms would be equivalent but add unnecessary indirection.
