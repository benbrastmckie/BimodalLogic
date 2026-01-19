/-!
# Boneyard: Trivial FMP (DEPRECATED)

This file documents the deprecated trivial Finite Model Property (FMP) proof that existed
in `Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean`.

## Status: DEPRECATED

**DO NOT USE** for new development. Use the constructive FMP approach instead.

## Why This Approach Was Deprecated

The trivial FMP proof was a placeholder that did not provide constructive information:

1. **Identity transformation**: The proof simply unpacked and repacked the satisfiability
   witness without providing any finite model construction.

2. **No explicit bounds**: The original `finite_model_property` theorem did not provide
   an explicit bound on model size in terms of formula complexity.

3. **No Fintype witness**: The proof did not provide a Fintype instance for the world
   states, making it useless for decidability proofs via enumeration.

## Location of Deprecated Code

The deprecated code was in `Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean`:

### Original Trivial Proof (lines 176-187)

```lean
theorem finite_model_property (φ : Formula) :
    formula_satisfiable φ →
    ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (F : TaskFrame D) (M : TaskModel F) (τ : WorldHistory F) (t : D),
      truth_at M τ t φ := by
  intro h_sat
  obtain ⟨D, inst1, inst2, inst3, F, M, τ, t, h_truth⟩ := h_sat
  exact ⟨D, inst1, inst2, inst3, F, M, τ, t, h_truth⟩
```

This proof was essentially `id` - it didn't transform the witness in any meaningful way.

### Other Placeholder Theorems

| Definition/Theorem | Status | Issue |
|-------------------|--------|-------|
| `satisfiability_decidable` | Classical.dec | No enumeration |
| `finite_model_size_bound` | Identity | No bound given |
| `validity_decidable_via_fmp` | Classical.dec | No construction |

## Replacement: Constructive FMP

The constructive approach provides:

1. **Explicit finite model**: Uses `SemanticCanonicalModel` which has finite world states
2. **Cardinality bound**: `2^|closure(phi)|` bound on world states
3. **Fintype witness**: Via `Fintype.ofFinite` from the `Finite SemanticWorldState` instance

### New Theorems (in FiniteModelProperty.lean)

| Definition/Theorem | Status | Benefit |
|-------------------|--------|---------|
| `finite_model_property_constructive` | Partial | Explicit bounds |
| `semanticWorldState_card_bound` | Partial | 2^|closure| bound |

### Supporting Infrastructure

The constructive FMP relies on proven infrastructure from FiniteCanonicalModel.lean:

- `SemanticWorldState phi` - Quotient type with `Finite` instance
- `SemanticCanonicalModel phi` - Canonical model construction
- `semantic_weak_completeness` - Core completeness (proven, no sorries)
- `closureSize phi` - Size bound on subformula closure

## Migration Guide

Code using the trivial FMP should migrate to the constructive version:

### Old Pattern
```lean
-- Getting a model without bounds
have h := finite_model_property φ h_sat
-- Proceeding without knowing model size
```

### New Pattern
```lean
-- Getting a model with explicit bounds
have h := finite_model_property_constructive φ h_sat
-- Now have Fintype witness and cardinality bound
obtain ⟨F, M, τ, t, h_finite, h_fintype, h_truth, h_bound⟩ := h
-- Can enumerate world states, know size is ≤ 2^|closure|
```

## Related Files

- `Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean` - Constructive FMP
- `Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Infrastructure
- `Bimodal/Boneyard/SyntacticApproach.lean` - Related deprecation

## Task Reference

This file was created as part of Task 596 (Constructive Finite Model Bounds).
-/
