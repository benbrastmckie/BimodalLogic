/-!
# Logos Core Layer

This module re-exports all components of the Logos Core layer, which implements
the foundational Layer 0 (Core TM) of the Logos bimodal logic system.

## Core Layer Components

The Core layer provides:
- **Syntax**: Formula types and context structures
- **ProofSystem**: Axioms and derivability relation
- **Semantics**: Task frames, world histories, and truth evaluation
- **Metalogic**: Soundness and completeness theorems
- **Theorems**: Perpetuity principles and derived theorems
- **Automation**: Proof tactics and automated reasoning

## Usage

Import the entire Core layer:
```lean
import Logos.Core
```

Or import specific submodules:
```lean
import Logos.Core.Syntax.Formula
import Logos.Core.ProofSystem.Derivation
```

## References

* [ARCHITECTURE.md](../../Documentation/UserGuide/ARCHITECTURE.md) - System architecture
* [METHODOLOGY.md](../../Documentation/UserGuide/METHODOLOGY.md) - Layer structure
-/

-- Re-export all Core layer components
import Logos.Core.Core
