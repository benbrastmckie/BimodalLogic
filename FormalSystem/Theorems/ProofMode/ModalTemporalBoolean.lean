/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Theorems.ProofMode.PlusRules
import FormalSystem.Theorems.Perpetuity.Helpers

/-! # Boxed guarantees in strict temporal scopes -/

namespace FormalSystem.PlusLanguage.ProofMode

open FormalSystem.Syntax FormalSystem.ProofSystem

variable {fc : FrameClass}

private def atom : Formula := .atom (Atom.mkFresh "" 0)

/-- A boxed guarantee is valid at every strictly future point. -/
def boxToFuture (A : PlusFormula) : PlusDerivationTree fc [] (A.box.imp A.allFuture) :=
  .ofTMSubst (fun _ => A) (FormalSystem.Theorems.Perpetuity.boxToFuture atom)

/-- A boxed guarantee is valid at every strictly past point. -/
def boxToPast (A : PlusFormula) : PlusDerivationTree fc [] (A.box.imp A.allPast) :=
  .ofTMSubst (fun _ => A) (FormalSystem.Theorems.Perpetuity.boxToPast atom)

end FormalSystem.PlusLanguage.ProofMode
