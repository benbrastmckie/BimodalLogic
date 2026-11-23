/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Automation.ProofMode
import FormalSystem.Theorems.LinearityDerived

/-! # Temporal rewriting and frame premises -/

open FormalSystem.Syntax FormalSystem.ProofSystem
open FormalSystem.Theorems.LinearityDerived

namespace BimodalTest.Automation.ProofModeTemporalBooleanTest

variable {fc : FrameClass} (Γ : Context) (A B C : Formula)

-- Concrete frame gates are checked, not exposed as impossible obligations or silently assumed.
example (base : Γ ⊢ A.allFuture.allFuture)
    (dense : Γ ⊢[FrameClass.Dense] A.allFuture.allFuture) :
    (Γ ⊢ A.allFuture.allFuture) × (Γ ⊢[FrameClass.Dense] A.allFuture) := by
  constructor
  · fail_if_success lrewrite density at base as collapsed (obligations := expose)
    lexact base
  · lrewrite density at dense as collapsed
    lexact collapsed

private def implicitDensityRule {gate : FrameClass.Dense ≤ fc} (P : Formula) :
    ⊢[fc] P.allFuture.allFuture.imp P.allFuture :=
  density gate P

-- Leading implicit premises inserted by term elaboration are genuine, atomic obligations.
example (frameProvider : True → FrameClass.Dense ≤ fc)
    (provider : Γ ⊢[fc] A.allFuture.allFuture) : Γ ⊢[fc] A.allFuture := by
  fail_if_success lrewrite implicitDensityRule at provider as untracked
  fail_if_success lsimp only [implicitDensityRule] at provider as untracked
  lrewrite implicitDensityRule at provider as mapped (obligations := expose)
  · exact frameProvider True.intro
  · lexact mapped

-- Boolean reduction and strict FFA→FA are independent, genuinely one-way proof steps.
example (provider : Γ ⊢ A.neg.neg.someFuture.someFuture) : Γ ⊢ A.someFuture := by
  lsimp only [FormalSystem.Theorems.ProofMode.doubleNegationIff,
    FormalSystem.Theorems.ProofMode.futureCollapse] at provider as reduced
  lexact reduced

-- Occurrence selection precedes scope discharge: an inaccessible match is still ambiguous.
example (mapping : Γ ⊢ (A.imp B).allFuture) (provider : Γ ⊢ A.and A.allFuture) :
    Γ ⊢ A.and B.allFuture := by
  fail_if_success lrewrite mapping at provider as implicitChoice
  lrewrite mapping (path := [andRight, futureBody]) at provider as mapped
  lexact mapped

-- Past scope transport works through Previous and through the guard of Since.
example (mapping : Γ ⊢ (A.imp B).allPast) (previous : Γ ⊢ A.prev)
    (since : Γ ⊢ Formula.snce A C) : (Γ ⊢ B.prev) × (Γ ⊢ Formula.snce B C) := by
  constructor
  · lrewrite mapping (path := [prevBody]) at previous as mapped
    lexact mapped
  · lrewrite mapping (path := [sinceGuard]) at since as mapped
    lexact mapped

end BimodalTest.Automation.ProofModeTemporalBooleanTest
