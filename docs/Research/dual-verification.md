# Dual Verification Training Architecture

> **Implementation Status**: This document describes research vision.
> For current implementation progress, see [IMPLEMENTATION_STATUS.md](../ProjectInfo/IMPLEMENTATION_STATUS.md).

This document characterizes the dual verification training loop architecture enabling verified AI reasoning through complementary syntactic and semantic verification systems. The proof-checker generates positive reinforcement learning signals through LEAN proof receipts while model-checker generates corrective signals through Z3 counterexamples, creating infinite clean training data without human annotation.

## Introduction to Verified AI Reasoning

Traditional machine learning systems rely on finite natural language corpora containing errors, biases, and inconsistencies. AI models trained on such data approximate patterns statistically but cannot provide mathematical guarantees that their reasoning is correct. The proof-checker architecture addresses this fundamental limitation by enabling AI systems to master logical reasoning through self-supervised learning from axiomatic proof systems and recursive semantic theories for extensible formal languages.

**Key Innovation**: Given a formal language, an axiomatic proof systems defines an unlimited range of theorems that could be derived, and a recursive semantics provides an unlimited range of non-theorems that admit of countermodels. Each theorem comes with a proof receipt providing mathematical certainty, and each invalid inference has a counterexample showing exactly why the reasoning fails. Establishing soundness of the proof system over its semantics ensures that every theorem is valid. These verification signals enable AI training without human annotation, replacing finite noisy corpora with infinite clean training data.

**Result**: AI systems can learn verified logical reasoning through computational oversight rather than human labor, enabling scalable trustworthy AI through mathematical foundations rather than statistical approximation.

## Dual Verification Architecture

The proof-checker architecture combines **syntactic verification** (proof construction in LEAN) with **semantic verification** (model checking in Z3) to create complementary training signals for reinforcement learning.

### Architecture Overview

```
┌──────────────────────────────────────────────────────────────┐
│                    DUAL VERIFICATION                         │
│                                                              │
│   ┌──────────────────┐              ┌───────────────────┐    │
│   │  Proof-Checker   │              │  Model-Checker    │    │
│   │   (Syntactic)    │◄────────────►│   (Semantic)      │    │
│   │                  │              │                   │    │
│   │  LEAN 4 Prover   │              │  Z3 SMT Solver    │    │
│   │  TM Logic        │              │  State Models     │    │
│   └──────────────────┘              └───────────────────┘    │
│          │                                    │              │
│          │                                    │              │
│          ▼                                    ▼              │
│   ┌──────────────────┐              ┌───────────────────┐    │
│   │ Positive Signal  │              │ Corrective Signal │    │
│   │ Proof Receipt    │              │ Counterexample    │    │
│   │ (Valid)          │              │ (Invalid)         │    │
│   └──────────────────┘              └───────────────────┘    │
│          │                                    │              │
│          └────────────────┬───────────────────┘              │
│                           │                                  │
│                           ▼                                  │
│                  ┌─────────────────┐                         │
│                  │  RL Training    │                         │
│                  │  Signal         │                         │
│                  └─────────────────┘                         │
└──────────────────────────────────────────────────────────────┘
```

### Syntactic Verification Component

**Proof-Checker** (LEAN 4 implementation):

- **Language**: Bimodal logic TM (Tense and Modality)
- **Axioms**: 8 axiom schemata (S5 modal + linear temporal + bimodal interaction)
- **Rules**: 7 inference rules (modus ponens, modal K, temporal K, temporal duality, weakening, axiom, assumption)
- **Output**: Proof receipts when inference derivable, failure signal otherwise

The proof-checker attempts to construct formal proofs for candidate inferences by systematically applying inference rules to derive conclusions from axiom instantiations. When a proof succeeds, LEAN generates a proof receipt providing mathematical certainty that the inference is valid.

### Semantic Verification Component

**Model-Checker** (Z3 implementation):

- **Framework**: Programmatic hyperintensional semantics
- **States**: Modeled as bitvectors with fusion operation
- **Propositions**: Bilateral structures with verifier/falsifier state pairs
- **Output**: Countermodels when inference invalid, validation when no countermodel found

The model-checker searches for countermodels in finite state spaces by encoding semantic clauses as SMT constraints. When a countermodel exists, Z3 generates a concrete semantic scenario showing exactly why the inference fails, pinpointing the breakdown in reasoning.

### Bidirectional Verification Flow

```
Candidate Inference
        ↓
   ┌────────────────┐
   │ Proof-Checker  │
   │ Attempt Proof  │
   └────────────────┘
         │
    ┌────┴────┐
    │         │
  ✓ Proof   ✗ Failed
    │         │
    │         ▼
    │    ┌────────────────┐
    │    │ Model-Checker  │
    │    │ Search Counter │
    │    └────────────────┘
    │         │
    │    ┌────┴────┐
    │    │         │
    │  ✓ Valid   ✗ Counter
    │    │         │
    │    │         ▼
    ▼    ▼    ┌────────────┐
  Positive    │ Corrective │
  Signal      │  Signal    │
              └────────────┘
```

**Workflow**:
1. Candidate inference submitted to proof-checker
2. If proof constructed: Return proof receipt (positive signal)
3. If proof fails: Forward to model-checker
4. Model-checker searches for countermodel in finite state space
5. If countermodel found: Return counterexample (corrective signal)
6. If no countermodel found: Evidence of validity, reattempt proof with different strategy

This bidirectional flow ensures comprehensive verification: syntactic validity through proof construction, semantic validity through model checking.

## Positive RL Signals from Proof-Checker

The proof-checker generates positive reinforcement learning signals through LEAN proof receipts, providing mathematical certainty for valid inferences.

### Proof Receipts as Training Signals

**Mathematical Certainty**: Every proof receipt from LEAN provides absolute certainty that the inference is valid. Unlike statistical confidence scores, proof receipts guarantee correctness through formal verification.

**Immediate Feedback**: Verification happens during inference generation, enabling real-time learning. AI systems receive instant positive reinforcement when reasoning correctly.

**Systematic Coverage**: The TM logic axiom system enables systematic exploration of logical space. AI systems can master reasoning patterns progressively from simple theorems to complex derivations.

### Infinite Theorem Generation

**Axiom Schemata**: The TM logic includes 8 axiom schemata, each generating infinite axiom instantiations:

- **Modal T**: `□φ → φ` (necessity implies truth) - infinite instances for any formula φ
- **Modal 4**: `□φ → □□φ` (positive introspection) - infinite instances
- **Modal B**: `φ → □◇φ` (symmetry) - infinite instances
- **Temporal 4**: `Fφ → FFφ` (temporal transitivity) - infinite instances
- **Temporal A**: `φ → F(Pφ)` (temporal accessibility) - infinite instances
- **Temporal L**: `△φ → F(Hφ)` (temporal perpetuity) - infinite instances
- **Modal-Future**: `□φ → □Fφ` (modal persistence) - infinite instances
- **Temporal-Future**: `□φ → F□φ` (temporal persistence) - infinite instances

Each schema φ can be instantiated with any well-formed formula, generating unlimited training examples.

### Perpetuity Principles as Theorems

The TM logic enables derivation of novel theorems connecting modal and temporal operators. The **perpetuity principles** (P1-P6) demonstrate the system's capacity for mathematical discovery:

**P1**: `□φ → △φ` (what is necessary is always the case)
**P2**: `▽φ → ◇φ` (what is sometimes the case is possible)
**P3**: `□φ → □△φ` (necessity of perpetuity)
**P4**: `◇▽φ → ◇φ` (possibility of occurrence)
**P5**: `◇▽φ → △◇φ` (persistent possibility)
**P6**: `▽□φ → □△φ` (occurrent necessity is perpetual)

These theorems are not axioms but derivable results, demonstrating how axiomatic systems produce unlimited mathematical knowledge through systematic derivation.

**Implementation Status**: See [IMPLEMENTATION_STATUS.md](../ProjectInfo/IMPLEMENTATION_STATUS.md) for current progress on perpetuity principle proofs.

### Training Loop Integration

Positive signals integrate into RL training through:

1. **Reward Function**: Proof receipts contribute positive reward to model policy
2. **Pattern Recognition**: AI learns which inference patterns yield valid proofs
3. **Incremental Complexity**: Training progresses from simple theorems to complex derivations
4. **Proof Strategy Learning**: AI develops heuristics for efficient proof search

## Negative RL Signals from Model-Checker

The model-checker generates corrective reinforcement learning signals through Z3 counterexamples, providing precise error localization for invalid inferences.

### Counterexamples as Corrective Feedback

**Concrete Semantic Scenarios**: Counterexamples provide specific models showing exactly why an inference fails. Rather than abstract error messages, AI systems see concrete situations where premises hold but conclusion fails.

**Error Localization**: Countermodels pinpoint the exact breakdown in reasoning chains. AI systems learn which logical steps are problematic and why.

**Negative Reinforcement**: Invalid inferences receive corrective signals, enabling AI systems to avoid fallacious reasoning patterns.

### Countermodel Generation Process

The model-checker searches for countermodels by encoding semantic constraints as SMT problems:

**State Space Construction**:
1. Generate finite bitvector state space (configurable size: 2-8 bits)
2. Define state fusion operation (bitwise OR)
3. Construct all possible states from null state to maximal state

**Proposition Semantics**:
1. Each atomic proposition assigned verifier/falsifier state pairs
2. Complex propositions computed recursively from operators
3. Bilateral constraints enforced (verifiers and falsifiers disjoint)

**Model Checking**:
1. Encode premises as SMT constraints (must be satisfied)
2. Encode conclusion negation as SMT constraint (must be satisfiable)
3. Invoke Z3 solver to search for satisfying assignment
4. If satisfiable: Extract countermodel from Z3 solution
5. If unsatisfiable: No countermodel exists (evidence of validity)

### Example Countermodel

Consider invalid inference: `◇p → □p` (possibility implies necessity)

**Countermodel**:
- State space: `{#b00, #b01, #b10, #b11}`
- Proposition `p`: verifiers = `{#b01}`, falsifiers = `{#b10}`
- Evaluation: `◇p` true (verifier `#b01` possible), `□p` false (falsifier `#b10` compatible with some state)

This concrete model shows exactly why the inference fails: possibility requires at least one compatible state, but necessity requires all states incompatible with falsifiers.

### Training Loop Integration

Corrective signals integrate into RL training through:

1. **Penalty Function**: Counterexamples contribute negative reward to model policy
2. **Error Pattern Avoidance**: AI learns which inference patterns are invalid
3. **Semantic Understanding**: Concrete countermodels build intuition about operator semantics
4. **Refinement Cycles**: Corrective feedback guides iterative improvement

## Infinite Clean Training Data

The dual verification architecture produces unlimited training data without human annotation, solving the data scarcity problem for verified reasoning systems.

### Why This Matters

**Finite Corpus Limitation**: Traditional ML systems trained on finite natural language corpora containing:
- Errors and inconsistencies
- Cultural and demographic biases
- Ambiguities requiring context
- Missing reasoning steps

**Statistical Approximation**: Pattern matching on finite noisy data produces approximate reasoning without guarantees.

**Annotation Bottleneck**: Human labeling is expensive, slow, and error-prone, limiting dataset size and quality.

### Axiomatic Systems Advantage

**Unlimited Theorems**: Axiom schemata generate infinite valid inferences through systematic instantiation and derivation.

**Clean Signals**: Proof receipts and counterexamples are mathematically guaranteed correct - no annotation errors.

**Systematic Coverage**: Axiomatic derivation explores logical space systematically rather than sampling randomly.

**No Human Labor**: Verification systems generate training signals automatically through computation.

### TM Logic as Training Data Source

The TM logic provides comprehensive training data foundation:

**8 Axiom Schemata** × **Infinite Instantiations** = **Unlimited Axioms**

**7 Inference Rules** × **Combinatorial Derivations** = **Unlimited Theorems**

**Example Progression**:
1. Simple axiom instances: `□p → p`, `□q → q`, `□(p ∧ q) → (p ∧ q)`
2. One-step derivations: `□p → □□p` (from M4), `p → □◇p` (from MB)
3. Multi-step proofs: Perpetuity principles P1-P6
4. Complex derivations: Novel theorem discovery through systematic search

Each level provides training examples of increasing complexity, enabling progressive learning from foundations to advanced reasoning.

### Scaling Properties

**Computational Scaling**: Training data generation scales with computational resources, not human labor:
- Faster hardware → more theorems verified per second
- Parallel verification → multiple proof attempts simultaneously
- Proof libraries → cached theorems enable reuse

**Quality Guarantees**: All training signals mathematically verified:
- Proof receipts guarantee validity through LEAN type checking
- Counterexamples guarantee invalidity through Z3 model finding
- No false positives or false negatives (modulo soundness of LEAN and Z3)

**Progressive Difficulty**: Training curriculum emerges naturally:
- Short proofs discovered first (fewer derivation steps)
- Complex theorems require longer proof search
- Automatic difficulty progression from simple to advanced

## Implementation Status

For current implementation progress on proof-checker and model-checker integration, see [IMPLEMENTATION_STATUS.md](../ProjectInfo/IMPLEMENTATION_STATUS.md).

## Related Documentation

- [METHODOLOGY.md](../UserGuide/METHODOLOGY.md) - Philosophical foundations
- [ARCHITECTURE.md](../UserGuide/ARCHITECTURE.md) - Layer 0 (Core TM) specification
- [proof-library-design.md](proof-library-design.md) - Theorem caching architecture
- [layer-extensions.md](layer-extensions.md) - Layers 1-3 specifications

---

_Last updated: December 2025_
