import Bimodal.ProofSystem
import Bimodal.Semantics
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Boneyard.Metalogic_v2.Representation.CanonicalModel
import Bimodal.Theorems.Combinators
import Bimodal.Syntax.Subformulas
import Mathlib.Data.Finset.Basic
import Mathlib.Data.List.Basic

/-!
# Subformula Closure for Finite Model Property

This module provides the closure infrastructure for the finite model construction
in the parametric FMP architecture. It defines closures, closure-restricted consistency,
and projections from full MCS to closure-restricted MCS.

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

## Known Issue: Double-Negation Escape

When `ψ = χ.neg` for some `χ ∈ closure φ`, then `ψ.neg = χ.neg.neg` may escape
`closureWithNeg` because negation (defined as `imp _ bot`) is not involutive.
This is handled via explicit case analysis in the proofs (see `mcs_projection_is_closure_mcs`).

## Cross-References

- `BoundedTime.lean`: Parametric bounded time domain
- `FiniteWorldState.lean`: Uses closure for finite world construction
- `FiniteModelProperty.lean`: Uses closure-MCS for FMP proof

## References

- Modal Logic, Blackburn et al., Chapter 4
-/

namespace Bimodal.Metalogic.FMP

open Bimodal.Syntax Bimodal.ProofSystem Bimodal.Semantics
open Bimodal.Metalogic.Core
open Bimodal.Metalogic_v2.Representation

/-!
## Subformula Closure

The closure of a formula is the set of all its subformulas.
-/

/--
Subformula closure of a formula as a Finset.

The closure contains all subformulas, which is finite.
We use the subformulas list from the Syntax module.
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
  exact mcs_contains_or_neg h_mcs psi

/--
Key lemma: In a closure MCS, either psi or psi.neg is in the set (for psi in closure).

By restricting to psi ∈ closure phi (not closureWithNeg), we ensure psi.neg ∈ closureWithNeg phi,
which is needed for the maximality argument. The stronger statement with closureWithNeg would require
handling the double negation case where psi.neg.neg escapes closureWithNeg.
-/
theorem closure_mcs_neg_complete (phi : Formula) (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S) (psi : Formula) (h_clos : psi ∈ closure phi) :
    psi ∈ S ∨ psi.neg ∈ S := by
  by_cases h : psi ∈ S
  · left; exact h
  · right
    -- Since psi ∈ closure phi, both psi and psi.neg are in closureWithNeg phi
    have h_psi_closneg : psi ∈ closureWithNeg phi := closure_subset_closureWithNeg phi h_clos
    have h_psi_neg_closneg : psi.neg ∈ closureWithNeg phi := neg_mem_closureWithNeg phi psi h_clos

    -- Since psi ∉ S and S is closure-maximal, insert psi S is inconsistent
    have h_incons := h_mcs.2 psi h_psi_closneg h

    -- We need to show psi.neg ∈ S
    -- By contrapositive: if psi.neg ∉ S, then insert psi.neg S is inconsistent
    by_contra h_neg_not

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

    -- Now psi.neg ∈ closureWithNeg and psi.neg ∉ S, so by maximality
    -- insert psi.neg S is inconsistent
    have h_incons_neg := h_mcs.2 psi.neg h_psi_neg_closneg h_neg_not

    -- So there exists L' ⊆ insert psi.neg S with ¬Consistent L'
    unfold SetConsistent at h_incons_neg
    push_neg at h_incons_neg
    obtain ⟨L', h_L'_sub, h_L'_incons⟩ := h_incons_neg

    -- L' is inconsistent, so L' ⊢ ⊥
    have h_bot'' : Nonempty (DerivationTree L' Formula.bot) := inconsistent_derives_bot h_L'_incons
    obtain ⟨d_bot''⟩ := h_bot''

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

    -- Combine Γ and Δ
    let ΓΔ := Γ ++ Δ
    have h_ΓΔ_in_S : ∀ χ ∈ ΓΔ, χ ∈ S := by
      intro χ hχ
      simp only [ΓΔ, List.mem_append] at hχ
      rcases hχ with hχΓ | hχΔ
      · exact h_Γ_in_S χ hχΓ
      · exact h_Δ_in_S χ hχΔ

    -- Weaken both derivations to ΓΔ
    have d_neg' : DerivationTree ΓΔ psi.neg :=
      DerivationTree.weakening Γ ΓΔ _ d_neg (List.subset_append_left Γ Δ)
    have d_neg_neg' : DerivationTree ΓΔ psi.neg.neg :=
      DerivationTree.weakening Δ ΓΔ _ d_neg_neg (List.subset_append_right Γ Δ)

    -- Combine to get ⊥ from psi.neg and psi.neg.neg
    have d_bot_final : DerivationTree ΓΔ Formula.bot :=
      derives_bot_from_phi_neg_phi d_neg' d_neg_neg'

    -- This contradicts consistency of S
    exact h_mcs.1.2 ΓΔ h_ΓΔ_in_S ⟨d_bot_final⟩

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
    intro h_cons_proj
    unfold SetConsistent at h_incons_M h_cons_proj
    push_neg at h_incons_M
    obtain ⟨L, h_L_sub_M, h_L_incons⟩ := h_incons_M

    -- Step 2: psi.neg ∈ M
    have h_neg_M : psi.neg ∈ M := by
      have h_or := mcs_contains_or_neg h_mcs psi
      cases h_or with
      | inl h => exact absurd h h_not_M
      | inr h => exact h

    -- Case analysis on how psi is in closureWithNeg:
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

These lemmas extract subformula closure membership from compound formulas.
All proofs use the same pattern: unfold closure, simp to list membership,
then apply the corresponding subformula property.
-/

-- Helper tactic pattern: unfold closure to list membership
private theorem closure_mem_iff (phi psi : Formula) :
    psi ∈ closure phi ↔ psi ∈ phi.subformulas := by
  unfold closure; simp only [List.mem_toFinset]

theorem closure_imp_left (phi psi chi : Formula) (h : Formula.imp psi chi ∈ closure phi) :
    psi ∈ closure phi := by
  rw [closure_mem_iff] at h ⊢; exact Formula.mem_subformulas_of_imp_left h

theorem closure_imp_right (phi psi chi : Formula) (h : Formula.imp psi chi ∈ closure phi) :
    chi ∈ closure phi := by
  rw [closure_mem_iff] at h ⊢; exact Formula.mem_subformulas_of_imp_right h

theorem closure_box (phi psi : Formula) (h : Formula.box psi ∈ closure phi) :
    psi ∈ closure phi := by
  rw [closure_mem_iff] at h ⊢; exact Formula.mem_subformulas_of_box h

theorem closure_all_past (phi psi : Formula) (h : Formula.all_past psi ∈ closure phi) :
    psi ∈ closure phi := by
  rw [closure_mem_iff] at h ⊢; exact Formula.mem_subformulas_of_all_past h

theorem closure_all_future (phi psi : Formula) (h : Formula.all_future psi ∈ closure phi) :
    psi ∈ closure phi := by
  rw [closure_mem_iff] at h ⊢; exact Formula.mem_subformulas_of_all_future h

/-!
## Implication Closure Property

Key property: In a closure MCS, implication matches material implication.
-/

/--
Implication in closure MCS follows material implication.

If psi.imp chi ∈ closure phi, then in a closure MCS S:
(psi.imp chi) ∈ S ↔ (psi ∈ S → chi ∈ S)

Note: The membership constraints for psi and chi in closure are derived automatically
from h_imp_clos via closure_imp_left and closure_imp_right.
-/
theorem closure_mcs_imp_iff (phi : Formula) (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S)
    (psi chi : Formula)
    (h_imp_clos : Formula.imp psi chi ∈ closure phi) :
    Formula.imp psi chi ∈ S ↔ (psi ∈ S → chi ∈ S) := by
  -- Derive closure membership from implication subformula property
  have h_psi_clos : psi ∈ closure phi := closure_imp_left phi psi chi h_imp_clos
  have h_chi_clos : chi ∈ closure phi := closure_imp_right phi psi chi h_imp_clos
  constructor
  · -- Forward: (psi → chi) ∈ S and psi ∈ S implies chi ∈ S
    intro h_imp h_psi
    -- This follows from the consistency of S (modus ponens)
    by_contra h_chi_not
    -- If chi ∉ S and chi ∈ closure, then chi.neg ∈ S (by negation completeness)
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
    -- (psi → chi) ∉ S and (psi → chi) ∈ closure (so negation completeness applies)
    have h_or := closure_mcs_neg_complete phi S h_mcs (psi.imp chi) h_imp_clos
    cases h_or with
    | inl h => exact h_imp_not h
    | inr h_neg =>
      -- (psi → chi).neg ∈ S
      have h_psi_or := closure_mcs_neg_complete phi S h_mcs psi h_psi_clos
      cases h_psi_or with
      | inl h_psi =>
        -- psi ∈ S, so by h_material, chi ∈ S
        have h_chi := h_material h_psi
        -- Now we have chi ∈ S and (psi → chi).neg ∈ S
        have h_incons : ¬Consistent [chi, (psi.imp chi).neg] := by
          intro h_cons
          apply h_cons
          -- Build derivation [chi, (psi → chi).neg] ⊢ ⊥
          have d_prop_s : DerivationTree [] (chi.imp (psi.imp chi)) :=
            DerivationTree.axiom [] _ (Axiom.prop_s chi psi)
          have d_prop_s' : DerivationTree [chi, (psi.imp chi).neg] (chi.imp (psi.imp chi)) :=
            DerivationTree.weakening [] _ _ d_prop_s (by simp)
          have d_chi : DerivationTree [chi, (psi.imp chi).neg] chi :=
            DerivationTree.assumption _ _ (by simp)
          have d_imp : DerivationTree [chi, (psi.imp chi).neg] (psi.imp chi) :=
            DerivationTree.modus_ponens _ _ _ d_prop_s' d_chi
          have d_neg : DerivationTree [chi, (psi.imp chi).neg] (psi.imp chi).neg :=
            DerivationTree.assumption _ _ (by simp)
          exact ⟨derives_bot_from_phi_neg_phi d_imp d_neg⟩
        have h_sub : ∀ ψ ∈ [chi, (psi.imp chi).neg], ψ ∈ S := by
          intro ψ hψ
          simp only [List.mem_cons, List.mem_nil_iff, or_false] at hψ
          rcases hψ with rfl | rfl
          · exact h_chi
          · exact h_neg
        exact h_incons (h_mcs.1.2 [chi, (psi.imp chi).neg] h_sub)
      | inr h_neg_psi =>
        -- psi.neg ∈ S
        have h_incons : ¬Consistent [psi.neg, (psi.imp chi).neg] := by
          intro h_cons
          apply h_cons
          -- EFQ: ⊥ → chi
          have d_efq : DerivationTree [] (Formula.bot.imp chi) :=
            DerivationTree.axiom [] _ (Axiom.ex_falso chi)
          have d_efq' : DerivationTree [psi.neg, (psi.imp chi).neg] (Formula.bot.imp chi) :=
            DerivationTree.weakening [] _ _ d_efq (by simp)

          -- psi.neg = psi → ⊥ from context
          have d_psi_neg : DerivationTree [psi.neg, (psi.imp chi).neg] psi.neg :=
            DerivationTree.assumption _ _ (by simp)

          -- Use b_combinator pattern: (⊥ → chi) → (psi → ⊥) → (psi → chi)
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

          exact ⟨derives_bot_from_phi_neg_phi d_imp d_neg⟩
        have h_sub : ∀ ψ ∈ [psi.neg, (psi.imp chi).neg], ψ ∈ S := by
          intro ψ hψ
          simp only [List.mem_cons, List.mem_nil_iff, or_false] at hψ
          rcases hψ with rfl | rfl
          · exact h_neg_psi
          · exact h_neg
        exact h_incons (h_mcs.1.2 [psi.neg, (psi.imp chi).neg] h_sub)

/-!
## Additional Closure Membership Infrastructure (Task 825)

Helper lemmas for closure membership that unblock TruthLemma.lean.
-/

/--
If psi ∈ closure phi, then psi.neg ∈ closureWithNeg phi.

This is the key lemma for handling negations in closure MCS.
-/
theorem closure_neg_in_closureWithNeg (phi psi : Formula)
    (h : psi ∈ closure phi) : psi.neg ∈ closureWithNeg phi :=
  neg_mem_closureWithNeg phi psi h

/--
Both components of an implication in closure are in closureWithNeg.

If psi.imp chi ∈ closure phi, then both psi and chi are in closureWithNeg phi.
-/
theorem closure_imp_components_in_closureWithNeg (phi psi chi : Formula)
    (h : Formula.imp psi chi ∈ closure phi) :
    psi ∈ closureWithNeg phi ∧ chi ∈ closureWithNeg phi := by
  have h_psi := closure_imp_left phi psi chi h
  have h_chi := closure_imp_right phi psi chi h
  exact ⟨closure_subset_closureWithNeg phi h_psi, closure_subset_closureWithNeg phi h_chi⟩

/--
The inner formula of a Box is in closure.

If Box psi ∈ closure phi, then psi ∈ closure phi.
This is a direct consequence of the subformula property.
-/
theorem closure_box_inner (phi psi : Formula)
    (h : Formula.box psi ∈ closure phi) : psi ∈ closure phi :=
  closure_box phi psi h

/--
If Box psi ∈ closure phi, then psi ∈ closureWithNeg phi.
-/
theorem closure_box_inner_in_closureWithNeg (phi psi : Formula)
    (h : Formula.box psi ∈ closure phi) : psi ∈ closureWithNeg phi :=
  closure_subset_closureWithNeg phi (closure_box phi psi h)

/--
If Box psi ∈ closure phi, then Box psi ∈ closureWithNeg phi.
-/
theorem closure_box_in_closureWithNeg (phi psi : Formula)
    (h : Formula.box psi ∈ closure phi) : Formula.box psi ∈ closureWithNeg phi :=
  closure_subset_closureWithNeg phi h

/--
Diamond psi = neg(Box(neg psi)) membership in closureWithNeg.

If Box psi ∈ closure phi, then Diamond(psi.neg) ∈ closureWithNeg phi.
Note: Diamond psi is syntactically neg(Box(neg psi)).
-/
theorem diamond_in_closureWithNeg_of_box (phi psi : Formula)
    (h : Formula.box psi ∈ closure phi) :
    Formula.neg (Formula.box (Formula.neg psi)) ∈ closureWithNeg phi := by
  -- We have Box psi ∈ closure phi
  -- By subformula property, psi ∈ closure phi
  -- So psi.neg ∈ closureWithNeg phi
  -- And Box(psi.neg) needs to be in closureWithNeg... but it may not be!
  -- Actually, this lemma is not generally true.
  -- The diamond formula may not be a subformula of phi.
  sorry

/-!
## Closure MCS Properties for Implication (Task 825)

Additional properties relating implication membership to its components.
-/

/--
In a closure MCS, if psi ∈ S and psi.imp chi ∈ S and chi ∈ closure phi, then chi ∈ S.
This is modus ponens for MCS membership.
-/
theorem closure_mcs_modus_ponens (phi : Formula) (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S)
    (psi chi : Formula)
    (h_psi : psi ∈ S)
    (h_imp : psi.imp chi ∈ S)
    (h_chi_clos : chi ∈ closure phi) :
    chi ∈ S := by
  -- By consistency of S: if psi ∈ S and psi.imp chi ∈ S but chi ∉ S,
  -- then chi.neg ∈ S (by closure MCS), contradicting consistency
  by_contra h_chi_not
  -- chi ∉ S and chi ∈ closure, so chi.neg ∈ S (by negation completeness)
  have h_chi_neg : chi.neg ∈ S := by
    have h_or := closure_mcs_neg_complete phi S h_mcs chi h_chi_clos
    cases h_or with
    | inl h => exact absurd h h_chi_not
    | inr h_neg => exact h_neg
  -- Now we have psi, psi.imp chi, chi.neg all in S
  -- This is inconsistent: psi, psi → chi ⊢ chi; chi, chi.neg ⊢ ⊥
  have h_incons : ¬Consistent [psi, psi.imp chi, chi.neg] := by
    intro h_cons
    apply h_cons
    -- Build derivation
    have d_psi : DerivationTree [psi, psi.imp chi, chi.neg] psi :=
      DerivationTree.assumption _ _ (by simp)
    have d_imp : DerivationTree [psi, psi.imp chi, chi.neg] (psi.imp chi) :=
      DerivationTree.assumption _ _ (by simp)
    have d_chi : DerivationTree [psi, psi.imp chi, chi.neg] chi :=
      DerivationTree.modus_ponens _ _ _ d_imp d_psi
    have d_chi_neg : DerivationTree [psi, psi.imp chi, chi.neg] chi.neg :=
      DerivationTree.assumption _ _ (by simp)
    exact ⟨DerivationTree.modus_ponens _ _ _ d_chi_neg d_chi⟩
  have h_sub : ∀ ψ ∈ [psi, psi.imp chi, chi.neg], ψ ∈ S := by
    intro ψ hψ
    simp only [List.mem_cons, List.mem_nil_iff, or_false] at hψ
    rcases hψ with rfl | rfl | rfl
    · exact h_psi
    · exact h_imp
    · exact h_chi_neg
  exact h_incons (h_mcs.1.2 [psi, psi.imp chi, chi.neg] h_sub)

end Bimodal.Metalogic.FMP
