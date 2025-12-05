-- Re-export all Core layer modules
import Logos.Core.Syntax
import Logos.Core.ProofSystem
import Logos.Core.Semantics
import Logos.Core.Metalogic
import Logos.Core.Theorems
import Logos.Core.Automation

/-!
# Logos.Core - Layer 0 (Core TM)

This module aggregates all Core Layer (Layer 0) components, providing the foundation
of the Logos system with bimodal logic TM (Tense and Modality).

## Core Layer Components

- `Logos.Core.Syntax`: Formula types and proof contexts
- `Logos.Core.ProofSystem`: TM axioms and derivation rules
- `Logos.Core.Semantics`: Task frame semantics with world histories
- `Logos.Core.Metalogic`: Soundness and completeness theorems
- `Logos.Core.Theorems`: Perpetuity principles (P1-P6)
- `Logos.Core.Automation`: Proof tactics and automation

## Usage

Import the entire Core layer:
```lean
import Logos.Core
```

Or import specific modules:
```lean
import Logos.Core.Syntax.Formula
import Logos.Core.ProofSystem.Axioms
```
-/

namespace Logos.Core

-- Core layer version
def version : String := "0.1.0"

end Logos.Core
