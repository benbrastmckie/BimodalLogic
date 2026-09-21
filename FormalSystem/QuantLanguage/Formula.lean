/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.Formula

/-!
# `QuantFormula` — the base language plus propositional quantifiers

This module defines the **propositional-quantifier language** obtained from the base language L
(`FormalSystem/Syntax/Formula.lean`) by adding one primitive binder:

```
φ, ψ ::= pᵢ | ⊥ | φ → ψ | □φ | φ U ψ | φ S ψ | ∀p φ
```

`∀p φ` (`all p φ`) binds the sentence letter `p`. This file is syntax only; the truth clauses,
and the family of propositions the quantifier ranges over, are in
`QuantLanguage/QuantTruth.lean`.

## Design

`QuantFormula` is a **separate inductive** with a constructor-to-constructor embedding
`QuantFormula.ofFormula : Formula → QuantFormula`, following `PlusFormula.ofFormula`. No
constructor is added to `Formula`. Every derived operator below has the **same right-hand side**
as its `Formula` namesake, so that `ofFormula` pushes through each of them by `rfl` and the
abstract clause lemmas of `Semantics/TruthClauses.lean` are inherited without a `show`.

The bound variable of `all` is an `Atom`, the library's type of sentence letters, so that the
quantifier re-interprets a letter of the model rather than a separate sort of variable. The atom
formula `isAtom p q` therefore takes its bound letter `q` as an explicit argument, and the results
about it carry the hypothesis `p ≠ q`.

## Main Definitions

- `QuantFormula`: seven-constructor inductive type
- Derived operators with `Formula`'s right-hand sides: `top`, `neg`, `someFuture`, `somePast`,
  `allFuture`, `allPast`, `and`, `or`, `diamond`, `always`, `sometimes`
- `QuantFormula.univ` (`A φ := □△φ`, the universal modality) and `QuantFormula.exist`
  (`E φ := ¬A¬φ`)
- `QuantFormula.isAtom p q` — the atom formula `E p ∧ ∀q (A(p → q) ∨ A(p → ¬q))`
- `QuantFormula.qRec p q` — the quantified recurrence sentence
  `∀p (Atom(p) → ¬(p ∧ (P p ∨ F p)))`
- `QuantFormula.ofFormula` — the embedding of L

## Main Results

- `DecidableEq`, `Countable` for `QuantFormula`
- `QuantFormula.ofFormula_injective` and the `rfl` commutation pins

## Module Invariant

**This file imports nothing from `FormalSystem/Semantics/` and no semantic module of any
language.** It is the syntax half of the component; `scripts/check-metalogic-cycles.sh` checks the
edge.

## References

* JPL paper `def:BL-semantics` — the base language and its clauses
* `FormalSystem/Syntax/Formula.lean` — the base language whose derived operators are mirrored
* `FormalSystem/PlusLanguage/Formula.lean` — `PlusFormula.ofFormula`, the pattern followed

## Tags

quant-language · syntax · propositional-quantifier
-/

namespace FormalSystem.QuantLanguage

open FormalSystem.Syntax

/--
Formula type for the propositional-quantifier language: the six constructors of `Formula` plus the
propositional quantifier.

Constructor order and argument order (guard first, event second for `untl`/`snce`) are those of
`Formula`, so that `ofFormula` is constructor-to-constructor.

Paper: — (formalization-native; the paper's languages have no propositional quantifiers)
-/
inductive QuantFormula : Type where
  /-- Propositional atom (variable). -/
  | atom : Atom → QuantFormula
  /-- Bottom (`⊥`, falsum). -/
  | bot : QuantFormula
  /-- Implication (`φ → ψ`). -/
  | imp : QuantFormula → QuantFormula → QuantFormula
  /-- Modal necessity (`□φ`). -/
  | box : QuantFormula → QuantFormula
  /-- Until, `φ U ψ`, guard first and event second, exactly as `Formula.untl`. -/
  | untl : QuantFormula → QuantFormula → QuantFormula
  /-- Since, `φ S ψ`, guard first and event second, exactly as `Formula.snce`. -/
  | snce : QuantFormula → QuantFormula → QuantFormula
  /-- The propositional quantifier `∀p φ`: `φ` holds however the letter `p` is re-interpreted by
  an admissible proposition. -/
  | all : Atom → QuantFormula → QuantFormula
  deriving Repr, DecidableEq, Countable

namespace QuantFormula

/-! ### Derived operators

Each right-hand side is copied verbatim from `Syntax/Formula.lean`, so that `ofFormula` commutes
with it by `rfl` (see the pins at the end of the file). -/

/-- Top (`⊤`): `⊥ → ⊥`. Mirrors `Formula.top`. -/
def top : QuantFormula := QuantFormula.bot.imp QuantFormula.bot

/-- Negation (`¬φ`): `φ → ⊥`. Mirrors `Formula.neg`. -/
def neg (φ : QuantFormula) : QuantFormula := φ.imp bot

/-- Existential future (`Fφ`): `⊤ U φ`. Mirrors `Formula.someFuture`. -/
def someFuture (φ : QuantFormula) : QuantFormula := QuantFormula.untl QuantFormula.top φ

/-- Existential past (`Pφ`): `⊤ S φ`. Mirrors `Formula.somePast`. -/
def somePast (φ : QuantFormula) : QuantFormula := QuantFormula.snce QuantFormula.top φ

/-- Universal future (`Gφ`): `¬F¬φ`. Mirrors `Formula.allFuture`. -/
def allFuture (φ : QuantFormula) : QuantFormula := (someFuture φ.neg).neg

/-- Universal past (`Hφ`): `¬P¬φ`. Mirrors `Formula.allPast`. -/
def allPast (φ : QuantFormula) : QuantFormula := (somePast φ.neg).neg

/-- Conjunction (`φ ∧ ψ`): `¬(φ → ¬ψ)`. Mirrors `Formula.and`. -/
def and (φ ψ : QuantFormula) : QuantFormula := (φ.imp ψ.neg).neg

/-- Disjunction (`φ ∨ ψ`): `¬φ → ψ`. Mirrors `Formula.or`. -/
def or (φ ψ : QuantFormula) : QuantFormula := φ.neg.imp ψ

/-- Modal possibility (`◇φ`): `¬□¬φ`. Mirrors `Formula.diamond`. -/
def diamond (φ : QuantFormula) : QuantFormula := φ.neg.box.neg

/-- Temporal `always` (`△φ`): `Hφ ∧ (φ ∧ Gφ)`. Mirrors `Formula.always`. -/
def always (φ : QuantFormula) : QuantFormula := φ.allPast.and (φ.and φ.allFuture)

/-- Temporal `sometimes` (`▽φ`): `¬△¬φ`. Mirrors `Formula.sometimes`. -/
def sometimes (φ : QuantFormula) : QuantFormula := φ.neg.always.neg

/-! ### The universal modality and the two defining formulas -/

/-- The universal modality `A φ := □△φ`: `φ` at every history and every time. Definable because
world histories are total. -/
def univ (φ : QuantFormula) : QuantFormula := φ.always.box

/-- The existential modality `E φ := ¬A¬φ`. -/
def exist (φ : QuantFormula) : QuantFormula := (univ φ.neg).neg

/-- The **atom formula** `Atom(p) := E p ∧ ∀q (A(p → q) ∨ A(p → ¬q))`: `p` is true somewhere, and
every proposition is settled one way or the other throughout `p`. The bound letter `q` must differ
from `p`. -/
def isAtom (p q : Atom) : QuantFormula :=
  (exist (atom p)).and (all q ((univ ((atom p).imp (atom q))).or
    (univ ((atom p).imp (atom q).neg))))

/-- The **quantified recurrence sentence** `∀p (Atom(p) → ¬(p ∧ (P p ∨ F p)))`: no proposition
that names a world state is true now and at another time of the present history. -/
def qRec (p q : Atom) : QuantFormula :=
  all p ((isAtom p q).imp ((atom p).and ((somePast (atom p)).or (someFuture (atom p)))).neg)

/-! ## The embedding of L -/

/-- The embedding of the base language, constructor to constructor. -/
def ofFormula : Formula → QuantFormula
  | .atom p => .atom p
  | .bot => .bot
  | .imp φ ψ => .imp (ofFormula φ) (ofFormula ψ)
  | .box φ => .box (ofFormula φ)
  | .untl ψ φ => .untl (ofFormula ψ) (ofFormula φ)
  | .snce ψ φ => .snce (ofFormula ψ) (ofFormula φ)

/-- `ofFormula` is injective. Per-constructor `cases` on the target with the induction hypotheses
applied by `rw`, exactly as `PlusFormula.ofFormula_injective` does. -/
theorem ofFormula_injective : Function.Injective ofFormula := by
  intro φ ψ h
  induction φ generalizing ψ with
  | atom a => cases ψ <;> simp_all [ofFormula]
  | bot => cases ψ <;> simp_all [ofFormula]
  | imp φ₁ φ₂ ih₁ ih₂ =>
    cases ψ <;> simp only [ofFormula, reduceCtorEq, QuantFormula.imp.injEq] at h
    rw [ih₁ h.1, ih₂ h.2]
  | box φ ih =>
    cases ψ <;> simp only [ofFormula, reduceCtorEq, QuantFormula.box.injEq] at h
    rw [ih h]
  | untl φ₁ φ₂ ih₁ ih₂ =>
    cases ψ <;> simp only [ofFormula, reduceCtorEq, QuantFormula.untl.injEq] at h
    rw [ih₁ h.1, ih₂ h.2]
  | snce φ₁ φ₂ ih₁ ih₂ =>
    cases ψ <;> simp only [ofFormula, reduceCtorEq, QuantFormula.snce.injEq] at h
    rw [ih₁ h.1, ih₂ h.2]

/-! ### `rfl` pins

`ofFormula` commutes with every derived operator **definitionally**, because each operator above
was given `Formula`'s right-hand side verbatim. If one of these stops being `rfl`, the fix is in
the operator's right-hand side above, never at the use site. -/

example : ofFormula Formula.top = QuantFormula.top := rfl
example (φ : Formula) : ofFormula φ.neg = (ofFormula φ).neg := rfl
example (φ ψ : Formula) : ofFormula (φ.and ψ) = (ofFormula φ).and (ofFormula ψ) := rfl
example (φ ψ : Formula) : ofFormula (φ.or ψ) = (ofFormula φ).or (ofFormula ψ) := rfl
example (φ : Formula) : ofFormula φ.diamond = (ofFormula φ).diamond := rfl
example (φ : Formula) : ofFormula φ.someFuture = (ofFormula φ).someFuture := rfl
example (φ : Formula) : ofFormula φ.somePast = (ofFormula φ).somePast := rfl
example (φ : Formula) : ofFormula φ.allFuture = (ofFormula φ).allFuture := rfl
example (φ : Formula) : ofFormula φ.allPast = (ofFormula φ).allPast := rfl
example (φ : Formula) : ofFormula φ.always = (ofFormula φ).always := rfl
example (φ : Formula) : ofFormula φ.sometimes = (ofFormula φ).sometimes := rfl
example (φ : Formula) : ofFormula φ.always.box = (ofFormula φ).univ := rfl

end QuantFormula

end FormalSystem.QuantLanguage
