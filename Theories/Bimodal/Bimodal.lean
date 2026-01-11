-- Re-export all Bimodal library modules
import Bimodal.Syntax
import Bimodal.ProofSystem
import Bimodal.Semantics
import Bimodal.Metalogic
import Bimodal.Theorems
import Bimodal.Automation
import Bimodal.Examples

/-!
# Bimodal - TM Logic Library

This module aggregates all Bimodal library components, providing the foundation
for bimodal logic TM (Tense and Modality).

## Components

- `Bimodal.Syntax`: Formula types and proof contexts
- `Bimodal.ProofSystem`: TM axioms and derivation rules
- `Bimodal.Semantics`: Task frame semantics with world histories
- `Bimodal.Metalogic`: Soundness and completeness theorems
- `Bimodal.Theorems`: Perpetuity principles (P1-P6)
- `Bimodal.Automation`: Proof tactics and automation
- `Bimodal.Examples`: Pedagogical examples and proof strategies

## Usage

Import the entire library:
```lean
import Bimodal
```

Or import specific modules:
```lean
import Bimodal.Syntax.Formula
import Bimodal.ProofSystem.Axioms
```
-/

namespace Bimodal

/-- Core layer version string for tracking releases and compatibility. -/
def version : String := "0.1.0"

end Bimodal
