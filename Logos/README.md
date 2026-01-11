# Logos

Re-export layer providing the Logos namespace for TM bimodal logic.

## About Logos Logic

Logos is a **planned second-order hyperintensional logic** that will extend beyond Bimodal.

| Aspect | Description |
|--------|-------------|
| **Type** | Second-order hyperintensional logic (planned) |
| **Current status** | Re-exports Bimodal TM logic |
| **Semantic primitives** | States (more fine-grained than worlds) |
| **Logical level** | Second-order with first and second-order variables |

For comparison with Bimodal propositional logic, see
[THEORY_COMPARISON.md](../Documentation/Research/THEORY_COMPARISON.md).

## Purpose

This directory currently re-exports the Bimodal TM logic implementation under the Logos namespace.
When Logos extensions are implemented, this will include epistemic, normative, and explanatory
operators with state-based hyperintensional semantics.

## Theory-Specific Documentation

For Logos-specific guides and references, see [Documentation/](Documentation/README.md):

| Document | Description |
|----------|-------------|
| [Quick Start](Documentation/UserGuide/QUICKSTART.md) | Getting started (redirects to Bimodal) |
| [Current Status](Documentation/UserGuide/CURRENT_STATUS.md) | Logos development status |
| [Axiom Reference](Documentation/Reference/AXIOM_REFERENCE.md) | Axioms (via Bimodal) |
| [Extension Stubs](Documentation/Reference/EXTENSION_STUBS.md) | Planned extensions |
| [Implementation Status](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md) | Module status |
| [Roadmap](Documentation/ProjectInfo/ROADMAP.md) | Development roadmap |

## Submodules

- **Syntax/**: Formula types and proof contexts
  - Formula inductive type (atom, bot, imp, box, past, future)
  - Context type for proof premises
  - DSL for readable formula construction (planned)

- **ProofSystem/**: Axioms and derivation trees
  - 8 TM axiom schemata (MT, M4, MB, T4, TA, TL, MF, TF)
  - 7 inference rules as `DerivationTree` constructors (axiom, assumption, modusPonens, necessitation, temporalNecessitation, temporalDuality, weakening)
  - Derivation trees as inductive `Type` (not `Prop`)
  - Computable `height` function for well-founded recursion

- **Semantics/**: Task frame semantics
  - Task frame structure (world states, times, task relation)
  - World history functions
  - Task models with valuation
  - Truth evaluation and validity

- **Metalogic/**: Soundness and completeness
  - Soundness theorem (partial: 5/8 axioms, 4/7 rules proven)
  - Completeness infrastructure (canonical model construction)
  - Decidability procedures (planned)

- **Theorems/**: Key theorems and principles
  - Perpetuity principles P1-P6 (P1-P3 proven)
  - Modal-temporal interactions

- **Automation/**: Proof automation (planned)
  - Custom tactics (stubs only)
  - Automated proof search (planned)

## Quick Reference

**Where to find specific functionality**:

- **Formulas**: `Syntax/Formula.lean` - Inductive formula type
- **Contexts**: `Syntax/Context.lean` - Proof context lists
- **Axioms**: `ProofSystem/Axioms.lean` - TM axiom schemata
- **Derivation Trees**: `ProofSystem/Derivation.lean` - DerivationTree type and constructors
- **Task Frames**: `Semantics/TaskFrame.lean` - Task frame structure
- **Models**: `Semantics/TaskModel.lean` - Models with valuation
- **Truth**: `Semantics/Truth.lean` - Truth evaluation
- **Validity**: `Semantics/Validity.lean` - Semantic consequence
- **Soundness**: `Metalogic/Soundness.lean` - Soundness theorem
- **Completeness**: `Metalogic/Completeness.lean` - Canonical model construction
- **Perpetuity**: `Theorems/Perpetuity.lean` - Perpetuity principles P1-P6
- **Tactics**: `Automation/Tactics.lean` - Custom tactics (stubs)

## Building and Type-Checking

```bash
# Build entire Logos module
lake build Logos

# Build entire project
lake build

# Type-check specific file
lake env lean Logos/Syntax/Formula.lean
lake env lean Logos/ProofSystem/Axioms.lean
lake env lean Logos/Semantics/TaskFrame.lean

# Interactive mode (load and explore)
lake env lean --run
```

## Module Structure

The Logos module follows a layered architecture:

1. **Layer 0 (Foundation)**: Syntax and ProofSystem
   - Define formulas and axioms
   - Establish proof rules

2. **Layer 1 (Semantics)**: Task frame semantics
   - Define models and truth evaluation
   - Establish validity

3. **Layer 2 (Metalogic)**: Properties of the proof system
   - Prove soundness (derivability → validity)
   - Establish completeness (validity → derivability)

4. **Layer 3 (Theorems)**: Derived results
   - Perpetuity principles
   - Modal-temporal interactions

5. **Layer 4 (Automation)**: Proof automation
   - Custom tactics for TM proofs
   - Automated proof search

## Implementation Status

**Complete (Layer 0)**:
- Syntax: Formula, Context (DSL planned)
- ProofSystem: All axioms and rules defined

**Complete (Layer 1)**:
- Semantics: TaskFrame, TaskModel, Truth, Validity

**Partial (Layer 2)**:
- Metalogic/Soundness: 5/8 axioms, 4/7 rules proven
- Metalogic/Completeness: Infrastructure only

**Partial (Layer 3)**:
- Theorems/Perpetuity: P1-P3 proven, P4-P6 partial

**Planned (Layer 4)**:
- Automation: Tactics stubs only
- Automation: ProofSearch not started

For detailed status, see [IMPLEMENTATION_STATUS.md](../Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md).

## API Documentation

For detailed API documentation:

- **Module overview**: See [Logos.lean](../Logos.lean) for top-level re-exports
- **Generated docs**: Run `lake build :docs` to generate doc-gen4 API documentation
- **Architecture guide**: [ARCHITECTURE.md](../Documentation/UserGuide/ARCHITECTURE.md) for TM logic specification
- **Code comments**: All public definitions have comprehensive docstrings

## Development Guidelines

When working on Logos source code:

- **Follow style guide**: [LEAN_STYLE_GUIDE.md](../Documentation/Development/LEAN_STYLE_GUIDE.md)
- **Write tests first**: [TESTING_STANDARDS.md](../Documentation/Development/TESTING_STANDARDS.md)
- **Document thoroughly**: Every public definition requires docstring
- **Run lint**: Zero `#lint` warnings required
- **Build successfully**: `lake build` must complete without errors

## Common Tasks

### Adding a New Definition

1. Choose appropriate module (Syntax, ProofSystem, Semantics, etc.)
2. Write comprehensive docstring
3. Implement definition
4. Add to module export list
5. Write tests in `LogosTest/`
6. Update documentation if significant

### Proving a New Theorem

1. Write theorem statement with docstring in appropriate module
2. Sketch proof strategy in comments
3. Implement proof using tactics or term-mode
4. Add example usage to `Archive/`
5. Document in relevant guide (TUTORIAL.md, EXAMPLES.md)

### Adding a New Axiom

1. Add axiom schema to `ProofSystem/Axioms.lean`
2. Add case to `DerivationTree` in `ProofSystem/Derivation.lean` (as constructor)
3. Update `height` function to handle new constructor
4. Prove validity in `Metalogic/Soundness.lean`
5. Write tests in `LogosTest/ProofSystem/`
6. Update ARCHITECTURE.md if significant

## Related Documentation

### Theory-Specific (Logos)

- [Logos Documentation](Documentation/README.md) - Theory-specific documentation hub
- [Quick Start](Documentation/UserGuide/QUICKSTART.md) - Getting started with Logos
- [Extension Stubs](Documentation/Reference/EXTENSION_STUBS.md) - Planned extensions
- [Roadmap](Documentation/ProjectInfo/ROADMAP.md) - Development timeline

### Project-Wide

- [Theory Comparison](../Documentation/Research/THEORY_COMPARISON.md) - Bimodal vs Logos
- [LEAN Style Guide](../Documentation/Development/LEAN_STYLE_GUIDE.md) - Coding conventions
- [Module Organization](../Documentation/Development/MODULE_ORGANIZATION.md) - Directory structure
- [Testing Standards](../Documentation/Development/TESTING_STANDARDS.md) - Test requirements
- [Architecture Guide](../Documentation/UserGuide/ARCHITECTURE.md) - TM logic specification
- [Tutorial](../Documentation/UserGuide/TUTORIAL.md) - Getting started
- [Implementation Status](../Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md) - Project status

## Navigation

- **Up**: [Project Root](../)
- **Theory Docs**: [Documentation/](Documentation/) - Logos-specific documentation
- **Tests**: [LogosTest/](../LogosTest/)
- **Project Docs**: [Documentation/](../Documentation/) - Project-wide documentation
- **Examples**: [Archive/](../Archive/)
