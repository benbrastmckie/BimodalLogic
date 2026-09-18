/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.Formula
import FormalSystem.ProofSystem.Derivation
import FormalSystem.Automation.LemmaDB

/-!
# Derived Axioms: Time-Reflection Mirrors

The paper's axiom system (`def:BX`, `def:BX-z`, `def:BX-r`; see
`docs/reference/paper-definitions-of-record.md`) states only the future-directed temporal
schemata and obtains every past-directed mirror through the time-reflection rule TR
(`DerivationTree.time_reflection`, `Formula.reflectTime`). This module proves each such
mirror as a derived theorem of the primitive system, so none of them needs to be an `Axiom`
constructor.

Every definition here is obtained by one application of `time_reflection` to the
primitive's axiom instance at time-reflected arguments, followed by a formula identity
proved with `Formula.reflect_time_involution`. Each mirror has the same minimal frame class
as its primary: the Base mirrors are `fc`-polymorphic, `priorSZ` is gated by
`FrameClass.ZTime ≤ fc` and `priorSGap` by `FrameClass.RTime ≤ fc`.

## Main Definitions

Each entry reads *Derived* — *Primary (TR)*:

* `serialFutureImp` — `serial_future` (TS), by `prop_s` (not a mirror: the pre-paper form `⊤ → F⊤`)
* `serialPast` — `serial_future` (TS), then `prop_s`
* `leftMonoSinceH` — `left_mono_until_G` (UG)
* `rightMonoSince` — `right_mono_until` (UC)
* `connectPast` — `connect_future` (TC)
* `enrichmentSince` — `enrichment_until` (SU)
* `selfAccumSince` — `self_accum_until` (UF)
* `absorbSince` — `absorb_until` (UI)
* `sinceP` — `until_F` (UE)
* `pSinceEquiv` — `F_until_equiv` (UT)
* `discreteSymmBwd` — `discrete_symm_fwd` (NP)
* `priorSZ` — `prior_UZ` (UZ)
* `priorSGap` — `prior_U_gap` (PU)

For every `X` there is also a context-lifted form `XAt Γ … : Γ ⊢[fc] …`, obtained by
weakening from the empty context.

The two linearity mirrors `tempLinearityPast` and `linearSince` keep the historical disjunct
order, which differs from the TR image of the paper's TL and CN by a propositional permutation;
they are therefore derived in `Theorems/Combinators.lean`, next to the propositional combinators
they need, together with the legacy future forms `tempLinearityLegacy` and
`linearUntilLegacy`.
-/

namespace FormalSystem.ProofSystem.DerivedAxioms

open FormalSystem.Syntax

/-- Apply time reflection to a theorem and transport along a formula identity. -/
def ofReflect {fc : FrameClass} {φ ψ : Formula} (d : ⊢[fc] φ)
    (h : φ.reflectTime = ψ) : ⊢[fc] ψ :=
  h ▸ DerivationTree.time_reflection φ d

/-- Lift an empty-context derivation to an arbitrary context. -/
def lift {fc : FrameClass} (Γ : Context) {φ : Formula} (d : ⊢[fc] φ) : Γ ⊢[fc] φ :=
  DerivationTree.weakening [] Γ φ d (List.nil_subset Γ)

/-- A primitive axiom instance at the base frame class, usable in every `fc`. -/
private def baseAx {fc : FrameClass} {φ : Formula} (a : Axiom φ)
    (h : a.minFrameClass = FrameClass.Base) : ⊢[fc] φ :=
  DerivationTree.axiom [] φ a (h ▸ FrameClass.base_le fc)

/-! ## Base mirrors -/

/-- `⊤ → F⊤`: the former statement of TS, from the paper's `F⊤` by `prop_s` and MP. -/
@[tmLemma] def serialFutureImp {fc : FrameClass} :
    ⊢[fc] (Formula.bot.imp Formula.bot).imp
      (Formula.someFuture (Formula.bot.imp Formula.bot)) :=
  DerivationTree.modus_ponens [] _ _
    (baseAx (Axiom.prop_s (Formula.someFuture (Formula.bot.imp Formula.bot))
      (Formula.bot.imp Formula.bot)) rfl)
    (baseAx Axiom.serial_future rfl)

/-- `⊤ → P⊤`: TR of TS (`serial_future`), then `prop_s` and MP. -/
@[tmLemma] def serialPast {fc : FrameClass} :
    ⊢[fc] (Formula.bot.imp Formula.bot).imp (Formula.somePast (Formula.bot.imp Formula.bot)) :=
  DerivationTree.modus_ponens [] _ _
    (baseAx (Axiom.prop_s (Formula.somePast (Formula.bot.imp Formula.bot))
      (Formula.bot.imp Formula.bot)) rfl)
    (ofReflect (baseAx Axiom.serial_future rfl)
      (by simp [Formula.reflectTime, Formula.someFuture, Formula.somePast, Formula.top]))

/-- `H(φ→χ) → ((φ S ψ) → (χ S ψ))`: TR of UG (`left_mono_until_G`). -/
@[tmLemma] def leftMonoSinceH {fc : FrameClass} (φ χ ψ : Formula) :
    ⊢[fc] (φ.imp χ).allPast.imp ((Formula.snce φ ψ).imp (Formula.snce χ ψ)) :=
  ofReflect (baseAx (Axiom.left_mono_until_G φ.reflectTime χ.reflectTime ψ.reflectTime) rfl)
    (by simp [Formula.reflectTime, Formula.allFuture, Formula.allPast, Formula.someFuture,
      Formula.somePast, Formula.neg, Formula.top, Formula.reflect_time_involution])

/-- `H(φ → ψ) → ((χ S φ) → (χ S ψ))`: TR of UC (`right_mono_until`). -/
@[tmLemma] def rightMonoSince {fc : FrameClass} (φ ψ χ : Formula) :
    ⊢[fc] (φ.imp ψ).allPast.imp ((Formula.snce χ φ).imp (Formula.snce χ ψ)) :=
  ofReflect (baseAx (Axiom.right_mono_until φ.reflectTime ψ.reflectTime χ.reflectTime) rfl)
    (by simp [Formula.reflectTime, Formula.allFuture, Formula.allPast, Formula.someFuture,
      Formula.somePast, Formula.neg, Formula.top, Formula.reflect_time_involution])

/-- `φ → H(Fφ)`: TR of TC (`connect_future`). -/
@[tmLemma] def connectPast {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.imp (φ.someFuture.allPast) :=
  ofReflect (baseAx (Axiom.connect_future φ.reflectTime) rfl)
    (by simp [Formula.reflectTime, Formula.allFuture, Formula.allPast, Formula.someFuture,
      Formula.somePast, Formula.neg, Formula.top, Formula.reflect_time_involution])

/-- `p ∧ (φ S ψ) → φ S (ψ ∧ (φ U p))`: TR of SU (`enrichment_until`). -/
@[tmLemma] def enrichmentSince {fc : FrameClass} (φ ψ p : Formula) :
    ⊢[fc] (Formula.and p (Formula.snce φ ψ) |>.imp
      (Formula.snce φ (Formula.and ψ (Formula.untl φ p)))) :=
  ofReflect (baseAx (Axiom.enrichment_until φ.reflectTime ψ.reflectTime p.reflectTime) rfl)
    (by simp [Formula.reflectTime, Formula.and, Formula.neg, Formula.reflect_time_involution])

/-- Self-accumulation of Since: TR of UF (`self_accum_until`). -/
@[tmLemma] def selfAccumSince {fc : FrameClass} (φ ψ : Formula) :
    ⊢[fc] (Formula.snce φ ψ).imp (Formula.snce (Formula.and φ (Formula.snce φ ψ)) ψ) :=
  ofReflect (baseAx (Axiom.self_accum_until φ.reflectTime ψ.reflectTime) rfl)
    (by simp [Formula.reflectTime, Formula.and, Formula.neg, Formula.reflect_time_involution])

/-- Absorption of Since: TR of UI (`absorb_until`). -/
@[tmLemma] def absorbSince {fc : FrameClass} (φ ψ : Formula) :
    ⊢[fc] (Formula.snce φ (Formula.and φ (Formula.snce φ ψ))).imp (Formula.snce φ ψ) :=
  ofReflect (baseAx (Axiom.absorb_until φ.reflectTime ψ.reflectTime) rfl)
    (by simp [Formula.reflectTime, Formula.and, Formula.neg, Formula.reflect_time_involution])

/-- `(φ S ψ) → Pψ`: TR of UE (`until_F`). -/
@[tmLemma] def sinceP {fc : FrameClass} (φ ψ : Formula) :
    ⊢[fc] (Formula.snce φ ψ).imp (Formula.somePast ψ) :=
  ofReflect (baseAx (Axiom.until_F φ.reflectTime ψ.reflectTime) rfl)
    (by simp [Formula.reflectTime, Formula.someFuture, Formula.somePast, Formula.top,
      Formula.reflect_time_involution])

/-- `Pφ → S(⊤, φ)`: TR of UT (`F_until_equiv`). -/
@[tmLemma] def pSinceEquiv {fc : FrameClass} (φ : Formula) :
    ⊢[fc] (Formula.somePast φ).imp (Formula.snce (Formula.bot.imp Formula.bot) φ) :=
  ofReflect (baseAx (Axiom.F_until_equiv φ.reflectTime) rfl)
    (by simp [Formula.reflectTime, Formula.someFuture, Formula.somePast, Formula.top,
      Formula.reflect_time_involution])

/-- `S(⊥,⊤) → U(⊥,⊤)`: TR of NP (`discrete_symm_fwd`); the reflected formula is the
statement on the nose, so no transport is needed. -/
@[tmLemma] def discreteSymmBwd {fc : FrameClass} :
    ⊢[fc] (Formula.snce Formula.bot (Formula.bot.imp Formula.bot)).imp
      (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)) :=
  DerivationTree.time_reflection _ (baseAx Axiom.discrete_symm_fwd rfl)

/-! ## Frame-class-gated mirrors -/

/-- `Pφ → S(¬φ, φ)`: TR of UZ (`prior_UZ`), available wherever UZ is (`ZTime ≤ fc`). -/
def priorSZ {fc : FrameClass} (h : FrameClass.ZTime ≤ fc) (φ : Formula) :
    ⊢[fc] φ.somePast.imp (Formula.snce φ.neg φ) :=
  ofReflect (DerivationTree.axiom [] _ (Axiom.prior_UZ φ.reflectTime) h)
    (by simp [Formula.reflectTime, Formula.someFuture, Formula.somePast, Formula.top,
      Formula.neg, Formula.reflect_time_involution])

/-- Prior-S (gap form): TR of PU (`prior_U_gap`), available wherever PU is
(`RTime ≤ fc`). `kPlus` reflects to `kMinus`. -/
def priorSGap {fc : FrameClass} (h : FrameClass.RTime ≤ fc) (φ : Formula) :
    ⊢[fc] (Formula.and (Formula.snce φ Formula.top) φ.neg.somePast).imp
      (Formula.snce φ (Formula.or φ.neg (Formula.kMinus φ.neg))) :=
  ofReflect (DerivationTree.axiom [] _ (Axiom.prior_U_gap φ.reflectTime) h)
    (by simp [Formula.reflectTime, Formula.someFuture, Formula.somePast, Formula.top,
      Formula.and, Formula.or, Formula.neg, Formula.kPlus, Formula.kMinus,
      Formula.reflect_time_involution])

/-! ## Context-lifted forms -/

/-- Context-lifted `serialFutureImp`. -/
def serialFutureImpAt {fc : FrameClass} (Γ : Context) :
    Γ ⊢[fc] (Formula.bot.imp Formula.bot).imp
      (Formula.someFuture (Formula.bot.imp Formula.bot)) :=
  lift Γ serialFutureImp

/-- Context-lifted `serialPast`. -/
def serialPastAt {fc : FrameClass} (Γ : Context) :
    Γ ⊢[fc] (Formula.bot.imp Formula.bot).imp (Formula.somePast (Formula.bot.imp Formula.bot)) :=
  lift Γ serialPast

/-- Context-lifted `leftMonoSinceH`. -/
def leftMonoSinceHAt {fc : FrameClass} (Γ : Context) (φ χ ψ : Formula) :
    Γ ⊢[fc] (φ.imp χ).allPast.imp ((Formula.snce φ ψ).imp (Formula.snce χ ψ)) :=
  lift Γ (leftMonoSinceH φ χ ψ)

/-- Context-lifted `rightMonoSince`. -/
def rightMonoSinceAt {fc : FrameClass} (Γ : Context) (φ ψ χ : Formula) :
    Γ ⊢[fc] (φ.imp ψ).allPast.imp ((Formula.snce χ φ).imp (Formula.snce χ ψ)) :=
  lift Γ (rightMonoSince φ ψ χ)

/-- Context-lifted `connectPast`. -/
def connectPastAt {fc : FrameClass} (Γ : Context) (φ : Formula) :
    Γ ⊢[fc] φ.imp (φ.someFuture.allPast) :=
  lift Γ (connectPast φ)

/-- Context-lifted `enrichmentSince`. -/
def enrichmentSinceAt {fc : FrameClass} (Γ : Context) (φ ψ p : Formula) :
    Γ ⊢[fc] (Formula.and p (Formula.snce φ ψ) |>.imp
      (Formula.snce φ (Formula.and ψ (Formula.untl φ p)))) :=
  lift Γ (enrichmentSince φ ψ p)

/-- Context-lifted `selfAccumSince`. -/
def selfAccumSinceAt {fc : FrameClass} (Γ : Context) (φ ψ : Formula) :
    Γ ⊢[fc] (Formula.snce φ ψ).imp (Formula.snce (Formula.and φ (Formula.snce φ ψ)) ψ) :=
  lift Γ (selfAccumSince φ ψ)

/-- Context-lifted `absorbSince`. -/
def absorbSinceAt {fc : FrameClass} (Γ : Context) (φ ψ : Formula) :
    Γ ⊢[fc] (Formula.snce φ (Formula.and φ (Formula.snce φ ψ))).imp (Formula.snce φ ψ) :=
  lift Γ (absorbSince φ ψ)

/-- Context-lifted `sinceP`. -/
def sincePAt {fc : FrameClass} (Γ : Context) (φ ψ : Formula) :
    Γ ⊢[fc] (Formula.snce φ ψ).imp (Formula.somePast ψ) :=
  lift Γ (sinceP φ ψ)

/-- Context-lifted `pSinceEquiv`. -/
def pSinceEquivAt {fc : FrameClass} (Γ : Context) (φ : Formula) :
    Γ ⊢[fc] (Formula.somePast φ).imp (Formula.snce (Formula.bot.imp Formula.bot) φ) :=
  lift Γ (pSinceEquiv φ)

/-- Context-lifted `discreteSymmBwd`. -/
def discreteSymmBwdAt {fc : FrameClass} (Γ : Context) :
    Γ ⊢[fc] (Formula.snce Formula.bot (Formula.bot.imp Formula.bot)).imp
      (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)) :=
  lift Γ discreteSymmBwd

/-- Context-lifted `priorSZ`. -/
def priorSZAt {fc : FrameClass} (Γ : Context) (h : FrameClass.ZTime ≤ fc) (φ : Formula) :
    Γ ⊢[fc] φ.somePast.imp (Formula.snce φ.neg φ) :=
  lift Γ (priorSZ h φ)

/-- Context-lifted `priorSGap`. -/
def priorSGapAt {fc : FrameClass} (Γ : Context) (h : FrameClass.RTime ≤ fc) (φ : Formula) :
    Γ ⊢[fc] (Formula.and (Formula.snce φ Formula.top) φ.neg.somePast).imp
      (Formula.snce φ (Formula.or φ.neg (Formula.kMinus φ.neg))) :=
  lift Γ (priorSGap h φ)

end FormalSystem.ProofSystem.DerivedAxioms
