/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Theorems.Combinators
import FormalSystem.Theorems.ModalDerived
import FormalSystem.Theorems.ModalS4
import FormalSystem.Theorems.ModalS5
import FormalSystem.Theorems.Perpetuity.Helpers
import FormalSystem.Theorems.Perpetuity.MonotonicityDuality
import FormalSystem.Theorems.Perpetuity.Principles
import BimodalLib.Registry

/-!
# Registered theorems: `ModalBoolean` at `Base`

The closed derivations under `FormalSystem/Theorems/` whose statement has
a modal operator and no temporal one, derivable at every frame class.

Each line registers one declaration by reference; the row is built from the type of the
declaration, and the fragment and frame class it is filed under here are the ones the row
computes. Lines are grouped by the module that declares the derivation.
-/

-- Declared in `FormalSystem.Theorems.Combinators`.
register_theorem FormalSystem.ProofSystem.DerivedAxioms.modal4
  (dual := FormalSystem.Theorems.Perpetuity.diamond4)
register_theorem FormalSystem.ProofSystem.DerivedAxioms.modalB
  (dual := FormalSystem.Theorems.ModalS5.s5DiamondBoxToTruth)

-- Declared in `FormalSystem.Theorems.ModalDerived`.
register_theorem FormalSystem.Theorems.ModalDerived.axiom5NegativeIntrospection
register_theorem FormalSystem.Theorems.ModalDerived.boxDneTheorem
register_theorem FormalSystem.Theorems.ModalDerived.modal5CollapseTheorem
  (dual := FormalSystem.Theorems.Perpetuity.modal5)
register_theorem FormalSystem.Theorems.ModalDerived.negBoxToBoxNegBox

-- Declared in `FormalSystem.Theorems.ModalS4`.
register_theorem FormalSystem.Theorems.ModalS4.s4BoxDiamondBox
register_theorem FormalSystem.Theorems.ModalS4.s4DiamondBoxConj
register_theorem FormalSystem.Theorems.ModalS4.s4DiamondBoxDiamond
register_theorem FormalSystem.Theorems.ModalS4.s5DiamondConjDiamond

-- Declared in `FormalSystem.Theorems.ModalS5`.
register_theorem FormalSystem.Theorems.ModalS5.boxConjIff
  (dual := FormalSystem.Theorems.ModalS5.diamondDisjIff)
register_theorem FormalSystem.Theorems.ModalS5.boxContrapose
register_theorem FormalSystem.Theorems.ModalS5.boxDisjIntro
register_theorem FormalSystem.Theorems.ModalS5.diamondDisjIff
  (dual := FormalSystem.Theorems.ModalS5.boxConjIff)
register_theorem FormalSystem.Theorems.ModalS5.kDistDiamond
register_theorem FormalSystem.Theorems.ModalS5.s5DiamondBox
register_theorem FormalSystem.Theorems.ModalS5.s5DiamondBoxToTruth
  (dual := FormalSystem.ProofSystem.DerivedAxioms.modalB)
register_theorem FormalSystem.Theorems.ModalS5.tBoxConsistency
register_theorem FormalSystem.Theorems.ModalS5.tBoxToDiamond

-- Declared in `FormalSystem.Theorems.Perpetuity.Helpers`.
register_theorem FormalSystem.Theorems.Perpetuity.boxToPresent

-- Declared in `FormalSystem.Theorems.Perpetuity.MonotonicityDuality`.
register_theorem FormalSystem.Theorems.Perpetuity.modalDualityNeg
register_theorem FormalSystem.Theorems.Perpetuity.modalDualityNegRev

-- Declared in `FormalSystem.Theorems.Perpetuity.Principles`.
register_theorem FormalSystem.Theorems.Perpetuity.diamond4
  (dual := FormalSystem.ProofSystem.DerivedAxioms.modal4)
register_theorem FormalSystem.Theorems.Perpetuity.mbDiamond
  (dual := FormalSystem.Theorems.ModalS5.s5DiamondBoxToTruth)
register_theorem FormalSystem.Theorems.Perpetuity.modal5
  (dual := FormalSystem.Theorems.ModalDerived.modal5CollapseTheorem)
