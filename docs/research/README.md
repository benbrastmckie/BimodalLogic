# Research Documentation

Project-wide research documents applicable to ProofChecker.

**Audience**: Researchers, architects, contributors interested in design decisions

## Implementation Status

| Theory | Status | Description |
|--------|--------|-------------|
| **Bimodal** | Complete | Production-ready with soundness/completeness proofs |

> **Theory-Specific Research**: For research specific to the bimodal logic theory, see:
> - [Theories/Bimodal/docs/research/](../../Theories/Bimodal/docs/research/) - Proof search automation (complete implementation)

## Project-Wide Research

### Theory Foundations

#### BIMODAL_LOGIC.md

Authoritative presentation of Bimodal, a complete propositional intensional logic combining S5 modal
and linear temporal operators with **verified soundness and completeness proofs**. Includes comprehensive
operator and axiom coverage, perpetuity principles, and theoretical foundations.

**Status**: Complete (production-ready implementation)
**Related**: [Bimodal README](../../Theories/Bimodal/README.md)

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

Located in [Theories/Bimodal/docs/research/](../../Theories/Bimodal/docs/research/):

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
- **Bimodal Research**: [Theories/Bimodal/docs/research/](../../Theories/Bimodal/docs/research/)

---

_Last updated: March 2026_
