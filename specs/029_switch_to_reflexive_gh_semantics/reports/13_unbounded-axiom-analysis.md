# Research Report: Unbounded Axiom Analysis for Task 29

**Task**: 29 - switch_to_reflexive_gh_semantics
**Date**: 2026-03-22
**Session**: sess_1774231309_7c0478
**Focus**: Can weakening the logic to remove unbounded axioms eliminate the need for strict successors?

## Executive Summary

**Answer**: No, removing the unboundedness axioms would NOT help resolve the Phase 4-5 blockers. The strict successor requirement comes from the ORDER STRUCTURE needed for completeness, not from the soundness of unboundedness axioms.

**Key Finding**: Under reflexive semantics, the seriality axioms (`Gφ → Fφ`, `Hφ → Pφ`) are **trivially valid without NoMaxOrder/NoMinOrder frame conditions**. The frame conditions are needed for the canonical quotient's ORDER PROPERTIES (to be a valid temporal domain), not for axiom validity.

## Analysis

### 1. Current State of Seriality Axioms

The seriality axioms in `Axioms.lean` are:
- `seriality_future`: `Gφ → Fφ` (lines 402-426)
- `seriality_past`: `Hφ → Pφ` (lines 428-453)

Their soundness proofs in `Soundness.lean` (lines 353-379) reveal a critical insight:

```lean
/-- Future seriality axiom validity: `⊨_discrete Gφ → Fφ`.
Under reflexive semantics, this is trivially valid via T-axiom: Gφ → φ,
and φ at t witnesses Fφ (∃s ≥ t, φ(s)) by taking s = t. -/
theorem seriality_future_valid (φ : Formula) :
    valid_discrete (φ.all_future.imp φ.some_future) := by
  intro T _ _ _ _h_succ _h_pred _h_nontriv F M Omega _h_sc τ _h_mem t
  simp only [Formula.some_future, Formula.neg, truth_at]
  intro h_G h_neg_F
  -- Use t itself as witness: t ≥ t by reflexivity
  exact h_neg_F t le_rfl (h_G t le_rfl)
```

**The proof uses `le_refl` (t ≥ t) as the witness**, NOT any NoMaxOrder property.

### 2. Why NoMaxOrder/NoMinOrder Exist

The frame conditions serve a different purpose: they ensure the **canonical quotient** is a valid temporal domain for the completeness proof.

From `CanonicalSerialFrameInstance.lean`:
```lean
instance : NoMaxOrder (ConstructiveQuotient M₀ h_mcs₀) where
  exists_gt a := by
    -- Uses: (1) seriality axiom F(¬⊥) ∈ M
    -- (2) canonicalR_irreflexive for strictness
    -- Strictness is CRITICAL: proves the successor is STRICTLY greater
```

The chain of dependencies is:
1. **Seriality axiom** (`Gφ → Fφ`) in proof system → `F(¬⊥) ∈ M` for every MCS
2. **Lindenbaum extension** → constructs a successor MCS `N` with `CanonicalR M N`
3. **canonicalR_irreflexive** (from T-axiom) → proves `¬CanonicalR N M` (strictness)
4. **Strictness** → NoMaxOrder/NoMinOrder on the quotient

### 3. The Completeness Pipeline Requires Strictness

The completeness proof requires the canonical timeline to satisfy certain order properties. Looking at `FrameConditions/Completeness.lean`:

```lean
def DenseCompletenessStatement (φ : Formula) : Prop :=
  (∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
     [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [DenselyOrdered D]
     [DenseTemporalFrame D], valid_over D φ) →
  Nonempty ([] ⊢ φ)
```

The `NoMaxOrder`/`NoMinOrder` constraints appear in the completeness STATEMENT because the canonical model must be a valid temporal domain. Removing these would:
- Weaken the completeness theorem (only prove completeness over bounded domains)
- NOT affect soundness (soundness already proved without these constraints)

### 4. Would Removing Unboundedness Axioms Help?

**No**, for two reasons:

#### Reason A: Seriality Axioms Are Trivially Valid

Under reflexive semantics, `Gφ → Fφ` is valid because:
- `Gφ` at t means φ holds at all s ≥ t (including t)
- `Fφ` at t means φ holds at some s ≥ t
- Witness: s = t (reflexivity)

This does NOT depend on NoMaxOrder. The axiom would be valid even on a bounded domain.

#### Reason B: Strict Successors Are Needed for ORDER STRUCTURE

The Phase 4-5 blockers are about proving the canonical quotient is a valid ORDER:
- `forward_F`: When `F(φ) ∈ mcs(t)`, there exists `s > t` with `φ ∈ mcs(s)`
- `backward_P`: When `P(φ) ∈ mcs(t)`, there exists `s < t` with `φ ∈ mcs(s)`

These require STRICT witnesses (`s > t`, `s < t`), not just non-strict (`s ≥ t`, `s ≤ t`). Under reflexive semantics, the reflexive witness (s = t) satisfies the axiom but does NOT provide a strict successor.

### 5. Alternative Analysis: What If We Allowed Non-Strict Witnesses?

If `forward_F` were weakened to use `s ≥ t`:
```
When F(φ) ∈ mcs(t), there exists s ≥ t with φ ∈ mcs(s)
```

This would be **trivially satisfied by s = t** when `F(φ) ∈ M` and `φ ∈ M`. But this creates problems:

1. **NoMaxOrder fails**: We couldn't prove the quotient has no maximum element
2. **Truth Lemma breaks**: The semantic definition of F(φ) uses ≥, but we need to distinguish different times
3. **Density axiom breaks**: `FFφ → Fφ` requires finding a strictly intermediate point

### 6. The Real Issue: Per-Construction Strictness

The Team Research report (12_team-research.md) correctly identified the solution:

> The mathematically elegant and correct solution, making no compromises:
> 1. **Accept preorder structure** — CanonicalR is a preorder, antisymmetry fails
> 2. **Per-construction strictness** — prove witness ≠ source at each construction site

The strict successor comes from **canonicalR_irreflexive** (proven via T-axiom), NOT from any frame condition axiom in the logic.

## Conclusion

### Question: Would removing unbounded axioms eliminate the need for strict successors?

**Answer: NO.**

The strict successor requirement comes from:
1. The ORDER STRUCTURE of the canonical model (needs NoMaxOrder/NoMinOrder)
2. The TRUTH LEMMA (needs to distinguish different times)
3. The DENSITY/DISCRETENESS proofs (need strictly intermediate/adjacent points)

Removing the seriality axioms would:
- Weaken the logic unnecessarily (they're trivially valid anyway)
- NOT affect the strict successor requirement (which comes from canonicalR_irreflexive)
- NOT simplify completeness (we'd just prove completeness over a weaker class of frames)

### Recommended Path Forward

The Team Research recommendations remain correct:
1. **Per-construction strictness**: Prove ¬CanonicalR W M at each call site
2. **Use canonicalR_irreflexive**: The T-axiom approach provides strictness
3. **Bypass fresh atom existence**: Don't prove it universally; use construction-specific arguments

The seriality axioms should be KEPT because:
- They are trivially valid under reflexive semantics
- They provide the syntactic `F(¬⊥) ∈ M` membership needed for constructing successors
- Removing them would weaken expressiveness without simplifying proofs

## Files Examined

| File | Relevance |
|------|-----------|
| `Axioms.lean` | Seriality axiom definitions (lines 402-453) |
| `Soundness.lean` | Seriality validity proofs (lines 353-379) |
| `FrameConditions/FrameClass.lean` | Frame typeclass hierarchy |
| `CanonicalSerialFrameInstance.lean` | NoMaxOrder/NoMinOrder instances |
| `CanonicalIrreflexivityAxiom.lean` | canonicalR_irreflexive theorem |
| `FrameConditions/Completeness.lean` | Completeness statement with frame constraints |
| `TemporalCoherence.lean` | forward_F/backward_P definitions |

## Impact on Task 29

This analysis confirms that the Phase 4-5 approach should focus on:
1. **Per-witness strictness** via canonicalR_irreflexive
2. **NOT** on weakening the logic's axiom set
3. **NOT** on proving fresh atom existence universally

The seriality axioms are orthogonal to the strict successor problem.
