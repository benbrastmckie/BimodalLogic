/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.PlusLanguage.Formula

/-!
# `OpenFormula` — the language L^▷: L⁺ plus the open-future and open-past modals

This module defines the language **L^▷** obtained from L⁺ (`FormalSystem/PlusLanguage/Formula.lean`)
by adding two primitive unary operators, the **open-future** modal `▷` (`ofut`) and the
**open-past** modal `◁` (`opast`):

```
φ, ψ ::= pᵢ | ⊥ | φ → ψ | □φ | φ U ψ | φ S ψ | ⊡φ | ▷φ | ◁φ
```

The manuscript's subsection *Restricted Modalities* (`sub:RestrictedModalities`) introduces both
beside the stability modal: "the *open future* operator quantifies over all possible worlds that
agree with the world of evaluation up to the time of evaluation", and "the *open past* operator
is also intelligible and has been included for comparison". This file is syntax only; the truth
clauses are in `OpenLanguage/OpenTruth.lean`.

## Design

`OpenFormula` is a **separate inductive** with a constructor-to-constructor embedding
`ofPlus : PlusFormula → OpenFormula`, following `FormalSystem/StarLanguage/Formula.lean`. No
constructor is added to `PlusFormula`. Every derived operator below has the **same right-hand
side** as its `PlusFormula` namesake, so that `ofPlus` pushes through each of them by `rfl` and
the abstract clause lemmas of `Semantics/TruthClauses.lean` are inherited without a `show`.

Time reflection exchanges the two new operators, as it exchanges `U` and `S`: `|τ⟩_x` is defined
by a condition on the times `≤ x` and `⟨τ|_x` by the same condition on the times `≥ x`. It fixes
`⊡`, whose class `⟨τ⟩_x` is defined by a same-time condition.

## Main Definitions

- `OpenFormula`: nine-constructor inductive type for L^▷
- Derived operators with `PlusFormula`'s right-hand sides: `top`, `neg`, `someFuture`,
  `somePast`, `allFuture`, `allPast`, `and`, `or`, `iff`, `diamond`, `always`, `sometimes`, `dstab`
- The duals of the new operators: `dofut` (`▷̂φ := ¬▷¬φ`) and `dopast` (`◁̂φ := ¬◁¬φ`)
- `ofPlus`: the embedding of L⁺ into L^▷
- `OpenFormula.reflectTime`: the past/future interchange (`ofut ↦ opast`, `opast ↦ ofut`,
  `stab ↦ stab`)

## Main Results

- `DecidableEq`, `Countable` for `OpenFormula`
- `ofPlus_injective`, `ofPlus_reflectTime`, and the `rfl` commutation pins
- `reflect_time_involution` and the push-through lemmas `reflect_time_somePast`,
  `reflect_time_someFuture`, `reflect_time_dofut`, `reflect_time_dopast`, `reflect_time_dstab`

## Module Invariant

**This file imports nothing from `FormalSystem/Semantics/` and no semantic module of any
language.** It is the syntax half of the component; `scripts/check-metalogic-cycles.sh` checks the
edge.

## References

* JPL paper `sub:RestrictedModalities` — the open-future and open-past operators
* JPL paper `def:BLstar-semantics` — the stability modal `⊡`, which both extend
* `FormalSystem/PlusLanguage/Formula.lean` — the L⁺ side whose derived operators are mirrored
* `FormalSystem/StarLanguage/Formula.lean` — the sibling extension of L⁺, the pattern followed

## Tags

open-language · syntax · open-future · open-past
-/

namespace FormalSystem.OpenLanguage

open FormalSystem.Syntax
open FormalSystem.PlusLanguage

/--
Formula type for the language L^▷: the seven constructors of `PlusFormula` plus the open-future
and open-past modals.

Constructor order and argument order (guard first, event second for `untl`/`snce`) are those of
`PlusFormula`, so that `ofPlus` is constructor-to-constructor.
-/
inductive OpenFormula : Type where
  /-- Propositional atom (variable). -/
  | atom : Atom → OpenFormula
  /-- Bottom (`⊥`, falsum). -/
  | bot : OpenFormula
  /-- Implication (`φ → ψ`). -/
  | imp : OpenFormula → OpenFormula → OpenFormula
  /-- Modal necessity (`□φ`). -/
  | box : OpenFormula → OpenFormula
  /-- Until, `φ U ψ`, guard first and event second, exactly as `PlusFormula.untl`. -/
  | untl : OpenFormula → OpenFormula → OpenFormula
  /-- Since, `φ S ψ`, guard first and event second, exactly as `PlusFormula.snce`. -/
  | snce : OpenFormula → OpenFormula → OpenFormula
  /-- The stability modal `⊡φ` (`def:BLstar-semantics`): `φ` holds in every world sharing the
  present world state. -/
  | stab : OpenFormula → OpenFormula
  /-- The open-future modal `▷φ` (`sub:RestrictedModalities`): `φ` holds in every world that
  agrees with the world of evaluation up to and including the time of evaluation. -/
  | ofut : OpenFormula → OpenFormula
  /-- The open-past modal `◁φ` (`sub:RestrictedModalities`): `φ` holds in every world that agrees
  with the world of evaluation from the time of evaluation onward. -/
  | opast : OpenFormula → OpenFormula
  deriving Repr, DecidableEq, Countable

namespace OpenFormula

/-! ### Derived operators

Each right-hand side is copied verbatim from `PlusLanguage/Formula.lean`, so that `ofPlus`
commutes with it by `rfl` (see the pins at the end of the file). -/

/-- Top (`⊤`): `⊥ → ⊥`. Mirrors `PlusFormula.top`. -/
def top : OpenFormula := OpenFormula.bot.imp OpenFormula.bot

/-- Negation (`¬φ`): `φ → ⊥`. Mirrors `PlusFormula.neg`. -/
def neg (φ : OpenFormula) : OpenFormula := φ.imp bot

/-- Existential future (`Fφ`): `⊤ U φ`. Mirrors `PlusFormula.someFuture`. -/
def someFuture (φ : OpenFormula) : OpenFormula := OpenFormula.untl OpenFormula.top φ

/-- Existential past (`Pφ`): `⊤ S φ`. Mirrors `PlusFormula.somePast`. -/
def somePast (φ : OpenFormula) : OpenFormula := OpenFormula.snce OpenFormula.top φ

/-- Universal future (`Gφ`): `¬F¬φ`. Mirrors `PlusFormula.allFuture`. -/
def allFuture (φ : OpenFormula) : OpenFormula := (someFuture φ.neg).neg

/-- Universal past (`Hφ`): `¬P¬φ`. Mirrors `PlusFormula.allPast`. -/
def allPast (φ : OpenFormula) : OpenFormula := (somePast φ.neg).neg

/-- Conjunction (`φ ∧ ψ`): `¬(φ → ¬ψ)`. Mirrors `PlusFormula.and`. -/
def and (φ ψ : OpenFormula) : OpenFormula := (φ.imp ψ.neg).neg

/-- Disjunction (`φ ∨ ψ`): `¬φ → ψ`. Mirrors `PlusFormula.or`. -/
def or (φ ψ : OpenFormula) : OpenFormula := φ.neg.imp ψ

/-- Biconditional (`φ ↔ ψ`): `(φ → ψ) ∧ (ψ → φ)`. Mirrors `PlusFormula.iff`. -/
def iff (φ ψ : OpenFormula) : OpenFormula := (φ.imp ψ).and (ψ.imp φ)

/-- Modal possibility (`◇φ`): `¬□¬φ`. Mirrors `PlusFormula.diamond`. -/
def diamond (φ : OpenFormula) : OpenFormula := φ.neg.box.neg

/-- Temporal `always` (`△φ`): `Hφ ∧ (φ ∧ Gφ)`. Mirrors `PlusFormula.always`. -/
def always (φ : OpenFormula) : OpenFormula := φ.allPast.and (φ.and φ.allFuture)

/-- Temporal `sometimes` (`▽φ`): `¬△¬φ`. Mirrors `PlusFormula.sometimes`. -/
def sometimes (φ : OpenFormula) : OpenFormula := φ.neg.always.neg

/-- The dual stability modal `⟐φ := ¬⊡¬φ` (`sub:RestrictedModalities`). Mirrors
`PlusFormula.dstab`. -/
def dstab (φ : OpenFormula) : OpenFormula := neg (.stab (neg φ))

/-! ### The duals of the new operators -/

/-- The dual open-future modal `▷̂φ := ¬▷¬φ`: `φ` holds in *some* world that agrees with the world
of evaluation up to and including the time of evaluation. -/
def dofut (φ : OpenFormula) : OpenFormula := neg (.ofut (neg φ))

/-- The dual open-past modal `◁̂φ := ¬◁¬φ`: `φ` holds in *some* world that agrees with the world
of evaluation from the time of evaluation onward. -/
def dopast (φ : OpenFormula) : OpenFormula := neg (.opast (neg φ))

/-! ### Time reflection -/

/--
Reflect time (past ↔ future) in an L^▷ formula.

Mirrors `PlusFormula.reflectTime` on the seven shared constructors. The two new cases exchange
the open-future and open-past modals, exactly as `untl` and `snce` are exchanged: `|τ⟩_x` and
`⟨τ|_x` are defined by one condition read on the two sides of `x`.
-/
def reflectTime : OpenFormula → OpenFormula
  | atom s => atom s
  | bot => bot
  | imp φ ψ => imp φ.reflectTime ψ.reflectTime
  | box φ => box φ.reflectTime
  | untl ψ φ => snce ψ.reflectTime φ.reflectTime
  | snce ψ φ => untl ψ.reflectTime φ.reflectTime
  | stab φ => stab φ.reflectTime
  | ofut φ => opast φ.reflectTime
  | opast φ => ofut φ.reflectTime

/-- `reflectTime` is an involution. -/
theorem reflect_time_involution (φ : OpenFormula) :
    φ.reflectTime.reflectTime = φ := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp _ _ ihp ihq => simp only [reflectTime, ihp, ihq]
  | box _ ih => simp only [reflectTime, ih]
  | untl _ _ ih2 ih1 => simp only [reflectTime, ih1, ih2]
  | snce _ _ ih2 ih1 => simp only [reflectTime, ih1, ih2]
  | stab _ ih => simp only [reflectTime, ih]
  | ofut _ ih => simp only [reflectTime, ih]
  | opast _ ih => simp only [reflectTime, ih]

/-! The push-through lemmas the mirror theorems use; each holds by `rfl`. -/

@[simp]
theorem reflect_time_somePast (φ : OpenFormula) :
    (somePast φ).reflectTime = someFuture φ.reflectTime := rfl

@[simp]
theorem reflect_time_someFuture (φ : OpenFormula) :
    (someFuture φ).reflectTime = somePast φ.reflectTime := rfl

/-- `reflectTime` sends the open-future dual to the open-past dual. -/
@[simp]
theorem reflect_time_dofut (φ : OpenFormula) :
    (dofut φ).reflectTime = dopast φ.reflectTime := rfl

/-- `reflectTime` sends the open-past dual to the open-future dual. -/
@[simp]
theorem reflect_time_dopast (φ : OpenFormula) :
    (dopast φ).reflectTime = dofut φ.reflectTime := rfl

/-- `reflectTime` fixes `⟐`, as it fixes `⊡`. -/
@[simp]
theorem reflect_time_dstab (φ : OpenFormula) :
    (dstab φ).reflectTime = dstab φ.reflectTime := rfl

end OpenFormula

/-! ## The embedding of L⁺ into L^▷ -/

/-- The embedding of L⁺ into L^▷, constructor to constructor. -/
def ofPlus : PlusFormula → OpenFormula
  | .atom a => .atom a
  | .bot => .bot
  | .imp φ ψ => .imp (ofPlus φ) (ofPlus ψ)
  | .box φ => .box (ofPlus φ)
  | .untl φ ψ => .untl (ofPlus φ) (ofPlus ψ)
  | .snce φ ψ => .snce (ofPlus φ) (ofPlus ψ)
  | .stab φ => .stab (ofPlus φ)

/-- `ofPlus` is injective. Per-constructor `cases` on the target with the induction hypotheses
applied by `rw`, exactly as `ofFormula_injective` does. -/
theorem ofPlus_injective : Function.Injective ofPlus := by
  intro φ ψ h
  induction φ generalizing ψ with
  | atom a => cases ψ <;> simp_all [ofPlus]
  | bot => cases ψ <;> simp_all [ofPlus]
  | imp φ₁ φ₂ ih₁ ih₂ =>
    cases ψ <;> simp only [ofPlus, reduceCtorEq, OpenFormula.imp.injEq] at h
    rw [ih₁ h.1, ih₂ h.2]
  | box φ ih =>
    cases ψ <;> simp only [ofPlus, reduceCtorEq, OpenFormula.box.injEq] at h
    rw [ih h]
  | untl φ₁ φ₂ ih₁ ih₂ =>
    cases ψ <;> simp only [ofPlus, reduceCtorEq, OpenFormula.untl.injEq] at h
    rw [ih₁ h.1, ih₂ h.2]
  | snce φ₁ φ₂ ih₁ ih₂ =>
    cases ψ <;> simp only [ofPlus, reduceCtorEq, OpenFormula.snce.injEq] at h
    rw [ih₁ h.1, ih₂ h.2]
  | stab φ ih =>
    cases ψ <;> simp only [ofPlus, reduceCtorEq, OpenFormula.stab.injEq] at h
    rw [ih h]

/-- `ofPlus` commutes with time reflection. -/
theorem ofPlus_reflectTime (φ : PlusFormula) :
    ofPlus φ.reflectTime = (ofPlus φ).reflectTime := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp _ _ ih1 ih2 =>
    simp only [PlusFormula.reflectTime, ofPlus, OpenFormula.reflectTime, ih1, ih2]
  | box _ ih => simp only [PlusFormula.reflectTime, ofPlus, OpenFormula.reflectTime, ih]
  | untl _ _ ih1 ih2 =>
    simp only [PlusFormula.reflectTime, ofPlus, OpenFormula.reflectTime, ih1, ih2]
  | snce _ _ ih1 ih2 =>
    simp only [PlusFormula.reflectTime, ofPlus, OpenFormula.reflectTime, ih1, ih2]
  | stab _ ih => simp only [PlusFormula.reflectTime, ofPlus, OpenFormula.reflectTime, ih]

/-! ### `rfl` pins

`ofPlus` commutes with every derived operator **definitionally**, because each L^▷ operator was
given `PlusFormula`'s right-hand side verbatim. If one of these stops being `rfl`, the fix is in
the operator's right-hand side above, never at the use site. -/

example : ofPlus PlusFormula.top = OpenFormula.top := rfl
example (φ : PlusFormula) : ofPlus φ.neg = (ofPlus φ).neg := rfl
example (φ ψ : PlusFormula) : ofPlus (φ.and ψ) = (ofPlus φ).and (ofPlus ψ) := rfl
example (φ ψ : PlusFormula) : ofPlus (φ.or ψ) = (ofPlus φ).or (ofPlus ψ) := rfl
example (φ ψ : PlusFormula) : ofPlus (φ.iff ψ) = (ofPlus φ).iff (ofPlus ψ) := rfl
example (φ : PlusFormula) : ofPlus φ.diamond = (ofPlus φ).diamond := rfl
example (φ : PlusFormula) :
    ofPlus (PlusFormula.someFuture φ) = OpenFormula.someFuture (ofPlus φ) := rfl
example (φ : PlusFormula) :
    ofPlus (PlusFormula.somePast φ) = OpenFormula.somePast (ofPlus φ) := rfl
example (φ : PlusFormula) :
    ofPlus (PlusFormula.allFuture φ) = OpenFormula.allFuture (ofPlus φ) := rfl
example (φ : PlusFormula) :
    ofPlus (PlusFormula.allPast φ) = OpenFormula.allPast (ofPlus φ) := rfl
example (φ : PlusFormula) : ofPlus (PlusFormula.always φ) = OpenFormula.always (ofPlus φ) := rfl
example (φ : PlusFormula) :
    ofPlus (PlusFormula.sometimes φ) = OpenFormula.sometimes (ofPlus φ) := rfl
example (φ : PlusFormula) : ofPlus (PlusFormula.dstab φ) = OpenFormula.dstab (ofPlus φ) := rfl

end FormalSystem.OpenLanguage
