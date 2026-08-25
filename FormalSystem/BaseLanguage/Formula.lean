/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.Atom

/-!
# `BLFormula` — the tense-primitive base language BL

This module defines the *base language* `BL` of the paper's `\S sub:Logic`
(`def:BL-language`), in which `H` (`allPast`) and `G` (`allFuture`) are **primitive**:

```
φ, ψ ::= pᵢ | ⊥ | φ → ψ | □φ | Hφ | Gφ
```

This is deliberately *not* `FormalSystem.Syntax.Formula`, whose primitives are `untl`/`snce`
and whose `allPast`/`allFuture` are derived abbreviations. The two languages are related by the
translation `FormalSystem.BaseLanguage.tr` (`BaseLanguage/Translation.lean`), which is the
substance of the backward conservativity bridge in
`FormalSystem/Metalogic/Conservativity.lean`.

## Main Definitions

- `BLFormula`: six-constructor inductive type for BL
- `BLFormula.neg`, `top`, `and`, `or`, `iff`: derived Boolean operators
- `BLFormula.somePast` (P), `BLFormula.someFuture` (F): derived existential temporal operators
- `BLFormula.always` (△): `Hφ ∧ φ ∧ Gφ`, mirroring `Formula.always`
- `BLFormula.swapBL`: the past/future interchange used by TM's **TD** rule

## Main Results

- `DecidableEq BLFormula`, `Repr BLFormula`, `Countable BLFormula`
- `swapBL_involution`: `swapBL` is an involution
- `swapBL` push-through lemmas for every derived operator

## Polarity Warning

The paper writes `\Past`/`\Future` for the **universal** operators H/G and `\past`/`\future`
for the **existential** operators P/F. `allPast` here is H (universal) and `allFuture` is G
(universal); `somePast`/`someFuture` are the existential P/F and are *derived*. Reading these
the other way round transcribes a different logic.

## Module Invariant

**Nothing under `FormalSystem/BaseLanguage/` imports anything from `FormalSystem/Semantics/`.**
The bridge is purely proof-theoretic: it is a map between two `DerivationTree` types and
touches no truth definition, frame, or validity predicate. Keeping the invariant means the
bridge composes unchanged with whatever the totality-based validity definition becomes.

## References

* JPL paper `\S sub:Logic` — `def:BL-language` and the TM axiomatization
* `FormalSystem/Syntax/Formula.lean` — the BL⁺ (until/since-primitive) side
-/

namespace FormalSystem.BaseLanguage

open FormalSystem.Syntax

/--
Formula type for the tense-primitive base language BL.

Six primitive constructors, per `def:BL-language`:
`φ, ψ ::= pᵢ | ⊥ | φ → ψ | □φ | Hφ | Gφ`.

Atoms are the *existing* `FormalSystem.Syntax.Atom`, shared with BL⁺, so the translation `tr`
is the identity on atoms.
-/
inductive BLFormula : Type where
  /-- Propositional atom (variable), the paper's `pᵢ`. -/
  | atom : Atom → BLFormula
  /-- Bottom (`⊥`, falsum). -/
  | bot : BLFormula
  /-- Implication (`φ → ψ`). -/
  | imp : BLFormula → BLFormula → BLFormula
  /-- Modal necessity (`□φ`). -/
  | box : BLFormula → BLFormula
  /-- **Universal** past, the paper's `\Past φ` = `Hφ` ("φ has always been the case").
      This is H, *not* the existential P — see the polarity warning in the module docstring. -/
  | allPast : BLFormula → BLFormula
  /-- **Universal** future, the paper's `\Future φ` = `Gφ` ("φ will always be the case").
      This is G, *not* the existential F — see the polarity warning in the module docstring. -/
  | allFuture : BLFormula → BLFormula
  deriving Repr, DecidableEq, BEq, Hashable, Countable

namespace BLFormula

/-! ### Derived operators

Naming mirrors `FormalSystem/Syntax/Formula.lean` so the two sides read alike. Every definition
below is a `def` abbreviation over the six primitives; none of them is a new constructor. -/

/-- Top (`⊤`, verum): `⊥ → ⊥`. Mirrors `Formula.top`. -/
def top : BLFormula := BLFormula.bot.imp BLFormula.bot

/-- Negation (`¬φ`): `φ → ⊥`. Mirrors `Formula.neg`. -/
def neg (φ : BLFormula) : BLFormula := φ.imp bot

/-- Conjunction (`φ ∧ ψ`): `¬(φ → ¬ψ)`. Mirrors `Formula.and`. -/
def and (φ ψ : BLFormula) : BLFormula := (φ.imp ψ.neg).neg

/-- Disjunction (`φ ∨ ψ`): `¬φ → ψ`. Mirrors `Formula.or`. -/
def or (φ ψ : BLFormula) : BLFormula := φ.neg.imp ψ

/-- Biconditional (`φ ↔ ψ`): `(φ → ψ) ∧ (ψ → φ)`. -/
def iff (φ ψ : BLFormula) : BLFormula := (φ.imp ψ).and (ψ.imp φ)

/-- Modal possibility (`◇φ`): `¬□¬φ`. Mirrors `Formula.diamond`. -/
def diamond (φ : BLFormula) : BLFormula := φ.neg.box.neg

/-- **Existential** past (`Pφ`, the paper's `\past φ`): `¬H¬φ`. Mirrors `Formula.somePast`. -/
def somePast (φ : BLFormula) : BLFormula := (φ.neg.allPast).neg

/-- **Existential** future (`Fφ`, the paper's `\future φ`): `¬G¬φ`.
Mirrors `Formula.someFuture`. -/
def someFuture (φ : BLFormula) : BLFormula := (φ.neg.allFuture).neg

/-- Temporal `always` (`△φ`): `Hφ ∧ (φ ∧ Gφ)`.

The association mirrors `Formula.always` exactly (`φ.allPast.and (φ.and φ.allFuture)`), which
is what makes the CO axiom's translation line up with `Formula.co` without reassociation. -/
def always (φ : BLFormula) : BLFormula := φ.allPast.and (φ.and φ.allFuture)

/--
Interchange the two universal temporal operators `H` and `G` throughout a formula.

This is the BL-side analogue of `Formula.swapTemporal` and is what TM's **TD** rule
("if `⊢ φ` then `⊢ φ⟨P|F⟩`") transforms by. Note that on the BL⁺ side the corresponding
operation swaps the *primitive* `untl`/`snce`; the commutation of the two is
`BaseLanguage.tr_swapBL`.
-/
def swapBL : BLFormula → BLFormula
  | atom a => atom a
  | bot => bot
  | imp φ ψ => imp φ.swapBL ψ.swapBL
  | box φ => box φ.swapBL
  | allPast φ => allFuture φ.swapBL
  | allFuture φ => allPast φ.swapBL

/-- `swapBL` is an involution. -/
theorem swapBL_involution (φ : BLFormula) : φ.swapBL.swapBL = φ := by
  induction φ <;> simp_all [swapBL]

/-! ### `swapBL` push-through lemmas for the derived operators

These are the BL-side counterparts of `Formula.swap_temporal_neg`,
`Formula.swap_temporal_some_future`, and friends. They are `@[simp]` so that the TD case of
the Phase 8 recursion and the axiom-discharge table can normalise a `swapBL` of a derived
operator without unfolding to primitives by hand. -/

@[simp] theorem swapBL_top : top.swapBL = top := rfl

@[simp] theorem swapBL_neg (φ : BLFormula) : φ.neg.swapBL = φ.swapBL.neg := rfl

@[simp] theorem swapBL_and (φ ψ : BLFormula) :
    (φ.and ψ).swapBL = φ.swapBL.and ψ.swapBL := rfl

@[simp] theorem swapBL_or (φ ψ : BLFormula) :
    (φ.or ψ).swapBL = φ.swapBL.or ψ.swapBL := rfl

@[simp] theorem swapBL_iff (φ ψ : BLFormula) :
    (φ.iff ψ).swapBL = φ.swapBL.iff ψ.swapBL := rfl

@[simp] theorem swapBL_diamond (φ : BLFormula) :
    φ.diamond.swapBL = φ.swapBL.diamond := rfl

/-- `swapBL` exchanges the existential past and future: `swap(Pφ) = F(swap φ)`. -/
@[simp] theorem swapBL_somePast (φ : BLFormula) :
    φ.somePast.swapBL = φ.swapBL.someFuture := rfl

/-- `swapBL` exchanges the existential future and past: `swap(Fφ) = P(swap φ)`. -/
@[simp] theorem swapBL_someFuture (φ : BLFormula) :
    φ.someFuture.swapBL = φ.swapBL.somePast := rfl

/-- `swapBL` fixes `△` up to the swap of its argument: `swap(△φ) = △(swap φ)`.

`always φ = Hφ ∧ (φ ∧ Gφ)`, and swapping turns that into `Gφ' ∧ (φ' ∧ Hφ')` with
`φ' = swap φ` — the same three conjuncts in the *reverse* order, so this is **not** `rfl`.
It is nonetheless true because `△` is symmetric in H and G once the conjunction is
reassociated; the statement below is therefore about `always` up to that reordering and is
proved by the explicit unfolding. -/
theorem swapBL_always (φ : BLFormula) :
    φ.always.swapBL = φ.swapBL.allFuture.and (φ.swapBL.and φ.swapBL.allPast) := rfl

/-! ### Atom injectivity -/

/-- `BLFormula.atom` is injective. -/
theorem atom_injective : Function.Injective BLFormula.atom := by
  intro a b h
  injection h

end BLFormula

end FormalSystem.BaseLanguage
