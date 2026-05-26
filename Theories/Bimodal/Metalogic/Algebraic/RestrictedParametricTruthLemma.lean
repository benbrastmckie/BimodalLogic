import Bimodal.Metalogic.Algebraic.ParametricTruthLemma
import Bimodal.Metalogic.Bundle.TemporalCoherence
import Bimodal.Syntax.SubformulaClosure

/-!
# Restricted Parametric Truth Lemma

This module provides a restricted version of the parametric shifted truth lemma that only
requires `B.restricted_temporally_coherent root` instead of full `B.temporally_coherent`.

## Motivation

The full `parametric_shifted_truth_lemma` requires `B.temporally_coherent`, which demands
forward_F and backward_P for ALL formulas. For the BXCanonical construction, full temporal
coherence is unprovable because the dovetailed chain has unbounded F-nesting.

However, the truth lemma for evaluating a specific formula `root` only needs temporal
coherence for formulas in `deferralClosure root`. The G/H backward cases invoke forward_F
on `neg(psi)` where `psi` is a subformula of `root`, and `neg(psi) ∈ deferralClosure(root)`.

## Main Results

- `restricted_parametric_shifted_truth_lemma`: Truth lemma using restricted temporal coherence
- `restricted_parametric_completeness_from_neg_membership`: Completeness using restricted truth lemma
-/

namespace Bimodal.Metalogic.Algebraic.RestrictedParametricTruthLemma

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Algebraic.ParametricCanonical
open Bimodal.Metalogic.Algebraic.ParametricHistory
open Bimodal.Metalogic.Algebraic.ParametricTruthLemma
open Bimodal.Semantics

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/-!
## Helper Tautologies for Imp Case
-/

/-- Classical tautology: neg(psi -> chi) -> psi -/
private noncomputable def neg_imp_implies_antecedent (ψ χ : Formula) :
    DerivationTree FrameClass.Base [] ((ψ.imp χ).neg.imp ψ) := by
  have h_efq : DerivationTree FrameClass.Base [] (ψ.neg.imp (ψ.imp χ)) :=
    Bimodal.Theorems.Propositional.efq_neg ψ χ
  have h_efq_ctx : [ψ.neg, (ψ.imp χ).neg] ⊢ ψ.neg.imp (ψ.imp χ) :=
    Bimodal.ProofSystem.DerivationTree.weakening [] [ψ.neg, (ψ.imp χ).neg] _ h_efq (by intro; simp)
  have h_neg_psi : [ψ.neg, (ψ.imp χ).neg] ⊢ ψ.neg :=
    Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
  have h_imp : [ψ.neg, (ψ.imp χ).neg] ⊢ ψ.imp χ :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_efq_ctx h_neg_psi
  have h_neg_imp : [ψ.neg, (ψ.imp χ).neg] ⊢ (ψ.imp χ).neg :=
    Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
  have h_bot : [ψ.neg, (ψ.imp χ).neg] ⊢ Formula.bot :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_neg_imp h_imp
  have h_neg_neg_psi : [(ψ.imp χ).neg] ⊢ ψ.neg.neg :=
    Bimodal.Metalogic.Core.deduction_theorem [(ψ.imp χ).neg] ψ.neg Formula.bot h_bot
  have h_deduct : [] ⊢ (ψ.imp χ).neg.imp ψ.neg.neg :=
    Bimodal.Metalogic.Core.deduction_theorem [] (ψ.imp χ).neg ψ.neg.neg h_neg_neg_psi
  have h_dne : [] ⊢ ψ.neg.neg.imp ψ :=
    Bimodal.Theorems.Propositional.double_negation ψ
  have h_b : [] ⊢ (ψ.neg.neg.imp ψ).imp (((ψ.imp χ).neg.imp ψ.neg.neg).imp ((ψ.imp χ).neg.imp ψ)) :=
    Bimodal.Theorems.Combinators.b_combinator
  have h_step1 : [] ⊢ ((ψ.imp χ).neg.imp ψ.neg.neg).imp ((ψ.imp χ).neg.imp ψ) :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_b h_dne
  exact Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_step1 h_deduct

/-- Classical tautology: neg(psi -> chi) -> neg(chi) -/
private noncomputable def neg_imp_implies_neg_consequent (ψ χ : Formula) :
    DerivationTree FrameClass.Base [] ((ψ.imp χ).neg.imp χ.neg) := by
  have h_prop_s : [] ⊢ χ.imp (ψ.imp χ) :=
    Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.prop_s χ ψ) trivial
  have h_prop_s_ctx : [χ, (ψ.imp χ).neg] ⊢ χ.imp (ψ.imp χ) :=
    Bimodal.ProofSystem.DerivationTree.weakening [] [χ, (ψ.imp χ).neg] _ h_prop_s (by intro; simp)
  have h_chi : [χ, (ψ.imp χ).neg] ⊢ χ :=
    Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
  have h_imp : [χ, (ψ.imp χ).neg] ⊢ ψ.imp χ :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_prop_s_ctx h_chi
  have h_neg_imp : [χ, (ψ.imp χ).neg] ⊢ (ψ.imp χ).neg :=
    Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
  have h_bot : [χ, (ψ.imp χ).neg] ⊢ Formula.bot :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_neg_imp h_imp
  have h_neg_chi : [(ψ.imp χ).neg] ⊢ χ.neg :=
    Bimodal.Metalogic.Core.deduction_theorem [(ψ.imp χ).neg] χ Formula.bot h_bot
  exact Bimodal.Metalogic.Core.deduction_theorem [] (ψ.imp χ).neg χ.neg h_neg_chi

/-!
## Restricted Shifted Truth Lemma

The key theorem: MCS membership iff truth at canonical model, using only restricted
temporal coherence for formulas within `subformulaClosure root`.
-/

/--
Restricted parametric shifted truth lemma: like `parametric_shifted_truth_lemma` but
requiring only `B.restricted_temporally_coherent root` instead of `B.temporally_coherent`.

The hypothesis `h_sub : φ ∈ subformulaClosure root` ensures that in the G/H backward
cases, `neg(psi) ∈ deferralClosure root` (since `psi ∈ subformulaClosure root` implies
`psi.neg ∈ closureWithNeg root ⊆ deferralClosure root`).
-/
theorem restricted_parametric_shifted_truth_lemma (B : BFMCS D)
    (root : Formula)
    (h_rtc : B.restricted_temporally_coherent root)
    (h_buc : B.backward_until_since_coherent)
    (h_fuc : B.forward_until_since_coherent) (φ : Formula)
    (h_sub : φ ∈ subformulaClosure root)
    (fam : FMCS D) (hfam : fam ∈ B.families) (t : D) :
    φ ∈ fam.mcs t ↔
    truth_at (ParametricCanonicalTaskModel D) (ShiftClosedParametricCanonicalOmega B)
      (parametric_to_history fam) t φ := by
  induction φ generalizing fam t with
  | atom p =>
    simp only [truth_at, ParametricCanonicalTaskModel, parametric_to_history]
    constructor
    · intro h_mem
      exact ⟨True.intro, h_mem⟩
    · intro ⟨_, h_val⟩
      exact h_val
  | bot =>
    simp only [truth_at]
    constructor
    · intro h_mem
      exfalso
      have h_cons := (fam.is_mcs t).1
      have h_deriv : DerivationTree FrameClass.Base [Formula.bot] Formula.bot :=
        Bimodal.ProofSystem.DerivationTree.assumption [Formula.bot] Formula.bot (by simp)
      exact h_cons [Formula.bot] (fun psi hpsi => by simp at hpsi; rw [hpsi]; exact h_mem) ⟨h_deriv⟩
    · intro h; exact h.elim
  | imp ψ χ ih_ψ ih_χ =>
    have h_ψ_sub : ψ ∈ subformulaClosure root := closure_imp_left root ψ χ h_sub
    have h_χ_sub : χ ∈ subformulaClosure root := closure_imp_right root ψ χ h_sub
    simp only [truth_at]
    have h_mcs := fam.is_mcs t
    constructor
    · intro h_imp h_ψ_true
      have h_ψ_mem := (ih_ψ h_ψ_sub fam hfam t).mpr h_ψ_true
      exact (ih_χ h_χ_sub fam hfam t).mp (SetMaximalConsistent.implication_property h_mcs h_imp h_ψ_mem)
    · intro h_truth_imp
      rcases SetMaximalConsistent.negation_complete h_mcs (ψ.imp χ) with h_imp | h_neg_imp
      · exact h_imp
      · exfalso
        have h_ψ_mcs : ψ ∈ fam.mcs t := by
          have h_taut := neg_imp_implies_antecedent ψ χ
          exact SetMaximalConsistent.closed_under_derivation h_mcs [(ψ.imp χ).neg]
            (by simp [h_neg_imp])
            (Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _
              (Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_taut (by intro; simp))
              (Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)))
        have h_neg_χ_mcs : χ.neg ∈ fam.mcs t := by
          have h_taut := neg_imp_implies_neg_consequent ψ χ
          exact SetMaximalConsistent.closed_under_derivation h_mcs [(ψ.imp χ).neg]
            (by simp [h_neg_imp])
            (Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _
              (Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_taut (by intro; simp))
              (Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)))
        have h_ψ_true : truth_at (ParametricCanonicalTaskModel D) (ShiftClosedParametricCanonicalOmega B)
            (parametric_to_history fam) t ψ :=
          (ih_ψ h_ψ_sub fam hfam t).mp h_ψ_mcs
        have h_χ_true : truth_at (ParametricCanonicalTaskModel D) (ShiftClosedParametricCanonicalOmega B)
            (parametric_to_history fam) t χ :=
          h_truth_imp h_ψ_true
        have h_χ_mcs : χ ∈ fam.mcs t := (ih_χ h_χ_sub fam hfam t).mpr h_χ_true
        exact set_consistent_not_both (fam.is_mcs t).1 χ h_χ_mcs h_neg_χ_mcs
  | box ψ ih =>
    have h_ψ_sub : ψ ∈ subformulaClosure root := closure_box root ψ h_sub
    constructor
    · intro h_box σ h_σ_mem
      obtain ⟨fam', hfam', delta, h_σ_eq⟩ := h_σ_mem
      have h_box_shifted : Formula.box ψ ∈ fam.mcs (t + delta) :=
        parametric_box_persistent fam ψ t (t + delta) h_box
      have h_ψ_fam' : ψ ∈ fam'.mcs (t + delta) :=
        B.modal_forward fam hfam ψ (t + delta) h_box_shifted fam' hfam'
      have h_truth_canon := (ih h_ψ_sub fam' hfam' (t + delta)).mp h_ψ_fam'
      have h_preserve := TimeShift.time_shift_preserves_truth
        (ParametricCanonicalTaskModel D) (ShiftClosedParametricCanonicalOmega B)
        (shiftClosedParametricCanonicalOmega_is_shift_closed B) (parametric_to_history fam')
        t (t + delta) ψ
      have h_delta : (t + delta) - t = delta := add_sub_cancel_left t delta
      rw [h_σ_eq]
      rw [WorldHistory.time_shift_congr (parametric_to_history fam') ((t + delta) - t) delta h_delta] at h_preserve
      exact h_preserve.mpr h_truth_canon
    · intro h_all_σ
      have h_all_fam : ∀ fam' ∈ B.families, ψ ∈ fam'.mcs t := by
        intro fam' hfam'
        have h_mem := parametricCanonicalOmega_subset_shiftClosed B ⟨fam', hfam', rfl⟩
        exact (ih h_ψ_sub fam' hfam' t).mpr (h_all_σ (parametric_to_history fam') h_mem)
      exact B.modal_backward fam hfam ψ t h_all_fam
  | untl phi psi ih_phi ih_psi =>
    have h_phi_sub : phi ∈ subformulaClosure root := closure_untl_left root phi psi h_sub
    have h_psi_sub : psi ∈ subformulaClosure root := closure_untl_right root phi psi h_sub
    simp only [truth_at]
    obtain ⟨h_fwd_U, _⟩ := h_fuc fam hfam
    obtain ⟨h_bwd_U, _⟩ := h_buc fam hfam
    constructor
    · intro h_U
      obtain ⟨s, h_ts, h_phi_s, h_psi_guard⟩ := h_fwd_U t phi psi h_U
      exact ⟨s, h_ts,
        (ih_phi h_phi_sub fam hfam s).mp h_phi_s,
        fun r h_tr h_rs => (ih_psi h_psi_sub fam hfam r).mp (h_psi_guard r h_tr h_rs)⟩
    · intro ⟨s, h_ts, h_truth_phi_s, h_truth_psi_guard⟩
      exact h_bwd_U t phi psi ⟨s, h_ts,
        (ih_phi h_phi_sub fam hfam s).mpr h_truth_phi_s,
        fun r h_tr h_rs => (ih_psi h_psi_sub fam hfam r).mpr (h_truth_psi_guard r h_tr h_rs)⟩
  | snce phi psi ih_phi ih_psi =>
    have h_phi_sub : phi ∈ subformulaClosure root := closure_snce_left root phi psi h_sub
    have h_psi_sub : psi ∈ subformulaClosure root := closure_snce_right root phi psi h_sub
    simp only [truth_at]
    obtain ⟨_, h_fwd_S⟩ := h_fuc fam hfam
    obtain ⟨_, h_bwd_S⟩ := h_buc fam hfam
    constructor
    · intro h_S
      obtain ⟨s, h_st, h_phi_s, h_psi_guard⟩ := h_fwd_S t phi psi h_S
      exact ⟨s, h_st,
        (ih_phi h_phi_sub fam hfam s).mp h_phi_s,
        fun r h_sr h_rt => (ih_psi h_psi_sub fam hfam r).mp (h_psi_guard r h_sr h_rt)⟩
    · intro ⟨s, h_st, h_truth_phi_s, h_truth_psi_guard⟩
      exact h_bwd_S t phi psi ⟨s, h_st,
        (ih_phi h_phi_sub fam hfam s).mpr h_truth_phi_s,
        fun r h_sr h_rt => (ih_psi h_psi_sub fam hfam r).mpr (h_truth_psi_guard r h_sr h_rt)⟩

/-!
## Restricted Completeness Theorem
-/

/--
Restricted completeness: if φ.neg is in a family's MCS, then φ is false at the
canonical model. Uses restricted temporal coherence for φ only.
-/
theorem restricted_parametric_completeness_from_neg_membership
    (B : BFMCS D)
    (root : Formula)
    (h_rtc : B.restricted_temporally_coherent root)
    (h_buc : B.backward_until_since_coherent)
    (h_fuc : B.forward_until_since_coherent)
    (φ : Formula)
    (h_sub : φ ∈ subformulaClosure root)
    (fam : FMCS D) (hfam : fam ∈ B.families)
    (t : D) (h_neg_in : φ.neg ∈ fam.mcs t) :
    ¬truth_at (ParametricCanonicalTaskModel D) (ShiftClosedParametricCanonicalOmega B)
      (parametric_to_history fam) t φ := by
  intro h_phi_true
  have h_phi_in := (restricted_parametric_shifted_truth_lemma B root h_rtc h_buc h_fuc φ h_sub fam hfam t).mpr h_phi_true
  exact set_consistent_not_both (fam.is_mcs t).1 φ h_phi_in h_neg_in

/-!
## Fully Restricted Truth Lemma and Completeness

These variants weaken ALL three coherence hypotheses to their restricted forms:
- `restricted_temporally_coherent root` (forward_F/backward_P for deferralClosure only)
- `restricted_backward_until_since_coherent root` (buc for subformulaClosure only)
- `restricted_forward_until_since_coherent root` (fuc for subformulaClosure only)

The truth lemma induction only uses these coherence properties for subformulas of root,
so the restricted versions suffice.
-/

/--
Fully restricted parametric shifted truth lemma: all three coherence hypotheses
are restricted to subformulaClosure/deferralClosure of root.
-/
theorem fully_restricted_parametric_shifted_truth_lemma (B : BFMCS D)
    (root : Formula)
    (h_rtc : B.restricted_temporally_coherent root)
    (h_buc : B.restricted_backward_until_since_coherent root)
    (h_fuc : B.restricted_forward_until_since_coherent root) (φ : Formula)
    (h_sub : φ ∈ subformulaClosure root)
    (fam : FMCS D) (hfam : fam ∈ B.families) (t : D) :
    φ ∈ fam.mcs t ↔
    truth_at (ParametricCanonicalTaskModel D) (ShiftClosedParametricCanonicalOmega B)
      (parametric_to_history fam) t φ := by
  induction φ generalizing fam t with
  | atom p =>
    simp only [truth_at, ParametricCanonicalTaskModel, parametric_to_history]
    constructor
    · intro h_mem
      exact ⟨True.intro, h_mem⟩
    · intro ⟨_, h_val⟩
      exact h_val
  | bot =>
    simp only [truth_at]
    constructor
    · intro h_mem
      exfalso
      have h_cons := (fam.is_mcs t).1
      have h_deriv : DerivationTree FrameClass.Base [Formula.bot] Formula.bot :=
        Bimodal.ProofSystem.DerivationTree.assumption [Formula.bot] Formula.bot (by simp)
      exact h_cons [Formula.bot] (fun psi hpsi => by simp at hpsi; rw [hpsi]; exact h_mem) ⟨h_deriv⟩
    · intro h; exact h.elim
  | imp ψ χ ih_ψ ih_χ =>
    have h_ψ_sub : ψ ∈ subformulaClosure root := closure_imp_left root ψ χ h_sub
    have h_χ_sub : χ ∈ subformulaClosure root := closure_imp_right root ψ χ h_sub
    simp only [truth_at]
    have h_mcs := fam.is_mcs t
    constructor
    · intro h_imp h_ψ_true
      have h_ψ_mem := (ih_ψ h_ψ_sub fam hfam t).mpr h_ψ_true
      exact (ih_χ h_χ_sub fam hfam t).mp (SetMaximalConsistent.implication_property h_mcs h_imp h_ψ_mem)
    · intro h_truth_imp
      rcases SetMaximalConsistent.negation_complete h_mcs (ψ.imp χ) with h_imp | h_neg_imp
      · exact h_imp
      · exfalso
        have h_ψ_mcs : ψ ∈ fam.mcs t := by
          have h_taut := neg_imp_implies_antecedent ψ χ
          exact SetMaximalConsistent.closed_under_derivation h_mcs [(ψ.imp χ).neg]
            (by simp [h_neg_imp])
            (Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _
              (Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_taut (by intro; simp))
              (Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)))
        have h_neg_χ_mcs : χ.neg ∈ fam.mcs t := by
          have h_taut := neg_imp_implies_neg_consequent ψ χ
          exact SetMaximalConsistent.closed_under_derivation h_mcs [(ψ.imp χ).neg]
            (by simp [h_neg_imp])
            (Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _
              (Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_taut (by intro; simp))
              (Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)))
        have h_ψ_true : truth_at (ParametricCanonicalTaskModel D) (ShiftClosedParametricCanonicalOmega B)
            (parametric_to_history fam) t ψ :=
          (ih_ψ h_ψ_sub fam hfam t).mp h_ψ_mcs
        have h_χ_true : truth_at (ParametricCanonicalTaskModel D) (ShiftClosedParametricCanonicalOmega B)
            (parametric_to_history fam) t χ :=
          h_truth_imp h_ψ_true
        have h_χ_mcs : χ ∈ fam.mcs t := (ih_χ h_χ_sub fam hfam t).mpr h_χ_true
        exact set_consistent_not_both (fam.is_mcs t).1 χ h_χ_mcs h_neg_χ_mcs
  | box ψ ih =>
    have h_ψ_sub : ψ ∈ subformulaClosure root := closure_box root ψ h_sub
    constructor
    · intro h_box σ h_σ_mem
      obtain ⟨fam', hfam', delta, h_σ_eq⟩ := h_σ_mem
      have h_box_shifted : Formula.box ψ ∈ fam.mcs (t + delta) :=
        parametric_box_persistent fam ψ t (t + delta) h_box
      have h_ψ_fam' : ψ ∈ fam'.mcs (t + delta) :=
        B.modal_forward fam hfam ψ (t + delta) h_box_shifted fam' hfam'
      have h_truth_canon := (ih h_ψ_sub fam' hfam' (t + delta)).mp h_ψ_fam'
      have h_preserve := TimeShift.time_shift_preserves_truth
        (ParametricCanonicalTaskModel D) (ShiftClosedParametricCanonicalOmega B)
        (shiftClosedParametricCanonicalOmega_is_shift_closed B) (parametric_to_history fam')
        t (t + delta) ψ
      have h_delta : (t + delta) - t = delta := add_sub_cancel_left t delta
      rw [h_σ_eq]
      rw [WorldHistory.time_shift_congr (parametric_to_history fam') ((t + delta) - t) delta h_delta] at h_preserve
      exact h_preserve.mpr h_truth_canon
    · intro h_all_σ
      have h_all_fam : ∀ fam' ∈ B.families, ψ ∈ fam'.mcs t := by
        intro fam' hfam'
        have h_mem := parametricCanonicalOmega_subset_shiftClosed B ⟨fam', hfam', rfl⟩
        exact (ih h_ψ_sub fam' hfam' t).mpr (h_all_σ (parametric_to_history fam') h_mem)
      exact B.modal_backward fam hfam ψ t h_all_fam
  | untl phi psi ih_phi ih_psi =>
    have h_phi_sub : phi ∈ subformulaClosure root := closure_untl_left root phi psi h_sub
    have h_psi_sub : psi ∈ subformulaClosure root := closure_untl_right root phi psi h_sub
    simp only [truth_at]
    obtain ⟨h_fwd_U, _⟩ := h_fuc fam hfam
    obtain ⟨h_bwd_U, _⟩ := h_buc fam hfam
    constructor
    · intro h_U
      obtain ⟨s, h_ts, h_phi_s, h_psi_guard⟩ := h_fwd_U t phi psi h_sub h_U
      exact ⟨s, h_ts,
        (ih_phi h_phi_sub fam hfam s).mp h_phi_s,
        fun r h_tr h_rs => (ih_psi h_psi_sub fam hfam r).mp (h_psi_guard r h_tr h_rs)⟩
    · intro ⟨s, h_ts, h_truth_phi_s, h_truth_psi_guard⟩
      exact h_bwd_U t phi psi h_sub ⟨s, h_ts,
        (ih_phi h_phi_sub fam hfam s).mpr h_truth_phi_s,
        fun r h_tr h_rs => (ih_psi h_psi_sub fam hfam r).mpr (h_truth_psi_guard r h_tr h_rs)⟩
  | snce phi psi ih_phi ih_psi =>
    have h_phi_sub : phi ∈ subformulaClosure root := closure_snce_left root phi psi h_sub
    have h_psi_sub : psi ∈ subformulaClosure root := closure_snce_right root phi psi h_sub
    simp only [truth_at]
    obtain ⟨_, h_fwd_S⟩ := h_fuc fam hfam
    obtain ⟨_, h_bwd_S⟩ := h_buc fam hfam
    constructor
    · intro h_S
      obtain ⟨s, h_st, h_phi_s, h_psi_guard⟩ := h_fwd_S t phi psi h_sub h_S
      exact ⟨s, h_st,
        (ih_phi h_phi_sub fam hfam s).mp h_phi_s,
        fun r h_sr h_rt => (ih_psi h_psi_sub fam hfam r).mp (h_psi_guard r h_sr h_rt)⟩
    · intro ⟨s, h_st, h_truth_phi_s, h_truth_psi_guard⟩
      exact h_bwd_S t phi psi h_sub ⟨s, h_st,
        (ih_phi h_phi_sub fam hfam s).mpr h_truth_phi_s,
        fun r h_sr h_rt => (ih_psi h_psi_sub fam hfam r).mpr (h_truth_psi_guard r h_sr h_rt)⟩

/--
Fully restricted completeness: if φ.neg is in a family's MCS, then φ is false at the
canonical model. Uses restricted temporal coherence, restricted backward, and restricted
forward Until/Since coherence — all scoped to root.
-/
theorem fully_restricted_parametric_completeness_from_neg_membership
    (B : BFMCS D)
    (root : Formula)
    (h_rtc : B.restricted_temporally_coherent root)
    (h_buc : B.restricted_backward_until_since_coherent root)
    (h_fuc : B.restricted_forward_until_since_coherent root)
    (φ : Formula)
    (h_sub : φ ∈ subformulaClosure root)
    (fam : FMCS D) (hfam : fam ∈ B.families)
    (t : D) (h_neg_in : φ.neg ∈ fam.mcs t) :
    ¬truth_at (ParametricCanonicalTaskModel D) (ShiftClosedParametricCanonicalOmega B)
      (parametric_to_history fam) t φ := by
  intro h_phi_true
  have h_phi_in := (fully_restricted_parametric_shifted_truth_lemma B root h_rtc h_buc h_fuc φ h_sub fam hfam t).mpr h_phi_true
  exact set_consistent_not_both (fam.is_mcs t).1 φ h_phi_in h_neg_in

end Bimodal.Metalogic.Algebraic.RestrictedParametricTruthLemma
