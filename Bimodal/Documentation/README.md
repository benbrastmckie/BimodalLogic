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

| Topic | Bimodal-Specific | Project-Wide |
|-------|------------------|--------------|
| Getting started | [QUICKSTART.md](UserGuide/QUICKSTART.md) | [TUTORIAL.md](../../Documentation/UserGuide/TUTORIAL.md) |
| Axioms | [AXIOM_REFERENCE.md](Reference/AXIOM_REFERENCE.md) | [OPERATORS.md](../../Documentation/Reference/OPERATORS.md) |
| Status | [IMPLEMENTATION_STATUS.md](ProjectInfo/IMPLEMENTATION_STATUS.md) | [IMPLEMENTATION_STATUS.md](../../Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md) |
| Style | — | [LEAN_STYLE_GUIDE.md](../../Documentation/Development/LEAN_STYLE_GUIDE.md) |
| Testing | — | [TESTING_STANDARDS.md](../../Documentation/Development/TESTING_STANDARDS.md) |

## Navigation

- **Up**: [Bimodal/](../)
- **Project Documentation**: [Documentation/](../../Documentation/)
- **Theory Comparison**: [THEORY_COMPARISON.md](../../Documentation/Research/THEORY_COMPARISON.md)
