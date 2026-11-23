/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Automation.ProofMode

/-! # Modal simplification and named formula views -/

open FormalSystem.Syntax FormalSystem.ProofSystem

namespace BimodalTest.Automation.ProofModeModalBooleanTest

variable {fc : FrameClass} (Γ : Context) (A B C : Formula)

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

end BimodalTest.Automation.ProofModeModalBooleanTest
