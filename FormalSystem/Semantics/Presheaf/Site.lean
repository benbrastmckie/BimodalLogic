/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Init
import FormalSystem.Semantics.TemporalOrder

/-!
# The interval site `Int(D)`

The site on which a task frame's convex histories are a presheaf. Its objects are the durations —
the positive cone `D⁺` of a temporal order — and its morphisms `l' → l` are the **translations**
`Tr p`, one for each `p ∈ D⁺` with `p + l' ≤ l`: the translation that reads a window of length
`l'` starting at offset `p` out of a window of length `l`. Composition adds offsets, so the
identity is `Tr 0`, and the site carries the **Johnstone coverage** whose covering family at a
factorization `l = p + (l - p)` is the pair `Tr 0 : p → l` and `Tr p : (l - p) → l`.

This module is stated over a bare `{D : TemporalOrder}` and mentions no task frame at all: the
site depends on the temporal order and nothing else, which is why it sits strictly below
`Semantics/PartialHistory.lean` in the layering and why `Semantics/Presheaf/Behavior.lean` — the
presheaf *on* this site — is a separate module.

## Main Definitions

- `Interval p q`: the predicate `fun z => p ≤ z ∧ z ≤ q` cutting out a closed interval of `↑D`.
  The sections of the behavior presheaf are the partial histories whose domain is `Interval 0 l`.
- `Obj D`: the objects of `Int(D)`, namely `TemporalOrder.PositiveCone D`.
- `Tr l' l`: the morphisms `l' → l`, a `shift` in `↑D` together with `0 ≤ shift` and
  `shift + l' ≤ l`.
- `Tr.id`, `Tr.comp`: the identity `Tr 0` and composition, which adds shifts.
- `lres`, `rres`: the two canonical morphisms `l' → l` available whenever `l' ≤ l` — the left
  restriction `Tr 0` and the right restriction `Tr (l - l')`.
- `coverLeft`, `coverRight`: the two members of the Johnstone covering family of `l` determined
  by a cut point `p ≤ l`.

## Main Results

- `Tr.comp_shift`, `Tr.id_shift`: the shift of a composite is the sum of shifts, and the identity
  has shift `0`. Both `rfl`, and both `@[simp]`; everything below is a consequence.
- `Tr.id_comp`, `Tr.comp_id`, `Tr.comp_assoc`: the three category laws. Together with `Tr.id` and
  `Tr.comp` these are exactly the fields of a `Category` instance — see the Implementation Notes
  on why no such instance is declared.
- `Tr.le_of_hom`: a morphism `l' → l` witnesses `l' ≤ l`. The site is therefore a refinement of
  the order on durations, not an independent structure.
- `cover_germ_composites`: the two members of a covering family have equal composite shift with
  the germ `0 → ·`. This is the site-side content that makes the sheaf condition on this coverage
  a *two-section gluing* statement rather than a condition on arbitrary families.

## Implementation Notes

**Concrete structures, no `Mathlib.CategoryTheory`.** `Tr` is a plain `structure` and the three
category laws are plain theorems; no `Category` instance is declared and no category-theory module
is imported. Three reasons, recorded so the decision is not re-litigated. The live library imports
no category theory anywhere, so this would be the import that introduces the dependency. The
content of the interval site, as the paper defines it, is three composition laws plus a coverage —
all of which are stated here. And the concrete route keeps this module buildable from
`Semantics/TemporalOrder.lean` alone, which is what puts it below `Semantics/Truth.lean`.

**The decision is reversible without changing a single definition.** `Tr.id`, `Tr.comp`,
`Tr.id_comp`, `Tr.comp_id` and `Tr.comp_assoc` are precisely the data and fields a
`CategoryStruct`/`Category` instance on `Obj D` would need. Anything wanting the categorical
packaging — the duration monoid `BD⁺` and the twisted-arrow description of this site are the
obvious candidates — should add the instance beside these declarations and reconcile with this
note, rather than restating the site under a second encoding.

**Why `shift + l' ≤ l` rather than an equation.** The paper's translations are indexed by a
factorization `l = p + l' + q` with `q ∈ D⁺`. Carrying the inequality instead of the
factorization's witness `q` loses nothing — `q := l - p - l'` recovers it, and `sub_nonneg` turns
the inequality back into `q ∈ D⁺` — while making `Tr.ext` a one-field extensionality lemma, so
each of the three category laws is `by ext; simp`.

**Paper state: the source appendix is cut.** The anchors cited below live in the appendix
`app:Structure`, which the paper **cut in full** under an explicit `% SECTION CUT` record, and
whose surviving commented block carries a bare `% CHECK` — the author has not finished reviewing
this material. Every anchor below therefore resolves against
`docs/reference/paper-definitions-of-record.md`, where each carries a `DANGLING` row, and not
against a live `\label{}` in the paper; `scripts/check-paper-definitions.sh --resolve`
structurally cannot pin a commented-out label, so none of them is pinned. The mathematics here is
checked by Lean regardless of the appendix's fate, but its *correspondence to the paper* is
pinned to a record rather than to live text.

## References

* [P. Schultz, D. I. Spivak and C. Vasilakopoulou, *Dynamical Systems and Sheaves*][schultz2020],
  Defs. 3.1.1–3.1.2, Notation 3.1.7, Defs. 3.2.1–3.2.2 — the interval site at `ℝ≥0` and `ℕ`, of
  which `Int(D)` is the positive-cone-of-an-arbitrary-temporal-order instance
* [P. T. Johnstone, *A Note on Discrete Conduché Fibrations*][johnstone1999], §2 — the coverage
  `coverLeft`/`coverRight` instantiate
* JPL paper `def:interval-site` — the interval site `Int(D)`. **`DANGLING`**: cut from the paper
  with `app:Structure` and recorded in `docs/reference/paper-definitions-of-record.md`
* JPL paper `app:presheaf-dictionary` — the dictionary theorem whose *Sheaf* clause
  `cover_germ_composites` serves. **`DANGLING`**, as above
* JPL paper `app:Structure` — the cut appendix containing both. **`DANGLING`**, as above
* `FormalSystem/Semantics/TemporalOrder.lean` — `TemporalOrder.PositiveCone`, the objects
* `FormalSystem/Semantics/Presheaf/Behavior.lean` — the behavior presheaf on this site
-/

namespace FormalSystem.Semantics.Presheaf

variable {D : TemporalOrder}

/-- The closed interval `[p, q]` of `↑D`, as a predicate. The sections of the behavior presheaf
over `l` are the partial histories whose domain is `Interval 0 l`. -/
def Interval (p q : ↑D) : ↑D → Prop := fun z => p ≤ z ∧ z ≤ q

/-- The objects of the interval site `Int(D)`: the durations, i.e. the positive cone of `D`. -/
abbrev Obj (D : TemporalOrder) : Type := TemporalOrder.PositiveCone D

/-- A morphism `l' → l` of `Int(D)`: the translation `Tr p` that reads the window of length `l'`
beginning at offset `p = shift` out of a window of length `l`. -/
structure Tr (l' l : Obj D) where
  /-- The offset at which the shorter window begins. -/
  shift : ↑D
  /-- The offset is a duration. -/
  shift_nonneg : 0 ≤ shift
  /-- The shorter window, placed at the offset, fits inside the longer one. -/
  shift_add_le : shift + l'.val ≤ l.val

namespace Tr

/-- Translations between fixed objects are determined by their shift. -/
@[ext] theorem ext {l' l : Obj D} {f g : Tr l' l} (h : f.shift = g.shift) : f = g := by
  cases f; cases g; simp_all

/-- The identity morphism `Tr 0 : l → l`. -/
def id (l : Obj D) : Tr l l := ⟨0, le_refl 0, by rw [zero_add]⟩

/-- Composition of translations adds offsets: `Tr p ∘ Tr p' = Tr (p + p')`. -/
def comp {l'' l' l : Obj D} (f : Tr l' l) (g : Tr l'' l') : Tr l'' l :=
  ⟨f.shift + g.shift, add_nonneg f.shift_nonneg g.shift_nonneg, by
    calc f.shift + g.shift + l''.val = f.shift + (g.shift + l''.val) := by rw [add_assoc]
      _ ≤ f.shift + l'.val := add_le_add (le_refl _) g.shift_add_le
      _ ≤ l.val := f.shift_add_le⟩

/-- The shift of a composite is the sum of the shifts. -/
@[simp] theorem comp_shift {l'' l' l : Obj D} (f : Tr l' l) (g : Tr l'' l') :
    (comp f g).shift = f.shift + g.shift := rfl

/-- The identity has shift `0`. -/
@[simp] theorem id_shift (l : Obj D) : (id l).shift = 0 := rfl

/-- Left unit law. -/
theorem id_comp {l' l : Obj D} (f : Tr l' l) : comp (id l) f = f := by ext; simp

/-- Right unit law. -/
theorem comp_id {l' l : Obj D} (f : Tr l' l) : comp f (id l') = f := by ext; simp

/-- Associativity of composition. -/
theorem comp_assoc {l₃ l₂ l₁ l : Obj D} (f : Tr l₁ l) (g : Tr l₂ l₁) (h : Tr l₃ l₂) :
    comp (comp f g) h = comp f (comp g h) := by ext; simp [add_assoc]

/-- A morphism `l' → l` witnesses `l' ≤ l`: the site refines the order on durations. -/
theorem le_of_hom {l' l : Obj D} (f : Tr l' l) : l'.val ≤ l.val :=
  le_trans (le_add_of_nonneg_left f.shift_nonneg) f.shift_add_le

end Tr

/-- Left restriction: the morphism `Tr 0 : l' → l` available whenever `l' ≤ l`. -/
def lres {l l' : Obj D} (h : l'.val ≤ l.val) : Tr l' l :=
  ⟨0, le_refl 0, by rw [zero_add]; exact h⟩

/-- Right restriction: the morphism `Tr (l - l') : l' → l` available whenever `l' ≤ l`. -/
def rres {l l' : Obj D} (h : l'.val ≤ l.val) : Tr l' l :=
  ⟨l.val - l'.val, sub_nonneg.mpr h, by rw [sub_add_cancel]⟩

/-- The left member `Tr 0 : p → l` of the Johnstone covering family of `l` cut at `p`. -/
def coverLeft (l : Obj D) (p : ↑D) (hp : 0 ≤ p) (hpl : p ≤ l.val) : Tr ⟨p, hp⟩ l :=
  ⟨0, le_refl 0, by rw [zero_add]; exact hpl⟩

/-- The right member `Tr p : (l - p) → l` of the Johnstone covering family of `l` cut at `p`. -/
def coverRight (l : Obj D) (p : ↑D) (hp : 0 ≤ p) (hpl : p ≤ l.val) :
    Tr ⟨l.val - p, sub_nonneg.mpr hpl⟩ l :=
  ⟨p, hp, by rw [add_sub_cancel]⟩

/-- The two members of a covering family have the same composite with the germ `0 → ·`: the left
member reaches the cut point `p` through the right restriction of `p`, and the right member
reaches it through the left restriction of `l - p`, and both composites are the translation by
`p`. This is what makes the sheaf condition on this coverage the two-section gluing statement —
the two covering morphisms meet in exactly one point, so a compatible family is a pair of
sections agreeing on a single germ. -/
theorem cover_germ_composites (l : Obj D) (p : ↑D) (hp : 0 ≤ p) (hpl : p ≤ l.val) :
    (Tr.comp (coverLeft l p hp hpl) (rres (l' := (⟨0, le_refl 0⟩ : Obj D)) hp)).shift
      = (Tr.comp (coverRight l p hp hpl)
          (lres (l' := (⟨0, le_refl 0⟩ : Obj D)) (sub_nonneg.mpr hpl))).shift := by
  simp [coverLeft, coverRight, lres, rres]

end FormalSystem.Semantics.Presheaf

assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree
