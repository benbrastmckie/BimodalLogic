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

/-!
## Unembedding Axioms: ExtAxiom to Axiom
-/

/-- Convert an ExtAxiom to a base Axiom under unembedFormula. -/
def unembedAxiom {φ : ExtFormula} (h : ExtAxiom φ) : Axiom (unembedFormula φ) := by
  cases h with
  | prop_k a b c => exact Axiom.prop_k _ _ _
  | prop_s a b => exact Axiom.prop_s _ _
  | modal_t a => exact Axiom.modal_t _
  | modal_4 a => exact Axiom.modal_4 _
  | modal_b a => exact Axiom.modal_b _
  | modal_5_collapse a => exact Axiom.modal_5_collapse _
  | ex_falso a => exact Axiom.ex_falso _
  | peirce a b => exact Axiom.peirce _ _
  | modal_k_dist a b => exact Axiom.modal_k_dist _ _
  | temp_k_dist a b => exact Axiom.temp_k_dist _ _
  | temp_4 a => exact Axiom.temp_4 _
  | temp_a a => exact Axiom.temp_a _
  | temp_l a => exact Axiom.temp_l _
  | modal_future a => exact Axiom.modal_future _
  | temp_future a => exact Axiom.temp_future _
  | temp_linearity a b => exact Axiom.temp_linearity _ _
  | density a => exact Axiom.density _
  | discreteness_forward a => exact Axiom.discreteness_forward _
  | seriality_future => exact Axiom.seriality_future
  | seriality_past => exact Axiom.seriality_past

/-- unembedFormula commutes with swap_temporal. -/
theorem unembed_swap_temporal (φ : ExtFormula) :
    unembedFormula φ.swap_temporal = (unembedFormula φ).swap_temporal := by
  induction φ with
  | atom a => cases a with | inl s => rfl | inr u => cases u; rfl
  | bot => rfl
  | imp _ _ ih1 ih2 => simp [ExtFormula.swap_temporal, Formula.swap_temporal, unembedFormula, ih1, ih2]
  | box _ ih => simp [ExtFormula.swap_temporal, Formula.swap_temporal, unembedFormula, ih]
  | all_past _ ih => simp [ExtFormula.swap_temporal, Formula.swap_temporal, unembedFormula, ih]
  | all_future _ ih => simp [ExtFormula.swap_temporal, Formula.swap_temporal, unembedFormula, ih]

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

/-- If Sum.inl s ∉ φ.atoms then s ∉ (unembedFormula φ).atoms.
This transfers the freshness condition from Ext to base. -/
theorem inl_not_in_atoms_implies_unembed {s : String} {φ : ExtFormula}
    (h : Sum.inl s ∉ φ.atoms) : s ∉ (unembedFormula φ).atoms := by
  induction φ with
  | atom a =>
    cases a with
    | inl t =>
      simp [ExtFormula.atoms] at h
      simp [unembedFormula, Formula.atoms, h]
    | inr u => cases u; simp [unembedFormula, Formula.atoms]
  | bot => simp [unembedFormula, Formula.atoms]
  | imp a b iha ihb =>
    simp only [ExtFormula.atoms, Finset.mem_union, not_or] at h
    simp only [unembedFormula, Formula.atoms, Finset.mem_union, not_or]
    exact ⟨iha h.1, ihb h.2⟩
  | box a ih =>
    simp [ExtFormula.atoms] at h; simp [unembedFormula, Formula.atoms, ih h]
  | all_past a ih =>
    simp [ExtFormula.atoms] at h; simp [unembedFormula, Formula.atoms, ih h]
  | all_future a ih =>
    simp [ExtFormula.atoms] at h; simp [unembedFormula, Formula.atoms, ih h]

/-!
## Lifting Theorem: F+ to F via Substitution

The lifting theorem transfers F+ derivations of embedded F-formulas back to F.
This is the key conservative extension result.

### Strategy

1. Collect all Sum.inl atoms from the derivation tree
2. Choose a fresh string `s` not among them
3. Apply `substFreshWith s` to replace Sum.inr () with Sum.inl s throughout
4. Unembed the result (now using only Sum.inl atoms) to a DerivationTree
-/

/-- Collect all Sum.inl atoms from an ExtFormula. -/
private def collectInl : ExtFormula → Finset String
  | ExtFormula.atom (Sum.inl s) => {s}
  | ExtFormula.atom (Sum.inr ()) => ∅
  | ExtFormula.bot => ∅
  | ExtFormula.imp φ ψ => collectInl φ ∪ collectInl ψ
  | ExtFormula.box φ => collectInl φ
  | ExtFormula.all_past φ => collectInl φ
  | ExtFormula.all_future φ => collectInl φ

private theorem inl_mem_implies_collectInl {s : String} {φ : ExtFormula}
    (h : Sum.inl s ∈ φ.atoms) : s ∈ collectInl φ := by
  induction φ with
  | atom a => cases a with
    | inl t => simp [ExtFormula.atoms] at h; simp [collectInl, h]
    | inr u => cases u; simp [ExtFormula.atoms] at h
  | bot => simp [ExtFormula.atoms] at h
  | imp a b iha ihb =>
    simp only [ExtFormula.atoms, Finset.mem_union] at h
    simp only [collectInl, Finset.mem_union]
    cases h with | inl h => left; exact iha h | inr h => right; exact ihb h
  | box a ih => exact ih h
  | all_past a ih => exact ih h
  | all_future a ih => exact ih h

/-- Collect all Sum.inl atoms from all formulas in an ExtDerivationTree,
including IRR atom parameters. -/
private noncomputable def collectDerivInl :
    {Γ : ExtContext} → {φ : ExtFormula} → ExtDerivationTree Γ φ → Finset String
  | _, _, ExtDerivationTree.axiom _ φ _ => collectInl φ
  | _, _, ExtDerivationTree.assumption _ φ _ => collectInl φ
  | _, _, ExtDerivationTree.modus_ponens _ a b d1 d2 =>
    collectInl a ∪ collectInl b ∪ collectDerivInl d1 ∪ collectDerivInl d2
  | _, _, ExtDerivationTree.necessitation φ d => collectInl φ ∪ collectDerivInl d
  | _, _, ExtDerivationTree.temporal_necessitation φ d => collectInl φ ∪ collectDerivInl d
  | _, _, ExtDerivationTree.temporal_duality φ d => collectInl φ ∪ collectDerivInl d
  | _, _, ExtDerivationTree.irr p φ _ d =>
    (match p with | Sum.inl s => {s} | Sum.inr () => ∅) ∪ collectInl φ ∪ collectDerivInl d
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

private theorem collectDerivInl_sub_irr {p : ExtAtom} {φ : ExtFormula} {h : p ∉ φ.atoms}
    {d : ExtDerivationTree [] ((ExtFormula.and (ExtFormula.atom p)
      (ExtFormula.all_past (ExtFormula.neg (ExtFormula.atom p)))).imp φ)} :
    collectDerivInl d ⊆ collectDerivInl (ExtDerivationTree.irr p φ h d) := by
  intro x hx; simp only [collectDerivInl, Finset.mem_union]; tauto

private theorem collectDerivInl_sub_weak {Γ Δ : ExtContext} {φ : ExtFormula}
    {d : ExtDerivationTree Γ φ} {h : Γ ⊆ Δ} :
    collectDerivInl d ⊆ collectDerivInl (ExtDerivationTree.weakening Γ Δ φ d h) := by
  intro x hx; simp only [collectDerivInl, Finset.mem_union]; tauto

/-- For any Finset of strings, there exists a string not in it. -/
private theorem exists_fresh_string (S : Finset String) : ∃ s : String, s ∉ S := by
  by_contra h; push_neg at h
  have : Fintype String := ⟨S, h⟩
  exact not_finite String

/-!
### substFreshWith preserves IRR freshness

Key lemma: if `t ≠ s` and `Sum.inl t ∉ phi.atoms`, then `Sum.inl t ∉ (substFreshWith s phi).atoms`.
-/

private theorem substFreshWith_preserves_irr_fresh {s t : String} {phi : ExtFormula}
    (h : Sum.inl t ∉ phi.atoms) (h_ne : t ≠ s) :
    Sum.inl t ∉ (substFreshWith s phi).atoms := by
  induction phi with
  | atom a =>
    cases a with
    | inl u => simp [substFreshWith, ExtFormula.atoms] at h ⊢; exact h
    | inr u => cases u; simp [substFreshWith, ExtFormula.atoms]; exact h_ne
  | bot => simp [substFreshWith, ExtFormula.atoms]
  | imp a b iha ihb =>
    simp only [ExtFormula.atoms, Finset.mem_union, not_or] at h
    simp only [substFreshWith, ExtFormula.atoms, Finset.mem_union, not_or]
    exact ⟨iha h.1, ihb h.2⟩
  | box a ih => simp [ExtFormula.atoms] at h; simp [substFreshWith, ExtFormula.atoms, ih h]
  | all_past a ih => simp [ExtFormula.atoms] at h; simp [substFreshWith, ExtFormula.atoms, ih h]
  | all_future a ih => simp [ExtFormula.atoms] at h; simp [substFreshWith, ExtFormula.atoms, ih h]

/-- Subset preserved under substFreshWith map. -/
private theorem map_substFreshWith_subset (s : String) {Gamma Delta : ExtContext}
    (h : Gamma ⊆ Delta) : Gamma.map (substFreshWith s) ⊆ Delta.map (substFreshWith s) := by
  intro x hx; rw [List.mem_map] at hx ⊢
  obtain ⟨a, ha, rfl⟩ := hx; exact ⟨a, h ha, rfl⟩

/-!
### Combined Lifting: substFreshWith s + unembedFormula

We define a single recursive function that applies substFreshWith s to eliminate
Sum.inr () atoms, then unembeds to the base language. The parameter s must be
fresh for the entire derivation tree (not appearing in collectDerivInl).
-/

/-- The combined formula transformation: substFreshWith then unembed. -/
private def liftFormula (s : String) (φ : ExtFormula) : Formula :=
  unembedFormula (substFreshWith s φ)

/-- liftFormula preserves embedFormula (embedded formulas are q-free). -/
private theorem liftFormula_embed (s : String) (φ : Formula) :
    liftFormula s (embedFormula φ) = φ := by
  simp [liftFormula, substFreshWith_of_embedded, unembed_embed]

/-- liftFormula distributes over imp. -/
private theorem liftFormula_imp (s : String) (a b : ExtFormula) :
    liftFormula s (a.imp b) = (liftFormula s a).imp (liftFormula s b) := by
  simp [liftFormula, substFreshWith, unembedFormula]

/-- liftFormula distributes over swap_temporal. -/
private theorem liftFormula_swap_temporal (s : String) (φ : ExtFormula) :
    liftFormula s φ.swap_temporal = (liftFormula s φ).swap_temporal := by
  simp [liftFormula, substFreshWith_swap_temporal, unembed_swap_temporal]

/-- liftFormula distributes over and. -/
private theorem liftFormula_and (s : String) (a b : ExtFormula) :
    liftFormula s (a.and b) = (liftFormula s a).and (liftFormula s b) := rfl

/-- liftFormula on atom (Sum.inl t). -/
private theorem liftFormula_atom_inl (s : String) (t : String) :
    liftFormula s (ExtFormula.atom (Sum.inl t)) = Formula.atom t := rfl

/-- liftFormula on freshAtom. -/
private theorem liftFormula_freshAtom (s : String) :
    liftFormula s (ExtFormula.atom freshAtom) = Formula.atom s := rfl

/-- liftFormula on neg. -/
private theorem liftFormula_neg (s : String) (φ : ExtFormula) :
    liftFormula s φ.neg = (liftFormula s φ).neg := rfl

/-- liftFormula on all_past. -/
private theorem liftFormula_all_past (s : String) (φ : ExtFormula) :
    liftFormula s φ.all_past = (liftFormula s φ).all_past := rfl

/-- Lift an ExtAxiom to a base Axiom via liftFormula. -/
private def liftAxiom (s : String) {φ : ExtFormula} (h : ExtAxiom φ) :
    Axiom (liftFormula s φ) := by
  cases h with
  | prop_k a b c => exact Axiom.prop_k _ _ _
  | prop_s a b => exact Axiom.prop_s _ _
  | modal_t a => exact Axiom.modal_t _
  | modal_4 a => exact Axiom.modal_4 _
  | modal_b a => exact Axiom.modal_b _
  | modal_5_collapse a => exact Axiom.modal_5_collapse _
  | ex_falso a => exact Axiom.ex_falso _
  | peirce a b => exact Axiom.peirce _ _
  | modal_k_dist a b => exact Axiom.modal_k_dist _ _
  | temp_k_dist a b => exact Axiom.temp_k_dist _ _
  | temp_4 a => exact Axiom.temp_4 _
  | temp_a a => exact Axiom.temp_a _
  | temp_l a => exact Axiom.temp_l _
  | modal_future a => exact Axiom.modal_future _
  | temp_future a => exact Axiom.temp_future _
  | temp_linearity a b => exact Axiom.temp_linearity _ _
  | density a => exact Axiom.density _
  | discreteness_forward a => exact Axiom.discreteness_forward _
  | seriality_future => exact Axiom.seriality_future
  | seriality_past => exact Axiom.seriality_past

/-- liftFormula freshness transfer: if Sum.inl t ∉ phi.atoms and t ≠ s,
then t ∉ (liftFormula s phi).atoms. -/
private theorem liftFormula_fresh {s t : String} {phi : ExtFormula}
    (h : Sum.inl t ∉ phi.atoms) (h_ne : t ≠ s) :
    t ∉ (liftFormula s phi).atoms := by
  exact inl_not_in_atoms_implies_unembed (substFreshWith_preserves_irr_fresh h h_ne)

/-- liftFormula freshness for freshAtom (Sum.inr ()): if freshAtom ∉ phi.atoms
and Sum.inl s ∉ phi.atoms, then s ∉ (liftFormula s phi).atoms. -/
private theorem liftFormula_fresh_for_replacement {s : String} {phi : ExtFormula}
    (h_inl : Sum.inl s ∉ phi.atoms) (h_fresh : freshAtom ∉ phi.atoms) :
    s ∉ (liftFormula s phi).atoms := by
  apply inl_not_in_atoms_implies_unembed
  induction phi with
  | atom a =>
    cases a with
    | inl t => simp [substFreshWith, ExtFormula.atoms] at h_inl ⊢; exact h_inl
    | inr u => cases u; simp [ExtFormula.atoms, freshAtom] at h_fresh
  | bot => simp [substFreshWith, ExtFormula.atoms]
  | imp a b iha ihb =>
    simp only [ExtFormula.atoms, Finset.mem_union, not_or] at h_inl h_fresh
    simp only [substFreshWith, ExtFormula.atoms, Finset.mem_union, not_or]
    exact ⟨iha h_inl.1 h_fresh.1, ihb h_inl.2 h_fresh.2⟩
  | box a ih =>
    simp [ExtFormula.atoms] at h_inl h_fresh
    simp [substFreshWith, ExtFormula.atoms, ih h_inl h_fresh]
  | all_past a ih =>
    simp [ExtFormula.atoms] at h_inl h_fresh
    simp [substFreshWith, ExtFormula.atoms, ih h_inl h_fresh]
  | all_future a ih =>
    simp [ExtFormula.atoms] at h_inl h_fresh
    simp [substFreshWith, ExtFormula.atoms, ih h_inl h_fresh]

/-- The combined lifting function: convert an ExtDerivationTree to a DerivationTree
by replacing Sum.inr () with Sum.inl s and unembedding.

Requires s to be fresh for the entire derivation (s ∉ collectDerivInl d). -/
private noncomputable def liftDerivationWith (s : String) :
    {Γ : ExtContext} → {φ : ExtFormula} →
    (d : ExtDerivationTree Γ φ) →
    (h_fresh : s ∉ collectDerivInl d) →
    DerivationTree (Γ.map (liftFormula s)) (liftFormula s φ)
  | _, _, ExtDerivationTree.axiom Γ φ h_ax, _ =>
    DerivationTree.axiom _ _ (liftAxiom s h_ax)
  | _, _, ExtDerivationTree.assumption Γ φ h_mem, _ =>
    DerivationTree.assumption _ _ (List.mem_map_of_mem (f := liftFormula s) h_mem)
  | _, _, ExtDerivationTree.modus_ponens Γ a b d1 d2, h_fr => by
    have h_fr1 : s ∉ collectDerivInl d1 := by
      intro h; apply h_fr; exact collectDerivInl_sub_modus_ponens_left h
    have h_fr2 : s ∉ collectDerivInl d2 := by
      intro h; apply h_fr; exact collectDerivInl_sub_modus_ponens_right h
    exact DerivationTree.modus_ponens _ (liftFormula s a) (liftFormula s b)
      (liftDerivationWith s d1 h_fr1) (liftDerivationWith s d2 h_fr2)
  | _, _, ExtDerivationTree.necessitation φ d, h_fr => by
    have h_fr_d : s ∉ collectDerivInl d := by
      intro h; apply h_fr; exact collectDerivInl_sub_nec h
    exact DerivationTree.necessitation _ (liftDerivationWith s d h_fr_d)
  | _, _, ExtDerivationTree.temporal_necessitation φ d, h_fr => by
    have h_fr_d : s ∉ collectDerivInl d := by
      intro h; apply h_fr; exact collectDerivInl_sub_tnec h
    exact DerivationTree.temporal_necessitation _ (liftDerivationWith s d h_fr_d)
  | _, _, ExtDerivationTree.temporal_duality φ d, h_fr => by
    have h_fr_d : s ∉ collectDerivInl d := by
      intro h; apply h_fr; exact collectDerivInl_sub_tdual h
    exact liftFormula_swap_temporal s φ ▸
      DerivationTree.temporal_duality _ (liftDerivationWith s d h_fr_d)
  | _, _, ExtDerivationTree.irr (Sum.inl t) φ h_atom d, h_fr => by
    have h_fr_d : s ∉ collectDerivInl d := by
      intro h; apply h_fr; exact collectDerivInl_sub_irr h
    have h_ne : t ≠ s := by
      intro heq; apply h_fr
      simp only [collectDerivInl, Finset.mem_union]
      left; left; exact Finset.mem_singleton.mpr heq.symm
    exact DerivationTree.irr t (liftFormula s φ) (liftFormula_fresh h_atom h_ne)
      (liftDerivationWith s d h_fr_d)
  | _, _, ExtDerivationTree.irr (Sum.inr ()) φ h_atom d, h_fr => by
    have h_fr_d : s ∉ collectDerivInl d := by
      intro h; apply h_fr; exact collectDerivInl_sub_irr h
    -- s ∉ collectInl phi (from h_fr and the fact that collectInl phi ⊆ collectDerivInl parent)
    have h_s_not_in_phi : Sum.inl s ∉ φ.atoms := by
      intro h_in; apply h_fr
      simp only [collectDerivInl, Finset.mem_union]
      left; right; exact inl_mem_implies_collectInl h_in
    exact DerivationTree.irr s (liftFormula s φ)
      (liftFormula_fresh_for_replacement h_s_not_in_phi h_atom)
      (liftDerivationWith s d h_fr_d)
  | _, _, ExtDerivationTree.weakening Γ Δ φ d h_sub, h_fr => by
    have h_fr_d : s ∉ collectDerivInl d := by
      intro h; apply h_fr; exact collectDerivInl_sub_weak h
    have h_lift_sub : Γ.map (liftFormula s) ⊆ Δ.map (liftFormula s) := by
      intro x hx; rw [List.mem_map] at hx ⊢
      obtain ⟨a, ha, rfl⟩ := hx; exact ⟨a, h_sub ha, rfl⟩
    exact DerivationTree.weakening _ _ _
      (liftDerivationWith s d h_fr_d) h_lift_sub

/-!
### Main Lifting Theorem

Projects F+ derivations of embedded formulas back to F derivations.
-/

/-- F+ is a conservative extension of F: if F+ derives `embedFormula phi` from
`L.map embedFormula`, then F derives `phi` from `L`.

This is the key result enabling the irreflexivity proof. The proof works by:
1. Collecting all inl atoms from the derivation tree
2. Choosing a fresh string s not among them
3. Applying liftDerivationWith s to convert the ExtDerivationTree to a DerivationTree
4. Using liftFormula_embed to simplify the context and conclusion -/
theorem lift_derivation_qfree (L : List Formula) (phi : Formula)
    (d : ExtDerivationTree (L.map embedFormula) (embedFormula phi)) :
    Nonempty (DerivationTree L phi) := by
  obtain ⟨s, hs⟩ := exists_fresh_string (collectDerivInl d)
  have lifted := liftDerivationWith s d hs
  -- The context and conclusion simplify via liftFormula_embed
  have h_ctx : (L.map embedFormula).map (liftFormula s) = L := by
    rw [List.map_map]
    conv => lhs; arg 1; ext x; rw [Function.comp, liftFormula_embed]
    simp
  have h_concl : liftFormula s (embedFormula phi) = phi := liftFormula_embed s phi
  rw [h_ctx, h_concl] at lifted
  exact ⟨lifted⟩

end Bimodal.Metalogic.ConservativeExtension
