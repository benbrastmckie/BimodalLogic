# Research Documentation

Project-wide research documents applicable to all theories in ProofChecker.

> **Theory-Specific Research**: For research specific to each logic theory, see:
> - [Logos/Documentation/Research/](../../Logos/Documentation/Research/) - Logos semantic architecture
> - [Bimodal/Documentation/Research/](../../Bimodal/Documentation/Research/) - Proof search automation

## Project-Wide Research

### Theory Foundations

#### THEORY_COMPARISON.md

Comparison of the two logical systems in ProofChecker: **Bimodal** (propositional intensional logic
with world-state primitives) and **Logos** (planned second-order hyperintensional logic with state
primitives). Covers semantic frameworks, operators, and intended applications.

**Status**: Complete
**Related**: [Bimodal README](../../Bimodal/README.md), [Logos README](../../Logos/README.md)

---

### Classical Logic and Noncomputability

#### noncomputable-research.md

Comprehensive explanation of the `noncomputable` keyword in Lean 4, covering what it means, why
definitions become noncomputable, and the relationship between classical logic and computability
in proof systems. Analyzes ProofChecker's use of classical axioms in metalogic theorems.

**Status**: Complete analysis (Task 192)
**Related**: [ADR-001-Classical-Logic-Noncomputable.md](../Architecture/ADR-001-Classical-Logic-Noncomputable.md)

#### deduction-theorem-necessity-research.md

Detailed analysis of whether the deduction theorem MUST be noncomputable in ProofChecker.
Evaluates alternatives and concludes that classical logic with noncomputable definitions is
necessary, expected, and appropriate for Hilbert-style proof systems.

**Status**: Complete analysis (Task 192)

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

Located in [Logos/Documentation/Research/](../../Logos/Documentation/Research/):

- **RECURSIVE_SEMANTICS.md** - Full Logos semantic specification
- **LAYER_EXTENSIONS.md** - Extension architecture overview
- **CONCEPTUAL_ENGINEERING.md** - Philosophical foundations

### Bimodal Research

Located in [Bimodal/Documentation/Research/](../../Bimodal/Documentation/Research/):

- **MODAL_TEMPORAL_PROOF_SEARCH.md** - Proof search architecture
- **PROOF_SEARCH_AUTOMATION.md** - Automation strategies
- **temporal-logic-automation-research.md** - Temporal tactics
- **LEANSEARCH_API_SPECIFICATION.md** - LeanSearch API
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
- **Logos Research**: [Logos/Documentation/Research/](../../Logos/Documentation/Research/)
- **Bimodal Research**: [Bimodal/Documentation/Research/](../../Bimodal/Documentation/Research/)

---

_Last updated: January 2026_
