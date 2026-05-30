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
- [quickstart.md](user-guide/quickstart.md) - Getting started with Bimodal proofs
- [proof-patterns.md](user-guide/proof-patterns.md) - Common proof patterns and strategies
- [architecture.md](user-guide/architecture.md) - TM logic specification and system design
- [tutorial.md](user-guide/tutorial.md) - Step-by-step tutorial
- [examples.md](user-guide/examples.md) - Usage examples and proof patterns
- [tactic-development.md](user-guide/tactic-development.md) - Custom tactic development

**Audience**: Users of the library, learners

### reference/

Reference materials for Bimodal logic:

- [README.md](reference/README.md) - Directory overview and quick lookup guide
- [axiom-reference.md](reference/axiom-reference.md) - Complete axiom schemas with examples
- [tactic-reference.md](reference/tactic-reference.md) - Bimodal-specific tactic usage
- [operators.md](reference/operators.md) - TM operator reference and Unicode notation

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
- [implementation-status.md](project-info/implementation-status.md) - Bimodal module status
- [known-limitations.md](project-info/known-limitations.md) - MVP limitations with workarounds
- [tactic-registry.md](project-info/tactic-registry.md) - Tactic implementation status

**Audience**: Contributors, maintainers

## Quick Links

Most-referenced documents:

- [Quick Start](user-guide/quickstart.md) - Get started quickly
- [Tutorial](user-guide/tutorial.md) - Step-by-step guide
- [Architecture](user-guide/architecture.md) - TM logic specification
- [Axiom Reference](reference/axiom-reference.md) - Axiom schemas
- [Operators](reference/operators.md) - Operator reference
- [Implementation Status](project-info/implementation-status.md) - Current status
- [Known Limitations](project-info/known-limitations.md) - MVP limitations
- [Performance Targets](project-info/performance-targets.md) - Benchmark baselines

## Relationship to Project Documentation

**Bimodal-Specific**:
- [quickstart](user-guide/quickstart.md) - Getting started with Bimodal
- [tutorial](user-guide/tutorial.md) - Step-by-step tutorial
- [architecture](user-guide/architecture.md) - TM logic specification
- [examples](user-guide/examples.md) - Usage examples
- [tactic-development](user-guide/tactic-development.md) - Custom tactics
- [axiom-reference](reference/axiom-reference.md) - TM axiom schemas
- [operators](reference/operators.md) - Operator reference
- [tactic-registry](project-info/tactic-registry.md) - Tactic status
- [research/](research/) - Proof search automation research

**Project-Wide** (in [docs/](../../docs/)):
- [STYLE_GUIDE](../../docs/development/LEAN_STYLE_GUIDE.md) - Coding style
- [TESTING](../../docs/development/TESTING_STANDARDS.md) - Test standards

## Navigation

- **Up**: [Bimodal/](../)
- **Project Documentation**: [docs/](../../docs/)
- **Theory Comparison**: [bimodal-logic.md](../../../docs/research/bimodal-logic.md)
