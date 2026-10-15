/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.Formula

/-!
# `NomicFormula` — the language of BL plus the nomic operator

This module defines the language obtained from BL (`FormalSystem/Syntax/Formula.lean`) by adding
one primitive unary operator, the **nomic** modal `◈` (`nomic`):

```
φ, ψ ::= pᵢ | ⊥ | φ → ψ | □φ | φ U ψ | φ S ψ | ◈φ
```

The manuscript's subsection *Restricted Modalities* (`sub:RestrictedModalities`) introduces it
beside the open-future and open-past modals, and `def:nomic-frame`'s item *Nomological Necessity*
gives its clause: `◈φ` holds at `(τ, x)` iff `φ` holds at `(σ, x)` for every law-history `σ` at
the state `τ` occupies at `x`. This file is syntax only; the truth clauses are in
`NomicLanguage/NomicTruth.lean`.

## Design

`NomicFormula` is a **separate inductive** with a constructor-to-constructor embedding
`ofFormula : Formula → NomicFormula`, following `FormalSystem/OpenLanguage/Formula.lean`. No
constructor is added to `Formula`: that would change the type every existing BL and BL⁺ theorem is
stated at. Every derived operator below has the **same right-hand side** as its `Formula`
namesake, so that `ofFormula` pushes through each of them by `rfl`.

The **stability modal `⊡` is deliberately absent.** `prop:nomic-tense-free`'s fragment is exactly
`{pᵢ, ⊥, →, □, ◈}`, and the three results this component formalizes are stated in BL plus `◈`.
Adding `⊡` would force a decision the paper does not make — whether `⊡` belongs in the tense-free
fragment — and would add a state-set clause for no result in scope. See
`FormalSystem/NomicLanguage/README.md`, which records this and the component's two other
exclusions with their reasons.

## Main Definitions

- `NomicFormula`: seven-constructor inductive type for BL plus `◈`
- Derived operators with `Formula`'s right-hand sides: `top`, `neg`, `someFuture`, `somePast`,
  `allFuture`, `allPast`, `and`, `or`, `iff`, `diamond`, `always`, `next`
- `ofFormula`: the embedding of BL into this language

## Main Results

- `DecidableEq`, `Countable` for `NomicFormula`
- `ofFormula_injective`, and the `rfl` commutation pins for the derived operators

## Module Invariant

**This file imports nothing from `FormalSystem/Semantics/` and no semantic module of any
language.** It is the syntax half of the component; `scripts/check-metalogic-cycles.sh` assertion
C checks the edge, reading its directory set off `LANGUAGE_FILE_LAYERS` in
`scripts/measure-refactor-partitions.py`.

## References

* JPL paper `sub:RestrictedModalities` — the nomic operator, beside the two open modals
* JPL paper `def:nomic-frame` — the operator's clause, formalized in `NomicTruth.lean`
* JPL paper `prop:nomic-tense-free` — the fragment that fixes this constructor set
* `FormalSystem/Syntax/Formula.lean` — the BL side whose derived operators are mirrored
* `FormalSystem/OpenLanguage/Formula.lean` — the semantic-only component precedent followed here

## Tags

nomic-language · syntax · nomic-operator
-/

namespace FormalSystem.NomicLanguage

open FormalSystem.Syntax

/--
Formula type for BL plus the nomic operator: the six constructors of `Formula` plus `nomic`.

Constructor order and argument order (guard first, event second for `untl`/`snce`) are those of
`Formula`, so that `ofFormula` is constructor-to-constructor.
-/
inductive NomicFormula : Type where
  /-- Propositional atom (variable). -/
  | atom : Atom → NomicFormula
  /-- Bottom (`⊥`, falsum). -/
  | bot : NomicFormula
  /-- Implication (`φ → ψ`). -/
  | imp : NomicFormula → NomicFormula → NomicFormula
  /-- Modal necessity (`□φ`). -/
  | box : NomicFormula → NomicFormula
  /-- Until, `φ U ψ`, guard first and event second, exactly as `Formula.untl`. -/
  | untl : NomicFormula → NomicFormula → NomicFormula
  /-- Since, `φ S ψ`, guard first and event second, exactly as `Formula.snce`. -/
  | snce : NomicFormula → NomicFormula → NomicFormula
  /-- The nomic modal `◈φ` (`def:nomic-frame`, *Nomological Necessity*): `φ` holds along every
  law-history at the world state occupied at the time of evaluation. -/
  | nomic : NomicFormula → NomicFormula
  deriving Repr, DecidableEq, Countable

namespace NomicFormula

/-! ### Derived operators

Each right-hand side is copied verbatim from `Syntax/Formula.lean`, so that `ofFormula` commutes
with it by `rfl` (see the pins at the end of the file). -/

/-- Top (`⊤`): `⊥ → ⊥`. Mirrors `Formula.top`. -/
def top : NomicFormula := NomicFormula.bot.imp NomicFormula.bot

/-- Negation (`¬φ`): `φ → ⊥`. Mirrors `Formula.neg`. -/
def neg (φ : NomicFormula) : NomicFormula := φ.imp bot

/-- Existential future (`Fφ`): `⊤ U φ`. Mirrors `Formula.someFuture`. -/
def someFuture (φ : NomicFormula) : NomicFormula := NomicFormula.untl NomicFormula.top φ

/-- Existential past (`Pφ`): `⊤ S φ`. Mirrors `Formula.somePast`. -/
def somePast (φ : NomicFormula) : NomicFormula := NomicFormula.snce NomicFormula.top φ

/-- Universal future (`Gφ`): `¬F¬φ`. Mirrors `Formula.allFuture`. -/
def allFuture (φ : NomicFormula) : NomicFormula := (someFuture φ.neg).neg

/-- Universal past (`Hφ`): `¬P¬φ`. Mirrors `Formula.allPast`. -/
def allPast (φ : NomicFormula) : NomicFormula := (somePast φ.neg).neg

/-- Conjunction (`φ ∧ ψ`): `¬(φ → ¬ψ)`. Mirrors `Formula.and`. -/
def and (φ ψ : NomicFormula) : NomicFormula := (φ.imp ψ.neg).neg

/-- Disjunction (`φ ∨ ψ`): `¬φ → ψ`. Mirrors `Formula.or`. -/
def or (φ ψ : NomicFormula) : NomicFormula := φ.neg.imp ψ

/-- Biconditional (`φ ↔ ψ`): `(φ → ψ) ∧ (ψ → φ)`. Mirrors `PlusFormula.iff`, the same right-hand
side BL's own defined biconditional has. -/
def iff (φ ψ : NomicFormula) : NomicFormula := (φ.imp ψ).and (ψ.imp φ)

/-- Modal possibility (`◇φ`): `¬□¬φ`. Mirrors `Formula.diamond`. -/
def diamond (φ : NomicFormula) : NomicFormula := φ.neg.box.neg

/-- Temporal `always` (`△φ`): `Hφ ∧ (φ ∧ Gφ)`. Mirrors `Formula.always`. The witness sentence of
`app:nomic-four` is built from this and `next`. -/
def always (φ : NomicFormula) : NomicFormula := φ.allPast.and (φ.and φ.allFuture)

/-- Next-step operator (`◯φ`): `⊥ U φ`. Mirrors `Formula.next`. `OpenFormula` has no `next`, so
the right-hand side is copied from `Formula` rather than from the component precedent. -/
def next (φ : NomicFormula) : NomicFormula := NomicFormula.untl NomicFormula.bot φ

end NomicFormula

/-! ## The embedding of BL into the nomic language -/

/-- The embedding of BL into BL plus `◈`, constructor to constructor. -/
def ofFormula : Formula → NomicFormula
  | .atom a => .atom a
  | .bot => .bot
  | .imp φ ψ => .imp (ofFormula φ) (ofFormula ψ)
  | .box φ => .box (ofFormula φ)
  | .untl φ ψ => .untl (ofFormula φ) (ofFormula ψ)
  | .snce φ ψ => .snce (ofFormula φ) (ofFormula ψ)

/--
`ofFormula` is injective. Per-constructor `cases` on the target with the induction hypotheses
applied by `rw`, exactly as `OpenLanguage.ofPlus_injective` does.

**No result in this component consumes it, and it is kept anyway.** It is what makes "this
language extends BL" a theorem rather than a claim in prose; C17's dead-declaration scan is
reporting-only, so keeping it costs nothing a gate measures. Truth-level conservativity, by
contrast, is **not statable** here — see `FormalSystem/NomicLanguage/README.md`.
-/
theorem ofFormula_injective : Function.Injective ofFormula := by
  intro φ ψ h
  induction φ generalizing ψ with
  | atom a => cases ψ <;> simp_all [ofFormula]
  | bot => cases ψ <;> simp_all [ofFormula]
  | imp φ₁ φ₂ ih₁ ih₂ =>
    cases ψ <;> simp only [ofFormula, reduceCtorEq, NomicFormula.imp.injEq] at h
    rw [ih₁ h.1, ih₂ h.2]
  | box φ ih =>
    cases ψ <;> simp only [ofFormula, reduceCtorEq, NomicFormula.box.injEq] at h
    rw [ih h]
  | untl φ₁ φ₂ ih₁ ih₂ =>
    cases ψ <;> simp only [ofFormula, reduceCtorEq, NomicFormula.untl.injEq] at h
    rw [ih₁ h.1, ih₂ h.2]
  | snce φ₁ φ₂ ih₁ ih₂ =>
    cases ψ <;> simp only [ofFormula, reduceCtorEq, NomicFormula.snce.injEq] at h
    rw [ih₁ h.1, ih₂ h.2]

/-! ### `rfl` pins

`ofFormula` commutes with every derived operator **definitionally**, because each operator above
was given `Formula`'s right-hand side verbatim. If one of these stops being `rfl`, the fix is in
the operator's right-hand side above, never at the use site. -/

example : ofFormula Formula.top = NomicFormula.top := rfl
example (φ : Formula) : ofFormula φ.neg = (ofFormula φ).neg := rfl
example (φ ψ : Formula) : ofFormula (φ.and ψ) = (ofFormula φ).and (ofFormula ψ) := rfl
example (φ ψ : Formula) : ofFormula (φ.or ψ) = (ofFormula φ).or (ofFormula ψ) := rfl
example (φ : Formula) : ofFormula φ.diamond = (ofFormula φ).diamond := rfl
example (φ : Formula) :
    ofFormula (Formula.someFuture φ) = NomicFormula.someFuture (ofFormula φ) := rfl
example (φ : Formula) : ofFormula (Formula.somePast φ) = NomicFormula.somePast (ofFormula φ) := rfl
example (φ : Formula) :
    ofFormula (Formula.allFuture φ) = NomicFormula.allFuture (ofFormula φ) := rfl
example (φ : Formula) : ofFormula (Formula.allPast φ) = NomicFormula.allPast (ofFormula φ) := rfl
example (φ : Formula) : ofFormula (Formula.always φ) = NomicFormula.always (ofFormula φ) := rfl
example (φ : Formula) : ofFormula (Formula.next φ) = NomicFormula.next (ofFormula φ) := rfl

end FormalSystem.NomicLanguage
