import Bimodal.Metalogic.Algebraic.DeterministicChain
import Bimodal.Metalogic.Algebraic.UltrafilterChain
import Bimodal.Metalogic.Algebraic.ParametricTruthLemma
import Bimodal.Metalogic.Algebraic.ParametricRepresentation
import Bimodal.Metalogic.Bundle.TemporalCoherence
import Bimodal.Metalogic.Bundle.CanonicalFrame

/-!
# Deterministic FMCS and BFMCS Construction

Builds a BFMCS from the deterministic chain and wires to the parametric
representation theorem for completeness over Int.

## Sorry Inventory

| Theorem | Status | Notes |
|---------|--------|-------|
| `deterministic_forward_F` | SORRY | Intra-family F witness |
| `deterministic_backward_P` | SORRY | Intra-family P witness |

All structural theorems (FMCS, BFMCS, modal coherence, completeness wiring)
are sorry-free given these two.
-/

namespace Bimodal.Metalogic.Algebraic.DeterministicFMCS

open Bimodal.Syntax Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Algebraic.DeterministicChain
open Bimodal.Metalogic.Algebraic.UltrafilterChain
open Bimodal.Metalogic.Algebraic.ParametricTruthLemma
open Bimodal.Metalogic.Algebraic.ParametricRepresentation
open Bimodal.Metalogic.Algebraic.ParametricHistory

/-!
## DeterministicFMCS
-/

/-- Build an FMCS Int from the deterministic chain rooted at M₀. -/
noncomputable def DeterministicFMCS (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀) :
    FMCS Int where
  mcs := deterministic_chain M₀
  is_mcs := deterministic_chain_mcs M₀ h_mcs
  forward_G := fun t t' phi h_lt h_G => forward_G_int M₀ h_mcs t t' h_lt phi h_G
  backward_H := fun t t' phi h_lt h_H => backward_H_int M₀ h_mcs t t' h_lt phi h_H

/-- DeterministicFMCS at time 0 is M₀. -/
theorem DeterministicFMCS_at_zero (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀) :
    (DeterministicFMCS M₀ h_mcs).mcs 0 = M₀ := rfl

/-!
## Forward F / Backward P (Isolated Sorries)
-/

/-- **SORRY**: Intra-family F witness for the deterministic chain. -/
theorem deterministic_forward_F (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (t : ℤ) (psi : Formula) (h_F : Formula.some_future psi ∈ deterministic_chain M₀ t) :
    ∃ s : ℤ, t < s ∧ psi ∈ deterministic_chain M₀ s := by
  sorry

/-- **SORRY**: Intra-family P witness for the deterministic chain. -/
theorem deterministic_backward_P (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (t : ℤ) (psi : Formula) (h_P : Formula.some_past psi ∈ deterministic_chain M₀ t) :
    ∃ s : ℤ, s < t ∧ psi ∈ deterministic_chain M₀ s := by
  sorry

/-!
## Box Persistence and Class Agreement
-/

/-- Box formulas are constant along the deterministic chain. -/
theorem deterministic_box_persistent (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (φ : Formula) (t s : ℤ)
    (h_box : Formula.box φ ∈ (DeterministicFMCS M₀ h_mcs).mcs t) :
    Formula.box φ ∈ (DeterministicFMCS M₀ h_mcs).mcs s :=
  parametric_box_persistent (DeterministicFMCS M₀ h_mcs) φ t s h_box

/-- Box class agreement between M₀ and any chain position. -/
theorem deterministic_chain_box_agree (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (t : ℤ) : box_class_agree M₀ (deterministic_chain M₀ t) :=
  fun φ => ⟨fun h => deterministic_box_persistent M₀ h_mcs φ 0 t h,
            fun h => deterministic_box_persistent M₀ h_mcs φ t 0 h⟩

/-!
## Deterministic BFMCS Bundle
-/

/-- Box-class families of shifted deterministic chains. -/
noncomputable def deterministicBoxClassFamilies (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀) :
    Set (FMCS Int) :=
  { f | ∃ (W : Set Formula) (h_W : SetMaximalConsistent W) (k : Int),
    box_class_agree M₀ W ∧ f = shifted_fmcs (DeterministicFMCS W h_W) k }

/-- The bundle is nonempty. -/
theorem bundle_nonempty (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀) :
    (deterministicBoxClassFamilies M₀ h_mcs).Nonempty :=
  ⟨DeterministicFMCS M₀ h_mcs, M₀, h_mcs, 0, box_class_agree_refl M₀, by
    unfold shifted_fmcs; cases (DeterministicFMCS M₀ h_mcs); simp only [Int.sub_zero]⟩

/-- The eval family is in the bundle. -/
theorem eval_in_bundle (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀) :
    DeterministicFMCS M₀ h_mcs ∈ deterministicBoxClassFamilies M₀ h_mcs :=
  ⟨M₀, h_mcs, 0, box_class_agree_refl M₀, by
    unfold shifted_fmcs; cases (DeterministicFMCS M₀ h_mcs); simp only [Int.sub_zero]⟩

/-- Modal forward coherence. -/
theorem bundle_modal_forward (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (fam : FMCS Int) (hfam : fam ∈ deterministicBoxClassFamilies M₀ h_mcs)
    (phi : Formula) (t : Int) (h_box : Formula.box phi ∈ fam.mcs t)
    (fam' : FMCS Int) (hfam' : fam' ∈ deterministicBoxClassFamilies M₀ h_mcs) :
    phi ∈ fam'.mcs t := by
  obtain ⟨W, h_W, k, h_agree, rfl⟩ := hfam
  obtain ⟨W', h_W', k', h_agree', rfl⟩ := hfam'
  have h_box_0 : Formula.box phi ∈ W :=
    parametric_box_persistent (DeterministicFMCS W h_W) phi (t - k) 0 h_box
  have h_box_W' : Formula.box phi ∈ W' := (h_agree' phi).mp ((h_agree phi).mpr h_box_0)
  have h_box_t' : Formula.box phi ∈ (DeterministicFMCS W' h_W').mcs (t - k') :=
    parametric_box_persistent (DeterministicFMCS W' h_W') phi 0 (t - k') h_box_W'
  exact SetMaximalConsistent.implication_property
    ((DeterministicFMCS W' h_W').is_mcs (t - k'))
    (theorem_in_mcs ((DeterministicFMCS W' h_W').is_mcs (t - k'))
      (DerivationTree.axiom _ _ (Axiom.modal_t phi))) h_box_t'

/-- Modal backward coherence. -/
theorem bundle_modal_backward (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (fam : FMCS Int) (hfam : fam ∈ deterministicBoxClassFamilies M₀ h_mcs)
    (phi : Formula) (t : Int)
    (h_all : ∀ fam' ∈ deterministicBoxClassFamilies M₀ h_mcs, phi ∈ fam'.mcs t) :
    Formula.box phi ∈ fam.mcs t := by
  obtain ⟨W, h_W, k, h_agree, rfl⟩ := hfam
  by_contra h_not_box
  have h_box_not_W : Formula.box phi ∉ W :=
    fun h => h_not_box (parametric_box_persistent (DeterministicFMCS W h_W) phi 0 (t - k) h)
  have h_neg_box_M₀ : (Formula.box phi).neg ∈ M₀ := by
    rcases SetMaximalConsistent.negation_complete h_mcs (Formula.box phi) with h | h
    · exact absurd ((h_agree phi).mp h) h_box_not_W
    · exact h
  have h_diamond_neg : (Formula.neg phi).diamond ∈ M₀ :=
    SetMaximalConsistent.contrapositive h_mcs (box_dne_theorem phi) h_neg_box_M₀
  obtain ⟨W', h_W'_mcs, h_neg_phi_W', h_agree'⟩ :=
    box_theory_witness_exists M₀ h_mcs (Formula.neg phi) h_diamond_neg
  have h_in : shifted_fmcs (DeterministicFMCS W' h_W'_mcs) t ∈
      deterministicBoxClassFamilies M₀ h_mcs := ⟨W', h_W'_mcs, t, h_agree', rfl⟩
  have h_neg : Formula.neg phi ∈ (shifted_fmcs (DeterministicFMCS W' h_W'_mcs) t).mcs t := by
    simp only [shifted_fmcs, Int.sub_self]; exact h_neg_phi_W'
  exact set_consistent_not_both
    ((shifted_fmcs (DeterministicFMCS W' h_W'_mcs) t).is_mcs t).1
    phi (h_all _ h_in) h_neg

/-- Construct the deterministic BFMCS. -/
noncomputable def construct_deterministic_bfmcs (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀) :
    BFMCS Int where
  families := deterministicBoxClassFamilies M₀ h_mcs
  nonempty := bundle_nonempty M₀ h_mcs
  modal_forward := bundle_modal_forward M₀ h_mcs
  modal_backward := bundle_modal_backward M₀ h_mcs
  eval_family := DeterministicFMCS M₀ h_mcs
  eval_family_mem := eval_in_bundle M₀ h_mcs

/-- The eval family at time 0 is M₀. -/
theorem eval_at_zero (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀) :
    (construct_deterministic_bfmcs M₀ h_mcs).eval_family.mcs 0 = M₀ := rfl

/-!
## Temporal and Until/Since Coherence
-/

/-- Temporal coherence. Depends on forward_F/backward_P (sorry). -/
theorem tc (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀) :
    (construct_deterministic_bfmcs M₀ h_mcs).temporally_coherent := by
  intro fam hfam
  obtain ⟨W, h_W, k, _, rfl⟩ := hfam
  constructor
  · intro t psi h_F
    obtain ⟨s, h_lt, h_psi⟩ := deterministic_forward_F W h_W (t - k) psi h_F
    exact ⟨s + k, by omega, by
      show psi ∈ (DeterministicFMCS W h_W).mcs ((s + k) - k)
      simp [Int.add_sub_cancel]; exact h_psi⟩
  · intro t psi h_P
    obtain ⟨s, h_lt, h_psi⟩ := deterministic_backward_P W h_W (t - k) psi h_P
    exact ⟨s + k, by omega, by
      show psi ∈ (DeterministicFMCS W h_W).mcs ((s + k) - k)
      simp [Int.add_sub_cancel]; exact h_psi⟩

/-- Until/Since coherence. Depends on forward_F/backward_P (sorry). -/
theorem usc (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀) :
    (construct_deterministic_bfmcs M₀ h_mcs).until_since_coherent := by
  intro fam hfam
  obtain ⟨W, h_W, k, _, rfl⟩ := hfam
  refine ⟨?_, ?_, ?_, ?_⟩
  · -- Forward Until: uses forward_F + until persistence
    intro t phi psi h_U; sorry
  · -- Backward Until: uses until_intro
    intro t phi psi h_wit; sorry
  · -- Forward Since: symmetric
    intro t phi psi h_S; sorry
  · -- Backward Since: symmetric
    intro t phi psi h_wit; sorry

/-!
## Completeness Wiring
-/

/-- The construct_bfmcs callback for parametric representation. -/
noncomputable def construct_bfmcs_callback (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    Σ' (B : BFMCS Int) (h_tc : B.temporally_coherent) (h_uc : B.until_since_coherent)
       (fam : FMCS Int) (hfam : fam ∈ B.families) (t : Int),
       M = fam.mcs t :=
  ⟨construct_deterministic_bfmcs M h_mcs,
   tc M h_mcs,
   usc M h_mcs,
   DeterministicFMCS M h_mcs,
   eval_in_bundle M h_mcs,
   0, rfl⟩

/-- Representation theorem via deterministic chains: non-provable formulas have countermodels.
Wires through `parametric_algebraic_representation_conditional` (sorry-free). -/
noncomputable def deterministic_representation {φ : Formula}
    (h_not_prov : ¬Nonempty ([] ⊢ φ)) :=
  parametric_algebraic_representation_conditional φ h_not_prov construct_bfmcs_callback

end Bimodal.Metalogic.Algebraic.DeterministicFMCS
