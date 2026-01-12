import Bimodal.ProofSystem.Axioms
import Bimodal.ProofSystem.Derivation

/-!
# Bimodal.ProofSystem - TM Proof System

Aggregates all proof system components for bimodal logic TM (Tense and Modality).
Provides the Hilbert-style axiom system with 14 axiom schemata and derivation
trees with 7 inference rules.

## Submodules

- `Axioms`: 14 TM axiom schemata organized by category
  - Propositional: K, S, EFQ (ex falso), Peirce
  - Modal S5: MT (reflexivity), M4 (transitivity), MB (symmetry), MK (distribution)
  - Temporal: TK (distribution), T4 (transitivity), TA (present-past-future), TL (perpetuity)
  - Modal-Temporal: MF (modal-future), TF (temporal-future)

- `Derivation`: Derivation tree type `Γ ⊢ φ` with 7 inference rules
  - axiom, assumption, modus_ponens, necessitation, temporal_necessitation,
    temporal_duality, weakening

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
| temporal_duality | ⊢ φ | ⊢ swap_past_future φ |
| weakening | Γ ⊢ φ, Γ ⊆ Δ | Δ ⊢ φ |

## Usage

```lean
import Bimodal.ProofSystem

open Bimodal.ProofSystem
open Bimodal.Syntax

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
-/
