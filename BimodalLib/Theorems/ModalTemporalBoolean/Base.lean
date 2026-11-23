/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Theorems.Combinators
import FormalSystem.Theorems.Interaction
import FormalSystem.Theorems.Perpetuity.Helpers
import FormalSystem.Theorems.Perpetuity.MonotonicityDuality
import FormalSystem.Theorems.Perpetuity.Principles
import BimodalLib.Registry

/-!
# Registered theorems: `ModalTemporalBoolean` at `Base`

The closed derivations under `FormalSystem/Theorems/` whose statement has
both a modal and a temporal operator, derivable at every frame class.

Each line registers one declaration by reference; the row is built from the type of the
declaration, and the fragment and frame class it is filed under here are the ones the row
computes. Lines are grouped by the module that declares the derivation.
-/

-- Declared in `FormalSystem.Theorems.Combinators`.
register_theorem FormalSystem.Theorems.Combinators.temporalFutureDerived

-- Declared in `FormalSystem.Theorems.Interaction`.
register_theorem FormalSystem.Theorems.Interaction.alwaysBoxIffBox
register_theorem FormalSystem.Theorems.Interaction.alwaysDiamondToDiamond
register_theorem FormalSystem.Theorems.Interaction.boxAlwaysIffAlwaysBox
register_theorem FormalSystem.Theorems.Interaction.boxAlwaysIffBox
register_theorem FormalSystem.Theorems.Interaction.boxToAlwaysBox
  (dual := FormalSystem.Theorems.Interaction.sometimesDiamondToDiamond)
register_theorem FormalSystem.Theorems.Interaction.diamondAlwaysToDiamond
register_theorem FormalSystem.Theorems.Interaction.diamondIffDiamondSometimes
register_theorem FormalSystem.Theorems.Interaction.diamondSometimesIffSometimesDiamond
register_theorem FormalSystem.Theorems.Interaction.diamondSometimesToSometimesDiamond
register_theorem FormalSystem.Theorems.Interaction.diamondToDiamondSometimes
register_theorem FormalSystem.Theorems.Interaction.sometimesBoxIffBox
register_theorem FormalSystem.Theorems.Interaction.sometimesDiamondToDiamond
  (dual := FormalSystem.Theorems.Interaction.boxToAlwaysBox)
register_theorem FormalSystem.Theorems.Interaction.sometimesDiamondToDiamondSometimes
register_theorem FormalSystem.Theorems.Interaction.temporalPastDerived

-- Declared in `FormalSystem.Theorems.Perpetuity.Helpers`.
register_theorem FormalSystem.Theorems.Perpetuity.boxToFuture
register_theorem FormalSystem.Theorems.Perpetuity.boxToPast

-- Declared in `FormalSystem.Theorems.Perpetuity.MonotonicityDuality`.
register_theorem FormalSystem.Theorems.Perpetuity.bridge1
register_theorem FormalSystem.Theorems.Perpetuity.bridge2
register_theorem FormalSystem.Theorems.Perpetuity.perpetuity6
  (dual := FormalSystem.Theorems.Perpetuity.perpetuity5)

-- Declared in `FormalSystem.Theorems.Perpetuity.Principles`.
register_theorem FormalSystem.Theorems.Perpetuity.boxDiamondToFutureBoxDiamond
register_theorem FormalSystem.Theorems.Perpetuity.boxDiamondToPastBoxDiamond
register_theorem FormalSystem.Theorems.Perpetuity.boxToBoxPast
register_theorem FormalSystem.Theorems.Perpetuity.perpetuity1
  (dual := FormalSystem.Theorems.Perpetuity.perpetuity2)
register_theorem FormalSystem.Theorems.Perpetuity.perpetuity2
  (dual := FormalSystem.Theorems.Perpetuity.perpetuity1)
register_theorem FormalSystem.Theorems.Perpetuity.perpetuity3
  (dual := FormalSystem.Theorems.Perpetuity.perpetuity4)
register_theorem FormalSystem.Theorems.Perpetuity.perpetuity4
  (dual := FormalSystem.Theorems.Perpetuity.perpetuity3)
register_theorem FormalSystem.Theorems.Perpetuity.perpetuity5
  (dual := FormalSystem.Theorems.Perpetuity.perpetuity6)
register_theorem FormalSystem.Theorems.Perpetuity.persistence
