-- Re-export public API
import Logos.Core

/-!
# Logos Library Root

This is the main entry point for the Logos library, which implements
an axiomatic proof system for the bimodal logic TM (Tense and Modality) with
task semantics.

## Overview

Logos provides:
- **Bimodal Logic TM**: Combining S5 modal logic (metaphysical necessity/possibility)
  with linear temporal logic (past/future operators)
- **Task Semantics**: Possible worlds as functions from times to world states
  constrained by task relations
- **Layered Architecture**: Layer 0 (Core TM) with planned extensions
- **Complete Metalogic**: Soundness and completeness proofs
- **Perpetuity Principles**: P1-P6 derived theorems

## Module Structure

The library is organized into the following submodules:

- `Logos.Core.Syntax`: Formula types, parsing, DSL
- `Logos.Core.ProofSystem`: Axioms and inference rules
- `Logos.Core.Semantics`: Task frame semantics
- `Logos.Core.Metalogic`: Soundness and completeness proofs
- `Logos.Core.Theorems`: Key theorems (perpetuity principles, etc.)
- `Logos.Core.Automation`: Proof automation tactics

## Usage

Import the entire library:
```lean
import Logos
```

Or import specific modules:
```lean
import Logos.Core.Syntax.Formula
import Logos.Core.ProofSystem.Axioms
```
-/

namespace Logos

-- Version information
def version : String := "0.1.0"

end Logos
