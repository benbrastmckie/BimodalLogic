/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Theorems.LinearityDerived
import BimodalLib.Registry

/-!
# Registered theorems: `TemporalBoolean` at `Dense`

The closed derivations under `FormalSystem/Theorems/` whose statement has
a temporal operator and no modal one, stated at the dense class.

Each line registers one declaration by reference; the row is built from the type of the
declaration, and the fragment and frame class it is filed under here are the ones the row
computes. Lines are grouped by the module that declares the derivation.
-/

-- Declared in `FormalSystem.Theorems.LinearityDerived`.
register_theorem FormalSystem.Theorems.LinearityDerived.density
