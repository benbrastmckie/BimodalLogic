/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Theorems.ProofMode.Temporal

/-!
# Discrete scope rules for the derivation proof mode

Next and Previous distribute over native derivations with every assumption shifted to the
same adjacent point. Their closed necessitation rules require `FrameClass.ZTime ≤ fc`:
the source calculus proves an adjacent point exists only under this frame hypothesis.
-/

namespace FormalSystem.Theorems.ProofMode

open FormalSystem.Syntax FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Theorems.Combinators FormalSystem.Theorems.TemporalDerived
open FormalSystem.Theorems.Propositional

variable {fc : FrameClass}

private def implicationPair (A B : Formula) :
    ⊢[fc] ((A.imp B).and A).imp B := by
  refine deductionTheorem [] ((A.imp B).and A) B ?_
  have h : [(A.imp B).and A] ⊢[fc] (A.imp B).and A :=
    .assumption _ _ (by simp)
  exact ctxMp (andFst h) (andSnd h)

/-- Next distributes over implication whenever its adjacent witnesses exist. -/
def nextK (A B : Formula) : ⊢[fc] (A.imp B).next.imp (A.next.imp B.next) := by
  refine deductionTheorem [] (A.imp B).next _ ?_
  refine deductionTheorem [(A.imp B).next] A.next B.next ?_
  have hImp : [A.next, (A.imp B).next] ⊢[fc] (A.imp B).next :=
    .assumption _ _ (by simp)
  have hA : [A.next, (A.imp B).next] ⊢[fc] A.next :=
    .assumption _ _ (by simp)
  have hPair := ctxMp (thmIn (DiscreteUnfolding.nextConj (A.imp B) A))
    (andIntro hImp hA)
  exact eventMono _ _ _ Formula.bot (implicationPair A B) hPair

/-- Previous distributes over implication by the native time-reflection rule. -/
def prevK (A B : Formula) : ⊢[fc] (A.imp B).prev.imp (A.prev.imp B.prev) := by
  simpa only [Formula.reflectTime, Formula.reflect_time_next,
    Formula.reflect_time_involution] using
      DerivationTree.time_reflection _ (nextK (fc := fc) A.reflectTime B.reflectTime)

/-- Necessitate a closed theorem at the next point, with checked existence of that point. -/
def nextNecessitation (hFrame : FrameClass.ZTime ≤ fc) (A : Formula) (h : ⊢[fc] A) :
    ⊢[fc] A.next := by
  have hTop : ⊢[fc] Formula.top.imp A :=
    deductionTheorem [] Formula.top A (.weakening [] _ _ h (List.nil_subset _))
  exact eventMono [] Formula.top A Formula.bot hTop
    (DiscreteUnfolding.succIndicatorAt hFrame)

/-- Necessitate a closed theorem at the previous point, with the same discrete-frame gate. -/
def prevNecessitation (hFrame : FrameClass.ZTime ≤ fc) (A : Formula) (h : ⊢[fc] A) :
    ⊢[fc] A.prev := by
  have hTop : ⊢[fc] Formula.top.imp A :=
    deductionTheorem [] Formula.top A (.weakening [] _ _ h (List.nil_subset _))
  exact snceEventMono [] Formula.top A Formula.bot hTop
    (DiscreteUnfolding.prevIndicatorAt hFrame)

/-- Move a derivation to the next point, shifting exactly its assumption context. -/
def generalizedNextK (hFrame : FrameClass.ZTime ≤ fc) :
    (Γ : Context) → (A : Formula) → (Γ ⊢[fc] A) →
      Context.map Formula.next Γ ⊢[fc] A.next
  | [], A, h => nextNecessitation hFrame A h
  | B :: Γ, A, h =>
      reverseDeduction
        (ctxMp (thmIn (nextK B A))
          (generalizedNextK hFrame Γ (B.imp A) (deductionTheorem Γ B A h)))

/-- Move a derivation to the previous point, shifting exactly its assumption context. -/
def generalizedPrevK (hFrame : FrameClass.ZTime ≤ fc) :
    (Γ : Context) → (A : Formula) → (Γ ⊢[fc] A) →
      Context.map Formula.prev Γ ⊢[fc] A.prev
  | [], A, h => prevNecessitation hFrame A h
  | B :: Γ, A, h =>
      reverseDeduction
        (ctxMp (thmIn (prevK B A))
          (generalizedPrevK hFrame Γ (B.imp A) (deductionTheorem Γ B A h)))

private def conjunctionClash (A : Formula) : ⊢[fc] (A.and A.neg).imp Formula.bot := by
  refine deductionTheorem [] (A.and A.neg) Formula.bot ?_
  have h : [A.and A.neg] ⊢[fc] A.and A.neg := .assumption _ _ (by simp)
  exact ctxMp (andSnd h) (andFst h)

private def nextClash (A : Formula) :
    ⊢[fc] (A.next.and A.neg.next).imp Formula.bot := by
  refine deductionTheorem [] (A.next.and A.neg.next) Formula.bot ?_
  have h : [A.next.and A.neg.next] ⊢[fc] A.next.and A.neg.next :=
    .assumption _ _ (by simp)
  have hPair := ctxMp (thmIn (DiscreteUnfolding.nextConj A A.neg)) h
  exact ctxMp (thmIn (untlBotFalse Formula.bot))
    (eventMono _ _ Formula.bot Formula.bot (conjunctionClash A) hPair)

/-- A next point of the immediate predecessor is the present point.

The proof uses Since enrichment and successor functionality. It assumes neither that an
adjacent point always exists nor any semantic time index, so it is frame-polymorphic.
-/
def prevNext (A : Formula) : ⊢[fc] A.next.prev.imp A := by
  refine deductionTheorem [] A.next.prev A ?_
  apply ctxMp (thmIn (doubleNegation A))
  refine deductionTheorem [A.next.prev] A.neg Formula.bot ?_
  have hPrev : [A.neg, A.next.prev] ⊢[fc] A.next.prev := .assumption _ _ (by simp)
  have hNeg : [A.neg, A.next.prev] ⊢[fc] A.neg := .assumption _ _ (by simp)
  have hEnriched := ctxMp (thmIn (DerivedAxioms.enrichmentSince Formula.bot A.next A.neg))
    (andIntro hNeg hPrev)
  exact ctxMp (thmIn (snceBotFalse Formula.bot))
    (snceEventMono _ _ Formula.bot Formula.bot (nextClash A) hEnriched)

private def invariantFailureEvent (A : Formula) :
    ⊢[FrameClass.ZTime]
      (A.neg.and (Formula.snce (A.and (A.imp A.next)) (A.and (A.imp A.next)))).imp
        Formula.bot := by
  let B := A.and (A.imp A.next)
  let S := Formula.snce B B
  let Γ : Context := [A.neg.and S]
  refine deductionTheorem [] (A.neg.and S) Formula.bot ?_
  have hEvent : Γ ⊢[FrameClass.ZTime] A.neg.and S := .assumption _ _ (by simp [Γ])
  have hSplit := ctxMp (thmIn (DiscreteUnfolding.unfoldBackwardSince B B)) (andSnd hEvent)
  have hDrop : ⊢[FrameClass.ZTime] (B.and S).prev.imp B.prev := by
    refine deductionTheorem [] (B.and S).prev B.prev ?_
    have hPrev : [(B.and S).prev] ⊢[FrameClass.ZTime] (B.and S).prev :=
      .assumption _ _ (by simp)
    exact snceEventMono _ _ _ Formula.bot (lceImp B S) hPrev
  have hPrevB : Γ ⊢[FrameClass.ZTime] B.prev :=
    orElim Γ B.prev (B.and S).prev B.prev hSplit (thmIn (identity B.prev)) (thmIn hDrop)
  have hStep : ⊢[FrameClass.ZTime] B.imp A.next := by
    refine deductionTheorem [] B A.next ?_
    have h : [B] ⊢[FrameClass.ZTime] B := .assumption _ _ (by simp)
    exact ctxMp (andSnd h) (andFst h)
  have hPrevNext := snceEventMono Γ B A.next Formula.bot hStep hPrevB
  exact ctxMp (andFst hEvent) (ctxMp (thmIn (prevNext A)) hPrevNext)

/-- Ordinary forward invariance on integer time, including the current one-step premise.

UZ selects a first future failure. Until enrichment records the initialized prefix there;
Since unfolding exposes its immediate predecessor, whose one-step guarantee contradicts the
failure. Strict `G` excludes the present, so `A → X A` is required both now and under `G`.
-/
def forwardInvariantRule (A : Formula) :
    ⊢[FrameClass.ZTime] A.imp ((A.imp A.next).imp
      ((A.imp A.next).allFuture.imp A.allFuture)) := by
  let step := A.imp A.next
  let B := A.and step
  let Γ : Context := [step.allFuture, step, A]
  refine deductionTheorem [] A _ ?_
  refine deductionTheorem [A] step _ ?_
  refine deductionTheorem [step, A] step.allFuture A.allFuture ?_
  refine deductionTheorem Γ A.neg.someFuture Formula.bot ?_
  let Δ : Context := A.neg.someFuture :: Γ
  have hFailure : Δ ⊢[FrameClass.ZTime] A.neg.someFuture := .assumption _ _ (by simp [Δ])
  have hA : Δ ⊢[FrameClass.ZTime] A := .assumption _ _ (by simp [Δ, Γ])
  have hStep : Δ ⊢[FrameClass.ZTime] step := .assumption _ _ (by simp [Δ, Γ])
  have hFutureStep : Δ ⊢[FrameClass.ZTime] step.allFuture :=
    .assumption _ _ (by simp [Δ, Γ])
  have hFirst := ctxMp (DerivationTree.axiom Δ _ (Axiom.prior_UZ A.neg) le_rfl) hFailure
  have hPrefix := guardMono Δ A.neg A.neg.neg A (doubleNegation A) hFirst
  have hPairRule : ⊢[FrameClass.ZTime] step.imp (A.imp B) := by
    refine deductionTheorem [] step _ ?_
    refine deductionTheorem [step] A B ?_
    exact andIntro (.assumption _ _ (by simp)) (.assumption _ _ (by simp))
  have hGuardMap : Δ ⊢[FrameClass.ZTime] (A.imp B).allFuture :=
    ctxMp (ctxMp (thmIn (gDistribution step (A.imp B)))
      (thmIn (DerivationTree.temporal_necessitation _ hPairRule))) hFutureStep
  have hGuarded := untilGuard hGuardMap hPrefix
  have hEnriched := ctxMp
    (DerivationTree.axiom Δ _ (Axiom.enrichment_until B A.neg B)
      (FrameClass.base_le _)) (andIntro (andIntro hA hStep) hGuarded)
  exact ctxMp (thmIn (untlBotFalse B))
    (eventMono Δ _ Formula.bot B (invariantFailureEvent A) hEnriched)

/-- Apply forward invariance while retaining all current and persistent assumptions. -/
def forwardInvariant {Γ : Context} {A : Formula} (hFrame : FrameClass.ZTime ≤ fc)
    (hInit : Γ ⊢[fc] A) (hNow : Γ ⊢[fc] A.imp A.next)
    (hFuture : Γ ⊢[fc] (A.imp A.next).allFuture) : Γ ⊢[fc] A.allFuture :=
  ctxMp (ctxMp (ctxMp (thmIn ((forwardInvariantRule A).lift hFrame)) hInit) hNow) hFuture

/-- The native time-reflection mirror of ordinary forward invariance. -/
def pastInvariantRule (hFrame : FrameClass.ZTime ≤ fc) (A : Formula) :
    ⊢[fc] A.imp ((A.imp A.prev).imp ((A.imp A.prev).allPast.imp A.allPast)) := by
  simpa only [Formula.reflectTime, Formula.reflect_time_next, Formula.reflect_time_all_future,
    Formula.reflect_time_involution] using
      DerivationTree.time_reflection _ ((forwardInvariantRule A.reflectTime).lift hFrame)

/-- Apply past invariance with its current and strict-past one-step guarantees. -/
def pastInvariant {Γ : Context} {A : Formula} (hFrame : FrameClass.ZTime ≤ fc)
    (hInit : Γ ⊢[fc] A) (hNow : Γ ⊢[fc] A.imp A.prev)
    (hPast : Γ ⊢[fc] (A.imp A.prev).allPast) : Γ ⊢[fc] A.allPast :=
  ctxMp (ctxMp (ctxMp (thmIn (pastInvariantRule hFrame A)) hInit) hNow) hPast

end FormalSystem.Theorems.ProofMode
