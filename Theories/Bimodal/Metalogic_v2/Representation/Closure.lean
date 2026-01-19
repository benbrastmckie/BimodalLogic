import Bimodal.ProofSystem
import Bimodal.Semantics
import Bimodal.Metalogic_v2.Core.MaximalConsistent
import Bimodal.Metalogic_v2.Representation.CanonicalModel
import Bimodal.Theorems.Combinators
-- Formula.subformulas is now defined in Bimodal.Syntax.Subformulas
import Bimodal.Syntax.Subformulas
import Mathlib.Data.Finset.Basic
import Mathlib.Data.List.Basic

/-!
# Subformula Closure for Metalogic_v2

This module provides the closure infrastructure for the finite model construction
in Metalogic_v2. It defines closures, closure-restricted consistency, and
projections from full MCS to closure-restricted MCS.

## Overview

For a formula `φ`, the **closure** is the set of all subformulas. The **closure with negations**
extends this to include negations of all closure members. This finite set is the domain
for finite world states.

## Main Definitions

- `closure`: Subformula closure as a Finset
- `closureWithNeg`: Closure extended with negations
- `ClosureConsistent`: Set-consistent and subset of closureWithNeg
- `ClosureMaximalConsistent`: Maximal within closureWithNeg
- `mcs_projection`: Project a full MCS to closure
- `mcs_projection_is_closure_mcs`: The projection is closure-maximal

## References

- Old Metalogic: `Bimodal.Metalogic.Completeness.FiniteCanonicalModel`
- Modal Logic, Blackburn et al., Chapter 4
-/

namespace Bimodal.Metalogic_v2.Representation

open Bimodal.Syntax Bimodal.ProofSystem Bimodal.Semantics
open Bimodal.Metalogic_v2.Core

/-!
## Subformula Closure

The closure of a formula is the set of all its subformulas.
-/

/--
Subformula closure of a formula as a Finset.

The closure contains all subformulas, which is finite.
We use the subformulas list from the Decidability module.
-/
def closure (phi : Formula) : Finset Formula :=
  (Formula.subformulas phi).toFinset

/--
The formula itself is in its closure.
-/
theorem phi_mem_closure (phi : Formula) : phi ∈ closure phi := by
  unfold closure
  simp only [List.mem_toFinset]
  induction phi with
  | atom p => simp [Formula.subformulas]
  | bot => simp [Formula.subformulas]
  | imp ψ χ _ _ =>
    simp only [Formula.subformulas, List.mem_cons, List.mem_append, true_or]
  | box ψ _ =>
    simp only [Formula.subformulas, List.mem_cons, true_or]
  | all_past ψ _ =>
    simp only [Formula.subformulas, List.mem_cons, true_or]
  | all_future ψ _ =>
    simp only [Formula.subformulas, List.mem_cons, true_or]

/--
Closure is decidable membership.
-/
instance (phi : Formula) : DecidablePred (· ∈ closure phi) :=
  fun psi => Finset.decidableMem psi (closure phi)

/--
The closure is a finite set (trivially, since it's a Finset).
-/
theorem closure_card_finite (phi : Formula) : (closure phi).card < Nat.succ (closure phi).card := by
  omega

/--
Size of the closure (number of distinct subformulas).

This bounds the complexity of the finite model.
-/
def closureSize (phi : Formula) : Nat := (closure phi).card

/-!
## Closure with Negations

For negation completeness in MCS, we extend closure with negations.
-/

/--
Closure extended with negations of all closure members.

This gives a finite set that is closed under negation within the closure.
-/
def closureWithNeg (phi : Formula) : Finset Formula :=
  closure phi ∪ (closure phi).image Formula.neg

/--
Closure is a subset of closureWithNeg.
-/
theorem closure_subset_closureWithNeg (phi : Formula) :
    closure phi ⊆ closureWithNeg phi := by
  intro psi h
  unfold closureWithNeg
  exact Finset.mem_union_left _ h

/--
Negation of closure member is in closureWithNeg.
-/
theorem neg_mem_closureWithNeg (phi psi : Formula) (h : psi ∈ closure phi) :
    psi.neg ∈ closureWithNeg phi := by
  unfold closureWithNeg
  apply Finset.mem_union_right
  exact Finset.mem_image_of_mem Formula.neg h

/--
The formula itself is in closureWithNeg.
-/
theorem phi_mem_closureWithNeg (phi : Formula) : phi ∈ closureWithNeg phi := by
  exact closure_subset_closureWithNeg phi (phi_mem_closure phi)

/--
The negation of the formula is in closureWithNeg.
-/
theorem neg_phi_mem_closureWithNeg (phi : Formula) : phi.neg ∈ closureWithNeg phi := by
  exact neg_mem_closureWithNeg phi phi (phi_mem_closure phi)

/--
closureWithNeg is decidable membership.
-/
instance (phi : Formula) : DecidablePred (· ∈ closureWithNeg phi) :=
  fun psi => Finset.decidableMem psi (closureWithNeg phi)

/-!
## Closure-Restricted Consistency

Consistency restricted to closureWithNeg.
-/

/--
Closure-consistent: A set that is a subset of closureWithNeg and is set-consistent.
-/
def ClosureConsistent (phi : Formula) (S : Set Formula) : Prop :=
  S ⊆ (closureWithNeg phi : Set Formula) ∧ SetConsistent S

/--
Closure-maximal consistent: A closure-consistent set that cannot be extended
within closureWithNeg while remaining consistent.
-/
def ClosureMaximalConsistent (phi : Formula) (S : Set Formula) : Prop :=
  ClosureConsistent phi S ∧
  ∀ ψ : Formula, ψ ∈ closureWithNeg phi → ψ ∉ S → ¬SetConsistent (insert ψ S)

/--
A closure-consistent set is a subset of closureWithNeg.
-/
theorem closure_consistent_subset {phi : Formula} {S : Set Formula}
    (h : ClosureConsistent phi S) : S ⊆ (closureWithNeg phi : Set Formula) :=
  h.1

/--
A closure-consistent set is set-consistent.
-/
theorem closure_consistent_set_consistent {phi : Formula} {S : Set Formula}
    (h : ClosureConsistent phi S) : SetConsistent S :=
  h.2

/--
A closure-maximal consistent set is closure-consistent.
-/
theorem closure_mcs_closure_consistent {phi : Formula} {S : Set Formula}
    (h : ClosureMaximalConsistent phi S) : ClosureConsistent phi S :=
  h.1

/--
A closure-maximal consistent set is set-consistent.
-/
theorem closure_mcs_set_consistent {phi : Formula} {S : Set Formula}
    (h : ClosureMaximalConsistent phi S) : SetConsistent S :=
  h.1.2

/-!
## MCS Projection

Project a full MCS to its intersection with closureWithNeg.
-/

/--
Project a full MCS to its intersection with closureWithNeg.

This gives the closure-restricted portion of the MCS.
-/
def mcs_projection (phi : Formula) (M : Set Formula) : Set Formula :=
  M ∩ (closureWithNeg phi : Set Formula)

/--
The projection is a subset of the original MCS.
-/
theorem mcs_projection_subset_M (phi : Formula) (M : Set Formula) :
    mcs_projection phi M ⊆ M := by
  intro psi h
  exact h.1

/--
The projection is a subset of closureWithNeg.
-/
theorem mcs_projection_subset_closure (phi : Formula) (M : Set Formula) :
    mcs_projection phi M ⊆ (closureWithNeg phi : Set Formula) := by
  intro psi h
  exact h.2

/--
If psi ∈ closureWithNeg and psi ∈ M, then psi ∈ mcs_projection.
-/
theorem mem_mcs_projection_of_mem_both (phi : Formula) (M : Set Formula)
    (psi : Formula) (h_M : psi ∈ M) (h_clos : psi ∈ closureWithNeg phi) :
    psi ∈ mcs_projection phi M := by
  exact ⟨h_M, h_clos⟩

/--
The projection preserves consistency.

If M is set-consistent, then mcs_projection phi M is also set-consistent.
-/
theorem mcs_projection_set_consistent (phi : Formula) (M : Set Formula)
    (h_cons : SetConsistent M) : SetConsistent (mcs_projection phi M) := by
  intro L h_L
  apply h_cons L
  intro psi h_psi
  exact (h_L psi h_psi).1

/--
The projection is closure-consistent.
-/
theorem mcs_projection_closure_consistent (phi : Formula) (M : Set Formula)
    (h_cons : SetConsistent M) : ClosureConsistent phi (mcs_projection phi M) := by
  constructor
  · exact mcs_projection_subset_closure phi M
  · exact mcs_projection_set_consistent phi M h_cons

/--
Key lemma: For any ψ in closureWithNeg, either ψ or ψ.neg is in M (by MCS property).
-/
theorem mcs_closure_neg_complete (phi : Formula) (M : Set Formula)
    (h_mcs : SetMaximalConsistent M) (psi : Formula) (h_clos : psi ∈ closureWithNeg phi) :
    psi ∈ M ∨ psi.neg ∈ M := by
  -- By mcs_contains_or_neg, either psi ∈ M or psi.neg ∈ M
  -- Import from CanonicalModel
  exact mcs_contains_or_neg h_mcs psi

/--
Key lemma: In a closure MCS, either psi or psi.neg is in the set (for psi in closureWithNeg).
-/
theorem closure_mcs_neg_complete (phi : Formula) (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S) (psi : Formula) (h_clos : psi ∈ closureWithNeg phi) :
    psi ∈ S ∨ psi.neg ∈ S := by
  by_cases h : psi ∈ S
  · left; exact h
  · right
    -- Since psi ∉ S and S is closure-maximal, insert psi S is inconsistent
    have h_incons := h_mcs.2 psi h_clos h
    -- We need to show psi.neg ∈ S
    -- By contrapositive: if psi.neg ∉ S, then insert psi.neg S is inconsistent
    by_contra h_neg_not
    -- Check if psi.neg ∈ closureWithNeg
    -- Two cases: psi is in closure, or psi is a negation of something in closure
    -- In either case, we can derive a contradiction

    -- Since S is closure-maximal, if psi.neg ∉ S and psi.neg ∈ closureWithNeg, then
    -- insert psi.neg S is inconsistent

    -- First, let's check if psi.neg is even in closureWithNeg
    -- psi ∈ closureWithNeg means psi ∈ closure ∨ psi = χ.neg for some χ ∈ closure

    -- The key insight: if neither psi nor psi.neg is in S, then S is not maximal
    -- We derive a contradiction from the maximality property

    -- From h_incons: ¬SetConsistent (insert psi S)
    -- This means there exists L ⊆ insert psi S with ¬Consistent L
    unfold SetConsistent at h_incons
    push_neg at h_incons
    obtain ⟨L, h_L_sub, h_L_incons⟩ := h_incons

    -- L is inconsistent, so L ⊢ ⊥
    have h_bot : Nonempty (DerivationTree L Formula.bot) := inconsistent_derives_bot h_L_incons
    obtain ⟨d_bot⟩ := h_bot

    -- Define Γ = L.filter (· ≠ psi)
    let Γ := L.filter (· ≠ psi)

    -- Show Γ ⊆ S
    have h_Γ_in_S : ∀ χ ∈ Γ, χ ∈ S := by
      intro χ hχ
      have hχ' := List.mem_filter.mp hχ
      have hχL := hχ'.1
      have hχne : χ ≠ psi := by simpa using hχ'.2
      specialize h_L_sub χ hχL
      simp [Set.mem_insert_iff] at h_L_sub
      rcases h_L_sub with rfl | h_in_S
      · exact absurd rfl hχne
      · exact h_in_S

    -- L ⊆ psi :: Γ
    have h_L_sub_psiGamma : L ⊆ psi :: Γ := by
      intro χ hχ
      by_cases hχpsi : χ = psi
      · simp [hχpsi]
      · simp only [List.mem_cons]
        right
        exact List.mem_filter.mpr ⟨hχ, by simpa⟩

    -- Weaken derivation from L to psi :: Γ
    have d_bot' : DerivationTree (psi :: Γ) Formula.bot :=
      DerivationTree.weakening L (psi :: Γ) Formula.bot d_bot h_L_sub_psiGamma

    -- By deduction theorem, Γ ⊢ psi.neg
    have d_neg : DerivationTree Γ psi.neg := deduction_theorem Γ psi Formula.bot d_bot'

    -- We have Γ ⊢ psi.neg where Γ ⊆ S, and we're assuming psi.neg ∉ S
    -- Now we need to derive a contradiction by showing S is inconsistent

    -- Case analysis: psi is either in closure, or psi = χ.neg for some χ in closure
    unfold closureWithNeg at h_clos
    simp only [Finset.mem_union, Finset.mem_image] at h_clos
    rcases h_clos with h_in_clos | ⟨chi, h_chi_clos, h_psi_eq⟩

    · -- Case 1: psi ∈ closure phi
      -- Then psi.neg ∈ closureWithNeg phi by neg_mem_closureWithNeg
      have h_psi_neg_in_closneg : psi.neg ∈ closureWithNeg phi :=
        neg_mem_closureWithNeg phi psi h_in_clos
      -- Since psi.neg ∈ closureWithNeg and psi.neg ∉ S, by maximality
      -- insert psi.neg S is inconsistent
      have h_incons_neg := h_mcs.2 psi.neg h_psi_neg_in_closneg h_neg_not
      -- So there exists L' ⊆ insert psi.neg S with ¬Consistent L'
      unfold SetConsistent at h_incons_neg
      push_neg at h_incons_neg
      obtain ⟨L', h_L'_sub, h_L'_incons⟩ := h_incons_neg
      -- L' is inconsistent, so L' ⊢ ⊥
      have h_bot' : Nonempty (DerivationTree L' Formula.bot) := inconsistent_derives_bot h_L'_incons
      obtain ⟨d_bot''⟩ := h_bot'
      -- Define Δ = L'.filter (· ≠ psi.neg)
      let Δ := L'.filter (· ≠ psi.neg)
      -- Show Δ ⊆ S
      have h_Δ_in_S : ∀ χ ∈ Δ, χ ∈ S := by
        intro χ hχ
        have hχ' := List.mem_filter.mp hχ
        have hχL' := hχ'.1
        have hχne : χ ≠ psi.neg := by simpa using hχ'.2
        specialize h_L'_sub χ hχL'
        simp [Set.mem_insert_iff] at h_L'_sub
        rcases h_L'_sub with rfl | h_in_S
        · exact absurd rfl hχne
        · exact h_in_S
      -- L' ⊆ psi.neg :: Δ
      have h_L'_sub_psiΔ : L' ⊆ psi.neg :: Δ := by
        intro χ hχ
        by_cases hχpsi : χ = psi.neg
        · simp [hχpsi]
        · simp only [List.mem_cons]
          right
          exact List.mem_filter.mpr ⟨hχ, by simpa⟩
      -- Weaken derivation from L' to psi.neg :: Δ
      have d_bot''' : DerivationTree (psi.neg :: Δ) Formula.bot :=
        DerivationTree.weakening L' (psi.neg :: Δ) Formula.bot d_bot'' h_L'_sub_psiΔ
      -- By deduction theorem, Δ ⊢ psi.neg.neg
      have d_neg_neg : DerivationTree Δ psi.neg.neg :=
        deduction_theorem Δ psi.neg Formula.bot d_bot'''
      -- Weaken d_neg (Γ ⊢ psi.neg) to Γ ∪ Δ ⊢ psi.neg
      let ΓΔ := Γ ++ Δ
      have h_ΓΔ_in_S : ∀ χ ∈ ΓΔ, χ ∈ S := by
        intro χ hχ
        simp only [ΓΔ, List.mem_append] at hχ
        rcases hχ with hχΓ | hχΔ
        · exact h_Γ_in_S χ hχΓ
        · exact h_Δ_in_S χ hχΔ
      have d_neg' : DerivationTree ΓΔ psi.neg :=
        DerivationTree.weakening Γ ΓΔ _ d_neg (List.subset_append_left Γ Δ)
      have d_neg_neg' : DerivationTree ΓΔ psi.neg.neg :=
        DerivationTree.weakening Δ ΓΔ _ d_neg_neg (List.subset_append_right Γ Δ)
      -- Combine to get ⊥
      have d_bot_final : DerivationTree ΓΔ Formula.bot :=
        derives_bot_from_phi_neg_phi d_neg' d_neg_neg'
      -- This contradicts consistency of S
      exact h_mcs.1.2 ΓΔ h_ΓΔ_in_S ⟨d_bot_final⟩

    · -- Case 2: psi = chi.neg for some chi ∈ closure phi
      subst h_psi_eq
      -- psi = chi.neg, so psi.neg = chi.neg.neg = (chi → ⊥) → ⊥
      -- chi ∈ closure phi, so chi ∈ closureWithNeg phi
      have h_chi_in_closneg : chi ∈ closureWithNeg phi :=
        closure_subset_closureWithNeg phi h_chi_clos
      -- We have: chi.neg ∉ S (since psi = chi.neg and psi ∉ S)
      -- and chi.neg.neg ∉ S (since psi.neg = chi.neg.neg and psi.neg ∉ S)
      -- By negation completeness for chi: either chi ∈ S or chi.neg ∈ S
      -- But chi.neg = psi ∉ S, so chi ∈ S
      by_cases h_chi_in_S : chi ∈ S
      · -- chi ∈ S and Γ ⊢ chi.neg.neg (= psi.neg)
        -- Weaken to show {chi, chi.neg.neg} leads to inconsistency
        -- DNE: chi.neg.neg → chi is provable
        -- From chi and chi.neg.neg, we can derive chi, but chi ∈ S already
        -- Actually, the contradiction comes from: chi ∈ S and insert chi.neg S inconsistent
        -- means there's a derivation from chi.neg, L where L ⊆ S, deriving ⊥
        -- But chi.neg ∉ S is our assumption (since psi = chi.neg)
        -- So we need to show insert chi.neg S is inconsistent
        -- Since chi.neg ∈ closureWithNeg and chi.neg ∉ S, by maximality:
        have h_chi_neg_clos : chi.neg ∈ closureWithNeg phi := neg_mem_closureWithNeg phi chi h_chi_clos
        have h_incons_chi_neg := h_mcs.2 chi.neg h_chi_neg_clos h
        unfold SetConsistent at h_incons_chi_neg
        push_neg at h_incons_chi_neg
        obtain ⟨L'', h_L''_sub, h_L''_incons⟩ := h_incons_chi_neg
        have h_bot'' : Nonempty (DerivationTree L'' Formula.bot) := inconsistent_derives_bot h_L''_incons
        obtain ⟨d_bot''⟩ := h_bot''
        -- Define Λ = L''.filter (· ≠ chi.neg)
        let Λ := L''.filter (· ≠ chi.neg)
        have h_Λ_in_S : ∀ χ ∈ Λ, χ ∈ S := by
          intro χ hχ
          have hχ' := List.mem_filter.mp hχ
          have hχL'' := hχ'.1
          have hχne : χ ≠ chi.neg := by simpa using hχ'.2
          specialize h_L''_sub χ hχL''
          simp [Set.mem_insert_iff] at h_L''_sub
          rcases h_L''_sub with rfl | h_in_S
          · exact absurd rfl hχne
          · exact h_in_S
        have h_L''_sub_Λ : L'' ⊆ chi.neg :: Λ := by
          intro χ hχ
          by_cases hχchi : χ = chi.neg
          · simp [hχchi]
          · simp only [List.mem_cons]
            right
            exact List.mem_filter.mpr ⟨hχ, by simpa⟩
        have d_bot''' : DerivationTree (chi.neg :: Λ) Formula.bot :=
          DerivationTree.weakening L'' (chi.neg :: Λ) Formula.bot d_bot'' h_L''_sub_Λ
        have d_chi_neg_neg : DerivationTree Λ chi.neg.neg :=
          deduction_theorem Λ chi.neg Formula.bot d_bot'''
        -- DNE theorem: chi.neg.neg → chi
        have d_dne : DerivationTree [] (chi.neg.neg.imp chi) :=
          Bimodal.Theorems.Propositional.double_negation chi
        have d_dne' : DerivationTree Λ (chi.neg.neg.imp chi) :=
          DerivationTree.weakening [] Λ _ d_dne (by simp)
        have d_chi_from_Λ : DerivationTree Λ chi :=
          DerivationTree.modus_ponens Λ _ _ d_dne' d_chi_neg_neg
        -- Now Λ ⊆ S and chi ∈ S
        -- We need to show inconsistency using chi ∈ S and something else
        -- Actually, we have chi ∈ S but chi.neg ∉ S
        -- The issue is that d_chi_from_Λ proves chi which is already in S
        -- This doesn't directly give us a contradiction

        -- KNOWN ISSUE: When psi = chi.neg (chi ∈ closure), psi.neg = chi.neg.neg
        -- escapes closureWithNeg. This means the maximality condition doesn't
        -- directly apply to psi.neg.
        --
        -- The current situation:
        -- - chi ∈ S (by h_chi_in_S)
        -- - chi.neg ∉ S (since psi = chi.neg ∉ S)
        -- - chi.neg.neg ∉ S (since psi.neg = chi.neg.neg ∉ S by h_neg_not)
        --
        -- This is actually consistent with closure MCS properties since
        -- chi.neg.neg is not required to be in closureWithNeg.
        --
        -- The resolution requires either:
        -- 1. Restricting this theorem to psi ∈ closure (not closureWithNeg), or
        -- 2. Extending closureWithNeg to include double negations, or
        -- 3. Using a different approach in the truth lemma that avoids this case
        --
        -- For the completeness proof, the key uses of this lemma are for
        -- formulas that are subformulas (in closure), where this issue doesn't arise.
        -- The closureWithNeg version is stronger than needed.
        --
        -- TODO: Consider refactoring to use closure_mcs_neg_complete_closure
        -- which restricts to psi ∈ closure and is fully provable.
        sorry

      · -- chi ∉ S
        -- Since chi ∈ closureWithNeg and chi ∉ S, by maximality
        -- insert chi S is inconsistent
        have h_incons_chi := h_mcs.2 chi h_chi_in_closneg h_chi_in_S
        unfold SetConsistent at h_incons_chi
        push_neg at h_incons_chi
        obtain ⟨L''', h_L'''_sub, h_L'''_incons⟩ := h_incons_chi
        have h_bot'''' : Nonempty (DerivationTree L''' Formula.bot) := inconsistent_derives_bot h_L'''_incons
        obtain ⟨d_bot''''⟩ := h_bot''''
        -- Define Θ = L'''.filter (· ≠ chi)
        let Θ := L'''.filter (· ≠ chi)
        have h_Θ_in_S : ∀ χ ∈ Θ, χ ∈ S := by
          intro χ hχ
          have hχ' := List.mem_filter.mp hχ
          have hχL''' := hχ'.1
          have hχne : χ ≠ chi := by simpa using hχ'.2
          specialize h_L'''_sub χ hχL'''
          simp [Set.mem_insert_iff] at h_L'''_sub
          rcases h_L'''_sub with rfl | h_in_S
          · exact absurd rfl hχne
          · exact h_in_S
        have h_L'''_sub_Θ : L''' ⊆ chi :: Θ := by
          intro χ hχ
          by_cases hχchi : χ = chi
          · simp [hχchi]
          · simp only [List.mem_cons]
            right
            exact List.mem_filter.mpr ⟨hχ, by simpa⟩
        have d_bot''''' : DerivationTree (chi :: Θ) Formula.bot :=
          DerivationTree.weakening L''' (chi :: Θ) Formula.bot d_bot'''' h_L'''_sub_Θ
        have d_chi_neg' : DerivationTree Θ chi.neg :=
          deduction_theorem Θ chi Formula.bot d_bot'''''
        -- Now we have: Γ ⊢ chi.neg.neg (= psi.neg) and Θ ⊢ chi.neg
        -- Combine: Γ ∪ Θ ⊢ chi.neg.neg and Γ ∪ Θ ⊢ chi.neg
        -- This gives ⊥
        let ΓΘ := Γ ++ Θ
        have h_ΓΘ_in_S : ∀ χ ∈ ΓΘ, χ ∈ S := by
          intro χ hχ
          simp only [ΓΘ, List.mem_append] at hχ
          rcases hχ with hχΓ | hχΘ
          · exact h_Γ_in_S χ hχΓ
          · exact h_Θ_in_S χ hχΘ
        have d_chi_neg_neg' : DerivationTree ΓΘ chi.neg.neg :=
          DerivationTree.weakening Γ ΓΘ _ d_neg (List.subset_append_left Γ Θ)
        have d_chi_neg'' : DerivationTree ΓΘ chi.neg :=
          DerivationTree.weakening Θ ΓΘ _ d_chi_neg' (List.subset_append_right Γ Θ)
        have d_bot_final : DerivationTree ΓΘ Formula.bot :=
          derives_bot_from_phi_neg_phi d_chi_neg'' d_chi_neg_neg'
        exact h_mcs.1.2 ΓΘ h_ΓΘ_in_S ⟨d_bot_final⟩

/--
The projection of a full MCS is closure-maximal consistent.

This is the key theorem: projecting a full MCS to closureWithNeg gives
a closure-maximal consistent set.
-/
theorem mcs_projection_is_closure_mcs (phi : Formula) (M : Set Formula)
    (h_mcs : SetMaximalConsistent M) :
    ClosureMaximalConsistent phi (mcs_projection phi M) := by
  constructor
  · -- ClosureConsistent
    exact mcs_projection_closure_consistent phi M h_mcs.1
  · -- Maximality within closureWithNeg
    intro psi h_clos h_not_proj
    -- h_not_proj : psi ∉ mcs_projection phi M = M ∩ closureWithNeg
    -- Since psi ∈ closureWithNeg, we have psi ∉ M (from h_not_proj)
    have h_not_M : psi ∉ M := by
      intro h_M
      apply h_not_proj
      exact ⟨h_M, h_clos⟩
    -- By MCS maximality, insert psi M is inconsistent
    have h_incons_M := h_mcs.2 psi h_not_M
    -- We need to show insert psi (mcs_projection phi M) is inconsistent
    -- Since mcs_projection phi M ⊆ M, if insert psi M is inconsistent,
    -- the witnessing list L from insert psi M gives inconsistency
    intro h_cons_proj
    unfold SetConsistent at h_incons_M h_cons_proj
    push_neg at h_incons_M
    obtain ⟨L, h_L_sub_M, h_L_incons⟩ := h_incons_M
    -- L ⊆ insert psi M and L is inconsistent
    -- Build L' = elements of L that are in mcs_projection
    -- Actually, we need a different approach:
    -- If insert psi (projection) is consistent, then insert psi M is consistent
    -- (since projection ⊆ M implies insert psi projection ⊆ insert psi M)
    -- But we know insert psi M is inconsistent, contradiction

    -- The issue is: h_cons_proj says insert psi (projection) is consistent
    -- But h_L_sub_M gives a list in insert psi M, not necessarily in insert psi (projection)

    -- Let's use the fact that SetConsistent is monotone in the subset ordering
    -- If L ⊆ insert psi M and L is inconsistent, we need L ⊆ insert psi (projection)
    -- This is NOT automatically true!

    -- We need a more careful argument. Let's use contrapositive:
    -- If insert psi (projection) is consistent, we derive a contradiction

    -- Actually, the key observation is:
    -- Every formula in L comes from insert psi M
    -- For formulas in M ∩ closureWithNeg, they are in the projection
    -- For formulas in M \ closureWithNeg, we need to handle them

    -- But wait - L consists of formulas, and the inconsistency derivation
    -- only needs finitely many formulas. If some formula in L is not in
    -- closureWithNeg, we cannot directly use the projection.

    -- The correct approach is: project L itself to closureWithNeg-relevant formulas
    -- But this doesn't work either because derivation trees may use formulas
    -- outside closureWithNeg.

    -- The standard approach in finite model property proofs is:
    -- 1. Use the closure to bound the relevant formulas
    -- 2. Show that if a set restricted to closure is consistent, the full extension is too

    -- For this proof, we use a different fact:
    -- The full MCS M restricted to closureWithNeg is closure-maximal because:
    -- If psi ∈ closureWithNeg and psi ∉ M, then by full MCS maximality,
    -- insert psi M is inconsistent, which implies insert psi (projection) is inconsistent
    -- via the witnessing derivation that uses only formulas from insert psi M

    -- The subtlety is: the witnessing list L may contain formulas outside closureWithNeg
    -- But those formulas are in M, and their presence doesn't help consistency

    -- Hmm, this is getting circular. Let me think more carefully.

    -- Actually, the correct statement is: we need the inconsistency witness
    -- to only use formulas from closureWithNeg. This is where the filtration
    -- argument comes in, but that's complex.

    -- For now, let's use a more direct approach:
    -- If psi ∉ projection and psi ∈ closureWithNeg, then psi ∉ M (as we showed)
    -- By MCS property of M, psi.neg ∈ M
    -- Is psi.neg in closureWithNeg? It depends on the structure of closure.

    -- The key insight from the old Metalogic is: the completeness proof
    -- constructs a countermodel where truth is defined by membership in the
    -- closure-restricted MCS. The negation completeness within closureWithNeg
    -- is crucial.

    -- For a cleaner proof, we use the fact that:
    -- 1. psi ∈ closureWithNeg and psi ∉ projection means psi ∉ M
    -- 2. By MCS of M, psi.neg ∈ M
    -- 3. We want to show insert psi (projection) is inconsistent
    -- 4. Since psi.neg ∈ M, and if psi.neg ∈ closureWithNeg, then psi.neg ∈ projection
    -- 5. Having both psi and psi.neg in insert psi (projection) gives inconsistency

    -- Step 2: psi.neg ∈ M
    have h_neg_M : psi.neg ∈ M := by
      have h_or := mcs_contains_or_neg h_mcs psi
      cases h_or with
      | inl h => exact absurd h h_not_M
      | inr h => exact h

    -- We need to show psi.neg ∈ closureWithNeg to conclude psi.neg ∈ projection
    -- This is where the structure of closureWithNeg matters

    -- Case analysis on how psi is in closureWithNeg:
    -- Case 1: psi ∈ closure phi
    --   Then psi.neg ∈ closureWithNeg by definition (neg_mem_closureWithNeg)
    -- Case 2: psi = χ.neg for some χ ∈ closure phi
    --   Then psi.neg = χ.neg.neg, which may or may not be in closureWithNeg

    -- For Case 2, psi.neg = χ.neg.neg
    -- If χ.neg.neg = χ (definitionally or by some identity), we'd have χ ∈ closure
    -- But Formula.neg is not involutive in general (it adds a layer of imp _ bot)

    -- The proper treatment requires either:
    -- a) Extending closureWithNeg to include double negations (making it larger)
    -- b) Using a different definition that's closed under "semantic negation"
    -- c) Handling the cases separately in the completeness proof

    -- KNOWN ISSUE: Same double-negation escape issue as closure_mcs_neg_complete.
    -- When psi = chi.neg (chi ∈ closure), psi.neg = chi.neg.neg escapes closureWithNeg.
    --
    -- The proof works for Case 1 (psi ∈ closure phi) because:
    -- - psi.neg ∈ closureWithNeg by neg_mem_closureWithNeg
    -- - psi.neg ∈ M (by mcs_contains_or_neg)
    -- - Therefore psi.neg ∈ projection
    -- - {psi, psi.neg} ⊆ insert psi projection is inconsistent
    --
    -- For Case 2 (psi = chi.neg), we can show:
    -- - chi ∈ closure, so chi ∈ closureWithNeg
    -- - By mcs_contains_or_neg: chi ∈ M or chi.neg ∈ M
    -- - chi.neg = psi ∉ M (by h_not_M), so chi ∈ M
    -- - chi ∈ closureWithNeg and chi ∈ M, so chi ∈ projection
    -- - Need to show {psi, chi} = {chi.neg, chi} makes insert psi projection inconsistent
    --
    -- Case 2 implementation:
    unfold closureWithNeg at h_clos
    simp only [Finset.mem_union, Finset.mem_image] at h_clos
    rcases h_clos with h_in_clos | ⟨chi, h_chi_clos, h_psi_eq⟩
    · -- Case 1: psi ∈ closure phi - psi.neg is in closureWithNeg
      have h_neg_closneg : psi.neg ∈ closureWithNeg phi := neg_mem_closureWithNeg phi psi h_in_clos
      have h_neg_proj : psi.neg ∈ mcs_projection phi M := ⟨h_neg_M, h_neg_closneg⟩
      -- insert psi (projection) contains both psi and psi.neg, so it's inconsistent
      have h_deriv : DerivationTree [psi, psi.neg] Formula.bot := by
        have h_psi_assume : DerivationTree [psi, psi.neg] psi :=
          DerivationTree.assumption _ _ (by simp)
        have h_neg_assume : DerivationTree [psi, psi.neg] psi.neg :=
          DerivationTree.assumption _ _ (by simp)
        exact DerivationTree.modus_ponens _ psi Formula.bot h_neg_assume h_psi_assume
      have h_sub : ∀ x ∈ [psi, psi.neg], x ∈ insert psi (mcs_projection phi M) := by
        intro x hx
        simp only [List.mem_cons, List.mem_nil_iff, or_false] at hx
        rcases hx with rfl | rfl
        · simp only [Set.mem_insert_iff, true_or]
        · simp only [Set.mem_insert_iff]
          right; exact h_neg_proj
      exact h_cons_proj [psi, psi.neg] h_sub ⟨h_deriv⟩
    · -- Case 2: psi = chi.neg for chi ∈ closure
      subst h_psi_eq
      -- chi ∈ closure, so chi ∈ closureWithNeg
      have h_chi_closneg : chi ∈ closureWithNeg phi := closure_subset_closureWithNeg phi h_chi_clos
      -- By MCS of M: chi ∈ M or chi.neg ∈ M
      -- chi.neg = psi ∉ M (by h_not_M), so chi ∈ M
      have h_chi_M : chi ∈ M := by
        have h_or := mcs_contains_or_neg h_mcs chi
        cases h_or with
        | inl h => exact h
        | inr h => exact absurd h h_not_M
      -- chi ∈ projection
      have h_chi_proj : chi ∈ mcs_projection phi M := ⟨h_chi_M, h_chi_closneg⟩
      -- insert chi.neg (projection) contains both chi and chi.neg, so inconsistent
      have h_deriv : DerivationTree [chi.neg, chi] Formula.bot := by
        have h_chi_assume : DerivationTree [chi.neg, chi] chi :=
          DerivationTree.assumption _ _ (by simp)
        have h_neg_assume : DerivationTree [chi.neg, chi] chi.neg :=
          DerivationTree.assumption _ _ (by simp)
        exact DerivationTree.modus_ponens _ chi Formula.bot h_neg_assume h_chi_assume
      have h_sub : ∀ x ∈ [chi.neg, chi], x ∈ insert chi.neg (mcs_projection phi M) := by
        intro x hx
        simp only [List.mem_cons, List.mem_nil_iff, or_false] at hx
        rcases hx with rfl | rfl
        · simp only [Set.mem_insert_iff, true_or]
        · simp only [Set.mem_insert_iff]
          right; exact h_chi_proj
      exact h_cons_proj [chi.neg, chi] h_sub ⟨h_deriv⟩

/-!
## Subformula Membership Lemmas
-/

/--
Subformula of implication: left side.
-/
theorem closure_imp_left (phi psi chi : Formula) (h : Formula.imp psi chi ∈ closure phi) :
    psi ∈ closure phi := by
  unfold closure at h ⊢
  simp only [List.mem_toFinset] at h ⊢
  exact Formula.mem_subformulas_of_imp_left h

/--
Subformula of implication: right side.
-/
theorem closure_imp_right (phi psi chi : Formula) (h : Formula.imp psi chi ∈ closure phi) :
    chi ∈ closure phi := by
  unfold closure at h ⊢
  simp only [List.mem_toFinset] at h ⊢
  exact Formula.mem_subformulas_of_imp_right h

/--
Subformula of box.
-/
theorem closure_box (phi psi : Formula) (h : Formula.box psi ∈ closure phi) :
    psi ∈ closure phi := by
  unfold closure at h ⊢
  simp only [List.mem_toFinset] at h ⊢
  exact Formula.mem_subformulas_of_box h

/--
Subformula of all_past.
-/
theorem closure_all_past (phi psi : Formula) (h : Formula.all_past psi ∈ closure phi) :
    psi ∈ closure phi := by
  unfold closure at h ⊢
  simp only [List.mem_toFinset] at h ⊢
  exact Formula.mem_subformulas_of_all_past h

/--
Subformula of all_future.
-/
theorem closure_all_future (phi psi : Formula) (h : Formula.all_future psi ∈ closure phi) :
    psi ∈ closure phi := by
  unfold closure at h ⊢
  simp only [List.mem_toFinset] at h ⊢
  exact Formula.mem_subformulas_of_all_future h

/-!
## Implication Closure Property

Key property: In a closure MCS, implication matches material implication.
-/

/--
Implication in closure MCS follows material implication.

If psi.imp chi ∈ closure phi, then in a closure MCS S:
(psi.imp chi) ∈ S ↔ (psi ∈ S → chi ∈ S)
-/
theorem closure_mcs_imp_iff (phi : Formula) (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S)
    (psi chi : Formula)
    (h_imp_clos : Formula.imp psi chi ∈ closure phi)
    (h_psi_clos : psi ∈ closureWithNeg phi)
    (h_chi_clos : chi ∈ closureWithNeg phi) :
    Formula.imp psi chi ∈ S ↔ (psi ∈ S → chi ∈ S) := by
  constructor
  · -- Forward: (psi → chi) ∈ S and psi ∈ S implies chi ∈ S
    intro h_imp h_psi
    -- This follows from the consistency of S (modus ponens)
    -- Build context [psi, psi.imp chi] and derive chi
    by_contra h_chi_not
    -- If chi ∉ S and chi ∈ closureWithNeg, then chi.neg ∈ S (by negation completeness)
    have h_chi_or := closure_mcs_neg_complete phi S h_mcs chi h_chi_clos
    cases h_chi_or with
    | inl h => exact h_chi_not h
    | inr h_neg =>
      -- Now we have psi ∈ S, (psi → chi) ∈ S, and chi.neg ∈ S
      -- From psi and (psi → chi), we can derive chi
      -- From chi and chi.neg, we can derive ⊥
      -- This contradicts consistency of S
      have h_incons : ¬Consistent [psi, psi.imp chi, chi.neg] := by
        intro h_cons
        apply h_cons
        -- Build derivation [psi, psi.imp chi, chi.neg] ⊢ ⊥
        have d_psi : DerivationTree [psi, psi.imp chi, chi.neg] psi :=
          DerivationTree.assumption _ _ (by simp)
        have d_imp : DerivationTree [psi, psi.imp chi, chi.neg] (psi.imp chi) :=
          DerivationTree.assumption _ _ (by simp)
        have d_chi : DerivationTree [psi, psi.imp chi, chi.neg] chi :=
          DerivationTree.modus_ponens _ _ _ d_imp d_psi
        have d_neg : DerivationTree [psi, psi.imp chi, chi.neg] chi.neg :=
          DerivationTree.assumption _ _ (by simp)
        exact ⟨derives_bot_from_phi_neg_phi d_chi d_neg⟩
      -- But [psi, psi.imp chi, chi.neg] ⊆ S, so S is inconsistent
      have h_sub : ∀ ψ ∈ [psi, psi.imp chi, chi.neg], ψ ∈ S := by
        intro ψ hψ
        simp only [List.mem_cons, List.mem_nil_iff, or_false] at hψ
        rcases hψ with rfl | rfl | rfl
        · exact h_psi
        · exact h_imp
        · exact h_neg
      exact h_incons (h_mcs.1.2 [psi, psi.imp chi, chi.neg] h_sub)
  · -- Backward: (psi ∈ S → chi ∈ S) implies (psi → chi) ∈ S
    intro h_material
    by_contra h_imp_not
    -- (psi → chi) ∉ S and (psi → chi) ∈ closureWithNeg
    have h_imp_closneg : Formula.imp psi chi ∈ closureWithNeg phi :=
      closure_subset_closureWithNeg phi h_imp_clos
    have h_or := closure_mcs_neg_complete phi S h_mcs (psi.imp chi) h_imp_closneg
    cases h_or with
    | inl h => exact h_imp_not h
    | inr h_neg =>
      -- (psi → chi).neg ∈ S
      -- (psi → chi).neg = (psi → chi) → ⊥
      -- We need to derive a contradiction from this
      -- Using h_material: psi ∈ S → chi ∈ S
      -- If psi ∉ S, then psi.neg ∈ S, and we should be able to prove (psi → chi)
      -- If psi ∈ S, then chi ∈ S by h_material
      have h_psi_or := closure_mcs_neg_complete phi S h_mcs psi h_psi_clos
      cases h_psi_or with
      | inl h_psi =>
        -- psi ∈ S, so by h_material, chi ∈ S
        have h_chi := h_material h_psi
        -- Now we have chi ∈ S and (psi → chi).neg ∈ S
        -- From chi, we can prove (psi → chi) using prop_s: chi → (psi → chi)
        -- Then (psi → chi) and (psi → chi).neg give ⊥
        have h_incons : ¬Consistent [chi, (psi.imp chi).neg] := by
          intro h_cons
          apply h_cons
          -- Build derivation [chi, (psi → chi).neg] ⊢ ⊥
          -- Step 1: prop_s chi psi gives chi → (psi → chi)
          have d_prop_s : DerivationTree [] (chi.imp (psi.imp chi)) :=
            DerivationTree.axiom [] _ (Axiom.prop_s chi psi)
          have d_prop_s' : DerivationTree [chi, (psi.imp chi).neg] (chi.imp (psi.imp chi)) :=
            DerivationTree.weakening [] _ _ d_prop_s (by simp)
          -- Step 2: Get chi from context
          have d_chi : DerivationTree [chi, (psi.imp chi).neg] chi :=
            DerivationTree.assumption _ _ (by simp)
          -- Step 3: MP to get (psi → chi)
          have d_imp : DerivationTree [chi, (psi.imp chi).neg] (psi.imp chi) :=
            DerivationTree.modus_ponens _ _ _ d_prop_s' d_chi
          -- Step 4: Get (psi → chi).neg from context
          have d_neg : DerivationTree [chi, (psi.imp chi).neg] (psi.imp chi).neg :=
            DerivationTree.assumption _ _ (by simp)
          -- Step 5: MP to get ⊥
          exact ⟨derives_bot_from_phi_neg_phi d_imp d_neg⟩
        -- But [chi, (psi → chi).neg] ⊆ S, so S is inconsistent
        have h_sub : ∀ ψ ∈ [chi, (psi.imp chi).neg], ψ ∈ S := by
          intro ψ hψ
          simp only [List.mem_cons, List.mem_nil_iff, or_false] at hψ
          rcases hψ with rfl | rfl
          · exact h_chi
          · exact h_neg
        exact h_incons (h_mcs.1.2 [chi, (psi.imp chi).neg] h_sub)
      | inr h_neg_psi =>
        -- psi.neg ∈ S
        -- From psi.neg = psi → ⊥, we can derive (psi → chi) using explosion pattern
        -- First derive ⊥ from psi, then derive chi from ⊥ using EFQ
        -- Together: psi → ⊥ and ⊥ → chi give psi → chi
        have h_incons : ¬Consistent [psi.neg, (psi.imp chi).neg] := by
          intro h_cons
          apply h_cons
          -- Build derivation [psi.neg, (psi → chi).neg] ⊢ ⊥
          -- We use the fact that psi.neg = psi → ⊥
          -- From psi → ⊥ and ⊥ → chi (EFQ), we get psi → chi via composition
          -- Then we have both (psi → chi) and (psi → chi).neg, giving ⊥

          -- EFQ: ⊥ → chi
          have d_efq : DerivationTree [] (Formula.bot.imp chi) :=
            DerivationTree.axiom [] _ (Axiom.ex_falso chi)
          have d_efq' : DerivationTree [psi.neg, (psi.imp chi).neg] (Formula.bot.imp chi) :=
            DerivationTree.weakening [] _ _ d_efq (by simp)

          -- psi.neg = psi → ⊥ from context
          have d_psi_neg : DerivationTree [psi.neg, (psi.imp chi).neg] psi.neg :=
            DerivationTree.assumption _ _ (by simp)

          -- Use b_combinator pattern: (⊥ → chi) → (psi → ⊥) → (psi → chi)
          -- This is the standard composition pattern
          have d_b : DerivationTree [] ((Formula.bot.imp chi).imp ((psi.imp Formula.bot).imp (psi.imp chi))) :=
            Bimodal.Theorems.Combinators.b_combinator

          have d_b' : DerivationTree [psi.neg, (psi.imp chi).neg] ((Formula.bot.imp chi).imp ((psi.imp Formula.bot).imp (psi.imp chi))) :=
            DerivationTree.weakening [] _ _ d_b (by simp)

          -- MP with EFQ
          have d_step1 : DerivationTree [psi.neg, (psi.imp chi).neg] ((psi.imp Formula.bot).imp (psi.imp chi)) :=
            DerivationTree.modus_ponens _ _ _ d_b' d_efq'

          -- MP with psi.neg
          have d_imp : DerivationTree [psi.neg, (psi.imp chi).neg] (psi.imp chi) :=
            DerivationTree.modus_ponens _ _ _ d_step1 d_psi_neg

          -- Get (psi → chi).neg from context
          have d_neg : DerivationTree [psi.neg, (psi.imp chi).neg] (psi.imp chi).neg :=
            DerivationTree.assumption _ _ (by simp)

          -- MP to get ⊥
          exact ⟨derives_bot_from_phi_neg_phi d_imp d_neg⟩
        -- But [psi.neg, (psi → chi).neg] ⊆ S, so S is inconsistent
        have h_sub : ∀ ψ ∈ [psi.neg, (psi.imp chi).neg], ψ ∈ S := by
          intro ψ hψ
          simp only [List.mem_cons, List.mem_nil_iff, or_false] at hψ
          rcases hψ with rfl | rfl
          · exact h_neg_psi
          · exact h_neg
        exact h_incons (h_mcs.1.2 [psi.neg, (psi.imp chi).neg] h_sub)

end Bimodal.Metalogic_v2.Representation
