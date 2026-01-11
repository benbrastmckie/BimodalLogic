# Proof-Checker Documentation Suite

## Documentation Suite Overview

This directory contains comprehensive technical documentation for the proof-checker repository, focusing on two key architectural innovations: **dual verification training** and **Logos extensibility**. The documentation suite characterizes how proof-checker provides verified AI reasoning through LEAN-based formal verification while model-checker provides complementary semantic verification through Z3-based model checking, creating infinite clean training data for reinforcement learning without human annotation.

The proof-checker implements the Logos formal language of thought, designed with progressive extensibility from a Core Layer (Boolean, modal, temporal operators) through three semantic extensions (Explanatory, Epistemic, Normative) that can be added in any combination to support domain-specific reasoning requirements.

**Target Audience**: This documentation suite serves AI safety researchers, logic researchers, software engineers, and domain experts seeking to understand verified AI reasoning through dual verification architecture.

**Documentation Focus**: These documents emphasize proof-checker as the primary package with model-checker as a complementary verification system.

## Quick Navigation

### Core Documentation Files

**[RL_TRAINING.md](RL_TRAINING.md)** - Dual Verification Training Architecture

Comprehensive documentation of the reinforcement learning training loop architecture, explaining how proof-checker generates positive RL signals through LEAN proof receipts and model-checker generates negative RL signals through Z3 counterexamples. Includes detailed explanation of infinite clean training data from axiomatic systems, training loop flow diagrams, and worked examples demonstrating proof construction and countermodel generation.

**Key Topics**:
- Dual verification architecture (syntax verification + semantic verification)
- Positive RL signals from proof receipts
- Negative RL signals from counterexamples
- Infinite clean training data from axiomatic systems
- Training loop integration and coordination
- Worked examples with simple theorems

**[LOGOS_LAYERS.md](LOGOS_LAYERS.md)** - Progressive Operator Extensibility

Complete documentation of the Logos formal language architecture, describing the Core Layer (Layer 0) implementing Boolean, modal, and temporal operators, plus three semantic extensions that can be added progressively: Explanatory Extension (Layer 1: counterfactual, constitutive, causal operators), Epistemic Extension (Layer 2: belief, probability, knowledge operators), and Normative Extension (Layer 3: obligation, permission, preference operators). Includes operator catalog, combination principles, concrete application examples from medical, legal, and multi-agent domains, and development roadmap.

**Key Topics**:
- Core Layer (Layer 0): TM logic implementation
- Explanatory Extension (Layer 1): Counterfactual reasoning
- Epistemic Extension (Layer 2): Belief and knowledge
- Normative Extension (Layer 3): Obligation and preference
- Combination principles and extensibility methodology
- Application examples across domains

**[PROOF_LIBRARY.md](PROOF_LIBRARY.md)** - Theorem Caching and Fast Inference

Documentation of the proof library architecture enabling computational scaling through theorem caching, pattern matching, and fast inference lookup. Explains how cached verification patterns support incremental learning from simple to complex theorems, provide instant positive RL signals, and reduce computational overhead through reuse of proven theorems.

**Key Topics**:
- Library architecture and theorem registry
- Pattern matching for theorem lookup
- Benefits for RL training efficiency
- Integration with proof-checker workflow
- Common theorem patterns and examples
- Performance characteristics and scaling

## Target Audience

### AI Safety Researchers

Focus on dual verification training architecture and how proof-checker enables verified AI reasoning through mathematical certainty. Start with [RL_TRAINING.md](RL_TRAINING.md) to understand the training loop, then explore [PROOF_LIBRARY.md](PROOF_LIBRARY.md) for scaling considerations.

**Recommended Reading Order**:
1. RL_TRAINING.md - Understand dual verification and training signals
2. PROOF_LIBRARY.md - Learn about computational scaling
3. LOGOS_LAYERS.md - Explore extensibility for domain-specific applications

### Logic Researchers

Focus on Logos formal language architecture and progressive extensibility from Core Layer through semantic extensions. Start with [LOGOS_LAYERS.md](LOGOS_LAYERS.md) to understand the operator catalog and layer structure, then explore [RL_TRAINING.md](RL_TRAINING.md) for proof-theoretic foundations.

**Recommended Reading Order**:
1. LOGOS_LAYERS.md - Explore formal language architecture
2. RL_TRAINING.md - Understand proof construction and verification
3. PROOF_LIBRARY.md - Learn about theorem organization

### Software Engineers

Focus on implementation architecture, integration patterns, and workflow. Start with [RL_TRAINING.md](RL_TRAINING.md) for system overview, then explore [PROOF_LIBRARY.md](PROOF_LIBRARY.md) for caching architecture.

**Recommended Reading Order**:
1. RL_TRAINING.md - Understand overall system architecture
2. PROOF_LIBRARY.md - Learn about library integration
3. LOGOS_LAYERS.md - Understand operator implementation requirements

### Domain Experts

Focus on application examples demonstrating how Logos extensions support domain-specific reasoning. Start with [LOGOS_LAYERS.md](LOGOS_LAYERS.md) to see medical planning (Layer 1), legal reasoning (Layer 2), and multi-agent negotiation (Layer 3) examples.

**Recommended Reading Order**:
1. LOGOS_LAYERS.md - Explore domain-specific examples
2. RL_TRAINING.md - Understand verification process
3. PROOF_LIBRARY.md - Learn about theorem reuse

## Key Concepts

### Dual Verification

The proof-checker architecture combines syntactic verification through LEAN proof-checking with semantic verification through Z3 model-checking, creating complementary training signals:

- **Syntactic Verification**: LEAN proof-checker attempts to construct formal proofs for candidate inferences from axiom schemata and inference rules
- **Semantic Verification**: Z3 model-checker searches for countermodels in finite state spaces to validate or refute inferences
- **Complementary Signals**: Proof receipts provide positive reinforcement, counterexamples provide corrective feedback
- **Self-Supervised Learning**: No human annotation required - verification systems generate training signals automatically

### Logos Extensibility

The Logos formal language follows a progressive operator methodology enabling domain-specific customization:

- **Core Layer (Layer 0)**: Boolean, modal, temporal operators providing foundational reasoning (TM logic implementation)
- **Explanatory Extension (Layer 1)**: Counterfactual, constitutive, causal operators for causal reasoning
- **Epistemic Extension (Layer 2)**: Belief, probability, knowledge operators for uncertainty reasoning
- **Normative Extension (Layer 3)**: Obligation, permission, preference operators for ethical reasoning
- **Combination Principle**: Any combination of extensions can be added to Core Layer
- **Future Extensions**: New operator families can be added following the progressive methodology

### Proof Library

The proof library provides computational scaling through caching verified theorems:

- **Theorem Registry**: Searchable database of proven theorems with metadata
- **Pattern Matching**: Automatic theorem lookup and application where patterns match
- **Dependency Tracking**: Maintains proof dependencies across theorem hierarchy
- **Fast Inference**: Instant positive RL signals from cached proofs
- **Incremental Learning**: Library grows continuously as new theorems proven
- **Efficiency**: Reduces computational overhead through theorem reuse

## Implementation Status

For detailed module-by-module implementation progress, see
[IMPLEMENTATION_STATUS.md](../Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md).

## External Resources

### Proof-Checker Repository

**GitHub**: https://github.com/benbrastmckie/ProofChecker

The proof-checker repository implements LEAN-based formal verification for the Logos formal language. Currently implements Core Layer (Layer 0) with TM logic including 8 axiom schemata, 7 inference rules, and 6 perpetuity principles. Future development will add semantic extensions progressively.

### Model-Checker Repository

**GitHub**: https://github.com/benbrastmckie/ModelChecker
**PyPI**: https://pypi.org/project/model-checker/

The model-checker repository implements Z3-based semantic verification for Logos (version 0.9.26 currently released). Provides programmatic semantics for hyperintensional state-based verification, countermodel generation, and finite model checking. Actively maintained with regular releases.

### Research Foundations

**Key Paper**: "Counterfactual Worlds" (2025) by Brast-McKie - Provides theoretical foundations for state-based hyperintensional semantics underlying both verification systems.

**Foundational Work**: Kit Fine's research on hyperintensional semantics and propositional structure provides the philosophical foundations for the Logos architecture.

## Getting Started

### For Understanding Dual Verification

1. Read the "Dual Verification Architecture" section in [RL_TRAINING.md](RL_TRAINING.md)
2. Review worked examples showing proof construction and countermodel generation
3. Explore the "Training Loop Flow" section for integration architecture
4. Study the "Infinite Clean Training Data" section for theoretical foundations

### For Understanding Logos Extensibility

1. Read the "Core Layer (Layer 0)" section in [LOGOS_LAYERS.md](LOGOS_LAYERS.md)
2. Explore each semantic extension (Layers 1-3) with concrete examples
3. Review the "Combination Principles" section for extensibility methodology
4. Study the "Development Roadmap" for implementation planning

### For Understanding Proof Library

1. Read the "Library Architecture" section in [PROOF_LIBRARY.md](PROOF_LIBRARY.md)
2. Explore the "Integration with Proof-Checker" section for workflow
3. Review the "Benefits for RL Training" section for efficiency gains
4. Study "Common Theorem Patterns" for practical examples

## Documentation Standards

This documentation suite follows strict formatting and terminology standards:

- **Operator Formatting**: All formal logical operators use backtick formatting (e.g., `�`, `�`, `�`)
- **State Formatting**: States formatted as `[state description]` with backticks
- **Professional Tone**: Academic writing style without emojis
- **Terminology Consistency**: Uses exact terms from Logos glossary
- **Cross-Referencing**: Bidirectional links between related documents
- **Accessibility**: Progressive complexity from overview to technical detail

## Repository Focus

**Important Note**: This documentation suite focuses exclusively on proof-checker and model-checker packages. References to "semantic models" in this documentation refer to mathematical structures for logical interpretation, not to AI models.

---

**Related Documentation:**
- [RL Training Architecture](RL_TRAINING.md)
- [Logos Layer Extensibility](LOGOS_LAYERS.md)
- [Proof Library Architecture](PROOF_LIBRARY.md)

_Last updated: December 2025_
