/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Automation.ProofMode

/-! # Strict leads-to composition -/

open FormalSystem.Syntax FormalSystem.ProofSystem

namespace BimodalTest.Automation.ProofModeTemporalBooleanProgressTest

variable {fc : FrameClass} (Γ : Context) (A B C : Formula)

-- Consequence and finite cases compose persistent leads-to guarantees.
example : [(A.imp C.someFuture).allFuture, (B.imp C.someFuture).allFuture] ⊢
    ((A.or B).imp C.someFuture).allFuture := by
  lstart hA hB
  lprogress cases
  · lexact hA
  · lexact hB

end BimodalTest.Automation.ProofModeTemporalBooleanProgressTest
