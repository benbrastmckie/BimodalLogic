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

* `connectFuture` — TC, `φ → G P φ`. From `φ ∧ U(⊤, ¬Pφ)`, US enriches the Until to
  `U(⊤, ¬Pφ ∧ S(⊤, φ))`, whose event is contradictory, so UC drives it to `U(⊤, ⊥)`, refuted by
  `untlBotFalseThm`; currying the conjunction gives `φ → ¬U(⊤, ¬Pφ) = φ → G P φ`.
* `fHImp` — `F H ψ → ψ`, the contrapositive of TC at `¬ψ`; the direct re-proof of
  `DedekindDerived.someFutureAllPastImp`.
* `discreteSymmFwd` — NP, `X⊤ → Y⊤` (`X⊤ = U(⊤,⊥)`, `Y⊤ = S(⊤,⊥)`). US at `(⊥, ⊤, ⊤)` turns
  `X⊤` into `U(⊥, Y⊤)`; TR of NF (`DerivedAxioms.discretePropagateFwdMirror`) lifts the event to
  `H Y⊤`; UE (`DerivedAxioms.untilF`) gives `F H Y⊤`, and `fHImp` lands on `Y⊤`.
* `discretePropagateBwd` — NA, `X⊤ → H X⊤`, as NP ; TR(NF) ; `H Y⊤ → H X⊤`, the last by
  H-monotonicity (`gMonoThm` reflected) applied to NP.

The TR mirrors `connectPast`, `connectPastAt`, `discreteSymmBwd` and `discreteSymmBwdAt` live
here as well, reflecting `connectFuture` and `discreteSymmFwd`.

## Computability

Every definition in this module is **computable**: the runtime proof search
(`Automation/ProofSearch/Core.lean`, evaluated by `#guard`) and the dataset tooling
(`BimodalTools/ProofExtractorMain.lean`) build and traverse these derivation trees at runtime,
so the proofs are written as explicit combinator terms over `prop_k`/`prop_s` (`bCombinator`,
`theoremFlip`, `pairing`, `notNotIntro`, `doubleNegation`, `contraposeImp`) rather than through
the noncomputable deduction theorem. The small propositional stock this needs beyond
`Combinators` — `compLeft`, `compRight`, `curryThm`, `lceImpThm`, `rceImpThm`, `untlBotFalseThm`,
`gMonoThm` — is exported for `Theorems/LinearityDerived.lean`.
-/

namespace FormalSystem.Theorems.ConnectDerived

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.ProofSystem.DerivedAxioms (untilF eventMonoThm discretePropagateFwdMirror
  ofReflect lift)
open FormalSystem.Theorems.Combinators
open FormalSystem.Theorems.Propositional

/-! ## Computable propositional helpers -/

/-- Composition on the left: from `⊢ B → C` derive `⊢ (A → B) → (A → C)`. -/
def compLeft {fc : FrameClass} {A B C : Formula} (h : ⊢[fc] B.imp C) :
    ⊢[fc] (A.imp B).imp (A.imp C) :=
  mp h (bCombinator (A := A) (B := B) (C := C))

/-- Composition on the right: from `⊢ A → B` derive `⊢ (B → C) → (A → C)`. -/
def compRight {fc : FrameClass} {A B C : Formula} (h : ⊢[fc] A.imp B) :
    ⊢[fc] (B.imp C).imp (A.imp C) :=
  mp h (mp (bCombinator (A := A) (B := B) (C := C))
    (theoremFlip (A := B.imp C) (B := A.imp B) (C := A.imp C)))

/-- Currying: from `⊢ (A ∧ B) → C` derive `⊢ A → (B → C)`. -/
def curryThm {fc : FrameClass} {A B C : Formula} (h : ⊢[fc] (A.and B).imp C) :
    ⊢[fc] A.imp (B.imp C) :=
  impTrans (pairing A B) (compLeft h)

/-- `(A ∧ B) → B`, computable: `A ∧ B` is `¬(A → ¬B)` and `¬B → (A → ¬B)` is K, so
contraposition gives `¬¬B`, then DNE. -/
def rceImpThm {fc : FrameClass} (A B : Formula) : ⊢[fc] (A.and B).imp B :=
  impTrans
    (compRight (C := Formula.bot)
      (DerivationTree.axiom [] _ (Axiom.prop_s B.neg A) (FrameClass.base_le fc)))
    (doubleNegation B)

/-- `(A ∧ B) → A`, computable: `¬A → (A → ¬B)` by EFQ under the binder, then as above. -/
def lceImpThm {fc : FrameClass} (A B : Formula) : ⊢[fc] (A.and B).imp A :=
  impTrans
    (compRight (C := Formula.bot)
      (show ⊢[fc] A.neg.imp (A.imp B.neg) from compLeft (efqAxiom B.neg)))
    (doubleNegation A)

/-- `U(X, ⊥) → ⊥` as a computable theorem: UE to `F⊥`, UC to `F¬¬⊥`, and TN of `¬⊥`, whose
`G` unfolds to exactly `¬F¬¬⊥`. -/
def untlBotFalseThm {fc : FrameClass} (X : Formula) :
    ⊢[fc] (Formula.untl X Formula.bot).imp Formula.bot :=
  impTrans (untilF X Formula.bot)
    (impTrans (eventMonoThm Formula.bot Formula.bot.neg.neg Formula.top (efqAxiom _))
      (show ⊢[fc] (Formula.untl Formula.top Formula.bot.neg.neg).imp Formula.bot from
        DerivationTree.temporal_necessitation _ (efqAxiom Formula.bot)))

/-- G-monotonicity at theorem level, computable: from `⊢ X → Y` derive `⊢ GX → GY`, as the
contrapositive of UC on `¬Y → ¬X`. -/
def gMonoThm {fc : FrameClass} {X Y : Formula} (h : ⊢[fc] X.imp Y) :
    ⊢[fc] X.allFuture.imp Y.allFuture :=
  mp (eventMonoThm Y.neg X.neg Formula.top (mp h (contraposeImp X Y)))
    (contraposeImp (Formula.untl Formula.top Y.neg) (Formula.untl Formula.top X.neg))

/-! ## TC, `F H ψ → ψ`, NP, NA -/

/-- TC: `φ → G(P φ)`. From `φ ∧ U(⊤, ¬Pφ)`, US gives `U(⊤, ¬Pφ ∧ S(⊤, φ))`; the event refutes
itself, so the Until collapses to `U(⊤, ⊥)` and `untlBotFalseThm` closes it; currying yields
`φ → ¬U(⊤, ¬Pφ)`, which is `φ → G P φ` by definition. -/
@[tmLemma]
def connectFuture {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.imp φ.somePast.allFuture :=
  let U : Formula := Formula.untl Formula.top φ.somePast.neg
  let hUS : ⊢[fc] (Formula.and φ U).imp
      (Formula.untl Formula.top (Formula.and φ.somePast.neg (Formula.snce Formula.top φ))) :=
    DerivationTree.axiom [] _ (Axiom.enrichment_until Formula.top φ.somePast.neg φ)
      (FrameClass.base_le fc)
  let hcontra : ⊢[fc] (Formula.and φ.somePast.neg (Formula.snce Formula.top φ)).imp
      Formula.bot :=
    mp (identity φ.somePast.neg) (notNotIntro (φ.somePast.neg.imp φ.somePast.neg))
  let h1 : ⊢[fc] (Formula.and φ U).imp (Formula.untl Formula.top Formula.bot) :=
    impTrans hUS (eventMonoThm _ _ _ hcontra)
  let h2 : ⊢[fc] (Formula.and φ U).imp Formula.bot := impTrans h1 (untlBotFalseThm Formula.top)
  curryThm h2

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
    impTrans (impTrans hpair hUS) (eventMonoThm _ _ _ (rceImpThm Formula.top Y))
  let h2 : ⊢[fc] (Formula.untl Formula.bot Y).imp (Formula.untl Formula.bot Y.allPast) :=
    eventMonoThm _ _ _ discretePropagateFwdMirror
  impTrans h1 (impTrans h2 (impTrans (untilF Formula.bot Y.allPast) (fHImp Y)))

/-- NA: `X⊤ → H X⊤`. This is the paper's NA itself, not the TR mirror of NF (that is
`DerivedAxioms.discretePropagateFwdMirror`, `Y⊤ → H Y⊤`). Compose NP, TR(NF), and
`H Y⊤ → H X⊤`, which is the time reflection of `G X⊤ → G Y⊤` (G-monotonicity on NP). -/
@[tmLemma]
def discretePropagateBwd {fc : FrameClass} :
    ⊢[fc] (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).imp
      (Formula.allPast (Formula.untl Formula.bot (Formula.bot.imp Formula.bot))) :=
  let X : Formula := Formula.untl Formula.bot (Formula.bot.imp Formula.bot)
  let Y : Formula := Formula.snce Formula.bot (Formula.bot.imp Formula.bot)
  let hYX : ⊢[fc] Y.allPast.imp X.allPast := ofReflect (gMonoThm discreteSymmFwd) rfl
  impTrans discreteSymmFwd (impTrans discretePropagateFwdMirror hYX)

/-! ## Time-reflection mirrors of TC and NP -/

/-- `φ → H(Fφ)`: TR of TC (`connectFuture`). -/
@[tmLemma]
def connectPast {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.imp (φ.someFuture.allPast) :=
  ofReflect (connectFuture φ.reflectTime)
    (by simp [Formula.reflectTime, Formula.allFuture, Formula.allPast, Formula.someFuture,
      Formula.somePast, Formula.neg, Formula.top, Formula.reflect_time_involution])

/-- `S(⊥,⊤) → U(⊥,⊤)`: TR of NP (`discreteSymmFwd`); the reflected formula is the statement on
the nose, so no transport is needed. -/
@[tmLemma]
def discreteSymmBwd {fc : FrameClass} :
    ⊢[fc] (Formula.snce Formula.bot (Formula.bot.imp Formula.bot)).imp
      (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)) :=
  DerivationTree.time_reflection _ discreteSymmFwd

/-- Context-lifted `connectPast`. -/
def connectPastAt {fc : FrameClass} (Γ : Context) (φ : Formula) :
    Γ ⊢[fc] φ.imp (φ.someFuture.allPast) :=
  lift Γ (connectPast φ)

/-- Context-lifted `discreteSymmBwd`. -/
def discreteSymmBwdAt {fc : FrameClass} (Γ : Context) :
    Γ ⊢[fc] (Formula.snce Formula.bot (Formula.bot.imp Formula.bot)).imp
      (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)) :=
  lift Γ discreteSymmBwd

end FormalSystem.Theorems.ConnectDerived
