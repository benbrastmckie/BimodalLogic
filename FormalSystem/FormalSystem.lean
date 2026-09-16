/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

-- Re-export all Bimodal library modules
import FormalSystem.ForMathlib
import FormalSystem.Syntax
import FormalSystem.ProofSystem
import FormalSystem.Syntax.MinusLanguage
import FormalSystem.Syntax.PlusLanguage
import FormalSystem.Syntax.StarLanguage
import FormalSystem.Semantics
import FormalSystem.Semantics.MinusLanguage
import FormalSystem.Semantics.PlusLanguage
import FormalSystem.Semantics.StarLanguage
import FormalSystem.Metalogic
import FormalSystem.Theorems
import FormalSystem.Automation
import FormalSystem.Examples
import FormalSystem.MainResults

/-!
# Bimodal - TM Logic Library

This module aggregates all Bimodal library components, providing a complete
formalization of bimodal logic TM (Tense and Modality) combining S5 modal logic
with linear temporal logic.

## Components

- `FormalSystem.ForMathlib`: Mathlib-shaped extensions intended for upstreaming (currently the
  proper/maximal/prime-filter API of `Order.PFilter` and the bundled `Order.PrimeFilter`). Imports
  nothing from `FormalSystem.*`; the import direction is strictly `Mathlib → ForMathlib → FormalSystem`
- `FormalSystem.Syntax`: Formula type with 6 primitives (atom, bot, imp, box, allPast, allFuture)
  plus derived operators and context types
- `FormalSystem.ProofSystem`: Hilbert-style proof system with 45 axiom schemata
(base/dense/discrete)
and 7 inference rules
- `FormalSystem.MinusLanguage`: The tense-primitive base language L⁻ (`H`/`G` primitive) with
  TM's Hilbert system and the translation `tr : MinusFormula → Formula` into L, supporting the
  backward conservativity bridge in `Metalogic/Conservativity/Backward.lean`. Imports nothing from
  `Semantics/`
- `FormalSystem.StarLanguage`: The language L⋆ = L⁺ + the manuscript's time store/recall
  operators (`def:BLstar-semantics`), as a separate inductive `StarFormula` with the embedding
  `ofPlus : PlusFormula → StarFormula`. Semantic-only: `StarAxiom`/`StarDerivationTree`/`TM⋆` are
  reserved and unbuilt. Imports nothing from `Semantics/`
- `FormalSystem.Semantics`: Task frame semantics with convex histories, truth evaluation, and
validity
- `FormalSystem.Metalogic`: Soundness, three completeness routes, and the tableau decision
  procedure. By far the largest component; see `Metalogic/README.md` for the architecture map.
  The archive at `Boneyard/` is excluded from the Mathlib naming conventions the rest of this
  library follows: its identifiers predate the migration and were deliberately left untouched
  (it has no `.ilean` artifacts and no imports from active code, so a position-anchored rewrite
  structurally could not reach it). There is exactly one archive -- see
  `docs/architecture/ADR-005-Single-Boneyard.md` -- and `Boneyard/README.md` is the single source
  for its counts; read it before grepping the archive for identifier usage
- `FormalSystem.Theorems`: Derived theorems (Combinators, Propositional, ModalS5, ModalS4,
  Perpetuity, GeneralizedNecessitation, TemporalDerived, ContextualProofs)
- `FormalSystem.MainResults`: the headline metatheory on one page, each result followed
  by `#print axioms`
- `FormalSystem.Automation`: Proof tactics (modal_search), native proof search,
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
#check perpetuity1  -- □φ → △φ
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
* [Theorems.lean](Theorems.lean) - Derived theorems (6 modules)
* [Automation.lean](Automation.lean) - Proof tactics
* [Examples.lean](Examples.lean) - Pedagogical examples
-/

namespace FormalSystem

/-- Core layer version string for tracking releases and compatibility. -/
def version : String := "0.1.0"

end FormalSystem
