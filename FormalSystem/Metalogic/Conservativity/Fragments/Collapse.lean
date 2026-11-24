/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Conservativity.Fragments.PropComplete

/-!
# The collapse translation

The translation that proves the edges out of the Boolean sublanguage and out of the sublanguage
with `□`. It reads a formula in a model with a single moment, where Until and Since have nothing
to quantify over, and either keeps `□` or reads it as the identity.

Two readings of Until and Since are needed, because no single one validates every axiom of every
frame class:

* the **dense** reading sends `U(g, e)` and `S(g, e)` to `g ∧ e`. Under it "next" is false, which
  the density axiom requires and the prior axiom for the integers forbids;
* the **discrete** reading sends `U(g, e)` and `S(g, e)` to `e`. Under it "next" is true, which
  the prior axiom for the integers requires.

`denseReading` chooses the dense reading at every class but `.ZTime`.

## Main definitions

* `BooleanFormula`, `ModalFormula`: the sublanguage without operators, and the sublanguage whose
  only operator is `□`.
* `collapse`: the translation, with a flag for the reading and a flag for keeping `□`.
* `denseReading`: the reading used at a frame class.

## Main statements

* `collapse_reflectTime`: the translation does not see time reflection.
* `collapse_of_boolean`, `collapse_of_modal`: the translation is the identity on its target.
* `booleanFormula_collapse`, `modalFormula_collapse`: the translation lands in its target.
* `collapse_allFuture_derivable`, `collapse_box_derivable`,
  `collapse_reflectTime_derivable`: derivability of a translation is preserved by the three
  rules for theorems.
-/

namespace FormalSystem.Metalogic.Conservativity.Fragments

open FormalSystem.Syntax FormalSystem.ProofSystem

/-- A formula with no operator: built from atoms, `⊥` and implication. -/
def BooleanFormula : Formula → Prop
  | .atom _ => True
  | .bot => True
  | .imp φ ψ => BooleanFormula φ ∧ BooleanFormula ψ
  | .box _ => False
  | .untl _ _ => False
  | .snce _ _ => False

/-- A formula whose only operator is `□`: no Until and no Since. -/
def ModalFormula : Formula → Prop
  | .atom _ => True
  | .bot => True
  | .imp φ ψ => ModalFormula φ ∧ ModalFormula ψ
  | .box φ => ModalFormula φ
  | .untl _ _ => False
  | .snce _ _ => False

/-- The formulas with no operator are a sublanguage. -/
theorem booleanFormula_sublanguage : Sublanguage BooleanFormula where
  bot := trivial
  imp_iff := fun _ _ => Iff.rfl
  reflectTime := fun φ h => by
    induction φ <;> simp_all [BooleanFormula, Formula.reflectTime]

/-- The formulas whose only operator is `□` are a sublanguage. -/
theorem modalFormula_sublanguage : Sublanguage ModalFormula where
  bot := trivial
  imp_iff := fun _ _ => Iff.rfl
  reflectTime := fun φ h => by
    induction φ <;> simp_all [ModalFormula, Formula.reflectTime]

/-- The collapse translation. Until and Since become a conjunction of both arguments under the
dense reading and the event argument alone under the discrete reading; `□` is kept when `keep` is
set and read as the identity otherwise. -/
def collapse (dense keep : Bool) : Formula → Formula
  | .atom a => .atom a
  | .bot => .bot
  | .imp φ ψ => .imp (collapse dense keep φ) (collapse dense keep ψ)
  | .box φ => bif keep then .box (collapse dense keep φ) else collapse dense keep φ
  | .untl g e =>
    bif dense then (collapse dense keep g).and (collapse dense keep e) else collapse dense keep e
  | .snce g e =>
    bif dense then (collapse dense keep g).and (collapse dense keep e) else collapse dense keep e

/-- The reading of Until and Since used at a frame class: discrete at `.ZTime`, dense at the
other three. -/
def denseReading : FrameClass → Bool
  | .ZTime => false
  | _ => true

variable (dense keep : Bool)

/-- The translation commutes with implication. -/
theorem collapse_imp (φ ψ : Formula) :
    collapse dense keep (φ.imp ψ) = (collapse dense keep φ).imp (collapse dense keep ψ) := rfl

/-- The translation does not see time reflection. -/
theorem collapse_reflectTime (φ : Formula) :
    collapse dense keep φ.reflectTime = collapse dense keep φ := by
  cases dense <;> cases keep <;> induction φ <;> simp_all [collapse, Formula.reflectTime]

/-- The translation is the identity on the formulas with no operator. -/
theorem collapse_of_boolean {φ : Formula} (h : BooleanFormula φ) :
    collapse dense keep φ = φ := by
  induction φ <;> simp_all [collapse, BooleanFormula]

/-- The translation that keeps `□` is the identity on the formulas whose only operator is
`□`. -/
theorem collapse_of_modal {φ : Formula} (h : ModalFormula φ) : collapse dense true φ = φ := by
  induction φ <;> simp_all [collapse, ModalFormula]

/-- The translation that erases `□` lands in the formulas with no operator. -/
theorem booleanFormula_collapse (φ : Formula) : BooleanFormula (collapse dense false φ) := by
  cases dense <;> induction φ <;>
    simp_all [collapse, BooleanFormula, Formula.and, Formula.neg]

/-- The translation that keeps `□` lands in the formulas whose only operator is `□`. -/
theorem modalFormula_collapse (φ : Formula) : ModalFormula (collapse dense true φ) := by
  cases dense <;> induction φ <;>
    simp_all [collapse, ModalFormula, Formula.and, Formula.neg]

/-- The translation of `φ` implies the translation of `Gφ`, as a tautology. -/
theorem collapse_allFuture_tautology (φ : Formula) :
    Tautology ((collapse dense keep φ).imp (collapse dense keep φ.allFuture)) := by
  intro v
  cases dense <;>
    simp [collapse, Formula.allFuture, Formula.someFuture, Formula.neg, Formula.top,
      Formula.and, evalProp]

variable {dense keep} {L : Formula → Prop} {fc : FrameClass}

/-- Temporal necessitation is preserved: from the translation of `φ`, the translation of `Gφ`. -/
theorem collapse_allFuture_derivable (hL : Sublanguage L)
    (hrange : ∀ φ : Formula, L (collapse dense keep φ)) (φ : Formula)
    (d : CellDerivable L fc [] (collapse dense keep φ)) :
    CellDerivable L fc [] (collapse dense keep φ.allFuture) :=
  CellDerivable.mp hL
    (tautology_derivable hL (hL.imp (hrange φ) (hrange _)) (collapse_allFuture_tautology _ _ φ)) d

/-- Necessitation is preserved: from the translation of `φ`, the translation of `□φ`. When `□` is
kept this is necessitation inside the sublanguage; when it is erased the two translations are
the same formula. -/
theorem collapse_box_derivable (hrange : ∀ φ : Formula, L (collapse dense keep φ)) (φ : Formula)
    (d : CellDerivable L fc [] (collapse dense keep φ)) :
    CellDerivable L fc [] (collapse dense keep φ.box) := by
  cases keep with
  | false => exact d
  | true => exact .necessitation _ d (hrange φ.box)

/-- Time reflection is preserved: the translation of the reflection is the translation. -/
theorem collapse_reflectTime_derivable (φ : Formula)
    (d : CellDerivable L fc [] (collapse dense keep φ)) :
    CellDerivable L fc [] (collapse dense keep φ.reflectTime) := by
  rwa [collapse_reflectTime]

end FormalSystem.Metalogic.Conservativity.Fragments
