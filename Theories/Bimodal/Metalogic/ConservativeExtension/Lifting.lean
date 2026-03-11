import Bimodal.Metalogic.ConservativeExtension.Substitution

/-!
# Lifting Infrastructure for Conservative Extension

This module provides the lifting infrastructure for projecting F+ derivations back
to F derivations via the substitution sigma[q -> bot].

## Main Results

- `substDerivation`: Substitution sigma[q -> bot] preserves derivations in Ext
- `unembedFormula`: Project q-free ExtFormula back to Formula
- `unembed_embed`: unembedFormula is left-inverse of embedFormula
- `embed_unembed_qfree`: embedFormula is left-inverse of unembedFormula for q-free formulas
- `substFreshWith`: Parameterized substitution replacing freshAtom with atom (Sum.inl s)
- `substAxiomFresh`: Axiom closure under parameterized substitution

## Key Insight

The IRR case with `p = freshAtom` in substDerivation is handled by the observation
that `substFormula phi = phi` when `freshAtom not-in phi.atoms`, so the original IRR
step can be preserved without modification.

## References

- Task 958 research-006.md: Substitution-based conservative extension
- Goldblatt 1992, Logics of Time and Computation
-/

namespace Bimodal.Metalogic.ConservativeExtension

open Bimodal.Syntax
open Bimodal.ProofSystem

/-!
## Unembedding: Inverse of embedFormula for q-free formulas
-/

/-- Partial inverse of embedFormula. Maps `Sum.inl s` atoms back to `String` atoms.
For q-free formulas (after substitution), this is a true inverse. -/
def unembedFormula : ExtFormula → Formula
  | ExtFormula.atom (Sum.inl s) => Formula.atom s
  | ExtFormula.atom (Sum.inr ()) => Formula.bot  -- unreachable for q-free formulas
  | ExtFormula.bot => Formula.bot
  | ExtFormula.imp φ ψ => Formula.imp (unembedFormula φ) (unembedFormula ψ)
  | ExtFormula.box φ => Formula.box (unembedFormula φ)
  | ExtFormula.all_past φ => Formula.all_past (unembedFormula φ)
  | ExtFormula.all_future φ => Formula.all_future (unembedFormula φ)

/-- unembedFormula is left-inverse of embedFormula. -/
theorem unembed_embed (φ : Formula) : unembedFormula (embedFormula φ) = φ := by
  induction φ with
  | atom s => rfl
  | bot => rfl
  | imp a b iha ihb => simp [embedFormula, unembedFormula, iha, ihb]
  | box a ih => simp [embedFormula, unembedFormula, ih]
  | all_past a ih => simp [embedFormula, unembedFormula, ih]
  | all_future a ih => simp [embedFormula, unembedFormula, ih]

/-- embedFormula is left-inverse of unembedFormula for q-free formulas. -/
theorem embed_unembed_qfree (φ : ExtFormula) (h : freshAtom ∉ φ.atoms) :
    embedFormula (unembedFormula φ) = φ := by
  induction φ with
  | atom a =>
    cases a with
    | inl s => rfl
    | inr u => cases u; simp [ExtFormula.atoms, freshAtom] at h
  | bot => rfl
  | imp a b iha ihb =>
    simp only [ExtFormula.atoms, Finset.mem_union, not_or] at h
    simp [unembedFormula, embedFormula, iha h.1, ihb h.2]
  | box a ih =>
    simp [ExtFormula.atoms] at h; simp [unembedFormula, embedFormula, ih h]
  | all_past a ih =>
    simp [ExtFormula.atoms] at h; simp [unembedFormula, embedFormula, ih h]
  | all_future a ih =>
    simp [ExtFormula.atoms] at h; simp [unembedFormula, embedFormula, ih h]

/-- List unembedding inverts list embedding. -/
theorem unembed_embed_list (L : List Formula) :
    (L.map embedFormula).map unembedFormula = L := by
  induction L with
  | nil => rfl
  | cons hd tl ih => simp [List.map, unembed_embed hd, ih]

/-!
## Helper Lemmas for substDerivation
-/

/-- Sum.inl atoms are preserved by substitution. -/
private theorem inl_not_in_substFormula_atoms {s : String} {phi : ExtFormula}
    (h : Sum.inl s ∉ phi.atoms) : Sum.inl s ∉ (substFormula phi).atoms := by
  induction phi with
  | atom a =>
    cases a with
    | inl t => simp [substFormula, ExtFormula.atoms] at h ⊢; exact h
    | inr u => cases u; simp [substFormula, ExtFormula.atoms]
  | bot => simp [substFormula, ExtFormula.atoms]
  | imp a b iha ihb =>
    simp only [ExtFormula.atoms, Finset.mem_union, not_or] at h
    simp only [substFormula, ExtFormula.atoms, Finset.mem_union, not_or]
    exact ⟨iha h.1, ihb h.2⟩
  | box a ih => simp [ExtFormula.atoms] at h; simp [substFormula, ExtFormula.atoms, ih h]
  | all_past a ih => simp [ExtFormula.atoms] at h; simp [substFormula, ExtFormula.atoms, ih h]
  | all_future a ih => simp [ExtFormula.atoms] at h; simp [substFormula, ExtFormula.atoms, ih h]

/-- Subset preserved under substFormula map. -/
private theorem map_substFormula_subset {Gamma Delta : ExtContext}
    (h : Gamma ⊆ Delta) : Gamma.map substFormula ⊆ Delta.map substFormula := by
  intro x hx
  rw [List.mem_map] at hx ⊢
  obtain ⟨a, ha, rfl⟩ := hx
  exact ⟨a, h ha, rfl⟩

/-!
## substDerivation: Substitution sigma[q -> bot] Preserves Derivations

Apply sigma[q -> bot] to an entire derivation tree. The IRR case with
p = freshAtom is handled by observing that substFormula phi = phi when
freshAtom not-in phi.atoms, so the IRR step is preserved unchanged.
-/

/-- Apply substitution sigma[q -> bot] to a derivation tree. -/
noncomputable def substDerivation : {Gamma : ExtContext} → {phi : ExtFormula} →
    ExtDerivationTree Gamma phi →
    ExtDerivationTree (Gamma.map substFormula) (substFormula phi)
  | _, _, ExtDerivationTree.axiom _Gamma _phi h =>
    ExtDerivationTree.axiom _ _ (substAxiom h)
  | _, _, ExtDerivationTree.assumption _Gamma _phi h =>
    ExtDerivationTree.assumption _ _ (List.mem_map_of_mem (f := substFormula) h)
  | _, _, ExtDerivationTree.modus_ponens _Gamma a b d1 d2 =>
    ExtDerivationTree.modus_ponens _ (substFormula a) (substFormula b)
      (substDerivation d1) (substDerivation d2)
  | _, _, ExtDerivationTree.necessitation _phi d =>
    ExtDerivationTree.necessitation _ (substDerivation d)
  | _, _, ExtDerivationTree.temporal_necessitation _phi d =>
    ExtDerivationTree.temporal_necessitation _ (substDerivation d)
  | _, _, ExtDerivationTree.temporal_duality phi d =>
    substFormula_swap_temporal phi ▸
      ExtDerivationTree.temporal_duality _ (substDerivation d)
  | _, _, ExtDerivationTree.irr (Sum.inl s) phi h_fresh d =>
    ExtDerivationTree.irr (Sum.inl s) (substFormula phi)
      (inl_not_in_substFormula_atoms h_fresh) (substDerivation d)
  | _, _, ExtDerivationTree.irr (Sum.inr ()) phi h_fresh d =>
    -- p = freshAtom: substFormula phi = phi, so reconstruct IRR unchanged
    (substFormula_preserves_qfree phi h_fresh).symm ▸
      ExtDerivationTree.irr (Sum.inr ()) phi h_fresh d
  | _, _, ExtDerivationTree.weakening _Gamma _Delta _phi d h =>
    ExtDerivationTree.weakening _ _ _ (substDerivation d) (map_substFormula_subset h)

/-!
## Parameterized Substitution: Replace freshAtom with atom (Sum.inl s)
-/

/-- Replace freshAtom with atom (Sum.inl s) in an ExtFormula. -/
def substFreshWith (s : String) : ExtFormula → ExtFormula
  | ExtFormula.atom (Sum.inl t) => ExtFormula.atom (Sum.inl t)
  | ExtFormula.atom (Sum.inr ()) => ExtFormula.atom (Sum.inl s)
  | ExtFormula.bot => ExtFormula.bot
  | ExtFormula.imp φ ψ => ExtFormula.imp (substFreshWith s φ) (substFreshWith s ψ)
  | ExtFormula.box φ => ExtFormula.box (substFreshWith s φ)
  | ExtFormula.all_past φ => ExtFormula.all_past (substFreshWith s φ)
  | ExtFormula.all_future φ => ExtFormula.all_future (substFreshWith s φ)

theorem substFreshWith_swap_temporal (s : String) (φ : ExtFormula) :
    substFreshWith s φ.swap_temporal = (substFreshWith s φ).swap_temporal := by
  induction φ with
  | atom a =>
    cases a with
    | inl t => simp [ExtFormula.swap_temporal, substFreshWith]
    | inr u => cases u; simp [ExtFormula.swap_temporal, substFreshWith]
  | bot => rfl
  | imp _ _ ih1 ih2 => simp [ExtFormula.swap_temporal, substFreshWith, ih1, ih2]
  | box _ ih => simp [ExtFormula.swap_temporal, substFreshWith, ih]
  | all_past _ ih => simp [ExtFormula.swap_temporal, substFreshWith, ih]
  | all_future _ ih => simp [ExtFormula.swap_temporal, substFreshWith, ih]

theorem substFreshWith_preserves_qfree (s : String) (φ : ExtFormula) (h : freshAtom ∉ φ.atoms) :
    substFreshWith s φ = φ := by
  induction φ with
  | atom a =>
    cases a with
    | inl t => rfl
    | inr u => cases u; simp [ExtFormula.atoms, freshAtom] at h
  | bot => rfl
  | imp a b iha ihb =>
    simp only [ExtFormula.atoms, Finset.mem_union, not_or] at h
    simp [substFreshWith, iha h.1, ihb h.2]
  | box a ih => simp [ExtFormula.atoms] at h; simp [substFreshWith, ih h]
  | all_past a ih => simp [ExtFormula.atoms] at h; simp [substFreshWith, ih h]
  | all_future a ih => simp [ExtFormula.atoms] at h; simp [substFreshWith, ih h]

theorem substFreshWith_of_embedded (s : String) (φ : Formula) :
    substFreshWith s (embedFormula φ) = embedFormula φ :=
  substFreshWith_preserves_qfree s _ (fresh_not_in_embedFormula_atoms φ)

/-- Axioms are closed under replacing freshAtom with atom (Sum.inl s). -/
def substAxiomFresh (s : String) {φ : ExtFormula} (h : ExtAxiom φ) :
    ExtAxiom (substFreshWith s φ) := by
  cases h with
  | prop_k a b c => exact ExtAxiom.prop_k _ _ _
  | prop_s a b => exact ExtAxiom.prop_s _ _
  | modal_t a => exact ExtAxiom.modal_t _
  | modal_4 a => exact ExtAxiom.modal_4 _
  | modal_b a => exact ExtAxiom.modal_b _
  | modal_5_collapse a => exact ExtAxiom.modal_5_collapse _
  | ex_falso a => exact ExtAxiom.ex_falso _
  | peirce a b => exact ExtAxiom.peirce _ _
  | modal_k_dist a b => exact ExtAxiom.modal_k_dist _ _
  | temp_k_dist a b => exact ExtAxiom.temp_k_dist _ _
  | temp_4 a => exact ExtAxiom.temp_4 _
  | temp_a a => exact ExtAxiom.temp_a _
  | temp_l a => exact ExtAxiom.temp_l _
  | modal_future a => exact ExtAxiom.modal_future _
  | temp_future a => exact ExtAxiom.temp_future _
  | temp_linearity a b => exact ExtAxiom.temp_linearity _ _
  | density a => exact ExtAxiom.density _
  | discreteness_forward a => exact ExtAxiom.discreteness_forward _
  | seriality_future => exact ExtAxiom.seriality_future
  | seriality_past => exact ExtAxiom.seriality_past

end Bimodal.Metalogic.ConservativeExtension
