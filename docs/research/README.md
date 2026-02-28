# Research Documentation

Project-wide research documents applicable to all theories in ProofChecker.

**Audience**: Researchers, architects, contributors interested in design decisions

## Implementation Status

| Theory | Status | Description |
|--------|--------|-------------|
| **Bimodal** | Complete | Production-ready with soundness/completeness proofs |
| **Logos** | Research | Hyperintensional extensions (roadmap) |

> **Theory-Specific Research**: For research specific to each logic theory, see:
> - [Bimodal/docs/research/](../../Theories/Bimodal/docs/research/) - Proof search automation (complete implementation)
> - [Logos/docs/research/](../../Theories/Logos/docs/research/) - Logos semantic architecture (research roadmap)

## Project-Wide Research

### Theory Foundations

#### bimodal-logic.md

Authoritative presentation of Bimodal, a complete propositional intensional logic combining S5 modal
and linear temporal operators with **verified soundness and completeness proofs**. Includes comprehensive
operator and axiom coverage, perpetuity principles, and a comparison section with Logos research roadmap.

**Status**: Complete (production-ready implementation)
**Related**: [Bimodal README](../../Theories/Bimodal/README.md), [Logos README](../../Theories/Logos/README.md)

---

### Classical Logic and Noncomputability

#### noncomputable.md

Comprehensive explanation of the `noncomputable` keyword in Lean 4, covering what it means, why
definitions become noncomputable, and the relationship between classical logic and computability
in proof systems. Analyzes ProofChecker's use of classical axioms in metalogic theorems.

**Status**: Complete analysis (Task 192)
**Related**: [ADR-001-Classical-Logic-Noncomputable.md](../architecture/ADR-001-Classical-Logic-Noncomputable.md)

#### deduction-theorem-necessity.md

Detailed analysis of whether the deduction theorem MUST be noncomputable in ProofChecker.
Evaluates alternatives and concludes that classical logic with noncomputable definitions is
necessary, expected, and appropriate for Hilbert-style proof systems.

**Status**: Complete analysis (Task 192)

---

### AI Training Architecture

#### dual-verification.md

Training architecture using dual verification combining proof-checker (syntactic verification via
LEAN) with model-checker (semantic verification via Z3). Describes how complementary verification
systems generate unlimited training data for reinforcement learning without human annotation.

**Status**: Research vision

#### proof-library-design.md

Theorem caching and pattern matching design enabling computational scaling through cached
verification patterns. Supports incremental learning from simple to complex theorems.

**Status**: Planned architecture

---

### Testing Research

#### property-based-testing-lean4.md

Comprehensive research on property-based testing in Lean 4, covering LeanCheck framework, random
testing, generators for custom types, and integration with ProofChecker's formula and derivation
types.

**Status**: Research complete (Task 199)
**Related**: [TESTING_STANDARDS.md](../development/TESTING_STANDARDS.md)

---

## Theory-Specific Research

Research specific to individual theories has been moved to theory directories:

### Logos Research

Located in [Logos/docs/research/](../../Theories/Logos/docs/research/):

- **recursive-semantics.md** - Full Logos semantic specification
- **layer-extensions.md** - Extension architecture overview
- **conceptual-engineering.md** - Philosophical foundations

### Bimodal Research

Located in [Bimodal/docs/research/](../../Theories/Bimodal/docs/research/):

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
- **Logos Research**: [Logos/docs/research/](../../Theories/Logos/docs/research/)
- **Bimodal Research**: [Bimodal/docs/research/](../../Theories/Bimodal/docs/research/)

---

_Last updated: January 2026_
