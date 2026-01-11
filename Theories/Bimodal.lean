-- Re-export all Bimodal modules
import Bimodal.Bimodal

/-!
# Bimodal - TM Logic Library

This module is the main entry point for the Bimodal library, which implements
an axiomatic proof system for the bimodal logic TM (Tense and Modality) with
task semantics.

## Overview

Bimodal provides:
- **Bimodal Logic TM**: Combining S5 modal logic (metaphysical necessity/possibility)
  with linear temporal logic (past/future operators)
- **Task Semantics**: Possible worlds as functions from times to world states
  constrained by task relations
- **Complete Metalogic**: Soundness and completeness proofs
- **Perpetuity Principles**: P1-P6 derived theorems

## Module Structure

The library is organized into the following submodules:

- `Bimodal.Syntax`: Formula types, parsing, DSL
- `Bimodal.ProofSystem`: Axioms, derivation trees, and inference rules
- `Bimodal.Semantics`: Task frame semantics
- `Bimodal.Metalogic`: Soundness and completeness proofs
- `Bimodal.Theorems`: Key theorems (perpetuity principles, etc.)
- `Bimodal.Automation`: Proof automation tactics

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

## Backwards Compatibility

For backwards compatibility with existing code using `Logos.Core`:
```lean
import Logos.Core  -- Re-exports Bimodal
```
-/
