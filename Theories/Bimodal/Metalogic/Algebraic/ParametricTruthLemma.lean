import Bimodal.Metalogic.Algebraic.ParametricHistory
import Bimodal.Metalogic.Bundle.TemporalCoherence
import Bimodal.Semantics.TaskModel
import Bimodal.Theorems.Propositional

/-!
# D-Parametric Truth Lemma

This module proves the truth lemma for the D-parametric canonical model construction.
The truth lemma states:

  phi in fam.mcs t <-> truth_at ParametricCanonicalTaskModel (ParametricCanonicalOmega B) (parametric_to_history fam) t phi

This is the key lemma connecting MCS membership to semantic truth evaluation.

## Main Results

- `ParametricCanonicalTaskModel D`: D-parametric task model with valuation = MCS membership
- `parametric_canonical_truth_lemma`: The main truth lemma for D-parametric canonical model
- `parametric_shifted_truth_lemma`: Truth lemma for shift-closed Omega
- `parametric_box_persistent`: Box phi persists to all times (TF axiom)

## Design

The proof follows the same structure as CanonicalConstruction.lean, but generalized
to arbitrary D. The key cases are:
- atom: valuation = MCS membership (by definition)
- bot: both sides are False
- imp: by induction and MCS closure under derivation
- box: by modal coherence of BFMCS
- all_future (G): by forward_G and temporal_backward_G
- all_past (H): by backward_H and temporal_backward_H

## References

- Existing: Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean
- Research: specs/985_lindenbaum_tarski_representation_theorem/reports/research-002.md
-/

namespace Bimodal.Metalogic.Algebraic.ParametricTruthLemma

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Algebraic.ParametricCanonical
open Bimodal.Metalogic.Algebraic.ParametricHistory
open Bimodal.Semantics

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/-!
## Parametric Canonical Task Model
-/

/--
The D-parametric canonical task model: valuation is MCS membership.

An atom p is true at world-state M iff `atom p in M.val`.
-/
def ParametricCanonicalTaskModel (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] : TaskModel (ParametricCanonicalTaskFrame D) where
  valuation := fun M p => Formula.atom p ∈ M.val

/-!
## Helper Tautologies for Imp Case
-/

/-- Classical tautology: neg(psi -> chi) -> psi -/
private noncomputable def neg_imp_implies_antecedent (ψ χ : Formula) :
    Bimodal.ProofSystem.DerivationTree [] ((ψ.imp χ).neg.imp ψ) := by
  have h_efq : Bimodal.ProofSystem.DerivationTree [] (ψ.neg.imp (ψ.imp χ)) :=
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
    Bimodal.ProofSystem.DerivationTree [] ((ψ.imp χ).neg.imp χ.neg) := by
  have h_prop_s : [] ⊢ χ.imp (ψ.imp χ) :=
    Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.prop_s χ ψ)
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
## Box Persistence
-/

/-- Past analog of TF axiom: Box phi -> H(Box phi), derived via temporal duality. -/
private def past_tf_deriv (φ : Formula) :
    Bimodal.ProofSystem.DerivationTree [] ((Formula.box φ).imp (Formula.box φ).all_past) := by
  have h_tf_swap := Bimodal.ProofSystem.DerivationTree.axiom [] _
    (Bimodal.ProofSystem.Axiom.temp_future (Formula.swap_past_future φ))
  have h_dual := Bimodal.ProofSystem.DerivationTree.temporal_duality _ h_tf_swap
  have h_eq : Formula.swap_past_future ((Formula.box (Formula.swap_past_future φ)).imp
      (Formula.box (Formula.swap_past_future φ)).all_future) =
    (Formula.box φ).imp (Formula.box φ).all_past := by
    simp [Formula.swap_past_future, Formula.swap_temporal]
  rw [h_eq] at h_dual
  exact h_dual

/-- Box phi at time t implies Box phi at all times s, for any family in an FMCS.

The proof uses:
1. TF axiom: Box phi -> G(Box phi) -- so Box phi persists to all future times
2. Temporal dual of TF: Box phi -> H(Box phi) -- so Box phi persists to all past times
3. forward_G and backward_H to extract Box phi at specific times
-/
theorem parametric_box_persistent
    (fam : FMCS D)
    (φ : Formula) (t s : D)
    (h_box : Formula.box φ ∈ fam.mcs t) :
    Formula.box φ ∈ fam.mcs s := by
  -- Step 1: G(Box phi) in fam.mcs t via TF axiom
  have h_tf : (Formula.box φ).imp (Formula.box φ).all_future ∈ fam.mcs t :=
    theorem_in_mcs (fam.is_mcs t) (Bimodal.ProofSystem.DerivationTree.axiom [] _
      (Bimodal.ProofSystem.Axiom.temp_future φ))
  have h_G_box : (Formula.box φ).all_future ∈ fam.mcs t :=
    SetMaximalConsistent.implication_property (fam.is_mcs t) h_tf h_box
  -- Step 2: H(Box phi) in fam.mcs t via past-TF
  have h_past_tf : (Formula.box φ).imp (Formula.box φ).all_past ∈ fam.mcs t :=
    theorem_in_mcs (fam.is_mcs t) (past_tf_deriv φ)
  have h_H_box : (Formula.box φ).all_past ∈ fam.mcs t :=
    SetMaximalConsistent.implication_property (fam.is_mcs t) h_past_tf h_box
  -- Step 3: Case split on s vs t (three cases for irreflexive semantics)
  rcases lt_trichotomy t s with h_lt | h_eq | h_gt
  · -- s > t: use forward_G (strict)
    exact fam.forward_G t s (Formula.box φ) h_lt h_G_box
  · -- s = t: trivial from h_box
    rw [← h_eq]
    exact h_box
  · -- s < t: use backward_H (strict)
    exact fam.backward_H t s (Formula.box φ) h_gt h_H_box

/-!
## The Parametric Canonical Truth Lemma
-/

/--
The parametric canonical truth lemma: MCS membership iff truth at canonical model.

For any D-parametric BFMCS with temporal coherence, family in the BFMCS, time t, and formula phi:
  phi in fam.mcs t <-> truth_at (ParametricCanonicalTaskModel D) (ParametricCanonicalOmega B) (parametric_to_history fam) t phi
-/
theorem parametric_canonical_truth_lemma
    (B : BFMCS D) (h_tc : B.temporally_coherent)
    (fam : FMCS D) (hfam : fam ∈ B.families)
    (t : D) (phi : Formula) :
    phi ∈ fam.mcs t ↔
      truth_at (ParametricCanonicalTaskModel D) (ParametricCanonicalOmega B)
        (parametric_to_history fam) t phi := by
  induction phi generalizing fam t with
  | atom p =>
    -- atom case: phi in fam.mcs t <-> exists ht, M.valuation (tau.states t ht) p
    -- Since domain = True, ht = True.intro
    -- valuation (fam.mcs t, is_mcs t) p = (atom p in fam.mcs t)
    simp only [truth_at, ParametricCanonicalTaskModel, parametric_to_history]
    constructor
    · intro h_atom
      exact ⟨True.intro, h_atom⟩
    · intro ⟨_, h_val⟩
      exact h_val
  | bot =>
    -- bot case: bot in fam.mcs t <-> False
    simp only [truth_at]
    constructor
    · intro h_bot
      -- bot in MCS contradicts consistency
      have h_cons := (fam.is_mcs t).1
      have h_deriv : Bimodal.ProofSystem.DerivationTree [Formula.bot] Formula.bot :=
        Bimodal.ProofSystem.DerivationTree.assumption [Formula.bot] Formula.bot (by simp)
      exact h_cons [Formula.bot] (fun psi hpsi => by simp at hpsi; rw [hpsi]; exact h_bot) ⟨h_deriv⟩
    · intro h_false
      exact False.elim h_false
  | imp psi chi ih_psi ih_chi =>
    -- imp case: (psi -> chi) in MCS <-> (truth psi -> truth chi)
    simp only [truth_at]
    have h_mcs := fam.is_mcs t
    constructor
    · -- Forward: (psi -> chi) in MCS and truth psi -> truth chi
      intro h_imp h_psi_true
      -- By IH backward: psi in MCS
      have h_psi_mcs : psi ∈ fam.mcs t := (ih_psi fam hfam t).mpr h_psi_true
      -- By MCS modus ponens: chi in MCS
      have h_chi_mcs : chi ∈ fam.mcs t := SetMaximalConsistent.implication_property h_mcs h_imp h_psi_mcs
      -- By IH forward: truth chi
      exact (ih_chi fam hfam t).mp h_chi_mcs
    · -- Backward: (truth psi -> truth chi) -> (psi -> chi) in MCS
      intro h_truth_imp
      rcases SetMaximalConsistent.negation_complete h_mcs (psi.imp chi) with h_imp | h_neg_imp
      · exact h_imp
      · -- neg(psi -> chi) in MCS - derive contradiction
        exfalso
        -- From neg(psi -> chi), we get psi in MCS and neg(chi) in MCS
        have h_psi_mcs : psi ∈ fam.mcs t := by
          have h_taut := neg_imp_implies_antecedent psi chi
          exact SetMaximalConsistent.closed_under_derivation h_mcs [(psi.imp chi).neg]
            (by simp [h_neg_imp])
            (Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _
              (Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_taut (by intro; simp))
              (Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)))
        have h_neg_chi_mcs : chi.neg ∈ fam.mcs t := by
          have h_taut := neg_imp_implies_neg_consequent psi chi
          exact SetMaximalConsistent.closed_under_derivation h_mcs [(psi.imp chi).neg]
            (by simp [h_neg_imp])
            (Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _
              (Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_taut (by intro; simp))
              (Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)))
        -- By IH: psi is true
        have h_psi_true : truth_at (ParametricCanonicalTaskModel D) (ParametricCanonicalOmega B)
            (parametric_to_history fam) t psi :=
          (ih_psi fam hfam t).mp h_psi_mcs
        -- By hypothesis: chi is true
        have h_chi_true : truth_at (ParametricCanonicalTaskModel D) (ParametricCanonicalOmega B)
            (parametric_to_history fam) t chi :=
          h_truth_imp h_psi_true
        -- By IH: chi in MCS
        have h_chi_mcs : chi ∈ fam.mcs t := (ih_chi fam hfam t).mpr h_chi_true
        -- Contradiction: chi and neg(chi) in consistent MCS
        exact set_consistent_not_both (fam.is_mcs t).1 chi h_chi_mcs h_neg_chi_mcs
  | box psi ih =>
    -- box case: box psi in MCS <-> forall sigma in Omega, truth sigma t psi
    simp only [truth_at]
    constructor
    · -- Forward: box psi in MCS -> forall sigma in Omega, truth sigma t psi
      intro h_box sigma h_sigma_mem
      -- sigma in ParametricCanonicalOmega B means sigma = parametric_to_history fam' for some fam' in B.families
      obtain ⟨fam', hfam', h_eq⟩ := h_sigma_mem
      subst h_eq
      -- By modal_forward: psi in fam'.mcs t
      have h_psi_mcs : psi ∈ fam'.mcs t := B.modal_forward fam hfam psi t h_box fam' hfam'
      -- By IH: truth at fam'
      exact (ih fam' hfam' t).mp h_psi_mcs
    · -- Backward: forall sigma in Omega, truth sigma t psi -> box psi in MCS
      intro h_all
      -- For each fam' in B.families, parametric_to_history fam' is in ParametricCanonicalOmega
      -- By IH backward: psi in fam'.mcs t
      have h_psi_all_mcs : ∀ fam' ∈ B.families, psi ∈ fam'.mcs t := by
        intro fam' hfam'
        have h_in_omega : parametric_to_history fam' ∈ ParametricCanonicalOmega B := ⟨fam', hfam', rfl⟩
        have h_truth := h_all (parametric_to_history fam') h_in_omega
        exact (ih fam' hfam' t).mpr h_truth
      -- By modal_backward: box psi in MCS
      exact B.modal_backward fam hfam psi t h_psi_all_mcs
  | all_future psi ih =>
    -- G case: Under strict semantics (Task 991), G quantifies over s > t
    simp only [truth_at]
    constructor
    · -- Forward: G psi in MCS -> forall s > t, truth tau s psi
      intro h_G s hts
      have h_psi_mcs : psi ∈ fam.mcs s := fam.forward_G t s psi hts h_G
      exact (ih fam hfam s).mp h_psi_mcs
    · -- Backward: forall s > t, truth tau s psi -> G psi in MCS
      intro h_all
      obtain ⟨h_forward_F, h_backward_P⟩ := h_tc fam hfam
      let tcf : TemporalCoherentFamily D := {
        toFMCS := fam
        forward_F := h_forward_F
        backward_P := h_backward_P
      }
      have h_all_mcs : ∀ s : D, t < s → psi ∈ fam.mcs s := by
        intro s hts
        exact (ih fam hfam s).mpr (h_all s hts)
      exact temporal_backward_G tcf t psi h_all_mcs
  | all_past psi ih =>
    -- H case: Under strict semantics (Task 991), H quantifies over s < t
    simp only [truth_at]
    constructor
    · -- Forward: H psi in MCS -> forall s < t, truth tau s psi
      intro h_H s hst
      have h_psi_mcs : psi ∈ fam.mcs s := fam.backward_H t s psi hst h_H
      exact (ih fam hfam s).mp h_psi_mcs
    · -- Backward: forall s < t, truth tau s psi -> H psi in MCS
      intro h_all
      obtain ⟨h_forward_F, h_backward_P⟩ := h_tc fam hfam
      let tcf : TemporalCoherentFamily D := {
        toFMCS := fam
        forward_F := h_forward_F
        backward_P := h_backward_P
      }
      have h_all_mcs : ∀ s : D, s < t → psi ∈ fam.mcs s := by
        intro s hst
        exact (ih fam hfam s).mpr (h_all s hst)
      exact temporal_backward_H tcf t psi h_all_mcs

/-!
## Shifted Truth Lemma

The truth lemma extended to ShiftClosedParametricCanonicalOmega. This is the key result
enabling the completeness proof: it relates MCS membership to truth in the canonical
model with a shift-closed set of histories.
-/

/--
Shifted truth lemma: MCS membership iff truth at the parametric canonical model with
shift-closed parametric canonical Omega. The box forward case uses `parametric_box_persistent`
to show that Box phi persists to all times, enabling truth at shifted histories
via `time_shift_preserves_truth`.
-/
theorem parametric_shifted_truth_lemma (B : BFMCS D)
    (h_tc : B.temporally_coherent) (φ : Formula)
    (fam : FMCS D) (hfam : fam ∈ B.families) (t : D) :
    φ ∈ fam.mcs t ↔
    truth_at (ParametricCanonicalTaskModel D) (ShiftClosedParametricCanonicalOmega B)
      (parametric_to_history fam) t φ := by
  induction φ generalizing fam t with
  | atom p =>
    -- Identical to parametric_canonical_truth_lemma (atom case is Omega-independent)
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
      have h_deriv : Bimodal.ProofSystem.DerivationTree [Formula.bot] Formula.bot :=
        Bimodal.ProofSystem.DerivationTree.assumption [Formula.bot] Formula.bot (by simp)
      exact h_cons [Formula.bot] (fun psi hpsi => by simp at hpsi; rw [hpsi]; exact h_mem) ⟨h_deriv⟩
    · intro h; exact h.elim
  | imp ψ χ ih_ψ ih_χ =>
    simp only [truth_at]
    have h_mcs := fam.is_mcs t
    constructor
    · intro h_imp h_ψ_true
      have h_ψ_mem := (ih_ψ fam hfam t).mpr h_ψ_true
      exact (ih_χ fam hfam t).mp (SetMaximalConsistent.implication_property h_mcs h_imp h_ψ_mem)
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
          (ih_ψ fam hfam t).mp h_ψ_mcs
        have h_χ_true : truth_at (ParametricCanonicalTaskModel D) (ShiftClosedParametricCanonicalOmega B)
            (parametric_to_history fam) t χ :=
          h_truth_imp h_ψ_true
        have h_χ_mcs : χ ∈ fam.mcs t := (ih_χ fam hfam t).mpr h_χ_true
        exact set_consistent_not_both (fam.is_mcs t).1 χ h_χ_mcs h_neg_χ_mcs
  | box ψ ih =>
    constructor
    · -- Forward: Box ψ in fam.mcs t -> forall sigma in ShiftClosedParametricCanonicalOmega B, truth_at ... sigma t ψ
      intro h_box σ h_σ_mem
      -- sigma in ShiftClosedParametricCanonicalOmega B means sigma = time_shift (parametric_to_history fam') delta
      obtain ⟨fam', hfam', delta, h_σ_eq⟩ := h_σ_mem
      -- By parametric_box_persistent: Box ψ in fam.mcs (t + delta)
      have h_box_shifted : Formula.box ψ ∈ fam.mcs (t + delta) :=
        parametric_box_persistent fam ψ t (t + delta) h_box
      -- By modal_forward: ψ in fam'.mcs (t + delta)
      have h_ψ_fam' : ψ ∈ fam'.mcs (t + delta) :=
        B.modal_forward fam hfam ψ (t + delta) h_box_shifted fam' hfam'
      -- By IH at (fam', hfam', t + delta): truth_at ... (parametric_to_history fam') (t + delta) ψ
      have h_truth_canon := (ih fam' hfam' (t + delta)).mp h_ψ_fam'
      -- By time_shift_preserves_truth with shift-closed Omega:
      -- truth_at ... (time_shift (parametric_to_history fam') delta) t ψ <-> truth_at ... (parametric_to_history fam') (t + delta) ψ
      have h_preserve := TimeShift.time_shift_preserves_truth
        (ParametricCanonicalTaskModel D) (ShiftClosedParametricCanonicalOmega B)
        (shiftClosedParametricCanonicalOmega_is_shift_closed B) (parametric_to_history fam')
        t (t + delta) ψ
      -- time_shift_preserves_truth: truth_at ... (time_shift sigma (y - x)) x phi <-> truth_at ... sigma y phi
      -- With x = t, y = t + delta: (t+delta) - t = delta
      have h_delta : (t + delta) - t = delta := add_sub_cancel_left t delta
      rw [h_σ_eq]
      rw [WorldHistory.time_shift_congr (parametric_to_history fam') ((t + delta) - t) delta h_delta] at h_preserve
      exact h_preserve.mpr h_truth_canon
    · -- Backward: (forall sigma in ShiftClosedParametricCanonicalOmega B, truth_at ... sigma t ψ) -> Box ψ in fam.mcs t
      intro h_all_σ
      -- Only use canonical histories (delta = 0 case)
      have h_all_fam : ∀ fam' ∈ B.families, ψ ∈ fam'.mcs t := by
        intro fam' hfam'
        have h_mem := parametricCanonicalOmega_subset_shiftClosed B ⟨fam', hfam', rfl⟩
        exact (ih fam' hfam' t).mpr (h_all_σ (parametric_to_history fam') h_mem)
      exact B.modal_backward fam hfam ψ t h_all_fam
  | all_future ψ ih =>
    -- G case: Under strict semantics (Task 991), G quantifies over s > t
    simp only [truth_at]
    constructor
    · -- Forward: G ψ ∈ fam.mcs t → ∀ s > t, truth_at ... s ψ
      intro h_G s hts
      have h_psi_mcs : ψ ∈ fam.mcs s := fam.forward_G t s ψ hts h_G
      exact (ih fam hfam s).mp h_psi_mcs
    · -- Backward: (∀ s > t, truth_at ... s ψ) → G ψ ∈ fam.mcs t
      intro h_all
      obtain ⟨h_forward_F, h_backward_P⟩ := h_tc fam hfam
      let tcf : TemporalCoherentFamily D := {
        toFMCS := fam
        forward_F := h_forward_F
        backward_P := h_backward_P
      }
      have h_all_mcs : ∀ s : D, t < s → ψ ∈ fam.mcs s := by
        intro s hts
        exact (ih fam hfam s).mpr (h_all s hts)
      exact temporal_backward_G tcf t ψ h_all_mcs
  | all_past ψ ih =>
    -- H case: Under strict semantics (Task 991), H quantifies over s < t
    simp only [truth_at]
    constructor
    · -- Forward: H ψ ∈ fam.mcs t → ∀ s < t, truth_at ... s ψ
      intro h_H s hst
      have h_psi_mcs : ψ ∈ fam.mcs s := fam.backward_H t s ψ hst h_H
      exact (ih fam hfam s).mp h_psi_mcs
    · -- Backward: (∀ s < t, truth_at ... s ψ) → H ψ ∈ fam.mcs t
      intro h_all
      obtain ⟨h_forward_F, h_backward_P⟩ := h_tc fam hfam
      let tcf : TemporalCoherentFamily D := {
        toFMCS := fam
        forward_F := h_forward_F
        backward_P := h_backward_P
      }
      have h_all_mcs : ∀ s : D, s < t → ψ ∈ fam.mcs s := by
        intro s hst
        exact (ih fam hfam s).mpr (h_all s hst)
      exact temporal_backward_H tcf t ψ h_all_mcs

end Bimodal.Metalogic.Algebraic.ParametricTruthLemma
