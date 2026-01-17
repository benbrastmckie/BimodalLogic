import Bimodal.ProofSystem
import Mathlib.Data.List.Basic
import Mathlib.Data.Finset.Basic

namespace Bimodal.Metalogic.Core

open Bimodal.Syntax Bimodal.ProofSystem

-- Import Consistent from Basic after defining it locally to avoid circular imports
def LocalConsistent (Γ : Context) : Prop :=
  ∃ φ : Formula, ¬Nonempty (DerivationTree Γ φ)

/-- 
Set-based provability: Γ ⊢ φ iff some finite subset of Γ derives φ.

This is being eliminated per Task 502 but kept for backward compatibility.
-/
def SetDerivable (Γ : Set Formula) (φ : Formula) : Prop :=
  ∃ (Δ : Finset Formula), (↑Δ : Set Formula) ⊆ Γ ∧ Nonempty (DerivationTree Δ.toList φ)

/-- 
Context-based provability: Γ ⊢ φ using List Formula.

This uses Lean's native List type which is naturally finite, avoiding
artificial finiteness constraints while matching actual proof practice.
-/
def ContextDerivable (Γ : Context) (φ : Formula) : Prop :=
  Nonempty (DerivationTree Γ φ)

/-- 
Basic lemma: Empty context derivability matches standard derivability.

This shows that ContextDerivable generalizes the existing DerivationTree system.
-/
lemma empty_context_derivability_iff {φ : Formula} :
    ContextDerivable [] φ ↔ Nonempty (DerivationTree [] φ) := by
  rfl

/-! 
## Context Manipulation Utilities

These utilities provide basic operations for working with Context contexts
in the context-based provability system.
-/

/-- 
Context extension: Check if Δ extends Γ (all elements of Δ are in Γ).
-/
def Context.extends (Δ Γ : Context) : Prop :=
  ∀ ψ ∈ Δ, ψ ∈ Γ

/-- 
Context merge: Combine two contexts by concatenation.
-/
def Context.merge (Γ₁ Γ₂ : Context) : Context :=
  Γ₁ ++ Γ₂

/-- 
Context subset: Check if Γ₁ is a subset of Γ₂ element-wise.
-/
def Context.subset (Γ₁ Γ₂ : Context) : Prop :=
  ∀ ψ ∈ Γ₁, ψ ∈ Γ₂

end Bimodal.Metalogic.Core
