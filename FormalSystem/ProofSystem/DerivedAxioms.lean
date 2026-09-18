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
as its primary: the Base mirrors are `fc`-polymorphic, `prior_SZ` is gated by
`FrameClass.ZTime ≤ fc` and `prior_S_gap` by `FrameClass.RTime ≤ fc`.

## Main Definitions

| Derived | Primary (TR) |
|---------|--------------|
| `serial_past` | `serial_future` (TS) |
| `left_mono_since_H` | `left_mono_until_G` (UG) |
| `right_mono_since` | `right_mono_until` (UC) |
| `connect_past` | `connect_future` (TC) |
| `enrichment_since` | `enrichment_until` (SU) |
| `self_accum_since` | `self_accum_until` (UF) |
| `absorb_since` | `absorb_until` (UI) |
| `since_P` | `until_F` (UE) |
| `P_since_equiv` | `F_until_equiv` (UT) |
| `discrete_symm_bwd` | `discrete_symm_fwd` (NP) |
| `prior_SZ` | `prior_UZ` (UZ) |
| `prior_S_gap` | `prior_U_gap` (PU) |

For every `X` there is also a context-lifted form `XAt Γ … : Γ ⊢[fc] …`, obtained by
weakening from the empty context.

The two linearity mirrors `temp_linearity_past` and `linear_since` keep the historical disjunct
order, which differs from the TR image of the paper's TL and CN by a propositional permutation;
they are therefore derived in `Theorems/Combinators.lean`, next to the propositional combinators
they need, together with the legacy future forms `temp_linearity_legacy` and
`linear_until_legacy`.
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

/-- `⊤ → P⊤`: TR of TS (`serial_future`). -/
@[tmLemma] def serial_past {fc : FrameClass} :
    ⊢[fc] (Formula.bot.imp Formula.bot).imp (Formula.somePast (Formula.bot.imp Formula.bot)) :=
  ofReflect (baseAx Axiom.serial_future rfl)
    (by simp [Formula.reflectTime, Formula.someFuture, Formula.somePast, Formula.top])

/-- `H(φ→χ) → ((φ S ψ) → (χ S ψ))`: TR of UG (`left_mono_until_G`). -/
@[tmLemma] def left_mono_since_H {fc : FrameClass} (φ χ ψ : Formula) :
    ⊢[fc] (φ.imp χ).allPast.imp ((Formula.snce φ ψ).imp (Formula.snce χ ψ)) :=
  ofReflect (baseAx (Axiom.left_mono_until_G φ.reflectTime χ.reflectTime ψ.reflectTime) rfl)
    (by simp [Formula.reflectTime, Formula.allFuture, Formula.allPast, Formula.someFuture,
      Formula.somePast, Formula.neg, Formula.top, Formula.reflect_time_involution])

/-- `H(φ → ψ) → ((χ S φ) → (χ S ψ))`: TR of UC (`right_mono_until`). -/
@[tmLemma] def right_mono_since {fc : FrameClass} (φ ψ χ : Formula) :
    ⊢[fc] (φ.imp ψ).allPast.imp ((Formula.snce χ φ).imp (Formula.snce χ ψ)) :=
  ofReflect (baseAx (Axiom.right_mono_until φ.reflectTime ψ.reflectTime χ.reflectTime) rfl)
    (by simp [Formula.reflectTime, Formula.allFuture, Formula.allPast, Formula.someFuture,
      Formula.somePast, Formula.neg, Formula.top, Formula.reflect_time_involution])

/-- `φ → H(Fφ)`: TR of TC (`connect_future`). -/
@[tmLemma] def connect_past {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.imp (φ.someFuture.allPast) :=
  ofReflect (baseAx (Axiom.connect_future φ.reflectTime) rfl)
    (by simp [Formula.reflectTime, Formula.allFuture, Formula.allPast, Formula.someFuture,
      Formula.somePast, Formula.neg, Formula.top, Formula.reflect_time_involution])

/-- `p ∧ (φ S ψ) → φ S (ψ ∧ (φ U p))`: TR of SU (`enrichment_until`). -/
@[tmLemma] def enrichment_since {fc : FrameClass} (φ ψ p : Formula) :
    ⊢[fc] (Formula.and p (Formula.snce φ ψ) |>.imp
      (Formula.snce φ (Formula.and ψ (Formula.untl φ p)))) :=
  ofReflect (baseAx (Axiom.enrichment_until φ.reflectTime ψ.reflectTime p.reflectTime) rfl)
    (by simp [Formula.reflectTime, Formula.and, Formula.neg, Formula.reflect_time_involution])

/-- Self-accumulation of Since: TR of UF (`self_accum_until`). -/
@[tmLemma] def self_accum_since {fc : FrameClass} (φ ψ : Formula) :
    ⊢[fc] (Formula.snce φ ψ).imp (Formula.snce (Formula.and φ (Formula.snce φ ψ)) ψ) :=
  ofReflect (baseAx (Axiom.self_accum_until φ.reflectTime ψ.reflectTime) rfl)
    (by simp [Formula.reflectTime, Formula.and, Formula.neg, Formula.reflect_time_involution])

/-- Absorption of Since: TR of UI (`absorb_until`). -/
@[tmLemma] def absorb_since {fc : FrameClass} (φ ψ : Formula) :
    ⊢[fc] (Formula.snce φ (Formula.and φ (Formula.snce φ ψ))).imp (Formula.snce φ ψ) :=
  ofReflect (baseAx (Axiom.absorb_until φ.reflectTime ψ.reflectTime) rfl)
    (by simp [Formula.reflectTime, Formula.and, Formula.neg, Formula.reflect_time_involution])

/-- `(φ S ψ) → Pψ`: TR of UE (`until_F`). -/
@[tmLemma] def since_P {fc : FrameClass} (φ ψ : Formula) :
    ⊢[fc] (Formula.snce φ ψ).imp (Formula.somePast ψ) :=
  ofReflect (baseAx (Axiom.until_F φ.reflectTime ψ.reflectTime) rfl)
    (by simp [Formula.reflectTime, Formula.someFuture, Formula.somePast, Formula.top,
      Formula.reflect_time_involution])

/-- `Pφ → S(⊤, φ)`: TR of UT (`F_until_equiv`). -/
@[tmLemma] def P_since_equiv {fc : FrameClass} (φ : Formula) :
    ⊢[fc] (Formula.somePast φ).imp (Formula.snce (Formula.bot.imp Formula.bot) φ) :=
  ofReflect (baseAx (Axiom.F_until_equiv φ.reflectTime) rfl)
    (by simp [Formula.reflectTime, Formula.someFuture, Formula.somePast, Formula.top,
      Formula.reflect_time_involution])

/-- `S(⊥,⊤) → U(⊥,⊤)`: TR of NP (`discrete_symm_fwd`); the reflected formula is the
statement on the nose, so no transport is needed. -/
@[tmLemma] def discrete_symm_bwd {fc : FrameClass} :
    ⊢[fc] (Formula.snce Formula.bot (Formula.bot.imp Formula.bot)).imp
      (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)) :=
  DerivationTree.time_reflection _ (baseAx Axiom.discrete_symm_fwd rfl)

/-! ## Frame-class-gated mirrors -/

/-- `Pφ → S(¬φ, φ)`: TR of UZ (`prior_UZ`), available wherever UZ is (`ZTime ≤ fc`). -/
def prior_SZ {fc : FrameClass} (h : FrameClass.ZTime ≤ fc) (φ : Formula) :
    ⊢[fc] φ.somePast.imp (Formula.snce φ.neg φ) :=
  ofReflect (DerivationTree.axiom [] _ (Axiom.prior_UZ φ.reflectTime) h)
    (by simp [Formula.reflectTime, Formula.someFuture, Formula.somePast, Formula.top,
      Formula.neg, Formula.reflect_time_involution])

/-- Prior-S (gap form): TR of PU (`prior_U_gap`), available wherever PU is
(`RTime ≤ fc`). `kPlus` reflects to `kMinus`. -/
def prior_S_gap {fc : FrameClass} (h : FrameClass.RTime ≤ fc) (φ : Formula) :
    ⊢[fc] (Formula.and (Formula.snce φ Formula.top) φ.neg.somePast).imp
      (Formula.snce φ (Formula.or φ.neg (Formula.kMinus φ.neg))) :=
  ofReflect (DerivationTree.axiom [] _ (Axiom.prior_U_gap φ.reflectTime) h)
    (by simp [Formula.reflectTime, Formula.someFuture, Formula.somePast, Formula.top,
      Formula.and, Formula.or, Formula.neg, Formula.kPlus, Formula.kMinus,
      Formula.reflect_time_involution])

/-! ## Context-lifted forms -/

/-- Context-lifted `serial_past`. -/
def serial_pastAt {fc : FrameClass} (Γ : Context) :
    Γ ⊢[fc] (Formula.bot.imp Formula.bot).imp (Formula.somePast (Formula.bot.imp Formula.bot)) :=
  lift Γ serial_past

/-- Context-lifted `left_mono_since_H`. -/
def left_mono_since_HAt {fc : FrameClass} (Γ : Context) (φ χ ψ : Formula) :
    Γ ⊢[fc] (φ.imp χ).allPast.imp ((Formula.snce φ ψ).imp (Formula.snce χ ψ)) :=
  lift Γ (left_mono_since_H φ χ ψ)

/-- Context-lifted `right_mono_since`. -/
def right_mono_sinceAt {fc : FrameClass} (Γ : Context) (φ ψ χ : Formula) :
    Γ ⊢[fc] (φ.imp ψ).allPast.imp ((Formula.snce χ φ).imp (Formula.snce χ ψ)) :=
  lift Γ (right_mono_since φ ψ χ)

/-- Context-lifted `connect_past`. -/
def connect_pastAt {fc : FrameClass} (Γ : Context) (φ : Formula) :
    Γ ⊢[fc] φ.imp (φ.someFuture.allPast) :=
  lift Γ (connect_past φ)

/-- Context-lifted `enrichment_since`. -/
def enrichment_sinceAt {fc : FrameClass} (Γ : Context) (φ ψ p : Formula) :
    Γ ⊢[fc] (Formula.and p (Formula.snce φ ψ) |>.imp
      (Formula.snce φ (Formula.and ψ (Formula.untl φ p)))) :=
  lift Γ (enrichment_since φ ψ p)

/-- Context-lifted `self_accum_since`. -/
def self_accum_sinceAt {fc : FrameClass} (Γ : Context) (φ ψ : Formula) :
    Γ ⊢[fc] (Formula.snce φ ψ).imp (Formula.snce (Formula.and φ (Formula.snce φ ψ)) ψ) :=
  lift Γ (self_accum_since φ ψ)

/-- Context-lifted `absorb_since`. -/
def absorb_sinceAt {fc : FrameClass} (Γ : Context) (φ ψ : Formula) :
    Γ ⊢[fc] (Formula.snce φ (Formula.and φ (Formula.snce φ ψ))).imp (Formula.snce φ ψ) :=
  lift Γ (absorb_since φ ψ)

/-- Context-lifted `since_P`. -/
def since_PAt {fc : FrameClass} (Γ : Context) (φ ψ : Formula) :
    Γ ⊢[fc] (Formula.snce φ ψ).imp (Formula.somePast ψ) :=
  lift Γ (since_P φ ψ)

/-- Context-lifted `P_since_equiv`. -/
def P_since_equivAt {fc : FrameClass} (Γ : Context) (φ : Formula) :
    Γ ⊢[fc] (Formula.somePast φ).imp (Formula.snce (Formula.bot.imp Formula.bot) φ) :=
  lift Γ (P_since_equiv φ)

/-- Context-lifted `discrete_symm_bwd`. -/
def discrete_symm_bwdAt {fc : FrameClass} (Γ : Context) :
    Γ ⊢[fc] (Formula.snce Formula.bot (Formula.bot.imp Formula.bot)).imp
      (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)) :=
  lift Γ discrete_symm_bwd

/-- Context-lifted `prior_SZ`. -/
def prior_SZAt {fc : FrameClass} (Γ : Context) (h : FrameClass.ZTime ≤ fc) (φ : Formula) :
    Γ ⊢[fc] φ.somePast.imp (Formula.snce φ.neg φ) :=
  lift Γ (prior_SZ h φ)

/-- Context-lifted `prior_S_gap`. -/
def prior_S_gapAt {fc : FrameClass} (Γ : Context) (h : FrameClass.RTime ≤ fc) (φ : Formula) :
    Γ ⊢[fc] (Formula.and (Formula.snce φ Formula.top) φ.neg.somePast).imp
      (Formula.snce φ (Formula.or φ.neg (Formula.kMinus φ.neg))) :=
  lift Γ (prior_S_gap h φ)

end FormalSystem.ProofSystem.DerivedAxioms
