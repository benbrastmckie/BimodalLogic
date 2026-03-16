import Bimodal.Metalogic.Canonical.CanonicalTimeline
import Bimodal.Metalogic.Bundle.CanonicalFMCS
import Bimodal.Metalogic.Bundle.Construction
import Bimodal.Metalogic.Bundle.TemporalCoherence
import Bimodal.Metalogic.Completeness
import Mathlib.Order.CountableDenseLinearOrder
import Mathlib.Order.Antisymmetrization
import Mathlib.Data.Countable.Basic
import Mathlib.Logic.Equiv.List

/-!
# Constructive Countable Fragment of the Canonical Timeline

This module defines a countable sub-fragment of the canonical timeline by
inductively enumerating specific Lindenbaum witnesses for F/P obligations,
then takes the Antisymmetrization quotient to obtain a type with LinearOrder.

## Overview

The full set of MCSs reachable from M₀ via BidirectionalR is uncountable.
We construct a countable fragment by enumerating specific witnesses.
The Antisymmetrization quotient gives LinearOrder + Countable.

## References

- Task 956 plan v012: Phase 2B
- Research-030: Constructive countable fragment strategy
- Boneyard/BidirectionalReachable.lean: Totality proof technique
-/

namespace Bimodal.Metalogic.Canonical

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic
open Bimodal.ProofSystem

variable {M₀ : Set Formula} {h_mcs₀ : SetMaximalConsistent M₀}

/-!
## Constructive Witness Paths

Instead of defining reachability as a Prop, we define the constructive fragment
via witness paths: finite sequences of (direction, formula) pairs that determine
which Lindenbaum witnesses to take starting from M₀.

A path determines a unique MCS by iterating: start at M₀, then for each step
(true, φ) take the forward Lindenbaum witness for F(φ), and for (false, φ)
take the backward witness for P(φ). A path is valid if each step's prerequisite
(F(φ) ∈ current MCS or P(φ) ∈ current MCS) is satisfied.
-/

/--
A witness step: either forward (for F obligation) or backward (for P obligation).
-/
abbrev WitnessStep := Bool × Formula

/--
Execute a single forward witness step: given an MCS M with F(φ) ∈ M,
return the specific Lindenbaum witness.
-/
noncomputable def executeForwardStep (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (φ : Formula) (h_F : Formula.some_future φ ∈ M) : Set Formula :=
  lindenbaumMCS_set (forward_temporal_witness_seed M φ)
    (forward_temporal_witness_seed_consistent M h_mcs φ h_F)

/--
Execute a single backward witness step: given an MCS M with P(φ) ∈ M,
return the specific Lindenbaum witness.
-/
noncomputable def executeBackwardStep (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (φ : Formula) (h_P : Formula.some_past φ ∈ M) : Set Formula :=
  lindenbaumMCS_set (past_temporal_witness_seed M φ)
    (past_temporal_witness_seed_consistent M h_mcs φ h_P)

/-!
## CanonicalR Properties for Witnesses
-/

theorem executeForwardStep_canonicalR {M : Set Formula} {h_mcs : SetMaximalConsistent M}
    {φ : Formula} {h_F : Formula.some_future φ ∈ M} :
    CanonicalR M (executeForwardStep M h_mcs φ h_F) :=
  fun _ h_ψ => lindenbaumMCS_set_extends _ _ (g_content_subset_forward_temporal_witness_seed M φ h_ψ)

theorem executeBackwardStep_canonicalR_past {M : Set Formula} {h_mcs : SetMaximalConsistent M}
    {φ : Formula} {h_P : Formula.some_past φ ∈ M} :
    CanonicalR_past M (executeBackwardStep M h_mcs φ h_P) :=
  fun _ h_ψ => lindenbaumMCS_set_extends _ _ (h_content_subset_past_temporal_witness_seed M φ h_ψ)

theorem executeBackwardStep_canonicalR {M : Set Formula} {h_mcs : SetMaximalConsistent M}
    {φ : Formula} {h_P : Formula.some_past φ ∈ M} :
    CanonicalR (executeBackwardStep M h_mcs φ h_P) M :=
  h_content_subset_implies_g_content_reverse M _ h_mcs
    (lindenbaumMCS_set_is_mcs _ _)
    (executeBackwardStep_canonicalR_past (h_mcs := h_mcs) (h_P := h_P))

theorem executeForwardStep_mcs {M : Set Formula} {h_mcs : SetMaximalConsistent M}
    {φ : Formula} {h_F : Formula.some_future φ ∈ M} :
    SetMaximalConsistent (executeForwardStep M h_mcs φ h_F) :=
  lindenbaumMCS_set_is_mcs _ _

theorem executeBackwardStep_mcs {M : Set Formula} {h_mcs : SetMaximalConsistent M}
    {φ : Formula} {h_P : Formula.some_past φ ∈ M} :
    SetMaximalConsistent (executeBackwardStep M h_mcs φ h_P) :=
  lindenbaumMCS_set_is_mcs _ _

/-!
## Constructive Reachability (Type-valued)

We define reachability as a Type (not Prop) to enable encoding into countable types.
-/

/--
Constructive reachability proof object. Type-valued to enable encoding.
-/
inductive ConstructiveReachable (M₀ : Set Formula) (h_mcs₀ : SetMaximalConsistent M₀)
    : Set Formula → Type where
  | root : ConstructiveReachable M₀ h_mcs₀ M₀
  | forward_witness (M : Set Formula) (φ : Formula)
      (h_reach : ConstructiveReachable M₀ h_mcs₀ M)
      (h_mcs : SetMaximalConsistent M)
      (h_F : Formula.some_future φ ∈ M) :
      ConstructiveReachable M₀ h_mcs₀ (executeForwardStep M h_mcs φ h_F)
  | backward_witness (M : Set Formula) (φ : Formula)
      (h_reach : ConstructiveReachable M₀ h_mcs₀ M)
      (h_mcs : SetMaximalConsistent M)
      (h_P : Formula.some_past φ ∈ M) :
      ConstructiveReachable M₀ h_mcs₀ (executeBackwardStep M h_mcs φ h_P)

theorem constructiveReachable_mcs
    {M : Set Formula} (h : ConstructiveReachable M₀ h_mcs₀ M) :
    SetMaximalConsistent M := by
  induction h with
  | root => exact h_mcs₀
  | forward_witness _ _ _ _ _ => exact executeForwardStep_mcs
  | backward_witness _ _ _ _ _ => exact executeBackwardStep_mcs

/-!
## The Constructive Fragment
-/

/--
The constructive fragment: type of all MCSs constructively reachable from M₀.
Uses Nonempty to project from Type-valued reachability to Prop for the subtype.
-/
def ConstructiveFragment (M₀ : Set Formula) (h_mcs₀ : SetMaximalConsistent M₀) : Type :=
  { M : Set Formula // Nonempty (ConstructiveReachable M₀ h_mcs₀ M) }

def ConstructiveFragment.root : ConstructiveFragment M₀ h_mcs₀ :=
  ⟨M₀, ⟨ConstructiveReachable.root⟩⟩

instance : Nonempty (ConstructiveFragment M₀ h_mcs₀) :=
  ⟨ConstructiveFragment.root⟩

theorem ConstructiveFragment.is_mcs (w : ConstructiveFragment M₀ h_mcs₀) :
    SetMaximalConsistent w.val := by
  obtain ⟨h⟩ := w.property
  exact constructiveReachable_mcs h

/-!
## Countability

The constructive fragment is countable because:
1. Each ConstructiveReachable proof encodes as a List (Bool × Formula)
2. Formula is Countable, so List (Bool × Formula) is Countable
3. The encoding is injective on the MCS (same path = same MCS)
4. So there are at most countably many distinct MCSs in the fragment
-/

/--
Encoding of a constructive reachability proof as a list of witness steps.
-/
noncomputable def ConstructiveReachable.encode
    {M : Set Formula} : ConstructiveReachable M₀ h_mcs₀ M → List WitnessStep
  | .root => []
  | .forward_witness _ φ h_reach _ _ => h_reach.encode ++ [(true, φ)]
  | .backward_witness _ φ h_reach _ _ => h_reach.encode ++ [(false, φ)]

/--
Two reachability proofs with the same encoding produce the same MCS.
-/
theorem ConstructiveReachable.encode_determines
    {M₁ M₂ : Set Formula}
    (h₁ : ConstructiveReachable M₀ h_mcs₀ M₁)
    (h₂ : ConstructiveReachable M₀ h_mcs₀ M₂)
    (h_eq : h₁.encode = h₂.encode) : M₁ = M₂ := by
  induction h₁ with
  | root =>
    cases h₂ with
    | root => rfl
    | forward_witness _ _ _ _ _ => simp [encode] at h_eq
    | backward_witness _ _ _ _ _ => simp [encode] at h_eq
  | forward_witness M₁' φ₁ _ h_mcs₁ h_F₁ ih =>
    cases h₂ with
    | root => simp [encode] at h_eq
    | forward_witness M₂' φ₂ h_reach₂ h_mcs₂ h_F₂ =>
      simp [encode] at h_eq
      obtain ⟨h_prefix, h_φ_eq⟩ := h_eq
      have h_M_eq : M₁' = M₂' := ih h_reach₂ h_prefix
      subst h_M_eq
      -- After subst, h_mcs₁ = h_mcs₂ by proof irrelevance, h_F₁ = h_F₂ similarly
      -- And φ₁ = φ₂ from h_φ_eq
      subst h_φ_eq
      rfl
    | backward_witness _ _ _ _ _ => simp [encode] at h_eq
  | backward_witness M₁' φ₁ _ h_mcs₁ h_P₁ ih =>
    cases h₂ with
    | root => simp [encode] at h_eq
    | forward_witness _ _ _ _ _ => simp [encode] at h_eq
    | backward_witness M₂' φ₂ h_reach₂ h_mcs₂ h_P₂ =>
      simp [encode] at h_eq
      obtain ⟨h_prefix, h_φ_eq⟩ := h_eq
      have h_M_eq : M₁' = M₂' := ih h_reach₂ h_prefix
      subst h_M_eq
      subst h_φ_eq
      rfl

/--
The constructive fragment is countable.
-/
noncomputable instance : Countable (ConstructiveFragment M₀ h_mcs₀) := by
  -- For each element w, pick any reachability proof and encode it
  -- Two elements with the same encoding have the same underlying MCS
  apply Function.Injective.countable
    (f := fun (w : ConstructiveFragment M₀ h_mcs₀) => w.property.some.encode)
  intro ⟨M₁, ⟨h₁⟩⟩ ⟨M₂, ⟨h₂⟩⟩ h_eq
  simp only at h_eq
  exact Subtype.ext (ConstructiveReachable.encode_determines h₁ h₂ h_eq)

/-!
## Total Preorder via CanonicalR + temp_linearity
-/

noncomputable instance : Preorder (ConstructiveFragment M₀ h_mcs₀) where
  le a b := a.val = b.val ∨ CanonicalR a.val b.val
  le_refl a := Or.inl rfl
  le_trans a b c hab hbc := by
    rcases hab with rfl | hab
    · exact hbc
    · rcases hbc with rfl | hbc
      · exact Or.inr hab
      · exact Or.inr (canonicalR_transitive a.val b.val c.val a.is_mcs hab hbc)

/-!
### MCS-Level Linearity Lemmas (adapted from Boneyard)
-/

lemma canonical_F_of_mem_successor (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M') (phi : Formula) (h_phi : phi ∈ M') :
    Formula.some_future phi ∈ M := by
  by_contra h_not_F
  have h_neg_F : Formula.neg (Formula.some_future phi) ∈ M := by
    cases SetMaximalConsistent.negation_complete h_mcs (Formula.some_future phi) with
    | inl h => exact absurd h h_not_F
    | inr h => exact h
  have h_G_neg : Formula.all_future (Formula.neg phi) ∈ M :=
    SetMaximalConsistent.double_neg_elim h_mcs _ h_neg_F
  exact set_consistent_not_both h_mcs'.1 phi h_phi (h_R h_G_neg)

lemma canonical_P_of_mem_predecessor (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M' M) (phi : Formula) (h_phi : phi ∈ M') :
    Formula.some_past phi ∈ M := by
  have h_R_past : CanonicalR_past M M' :=
    g_content_subset_implies_h_content_reverse M' M h_mcs' h_mcs h_R
  by_contra h_not_P
  have h_neg_P : Formula.neg (Formula.some_past phi) ∈ M := by
    cases SetMaximalConsistent.negation_complete h_mcs (Formula.some_past phi) with
    | inl h => exact absurd h h_not_P
    | inr h => exact h
  have h_H_neg : Formula.all_past (Formula.neg phi) ∈ M :=
    SetMaximalConsistent.double_neg_elim h_mcs _ h_neg_P
  exact set_consistent_not_both h_mcs'.1 phi h_phi (h_R_past h_H_neg)

lemma SetMaximalConsistent.F_linearity (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi psi : Formula)
    (h_Fphi : Formula.some_future phi ∈ M)
    (h_Fpsi : Formula.some_future psi ∈ M) :
    Formula.some_future (Formula.and phi psi) ∈ M ∨
    Formula.some_future (Formula.and phi (Formula.some_future psi)) ∈ M ∨
    Formula.some_future (Formula.and (Formula.some_future phi) psi) ∈ M := by
  have h_lin : [] ⊢ (Formula.and (Formula.some_future phi) (Formula.some_future psi)).imp
      (Formula.or (Formula.some_future (Formula.and phi psi))
        (Formula.or (Formula.some_future (Formula.and phi (Formula.some_future psi)))
          (Formula.some_future (Formula.and (Formula.some_future phi) psi)))) :=
    DerivationTree.axiom [] _ (Axiom.temp_linearity phi psi)
  have h_conj := SetMaximalConsistent.conjunction_intro h_mcs h_Fphi h_Fpsi
  have h_disj := SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_lin) h_conj
  cases SetMaximalConsistent.disjunction_elim h_mcs h_disj with
  | inl h1 => exact Or.inl h1
  | inr h23 =>
    cases SetMaximalConsistent.disjunction_elim h_mcs h23 with
    | inl h2 => exact Or.inr (Or.inl h2)
    | inr h3 => exact Or.inr (Or.inr h3)

theorem canonical_forward_reachable_linear (M M1 M2 : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (h_mcs1 : SetMaximalConsistent M1)
    (h_mcs2 : SetMaximalConsistent M2)
    (h_R1 : CanonicalR M M1) (h_R2 : CanonicalR M M2) :
    CanonicalR M1 M2 ∨ CanonicalR M2 M1 ∨ M1 = M2 := by
  by_cases h_12 : CanonicalR M1 M2
  · exact Or.inl h_12
  · right
    by_contra h_neg
    push_neg at h_neg
    obtain ⟨h_not_21, h_neq⟩ := h_neg
    rw [CanonicalR, Set.not_subset] at h_12
    obtain ⟨alpha, h_alpha_G1, h_alpha_not2⟩ := h_12
    have h_neg_alpha_M2 : Formula.neg alpha ∈ M2 := by
      cases SetMaximalConsistent.negation_complete h_mcs2 alpha with
      | inl h => exact absurd h h_alpha_not2
      | inr h => exact h
    have h_not_sub_21 : ¬(g_content M2 ⊆ M1) := h_not_21
    rw [Set.not_subset] at h_not_sub_21
    obtain ⟨beta, h_beta_G2, h_beta_not1⟩ := h_not_sub_21
    have h_neg_beta_M1 : Formula.neg beta ∈ M1 := by
      cases SetMaximalConsistent.negation_complete h_mcs1 beta with
      | inl h => exact absurd h h_beta_not1
      | inr h => exact h
    have h_sep : ∃ gamma, gamma ∈ M1 ∧ gamma ∉ M2 := by
      by_contra h_all; push_neg at h_all; apply h_neq
      apply Set.Subset.antisymm h_all
      intro phi h_phi_M2
      cases SetMaximalConsistent.negation_complete h_mcs1 phi with
      | inl h => exact h
      | inr h => exact absurd (h_all _ h) (fun h_neg_M2 =>
          set_consistent_not_both h_mcs2.1 phi h_phi_M2 h_neg_M2)
    obtain ⟨gamma, h_gamma_M1, h_gamma_not_M2⟩ := h_sep
    have h_neg_gamma_M2 : Formula.neg gamma ∈ M2 := by
      cases SetMaximalConsistent.negation_complete h_mcs2 gamma with
      | inl h => exact absurd h h_gamma_not_M2
      | inr h => exact h
    have h_conj_M1 := SetMaximalConsistent.conjunction_intro h_mcs1
      (SetMaximalConsistent.conjunction_intro h_mcs1 (h_alpha_G1 : Formula.all_future alpha ∈ M1) h_gamma_M1)
      h_neg_beta_M1
    have h_conj_M2 := SetMaximalConsistent.conjunction_intro h_mcs2
      (SetMaximalConsistent.conjunction_intro h_mcs2 (h_beta_G2 : Formula.all_future beta ∈ M2) h_neg_gamma_M2)
      h_neg_alpha_M2
    have h_F_conj1 := canonical_F_of_mem_successor M M1 h_mcs h_mcs1 h_R1 _ h_conj_M1
    have h_F_conj2 := canonical_F_of_mem_successor M M2 h_mcs h_mcs2 h_R2 _ h_conj_M2
    have h_lin := SetMaximalConsistent.F_linearity M h_mcs _ _ h_F_conj1 h_F_conj2
    rcases h_lin with h_case1 | h_case2 | h_case3
    · obtain ⟨W, h_W_mcs, _, h_W_mem⟩ := canonical_forward_F M h_mcs _ h_case1
      have h_big := SetMaximalConsistent.conjunction_elim h_W_mcs h_W_mem
      have h_inner1_W := (SetMaximalConsistent.conjunction_elim h_W_mcs h_big.1).1
      have h_gamma_W := (SetMaximalConsistent.conjunction_elim h_W_mcs h_inner1_W).2
      have h_inner2_W := (SetMaximalConsistent.conjunction_elim h_W_mcs h_big.2).1
      have h_neg_gamma_W := (SetMaximalConsistent.conjunction_elim h_W_mcs h_inner2_W).2
      exact set_consistent_not_both h_W_mcs.1 gamma h_gamma_W h_neg_gamma_W
    · obtain ⟨W, h_W_mcs, _, h_W_mem⟩ := canonical_forward_F M h_mcs _ h_case2
      have h_outer := SetMaximalConsistent.conjunction_elim h_W_mcs h_W_mem
      have h_inner1 := (SetMaximalConsistent.conjunction_elim h_W_mcs h_outer.1).1
      have h_G_alpha_W := (SetMaximalConsistent.conjunction_elim h_W_mcs h_inner1).1
      obtain ⟨W', h_W'_mcs, h_R_WW', h_conj2_W'⟩ := canonical_forward_F W h_W_mcs _ h_outer.2
      have h_neg_alpha_W' := (SetMaximalConsistent.conjunction_elim h_W'_mcs h_conj2_W').2
      exact set_consistent_not_both h_W'_mcs.1 alpha
        (canonical_forward_G W W' h_R_WW' alpha h_G_alpha_W) h_neg_alpha_W'
    · obtain ⟨W, h_W_mcs, _, h_W_mem⟩ := canonical_forward_F M h_mcs _ h_case3
      have h_outer := SetMaximalConsistent.conjunction_elim h_W_mcs h_W_mem
      have h_inner2 := (SetMaximalConsistent.conjunction_elim h_W_mcs h_outer.2).1
      have h_G_beta_W := (SetMaximalConsistent.conjunction_elim h_W_mcs h_inner2).1
      obtain ⟨W', h_W'_mcs, h_R_WW', h_conj1_W'⟩ := canonical_forward_F W h_W_mcs _ h_outer.1
      have h_neg_beta_W' := (SetMaximalConsistent.conjunction_elim h_W'_mcs h_conj1_W').2
      exact set_consistent_not_both h_W'_mcs.1 beta
        (canonical_forward_G W W' h_R_WW' beta h_G_beta_W) h_neg_beta_W'

lemma SetMaximalConsistent.P_linearity (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi psi : Formula)
    (h_Pphi : Formula.some_past phi ∈ M)
    (h_Ppsi : Formula.some_past psi ∈ M) :
    Formula.some_past (Formula.and phi psi) ∈ M ∨
    Formula.some_past (Formula.and phi (Formula.some_past psi)) ∈ M ∨
    Formula.some_past (Formula.and (Formula.some_past phi) psi) ∈ M := by
  have h_lin_future := DerivationTree.axiom []
    (Formula.and (Formula.some_future phi.swap_temporal) (Formula.some_future psi.swap_temporal) |>.imp
      (Formula.or (Formula.some_future (Formula.and phi.swap_temporal psi.swap_temporal))
        (Formula.or (Formula.some_future (Formula.and phi.swap_temporal (Formula.some_future psi.swap_temporal)))
          (Formula.some_future (Formula.and (Formula.some_future phi.swap_temporal) psi.swap_temporal)))))
    (Axiom.temp_linearity phi.swap_temporal psi.swap_temporal)
  have h_dual := DerivationTree.temporal_duality _ h_lin_future
  simp only [Formula.swap_temporal, Formula.and, Formula.or, Formula.imp, Formula.neg,
    Formula.all_future, Formula.all_past, Formula.some_future, Formula.some_past,
    Formula.swap_temporal_involution] at h_dual
  have h_conj := SetMaximalConsistent.conjunction_intro h_mcs h_Pphi h_Ppsi
  have h_disj := SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_dual) h_conj
  cases SetMaximalConsistent.disjunction_elim h_mcs h_disj with
  | inl h1 => exact Or.inl h1
  | inr h23 =>
    cases SetMaximalConsistent.disjunction_elim h_mcs h23 with
    | inl h2 => exact Or.inr (Or.inl h2)
    | inr h3 => exact Or.inr (Or.inr h3)

theorem canonical_backward_reachable_linear (M M1 M2 : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (h_mcs1 : SetMaximalConsistent M1)
    (h_mcs2 : SetMaximalConsistent M2)
    (h_R1 : CanonicalR M1 M) (h_R2 : CanonicalR M2 M) :
    CanonicalR M1 M2 ∨ CanonicalR M2 M1 ∨ M1 = M2 := by
  by_cases h_12 : CanonicalR M1 M2
  · exact Or.inl h_12
  · right
    by_contra h_neg
    push_neg at h_neg
    obtain ⟨h_not_21, h_neq⟩ := h_neg
    have h_not_H21 : ¬(h_content M2 ⊆ M1) := by
      intro h_HC
      exact h_12 (h_content_subset_implies_g_content_reverse M2 M1 h_mcs2 h_mcs1 h_HC)
    rw [Set.not_subset] at h_not_H21
    obtain ⟨alpha, h_H_alpha_M2, h_alpha_not1⟩ := h_not_H21
    have h_neg_alpha_M1 : Formula.neg alpha ∈ M1 := by
      cases SetMaximalConsistent.negation_complete h_mcs1 alpha with
      | inl h => exact absurd h h_alpha_not1
      | inr h => exact h
    have h_not_H12 : ¬(h_content M1 ⊆ M2) := by
      intro h_HC
      exact h_not_21 (h_content_subset_implies_g_content_reverse M1 M2 h_mcs1 h_mcs2 h_HC)
    rw [Set.not_subset] at h_not_H12
    obtain ⟨beta, h_H_beta_M1, h_beta_not2⟩ := h_not_H12
    have h_neg_beta_M2 : Formula.neg beta ∈ M2 := by
      cases SetMaximalConsistent.negation_complete h_mcs2 beta with
      | inl h => exact absurd h h_beta_not2
      | inr h => exact h
    have h_sep : ∃ gamma, gamma ∈ M1 ∧ gamma ∉ M2 := by
      by_contra h_all; push_neg at h_all; apply h_neq
      apply Set.Subset.antisymm h_all
      intro phi h_phi_M2
      cases SetMaximalConsistent.negation_complete h_mcs1 phi with
      | inl h => exact h
      | inr h => exact absurd (h_all _ h) (fun h_neg_M2 =>
          set_consistent_not_both h_mcs2.1 phi h_phi_M2 h_neg_M2)
    obtain ⟨gamma, h_gamma_M1, h_gamma_not_M2⟩ := h_sep
    have h_neg_gamma_M2 : Formula.neg gamma ∈ M2 := by
      cases SetMaximalConsistent.negation_complete h_mcs2 gamma with
      | inl h => exact absurd h h_gamma_not_M2
      | inr h => exact h
    have h_conj_M1 := SetMaximalConsistent.conjunction_intro h_mcs1
      (SetMaximalConsistent.conjunction_intro h_mcs1 (h_H_beta_M1 : Formula.all_past beta ∈ M1) h_gamma_M1)
      h_neg_alpha_M1
    have h_conj_M2 := SetMaximalConsistent.conjunction_intro h_mcs2
      (SetMaximalConsistent.conjunction_intro h_mcs2 (h_H_alpha_M2 : Formula.all_past alpha ∈ M2) h_neg_gamma_M2)
      h_neg_beta_M2
    have h_P_conj1 := canonical_P_of_mem_predecessor M M1 h_mcs h_mcs1 h_R1 _ h_conj_M1
    have h_P_conj2 := canonical_P_of_mem_predecessor M M2 h_mcs h_mcs2 h_R2 _ h_conj_M2
    have h_lin := SetMaximalConsistent.P_linearity M h_mcs _ _ h_P_conj1 h_P_conj2
    rcases h_lin with h_case1 | h_case2 | h_case3
    · obtain ⟨W, h_W_mcs, _, h_W_mem⟩ := canonical_backward_P M h_mcs _ h_case1
      have h_big := SetMaximalConsistent.conjunction_elim h_W_mcs h_W_mem
      have h_inner1_W := (SetMaximalConsistent.conjunction_elim h_W_mcs h_big.1).1
      have h_gamma_W := (SetMaximalConsistent.conjunction_elim h_W_mcs h_inner1_W).2
      have h_inner2_W := (SetMaximalConsistent.conjunction_elim h_W_mcs h_big.2).1
      have h_neg_gamma_W := (SetMaximalConsistent.conjunction_elim h_W_mcs h_inner2_W).2
      exact set_consistent_not_both h_W_mcs.1 gamma h_gamma_W h_neg_gamma_W
    · obtain ⟨W, h_W_mcs, _, h_W_mem⟩ := canonical_backward_P M h_mcs _ h_case2
      have h_outer := SetMaximalConsistent.conjunction_elim h_W_mcs h_W_mem
      have h_inner1 := (SetMaximalConsistent.conjunction_elim h_W_mcs h_outer.1).1
      have h_H_beta_W := (SetMaximalConsistent.conjunction_elim h_W_mcs h_inner1).1
      obtain ⟨W', h_W'_mcs, h_R_past_WW', h_conj2_W'⟩ := canonical_backward_P W h_W_mcs _ h_outer.2
      have h_neg_beta_W' := (SetMaximalConsistent.conjunction_elim h_W'_mcs h_conj2_W').2
      exact set_consistent_not_both h_W'_mcs.1 beta
        (canonical_backward_H W W' h_R_past_WW' beta h_H_beta_W) h_neg_beta_W'
    · obtain ⟨W, h_W_mcs, _, h_W_mem⟩ := canonical_backward_P M h_mcs _ h_case3
      have h_outer := SetMaximalConsistent.conjunction_elim h_W_mcs h_W_mem
      have h_inner2 := (SetMaximalConsistent.conjunction_elim h_W_mcs h_outer.2).1
      have h_H_alpha_W := (SetMaximalConsistent.conjunction_elim h_W_mcs h_inner2).1
      obtain ⟨W', h_W'_mcs, h_R_past_WW', h_conj1_W'⟩ := canonical_backward_P W h_W_mcs _ h_outer.1
      have h_neg_alpha_W' := (SetMaximalConsistent.conjunction_elim h_W'_mcs h_conj1_W').2
      exact set_consistent_not_both h_W'_mcs.1 alpha
        (canonical_backward_H W W' h_R_past_WW' alpha h_H_alpha_W) h_neg_alpha_W'

/-!
### Comparability and Totality
-/

private lemma comparable_step_forward
    (W₁ W₂ W₃ : Set Formula)
    (h_mcs1 : SetMaximalConsistent W₁)
    (h_mcs2 : SetMaximalConsistent W₂)
    (h_mcs3 : SetMaximalConsistent W₃)
    (h_comp : CanonicalR W₁ W₂ ∨ CanonicalR W₂ W₁ ∨ W₁ = W₂)
    (h_R23 : CanonicalR W₂ W₃) :
    CanonicalR W₁ W₃ ∨ CanonicalR W₃ W₁ ∨ W₁ = W₃ := by
  rcases h_comp with h_12 | h_21 | h_eq
  · exact Or.inl (canonicalR_transitive W₁ W₂ W₃ h_mcs1 h_12 h_R23)
  · exact canonical_forward_reachable_linear W₂ W₁ W₃ h_mcs2 h_mcs1 h_mcs3 h_21 h_R23
  · subst h_eq; exact Or.inl h_R23

private lemma comparable_step_backward
    (W₁ W₂ W₃ : Set Formula)
    (h_mcs1 : SetMaximalConsistent W₁)
    (h_mcs2 : SetMaximalConsistent W₂)
    (h_mcs3 : SetMaximalConsistent W₃)
    (h_comp : CanonicalR W₁ W₂ ∨ CanonicalR W₂ W₁ ∨ W₁ = W₂)
    (h_R32 : CanonicalR W₃ W₂) :
    CanonicalR W₁ W₃ ∨ CanonicalR W₃ W₁ ∨ W₁ = W₃ := by
  rcases h_comp with h_12 | h_21 | h_eq
  · exact canonical_backward_reachable_linear W₂ W₁ W₃ h_mcs2 h_mcs1 h_mcs3 h_12 h_R32
  · exact Or.inr (Or.inl (canonicalR_transitive W₃ W₂ W₁ h_mcs3 h_R32 h_21))
  · subst h_eq; exact Or.inr (Or.inl h_R32)

private theorem comparable_with_reachable
    (W₁ : Set Formula) (h_mcs1 : SetMaximalConsistent W₁)
    (h_comp_root : CanonicalR W₁ M₀ ∨ CanonicalR M₀ W₁ ∨ W₁ = M₀)
    (W₂ : Set Formula)
    (h_reach : ConstructiveReachable M₀ h_mcs₀ W₂) :
    CanonicalR W₁ W₂ ∨ CanonicalR W₂ W₁ ∨ W₁ = W₂ := by
  induction h_reach with
  | root => exact h_comp_root
  | forward_witness M φ _ h_mcs h_F ih =>
    exact comparable_step_forward W₁ M _ h_mcs1 h_mcs
      executeForwardStep_mcs ih
      (executeForwardStep_canonicalR (h_mcs := h_mcs) (h_F := h_F))
  | backward_witness M φ _ h_mcs h_P ih =>
    exact comparable_step_backward W₁ M _ h_mcs1 h_mcs
      executeBackwardStep_mcs ih
      (executeBackwardStep_canonicalR (h_mcs := h_mcs) (h_P := h_P))

theorem constructive_totally_ordered
    (a b : ConstructiveFragment M₀ h_mcs₀) :
    CanonicalR a.val b.val ∨ CanonicalR b.val a.val ∨ a.val = b.val := by
  obtain ⟨ha⟩ := a.property
  obtain ⟨hb⟩ := b.property
  have h_a_comp := comparable_with_reachable M₀ h_mcs₀ (Or.inr (Or.inr rfl)) a.val ha
  have h_comp_root : CanonicalR a.val M₀ ∨ CanonicalR M₀ a.val ∨ a.val = M₀ := by
    rcases h_a_comp with h1 | h2 | h3
    · exact Or.inr (Or.inl h1)
    · exact Or.inl h2
    · exact Or.inr (Or.inr h3.symm)
  exact comparable_with_reachable a.val a.is_mcs h_comp_root b.val hb

theorem fragment_le_total
    (a b : ConstructiveFragment M₀ h_mcs₀) : a ≤ b ∨ b ≤ a := by
  rcases constructive_totally_ordered a b with h | h | h
  · exact Or.inl (Or.inr h)
  · exact Or.inr (Or.inr h)
  · exact Or.inl (Or.inl h)

noncomputable instance : IsTotal (ConstructiveFragment M₀ h_mcs₀) (· ≤ ·) where
  total := fragment_le_total

/-!
## Antisymmetrization Quotient with LinearOrder
-/

abbrev ConstructiveQuotient (M₀ : Set Formula) (h_mcs₀ : SetMaximalConsistent M₀) :=
  Antisymmetrization (ConstructiveFragment M₀ h_mcs₀) (· ≤ ·)

noncomputable instance : LinearOrder (ConstructiveQuotient M₀ h_mcs₀) where
  le_total := by
    intro a b
    induction a using Quotient.ind with | _ a =>
    induction b using Quotient.ind with | _ b =>
    exact fragment_le_total a b
  toDecidableLE := Classical.decRel _

instance : Nonempty (ConstructiveQuotient M₀ h_mcs₀) :=
  ⟨toAntisymmetrization (· ≤ ·) ConstructiveFragment.root⟩

noncomputable instance : Countable (ConstructiveQuotient M₀ h_mcs₀) :=
  Quotient.countable

/-!
## NoMaxOrder and NoMinOrder

These are the hardest parts of Phase 2B. The key challenge is showing that
the forward/backward witnesses produce STRICTLY greater/lesser elements
in the quotient (not just ≤-equivalent ones).

The proofs are marked sorry pending a detailed analysis of when
CanonicalR-equivalent MCSs collapse in the Antisymmetrization quotient.
-/

instance : NoMaxOrder (ConstructiveQuotient M₀ h_mcs₀) where
  exists_gt a := by
    induction a using Quotient.ind with | _ w =>
    -- Every MCS has F(¬⊥) by seriality, giving a forward witness
    -- The forward witness is ≥ w in the preorder
    -- We need to show it's strictly > in the quotient
    sorry

instance : NoMinOrder (ConstructiveQuotient M₀ h_mcs₀) where
  exists_lt a := by
    induction a using Quotient.ind with | _ w =>
    sorry

end Bimodal.Metalogic.Canonical
