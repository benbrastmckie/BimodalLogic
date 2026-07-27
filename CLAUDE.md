# ProofChecker

Lean 4 formalization of bimodal logic TM (Tense and Modality) combining S5 modal logic with linear temporal logic.

## Build

```
lake build
```

## Project Structure

- `FormalSystem/` — Main library source
  - `Syntax/` — Formula types, atoms, contexts
  - `ProofSystem/` — Axioms, derivation trees, inference rules
  - `Semantics/` — Task frame semantics, truth evaluation
  - `Metalogic/` — Soundness, completeness, decidability
  - `Theorems/` — Derived theorems (perpetuity, combinators, propositional)
  - `Automation/` — Proof tactics and search
  - `Examples/` — Pedagogical examples
- `Tests/BimodalTest/` — Test suite

## Lean Version

Lean v4.33.0-rc1 with Mathlib pinned to tag `v4.33.0-rc1` (resolved commit `79d0395a`).

To re-derive these rather than trusting this note:

```
cat lean-toolchain          # toolchain pin
lake env lean --version     # Lean version actually in use
```

Mathlib's resolved commit is recorded in `lake-manifest.json`; the requested tag is in
`lakefile.lean`. Mathlib4 has no independent version number of its own — it tags releases to
track the Lean release they build against, so the two version strings matching here is
expected rather than coincidental.
