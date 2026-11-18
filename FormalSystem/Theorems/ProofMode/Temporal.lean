/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Theorems.TemporalDerived
import FormalSystem.Theorems.DiscreteUnfolding

/-!
# Temporal rules for the derivation proof mode

These rules construct native TM derivations. They support composition of future and past
guarantees without introducing semantic histories or times. Contextual eventuality elimination
requires an explicitly `G`- or `H`-mapped context: an assumption at the current point cannot be
silently moved to the point at which an eventuality holds.

The future rules use the paper's UC/UG monotonicity, UI absorption, and derived temporal
distribution/transitivity. Past theorem schemata follow by the calculus's time reflection rule;
contextual past wrappers use those schemata and the existing reflected monotonicity rules.
Until and Since retain the source constructors' guard-first, event-second convention.
-/

namespace FormalSystem.Theorems.ProofMode

open FormalSystem.Syntax FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Theorems.Combinators FormalSystem.Theorems.TemporalDerived

variable {fc : FrameClass} {Γ : Context}

/-- Map a future eventuality through an implication that holds throughout the strict future. -/
def futureConsequence {φ ψ : Formula}
    (hMap : Γ ⊢[fc] (φ.imp ψ).allFuture) (hφ : Γ ⊢[fc] φ.someFuture) :
    Γ ⊢[fc] ψ.someFuture :=
  ctxMp (ctxMp (thmIn (fMono φ ψ)) hMap) hφ

/-- Map a past eventuality through an implication that holds throughout the strict past. -/
def pastConsequence {φ ψ : Formula}
    (hMap : Γ ⊢[fc] (φ.imp ψ).allPast) (hφ : Γ ⊢[fc] φ.somePast) :
    Γ ⊢[fc] ψ.somePast :=
  ctxMp (ctxMp (thmIn (pMono φ ψ)) hMap) hφ

/-- UI absorption collapses a nested strict-future eventuality, at every frame class. -/
def futureCollapse (φ : Formula) : ⊢[fc] φ.someFuture.someFuture.imp φ.someFuture :=
  impTrans
    (someFutureMono (mp topThm (pairing Formula.top φ.someFuture)))
    (DerivationTree.axiom [] _ (Axiom.absorb_until Formula.top φ) (FrameClass.base_le fc))

/-- The past mirror of strict-future eventuality collapse, obtained by time reflection. -/
def pastCollapse (φ : Formula) : ⊢[fc] φ.somePast.somePast.imp φ.somePast := by
  simpa only [Formula.reflectTime, Formula.reflect_time_some_future,
    Formula.reflect_time_involution] using
      DerivationTree.time_reflection _ (futureCollapse (fc := fc) φ.reflectTime)

/-- Persistent future information can be joined with an eventuality at its witness point. -/
def futureConjunction (φ ψ : Formula) :
    ⊢[fc] φ.allFuture.imp (ψ.someFuture.imp (φ.and ψ).someFuture) := by
  have hPair : ⊢[fc] φ.allFuture.imp (ψ.imp (φ.and ψ)).allFuture :=
    mp (DerivationTree.temporal_necessitation _ (pairing φ ψ))
      (gDistribution φ (ψ.imp (φ.and ψ)))
  exact impTrans hPair (fMono ψ (φ.and ψ))

/-- Time reflection gives the conjunction rule for past persistence and eventuality. -/
def pastConjunction (φ ψ : Formula) :
    ⊢[fc] φ.allPast.imp (ψ.somePast.imp (φ.and ψ).somePast) := by
  simpa only [Formula.reflectTime, Formula.reflect_time_all_future,
    Formula.reflect_time_some_future, Formula.reflect_time_involution, Formula.and,
    Formula.neg] using
      DerivationTree.time_reflection _
        (futureConjunction (fc := fc) φ.reflectTime ψ.reflectTime)

/-- Combine `G φ` and `F ψ` into `F (φ ∧ ψ)` without exposing an eventuality's time. -/
def futureAnd {φ ψ : Formula}
    (hφ : Γ ⊢[fc] φ.allFuture) (hψ : Γ ⊢[fc] ψ.someFuture) :
    Γ ⊢[fc] (φ.and ψ).someFuture :=
  ctxMp (ctxMp (thmIn (futureConjunction φ ψ)) hφ) hψ

/-- Combine `H φ` and `P ψ` into `P (φ ∧ ψ)` through the reflected conjunction rule. -/
def pastAnd {φ ψ : Formula}
    (hφ : Γ ⊢[fc] φ.allPast) (hψ : Γ ⊢[fc] ψ.somePast) :
    Γ ⊢[fc] (φ.and ψ).somePast :=
  ctxMp (ctxMp (thmIn (pastConjunction φ ψ)) hφ) hψ

/-- Future monotonicity and UI yield a compositional eventuality consequence rule. -/
def futureBindRule (φ ψ : Formula) :
    ⊢[fc] (φ.imp ψ.someFuture).allFuture.imp (φ.someFuture.imp ψ.someFuture) := by
  have hCollapse : ⊢[fc] (φ.someFuture.imp ψ.someFuture.someFuture).imp
      (φ.someFuture.imp ψ.someFuture) :=
    mp (futureCollapse ψ) bCombinator
  exact impTrans (fMono φ ψ.someFuture) hCollapse

/-- The past counterpart of the compositional eventuality consequence rule. -/
def pastBindRule (φ ψ : Formula) :
    ⊢[fc] (φ.imp ψ.somePast).allPast.imp (φ.somePast.imp ψ.somePast) := by
  simpa only [Formula.reflectTime, Formula.reflect_time_all_future,
    Formula.reflect_time_some_future, Formula.reflect_time_involution] using
      DerivationTree.time_reflection _ (futureBindRule (fc := fc) φ.reflectTime ψ.reflectTime)

/-- Apply an eventual-future guarantee at a future eventuality, then collapse the result. -/
def futureBind {φ ψ : Formula}
    (hMap : Γ ⊢[fc] (φ.imp ψ.someFuture).allFuture) (hφ : Γ ⊢[fc] φ.someFuture) :
    Γ ⊢[fc] ψ.someFuture :=
  ctxMp (ctxMp (thmIn (futureBindRule φ ψ)) hMap) hφ

/-- Apply an eventual-past guarantee at a past eventuality. -/
def pastBind {φ ψ : Formula}
    (hMap : Γ ⊢[fc] (φ.imp ψ.somePast).allPast) (hφ : Γ ⊢[fc] φ.somePast) :
    Γ ⊢[fc] ψ.somePast :=
  ctxMp (ctxMp (thmIn (pastBindRule φ ψ)) hMap) hφ

/-- Compose future progress guarantees, retaining the second guarantee through temporal 4. -/
def progressTrans {φ ψ χ : Formula}
    (hφψ : Γ ⊢[fc] (φ.imp ψ.someFuture).allFuture)
    (hψχ : Γ ⊢[fc] (ψ.imp χ.someFuture).allFuture) :
    Γ ⊢[fc] (φ.imp χ.someFuture).allFuture := by
  let bridge := ψ.someFuture.imp χ.someFuture
  let guarantee := ψ.imp χ.someFuture
  have hPersistent : Γ ⊢[fc] guarantee.allFuture.allFuture :=
    ctxMp (thmIn (gTransitivity guarantee)) hψχ
  have hBridge : Γ ⊢[fc] bridge.allFuture :=
    ctxMp
      (ctxMp (thmIn (gDistribution guarantee.allFuture bridge))
        (thmIn (DerivationTree.temporal_necessitation _ (futureBindRule ψ χ))))
      hPersistent
  exact ctxMp (ctxMp (thmIn (gImpTrans φ ψ.someFuture χ.someFuture)) hφψ) hBridge

/-- Compose past progress guarantees using the reflected persistence and consequence rules. -/
def pastProgressTrans {φ ψ χ : Formula}
    (hφψ : Γ ⊢[fc] (φ.imp ψ.somePast).allPast)
    (hψχ : Γ ⊢[fc] (ψ.imp χ.somePast).allPast) :
    Γ ⊢[fc] (φ.imp χ.somePast).allPast := by
  let bridge := ψ.somePast.imp χ.somePast
  let guarantee := ψ.imp χ.somePast
  have hPersistent : Γ ⊢[fc] guarantee.allPast.allPast :=
    ctxMp (thmIn (hTransitivity guarantee)) hψχ
  have hBridge : Γ ⊢[fc] bridge.allPast :=
    ctxMp
      (ctxMp (thmIn (hDistribution guarantee.allPast bridge))
        (thmIn (pastNecessitation _ (pastBindRule ψ χ))))
      hPersistent
  exact ctxMp (ctxMp (thmIn (hImpTrans φ ψ.somePast χ.somePast)) hφψ) hBridge

/-- Apply the paper's discrete backward-induction principle Z1 in the current context.

The premises are exactly `G (G φ → φ)` and `F (G φ)`. This is not an unrestricted
initialization/one-step invariant rule; the explicit frame inequality preserves its ZTime gate.
-/
def futureBackwardInduction {φ : Formula} (hFrame : FrameClass.ZTime ≤ fc)
    (hStep : Γ ⊢[fc] (φ.allFuture.imp φ).allFuture)
    (hEventually : Γ ⊢[fc] φ.allFuture.someFuture) : Γ ⊢[fc] φ.allFuture :=
  ctxMp
    (ctxMp (thmIn (DiscreteUnfolding.z1SchemaAt hFrame φ)) hStep)
    hEventually

/-- The past mirror of Z1, with the same explicit discrete-frame requirement. -/
def pastBackwardInduction {φ : Formula} (hFrame : FrameClass.ZTime ≤ fc)
    (hStep : Γ ⊢[fc] (φ.allPast.imp φ).allPast)
    (hEventually : Γ ⊢[fc] φ.allPast.somePast) : Γ ⊢[fc] φ.allPast := by
  have hRule : ⊢[fc] (φ.allPast.imp φ).allPast.imp
      (φ.allPast.somePast.imp φ.allPast) := by
    simpa only [Formula.reflectTime, Formula.reflect_time_all_future,
      Formula.reflect_time_some_future, Formula.reflect_time_involution] using
        DerivationTree.time_reflection _
          (DiscreteUnfolding.z1SchemaAt hFrame φ.reflectTime)
  exact ctxMp (ctxMp (thmIn hRule) hStep) hEventually

/-- Weaken an Until guard using a future-scoped implication. -/
def untilGuard {φ ψ χ : Formula}
    (hMap : Γ ⊢[fc] (φ.imp χ).allFuture) (hUntil : Γ ⊢[fc] Formula.untl φ ψ) :
    Γ ⊢[fc] Formula.untl χ ψ :=
  ctxMp (ctxMp (thmIn (untilMonoGuard φ χ ψ)) hMap) hUntil

/-- Map an Until event using a future-scoped implication. -/
def untilEvent {φ ψ χ : Formula}
    (hMap : Γ ⊢[fc] (φ.imp ψ).allFuture) (hUntil : Γ ⊢[fc] Formula.untl χ φ) :
    Γ ⊢[fc] Formula.untl χ ψ :=
  ctxMp (ctxMp (thmIn (untilMonoEvent φ ψ χ)) hMap) hUntil

/-- Weaken a Since guard using a past-scoped implication. -/
def sinceGuard {φ ψ χ : Formula}
    (hMap : Γ ⊢[fc] (φ.imp χ).allPast) (hSince : Γ ⊢[fc] Formula.snce φ ψ) :
    Γ ⊢[fc] Formula.snce χ ψ :=
  ctxMp (ctxMp (thmIn (sinceMonoGuard φ χ ψ)) hMap) hSince

/-- Map a Since event using a past-scoped implication. -/
def sinceEvent {φ ψ χ : Formula}
    (hMap : Γ ⊢[fc] (φ.imp ψ).allPast) (hSince : Γ ⊢[fc] Formula.snce χ φ) :
    Γ ⊢[fc] Formula.snce χ ψ :=
  ctxMp (ctxMp (thmIn (sinceMonoEvent φ ψ χ)) hMap) hSince

/-- Next-event monotonicity requires the implication in the future scope, not just now. -/
def nextConsequence {φ ψ : Formula}
    (hMap : Γ ⊢[fc] (φ.imp ψ).allFuture) (hNext : Γ ⊢[fc] φ.next) :
    Γ ⊢[fc] ψ.next :=
  untilEvent hMap hNext

/-- Previous-event monotonicity requires the implication in the past scope. -/
def prevConsequence {φ ψ : Formula}
    (hMap : Γ ⊢[fc] (φ.imp ψ).allPast) (hPrev : Γ ⊢[fc] φ.prev) :
    Γ ⊢[fc] ψ.prev :=
  sinceEvent hMap hPrev

end FormalSystem.Theorems.ProofMode
