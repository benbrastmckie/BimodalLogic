-- Re-export public API
import Logos.Syntax
import Logos.ProofSystem
import Logos.Semantics
import Logos.Metalogic
import Logos.Theorems
import Logos.Automation

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

- `Logos.Syntax`: Formula types, parsing, DSL
- `Logos.ProofSystem`: Axioms and inference rules
- `Logos.Semantics`: Task frame semantics
- `Logos.Metalogic`: Soundness and completeness proofs
- `Logos.Theorems`: Key theorems (perpetuity principles, etc.)
- `Logos.Automation`: Proof automation tactics

## Usage

Import the entire library:
```lean
import Logos
```

Or import specific modules:
```lean
import Logos.Syntax.Formula
import Logos.ProofSystem.Axioms
```
-/

namespace Logos

-- Version information
def version : String := "0.1.0"

end Logos
