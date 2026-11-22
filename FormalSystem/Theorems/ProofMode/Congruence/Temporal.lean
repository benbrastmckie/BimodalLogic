/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Theorems.ProofMode.Congruence.Boolean
import FormalSystem.Theorems.ProofMode.PlusDiscrete

/-! # Scoped temporal congruence in TM and TM⁺ -/

namespace FormalSystem.Theorems.ProofMode.Congruence

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.PlusLanguage

section TM

variable {fc : FrameClass}

private def tmMp {A B : Formula} (hAB : DerivationTree fc [] (A.imp B))
    (hA : DerivationTree fc [] A) : DerivationTree fc [] B :=
  .modus_ponens [] A B hAB hA

private def tmFutureMono {A B : Formula} (h : DerivationTree fc [] (A.imp B)) :
    DerivationTree fc [] (A.allFuture.imp B.allFuture) :=
  tmMp (TemporalDerived.gDistribution A B) (.temporal_necessitation _ h)

private def tmPastMono {A B : Formula} (h : DerivationTree fc [] (A.imp B)) :
    DerivationTree fc [] (A.allPast.imp B.allPast) :=
  tmMp (TemporalDerived.hDistribution A B) (pastNecessitation _ h)

/-- Strict future body `x ↦ Gx`, demand `G`, by `gDistribution`. -/
def tmFuture : Step (tmKit fc) where
  wrap := Formula.allFuture
  demand := Formula.allFuture
  flips := false
  transfer := TemporalDerived.gDistribution
  demandMono := tmFutureMono

/-- Strict past body `x ↦ Hx`, demand `H`, by `hDistribution`. -/
def tmPast : Step (tmKit fc) where
  wrap := Formula.allPast
  demand := Formula.allPast
  flips := false
  transfer := TemporalDerived.hDistribution
  demandMono := tmPastMono

/-- Until guard `x ↦ x U e` at fixed event `e`, demand `G`, by `untilMonoGuard`. -/
def tmUntilGuard (event : Formula) : Step (tmKit fc) where
  wrap x := Formula.untl x event
  demand := Formula.allFuture
  flips := false
  transfer A B := TemporalDerived.untilMonoGuard A B event
  demandMono := tmFutureMono

/-- Until event `x ↦ g U x` at fixed guard `g`, demand `G`, by `untilMonoEvent`. -/
def tmUntilEvent (guard : Formula) : Step (tmKit fc) where
  wrap x := Formula.untl guard x
  demand := Formula.allFuture
  flips := false
  transfer A B := TemporalDerived.untilMonoEvent A B guard
  demandMono := tmFutureMono

/-- Since guard `x ↦ x S e` at fixed event `e`, demand `H`, by `sinceMonoGuard`. -/
def tmSinceGuard (event : Formula) : Step (tmKit fc) where
  wrap x := Formula.snce x event
  demand := Formula.allPast
  flips := false
  transfer A B := TemporalDerived.sinceMonoGuard A B event
  demandMono := tmPastMono

/-- Since event `x ↦ g S x` at fixed guard `g`, demand `H`, by `sinceMonoEvent`. -/
def tmSinceEvent (guard : Formula) : Step (tmKit fc) where
  wrap x := Formula.snce guard x
  demand := Formula.allPast
  flips := false
  transfer A B := TemporalDerived.sinceMonoEvent A B guard
  demandMono := tmPastMono

/-- Next event `x ↦ Xx` with the conditional demand `X`, by closed `nextK`. Demand
monotonicity uses G-necessitation and event monotonicity at guard `⊥`, so it needs no
adjacent-time existence and holds at every frame class. -/
def tmNext : Step (tmKit fc) where
  wrap := Formula.next
  demand := Formula.next
  flips := false
  transfer := ProofMode.nextK
  demandMono {A B} h :=
    tmMp (TemporalDerived.untilMonoEvent A B .bot) (.temporal_necessitation _ h)

/-- Previous event `x ↦ Yx` with the conditional demand `Y`, by closed `prevK`. Demand
monotonicity uses H-necessitation and Since event monotonicity at guard `⊥`. -/
def tmPrev : Step (tmKit fc) where
  wrap := Formula.prev
  demand := Formula.prev
  flips := false
  transfer := ProofMode.prevK
  demandMono {A B} h :=
    tmMp (TemporalDerived.sinceMonoEvent A B .bot) (pastNecessitation _ h)

/-- Next event `x ↦ Xx` with demand `G`, by `untilMonoEvent` at guard `⊥`. -/
def tmNextFuture : Step (tmKit fc) where
  wrap := Formula.next
  demand := Formula.allFuture
  flips := false
  transfer A B := TemporalDerived.untilMonoEvent A B .bot
  demandMono := tmFutureMono

/-- Previous event `x ↦ Yx` with demand `H`, by `sinceMonoEvent` at guard `⊥`. -/
def tmPrevPast : Step (tmKit fc) where
  wrap := Formula.prev
  demand := Formula.allPast
  flips := false
  transfer A B := TemporalDerived.sinceMonoEvent A B .bot
  demandMono := tmPastMono

end TM

section TMPlus

variable {fc : FrameClass}

private def plusFutureMono {A B : PlusFormula} (h : PlusDerivationTree fc [] (A.imp B)) :
    PlusDerivationTree fc [] (A.allFuture.imp B.allFuture) :=
  PlusLanguage.ProofMode.ctxMp (PlusLanguage.ProofMode.gDistribution A B)
    (.temporal_necessitation _ h)

private def plusPastMono {A B : PlusFormula} (h : PlusDerivationTree fc [] (A.imp B)) :
    PlusDerivationTree fc [] (A.allPast.imp B.allPast) :=
  PlusLanguage.ProofMode.ctxMp (PlusLanguage.ProofMode.hDistribution A B)
    (PlusLanguage.ProofMode.pastNecessitation _ h)

private def plusUntilMonoGuard (A B e : PlusFormula) :
    PlusDerivationTree fc [] ((A.imp B).allFuture.imp ((PlusFormula.untl A e).imp
      (PlusFormula.untl B e))) :=
  .ofTMSubst (assignSchemaAtoms A B e)
    (TemporalDerived.untilMonoGuard (schemaAtom 0) (schemaAtom 1) (schemaAtom 2))

private def plusUntilMonoEvent (A B g : PlusFormula) :
    PlusDerivationTree fc [] ((A.imp B).allFuture.imp ((PlusFormula.untl g A).imp
      (PlusFormula.untl g B))) :=
  .ofTMSubst (assignSchemaAtoms A B g)
    (TemporalDerived.untilMonoEvent (schemaAtom 0) (schemaAtom 1) (schemaAtom 2))

private def plusSinceMonoGuard (A B e : PlusFormula) :
    PlusDerivationTree fc [] ((A.imp B).allPast.imp ((PlusFormula.snce A e).imp
      (PlusFormula.snce B e))) :=
  .ofTMSubst (assignSchemaAtoms A B e)
    (TemporalDerived.sinceMonoGuard (schemaAtom 0) (schemaAtom 1) (schemaAtom 2))

private def plusSinceMonoEvent (A B g : PlusFormula) :
    PlusDerivationTree fc [] ((A.imp B).allPast.imp ((PlusFormula.snce g A).imp
      (PlusFormula.snce g B))) :=
  .ofTMSubst (assignSchemaAtoms A B g)
    (TemporalDerived.sinceMonoEvent (schemaAtom 0) (schemaAtom 1) (schemaAtom 2))

/-- Strict future body `x ↦ Gx`, demand `G`, by transferred `gDistribution`. -/
def plusFuture : Step (plusKit fc) where
  wrap := PlusFormula.allFuture
  demand := PlusFormula.allFuture
  flips := false
  transfer := PlusLanguage.ProofMode.gDistribution
  demandMono := plusFutureMono

/-- Strict past body `x ↦ Hx`, demand `H`, by transferred `hDistribution`. -/
def plusPast : Step (plusKit fc) where
  wrap := PlusFormula.allPast
  demand := PlusFormula.allPast
  flips := false
  transfer := PlusLanguage.ProofMode.hDistribution
  demandMono := plusPastMono

/-- Until guard `x ↦ x U e` at fixed event `e`, demand `G`. -/
def plusUntilGuard (event : PlusFormula) : Step (plusKit fc) where
  wrap x := PlusFormula.untl x event
  demand := PlusFormula.allFuture
  flips := false
  transfer A B := plusUntilMonoGuard A B event
  demandMono := plusFutureMono

/-- Until event `x ↦ g U x` at fixed guard `g`, demand `G`. -/
def plusUntilEvent (guard : PlusFormula) : Step (plusKit fc) where
  wrap x := PlusFormula.untl guard x
  demand := PlusFormula.allFuture
  flips := false
  transfer A B := plusUntilMonoEvent A B guard
  demandMono := plusFutureMono

/-- Since guard `x ↦ x S e` at fixed event `e`, demand `H`. -/
def plusSinceGuard (event : PlusFormula) : Step (plusKit fc) where
  wrap x := PlusFormula.snce x event
  demand := PlusFormula.allPast
  flips := false
  transfer A B := plusSinceMonoGuard A B event
  demandMono := plusPastMono

/-- Since event `x ↦ g S x` at fixed guard `g`, demand `H`. -/
def plusSinceEvent (guard : PlusFormula) : Step (plusKit fc) where
  wrap x := PlusFormula.snce guard x
  demand := PlusFormula.allPast
  flips := false
  transfer A B := plusSinceMonoEvent A B guard
  demandMono := plusPastMono

/-- Next event with conditional demand `X`, by transferred `nextK`. Demand monotonicity uses
G-necessitation and event monotonicity at guard `⊥`, never closed Next necessitation. -/
def plusNext : Step (plusKit fc) where
  wrap := PlusFormula.next
  demand := PlusFormula.next
  flips := false
  transfer := PlusLanguage.ProofMode.nextK
  demandMono {A B} h :=
    PlusLanguage.ProofMode.ctxMp (plusUntilMonoEvent A B .bot) (.temporal_necessitation _ h)

/-- Previous event with conditional demand `Y`, by transferred `prevK`. Demand monotonicity
uses H-necessitation and Since event monotonicity at guard `⊥`. -/
def plusPrev : Step (plusKit fc) where
  wrap := PlusFormula.prev
  demand := PlusFormula.prev
  flips := false
  transfer := PlusLanguage.ProofMode.prevK
  demandMono {A B} h :=
    PlusLanguage.ProofMode.ctxMp (plusSinceMonoEvent A B .bot)
      (PlusLanguage.ProofMode.pastNecessitation _ h)

/-- Next event with demand `G`, by transferred event monotonicity at guard `⊥`. -/
def plusNextFuture : Step (plusKit fc) where
  wrap := PlusFormula.next
  demand := PlusFormula.allFuture
  flips := false
  transfer A B := plusUntilMonoEvent A B .bot
  demandMono := plusFutureMono

/-- Previous event with demand `H`, by transferred Since event monotonicity at guard `⊥`. -/
def plusPrevPast : Step (plusKit fc) where
  wrap := PlusFormula.prev
  demand := PlusFormula.allPast
  flips := false
  transfer A B := plusSinceMonoEvent A B .bot
  demandMono := plusPastMono

end TMPlus

end FormalSystem.Theorems.ProofMode.Congruence
