/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Expressiveness.SeparationZ.Syntax
import FormalSystem.PlusLanguage.TemporalViews
import FormalSystem.StarLanguage.Formula
import FormalSystem.Syntax.ConnectivesElab

/-!
# Connective Signature Test Suite

Fixes the output of the `sig%` body generator on toy languages, independently of the formula
types of the library, and ties the generated operators of the library's formula types to the
signature.

## Test Categories

- Literal bodies: each of the 26 signature operators, generated at a toy language and compared by
  `rfl` with its full constructor form
- One layer: the stored body of a generated definition is stated with the per-language names
- Stored bodies: no generated definition mentions a signature constant
- Library types: each generated operator of `Formula`, `PlusFormula`, `StarFormula` and `USForm`
  equals its signature operator by `rfl`; the `Formula` operators are compared with their full
  constructor forms; no stored body mentions a signature constant
- Rejections: a missing per-language name, and a per-language name that disagrees with the
  signature, each raise an error naming the constant
-/

namespace BimodalTest.Syntax.ConnectivesTest

open FormalSystem.Syntax
open FormalSystem.PlusLanguage (PlusFormula)
open FormalSystem.StarLanguage (StarFormula)
open FormalSystem.Metalogic.Expressiveness.SeparationZ (USForm)

/-! ## A toy language over Until and Since -/

/-- A toy language with every primitive the Until/Since operators of the signature need. -/
inductive Toy where
  | atom : Nat → Toy
  | bot : Toy
  | imp : Toy → Toy → Toy
  | box : Toy → Toy
  | stab : Toy → Toy
  | untl : Toy → Toy → Toy
  | snce : Toy → Toy → Toy

instance : HasBot Toy := ⟨.bot⟩
instance : HasImp Toy := ⟨.imp⟩
instance : HasBox Toy := ⟨.box⟩
instance : HasStab Toy := ⟨.stab⟩
instance : HasUntl Toy := ⟨.untl⟩
instance : HasSnce Toy := ⟨.snce⟩

/-! Generated in dependency order: each definition mentions only names above it. -/

def Toy.neg (φ : Toy) : Toy := sig% Sig.neg φ
def Toy.top : Toy := sig% Sig.top
def Toy.and (φ ψ : Toy) : Toy := sig% Sig.and φ ψ
def Toy.or (φ ψ : Toy) : Toy := sig% Sig.or φ ψ
def Toy.diamond (φ : Toy) : Toy := sig% Sig.diamond φ
def Toy.dstab (φ : Toy) : Toy := sig% Sig.dstab φ
def Toy.someFuture (φ : Toy) : Toy := sig% Sig.someFuture φ
def Toy.allFuture (φ : Toy) : Toy := sig% Sig.allFuture φ
def Toy.kPlus (φ : Toy) : Toy := sig% Sig.kPlus φ
def Toy.after (φ ψ : Toy) : Toy := sig% Sig.after φ ψ
def Toy.next (φ : Toy) : Toy := sig% Sig.next φ
def Toy.somePast (φ : Toy) : Toy := sig% Sig.somePast φ
def Toy.allPast (φ : Toy) : Toy := sig% Sig.allPast φ
def Toy.kMinus (φ : Toy) : Toy := sig% Sig.kMinus φ
def Toy.prev (φ : Toy) : Toy := sig% Sig.prev φ
def Toy.always (φ : Toy) : Toy := sig% Sig.always φ
def Toy.sometimes (φ : Toy) : Toy := sig% Sig.sometimes φ
def Toy.inclusiveUntil (g ev : Toy) : Toy := sig% Sig.inclusiveUntil g ev
def Toy.release (φ ψ : Toy) : Toy := sig% Sig.release φ ψ
def Toy.weakUntil (φ ψ : Toy) : Toy := sig% Sig.weakUntil φ ψ
def Toy.inclusiveSince (g ev : Toy) : Toy := sig% Sig.inclusiveSince g ev
def Toy.trigger (φ ψ : Toy) : Toy := sig% Sig.trigger φ ψ
def Toy.weakSince (φ ψ : Toy) : Toy := sig% Sig.weakSince φ ψ

/-! ## A toy language over primitive tenses -/

/-- A toy language taking `G` and `H` as primitives, for the three primed operators. -/
inductive Tense where
  | bot : Tense
  | imp : Tense → Tense → Tense
  | allFuture : Tense → Tense
  | allPast : Tense → Tense

instance : HasBot Tense := ⟨.bot⟩
instance : HasImp Tense := ⟨.imp⟩
instance : HasAllFuture Tense := ⟨.allFuture⟩
instance : HasAllPast Tense := ⟨.allPast⟩

def Tense.neg (φ : Tense) : Tense := sig% Sig.neg φ
def Tense.and (φ ψ : Tense) : Tense := sig% Sig.and φ ψ
def Tense.someFuture' (φ : Tense) : Tense := sig% Sig.someFuture' φ
def Tense.somePast' (φ : Tense) : Tense := sig% Sig.somePast' φ
def Tense.always' (φ : Tense) : Tense := sig% Sig.always' φ

/-! ## Literal bodies

Each generated operator against its full constructor form. `⊥ₜ` is `bot` and `⇒` is `imp`, right
associative; `untl` and `snce` are guard first. -/

section Literal

local notation "⊥ₜ" => Toy.bot
local infixr:25 " ⇒ " => Toy.imp

variable (φ ψ : Toy)

-- Boolean
example : φ.neg = (φ ⇒ ⊥ₜ) := rfl
example : Toy.top = (⊥ₜ ⇒ ⊥ₜ) := rfl
example : φ.and ψ = ((φ ⇒ ψ ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl
example : φ.or ψ = ((φ ⇒ ⊥ₜ) ⇒ ψ) := rfl

-- Modal
example : φ.diamond = (.box (φ ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl
example : φ.dstab = (.stab (φ ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl

-- Future
example : φ.someFuture = .untl (⊥ₜ ⇒ ⊥ₜ) φ := rfl
example : φ.allFuture = (.untl (⊥ₜ ⇒ ⊥ₜ) (φ ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl
example : φ.kPlus = (.untl (φ ⇒ ⊥ₜ) (⊥ₜ ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl
example : φ.after ψ = .untl (φ ⇒ ⊥ₜ) ((φ ⇒ ψ ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl
example : φ.next = .untl ⊥ₜ φ := rfl

-- Past
example : φ.somePast = .snce (⊥ₜ ⇒ ⊥ₜ) φ := rfl
example : φ.allPast = (.snce (⊥ₜ ⇒ ⊥ₜ) (φ ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl
example : φ.kMinus = (.snce (φ ⇒ ⊥ₜ) (⊥ₜ ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl
example : φ.prev = .snce ⊥ₜ φ := rfl

-- Both directions: `Hφ ∧ (φ ∧ Gφ)` and its dual
example : φ.always =
    (((.snce (⊥ₜ ⇒ ⊥ₜ) (φ ⇒ ⊥ₜ) ⇒ ⊥ₜ) ⇒
      ((φ ⇒ (.untl (⊥ₜ ⇒ ⊥ₜ) (φ ⇒ ⊥ₜ) ⇒ ⊥ₜ) ⇒ ⊥ₜ) ⇒ ⊥ₜ) ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl
example : φ.sometimes =
    ((((.snce (⊥ₜ ⇒ ⊥ₜ) ((φ ⇒ ⊥ₜ) ⇒ ⊥ₜ) ⇒ ⊥ₜ) ⇒
      (((φ ⇒ ⊥ₜ) ⇒ (.untl (⊥ₜ ⇒ ⊥ₜ) ((φ ⇒ ⊥ₜ) ⇒ ⊥ₜ) ⇒ ⊥ₜ) ⇒ ⊥ₜ) ⇒ ⊥ₜ) ⇒ ⊥ₜ) ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl

-- Intervals. `inclusiveUntil`/`inclusiveSince` are guard first; the other four are event first.
example : φ.inclusiveUntil ψ = ((ψ ⇒ ⊥ₜ) ⇒ (φ ⇒ .untl φ ψ ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl
example : φ.release ψ = (.untl (ψ ⇒ ⊥ₜ) (φ ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl
example : φ.weakUntil ψ = ((.untl ψ φ ⇒ ⊥ₜ) ⇒ .untl (⊥ₜ ⇒ ⊥ₜ) (ψ ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl
example : φ.inclusiveSince ψ = ((ψ ⇒ ⊥ₜ) ⇒ (φ ⇒ .snce φ ψ ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl
example : φ.trigger ψ = (.snce (ψ ⇒ ⊥ₜ) (φ ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl
example : φ.weakSince ψ = ((.snce ψ φ ⇒ ⊥ₜ) ⇒ .snce (⊥ₜ ⇒ ⊥ₜ) (ψ ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl

end Literal

section LiteralTense

local notation "⊥ₜ" => Tense.bot
local infixr:25 " ⇒ " => Tense.imp

variable (φ : Tense)

example : φ.someFuture' = (.allFuture (φ ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl
example : φ.somePast' = (.allPast (φ ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl
example : φ.always' = ((.allPast φ ⇒ ((φ ⇒ .allFuture φ ⇒ ⊥ₜ) ⇒ ⊥ₜ) ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl

end LiteralTense

/-! ## One layer

The stored body is stated with the per-language names, not unfolded to constructors throughout. -/

/--
info: def BimodalTest.Syntax.ConnectivesTest.Toy.always : Toy → Toy :=
fun φ ↦ φ.allPast.and (φ.and φ.allFuture)
-/
#guard_msgs in
#print Toy.always

/--
info: def BimodalTest.Syntax.ConnectivesTest.Toy.weakUntil : Toy → Toy → Toy :=
fun φ ψ ↦ (ψ.untl φ).or ψ.allFuture
-/
#guard_msgs in
#print Toy.weakUntil

/--
info: def BimodalTest.Syntax.ConnectivesTest.Toy.next : Toy → Toy :=
fun φ ↦ Toy.bot.untl φ
-/
#guard_msgs in
#print Toy.next

/-! ## Stored bodies mention no signature constant -/

open Lean Elab Command in
run_cmd liftTermElabM do
  let generated := [``Toy.neg, ``Toy.top, ``Toy.and, ``Toy.or, ``Toy.diamond, ``Toy.dstab,
    ``Toy.someFuture, ``Toy.allFuture, ``Toy.kPlus, ``Toy.after, ``Toy.next, ``Toy.somePast,
    ``Toy.allPast, ``Toy.kMinus, ``Toy.prev, ``Toy.always, ``Toy.sometimes,
    ``Toy.inclusiveUntil, ``Toy.release, ``Toy.weakUntil, ``Toy.inclusiveSince, ``Toy.trigger,
    ``Toy.weakSince, ``Tense.neg, ``Tense.and, ``Tense.someFuture', ``Tense.somePast',
    ``Tense.always']
  unless generated.length = 28 do throwError "expected 28 generated definitions"
  for n in generated do
    if let some s := Sig.survivor? (← getConstInfo n).value! then
      throwError "{n}: the stored body mentions the signature constant {s}"

/-! ## The formula types of the library

The derived operators of `Formula`, `PlusFormula`, `StarFormula` and `USForm` take their bodies
from the signature through `sig%`. Each is tied to its signature operator by `rfl`; the operators
of `Formula` are also compared with their full constructor forms, and the stored bodies are
checked to mention no signature constant. -/

section TiesFormula

variable (φ ψ : Formula)

example : Formula.top = Sig.top := rfl
example : Formula.neg φ = Sig.neg φ := rfl
example : Formula.someFuture φ = Sig.someFuture φ := rfl
example : Formula.somePast φ = Sig.somePast φ := rfl
example : Formula.allFuture φ = Sig.allFuture φ := rfl
example : Formula.allPast φ = Sig.allPast φ := rfl
example : Formula.kPlus φ = Sig.kPlus φ := rfl
example : Formula.kMinus φ = Sig.kMinus φ := rfl
example : Formula.and φ ψ = Sig.and φ ψ := rfl
example : Formula.or φ ψ = Sig.or φ ψ := rfl
example : Formula.diamond φ = Sig.diamond φ := rfl
example : Formula.always φ = Sig.always φ := rfl
example : Formula.next φ = Sig.next φ := rfl
example : Formula.prev φ = Sig.prev φ := rfl
example : Formula.release φ ψ = Sig.release φ ψ := rfl
example : Formula.after φ ψ = Sig.after φ ψ := rfl
example : Formula.weakUntil φ ψ = Sig.weakUntil φ ψ := rfl
example : Formula.trigger φ ψ = Sig.trigger φ ψ := rfl
example : Formula.weakSince φ ψ = Sig.weakSince φ ψ := rfl
example : Formula.sometimes φ = Sig.sometimes φ := rfl
example : Formula.inclusiveUntil φ ψ = Sig.inclusiveUntil φ ψ := rfl
example : Formula.inclusiveSince φ ψ = Sig.inclusiveSince φ ψ := rfl

end TiesFormula

section TiesPlusFormula

variable (φ ψ : PlusFormula)

example : PlusFormula.top = Sig.top := rfl
example : PlusFormula.neg φ = Sig.neg φ := rfl
example : PlusFormula.someFuture φ = Sig.someFuture φ := rfl
example : PlusFormula.somePast φ = Sig.somePast φ := rfl
example : PlusFormula.allFuture φ = Sig.allFuture φ := rfl
example : PlusFormula.allPast φ = Sig.allPast φ := rfl
example : PlusFormula.kPlus φ = Sig.kPlus φ := rfl
example : PlusFormula.kMinus φ = Sig.kMinus φ := rfl
example : PlusFormula.and φ ψ = Sig.and φ ψ := rfl
example : PlusFormula.or φ ψ = Sig.or φ ψ := rfl
example : PlusFormula.diamond φ = Sig.diamond φ := rfl
example : PlusFormula.always φ = Sig.always φ := rfl
example : PlusFormula.sometimes φ = Sig.sometimes φ := rfl
example : PlusFormula.next φ = Sig.next φ := rfl
example : PlusFormula.prev φ = Sig.prev φ := rfl
example : PlusFormula.after φ ψ = Sig.after φ ψ := rfl
example : PlusFormula.dstab φ = Sig.dstab φ := rfl
example : PlusFormula.release φ ψ = Sig.release φ ψ := rfl
example : PlusFormula.trigger φ ψ = Sig.trigger φ ψ := rfl
example : PlusFormula.weakUntil φ ψ = Sig.weakUntil φ ψ := rfl
example : PlusFormula.weakSince φ ψ = Sig.weakSince φ ψ := rfl
example : PlusFormula.inclusiveUntil φ ψ = Sig.inclusiveUntil φ ψ := rfl
example : PlusFormula.inclusiveSince φ ψ = Sig.inclusiveSince φ ψ := rfl

end TiesPlusFormula

section TiesStarFormula

variable (φ ψ : StarFormula)

example : StarFormula.top = Sig.top := rfl
example : StarFormula.neg φ = Sig.neg φ := rfl
example : StarFormula.someFuture φ = Sig.someFuture φ := rfl
example : StarFormula.somePast φ = Sig.somePast φ := rfl
example : StarFormula.allFuture φ = Sig.allFuture φ := rfl
example : StarFormula.allPast φ = Sig.allPast φ := rfl
example : StarFormula.kPlus φ = Sig.kPlus φ := rfl
example : StarFormula.kMinus φ = Sig.kMinus φ := rfl
example : StarFormula.and φ ψ = Sig.and φ ψ := rfl
example : StarFormula.or φ ψ = Sig.or φ ψ := rfl
example : StarFormula.diamond φ = Sig.diamond φ := rfl
example : StarFormula.always φ = Sig.always φ := rfl
example : StarFormula.sometimes φ = Sig.sometimes φ := rfl
example : StarFormula.next φ = Sig.next φ := rfl
example : StarFormula.prev φ = Sig.prev φ := rfl
example : StarFormula.dstab φ = Sig.dstab φ := rfl

end TiesStarFormula

section TiesUSForm

variable (φ ψ : USForm)

example : USForm.top = Sig.top := rfl
example : USForm.neg φ = Sig.neg φ := rfl
example : USForm.and φ ψ = Sig.and φ ψ := rfl
example : USForm.or φ ψ = Sig.or φ ψ := rfl
example : USForm.someFuture φ = Sig.someFuture φ := rfl
example : USForm.somePast φ = Sig.somePast φ := rfl
example : USForm.allFuture φ = Sig.allFuture φ := rfl
example : USForm.allPast φ = Sig.allPast φ := rfl
example : USForm.next φ = Sig.next φ := rfl
example : USForm.prev φ = Sig.prev φ := rfl

end TiesUSForm

/-! ### Literal bodies at `Formula`

`⊥ₜ` is `Formula.bot` and `⇒` is `Formula.imp`, right associative. -/

section LiteralFormula

local notation "⊥ₜ" => Formula.bot
local infixr:25 " ⇒ " => Formula.imp

variable (φ ψ : Formula)

-- Boolean
example : φ.neg = (φ ⇒ ⊥ₜ) := rfl
example : Formula.top = (⊥ₜ ⇒ ⊥ₜ) := rfl
example : φ.and ψ = ((φ ⇒ ψ ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl
example : φ.or ψ = ((φ ⇒ ⊥ₜ) ⇒ ψ) := rfl

-- Modal
example : φ.diamond = (.box (φ ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl

-- Future
example : φ.someFuture = .untl (⊥ₜ ⇒ ⊥ₜ) φ := rfl
example : φ.allFuture = (.untl (⊥ₜ ⇒ ⊥ₜ) (φ ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl
example : φ.kPlus = (.untl (φ ⇒ ⊥ₜ) (⊥ₜ ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl
example : φ.after ψ = .untl (φ ⇒ ⊥ₜ) ((φ ⇒ ψ ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl
example : φ.next = .untl ⊥ₜ φ := rfl

-- Past
example : φ.somePast = .snce (⊥ₜ ⇒ ⊥ₜ) φ := rfl
example : φ.allPast = (.snce (⊥ₜ ⇒ ⊥ₜ) (φ ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl
example : φ.kMinus = (.snce (φ ⇒ ⊥ₜ) (⊥ₜ ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl
example : φ.prev = .snce ⊥ₜ φ := rfl

-- Both directions: `Hφ ∧ (φ ∧ Gφ)` and its dual
example : φ.always =
    (((.snce (⊥ₜ ⇒ ⊥ₜ) (φ ⇒ ⊥ₜ) ⇒ ⊥ₜ) ⇒
      ((φ ⇒ (.untl (⊥ₜ ⇒ ⊥ₜ) (φ ⇒ ⊥ₜ) ⇒ ⊥ₜ) ⇒ ⊥ₜ) ⇒ ⊥ₜ) ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl
example : φ.sometimes =
    ((((.snce (⊥ₜ ⇒ ⊥ₜ) ((φ ⇒ ⊥ₜ) ⇒ ⊥ₜ) ⇒ ⊥ₜ) ⇒
      (((φ ⇒ ⊥ₜ) ⇒ (.untl (⊥ₜ ⇒ ⊥ₜ) ((φ ⇒ ⊥ₜ) ⇒ ⊥ₜ) ⇒ ⊥ₜ) ⇒ ⊥ₜ) ⇒ ⊥ₜ) ⇒ ⊥ₜ) ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl

-- Intervals. `inclusiveUntil`/`inclusiveSince` are guard first; the other four are event first.
example : φ.inclusiveUntil ψ = ((ψ ⇒ ⊥ₜ) ⇒ (φ ⇒ .untl φ ψ ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl
example : φ.release ψ = (.untl (ψ ⇒ ⊥ₜ) (φ ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl
example : φ.weakUntil ψ = ((.untl ψ φ ⇒ ⊥ₜ) ⇒ .untl (⊥ₜ ⇒ ⊥ₜ) (ψ ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl
example : φ.inclusiveSince ψ = ((ψ ⇒ ⊥ₜ) ⇒ (φ ⇒ .snce φ ψ ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl
example : φ.trigger ψ = (.snce (ψ ⇒ ⊥ₜ) (φ ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl
example : φ.weakSince ψ = ((.snce ψ φ ⇒ ⊥ₜ) ⇒ .snce (⊥ₜ ⇒ ⊥ₜ) (ψ ⇒ ⊥ₜ) ⇒ ⊥ₜ) := rfl

end LiteralFormula

/-! ### One layer at `Formula`

The stored bodies are the ones the definitions carried when written by hand. -/

/--
info: def FormalSystem.Syntax.Formula.always : Formula → Formula :=
fun φ ↦ φ.allPast.and (φ.and φ.allFuture)
-/
#guard_msgs in
#print Formula.always

/--
info: def FormalSystem.Syntax.Formula.weakUntil : Formula → Formula → Formula :=
fun φ ψ ↦ (ψ.untl φ).or ψ.allFuture
-/
#guard_msgs in
#print Formula.weakUntil

/--
info: def FormalSystem.Syntax.Formula.next : Formula → Formula :=
fun φ ↦ Formula.bot.untl φ
-/
#guard_msgs in
#print Formula.next

/-! ### Stored bodies of the library definitions mention no signature constant -/

open Lean Elab Command in
run_cmd liftTermElabM do
  let generated := [
    ``Formula.top, ``Formula.neg, ``Formula.someFuture, ``Formula.somePast, ``Formula.allFuture,
    ``Formula.allPast, ``Formula.kPlus, ``Formula.kMinus, ``Formula.and, ``Formula.or,
    ``Formula.diamond, ``Formula.always, ``Formula.next, ``Formula.prev, ``Formula.release,
    ``Formula.after, ``Formula.weakUntil, ``Formula.trigger, ``Formula.weakSince,
    ``Formula.sometimes, ``Formula.inclusiveUntil, ``Formula.inclusiveSince, ``PlusFormula.top,
    ``PlusFormula.neg, ``PlusFormula.someFuture, ``PlusFormula.somePast, ``PlusFormula.allFuture,
    ``PlusFormula.allPast, ``PlusFormula.kPlus, ``PlusFormula.kMinus, ``PlusFormula.and,
    ``PlusFormula.or, ``PlusFormula.diamond, ``PlusFormula.always, ``PlusFormula.sometimes,
    ``PlusFormula.next, ``PlusFormula.prev, ``PlusFormula.after, ``PlusFormula.dstab,
    ``PlusFormula.release, ``PlusFormula.trigger, ``PlusFormula.weakUntil, ``PlusFormula.weakSince,
    ``PlusFormula.inclusiveUntil, ``PlusFormula.inclusiveSince, ``StarFormula.top,
    ``StarFormula.neg, ``StarFormula.someFuture, ``StarFormula.somePast, ``StarFormula.allFuture,
    ``StarFormula.allPast, ``StarFormula.kPlus, ``StarFormula.kMinus, ``StarFormula.and,
    ``StarFormula.or, ``StarFormula.diamond, ``StarFormula.always, ``StarFormula.sometimes,
    ``StarFormula.next, ``StarFormula.prev, ``StarFormula.dstab, ``USForm.top, ``USForm.neg,
    ``USForm.and, ``USForm.or, ``USForm.someFuture, ``USForm.somePast, ``USForm.allFuture,
    ``USForm.allPast, ``USForm.next, ``USForm.prev]
  unless generated.length = 71 do throwError "expected 71 generated definitions"
  for n in generated do
    if let some s := Sig.survivor? (← getConstInfo n).value! then
      throwError "{n}: the stored body mentions the signature constant {s}"

/-! ## Rejections -/

/-- A language with instances and no derived operator defined yet. -/
inductive Bare where
  | bot : Bare
  | imp : Bare → Bare → Bare

instance : HasBot Bare := ⟨.bot⟩
instance : HasImp Bare := ⟨.imp⟩

-- `Bare.neg` does not exist yet, so `Sig.neg` would survive in the body of `Bare.and`.
/--
error: sig%: `FormalSystem.Syntax.Sig.neg` survives in the generated body
  Sig.neg (φ.imp (Sig.neg ψ))
Define `BimodalTest.Syntax.ConnectivesTest.Bare.neg` before this definition.
-/
#guard_msgs in
def Bare.and (φ ψ : Bare) : Bare := sig% Sig.and φ ψ

/-- A per-language `neg` that is not the signature's. -/
def Bare.neg (φ : Bare) : Bare := φ

-- `Bare.neg` now exists and disagrees with `Sig.neg`.
/--
error: sig%: `BimodalTest.Syntax.ConnectivesTest.Bare.neg` exists but does not agree with `FormalSystem.Syntax.Sig.neg` on
  Sig.neg φ
-/
#guard_msgs in
def Bare.or (φ ψ : Bare) : Bare := sig% Sig.or φ ψ

-- Not an application of a signature operator: a variable, and a per-language definition.
/--
error: sig%: not an application of a signature operator:
  φ
-/
#guard_msgs in
def Bare.id (φ : Bare) : Bare := sig% φ

/--
error: sig%: not an application of a signature operator:
  φ.neg
-/
#guard_msgs in
def Bare.neg' (φ : Bare) : Bare := sig% Bare.neg φ

end BimodalTest.Syntax.ConnectivesTest
