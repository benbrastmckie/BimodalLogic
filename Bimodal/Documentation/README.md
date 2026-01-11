# Bimodal Documentation

Theory-specific documentation hub for the Bimodal TM (Tense and Modality) logic implementation.

> **Note**: For project-wide documentation applicable to all theories, see
> [Documentation/](../../Documentation/README.md).

## About Bimodal Logic

Bimodal is a **propositional intensional logic** with:

- **Semantic primitives**: World-states in a Kripke-style framework
- **Interpretation**: Sentence letters are interpreted by sets of world-states
- **Logical level**: Propositional (zeroth-order)

For comparison with the planned Logos hyperintensional logic, see
[THEORY_COMPARISON.md](../../Documentation/Research/THEORY_COMPARISON.md).

## Documentation Organization

Documentation is organized into three categories:

### UserGuide/

User-facing documentation for working with Bimodal:

- [README.md](UserGuide/README.md) - Directory overview and reading order
- [QUICKSTART.md](UserGuide/QUICKSTART.md) - Getting started with Bimodal proofs
- [PROOF_PATTERNS.md](UserGuide/PROOF_PATTERNS.md) - Common proof patterns and strategies

**Audience**: Users of the library, learners

### Reference/

Reference materials for Bimodal logic:

- [README.md](Reference/README.md) - Directory overview and quick lookup guide
- [AXIOM_REFERENCE.md](Reference/AXIOM_REFERENCE.md) - Complete axiom schemas with examples
- [TACTIC_REFERENCE.md](Reference/TACTIC_REFERENCE.md) - Bimodal-specific tactic usage

**Audience**: All users

### ProjectInfo/

Bimodal-specific project status:

- [README.md](ProjectInfo/README.md) - Directory overview
- [IMPLEMENTATION_STATUS.md](ProjectInfo/IMPLEMENTATION_STATUS.md) - Bimodal module status
- [KNOWN_LIMITATIONS.md](ProjectInfo/KNOWN_LIMITATIONS.md) - MVP limitations with workarounds

**Audience**: Contributors, maintainers

## Quick Links

Most-referenced documents:

- [Quick Start](UserGuide/QUICKSTART.md) - Get started quickly
- [Axiom Reference](Reference/AXIOM_REFERENCE.md) - Axiom schemas
- [Implementation Status](ProjectInfo/IMPLEMENTATION_STATUS.md) - Current status
- [Known Limitations](ProjectInfo/KNOWN_LIMITATIONS.md) - MVP limitations

## Relationship to Project Documentation

**Bimodal-Specific**:
- [QUICKSTART](UserGuide/QUICKSTART.md) - Getting started with Bimodal
- [AXIOM_REFERENCE](Reference/AXIOM_REFERENCE.md) - TM axiom schemas
- [STATUS](ProjectInfo/IMPLEMENTATION_STATUS.md) - Module status

**Project-Wide** (in [Documentation/](../../Documentation/)):
- [TUTORIAL](../../Documentation/UserGuide/TUTORIAL.md) - General tutorial
- [OPERATORS](../../Documentation/Reference/OPERATORS.md) - Operator reference
- [STYLE_GUIDE](../../Documentation/Development/LEAN_STYLE_GUIDE.md) - Coding style
- [TESTING](../../Documentation/Development/TESTING_STANDARDS.md) - Test standards

## Navigation

- **Up**: [Bimodal/](../)
- **Project Documentation**: [Documentation/](../../Documentation/)
- **Theory Comparison**: [THEORY_COMPARISON.md](../../Documentation/Research/THEORY_COMPARISON.md)
