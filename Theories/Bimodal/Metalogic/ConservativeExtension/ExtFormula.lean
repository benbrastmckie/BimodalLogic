import Bimodal.Syntax.Formula
import Mathlib.Tactic.DeriveCountable
import Mathlib.Data.Countable.Basic

/-!
# Extended Formula Type for Conservative Extension

This module defines the extended formula type `ExtFormula` with atoms `ExtAtom := String ⊕ Unit`.
The key property is that the fresh atom `Sum.inr ()` does not appear in any embedded
formula from the original language, enabling the standard Goldblatt/BdRV naming argument.

## Main Definitions

- `ExtAtom`: Extended atom type `String ⊕ Unit`
- `ExtFormula`: Formula type over `ExtAtom`
- `embedAtom`: Embedding `String → ExtAtom` via `Sum.inl`
- `embedFormula`: Structural embedding `Formula → ExtFormula`

## Main Results

- `embedFormula_injective`: The embedding is injective
- `fresh_not_in_embedFormula_atoms`: `Sum.inr () ∉ (embedFormula φ).atoms` for all φ

## References

- Task 958 research-005.md: Conservative extension implementation guide
- Goldblatt 1992, Logics of Time and Computation
-/

namespace Bimodal.Metalogic.ConservativeExtension

open Bimodal.Syntax

/-- Extended atom type: original String atoms plus one fresh Unit atom. -/
abbrev ExtAtom := String ⊕ Unit

instance : Hashable ExtAtom where
  hash
    | Sum.inl s => mixHash 0 (hash s)
    | Sum.inr () => mixHash 1 0

/-- The fresh atom not appearing in any embedded formula. -/
def freshAtom : ExtAtom := Sum.inr ()

/--
Extended formula type mirroring `Formula` but with `ExtAtom` atoms.
-/
inductive ExtFormula : Type where
  | atom : ExtAtom → ExtFormula
  | bot : ExtFormula
  | imp : ExtFormula → ExtFormula → ExtFormula
  | box : ExtFormula → ExtFormula
  | all_past : ExtFormula → ExtFormula
  | all_future : ExtFormula → ExtFormula
  deriving Repr, DecidableEq, BEq, Hashable, Countable

namespace ExtFormula

/-- Negation: ¬φ := φ → ⊥ -/
def neg (φ : ExtFormula) : ExtFormula := φ.imp bot

/-- Conjunction: φ ∧ ψ := ¬(φ → ¬ψ) -/
def and (φ ψ : ExtFormula) : ExtFormula := (φ.imp ψ.neg).neg

/-- Disjunction: φ ∨ ψ := ¬φ → ψ -/
def or (φ ψ : ExtFormula) : ExtFormula := φ.neg.imp ψ

/-- Modal diamond: ◇φ := ¬□¬φ -/
def diamond (φ : ExtFormula) : ExtFormula := φ.neg.box.neg

/-- Existential past: Pφ := ¬H¬φ -/
def some_past (φ : ExtFormula) : ExtFormula := φ.neg.all_past.neg

/-- Existential future: Fφ := ¬G¬φ -/
def some_future (φ : ExtFormula) : ExtFormula := φ.neg.all_future.neg

/-- Always: △φ := Hφ ∧ φ ∧ Gφ -/
def always (φ : ExtFormula) : ExtFormula := φ.all_past.and (φ.and φ.all_future)

/-- Sometimes: ▽φ := ¬△¬φ -/
def sometimes (φ : ExtFormula) : ExtFormula := φ.neg.always.neg

/-- Swap temporal operators (past ↔ future). -/
def swap_temporal : ExtFormula → ExtFormula
  | atom s => atom s
  | bot => bot
  | imp φ ψ => imp φ.swap_temporal ψ.swap_temporal
  | box φ => box φ.swap_temporal
  | all_past φ => all_future φ.swap_temporal
  | all_future φ => all_past φ.swap_temporal

/-- The set of atoms appearing in an extended formula. -/
def atoms : ExtFormula → Finset ExtAtom
  | atom s => {s}
  | bot => ∅
  | imp φ ψ => φ.atoms ∪ ψ.atoms
  | box φ => φ.atoms
  | all_past φ => φ.atoms
  | all_future φ => φ.atoms

/-- Structural complexity measure. -/
def complexity : ExtFormula → Nat
  | atom _ => 1
  | bot => 1
  | imp φ ψ => 1 + φ.complexity + ψ.complexity
  | box φ => 1 + φ.complexity
  | all_past φ => 1 + φ.complexity
  | all_future φ => 1 + φ.complexity

end ExtFormula

/-!
## Embedding Functions
-/

/-- Embed a String atom into ExtAtom. -/
def embedAtom : String → ExtAtom := Sum.inl

/-- Embed a Formula (String atoms) into ExtFormula (ExtAtom atoms). -/
def embedFormula : Formula → ExtFormula
  | Formula.atom s => ExtFormula.atom (embedAtom s)
  | Formula.bot => ExtFormula.bot
  | Formula.imp φ ψ => ExtFormula.imp (embedFormula φ) (embedFormula ψ)
  | Formula.box φ => ExtFormula.box (embedFormula φ)
  | Formula.all_past φ => ExtFormula.all_past (embedFormula φ)
  | Formula.all_future φ => ExtFormula.all_future (embedFormula φ)

/-!
## Embedding Preservation Lemmas

All derived operators are defined identically, so embedding commutes with them by `rfl`.
-/

@[simp]
theorem embedFormula_neg (φ : Formula) :
    embedFormula (Formula.neg φ) = ExtFormula.neg (embedFormula φ) := rfl

@[simp]
theorem embedFormula_and (φ ψ : Formula) :
    embedFormula (Formula.and φ ψ) = ExtFormula.and (embedFormula φ) (embedFormula ψ) := rfl

@[simp]
theorem embedFormula_or (φ ψ : Formula) :
    embedFormula (Formula.or φ ψ) = ExtFormula.or (embedFormula φ) (embedFormula ψ) := rfl

@[simp]
theorem embedFormula_imp (φ ψ : Formula) :
    embedFormula (Formula.imp φ ψ) = ExtFormula.imp (embedFormula φ) (embedFormula ψ) := rfl

@[simp]
theorem embedFormula_box (φ : Formula) :
    embedFormula (Formula.box φ) = ExtFormula.box (embedFormula φ) := rfl

@[simp]
theorem embedFormula_all_past (φ : Formula) :
    embedFormula (Formula.all_past φ) = ExtFormula.all_past (embedFormula φ) := rfl

@[simp]
theorem embedFormula_all_future (φ : Formula) :
    embedFormula (Formula.all_future φ) = ExtFormula.all_future (embedFormula φ) := rfl

@[simp]
theorem embedFormula_diamond (φ : Formula) :
    embedFormula (Formula.diamond φ) = ExtFormula.diamond (embedFormula φ) := rfl

@[simp]
theorem embedFormula_some_past (φ : Formula) :
    embedFormula (Formula.some_past φ) = ExtFormula.some_past (embedFormula φ) := rfl

@[simp]
theorem embedFormula_some_future (φ : Formula) :
    embedFormula (Formula.some_future φ) = ExtFormula.some_future (embedFormula φ) := rfl

@[simp]
theorem embedFormula_always (φ : Formula) :
    embedFormula (Formula.always φ) = ExtFormula.always (embedFormula φ) := rfl

@[simp]
theorem embedFormula_swap_temporal (φ : Formula) :
    embedFormula (Formula.swap_temporal φ) = ExtFormula.swap_temporal (embedFormula φ) := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp _ _ ih1 ih2 => simp [Formula.swap_temporal, ExtFormula.swap_temporal, embedFormula, ih1, ih2]
  | box _ ih => simp [Formula.swap_temporal, ExtFormula.swap_temporal, embedFormula, ih]
  | all_past _ ih => simp [Formula.swap_temporal, ExtFormula.swap_temporal, embedFormula, ih]
  | all_future _ ih => simp [Formula.swap_temporal, ExtFormula.swap_temporal, embedFormula, ih]

/-!
## Injectivity
-/

theorem embedAtom_injective : Function.Injective embedAtom := Sum.inl_injective

theorem embedFormula_injective : Function.Injective embedFormula := by
  intro φ ψ h
  induction φ generalizing ψ with
  | atom s =>
    cases ψ with
    | atom t => simp [embedFormula, embedAtom] at h; exact congrArg Formula.atom h
    | bot => simp [embedFormula] at h
    | imp _ _ => simp [embedFormula] at h
    | box _ => simp [embedFormula] at h
    | all_past _ => simp [embedFormula] at h
    | all_future _ => simp [embedFormula] at h
  | bot =>
    cases ψ with
    | bot => rfl
    | atom _ => simp [embedFormula] at h
    | imp _ _ => simp [embedFormula] at h
    | box _ => simp [embedFormula] at h
    | all_past _ => simp [embedFormula] at h
    | all_future _ => simp [embedFormula] at h
  | imp a b iha ihb =>
    cases ψ with
    | imp c d =>
      simp [embedFormula] at h
      exact congrArg₂ Formula.imp (iha h.1) (ihb h.2)
    | atom _ => simp [embedFormula] at h
    | bot => simp [embedFormula] at h
    | box _ => simp [embedFormula] at h
    | all_past _ => simp [embedFormula] at h
    | all_future _ => simp [embedFormula] at h
  | box a ih =>
    cases ψ with
    | box c => simp [embedFormula] at h; exact congrArg Formula.box (ih h)
    | atom _ => simp [embedFormula] at h
    | bot => simp [embedFormula] at h
    | imp _ _ => simp [embedFormula] at h
    | all_past _ => simp [embedFormula] at h
    | all_future _ => simp [embedFormula] at h
  | all_past a ih =>
    cases ψ with
    | all_past c => simp [embedFormula] at h; exact congrArg Formula.all_past (ih h)
    | atom _ => simp [embedFormula] at h
    | bot => simp [embedFormula] at h
    | imp _ _ => simp [embedFormula] at h
    | box _ => simp [embedFormula] at h
    | all_future _ => simp [embedFormula] at h
  | all_future a ih =>
    cases ψ with
    | all_future c => simp [embedFormula] at h; exact congrArg Formula.all_future (ih h)
    | atom _ => simp [embedFormula] at h
    | bot => simp [embedFormula] at h
    | imp _ _ => simp [embedFormula] at h
    | box _ => simp [embedFormula] at h
    | all_past _ => simp [embedFormula] at h

/-!
## Freshness: The Critical Lemma

`Sum.inr ()` does not appear in any embedded formula. This is because `embedFormula`
maps atoms via `Sum.inl`, and `Sum.inr () ≠ Sum.inl s` for any `s`.
-/

theorem fresh_not_in_embedFormula_atoms (φ : Formula) :
    freshAtom ∉ (embedFormula φ).atoms := by
  induction φ with
  | atom s =>
    simp [embedFormula, ExtFormula.atoms, embedAtom, freshAtom]
  | bot =>
    simp [embedFormula, ExtFormula.atoms]
  | imp a b iha ihb =>
    simp [embedFormula, ExtFormula.atoms, Finset.mem_union]
    exact ⟨iha, ihb⟩
  | box a ih =>
    simp [embedFormula, ExtFormula.atoms]
    exact ih
  | all_past a ih =>
    simp [embedFormula, ExtFormula.atoms]
    exact ih
  | all_future a ih =>
    simp [embedFormula, ExtFormula.atoms]
    exact ih

/-- Variant: all atoms in an embedded formula are of the form Sum.inl. -/
theorem embedFormula_atoms_subset_inl (φ : Formula) :
    ∀ a ∈ (embedFormula φ).atoms, ∃ s : String, a = Sum.inl s := by
  induction φ with
  | atom s =>
    intro a ha
    simp [embedFormula, ExtFormula.atoms, embedAtom] at ha
    exact ⟨s, ha⟩
  | bot =>
    intro a ha
    simp [embedFormula, ExtFormula.atoms] at ha
  | imp a b iha ihb =>
    intro x hx
    simp [embedFormula, ExtFormula.atoms, Finset.mem_union] at hx
    cases hx with
    | inl h => exact iha x h
    | inr h => exact ihb x h
  | box a ih =>
    intro x hx
    simp [embedFormula, ExtFormula.atoms] at hx
    exact ih x hx
  | all_past a ih =>
    intro x hx
    simp [embedFormula, ExtFormula.atoms] at hx
    exact ih x hx
  | all_future a ih =>
    intro x hx
    simp [embedFormula, ExtFormula.atoms] at hx
    exact ih x hx

/-- Key lemma for IRR embedding: atom membership is preserved under embedding. -/
theorem embedAtom_mem_embedFormula_atoms_iff (p : String) (φ : Formula) :
    embedAtom p ∈ (embedFormula φ).atoms ↔ p ∈ φ.atoms := by
  induction φ with
  | atom s =>
    simp [embedFormula, ExtFormula.atoms, embedAtom, Formula.atoms]
  | bot =>
    simp [embedFormula, ExtFormula.atoms, Formula.atoms]
  | imp a b iha ihb =>
    simp [embedFormula, ExtFormula.atoms, Formula.atoms, Finset.mem_union, iha, ihb]
  | box a ih =>
    simp [embedFormula, ExtFormula.atoms, Formula.atoms, ih]
  | all_past a ih =>
    simp [embedFormula, ExtFormula.atoms, Formula.atoms, ih]
  | all_future a ih =>
    simp [embedFormula, ExtFormula.atoms, Formula.atoms, ih]

/-- Corollary: freshAtom is not in atoms of any formula in an embedded set. -/
theorem fresh_not_in_embedded_set_atoms (S : Set Formula) (ψ : ExtFormula) (h : ψ ∈ embedFormula '' S) :
    freshAtom ∉ ψ.atoms := by
  obtain ⟨φ, _, rfl⟩ := h
  exact fresh_not_in_embedFormula_atoms φ

end Bimodal.Metalogic.ConservativeExtension
