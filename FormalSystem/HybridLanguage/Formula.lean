/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.PlusLanguage.Formula

/-!
# `HybridFormula` — L⁺ plus the same-state modality, state registers and the state binder

This module defines the **hybrid state language** obtained from L⁺
(`FormalSystem/PlusLanguage/Formula.lean`) by adding three primitives:

```
φ, ψ ::= pᵢ | ⊥ | φ → ψ | □φ | φ U ψ | φ S ψ | ⊡φ | [≡]φ | i | ↓ᵢ φ
```

* `[≡]φ` (`same`) — the **same-state modality**: `φ` holds at every (history, time) pair that
  occupies the present world state, at any time;
* `i` (`reg i`) — a **state register**: true iff the present world state is the `i`-th stored
  state;
* `↓ᵢ φ` (`bind i φ`) — the **state binder**: store the present world state in register `i`, then
  evaluate `φ`.

This file is syntax only; the truth clauses are in `HybridLanguage/HybridTruth.lean`.

## Design

**A state nominal is a free register.** Truth is evaluated relative to a register vector
`ℕ → WorldState`, and validity quantifies over every such vector, so a register that no binder
captures behaves as a nominal under an arbitrary assignment. Nominals and registers are therefore
one language rather than two: `reg i` is the nominal `i` when free and the bound variable of
`↓ᵢ` when not.

`HybridFormula` is a **separate inductive** with a constructor-to-constructor embedding
`HybridFormula.ofPlus : PlusFormula → HybridFormula`, following
`FormalSystem/OpenLanguage/Formula.lean`. No constructor is added to `PlusFormula`. Every derived
operator below has the **same right-hand side** as its `PlusFormula` namesake, so that `ofPlus`
pushes through each of them by `rfl` and the abstract clause lemmas of
`Semantics/TruthClauses.lean` are inherited without a `show`.

## A state nominal names a point of a quotient

A register names a **world state**, and a world state is not a point of evaluation: many
(history, time) pairs occupy it. A state nominal therefore names a point of the quotient of the
(history, time) pairs by the same-state relation, not a point. In particular `A(i → φ)` and
`E(i ∧ φ)` are **not** dual in the way `@ᵢ φ` is self-dual for a point nominal — the first says
`φ` holds at every pair occupying the named state, the second at some — and results of hybrid
logic that depend on a nominal being true at exactly one point do not transfer.

## Main Definitions

- `HybridFormula`: ten-constructor inductive type
- Derived operators with `PlusFormula`'s right-hand sides: `top`, `neg`, `someFuture`,
  `somePast`, `allFuture`, `allPast`, `and`, `or`, `iff`, `diamond`, `always`, `sometimes`, `dstab`
- `HybridFormula.univ` (`A φ := □△φ`, the universal modality) and `HybridFormula.exist`
  (`E φ := ¬A¬φ`)
- `HybridFormula.recF i` — the recurrence formula `¬(i ∧ (P i ∨ F i))`
- `HybridFormula.transF i j` — the transposition formula `¬(E(i ∧ F j) ∧ E(j ∧ F i))`
- `HybridFormula.RegFree` — the register-free fragment, L⁺ plus `[≡]`
- `HybridFormula.ofPlus` — the embedding of L⁺

## Main Results

- `DecidableEq`, `Countable` for `HybridFormula`
- `HybridFormula.ofPlus_injective`, `HybridFormula.regFree_ofPlus`, and the `rfl` commutation
  pins

## Module Invariant

**This file imports nothing from `FormalSystem/Semantics/` and no semantic module of any
language.** It is the syntax half of the component; `scripts/check-metalogic-cycles.sh` checks the
edge.

## References

* JPL paper `def:BLstar-semantics` — the stability modal `⊡`, which `[≡]` frees from the present
  time
* JPL paper `sub:Extension` — the manuscript's registers, which store **times and worlds**; the
  registers here store **world states**, which the manuscript does not have
* [P. Blackburn, M. de Rijke, Y. Venema, *Modal Logic*][blackburn2002], §7.3 — nominals true at
  exactly one point and the satisfaction operator, the point-nominal setting contrasted above
* `FormalSystem/PlusLanguage/Formula.lean` — the L⁺ side whose derived operators are mirrored
* `FormalSystem/OpenLanguage/Formula.lean` — the sibling extension of L⁺, the pattern followed

## Tags

hybrid-language · syntax · state-nominal · state-register · binder
-/

namespace FormalSystem.HybridLanguage

open FormalSystem.Syntax
open FormalSystem.PlusLanguage

/--
Formula type for the hybrid state language: the seven constructors of `PlusFormula` plus the
same-state modality, state registers and the state binder.

Constructor order and argument order (guard first, event second for `untl`/`snce`) are those of
`PlusFormula`, so that `ofPlus` is constructor-to-constructor.

Paper: — (formalization-native; the paper's registers of `sub:Extension` store times and worlds,
not world states)
-/
inductive HybridFormula : Type where
  /-- Propositional atom (variable). -/
  | atom : Atom → HybridFormula
  /-- Bottom (`⊥`, falsum). -/
  | bot : HybridFormula
  /-- Implication (`φ → ψ`). -/
  | imp : HybridFormula → HybridFormula → HybridFormula
  /-- Modal necessity (`□φ`). -/
  | box : HybridFormula → HybridFormula
  /-- Until, `φ U ψ`, guard first and event second, exactly as `PlusFormula.untl`. -/
  | untl : HybridFormula → HybridFormula → HybridFormula
  /-- Since, `φ S ψ`, guard first and event second, exactly as `PlusFormula.snce`. -/
  | snce : HybridFormula → HybridFormula → HybridFormula
  /-- The stability modal `⊡φ` (`def:BLstar-semantics`): `φ` holds in every world sharing the
  present world state at the present time. -/
  | stab : HybridFormula → HybridFormula
  /-- The same-state modality `[≡]φ`: `φ` holds at every (history, time) pair occupying the
  present world state, at any time. -/
  | same : HybridFormula → HybridFormula
  /-- The state register `i`: the present world state is the `i`-th stored state. A state
  nominal when free. -/
  | reg : ℕ → HybridFormula
  /-- The state binder `↓ᵢ φ`: store the present world state in register `i`, then evaluate
  `φ`. -/
  | bind : ℕ → HybridFormula → HybridFormula
  deriving Repr, DecidableEq, Countable

namespace HybridFormula

/-! ### Derived operators

Each right-hand side is copied verbatim from `PlusLanguage/Formula.lean`, so that `ofPlus`
commutes with it by `rfl` (see the pins at the end of the file). -/

/-- Top (`⊤`): `⊥ → ⊥`. Mirrors `PlusFormula.top`. -/
def top : HybridFormula := HybridFormula.bot.imp HybridFormula.bot

/-- Negation (`¬φ`): `φ → ⊥`. Mirrors `PlusFormula.neg`. -/
def neg (φ : HybridFormula) : HybridFormula := φ.imp bot

/-- Existential future (`Fφ`): `⊤ U φ`. Mirrors `PlusFormula.someFuture`. -/
def someFuture (φ : HybridFormula) : HybridFormula := HybridFormula.untl HybridFormula.top φ

/-- Existential past (`Pφ`): `⊤ S φ`. Mirrors `PlusFormula.somePast`. -/
def somePast (φ : HybridFormula) : HybridFormula := HybridFormula.snce HybridFormula.top φ

/-- Universal future (`Gφ`): `¬F¬φ`. Mirrors `PlusFormula.allFuture`. -/
def allFuture (φ : HybridFormula) : HybridFormula := (someFuture φ.neg).neg

/-- Universal past (`Hφ`): `¬P¬φ`. Mirrors `PlusFormula.allPast`. -/
def allPast (φ : HybridFormula) : HybridFormula := (somePast φ.neg).neg

/-- Conjunction (`φ ∧ ψ`): `¬(φ → ¬ψ)`. Mirrors `PlusFormula.and`. -/
def and (φ ψ : HybridFormula) : HybridFormula := (φ.imp ψ.neg).neg

/-- Disjunction (`φ ∨ ψ`): `¬φ → ψ`. Mirrors `PlusFormula.or`. -/
def or (φ ψ : HybridFormula) : HybridFormula := φ.neg.imp ψ

/-- Biconditional (`φ ↔ ψ`): `(φ → ψ) ∧ (ψ → φ)`. Mirrors `PlusFormula.iff`. -/
def iff (φ ψ : HybridFormula) : HybridFormula := (φ.imp ψ).and (ψ.imp φ)

/-- Modal possibility (`◇φ`): `¬□¬φ`. Mirrors `PlusFormula.diamond`. -/
def diamond (φ : HybridFormula) : HybridFormula := φ.neg.box.neg

/-- Temporal `always` (`△φ`): `Hφ ∧ (φ ∧ Gφ)`. Mirrors `PlusFormula.always`. -/
def always (φ : HybridFormula) : HybridFormula := φ.allPast.and (φ.and φ.allFuture)

/-- Temporal `sometimes` (`▽φ`): `¬△¬φ`. Mirrors `PlusFormula.sometimes`. -/
def sometimes (φ : HybridFormula) : HybridFormula := φ.neg.always.neg

/-- The dual stability modal `⟐φ := ¬⊡¬φ`. Mirrors `PlusFormula.dstab`. -/
def dstab (φ : HybridFormula) : HybridFormula := neg (.stab (neg φ))

/-! ### The universal modality and the two defining formulas -/

/-- The universal modality `A φ := □△φ`: `φ` at every history and every time. Definable because
world histories are total. -/
def univ (φ : HybridFormula) : HybridFormula := φ.always.box

/-- The existential modality `E φ := ¬A¬φ`. -/
def exist (φ : HybridFormula) : HybridFormula := (univ φ.neg).neg

/-- The **recurrence formula** `¬(i ∧ (P i ∨ F i))`: the state named by `i` does not occur both
now and at another time of the present history. -/
def recF (i : ℕ) : HybridFormula :=
  ((reg i).and ((somePast (reg i)).or (someFuture (reg i)))).neg

/-- The **transposition formula** `¬(E(i ∧ F j) ∧ E(j ∧ F i))`: no history passes through the
state named by `i` and later through the one named by `j` while another passes through them in the
opposite order. -/
def transF (i j : ℕ) : HybridFormula :=
  ((exist ((reg i).and (someFuture (reg j)))).and
    (exist ((reg j).and (someFuture (reg i))))).neg

/-! ### The register-free fragment -/

/-- The register-free fragment: L⁺ plus `[≡]`. A formula is register-free iff it contains neither
a register nor a binder. -/
def RegFree : HybridFormula → Prop
  | atom _ => True
  | bot => True
  | imp a b => RegFree a ∧ RegFree b
  | box a => RegFree a
  | untl a b => RegFree a ∧ RegFree b
  | snce a b => RegFree a ∧ RegFree b
  | stab a => RegFree a
  | same a => RegFree a
  | reg _ => False
  | bind _ _ => False

/-! ## The embedding of L⁺ -/

/-- The embedding of L⁺ into the hybrid state language, constructor to constructor. -/
def ofPlus : PlusFormula → HybridFormula
  | .atom p => .atom p
  | .bot => .bot
  | .imp φ ψ => .imp (ofPlus φ) (ofPlus ψ)
  | .box φ => .box (ofPlus φ)
  | .untl ψ φ => .untl (ofPlus ψ) (ofPlus φ)
  | .snce ψ φ => .snce (ofPlus ψ) (ofPlus φ)
  | .stab φ => .stab (ofPlus φ)

/-- `ofPlus` is injective. Per-constructor `cases` on the target with the induction hypotheses
applied by `rw`, exactly as `OpenLanguage.ofPlus_injective` does. -/
theorem ofPlus_injective : Function.Injective ofPlus := by
  intro φ ψ h
  induction φ generalizing ψ with
  | atom a => cases ψ <;> simp_all [ofPlus]
  | bot => cases ψ <;> simp_all [ofPlus]
  | imp φ₁ φ₂ ih₁ ih₂ =>
    cases ψ <;> simp only [ofPlus, reduceCtorEq, HybridFormula.imp.injEq] at h
    rw [ih₁ h.1, ih₂ h.2]
  | box φ ih =>
    cases ψ <;> simp only [ofPlus, reduceCtorEq, HybridFormula.box.injEq] at h
    rw [ih h]
  | untl φ₁ φ₂ ih₁ ih₂ =>
    cases ψ <;> simp only [ofPlus, reduceCtorEq, HybridFormula.untl.injEq] at h
    rw [ih₁ h.1, ih₂ h.2]
  | snce φ₁ φ₂ ih₁ ih₂ =>
    cases ψ <;> simp only [ofPlus, reduceCtorEq, HybridFormula.snce.injEq] at h
    rw [ih₁ h.1, ih₂ h.2]
  | stab φ ih =>
    cases ψ <;> simp only [ofPlus, reduceCtorEq, HybridFormula.stab.injEq] at h
    rw [ih h]

/-- The image of L⁺ is register-free: `ofPlus` produces neither a register nor a binder. -/
theorem regFree_ofPlus (φ : PlusFormula) : (ofPlus φ).RegFree := by
  induction φ with
  | atom _ => exact trivial
  | bot => exact trivial
  | imp _ _ ih₁ ih₂ => exact ⟨ih₁, ih₂⟩
  | box _ ih => exact ih
  | untl _ _ ih₁ ih₂ => exact ⟨ih₁, ih₂⟩
  | snce _ _ ih₁ ih₂ => exact ⟨ih₁, ih₂⟩
  | stab _ ih => exact ih

/-! ### `rfl` pins

`ofPlus` commutes with every derived operator **definitionally**, because each operator above was
given `PlusFormula`'s right-hand side verbatim. If one of these stops being `rfl`, the fix is in
the operator's right-hand side above, never at the use site. -/

example : ofPlus PlusFormula.top = HybridFormula.top := rfl
example (φ : PlusFormula) : ofPlus φ.neg = (ofPlus φ).neg := rfl
example (φ ψ : PlusFormula) : ofPlus (φ.and ψ) = (ofPlus φ).and (ofPlus ψ) := rfl
example (φ ψ : PlusFormula) : ofPlus (φ.or ψ) = (ofPlus φ).or (ofPlus ψ) := rfl
example (φ ψ : PlusFormula) : ofPlus (φ.iff ψ) = (ofPlus φ).iff (ofPlus ψ) := rfl
example (φ : PlusFormula) : ofPlus φ.diamond = (ofPlus φ).diamond := rfl
example (φ : PlusFormula) :
    ofPlus (PlusFormula.someFuture φ) = HybridFormula.someFuture (ofPlus φ) := rfl
example (φ : PlusFormula) :
    ofPlus (PlusFormula.somePast φ) = HybridFormula.somePast (ofPlus φ) := rfl
example (φ : PlusFormula) :
    ofPlus (PlusFormula.allFuture φ) = HybridFormula.allFuture (ofPlus φ) := rfl
example (φ : PlusFormula) :
    ofPlus (PlusFormula.allPast φ) = HybridFormula.allPast (ofPlus φ) := rfl
example (φ : PlusFormula) : ofPlus (PlusFormula.always φ) = HybridFormula.always (ofPlus φ) := rfl
example (φ : PlusFormula) :
    ofPlus (PlusFormula.sometimes φ) = HybridFormula.sometimes (ofPlus φ) := rfl
example (φ : PlusFormula) : ofPlus (PlusFormula.dstab φ) = HybridFormula.dstab (ofPlus φ) := rfl

end HybridFormula

end FormalSystem.HybridLanguage
