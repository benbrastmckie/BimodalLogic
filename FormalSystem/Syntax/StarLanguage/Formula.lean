/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.PlusLanguage.Formula

/-!
# `StarFormula` — the language L⋆: L⁺ plus the time store/recall operators

This module defines the language **L⋆**, obtained from L⁺
(`FormalSystem/PlusLanguage/Formula.lean`) by adding the manuscript's two **hybrid time
registers**:

```
φ, ψ ::= pᵢ | ⊥ | φ → ψ | □φ | φ U ψ | φ S ψ | ⊡φ | ↑ⁱφ | ↓ⁱφ
```

`↑ⁱ` (`timeStore i`) stores the current time in register `i`; `↓ⁱ` (`timeRecall i`) moves
evaluation to the time held in register `i`. The manuscript's `def:BLstar-semantics` interprets
exactly these two together with `⊡` over points `(τ, x, v⃗)`, `v⃗` a vector of stored **times**,
suppressing the world registers `↑_M`/`↓_M`; this component follows that presentation.

## Why a separate inductive rather than two more `PlusFormula` constructors

`PlusFormula` must not grow store/recall constructors. The atomization route to TM⁺ soundness
(`Metalogic/Conservativity/Plus/Atomization.lean`) rests on `stab_state_only`
(`Semantics/PlusLanguage/PlusTruth.lean`): `⊡φ`'s truth depends on the world state alone, at any time. That
invariant is **false inside a recall scope** — `⊡↓ⁱφ` reaches back to a time the register names,
which the present world state does not determine — so adding the operators to `PlusFormula`
would silently invalidate a landed conservativity result. `StarFormula` is therefore a separate
inductive with a constructor-to-constructor embedding `ofPlus`, exactly the landed
`MinusFormula`/`PlusFormula` pattern.

## Design

Every derived operator below has the **same right-hand side** as its `PlusFormula` namesake, so
`ofPlus` commutes with each of them by `rfl`; the `rfl` pins at the end of the file are that
contract. The `⊡`-specific operators (`dstab`, `Will`, `will`, `Could`, `could`) are mirrored
too, so no consumer has to reach back into `PlusFormula` for them.

## Main Definitions

- `StarFormula`: nine-constructor inductive type for L⋆; `StarContext := List StarFormula`
- `StarFormula.reflectTime`: the past/future interchange for the TR rule
  (`stab ↦ stab`, `timeStore ↦ timeStore`, `timeRecall ↦ timeRecall`)
- Derived operators with `PlusFormula`'s right-hand sides: `top`, `neg`, `and`, `or`, `iff`,
  `diamond`, `someFuture`, `somePast`, `allFuture`, `allPast`, `kPlus`, `kMinus`, `always`,
  `sometimes`, `next`, `prev`, `dstab`, `Will`, `will`, `Could`, `could`
- `ofPlus`, `ofStarCtx`: the embedding of L⁺ into L⋆ and its context lift

## Main Results

- `DecidableEq`, `Countable`, `Infinite`, `Denumerable` for `StarFormula`
- `ofPlus_injective`, and the `rfl`-shaped commutation lemmas `ofPlus_neg`, `ofPlus_allFuture`,
  `ofPlus_always`, `ofPlus_someFuture`, `ofPlus_or`, `ofPlus_top`
- `StarFormula.reflectTime` with `reflect_time_involution`, the `reflect_time_*`
  push-through family, and the commutation pin `ofPlus_reflectTime`
- `ofPlus_ne_timeStore`, `ofPlus_ne_timeRecall`: nothing in the image of the embedding is a
  top-level register operator

## Module Invariant

**Nothing under `FormalSystem/StarLanguage/` imports anything from `FormalSystem/Semantics/`.**
Checkable by `grep -rn 'import FormalSystem.Semantics' FormalSystem/StarLanguage/`. The invariant
is directional, exactly as for `MinusLanguage/` and `PlusLanguage/`: the converse edge is
permitted and is how L⋆ acquires its semantics
(`FormalSystem/Semantics/StarLanguage/StarTruth.lean`).

## Where the proof system lives

`StarAxiom` (`StarLanguage/Axioms.lean`) and `StarDerivationTree` with the notation `⊢⋆[fc]`
(`StarLanguage/Derivation.lean`) present **TM⋆**, the proof system for L⋆. Nothing in this file
depends on them; `reflectTime` and `ofPlus_reflectTime` are declared here because they are
syntax, and the `time_reflection` rule and the swap-validity dispatch both consume them from
above.
See `FormalSystem/StarLanguage/README.md`.

## References

* JPL paper `possible_worlds.tex` — `def:BLstar-semantics` (the store/recall clauses and the
  point `(τ, x, v⃗)`), `sub:Extension`, `sent:det`, `app:deterministic-future`
* `FormalSystem/PlusLanguage/Formula.lean` — the L⁺ side whose operators are mirrored here
* `FormalSystem/Semantics/StarLanguage/StarTruth.lean` — `StarTruthAt`, the truth recursion over
  `(τ, x, v⃗)`

## Tags

star-language · store-recall · time-register · hybrid-logic
-/

namespace FormalSystem.StarLanguage

open FormalSystem.Syntax
open FormalSystem.PlusLanguage

/--
Formula type for the language L⋆: the seven constructors of `PlusFormula` plus the two time
registers of `def:BLstar-semantics`.

Constructor order and argument order (guard first, event second for `untl`/`snce`) are those of
`FormalSystem.PlusLanguage.PlusFormula`, so that `ofPlus` is constructor-to-constructor.
-/
inductive StarFormula : Type where
  /-- Propositional atom (variable). -/
  | atom : Atom → StarFormula
  /-- Bottom (`⊥`, falsum). -/
  | bot : StarFormula
  /-- Implication (`φ → ψ`). -/
  | imp : StarFormula → StarFormula → StarFormula
  /-- Modal necessity (`□φ`). -/
  | box : StarFormula → StarFormula
  /-- Until, `φ U ψ`, guard first and event second, exactly as `PlusFormula.untl`. -/
  | untl : StarFormula → StarFormula → StarFormula
  /-- Since, `φ S ψ`, guard first and event second, exactly as `PlusFormula.snce`. -/
  | snce : StarFormula → StarFormula → StarFormula
  /-- The stability modal `⊡φ` (`def:BLstar-semantics`). -/
  | stab : StarFormula → StarFormula
  /-- Time store `↑ⁱφ` (`def:BLstar-semantics`): evaluate `φ` with the current time written into
      register `i`. -/
  | timeStore : ℕ → StarFormula → StarFormula
  /-- Time recall `↓ⁱφ` (`def:BLstar-semantics`): evaluate `φ` at the time held in register
      `i`. -/
  | timeRecall : ℕ → StarFormula → StarFormula
  deriving Repr, DecidableEq, Countable

/-- `StarFormula.atom` is injective. -/
theorem StarFormula.atom_injective : Function.Injective StarFormula.atom := by
  intro a b h
  injection h

/-- `StarFormula` is infinite, via the injection of atoms. -/
instance : Infinite StarFormula :=
  Infinite.of_injective StarFormula.atom StarFormula.atom_injective

/-- `StarFormula` is denumerable (countable + infinite), exactly as `PlusFormula` obtains it. -/
noncomputable instance : Denumerable StarFormula :=
  Classical.choice (nonempty_denumerable StarFormula)

/-- Contexts of L⋆ formulas. -/
abbrev StarContext := List StarFormula

namespace StarFormula

/-! ### Derived operators

Each right-hand side is copied verbatim from `PlusLanguage/Formula.lean`, so that `ofPlus`
commutes with it by `rfl` (see the pins at the end of the file). -/

/-- Top (`⊤`): `⊥ → ⊥`. Mirrors `PlusFormula.top`. -/
def top : StarFormula := StarFormula.bot.imp StarFormula.bot

/-- Negation (`¬φ`): `φ → ⊥`. Mirrors `PlusFormula.neg`. -/
def neg (φ : StarFormula) : StarFormula := φ.imp bot

/-- Existential future (`Fφ`): `⊤ U φ`. Mirrors `PlusFormula.someFuture`. -/
def someFuture (φ : StarFormula) : StarFormula := StarFormula.untl StarFormula.top φ

/-- Existential past (`Pφ`): `⊤ S φ`. Mirrors `PlusFormula.somePast`. -/
def somePast (φ : StarFormula) : StarFormula := StarFormula.snce StarFormula.top φ

/-- Universal future (`Gφ`): `¬F¬φ`. Mirrors `PlusFormula.allFuture`. -/
def allFuture (φ : StarFormula) : StarFormula := (someFuture φ.neg).neg

/-- Universal past (`Hφ`): `¬P¬φ`. Mirrors `PlusFormula.allPast`. -/
def allPast (φ : StarFormula) : StarFormula := (somePast φ.neg).neg

/-- Reynolds' `K⁺`: `¬U(¬φ, ⊤)` in guard-first order. Mirrors `PlusFormula.kPlus`. -/
def kPlus (φ : StarFormula) : StarFormula := (StarFormula.untl φ.neg StarFormula.top).neg

/-- Reynolds' `K⁻`: `¬S(¬φ, ⊤)` in guard-first order. Mirrors `PlusFormula.kMinus`. -/
def kMinus (φ : StarFormula) : StarFormula := (StarFormula.snce φ.neg StarFormula.top).neg

/-- Conjunction (`φ ∧ ψ`): `¬(φ → ¬ψ)`. Mirrors `PlusFormula.and`. -/
def and (φ ψ : StarFormula) : StarFormula := (φ.imp ψ.neg).neg

/-- Disjunction (`φ ∨ ψ`): `¬φ → ψ`. Mirrors `PlusFormula.or`. -/
def or (φ ψ : StarFormula) : StarFormula := φ.neg.imp ψ

/-- Biconditional (`φ ↔ ψ`): `(φ → ψ) ∧ (ψ → φ)`. Mirrors `PlusFormula.iff`. -/
def iff (φ ψ : StarFormula) : StarFormula := (φ.imp ψ).and (ψ.imp φ)

/-- Modal possibility (`◇φ`): `¬□¬φ`. Mirrors `PlusFormula.diamond`. -/
def diamond (φ : StarFormula) : StarFormula := φ.neg.box.neg

/-- Temporal `always` (`△φ`): `Hφ ∧ (φ ∧ Gφ)`. Mirrors `PlusFormula.always`. -/
def always (φ : StarFormula) : StarFormula := φ.allPast.and (φ.and φ.allFuture)

/-- Temporal `sometimes` (`▽φ`): `¬△¬φ`. Mirrors `PlusFormula.sometimes`. -/
def sometimes (φ : StarFormula) : StarFormula := φ.neg.always.neg

/-- Next-step (`Xφ`): `⊥ U φ`. Mirrors `PlusFormula.next`. -/
def next (φ : StarFormula) : StarFormula := StarFormula.untl StarFormula.bot φ

/-- Previous-step (`Yφ`): `⊥ S φ`. Mirrors `PlusFormula.prev`. -/
def prev (φ : StarFormula) : StarFormula := StarFormula.snce StarFormula.bot φ

/-! ### The `⊡`-specific operators, mirrored from L⁺ -/

/-- The dual stability modal `⟐φ := ¬⊡¬φ`. Mirrors `PlusFormula.dstab`. -/
def dstab (φ : StarFormula) : StarFormula := neg (.stab (neg φ))

/-- `Will φ := ⊡Gφ`. Mirrors `PlusFormula.Will`. -/
def Will (φ : StarFormula) : StarFormula := .stab (allFuture φ)

/-- `will φ := ⊡Fφ`. Mirrors `PlusFormula.will`. -/
def will (φ : StarFormula) : StarFormula := .stab (someFuture φ)

/-- `Could φ := ⟐Gφ`. Mirrors `PlusFormula.Could`. -/
def Could (φ : StarFormula) : StarFormula := dstab (allFuture φ)

/-- `could φ := ⟐Fφ`. Mirrors `PlusFormula.could`. -/
def could (φ : StarFormula) : StarFormula := dstab (someFuture φ)

/-! ### Time reflection

`reflectTime` interchanges past and future. It is what the `time_reflection` rule of TM⋆
(`FormalSystem/StarLanguage/Derivation.lean`) applies to a theorem, and what the swap half of
TM⋆ soundness (`Metalogic/Conservativity/Star/StarSoundness.lean`) carries alongside validity.

The two register cases are **structural**, exactly as `stab ↦ stab` is: registers hold *times*
and carry no orientation of their own, so neither `↑ⁱ` nor `↓ⁱ` is exchanged for anything. -/

/--
Swap temporal operators (past ↔ future) in an L⋆ formula.

Mirrors `PlusFormula.reflectTime` constructor for constructor, with `timeStore i φ ↦
timeStore i φ.reflectTime` and `timeRecall i φ ↦ timeRecall i φ.reflectTime`.
-/
def reflectTime : StarFormula → StarFormula
  | atom p => atom p
  | bot => bot
  | imp φ ψ => imp φ.reflectTime ψ.reflectTime
  | box φ => box φ.reflectTime
  | untl ψ φ => snce ψ.reflectTime φ.reflectTime
  | snce ψ φ => untl ψ.reflectTime φ.reflectTime
  | stab φ => stab φ.reflectTime
  | timeStore i φ => timeStore i φ.reflectTime
  | timeRecall i φ => timeRecall i φ.reflectTime

/-- `reflectTime` is an involution. -/
theorem reflect_time_involution (φ : StarFormula) :
    φ.reflectTime.reflectTime = φ := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp _ _ ihp ihq => simp only [reflectTime, ihp, ihq]
  | box _ ih => simp only [reflectTime, ih]
  | untl _ _ ih2 ih1 => simp only [reflectTime, ih1, ih2]
  | snce _ _ ih2 ih1 => simp only [reflectTime, ih1, ih2]
  | stab _ ih => simp only [reflectTime, ih]
  | timeStore _ _ ih => simp only [reflectTime, ih]
  | timeRecall _ _ ih => simp only [reflectTime, ih]

/-! The push-through lemmas, mirroring the `PlusFormula.reflect_time_*` family. -/

theorem reflect_time_top : top.reflectTime = top := rfl

theorem reflect_time_neg (φ : StarFormula) :
    φ.neg.reflectTime = φ.reflectTime.neg := by
  simp only [neg, reflectTime]

theorem reflect_time_diamond (φ : StarFormula) :
    φ.diamond.reflectTime = φ.reflectTime.diamond := by
  simp only [diamond, neg, reflectTime]

@[simp]
theorem reflect_time_some_future (φ : StarFormula) :
    (someFuture φ).reflectTime = somePast φ.reflectTime := by
  simp only [someFuture, somePast, top, reflectTime]

@[simp]
theorem reflect_time_some_past (φ : StarFormula) :
    (somePast φ).reflectTime = someFuture φ.reflectTime := by
  simp only [somePast, someFuture, top, reflectTime]

@[simp]
theorem reflect_time_all_future (φ : StarFormula) :
    (allFuture φ).reflectTime = allPast φ.reflectTime := by
  simp only [allFuture, allPast, someFuture, somePast, neg, top, reflectTime]

@[simp]
theorem reflect_time_all_past (φ : StarFormula) :
    (allPast φ).reflectTime = allFuture φ.reflectTime := by
  simp only [allPast, allFuture, somePast, someFuture, neg, top, reflectTime]

theorem reflect_time_and (φ ψ : StarFormula) :
    (φ.and ψ).reflectTime = φ.reflectTime.and ψ.reflectTime := by
  simp only [and, neg, reflectTime]

theorem reflect_time_or (φ ψ : StarFormula) :
    (φ.or ψ).reflectTime = φ.reflectTime.or ψ.reflectTime := by
  simp only [or, neg, reflectTime]

theorem reflect_time_iff (φ ψ : StarFormula) :
    (φ.iff ψ).reflectTime = φ.reflectTime.iff ψ.reflectTime := by
  simp only [StarFormula.iff, and, neg, reflectTime]

/-- `reflectTime` fixes `⟐`, as it fixes `⊡`. -/
theorem reflect_time_dstab (φ : StarFormula) :
    (dstab φ).reflectTime = dstab φ.reflectTime := by
  simp only [dstab, neg, reflectTime]

/-- The store register is unoriented: `reflectTime` passes straight through it. -/
theorem reflect_time_timeStore (i : ℕ) (φ : StarFormula) :
    (StarFormula.timeStore i φ).reflectTime = StarFormula.timeStore i φ.reflectTime := rfl

/-- The recall register is unoriented: `reflectTime` passes straight through it. -/
theorem reflect_time_timeRecall (i : ℕ) (φ : StarFormula) :
    (StarFormula.timeRecall i φ).reflectTime = StarFormula.timeRecall i φ.reflectTime := rfl

/-- `reflectTime` exchanges the two Reynolds gap operators, mirroring
`PlusFormula.reflect_time_kPlus`. -/
theorem reflect_time_kPlus (φ : StarFormula) :
    φ.kPlus.reflectTime = φ.reflectTime.kMinus := by
  simp only [kPlus, kMinus, neg, top, reflectTime]

/-- The mirror of `reflect_time_kPlus`, matching `PlusFormula.reflect_time_kMinus`. -/
theorem reflect_time_kMinus (φ : StarFormula) :
    φ.kMinus.reflectTime = φ.reflectTime.kPlus := by
  simp only [kMinus, kPlus, neg, top, reflectTime]

end StarFormula

/-! ## The embedding of L⁺ into L⋆ -/

/-- The embedding of L⁺ into L⋆, constructor to constructor. Nothing in its image mentions a
time register, which is why `StarTruthAt` evaluates it independently of the stored-time vector
(`starTruthAt_ofPlus`, `Semantics/StarLanguage/StarTruth.lean`). -/
def ofPlus : PlusFormula → StarFormula
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
    cases ψ <;> simp [ofPlus] at h
    rw [ih₁ h.1, ih₂ h.2]
  | box φ ih =>
    cases ψ <;> simp [ofPlus] at h
    rw [ih h]
  | untl φ₁ φ₂ ih₁ ih₂ =>
    cases ψ <;> simp [ofPlus] at h
    rw [ih₁ h.1, ih₂ h.2]
  | snce φ₁ φ₂ ih₁ ih₂ =>
    cases ψ <;> simp [ofPlus] at h
    rw [ih₁ h.1, ih₂ h.2]
  | stab φ ih =>
    cases ψ <;> simp [ofPlus] at h
    rw [ih h]

/-- Nothing in the range of `ofPlus` is a top-level `timeStore`. -/
@[simp] theorem ofPlus_ne_timeStore (φ : PlusFormula) (i : ℕ) (ψ : StarFormula) :
    ofPlus φ ≠ StarFormula.timeStore i ψ := by
  cases φ <;> simp [ofPlus]

/-- Nothing in the range of `ofPlus` is a top-level `timeRecall`. -/
@[simp] theorem ofPlus_ne_timeRecall (φ : PlusFormula) (i : ℕ) (ψ : StarFormula) :
    ofPlus φ ≠ StarFormula.timeRecall i ψ := by
  cases φ <;> simp [ofPlus]

/-- `ofPlus` commutes with time reflection — the pin the `time_reflection` case of the
proof-system embedding (`StarLanguage/Embedding.lean`) and the swap arms of validity
(`Metalogic/Conservativity/Star/StarAxiomValidity.lean`) both route through. Mirrors
`ofFormula_reflectTime`. -/
theorem ofPlus_reflectTime (φ : PlusFormula) :
    ofPlus φ.reflectTime = (ofPlus φ).reflectTime := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp _ _ ih1 ih2 =>
    simp only [PlusFormula.reflectTime, ofPlus, StarFormula.reflectTime, ih1, ih2]
  | box _ ih => simp only [PlusFormula.reflectTime, ofPlus, StarFormula.reflectTime, ih]
  | untl _ _ ih1 ih2 =>
    simp only [PlusFormula.reflectTime, ofPlus, StarFormula.reflectTime, ih1, ih2]
  | snce _ _ ih1 ih2 =>
    simp only [PlusFormula.reflectTime, ofPlus, StarFormula.reflectTime, ih1, ih2]
  | stab _ ih => simp only [PlusFormula.reflectTime, ofPlus, StarFormula.reflectTime, ih]

/-- The embedding lifted to contexts. Definitionally `List.map ofPlus`. -/
abbrev ofStarCtx (Γ : PlusContext) : StarContext := List.map ofPlus Γ

@[simp] theorem ofStarCtx_nil : ofStarCtx [] = [] := rfl

@[simp] theorem ofStarCtx_cons (φ : PlusFormula) (Γ : PlusContext) :
    ofStarCtx (φ :: Γ) = ofPlus φ :: ofStarCtx Γ := rfl

/-- Membership transports through `ofPlus`. -/
theorem mem_ofStarCtx {φ : PlusFormula} {Γ : PlusContext} (h : φ ∈ Γ) : ofPlus φ ∈ ofStarCtx Γ :=
  List.mem_map_of_mem h

/-! ### `rfl` pins

`ofPlus` commutes with every derived operator **definitionally**, because each L⋆ operator was
given `PlusFormula`'s right-hand side verbatim. If one of these stops being `rfl`, the fix is in
the operator's right-hand side above, never at the use site. -/

theorem ofPlus_top : ofPlus PlusFormula.top = StarFormula.top := rfl

theorem ofPlus_neg (φ : PlusFormula) : ofPlus φ.neg = (ofPlus φ).neg := rfl

theorem ofPlus_and (φ ψ : PlusFormula) :
    ofPlus (φ.and ψ) = (ofPlus φ).and (ofPlus ψ) := rfl

theorem ofPlus_or (φ ψ : PlusFormula) :
    ofPlus (φ.or ψ) = (ofPlus φ).or (ofPlus ψ) := rfl

theorem ofPlus_someFuture (φ : PlusFormula) :
    ofPlus (PlusFormula.someFuture φ) = StarFormula.someFuture (ofPlus φ) := rfl

theorem ofPlus_somePast (φ : PlusFormula) :
    ofPlus (PlusFormula.somePast φ) = StarFormula.somePast (ofPlus φ) := rfl

theorem ofPlus_allFuture (φ : PlusFormula) :
    ofPlus (PlusFormula.allFuture φ) = StarFormula.allFuture (ofPlus φ) := rfl

theorem ofPlus_allPast (φ : PlusFormula) :
    ofPlus (PlusFormula.allPast φ) = StarFormula.allPast (ofPlus φ) := rfl

theorem ofPlus_always (φ : PlusFormula) :
    ofPlus (PlusFormula.always φ) = StarFormula.always (ofPlus φ) := rfl

theorem ofPlus_sometimes (φ : PlusFormula) :
    ofPlus (PlusFormula.sometimes φ) = StarFormula.sometimes (ofPlus φ) := rfl

theorem ofPlus_diamond (φ : PlusFormula) :
    ofPlus φ.diamond = (ofPlus φ).diamond := rfl

theorem ofPlus_dstab (φ : PlusFormula) :
    ofPlus (PlusFormula.dstab φ) = StarFormula.dstab (ofPlus φ) := rfl

example (φ ψ : PlusFormula) : ofPlus (φ.iff ψ) = (ofPlus φ).iff (ofPlus ψ) := rfl
example (φ : PlusFormula) : ofPlus (PlusFormula.kPlus φ) = StarFormula.kPlus (ofPlus φ) := rfl
example (φ : PlusFormula) : ofPlus (PlusFormula.kMinus φ) = StarFormula.kMinus (ofPlus φ) := rfl
example (φ : PlusFormula) : ofPlus (PlusFormula.next φ) = StarFormula.next (ofPlus φ) := rfl
example (φ : PlusFormula) : ofPlus (PlusFormula.prev φ) = StarFormula.prev (ofPlus φ) := rfl
example (φ : PlusFormula) : ofPlus (PlusFormula.Will φ) = StarFormula.Will (ofPlus φ) := rfl
example (φ : PlusFormula) : ofPlus (PlusFormula.will φ) = StarFormula.will (ofPlus φ) := rfl
example (φ : PlusFormula) : ofPlus (PlusFormula.Could φ) = StarFormula.Could (ofPlus φ) := rfl
example (φ : PlusFormula) : ofPlus (PlusFormula.could φ) = StarFormula.could (ofPlus φ) := rfl

/-! ## Side-condition predicates for the TM⋆ schemata

Three purely syntactic fragments of L⋆, each the side condition of one or two `StarAxiom`
constructors (`StarLanguage/Axioms.lean`). They live here, beside `ofPlus`, because the three
transfer lemmas below — which say every embedded formula lies in each fragment — are what make
the corresponding TM⁺ schema block reachable at its embedded instances.

**Why `RecallFree` and not a register-free predicate.** MF (`□φ → □Gφ`) is refuted over L⋆ at
`φ := ↓¹p → p` (`Semantics/StarLanguage/StarNonValidities.lean`, `refute_modal_future`), and the obstruction
is the *recall* register alone: `↓ⁱ` reads at the time register `i` names, which the time-shift
argument moves. `↑ⁱ` is harmless, so a register-free side condition would discard the sound
instances at `↑ⁱ`-formulas — `□↑¹p → □G↑¹p` among them, and `↑¹p` is not an `ofPlus` image
(`ofPlus_ne_timeStore`). The widening past the embedded fragment is therefore proper, and the
`example`s below pin both its lower and its upper boundary. -/

/-- **`↓ⁱ`-free L⋆ formulas**: every `StarFormula` constructor but `timeRecall`.

The side condition of `StarAxiom.modal_future`, the sole TM⋆ schema carrying one its `PlusAxiom`
mirror does not. Semantically it is exactly the fragment on which the stored-time vector is inert
(`Metalogic/Conservativity/Star/StarAxiomValidity.lean`, `recallFree_vector_irrelevant`), which
is what the MF time-shift argument needs and what `↓ⁱ` destroys.

Paper: — (formalization-native; `def:BLstar-semantics` supplies the `↓ⁱ` clause this excludes)
-/
inductive RecallFree : StarFormula → Prop
  | atom (p : Atom) : RecallFree (.atom p)
  | bot : RecallFree .bot
  | imp {φ ψ : StarFormula} : RecallFree φ → RecallFree ψ → RecallFree (.imp φ ψ)
  | box {φ : StarFormula} : RecallFree φ → RecallFree (.box φ)
  | untl {ψ φ : StarFormula} : RecallFree ψ → RecallFree φ → RecallFree (.untl ψ φ)
  | snce {ψ φ : StarFormula} : RecallFree ψ → RecallFree φ → RecallFree (.snce ψ φ)
  | stab {φ : StarFormula} : RecallFree φ → RecallFree (.stab φ)
  | timeStore (i : ℕ) {φ : StarFormula} : RecallFree φ → RecallFree (.timeStore i φ)

/-- **Pure-future L⋆ formulas**: `PlusFormula.IsPureFuture`'s six arms, plus a `timeStore` arm.

The side condition of `StarAxiom.paste` and (in its `hφ` slot) `StarAxiom.untl_paste`.

`timeRecall` is deliberately **absent**: `↓ⁱφ` is read at the time register `i` names, which may
lie on the far side of the pasting point, so a recall is not a future-looking leaf. `box` and
`stab` remain leaves admitting **arbitrary** bodies, exactly as on the L⁺ side — so `□↓¹p` *is*
pure-future, and the L⋆ pasting schemata therefore reach register-carrying formulas that no
`ofPlus` instance supplies.

Paper: `def:BLstar-semantics` (the `↑ⁱ`/`↓ⁱ` clauses distinguishing the two register arms)
-/
inductive StarIsPureFuture : StarFormula → Prop
  | atom (p : Atom) : StarIsPureFuture (.atom p)
  | bot : StarIsPureFuture .bot
  | imp {φ ψ : StarFormula} : StarIsPureFuture φ → StarIsPureFuture ψ →
      StarIsPureFuture (.imp φ ψ)
  | box (φ : StarFormula) : StarIsPureFuture (.box φ)
  | stab (φ : StarFormula) : StarIsPureFuture (.stab φ)
  | untl {ψ φ : StarFormula} : StarIsPureFuture ψ → StarIsPureFuture φ →
      StarIsPureFuture (.untl ψ φ)
  | timeStore (i : ℕ) {φ : StarFormula} : StarIsPureFuture φ →
      StarIsPureFuture (.timeStore i φ)

/-- **Pure-past L⋆ formulas**, the temporal dual of `StarIsPureFuture`: `snce` replaces `untl`.

The side condition of `StarAxiom.paste`'s `hψ` slot and `StarAxiom.untl_paste`'s `hα`. The same
two design points hold: no `timeRecall` arm, and `box`/`stab` are leaves at arbitrary bodies.

Paper: `def:BLstar-semantics`
-/
inductive StarIsPurePast : StarFormula → Prop
  | atom (p : Atom) : StarIsPurePast (.atom p)
  | bot : StarIsPurePast .bot
  | imp {φ ψ : StarFormula} : StarIsPurePast φ → StarIsPurePast ψ → StarIsPurePast (.imp φ ψ)
  | box (φ : StarFormula) : StarIsPurePast (.box φ)
  | stab (φ : StarFormula) : StarIsPurePast (.stab φ)
  | snce {ψ φ : StarFormula} : StarIsPurePast ψ → StarIsPurePast φ → StarIsPurePast (.snce ψ φ)
  | timeStore (i : ℕ) {φ : StarFormula} : StarIsPurePast φ → StarIsPurePast (.timeStore i φ)

/-- `reflectTime` preserves `↓ⁱ`-freedom: it exchanges `untl` and `snce` and fixes everything
else, and `RecallFree` treats those two arms alike. This is what makes the swap arm of
`StarAxiom.modal_future` land. -/
theorem RecallFree.reflectTime {φ : StarFormula} (h : RecallFree φ) :
    RecallFree φ.reflectTime := by
  induction h with
  | atom p => exact RecallFree.atom p
  | bot => exact RecallFree.bot
  | imp _ _ ih1 ih2 => exact RecallFree.imp ih1 ih2
  | box _ ih => exact RecallFree.box ih
  | untl _ _ ih1 ih2 => exact RecallFree.snce ih1 ih2
  | snce _ _ ih1 ih2 => exact RecallFree.untl ih1 ih2
  | stab _ ih => exact RecallFree.stab ih
  | timeStore i _ ih => exact RecallFree.timeStore i ih

/-- `reflectTime` exchanges the two L⋆ purity fragments, mirroring
`PlusFormula.IsPureFuture.reflectTime`. -/
theorem StarIsPureFuture.reflectTime {φ : StarFormula} (h : StarIsPureFuture φ) :
    StarIsPurePast φ.reflectTime := by
  induction h with
  | atom p => exact StarIsPurePast.atom p
  | bot => exact StarIsPurePast.bot
  | imp _ _ ih1 ih2 => exact StarIsPurePast.imp ih1 ih2
  | box φ => exact StarIsPurePast.box _
  | stab φ => exact StarIsPurePast.stab _
  | untl _ _ ih1 ih2 => exact StarIsPurePast.snce ih1 ih2
  | timeStore i _ ih => exact StarIsPurePast.timeStore i ih

/-- The mirror of `StarIsPureFuture.reflectTime`. -/
theorem StarIsPurePast.reflectTime {φ : StarFormula} (h : StarIsPurePast φ) :
    StarIsPureFuture φ.reflectTime := by
  induction h with
  | atom p => exact StarIsPureFuture.atom p
  | bot => exact StarIsPureFuture.bot
  | imp _ _ ih1 ih2 => exact StarIsPureFuture.imp ih1 ih2
  | box φ => exact StarIsPureFuture.box _
  | stab φ => exact StarIsPureFuture.stab _
  | snce _ _ ih1 ih2 => exact StarIsPureFuture.untl ih1 ih2
  | timeStore i _ ih => exact StarIsPureFuture.timeStore i ih

/-! ### Transfer along the embedding

Every embedded formula lies in all three fragments — `ofPlus`'s image mentions no register at
all. These are what let the TM⋆ schemata carrying side conditions be discharged at `ofPlus`
instances, and hence what `StarAxiom.ofPlusAxiom` (`StarLanguage/Embedding.lean`) consumes. -/

/-- Every embedded formula is `↓ⁱ`-free: `ofPlus`'s image contains no register at all. -/
theorem recallFree_ofPlus (ψ : PlusFormula) : RecallFree (ofPlus ψ) := by
  induction ψ with
  | atom p => exact RecallFree.atom p
  | bot => exact RecallFree.bot
  | imp _ _ ih1 ih2 => exact RecallFree.imp ih1 ih2
  | box _ ih => exact RecallFree.box ih
  | untl _ _ ih1 ih2 => exact RecallFree.untl ih1 ih2
  | snce _ _ ih1 ih2 => exact RecallFree.snce ih1 ih2
  | stab _ ih => exact RecallFree.stab ih

/-- `ofPlus` carries `IsPureFuture` to `StarIsPureFuture`, arm for arm. -/
theorem starIsPureFuture_ofPlus {ψ : PlusFormula} (h : PlusFormula.IsPureFuture ψ) :
    StarIsPureFuture (ofPlus ψ) := by
  induction h with
  | atom p => exact StarIsPureFuture.atom p
  | bot => exact StarIsPureFuture.bot
  | imp _ _ ih1 ih2 => exact StarIsPureFuture.imp ih1 ih2
  | box φ => exact StarIsPureFuture.box _
  | stab φ => exact StarIsPureFuture.stab _
  | untl _ _ ih1 ih2 => exact StarIsPureFuture.untl ih1 ih2

/-- `ofPlus` carries `IsPurePast` to `StarIsPurePast`, arm for arm. -/
theorem starIsPurePast_ofPlus {ψ : PlusFormula} (h : PlusFormula.IsPurePast ψ) :
    StarIsPurePast (ofPlus ψ) := by
  induction h with
  | atom p => exact StarIsPurePast.atom p
  | bot => exact StarIsPurePast.bot
  | imp _ _ ih1 ih2 => exact StarIsPurePast.imp ih1 ih2
  | box φ => exact StarIsPurePast.box _
  | stab φ => exact StarIsPurePast.stab _
  | snce _ _ ih1 ih2 => exact StarIsPurePast.snce ih1 ih2

/-! ### Properness pins

The `RecallFree` fragment is **strictly between** the embedded fragment and all of L⋆. Both
inclusions are strict, and both `example`s below are load-bearing: the first says the widening
past the embedded fragment is real rather than cosmetic, the second says it cannot be
dropped. -/

/-- `↑¹p` is `↓ⁱ`-free, so MF holds there — and it is **not** an `ofPlus` image, so this is an
instance the embedded fragment does not supply. The `RecallFree` widening is proper. -/
example (p : Atom) : RecallFree (StarFormula.timeStore 1 (.atom p)) :=
  RecallFree.timeStore 1 (RecallFree.atom p)

example (p : Atom) (ψ : PlusFormula) :
    ofPlus ψ ≠ StarFormula.timeStore 1 (.atom p) := ofPlus_ne_timeStore ψ 1 _

/-- `↓¹p → p` is **not** `↓ⁱ`-free — and it is precisely `refute_modal_future`'s witness
(`Semantics/StarLanguage/StarNonValidities.lean`). The side condition is exactly what excludes it. -/
example (p : Atom) :
    ¬ RecallFree ((StarFormula.timeRecall 1 (.atom p)).imp (.atom p)) := by
  rintro (_ | _ | ⟨h, -⟩)
  cases h

/-- `□↓¹p` is pure-future even though it carries a recall: `StarIsPureFuture.box` admits an
arbitrary body, so the L⋆ pasting schemata reach register-carrying formulas too. -/
example (p : Atom) :
    StarIsPureFuture (StarFormula.box (.timeRecall 1 (.atom p))) := StarIsPureFuture.box _

end FormalSystem.StarLanguage
