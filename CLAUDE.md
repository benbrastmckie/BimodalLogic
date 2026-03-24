# ProofChecker

Lean 4 formalization of bimodal logic TM (Tense and Modality) combining S5 modal logic with linear temporal logic.

## Build

```
lake build
```

## Project Structure

- `Theories/Bimodal/` — Main library source
  - `Syntax/` — Formula types, atoms, contexts
  - `ProofSystem/` — Axioms, derivation trees, inference rules
  - `Semantics/` — Task frame semantics, truth evaluation
  - `Metalogic/` — Soundness, completeness, decidability
  - `Theorems/` — Derived theorems (perpetuity, combinators, propositional)
  - `Automation/` — Proof tactics and search
  - `Examples/` — Pedagogical examples
- `Tests/BimodalTest/` — Test suite

## Lean Version

v4.27.0-rc1 with Mathlib v4.27.0-rc1
