# Research Documentation

Project-wide research documents applicable to ProofChecker.

**Audience**: Researchers, architects, contributors interested in design decisions

## Implementation Status

| Theory | Status | Description |
|--------|--------|-------------|
| **Bimodal** | Complete | Production-ready with soundness/completeness proofs |

> **Theory-Specific Research**: For research specific to the bimodal logic theory, see:
> - [docs/research/](.) - Proof search automation (complete implementation)

## Project-Wide Research

### Theory Foundations

#### BIMODAL_LOGIC.md

Authoritative presentation of Bimodal, a complete propositional intensional logic combining S5 modal
and linear temporal operators with **verified soundness and completeness proofs**. Includes comprehensive
operator and axiom coverage, perpetuity principles, and theoretical foundations.

**Status**: Complete (production-ready implementation)
**Related**: [Bimodal README](../../FormalSystem/README.md)

---

### Classical Logic and Noncomputability

#### NONCOMPUTABLE.md

Comprehensive explanation of the `noncomputable` keyword in Lean 4, covering what it means, why
definitions become noncomputable, and the relationship between classical logic and computability
in proof systems. Analyzes ProofChecker's use of classical axioms in metalogic theorems.

**Status**: Complete analysis (Task 192)
**Related**: [ADR-001-Classical-Logic-Noncomputable.md](../architecture/ADR-001-Classical-Logic-Noncomputable.md)

#### DEDUCTION_THEOREM_NECESSITY.md

Detailed analysis of whether the deduction theorem MUST be noncomputable in ProofChecker.
Evaluates alternatives and concludes that classical logic with noncomputable definitions is
necessary, expected, and appropriate for Hilbert-style proof systems.

**Status**: Complete analysis (Task 192)

---

### Dataset and Competitive Analysis

#### competitive-landscape.md

Detailed competitive landscape analysis of the BMLogic-Bench dataset relative to formal reasoning
benchmarks. Includes a 13-dimension feature comparison matrix covering 12 benchmarks, novelty
assessment, gap analysis, and enhancement roadmap (R1–R7).

**Status**: Complete analysis
**Related**: [data/README.md](../../data/README.md), [data/dataset-card.md](../../data/dataset-card.md)

---

### AI Training Architecture

#### DUAL_VERIFICATION.md

Training architecture using dual verification combining proof-checker (syntactic verification via
LEAN) with model-checker (semantic verification via Z3). Describes how complementary verification
systems generate unlimited training data for reinforcement learning without human annotation.

**Status**: Research vision

#### PROOF_LIBRARY_DESIGN.md

Theorem caching and pattern matching design enabling computational scaling through cached
verification patterns. Supports incremental learning from simple to complex theorems.

**Status**: Planned architecture

---

### Testing Research

#### PROPERTY_BASED_TESTING_LEAN4.md

Comprehensive research on property-based testing in Lean 4, covering LeanCheck framework, random
testing, generators for custom types, and integration with ProofChecker's formula and derivation
types.

**Status**: Research complete (Task 199)
**Related**: [TESTING_STANDARDS.md](../development/TESTING_STANDARDS.md)

---

## Theory-Specific Research

Research specific to Bimodal has been moved to the theory directory:

### Bimodal Research

Located in [docs/research/](.):

- **modal-temporal-proof-search.md** - Proof search architecture
- **proof-search-automation.md** - Automation strategies
- **temporal-logic-automation.md** - Temporal tactics
- **leansearch-api-specification.md** - LeanSearch API
- **leansearch-best-first-search.md** - Best-first search
- **leansearch-priority-queue.md** - Priority queue design
- **leansearch-proof-caching-memoization.md** - Caching design

---

## Related Documentation

### Architecture Decisions
- [ADR-001-Classical-Logic-Noncomputable.md](../architecture/ADR-001-Classical-Logic-Noncomputable.md)

### Development Standards
- [NONCOMPUTABLE_GUIDE.md](../development/NONCOMPUTABLE_GUIDE.md) - Noncomputable handling
- [TESTING_STANDARDS.md](../development/TESTING_STANDARDS.md) - Test requirements

## Navigation

- **Up**: [docs/](../README.md)
- **Bimodal Research**: [docs/research/](.)

---

_Last updated: March 2026_

---

## Merged from the Lean source tree

The `docs/` tree was folded into this one. Previously the repository
carried two parallel `docs/` trees, and this file cross-linked into the other via
`docs/...` — an incoherence that the merge removes. The index below
came from the source-tree copy of this file; its entries now refer to files in this
directory.

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
- [architecture.md](../user-guide/architecture.md) - TM logic specification
- [tactic-registry.md](../project-info/tactic-registry.md) - Tactic implementation status

## Navigation

- **Up**: [Bimodal/docs/](../README.md)
- **Project Research**: [docs/research/](../../../docs/research/)
