import Bimodal.ProofSystem.Derivation
import Bimodal.Syntax.Formula

/-!
# Atom Substitution in Derivations

This module defines atom substitution for formulas and proves that derivations
are preserved under atom substitution when the substituted atom is fresh.

## Main Definitions

- `Formula.subst`: Substitute atom q with atom r in a formula
- `Context.subst`: Apply substitution to all formulas in a context
- `atoms_of_context`: All atoms appearing in a context

## Main Results

- `subst_atoms`: Atoms of substituted formula
- `subst_fresh_eq`: Substituting a fresh atom leaves the formula unchanged
- `derivation_subst`: Derivations are preserved under atom substitution

## References

- Standard proof theory: substitution lemma for Hilbert calculi
-/

namespace Bimodal.Syntax

open Bimodal.Syntax.Formula

/-- Substitute atom `q` with atom `r` in a formula. -/
def Formula.subst (q r : Atom) : Formula → Formula
  | atom s => if s = q then atom r else atom s
  | bot => bot
  | imp φ ψ => imp (φ.subst q r) (ψ.subst q r)
  | box φ => box (φ.subst q r)
  | all_past φ => all_past (φ.subst q r)
  | all_future φ => all_future (φ.subst q r)

namespace Formula

/-!
## Structural lemmas for substitution
-/

@[simp]
theorem subst_atom_eq (q r : Atom) : (atom q).subst q r = atom r := by
  simp [subst]

@[simp]
theorem subst_atom_ne (q r s : Atom) (h : s ≠ q) : (atom s).subst q r = atom s := by
  simp [subst, h]

@[simp]
theorem subst_bot (q r : Atom) : bot.subst q r = bot := rfl

@[simp]
theorem subst_imp (q r : Atom) (φ ψ : Formula) :
    (imp φ ψ).subst q r = imp (φ.subst q r) (ψ.subst q r) := rfl

@[simp]
theorem subst_box (q r : Atom) (φ : Formula) :
    (box φ).subst q r = box (φ.subst q r) := rfl

@[simp]
theorem subst_all_past (q r : Atom) (φ : Formula) :
    (all_past φ).subst q r = all_past (φ.subst q r) := rfl

@[simp]
theorem subst_all_future (q r : Atom) (φ : Formula) :
    (all_future φ).subst q r = all_future (φ.subst q r) := rfl

/-!
## Derived operator substitution
-/

@[simp]
theorem subst_neg (q r : Atom) (φ : Formula) :
    (neg φ).subst q r = neg (φ.subst q r) := by
  simp [neg, subst]

@[simp]
theorem subst_and (q r : Atom) (φ ψ : Formula) :
    (Formula.and φ ψ).subst q r = Formula.and (φ.subst q r) (ψ.subst q r) := by
  simp only [Formula.and, neg, subst_imp, subst_bot]

@[simp]
theorem subst_or (q r : Atom) (φ ψ : Formula) :
    (Formula.or φ ψ).subst q r = Formula.or (φ.subst q r) (ψ.subst q r) := by
  simp only [Formula.or, neg, subst_imp, subst_bot]

@[simp]
theorem subst_diamond (q r : Atom) (φ : Formula) :
    (diamond φ).subst q r = diamond (φ.subst q r) := by
  simp only [diamond, neg, subst_imp, subst_bot, subst_box]

@[simp]
theorem subst_some_past (q r : Atom) (φ : Formula) :
    (some_past φ).subst q r = some_past (φ.subst q r) := by
  simp only [some_past, neg, subst_imp, subst_bot, subst_all_past]

@[simp]
theorem subst_some_future (q r : Atom) (φ : Formula) :
    (some_future φ).subst q r = some_future (φ.subst q r) := by
  simp only [some_future, neg, subst_imp, subst_bot, subst_all_future]

/-!
## Freshness and substitution
-/

/-- If q is not in the atoms of φ, substituting q with r leaves φ unchanged. -/
theorem subst_fresh_eq (q r : Atom) (φ : Formula) (h : q ∉ φ.atoms) :
    φ.subst q r = φ := by
  induction φ with
  | atom s =>
    simp only [atoms, Finset.mem_singleton] at h
    simp only [subst]
    simp only [if_neg (Ne.symm h)]
  | bot => rfl
  | imp φ ψ ih1 ih2 =>
    simp only [atoms, Finset.mem_union, not_or] at h
    simp [subst, ih1 h.1, ih2 h.2]
  | box φ ih =>
    simp only [atoms] at h
    simp [subst, ih h]
  | all_past φ ih =>
    simp only [atoms] at h
    simp [subst, ih h]
  | all_future φ ih =>
    simp only [atoms] at h
    simp [subst, ih h]

/-- Atoms of substituted formula: if q ∉ φ.atoms, then (φ.subst q r).atoms = φ.atoms.
    If q ∈ φ.atoms, then we replace q with r in the atom set. -/
theorem subst_atoms (q r : Atom) (φ : Formula) :
    (φ.subst q r).atoms = φ.atoms.image (fun a => if a = q then r else a) := by
  induction φ with
  | atom s =>
    simp only [subst, atoms]
    by_cases hs : s = q
    · simp only [hs, ↓reduceIte, atoms, Finset.image_singleton, ↓reduceIte]
    · simp only [if_neg hs, atoms, Finset.image_singleton]
  | bot => simp [subst, atoms, Finset.image_empty]
  | imp φ ψ ih1 ih2 =>
    simp only [subst, atoms, Finset.image_union, ih1, ih2]
  | box φ ih =>
    simp only [subst, atoms, ih]
  | all_past φ ih =>
    simp only [subst, atoms, ih]
  | all_future φ ih =>
    simp only [subst, atoms, ih]

end Formula

end Bimodal.Syntax

namespace Bimodal.ProofSystem

open Bimodal.Syntax
open Bimodal.Syntax.Formula

/-!
## Context substitution
-/

/-- Apply atom substitution to all formulas in a context. -/
def Context.subst (q r : Atom) (Γ : Context) : Context :=
  Γ.map (Formula.subst q r)

/-- All atoms appearing in formulas of a context. -/
def atoms_of_context (Γ : Context) : Finset Atom :=
  Γ.foldr (fun φ acc => φ.atoms ∪ acc) ∅

@[simp]
theorem atoms_of_context_nil : atoms_of_context [] = ∅ := rfl

@[simp]
theorem atoms_of_context_cons (φ : Formula) (Γ : Context) :
    atoms_of_context (φ :: Γ) = φ.atoms ∪ atoms_of_context Γ := rfl

theorem mem_atoms_of_context_iff {q : Atom} {Γ : Context} :
    q ∈ atoms_of_context Γ ↔ ∃ φ ∈ Γ, q ∈ φ.atoms := by
  induction Γ with
  | nil => simp [atoms_of_context]
  | cons hd tl ih =>
    simp only [atoms_of_context_cons, Finset.mem_union, ih, List.mem_cons]
    constructor
    · intro h
      cases h with
      | inl h => exact ⟨hd, Or.inl rfl, h⟩
      | inr h =>
        obtain ⟨φ, hφ, hq⟩ := h
        exact ⟨φ, Or.inr hφ, hq⟩
    · intro ⟨φ, hφ, hq⟩
      cases hφ with
      | inl h => left; subst h; exact hq
      | inr h => right; exact ⟨φ, h, hq⟩

/-- If q is not in atoms_of_context Γ, substituting q with r leaves Γ unchanged. -/
theorem context_subst_fresh_eq (q r : Atom) (Γ : Context) (h : q ∉ atoms_of_context Γ) :
    Context.subst q r Γ = Γ := by
  induction Γ with
  | nil => rfl
  | cons hd tl ih =>
    simp only [atoms_of_context_cons, Finset.mem_union, not_or] at h
    unfold Context.subst Context.map
    rw [List.map_cons, Formula.subst_fresh_eq q r hd h.1]
    unfold Context.subst Context.map at ih
    rw [ih h.2]

/-- Membership in substituted context. -/
theorem mem_context_subst_iff {q r : Atom} {φ : Formula} {Γ : Context} :
    φ ∈ Context.subst q r Γ ↔ ∃ ψ ∈ Γ, φ = ψ.subst q r := by
  unfold Context.subst
  constructor
  · intro h
    have h' := List.mem_map.mp h
    obtain ⟨ψ, hψ, heq⟩ := h'
    exact ⟨ψ, hψ, heq.symm⟩
  · intro ⟨ψ, hψ, heq⟩
    apply List.mem_map.mpr
    exact ⟨ψ, hψ, heq.symm⟩

/-!
## Axiom substitution

We need to show that axiom instances are preserved under atom substitution.
-/

/-- Axiom instances are preserved under atom substitution. -/
def axiom_subst (q r : Atom) {φ : Formula} (h : Axiom φ) : Axiom (φ.subst q r) := by
  cases h with
  | prop_k a b c =>
    simp only [subst_imp]
    exact Axiom.prop_k (a.subst q r) (b.subst q r) (c.subst q r)
  | prop_s a b =>
    simp only [subst_imp]
    exact Axiom.prop_s (a.subst q r) (b.subst q r)
  | modal_t a =>
    simp only [subst_imp, subst_box]
    exact Axiom.modal_t (a.subst q r)
  | modal_4 a =>
    simp only [subst_imp, subst_box]
    exact Axiom.modal_4 (a.subst q r)
  | modal_b a =>
    simp only [subst_imp, subst_box, subst_diamond]
    exact Axiom.modal_b (a.subst q r)
  | modal_5_collapse a =>
    simp only [subst_imp, subst_box, subst_diamond]
    exact Axiom.modal_5_collapse (a.subst q r)
  | ex_falso a =>
    simp only [subst_imp, subst_bot]
    exact Axiom.ex_falso (a.subst q r)
  | peirce a b =>
    simp only [subst_imp]
    exact Axiom.peirce (a.subst q r) (b.subst q r)
  | modal_k_dist a b =>
    simp only [subst_imp, subst_box]
    exact Axiom.modal_k_dist (a.subst q r) (b.subst q r)
  | temp_k_dist a b =>
    simp only [subst_imp, subst_all_future]
    exact Axiom.temp_k_dist (a.subst q r) (b.subst q r)
  | temp_4 a =>
    simp only [subst_imp, subst_all_future]
    exact Axiom.temp_4 (a.subst q r)
  | temp_a a =>
    simp only [subst_imp, subst_all_future, subst_some_past]
    exact Axiom.temp_a (a.subst q r)
  | temp_l a =>
    -- always = H a ∧ (a ∧ G a)
    -- We need to unfold always and show substitution preserves the structure
    simp only [subst_imp, subst_all_future, subst_all_past]
    -- temp_l takes always a which is (a.all_past.and (a.and a.all_future))
    have h1 : (Formula.always a).subst q r = Formula.always (a.subst q r) := by
      simp only [Formula.always, subst_and, subst_all_past, subst_all_future]
    rw [h1]
    exact Axiom.temp_l (a.subst q r)
  | temp_t_future a =>
    simp only [subst_imp, subst_all_future]
    exact Axiom.temp_t_future (a.subst q r)
  | temp_t_past a =>
    simp only [subst_imp, subst_all_past]
    exact Axiom.temp_t_past (a.subst q r)
  | modal_future a =>
    simp only [subst_imp, subst_box, subst_all_future]
    exact Axiom.modal_future (a.subst q r)
  | temp_future a =>
    simp only [subst_imp, subst_box, subst_all_future]
    exact Axiom.temp_future (a.subst q r)
  | temp_linearity a b =>
    simp only [subst_imp, subst_and, subst_or, subst_some_future]
    exact Axiom.temp_linearity (a.subst q r) (b.subst q r)
  | density a =>
    simp only [subst_imp, subst_all_future]
    exact Axiom.density (a.subst q r)
  | discreteness_forward a =>
    -- discreteness_forward is: (F(¬⊥) ∧ (a ∧ Ha)) → F(Ha)
    -- Note: bot.neg = bot → bot, which doesn't mention any atoms
    simp only [subst_imp, subst_and, subst_some_future, subst_all_past]
    have h : (Formula.bot.neg).subst q r = Formula.bot.neg := by
      simp only [subst_neg, subst_bot]
    simp only [h]
    exact Axiom.discreteness_forward (a.subst q r)
  | seriality_future a =>
    simp only [subst_imp, subst_all_future, subst_some_future]
    exact Axiom.seriality_future (a.subst q r)
  | seriality_past a =>
    simp only [subst_imp, subst_all_past, subst_some_past]
    exact Axiom.seriality_past (a.subst q r)

/-!
## Main theorem: derivation substitution

Derivations are preserved under atom substitution.
-/

/-- swap_temporal commutes with substitution. -/
theorem swap_temporal_subst (q r : Atom) (φ : Formula) :
    (φ.swap_temporal).subst q r = (φ.subst q r).swap_temporal := by
  induction φ with
  | atom s =>
    simp only [swap_temporal, subst]
    by_cases hs : s = q <;> simp [hs, swap_temporal]
  | bot => simp [swap_temporal, subst]
  | imp a b iha ihb => simp [swap_temporal, subst, iha, ihb]
  | box a ih => simp [swap_temporal, subst, ih]
  | all_past a ih => simp [swap_temporal, subst, ih]
  | all_future a ih => simp [swap_temporal, subst, ih]

/-- Derivations are preserved under atom substitution.

If `Γ ⊢ φ`, then `Γ.subst q r ⊢ φ.subst q r`.
-/
def derivation_subst (q r : Atom) : {Γ : Context} → {φ : Formula} →
    DerivationTree Γ φ → DerivationTree (Context.subst q r Γ) (φ.subst q r)
  | Γ, φ, DerivationTree.axiom _ _ h =>
    DerivationTree.axiom (Context.subst q r Γ) (φ.subst q r) (axiom_subst q r h)
  | Γ, φ, DerivationTree.assumption _ _ h => by
    apply DerivationTree.assumption
    rw [mem_context_subst_iff]
    exact ⟨φ, h, rfl⟩
  | Γ, _, DerivationTree.modus_ponens _ ψ χ d1 d2 => by
    have d1' := derivation_subst q r d1
    have d2' := derivation_subst q r d2
    simp only [subst_imp] at d1'
    exact DerivationTree.modus_ponens _ _ _ d1' d2'
  | _, _, DerivationTree.necessitation ψ d => by
    have d' := derivation_subst q r d
    simp only [Context.subst, Context.map] at d'
    simp only [List.map_nil] at d'
    simp only [subst_box]
    exact DerivationTree.necessitation (ψ.subst q r) d'
  | _, _, DerivationTree.temporal_necessitation ψ d => by
    have d' := derivation_subst q r d
    simp only [Context.subst, Context.map] at d'
    simp only [List.map_nil] at d'
    simp only [subst_all_future]
    exact DerivationTree.temporal_necessitation (ψ.subst q r) d'
  | _, _, DerivationTree.temporal_duality ψ d => by
    have d' := derivation_subst q r d
    simp only [Context.subst, Context.map] at d'
    simp only [List.map_nil] at d'
    rw [swap_temporal_subst]
    exact DerivationTree.temporal_duality (ψ.subst q r) d'
  | Γ, φ, DerivationTree.weakening Γ' _ _ d h => by
    have d' := derivation_subst q r d
    apply DerivationTree.weakening (Context.subst q r Γ') _ _ d'
    intro ψ hψ
    rw [mem_context_subst_iff] at hψ ⊢
    obtain ⟨χ, hχ, heq⟩ := hψ
    exact ⟨χ, h hχ, heq⟩

end Bimodal.ProofSystem
