/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Theorems.GeneralizedNecessitation
import FormalSystem.Theorems.Propositional.Core
import FormalSystem.Theorems.DeductionTheorem

/-!
# Temporal Connectedness and Discrete Symmetry as Derived Schemata

Three schemata the paper lists under `def:BX` are theorems of the reduced primitive system,
derived here below `Theorems/TemporalDerived.lean` (which consumes `connectFuture`) from the
Base primitives US (`enrichment_until`), UG (`left_mono_until_G`), UC (`right_mono_until`), NB,
MF, MT, and the rules TN and TR:

* `connectFuture` — TC, `φ → G P φ`. Assume `φ` and, for contradiction, `U(⊤, ¬Pφ)`; US
  enriches the Until to `U(⊤, ¬Pφ ∧ S(⊤, φ))`, whose event is contradictory, so UC drives it to
  `U(⊤, ⊥)`, refuted by `untlBotFalse`.
* `fHImp` — `F H ψ → ψ`, the contrapositive of TC at `¬ψ`; the direct re-proof of
  `DedekindDerived.someFutureAllPastImp`.
* `discreteSymmFwd` — NP, `X⊤ → Y⊤` (`X⊤ = U(⊤,⊥)`, `Y⊤ = S(⊤,⊥)`). US at `(⊥, ⊤, ⊤)` turns
  `X⊤` into `U(⊥, Y⊤)`; TR of NF (`DerivedAxioms.discretePropagateFwdMirror`) lifts the event to
  `H Y⊤`; UE (`DerivedAxioms.untilF`) gives `F H Y⊤`, and `fHImp` lands on `Y⊤`.
* `discretePropagateBwd` — NA, `X⊤ → H X⊤`, as NP ; TR(NF) ; `H(Y⊤ → X⊤)` by TR of TN on NP,
  distributed by `pastKDist`.

The TR mirrors `connectPast`, `connectPastAt` and `discreteSymmBwd` live here as well, reflecting
`connectFuture` and `discreteSymmFwd`.
-/

namespace FormalSystem.Theorems.ConnectDerived

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.ProofSystem.DerivedAxioms (untilF eventMonoThm discretePropagateFwdMirror
  ofReflect lift)
open FormalSystem.Theorems.Combinators
open FormalSystem.Theorems.Propositional
open FormalSystem.Metalogic.Core (deductionTheorem)

noncomputable section

/-- TC: `φ → G(P φ)`. From `φ` and `U(⊤, ¬Pφ)`, US gives `U(⊤, ¬Pφ ∧ S(⊤, φ))`; the event
refutes itself, so the Until collapses to `U(⊤, ⊥)` and `untlBotFalse` closes the goal. -/
@[tmLemma]
def connectFuture {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.imp φ.somePast.allFuture := by
  refine deductionTheorem [] φ _ ?_
  refine deductionTheorem [φ] (Formula.untl Formula.top φ.somePast.neg) Formula.bot ?_
  let Γ : Context := [Formula.untl Formula.top φ.somePast.neg, φ]
  have hφ : Γ ⊢[fc] φ := DerivationTree.assumption _ _ (by simp [Γ])
  have hU : Γ ⊢[fc] Formula.untl Formula.top φ.somePast.neg :=
    DerivationTree.assumption _ _ (by simp [Γ])
  have hUS : Γ ⊢[fc] (Formula.and φ (Formula.untl Formula.top φ.somePast.neg)).imp
      (Formula.untl Formula.top (Formula.and φ.somePast.neg (Formula.snce Formula.top φ))) :=
    DerivationTree.axiom _ _ (Axiom.enrichment_until Formula.top φ.somePast.neg φ)
      (FrameClass.base_le fc)
  have h1 : Γ ⊢[fc] Formula.untl Formula.top
      (Formula.and φ.somePast.neg (Formula.snce Formula.top φ)) :=
    ctxMp hUS (andIntro hφ hU)
  have hcontra : ⊢[fc] (Formula.and φ.somePast.neg (Formula.snce Formula.top φ)).imp
      Formula.bot := by
    refine deductionTheorem [] _ _ ?_
    have hAB : [Formula.and φ.somePast.neg (Formula.snce Formula.top φ)] ⊢[fc]
        Formula.and φ.somePast.neg (Formula.snce Formula.top φ) :=
      DerivationTree.assumption _ _ (by simp)
    exact ctxMp (andFst hAB) (andSnd hAB)
  have h2 : Γ ⊢[fc] Formula.untl Formula.top Formula.bot := eventMono Γ _ _ _ hcontra h1
  exact ctxMp (thmIn (untlBotFalse Formula.top)) h2

/-- `F(Hψ) → ψ`: TC at `¬ψ` contraposed, with double-negation elimination at both ends. -/
def fHImp {fc : FrameClass} (ψ : Formula) : ⊢[fc] ψ.allPast.someFuture.imp ψ :=
  let connect : ⊢[fc] ψ.neg.imp ψ.neg.somePast.allFuture := connectFuture ψ.neg
  let contra : ⊢[fc] ψ.neg.somePast.allFuture.neg.imp ψ.neg.neg :=
    mp connect (contraposeImp ψ.neg ψ.neg.somePast.allFuture)
  impTrans (notNotIntro ψ.allPast.someFuture)
    (impTrans (show ⊢[fc] ψ.allPast.someFuture.neg.neg.imp ψ.neg.neg from contra)
      (doubleNegation ψ))

/-- NP: `X⊤ → Y⊤`, i.e. `U(⊤,⊥) → S(⊤,⊥)` (spelled `untl ⊥ (⊥→⊥)` and `snce ⊥ (⊥→⊥)` exactly
as the former constructor did). US at `(⊥, ⊤, ⊤)` enriches `⊤ ∧ X⊤` to `U(⊥, ⊤ ∧ Y⊤)`; the
event is lifted to `H Y⊤` by TR of NF, UE gives `F H Y⊤`, and `fHImp` yields `Y⊤`. -/
@[tmLemma]
def discreteSymmFwd {fc : FrameClass} :
    ⊢[fc] (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).imp
      (Formula.snce Formula.bot (Formula.bot.imp Formula.bot)) :=
  let X : Formula := Formula.untl Formula.bot (Formula.bot.imp Formula.bot)
  let Y : Formula := Formula.snce Formula.bot (Formula.bot.imp Formula.bot)
  let hUS : ⊢[fc] (Formula.and Formula.top X).imp
      (Formula.untl Formula.bot (Formula.and Formula.top (Formula.snce Formula.bot Formula.top))) :=
    DerivationTree.axiom [] _ (Axiom.enrichment_until Formula.bot Formula.top Formula.top)
      (FrameClass.base_le fc)
  let hpair : ⊢[fc] X.imp (Formula.and Formula.top X) := mp topThm (pairing Formula.top X)
  let h1 : ⊢[fc] X.imp (Formula.untl Formula.bot Y) :=
    impTrans (impTrans hpair hUS) (eventMonoThm _ _ _ (rceImp Formula.top Y))
  let h2 : ⊢[fc] (Formula.untl Formula.bot Y).imp (Formula.untl Formula.bot Y.allPast) :=
    eventMonoThm _ _ _ discretePropagateFwdMirror
  impTrans h1 (impTrans h2 (impTrans (untilF Formula.bot Y.allPast) (fHImp Y)))

/-- NA: `X⊤ → H X⊤`. This is the paper's NA itself, not the TR mirror of NF (that is
`DerivedAxioms.discretePropagateFwdMirror`, `Y⊤ → H Y⊤`). Compose NP, TR(NF), and
`H(Y⊤ → X⊤)` — TR of TN applied to NP — distributed by `pastKDist`. -/
@[tmLemma]
def discretePropagateBwd {fc : FrameClass} :
    ⊢[fc] (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).imp
      (Formula.allPast (Formula.untl Formula.bot (Formula.bot.imp Formula.bot))) :=
  let X : Formula := Formula.untl Formula.bot (Formula.bot.imp Formula.bot)
  let Y : Formula := Formula.snce Formula.bot (Formula.bot.imp Formula.bot)
  let hHYX : ⊢[fc] (Y.imp X).allPast :=
    ofReflect (DerivationTree.temporal_necessitation _ discreteSymmFwd) rfl
  impTrans discreteSymmFwd (impTrans discretePropagateFwdMirror (mp hHYX (pastKDist Y X)))

end

end FormalSystem.Theorems.ConnectDerived
