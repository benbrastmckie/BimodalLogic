# Bimodal

**Production-ready** core library for TM bimodal logic (Tense and Modality) with task semantics and **complete soundness and completeness proofs**.

## Reference Document

For the complete formal specification, see **BimodalReference** ([tex](latex/BimodalReference.tex) | [pdf](latex/BimodalReference.pdf)).

This README provides an overview; BimodalReference contains the detailed specification of syntax, semantics, proof theory, and metalogic.

## About Bimodal Logic

Bimodal is a **complete propositional intensional logic** implementing TM (Tense and Modality) with verified metalogic.

| Aspect | Description |
|--------|-------------|
| **Type** | Propositional intensional logic |
| **Status** | Production-ready with soundness/completeness proofs |
| **Semantic primitives** | World-states in a Kripke-style framework |
| **Interpretation** | Sentence letters are interpreted by sets of world-states |
| **Logical level** | Propositional (zeroth-order) |

## Syntax Quick Reference

### Primitive Operators

| Symbol | Lean | Reading |
|--------|------|---------|
| `p` | `atom "p"` | propositional variable |
| `⊥` | `bot` | falsity (bottom) |
| `φ → ψ` | `imp φ ψ` | implication |
| `□φ` | `box φ` | necessity ("necessarily φ") |
| `Hφ` | `all_past φ` | "φ has always been true" |
| `Gφ` | `all_future φ` | "φ will always be true" |

### Derived Operators

| Symbol | Lean | Definition |
|--------|------|------------|
| `¬φ` | `neg φ` | `φ → ⊥` |
| `φ ∧ ψ` | `and φ ψ` | `¬(φ → ¬ψ)` |
| `φ ∨ ψ` | `or φ ψ` | `¬φ → ψ` |
| `◇φ` | `diamond φ` | `¬□¬φ` (possibility) |
| `Pφ` | `some_past φ` | `¬H¬φ` ("φ was once true") |
| `Fφ` | `some_future φ` | `¬G¬φ` ("φ will be true") |
| `△φ` | `always φ` | `Hφ ∧ φ ∧ Gφ` (eternal) |
| `▽φ` | `sometimes φ` | `¬△¬φ` (sometime) |

See BimodalReference Section 1 for complete syntax details.

## Proof System Overview

### Axiom System

The axiom system uses the `Axiom` inductive type with **42 constructors** organized into 8 layers:

| Layer | Constructors | Frame Class | Description |
|-------|-------------|-------------|-------------|
| Propositional | 4 | Base | K, S, EFQ, Peirce |
| S5 Modal | 5 | Base | T, 4, B, 5-collapse, K-distribution |
| BX Temporal | 22 | Base | Burgess-Xu Until/Since axioms (paired G/H forms) |
| Interaction | 1 | Base | MF (`□φ → □Gφ`); TF is now derived |
| Uniformity | 5 | Base | Discrete uniformity (valid on all ordered abelian groups) |
| Prior | 2 | Discrete | Prior-UZ/SZ for discrete well-ordering |
| Z1 | 1 | Discrete | IsSuccArchimedean characteristic axiom |
| Density | 2 | Dense | `Gφ → GGφ` and `¬U(⊤,⊥)` |

**Schema vs. constructor count**: The 42 constructors implement a smaller set of logical schemas.
The "21 axiom schemata" figure counts distinct logical schemas (e.g., G-monotonicity and H-monotonicity
count as one schema with two constructors). The `Axiom` inductive type uses 42 constructors to
represent all paired temporal forms explicitly.

**Frame classification**: 37 Base constructors (valid on all linear orders), 3 Discrete-only, 2 Dense-only.

See [ProofSystem/Axioms.lean](ProofSystem/Axioms.lean) for the complete definition.

### Inference Rules (7 total)

- **Modus Ponens**: From `⊢ φ → ψ` and `⊢ φ`, derive `⊢ ψ`
- **Necessitation**: From `⊢ φ`, derive `⊢ □φ`
- **Temporal Necessitation**: From `⊢ φ`, derive `⊢ Gφ`
- **Temporal Duality**: From `⊢ φ`, derive `⊢ swap(φ)` (swap H/G, P/F)
- **Axiom**: Any axiom instance is derivable
- **Assumption**: Hypotheses in context are derivable
- **Weakening**: Derivations extend to larger contexts

**Note**: `DerivationTree` is `Type` (not `Prop`) for computability.

See BimodalReference Section 3 for full proof system presentation.

## Semantics Overview

### Task Frame Structure

A task frame `(W, T, R)` consists of:
- **W**: Set of world-states (metaphysically possible states)
- **T**: Set of times with linear order `<`
- **R : W → T → W → Prop**: Task relation (accessibility across time)

Properties: Nullity (reflexive at each time) and Compositionality (forward composition).

### Truth Conditions

- **Atoms**: `M,τ,t ⊨ p` iff `p ∈ V(τ(t))`
- **Modal**: `M,τ,t ⊨ □φ` iff `∀σ. R(τ,t,σ) → M,σ,t ⊨ φ`
- **Temporal**: `M,τ,t ⊨ Gφ` iff `∀s > t. M,τ,s ⊨ φ`

The interaction axiom MF ensures coherence between modal and temporal reasoning.

See BimodalReference Section 2 for formal semantic definitions.

## Logic Variants

TM logic has three variants based on frame conditions:

### TM Base (37 constructor axioms)

The core logic valid on all linear orders. See `FrameClass.Base` in [ProofSystem/Axioms.lean](ProofSystem/Axioms.lean).

- **Soundness**: `axiom_valid` - all base axioms valid on linear orders
- **Frame**: Linear temporal order (no additional constraints)

### TM Dense (Base + 2 density constructors)

Extension requiring densely ordered temporal domains. See `FrameClass.Dense`.

- **Additional Axioms**: `density` (`Gφ → GGφ`) and `dense_indicator` (`¬U(⊤,⊥)`)
- **Completeness**: `completeness_dense` in [BXCanonical/Completeness.lean](Metalogic/BXCanonical/Completeness.lean)
- **Frame**: `DenselyOrdered D` - between any two times exists another

### TM Discrete (Base + 3 discrete constructors)

Extension requiring discretely ordered temporal domains. See `FrameClass.Discrete`.

- **Additional Axioms**: `prior_UZ`, `prior_SZ` (Prior's axioms), `z1` (IsSuccArchimedean)
- **Completeness**: `completeness_discrete` in [BXCanonical/Completeness.lean](Metalogic/BXCanonical/Completeness.lean)
- **Frame**: `SuccOrder D`, `PredOrder D`, `NoMaxOrder D`, `NoMinOrder D`

### Variant Incompatibility

Dense and discrete extensions are **incompatible** on any non-degenerate domain.

## Key Results Proven

| Result | Statement | Status |
|--------|-----------|--------|
| Soundness | `(Γ ⊢ φ) → (Γ ⊨ φ)` | Proven |
| Deduction Theorem | `((A :: Γ) ⊢ B) → (Γ ⊢ A → B)` | Proven |
| Dense Completeness | `valid_dense φ → (⊢ φ)` | Proven |
| Discrete Completeness | `valid_discrete φ → (⊢ φ)` | Proven |
| Decidability | `decide φ : DecisionResult φ` | Implemented |

## Module Structure

The Bimodal library follows a layered architecture:

### Root Entry Point

| File | Lines | Description |
|------|-------|-------------|
| `Bimodal.lean` | 86 | Top-level re-export: imports all submodules for unified access |
| `Automation.lean` | 92 | Re-export for Automation submodule |
| `Examples.lean` | 27 | Re-export for Examples submodule |
| `FrameConditions.lean` | 52 | Re-export for FrameConditions submodule |
| `Metalogic.lean` | 55 | Re-export for Metalogic submodule |
| `ProofSystem.lean` | 73 | Re-export for ProofSystem submodule |
| `Semantics.lean` | 86 | Re-export for Semantics submodule |
| `Syntax.lean` | 68 | Re-export for Syntax submodule |
| `Theorems.lean` | 74 | Re-export for Theorems submodule |

### Layer 0 — Foundation

| Module | File | Description |
|--------|------|-------------|
| Syntax | `Syntax.lean` | Formula type, atoms, contexts, subformula closure |
| ProofSystem | `ProofSystem.lean` | 42 axiom constructors, 7 inference rules, derivation trees |

### Layer 1 — Semantics

| Module | File | Description |
|--------|------|-------------|
| Semantics | `Semantics.lean` | Task frame structure, world histories, truth evaluation |
| FrameConditions | `FrameConditions.lean` | Frame classes, soundness certificates |

### Layer 2 — Metalogic

| Module | File | Description |
|--------|------|-------------|
| Metalogic | `Metalogic.lean` | Soundness, completeness, deduction theorem, decidability |

### Layer 3 — Theorems

| Module | File | Description |
|--------|------|-------------|
| Theorems | `Theorems.lean` | Derived theorems: perpetuity, combinators, modal S4/S5 |

### Layer 4 — Automation

| Module | File | Description |
|--------|------|-------------|
| Automation | `Automation.lean` | Tactics, Aesop rules, ML dataset pipeline |

### Layer 5 — Examples

| Module | File | Description |
|--------|------|-------------|
| Examples | `Examples.lean` | Pedagogical examples and proof demonstrations |

## Submodule Navigation

| Submodule | README | Description |
|-----------|--------|-------------|
| [Syntax/](Syntax/README.md) | Yes | Formula types and proof contexts |
| [ProofSystem/](ProofSystem/README.md) | Yes | Axioms and derivation trees |
| [Semantics/](Semantics/README.md) | Yes | Task frame semantics |
| [FrameConditions/](FrameConditions/README.md) | Yes | Frame classes and soundness |
| [Metalogic/](Metalogic/README.md) | Yes | Soundness, completeness, decidability |
| [Theorems/](Theorems/README.md) | Yes | Derived theorems |
| [Automation/](Automation/README.md) | Yes | Proof tactics and ML pipeline |
| [Examples/](Examples/README.md) | Yes | Pedagogical examples |

## Quick Reference

**Where to find specific functionality**:

- **Formulas**: `Syntax/Formula.lean` - Inductive formula type
- **Contexts**: `Syntax/Context.lean` - Proof context lists
- **Axioms**: `ProofSystem/Axioms.lean` - TM axiom constructors (42)
- **Derivation Trees**: `ProofSystem/Derivation.lean` - DerivationTree type
- **Task Frames**: `Semantics/TaskFrame.lean` - Task frame structure
- **Models**: `Semantics/TaskModel.lean` - Models with valuation
- **Truth**: `Semantics/Truth.lean` - Truth evaluation
- **Validity**: `Semantics/Validity.lean` - Semantic consequence
- **Soundness**: `Metalogic/Soundness.lean` - Soundness theorem
- **Completeness**: `Metalogic/BXCanonical/Completeness.lean` - Canonical model
- **Perpetuity**: `Theorems/Perpetuity.lean` - P1-P6 principles
- **Tactics**: `Automation/Tactics/Commands.lean` - Custom tactics

## Building and Type-Checking

```bash
# Build Bimodal library
lake build Bimodal

# Build entire project
lake build

# Type-check specific file
lake env lean Theories/Bimodal/Syntax/Formula.lean
lake env lean Theories/Bimodal/ProofSystem/Axioms.lean
```

## Implementation Status

| Layer | Component | Status |
|-------|-----------|--------|
| 0 | Syntax | Complete |
| 0 | ProofSystem | Complete (42 axiom constructors, 7 rules) |
| 1 | Semantics | Complete (TaskFrame, TaskModel, Truth) |
| 1 | FrameConditions | Complete (Base, Dense, Discrete soundness) |
| 2 | Metalogic | **Complete** (Soundness, Completeness, Deduction, Decidability) |
| 3 | Theorems | Complete (P1-P6 perpetuity principles, S4/S5 modal) |
| 4 | Automation | Complete (tactics); ML pipeline active |

**Key Results**: Soundness theorem, completeness theorem (Dense and Discrete variants),
deduction theorem, and decidability are all fully proven.

## Theory-Specific Documentation

For Bimodal-specific guides and references, see [docs/](docs/README.md):

| Document | Description |
|----------|-------------|
| [Quick Start](docs/user-guide/QUICKSTART.md) | Get started with Bimodal proofs |
| [Proof Patterns](docs/user-guide/PROOF_PATTERNS.md) | Common proof strategies |
| [Axiom Reference](docs/reference/AXIOM_REFERENCE.md) | Complete axiom schemas |
| [Tactic Reference](docs/reference/TACTIC_REFERENCE.md) | Custom tactic usage |

## Navigation

- **Parent**: [Project Root](../../) | [Tests](../../Tests/)
- **Docs**: [docs/](docs/README.md)
- **Boneyard**: [Boneyard/](Boneyard/README.md) (archived code)

---

*Last verified: 2026-05-29*

> **Note**: This README was last verified before task 131 (module reorg) -- verify
> file list is still current after that task completes.
