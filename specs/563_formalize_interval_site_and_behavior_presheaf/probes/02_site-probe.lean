/-
Port probe for the interval site `Int(D)` of `def:interval-site`, concrete (non-CategoryTheory)
route, stated over a bare `TemporalOrder` with no task frame.
-/
import FormalSystem.Init
import FormalSystem.Semantics.TemporalOrder

namespace Probe563Site

open FormalSystem.Semantics

variable {D : TemporalOrder}

/-- `def:interval-site`, *Interval*: `[p, q] := {z ∈ D : p ≤ z ≤ q}`. -/
def Interval (p q : ↑D) : ↑D → Prop := fun z => p ≤ z ∧ z ≤ q

/-- Objects of the interval category: the durations `ℓ ∈ D⁺`. -/
abbrev Obj (D : TemporalOrder) : Type := TemporalOrder.PositiveCone D

/-- `def:interval-site`, *Interval Category*: a morphism `Tr p : l' → l` is a translation by a
duration `p ∈ D⁺` with `p + l' ≤ l`. -/
structure Tr (l' l : Obj D) where
  shift : ↑D
  shift_nonneg : 0 ≤ shift
  shift_add_le : shift + l'.val ≤ l.val

namespace Tr

@[ext] theorem ext {l' l : Obj D} {f g : Tr l' l} (h : f.shift = g.shift) : f = g := by
  cases f; cases g; simp_all

/-- The identity `Tr 0`. -/
def id (l : Obj D) : Tr l l := ⟨0, le_refl 0, by rw [zero_add]⟩

/-- `Tr p ∘ Tr p' = Tr (p + p')`. -/
def comp {l'' l' l : Obj D} (f : Tr l' l) (g : Tr l'' l') : Tr l'' l :=
  ⟨f.shift + g.shift, add_nonneg f.shift_nonneg g.shift_nonneg, by
    calc f.shift + g.shift + l''.val = f.shift + (g.shift + l''.val) := by rw [add_assoc]
      _ ≤ f.shift + l'.val := by exact add_le_add (le_refl _) g.shift_add_le
      _ ≤ l.val := f.shift_add_le⟩

@[simp] theorem comp_shift {l'' l' l : Obj D} (f : Tr l' l) (g : Tr l'' l') :
    (comp f g).shift = f.shift + g.shift := rfl

@[simp] theorem id_shift (l : Obj D) : (id l).shift = 0 := rfl

theorem id_comp {l' l : Obj D} (f : Tr l' l) : comp (id l) f = f := by ext; simp

theorem comp_id {l' l : Obj D} (f : Tr l' l) : comp f (id l') = f := by ext; simp

theorem comp_assoc {l₃ l₂ l₁ l : Obj D} (f : Tr l₁ l) (g : Tr l₂ l₁) (h : Tr l₃ l₂) :
    comp (comp f g) h = comp f (comp g h) := by ext; simp [add_assoc]

/-- A morphism exists `l' → l` exactly when `l' ≤ l`: this is the preorder underlying `Int(D)`. -/
theorem le_of_hom {l' l : Obj D} (f : Tr l' l) : l'.val ≤ l.val :=
  le_trans (le_add_of_nonneg_left f.shift_nonneg) f.shift_add_le

end Tr

/-- `def:interval-site`, *Presheaf*: the **left restriction** `Lres l l'`, along `Tr 0 : l' → l`. -/
def lres {l l' : Obj D} (h : l'.val ≤ l.val) : Tr l' l :=
  ⟨0, le_refl 0, by rw [zero_add]; exact h⟩

/-- The **right restriction** `Rres l l'`, along `Tr (l - l') : l' → l`. -/
def rres {l l' : Obj D} (h : l'.val ≤ l.val) : Tr l' l :=
  ⟨l.val - l'.val, sub_nonneg.mpr h, by rw [sub_add_cancel]⟩

/-- `def:interval-site`, *Johnstone Coverage*: for `l ∈ D⁺` and `p ∈ [0, l]`, the covering family
is the pair `Tr 0 : p → l` and `Tr p : l - p → l`. -/
def coverLeft (l : Obj D) (p : ↑D) (hp : 0 ≤ p) (hpl : p ≤ l.val) : Tr ⟨p, hp⟩ l :=
  ⟨0, le_refl 0, by rw [zero_add]; exact hpl⟩

def coverRight (l : Obj D) (p : ↑D) (hp : 0 ≤ p) (hpl : p ≤ l.val) :
    Tr ⟨l.val - p, sub_nonneg.mpr hpl⟩ l :=
  ⟨p, hp, by rw [add_sub_cancel]⟩

/-- The two members of a Johnstone covering family have the same composite with a germ, which is
what makes the sheaf condition of `def:interval-site` the two-section gluing statement. -/
theorem cover_germ_composites (l : Obj D) (p : ↑D) (hp : 0 ≤ p) (hpl : p ≤ l.val) :
    (Tr.comp (coverLeft l p hp hpl) (rres (l' := (⟨0, le_refl 0⟩ : Obj D)) hp)).shift
      = (Tr.comp (coverRight l p hp hpl)
          (lres (l' := (⟨0, le_refl 0⟩ : Obj D)) (sub_nonneg.mpr hpl))).shift := by
  simp [coverLeft, coverRight, lres, rres]

end Probe563Site
