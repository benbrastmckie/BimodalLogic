import Bimodal.ProofSystem
import Bimodal.Semantics.Validity
import Bimodal.Metalogic.Core.Basic
import Bimodal.Metalogic.Core.Provability
import Bimodal.Metalogic.Representation.CanonicalModel
import Bimodal.Metalogic.Representation.RepresentationTheorem
import Bimodal.Metalogic.Soundness.Soundness

namespace Bimodal.Metalogic.Completeness

open Bimodal.Syntax Bimodal.ProofSystem Bimodal.Semantics Bimodal.Metalogic.Core Bimodal.Metalogic.Representation

variable {Γ : Context} {φ : Formula}

/-- 
Strong Completeness: If Γ semantically entails φ, then Γ proves φ.

This is the main completeness theorem derived from the representation theorem.
The proof goes by contrapositive using the representation theorem.
-/
theorem strong_completeness :
    semantic_consequence Γ φ → ContextDerivable Γ φ := by
  intro h_consequence
  -- Proof by contrapositive: If Γ ⊬ φ, then Γ ⊭ φ
  by_contra h_not_derivable
  -- Apply strong representation theorem to Γ ∪ {¬φ}
  have := strong_representation_theorem h_not_derivable
  obtain ⟨M, w, h_truth_Γ, h_truth_neg⟩ := this
  -- Γ is true at w, but ¬φ is also true at w
  -- Therefore φ is false at w, contradicting semantic consequence
  have h_not_consequence := by
    intro D _ _ F M_val τ t h_all_true
    -- Build a countermodel from the canonical model
    sorry
  exact h_consequence h_not_consequence

/-- 
Weak Completeness: Every valid formula is derivable.

This is the special case of strong completeness with empty context.
-/
theorem weak_completeness {φ : Formula} :
    valid φ → ContextDerivable [] φ := by
  intro h_valid
  have := strong_completeness (Γ := []) (φ := φ)
  exact this h_valid

/-- 
Completeness corollary: Consistency and satisfiability equivalence.

A context is consistent iff it is satisfiable.
-/
theorem consistency_satisfiability_equivalence :
    Consistent Γ ↔ satisfiable_abs Γ := by
  constructor
  · intro h_cons
    -- If consistent, apply representation theorem
    exact Representation.representation_theorem h_cons
  · intro h_sat
    -- If satisfiable, then consistent (by soundness contrapositive)
    intro h_incons
    have := (soundness Γ .bot).mp ⟨axiom_axiom (.bot), h_incons⟩
    sorry

/-- 
Compactness: If every finite subset of Γ is satisfiable, then Γ is satisfiable.

This follows from the representation theorem and finite consistency.
-/
theorem compactness :
    (∀ Δ ⊆ Γ, Δ.Finite → satisfiable_abs Δ.toList) → satisfiable_abs Γ := by
  intro h_fin_sat
  -- Show Γ is finitely consistent
  have h_fin_cons : FinitelyConsistent (↑Γ : Set Formula) := by
    intro Δ h_sub h_fin
    have h_sat := h_fin_sat (↑Δ) (by sorry) h_fin
    exact (consistency_satisfiability_equivalence.mp h_sat).symm
  -- Show consistency from finite consistency using compactness
  sorry

/-- 
Decidability corollary: If φ is not valid, then ¬φ is satisfiable.

This is a direct consequence of completeness.
-/
theorem decidability_corollary {φ : Formula} :
    ¬valid φ → satisfiable_abs [¬φ] := by
  intro h_not_valid
  have h_not_derivable := mt weak_completeness h_not_valid
  exact Representation.representation_theorem ⟨¬φ, h_not_derivable⟩

end Bimodal.Metalogic.Completeness
