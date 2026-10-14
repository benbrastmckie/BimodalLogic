/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.Formula
import FormalSystem.ProofSystem.Derivation

/-!
# Derived Axioms: Time-Reflection Mirrors and Raw-Constructor Schemata

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
* `enrichmentSince` — `enrichment_until` (US)
* `selfAccumSince` — `self_accum_until` (UF)
* `absorbSince` — `absorb_until` (UI)
* `sinceP` — `untilF` (UE, itself derived below)
* `pSinceEquiv` — `fUntilEquiv` (UT, itself derived below)
* `priorSZ` — `prior_UZ` (UZ)
* `priorSGap` — `prior_U_gap` (PU)

## Derived schemata from the raw constructors

Four schemata the paper lists under `def:BX` need nothing beyond the primitive constructors
(`prop_k`, `prop_s`, UG, UC, NB, MF, MT) and the rules TN and TR, so they are derived here
rather than kept as `Axiom` constructors:

* `untilF` — UE `U(ψ, φ) → Fψ`, from UG (`left_mono_until_G`) with the new guard `⊤`, plus TN
* `fUntilEquiv` — UT `Fφ → U(φ, ⊤)`, an identity: `Fφ` *is* `untl ⊤ φ` by definition
* `discretePropagateFwd` — NF `X⊤ → G X⊤`, as NB ; MF ; MT
* `discretePropagateFwdMirror` — TR of NF, `Y⊤ → H Y⊤`

The theorem-level monotonicity forms `guardMonoThm` (UG + TN) and `eventMonoThm` (UC + TN) and
the lemma `impTop` (`φ → ⊤`) are exported for the derived stock in `Theorems/`.

The mirrors of TC and NP, `connectPast` and `discreteSymmBwd` (with their `At` forms), live in
`Theorems/ConnectDerived.lean` next to their derived primaries `connectFuture` and
`discreteSymmFwd`.

For every `X` there is also a context-lifted form `XAt Γ … : Γ ⊢[fc] …`, obtained by
weakening from the empty context.

The linearity mirror `linearSince` keeps the historical association, which differs from the TR
image of the paper's CN by a propositional permutation; it is therefore derived in
`Theorems/Combinators.lean`, next to the propositional combinators it needs, together with the
legacy future form `linearUntilLegacy`. The analogous `tempLinearityPast` and
`tempLinearityLegacy` live in `Theorems/LinearityDerived.lean`, where TL itself is derived.
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

/-! ## Propositional helpers from `prop_k`/`prop_s`

This module imports only `Syntax.Formula` and `ProofSystem.Derivation`, so the handful of
combinators the derived schemata need are rebuilt here from the two propositional axioms
instead of imported from `Theorems/Combinators.lean` (which imports this module). -/

/-- Modus ponens at the empty context, premise first. -/
private def mpThm {fc : FrameClass} {A B : Formula} (h1 : ⊢[fc] A) (h2 : ⊢[fc] A.imp B) :
    ⊢[fc] B :=
  DerivationTree.modus_ponens [] A B h2 h1

/-- Transitivity of implication from `prop_s` and `prop_k`. -/
private def impTransThm {fc : FrameClass} {A B C : Formula}
    (h1 : ⊢[fc] A.imp B) (h2 : ⊢[fc] B.imp C) : ⊢[fc] A.imp C :=
  mpThm h1 (mpThm (mpThm h2 (baseAx (Axiom.prop_s (B.imp C) A) rfl))
    (baseAx (Axiom.prop_k A B C) rfl))

/-- `A → A` (SKK). -/
private def identityThm {fc : FrameClass} (A : Formula) : ⊢[fc] A.imp A :=
  mpThm (baseAx (Axiom.prop_s A A) rfl)
    (mpThm (baseAx (Axiom.prop_s A (A.imp A)) rfl) (baseAx (Axiom.prop_k A (A.imp A) A) rfl))

/-- `⊢ ⊤`, i.e. `⊥ → ⊥`. -/
private def topThm {fc : FrameClass} : ⊢[fc] Formula.top := identityThm Formula.bot

/-- `φ → ⊤`. -/
def impTop {fc : FrameClass} (φ : Formula) : ⊢[fc] φ.imp Formula.top :=
  mpThm topThm (baseAx (Axiom.prop_s Formula.top φ) rfl)

/-- Theorem-level guard monotonicity, UG (`left_mono_until_G`) + TN: from `⊢ g → g'` derive
`⊢ (g U e) → (g' U e)` (terms guard-first: `untl g e`). -/
def guardMonoThm {fc : FrameClass} (g g' e : Formula) (hg : ⊢[fc] g.imp g') :
    ⊢[fc] (Formula.untl g e).imp (Formula.untl g' e) :=
  mpThm (DerivationTree.temporal_necessitation _ hg) (baseAx (Axiom.left_mono_until_G g g' e) rfl)

/-- Theorem-level event monotonicity, UC (`right_mono_until`) + TN: from `⊢ e → e'` derive
`⊢ (g U e) → (g U e')`. -/
def eventMonoThm {fc : FrameClass} (e e' g : Formula) (he : ⊢[fc] e.imp e') :
    ⊢[fc] (Formula.untl g e).imp (Formula.untl g e') :=
  mpThm (DerivationTree.temporal_necessitation _ he) (baseAx (Axiom.right_mono_until e e' g) rfl)

/-! ## Derived schemata from the raw constructors -/

/-- UE: `U(ψ, φ) → F(ψ)` (guard-first: `untl φ ψ`). Widen the guard `φ` to `⊤` by UG + TN;
`F ψ` is `untl ⊤ ψ` by definition. Not a Burgess axiom. -/
@[tmLemma] def untilF {fc : FrameClass} (φ ψ : Formula) :
    ⊢[fc] (Formula.untl φ ψ).imp (Formula.someFuture ψ) :=
  guardMonoThm φ Formula.top ψ (impTop φ)

/-- UT: `F(φ) → U(φ, ⊤)` (guard-first: `untl ⊤ φ`). `F φ` unfolds to exactly `untl (⊥ → ⊥) φ`,
so this is the identity. -/
@[tmLemma] def fUntilEquiv {fc : FrameClass} (φ : Formula) :
    ⊢[fc] (Formula.someFuture φ).imp (Formula.untl (Formula.bot.imp Formula.bot) φ) :=
  identityThm _

/-- NF: `X⊤ → G X⊤` with `X⊤ = U(⊤, ⊥)` spelled `untl ⊥ (⊥ → ⊥)`. The gap witness propagates
forward as NB (`discrete_box_necessity`) ; MF (`modal_future`) ; MT (`modal_t`): `X⊤ → □X⊤ →
□G X⊤ → G X⊤`. -/
@[tmLemma] def discretePropagateFwd {fc : FrameClass} :
    ⊢[fc] (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).imp
      (Formula.allFuture (Formula.untl Formula.bot (Formula.bot.imp Formula.bot))) :=
  impTransThm (baseAx Axiom.discrete_box_necessity rfl)
    (impTransThm
      (baseAx (Axiom.modal_future (Formula.untl Formula.bot (Formula.bot.imp Formula.bot))) rfl)
      (baseAx (Axiom.modal_t
        (Formula.allFuture (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)))) rfl))

/-- TR of NF: `Y⊤ → H Y⊤` with `Y⊤ = S(⊤, ⊥)`. The reflected formula is the statement on
the nose. (This is *not* the paper's NA, `X⊤ → H X⊤`, which is
`Theorems.ConnectDerived.discretePropagateBwd`.) -/
@[tmLemma] def discretePropagateFwdMirror {fc : FrameClass} :
    ⊢[fc] (Formula.snce Formula.bot (Formula.bot.imp Formula.bot)).imp
      (Formula.allPast (Formula.snce Formula.bot (Formula.bot.imp Formula.bot))) :=
  ofReflect discretePropagateFwd rfl

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

/-- `p ∧ (φ S ψ) → φ S (ψ ∧ (φ U p))`: TR of US (`enrichment_until`). -/
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

/-- `(φ S ψ) → Pψ`: TR of UE (`untilF`). -/
@[tmLemma] def sinceP {fc : FrameClass} (φ ψ : Formula) :
    ⊢[fc] (Formula.snce φ ψ).imp (Formula.somePast ψ) :=
  ofReflect (untilF φ.reflectTime ψ.reflectTime)
    (by simp [Formula.reflectTime, Formula.someFuture, Formula.somePast, Formula.top,
      Formula.reflect_time_involution])

/-- `Pφ → S(⊤, φ)`: TR of UT (`fUntilEquiv`). -/
@[tmLemma] def pSinceEquiv {fc : FrameClass} (φ : Formula) :
    ⊢[fc] (Formula.somePast φ).imp (Formula.snce (Formula.bot.imp Formula.bot) φ) :=
  ofReflect (fUntilEquiv φ.reflectTime)
    (by simp [Formula.reflectTime, Formula.someFuture, Formula.somePast, Formula.top,
      Formula.reflect_time_involution])

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
