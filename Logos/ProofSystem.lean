import Logos.Core.ProofSystem.Axioms
import Logos.Core.ProofSystem.Derivation

/-!
# ProofSystem - TM Proof System Module

This module exports all components of the TM proof system.

## Submodules

- `Axioms`: The 8 TM axiom schemata (MT, M4, MB, T4, TA, TL, MF, TF)
- `Derivation`: The derivability relation with 7 inference rules

## Usage

```lean
import Logos.Core.ProofSystem

open Logos.Core.ProofSystem

-- Derive Modal T axiom
example (p : String) : ⊢ (Formula.box (Formula.atom p)).imp (Formula.atom p) := by
  apply Derivable.axiom
  apply Axiom.modal_t

-- Apply modus ponens
example (p q : Formula) : [p.imp q, p] ⊢ q := by
  apply Derivable.modus_ponens (φ := p)
  · apply Derivable.assumption; simp
  · apply Derivable.assumption; simp
```

## References

* [ARCHITECTURE.md](../../docs/ARCHITECTURE.md) - Proof system specification
-/
