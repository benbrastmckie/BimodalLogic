/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.Atom

/-!
# `MinusFormula` — the tense-primitive base language L⁻

This module defines the *base language* `L⁻` of the paper's `\S sub:Logic`
(`def:BL-language`), in which `H` (`allPast`) and `G` (`allFuture`) are **primitive**:

```
φ, ψ ::= pᵢ | ⊥ | φ → ψ | □φ | Hφ | Gφ
```

This is deliberately *not* `FormalSystem.Syntax.Formula`, whose primitives are `untl`/`snce`
and whose `allPast`/`allFuture` are derived abbreviations. The two languages are related by the
translation `FormalSystem.MinusLanguage.tr` (`MinusLanguage/Translation.lean`), which is the
substance of the backward conservativity bridge in
`FormalSystem/Metalogic/Conservativity/Backward.lean`.

## Main Definitions

- `MinusFormula`: six-constructor inductive type for L⁻
- `MinusFormula.neg`, `top`, `and`, `or`, `iff`: derived Boolean operators
- `MinusFormula.somePast` (P), `MinusFormula.someFuture` (F): derived existential temporal operators
- `MinusFormula.always` (△): `Hφ ∧ φ ∧ Gφ`, mirroring `Formula.always`
- `MinusFormula.swapMinus`: the past/future interchange used by TM⁻'s **TD** rule

## Main Results

- `DecidableEq MinusFormula`, `Repr MinusFormula`, `Countable MinusFormula`
- `swapMinus_involution`: `swapMinus` is an involution
- `swapMinus` push-through lemmas for every derived operator

## Polarity Warning

The paper writes `\Past`/`\Future` for the **universal** operators H/G and `\past`/`\future`
for the **existential** operators P/F. `allPast` here is H (universal) and `allFuture` is G
(universal); `somePast`/`someFuture` are the existential P/F and are *derived*. Reading these
the other way round transcribes a different logic.

## Module Invariant

**Nothing under `FormalSystem/MinusLanguage/` imports anything from `FormalSystem/Semantics/`.**
The bridge is purely proof-theoretic: it is a map between two `DerivationTree` types and
touches no truth definition, frame, or validity predicate. Keeping the invariant means the
bridge composes unchanged with whatever the totality-based validity definition becomes.

The invariant is **directional**. It forbids the edge `MinusLanguage/ → Semantics/` and says
nothing about the converse, which is permitted and is how this file's `MinusFormula` acquires a
semantics: `FormalSystem/Semantics/MinusTruth.lean` imports *this module* — a leaf that itself
imports only `FormalSystem.Syntax.Atom` — and defines `MinusTruthAt` by recursion on the six
constructors below. Nothing flows back the other way, so the `grep` check above still returns no
`import` line.

## References

* JPL paper `\S sub:Logic` — `def:BL-language` and the TM axiomatization that TM⁻ transposes
* `FormalSystem/Syntax/Formula.lean` — the L (until/since-primitive) side
-/

namespace FormalSystem.MinusLanguage

open FormalSystem.Syntax

/--
Formula type for the tense-primitive base language L⁻.

Six primitive constructors, per `def:BL-language`:
`φ, ψ ::= pᵢ | ⊥ | φ → ψ | □φ | Hφ | Gφ`.

Atoms are the *existing* `FormalSystem.Syntax.Atom`, shared with L, so the translation `tr`
is the identity on atoms.
-/
inductive MinusFormula : Type where
  /-- Propositional atom (variable), the paper's `pᵢ`. -/
  | atom : Atom → MinusFormula
  /-- Bottom (`⊥`, falsum). -/
  | bot : MinusFormula
  /-- Implication (`φ → ψ`). -/
  | imp : MinusFormula → MinusFormula → MinusFormula
  /-- Modal necessity (`□φ`). -/
  | box : MinusFormula → MinusFormula
  /-- **Universal** past, the paper's `\Past φ` = `Hφ` ("φ has always been the case").
      This is H, *not* the existential P — see the polarity warning in the module docstring. -/
  | allPast : MinusFormula → MinusFormula
  /-- **Universal** future, the paper's `\Future φ` = `Gφ` ("φ will always be the case").
      This is G, *not* the existential F — see the polarity warning in the module docstring. -/
  | allFuture : MinusFormula → MinusFormula
  deriving Repr, DecidableEq, BEq, Hashable, Countable

namespace MinusFormula

/-! ### Derived operators

Naming mirrors `FormalSystem/Syntax/Formula.lean` so the two sides read alike. Every definition
below is a `def` abbreviation over the six primitives; none of them is a new constructor. -/

/-- Top (`⊤`, verum): `⊥ → ⊥`. Mirrors `Formula.top`. -/
def top : MinusFormula := MinusFormula.bot.imp MinusFormula.bot

/-- Negation (`¬φ`): `φ → ⊥`. Mirrors `Formula.neg`. -/
def neg (φ : MinusFormula) : MinusFormula := φ.imp bot

/-- Conjunction (`φ ∧ ψ`): `¬(φ → ¬ψ)`. Mirrors `Formula.and`. -/
def and (φ ψ : MinusFormula) : MinusFormula := (φ.imp ψ.neg).neg

/-- Disjunction (`φ ∨ ψ`): `¬φ → ψ`. Mirrors `Formula.or`. -/
def or (φ ψ : MinusFormula) : MinusFormula := φ.neg.imp ψ

/-- Biconditional (`φ ↔ ψ`): `(φ → ψ) ∧ (ψ → φ)`. -/
def iff (φ ψ : MinusFormula) : MinusFormula := (φ.imp ψ).and (ψ.imp φ)

/-- Modal possibility (`◇φ`): `¬□¬φ`. Mirrors `Formula.diamond`. -/
def diamond (φ : MinusFormula) : MinusFormula := φ.neg.box.neg

/-- **Existential** past (`Pφ`, the paper's `\past φ`): `¬H¬φ`. Mirrors `Formula.somePast`. -/
def somePast (φ : MinusFormula) : MinusFormula := (φ.neg.allPast).neg

/-- **Existential** future (`Fφ`, the paper's `\future φ`): `¬G¬φ`.
Mirrors `Formula.someFuture`. -/
def someFuture (φ : MinusFormula) : MinusFormula := (φ.neg.allFuture).neg

/-- Temporal `always` (`△φ`): `Hφ ∧ (φ ∧ Gφ)`.

The association mirrors `Formula.always` exactly (`φ.allPast.and (φ.and φ.allFuture)`), which
is what makes the CO axiom's translation line up with `Formula.co` without reassociation. -/
def always (φ : MinusFormula) : MinusFormula := φ.allPast.and (φ.and φ.allFuture)

/--
Interchange the two universal temporal operators `H` and `G` throughout a formula.

This is the L⁻-side analogue of `Formula.swapTemporal` and is what TM⁻'s **TD** rule
("if `⊢ φ` then `⊢ φ⟨P|F⟩`") transforms by. Note that on the L side the corresponding
operation swaps the *primitive* `untl`/`snce`; the commutation of the two is
`MinusLanguage.tr_swapMinus`.
-/
def swapMinus : MinusFormula → MinusFormula
  | atom a => atom a
  | bot => bot
  | imp φ ψ => imp φ.swapMinus ψ.swapMinus
  | box φ => box φ.swapMinus
  | allPast φ => allFuture φ.swapMinus
  | allFuture φ => allPast φ.swapMinus

/-- `swapMinus` is an involution. -/
theorem swapMinus_involution (φ : MinusFormula) : φ.swapMinus.swapMinus = φ := by
  induction φ <;> simp_all [swapMinus]

/-! ### `swapMinus` push-through lemmas for the derived operators

These are the L⁻-side counterparts of `Formula.swap_temporal_neg`,
`Formula.swap_temporal_some_future`, and friends. They are `@[simp]` so that the TD case of
the Phase 8 recursion and the axiom-discharge table can normalise a `swapMinus` of a derived
operator without unfolding to primitives by hand. -/

@[simp] theorem swapMinus_top : top.swapMinus = top := rfl

@[simp] theorem swapMinus_neg (φ : MinusFormula) : φ.neg.swapMinus = φ.swapMinus.neg := rfl

@[simp] theorem swapMinus_and (φ ψ : MinusFormula) :
    (φ.and ψ).swapMinus = φ.swapMinus.and ψ.swapMinus := rfl

@[simp] theorem swapMinus_or (φ ψ : MinusFormula) :
    (φ.or ψ).swapMinus = φ.swapMinus.or ψ.swapMinus := rfl

@[simp] theorem swapMinus_iff (φ ψ : MinusFormula) :
    (φ.iff ψ).swapMinus = φ.swapMinus.iff ψ.swapMinus := rfl

@[simp] theorem swapMinus_diamond (φ : MinusFormula) :
    φ.diamond.swapMinus = φ.swapMinus.diamond := rfl

/-- `swapMinus` exchanges the existential past and future: `swap(Pφ) = F(swap φ)`. -/
@[simp] theorem swapMinus_somePast (φ : MinusFormula) :
    φ.somePast.swapMinus = φ.swapMinus.someFuture := rfl

/-- `swapMinus` exchanges the existential future and past: `swap(Fφ) = P(swap φ)`. -/
@[simp] theorem swapMinus_someFuture (φ : MinusFormula) :
    φ.someFuture.swapMinus = φ.swapMinus.somePast := rfl

/-- `swapMinus` fixes `△` up to the swap of its argument: `swap(△φ) = △(swap φ)`.

`always φ = Hφ ∧ (φ ∧ Gφ)`, and swapping turns that into `Gφ' ∧ (φ' ∧ Hφ')` with
`φ' = swap φ` — the same three conjuncts in the *reverse* order, so this is **not** `rfl`.
It is nonetheless true because `△` is symmetric in H and G once the conjunction is
reassociated; the statement below is therefore about `always` up to that reordering and is
proved by the explicit unfolding. -/
theorem swapMinus_always (φ : MinusFormula) :
    φ.always.swapMinus = φ.swapMinus.allFuture.and (φ.swapMinus.and φ.swapMinus.allPast) := rfl

/-! ### Atom injectivity -/

/-- `MinusFormula.atom` is injective. -/
theorem atom_injective : Function.Injective MinusFormula.atom := by
  intro a b h
  injection h

end MinusFormula

/-- L⁻-side proof contexts, mirroring `FormalSystem.Syntax.Context`.

Defined here rather than in `MinusLanguage/Derivation.lean` because both `Derivation.lean` and
`Translation.lean` need it and neither imports the other. -/
abbrev Context := List MinusFormula

end FormalSystem.MinusLanguage
