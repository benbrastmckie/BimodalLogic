# Logos Documentation

Theory-specific documentation hub for the Logos second-order hyperintensional logic.

> **Note**: For project-wide documentation applicable to all theories, see
> [Documentation/](../../Documentation/README.md).

## About Logos Logic

Logos is a **planned second-order hyperintensional logic** that will extend beyond Bimodal.

| Aspect | Current State |
|--------|---------------|
| **Type** | Second-order hyperintensional logic (planned) |
| **Current status** | Re-exports Bimodal TM logic |
| **Semantic primitives** | States (more fine-grained than worlds) |
| **Logical level** | Second-order with first and second-order variables |

**Current Implementation**: Logos currently re-exports Bimodal's propositional intensional
logic. For working functionality, see [Bimodal/Documentation/](../../Bimodal/Documentation/).

For comparison with Bimodal propositional logic, see
[THEORY_COMPARISON.md](../../Documentation/Research/THEORY_COMPARISON.md).

## Documentation Organization

Documentation is organized into three categories:

### UserGuide/

User-facing documentation for working with Logos:

- [README.md](UserGuide/README.md) - Directory overview
- [QUICKSTART.md](UserGuide/QUICKSTART.md) - Getting started (redirects to Bimodal)
- [CURRENT_STATUS.md](UserGuide/CURRENT_STATUS.md) - Logos development status

**Audience**: Users of the library, learners

### Reference/

Reference materials for Logos logic:

- [README.md](Reference/README.md) - Directory overview
- [AXIOM_REFERENCE.md](Reference/AXIOM_REFERENCE.md) - Axioms (redirects to Bimodal)
- [EXTENSION_STUBS.md](Reference/EXTENSION_STUBS.md) - Planned extension modules

**Audience**: All users

### ProjectInfo/

Logos-specific project status:

- [README.md](ProjectInfo/README.md) - Directory overview
- [IMPLEMENTATION_STATUS.md](ProjectInfo/IMPLEMENTATION_STATUS.md) - Logos module status
- [KNOWN_LIMITATIONS.md](ProjectInfo/KNOWN_LIMITATIONS.md) - Current limitations
- [ROADMAP.md](ProjectInfo/ROADMAP.md) - Development roadmap

**Audience**: Contributors, maintainers

## Quick Links

Most-referenced documents:

- [Quick Start](UserGuide/QUICKSTART.md) - Get started (via Bimodal)
- [Current Status](UserGuide/CURRENT_STATUS.md) - Development status
- [Extension Stubs](Reference/EXTENSION_STUBS.md) - Planned extensions
- [Roadmap](ProjectInfo/ROADMAP.md) - Future development

## Relationship to Project Documentation

**Logos-Specific** (unique to this theory):
- [CURRENT_STATUS](UserGuide/CURRENT_STATUS.md) - Logos development status
- [EXTENSION_STUBS](Reference/EXTENSION_STUBS.md) - Planned extensions
- [ROADMAP](ProjectInfo/ROADMAP.md) - Development roadmap

**Redirects to Bimodal** (re-exported functionality):
- [QUICKSTART](UserGuide/QUICKSTART.md) → Bimodal/Documentation/UserGuide/QUICKSTART.md
- [AXIOM_REFERENCE](Reference/AXIOM_REFERENCE.md) → Bimodal axioms

**Project-Wide** (in [Documentation/](../../Documentation/)):
- [TUTORIAL](../../Documentation/UserGuide/TUTORIAL.md) - General tutorial
- [STYLE_GUIDE](../../Documentation/Development/LEAN_STYLE_GUIDE.md) - Coding style
- [TESTING](../../Documentation/Development/TESTING_STANDARDS.md) - Test standards

## Navigation

- **Up**: [Logos/](../)
- **Project Documentation**: [Documentation/](../../Documentation/)
- **Bimodal Documentation**: [Bimodal/Documentation/](../../Bimodal/Documentation/)
- **Theory Comparison**: [THEORY_COMPARISON.md](../../Documentation/Research/THEORY_COMPARISON.md)
