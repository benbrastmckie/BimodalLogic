/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.OpenLanguage.OpenAxioms
import FormalSystem.PlusLanguage.Formula

/-!
# `eraseOpen` — the `▷/◁`-deleting retraction of the embedding of L⁺ into L^▷

`eraseOpen : OpenFormula → PlusFormula` deletes every occurrence of the open-future modal `▷` and
the open-past modal `◁`, keeping `⊡` and the six L constructors. It is a **retraction** of
`ofPlus` (`eraseOpen_ofPlus`), it commutes with time reflection (`eraseOpen_reflectTime`), and it
transports both purity side conditions (`isPureFuture_eraseOpen`, `isPurePast_eraseOpen`).

## Why a syntactic deletion rather than a truth-preserving translation

There is no truth-preserving translation of L^▷ into L⁺ at the base class: `▷` is not L⁺-definable
there, by the non-definability result of `FormalSystem/Metalogic/Expressiveness/`. `eraseOpen` is
therefore **not** truth-preserving in general — it is truth-preserving exactly over the
deterministic frames, where `⊡ = ▷ = ◁ = id`
(`Metalogic/Deterministic/OpenCollapse.lean`). What it *is* unconditionally is
**derivability-preserving**, and that is what carries forward conservativity over TM⁺: the
axiom-discharge table below sends each `OpenAxiom` constructor's erasure to a TM⁺ theorem, so an
L^▷ derivation erases rulewise to a TM⁺ derivation. That route is syntactic, needs no engine, and
is unconditional.

## `⊡` stays primitive

`eraseOpen` keeps `⊡` rather than deleting it or expanding it as `▷◁`. Two reasons, both
load-bearing. The `←` half of the definability biconditional `⊡φ ↔ ▷◁φ` needs a regularity
hypothesis on the frame, so a syntactic abbreviation would change `⊡`'s truth conditions off the
regular class. And the decidability front's one working anchor for `⊡` is one bit per cell
(`stab_mem_tpOf_iff_cell`, resting on `stab_state_only`), which routing `⊡` through two
operators that are not state-local would lose.

## Main Definitions

- `eraseOpen` — the deletion, nine arms, one per `OpenFormula` constructor, no wildcard

## Main Results

- `eraseOpen_ofPlus` — the retraction
- `eraseOpen_reflectTime` — erasure commutes with time reflection
- `isPureFuture_eraseOpen`, `isPurePast_eraseOpen` — the purity side conditions transport

## References

* `FormalSystem/OpenLanguage/OpenAxioms.lean` — the axiom type whose erasure this file discharges
* `FormalSystem/Metalogic/Deterministic/Erasure.lean` — `erasePlus`, the `⊡`-deleting erasure
  this one composes with over a deterministic frame

## Tags

open-language · erasure · conservativity · retraction
-/

namespace FormalSystem.OpenLanguage

open FormalSystem.Syntax
open FormalSystem.PlusLanguage (PlusFormula)

/-- Deletion of every `▷` and `◁` occurrence; `⊡` and the six L constructors are kept. Nine arms,
one per `OpenFormula` constructor, no wildcard: a tenth constructor would be a build error here
rather than a silent gap. -/
def eraseOpen : OpenFormula → PlusFormula
  | .atom p => .atom p
  | .bot => .bot
  | .imp φ ψ => .imp (eraseOpen φ) (eraseOpen ψ)
  | .box φ => .box (eraseOpen φ)
  | .untl ψ φ => .untl (eraseOpen ψ) (eraseOpen φ)
  | .snce ψ φ => .snce (eraseOpen ψ) (eraseOpen φ)
  | .stab φ => .stab (eraseOpen φ)
  | .ofut φ => eraseOpen φ
  | .opast φ => eraseOpen φ

/-- `eraseOpen` is a retraction of the embedding `ofPlus`. -/
@[simp] theorem eraseOpen_ofPlus (φ : PlusFormula) : eraseOpen (ofPlus φ) = φ := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp _ _ ih1 ih2 => simp only [ofPlus, eraseOpen, ih1, ih2]
  | box _ ih => simp only [ofPlus, eraseOpen, ih]
  | untl _ _ ih1 ih2 => simp only [ofPlus, eraseOpen, ih1, ih2]
  | snce _ _ ih1 ih2 => simp only [ofPlus, eraseOpen, ih1, ih2]
  | stab _ ih => simp only [ofPlus, eraseOpen, ih]

/-- Erasure commutes with time reflection: `reflectTime` exchanges `▷` with `◁`, which erasure
deletes, and acts on the six L constructors in the same pattern on both sides. -/
theorem eraseOpen_reflectTime (φ : OpenFormula) :
    eraseOpen φ.reflectTime = (eraseOpen φ).reflectTime := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp _ _ ih1 ih2 =>
    simp only [OpenFormula.reflectTime, eraseOpen, PlusFormula.reflectTime, ih1, ih2]
  | box _ ih => simp only [OpenFormula.reflectTime, eraseOpen, PlusFormula.reflectTime, ih]
  | untl _ _ ih1 ih2 =>
    simp only [OpenFormula.reflectTime, eraseOpen, PlusFormula.reflectTime, ih1, ih2]
  | snce _ _ ih1 ih2 =>
    simp only [OpenFormula.reflectTime, eraseOpen, PlusFormula.reflectTime, ih1, ih2]
  | stab _ ih => simp only [OpenFormula.reflectTime, eraseOpen, PlusFormula.reflectTime, ih]
  | ofut _ ih => simp only [OpenFormula.reflectTime, eraseOpen, ih]
  | opast _ ih => simp only [OpenFormula.reflectTime, eraseOpen, ih]

/-! ### Pins

Erasure commutes with the derived operators **definitionally**, because each L^▷ operator was
given `PlusFormula`'s right-hand side verbatim. If one of these stops being `rfl`, the fix is in
the operator's right-hand side in `OpenLanguage/Formula.lean`, never at the use site. `dofut` has
no `PlusFormula` namesake, so its pin records the deletion instead: `▷̂φ := ¬▷¬φ` erases to
`¬¬φ°`. -/

example (φ : OpenFormula) : eraseOpen φ.neg = (eraseOpen φ).neg := rfl
example (φ : OpenFormula) :
    eraseOpen (OpenFormula.somePast φ) = PlusFormula.somePast (eraseOpen φ) := rfl
example (φ : OpenFormula) : eraseOpen (OpenFormula.dofut φ) = (eraseOpen φ).neg.neg := rfl
example (φ : OpenFormula) : eraseOpen (OpenFormula.dstab φ) = PlusFormula.dstab (eraseOpen φ) :=
  rfl

/-! ### The purity transports

These are what the **recursive guards** on `IsPureFutureOpen.opast` and `IsPurePastOpen.ofut`
buy (`OpenLanguage/OpenAxioms.lean`). A blanket leaf clause
`| opast (ψ : OpenFormula) : IsPureFutureOpen (.opast ψ)` is semantically true, but it would make
the `opast` arm below unprovable: `eraseOpen (◁ψ) = eraseOpen ψ` with `ψ` arbitrary, so the arm
would owe `IsPureFuture (eraseOpen ψ)` with no induction hypothesis to supply it. The guard
supplies exactly that hypothesis. -/

/-- The pure-future side condition survives erasure. The `opast` arm is where the recursive guard
is consumed: the erasure deletes the `◁`, so the arm is its own induction hypothesis. -/
theorem isPureFuture_eraseOpen {φ : OpenFormula} (h : IsPureFutureOpen φ) :
    PlusFormula.IsPureFuture (eraseOpen φ) := by
  induction h with
  | atom p => exact PlusFormula.IsPureFuture.atom p
  | bot => exact PlusFormula.IsPureFuture.bot
  | imp _ _ ih1 ih2 => exact PlusFormula.IsPureFuture.imp ih1 ih2
  | box φ => exact PlusFormula.IsPureFuture.box (eraseOpen φ)
  | stab φ => exact PlusFormula.IsPureFuture.stab (eraseOpen φ)
  | untl _ _ ih1 ih2 => exact PlusFormula.IsPureFuture.untl ih1 ih2
  | opast _ ih => exact ih

/-- The pure-past side condition survives erasure. The `ofut` arm is the mirror of
`isPureFuture_eraseOpen`'s `opast` arm. -/
theorem isPurePast_eraseOpen {φ : OpenFormula} (h : IsPurePastOpen φ) :
    PlusFormula.IsPurePast (eraseOpen φ) := by
  induction h with
  | atom p => exact PlusFormula.IsPurePast.atom p
  | bot => exact PlusFormula.IsPurePast.bot
  | imp _ _ ih1 ih2 => exact PlusFormula.IsPurePast.imp ih1 ih2
  | box φ => exact PlusFormula.IsPurePast.box (eraseOpen φ)
  | stab φ => exact PlusFormula.IsPurePast.stab (eraseOpen φ)
  | snce _ _ ih1 ih2 => exact PlusFormula.IsPurePast.snce ih1 ih2
  | ofut _ ih => exact ih

end FormalSystem.OpenLanguage
