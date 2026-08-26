/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

-- Re-export all Bimodal library modules
import FormalSystem.Syntax
import FormalSystem.ProofSystem
import FormalSystem.BaseLanguage
import FormalSystem.Semantics
import FormalSystem.Metalogic
import FormalSystem.FrameConditions
import FormalSystem.Theorems
import FormalSystem.Automation
import FormalSystem.Examples

/-!
# Bimodal - TM Logic Library

This module aggregates all Bimodal library components, providing a complete
formalization of bimodal logic TM (Tense and Modality) combining S5 modal logic
with linear temporal logic.

## Components

- `FormalSystem.Syntax`: Formula type with 6 primitives (atom, bot, imp, box, allPast, allFuture)
  plus derived operators and context types
- `FormalSystem.ProofSystem`: Hilbert-style proof system with 45 axiom schemata
(base/dense/discrete)
and 7 inference rules
- `FormalSystem.BaseLanguage`: The tense-primitive base language BL (`H`/`G` primitive) with
  TM's Hilbert system and the translation `tr : BLFormula → Formula` into BL⁺, supporting the
  backward conservativity bridge in `Metalogic/Conservativity.lean`. Imports nothing from
  `Semantics/`
- `FormalSystem.Semantics`: Task frame semantics with world histories, truth evaluation, and
validity
- `FormalSystem.Metalogic`: Soundness, three completeness routes, and the tableau decision
  procedure. By far the largest component (210 live files); see `Metalogic/README.md` for
  the architecture map and the two-Boneyard counting caveat. Both Boneyard trees are excluded
  from the Mathlib naming conventions the rest of this library follows: their identifiers
  predate the migration and were deliberately left untouched (they have no `.ilean` artifacts
  and no imports from active code, so a position-anchored rewrite structurally could not reach
  them). See `Boneyard/README.md` before grepping either tree for identifier usage
- `FormalSystem.FrameConditions`: Typeclass-based frame condition architecture (4 modules)
  - `LinearTemporalFrame`, `SerialFrame`, `DenseTemporalFrame`, `DiscreteTemporalFrame`
  - Parameterized validity and soundness, plus axiom compatibility typeclasses
  - Sits strictly above `Metalogic`, which it consumes; see `FrameConditions/README.md`
- `FormalSystem.Theorems`: Derived theorems (Combinators, Propositional, ModalS5, ModalS4,
  Perpetuity, GeneralizedNecessitation, TemporalDerived, ContextualProofs)
- `FormalSystem.Automation`: Proof tactics (modal_search, temporal_search), native proof search,
  and the ML dataset-generation pipeline
- `FormalSystem.Examples`: Pedagogical examples and proof strategies

## Quick Start

```lean
import FormalSystem

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Automation

-- Define a formula
def myFormula : Formula := Formula.box (Formula.atomS "p")

-- Prove a theorem
example (p : String) : ⊢ (Formula.box (Formula.atom p)).imp (Formula.atom p) := by
  modal_search

-- Use perpetuity principles
open FormalSystem.Theorems.Perpetuity
#check perpetuity_1  -- □φ → △φ
```

## Usage

Import the entire library:
```lean
import FormalSystem
```

Or import specific modules:
```lean
import FormalSystem.Syntax.Formula
import FormalSystem.ProofSystem.Axioms
import FormalSystem.Theorems
```

## References

* [Syntax.lean](Syntax.lean) - Formula syntax
* [ProofSystem.lean](ProofSystem.lean) - Axioms and derivation
* [Semantics.lean](Semantics.lean) - Task frame semantics
* [Metalogic.lean](Metalogic.lean) - Soundness, completeness, decidability
* [FrameConditions.lean](FrameConditions.lean) - Typeclass-based frame conditions
* [Theorems.lean](Theorems.lean) - Derived theorems (6 modules)
* [Automation.lean](Automation.lean) - Proof tactics
* [Examples.lean](Examples.lean) - Pedagogical examples
-/

namespace FormalSystem

/-- Core layer version string for tracking releases and compatibility. -/
def version : String := "0.1.0"

end FormalSystem
