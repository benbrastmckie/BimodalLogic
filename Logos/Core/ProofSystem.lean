import Logos.Core.ProofSystem.Axioms
import Logos.Core.ProofSystem.Derivation

/-!
# Logos.Core.ProofSystem - TM Proof System

Aggregates all ProofSystem components for the Core TM logic layer.

## Submodules

- `Axioms`: TM axiom schemata (MT, M4, MB, T4, TA, TL, MF, TF)
- `Derivation`: Derivability relation with 7 inference rules

## Usage

```lean
import Logos.Core.ProofSystem

open Logos.Core.ProofSystem

example (p : String) : ⊢ (Formula.box (Formula.atom p)).imp (Formula.atom p) := by
  apply Derivable.axiom
  apply Axiom.modal_t
```
-/
