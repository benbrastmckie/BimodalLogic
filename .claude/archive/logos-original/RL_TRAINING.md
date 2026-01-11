# Reinforcement Learning Training Architecture

> **Implementation Status**: This document describes **research vision**.
> For current implementation progress, see
> [IMPLEMENTATION_STATUS.md](../Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md).

This document characterizes the dual verification training loop architecture enabling verified AI reasoning through complementary syntactic and semantic verification systems. The proof-checker generates positive reinforcement learning signals through LEAN proof receipts while model-checker generates corrective signals through Z3 counterexamples, creating infinite clean training data without human annotation.

## Introduction to Verified AI Reasoning

Traditional machine learning systems rely on finite natural language corpora containing errors, biases, and inconsistencies. AI models trained on such data approximate patterns statistically but cannot provide mathematical guarantees about their reasoning. The proof-checker architecture addresses this fundamental limitation by enabling AI systems to master logical reasoning through self-supervised learning from axiomatic systems.

**Key Innovation**: Axiomatic proof systems produce unlimited theorems through systematic derivation from axioms and inference rules. Each theorem comes with a proof receipt providing mathematical certainty, and each invalid inference attempt yields a counterexample showing exactly why the reasoning fails. These verification signals enable AI training without human annotation, replacing finite noisy corpora with infinite clean training data.

**Result**: AI systems can learn verified logical reasoning through computational oversight rather than human labor, enabling scalable trustworthy AI through mathematical foundations rather than statistical approximation.

## Dual Verification Architecture

The proof-checker architecture combines **syntactic verification** (proof construction in LEAN) with **semantic verification** (model checking in Z3) to create complementary training signals for reinforcement learning.

### Architecture Overview

```
┌──────────────────────────────────────────────────────────────┐
│                    DUAL VERIFICATION                         │
│                                                              │
│   ┌──────────────────┐              ┌───────────────────┐   │
│   │  Proof-Checker   │              │  Model-Checker    │   │
│   │   (Syntactic)    │◄────────────►│   (Semantic)      │   │
│   │                  │              │                   │   │
│   │  LEAN 4 Prover   │              │  Z3 SMT Solver    │   │
│   │  TM Logic        │              │  State Models     │   │
│   └──────────────────┘              └───────────────────┘   │
│          │                                    │              │
│          │                                    │              │
│          ▼                                    ▼              │
│   ┌──────────────────┐              ┌───────────────────┐   │
│   │ Positive Signal  │              │ Corrective Signal │   │
│   │ Proof Receipt    │              │ Counterexample    │   │
│   │ (Valid)          │              │ (Invalid)         │   │
│   └──────────────────┘              └───────────────────┘   │
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

## Training Loop Flow

The complete training loop integrates dual verification into end-to-end AI reasoning pipeline.

### System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    TRAINING LOOP FLOW                        │
│                                                              │
│  ┌──────────────────┐                                       │
│  │ Natural Language │                                       │
│  │ Context (NLC)    │                                       │
│  └────────┬─────────┘                                       │
│           │                                                  │
│           ▼                                                  │
│  ┌──────────────────────────────────────────────────┐       │
│  │     Five Generative Outputs                      │       │
│  │  1. FLF Extraction                               │       │
│  │  2. SRS Generation                               │       │
│  │  3. SMS Construction                             │       │
│  │  4. SCP Construction                             │       │
│  │  5. SRI Evaluation (Candidate Inferences)        │       │
│  └──────────────────┬───────────────────────────────┘       │
│                     │                                        │
│                     ▼                                        │
│  ┌─────────────────────────────────────────────────┐        │
│  │         Proof-Checker (Syntactic)               │        │
│  │  • Attempt proof construction                   │        │
│  │  • LEAN 4 verification                          │        │
│  │  • TM logic axioms and rules                    │        │
│  └─────────────┬───────────────────┬───────────────┘        │
│                │                   │                         │
│          ✓ Proof Receipt     ✗ Proof Failed                 │
│                │                   │                         │
│                │                   ▼                         │
│                │      ┌──────────────────────────┐           │
│                │      │  Model-Checker (Semantic)│           │
│                │      │  • Search countermodel   │           │
│                │      │  • Z3 SMT solving        │           │
│                │      │  • State-based semantics │           │
│                │      └──────┬──────────┬────────┘           │
│                │             │          │                    │
│                │       ✓ Valid    ✗ Counterexample          │
│                │             │          │                    │
│                ▼             ▼          ▼                    │
│      ┌──────────────┐  ┌────────┐  ┌──────────────┐        │
│      │ Positive RL  │  │ Retry  │  │ Corrective   │        │
│      │ Signal       │  │ Proof  │  │ RL Signal    │        │
│      │ (Theorem)    │  │        │  │ (Counter)    │        │
│      └──────────────┘  └────────┘  └──────────────┘        │
│             │                              │                 │
│             └──────────────┬───────────────┘                 │
│                            │                                 │
│                            ▼                                 │
│              ┌──────────────────────────┐                    │
│              │  RL Training Update      │                    │
│              │  • Reward/penalty signal │                    │
│              │  • Policy gradient       │                    │
│              │  • Model update          │                    │
│              └──────────────────────────┘                    │
└─────────────────────────────────────────────────────────────┘
```

### Pipeline Stages

**Stage 1: FLF Extraction**
- Parse natural language context to identify needed operators
- Determine which Logos layer required (Layer 0, 1, 2, or 3)
- Extract formal language fragment appropriate for reasoning task

**Stage 2: SRS Generation**
- Generate salient range of sentences capturing logical content
- Create representative formulas for proof checking

**Stage 3: SMS Construction**
- Build semantic model structure (domain, states, propositions)
- Construct interpretation mapping for verification

**Stage 4: SCP Construction**
- Establish evaluation context parameters
- Configure verification constraints

**Stage 5: SRI Evaluation**
- Generate candidate inferences from context
- Submit to dual verification pipeline
- Collect proof receipts and counterexamples
- Integrate verified inferences into knowledge base

### Verification Coordination

The SRI evaluation stage coordinates dual verification:

```python
def verify_inference(candidate_inference):
    # Stage 1: Attempt proof construction
    proof_result = proof_checker.attempt_proof(candidate_inference)

    if proof_result.success:
        # Positive RL signal
        return TrainingSignal(
            type="positive",
            inference=candidate_inference,
            proof_receipt=proof_result.receipt,
            confidence=1.0  # Mathematical certainty
        )

    # Stage 2: Search for countermodel
    counter_result = model_checker.find_countermodel(candidate_inference)

    if counter_result.found:
        # Corrective RL signal
        return TrainingSignal(
            type="corrective",
            inference=candidate_inference,
            counterexample=counter_result.model,
            error_location=counter_result.breakdown_point
        )
    else:
        # No countermodel found - evidence of validity
        # Retry proof with different strategy
        return verify_inference_retry(candidate_inference)
```

### Training Signal Integration

Training signals flow into RL optimization:

**Positive Signals**:
- Add to theorem library for future reuse
- Increment reward in policy gradient
- Strengthen neural pathways for valid reasoning patterns

**Corrective Signals**:
- Log counterexample for error pattern analysis
- Apply penalty in policy gradient
- Weaken neural pathways for invalid reasoning patterns

**Batch Learning**:
- Collect multiple verification results
- Compute aggregate reward signal
- Update model parameters via gradient descent

## Worked Examples

This section demonstrates dual verification through concrete examples showing proof construction and countermodel generation.

### Example 1: Modal T Axiom

**Theorem**: `□p → p` (necessity implies truth)

**Proof Construction** (Proof-Checker):
```lean
theorem modal_t_instance : ⊢ (Formula.box (Formula.atom "p")).imp (Formula.atom "p") := by
  apply Derivable.axiom
  apply Axiom.modal_t
```

**Verification**: LEAN proof receipt confirms validity through axiom application.

**Training Signal**: Positive RL signal with mathematical certainty.

### Example 2: Perpetuity Principle P3

**Theorem**: `□φ → □△φ` (necessity of perpetuity)

**Informal Proof**:
1. Assume `□φ` (necessity of φ)
2. From P1: `□φ → △φ` (necessity implies always)
3. By modus ponens: `△φ`
4. From MF: `□φ → □Fφ` (modal persistence)
5. Temporal transitivity yields `□△φ`

**Proof Construction** (multi-step derivation in LEAN using perpetuity_3 theorem).

**Training Signal**: Positive RL signal demonstrating complex multi-step reasoning.

### Example 3: Invalid Inference

**Candidate**: `◇p → □p` (possibility implies necessity)

**Proof Attempt** (Proof-Checker):
- Fails: No derivation path from TM axioms and rules

**Countermodel Search** (Model-Checker):

**State Space**: `{#b00, #b01, #b10, #b11}`

**Proposition p**:
- Verifiers: `{#b01}`
- Falsifiers: `{#b10}`

**Evaluation**:
- `◇p` evaluates to true: `#b01` is a possible state (compatible with some maximal state)
- `□p` evaluates to false: `#b10` is a falsifier compatible with some state

**Countermodel**: Semantic structure where `◇p` true but `□p` false, demonstrating invalidity.

**Training Signal**: Corrective RL signal with concrete error localization.

### Example 4: Temporal Reasoning

**Theorem**: `Fp → FFp` (future implies future-future)

**Proof Construction**:
```lean
theorem temporal_4_instance : ⊢ (Formula.future (Formula.atom "p")).imp
    (Formula.future (Formula.future (Formula.atom "p"))) := by
  apply Derivable.axiom
  apply Axiom.temp_4
```

**Interpretation**:
- If p will be true at some future time t
- Then at t, p is present (not future)
- But there exists future time t' > t where p true
- Therefore FFp (future-future p)

**Training Signal**: Positive RL signal for temporal reasoning pattern.

## Integration Architecture

The dual verification architecture integrates with broader AI reasoning systems through the SRI evaluation coordination stage.

### Verification System Interfaces

**Proof-Checker API**:
```lean
structure ProofRequest :=
  (premises : Context)
  (conclusion : Formula)
  (timeout : Nat := 5000)  -- milliseconds

structure ProofResponse :=
  (success : Bool)
  (receipt : Option ProofReceipt)
  (derivation_steps : Nat)
  (time_elapsed : Nat)

def attempt_proof (request : ProofRequest) : ProofResponse
```

**Model-Checker API**:
```python
class CountermodelRequest:
    premises: List[Formula]
    conclusion: Formula
    max_states: int = 16  # bitvector size

class CountermodelResponse:
    found: bool
    model: Optional[SemanticModel]
    verification_time: float
    state_space_size: int

def find_countermodel(request: CountermodelRequest) -> CountermodelResponse
```

### SRI Evaluation Coordination

The SRI evaluation stage orchestrates dual verification:

1. **Inference Generation**: Extract candidate inferences from semantic context
2. **Proof Attempt**: Submit to proof-checker with timeout
3. **Countermodel Search**: If proof fails, submit to model-checker
4. **Signal Classification**: Categorize result as positive, corrective, or uncertain
5. **Library Update**: Cache verified theorems for future reuse
6. **Training Integration**: Format signals for RL optimization

### Performance Characteristics

**Proof-Checker**:
- Average proof time: 10-500ms (simple theorems)
- Complex proofs: 1-5 seconds
- Timeout threshold: 5 seconds
- Parallelizable: Multiple proof attempts simultaneously

**Model-Checker**:
- Average search time: 50-200ms (4-bit states)
- Large state spaces: 500ms-2s (8-bit states)
- Timeout threshold: 3 seconds
- Parallelizable: Multiple countermodel searches simultaneously

**End-to-End Pipeline**:
- Target: < 5 seconds per inference verification
- Achievable throughput: 10-20 inferences/second (parallel)
- Bottleneck: Proof construction for complex theorems

## Conclusion

The dual verification training architecture provides comprehensive RL signals for verified AI reasoning through complementary syntactic and semantic verification. Proof-checker generates unlimited positive signals via LEAN proof receipts while model-checker generates unlimited corrective signals via Z3 counterexamples, creating infinite clean training data without human annotation. This architecture enables scalable oversight through computational verification rather than human labor, laying the foundation for trustworthy AI reasoning systems with mathematical guarantees.

**Key Advantages**:
- Mathematical certainty through formal verification
- Infinite clean training data from axiomatic systems
- Transparent reasoning with auditable proof receipts
- Scalable oversight without human annotation bottleneck
- Progressive complexity from simple theorems to advanced derivations

**Future Directions**:
- Extend to Layer 1 (counterfactual, causal, constitutive operators)
- Integrate proof library for fast inference lookup
- Develop proof strategy learning for efficient search
- Scale to epistemic and normative reasoning (Layers 2-3)

---

**Related Documentation:**
- [Logos Layer Extensibility](LOGOS_LAYERS.md)
- [Proof Library Architecture](PROOF_LIBRARY.md)
- [Description Suite Overview](README.md)

_Last updated: December 2025_
