import Bimodal.Metalogic.ConservativeExtension.ExtFormula
import Bimodal.Metalogic.ConservativeExtension.ExtDerivation

/-!
# Substitution for Conservative Extension

This module defines the substitution `sigma[q -> bot]` that maps `ExtFormula` to `ExtFormula`
by replacing the fresh atom `q = Sum.inr ()` with `bot`. The key properties are:

1. `substFormula_preserves_qfree`: q-free formulas are fixed points of substitution
2. `substFormula_of_embedded`: embedded formulas are unchanged
3. Various structural lemmas for derived operators

These are the foundation for proving axiom closure and the lifting theorem.

## References

- Goldblatt 1992, Logics of Time and Computation
-/

namespace Bimodal.Metalogic.ConservativeExtension

open Bimodal.Syntax

/-- Substitution sigma[q -> bot]: replace the fresh atom `Sum.inr ()` with `bot`.
All other atoms (of the form `Sum.inl a`) are unchanged. -/
def substFormula : ExtFormula → ExtFormula
  | ExtFormula.atom (Sum.inl a) => ExtFormula.atom (Sum.inl a)
  | ExtFormula.atom (Sum.inr ()) => ExtFormula.bot
  | ExtFormula.bot => ExtFormula.bot
  | ExtFormula.imp φ ψ => ExtFormula.imp (substFormula φ) (substFormula ψ)
  | ExtFormula.box φ => ExtFormula.box (substFormula φ)
  | ExtFormula.untl φ ψ => ExtFormula.untl (substFormula φ) (substFormula ψ)
  | ExtFormula.snce φ ψ => ExtFormula.snce (substFormula φ) (substFormula ψ)

/-!
## Structural Lemmas
-/

@[simp]
theorem substFormula_bot : substFormula ExtFormula.bot = ExtFormula.bot := rfl

@[simp]
theorem substFormula_atom_inl (a : Atom) :
    substFormula (ExtFormula.atom (Sum.inl a)) = ExtFormula.atom (Sum.inl a) := rfl

@[simp]
theorem substFormula_atom_fresh :
    substFormula (ExtFormula.atom freshAtom) = ExtFormula.bot := rfl

@[simp]
theorem substFormula_imp (φ ψ : ExtFormula) :
    substFormula (φ.imp ψ) = (substFormula φ).imp (substFormula ψ) := rfl

@[simp]
theorem substFormula_box (φ : ExtFormula) :
    substFormula (φ.box) = (substFormula φ).box := rfl

@[simp]
theorem substFormula_untl (φ ψ : ExtFormula) :
    substFormula (ExtFormula.untl φ ψ) = ExtFormula.untl (substFormula φ) (substFormula ψ) := rfl

@[simp]
theorem substFormula_snce (φ ψ : ExtFormula) :
    substFormula (ExtFormula.snce φ ψ) = ExtFormula.snce (substFormula φ) (substFormula ψ) := rfl

/-!
## Derived Operator Preservation
-/

@[simp]
theorem substFormula_neg (φ : ExtFormula) :
    substFormula φ.neg = (substFormula φ).neg := rfl

@[simp]
theorem substFormula_and (φ ψ : ExtFormula) :
    substFormula (φ.and ψ) = (substFormula φ).and (substFormula ψ) := rfl

@[simp]
theorem substFormula_or (φ ψ : ExtFormula) :
    substFormula (φ.or ψ) = (substFormula φ).or (substFormula ψ) := rfl

@[simp]
theorem substFormula_diamond (φ : ExtFormula) :
    substFormula φ.diamond = (substFormula φ).diamond := rfl

@[simp]
theorem substFormula_top : substFormula ExtFormula.top = ExtFormula.top := rfl

@[simp]
theorem substFormula_some_future (φ : ExtFormula) :
    substFormula φ.some_future = (substFormula φ).some_future := rfl

@[simp]
theorem substFormula_some_past (φ : ExtFormula) :
    substFormula φ.some_past = (substFormula φ).some_past := rfl

@[simp]
theorem substFormula_all_future (φ : ExtFormula) :
    substFormula φ.all_future = (substFormula φ).all_future := rfl

@[simp]
theorem substFormula_all_past (φ : ExtFormula) :
    substFormula φ.all_past = (substFormula φ).all_past := rfl

@[simp]
theorem substFormula_always (φ : ExtFormula) :
    substFormula φ.always = (substFormula φ).always := rfl

/-!
## Swap Temporal Preservation
-/

theorem substFormula_swap_temporal (φ : ExtFormula) :
    substFormula φ.swap_temporal = (substFormula φ).swap_temporal := by
  induction φ with
  | atom a =>
    cases a with
    | inl s => simp [ExtFormula.swap_temporal, substFormula]
    | inr u => cases u; simp [ExtFormula.swap_temporal, substFormula]
  | bot => rfl
  | imp _ _ ih1 ih2 =>
    simp [ExtFormula.swap_temporal, substFormula, ih1, ih2]
  | box _ ih =>
    simp [ExtFormula.swap_temporal, substFormula, ih]
  | untl _ _ ih1 ih2 =>
    simp [ExtFormula.swap_temporal, substFormula, ih1, ih2]
  | snce _ _ ih1 ih2 =>
    simp [ExtFormula.swap_temporal, substFormula, ih1, ih2]

/-!
## Key Preservation Lemma: q-free formulas are fixed points
-/

/-- If the fresh atom is not in a formula's atoms, substitution is the identity. -/
theorem substFormula_preserves_qfree (φ : ExtFormula) (h : freshAtom ∉ φ.atoms) :
    substFormula φ = φ := by
  induction φ with
  | atom a =>
    cases a with
    | inl s => rfl
    | inr u =>
      cases u
      simp [ExtFormula.atoms, freshAtom] at h
  | bot => rfl
  | imp a b iha ihb =>
    simp only [ExtFormula.atoms, Finset.mem_union, not_or] at h
    simp [substFormula, iha h.1, ihb h.2]
  | box a ih =>
    simp [ExtFormula.atoms] at h
    simp [substFormula, ih h]
  | untl a b iha ihb =>
    simp only [ExtFormula.atoms, Finset.mem_union, not_or] at h
    simp [substFormula, iha h.1, ihb h.2]
  | snce a b iha ihb =>
    simp only [ExtFormula.atoms, Finset.mem_union, not_or] at h
    simp [substFormula, iha h.1, ihb h.2]

/-- Embedded formulas are unchanged by substitution. -/
theorem substFormula_of_embedded (φ : Formula) :
    substFormula (embedFormula φ) = embedFormula φ :=
  substFormula_preserves_qfree _ (fresh_not_in_embedFormula_atoms φ)

/-!
## Idempotence
-/

/-- After substitution, the fresh atom does not appear. -/
theorem freshAtom_not_in_substFormula_atoms (φ : ExtFormula) :
    freshAtom ∉ (substFormula φ).atoms := by
  induction φ with
  | atom a =>
    cases a with
    | inl s => simp [substFormula, ExtFormula.atoms, freshAtom]
    | inr u => cases u; simp [substFormula, ExtFormula.atoms]
  | bot => simp [substFormula, ExtFormula.atoms]
  | imp a b iha ihb =>
    simp [substFormula, ExtFormula.atoms, Finset.mem_union]
    exact ⟨iha, ihb⟩
  | box a ih => simp [substFormula, ExtFormula.atoms]; exact ih
  | untl a b iha ihb =>
    simp [substFormula, ExtFormula.atoms, Finset.mem_union]
    exact ⟨iha, ihb⟩
  | snce a b iha ihb =>
    simp [substFormula, ExtFormula.atoms, Finset.mem_union]
    exact ⟨iha, ihb⟩

/-- Substitution is idempotent: applying it twice gives the same result. -/
theorem substFormula_idempotent (φ : ExtFormula) :
    substFormula (substFormula φ) = substFormula φ :=
  substFormula_preserves_qfree _ (freshAtom_not_in_substFormula_atoms φ)

/-!
## Axiom Substitution Closure

Every axiom schema is closed under uniform substitution: if `ExtAxiom φ` then
`ExtAxiom (substFormula φ)`. This is because each axiom has the form
`A(φ₁, ..., φₙ)` and substitution distributes over all constructors, so
`substFormula (A(φ₁, ..., φₙ)) = A(substFormula φ₁, ..., substFormula φₙ)`.
-/

/-- All axiom schemas are closed under the substitution sigma[q -> bot]. -/
def substAxiom {φ : ExtFormula} (h : ExtAxiom φ) : ExtAxiom (substFormula φ) := by
  cases h with
  | prop_k a b c => exact ExtAxiom.prop_k (substFormula a) (substFormula b) (substFormula c)
  | prop_s a b => exact ExtAxiom.prop_s (substFormula a) (substFormula b)
  | ex_falso a => exact ExtAxiom.ex_falso (substFormula a)
  | peirce a b => exact ExtAxiom.peirce (substFormula a) (substFormula b)
  | modal_t a => exact ExtAxiom.modal_t (substFormula a)
  | modal_4 a => exact ExtAxiom.modal_4 (substFormula a)
  | modal_b a => exact ExtAxiom.modal_b (substFormula a)
  | modal_5_collapse a => exact ExtAxiom.modal_5_collapse (substFormula a)
  | modal_k_dist a b => exact ExtAxiom.modal_k_dist (substFormula a) (substFormula b)
  | serial_future => exact ExtAxiom.serial_future
  | serial_past => exact ExtAxiom.serial_past
  | left_mono_until_G a b c => exact ExtAxiom.left_mono_until_G (substFormula a) (substFormula b) (substFormula c)
  | left_mono_since_H a b c => exact ExtAxiom.left_mono_since_H (substFormula a) (substFormula b) (substFormula c)
  | right_mono_until a b c => exact ExtAxiom.right_mono_until (substFormula a) (substFormula b) (substFormula c)
  | right_mono_since a b c => exact ExtAxiom.right_mono_since (substFormula a) (substFormula b) (substFormula c)
  | connect_future a => exact ExtAxiom.connect_future (substFormula a)
  | connect_past a => exact ExtAxiom.connect_past (substFormula a)
  | enrichment_until a b c => exact ExtAxiom.enrichment_until (substFormula a) (substFormula b) (substFormula c)
  | enrichment_since a b c => exact ExtAxiom.enrichment_since (substFormula a) (substFormula b) (substFormula c)
  | self_accum_until a b => exact ExtAxiom.self_accum_until (substFormula a) (substFormula b)
  | self_accum_since a b => exact ExtAxiom.self_accum_since (substFormula a) (substFormula b)
  | absorb_until a b => exact ExtAxiom.absorb_until (substFormula a) (substFormula b)
  | absorb_since a b => exact ExtAxiom.absorb_since (substFormula a) (substFormula b)
  | linear_until a b c d => exact ExtAxiom.linear_until (substFormula a) (substFormula b) (substFormula c) (substFormula d)
  | linear_since a b c d => exact ExtAxiom.linear_since (substFormula a) (substFormula b) (substFormula c) (substFormula d)
  | until_F a b => exact ExtAxiom.until_F (substFormula a) (substFormula b)
  | since_P a b => exact ExtAxiom.since_P (substFormula a) (substFormula b)
  | temp_linearity a b => exact ExtAxiom.temp_linearity (substFormula a) (substFormula b)
  | temp_linearity_past a b => exact ExtAxiom.temp_linearity_past (substFormula a) (substFormula b)
  | F_until_equiv a => exact ExtAxiom.F_until_equiv (substFormula a)
  | P_since_equiv a => exact ExtAxiom.P_since_equiv (substFormula a)
  | modal_future a => exact ExtAxiom.modal_future (substFormula a)
  | discrete_symm_fwd => exact ExtAxiom.discrete_symm_fwd
  | discrete_symm_bwd => exact ExtAxiom.discrete_symm_bwd
  | discrete_propagate_fwd => exact ExtAxiom.discrete_propagate_fwd
  | discrete_propagate_bwd => exact ExtAxiom.discrete_propagate_bwd
  | discrete_box_necessity => exact ExtAxiom.discrete_box_necessity
  | prior_UZ a => exact ExtAxiom.prior_UZ (substFormula a)
  | prior_SZ a => exact ExtAxiom.prior_SZ (substFormula a)
  | z1 a => exact ExtAxiom.z1 (substFormula a)

/-!
## List Substitution
-/

/-- Substitution distributes over list map. -/
theorem substFormula_map_embedded (L : List Formula) :
    (L.map embedFormula).map substFormula = L.map embedFormula := by
  simp [List.map_map, Function.comp, substFormula_of_embedded]

end Bimodal.Metalogic.ConservativeExtension
