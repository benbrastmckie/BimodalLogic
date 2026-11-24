/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem
import BimodalLib.Theorems.Boolean.Base
import BimodalLib.Theorems.ModalBoolean.Base
import BimodalLib.Theorems.ModalTemporalBoolean.Base
import BimodalLib.Theorems.TemporalBoolean.Base
import BimodalLib.Theorems.TemporalBoolean.Dense
import BimodalLib.Theorems.TemporalBoolean.RTime
import BimodalLib.Theorems.TemporalBoolean.ZTime
import BimodalLib.ProofFragment
import BimodalLib.Registry.Complete

/-!
# The registry is complete

This module runs the registration check over the published library. It imports the root
`FormalSystem`, so that every module under `FormalSystem/Theorems/` is in scope, and every
registration module. It fails to build when a closed derivation declared under
`FormalSystem/Theorems/`, outside its `ProofMode/` directory, has no `register_theorem` line.

It then runs the proof-fragment check: the module fails to build when a registered theorem whose
reference proof leaves the cell of its statement has neither a proved conservativity edge out of
that cell nor a reason recorded with `record_proof_fragment`.
-/

assert_registry_complete

assert_proof_fragments_recorded
