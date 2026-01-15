import Bimodal.ProofSystem
import Bimodal.Semantics
import Bimodal.Metalogic.Soundness
import Mathlib.Data.Set.Basic
import Mathlib.Data.Finset.Basic

/-!
# Set-Based Provability and Representation Theorems

This module implements the systematic refactor for metalogical theorem strategies,
establishing representation theorems as foundational result for bimodal/temporal
modal logic.

## Main Results

- `SetDerivable Γ φ`: Set-based provability with finite subset requirement
- `entails Γ φ`: Context-sensitive semantic entailment
- `set_soundness`: Soundness for set-based provability

## Architecture Design

Based on research findings (Task 499), this establishes a hierarchy:
1. **Representation Theorem** (Primary): Isomorphism between abstract and concrete structures
2. **General Completeness** (Context-Sensitive): Γ ⊨ φ ⇒ SetDerivable Γ φ  
3. **Finite Model Property** (Contrapositive): From representation theorem
4. **Decidability** (Finite Search): From FMP + correctness

## Key Features

- **Set-Based Provability**: Handles infinite contexts via finite subset requirement
- **Context Universality**: Unified framework for empty, finite, and infinite Γ
- **Semantic Integration**: Builds on proven SemanticWorldState infrastructure

## References

* Task 499 Research: Representation theorems for bimodal/temporal modal logic
* Transfer Theorems for Independently Axiomatizable Bimodal Logics (J. Symbolic Logic, 2024)
* Jónsson-Tarski Representation Theorem - Algebraic-semantic duality
-/

namespace Bimodal.Metalogic.Representation

open Bimodal.Syntax ProofSystem Semantics

/-- 
Set-based provability: Γ ⊢ φ iff some finite subset of Γ derives φ.

This handles infinite contexts by requiring only finitely many premises be used
in any derivation, which matches the actual nature of formal proofs.
-/
def SetDerivable (Γ : Set Formula) (φ : Formula) : Prop :=
  ∃ (Δ : Finset Formula), (↑Δ : Set Formula) ⊆ Γ ∧ Nonempty (DerivationTree Δ.toList φ)

/-- 
Context-sensitive semantic entailment: Γ ⊨ φ means φ is true in all
models where all formulas in Γ are true.

This supports empty, finite, and infinite contexts uniformly.
-/
def entails (Γ : Set Formula) (φ : Formula) : Prop :=
  ∀ {F : Type} [AddCommGroup F] [LinearOrder F] [IsOrderedAddMonoid F]
    (M : TaskModel F) (τ : TaskFrame F) (t : F),
    (∀ ψ ∈ Γ, truth_at M τ t ψ) → truth_at M τ t φ

/-- 
Basic lemma: Empty context set-derivability matches standard derivability.

This shows that SetDerivable generalizes the existing DerivationTree system.
-/
lemma empty_SetDerivable_iff {φ : Formula} :
    SetDerivable ∅ φ ↔ Nonempty (DerivationTree [] φ) := by
  constructor
  · intro h_set
    obtain ⟨Δ, h_sub, ⟨d⟩⟩ := h_set
    have h_empty : Δ = ∅ := by
      apply Finset.eq_empty_of_forall_notMem
      intro ψ hψ
      exact absurd (h_sub hψ) (by simp)
    rw [h_empty] at d
    exact ⟨d⟩
  · intro ⟨d⟩
    use ∅
    simp
    exact ⟨d⟩

/-- 
Soundness theorem for set-based provability.

If Γ ⊢ φ via SetDerivable, then Γ ⊨ φ semantically.
-/
theorem set_soundness {F : Type} [AddCommGroup F] [LinearOrder F] [IsOrderedAddMonoid F]
    (Γ : Set Formula) (φ : Formula) :
    SetDerivable Γ φ → entails Γ φ := by
  intro ⟨Δ, h_sub, ⟨d⟩⟩
  intro M τ t h_Γ_true
  have h_Δ_true : ∀ ψ ∈ Δ, truth_at M τ t ψ := by
    intro ψ hψ
    exact h_Γ_true ψ (h_sub (Finset.mem_coe.1 hψ))
  exact soundness Δ.toList φ d M τ t h_Δ_true

/-! 
## Architecture Notes

The representation theorem approach eliminates circular dependencies identified in Task 499:

### Previous Architecture (Circular):
```
Completeness → FMP → Decidability → (back to) Completeness
```

### New Architecture (Hierarchical):
```
1. Representation Theorem (Primary):
   SetDerivable Γ φ ↔ ∃ concrete model with Γ true and φ true
   Uses only soundness as foundation

2. General Completeness (Derived):
   entails Γ φ → SetDerivable Γ φ
   Direct consequence of representation theorem

3. Finite Model Property (Derived):
   If ⊬ φ, then ∃ finite countermodel
   Contrapositive of representation theorem

4. Decidability (Derived):
   From FMP + bounded model checking
   Computational decision procedure
```

### Research Insights

1. **Set-Based Provability**: Essential for handling infinite contexts
   - Finite subset requirement matches actual proof practice
   - Enables compactness arguments

2. **Transfer Theorems**: For bimodal logics L = L₁ ⊗ L₂
   - Properties transfer under independent axiomatization
   - Completeness, FMP, decidability all transfer

3. **Context Universality**: Single framework for all context types
   - Empty context: Standard completeness
   - Finite context: Bounded search with FMP
   - Infinite context: Countable compactness

### Implementation Status

This module provides the foundational infrastructure:
- ✅ SetDerivable definition with finite subset requirement
- ✅ Context-sensitive entailment definition  
- ✅ Basic soundness theorem for set-based provability
- 🔄 Full representation theorem (requires integration with FiniteCanonicalModel)
- 🔄 General completeness (requires compactness arguments)

The architecture establishes a mathematically elegant foundation for systematic
refactor of metalogical results in bimodal/temporal modal logic.
-/

end Bimodal.Metalogic.Representation