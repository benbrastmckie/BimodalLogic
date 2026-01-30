-- Re-export all Bimodal library modules
import Bimodal.Syntax
import Bimodal.ProofSystem
import Bimodal.Semantics
import Bimodal.Metalogic.Metalogic
import Bimodal.Theorems
import Bimodal.Automation
import Bimodal.Examples

/-!
# Bimodal - TM Logic Library

This module aggregates all Bimodal library components, providing a complete
formalization of bimodal logic TM (Tense and Modality) combining S5 modal logic
with linear temporal logic.

## Components

- `Bimodal.Syntax`: Formula type with 6 primitives (atom, bot, imp, box, all_past, all_future)
  plus derived operators and context types
- `Bimodal.ProofSystem`: Hilbert-style proof system with 14 axiom schemata and 7 inference rules
- `Bimodal.Semantics`: Task frame semantics with world histories, truth evaluation, and validity
- `Bimodal.Metalogic`: Soundness theorem, completeness infrastructure, and tableau decision procedure
- `Bimodal.Theorems`: Derived theorems (6 modules: Combinators, Propositional, ModalS5, ModalS4,
  Perpetuity, GeneralizedNecessitation)
- `Bimodal.Automation`: Proof tactics (modal_search, temporal_search) and native proof search
- `Bimodal.Examples`: Pedagogical examples and proof strategies (7 modules)

## Quick Start

```lean
import Bimodal

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Automation

-- Define a formula
def my_formula : Formula := Formula.box (Formula.atom "p")

-- Prove a theorem
example (p : String) : ⊢ (Formula.box (Formula.atom p)).imp (Formula.atom p) := by
  modal_search

-- Use perpetuity principles
open Bimodal.Theorems.Perpetuity
#check perpetuity_1  -- □φ → △φ
```

## Usage

Import the entire library:
```lean
import Bimodal
```

Or import specific modules:
```lean
import Bimodal.Syntax.Formula
import Bimodal.ProofSystem.Axioms
import Bimodal.Theorems
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

namespace Bimodal

/-- Core layer version string for tracking releases and compatibility. -/
def version : String := "0.1.0"

end Bimodal
