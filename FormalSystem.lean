/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

-- Re-export all Bimodal modules
import FormalSystem.FormalSystem

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

- `FormalSystem.Syntax`: Formula types, parsing, DSL
- `FormalSystem.ProofSystem`: Axioms, derivation trees, and inference rules
- `FormalSystem.Semantics`: Task frame semantics
- `FormalSystem.Metalogic`: Soundness and completeness proofs
- `FormalSystem.Theorems`: Key theorems (perpetuity principles, etc.)
- `FormalSystem.Automation`: Proof automation tactics

## Usage

Import the entire library:
```lean
import FormalSystem
```

Or import specific modules:
```lean
import FormalSystem.Syntax.Formula
import FormalSystem.ProofSystem.Axioms
```
-/
