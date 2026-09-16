/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.Formula
import FormalSystem.Syntax.Context

/-!
# `PlusFormula` — the language L⁺: L plus the stability modal `⊡`

This module defines the language **L⁺** obtained from the until/since-primitive language L
(`FormalSystem.Syntax.Formula`) by adding one primitive unary operator, the **stability modal**
`⊡` (`stab`), read "settled at the present world state":

```
φ, ψ ::= pᵢ | ⊥ | φ → ψ | □φ | φ U ψ | φ S ψ | ⊡φ
```

The paper (`possible_worlds.tex`) introduces `⊡` in `def:BLstar-semantics`: `M,τ,x ⊨ ⊡φ` iff `M,σ,x ⊨ φ`
for every possible world `σ ∈ ⟨τ⟩_x`, where `⟨τ⟩_x := {σ ∈ H_F | σ(x) = τ(x)}` (line 1108) is
the set of worlds that share `τ`'s world state at `x`. The dual `⟐φ := ¬⊡¬φ` is line 1121
(`dstab`), and the defined modals `Will := ⊡G`, `will := ⊡F`, `Could := ⟐G`, `could := ⟐F`
are lines 1125-1129.

**Scope.** L⁺ here is L plus `⊡` only, and it is therefore the **⊡-only fragment** of the
manuscript's `\BL^\star` (`sub:Extension`), not a language the manuscript names. `\BL^\star`
additionally carries the hybrid store/recall operators `\timeStore^i, \timeRecall^i,
\worldStore^i, \worldRecall^i`, which change the point of evaluation and would need a different
truth-definition signature; they are **out of scope** for this component, and their
time-register half is what this tree reserves the name L⋆ (`FormalSystem/StarLanguage/`) for.

## Design

`PlusFormula` is a **separate inductive** with a constructor-to-constructor embedding
`ofFormula : Formula → PlusFormula`, mirroring the landed `MinusFormula`/`tr` pattern of
`FormalSystem/MinusLanguage/`. Every derived operator below has the **same right-hand side** as
its `Formula` namesake in `Syntax/Formula.lean`, so that `ofFormula` pushes through each of them
by `rfl` — the `rfl` pins at the end of this file are what the proof-system embedding
(`PlusLanguage/Derivation.lean`) and the atomization transfer
(`Metalogic/Conservativity/Plus/Atomization.lean`) rely on.

## Main Definitions

- `PlusFormula`: seven-constructor inductive type for L⁺; `PlusContext := List PlusFormula`
- Derived operators with `Formula`'s right-hand sides: `top`, `neg`, `and`, `or`, `iff`,
  `diamond`, `someFuture`, `somePast`, `allFuture`, `allPast`, `kPlus`, `kMinus`, `always`,
  `sometimes`, `next`, `prev`
- The `⊡`-specific operators `dstab` (`⟐`), `Will`, `will`, `Could`, `could`
- `PlusFormula.swapTemporal`: the past/future interchange for the TD rule (`stab ↦ stab`)
- `IsPureFuture`, `IsPurePast`: the syntactic purity predicates that guard the pasting axioms
- `ofFormula`, `ofCtx`: the embedding of L into L⁺

## Main Results

- `DecidableEq`, `Countable`, `Infinite`, `Denumerable` for `PlusFormula`
- `swap_temporal_involution` and the push-through lemmas for every derived operator
- `IsPureFuture.swapTemporal`, `IsPurePast.swapTemporal`: `swapTemporal` exchanges the purity
  predicates
- `ofFormula_injective`, `ofFormula_ne_stab`, `ofFormula_swapTemporal`, `mem_ofCtx`

## Module Invariant

**Nothing under `FormalSystem/PlusLanguage/` imports anything from `FormalSystem/Semantics/`.**
This mirrors the `MinusLanguage/ → Semantics/` prohibition recorded in
`FormalSystem/MinusLanguage/Formula.lean`, and for the same reason: the proof system and its
embedding are purely syntactic. The invariant is **directional** — the converse edge is
permitted and used: `FormalSystem/Semantics/PlusTruth.lean` imports this module to define
`PlusTruthAt` natively on the seven constructors.

## References

* JPL paper `possible_worlds.tex` lines 1108-1129 — `⟨τ⟩_x`, the `⊡` clause, `⟐`, and the
  defined modals; `sub:Extension` — the (out-of-scope) store/recall operators
* `FormalSystem/Syntax/Formula.lean` — the L side whose derived operators are mirrored here
* `FormalSystem/MinusLanguage/Formula.lean` — the pattern this component follows
-/

namespace FormalSystem.PlusLanguage

open FormalSystem.Syntax

/--
Formula type for the language L⁺: the six constructors of `Formula` plus the stability modal.

Constructor order and argument order (guard first, event second for `untl`/`snce`) are those of
`FormalSystem.Syntax.Formula`, so that `ofFormula` is constructor-to-constructor.
-/
inductive PlusFormula : Type where
  /-- Propositional atom (variable). -/
  | atom : Atom → PlusFormula
  /-- Bottom (`⊥`, falsum). -/
  | bot : PlusFormula
  /-- Implication (`φ → ψ`). -/
  | imp : PlusFormula → PlusFormula → PlusFormula
  /-- Modal necessity (`□φ`). -/
  | box : PlusFormula → PlusFormula
  /-- Until, `φ U ψ`, guard first and event second, exactly as `Formula.untl`. -/
  | untl : PlusFormula → PlusFormula → PlusFormula
  /-- Since, `φ S ψ`, guard first and event second, exactly as `Formula.snce`. -/
  | snce : PlusFormula → PlusFormula → PlusFormula
  /-- The stability modal `⊡φ` (`def:BLstar-semantics`): `φ` holds in every world sharing the present
      world state. -/
  | stab : PlusFormula → PlusFormula
  deriving Repr, DecidableEq, Countable

/-- `PlusFormula.atom` is injective. -/
theorem PlusFormula.atom_injective : Function.Injective PlusFormula.atom := by
  intro a b h
  injection h

/-- `PlusFormula` is infinite, via the injection of atoms. -/
instance : Infinite PlusFormula :=
  Infinite.of_injective PlusFormula.atom PlusFormula.atom_injective

/-- `PlusFormula` is denumerable (countable + infinite), exactly as `Formula` obtains it. -/
noncomputable instance : Denumerable PlusFormula :=
  Classical.choice (nonempty_denumerable PlusFormula)

/-- Contexts of L⁺ formulas. -/
abbrev PlusContext := List PlusFormula

namespace PlusFormula

/-! ### Derived operators

Each right-hand side is copied verbatim from `Syntax/Formula.lean`, so that `ofFormula`
commutes with it by `rfl` (see the pins at the end of the file). -/

/-- Top (`⊤`): `⊥ → ⊥`. Mirrors `Formula.top`. -/
def top : PlusFormula := PlusFormula.bot.imp PlusFormula.bot

/-- Negation (`¬φ`): `φ → ⊥`. Mirrors `Formula.neg`. -/
def neg (φ : PlusFormula) : PlusFormula := φ.imp bot

/-- Existential future (`Fφ`): `⊤ U φ`. Mirrors `Formula.someFuture`. -/
def someFuture (φ : PlusFormula) : PlusFormula := PlusFormula.untl PlusFormula.top φ

/-- Existential past (`Pφ`): `⊤ S φ`. Mirrors `Formula.somePast`. -/
def somePast (φ : PlusFormula) : PlusFormula := PlusFormula.snce PlusFormula.top φ

/-- Universal future (`Gφ`): `¬F¬φ`. Mirrors `Formula.allFuture`. -/
def allFuture (φ : PlusFormula) : PlusFormula := (someFuture φ.neg).neg

/-- Universal past (`Hφ`): `¬P¬φ`. Mirrors `Formula.allPast`. -/
def allPast (φ : PlusFormula) : PlusFormula := (somePast φ.neg).neg

/-- Reynolds' `K⁺`: `¬U(¬φ, ⊤)` in guard-first order. Mirrors `Formula.kPlus`. -/
def kPlus (φ : PlusFormula) : PlusFormula := (PlusFormula.untl φ.neg PlusFormula.top).neg

/-- Reynolds' `K⁻`: `¬S(¬φ, ⊤)` in guard-first order. Mirrors `Formula.kMinus`. -/
def kMinus (φ : PlusFormula) : PlusFormula := (PlusFormula.snce φ.neg PlusFormula.top).neg

/-- Conjunction (`φ ∧ ψ`): `¬(φ → ¬ψ)`. Mirrors `Formula.and`. -/
def and (φ ψ : PlusFormula) : PlusFormula := (φ.imp ψ.neg).neg

/-- Disjunction (`φ ∨ ψ`): `¬φ → ψ`. Mirrors `Formula.or`. -/
def or (φ ψ : PlusFormula) : PlusFormula := φ.neg.imp ψ

/-- Biconditional (`φ ↔ ψ`): `(φ → ψ) ∧ (ψ → φ)`. -/
def iff (φ ψ : PlusFormula) : PlusFormula := (φ.imp ψ).and (ψ.imp φ)

/-- Modal possibility (`◇φ`): `¬□¬φ`. Mirrors `Formula.diamond`. -/
def diamond (φ : PlusFormula) : PlusFormula := φ.neg.box.neg

/-- Temporal `always` (`△φ`): `Hφ ∧ (φ ∧ Gφ)`. Mirrors `Formula.always`. -/
def always (φ : PlusFormula) : PlusFormula := φ.allPast.and (φ.and φ.allFuture)

/-- Temporal `sometimes` (`▽φ`): `¬△¬φ`. Mirrors `Formula.sometimes`. -/
def sometimes (φ : PlusFormula) : PlusFormula := φ.neg.always.neg

/-- Next-step (`Xφ`): `⊥ U φ`. Mirrors `Formula.next`. -/
def next (φ : PlusFormula) : PlusFormula := PlusFormula.untl PlusFormula.bot φ

/-- Previous-step (`Yφ`): `⊥ S φ`. Mirrors `Formula.prev`. -/
def prev (φ : PlusFormula) : PlusFormula := PlusFormula.snce PlusFormula.bot φ

/-! ### The `⊡`-specific operators (paper lines 1121, 1125-1129) -/

/-- The dual stability modal `⟐φ := ¬⊡¬φ` (paper line 1121): `φ` holds in *some* world sharing
the present world state. -/
def dstab (φ : PlusFormula) : PlusFormula := neg (.stab (neg φ))

/-- `Will φ := ⊡Gφ` (paper line 1125): settled to hold at every future time. -/
def Will (φ : PlusFormula) : PlusFormula := .stab (allFuture φ)

/-- `will φ := ⊡Fφ` (paper line 1126): settled to hold at some future time. -/
def will (φ : PlusFormula) : PlusFormula := .stab (someFuture φ)

/-- `Could φ := ⟐Gφ` (paper line 1128): possibly, relative to the present state, always
future. -/
def Could (φ : PlusFormula) : PlusFormula := dstab (allFuture φ)

/-- `could φ := ⟐Fφ` (paper line 1129): possibly, relative to the present state, sometime
future. -/
def could (φ : PlusFormula) : PlusFormula := dstab (someFuture φ)

/-! ### Temporal duality -/

/--
Swap temporal operators (past ↔ future) in an L⁺ formula.

Mirrors `Formula.swapTemporal` constructor for constructor; the new case sends `stab φ` to
`stab φ.swapTemporal` — `⊡` is fixed by time reversal because `⟨τ⟩_x` is defined by a
same-time condition on world states.
-/
def swapTemporal : PlusFormula → PlusFormula
  | atom s => atom s
  | bot => bot
  | imp φ ψ => imp φ.swapTemporal ψ.swapTemporal
  | box φ => box φ.swapTemporal
  | untl ψ φ => snce ψ.swapTemporal φ.swapTemporal
  | snce ψ φ => untl ψ.swapTemporal φ.swapTemporal
  | stab φ => stab φ.swapTemporal

/-- `swapTemporal` is an involution. -/
theorem swap_temporal_involution (φ : PlusFormula) :
    φ.swapTemporal.swapTemporal = φ := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp _ _ ihp ihq => simp only [swapTemporal, ihp, ihq]
  | box _ ih => simp only [swapTemporal, ih]
  | untl _ _ ih2 ih1 => simp only [swapTemporal, ih1, ih2]
  | snce _ _ ih2 ih1 => simp only [swapTemporal, ih1, ih2]
  | stab _ ih => simp only [swapTemporal, ih]

/-! The push-through lemmas, mirroring the `Formula.swap_temporal_*` family. -/

theorem swap_temporal_top : top.swapTemporal = top := rfl

theorem swap_temporal_neg (φ : PlusFormula) :
    φ.neg.swapTemporal = φ.swapTemporal.neg := by
  simp only [neg, swapTemporal]

theorem swap_temporal_diamond (φ : PlusFormula) :
    φ.diamond.swapTemporal = φ.swapTemporal.diamond := by
  simp only [diamond, neg, swapTemporal]

@[simp]
theorem swap_temporal_some_future (φ : PlusFormula) :
    (someFuture φ).swapTemporal = somePast φ.swapTemporal := by
  simp only [someFuture, somePast, top, swapTemporal]

@[simp]
theorem swap_temporal_some_past (φ : PlusFormula) :
    (somePast φ).swapTemporal = someFuture φ.swapTemporal := by
  simp only [somePast, someFuture, top, swapTemporal]

@[simp]
theorem swap_temporal_all_future (φ : PlusFormula) :
    (allFuture φ).swapTemporal = allPast φ.swapTemporal := by
  simp only [allFuture, allPast, someFuture, somePast, neg, top, swapTemporal]

@[simp]
theorem swap_temporal_all_past (φ : PlusFormula) :
    (allPast φ).swapTemporal = allFuture φ.swapTemporal := by
  simp only [allPast, allFuture, somePast, someFuture, neg, top, swapTemporal]

theorem swap_temporal_next (φ : PlusFormula) :
    φ.next.swapTemporal = φ.swapTemporal.prev := by
  simp only [next, prev, swapTemporal]

theorem swap_temporal_prev (φ : PlusFormula) :
    φ.prev.swapTemporal = φ.swapTemporal.next := by
  simp only [prev, next, swapTemporal]

theorem swap_temporal_and (φ ψ : PlusFormula) :
    (φ.and ψ).swapTemporal = φ.swapTemporal.and ψ.swapTemporal := by
  simp only [and, neg, swapTemporal]

theorem swap_temporal_or (φ ψ : PlusFormula) :
    (φ.or ψ).swapTemporal = φ.swapTemporal.or ψ.swapTemporal := by
  simp only [or, neg, swapTemporal]

theorem swap_temporal_kPlus (φ : PlusFormula) :
    φ.kPlus.swapTemporal = φ.swapTemporal.kMinus := by
  simp only [kPlus, kMinus, neg, top, swapTemporal]

theorem swap_temporal_kMinus (φ : PlusFormula) :
    φ.kMinus.swapTemporal = φ.swapTemporal.kPlus := by
  simp only [kMinus, kPlus, neg, top, swapTemporal]

/-- `swapTemporal` fixes `⟐`, as it fixes `⊡`. -/
theorem swap_temporal_dstab (φ : PlusFormula) :
    (dstab φ).swapTemporal = dstab φ.swapTemporal := by
  simp only [dstab, neg, swapTemporal]

/-! ### Purity predicates

The side conditions of the pasting axioms (`PlusLanguage/Axioms.lean`, `paste` and
`untl_paste`). A formula is **pure-future** if it contains no `snce` outside a `box`/`stab`
scope, and **pure-past** if it contains no `untl` outside such a scope. `box ψ` and `stab ψ` are
leaves for any `ψ`: `□ψ` is history-independent, and `⊡ψ` depends on the present world state
alone, so neither looks along the history in either direction. -/

/-- Pure-future formulas: no `snce` outside a `box`/`stab` scope. -/
inductive IsPureFuture : PlusFormula → Prop
  | atom (p : Atom) : IsPureFuture (.atom p)
  | bot : IsPureFuture .bot
  | imp {φ ψ : PlusFormula} : IsPureFuture φ → IsPureFuture ψ → IsPureFuture (.imp φ ψ)
  | box (φ : PlusFormula) : IsPureFuture (.box φ)
  | stab (φ : PlusFormula) : IsPureFuture (.stab φ)
  | untl {ψ φ : PlusFormula} : IsPureFuture ψ → IsPureFuture φ → IsPureFuture (.untl ψ φ)

/-- Pure-past formulas: no `untl` outside a `box`/`stab` scope. -/
inductive IsPurePast : PlusFormula → Prop
  | atom (p : Atom) : IsPurePast (.atom p)
  | bot : IsPurePast .bot
  | imp {φ ψ : PlusFormula} : IsPurePast φ → IsPurePast ψ → IsPurePast (.imp φ ψ)
  | box (φ : PlusFormula) : IsPurePast (.box φ)
  | stab (φ : PlusFormula) : IsPurePast (.stab φ)
  | snce {ψ φ : PlusFormula} : IsPurePast ψ → IsPurePast φ → IsPurePast (.snce ψ φ)

/-- `swapTemporal` sends pure-future formulas to pure-past ones. -/
theorem IsPureFuture.swapTemporal {φ : PlusFormula} (h : IsPureFuture φ) :
    IsPurePast φ.swapTemporal := by
  induction h with
  | atom p => exact IsPurePast.atom p
  | bot => exact IsPurePast.bot
  | imp _ _ ih1 ih2 => exact IsPurePast.imp ih1 ih2
  | box φ => exact IsPurePast.box _
  | stab φ => exact IsPurePast.stab _
  | untl _ _ ih1 ih2 => exact IsPurePast.snce ih1 ih2

/-- `swapTemporal` sends pure-past formulas to pure-future ones. -/
theorem IsPurePast.swapTemporal {φ : PlusFormula} (h : IsPurePast φ) :
    IsPureFuture φ.swapTemporal := by
  induction h with
  | atom p => exact IsPureFuture.atom p
  | bot => exact IsPureFuture.bot
  | imp _ _ ih1 ih2 => exact IsPureFuture.imp ih1 ih2
  | box φ => exact IsPureFuture.box _
  | stab φ => exact IsPureFuture.stab _
  | snce _ _ ih1 ih2 => exact IsPureFuture.untl ih1 ih2

/-! Closure of the purity predicates under the derived Boolean and temporal operators. -/

theorem IsPureFuture.top : IsPureFuture top := IsPureFuture.imp IsPureFuture.bot IsPureFuture.bot

theorem IsPureFuture.neg {φ : PlusFormula} (h : IsPureFuture φ) : IsPureFuture φ.neg :=
  IsPureFuture.imp h IsPureFuture.bot

theorem IsPureFuture.and {φ ψ : PlusFormula} (hφ : IsPureFuture φ) (hψ : IsPureFuture ψ) :
    IsPureFuture (φ.and ψ) :=
  (IsPureFuture.imp hφ hψ.neg).neg

theorem IsPureFuture.someFuture {φ : PlusFormula} (h : IsPureFuture φ) :
    IsPureFuture (someFuture φ) :=
  IsPureFuture.untl IsPureFuture.top h

theorem IsPureFuture.allFuture {φ : PlusFormula} (h : IsPureFuture φ) :
    IsPureFuture (allFuture φ) :=
  h.neg.someFuture.neg

theorem IsPurePast.top : IsPurePast top := IsPurePast.imp IsPurePast.bot IsPurePast.bot

theorem IsPurePast.neg {φ : PlusFormula} (h : IsPurePast φ) : IsPurePast φ.neg :=
  IsPurePast.imp h IsPurePast.bot

theorem IsPurePast.and {φ ψ : PlusFormula} (hφ : IsPurePast φ) (hψ : IsPurePast ψ) :
    IsPurePast (φ.and ψ) :=
  (IsPurePast.imp hφ hψ.neg).neg

theorem IsPurePast.somePast {φ : PlusFormula} (h : IsPurePast φ) :
    IsPurePast (somePast φ) :=
  IsPurePast.snce IsPurePast.top h

theorem IsPurePast.allPast {φ : PlusFormula} (h : IsPurePast φ) :
    IsPurePast (allPast φ) :=
  h.neg.somePast.neg

end PlusFormula

/-! ## The embedding of L into L⁺ -/

/-- The embedding of L into L⁺, constructor to constructor. -/
def ofFormula : Formula → PlusFormula
  | .atom a => .atom a
  | .bot => .bot
  | .imp φ ψ => .imp (ofFormula φ) (ofFormula ψ)
  | .box φ => .box (ofFormula φ)
  | .untl φ ψ => .untl (ofFormula φ) (ofFormula ψ)
  | .snce φ ψ => .snce (ofFormula φ) (ofFormula ψ)

/-- `ofFormula` is injective. Per-constructor `cases` on the target with the induction
hypotheses applied by `rw`; `simp_all` alone does not use them. -/
theorem ofFormula_injective : Function.Injective ofFormula := by
  intro φ ψ h
  induction φ generalizing ψ with
  | atom a => cases ψ <;> simp_all [ofFormula]
  | bot => cases ψ <;> simp_all [ofFormula]
  | imp φ₁ φ₂ ih₁ ih₂ =>
    cases ψ <;> simp [ofFormula] at h
    rw [ih₁ h.1, ih₂ h.2]
  | box φ ih =>
    cases ψ <;> simp [ofFormula] at h
    rw [ih h]
  | untl φ₁ φ₂ ih₁ ih₂ =>
    cases ψ <;> simp [ofFormula] at h
    rw [ih₁ h.1, ih₂ h.2]
  | snce φ₁ φ₂ ih₁ ih₂ =>
    cases ψ <;> simp [ofFormula] at h
    rw [ih₁ h.1, ih₂ h.2]

/-- Nothing in the range of `ofFormula` is a top-level `stab`. The L⁺ mirror of
`MinusLanguage.tr_ne_untl`. -/
@[simp] theorem ofFormula_ne_stab (φ : Formula) (ψ : PlusFormula) :
    ofFormula φ ≠ PlusFormula.stab ψ := by
  cases φ <;> simp [ofFormula]

/-- `ofFormula` commutes with temporal duality, which is what the `temporal_duality` case of the
proof-system embedding needs. -/
theorem ofFormula_swapTemporal (φ : Formula) :
    ofFormula φ.swapTemporal = (ofFormula φ).swapTemporal := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp _ _ ih1 ih2 => simp only [Formula.swapTemporal, ofFormula, PlusFormula.swapTemporal, ih1, ih2]
  | box _ ih => simp only [Formula.swapTemporal, ofFormula, PlusFormula.swapTemporal, ih]
  | untl _ _ ih1 ih2 => simp only [Formula.swapTemporal, ofFormula, PlusFormula.swapTemporal, ih1, ih2]
  | snce _ _ ih1 ih2 => simp only [Formula.swapTemporal, ofFormula, PlusFormula.swapTemporal, ih1, ih2]

/-- The embedding lifted to contexts. Definitionally `List.map ofFormula`. -/
abbrev ofCtx (Γ : Context) : PlusContext := List.map ofFormula Γ

@[simp] theorem ofCtx_nil : ofCtx [] = [] := rfl

@[simp] theorem ofCtx_cons (φ : Formula) (Γ : Context) :
    ofCtx (φ :: Γ) = ofFormula φ :: ofCtx Γ := rfl

/-- Membership transports through `ofFormula`. -/
theorem mem_ofCtx {φ : Formula} {Γ : Context} (h : φ ∈ Γ) : ofFormula φ ∈ ofCtx Γ :=
  List.mem_map_of_mem h

/-! ### `rfl` pins

`ofFormula` commutes with every derived operator **definitionally**, because each L⁺ operator
was given `Formula`'s right-hand side verbatim. These `example`s are the contract the
`PlusAxiom.ofTM` arms (`PlusLanguage/Derivation.lean`) and the atomization push-through
lemmas rely on; if one of them stops being `rfl`, the fix is in the operator's right-hand side
above, never at the use site. -/

example : ofFormula Formula.top = PlusFormula.top := rfl
example (φ : Formula) : ofFormula φ.neg = (ofFormula φ).neg := rfl
example (φ ψ : Formula) : ofFormula (φ.and ψ) = (ofFormula φ).and (ofFormula ψ) := rfl
example (φ ψ : Formula) : ofFormula (φ.or ψ) = (ofFormula φ).or (ofFormula ψ) := rfl
example (φ : Formula) : ofFormula φ.diamond = (ofFormula φ).diamond := rfl
example (φ : Formula) : ofFormula (Formula.someFuture φ) = PlusFormula.someFuture (ofFormula φ) := rfl
example (φ : Formula) : ofFormula (Formula.somePast φ) = PlusFormula.somePast (ofFormula φ) := rfl
example (φ : Formula) : ofFormula (Formula.allFuture φ) = PlusFormula.allFuture (ofFormula φ) := rfl
example (φ : Formula) : ofFormula (Formula.allPast φ) = PlusFormula.allPast (ofFormula φ) := rfl
example (φ : Formula) : ofFormula (Formula.kPlus φ) = PlusFormula.kPlus (ofFormula φ) := rfl
example (φ : Formula) : ofFormula (Formula.kMinus φ) = PlusFormula.kMinus (ofFormula φ) := rfl
example (φ : Formula) : ofFormula (Formula.always φ) = PlusFormula.always (ofFormula φ) := rfl
example (φ : Formula) : ofFormula (Formula.sometimes φ) = PlusFormula.sometimes (ofFormula φ) := rfl
example (φ : Formula) : ofFormula (Formula.next φ) = PlusFormula.next (ofFormula φ) := rfl
example (φ : Formula) : ofFormula (Formula.prev φ) = PlusFormula.prev (ofFormula φ) := rfl

end FormalSystem.PlusLanguage
