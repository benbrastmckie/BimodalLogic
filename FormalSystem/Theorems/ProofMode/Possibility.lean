/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Theorems.ProofMode.Basic
import FormalSystem.Theorems.ModalS5

/-!
# Contextual possibility consequence

Possibility consequence requires a boxed implication. A current-point implication does not
provide a guarantee at the possible alternative selected by the possibility premise.
-/

namespace FormalSystem.Theorems.ProofMode

open FormalSystem.Syntax FormalSystem.ProofSystem
open FormalSystem.Theorems.Combinators

/-- Map a possible assertion through a necessary implication using the derived modal K rule. -/
def diamondConsequence {fc : FrameClass} {Γ : Context} {A B : Formula}
    (hMap : Γ ⊢[fc] (A.imp B).box) (hA : Γ ⊢[fc] A.diamond) :
    Γ ⊢[fc] B.diamond :=
  ctxMp (ctxMp (thmIn (ModalS5.kDistDiamond A B)) hMap) hA

end FormalSystem.Theorems.ProofMode
