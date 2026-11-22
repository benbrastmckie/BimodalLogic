/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Automation.ProofMode

/-! # Rewriting across modal and temporal scopes -/

open FormalSystem.Syntax FormalSystem.ProofSystem

namespace BimodalTest.Automation.ProofModeModalTemporalBooleanTest

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

-- Current-point equivalence cannot enter a fresh world/time scope.
example (_localEq : Γ ⊢[fc] (A.imp B).and (B.imp A))
    (provider : Γ ⊢[fc] A.allFuture.box) : Γ ⊢[fc] A.allFuture.box := by
  fail_if_success lrewrite _localEq at provider as leaked
  lexact provider

-- Closed logical equivalences rewrite through conditional Next at Base without an existence gate.
example (provider : Γ ⊢ A.box.next.allFuture) : Γ ⊢ A.box.diamond.next.allFuture := by
  lrewrite (FormalSystem.Theorems.ModalS5.s5DiamondBox A)
  lexact provider

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

end BimodalTest.Automation.ProofModeModalTemporalBooleanTest
