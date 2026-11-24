/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.Formula
import FormalSystem.PlusLanguage.Formula

/-!
# Fragments of the bimodal languages

A library entry is filed by the operators that occur in its statement. This module computes
that filing for both formula types.

## Main definitions

* `BimodalLib.Family`: the operator families over the Boolean base, Modal and Temporal.
* `BimodalLib.Fragment`: the four fragments, each a set of families.
* `BimodalLib.Profile`: which primitive operators occur in a formula. It records `□` and `⊡`
  separately, so it carries the modal operator set as well as the fragment.
* `BimodalLib.profileF`, `BimodalLib.profileP`: the profile of a `Formula` and of a
  `PlusFormula`, by recursion on the primitives. A defined operator is counted through its
  definition, because it unfolds to primitives.
* `BimodalLib.Profile.fragment`: the fragment of a profile. Both `□` and `⊡` put a formula in
  the Modal family.
* `BimodalLib.SubstClass`: whether a statement is schematic in its variables or restricted.

## Main statements

* `BimodalLib.profileP_ofFormula`: the two computations agree on the embedding of `Formula`
  into `PlusFormula`.
-/

namespace BimodalLib

open FormalSystem.Syntax FormalSystem.PlusLanguage

/-- The operator families over the Boolean base. -/
inductive Family
  /-- The necessity operators over histories: `□`, and `⊡` in the extended language. -/
  | Modal
  /-- Until, Since and the operators defined from them. -/
  | Temporal
  deriving DecidableEq, Repr

/-- The four fragments. A fragment is a set of families; the Boolean base is in each. -/
inductive Fragment
  /-- No operator family: the propositional language. -/
  | Boolean
  /-- The Modal family alone. -/
  | ModalBoolean
  /-- The Temporal family alone. -/
  | TemporalBoolean
  /-- Both families. -/
  | ModalTemporalBoolean
  deriving DecidableEq, Repr

/-- The families a fragment contains. -/
def Fragment.families : Fragment → List Family
  | .Boolean => []
  | .ModalBoolean => [.Modal]
  | .TemporalBoolean => [.Temporal]
  | .ModalTemporalBoolean => [.Modal, .Temporal]

/-- The name of a fragment, which is also the name of its directory. -/
def Fragment.name : Fragment → String
  | .Boolean => "Boolean"
  | .ModalBoolean => "ModalBoolean"
  | .TemporalBoolean => "TemporalBoolean"
  | .ModalTemporalBoolean => "ModalTemporalBoolean"

/-- Which primitive operators occur in a formula. The fields `box` and `stab` together are the
modal operator set of the formula. -/
structure Profile where
  /-- `□` occurs. -/
  box : Bool := false
  /-- `⊡` occurs. -/
  stab : Bool := false
  /-- Until or Since occurs. -/
  temporal : Bool := false
  deriving DecidableEq, Repr

/-- The profile of a formula built from two parts. -/
def Profile.join (a b : Profile) : Profile :=
  ⟨a.box || b.box, a.stab || b.stab, a.temporal || b.temporal⟩

/-- Inclusion of profiles: every operator of `a` occurs in `b`. -/
def Profile.le (a b : Profile) : Bool :=
  (!a.box || b.box) && (!a.stab || b.stab) && (!a.temporal || b.temporal)

/-- Profiles are ordered by inclusion. -/
instance : LE Profile := ⟨fun a b => a.le b = true⟩

/-- Inclusion of profiles is decidable. -/
instance (a b : Profile) : Decidable (a ≤ b) := inferInstanceAs (Decidable (a.le b = true))

/-- The fragment of a profile. `□` and `⊡` both belong to the Modal family. -/
def Profile.fragment (p : Profile) : Fragment :=
  match p.box || p.stab, p.temporal with
  | false, false => .Boolean
  | true, false => .ModalBoolean
  | false, true => .TemporalBoolean
  | true, true => .ModalTemporalBoolean

/-- The modal operator set of a profile, as text: none, `□`, `⊡`, or both. -/
def Profile.opsName (p : Profile) : String :=
  match p.box, p.stab with
  | false, false => "none"
  | true, false => "□"
  | false, true => "⊡"
  | true, true => "□, ⊡"

/-- The profile of a formula of the base language. -/
def profileF : Formula → Profile
  | .atom _ => {}
  | .bot => {}
  | .imp φ ψ => (profileF φ).join (profileF ψ)
  | .box φ => { profileF φ with box := true }
  | .untl φ ψ => { (profileF φ).join (profileF ψ) with temporal := true }
  | .snce φ ψ => { (profileF φ).join (profileF ψ) with temporal := true }

/-- The profile of a formula of the extended language. -/
def profileP : PlusFormula → Profile
  | .atom _ => {}
  | .bot => {}
  | .imp φ ψ => (profileP φ).join (profileP ψ)
  | .box φ => { profileP φ with box := true }
  | .untl φ ψ => { (profileP φ).join (profileP ψ) with temporal := true }
  | .snce φ ψ => { (profileP φ).join (profileP ψ) with temporal := true }
  | .stab φ => { profileP φ with stab := true }

/-- Inclusion of profiles, field by field. -/
theorem Profile.le_iff (a b : Profile) :
    a ≤ b ↔ (a.box = true → b.box = true) ∧ (a.stab = true → b.stab = true) ∧
      (a.temporal = true → b.temporal = true) := by
  obtain ⟨_ | _, _ | _, _ | _⟩ := a <;> obtain ⟨_ | _, _ | _, _ | _⟩ := b <;>
    simp [LE.le, Profile.le]

/-- Inclusion of profiles is reflexive. -/
@[simp] theorem Profile.le_refl (a : Profile) : a ≤ a := by
  simp [Profile.le_iff]

/-- Inclusion of profiles is transitive. -/
theorem Profile.le_trans {a b c : Profile} (h1 : a ≤ b) (h2 : b ≤ c) : a ≤ c := by
  rw [Profile.le_iff] at *
  exact ⟨fun h => h2.1 (h1.1 h), fun h => h2.2.1 (h1.2.1 h), fun h => h2.2.2 (h1.2.2 h)⟩

/-- A join is included in a profile exactly when both parts are. -/
@[simp] theorem Profile.join_le_iff {a b c : Profile} : a.join b ≤ c ↔ a ≤ c ∧ b ≤ c := by
  simp only [Profile.le_iff, Profile.join, Bool.or_eq_true]
  exact ⟨fun h => ⟨⟨fun x => h.1 (Or.inl x), fun x => h.2.1 (Or.inl x), fun x => h.2.2 (Or.inl x)⟩,
    ⟨fun x => h.1 (Or.inr x), fun x => h.2.1 (Or.inr x), fun x => h.2.2 (Or.inr x)⟩⟩,
    fun h => ⟨fun x => x.elim h.1.1 h.2.1, fun x => x.elim h.1.2.1 h.2.2.1,
      fun x => x.elim h.1.2.2 h.2.2.2⟩⟩

/-- The profile of an atom is empty. -/
@[simp] theorem profileF_atom (a : Atom) : profileF (.atom a) = {} := rfl

/-- The profile of falsum is empty. -/
@[simp] theorem profileF_bot : profileF .bot = {} := rfl

/-- The empty profile is included in every profile. -/
@[simp] theorem Profile.empty_le (c : Profile) : ({} : Profile) ≤ c := by
  simp [Profile.le_iff]

/-- The profile of an implication is the join of the profiles of its parts. -/
@[simp] theorem profileF_imp (φ ψ : Formula) :
    profileF (φ.imp ψ) = (profileF φ).join (profileF ψ) := rfl

/-- The profile of an implication is included in a cell exactly when those of its parts are. -/
theorem profileF_imp_le_iff (φ ψ : Formula) (c : Profile) :
    profileF (φ.imp ψ) ≤ c ↔ profileF φ ≤ c ∧ profileF ψ ≤ c := by
  simp

/-- The profile of `□φ` is included in a cell exactly when the cell has `□` and includes the
profile of `φ`. -/
theorem profileF_box_le_iff (φ : Formula) (c : Profile) :
    profileF φ.box ≤ c ↔ c.box = true ∧ profileF φ ≤ c := by
  simp only [profileF, Profile.le_iff]
  exact ⟨fun h => ⟨h.1 trivial, fun _ => h.1 trivial, h.2.1, h.2.2⟩,
    fun h => ⟨fun _ => h.1, h.2.2.1, h.2.2.2⟩⟩

/-- The profile of an Until formula is included in a cell exactly when the cell has the temporal
operators and includes the profiles of both arguments. -/
theorem profileF_untl_le_iff (φ ψ : Formula) (c : Profile) :
    profileF (φ.untl ψ) ≤ c ↔ c.temporal = true ∧ profileF φ ≤ c ∧ profileF ψ ≤ c := by
  rw [← Profile.join_le_iff]
  simp only [profileF, Profile.le_iff]
  exact ⟨fun h => ⟨h.2.2 trivial, h.1, h.2.1, fun _ => h.2.2 trivial⟩,
    fun h => ⟨h.2.1, h.2.2.1, fun _ => h.1⟩⟩

/-- The profile of a Since formula is included in a cell exactly when the cell has the temporal
operators and includes the profiles of both arguments. -/
theorem profileF_snce_le_iff (φ ψ : Formula) (c : Profile) :
    profileF (φ.snce ψ) ≤ c ↔ c.temporal = true ∧ profileF φ ≤ c ∧ profileF ψ ≤ c := by
  rw [← Profile.join_le_iff]
  simp only [profileF, Profile.le_iff]
  exact ⟨fun h => ⟨h.2.2 trivial, h.1, h.2.1, fun _ => h.2.2 trivial⟩,
    fun h => ⟨h.2.1, h.2.2.1, fun _ => h.1⟩⟩

/-- Time reflection exchanges Until and Since, so it preserves the profile. -/
@[simp] theorem profileF_reflectTime (φ : Formula) : profileF φ.reflectTime = profileF φ := by
  induction φ <;> simp_all [profileF, Formula.reflectTime]

/-- The fragment of a formula of the base language. -/
def fragmentF (φ : Formula) : Fragment := (profileF φ).fragment

/-- The fragment of a formula of the extended language. -/
def fragmentP (φ : PlusFormula) : Fragment := (profileP φ).fragment

/-- The embedding of the base language preserves the profile, so a statement is filed in the
same place whichever language it is read in. -/
theorem profileP_ofFormula (φ : Formula) : profileP (ofFormula φ) = profileF φ := by
  induction φ <;> simp_all [profileP, profileF, ofFormula]

/-- The embedding of the base language preserves the fragment. -/
theorem fragmentP_ofFormula (φ : Formula) : fragmentP (ofFormula φ) = fragmentF φ := by
  simp [fragmentP, fragmentF, profileP_ofFormula]

/-- The substitution class of a statement. The extended system is not closed under uniform
substitution, so a statement that mentions `⊡` may hold only for restricted instances of some
of its variables. The variables are named by their position among the schema variables. -/
inductive SubstClass
  /-- Every instance of every variable is a theorem. -/
  | schematic
  /-- The named variables range over atoms only. -/
  | atoms (vars : List Nat)
  /-- The named variables range over state-local formulas only. -/
  | stateLocal (vars : List Nat)
  deriving DecidableEq, Repr

end BimodalLib
