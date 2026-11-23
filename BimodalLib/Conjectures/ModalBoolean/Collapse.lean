/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.PlusLanguage.Derivation
import FormalSystem.PlusLanguage.PlusStateLocal
import BimodalLib.Conjecture

/-!
# Conjecture: the collapse of `⊡` is derivable

On a state-local formula `⊡` is the identity: `φ ↔ ⊡φ` is valid at every frame
(`plusStateLocal_stab_iff` in `FormalSystem/PlusLanguage/PlusStateLocal.lean`). The validity is
proved semantically. That the extended system derives it is registered here as a conjecture.
-/

namespace BimodalLib.Conjectures

open FormalSystem.ProofSystem FormalSystem.PlusLanguage

/-- The extended system derives `φ ↔ ⊡φ` for every state-local `φ`, at every frame class. -/
def stabCollapseDerivable : Conjecture where
  statement := ∀ (fc : FrameClass) (φ : PlusFormula), φ.StateLocal →
    Nonempty (PlusDerivationTree fc [] ((φ.imp φ.stab).and (φ.stab.imp φ)))
  fragment := .ModalBoolean
  ops := { stab := true }
  frameClass := none
  status := .unsettled
  note := "Valid at every frame by plusStateLocal_stab_iff, which is a semantic proof. The \
    derivation would go by induction on the state-local formula, from the axiom p → ⊡p for \
    atoms and the S5 laws of ⊡. Restricted to state-local instances: the extended system is \
    not closed under uniform substitution."

end BimodalLib.Conjectures
