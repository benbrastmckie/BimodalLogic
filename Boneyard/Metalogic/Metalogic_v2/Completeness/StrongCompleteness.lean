import Bimodal.Boneyard.Metalogic_v2.Completeness.WeakCompleteness

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
Helper: Build implication chain from context to formula.

Given Γ = [ψ₁, ..., ψₙ] and φ, builds the formula ψ₁ → ... → ψₙ → φ.
-/
def impChain (Γ : Context) (φ : Formula) : Formula :=
  match Γ with
  | [] => φ
  | ψ :: Γ' => Formula.imp ψ (impChain Γ' φ)

/--
Helper: Given a derivation of impChain Γ φ from context Δ,
derive φ from context (Γ ++ Δ).

This uses the fact that elements of Γ are available as assumptions in Γ ++ Δ,
so we can apply modus ponens repeatedly to unfold the implication chain.
-/
def imp_chain_unfold (Γ Δ : Context) (φ : Formula) :
    DerivationTree Δ (impChain Γ φ) → DerivationTree (Γ ++ Δ) φ := by
  intro d
  induction Γ generalizing Δ with
  | nil =>
    -- impChain [] φ = φ, and [] ++ Δ = Δ
    simp only [List.nil_append]
    exact d
  | cons ψ Γ' ih =>
    -- impChain (ψ :: Γ') φ = ψ → impChain Γ' φ
    -- d : Δ ⊢ ψ → impChain Γ' φ
    -- Goal: (ψ :: Γ') ++ Δ ⊢ φ
    simp only [impChain, List.cons_append] at d ⊢
    -- Need: ψ :: (Γ' ++ Δ) ⊢ φ
    -- Weaken d to context ψ :: (Γ' ++ Δ)
    have d_weak : DerivationTree (ψ :: (Γ' ++ Δ)) (Formula.imp ψ (impChain Γ' φ)) :=
      DerivationTree.weakening Δ (ψ :: (Γ' ++ Δ)) _ d (by
        intro x hx
        simp [hx])
    -- Get ψ by assumption
    have d_assump : DerivationTree (ψ :: (Γ' ++ Δ)) ψ :=
      DerivationTree.assumption (ψ :: (Γ' ++ Δ)) ψ (by simp)
    -- Apply modus ponens to get impChain Γ' φ
    have d_chain : DerivationTree (ψ :: (Γ' ++ Δ)) (impChain Γ' φ) :=
      DerivationTree.modus_ponens (ψ :: (Γ' ++ Δ)) ψ (impChain Γ' φ) d_weak d_assump
    -- Apply IH with Δ' = ψ :: Δ (which doesn't quite work)
    -- Actually need: Γ' ++ (ψ :: Δ) = ψ :: (Γ' ++ Δ) is NOT true in general
    -- Let's think again...
    -- We have d_chain : (ψ :: (Γ' ++ Δ)) ⊢ impChain Γ' φ
    -- By IH with Δ' = ψ :: (Γ' ++ Δ), we get:
    --   Γ' ++ (ψ :: (Γ' ++ Δ)) ⊢ φ
    -- But we want (ψ :: (Γ' ++ Δ)) ⊢ φ
    -- This requires weakening, since Γ' ⊆ Γ' ++ Δ ⊆ ψ :: (Γ' ++ Δ)
    have d_from_ih : DerivationTree (Γ' ++ (ψ :: (Γ' ++ Δ))) φ := ih (ψ :: (Γ' ++ Δ)) d_chain
    -- Weaken from Γ' ++ (ψ :: (Γ' ++ Δ)) to ψ :: (Γ' ++ Δ)
    exact DerivationTree.weakening (Γ' ++ (ψ :: (Γ' ++ Δ))) (ψ :: (Γ' ++ Δ)) φ d_from_ih (by
      intro x hx
      simp at hx ⊢
      rcases hx with h | h
      · right; left; exact h
      · exact h)

/--
Helper: impChain Γ φ is semantically equivalent to "if all of Γ hold, then φ holds"

This lemma shows that truth_at M τ t (impChain Γ φ) holds iff
(∀ ψ ∈ Γ, truth_at M τ t ψ) → truth_at M τ t φ
-/
lemma impChain_semantics {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {F : TaskFrame D} {M : TaskModel F} {τ : WorldHistory F} {t : D}
    (Γ : Context) (φ : Formula) :
    truth_at M τ t (impChain Γ φ) ↔ ((∀ ψ ∈ Γ, truth_at M τ t ψ) → truth_at M τ t φ) := by
  induction Γ with
  | nil =>
    -- impChain [] φ = φ
    simp only [impChain, List.not_mem_nil, false_implies, forall_const, implies_true]
  | cons ψ Γ' ih =>
    -- impChain (ψ :: Γ') φ = ψ → impChain Γ' φ
    simp only [impChain, truth_at, ih, List.mem_cons]
    constructor
    · -- Forward: (ψ → (Γ' → φ)) → ((ψ ∧ Γ') → φ)
      intro h h_all
      have h_psi : truth_at M τ t ψ := h_all ψ (Or.inl rfl)
      have h_Γ' : ∀ χ ∈ Γ', truth_at M τ t χ := fun χ hχ => h_all χ (Or.inr hχ)
      exact h h_psi h_Γ'
    · -- Backward: ((ψ ∧ Γ') → φ) → (ψ → (Γ' → φ))
      intro h h_psi h_Γ'
      apply h
      intro χ hχ
      rcases hχ with rfl | hχ'
      · exact h_psi
      · exact h_Γ' χ hχ'

/--
If Γ ⊨ φ, then ⊨ impChain Γ φ.

The proof uses impChain_semantics to show that the semantic content of impChain Γ φ
matches exactly the definition of semantic consequence.
-/
lemma entails_imp_chain (Γ : Context) (φ : Formula) :
    semantic_consequence Γ φ → valid (impChain Γ φ) := by
  intro h_entails D _ _ _ F M τ t
  -- Use impChain_semantics to convert the goal
  rw [impChain_semantics]
  -- Now goal is: (∀ ψ ∈ Γ, truth_at M τ t ψ) → truth_at M τ t φ
  -- This is exactly what h_entails gives us
  intro h_all
  exact h_entails D F M τ t h_all

/--
If ⊢ impChain Γ φ, then Γ ⊢ φ.

Uses imp_chain_unfold to unfold the implication chain with Δ = [].
-/
lemma imp_chain_to_context (Γ : Context) (φ : Formula) :
    ContextDerivable [] (impChain Γ φ) → ContextDerivable Γ φ := by
  intro ⟨d⟩
  -- Use imp_chain_unfold with Δ = []
  -- imp_chain_unfold Γ [] φ d : DerivationTree (Γ ++ []) φ
  have d' := imp_chain_unfold Γ [] φ d
  -- Γ ++ [] = Γ
  simp only [List.append_nil] at d'
  exact ⟨d'⟩

/--
**Strong Completeness**: Semantic consequence implies syntactic derivability.

**Statement**: `Γ ⊨ φ → ContextDerivable Γ φ`

Equivalently: `(∀ F M τ t, (∀ ψ ∈ Γ, truth_at M τ t ψ) → truth_at M τ t φ) → Nonempty (Γ ⊢ φ)`

**Proof Strategy**:
This follows from weak completeness via the deduction theorem. Given Γ ⊨ φ:
1. If Γ is empty, this is weak completeness
2. If Γ = [ψ₁, ..., ψₙ], then ⊨ (ψ₁ → ... → ψₙ → φ)
3. By weak completeness, ⊢ (ψ₁ → ... → ψₙ → φ)
4. By repeated modus ponens with assumptions, Γ ⊢ φ

**Implementation Status**:
Uses the representation_theorem_backward_empty axiom transitively.
Has sorries in helper lemmas for the full structural proof.
-/
theorem strong_completeness (Γ : Context) (φ : Formula) :
    semantic_consequence Γ φ → ContextDerivable Γ φ := by
  intro h_entails
  -- Step 1: Show ⊨ impChain Γ φ
  have h_valid := entails_imp_chain Γ φ h_entails
  -- Step 2: By weak completeness, ⊢ impChain Γ φ
  have h_deriv := weak_completeness (impChain Γ φ) h_valid
  -- Step 3: Convert to Γ ⊢ φ
  exact imp_chain_to_context Γ φ h_deriv

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
    exact strong_completeness Γ φ

end Bimodal.Metalogic_v2.Completeness
