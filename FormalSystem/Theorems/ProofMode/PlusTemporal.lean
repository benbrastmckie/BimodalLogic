/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Theorems.ProofMode.PlusRules
import FormalSystem.Theorems.ProofMode.Temporal

/-!
# Native TM⁺ temporal composition

The proved TM temporal rules transfer by `ofTMSubst` at arbitrary TM⁺ formula arguments.
Context substitution then supplies the caller's opaque premise derivations. This shares the
source calculus's proof theory, including shifted substitution under time reflection, without
replacing native derivation data by semantic truth or extracting it from `Nonempty`.
-/

namespace FormalSystem.PlusLanguage.ProofMode

open FormalSystem.Syntax FormalSystem.PlusLanguage
open FormalSystem.ProofSystem (FrameClass DerivationTree)

variable {fc : FrameClass} {Γ : PlusContext}

private def atom (n : Nat) : Formula := .atom (Atom.mkFresh "" n)

private def assign (A B C : PlusFormula) (p : Atom) : PlusFormula :=
  match p.freshIndex with
  | some 0 => A
  | some 1 => B
  | _ => C

private def premiseL (A B : Formula) : DerivationTree fc [A, B] A :=
  .assumption _ _ (by simp)

private def premiseR (A B : Formula) : DerivationTree fc [A, B] B :=
  .assumption _ _ (by simp)

private def transferBinary {σ : Atom → PlusFormula} {A B C : Formula}
    (d : DerivationTree fc [A, B] C)
    (hA : PlusDerivationTree fc Γ (substPlus σ A))
    (hB : PlusDerivationTree fc Γ (substPlus σ B)) :
    PlusDerivationTree fc Γ (substPlus σ C) :=
  substContext (.ofTMSubst σ d)
    (consContextProofs hA (consContextProofs hB (nilContextProofs Γ)))

/-- Map an eventuality through an implication valid throughout the strict future. -/
def futureConsequence {φ ψ : PlusFormula}
    (hMap : PlusDerivationTree fc Γ (φ.imp ψ).allFuture)
    (hφ : PlusDerivationTree fc Γ φ.someFuture) :
    PlusDerivationTree fc Γ ψ.someFuture :=
  transferBinary (σ := assign φ ψ ψ)
    (FormalSystem.Theorems.ProofMode.futureConsequence (φ := atom 0) (ψ := atom 1)
      (premiseL _ _) (premiseR _ _)) hMap hφ

/-- Map a past eventuality through a past-scoped implication. -/
def pastConsequence {φ ψ : PlusFormula}
    (hMap : PlusDerivationTree fc Γ (φ.imp ψ).allPast)
    (hφ : PlusDerivationTree fc Γ φ.somePast) : PlusDerivationTree fc Γ ψ.somePast :=
  transferBinary (σ := assign φ ψ ψ)
    (FormalSystem.Theorems.ProofMode.pastConsequence (φ := atom 0) (ψ := atom 1)
      (premiseL _ _) (premiseR _ _)) hMap hφ

/-- Join a persistent future fact with an eventuality at its occurrence. -/
def futureAnd {φ ψ : PlusFormula}
    (hφ : PlusDerivationTree fc Γ φ.allFuture)
    (hψ : PlusDerivationTree fc Γ ψ.someFuture) :
    PlusDerivationTree fc Γ (φ.and ψ).someFuture :=
  transferBinary (σ := assign φ ψ ψ)
    (FormalSystem.Theorems.ProofMode.futureAnd (φ := atom 0) (ψ := atom 1)
      (premiseL _ _) (premiseR _ _)) hφ hψ

/-- Join a persistent past fact with a past eventuality. -/
def pastAnd {φ ψ : PlusFormula}
    (hφ : PlusDerivationTree fc Γ φ.allPast)
    (hψ : PlusDerivationTree fc Γ ψ.somePast) :
    PlusDerivationTree fc Γ (φ.and ψ).somePast :=
  transferBinary (σ := assign φ ψ ψ)
    (FormalSystem.Theorems.ProofMode.pastAnd (φ := atom 0) (ψ := atom 1)
      (premiseL _ _) (premiseR _ _)) hφ hψ

/-- Apply a future progress guarantee at an eventuality and collapse the nested future. -/
def futureBind {φ ψ : PlusFormula}
    (hMap : PlusDerivationTree fc Γ (φ.imp ψ.someFuture).allFuture)
    (hφ : PlusDerivationTree fc Γ φ.someFuture) :
    PlusDerivationTree fc Γ ψ.someFuture :=
  transferBinary (σ := assign φ ψ ψ)
    (FormalSystem.Theorems.ProofMode.futureBind (φ := atom 0) (ψ := atom 1)
      (premiseL _ _) (premiseR _ _)) hMap hφ

/-- Apply a past progress guarantee at a past eventuality. -/
def pastBind {φ ψ : PlusFormula}
    (hMap : PlusDerivationTree fc Γ (φ.imp ψ.somePast).allPast)
    (hφ : PlusDerivationTree fc Γ φ.somePast) : PlusDerivationTree fc Γ ψ.somePast :=
  transferBinary (σ := assign φ ψ ψ)
    (FormalSystem.Theorems.ProofMode.pastBind (φ := atom 0) (ψ := atom 1)
      (premiseL _ _) (premiseR _ _)) hMap hφ

/-- Compose future progress while retaining the second guarantee through temporal 4. -/
def progressTrans {φ ψ χ : PlusFormula}
    (hφψ : PlusDerivationTree fc Γ (φ.imp ψ.someFuture).allFuture)
    (hψχ : PlusDerivationTree fc Γ (ψ.imp χ.someFuture).allFuture) :
    PlusDerivationTree fc Γ (φ.imp χ.someFuture).allFuture :=
  transferBinary (σ := assign φ ψ χ)
    (FormalSystem.Theorems.ProofMode.progressTrans (φ := atom 0) (ψ := atom 1) (χ := atom 2)
      (premiseL _ _) (premiseR _ _)) hφψ hψχ

/-- Compose past progress through the reflected persistence rule. -/
def pastProgressTrans {φ ψ χ : PlusFormula}
    (hφψ : PlusDerivationTree fc Γ (φ.imp ψ.somePast).allPast)
    (hψχ : PlusDerivationTree fc Γ (ψ.imp χ.somePast).allPast) :
    PlusDerivationTree fc Γ (φ.imp χ.somePast).allPast :=
  transferBinary (σ := assign φ ψ χ)
    (FormalSystem.Theorems.ProofMode.pastProgressTrans (φ := atom 0) (ψ := atom 1) (χ := atom 2)
      (premiseL _ _) (premiseR _ _)) hφψ hψχ

/-- Apply discrete backward induction with the source rule's explicit frame requirement. -/
def futureBackwardInduction {φ : PlusFormula} (hFrame : FrameClass.ZTime ≤ fc)
    (hStep : PlusDerivationTree fc Γ (φ.allFuture.imp φ).allFuture)
    (hEventually : PlusDerivationTree fc Γ φ.allFuture.someFuture) :
    PlusDerivationTree fc Γ φ.allFuture :=
  transferBinary (σ := assign φ φ φ)
    (FormalSystem.Theorems.ProofMode.futureBackwardInduction
      (φ := atom 0) hFrame (premiseL _ _) (premiseR _ _))
    hStep hEventually

/-- The past mirror of discrete backward induction, with the same frame requirement. -/
def pastBackwardInduction {φ : PlusFormula} (hFrame : FrameClass.ZTime ≤ fc)
    (hStep : PlusDerivationTree fc Γ (φ.allPast.imp φ).allPast)
    (hEventually : PlusDerivationTree fc Γ φ.allPast.somePast) :
    PlusDerivationTree fc Γ φ.allPast :=
  transferBinary (σ := assign φ φ φ)
    (FormalSystem.Theorems.ProofMode.pastBackwardInduction
      (φ := atom 0) hFrame (premiseL _ _) (premiseR _ _))
    hStep hEventually

/-- Weaken an Until guard using a future-scoped implication. -/
def untilGuard {φ ψ χ : PlusFormula}
    (hMap : PlusDerivationTree fc Γ (φ.imp χ).allFuture)
    (hUntil : PlusDerivationTree fc Γ (.untl φ ψ)) :
    PlusDerivationTree fc Γ (.untl χ ψ) :=
  transferBinary (σ := assign φ ψ χ)
    (FormalSystem.Theorems.ProofMode.untilGuard (φ := atom 0) (ψ := atom 1) (χ := atom 2)
      (premiseL _ _) (premiseR _ _)) hMap hUntil

/-- Map an Until event while preserving its guard and operand order. -/
def untilEvent {φ ψ χ : PlusFormula}
    (hMap : PlusDerivationTree fc Γ (φ.imp ψ).allFuture)
    (hUntil : PlusDerivationTree fc Γ (.untl χ φ)) :
    PlusDerivationTree fc Γ (.untl χ ψ) :=
  transferBinary (σ := assign φ ψ χ)
    (FormalSystem.Theorems.ProofMode.untilEvent (φ := atom 0) (ψ := atom 1) (χ := atom 2)
      (premiseL _ _) (premiseR _ _)) hMap hUntil

/-- Weaken a Since guard using a past-scoped implication. -/
def sinceGuard {φ ψ χ : PlusFormula}
    (hMap : PlusDerivationTree fc Γ (φ.imp χ).allPast)
    (hSince : PlusDerivationTree fc Γ (.snce φ ψ)) :
    PlusDerivationTree fc Γ (.snce χ ψ) :=
  transferBinary (σ := assign φ ψ χ)
    (FormalSystem.Theorems.ProofMode.sinceGuard (φ := atom 0) (ψ := atom 1) (χ := atom 2)
      (premiseL _ _) (premiseR _ _)) hMap hSince

/-- Map a Since event while preserving its guard and operand order. -/
def sinceEvent {φ ψ χ : PlusFormula}
    (hMap : PlusDerivationTree fc Γ (φ.imp ψ).allPast)
    (hSince : PlusDerivationTree fc Γ (.snce χ φ)) :
    PlusDerivationTree fc Γ (.snce χ ψ) :=
  transferBinary (σ := assign φ ψ χ)
    (FormalSystem.Theorems.ProofMode.sinceEvent (φ := atom 0) (ψ := atom 1) (χ := atom 2)
      (premiseL _ _) (premiseR _ _)) hMap hSince

/-- Map a next event with a future-scoped implication; no successor is invented. -/
def nextConsequence {φ ψ : PlusFormula}
    (hMap : PlusDerivationTree fc Γ (φ.imp ψ).allFuture)
    (hNext : PlusDerivationTree fc Γ φ.next) : PlusDerivationTree fc Γ ψ.next :=
  untilEvent hMap hNext

/-- Map a previous event with a past-scoped implication. -/
def prevConsequence {φ ψ : PlusFormula}
    (hMap : PlusDerivationTree fc Γ (φ.imp ψ).allPast)
    (hPrev : PlusDerivationTree fc Γ φ.prev) : PlusDerivationTree fc Γ ψ.prev :=
  sinceEvent hMap hPrev

end FormalSystem.PlusLanguage.ProofMode
