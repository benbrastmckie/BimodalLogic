import Bimodal.Metalogic_v2.Completeness.WeakCompleteness

/-!
# Strong Completeness for TM Bimodal Logic (Metalogic_v2)

This module proves the strong completeness theorem for TM bimodal logic:
semantic consequence implies syntactic derivability (Γ ⊨ φ → Γ ⊢ φ).

## Overview

This is part of the Metalogic_v2 reorganization that establishes a
representation-first architecture with the Finite Model Property (FMP)
as the central bridge theorem.

## Main Results

- `strong_completeness`: `Γ ⊨ φ → Γ ⊢ φ` (semantic consequence implies derivability)
- `context_provable_iff_entails`: `Γ ⊢ φ ↔ Γ ⊨ φ` (equivalence)

## Layer Dependencies

Completeness.StrongCompleteness depends on:
- Bimodal.Metalogic_v2.Completeness.WeakCompleteness

## Proof Strategy

Strong completeness follows from weak completeness via the deduction theorem:
1. Assume Γ ⊨ φ
2. By semantic compactness arguments, φ follows from finitely many formulas in Γ
3. Apply deduction theorem to reduce to weak completeness
4. Reconstruct derivation from Γ

## References

- Modal Logic, Blackburn et al., Chapter 4
-/

namespace Bimodal.Metalogic_v2.Completeness

open Bimodal.Syntax Bimodal.ProofSystem Bimodal.Semantics
open Bimodal.Metalogic_v2.Core Bimodal.Metalogic_v2.Representation

/-!
## Strong Completeness

Completeness for arbitrary contexts.
-/

/--
**Strong Completeness**: Semantic consequence implies syntactic derivability.

**Statement**: `Γ ⊨ φ → Γ ⊢ φ`

Equivalently: `(∀ F M τ t, (∀ ψ ∈ Γ, truth_at M τ t ψ) → truth_at M τ t φ) → (Γ ⊢ φ)`

**Proof Strategy**:
This follows from weak completeness via the deduction theorem. Given Γ ⊨ φ:
1. If Γ is empty, this is weak completeness
2. If Γ = [ψ₁, ..., ψₙ], then ⊨ (ψ₁ → ... → ψₙ → φ)
3. By weak completeness, ⊢ (ψ₁ → ... → ψₙ → φ)
4. By repeated modus ponens with assumptions, Γ ⊢ φ

**Implementation Status**:
Uses the representation_theorem_backward_empty axiom transitively.
-/
theorem strong_completeness (Γ : Context) (φ : Formula) :
    semantic_consequence Γ φ → DerivationTree Γ φ := by
  intro h_entails
  -- For now, use a simple approach:
  -- Build implication chain from context and use weak completeness
  induction Γ with
  | nil =>
    -- Empty context case: semantic_consequence [] φ means valid φ
    have h_valid : valid φ := by
      intro D _ _ _ F M τ t
      exact h_entails D F M τ t (fun _ h => (List.not_mem_nil h).elim)
    exact weak_completeness φ h_valid
  | cons ψ Γ' ih =>
    -- For ψ :: Γ' ⊨ φ, we need to derive φ from ψ :: Γ'
    -- Strategy: Show Γ' ⊨ (ψ → φ), then apply IH and modus ponens
    have h_imp_entails : semantic_consequence Γ' (Formula.imp ψ φ) := by
      intro D inst1 inst2 inst3 F M τ t h_all
      unfold truth_at
      intro h_psi
      -- Need to show truth_at M τ t φ
      -- We know h_entails : ∀ ..., (∀ χ ∈ ψ :: Γ', truth_at M τ t χ) → truth_at M τ t φ
      apply h_entails D F M τ t
      intro χ h_mem
      cases List.mem_cons.mp h_mem with
      | inl h_eq => rw [h_eq]; exact h_psi
      | inr h_in_Γ' => exact h_all χ h_in_Γ'
    -- By IH, Γ' ⊢ ψ → φ
    have h_deriv_imp : DerivationTree Γ' (Formula.imp ψ φ) := ih h_imp_entails
    -- Weaken to ψ :: Γ'
    have h_deriv_imp' : DerivationTree (ψ :: Γ') (Formula.imp ψ φ) :=
      DerivationTree.weakening Γ' (ψ :: Γ') (Formula.imp ψ φ) h_deriv_imp
        (fun χ h => List.mem_cons_of_mem ψ h)
    -- Get assumption ψ from ψ :: Γ'
    have h_assump : DerivationTree (ψ :: Γ') ψ :=
      DerivationTree.assumption (ψ :: Γ') ψ (List.mem_cons_self ψ Γ')
    -- Apply modus ponens
    exact DerivationTree.modus_ponens (ψ :: Γ') ψ φ h_deriv_imp' h_assump

/--
Context provability equivalence: derivability and semantic consequence are equivalent.

**Statement**: `ContextDerivable Γ φ ↔ Γ ⊨ φ`
-/
theorem context_provable_iff_entails (Γ : Context) (φ : Formula) :
    ContextDerivable Γ φ ↔ semantic_consequence Γ φ := by
  constructor
  · -- Soundness: derivable implies semantic consequence
    intro ⟨d⟩
    exact Soundness.soundness Γ φ d
  · -- Completeness: semantic consequence implies derivable
    intro h
    exact ⟨strong_completeness Γ φ h⟩

end Bimodal.Metalogic_v2.Completeness
