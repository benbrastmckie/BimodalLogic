# Research Report: Existential Temporal Content Extractors

**Task**: 9 - add_existential_temporal_extractors
**Date**: 2026-03-21
**Status**: Researched

---

## 1. Executive Summary

This task adds two new content extractors (`f_content` and `p_content`) to `TemporalContent.lean`, complementing the existing universal extractors (`g_content` and `h_content`). The implementation is straightforward (2 lines each), and basic duality lemmas can be proved using existing MCS properties. This is a low-risk foundational task that enables downstream tasks 10-18.

**Complexity Assessment**: Low
**Estimated Effort**: 1-2 hours
**Blockers**: None identified

---

## 2. Current State Analysis

### 2.1 Existing Definitions in TemporalContent.lean

Location: `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean`

```lean
def g_content (M : Set Formula) : Set Formula :=
  {phi | Formula.all_future phi ∈ M}

def h_content (M : Set Formula) : Set Formula :=
  {phi | Formula.all_past phi ∈ M}
```

These extract formulas under universal temporal operators (G = all_future, H = all_past).

### 2.2 Formula Definitions

From `Theories/Bimodal/Syntax/Formula.lean`:

```lean
-- Existential operators defined via negation
def some_past (φ : Formula) : Formula := φ.neg.all_past.neg   -- P = ¬H¬
def some_future (φ : Formula) : Formula := φ.neg.all_future.neg -- F = ¬G¬
```

Key definitional equality (used in existing proofs):
```lean
Formula.some_future phi = Formula.neg (Formula.all_future (Formula.neg phi))
-- This is definitionally true by the definition of some_future
```

### 2.3 Four-Extractor Table

| Extractor | Formula | Semantic Role | Existing? |
|-----------|---------|---------------|-----------|
| `g_content(M)` | `{φ \| Gφ ∈ M}` | Universal future commitments | Yes |
| `h_content(M)` | `{φ \| Hφ ∈ M}` | Universal past commitments | Yes |
| `f_content(M)` | `{φ \| Fφ ∈ M}` | Existential future obligations | **New** |
| `p_content(M)` | `{φ \| Pφ ∈ M}` | Existential past obligations | **New** |

---

## 3. Implementation Specification

### 3.1 New Definitions

Add to `TemporalContent.lean`:

```lean
/--
f_content of an MCS: the set of all formulas φ where F φ (some_future φ) appears in the MCS.

Captures existential future obligations — formulas that must hold at some future time.
Used in the Succ relation for discrete canonical model construction.
-/
def f_content (M : Set Formula) : Set Formula :=
  {phi | Formula.some_future phi ∈ M}

/--
p_content of an MCS: the set of all formulas φ where P φ (some_past φ) appears in the MCS.

Captures existential past obligations — formulas that held at some past time.
Symmetric to f_content for backward temporal reasoning.
-/
def p_content (M : Set Formula) : Set Formula :=
  {phi | Formula.some_past phi ∈ M}
```

### 3.2 Membership Lemmas (Trivial)

```lean
@[simp]
lemma mem_f_content_iff (M : Set Formula) (φ : Formula) :
    φ ∈ f_content M ↔ Formula.some_future φ ∈ M := by
  simp only [f_content, Set.mem_setOf_eq]

@[simp]
lemma mem_p_content_iff (M : Set Formula) (φ : Formula) :
    φ ∈ p_content M ↔ Formula.some_past φ ∈ M := by
  simp only [p_content, Set.mem_setOf_eq]
```

---

## 4. Duality Lemmas

### 4.1 Core Duality Relationships

The F and G operators are dual via negation:
- `Fφ = ¬G¬φ` (definitionally in the codebase)
- `Gφ = ¬F¬φ` (derivable from the above)

Similarly for P and H:
- `Pφ = ¬H¬φ` (definitionally)
- `Hφ = ¬P¬φ` (derivable)

### 4.2 Set-Level Duality Lemmas

**Lemma 1**: φ ∈ f_content(M) ↔ ¬φ ∉ g_content(M) (for MCS M)

```lean
/-- For MCS M: φ ∈ f_content(M) iff ¬φ ∉ g_content(M).
    Uses MCS negation completeness: either Fφ ∈ M or ¬Fφ ∈ M.
    Since ¬Fφ = G¬φ, we have Fφ ∈ M ↔ G¬φ ∉ M. -/
lemma f_content_iff_not_neg_in_g_content
    (M : Set Formula) (h_mcs : SetMaximalConsistent M) (φ : Formula) :
    φ ∈ f_content M ↔ φ.neg ∉ g_content M := by
  simp only [f_content, g_content, Set.mem_setOf_eq]
  constructor
  · intro h_F_in h_G_neg_in
    -- Fφ ∈ M and G(¬φ) ∈ M
    -- But Fφ = ¬G¬φ, so ¬G¬φ ∈ M and G¬φ ∈ M contradicts MCS consistency
    have h_eq : Formula.some_future φ = Formula.neg (Formula.all_future (Formula.neg φ)) := rfl
    rw [h_eq] at h_F_in
    exact set_consistent_not_both h_mcs.1 _ h_G_neg_in h_F_in
  · intro h_G_neg_not_in
    -- G(¬φ) ∉ M, so by negation completeness, ¬G(¬φ) ∈ M
    -- But ¬G¬φ = Fφ, so Fφ ∈ M
    rcases SetMaximalConsistent.negation_complete h_mcs (Formula.all_future φ.neg) with h | h
    · exact absurd h h_G_neg_not_in
    · -- ¬G(¬φ) ∈ M, and ¬G(¬φ) = Fφ
      have h_eq : Formula.neg (Formula.all_future φ.neg) = Formula.some_future φ := rfl
      rw [h_eq] at h
      exact h
```

**Lemma 2**: Symmetric for p_content and h_content.

```lean
lemma p_content_iff_not_neg_in_h_content
    (M : Set Formula) (h_mcs : SetMaximalConsistent M) (φ : Formula) :
    φ ∈ p_content M ↔ φ.neg ∉ h_content M := by
  -- Symmetric proof using Pφ = ¬H¬φ
  sorry  -- Same pattern as above
```

### 4.3 Cross-MCS Duality Lemmas

The existing codebase has `g_content_subset_implies_h_content_reverse` in WitnessSeed.lean.

We should add analogous lemmas for f_content/p_content:

**Lemma 3**: Relationship between f_content and g_content across MCS pairs.

```lean
/-- If g_content(M) ⊆ M', then for any φ with Fφ ∈ M:
    Either φ ∈ M' or Fφ ∈ M' (F-step condition).
    This follows from G-persistence plus consistency. -/
lemma f_content_step_condition
    (M M' : Set Formula) (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_GC : g_content M ⊆ M') :
    f_content M ⊆ M' ∪ f_content M' := by
  intro φ h_F_in
  -- Fφ ∈ M. We need: φ ∈ M' ∨ Fφ ∈ M'
  by_cases h_phi_in_M' : φ ∈ M'
  · left; exact h_phi_in_M'
  · right
    -- Need Fφ ∈ M', i.e., ¬G¬φ ∈ M'
    -- By negation completeness of M', either G¬φ ∈ M' or ¬G¬φ ∈ M'
    -- If G¬φ ∈ M', then... we need to show contradiction from Fφ ∈ M
    -- This requires more work - may need additional axioms
    sorry
```

**Note**: The full f_content_step_condition may require additional axioms (particularly temp_4 or discrete extension axioms). This should be deferred to tasks 10-15 where Succ relation is defined.

---

## 5. Minimal Deliverables for This Task

Given that tasks 10-15 (Succ relation) and 16-18 (DenseTask) build on these definitions, the minimal deliverables are:

### Required (Task 9 scope)

1. **f_content definition** (2 lines)
2. **p_content definition** (2 lines)
3. **mem_f_content_iff simp lemma** (~3 lines)
4. **mem_p_content_iff simp lemma** (~3 lines)
5. **f_content_iff_not_neg_in_g_content** - MCS duality (~15 lines)
6. **p_content_iff_not_neg_in_h_content** - MCS duality (~15 lines)

### Deferred (Tasks 10-15)

- f_content_step_condition (requires Succ relation context)
- p_content_step_condition (symmetric)
- Interaction with discrete axioms (DF, DB)

---

## 6. Dependencies and Imports

### Required Imports

```lean
import Bimodal.Syntax.Formula  -- already present
import Bimodal.Metalogic.Core.MCSProperties  -- for negation_complete, set_consistent_not_both
```

### No New External Dependencies

The implementation uses only existing infrastructure:
- `Set.mem_setOf_eq` from Mathlib (already available)
- `SetMaximalConsistent.negation_complete` from MCSProperties.lean
- `set_consistent_not_both` from MaximalConsistent.lean

---

## 7. Downstream Usage

### Tasks 10-15 (Discrete Track: Succ Relation)

The Succ relation is defined as:
```lean
def Succ (u v : Set Formula) : Prop :=
  g_content u ⊆ v                          -- G-persistence
  ∧ f_content u ⊆ v ∪ f_content v          -- F-step
```

### Tasks 16-18 (Dense Track: DenseTask Relation)

The dense construction uses all four extractors for the density argument:
- g_content for G-persistence
- h_content for H-persistence
- f_content for F-witness existence
- p_content for P-witness existence

---

## 8. Implementation Notes

### 8.1 simp Attributes

The membership lemmas should have `@[simp]` to enable automatic rewriting:
```lean
@[simp] lemma mem_f_content_iff ...
@[simp] lemma mem_p_content_iff ...
```

### 8.2 Documentation

Each definition should have docstrings explaining:
- What the extractor captures semantically
- Relationship to the dual extractor (g_content/h_content)
- Where it's used (Succ relation, DenseTask)

### 8.3 Naming Convention

Follow existing pattern:
- `f_content` (not `some_future_content` or `F_content`)
- `p_content` (not `some_past_content` or `P_content`)

This matches the existing `g_content`/`h_content` naming.

---

## 9. Zero-Debt Compliance

This task achieves zero sorries:

1. **Definitions**: No proofs needed, just set-builder notation
2. **mem_*_iff lemmas**: Trivial `simp only [_, Set.mem_setOf_eq]`
3. **Duality lemmas**: Use existing MCS infrastructure (negation_complete, set_consistent_not_both)

The f_content_step_condition (which may require sorry) is explicitly deferred to tasks 10-15.

---

## 10. Recommendation

**Proceed with implementation.** This is a low-risk, well-defined task with clear specifications from reports 17 and 20. The definitions are trivial and the duality lemmas use established patterns from WitnessSeed.lean.

### Implementation Order

1. Add f_content and p_content definitions to TemporalContent.lean
2. Add mem_*_iff simp lemmas immediately after definitions
3. Add duality lemmas (f_content_iff_not_neg_in_g_content, p_content_iff_not_neg_in_h_content)
4. Verify with `lake build`
5. Done

---

## Appendix A: Mathlib References

| Lemma | Module | Usage |
|-------|--------|-------|
| `Set.mem_setOf_eq` | `Mathlib.Data.Set.Operations` | Unfold set builder membership |
| `Set.mem_union` | `Mathlib.Data.Set.Basic` | For f_content ⊆ M' ∪ f_content M' |

## Appendix B: Existing Codebase References

| Definition/Theorem | File | Usage |
|-------------------|------|-------|
| `g_content`, `h_content` | TemporalContent.lean | Pattern to follow |
| `Formula.some_future` | Formula.lean | F operator definition |
| `Formula.some_past` | Formula.lean | P operator definition |
| `SetMaximalConsistent.negation_complete` | MCSProperties.lean | φ ∈ M ∨ ¬φ ∈ M |
| `set_consistent_not_both` | MaximalConsistent.lean | ¬(φ ∈ M ∧ ¬φ ∈ M) |
| `g_content_subset_implies_h_content_reverse` | WitnessSeed.lean | Duality pattern |
