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
- `substFreshWith`: Parameterized substitution replacing freshAtom with atom (Sum.inl a)
- `substAxiomFresh`: Axiom closure under parameterized substitution

## Key Insight

The IRR case with `p = freshAtom` in substDerivation is handled by the observation
that `substFormula phi = phi` when `freshAtom not-in phi.atoms`, so the original IRR
step can be preserved without modification.

## References

- Goldblatt 1992, Logics of Time and Computation
-/

namespace Bimodal.Metalogic.ConservativeExtension

open Bimodal.Syntax
open Bimodal.ProofSystem

/-!
## Unembedding: Inverse of embedFormula for q-free formulas
-/

/-- Partial inverse of embedFormula. Maps `Sum.inl a` atoms back to `Atom` atoms.
For q-free formulas (after substitution), this is a true inverse. -/
def unembedFormula : ExtFormula → Formula
  | ExtFormula.atom (Sum.inl a) => Formula.atom a
  | ExtFormula.atom (Sum.inr ()) => Formula.bot  -- unreachable for q-free formulas
  | ExtFormula.bot => Formula.bot
  | ExtFormula.imp φ ψ => Formula.imp (unembedFormula φ) (unembedFormula ψ)
  | ExtFormula.box φ => Formula.box (unembedFormula φ)
  | ExtFormula.untl φ ψ => Formula.untl (unembedFormula φ) (unembedFormula ψ)
  | ExtFormula.snce φ ψ => Formula.snce (unembedFormula φ) (unembedFormula ψ)

/-- unembedFormula is left-inverse of embedFormula. -/
theorem unembed_embed (φ : Formula) : unembedFormula (embedFormula φ) = φ := by
  induction φ with
  | atom s => rfl
  | bot => rfl
  | imp a b iha ihb => simp [embedFormula, unembedFormula, iha, ihb]
  | box a ih => simp [embedFormula, unembedFormula, ih]
  | untl a b iha ihb => simp [embedFormula, unembedFormula, iha, ihb]
  | snce a b iha ihb => simp [embedFormula, unembedFormula, iha, ihb]

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
  | untl a b iha ihb =>
    simp only [ExtFormula.atoms, Finset.mem_union, not_or] at h
    simp [unembedFormula, embedFormula, iha h.1, ihb h.2]
  | snce a b iha ihb =>
    simp only [ExtFormula.atoms, Finset.mem_union, not_or] at h
    simp [unembedFormula, embedFormula, iha h.1, ihb h.2]

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
private theorem inl_not_in_substFormula_atoms {a : Atom} {phi : ExtFormula}
    (h : Sum.inl a ∉ phi.atoms) : Sum.inl a ∉ (substFormula phi).atoms := by
  induction phi with
  | atom x =>
    cases x with
    | inl t => simp [substFormula, ExtFormula.atoms] at h ⊢; exact h
    | inr u => cases u; simp [substFormula, ExtFormula.atoms]
  | bot => simp [substFormula, ExtFormula.atoms]
  | imp a' b iha ihb =>
    simp only [ExtFormula.atoms, Finset.mem_union, not_or] at h
    simp only [substFormula, ExtFormula.atoms, Finset.mem_union, not_or]
    exact ⟨iha h.1, ihb h.2⟩
  | box a' ih => simp [ExtFormula.atoms] at h; simp [substFormula, ExtFormula.atoms, ih h]
  | untl a' b iha ihb =>
    simp only [ExtFormula.atoms, Finset.mem_union, not_or] at h
    simp only [substFormula, ExtFormula.atoms, Finset.mem_union, not_or]
    exact ⟨iha h.1, ihb h.2⟩
  | snce a' b iha ihb =>
    simp only [ExtFormula.atoms, Finset.mem_union, not_or] at h
    simp only [substFormula, ExtFormula.atoms, Finset.mem_union, not_or]
    exact ⟨iha h.1, ihb h.2⟩

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
  | _, _, ExtDerivationTree.weakening _Gamma _Delta _phi d h =>
    ExtDerivationTree.weakening _ _ _ (substDerivation d) (map_substFormula_subset h)

/-!
## Parameterized Substitution: Replace freshAtom with atom (Sum.inl a)
-/

/-- Replace freshAtom with atom (Sum.inl a) in an ExtFormula. -/
def substFreshWith (a : Atom) : ExtFormula → ExtFormula
  | ExtFormula.atom (Sum.inl t) => ExtFormula.atom (Sum.inl t)
  | ExtFormula.atom (Sum.inr ()) => ExtFormula.atom (Sum.inl a)
  | ExtFormula.bot => ExtFormula.bot
  | ExtFormula.imp φ ψ => ExtFormula.imp (substFreshWith a φ) (substFreshWith a ψ)
  | ExtFormula.box φ => ExtFormula.box (substFreshWith a φ)
  | ExtFormula.untl φ ψ => ExtFormula.untl (substFreshWith a φ) (substFreshWith a ψ)
  | ExtFormula.snce φ ψ => ExtFormula.snce (substFreshWith a φ) (substFreshWith a ψ)

theorem substFreshWith_swap_temporal (a : Atom) (φ : ExtFormula) :
    substFreshWith a φ.swap_temporal = (substFreshWith a φ).swap_temporal := by
  induction φ with
  | atom x =>
    cases x with
    | inl t => simp [ExtFormula.swap_temporal, substFreshWith]
    | inr u => cases u; simp [ExtFormula.swap_temporal, substFreshWith]
  | bot => rfl
  | imp _ _ ih1 ih2 => simp [ExtFormula.swap_temporal, substFreshWith, ih1, ih2]
  | box _ ih => simp [ExtFormula.swap_temporal, substFreshWith, ih]
  | untl _ _ ih1 ih2 => simp [ExtFormula.swap_temporal, substFreshWith, ih1, ih2]
  | snce _ _ ih1 ih2 => simp [ExtFormula.swap_temporal, substFreshWith, ih1, ih2]

theorem substFreshWith_preserves_qfree (a : Atom) (φ : ExtFormula) (h : freshAtom ∉ φ.atoms) :
    substFreshWith a φ = φ := by
  induction φ with
  | atom x =>
    cases x with
    | inl t => rfl
    | inr u => cases u; simp [ExtFormula.atoms, freshAtom] at h
  | bot => rfl
  | imp a' b iha ihb =>
    simp only [ExtFormula.atoms, Finset.mem_union, not_or] at h
    simp [substFreshWith, iha h.1, ihb h.2]
  | box a' ih => simp [ExtFormula.atoms] at h; simp [substFreshWith, ih h]
  | untl a' b iha ihb =>
    simp only [ExtFormula.atoms, Finset.mem_union, not_or] at h
    simp [substFreshWith, iha h.1, ihb h.2]
  | snce a' b iha ihb =>
    simp only [ExtFormula.atoms, Finset.mem_union, not_or] at h
    simp [substFreshWith, iha h.1, ihb h.2]

theorem substFreshWith_of_embedded (a : Atom) (φ : Formula) :
    substFreshWith a (embedFormula φ) = embedFormula φ :=
  substFreshWith_preserves_qfree a _ (fresh_not_in_embedFormula_atoms φ)

/-- Axioms are closed under replacing freshAtom with atom (Sum.inl a). -/
def substAxiomFresh (a : Atom) {φ : ExtFormula} (h : ExtAxiom φ) :
    ExtAxiom (substFreshWith a φ) := by
  cases h with
  | prop_k x y z => exact ExtAxiom.prop_k _ _ _
  | prop_s x y => exact ExtAxiom.prop_s _ _
  | ex_falso x => exact ExtAxiom.ex_falso _
  | peirce x y => exact ExtAxiom.peirce _ _
  | modal_t x => exact ExtAxiom.modal_t _
  | modal_4 x => exact ExtAxiom.modal_4 _
  | modal_b x => exact ExtAxiom.modal_b _
  | modal_5_collapse x => exact ExtAxiom.modal_5_collapse _
  | modal_k_dist x y => exact ExtAxiom.modal_k_dist _ _
  | serial_future => exact ExtAxiom.serial_future
  | serial_past => exact ExtAxiom.serial_past
  | left_mono_until_G x y z => exact ExtAxiom.left_mono_until_G _ _ _
  | left_mono_since_H x y z => exact ExtAxiom.left_mono_since_H _ _ _
  | right_mono_until x y z => exact ExtAxiom.right_mono_until _ _ _
  | right_mono_since x y z => exact ExtAxiom.right_mono_since _ _ _
  | connect_future x => exact ExtAxiom.connect_future _
  | connect_past x => exact ExtAxiom.connect_past _
  | enrichment_until x y z => exact ExtAxiom.enrichment_until _ _ _
  | enrichment_since x y z => exact ExtAxiom.enrichment_since _ _ _
  | self_accum_until x y => exact ExtAxiom.self_accum_until _ _
  | self_accum_since x y => exact ExtAxiom.self_accum_since _ _
  | absorb_until x y => exact ExtAxiom.absorb_until _ _
  | absorb_since x y => exact ExtAxiom.absorb_since _ _
  | linear_until x y z w => exact ExtAxiom.linear_until _ _ _ _
  | linear_since x y z w => exact ExtAxiom.linear_since _ _ _ _
  | until_F x y => exact ExtAxiom.until_F _ _
  | since_P x y => exact ExtAxiom.since_P _ _
  | temp_linearity x y => exact ExtAxiom.temp_linearity _ _
  | temp_linearity_past x y => exact ExtAxiom.temp_linearity_past _ _
  | F_until_equiv x => exact ExtAxiom.F_until_equiv _
  | P_since_equiv x => exact ExtAxiom.P_since_equiv _
  | modal_future x => exact ExtAxiom.modal_future _
  | discrete_symm_fwd => exact ExtAxiom.discrete_symm_fwd
  | discrete_symm_bwd => exact ExtAxiom.discrete_symm_bwd
  | discrete_propagate_fwd => exact ExtAxiom.discrete_propagate_fwd
  | discrete_propagate_bwd => exact ExtAxiom.discrete_propagate_bwd
  | discrete_box_necessity => exact ExtAxiom.discrete_box_necessity
  | prior_UZ x => exact ExtAxiom.prior_UZ _
  | prior_SZ x => exact ExtAxiom.prior_SZ _
  | z1 x => exact ExtAxiom.z1 _

/-!
## Unembedding Axioms: ExtAxiom to Axiom
-/

/-- Convert an ExtAxiom to a base Axiom under unembedFormula. -/
def unembedAxiom {φ : ExtFormula} (h : ExtAxiom φ) : Axiom (unembedFormula φ) := by
  cases h with
  | prop_k a b c => exact Axiom.prop_k _ _ _
  | prop_s a b => exact Axiom.prop_s _ _
  | ex_falso a => exact Axiom.ex_falso _
  | peirce a b => exact Axiom.peirce _ _
  | modal_t a => exact Axiom.modal_t _
  | modal_4 a => exact Axiom.modal_4 _
  | modal_b a => exact Axiom.modal_b _
  | modal_5_collapse a => exact Axiom.modal_5_collapse _
  | modal_k_dist a b => exact Axiom.modal_k_dist _ _
  | serial_future => exact Axiom.serial_future
  | serial_past => exact Axiom.serial_past
  | left_mono_until_G a b c => exact Axiom.left_mono_until_G _ _ _
  | left_mono_since_H a b c => exact Axiom.left_mono_since_H _ _ _
  | right_mono_until a b c => exact Axiom.right_mono_until _ _ _
  | right_mono_since a b c => exact Axiom.right_mono_since _ _ _
  | connect_future a => exact Axiom.connect_future _
  | connect_past a => exact Axiom.connect_past _
  | enrichment_until a b c => exact Axiom.enrichment_until _ _ _
  | enrichment_since a b c => exact Axiom.enrichment_since _ _ _
  | self_accum_until a b => exact Axiom.self_accum_until _ _
  | self_accum_since a b => exact Axiom.self_accum_since _ _
  | absorb_until a b => exact Axiom.absorb_until _ _
  | absorb_since a b => exact Axiom.absorb_since _ _
  | linear_until a b c d => exact Axiom.linear_until _ _ _ _
  | linear_since a b c d => exact Axiom.linear_since _ _ _ _
  | until_F a b => exact Axiom.until_F _ _
  | since_P a b => exact Axiom.since_P _ _
  | temp_linearity a b => exact Axiom.temp_linearity _ _
  | temp_linearity_past a b => exact Axiom.temp_linearity_past _ _
  | F_until_equiv a => exact Axiom.F_until_equiv _
  | P_since_equiv a => exact Axiom.P_since_equiv _
  | modal_future a => exact Axiom.modal_future _
  | discrete_symm_fwd => exact Axiom.discrete_symm_fwd
  | discrete_symm_bwd => exact Axiom.discrete_symm_bwd
  | discrete_propagate_fwd => exact Axiom.discrete_propagate_fwd
  | discrete_propagate_bwd => exact Axiom.discrete_propagate_bwd
  | discrete_box_necessity => exact Axiom.discrete_box_necessity
  | prior_UZ a => exact Axiom.prior_UZ _
  | prior_SZ a => exact Axiom.prior_SZ _
  | z1 a => exact Axiom.z1 _

/-- unembedFormula commutes with swap_temporal. -/
theorem unembed_swap_temporal (φ : ExtFormula) :
    unembedFormula φ.swap_temporal = (unembedFormula φ).swap_temporal := by
  induction φ with
  | atom a => cases a with | inl s => rfl | inr u => cases u; rfl
  | bot => rfl
  | imp _ _ ih1 ih2 => simp [ExtFormula.swap_temporal, Formula.swap_temporal, unembedFormula, ih1, ih2]
  | box _ ih => simp [ExtFormula.swap_temporal, Formula.swap_temporal, unembedFormula, ih]
  | untl _ _ ih1 ih2 => simp [ExtFormula.swap_temporal, Formula.swap_temporal, unembedFormula, ih1, ih2]
  | snce _ _ ih1 ih2 => simp [ExtFormula.swap_temporal, Formula.swap_temporal, unembedFormula, ih1, ih2]

/-- Membership preserved under unembedFormula map. -/
private theorem mem_map_unembedFormula {Gamma : ExtContext} {phi : ExtFormula}
    (h : phi ∈ Gamma) : unembedFormula phi ∈ Gamma.map unembedFormula :=
  List.mem_map_of_mem (f := unembedFormula) h

/-- Subset preserved under unembedFormula map. -/
private theorem map_unembed_subset {Gamma Delta : ExtContext}
    (h : Gamma ⊆ Delta) : Gamma.map unembedFormula ⊆ Delta.map unembedFormula := by
  intro x hx
  rw [List.mem_map] at hx ⊢
  obtain ⟨a, ha, rfl⟩ := hx
  exact ⟨a, h ha, rfl⟩

/-!
## Atom Relationship Lemmas for Unembedding
-/

/-- If Sum.inl a ∉ φ.atoms then a ∉ (unembedFormula φ).atoms.
This transfers the freshness condition from Ext to base. -/
theorem inl_not_in_atoms_implies_unembed {a : Atom} {φ : ExtFormula}
    (h : Sum.inl a ∉ φ.atoms) : a ∉ (unembedFormula φ).atoms := by
  induction φ with
  | atom x =>
    cases x with
    | inl t =>
      simp [ExtFormula.atoms] at h
      simp [unembedFormula, Formula.atoms, h]
    | inr u => cases u; simp [unembedFormula, Formula.atoms]
  | bot => simp [unembedFormula, Formula.atoms]
  | imp a' b iha ihb =>
    simp only [ExtFormula.atoms, Finset.mem_union, not_or] at h
    simp only [unembedFormula, Formula.atoms, Finset.mem_union, not_or]
    exact ⟨iha h.1, ihb h.2⟩
  | box a' ih =>
    simp [ExtFormula.atoms] at h; simp [unembedFormula, Formula.atoms, ih h]
  | untl a' b iha ihb =>
    simp only [ExtFormula.atoms, Finset.mem_union, not_or] at h
    simp only [unembedFormula, Formula.atoms, Finset.mem_union, not_or]
    exact ⟨iha h.1, ihb h.2⟩
  | snce a' b iha ihb =>
    simp only [ExtFormula.atoms, Finset.mem_union, not_or] at h
    simp only [unembedFormula, Formula.atoms, Finset.mem_union, not_or]
    exact ⟨iha h.1, ihb h.2⟩

/-!
## Lifting Theorem: F+ to F via Substitution

The lifting theorem transfers F+ derivations of embedded F-formulas back to F.
This is the key conservative extension result.

### Strategy

1. Collect all Sum.inl atoms from the derivation tree
2. Choose a fresh atom `a` not among them
3. Apply `substFreshWith a` to replace Sum.inr () with Sum.inl a throughout
4. Unembed the result (now using only Sum.inl atoms) to a DerivationTree
-/

/-- Collect all Sum.inl atoms from an ExtFormula. -/
private def collectInl : ExtFormula → Finset Atom
  | ExtFormula.atom (Sum.inl a) => {a}
  | ExtFormula.atom (Sum.inr ()) => ∅
  | ExtFormula.bot => ∅
  | ExtFormula.imp φ ψ => collectInl φ ∪ collectInl ψ
  | ExtFormula.box φ => collectInl φ
  | ExtFormula.untl φ ψ => collectInl φ ∪ collectInl ψ
  | ExtFormula.snce φ ψ => collectInl φ ∪ collectInl ψ

private theorem inl_mem_implies_collectInl {a : Atom} {φ : ExtFormula}
    (h : Sum.inl a ∈ φ.atoms) : a ∈ collectInl φ := by
  induction φ with
  | atom x => cases x with
    | inl t => simp [ExtFormula.atoms] at h; simp [collectInl, h]
    | inr u => cases u; simp [ExtFormula.atoms] at h
  | bot => simp [ExtFormula.atoms] at h
  | imp a' b iha ihb =>
    simp only [ExtFormula.atoms, Finset.mem_union] at h
    simp only [collectInl, Finset.mem_union]
    cases h with | inl h => left; exact iha h | inr h => right; exact ihb h
  | box a' ih => exact ih h
  | untl a' b iha ihb =>
    simp only [ExtFormula.atoms, Finset.mem_union] at h
    simp only [collectInl, Finset.mem_union]
    cases h with | inl h => left; exact iha h | inr h => right; exact ihb h
  | snce a' b iha ihb =>
    simp only [ExtFormula.atoms, Finset.mem_union] at h
    simp only [collectInl, Finset.mem_union]
    cases h with | inl h => left; exact iha h | inr h => right; exact ihb h

/-- Collect all Sum.inl atoms from all formulas in an ExtDerivationTree. -/
private noncomputable def collectDerivInl :
    {Γ : ExtContext} → {φ : ExtFormula} → ExtDerivationTree Γ φ → Finset Atom
  | _, _, ExtDerivationTree.axiom _ φ _ => collectInl φ
  | _, _, ExtDerivationTree.assumption _ φ _ => collectInl φ
  | _, _, ExtDerivationTree.modus_ponens _ a b d1 d2 =>
    collectInl a ∪ collectInl b ∪ collectDerivInl d1 ∪ collectDerivInl d2
  | _, _, ExtDerivationTree.necessitation φ d => collectInl φ ∪ collectDerivInl d
  | _, _, ExtDerivationTree.temporal_necessitation φ d => collectInl φ ∪ collectDerivInl d
  | _, _, ExtDerivationTree.temporal_duality φ d => collectInl φ ∪ collectDerivInl d
  | _, _, ExtDerivationTree.weakening _ Δ φ d _ =>
    collectInl φ ∪ collectDerivInl d ∪ Δ.foldl (fun acc ψ => acc ∪ collectInl ψ) ∅

/-- Subderivation atoms are included in parent atoms (monotonicity lemmas). -/
private theorem collectDerivInl_sub_modus_ponens_left {Γ : ExtContext} {a b : ExtFormula}
    {d1 : ExtDerivationTree Γ (a.imp b)} {d2 : ExtDerivationTree Γ a} :
    collectDerivInl d1 ⊆ collectDerivInl (ExtDerivationTree.modus_ponens Γ a b d1 d2) := by
  intro x hx; simp only [collectDerivInl, Finset.mem_union]; tauto

private theorem collectDerivInl_sub_modus_ponens_right {Γ : ExtContext} {a b : ExtFormula}
    {d1 : ExtDerivationTree Γ (a.imp b)} {d2 : ExtDerivationTree Γ a} :
    collectDerivInl d2 ⊆ collectDerivInl (ExtDerivationTree.modus_ponens Γ a b d1 d2) := by
  intro x hx; simp only [collectDerivInl, Finset.mem_union]; tauto

private theorem collectDerivInl_sub_nec {φ : ExtFormula} {d : ExtDerivationTree [] φ} :
    collectDerivInl d ⊆ collectDerivInl (ExtDerivationTree.necessitation φ d) := by
  intro x hx; simp only [collectDerivInl, Finset.mem_union]; tauto

private theorem collectDerivInl_sub_tnec {φ : ExtFormula} {d : ExtDerivationTree [] φ} :
    collectDerivInl d ⊆ collectDerivInl (ExtDerivationTree.temporal_necessitation φ d) := by
  intro x hx; simp only [collectDerivInl, Finset.mem_union]; tauto

private theorem collectDerivInl_sub_tdual {φ : ExtFormula} {d : ExtDerivationTree [] φ} :
    collectDerivInl d ⊆ collectDerivInl (ExtDerivationTree.temporal_duality φ d) := by
  intro x hx; simp only [collectDerivInl, Finset.mem_union]; tauto

private theorem collectDerivInl_sub_weak {Γ Δ : ExtContext} {φ : ExtFormula}
    {d : ExtDerivationTree Γ φ} {h : Γ ⊆ Δ} :
    collectDerivInl d ⊆ collectDerivInl (ExtDerivationTree.weakening Γ Δ φ d h) := by
  intro x hx; simp only [collectDerivInl, Finset.mem_union]; tauto

/-- For any Finset of atoms, there exists an atom not in it. -/
private theorem exists_fresh_atom (S : Finset Atom) : ∃ a : Atom, a ∉ S :=
  Infinite.exists_notMem_finset S

/-!
### substFreshWith preserves freshness

Key lemma: if `t ≠ a` and `Sum.inl t ∉ phi.atoms`, then `Sum.inl t ∉ (substFreshWith a phi).atoms`.
-/

private theorem substFreshWith_preserves_irr_fresh {a t : Atom} {phi : ExtFormula}
    (h : Sum.inl t ∉ phi.atoms) (h_ne : t ≠ a) :
    Sum.inl t ∉ (substFreshWith a phi).atoms := by
  induction phi with
  | atom x =>
    cases x with
    | inl u => simp [substFreshWith, ExtFormula.atoms] at h ⊢; exact h
    | inr u => cases u; simp [substFreshWith, ExtFormula.atoms]; exact h_ne
  | bot => simp [substFreshWith, ExtFormula.atoms]
  | imp a' b iha ihb =>
    simp only [ExtFormula.atoms, Finset.mem_union, not_or] at h
    simp only [substFreshWith, ExtFormula.atoms, Finset.mem_union, not_or]
    exact ⟨iha h.1, ihb h.2⟩
  | box a' ih => simp [ExtFormula.atoms] at h; simp [substFreshWith, ExtFormula.atoms, ih h]
  | untl a' b iha ihb =>
    simp only [ExtFormula.atoms, Finset.mem_union, not_or] at h
    simp only [substFreshWith, ExtFormula.atoms, Finset.mem_union, not_or]
    exact ⟨iha h.1, ihb h.2⟩
  | snce a' b iha ihb =>
    simp only [ExtFormula.atoms, Finset.mem_union, not_or] at h
    simp only [substFreshWith, ExtFormula.atoms, Finset.mem_union, not_or]
    exact ⟨iha h.1, ihb h.2⟩

/-- Subset preserved under substFreshWith map. -/
private theorem map_substFreshWith_subset (a : Atom) {Gamma Delta : ExtContext}
    (h : Gamma ⊆ Delta) : Gamma.map (substFreshWith a) ⊆ Delta.map (substFreshWith a) := by
  intro x hx; rw [List.mem_map] at hx ⊢
  obtain ⟨y, hy, rfl⟩ := hx; exact ⟨y, h hy, rfl⟩

/-!
### Combined Lifting: substFreshWith a + unembedFormula

We define a single recursive function that applies substFreshWith a to eliminate
Sum.inr () atoms, then unembeds to the base language. The parameter a must be
fresh for the entire derivation tree (not appearing in collectDerivInl).
-/

/-- The combined formula transformation: substFreshWith then unembed. -/
private def liftFormula (a : Atom) (φ : ExtFormula) : Formula :=
  unembedFormula (substFreshWith a φ)

/-- liftFormula preserves embedFormula (embedded formulas are q-free). -/
private theorem liftFormula_embed (a : Atom) (φ : Formula) :
    liftFormula a (embedFormula φ) = φ := by
  simp [liftFormula, substFreshWith_of_embedded, unembed_embed]

/-- liftFormula distributes over imp. -/
private theorem liftFormula_imp (a : Atom) (x y : ExtFormula) :
    liftFormula a (x.imp y) = (liftFormula a x).imp (liftFormula a y) := by
  simp [liftFormula, substFreshWith, unembedFormula]

/-- liftFormula distributes over swap_temporal. -/
private theorem liftFormula_swap_temporal (a : Atom) (φ : ExtFormula) :
    liftFormula a φ.swap_temporal = (liftFormula a φ).swap_temporal := by
  simp [liftFormula, substFreshWith_swap_temporal, unembed_swap_temporal]

/-- liftFormula distributes over and. -/
private theorem liftFormula_and (a : Atom) (x y : ExtFormula) :
    liftFormula a (x.and y) = (liftFormula a x).and (liftFormula a y) := rfl

/-- liftFormula on atom (Sum.inl t). -/
private theorem liftFormula_atom_inl (a : Atom) (t : Atom) :
    liftFormula a (ExtFormula.atom (Sum.inl t)) = Formula.atom t := rfl

/-- liftFormula on freshAtom. -/
private theorem liftFormula_freshAtom (a : Atom) :
    liftFormula a (ExtFormula.atom freshAtom) = Formula.atom a := rfl

/-- liftFormula on neg. -/
private theorem liftFormula_neg (a : Atom) (φ : ExtFormula) :
    liftFormula a φ.neg = (liftFormula a φ).neg := rfl

/-- liftFormula on untl. -/
private theorem liftFormula_untl (a : Atom) (φ ψ : ExtFormula) :
    liftFormula a (ExtFormula.untl φ ψ) = Formula.untl (liftFormula a φ) (liftFormula a ψ) := rfl

/-- liftFormula on snce. -/
private theorem liftFormula_snce (a : Atom) (φ ψ : ExtFormula) :
    liftFormula a (ExtFormula.snce φ ψ) = Formula.snce (liftFormula a φ) (liftFormula a ψ) := rfl

/-- Lift an ExtAxiom to a base Axiom via liftFormula. -/
private def liftAxiom (a : Atom) {φ : ExtFormula} (h : ExtAxiom φ) :
    Axiom (liftFormula a φ) := by
  cases h with
  | prop_k x y z => exact Axiom.prop_k _ _ _
  | prop_s x y => exact Axiom.prop_s _ _
  | ex_falso x => exact Axiom.ex_falso _
  | peirce x y => exact Axiom.peirce _ _
  | modal_t x => exact Axiom.modal_t _
  | modal_4 x => exact Axiom.modal_4 _
  | modal_b x => exact Axiom.modal_b _
  | modal_5_collapse x => exact Axiom.modal_5_collapse _
  | modal_k_dist x y => exact Axiom.modal_k_dist _ _
  | serial_future => exact Axiom.serial_future
  | serial_past => exact Axiom.serial_past
  | left_mono_until_G x y z => exact Axiom.left_mono_until_G _ _ _
  | left_mono_since_H x y z => exact Axiom.left_mono_since_H _ _ _
  | right_mono_until x y z => exact Axiom.right_mono_until _ _ _
  | right_mono_since x y z => exact Axiom.right_mono_since _ _ _
  | connect_future x => exact Axiom.connect_future _
  | connect_past x => exact Axiom.connect_past _
  | enrichment_until x y z => exact Axiom.enrichment_until _ _ _
  | enrichment_since x y z => exact Axiom.enrichment_since _ _ _
  | self_accum_until x y => exact Axiom.self_accum_until _ _
  | self_accum_since x y => exact Axiom.self_accum_since _ _
  | absorb_until x y => exact Axiom.absorb_until _ _
  | absorb_since x y => exact Axiom.absorb_since _ _
  | linear_until x y z w => exact Axiom.linear_until _ _ _ _
  | linear_since x y z w => exact Axiom.linear_since _ _ _ _
  | until_F x y => exact Axiom.until_F _ _
  | since_P x y => exact Axiom.since_P _ _
  | temp_linearity x y => exact Axiom.temp_linearity _ _
  | temp_linearity_past x y => exact Axiom.temp_linearity_past _ _
  | F_until_equiv x => exact Axiom.F_until_equiv _
  | P_since_equiv x => exact Axiom.P_since_equiv _
  | modal_future x => exact Axiom.modal_future _
  | discrete_symm_fwd => exact Axiom.discrete_symm_fwd
  | discrete_symm_bwd => exact Axiom.discrete_symm_bwd
  | discrete_propagate_fwd => exact Axiom.discrete_propagate_fwd
  | discrete_propagate_bwd => exact Axiom.discrete_propagate_bwd
  | discrete_box_necessity => exact Axiom.discrete_box_necessity
  | prior_UZ x => exact Axiom.prior_UZ _
  | prior_SZ x => exact Axiom.prior_SZ _
  | z1 x => exact Axiom.z1 _

/-- liftFormula freshness transfer: if Sum.inl t ∉ phi.atoms and t ≠ a,
then t ∉ (liftFormula a phi).atoms. -/
private theorem liftFormula_fresh {a t : Atom} {phi : ExtFormula}
    (h : Sum.inl t ∉ phi.atoms) (h_ne : t ≠ a) :
    t ∉ (liftFormula a phi).atoms := by
  exact inl_not_in_atoms_implies_unembed (substFreshWith_preserves_irr_fresh h h_ne)

/-- liftFormula freshness for freshAtom (Sum.inr ()): if freshAtom ∉ phi.atoms
and Sum.inl a ∉ phi.atoms, then a ∉ (liftFormula a phi).atoms. -/
private theorem liftFormula_fresh_for_replacement {a : Atom} {phi : ExtFormula}
    (h_inl : Sum.inl a ∉ phi.atoms) (h_fresh : freshAtom ∉ phi.atoms) :
    a ∉ (liftFormula a phi).atoms := by
  apply inl_not_in_atoms_implies_unembed
  induction phi with
  | atom x =>
    cases x with
    | inl t => simp [substFreshWith, ExtFormula.atoms] at h_inl ⊢; exact h_inl
    | inr u => cases u; simp [ExtFormula.atoms, freshAtom] at h_fresh
  | bot => simp [substFreshWith, ExtFormula.atoms]
  | imp a' b iha ihb =>
    simp only [ExtFormula.atoms, Finset.mem_union, not_or] at h_inl h_fresh
    simp only [substFreshWith, ExtFormula.atoms, Finset.mem_union, not_or]
    exact ⟨iha h_inl.1 h_fresh.1, ihb h_inl.2 h_fresh.2⟩
  | box a' ih =>
    simp [ExtFormula.atoms] at h_inl h_fresh
    simp [substFreshWith, ExtFormula.atoms, ih h_inl h_fresh]
  | untl a' b iha ihb =>
    simp only [ExtFormula.atoms, Finset.mem_union, not_or] at h_inl h_fresh
    simp only [substFreshWith, ExtFormula.atoms, Finset.mem_union, not_or]
    exact ⟨iha h_inl.1 h_fresh.1, ihb h_inl.2 h_fresh.2⟩
  | snce a' b iha ihb =>
    simp only [ExtFormula.atoms, Finset.mem_union, not_or] at h_inl h_fresh
    simp only [substFreshWith, ExtFormula.atoms, Finset.mem_union, not_or]
    exact ⟨iha h_inl.1 h_fresh.1, ihb h_inl.2 h_fresh.2⟩

/-- The combined lifting function: convert an ExtDerivationTree to a DerivationTree
by replacing Sum.inr () with Sum.inl a and unembedding.

Requires a to be fresh for the entire derivation (a ∉ collectDerivInl d). -/
private noncomputable def liftDerivationWith (a : Atom) :
    {Γ : ExtContext} → {φ : ExtFormula} →
    (d : ExtDerivationTree Γ φ) →
    (h_fresh : a ∉ collectDerivInl d) →
    DerivationTree (Γ.map (liftFormula a)) (liftFormula a φ)
  | _, _, ExtDerivationTree.axiom Γ φ h_ax, _ =>
    DerivationTree.axiom _ _ (liftAxiom a h_ax)
  | _, _, ExtDerivationTree.assumption Γ φ h_mem, _ =>
    DerivationTree.assumption _ _ (List.mem_map_of_mem (f := liftFormula a) h_mem)
  | _, _, ExtDerivationTree.modus_ponens Γ x y d1 d2, h_fr => by
    have h_fr1 : a ∉ collectDerivInl d1 := by
      intro h; apply h_fr; exact collectDerivInl_sub_modus_ponens_left h
    have h_fr2 : a ∉ collectDerivInl d2 := by
      intro h; apply h_fr; exact collectDerivInl_sub_modus_ponens_right h
    exact DerivationTree.modus_ponens _ (liftFormula a x) (liftFormula a y)
      (liftDerivationWith a d1 h_fr1) (liftDerivationWith a d2 h_fr2)
  | _, _, ExtDerivationTree.necessitation φ d, h_fr => by
    have h_fr_d : a ∉ collectDerivInl d := by
      intro h; apply h_fr; exact collectDerivInl_sub_nec h
    exact DerivationTree.necessitation _ (liftDerivationWith a d h_fr_d)
  | _, _, ExtDerivationTree.temporal_necessitation φ d, h_fr => by
    have h_fr_d : a ∉ collectDerivInl d := by
      intro h; apply h_fr; exact collectDerivInl_sub_tnec h
    exact DerivationTree.temporal_necessitation _ (liftDerivationWith a d h_fr_d)
  | _, _, ExtDerivationTree.temporal_duality φ d, h_fr => by
    have h_fr_d : a ∉ collectDerivInl d := by
      intro h; apply h_fr; exact collectDerivInl_sub_tdual h
    exact liftFormula_swap_temporal a φ ▸
      DerivationTree.temporal_duality _ (liftDerivationWith a d h_fr_d)
  | _, _, ExtDerivationTree.weakening Γ Δ φ d h_sub, h_fr => by
    have h_fr_d : a ∉ collectDerivInl d := by
      intro h; apply h_fr; exact collectDerivInl_sub_weak h
    have h_lift_sub : Γ.map (liftFormula a) ⊆ Δ.map (liftFormula a) := by
      intro x hx; rw [List.mem_map] at hx ⊢
      obtain ⟨y, hy, rfl⟩ := hx; exact ⟨y, h_sub hy, rfl⟩
    exact DerivationTree.weakening _ _ _
      (liftDerivationWith a d h_fr_d) h_lift_sub

/-!
### Main Lifting Theorem

Projects F+ derivations of embedded formulas back to F derivations.
-/

/-- F+ is a conservative extension of F: if F+ derives `embedFormula phi` from
`L.map embedFormula`, then F derives `phi` from `L`.

This is the key result enabling the irreflexivity proof. The proof works by:
1. Collecting all inl atoms from the derivation tree
2. Choosing a fresh atom a not among them
3. Applying liftDerivationWith a to convert the ExtDerivationTree to a DerivationTree
4. Using liftFormula_embed to simplify the context and conclusion -/
theorem lift_derivation_qfree (L : List Formula) (phi : Formula)
    (d : ExtDerivationTree (L.map embedFormula) (embedFormula phi)) :
    Nonempty (DerivationTree L phi) := by
  obtain ⟨a, ha⟩ := exists_fresh_atom (collectDerivInl d)
  have lifted := liftDerivationWith a d ha
  -- The context and conclusion simplify via liftFormula_embed
  have h_ctx : (L.map embedFormula).map (liftFormula a) = L := by
    rw [List.map_map]
    conv => lhs; arg 1; ext x; rw [Function.comp, liftFormula_embed]
    simp
  have h_concl : liftFormula a (embedFormula phi) = phi := liftFormula_embed a phi
  rw [h_ctx, h_concl] at lifted
  exact ⟨lifted⟩

end Bimodal.Metalogic.ConservativeExtension
