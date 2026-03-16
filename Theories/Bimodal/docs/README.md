# Bimodal Documentation

Theory-specific documentation hub for the Bimodal TM (Tense and Modality) logic implementation.

> **Note**: For project-wide documentation applicable to all theories, see
> [docs/](../../docs/README.md).

## About Bimodal Logic

Bimodal is a **propositional intensional logic** with:

- **Semantic primitives**: World-states in a Kripke-style framework
- **Interpretation**: Sentence letters are interpreted by sets of world-states
- **Logical level**: Propositional (zeroth-order)

For comparison with the planned Logos hyperintensional logic, see
[bimodal-logic.md](../../../docs/research/bimodal-logic.md).

## Documentation Organization

Documentation is organized into four categories:

### user-guide/

User-facing documentation for working with Bimodal:

- [README.md](user-guide/README.md) - Directory overview and reading order
- [QUICKSTART.md](user-guide/QUICKSTART.md) - Getting started with Bimodal proofs
- [PROOF_PATTERNS.md](user-guide/PROOF_PATTERNS.md) - Common proof patterns and strategies
- [ARCHITECTURE.md](user-guide/ARCHITECTURE.md) - TM logic specification and system design
- [TUTORIAL.md](user-guide/TUTORIAL.md) - Step-by-step tutorial
- [EXAMPLES.md](user-guide/EXAMPLES.md) - Usage examples and proof patterns
- [TACTIC_DEVELOPMENT.md](user-guide/TACTIC_DEVELOPMENT.md) - Custom tactic development

**Audience**: Users of the library, learners

### reference/

Reference materials for Bimodal logic:

- [README.md](reference/README.md) - Directory overview and quick lookup guide
- [AXIOM_REFERENCE.md](reference/AXIOM_REFERENCE.md) - Complete axiom schemas with examples
- [TACTIC_REFERENCE.md](reference/TACTIC_REFERENCE.md) - Bimodal-specific tactic usage
- [OPERATORS.md](reference/OPERATORS.md) - TM operator reference and Unicode notation

**Audience**: All users

### research/

Research and design documents for Bimodal proof automation:

- [README.md](research/README.md) - Research overview
- [modal-temporal-proof-search.md](research/modal-temporal-proof-search.md) - Proof search architecture
- [proof-search-automation.md](research/proof-search-automation.md) - Automation strategies
- [temporal-logic-automation.md](research/temporal-logic-automation.md) - Temporal tactics
- [leansearch-api-specification.md](research/leansearch-api-specification.md) - LeanSearch API
- [leansearch-best-first-search.md](research/leansearch-best-first-search.md) - Best-first search
- [leansearch-priority-queue.md](research/leansearch-priority-queue.md) - Priority queue design
- [leansearch-proof-caching-memoization.md](research/leansearch-proof-caching-memoization.md) - Caching

**Audience**: Researchers, contributors

### project-info/

Bimodal-specific project status:

- [README.md](project-info/README.md) - Directory overview
- [IMPLEMENTATION_STATUS.md](project-info/IMPLEMENTATION_STATUS.md) - Bimodal module status
- [KNOWN_LIMITATIONS.md](project-info/KNOWN_LIMITATIONS.md) - MVP limitations with workarounds
- [TACTIC_REGISTRY.md](project-info/TACTIC_REGISTRY.md) - Tactic implementation status

**Audience**: Contributors, maintainers

## Quick Links

Most-referenced documents:

- [Quick Start](user-guide/QUICKSTART.md) - Get started quickly
- [Tutorial](user-guide/TUTORIAL.md) - Step-by-step guide
- [Architecture](user-guide/ARCHITECTURE.md) - TM logic specification
- [Axiom Reference](reference/AXIOM_REFERENCE.md) - Axiom schemas
- [Operators](reference/OPERATORS.md) - Operator reference
- [Implementation Status](project-info/IMPLEMENTATION_STATUS.md) - Current status
- [Known Limitations](project-info/KNOWN_LIMITATIONS.md) - MVP limitations
- [Performance Targets](project-info/PERFORMANCE_TARGETS.md) - Benchmark baselines

## Relationship to Project Documentation

**Bimodal-Specific**:
- [QUICKSTART](user-guide/QUICKSTART.md) - Getting started with Bimodal
- [TUTORIAL](user-guide/TUTORIAL.md) - Step-by-step tutorial
- [ARCHITECTURE](user-guide/ARCHITECTURE.md) - TM logic specification
- [EXAMPLES](user-guide/EXAMPLES.md) - Usage examples
- [TACTIC_DEVELOPMENT](user-guide/TACTIC_DEVELOPMENT.md) - Custom tactics
- [AXIOM_REFERENCE](reference/AXIOM_REFERENCE.md) - TM axiom schemas
- [OPERATORS](reference/OPERATORS.md) - Operator reference
- [TACTIC_REGISTRY](project-info/TACTIC_REGISTRY.md) - Tactic status
- [research/](research/) - Proof search automation research

**Project-Wide** (in [docs/](../../docs/)):
- [STYLE_GUIDE](../../docs/development/LEAN_STYLE_GUIDE.md) - Coding style
- [TESTING](../../docs/development/TESTING_STANDARDS.md) - Test standards

## Navigation

- **Up**: [Bimodal/](../)
- **Project Documentation**: [docs/](../../docs/)
- **Theory Comparison**: [bimodal-logic.md](../../../docs/research/bimodal-logic.md)
