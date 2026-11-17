/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Theorems.ProofMode.PlusTemporal
import FormalSystem.Theorems.ProofMode.Discrete

/-!
# Native TM⁺ discrete scope and invariance

Next and Previous use transferred source distribution schemata and the native contextual
lifting operation. Necessitation retains the explicit ZTime gate proving that an adjacent
point exists. Ordinary invariance transfers the source derivation while retaining the current
one-step premise as well as its strict future or past counterpart.
-/

namespace FormalSystem.PlusLanguage.ProofMode

open FormalSystem.Syntax FormalSystem.PlusLanguage
open FormalSystem.ProofSystem (FrameClass)

variable {fc : FrameClass}

private def atom (n : Nat) : Formula := .atom (Atom.mkFresh "" n)

private def assign (A B : PlusFormula) (p : Atom) : PlusFormula :=
  if p.freshIndex == some 0 then A else B

/-- Next distributes over implication, without asserting that a successor exists. -/
def nextK (A B : PlusFormula) :
    PlusDerivationTree fc [] ((A.imp B).next.imp (A.next.imp B.next)) :=
  .ofTMSubst (assign A B) (FormalSystem.Theorems.ProofMode.nextK (atom 0) (atom 1))

/-- Previous distributes over implication, by the transferred reflected source rule. -/
def prevK (A B : PlusFormula) :
    PlusDerivationTree fc [] ((A.imp B).prev.imp (A.prev.imp B.prev)) :=
  .ofTMSubst (assign A B) (FormalSystem.Theorems.ProofMode.prevK (atom 0) (atom 1))

/-- Necessitate a native theorem at a successor, with checked existence of the successor. -/
def nextNecessitation (hFrame : FrameClass.ZTime ≤ fc) (A : PlusFormula)
    (h : PlusDerivationTree fc [] A) : PlusDerivationTree fc [] A.next :=
  nextConsequence
    (.temporal_necessitation _ (deductionTheorem [] .top A (thmIn h)))
    (.ofTMSubst (fun _ => A) (FormalSystem.Theorems.DiscreteUnfolding.succIndicatorAt hFrame))

/-- Necessitate a native theorem at a predecessor, with the same discrete-frame gate. -/
def prevNecessitation (hFrame : FrameClass.ZTime ≤ fc) (A : PlusFormula)
    (h : PlusDerivationTree fc [] A) : PlusDerivationTree fc [] A.prev :=
  prevConsequence
    (pastNecessitation _ (deductionTheorem [] .top A (thmIn h)))
    (.ofTMSubst (fun _ => A) (FormalSystem.Theorems.DiscreteUnfolding.prevIndicatorAt hFrame))

/-- Move exactly the selected body assumptions to the next point. -/
def generalizedNextK (hFrame : FrameClass.ZTime ≤ fc) (Γ : PlusContext) (A : PlusFormula)
    (h : PlusDerivationTree fc Γ A) :
    PlusDerivationTree fc (Γ.map PlusFormula.next) A.next :=
  liftContext PlusFormula.next (nextNecessitation hFrame) nextK Γ A h

/-- Move exactly the selected body assumptions to the previous point. -/
def generalizedPrevK (hFrame : FrameClass.ZTime ≤ fc) (Γ : PlusContext) (A : PlusFormula)
    (h : PlusDerivationTree fc Γ A) :
    PlusDerivationTree fc (Γ.map PlusFormula.prev) A.prev :=
  liftContext PlusFormula.prev (prevNecessitation hFrame) prevK Γ A h

/-- Forward invariance over integer time, including the current one-step premise. -/
def forwardInvariantRule (A : PlusFormula) :
    PlusDerivationTree .ZTime []
      (A.imp ((A.imp A.next).imp ((A.imp A.next).allFuture.imp A.allFuture))) :=
  .ofTMSubst (fun _ => A) (FormalSystem.Theorems.ProofMode.forwardInvariantRule (atom 0))

/-- Apply forward invariance with initialization, current step, and future step guarantees. -/
def forwardInvariant {Γ : PlusContext} {A : PlusFormula} (hFrame : FrameClass.ZTime ≤ fc)
    (hInit : PlusDerivationTree fc Γ A) (hNow : PlusDerivationTree fc Γ (A.imp A.next))
    (hFuture : PlusDerivationTree fc Γ (A.imp A.next).allFuture) :
    PlusDerivationTree fc Γ A.allFuture :=
  ctxMp (ctxMp (ctxMp (thmIn ((forwardInvariantRule A).lift hFrame)) hInit) hNow) hFuture

/-- The transferred past mirror of ordinary integer-time invariance. -/
def pastInvariantRule (hFrame : FrameClass.ZTime ≤ fc) (A : PlusFormula) :
    PlusDerivationTree fc []
      (A.imp ((A.imp A.prev).imp ((A.imp A.prev).allPast.imp A.allPast))) :=
  .ofTMSubst (fun _ => A) (FormalSystem.Theorems.ProofMode.pastInvariantRule hFrame (atom 0))

/-- Apply past invariance with initialization and both required one-step guarantees. -/
def pastInvariant {Γ : PlusContext} {A : PlusFormula} (hFrame : FrameClass.ZTime ≤ fc)
    (hInit : PlusDerivationTree fc Γ A) (hNow : PlusDerivationTree fc Γ (A.imp A.prev))
    (hPast : PlusDerivationTree fc Γ (A.imp A.prev).allPast) :
    PlusDerivationTree fc Γ A.allPast :=
  ctxMp (ctxMp (ctxMp (thmIn (pastInvariantRule hFrame A)) hInit) hNow) hPast

end FormalSystem.PlusLanguage.ProofMode
