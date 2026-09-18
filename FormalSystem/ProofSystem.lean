/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ProofSystem.Axioms
import FormalSystem.ProofSystem.Derivation
import FormalSystem.ProofSystem.Derivable
import FormalSystem.ProofSystem.DerivedAxioms
import FormalSystem.ProofSystem.LinearityDerivedFacts

/-!
# FormalSystem.ProofSystem - TM Proof System

Aggregates all proof system components for bimodal logic TM (Tense and Modality).
Provides the Hilbert-style axiom system with 29 axiom schemata (the paper's primitive
system) and derivation trees with 7 inference rules.

## Submodules

- `Axioms`: 29 TM axiom constructors organized into base (23), dense (2), discrete (2), and
  Dedekind (2) layers
  - Propositional: K, S, EFQ (ex falso), Peirce
  - Modal S5: MT (reflexivity), M5 (collapse), MK (distribution)
  - Temporal (BX, future direction): TS, UG, UC, TC, SU, UF, UI, CN, UE, TL, UT
  - Modal-Temporal: MF
  - Uniformity: NP, NF, NA, NB
  - Discrete: UZ, Z1; Dense: DN, NN; Reynolds Dedekind: PU, SEP

- `DerivedAxioms`: the schemata the paper does not take as primitive, as derived theorems —
  the time-reflection mirrors (by the TR rule) and, in `Theorems/Combinators.lean`, modal 4
  and B and the pre-paper forms of TL, CN and TS

- `Derivation`: Derivation tree type `Γ ⊢ φ` with 7 inference rules
  - axiom, assumption, modus_ponens, necessitation, temporal_necessitation,
    time_reflection, weakening

- `LinearityDerivedFacts`: consequences of `temp_linearity`, including the
  counterexample showing it is not derivable from the other axioms. `Axioms.lean`
  cites this file for that non-derivability claim, so it is imported here to keep
  the citation backed by compiled code rather than by an unbuilt file.

## Axiom Summary

| Category | Axioms | Description |
|----------|--------|-------------|
| Propositional | K, S, EFQ, Peirce | Classical propositional logic basis |
| Modal S5 | MT, M5, MK | S5 necessity (4 and B derived) |
| Temporal | TS, UG, UC, TC, SU, UF, UI, CN, UE, TL, UT | Burgess-Xu Until/Since, future direction |
| Interaction | MF | Modal-temporal connection axiom (TF derived) |

## Inference Rules

| Rule | From | To |
|------|------|-----|
| axiom | Axiom φ | Γ ⊢ φ |
| assumption | φ ∈ Γ | Γ ⊢ φ |
| modus_ponens | Γ ⊢ φ → ψ, Γ ⊢ φ | Γ ⊢ ψ |
| necessitation | ⊢ φ | ⊢ □φ |
| temporal_necessitation | ⊢ φ | ⊢ Fφ |
| time_reflection | ⊢ φ | ⊢ reflectTime φ |
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
* [LinearityDerivedFacts.lean](ProofSystem/LinearityDerivedFacts.lean) - `temp_linearity`
consequences and non-derivability counterexample
-/
