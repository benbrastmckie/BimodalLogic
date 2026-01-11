# Logos: Formal Language of Thought for Verified AI Reasoning

_[Return to Project Overview](../../README.md)_

## Overview

Logos is a formal language of thought designed to enable verified AI reasoning through progressive operator extensibility. The language implements an extension architecture where operators build incrementally from foundational logic (Boolean, modal, temporal) through domain-specific reasoning capabilities (explanatory, epistemic, normative). This design enables AI systems to reason with precisely the expressive power required for each application without unnecessary complexity.

**Core Principle**: "Any combination of extensions can be added to the Core Extension"

The complete Logos includes all three extensions, but applications can selectively load only needed operator families. A medical planning system might require Core + Explanatory operators, while a legal reasoning system might need Core + Epistemic operators, and a multi-agent coordination system might need all three extensions.

## Philosophical Foundations

### Hyperintensional Semantics

Logos builds on Kit Fine's research on hyperintensional semantics and propositional structure, which provides tools for distinguishing propositions that are necessarily equivalent but differ in content or structure. This foundation enables the system to represent fine-grained semantic distinctions essential for accurate reasoning about counterfactuals, constitutive relationships, and normative facts.

### State-Based Verification Approach

The verification architecture employs bilateral state-based semantics where propositions are modeled as verifier/falsifier state pairs. This approach, detailed in Brast-McKie's "Counterfactual Worlds" (2025), provides programmatic semantics suitable for computational verification while preserving the philosophical sophistication needed for hyperintensional reasoning.

### Task Semantics Framework

Logos implements task semantics for the bimodal logic TM (Tense and Modality), where possible worlds are functions from times to world states constrained by task relations. Task semantics provides mathematical foundations for combining metaphysical necessity (S5 modal logic) with temporal reasoning (linear temporal logic) through bimodal interaction axioms.

### Progressive Operator Methodology

The Logos architecture follows a progressive extension strategy where operators are organized into extensions building incrementally from foundational logic. This methodology enables domain-specific customization while maintaining mathematical rigor, allowing applications to use precisely the operators needed without carrying overhead from unused extensions.

#### Future Extensibility: Operator Discovery

This training methodology extends naturally to operator discovery. AI systems can learn to:
- Identify reasoning patterns in natural language involving operators not yet formalized
- Predict logics for new operators by constraining their semantic consequences
- Systematically explore the unbounded space of logical operators worth theorizing

Just as the space of theorems for any proof system and the space of models for any semantics are both infinite, the space of logical operators is unbounded. Formal logic provides an infinitely extensible supply of training resources that is:
- **Perfectly clean**: Soundness guarantees mathematical certainty
- **Perfectly consistent**: No contradictions or ambiguities
- **Unlimited by compute**: Not constrained by finite, noisy human-generated datasets

This contrasts sharply with natural language reasoning data, which is typically finite, noisy, and inconsistent—especially for sophisticated reasoning involving complex operator interactions that most humans cannot reliably perform without formal support. Like arithmetic computation, which vastly outstrips unaided human capability, complex logical reasoning requires formal systems to achieve accuracy and scale.

## Extension Architecture

### Extension 0 (Core TM): Boolean, Modal, Temporal

The Core Extension provides foundational reasoning through Boolean connectives, modal operators (necessity/possibility), and temporal operators (past/future). This extension implements the bimodal logic TM with task semantics.

**Operators**:
- Boolean: `¬`, `∧`, `∨`, `→`, `↔`, `⊥`, `⊤`
- Modal: `□` (necessity), `◇` (possibility)
- Temporal: `P` (past), `F` (future), `H` (always past), `G` (always future)
- Bimodal: `△` (always), `▽` (sometimes)

**Axioms**: 8 axiom schemata (MT, M4, MB, T4, TA, TL, MF, TF)

**Implementation**: See [ARCHITECTURE.md](ARCHITECTURE.md) for complete technical specification.

**Implementation Status**: See [IMPLEMENTATION_STATUS.md](../ProjectInfo/IMPLEMENTATION_STATUS.md) for current progress.

### Extension 1 (Explanatory): Counterfactual, Constitutive, Causal

Extension 1 extends the Core Extension with operators for explanatory reasoning, enabling AI systems to understand and reason about counterfactual scenarios, constitutive relationships, and causal connections.

**Operators**:
- Counterfactual: `□→` (would), `◇→` (might)
- Constitutive: `≤` (grounding), `⊑` (essence), `≡` (identity), `≼` (relevance)
- Causal: `○→` (causation)

**Application Domains**: Medical treatment planning, causal analysis, constitutive explanation

**Implementation Status**: Planned for future development. See [Research/LAYER_EXTENSIONS.md](../Research/LAYER_EXTENSIONS.md) for specifications.

### Extension 2 (Epistemic): Belief, Probability, Knowledge

Extension 2 extends the Core Extension with operators for reasoning under uncertainty, enabling AI systems to represent and reason about beliefs, probabilities, and knowledge states.

**Operators**:
- Belief: `B` (agent belief)
- Probability: `Pr` (probability quantification)
- Epistemic modals: `Mi` (might), `Mu` (must)
- Indicative conditional: `⟹`

**Application Domains**: Legal evidence analysis, reasoning under uncertainty, multi-agent belief modeling

**Implementation Status**: Planned for future development. See [Research/LAYER_EXTENSIONS.md](../Research/LAYER_EXTENSIONS.md) for specifications.

### Extension 3 (Normative): Obligation, Permission, Preference

Extension 3 extends the Core Extension with operators for ethical and cooperative reasoning, enabling AI systems to represent and reason about obligations, permissions, and preferences.

**Operators**:
- Deontic: `O` (obligation), `P` (permission)
- Preference: `≺` (preference ordering)
- Normative explanatory: `↦` (normative grounding)

**Application Domains**: Multi-party negotiation, ethical AI decision-making, cooperative planning

**Implementation Status**: Planned for future development. See [Research/LAYER_EXTENSIONS.md](../Research/LAYER_EXTENSIONS.md) for specifications.

## Application Domains

### Medical Planning (Core + Explanatory + Epistemic)

Physicians can use counterfactual operators to evaluate treatment strategies by reasoning about what would happen under different interventions, combined with epistemic operators for uncertainty quantification. The system distinguishes necessary consequences (`□→` would) from possible consequences (`◇→` might), while probability operators (`Pr`) and belief operators (`B`) enable nuanced risk-benefit analysis for complex treatment decisions with drug interactions and uncertain outcomes.

### Legal Reasoning (Core + Epistemic + Normative)

Legal professionals can track how evidence reveals agent beliefs and motives across time using belief operators (`B_a`) combined with temporal operators (`P`, `F`), while normative operators (`O` for obligation, `P` for permission) capture legal requirements and permissions. The system integrates epistemic, temporal, and normative reasoning to construct narratives connecting motive to action through transparent logical inference, while the model-checker searches for alternative explanations.

### Multi-Agent Coordination (Core + All Extensions)

Agents negotiating joint agreements can reason about counterfactual scenarios, track beliefs about other agents' preferences, and find solutions satisfying normative constraints. The system combines explanatory, epistemic, and normative operators to enable sophisticated coordination balancing heterogeneous preferences and obligations.

## Dual Verification Architecture

Logos enables verified AI reasoning through complementary syntactic and semantic verification:

**Proof-Checker** (LEAN 4): Constructs formal proofs from axioms and inference rules, generating proof receipts providing mathematical certainty for valid inferences.

**Model-Checker** (Z3): Searches for countermodels in finite state spaces, generating concrete semantic scenarios showing exactly why invalid inferences fail.

This dual verification creates unlimited training data for reinforcement learning without human annotation, enabling scalable oversight through computational verification.

### Complete Classification of Inference Space

The dual verification architecture provides binary classification covering the entire space of possible inferences. In a complete logic, every inference is either:
- **Derivable**: Can be proven from axioms (positive training signal from proof-checker)
- **Invalid**: Has a counterexample where premises are true but conclusion false (corrective training signal from model-checker)

Even in incomplete logics, additional valid principles can be consistently added as axioms to strengthen the system. This completeness property ensures comprehensive coverage of the inference space, creating an unbounded yet perfectly clean training environment.

### Three Dimensions of Training Mastery

By defining a proof system that is sound over a semantic model theory, the combined space of theorems and countermodels provides an infinite training ground limited only by computational resources:

1. **Reasoning WITH operators**: Master the inference patterns for modal, temporal, and bimodal operators by accumulating derivations and countermodels
2. **Finding derivations**: Learn to construct proofs within the axiom system—a challenging search problem even when validity is known
3. **Finding countermodels**: Learn to construct semantic models that refute invalid claims—the dual search problem

### Three Modes of Reasoning

The semantic model theory underlying Logos enables not just **deductive reasoning** (deriving conclusions from premises) but also **abductive reasoning** (generating hypotheses) and **inductive reasoning** (testing hypotheses with empirical feedback). This provides a comprehensive framework for AI reasoning across all three inference modes.

#### Deductive Reasoning

**Process**: From premises to conclusions via proof derivation within the axiom system

**Validation Mechanism**: The dual verification architecture validates deductions:
- If the inference is valid, the proof-checker derives it with a machine-checkable proof (positive training signal)
- If the inference is invalid, the model-checker refutes it with a counterexample (corrective training signal)

**Current Focus**: The implemented Core Extension provides complete infrastructure for training deductive reasoning with modal and temporal operators.

#### Abductive Reasoning

**Process**: Generate hypotheses by constructing semantic models that explain observations

**Methodology**: Given a goal or observed phenomenon, construct a semantic model (consisting of world states, task transitions, times, and valuations) that makes the desired claim true. The semantics then reveals:
- Which claims are **already true** given the current model
- Which claims **can be made true** by extending the model in specific ways
- What **must be added** to the model to achieve goals

**Future Capability**: Planned extensions (counterfactual, causal operators in Extension 1) will enable systematic hypothesis generation for explanatory reasoning.

#### Inductive Reasoning

**Process**: Test hypothesized models against empirical feedback and iteratively refine them

**Methodology**:
1. Construct a hypothesized semantic model (abduction)
2. Derive testable predictions from the model (deduction)
3. Collect empirical evidence to evaluate predictions
4. Refine the model based on consistency with evidence

**Future Capability**: Integration with empirical model-checking will enable systematic hypothesis testing and model refinement.

#### Example: Medical Treatment Planning

Consider evaluating treatment strategies for hypertension when a patient is already taking medication that interacts with some drugs:

**Deductive Reasoning**: "If we prescribe Drug A while the patient takes Medication X, liver damage will occur" (derive from known drug interaction model)

**Abductive Reasoning**: "What treatment would normalize blood pressure without side effects?" (hypothesize model extensions: alternative drugs, dosage adjustments, lifestyle interventions)

**Inductive Reasoning**: "Does empirical data support our drug interaction model?" (test predictions against clinical trials, refine interaction model based on evidence)

Training AI systems to reason in Logos—interpreted through semantic models with explicit semantic clauses—provides a pathway for mastering all three inference modes systematically.

**For detailed RL training architecture**, see [Research/DUAL_VERIFICATION.md](../Research/DUAL_VERIFICATION.md).

## Combination Principles

**Any combination of extensions can be added to the Core Extension**:
- Core only: Boolean, modal, temporal reasoning
- Core + Extension 1: Adds explanatory reasoning
- Core + Extension 2: Adds epistemic reasoning
- Core + Extension 3: Adds normative reasoning
- Core + Extensions 1,2: Explanatory + epistemic
- Core + Extensions 1,3: Explanatory + normative
- Core + Extensions 2,3: Epistemic + normative
- Core + Extensions 1,2,3: Complete Logos

Applications select operator combinations matching domain requirements, optimizing for needed expressiveness without unnecessary overhead.

## Implementation Status

See [IMPLEMENTATION_STATUS.md](../ProjectInfo/IMPLEMENTATION_STATUS.md) for current progress including:
- Extension 0 (Core TM) implementation status
- Metalogic completion (soundness, completeness)
- Perpetuity principles (P1-P6)
- Automation tactics
- Planning for Extensions 1-3

## References

### Research Foundations

**Brast-McKie, B.** (2025). "Counterfactual Worlds" - Theoretical foundations for state-based hyperintensional semantics underlying both verification systems.

**Fine, K.** - Research on hyperintensional semantics and propositional structure providing philosophical foundations for the Logos architecture.

### Implementation Repositories

**Logos**: https://github.com/benbrastmckie/Logos - LEAN 4 implementation of formal verification for Logos.

**ModelChecker**: https://github.com/benbrastmckie/ModelChecker - Z3-based semantic verification for Logos (v0.9.26).

## AI-Assisted Development Process

The Logos methodology integrates with an AI agent system that automates research, planning, implementation, and documentation workflows:

### Research Phase

Use `/research` to explore theoretical foundations, implementation patterns, and LEAN library resources:

```bash
/research "bimodal logic soundness proofs in LEAN 4"
```

Creates comprehensive research reports with LEAN library exploration and literature review.

### Planning Phase

Use `/plan` to create detailed implementation plans aligned with the Logos methodology:

```bash
/plan "Implement perpetuity principles P1-P6"
```

Generates step-by-step plans with complexity analysis, dependency tracking, and verification strategies.

### Implementation Phase

Use `/lean` to implement proofs following the methodology with automated verification:

```bash
/lean 023
```

Implements LEAN 4 proofs, verifies with lean-lsp-mcp, and commits to git.

### Documentation Phase

Use `/document` to maintain accurate, complete, and concise documentation:

```bash
/document "perpetuity principles"
```

Updates documentation to reflect current implementation status and theoretical foundations.

### AI System Integration

The AI system supports the complete Logos development methodology:

- **Research**: Multi-source research with LEAN library exploration
- **Planning**: Detailed implementation plans with complexity analysis
- **Implementation**: LEAN 4 proof development with verification
- **Documentation**: Automated documentation updates and accuracy verification
- **Review**: Comprehensive repository analysis and task identification

See [AI System Overview](../../.opencode/README.md) for complete workflow documentation.

## Related Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md) - Extension 0 (Core TM) technical specification
- [Research/LAYER_EXTENSIONS.md](../Research/LAYER_EXTENSIONS.md) - Extensions 1-3 specifications
- [Research/DUAL_VERIFICATION.md](../Research/DUAL_VERIFICATION.md) - RL training architecture
- [Research/PROOF_LIBRARY_DESIGN.md](../Research/PROOF_LIBRARY_DESIGN.md) - Theorem caching design
- [IMPLEMENTATION_STATUS.md](../ProjectInfo/IMPLEMENTATION_STATUS.md) - Current implementation progress
- [AI System Overview](../../.opencode/README.md) - Automated development workflows
- [AI Command Reference](../../.opencode/command/README.md) - Command usage and examples

---

_Last updated: December 2025_
