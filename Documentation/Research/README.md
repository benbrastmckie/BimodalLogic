# Research Documentation

This directory contains research vision documents describing planned features and future directions for Logos. For current implementation progress, see [IMPLEMENTATION_STATUS.md](../ProjectInfo/IMPLEMENTATION_STATUS.md).

## Documents

### Noncomputable Logic Research

#### noncomputable-research.md

Comprehensive explanation of the `noncomputable` keyword in Lean 4, covering what it means, why definitions become noncomputable, and the relationship between classical logic and computability in proof systems. Analyzes ProofChecker's use of classical axioms in metalogic theorems like the deduction theorem.

**Status**: Complete analysis (Task 192)  
**Related**: [ADR-001-Classical-Logic-Noncomputable.md](../Architecture/ADR-001-Classical-Logic-Noncomputable.md), [NONCOMPUTABLE_GUIDE.md](../Development/NONCOMPUTABLE_GUIDE.md)

#### deduction-theorem-necessity-research.md

Detailed analysis of whether the deduction theorem MUST be noncomputable in ProofChecker. Evaluates alternatives (constructive logic, Curry-Howard encoding, quotient types) and concludes that classical logic with noncomputable definitions is necessary, expected, and appropriate for Hilbert-style proof systems.

**Status**: Complete analysis (Task 192)  
**Related**: [ADR-001-Classical-Logic-Noncomputable.md](../Architecture/ADR-001-Classical-Logic-Noncomputable.md)

---

### DUAL_VERIFICATION.md

Training architecture using dual verification combining proof-checker (syntactic verification via LEAN) with model-checker (semantic verification via Z3). Describes how complementary verification systems generate unlimited training data for reinforcement learning without human annotation.

**Status**: Research vision

### PROOF_LIBRARY_DESIGN.md

Theorem caching and pattern matching design enabling computational scaling through cached verification patterns. Describes how proof library provides instant positive RL signals, reduces computational overhead, and supports incremental learning from simple to complex theorems.

**Status**: Planned architecture

### CONCEPTUAL_ENGINEERING.md

Philosophical foundations explaining why tense and historical modalities are essential for reasoning about future contingency and planning under uncertainty. Presents formal logic as conceptual engineering—a normative science for stipulating operators fit for AI reasoning—and explains how the Core Layer (tense and modality) enables progressive extension to explanatory, epistemic, and normative reasoning.

**Status**: Research vision

### LAYER_EXTENSIONS.md

Specifications for Layers 1-3 operator extensions building on Core Layer (Layer 0):
- Layer 1 (Explanatory): Counterfactual, constitutive, causal operators
- Layer 2 (Epistemic): Belief, probability, knowledge operators
- Layer 3 (Normative): Obligation, permission, preference operators

**Status**: Future development roadmap

---

### Proof Search and Automation Research

#### LEANSEARCH_API_SPECIFICATION.md

API specification for LeanSearch integration, a semantic search tool for Lean 4 mathlib and other libraries. Documents REST API endpoints, query parameters, response formats, and integration strategies for proof search automation.

**Status**: Research complete  
**Related**: [PROOF_SEARCH_AUTOMATION.md](PROOF_SEARCH_AUTOMATION.md), [MODAL_TEMPORAL_PROOF_SEARCH.md](MODAL_TEMPORAL_PROOF_SEARCH.md)

#### temporal-logic-automation-research.md

Research on temporal logic proof automation techniques, including LTL (Linear Temporal Logic) proof methods, tableau-based decision procedures, and adaptation strategies for ProofChecker's bimodal temporal logic.

**Status**: Research complete  
**Related**: [MODAL_TEMPORAL_PROOF_SEARCH.md](MODAL_TEMPORAL_PROOF_SEARCH.md)

#### MODAL_TEMPORAL_PROOF_SEARCH.md

Unified proof search architecture for modal and temporal logics, combining LeanSearch integration, proof caching, and specialized tactics for box/diamond and past/future operators.

**Status**: Research vision  
**Related**: [PROOF_SEARCH_AUTOMATION.md](PROOF_SEARCH_AUTOMATION.md)

#### PROOF_SEARCH_AUTOMATION.md

General proof search automation strategies including best-first search, priority queues, proof caching, and memoization techniques applicable to modal and temporal proof systems.

**Status**: Research complete  
**Related**: [leansearch-best-first-search.md](leansearch-best-first-search.md), [leansearch-priority-queue.md](leansearch-priority-queue.md)

#### leansearch-best-first-search.md

Best-first search algorithm design for LeanSearch-based proof automation, including heuristic evaluation, search space management, and termination criteria.

**Status**: Research complete

#### leansearch-priority-queue.md

Priority queue implementation strategies for proof search, covering heap-based queues, priority scoring, and integration with proof search automation.

**Status**: Research complete

#### leansearch-proof-caching-memoization.md

Proof caching and memoization design for avoiding redundant proof searches, including cache invalidation strategies and memory management.

**Status**: Research complete

---

### Testing and Quality Assurance

#### property-based-testing-lean4.md

Comprehensive research on property-based testing in Lean 4, covering LeanCheck framework, random testing, generators for custom types, and integration with ProofChecker's formula and derivation types.

**Status**: Research complete (Task 199)  
**Related**: [TESTING_STANDARDS.md](../Development/TESTING_STANDARDS.md), [PROPERTY_TESTING_GUIDE.md](../Development/PROPERTY_TESTING_GUIDE.md)

## Related Documentation

### Architecture Decisions
- [ADR-001-Classical-Logic-Noncomputable.md](../Architecture/ADR-001-Classical-Logic-Noncomputable.md) - Decision to use classical logic for metalogic

### User Documentation
- [METHODOLOGY.md](../UserGuide/METHODOLOGY.md) - Philosophical foundations and layer overview
- [ARCHITECTURE.md](../UserGuide/ARCHITECTURE.md) - Layer 0 (Core TM) technical specification
- [TUTORIAL.md](../UserGuide/TUTORIAL.md) - Getting started guide
- [EXAMPLES.md](../UserGuide/EXAMPLES.md) - Usage examples

### Project Information
- [IMPLEMENTATION_STATUS.md](../ProjectInfo/IMPLEMENTATION_STATUS.md) - Module-by-module status tracking
- [IMPLEMENTATION_STATUS.md - Known Limitations](../ProjectInfo/IMPLEMENTATION_STATUS.md#known-limitations) - Gaps and workarounds
- [CONTRIBUTING.md](../Development/CONTRIBUTING.md) - Contribution guidelines

### Development Standards
- [LEAN_STYLE_GUIDE.md](../Development/LEAN_STYLE_GUIDE.md) - Coding conventions
- [NONCOMPUTABLE_GUIDE.md](../Development/NONCOMPUTABLE_GUIDE.md) - Complete noncomputable catalog and guidelines
- [MODULE_ORGANIZATION.md](../Development/MODULE_ORGANIZATION.md) - Directory structure
- [TESTING_STANDARDS.md](../Development/TESTING_STANDARDS.md) - Test requirements
- [PROPERTY_TESTING_GUIDE.md](../Development/PROPERTY_TESTING_GUIDE.md) - Property-based testing guide

## Navigation

- [Documentation Index](../README.md) - Complete documentation overview
- [Project Root](../../README.md) - Logos repository root

---

_Last updated: December 2025_
