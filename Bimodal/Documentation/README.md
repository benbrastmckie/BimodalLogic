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

Documentation is organized into four categories:

### UserGuide/

User-facing documentation for working with Bimodal:

- [README.md](UserGuide/README.md) - Directory overview and reading order
- [QUICKSTART.md](UserGuide/QUICKSTART.md) - Getting started with Bimodal proofs
- [PROOF_PATTERNS.md](UserGuide/PROOF_PATTERNS.md) - Common proof patterns and strategies
- [ARCHITECTURE.md](UserGuide/ARCHITECTURE.md) - TM logic specification and system design
- [TUTORIAL.md](UserGuide/TUTORIAL.md) - Step-by-step tutorial
- [EXAMPLES.md](UserGuide/EXAMPLES.md) - Usage examples and proof patterns
- [TACTIC_DEVELOPMENT.md](UserGuide/TACTIC_DEVELOPMENT.md) - Custom tactic development

**Audience**: Users of the library, learners

### Reference/

Reference materials for Bimodal logic:

- [README.md](Reference/README.md) - Directory overview and quick lookup guide
- [AXIOM_REFERENCE.md](Reference/AXIOM_REFERENCE.md) - Complete axiom schemas with examples
- [TACTIC_REFERENCE.md](Reference/TACTIC_REFERENCE.md) - Bimodal-specific tactic usage
- [OPERATORS.md](Reference/OPERATORS.md) - TM operator reference and Unicode notation

**Audience**: All users

### Research/

Research and design documents for Bimodal proof automation:

- [README.md](Research/README.md) - Research overview
- [MODAL_TEMPORAL_PROOF_SEARCH.md](Research/MODAL_TEMPORAL_PROOF_SEARCH.md) - Proof search architecture
- [PROOF_SEARCH_AUTOMATION.md](Research/PROOF_SEARCH_AUTOMATION.md) - Automation strategies
- [temporal-logic-automation-research.md](Research/temporal-logic-automation-research.md) - Temporal tactics
- [LEANSEARCH_API_SPECIFICATION.md](Research/LEANSEARCH_API_SPECIFICATION.md) - LeanSearch API
- [leansearch-best-first-search.md](Research/leansearch-best-first-search.md) - Best-first search
- [leansearch-priority-queue.md](Research/leansearch-priority-queue.md) - Priority queue design
- [leansearch-proof-caching-memoization.md](Research/leansearch-proof-caching-memoization.md) - Caching

**Audience**: Researchers, contributors

### ProjectInfo/

Bimodal-specific project status:

- [README.md](ProjectInfo/README.md) - Directory overview
- [IMPLEMENTATION_STATUS.md](ProjectInfo/IMPLEMENTATION_STATUS.md) - Bimodal module status
- [KNOWN_LIMITATIONS.md](ProjectInfo/KNOWN_LIMITATIONS.md) - MVP limitations with workarounds
- [TACTIC_REGISTRY.md](ProjectInfo/TACTIC_REGISTRY.md) - Tactic implementation status

**Audience**: Contributors, maintainers

## Quick Links

Most-referenced documents:

- [Quick Start](UserGuide/QUICKSTART.md) - Get started quickly
- [Tutorial](UserGuide/TUTORIAL.md) - Step-by-step guide
- [Architecture](UserGuide/ARCHITECTURE.md) - TM logic specification
- [Axiom Reference](Reference/AXIOM_REFERENCE.md) - Axiom schemas
- [Operators](Reference/OPERATORS.md) - Operator reference
- [Implementation Status](ProjectInfo/IMPLEMENTATION_STATUS.md) - Current status
- [Known Limitations](ProjectInfo/KNOWN_LIMITATIONS.md) - MVP limitations

## Relationship to Project Documentation

**Bimodal-Specific**:
- [QUICKSTART](UserGuide/QUICKSTART.md) - Getting started with Bimodal
- [TUTORIAL](UserGuide/TUTORIAL.md) - Step-by-step tutorial
- [ARCHITECTURE](UserGuide/ARCHITECTURE.md) - TM logic specification
- [EXAMPLES](UserGuide/EXAMPLES.md) - Usage examples
- [TACTIC_DEVELOPMENT](UserGuide/TACTIC_DEVELOPMENT.md) - Custom tactics
- [AXIOM_REFERENCE](Reference/AXIOM_REFERENCE.md) - TM axiom schemas
- [OPERATORS](Reference/OPERATORS.md) - Operator reference
- [TACTIC_REGISTRY](ProjectInfo/TACTIC_REGISTRY.md) - Tactic status
- [Research/](Research/) - Proof search automation research

**Project-Wide** (in [Documentation/](../../Documentation/)):
- [STYLE_GUIDE](../../Documentation/Development/LEAN_STYLE_GUIDE.md) - Coding style
- [TESTING](../../Documentation/Development/TESTING_STANDARDS.md) - Test standards

## Navigation

- **Up**: [Bimodal/](../)
- **Project Documentation**: [Documentation/](../../Documentation/)
- **Theory Comparison**: [THEORY_COMPARISON.md](../../Documentation/Research/THEORY_COMPARISON.md)
