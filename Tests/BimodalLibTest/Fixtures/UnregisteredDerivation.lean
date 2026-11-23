/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Theorems.Combinators

/-!
# Fixture: one closed derivation with no registry row

The registration check is aimed at this module by `BimodalLibTest.RegistryCheckTest`, which
expects it to fail here. The module declares one closed derivation and nothing else, and no
module registers it except that test, after it has seen the failure.
-/

namespace BimodalLibTest.Fixtures

open FormalSystem.Syntax FormalSystem.ProofSystem

/-- A closed derivation that no registration module names. -/
def unregisteredIdentity {fc : FrameClass} (φ : Formula) : ⊢[fc] φ.imp φ :=
  FormalSystem.Theorems.Combinators.identity φ

end BimodalLibTest.Fixtures
