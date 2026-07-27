/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ProofSystem.Axioms
import FormalSystem.ProofSystem.Derivation
import FormalSystem.ProofSystem.Derivable
import FormalSystem.ProofSystem.LinearityDerivedFacts

/-!
# FormalSystem.ProofSystem - TM Proof System

Aggregates all proof system components for bimodal logic TM (Tense and Modality).
Provides the Hilbert-style axiom system with 21 axiom schemata and derivation
trees with 7 inference rules.

## Submodules

- `Axioms`: 21 TM axiom schemata organized into base (17), dense (1), and discrete (3) layers
  - Propositional: K, S, EFQ (ex falso), Peirce
  - Modal S5: MT (reflexivity), M4 (transitivity), MB (symmetry), M5 (collapse), MK (distribution)
  - Temporal: TK (distribution), T4 (transitivity), TT-F/TT-P (reflexivity), TA
  (present-past-future), TL (perpetuity), Lin (linearity)
  - Modal-Temporal: MF (modal-future), TF (temporal-future)
  - Dense Extension: DN (density)
  - Discrete Extension: DF (discreteness), F-seriality, P-seriality

- `Derivation`: Derivation tree type `Γ ⊢ φ` with 7 inference rules
  - axiom, assumption, modus_ponens, necessitation, temporal_necessitation,
    temporal_duality, weakening

- `LinearityDerivedFacts`: consequences of `temp_linearity`, including the
  counterexample showing it is not derivable from the other axioms. `Axioms.lean`
  cites this file for that non-derivability claim, so it is imported here to keep
  the citation backed by compiled code rather than by an unbuilt file.

## Axiom Summary

| Category | Axioms | Description |
|----------|--------|-------------|
| Propositional | K, S, EFQ, Peirce | Classical propositional logic basis |
| Modal S5 | MT, M4, MB, MK | Reflexive, transitive, symmetric accessibility |
| Temporal | TK, T4, TA, TL | Future/past with transitivity and recurrence |
| Interaction | MF, TF | Modal-temporal connection axioms |

## Inference Rules

| Rule | From | To |
|------|------|-----|
| axiom | Axiom φ | Γ ⊢ φ |
| assumption | φ ∈ Γ | Γ ⊢ φ |
| modus_ponens | Γ ⊢ φ → ψ, Γ ⊢ φ | Γ ⊢ ψ |
| necessitation | ⊢ φ | ⊢ □φ |
| temporal_necessitation | ⊢ φ | ⊢ Fφ |
| temporal_duality | ⊢ φ | ⊢ swap_temporal φ |
| weakening | Γ ⊢ φ, Γ ⊆ Δ | Δ ⊢ φ |

## Usage

```lean
import FormalSystem.ProofSystem

open FormalSystem.ProofSystem
open FormalSystem.Syntax

-- Use Modal T axiom: □φ → φ
example (p : String) : ⊢ (Formula.box (Formula.atom p)).imp (Formula.atom p) := by
  apply DerivationTree.axiom
  apply Axiom.modal_t

-- Use modus ponens
example (φ ψ : Formula) (h1 : ⊢ φ.imp ψ) (h2 : ⊢ φ) : ⊢ ψ :=
  DerivationTree.modus_ponens [] φ ψ h1 h2

-- Use necessitation
example (φ : Formula) (h : ⊢ φ) : ⊢ φ.box :=
  DerivationTree.necessitation φ h
```

## References

* [Axioms.lean](ProofSystem/Axioms.lean) - Axiom schemata definitions
* [Derivation.lean](ProofSystem/Derivation.lean) - Derivation tree and inference rules
* [LinearityDerivedFacts.lean](ProofSystem/LinearityDerivedFacts.lean) - `temp_linearity` consequences and non-derivability counterexample
-/
