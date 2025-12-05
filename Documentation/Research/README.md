# Research Documentation

This directory contains research vision documents describing planned features and future directions for Logos. For current implementation progress, see [IMPLEMENTATION_STATUS.md](../ProjectInfo/IMPLEMENTATION_STATUS.md).

## Status Legend

Documents in this directory describe planned or research-phase work. The following conventions clarify implementation status:

- **Implemented**: Feature available in Logos - see [IMPLEMENTATION_STATUS.md](../ProjectInfo/IMPLEMENTATION_STATUS.md)
- **Research**: Planned architecture in design phase
- **Roadmap**: Future development planned

All documents in this directory link to [IMPLEMENTATION_STATUS.md](../ProjectInfo/IMPLEMENTATION_STATUS.md) for current progress on related components.

## Documents

### DUAL_VERIFICATION.md

Training architecture using dual verification combining proof-checker (syntactic verification via LEAN) with model-checker (semantic verification via Z3). Describes how complementary verification systems generate unlimited training data for reinforcement learning without human annotation.

**Status**: Research vision

**Implementation Progress**: See [IMPLEMENTATION_STATUS.md](../ProjectInfo/IMPLEMENTATION_STATUS.md) for Layer 0 (Core TM) proof-checker implementation status.

### PROOF_LIBRARY_DESIGN.md

Theorem caching and pattern matching design enabling computational scaling through cached verification patterns. Describes how proof library provides instant positive RL signals, reduces computational overhead, and supports incremental learning from simple to complex theorems.

**Status**: Planned architecture

**Implementation Progress**: See [IMPLEMENTATION_STATUS.md](../ProjectInfo/IMPLEMENTATION_STATUS.md) for proof system implementation status.

### LAYER_EXTENSIONS.md

Specifications for Layers 1-3 operator extensions building on Core Layer (Layer 0):
- Layer 1 (Explanatory): Counterfactual, constitutive, causal operators
- Layer 2 (Epistemic): Belief, probability, knowledge operators
- Layer 3 (Normative): Obligation, permission, preference operators

**Status**: Future development roadmap

**Implementation Progress**: See [IMPLEMENTATION_STATUS.md](../ProjectInfo/IMPLEMENTATION_STATUS.md) for Layer 0 completion and planning for Layers 1-3.

## Related Documentation

### User Documentation
- [METHODOLOGY.md](../UserGuide/METHODOLOGY.md) - Philosophical foundations and layer overview
- [ARCHITECTURE.md](../UserGuide/ARCHITECTURE.md) - Layer 0 (Core TM) technical specification
- [TUTORIAL.md](../UserGuide/TUTORIAL.md) - Getting started guide
- [EXAMPLES.md](../UserGuide/EXAMPLES.md) - Usage examples

### Project Information
- [IMPLEMENTATION_STATUS.md](../ProjectInfo/IMPLEMENTATION_STATUS.md) - Module-by-module status tracking
- [IMPLEMENTATION_STATUS.md - Known Limitations](../ProjectInfo/IMPLEMENTATION_STATUS.md#known-limitations) - Gaps and workarounds
- [CONTRIBUTING.md](../ProjectInfo/CONTRIBUTING.md) - Contribution guidelines

### Development Standards
- [LEAN_STYLE_GUIDE.md](../Development/LEAN_STYLE_GUIDE.md) - Coding conventions
- [MODULE_ORGANIZATION.md](../Development/MODULE_ORGANIZATION.md) - Directory structure
- [TESTING_STANDARDS.md](../Development/TESTING_STANDARDS.md) - Test requirements

## Navigation

- [Documentation Index](../README.md) - Complete documentation overview
- [Project Root](../../README.md) - Logos repository root

---

_Last updated: December 2025_
