/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ProofSystem.DerivedAxioms
import BimodalLib.Registry

/-!
# Fixture: one registered theorem whose proof leaves the cell of its statement

The proof-fragment check is aimed at this module by `BimodalLibTest.ProofFragmentTest`, which
expects it to fail here. The module declares and registers one closed derivation: a statement
in Until alone whose derivation passes through `□`. No reason is recorded for it except by that
test, after it has seen the failure.
-/

namespace BimodalLibTest.Fixtures

open FormalSystem.Syntax FormalSystem.ProofSystem

/-- `X⊤ → G X⊤`, a temporal statement derived through `□`. -/
def nextThroughBox {fc : FrameClass} :
    ⊢[fc] (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).imp
      (Formula.allFuture (Formula.untl Formula.bot (Formula.bot.imp Formula.bot))) :=
  DerivedAxioms.discretePropagateFwd

end BimodalLibTest.Fixtures

register_theorem BimodalLibTest.Fixtures.nextThroughBox
