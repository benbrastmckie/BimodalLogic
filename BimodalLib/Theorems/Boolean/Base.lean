/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Theorems.Combinators
import FormalSystem.Theorems.ConnectDerived
import FormalSystem.Theorems.LinearityDerived
import FormalSystem.Theorems.ModalDerived
import FormalSystem.Theorems.ModalS5
import FormalSystem.Theorems.Propositional.Connectives
import FormalSystem.Theorems.Propositional.Core
import FormalSystem.Theorems.Propositional.Reasoning
import FormalSystem.Theorems.TemporalDerived
import BimodalLib.Registry

/-!
# Registered theorems: `Boolean` at `Base`

The closed derivations under `FormalSystem/Theorems/` whose statement has
no modal or temporal operator, derivable at every frame class.

Each line registers one declaration by reference; the row is built from the type of the
declaration, and the fragment and frame class it is filed under here are the ones the row
computes. Lines are grouped by the module that declares the derivation.
-/

-- Declared in `FormalSystem.Theorems.Combinators`.
register_theorem FormalSystem.ProofSystem.DerivedAxioms.contraSwap
register_theorem FormalSystem.ProofSystem.DerivedAxioms.orAssocRev
register_theorem FormalSystem.ProofSystem.DerivedAxioms.orRotate
register_theorem FormalSystem.Theorems.Combinators.bCombinator
register_theorem FormalSystem.Theorems.Combinators.identity
register_theorem FormalSystem.Theorems.Combinators.notNotIntro
register_theorem FormalSystem.Theorems.Combinators.pairing
register_theorem FormalSystem.Theorems.Combinators.theoremApp1
register_theorem FormalSystem.Theorems.Combinators.theoremApp2
register_theorem FormalSystem.Theorems.Combinators.theoremFlip
register_theorem FormalSystem.Theorems.Combinators.topThm

-- Declared in `FormalSystem.Theorems.ConnectDerived`.
register_theorem FormalSystem.Theorems.ConnectDerived.lceImpThm
register_theorem FormalSystem.Theorems.ConnectDerived.rceImpThm

-- Declared in `FormalSystem.Theorems.LinearityDerived`.
register_theorem FormalSystem.Theorems.LinearityDerived.claviusThm
register_theorem FormalSystem.Theorems.LinearityDerived.orInlThm
register_theorem FormalSystem.Theorems.LinearityDerived.orInrThm

-- Declared in `FormalSystem.Theorems.ModalDerived`.
register_theorem FormalSystem.Theorems.ModalDerived.dneTheorem

-- Declared in `FormalSystem.Theorems.ModalS5`.
register_theorem FormalSystem.Theorems.ModalS5.classicalMerge

-- Declared in `FormalSystem.Theorems.Propositional.Connectives`.
register_theorem FormalSystem.Theorems.Propositional.classicalMerge
register_theorem FormalSystem.Theorems.Propositional.contraposeImp
register_theorem FormalSystem.Theorems.Propositional.demorganConjNeg
register_theorem FormalSystem.Theorems.Propositional.demorganConjNegBackward
register_theorem FormalSystem.Theorems.Propositional.demorganConjNegForward
register_theorem FormalSystem.Theorems.Propositional.demorganDisjNeg
register_theorem FormalSystem.Theorems.Propositional.demorganDisjNegBackward
register_theorem FormalSystem.Theorems.Propositional.demorganDisjNegForward

-- Declared in `FormalSystem.Theorems.Propositional.Core`.
register_theorem FormalSystem.Theorems.Propositional.doubleNegation
register_theorem FormalSystem.Theorems.Propositional.efqAxiom
register_theorem FormalSystem.Theorems.Propositional.em
register_theorem FormalSystem.Theorems.Propositional.impNegImp
register_theorem FormalSystem.Theorems.Propositional.impOfNeg
register_theorem FormalSystem.Theorems.Propositional.lceImp
register_theorem FormalSystem.Theorems.Propositional.negImp
register_theorem FormalSystem.Theorems.Propositional.peirceAxiom
register_theorem FormalSystem.Theorems.Propositional.rceImp
register_theorem FormalSystem.Theorems.Propositional.topNegImpBot

-- Declared in `FormalSystem.Theorems.Propositional.Reasoning`.
register_theorem FormalSystem.Theorems.Propositional.biImp

-- Declared in `FormalSystem.Theorems.TemporalDerived`.
register_theorem FormalSystem.Theorems.TemporalDerived.contrapositive
register_theorem FormalSystem.Theorems.TemporalDerived.formulaOrComm
