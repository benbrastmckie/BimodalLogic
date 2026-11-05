/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.OpenLanguage.OpenDerivation
import FormalSystem.PlusLanguage.Formula
import FormalSystem.PlusLanguage.Substitution
import FormalSystem.Theorems.Propositional.Core
import FormalSystem.Theorems.TemporalDerived

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
open FormalSystem.ProofSystem (FrameClass)
open FormalSystem.PlusLanguage (PlusFormula PlusContext PlusAxiom PlusDerivationTree PlusDerivable)

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

/-! ## The axiom-discharge table

For each `OpenAxiom` constructor, a TM⁺ derivation of the schema's `eraseOpen` image. The table
is **wildcard-free**, exactly like the two dispatch lemmas of
`Metalogic/Conservativity/Open/OpenAxiomValidity.lean`: a constructor added without a discharge
arm is a build error here rather than a silent gap in forward conservativity.

Three shapes cover 69 of the 71 arms.

* **An identity.** Every schema whose erasure deletes the only operator it talks about collapses
  to `φ° → φ°`: the whole S5 block for `▷` and for `◁`, both halves of both rigidity schemata.
  `plusIdImp` discharges them.
* **A TM⁺ axiom at the erased parameters.** Each of the 53 re-declared TM⁺ schemata erases to its
  own `PlusAxiom` namesake, because `eraseOpen` commutes with every constructor and with every
  derived operator by `rfl`. Each bridge to `⊡` erases to `stab_t` or `box_stab`.
* **A substituted TM theorem.** The two Ockhamist arms are the only ones that are not one-liners:
  `Pα → ▷P▷̂α` erases to `Pα° → P¬¬α°`, which is `somePastMono` of `impNegImp` transported to an
  arbitrary L⁺ argument by `PlusDerivationTree.ofTMSubst`.

**This is the surface that excludes the backward definability half.** `▷◁φ → ⊡φ` erases to
`φ → ⊡φ`, the *Determined* schema, which `PlusLanguage/PlusNonValidities.lean` refutes at the base
class; by TM⁺ soundness its erasure is a TM⁺ theorem at no frame class, so no arm for it can
exist. Admitting the constructor would not weaken this table — it would make it impossible. -/

/-- `⊢⁺[fc] φ → φ`, the identity combinator, from `prop_k` and `prop_s`. -/
def plusIdImp {fc : FrameClass} (φ : PlusFormula) : ⊢⁺[fc] φ.imp φ :=
  .modus_ponens [] _ _
    (.modus_ponens [] _ _
      (.axiom [] _ (PlusAxiom.prop_k φ (φ.imp φ) φ) (FrameClass.base_le fc))
      (.axiom [] _ (PlusAxiom.prop_s φ (φ.imp φ)) (FrameClass.base_le fc)))
    (.axiom [] _ (PlusAxiom.prop_s φ φ) (FrameClass.base_le fc))

section Discharge

variable {fc : FrameClass}

/-! ### The S5 block for `▷` and for `◁`

Each of the eight schemata mentions no operator but its own, so its erasure is an identity. -/

/-- `▷`-K erases to an identity. -/
def dischargeOfutK (φ ψ : OpenFormula) :
    ⊢⁺[fc] eraseOpen ((OpenFormula.ofut (φ.imp ψ)).imp
      ((OpenFormula.ofut φ).imp (OpenFormula.ofut ψ))) :=
  plusIdImp _

/-- `▷`-T erases to an identity. -/
def dischargeOfutT (φ : OpenFormula) : ⊢⁺[fc] eraseOpen ((OpenFormula.ofut φ).imp φ) :=
  plusIdImp _

/-- `▷`-4 erases to an identity. -/
def dischargeOfutFour (φ : OpenFormula) :
    ⊢⁺[fc] eraseOpen ((OpenFormula.ofut φ).imp (OpenFormula.ofut (OpenFormula.ofut φ))) :=
  plusIdImp _

/-- `▷`-5 erases to an identity. -/
def dischargeOfutFive (φ : OpenFormula) :
    ⊢⁺[fc] eraseOpen ((OpenFormula.dofut φ).imp (OpenFormula.ofut (OpenFormula.dofut φ))) :=
  plusIdImp _

/-- `◁`-K erases to an identity. -/
def dischargeOpastK (φ ψ : OpenFormula) :
    ⊢⁺[fc] eraseOpen ((OpenFormula.opast (φ.imp ψ)).imp
      ((OpenFormula.opast φ).imp (OpenFormula.opast ψ))) :=
  plusIdImp _

/-- `◁`-T erases to an identity. -/
def dischargeOpastT (φ : OpenFormula) : ⊢⁺[fc] eraseOpen ((OpenFormula.opast φ).imp φ) :=
  plusIdImp _

/-- `◁`-4 erases to an identity. -/
def dischargeOpastFour (φ : OpenFormula) :
    ⊢⁺[fc] eraseOpen ((OpenFormula.opast φ).imp (OpenFormula.opast (OpenFormula.opast φ))) :=
  plusIdImp _

/-- `◁`-5 erases to an identity. -/
def dischargeOpastFive (φ : OpenFormula) :
    ⊢⁺[fc] eraseOpen ((OpenFormula.dopast φ).imp (OpenFormula.opast (OpenFormula.dopast φ))) :=
  plusIdImp _

/-! ### The bridges and the forward definability half -/

/-- `□φ → ⊡φ` erases to MS (`box_stab`) verbatim: erasure keeps both operators. -/
def dischargeStabOfBox (φ : OpenFormula) :
    ⊢⁺[fc] eraseOpen ((OpenFormula.box φ).imp (OpenFormula.stab φ)) :=
  .axiom [] _ (PlusAxiom.box_stab (eraseOpen φ)) (FrameClass.base_le fc)

/-- `⊡φ → ▷φ` erases to ST (`stab_t`). -/
def dischargeOfutOfStab (φ : OpenFormula) :
    ⊢⁺[fc] eraseOpen ((OpenFormula.stab φ).imp (OpenFormula.ofut φ)) :=
  .axiom [] _ (PlusAxiom.stab_t (eraseOpen φ)) (FrameClass.base_le fc)

/-- `⊡φ → ◁φ` erases to ST as well. -/
def dischargeOpastOfStab (φ : OpenFormula) :
    ⊢⁺[fc] eraseOpen ((OpenFormula.stab φ).imp (OpenFormula.opast φ)) :=
  .axiom [] _ (PlusAxiom.stab_t (eraseOpen φ)) (FrameClass.base_le fc)

/-- `⊡φ → ▷◁φ` erases to ST: the consequent's two restricted modals are both deleted. -/
def dischargeDefinabilityFwd (φ : OpenFormula) :
    ⊢⁺[fc] eraseOpen ((OpenFormula.stab φ).imp
      (OpenFormula.ofut (OpenFormula.opast φ))) :=
  .axiom [] _ (PlusAxiom.stab_t (eraseOpen φ)) (FrameClass.base_le fc)

/-! ### The rigidity blocks

Both halves of both rigidity schemata erase to the same identity `φ° → φ°`, which is precisely why
the two schemata are stated as implication **pairs** rather than biconditionals: each half is
discharged on its own, and a biconditional would have to be assembled from them anyway. The
`▷`-guarded pair reuses these two terms, since its erasure is the same formula. -/

/-- `◁φ⁺ → φ⁺` erases to an identity; reused for `▷ψ⁻ → ψ⁻`. -/
def dischargeRigidityFwd (φ : OpenFormula) :
    ⊢⁺[fc] eraseOpen ((OpenFormula.opast φ).imp φ) :=
  plusIdImp _

/-- `φ⁺ → ◁φ⁺` erases to an identity; reused for `ψ⁻ → ▷ψ⁻`. -/
def dischargeRigidityBwd (φ : OpenFormula) :
    ⊢⁺[fc] eraseOpen (φ.imp (OpenFormula.opast φ)) :=
  plusIdImp _

/-! ### The two Ockhamist arms

The only arms that are not one-liners. `Pα → ▷P▷̂α` erases to `Pα° → P¬¬α°` and its mirror
`Fα → ◁F◁̂α` to `Fα° → F¬¬α°`; each is a TM theorem at one atom, transported to the arbitrary L⁺
argument `α°` by `PlusDerivationTree.ofTMSubst`, which is `Type`-valued and so usable inside the
`Type`-valued table below. -/

/-- The atom the two Ockhamist TM theorems are stated at before substitution. Its identity is
irrelevant: `ofTMSubst` replaces every atom by `eraseOpen α`. -/
private def hnProxyAtom : Atom := ⟨"p", none⟩

/-- **The Ockhamist arm.** `Pα → ▷P▷̂α` erases to `Pα° → P¬¬α°`, which is
`Theorems.TemporalDerived.somePastMono` applied to `Theorems.Propositional.impNegImp`, substituted
at `α°`. -/
def dischargeHnOpen (α : OpenFormula) :
    ⊢⁺[fc] eraseOpen ((OpenFormula.somePast α).imp
      (OpenFormula.ofut (OpenFormula.somePast (OpenFormula.dofut α)))) :=
  PlusDerivationTree.ofTMSubst (fun _ => eraseOpen α)
    (Theorems.TemporalDerived.somePastMono
      (Theorems.Propositional.impNegImp (Formula.atom hnProxyAtom) Formula.bot))

/-- **The open-past Ockhamist arm.** `Fα → ◁F◁̂α` erases to `Fα° → F¬¬α°`, the future mirror of
`dischargeHnOpen` through `someFutureMono`. -/
def dischargeHnOpenMirror (α : OpenFormula) :
    ⊢⁺[fc] eraseOpen ((OpenFormula.someFuture α).imp
      (OpenFormula.opast (OpenFormula.someFuture (OpenFormula.dopast α)))) :=
  PlusDerivationTree.ofTMSubst (fun _ => eraseOpen α)
    (Theorems.TemporalDerived.someFutureMono
      (Theorems.Propositional.impNegImp (Formula.atom hnProxyAtom) Formula.bot))

end Discharge

/--
**The axiom-discharge table.** One arm per `OpenAxiom` constructor, no wildcard. The frame-class
gate is passed through unchanged: every re-declared TM⁺ schema's `OpenAxiom.minFrameClass` arm is
its `PlusAxiom.minFrameClass` arm by construction, so `h_fc` is already evidence at the right
class.
-/
def dischargeAxiom {fc : FrameClass} : {φ : OpenFormula} → (h : OpenAxiom φ) →
    h.minFrameClass ≤ fc → ⊢⁺[fc] eraseOpen φ
  -- The restricted-modal block (18)
  | _, .ofut_k φ ψ, _ => dischargeOfutK φ ψ
  | _, .ofut_t φ, _ => dischargeOfutT φ
  | _, .ofut_four φ, _ => dischargeOfutFour φ
  | _, .ofut_five φ, _ => dischargeOfutFive φ
  | _, .opast_k φ ψ, _ => dischargeOpastK φ ψ
  | _, .opast_t φ, _ => dischargeOpastT φ
  | _, .opast_four φ, _ => dischargeOpastFour φ
  | _, .opast_five φ, _ => dischargeOpastFive φ
  | _, .stab_of_box φ, _ => dischargeStabOfBox φ
  | _, .ofut_of_stab φ, _ => dischargeOfutOfStab φ
  | _, .opast_of_stab φ, _ => dischargeOpastOfStab φ
  | _, .hn_open α, _ => dischargeHnOpen α
  | _, .hn_open_mirror α, _ => dischargeHnOpenMirror α
  | _, .rigidity_opast_fwd φ _, _ => dischargeRigidityFwd φ
  | _, .rigidity_opast_bwd φ _, _ => dischargeRigidityBwd φ
  | _, .rigidity_ofut_fwd φ _, _ => dischargeRigidityFwd φ
  | _, .rigidity_ofut_bwd φ _, _ => dischargeRigidityBwd φ
  | _, .definability_fwd φ, _ => dischargeDefinabilityFwd φ
  -- The re-declared TM⁺ schemata (53), each discharged by its own `PlusAxiom` namesake
  | _, .prop_k φ ψ χ, h_fc =>
      .axiom [] _ (PlusAxiom.prop_k (eraseOpen φ) (eraseOpen ψ) (eraseOpen χ)) h_fc
  | _, .prop_s φ ψ, h_fc => .axiom [] _ (PlusAxiom.prop_s (eraseOpen φ) (eraseOpen ψ)) h_fc
  | _, .ex_falso φ, h_fc => .axiom [] _ (PlusAxiom.ex_falso (eraseOpen φ)) h_fc
  | _, .peirce φ ψ, h_fc => .axiom [] _ (PlusAxiom.peirce (eraseOpen φ) (eraseOpen ψ)) h_fc
  | _, .modal_t φ, h_fc => .axiom [] _ (PlusAxiom.modal_t (eraseOpen φ)) h_fc
  | _, .modal_4 φ, h_fc => .axiom [] _ (PlusAxiom.modal_4 (eraseOpen φ)) h_fc
  | _, .modal_b φ, h_fc => .axiom [] _ (PlusAxiom.modal_b (eraseOpen φ)) h_fc
  | _, .modal_5_collapse φ, h_fc => .axiom [] _ (PlusAxiom.modal_5_collapse (eraseOpen φ)) h_fc
  | _, .modal_k_dist φ ψ, h_fc =>
      .axiom [] _ (PlusAxiom.modal_k_dist (eraseOpen φ) (eraseOpen ψ)) h_fc
  | _, .serial_future, h_fc => .axiom [] _ (PlusAxiom.serial_future) h_fc
  | _, .serial_past, h_fc => .axiom [] _ (PlusAxiom.serial_past) h_fc
  | _, .left_mono_until_G φ χ ψ, h_fc =>
      .axiom [] _ (PlusAxiom.left_mono_until_G (eraseOpen φ) (eraseOpen χ) (eraseOpen ψ)) h_fc
  | _, .left_mono_since_H φ χ ψ, h_fc =>
      .axiom [] _ (PlusAxiom.left_mono_since_H (eraseOpen φ) (eraseOpen χ) (eraseOpen ψ)) h_fc
  | _, .right_mono_until φ ψ χ, h_fc =>
      .axiom [] _ (PlusAxiom.right_mono_until (eraseOpen φ) (eraseOpen ψ) (eraseOpen χ)) h_fc
  | _, .right_mono_since φ ψ χ, h_fc =>
      .axiom [] _ (PlusAxiom.right_mono_since (eraseOpen φ) (eraseOpen ψ) (eraseOpen χ)) h_fc
  | _, .connect_future φ, h_fc => .axiom [] _ (PlusAxiom.connect_future (eraseOpen φ)) h_fc
  | _, .connect_past φ, h_fc => .axiom [] _ (PlusAxiom.connect_past (eraseOpen φ)) h_fc
  | _, .enrichment_until φ ψ p, h_fc =>
      .axiom [] _ (PlusAxiom.enrichment_until (eraseOpen φ) (eraseOpen ψ) (eraseOpen p)) h_fc
  | _, .enrichment_since φ ψ p, h_fc =>
      .axiom [] _ (PlusAxiom.enrichment_since (eraseOpen φ) (eraseOpen ψ) (eraseOpen p)) h_fc
  | _, .self_accum_until φ ψ, h_fc =>
      .axiom [] _ (PlusAxiom.self_accum_until (eraseOpen φ) (eraseOpen ψ)) h_fc
  | _, .self_accum_since φ ψ, h_fc =>
      .axiom [] _ (PlusAxiom.self_accum_since (eraseOpen φ) (eraseOpen ψ)) h_fc
  | _, .absorb_until φ ψ, h_fc =>
      .axiom [] _ (PlusAxiom.absorb_until (eraseOpen φ) (eraseOpen ψ)) h_fc
  | _, .absorb_since φ ψ, h_fc =>
      .axiom [] _ (PlusAxiom.absorb_since (eraseOpen φ) (eraseOpen ψ)) h_fc
  | _, .linear_until φ ψ χ θ, h_fc =>
      .axiom [] _ (PlusAxiom.linear_until (eraseOpen φ) (eraseOpen ψ) (eraseOpen χ) (eraseOpen θ)
        ) h_fc
  | _, .linear_since φ ψ χ θ, h_fc =>
      .axiom [] _ (PlusAxiom.linear_since (eraseOpen φ) (eraseOpen ψ) (eraseOpen χ) (eraseOpen θ)
        ) h_fc
  | _, .until_F φ ψ, h_fc => .axiom [] _ (PlusAxiom.until_F (eraseOpen φ) (eraseOpen ψ)) h_fc
  | _, .since_P φ ψ, h_fc => .axiom [] _ (PlusAxiom.since_P (eraseOpen φ) (eraseOpen ψ)) h_fc
  | _, .temp_linearity φ ψ, h_fc =>
      .axiom [] _ (PlusAxiom.temp_linearity (eraseOpen φ) (eraseOpen ψ)) h_fc
  | _, .temp_linearity_past φ ψ, h_fc =>
      .axiom [] _ (PlusAxiom.temp_linearity_past (eraseOpen φ) (eraseOpen ψ)) h_fc
  | _, .F_until_equiv φ, h_fc => .axiom [] _ (PlusAxiom.F_until_equiv (eraseOpen φ)) h_fc
  | _, .P_since_equiv φ, h_fc => .axiom [] _ (PlusAxiom.P_since_equiv (eraseOpen φ)) h_fc
  | _, .modal_future φ, h_fc => .axiom [] _ (PlusAxiom.modal_future (eraseOpen φ)) h_fc
  | _, .discrete_symm_fwd, h_fc => .axiom [] _ (PlusAxiom.discrete_symm_fwd) h_fc
  | _, .discrete_symm_bwd, h_fc => .axiom [] _ (PlusAxiom.discrete_symm_bwd) h_fc
  | _, .discrete_propagate_fwd, h_fc => .axiom [] _ (PlusAxiom.discrete_propagate_fwd) h_fc
  | _, .discrete_propagate_bwd, h_fc => .axiom [] _ (PlusAxiom.discrete_propagate_bwd) h_fc
  | _, .discrete_box_necessity, h_fc => .axiom [] _ (PlusAxiom.discrete_box_necessity) h_fc
  | _, .prior_UZ φ, h_fc => .axiom [] _ (PlusAxiom.prior_UZ (eraseOpen φ)) h_fc
  | _, .prior_SZ φ, h_fc => .axiom [] _ (PlusAxiom.prior_SZ (eraseOpen φ)) h_fc
  | _, .z1 φ, h_fc => .axiom [] _ (PlusAxiom.z1 (eraseOpen φ)) h_fc
  | _, .density φ, h_fc => .axiom [] _ (PlusAxiom.density (eraseOpen φ)) h_fc
  | _, .dense_indicator, h_fc => .axiom [] _ (PlusAxiom.dense_indicator) h_fc
  | _, .prior_U_gap φ, h_fc => .axiom [] _ (PlusAxiom.prior_U_gap (eraseOpen φ)) h_fc
  | _, .prior_S_gap φ, h_fc => .axiom [] _ (PlusAxiom.prior_S_gap (eraseOpen φ)) h_fc
  | _, .sep φ, h_fc => .axiom [] _ (PlusAxiom.sep (eraseOpen φ)) h_fc
  | _, .stab_k φ ψ, h_fc => .axiom [] _ (PlusAxiom.stab_k (eraseOpen φ) (eraseOpen ψ)) h_fc
  | _, .stab_t φ, h_fc => .axiom [] _ (PlusAxiom.stab_t (eraseOpen φ)) h_fc
  | _, .stab_4 φ, h_fc => .axiom [] _ (PlusAxiom.stab_4 (eraseOpen φ)) h_fc
  | _, .stab_5 φ, h_fc => .axiom [] _ (PlusAxiom.stab_5 (eraseOpen φ)) h_fc
  | _, .box_stab φ, h_fc => .axiom [] _ (PlusAxiom.box_stab (eraseOpen φ)) h_fc
  | _, .atom_stab p, h_fc => .axiom [] _ (PlusAxiom.atom_stab p) h_fc
  | _, .paste φ ψ hφ hψ, h_fc =>
      .axiom [] _ (PlusAxiom.paste (eraseOpen φ) (eraseOpen ψ) (isPureFuture_eraseOpen hφ)
        (isPurePast_eraseOpen hψ)) h_fc
  | _, .untl_paste α φ hα hφ, h_fc =>
      .axiom [] _ (PlusAxiom.untl_paste (eraseOpen α) (eraseOpen φ) (isPurePast_eraseOpen hα)
        (isPureFuture_eraseOpen hφ)) h_fc

/-! ## Forward conservativity over TM⁺

An L^▷ derivation erases rulewise to a TM⁺ derivation: seven cases, one per rule, with `axiom`
routed through `dischargeAxiom` and `time_reflection` through `eraseOpen_reflectTime`.

**This route is forced, not chosen.** There is no truth-preserving translation of L^▷ into L⁺ at
the base class — `▷` is not L⁺-definable there — and there is no weak-completeness engine for TM⁺
to run a semantic argument through: TM⁺ is incomplete at the base class
(`Metalogic/Independence/`). So the result is deliberately **not** modelled on
`Metalogic.Conservativity.starConservative_of_plusComplete`, whose completeness hypothesis is
false at that class. The syntactic route needs no engine and no hypothesis at all.
-/

/--
**The erasure of a derivation.** Seven cases, one per `OpenDerivationTree` rule. The `axiom` case
consumes `dischargeAxiom` at the empty context and weakens into `Γ.map eraseOpen`; the
`time_reflection` case transports along `eraseOpen_reflectTime`; the rest are structural, because
`eraseOpen` commutes with `box` and with `allFuture` by `rfl`.
-/
def OpenDerivationTree.erase {fc : FrameClass} : {Γ : OpenContext} → {φ : OpenFormula} →
    OpenDerivationTree fc Γ φ → PlusDerivationTree fc (Γ.map eraseOpen) (eraseOpen φ)
  | _, _, .axiom Γ _ h h_fc =>
      .weakening [] (Γ.map eraseOpen) _ (dischargeAxiom h h_fc) (List.nil_subset _)
  | _, _, .assumption _ _ h => .assumption _ _ (List.mem_map_of_mem h)
  | _, _, .modus_ponens _ φ ψ d1 d2 =>
      .modus_ponens _ (eraseOpen φ) (eraseOpen ψ) (erase d1) (erase d2)
  | _, _, .necessitation φ d => .necessitation (eraseOpen φ) (erase d)
  | _, _, .temporal_necessitation φ d => .temporal_necessitation (eraseOpen φ) (erase d)
  | _, _, .time_reflection φ d =>
      have h : eraseOpen φ.reflectTime = (eraseOpen φ).reflectTime := eraseOpen_reflectTime φ
      h ▸ PlusDerivationTree.time_reflection (eraseOpen φ) (erase d)
  | _, _, .weakening _ _ _ d h =>
      .weakening _ _ _ (erase d)
        (by
          intro x hx
          obtain ⟨y, hy, rfl⟩ := List.mem_map.mp hx
          exact List.mem_map_of_mem (h hy))

/-- **Forward conservativity over TM⁺, `Prop`-level**: `L^▷ ⊢[fc] φ ⟹ TM⁺ ⊢[fc] eraseOpen φ`, at
every frame class and context, unconditionally. No completeness hypothesis and no engine.

Paper: — (formalization-native; the manuscript supplies no proof system over the restricted
modals, so neither conservativity direction has a manuscript statement)
-/
theorem plusDerivable_of_openDerivable {fc : FrameClass} {Γ : OpenContext} {φ : OpenFormula}
    (h : OpenDerivable fc Γ φ) : PlusDerivable fc (Γ.map eraseOpen) (eraseOpen φ) :=
  h.elim fun d => ⟨d.erase⟩

/-- **The TM⁺ row, both directions.** On the image of the embedding the two systems prove exactly
the same formulas: backward by `openDerivable_of_plusDerivable`, forward by
`plusDerivable_of_openDerivable` composed with the retraction `eraseOpen_ofPlus`. Unconditional
and syntactic — the statement takes no engine argument.

Paper: — (formalization-native; the manuscript supplies no proof system over the restricted
modals, so neither conservativity direction has a manuscript statement)
-/
theorem plusDerivable_openDerivable_iff {fc : FrameClass} (φ : PlusFormula) :
    OpenDerivable fc [] (ofPlus φ) ↔ PlusDerivable fc [] φ := by
  constructor
  · intro h
    have h' := plusDerivable_of_openDerivable h
    rwa [List.map_nil, eraseOpen_ofPlus] at h'
  · intro h
    have h' := openDerivable_of_plusDerivable h
    rwa [List.map_nil] at h'

end FormalSystem.OpenLanguage
