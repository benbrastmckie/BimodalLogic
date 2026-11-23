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
import BimodalLib.Registry.Complete

/-!
# The registry is complete

This module runs the registration check over the published library. It imports the root
`FormalSystem`, so that every module under `FormalSystem/Theorems/` is in scope, and every
registration module. It fails to build when a closed derivation declared under
`FormalSystem/Theorems/`, outside its `ProofMode/` directory, has no `register_theorem` line.
-/

assert_registry_complete
