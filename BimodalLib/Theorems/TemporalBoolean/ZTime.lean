/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Theorems.DiscreteUnfolding
import BimodalLib.Registry

/-!
# Registered theorems: `TemporalBoolean` at `ZTime`

The closed derivations under `FormalSystem/Theorems/` whose statement has
a temporal operator and no modal one, stated at the integer-time class.

Each line registers one declaration by reference; the row is built from the type of the
declaration, and the fragment and frame class it is filed under here are the ones the row
computes. Lines are grouped by the module that declares the derivation.
-/

-- Declared in `FormalSystem.Theorems.DiscreteUnfolding`.
register_theorem FormalSystem.Theorems.DiscreteUnfolding.dfSchema
register_theorem FormalSystem.Theorems.DiscreteUnfolding.nextAllFuture
register_theorem FormalSystem.Theorems.DiscreteUnfolding.noBlockingTriple
register_theorem FormalSystem.Theorems.DiscreteUnfolding.prevAllPast
register_theorem FormalSystem.Theorems.DiscreteUnfolding.prevIndicator
register_theorem FormalSystem.Theorems.DiscreteUnfolding.prevIndicatorAt
register_theorem FormalSystem.Theorems.DiscreteUnfolding.succIndicator
register_theorem FormalSystem.Theorems.DiscreteUnfolding.succIndicatorAt
register_theorem FormalSystem.Theorems.DiscreteUnfolding.unfoldBackwardSince
register_theorem FormalSystem.Theorems.DiscreteUnfolding.unfoldForward
register_theorem FormalSystem.Theorems.DiscreteUnfolding.unfoldTableForward
register_theorem FormalSystem.Theorems.DiscreteUnfolding.z1EventBot
register_theorem FormalSystem.Theorems.DiscreteUnfolding.z1Schema
register_theorem FormalSystem.Theorems.DiscreteUnfolding.z1SchemaAt
