/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Theorems.ProofMode.TemporalComposition.Temporal

/-!
# Adjacent-time rules, contraction and integer-time expansion

Contraction and transport to an existing successor or predecessor hold at Base.
Expansion and adjacent scope persistence require the integer-time certificate.
-/

namespace FormalSystem.Theorems.ProofMode

open FormalSystem.Syntax FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Theorems.Combinators FormalSystem.Theorems.TemporalDerived

variable {fc : FrameClass} {Γ : Context}

/-! ## One-step fold and unfold -/

/-- `X e ∨ X(g ∧ U g e) → U g e`, at every frame class. -/
def untilFoldRule (guard event : Formula) :
    ⊢[fc] ((Formula.next event).or (Formula.next (guard.and (Formula.untl guard event)))).imp
      (Formula.untl guard event) :=
  (DiscreteUnfolding.unfoldBackward event guard).lift (FrameClass.base_le fc)

/-- `Y e ∨ Y(g ∧ S g e) → S g e`, at every frame class: closed time reflection of the Base
Until fold. -/
def sinceFoldRule (guard event : Formula) :
    ⊢[fc] ((Formula.prev event).or (Formula.prev (guard.and (Formula.snce guard event)))).imp
      (Formula.snce guard event) :=
  reflectThm (untilFoldRule guard.reflectTime event.reflectTime) (by
    simp only [Formula.next, Formula.prev, Formula.or, Formula.and, Formula.neg,
      Formula.reflectTime, Formula.reflect_time_involution])

/-- `U g e → X e ∨ X(g ∧ U g e)`, requiring integer time. -/
def untilUnfoldRule (hFrame : FrameClass.ZTime ≤ fc) (guard event : Formula) :
    ⊢[fc] (Formula.untl guard event).imp
      ((Formula.next event).or (Formula.next (guard.and (Formula.untl guard event)))) :=
  (DiscreteUnfolding.unfoldForward event guard).lift hFrame

/-- `S g e → Y e ∨ Y(g ∧ S g e)`, requiring integer time. -/
def sinceUnfoldRule (hFrame : FrameClass.ZTime ≤ fc) (guard event : Formula) :
    ⊢[fc] (Formula.snce guard event).imp
      ((Formula.prev event).or (Formula.prev (guard.and (Formula.snce guard event)))) :=
  (DiscreteUnfolding.unfoldBackwardSince event guard).lift hFrame

/-- Reduce an Until goal to its one-step disjunction, at every frame class. -/
def untilFold {guard event : Formula}
    (h : Γ ⊢[fc] (Formula.next event).or (Formula.next (guard.and (Formula.untl guard event)))) :
    Γ ⊢[fc] Formula.untl guard event :=
  ctxMp (thmIn (untilFoldRule guard event)) h

/-- Reduce a Since goal to its one-step disjunction, at every frame class. -/
def sinceFold {guard event : Formula}
    (h : Γ ⊢[fc] (Formula.prev event).or (Formula.prev (guard.and (Formula.snce guard event)))) :
    Γ ⊢[fc] Formula.snce guard event :=
  ctxMp (thmIn (sinceFoldRule guard event)) h

/-- Unfold an Until fact one step on integer time. Both branches keep their `X` and must prove
the common conclusion. -/
def untilUnfoldCases (hFrame : FrameClass.ZTime ≤ fc) {guard event C : Formula}
    (h : Γ ⊢[fc] Formula.untl guard event)
    (hEvent : Formula.next event :: Γ ⊢[fc] C)
    (hContinue : Formula.next (guard.and (Formula.untl guard event)) :: Γ ⊢[fc] C) :
    Γ ⊢[fc] C :=
  orCases (ctxMp (thmIn (untilUnfoldRule hFrame guard event)) h) hEvent hContinue

/-- Unfold a Since fact one step on integer time, keeping `Y` in both branches. -/
def sinceUnfoldCases (hFrame : FrameClass.ZTime ≤ fc) {guard event C : Formula}
    (h : Γ ⊢[fc] Formula.snce guard event)
    (hEvent : Formula.prev event :: Γ ⊢[fc] C)
    (hContinue : Formula.prev (guard.and (Formula.snce guard event)) :: Γ ⊢[fc] C) :
    Γ ⊢[fc] C :=
  orCases (ctxMp (thmIn (sinceUnfoldRule hFrame guard event)) h) hEvent hContinue

/-- `G φ → (X ψ → X φ)`: persistent information holds at an existing successor. -/
private def nextOfAllFutureRule (φ ψ : Formula) : ⊢[fc] φ.allFuture.imp (ψ.next.imp φ.next) :=
  impTrans (gWeaken φ ψ) (untilMonoEvent ψ φ Formula.bot)

/-- `H φ → (Y ψ → Y φ)`, by closed time reflection. -/
private def prevOfAllPastRule (φ ψ : Formula) : ⊢[fc] φ.allPast.imp (ψ.prev.imp φ.prev) :=
  reflectThm (nextOfAllFutureRule φ.reflectTime ψ.reflectTime) (by
    simp only [Formula.reflectTime, Formula.reflect_time_all_future, Formula.reflect_time_next,
      Formula.reflect_time_involution])

/-- Move a persistent fact under an existing next witness. Frame-polymorphic: the witness is a
premise. With `futureKeep` and `succIndicatorAt` it supplies `X(G P)` for `generalizedNextK`. -/
def nextOfAllFuture {φ ψ : Formula} (hφ : Γ ⊢[fc] φ.allFuture) (hNext : Γ ⊢[fc] ψ.next) :
    Γ ⊢[fc] φ.next :=
  ctxMp (ctxMp (thmIn (nextOfAllFutureRule φ ψ)) hφ) hNext

/-- Move a persistent past fact under an existing previous witness. -/
def prevOfAllPast {φ ψ : Formula} (hφ : Γ ⊢[fc] φ.allPast) (hPrev : Γ ⊢[fc] ψ.prev) :
    Γ ⊢[fc] φ.prev :=
  ctxMp (ctxMp (thmIn (prevOfAllPastRule φ ψ)) hφ) hPrev

/-- `G P` yields `X(G P)` on integer time: temporal 4, then the successor indicator. -/
def nextKeep (hFrame : FrameClass.ZTime ≤ fc) {P : Formula} (h : Γ ⊢[fc] P.allFuture) :
    Γ ⊢[fc] P.allFuture.next :=
  nextOfAllFuture (futureKeep h) (thmIn (DiscreteUnfolding.succIndicatorAt hFrame))

/-- `H P` yields `Y(H P)` on integer time: past temporal 4, then the predecessor indicator. -/
def prevKeep (hFrame : FrameClass.ZTime ≤ fc) {P : Formula} (h : Γ ⊢[fc] P.allPast) :
    Γ ⊢[fc] P.allPast.prev :=
  prevOfAllPast (pastKeep h) (thmIn (DiscreteUnfolding.prevIndicatorAt hFrame))

end FormalSystem.Theorems.ProofMode

namespace FormalSystem.PlusLanguage.ProofMode

open FormalSystem.Syntax FormalSystem.PlusLanguage
open FormalSystem.ProofSystem (FrameClass DerivationTree)

variable {fc : FrameClass} {Γ : PlusContext}

open TemporalSchema

/-! ### Fold and unfold -/

/-- `X e ∨ X(g ∧ U g e) → U g e`, at every frame class. -/
def untilFoldRule (guard event : PlusFormula) :
    PlusDerivationTree fc [] (((PlusFormula.next event).or
      (PlusFormula.next (guard.and (.untl guard event)))).imp (.untl guard event)) :=
  .ofTMSubst (assign4 guard event guard guard) (Theorems.ProofMode.untilFoldRule (atom 0) (atom 1))

/-- `Y e ∨ Y(g ∧ S g e) → S g e`, at every frame class. -/
def sinceFoldRule (guard event : PlusFormula) :
    PlusDerivationTree fc [] (((PlusFormula.prev event).or
      (PlusFormula.prev (guard.and (.snce guard event)))).imp (.snce guard event)) :=
  .ofTMSubst (assign4 guard event guard guard) (Theorems.ProofMode.sinceFoldRule (atom 0) (atom 1))

/-- `U g e → X e ∨ X(g ∧ U g e)`, requiring integer time. -/
def untilUnfoldRule (hFrame : FrameClass.ZTime ≤ fc) (guard event : PlusFormula) :
    PlusDerivationTree fc [] ((PlusFormula.untl guard event).imp ((PlusFormula.next event).or
      (PlusFormula.next (guard.and (.untl guard event))))) :=
  .ofTMSubst (assign4 guard event guard guard)
    (Theorems.ProofMode.untilUnfoldRule hFrame (atom 0) (atom 1))

/-- `S g e → Y e ∨ Y(g ∧ S g e)`, requiring integer time. -/
def sinceUnfoldRule (hFrame : FrameClass.ZTime ≤ fc) (guard event : PlusFormula) :
    PlusDerivationTree fc [] ((PlusFormula.snce guard event).imp ((PlusFormula.prev event).or
      (PlusFormula.prev (guard.and (.snce guard event))))) :=
  .ofTMSubst (assign4 guard event guard guard)
    (Theorems.ProofMode.sinceUnfoldRule hFrame (atom 0) (atom 1))

/-- Reduce an Until goal to its one-step disjunction, at every frame class. -/
def untilFold {guard event : PlusFormula}
    (h : PlusDerivationTree fc Γ ((PlusFormula.next event).or
      (PlusFormula.next (guard.and (.untl guard event))))) :
    PlusDerivationTree fc Γ (.untl guard event) :=
  ctxMp (thmIn (untilFoldRule guard event)) h

/-- Reduce a Since goal to its one-step disjunction, at every frame class. -/
def sinceFold {guard event : PlusFormula}
    (h : PlusDerivationTree fc Γ ((PlusFormula.prev event).or
      (PlusFormula.prev (guard.and (.snce guard event))))) :
    PlusDerivationTree fc Γ (.snce guard event) :=
  ctxMp (thmIn (sinceFoldRule guard event)) h

/-- Unfold an Until fact one step on integer time, keeping `X` in both branches. -/
def untilUnfoldCases (hFrame : FrameClass.ZTime ≤ fc) {guard event C : PlusFormula}
    (h : PlusDerivationTree fc Γ (.untl guard event))
    (hEvent : PlusDerivationTree fc (PlusFormula.next event :: Γ) C)
    (hContinue : PlusDerivationTree fc
      (PlusFormula.next (guard.and (.untl guard event)) :: Γ) C) :
    PlusDerivationTree fc Γ C :=
  orCases (ctxMp (thmIn (untilUnfoldRule hFrame guard event)) h) hEvent hContinue

/-- Unfold a Since fact one step on integer time, keeping `Y` in both branches. -/
def sinceUnfoldCases (hFrame : FrameClass.ZTime ≤ fc) {guard event C : PlusFormula}
    (h : PlusDerivationTree fc Γ (.snce guard event))
    (hEvent : PlusDerivationTree fc (PlusFormula.prev event :: Γ) C)
    (hContinue : PlusDerivationTree fc
      (PlusFormula.prev (guard.and (.snce guard event)) :: Γ) C) :
    PlusDerivationTree fc Γ C :=
  orCases (ctxMp (thmIn (sinceUnfoldRule hFrame guard event)) h) hEvent hContinue

/-- Move a persistent fact under an existing next witness; no successor is asserted. -/
def nextOfAllFuture {φ ψ : PlusFormula} (hφ : PlusDerivationTree fc Γ φ.allFuture)
    (hNext : PlusDerivationTree fc Γ ψ.next) : PlusDerivationTree fc Γ φ.next :=
  apply2 (σ := assign4 φ ψ φ φ) (Theorems.ProofMode.nextOfAllFutureRule (atom 0) (atom 1)) hφ hNext

/-- Move a persistent past fact under an existing previous witness. -/
def prevOfAllPast {φ ψ : PlusFormula} (hφ : PlusDerivationTree fc Γ φ.allPast)
    (hPrev : PlusDerivationTree fc Γ ψ.prev) : PlusDerivationTree fc Γ φ.prev :=
  apply2 (σ := assign4 φ ψ φ φ) (Theorems.ProofMode.prevOfAllPastRule (atom 0) (atom 1)) hφ hPrev

/-- TM⁺ `G P` yields `X(G P)` on integer time, for arbitrary TM⁺ `P`. -/
def nextKeep (hFrame : FrameClass.ZTime ≤ fc) {P : PlusFormula}
    (h : PlusDerivationTree fc Γ P.allFuture) : PlusDerivationTree fc Γ P.allFuture.next :=
  nextOfAllFuture (ψ := PlusFormula.top) (futureKeep h)
    (thmIn (.ofTMSubst (fun _ => P)
      (FormalSystem.Theorems.DiscreteUnfolding.succIndicatorAt hFrame)))

/-- TM⁺ `H P` yields `Y(H P)` on integer time, for arbitrary TM⁺ `P`. -/
def prevKeep (hFrame : FrameClass.ZTime ≤ fc) {P : PlusFormula}
    (h : PlusDerivationTree fc Γ P.allPast) : PlusDerivationTree fc Γ P.allPast.prev :=
  prevOfAllPast (ψ := PlusFormula.top) (pastKeep h)
    (thmIn (.ofTMSubst (fun _ => P)
      (FormalSystem.Theorems.DiscreteUnfolding.prevIndicatorAt hFrame)))

end FormalSystem.PlusLanguage.ProofMode
