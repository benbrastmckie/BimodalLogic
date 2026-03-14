import Mathlib.Data.Finset.Basic
import Mathlib.Data.Fintype.EquivFin
import Mathlib.Data.Countable.Basic
import Mathlib.Tactic.DeriveCountable
import Mathlib.Logic.Equiv.Basic
import Mathlib.Logic.Equiv.List

/-!
# Atom Type for Bimodal Logic TM

This module defines the `Atom` type for propositional atoms in the bimodal logic TM.
The key innovation over plain `String` atoms is **freshness**: for any finite set of
atoms, there exists an atom not in the set.

## Main Definitions

- `Atom`: Structure with `base : String` and `fresh_index : Option Nat`
- `Atom.mk_base`: Create a base atom from a string (no fresh index)
- `Atom.mk_fresh`: Create a fresh atom with the given base and index

## Main Results

- `Countable Atom`: Atoms are countable (required for Lindenbaum extension)
- `Infinite Atom`: There are infinitely many atoms (enables freshness)
- `Atom.exists_fresh`: For any `Finset Atom`, there exists an atom not in it

## Design Rationale

The `Option Nat` fresh index provides infinitely many atoms for any base string:
- `{ base := "p", fresh_index := none }` is the "ordinary" atom p
- `{ base := "p", fresh_index := some n }` is the fresh variant p_n

This enables the Gabbay IRR (Irreflexivity Rule) proof: given any MCS M with
finitely many atoms in `GContent(M)`, we can find a fresh atom not mentioned.

## References

- Task 964: Resolve atom type freshness debt
- Goldblatt (1992), Logics of Time and Computation
- Blackburn, de Rijke, Venema (2001), Modal Logic
-/

namespace Bimodal.Syntax

/-!
## Countability Prerequisites

We need `Countable Char` and `Countable String` instances for Atom's Countable instance.
These are duplicated from Formula.lean to avoid circular imports.
-/

/-- Char is countable via injection into Nat. -/
instance : Countable Char := by
  have h : Function.Injective Char.toNat := by
    intro c1 c2 heq
    rw [← Char.ofNat_toNat c1, ← Char.ofNat_toNat c2, heq]
  exact Function.Injective.countable h

/-- String is countable via injection into List Char. -/
instance : Countable String := by
  have h : Function.Injective String.toList := fun _ _ => String.toList_injective
  exact Function.Injective.countable h

/--
Atom type for propositional variables with freshness support.

Each atom has a base string and an optional natural number index.
The index enables creating infinitely many distinct atoms for any base.
-/
structure Atom where
  /-- The base name of the atom (e.g., "p", "q") -/
  base : String
  /-- Optional fresh index: `none` for ordinary atoms, `some n` for fresh variants -/
  fresh_index : Option Nat
  deriving Repr, DecidableEq, BEq, Hashable

/-!
## BEq instances for Atom

We need ReflBEq and LawfulBEq instances for Atom to enable Formula's LawfulBEq.
-/

/-- BEq on Atom is reflexive. -/
theorem Atom.beq_refl (a : Atom) : (a == a) = true := by
  cases a with
  | mk base idx =>
    show (base == base && idx == idx) = true
    simp only [beq_self_eq_true, Bool.and_self]

instance : ReflBEq Atom where
  rfl := Atom.beq_refl _

/-- BEq on Atom is injective: if `a == b = true` then `a = b`. -/
theorem Atom.eq_of_beq {a b : Atom} (h : (a == b) = true) : a = b := by
  cases a with
  | mk base1 idx1 =>
    cases b with
    | mk base2 idx2 =>
      change (base1 == base2 && idx1 == idx2) = true at h
      simp only [Bool.and_eq_true] at h
      have hbase : base1 = base2 := beq_iff_eq.mp h.1
      have hidx : idx1 = idx2 := beq_iff_eq.mp h.2
      simp [hbase, hidx]

instance : LawfulBEq Atom where
  eq_of_beq := Atom.eq_of_beq
  rfl := Atom.beq_refl _

namespace Atom

/-- Create a base atom from a string (no fresh index). -/
def mk_base (s : String) : Atom := ⟨s, none⟩

/-- Create a fresh atom with the given base and index. -/
def mk_fresh (s : String) (n : Nat) : Atom := ⟨s, some n⟩

/-- The empty-string base atom, useful as a canonical fresh source. -/
def fresh_base : Atom := mk_fresh "" 0

/-- Two atoms with the same base but different indices are distinct. -/
theorem mk_fresh_injective (s : String) : Function.Injective (mk_fresh s) := by
  intro n m h
  simp only [mk_fresh, Atom.mk.injEq] at h
  exact Option.some_injective _ h.2

/-- Base atoms with different strings are distinct. -/
theorem mk_base_injective : Function.Injective mk_base := by
  intro s t h
  simp only [mk_base, Atom.mk.injEq] at h
  exact h.1

/-- mk_base and mk_fresh produce different atoms. -/
theorem mk_base_ne_mk_fresh (s t : String) (n : Nat) : mk_base s ≠ mk_fresh t n := by
  intro h
  simp only [mk_base, mk_fresh, Atom.mk.injEq] at h
  cases h.2

end Atom

/-!
## Countability

Atom is countable because it's equivalent to `String × Option Nat`,
and both `String` and `Option Nat` are countable.
-/

/-- Equivalence between Atom and String × Option Nat. -/
def atomEquiv : Atom ≃ String × Option Nat where
  toFun a := (a.base, a.fresh_index)
  invFun p := ⟨p.1, p.2⟩
  left_inv a := by cases a; rfl
  right_inv p := by cases p; rfl

/-- Nat is countable (should already exist, but ensure it's available). -/
instance : Countable Nat := inferInstance

/-- Option Nat is countable. -/
instance : Countable (Option Nat) := inferInstance

/-- String × Option Nat is countable. -/
instance : Countable (String × Option Nat) := inferInstance

/-- Atom is countable via equivalence with String × Option Nat. -/
instance : Countable Atom := Countable.of_equiv _ atomEquiv.symm

/-!
## Infinity

Atom is infinite because we can inject Nat into it via fresh indices.
-/

/-- Injection from Nat to Atom via fresh indices with empty base. -/
def natToAtom (n : Nat) : Atom := Atom.mk_fresh "" n

/-- The injection is indeed injective. -/
theorem natToAtom_injective : Function.Injective natToAtom := by
  intro n m h
  simp only [natToAtom, Atom.mk_fresh, Atom.mk.injEq] at h
  exact Option.some_injective _ h.2

/-- Atom is infinite via injection from Nat. -/
instance : Infinite Atom := Infinite.of_injective natToAtom natToAtom_injective

/-!
## Freshness

The key property: for any finite set of atoms, there exists an atom not in it.
This is an immediate consequence of `Infinite.exists_notMem_finset`.
-/

/-- For any finite set of atoms, there exists an atom not in the set.
This is the key freshness property enabling the Gabbay IRR proof. -/
theorem Atom.exists_fresh (S : Finset Atom) : ∃ a : Atom, a ∉ S :=
  Infinite.exists_notMem_finset S

/-- Alternative formulation using natural language. -/
theorem Atom.freshness (S : Finset Atom) : ∃ a : Atom, a ∉ S :=
  Atom.exists_fresh S

/-- Given a finite set of atoms, construct a specific fresh atom.
Uses the maximum fresh index + 1 with empty base. -/
noncomputable def Atom.fresh_for (S : Finset Atom) : Atom :=
  Classical.choose (Atom.exists_fresh S)

/-- The atom returned by `fresh_for` is indeed not in the set. -/
theorem Atom.fresh_for_not_mem (S : Finset Atom) : Atom.fresh_for S ∉ S :=
  Classical.choose_spec (Atom.exists_fresh S)

end Bimodal.Syntax
