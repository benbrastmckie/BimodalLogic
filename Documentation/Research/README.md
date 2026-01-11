# Research Documentation

Project-wide research documents applicable to all theories in ProofChecker.

**Audience**: Researchers, architects, contributors interested in design decisions

> **Theory-Specific Research**: For research specific to each logic theory, see:
> - [Logos/Documentation/Research/](../../Theories/Logos/Documentation/Research/) - Logos semantic architecture
> - [Bimodal/Documentation/Research/](../../Theories/Bimodal/Documentation/Research/) - Proof search automation

## Project-Wide Research

### Theory Foundations

#### theory-comparison.md

Comparison of the two logical systems in ProofChecker: **Bimodal** (propositional intensional logic
with world-state primitives) and **Logos** (planned second-order hyperintensional logic with state
primitives). Covers semantic frameworks, operators, and intended applications.

**Status**: Complete
**Related**: [Bimodal README](../../Theories/Bimodal/README.md), [Logos README](../../Theories/Logos/README.md)

---

### Classical Logic and Noncomputability

#### noncomputable.md

Comprehensive explanation of the `noncomputable` keyword in Lean 4, covering what it means, why
definitions become noncomputable, and the relationship between classical logic and computability
in proof systems. Analyzes ProofChecker's use of classical axioms in metalogic theorems.

**Status**: Complete analysis (Task 192)
**Related**: [ADR-001-Classical-Logic-Noncomputable.md](../Architecture/ADR-001-Classical-Logic-Noncomputable.md)

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
**Related**: [TESTING_STANDARDS.md](../Development/TESTING_STANDARDS.md)

---

## Theory-Specific Research

Research specific to individual theories has been moved to theory directories:

### Logos Research

Located in [Logos/Documentation/Research/](../../Theories/Logos/Documentation/Research/):

- **recursive-semantics.md** - Full Logos semantic specification
- **layer-extensions.md** - Extension architecture overview
- **conceptual-engineering.md** - Philosophical foundations

### Bimodal Research

Located in [Bimodal/Documentation/Research/](../../Theories/Bimodal/Documentation/Research/):

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
- [ADR-001-Classical-Logic-Noncomputable.md](../Architecture/ADR-001-Classical-Logic-Noncomputable.md)

### Development Standards
- [NONCOMPUTABLE_GUIDE.md](../Development/NONCOMPUTABLE_GUIDE.md) - Noncomputable handling
- [TESTING_STANDARDS.md](../Development/TESTING_STANDARDS.md) - Test requirements

## Navigation

- **Up**: [Documentation/](../README.md)
- **Logos Research**: [Logos/Documentation/Research/](../../Theories/Logos/Documentation/Research/)
- **Bimodal Research**: [Bimodal/Documentation/Research/](../../Theories/Bimodal/Documentation/Research/)

---

_Last updated: January 2026_
