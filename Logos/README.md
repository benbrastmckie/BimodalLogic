# Logos Source

Main source directory for the Logos TM logic implementation.

## Purpose

This directory contains the core implementation of the bimodal logic TM (Tense and Modality) proof system with task semantics, including syntax, proof rules, semantic models, metalogical properties, and automation.

## Submodules

- **Syntax/**: Formula types and proof contexts
  - Formula inductive type (atom, bot, imp, box, past, future)
  - Context type for proof premises
  - DSL for readable formula construction (planned)

- **ProofSystem/**: Axioms and inference rules
  - 8 TM axiom schemata (MT, M4, MB, T4, TA, TL, MF, TF)
  - 7 inference rules (MP, MK, TK, TD, plus structural rules)
  - Derivability relation

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
- **Inference Rules**: `ProofSystem/Derivation.lean` - Derivability and rules
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
2. Add case to `Derivable` in `ProofSystem/Derivation.lean`
3. Prove validity in `Metalogic/Soundness.lean`
4. Write tests in `LogosTest/ProofSystem/`
5. Update ARCHITECTURE.md if significant

## Related Documentation

- [LEAN Style Guide](../Documentation/Development/LEAN_STYLE_GUIDE.md) - Coding conventions
- [Module Organization](../Documentation/Development/MODULE_ORGANIZATION.md) - Directory structure
- [Testing Standards](../Documentation/Development/TESTING_STANDARDS.md) - Test requirements
- [Architecture Guide](../Documentation/UserGuide/ARCHITECTURE.md) - TM logic specification
- [Tutorial](../Documentation/UserGuide/TUTORIAL.md) - Getting started
- [Implementation Status](../Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md) - Current status

## Navigation

- **Up**: [Logos Root](../)
- **Tests**: [LogosTest/](../LogosTest/)
- **Documentation**: [Documentation/](../Documentation/)
- **Examples**: [Archive/](../Archive/)
