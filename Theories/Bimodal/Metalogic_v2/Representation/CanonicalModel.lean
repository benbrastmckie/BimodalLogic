import Bimodal.ProofSystem
import Bimodal.Semantics
import Bimodal.Metalogic_v2.Core.MaximalConsistent
import Bimodal.Theorems.Propositional
import Mathlib.Data.Set.Basic

/-!
# Canonical Model Foundation for TM Bimodal Logic (Metalogic_v2)

This module provides the foundational definitions for the canonical model construction,
which is the core of the completeness proof for TM bimodal logic.

## Overview

This is part of the Metalogic_v2 reorganization that establishes a
representation-first architecture with the Finite Model Property (FMP)
as the central bridge theorem.

## Main Definitions

- `CanonicalWorldState`: Worlds in the canonical model (maximal consistent sets)
- `CanonicalFrame`: Frame structure with accessibility relations
- `CanonicalModel`: Combined frame and valuation

## Layer Dependencies

Representation.CanonicalModel depends on:
- Bimodal.ProofSystem (derivation trees)
- Bimodal.Semantics (semantic definitions)
- Bimodal.Metalogic_v2.Core.MaximalConsistent (MCS theory)

## References

- Metalogic_v2/Core/MaximalConsistent.lean: SetConsistent, SetMaximalConsistent, set_lindenbaum
- Modal Logic, Blackburn et al., Chapter 4 (Canonical Models)
-/

namespace Bimodal.Metalogic_v2.Representation

open Bimodal.Syntax Bimodal.ProofSystem Bimodal.Semantics
open Bimodal.Metalogic_v2.Core

/-!
## Re-exports from Core

The core consistency and MCS definitions are in Core.MaximalConsistent.
We re-export the key definitions here for convenience.
-/

-- Re-export from Core for module clients
#check SetConsistent
#check SetMaximalConsistent
#check set_lindenbaum

/-!
## Canonical World State

A canonical world is a maximal consistent set of formulas.
-/

/--
A canonical world state is a set of formulas that is maximally consistent.

This is the subtype of sets that satisfy `SetMaximalConsistent`.
-/
def CanonicalWorldState : Type := {S : Set Formula // SetMaximalConsistent S}

namespace CanonicalWorldState

/--
The carrier set of formulas for a canonical world.
-/
def carrier (w : CanonicalWorldState) : Set Formula := w.val

/--
A canonical world is consistent.
-/
lemma is_consistent (w : CanonicalWorldState) : SetConsistent w.carrier :=
  w.property.1

/--
A canonical world is maximal: adding any formula not in it makes it inconsistent.
-/
lemma is_maximal (w : CanonicalWorldState) :
    ∀ φ : Formula, φ ∉ w.carrier → ¬SetConsistent (insert φ w.carrier) :=
  w.property.2

end CanonicalWorldState

/-!
## Canonical Frame

The canonical frame defines accessibility relations based on modal and temporal operators.
-/

/--
The canonical frame for TM bimodal logic.

The worlds are all maximal consistent sets. Accessibility relations are defined
based on the modal box operator and temporal operators (H, G).
-/
structure CanonicalFrame where
  /-- All canonical worlds (maximal consistent sets) -/
  worlds : Set CanonicalWorldState
  /-- Box accessibility: w' is box-accessible from w if all □φ in w implies φ in w' -/
  box_accessibility : CanonicalWorldState → Set CanonicalWorldState
  /-- Past accessibility: for H (universal past) operator -/
  past_accessibility : CanonicalWorldState → Set CanonicalWorldState
  /-- Future accessibility: for G (universal future) operator -/
  future_accessibility : CanonicalWorldState → Set CanonicalWorldState

/--
Construction of the canonical frame.

The worlds are all maximal consistent sets. Accessibility is defined
based on the modal and temporal operators.
-/
def canonicalFrame : CanonicalFrame :=
{
  worlds := { _w : CanonicalWorldState | True }
  box_accessibility := fun w =>
    { w' : CanonicalWorldState |
      ∀ φ, Formula.box φ ∈ w.carrier → φ ∈ w'.carrier }
  past_accessibility := fun w =>
    { w' : CanonicalWorldState |
      ∀ φ, Formula.all_past φ ∈ w.carrier → φ ∈ w'.carrier }
  future_accessibility := fun w =>
    { w' : CanonicalWorldState |
      ∀ φ, Formula.all_future φ ∈ w.carrier → φ ∈ w'.carrier }
}

/-!
## Canonical Model

The canonical model combines the frame with a valuation based on set membership.
-/

/--
The canonical model combines the frame with a valuation.

The valuation maps a formula to the set of worlds (maximal consistent sets)
that contain the formula.
-/
structure CanonicalModel where
  frame : CanonicalFrame
  valuation : Formula → Set CanonicalWorldState
  valuation_correct : ∀ φ w, w ∈ valuation φ ↔ φ ∈ w.carrier

/--
Construction of the canonical model.

The valuation maps a formula to the set of worlds that contain it.
-/
def canonicalModel : CanonicalModel :=
{
  frame := canonicalFrame
  valuation := fun φ => { w : CanonicalWorldState | φ ∈ w.carrier }
  valuation_correct := by
    intro φ w
    rfl
}

/-!
## MCS Properties

Key properties of maximal consistent sets needed for the truth lemma.
These build on the Core.MaximalConsistent module.
-/

open Bimodal.Theorems.Propositional in
/--
Helper lemma: From the negation of SetConsistent (insert φ S), extract a context Γ ⊆ S
such that Γ ⊢ ¬φ.

This bridges set-based inconsistency to list-based derivation infrastructure.
The key insight is that if `insert φ S` is inconsistent, there's a finite list L
with elements from `insert φ S` that derives ⊥. Filtering out φ gives a subset of S
from which we can derive ¬φ using the deduction theorem.
-/
lemma extract_neg_derivation {S : Set Formula} {φ : Formula}
    (h_incons : ¬SetConsistent (insert φ S))
    (_h_S_cons : SetConsistent S) :
    ∃ Γ : Context, (∀ ψ ∈ Γ, ψ ∈ S) ∧ Nonempty (DerivationTree Γ (Formula.neg φ)) := by
  -- Unfold ¬SetConsistent to get a witness list
  unfold SetConsistent at h_incons
  push_neg at h_incons
  obtain ⟨L, h_L_sub, h_L_incons⟩ := h_incons
  -- L is inconsistent, so L ⊢ ⊥
  have h_bot : Nonempty (DerivationTree L Formula.bot) := inconsistent_derives_bot h_L_incons
  obtain ⟨d_bot⟩ := h_bot
  -- Define Γ = L.filter (· ≠ φ) = elements of L that are in S
  let Γ := L.filter (· ≠ φ)
  -- Show Γ ⊆ S
  have h_Γ_in_S : ∀ ψ ∈ Γ, ψ ∈ S := by
    intro ψ hψ
    have hψ' := List.mem_filter.mp hψ
    have hψL := hψ'.1
    have hψne : ψ ≠ φ := by simpa using hψ'.2
    specialize h_L_sub ψ hψL
    simp [Set.mem_insert_iff] at h_L_sub
    rcases h_L_sub with rfl | h_in_S
    · exact absurd rfl hψne
    · exact h_in_S
  -- Key: L ⊆ φ :: Γ (since elements of L are either φ or in Γ)
  have h_L_sub_phiGamma : L ⊆ φ :: Γ := by
    intro ψ hψ
    by_cases hψφ : ψ = φ
    · simp [hψφ]
    · simp only [List.mem_cons]
      right
      exact List.mem_filter.mpr ⟨hψ, by simpa⟩
  -- Weaken derivation from L to φ :: Γ
  have d_bot' : DerivationTree (φ :: Γ) Formula.bot :=
    DerivationTree.weakening L (φ :: Γ) Formula.bot d_bot h_L_sub_phiGamma
  -- Now (φ :: Γ) ⊢ ⊥, so ¬Consistent (φ :: Γ)
  have h_phi_Gamma_incons : ¬Consistent (φ :: Γ) := fun h => h ⟨d_bot'⟩
  -- Apply derives_neg_from_inconsistent_extension to get Γ ⊢ ¬φ
  have h_neg := derives_neg_from_inconsistent_extension h_phi_Gamma_incons
  exact ⟨Γ, h_Γ_in_S, h_neg⟩

open Bimodal.Theorems.Propositional in
/--
Key property: A maximal consistent set contains φ or its negation.

This is essential for the truth lemma. The proof uses a classical argument:
if neither φ nor ¬φ is in S, then by maximality both `insert φ S` and
`insert ¬φ S` are inconsistent. From these, we extract derivations of ¬φ
and ¬¬φ from subsets of S, which (via DNE) yields both φ and ¬φ derivable
from S, contradicting SetConsistent S.
-/
theorem mcs_contains_or_neg {S : Set Formula} (h_mcs : SetMaximalConsistent S) (φ : Formula) :
    φ ∈ S ∨ Formula.neg φ ∈ S := by
  by_cases hφ : φ ∈ S
  · left; exact hφ
  · right
    by_contra hneg
    -- Both φ ∉ S and ¬φ ∉ S
    -- By maximality, insert φ S and insert ¬φ S are both inconsistent
    have h_incons_phi := h_mcs.2 φ hφ
    have h_incons_neg := h_mcs.2 (Formula.neg φ) hneg
    -- From h_incons_phi, get Γ₁ ⊆ S with Γ₁ ⊢ ¬φ
    obtain ⟨Γ₁, h_Γ₁_sub, ⟨d_neg_phi⟩⟩ := extract_neg_derivation h_incons_phi h_mcs.1
    -- From h_incons_neg, get Γ₂ ⊆ S with Γ₂ ⊢ ¬¬φ
    obtain ⟨Γ₂, h_Γ₂_sub, ⟨d_neg_neg_phi⟩⟩ := extract_neg_derivation h_incons_neg h_mcs.1
    -- Combine Γ₁ and Γ₂
    let Γ := Γ₁ ++ Γ₂
    have h_Γ_sub : ∀ ψ ∈ Γ, ψ ∈ S := by
      intro ψ hψ
      rcases List.mem_append.mp hψ with h | h
      · exact h_Γ₁_sub ψ h
      · exact h_Γ₂_sub ψ h
    -- Weaken both derivations to Γ
    have d_neg_phi' : DerivationTree Γ (Formula.neg φ) :=
      DerivationTree.weakening Γ₁ Γ _ d_neg_phi (List.subset_append_left Γ₁ Γ₂)
    have d_neg_neg_phi' : DerivationTree Γ (Formula.neg (Formula.neg φ)) :=
      DerivationTree.weakening Γ₂ Γ _ d_neg_neg_phi (List.subset_append_right Γ₁ Γ₂)
    -- Apply DNE to get Γ ⊢ φ
    have d_dne : DerivationTree [] ((Formula.neg (Formula.neg φ)).imp φ) := double_negation φ
    have d_dne' : DerivationTree Γ ((Formula.neg (Formula.neg φ)).imp φ) :=
      DerivationTree.weakening [] Γ _ d_dne (by simp)
    have d_phi : DerivationTree Γ φ := DerivationTree.modus_ponens Γ _ _ d_dne' d_neg_neg_phi'
    -- Combine φ and ¬φ to get ⊥
    have d_bot : DerivationTree Γ Formula.bot := derives_bot_from_phi_neg_phi d_phi d_neg_phi'
    -- This contradicts SetConsistent S
    have h_Γ_incons : ¬Consistent Γ := fun h => h ⟨d_bot⟩
    exact h_Γ_incons (h_mcs.1 Γ h_Γ_sub)

/--
Modus ponens for MCS: If (φ → ψ) ∈ S and φ ∈ S, then ψ ∈ S.

This follows from the negation completeness property: if ψ ∉ S, then ¬ψ ∈ S,
and combining φ, (φ → ψ), and ¬ψ yields a contradiction via modus ponens.
-/
theorem mcs_modus_ponens {S : Set Formula} (h_mcs : SetMaximalConsistent S)
    {φ ψ : Formula} (h_imp : Formula.imp φ ψ ∈ S) (h_ant : φ ∈ S) : ψ ∈ S := by
  by_contra hψ
  -- If ψ ∉ S, then ¬ψ ∈ S by mcs_contains_or_neg
  have h_or := mcs_contains_or_neg h_mcs ψ
  cases h_or with
  | inl h => exact hψ h
  | inr h_neg =>
    -- Now we have φ ∈ S, (φ → ψ) ∈ S, and ¬ψ ∈ S
    -- Build a derivation from [φ, φ.imp ψ, ψ.neg] that derives ⊥
    let L : List Formula := [φ, φ.imp ψ, ψ.neg]
    -- All elements of L are in S
    have h_L_sub : ∀ ψ' ∈ L, ψ' ∈ S := by
      intro ψ' hψ'
      simp only [L, List.mem_cons] at hψ'
      rcases hψ' with rfl | rfl | rfl | h
      · exact h_ant
      · exact h_imp
      · exact h_neg
      · simp at h
    -- Build membership proofs for explicit construction
    have h1 : φ ∈ L := by simp [L]
    have h2 : φ.imp ψ ∈ L := by simp [L]
    have h3 : ψ.neg ∈ L := by simp [L]
    -- Build derivations
    have d_phi : DerivationTree L φ := DerivationTree.assumption L φ h1
    have d_imp : DerivationTree L (φ.imp ψ) := DerivationTree.assumption L (φ.imp ψ) h2
    have d_psi : DerivationTree L ψ := DerivationTree.modus_ponens L _ _ d_imp d_phi
    have d_neg_psi : DerivationTree L ψ.neg := DerivationTree.assumption L ψ.neg h3
    have d_bot : DerivationTree L Formula.bot := derives_bot_from_phi_neg_phi d_psi d_neg_psi
    -- This shows ¬Consistent L
    have h_L_incons : ¬Consistent L := fun h => h ⟨d_bot⟩
    -- But all elements of L are in S, so L should be consistent
    have h_L_cons : Consistent L := h_mcs.1 L h_L_sub
    exact h_L_incons h_L_cons

/--
Box property for MCS: If □φ ∈ S and S is related to T, then φ ∈ T.

This is used in the canonical frame construction.
-/
theorem mcs_box_accessibility {S T : Set Formula}
    (_h_mcs_S : SetMaximalConsistent S) (_h_mcs_T : SetMaximalConsistent T)
    (h_rel : ∀ φ, Formula.box φ ∈ S → φ ∈ T) (φ : Formula) :
    Formula.box φ ∈ S → φ ∈ T := h_rel φ

end Bimodal.Metalogic_v2.Representation
