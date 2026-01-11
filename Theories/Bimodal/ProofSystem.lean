import Bimodal.ProofSystem.Axioms
import Bimodal.ProofSystem.Derivation

/-!
# Bimodal.ProofSystem - TM Proof System

Aggregates all ProofSystem components for the Core TM logic layer.

## Submodules

- `Axioms`: TM axiom schemata (MT, M4, MB, T4, TA, TL, MF, TF)
- `Derivation`: Derivability relation with 7 inference rules

## Usage

```lean
import Bimodal.ProofSystem

open Bimodal.ProofSystem

example (p : String) : ⊢ (Formula.box (Formula.atom p)).imp (Formula.atom p) := by
  apply Derivable.axiom
  apply Axiom.modal_t
```
-/
