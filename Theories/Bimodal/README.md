# Bimodal

Core library for TM bimodal logic (Tense and Modality) with task semantics.

## About Bimodal Logic

Bimodal is a **propositional intensional logic** implementing TM (Tense and Modality).

| Aspect | Description |
|--------|-------------|
| **Type** | Propositional intensional logic |
| **Semantic primitives** | World-states in a Kripke-style framework |
| **Interpretation** | Sentence letters are interpreted by sets of world-states |
| **Logical level** | Propositional (zeroth-order) |

For comparison with the planned Logos hyperintensional logic (second-order with state
primitives), see [theory-comparison.md](../docs/Research/theory-comparison.md).

## Purpose

This directory contains the foundational implementation of bimodal logic TM, providing the
syntax, proof system, semantics, metalogical results, and automation for temporal-modal
reasoning. The library is designed as an independent, reusable component that can be
imported by other projects.

## Theory-Specific Documentation

For Bimodal-specific guides and references, see [docs/](docs/README.md):

| Document | Description |
|----------|-------------|
| [Quick Start](docs/UserGuide/QUICKSTART.md) | Get started with Bimodal proofs |
| [Proof Patterns](docs/UserGuide/PROOF_PATTERNS.md) | Common proof strategies |
| [Axiom Reference](docs/Reference/AXIOM_REFERENCE.md) | Complete axiom schemas |
| [Tactic Reference](docs/Reference/TACTIC_REFERENCE.md) | Custom tactic usage |
| [Implementation Status](docs/ProjectInfo/IMPLEMENTATION_STATUS.md) | Module status |
| [Known Limitations](docs/ProjectInfo/KNOWN_LIMITATIONS.md) | MVP limitations |

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

**Complete (Layers 0-1)**:
- Syntax: Formula, Context, derived operators
- ProofSystem: All 14 axioms and 7 rules defined
- Semantics: TaskFrame, TaskModel, Truth, Validity

**Partial (Layer 2)**:
- Metalogic/Soundness: Soundness theorem proven
- Metalogic/Completeness: Infrastructure only

**Partial (Layer 3)**:
- Theorems/Perpetuity: P1-P3 fully proven, P4-P6 partial
- Modal S4/S5 theorems

**Partial (Layer 4)**:
- Automation: Core tactics implemented
- ProofSearch: Infrastructure with build issues

For detailed status, see [Bimodal Implementation Status](docs/ProjectInfo/IMPLEMENTATION_STATUS.md).
For known limitations, see [Known Limitations](docs/ProjectInfo/KNOWN_LIMITATIONS.md).

## API Documentation

For detailed API documentation:

- **Module overview**: See [Bimodal.lean](Bimodal.lean) for top-level re-exports
- **Generated docs**: Run `lake build :docs` to generate doc-gen4 documentation
- **Architecture guide**: [ARCHITECTURE.md](../docs/UserGuide/ARCHITECTURE.md)
- **Code comments**: All public definitions have comprehensive docstrings

## Development Guidelines

When working on Bimodal source code:

- **Follow style guide**: [LEAN_STYLE_GUIDE.md](../docs/Development/LEAN_STYLE_GUIDE.md)
- **Write tests first**: [TESTING_STANDARDS.md](../docs/Development/TESTING_STANDARDS.md)
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

### Theory-Specific (Bimodal)

- [Bimodal Documentation](docs/README.md) - Theory-specific documentation hub
- [Quick Start](docs/UserGuide/QUICKSTART.md) - Getting started with Bimodal
- [Axiom Reference](docs/Reference/AXIOM_REFERENCE.md) - Complete axiom schemas
- [Known Limitations](docs/ProjectInfo/KNOWN_LIMITATIONS.md) - MVP limitations

### Project-Wide

- [Theory Comparison](../docs/Research/theory-comparison.md) - Bimodal vs Logos
- [LEAN Style Guide](../docs/Development/LEAN_STYLE_GUIDE.md) - Coding conventions
- [Module Organization](../docs/Development/MODULE_ORGANIZATION.md) - Directory structure
- [Testing Standards](../docs/Development/TESTING_STANDARDS.md) - Test requirements
- [Architecture Guide](../docs/UserGuide/ARCHITECTURE.md) - TM logic specification
- [Tutorial](../docs/UserGuide/TUTORIAL.md) - Getting started
- [Implementation Status](../docs/ProjectInfo/IMPLEMENTATION_STATUS.md) - Project status

## Navigation

- **Up**: [Project Root](../)
- **Theory Docs**: [docs/](docs/) - Bimodal-specific documentation
- **Tests**: [BimodalTest/](../BimodalTest/)
- **Project Docs**: [docs/](../docs/) - Project-wide documentation
- **Examples**: [Examples/](Examples/)
