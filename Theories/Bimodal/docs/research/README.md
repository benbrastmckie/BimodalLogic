# Bimodal Research Documentation

Research and design documents for proof search automation and related features in Bimodal TM logic.

> **Parent**: [Bimodal/docs/](../README.md) | **Project Research**: [docs/research/](../../../docs/research/)

## Documents

### Proof Search Automation

#### modal-temporal-proof-search.md

Unified proof search architecture for modal and temporal logics. Covers tableau methods, sequent
calculi, and specialized strategies for box/diamond and past/future operators.

**Status**: Research complete

#### proof-search-automation.md

General proof search automation strategies including best-first search, priority queues, proof
caching, and memoization techniques for modal and temporal proof systems.

**Status**: Research complete

#### temporal-logic-automation.md

Research on temporal logic proof automation techniques, including LTL proof methods, tableau-based
decision procedures, and adaptation strategies for bimodal temporal logic.

**Status**: Research complete

### LeanSearch Integration

#### leansearch-api-specification.md

API specification for LeanSearch integration, documenting REST API endpoints, query parameters,
response formats, and integration strategies for proof search automation.

**Status**: Research complete

#### leansearch-best-first-search.md

Best-first search algorithm design for LeanSearch-based proof automation, including heuristic
evaluation, search space management, and termination criteria.

**Status**: Research complete

#### leansearch-priority-queue.md

Priority queue implementation strategies for proof search, covering heap-based queues, priority
scoring, and integration with proof search automation.

**Status**: Research complete

#### leansearch-proof-caching-memoization.md

Proof caching and memoization design for avoiding redundant proof searches, including cache
invalidation strategies and memory management.

**Status**: Research complete

## Related Documentation

- [bimodal-logic.md](../../../../docs/research/bimodal-logic.md) - Comparison with Logos
- [ARCHITECTURE.md](../user-guide/ARCHITECTURE.md) - TM logic specification
- [TACTIC_REGISTRY.md](../project-info/TACTIC_REGISTRY.md) - Tactic implementation status

## Navigation

- **Up**: [Bimodal/docs/](../README.md)
- **Project Research**: [docs/research/](../../../docs/research/)
