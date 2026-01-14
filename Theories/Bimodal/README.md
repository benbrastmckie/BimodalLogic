# Bimodal

Core library for TM bimodal logic (Tense and Modality) with task semantics.

## Reference Document

For the complete formal specification, see **BimodalReference** ([tex](latex/BimodalReference.tex) | [pdf](latex/BimodalReference.pdf)).

This README provides an overview; BimodalReference contains the detailed specification of syntax, semantics, proof theory, and metalogic.

## Interactive Demo

**[Demo.lean](Examples/Demo.lean)** provides a comprehensive tour of the Bimodal formalization, ideal for presentations and learning:

| Section | Content |
|---------|---------|
| **Quick Tour** | Perpetuity principles P1-P6, soundness, deduction theorem, completeness |
| **Interactive Exploration** | Step-by-step proof construction with modus ponens and necessitation |
| **Decision Procedure** | Live `#eval` demonstrations with valid/invalid formula examples |
| **Applications** | Meaningful examples (conservation of energy, lunar eclipses, mathematical truths) |

### Key Results Demonstrated

| Result | Statement | Status |
|--------|-----------|--------|
| Soundness | `(Γ ⊢ φ) → (Γ ⊨ φ)` | Proven |
| Deduction Theorem | `((A :: Γ) ⊢ B) → (Γ ⊢ A → B)` | Proven |
| Completeness | `valid φ → (⊢ φ)` | Proven |
| Equivalence | `Nonempty (⊢ φ) ↔ valid φ` | Proven |
| Decidability | `decide φ : DecisionResult φ` | Implemented |

Run `lake build Bimodal.Examples.Demo` to verify the demo compiles.

## About Bimodal Logic

Bimodal is a **propositional intensional logic** implementing TM (Tense and Modality).

| Aspect | Description |
|--------|-------------|
| **Type** | Propositional intensional logic |
| **Semantic primitives** | World-states in a Kripke-style framework |
| **Interpretation** | Sentence letters are interpreted by sets of world-states |
| **Logical level** | Propositional (zeroth-order) |

For comparison with the planned Logos hyperintensional logic (second-order with state
primitives), see [bimodal-logic.md](../../docs/research/bimodal-logic.md).

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

## Purpose

This directory contains the foundational implementation of bimodal logic TM, providing the
syntax, proof system, semantics, metalogical results, and automation for temporal-modal
reasoning. The library is designed as an independent, reusable component that can be
imported by other projects.

## Proof System Overview

### Axiom Schemata (14 total)

| Category | Axioms | Description |
|----------|--------|-------------|
| Propositional | K, S, EFQ, Peirce | Classical propositional logic |
| Modal (S5) | T (`□φ → φ`), 4 (`□φ → □□φ`), B (`φ → □◇φ`), 5 (`◇□φ → □φ`), K (`□(φ→ψ) → (□φ→□ψ)`) | Reflexive, transitive, symmetric |
| Temporal | K (`G(φ→ψ) → (Gφ→Gψ)`), 4 (`Gφ → GGφ`), A (`φ → GPφ`), L (`△φ → GHφ`) | Linear temporal structure |
| Interaction | MF (`□φ → □Gφ`), TF (`□φ → G□φ`) | Modal-temporal bridge |

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

The interaction axioms (MF, TF) ensure coherence between modal and temporal reasoning.

See BimodalReference Section 2 for formal semantic definitions.

## Theory-Specific Documentation

For Bimodal-specific guides and references, see [docs/](docs/README.md):

| Document | Description |
|----------|-------------|
| [Quick Start](docs/user-guide/QUICKSTART.md) | Get started with Bimodal proofs |
| [Proof Patterns](docs/user-guide/PROOF_PATTERNS.md) | Common proof strategies |
| [Examples](docs/user-guide/EXAMPLES.md) | Worked examples with exercises and solutions |
| [Troubleshooting](docs/user-guide/TROUBLESHOOTING.md) | Common errors and fixes |
| [Axiom Reference](docs/reference/AXIOM_REFERENCE.md) | Complete axiom schemas |
| [Tactic Reference](docs/reference/TACTIC_REFERENCE.md) | Custom tactic usage |
| [Implementation Status](docs/project-info/IMPLEMENTATION_STATUS.md) | Module status |
| [Known Limitations](docs/project-info/KNOWN_LIMITATIONS.md) | MVP limitations |

## Submodules

- **Syntax/**: Formula types and proof contexts
  - `Formula` inductive type (atom, bot, imp, box, past, future)
  - `Context` type for proof premises
  - Derived operators (neg, top, or, and, dia, etc.)

- **ProofSystem/**: Axioms and derivation trees
  - 14 TM axiom schemata (propositional + modal + temporal + interaction)
  - 7 inference rules as `DerivationTree` constructors
  - Derivation trees as inductive `Type` (not `Prop`)
  - Computable `height` function for well-founded recursion

- **Semantics/**: Task frame semantics
  - `TaskFrame` structure (world states, times, task relation)
  - `WorldHistory` functions for temporal traces
  - `TaskModel` with valuation
  - Truth evaluation (`truth_at`) and validity (`valid`)

- **Metalogic/**: Soundness, completeness, and deduction theorem
  - `Soundness.lean` - Soundness theorem and lemmas
  - `Completeness.lean` - Canonical model construction (infrastructure)
  - `DeductionTheorem.lean` - Deduction theorem for TM logic

- **Theorems/**: Key theorems and derived principles
  - Perpetuity principles P1-P6 in `Perpetuity/`
  - Modal S4/S5 theorems
  - Propositional theorem combinators
  - Generalized necessitation

- **Automation/**: Proof tactics and automation
  - `Tactics.lean` - Custom tactics (apply_axiom, modal_t, tm_auto)
  - `AesopRules.lean` - Aesop rule set for TM logic
  - `ProofSearch.lean` - Bounded proof search infrastructure

- **Examples/**: Pedagogical examples and proof strategies
  - Modal, temporal, and bimodal proof demonstrations
  - Strategy guides for different proof patterns

## Quick Reference

**Where to find specific functionality**:

- **Formulas**: `Syntax/Formula.lean` - Inductive formula type
- **Contexts**: `Syntax/Context.lean` - Proof context lists
- **Axioms**: `ProofSystem/Axioms.lean` - TM axiom schemata
- **Derivation Trees**: `ProofSystem/Derivation.lean` - DerivationTree type
- **Task Frames**: `Semantics/TaskFrame.lean` - Task frame structure
- **Models**: `Semantics/TaskModel.lean` - Models with valuation
- **Truth**: `Semantics/Truth.lean` - Truth evaluation
- **Validity**: `Semantics/Validity.lean` - Semantic consequence
- **Soundness**: `Metalogic/Soundness.lean` - Soundness theorem
- **Completeness**: `Metalogic/Completeness.lean` - Canonical model
- **Perpetuity**: `Theorems/Perpetuity.lean` - P1-P6 principles
- **Tactics**: `Automation/Tactics.lean` - Custom tactics

## Building and Type-Checking

```bash
# Build Bimodal library
lake build Bimodal

# Build entire project
lake build

# Type-check specific file
lake env lean Bimodal/Syntax/Formula.lean
lake env lean Bimodal/ProofSystem/Axioms.lean
lake env lean Bimodal/Semantics/TaskFrame.lean

# Interactive mode
lake env lean --run
```

## Module Structure

The Bimodal library follows a layered architecture:

1. **Layer 0 (Foundation)**: Syntax and ProofSystem
   - Define formulas and axioms
   - Establish proof rules

2. **Layer 1 (Semantics)**: Task frame semantics
   - Define models and truth evaluation
   - Establish validity

3. **Layer 2 (Metalogic)**: Properties of the proof system
   - Prove soundness (derivability implies validity)
   - Establish completeness (validity implies derivability)

4. **Layer 3 (Theorems)**: Derived results
   - Perpetuity principles
   - Modal-temporal interactions

5. **Layer 4 (Automation)**: Proof automation
   - Custom tactics for TM proofs
   - Automated proof search

## Implementation Status

| Layer | Component | Status |
|-------|-----------|--------|
| 0 | Syntax | Complete |
| 1 | ProofSystem | Complete |
| 2 | Semantics | Complete |
| 3 | Metalogic | Complete (Soundness, Completeness, Deduction, Decidability) |
| 4 | Theorems | Complete (P1-P6 perpetuity principles) |
| 5 | Automation | Partial |

For detailed status, see [Implementation Status](docs/project-info/IMPLEMENTATION_STATUS.md). For known limitations, see [Known Limitations](docs/project-info/KNOWN_LIMITATIONS.md).

## API Documentation

For detailed API documentation:

- **Module overview**: See [Bimodal.lean](Bimodal.lean) for top-level re-exports
- **Generated docs**: Run `lake build :docs` to generate doc-gen4 documentation
- **Architecture guide**: [ARCHITECTURE.md](../docs/user-guide/ARCHITECTURE.md)
- **Code comments**: All public definitions have comprehensive docstrings

## Development Guidelines

When working on Bimodal source code:

- **Follow style guide**: [LEAN_STYLE_GUIDE.md](../docs/development/LEAN_STYLE_GUIDE.md)
- **Write tests first**: [TESTING_STANDARDS.md](../docs/development/TESTING_STANDARDS.md)
- **Document thoroughly**: Every public definition requires docstring
- **Run lint**: Zero `#lint` warnings required
- **Build successfully**: `lake build` must complete without errors

## Common Tasks

### Adding a New Definition

1. Choose appropriate module (Syntax, ProofSystem, Semantics, etc.)
2. Write comprehensive docstring
3. Implement definition
4. Add to module export list
5. Write tests in `BimodalTest/`
6. Update documentation if significant

### Proving a New Theorem

1. Write theorem statement with docstring in appropriate module
2. Sketch proof strategy in comments
3. Implement proof using tactics or term-mode
4. Add example usage to `Examples/`
5. Document in relevant guide (TUTORIAL.md, EXAMPLES.md)

### Adding a New Axiom

1. Add axiom schema to `ProofSystem/Axioms.lean`
2. Add case to `DerivationTree` in `ProofSystem/Derivation.lean`
3. Update `height` function to handle new constructor
4. Prove validity in `Metalogic/Soundness.lean`
5. Write tests in `BimodalTest/ProofSystem/`
6. Update ARCHITECTURE.md if significant

## Related Documentation

### Primary Reference

- **BimodalReference** ([tex](latex/BimodalReference.tex) | [pdf](latex/BimodalReference.pdf)) - Complete formal specification

### User Guides

- [Quick Start](docs/user-guide/QUICKSTART.md) - Getting started with Bimodal proofs
- [Proof Patterns](docs/user-guide/PROOF_PATTERNS.md) - Common proof strategies
- [Examples](docs/user-guide/EXAMPLES.md) - Worked examples with solutions
- [Troubleshooting](docs/user-guide/TROUBLESHOOTING.md) - Common errors and fixes

### Reference

- [Axiom Reference](docs/reference/AXIOM_REFERENCE.md) - Complete axiom schemas
- [Tactic Reference](docs/reference/TACTIC_REFERENCE.md) - Custom tactic usage

### Project Info

- [Implementation Status](docs/project-info/IMPLEMENTATION_STATUS.md) - Module status
- [Known Limitations](docs/project-info/KNOWN_LIMITATIONS.md) - MVP limitations
- [Bimodal vs Logos](../../docs/research/bimodal-logic.md) - Theory comparison

## Navigation

- [Project Root](../) | [Theory Docs](docs/) | [Examples](Examples/) | [Tests](../BimodalTest/)
