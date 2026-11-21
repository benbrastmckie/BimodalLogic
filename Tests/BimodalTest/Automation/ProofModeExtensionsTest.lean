/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Automation.ProofMode
import FormalSystem.Theorems.ModalS5
import FormalSystem.Theorems.LinearityDerived

/-!
# Compositional proof-mode extension examples

Examples of checked rewriting, scoped normalization, and named formula views.
-/

open FormalSystem.Syntax FormalSystem.ProofSystem
open FormalSystem.Theorems.LinearityDerived

namespace BimodalTest.Automation.ProofModeExtensionsTest

variable {fc : FrameClass} (Γ : Context) (A B C : Formula)

-- The same opaque scoped statement supports fact rewriting and backward goal reconstruction.
example (mapping : Γ ⊢[fc] (A.imp B).allFuture.box)
    (provider : Γ ⊢[fc] (A.or C).allFuture.box) :
    Γ ⊢[fc] ((B.or C).allFuture.box).and ((B.or C).allFuture.box) := by
  lsplit
  · lrewrite mapping at provider as mapped
    lexact mapped
  · fail_if_success lrewrite mapping
    lrewrite ← mapping
    lexact provider

-- Negative positions reverse implication direction. Explicit paths disambiguate repeated leaves.
example (mapping : Γ ⊢[fc] B.imp A) (provider : Γ ⊢[fc] A.imp C) : Γ ⊢[fc] B.imp C := by
  lrewrite ← mapping (path := [impLeft]) at provider as mapped
  lexact mapped

-- Current-point equivalence cannot enter a fresh world/time scope.
example (_localEq : Γ ⊢[fc] (A.imp B).and (B.imp A))
    (provider : Γ ⊢[fc] A.allFuture.box) : Γ ⊢[fc] A.allFuture.box := by
  fail_if_success lrewrite _localEq at provider as leaked
  lexact provider

-- Closed logical equivalences rewrite through conditional Next at Base without an existence gate.
example (provider : Γ ⊢ A.box.next.allFuture) : Γ ⊢ A.box.diamond.next.allFuture := by
  lrewrite (FormalSystem.Theorems.ModalS5.s5DiamondBox A)
  lexact provider

-- Scope replacement needs a real native proof and drops unused implicit premises of the old map.
example (_localMap : ∀ {_unavailable : False}, Γ ⊢[fc] A.imp B)
    (hScoped : Γ ⊢[fc] (A.imp B).box)
    (provider : Γ ⊢[fc] A.box) : Γ ⊢[fc] B.box := by
  lrewrite _localMap at provider as mapped (obligations := expose)
  · guard_target =ₛ Γ ⊢[fc] (A.imp B).box
    lexact hScoped
  · guard_hyp mapped :ₛ Γ ⊢[fc] B.box
    lexact mapped

-- Named views change formula data at a goal or local hypothesis.
example (provider : Γ ⊢[fc] A.neg.box.neg) : Γ ⊢[fc] A.diamond := by
  lfold diamond at provider
  guard_hyp provider :ₛ Γ ⊢[fc] A.diamond
  lunfold diamond
  guard_target =ₛ Γ ⊢[fc] A.neg.box.neg
  exact provider

-- The exact same planner composes TM transfers and native stability at arbitrary Plus arguments.
example (Δ : FormalSystem.PlusLanguage.PlusContext)
    (P Q R : FormalSystem.PlusLanguage.PlusFormula)
    (mapping : FormalSystem.PlusLanguage.PlusDerivationTree fc Δ
      ((P.imp Q).allFuture.stab.box))
    (provider : FormalSystem.PlusLanguage.PlusDerivationTree fc Δ
      ((P.or R).allFuture.stab.box)) :
    FormalSystem.PlusLanguage.PlusDerivationTree fc Δ ((Q.or R).allFuture.stab.box) := by
  lrewrite mapping at provider as mapped
  lexact mapped

-- Simp reduces closed modal equivalences, skips growing orientations, and restores on exhaustion.
example (provider : Γ ⊢ A.box.next.allFuture) (boxes : Γ ⊢ (A.and B).box) :
    Γ ⊢ (A.box.and B.box).and A.box.diamond.next.allFuture := by
  lsplit
  · fail_if_success lsimp only [← FormalSystem.Theorems.ModalS5.boxConjIff]
    lsimp only [FormalSystem.Theorems.ModalS5.boxConjIff]
    lexact boxes
  · fail_if_success lsimp only [FormalSystem.Theorems.ModalS5.s5DiamondBox] (maxSteps := 0)
    lsimp only [FormalSystem.Theorems.ModalS5.s5DiamondBox]
    fail_if_success lsimp only [← FormalSystem.Theorems.ModalS5.s5DiamondBox]
    lexact provider

-- Concrete frame gates are checked, not exposed as impossible obligations or silently assumed.
example (base : Γ ⊢ A.allFuture.allFuture)
    (dense : Γ ⊢[FrameClass.Dense] A.allFuture.allFuture) :
    (Γ ⊢ A.allFuture.allFuture) × (Γ ⊢[FrameClass.Dense] A.allFuture) := by
  constructor
  · fail_if_success lrewrite density at base as collapsed (obligations := expose)
    lexact base
  · lrewrite density at dense as collapsed
    lexact collapsed

private def weakeningSchema (X Y : Formula) : ⊢[fc] X.imp (Y.imp X) :=
  .axiom [] _ (.prop_s X Y) (FrameClass.base_le fc)

private def implicitDensityRule {gate : FrameClass.Dense ≤ fc} (P : Formula) :
    ⊢[fc] P.allFuture.allFuture.imp P.allFuture :=
  density gate P

-- An unmatched data parameter is never guessed from the first Formula local in scope.
example (provider : Γ ⊢[fc] A) : Γ ⊢[fc] A := by
  fail_if_success lrewrite weakeningSchema at provider as guessed
  fail_if_success lrewrite weakeningSchema at provider as guessed (obligations := expose)
  lexact provider

-- Leading implicit premises inserted by term elaboration are genuine, atomic obligations.
example (frameProvider : True → FrameClass.Dense ≤ fc)
    (provider : Γ ⊢[fc] A.allFuture.allFuture) : Γ ⊢[fc] A.allFuture := by
  fail_if_success lrewrite implicitDensityRule at provider as untracked
  fail_if_success lsimp only [implicitDensityRule] at provider as untracked
  lrewrite implicitDensityRule at provider as mapped (obligations := expose)
  · exact frameProvider True.intro
  · lexact mapped

-- Run the fragile scope adapters and exact conditional Next in one compact product fixture.
example (boxMap : Γ ⊢ (A.imp B).box) (futureMap : Γ ⊢ (A.imp B).allFuture)
    (nextMap : Γ ⊢ (A.imp B).next) (future : Γ ⊢ A.allFuture)
    (futureFuture : Γ ⊢ A.allFuture.allFuture) (adjacent : Γ ⊢ A.next) :
    (Γ ⊢ B.allFuture) × (Γ ⊢ B.allFuture.allFuture) × (Γ ⊢ B.next) := by
  constructor
  · lrewrite boxMap at future as mapped
    lexact mapped
  constructor
  · lrewrite futureMap at futureFuture as mapped
    lexact mapped
  · lrewrite nextMap at adjacent as mapped
    lexact mapped

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

-- Backward goal rewriting exactly replays the closed boxDne derivation.
example (h : ⊢[fc] A.neg.neg.box) : ⊢[fc] A.box := by
  lrewrite ← (FormalSystem.Theorems.Propositional.doubleNegation (fc := fc) A)
    (path := [boxBody])
  lexact h

example (Δ : FormalSystem.PlusLanguage.PlusContext) (P : FormalSystem.PlusLanguage.PlusFormula)
    (provider : FormalSystem.PlusLanguage.PlusDerivationTree fc Δ P.neg.neg.stab) :
    FormalSystem.PlusLanguage.PlusDerivationTree fc Δ P.stab := by
  lsimp only [FormalSystem.PlusLanguage.ProofMode.doubleNegationIff] at provider as reduced
  lexact reduced

/-- error: Unknown identifier `missingRewriteRule` -/
#guard_msgs in
example : Γ ⊢[fc] A := by
  lsimp only [missingRewriteRule]

/-- error: formula equalities belong to named views (lunfold or lfold) -/
#guard_msgs in
example (equality : A = B) : Γ ⊢[fc] A := by
  lrewrite equality

/-- error: rewrite would leave the formula unchanged -/
#guard_msgs in
example (mapping : Γ ⊢[fc] A.imp A) : Γ ⊢[fc] A := by
  lrewrite mapping

/-- error: lsimp budget exhausted: matches 1/0, scope positions 0/4096 -/
#guard_msgs in
example : Γ ⊢[fc] A.neg.neg := by
  lsimp only [FormalSystem.Theorems.ProofMode.doubleNegationIff] (maxAttempts := 0)

end BimodalTest.Automation.ProofModeExtensionsTest
