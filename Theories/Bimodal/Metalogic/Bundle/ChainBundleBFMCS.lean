import Bimodal.Metalogic.Bundle.BFMCS
import Bimodal.Metalogic.Bundle.CanonicalFMCS
import Bimodal.Metalogic.Bundle.ChainFMCS
import Bimodal.Metalogic.Bundle.ModalSaturation
import Bimodal.Metalogic.Bundle.Construction
import Bimodal.Metalogic.Bundle.TemporalCoherentConstruction
import Bimodal.Metalogic.Bundle.TruthLemma
import Bimodal.Theorems.Propositional

/-!
# Chain-Bundle BFMCS Construction

This module constructs a chain-bundle BFMCS over CanonicalBC (MCSes with fixed
BoxContent). It provides the infrastructure for modal saturation and the
chain-bundle BFMCS structure used by the completeness proof in `Completeness.lean`.

## Construction

Domain: `CanonicalBC BC` -- MCSes whose BoxContent equals a fixed set `BC`.

Families:
  - Eval family (`canonicalBCBFMCS`): identity mapping on CanonicalBC (temporally coherent)
  - Witness families (`constantBCFamily`): constant families at MCSes with same BoxContent

## Key Results

- `MCSBoxContent_eq_of_CanonicalR`: BoxContent preserved along CanonicalR
- `MCSBoxContent_eq_of_superset`: BoxContent equality for superset MCSes
- `chainBundleBFMCS`: The chain-bundle BFMCS construction
- `chainBundleBFMCS_modally_saturated`: Modal saturation of the chain-bundle
- `chainBundle_modal_forward` / `chainBundle_modal_backward`: Modal coherence

## Axiom Dependencies

All theorems in this module depend ONLY on standard Lean axioms:
  propext, Classical.choice, Quot.sound, Lean.ofReduceBool, Lean.trustCompiler

NO sorry, NO custom axioms.
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

/-!
## BoxContent Equality Along CanonicalR
-/

/--
BoxContent is preserved in the reverse direction along CanonicalR.
-/
theorem MCSBoxContent_reverse_of_CanonicalR (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M') :
    MCSBoxContent M' ⊆ MCSBoxContent M := by
  intro phi h_box'
  simp only [MCSBoxContent, Set.mem_setOf_eq] at h_box' ⊢
  by_contra h_not_box
  have h_neg_box : (Formula.box phi).neg ∈ M := by
    rcases set_mcs_negation_complete h_mcs (Formula.box phi) with h | h
    · exact absurd h h_not_box
    · exact h
  have h_box_neg_box := mcs_neg_box_implies_box_neg_box h_mcs phi h_neg_box
  have h_neg_box_in_bc : (Formula.box phi).neg ∈ MCSBoxContent M := by
    simp only [MCSBoxContent, Set.mem_setOf_eq]; exact h_box_neg_box
  have h_neg_box' := MCSBoxContent_subset_of_CanonicalR M M' h_mcs h_mcs' h_R h_neg_box_in_bc
  simp only [MCSBoxContent, Set.mem_setOf_eq] at h_neg_box'
  have h_neg_box_M' : (Formula.box phi).neg ∈ M' := by
    have h_T : [] ⊢ (Formula.box (Formula.box phi).neg).imp (Formula.box phi).neg :=
      DerivationTree.axiom [] _ (Axiom.modal_t (Formula.box phi).neg)
    exact set_mcs_implication_property h_mcs' (theorem_in_mcs h_mcs' h_T) h_neg_box'
  exact set_consistent_not_both h_mcs'.1 (Formula.box phi) h_box' h_neg_box_M'

/--
BoxContent is exactly preserved along CanonicalR.
-/
theorem MCSBoxContent_eq_of_CanonicalR (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M') :
    MCSBoxContent M = MCSBoxContent M' := by
  ext phi
  constructor
  · exact fun h => MCSBoxContent_subset_of_CanonicalR M M' h_mcs h_mcs' h_R h
  · exact fun h => MCSBoxContent_reverse_of_CanonicalR M M' h_mcs h_mcs' h_R h

/--
BoxContent equality for MCSes whose union superset includes BoxContent.
-/
theorem MCSBoxContent_eq_of_superset (M N : Set Formula)
    (h_mcs_M : SetMaximalConsistent M) (h_mcs_N : SetMaximalConsistent N)
    (h_sub : MCSBoxContent M ⊆ N) :
    MCSBoxContent N = MCSBoxContent M := by
  ext phi
  constructor
  · intro h_box_N
    simp only [MCSBoxContent, Set.mem_setOf_eq] at h_box_N ⊢
    by_contra h_not_box_M
    have h_neg_box_M : (Formula.box phi).neg ∈ M := by
      rcases set_mcs_negation_complete h_mcs_M (Formula.box phi) with h | h
      · exact absurd h h_not_box_M
      · exact h
    have h_neg_box_bc : (Formula.box phi).neg ∈ MCSBoxContent M := by
      simp only [MCSBoxContent, Set.mem_setOf_eq]
      exact mcs_neg_box_implies_box_neg_box h_mcs_M phi h_neg_box_M
    have h_neg_box_N := h_sub h_neg_box_bc
    exact set_consistent_not_both h_mcs_N.1 (Formula.box phi) h_box_N h_neg_box_N
  · intro h_box_M
    simp only [MCSBoxContent, Set.mem_setOf_eq] at h_box_M ⊢
    have h_box_box : Formula.box (Formula.box phi) ∈ M := by
      have h_4 : [] ⊢ (Formula.box phi).imp (Formula.box (Formula.box phi)) :=
        DerivationTree.axiom [] _ (Axiom.modal_4 phi)
      exact set_mcs_implication_property h_mcs_M (theorem_in_mcs h_mcs_M h_4) h_box_M
    have h_box_in_bc : Formula.box phi ∈ MCSBoxContent M := by
      simp only [MCSBoxContent, Set.mem_setOf_eq]; exact h_box_box
    exact h_sub h_box_in_bc

/-!
## CanonicalBC: Domain of MCSes with Fixed BoxContent
-/

/--
An MCS with a specific BoxContent.
-/
structure CanonicalBC (BC : Set Formula) where
  /-- The underlying MCS -/
  world : Set Formula
  /-- The MCS is maximal consistent -/
  is_mcs : SetMaximalConsistent world
  /-- BoxContent equals the fixed BC -/
  bc_eq : MCSBoxContent world = BC

/--
Preorder on CanonicalBC via CanonicalR.
-/
noncomputable instance (BC : Set Formula) : Preorder (CanonicalBC BC) where
  le a b := CanonicalR a.world b.world
  le_refl a := canonicalR_reflexive a.world a.is_mcs
  le_trans a b c hab hbc := canonicalR_transitive a.world b.world c.world a.is_mcs hab hbc

/-!
## Eval Family on CanonicalBC
-/

/--
The eval family: maps each CanonicalBC element to its own MCS.
-/
noncomputable def canonicalBCBFMCS (BC : Set Formula) : FMCS (CanonicalBC BC) where
  mcs := fun w => w.world
  is_mcs := fun w => w.is_mcs
  forward_G := fun w₁ w₂ phi h_le h_G =>
    canonical_forward_G w₁.world w₂.world h_le phi h_G
  backward_H := fun w₁ w₂ phi h_le h_H => by
    have h_R_past : CanonicalR_past w₁.world w₂.world :=
      GContent_subset_implies_HContent_reverse w₂.world w₁.world
        w₂.is_mcs w₁.is_mcs h_le
    exact canonical_backward_H w₁.world w₂.world h_R_past phi h_H

/--
Forward F for canonicalBCBFMCS: witnesses stay in CanonicalBC.
-/
theorem canonicalBC_forward_F (BC : Set Formula)
    (w : CanonicalBC BC) (phi : Formula)
    (h_F : Formula.some_future phi ∈ (canonicalBCBFMCS BC).mcs w) :
    ∃ s : CanonicalBC BC, w ≤ s ∧ phi ∈ (canonicalBCBFMCS BC).mcs s := by
  obtain ⟨W, h_W_mcs, h_R, h_phi_W⟩ := canonical_forward_F w.world w.is_mcs phi h_F
  have h_bc_W : MCSBoxContent W = BC := by
    rw [← w.bc_eq]
    exact (MCSBoxContent_eq_of_CanonicalR w.world W w.is_mcs h_W_mcs h_R).symm
  exact ⟨⟨W, h_W_mcs, h_bc_W⟩, h_R, h_phi_W⟩

/--
Backward P for canonicalBCBFMCS: witnesses stay in CanonicalBC.
-/
theorem canonicalBC_backward_P (BC : Set Formula)
    (w : CanonicalBC BC) (phi : Formula)
    (h_P : Formula.some_past phi ∈ (canonicalBCBFMCS BC).mcs w) :
    ∃ s : CanonicalBC BC, s ≤ w ∧ phi ∈ (canonicalBCBFMCS BC).mcs s := by
  obtain ⟨W, h_W_mcs, h_R_past, h_phi_W⟩ := canonical_backward_P w.world w.is_mcs phi h_P
  have h_R : CanonicalR W w.world :=
    HContent_subset_implies_GContent_reverse w.world W w.is_mcs h_W_mcs h_R_past
  have h_bc_W : MCSBoxContent W = BC := by
    have h_bc_eq := MCSBoxContent_eq_of_CanonicalR W w.world h_W_mcs w.is_mcs h_R
    rw [h_bc_eq]; exact w.bc_eq
  exact ⟨⟨W, h_W_mcs, h_bc_W⟩, h_R, h_phi_W⟩

/-!
## Constant Witness Families on CanonicalBC
-/

/--
A constant witness family on CanonicalBC.
-/
noncomputable def constantBCFamily (BC : Set Formula) (N : Set Formula)
    (h_mcs : SetMaximalConsistent N) (_ : MCSBoxContent N = BC) :
    FMCS (CanonicalBC BC) where
  mcs := fun _ => N
  is_mcs := fun _ => h_mcs
  forward_G := fun _ _ phi _ h_G => by
    have h_T : [] ⊢ (Formula.all_future phi).imp phi :=
      DerivationTree.axiom [] _ (Axiom.temp_t_future phi)
    exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_G
  backward_H := fun _ _ phi _ h_H => by
    have h_T : [] ⊢ (Formula.all_past phi).imp phi :=
      DerivationTree.axiom [] _ (Axiom.temp_t_past phi)
    exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_H

/-!
## Chain-Bundle BFMCS Construction
-/

/--
The chain-bundle families: eval family plus constant families for modal saturation.
-/
noncomputable def chainBundleFamilies (BC : Set Formula) : Set (FMCS (CanonicalBC BC)) :=
  {canonicalBCBFMCS BC} ∪
  { fam | ∃ (N : Set Formula) (h_mcs : SetMaximalConsistent N)
      (h_bc : MCSBoxContent N = BC), fam = constantBCFamily BC N h_mcs h_bc }

lemma evalFamily_mem (BC : Set Formula) :
    canonicalBCBFMCS BC ∈ chainBundleFamilies BC :=
  Set.mem_union_left _ (Set.mem_singleton _)

lemma constantFamily_mem (BC : Set Formula) (N : Set Formula)
    (h_mcs : SetMaximalConsistent N) (h_bc : MCSBoxContent N = BC) :
    constantBCFamily BC N h_mcs h_bc ∈ chainBundleFamilies BC :=
  Set.mem_union_right _ ⟨N, h_mcs, h_bc, rfl⟩

/--
Every family in the bundle has BoxContent = BC at every time point.
-/
theorem chainBundle_boxcontent_eq (BC : Set Formula)
    (fam : FMCS (CanonicalBC BC)) (hfam : fam ∈ chainBundleFamilies BC)
    (t : CanonicalBC BC) :
    MCSBoxContent (fam.mcs t) = BC := by
  rcases hfam with h_eval | h_const
  · rw [Set.mem_singleton_iff.mp h_eval]; exact t.bc_eq
  · obtain ⟨N, _, h_bc_N, h_eq⟩ := h_const; rw [h_eq]; exact h_bc_N

/--
Modal forward for chain-bundle.
-/
theorem chainBundle_modal_forward (BC : Set Formula)
    (fam : FMCS (CanonicalBC BC)) (hfam : fam ∈ chainBundleFamilies BC)
    (φ : Formula) (t : CanonicalBC BC) (h_box : Formula.box φ ∈ fam.mcs t)
    (fam' : FMCS (CanonicalBC BC)) (hfam' : fam' ∈ chainBundleFamilies BC) :
    φ ∈ fam'.mcs t := by
  -- Box phi ∈ fam.mcs t → Box(Box phi) ∈ fam.mcs t (axiom 4)
  -- → Box phi ∈ BoxContent(fam.mcs t) = BC = BoxContent(fam'.mcs t)
  -- → Box(Box phi) ∈ fam'.mcs t → Box phi ∈ fam'.mcs t → phi ∈ fam'.mcs t
  have h_4 : [] ⊢ (Formula.box φ).imp (Formula.box (Formula.box φ)) :=
    DerivationTree.axiom [] _ (Axiom.modal_4 φ)
  have h_box_box := set_mcs_implication_property (fam.is_mcs t)
    (theorem_in_mcs (fam.is_mcs t) h_4) h_box
  -- Box phi ∈ BoxContent(fam.mcs t)
  have h_in_bc : Formula.box φ ∈ MCSBoxContent (fam.mcs t) := by
    simp only [MCSBoxContent, Set.mem_setOf_eq]; exact h_box_box
  -- BoxContent(fam.mcs t) = BC = BoxContent(fam'.mcs t)
  rw [chainBundle_boxcontent_eq BC fam hfam t] at h_in_bc
  rw [← chainBundle_boxcontent_eq BC fam' hfam' t] at h_in_bc
  -- Box phi ∈ BoxContent(fam'.mcs t) means Box(Box phi) ∈ fam'.mcs t
  simp only [MCSBoxContent, Set.mem_setOf_eq] at h_in_bc
  -- By T-axiom twice: Box phi → phi
  have h_T1 : [] ⊢ (Formula.box (Formula.box φ)).imp (Formula.box φ) :=
    DerivationTree.axiom [] _ (Axiom.modal_t (Formula.box φ))
  have h_box' := set_mcs_implication_property (fam'.is_mcs t)
    (theorem_in_mcs (fam'.is_mcs t) h_T1) h_in_bc
  have h_T2 : [] ⊢ (Formula.box φ).imp φ :=
    DerivationTree.axiom [] _ (Axiom.modal_t φ)
  exact set_mcs_implication_property (fam'.is_mcs t)
    (theorem_in_mcs (fam'.is_mcs t) h_T2) h_box'

/--
Modal saturation for chain-bundle.
-/
theorem chainBundle_modally_saturated (BC : Set Formula)
    (fam : FMCS (CanonicalBC BC)) (hfam : fam ∈ chainBundleFamilies BC)
    (t : CanonicalBC BC) (psi : Formula)
    (h_diamond : diamondFormula psi ∈ fam.mcs t) :
    ∃ fam' ∈ chainBundleFamilies BC, psi ∈ fam'.mcs t := by
  have h_consistent := modal_witness_seed_consistent (fam.mcs t) (fam.is_mcs t) psi h_diamond
  let N := lindenbaumMCS_set (ModalWitnessSeed (fam.mcs t) psi) h_consistent
  have h_mcs_N := lindenbaumMCS_set_is_mcs _ h_consistent
  have h_extends := lindenbaumMCS_set_extends _ h_consistent
  have h_psi_N : psi ∈ N := h_extends (psi_mem_ModalWitnessSeed (fam.mcs t) psi)
  have h_bc_sub : MCSBoxContent (fam.mcs t) ⊆ N :=
    Set.Subset.trans (MCSBoxContent_subset_ModalWitnessSeed (fam.mcs t) psi) h_extends
  have h_bc_N : MCSBoxContent N = BC := by
    rw [MCSBoxContent_eq_of_superset (fam.mcs t) N (fam.is_mcs t) h_mcs_N h_bc_sub]
    exact chainBundle_boxcontent_eq BC fam hfam t
  exact ⟨constantBCFamily BC N h_mcs_N h_bc_N,
         constantFamily_mem BC N h_mcs_N h_bc_N,
         h_psi_N⟩

/--
Modal backward for chain-bundle (from saturation).
-/
theorem chainBundle_modal_backward (BC : Set Formula)
    (fam : FMCS (CanonicalBC BC)) (hfam : fam ∈ chainBundleFamilies BC)
    (φ : Formula) (t : CanonicalBC BC)
    (h_all : ∀ fam' ∈ chainBundleFamilies BC, φ ∈ fam'.mcs t) :
    Formula.box φ ∈ fam.mcs t := by
  by_contra h_not_box
  have h_mcs := fam.is_mcs t
  have h_neg_box : Formula.neg (Formula.box φ) ∈ fam.mcs t := by
    rcases set_mcs_negation_complete h_mcs (Formula.box φ) with h | h
    · exact absurd h h_not_box
    · exact h
  have h_diamond_neg : diamondFormula (Formula.neg φ) ∈ fam.mcs t := by
    have h_box_dne := box_dne_theorem φ
    have h := mcs_contrapositive h_mcs h_box_dne h_neg_box
    show Formula.neg (Formula.box (Formula.neg (Formula.neg φ))) ∈ fam.mcs t
    exact h
  obtain ⟨fam', hfam', h_neg_phi⟩ :=
    chainBundle_modally_saturated BC fam hfam t (Formula.neg φ) h_diamond_neg
  exact set_consistent_not_both (fam'.is_mcs t).1 φ (h_all fam' hfam') h_neg_phi

/-!
## The Chain-Bundle BFMCS
-/

/--
The chain-bundle BFMCS.
-/
noncomputable def chainBundleBFMCS (BC : Set Formula) : BFMCS (CanonicalBC BC) where
  families := chainBundleFamilies BC
  nonempty := ⟨canonicalBCBFMCS BC, evalFamily_mem BC⟩
  modal_forward := chainBundle_modal_forward BC
  modal_backward := chainBundle_modal_backward BC
  eval_family := canonicalBCBFMCS BC
  eval_family_mem := evalFamily_mem BC

theorem chainBundleBFMCS_modally_saturated (BC : Set Formula) :
    is_modally_saturated (chainBundleBFMCS BC) :=
  chainBundle_modally_saturated BC

end Bimodal.Metalogic.Bundle
