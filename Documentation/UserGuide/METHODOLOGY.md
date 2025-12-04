# Logos: Formal Language of Thought for Verified AI Reasoning

_[Return to Project Overview](../../README.md)_

## Overview

Logos is a formal language of thought designed to enable verified AI reasoning through progressive operator extensibility. The language implements a layered architecture where operators build incrementally from foundational logic (Boolean, modal, temporal) through domain-specific reasoning capabilities (explanatory, epistemic, normative). This design enables AI systems to reason with precisely the expressive power required for each application without unnecessary complexity.

**Core Principle**: "Any combination of extensions can be added to the Core Layer"

The complete Logos includes all three extensions, but applications can selectively load only needed operator families. A medical planning system might require Core + Explanatory operators, while a legal reasoning system might need Core + Epistemic operators, and a multi-agent coordination system might need all three extensions.

## Philosophical Foundations

### Hyperintensional Semantics

Logos builds on Kit Fine's research on hyperintensional semantics and propositional structure, which provides tools for distinguishing propositions that are necessarily equivalent but differ in content or structure. This foundation enables the system to represent fine-grained semantic distinctions essential for accurate reasoning about counterfactuals, constitutive relationships, and normative facts.

### State-Based Verification Approach

The verification architecture employs bilateral state-based semantics where propositions are modeled as verifier/falsifier state pairs. This approach, detailed in Brast-McKie's "Counterfactual Worlds" (2025), provides programmatic semantics suitable for computational verification while preserving the philosophical sophistication needed for hyperintensional reasoning.

### Task Semantics Framework

Logos implements task semantics for the bimodal logic TM (Tense and Modality), where possible worlds are functions from times to world states constrained by task relations. Task semantics provides mathematical foundations for combining metaphysical necessity (S5 modal logic) with temporal reasoning (linear temporal logic) through bimodal interaction axioms.

### Progressive Operator Methodology

The Logos architecture follows a progressive extension strategy where operators are organized into layers building incrementally from foundational logic. This methodology enables domain-specific customization while maintaining mathematical rigor, allowing applications to use precisely the operators needed without carrying overhead from unused extensions.

## Layer Architecture

### Layer 0 (Core TM): Boolean, Modal, Temporal

The Core Layer provides foundational reasoning through Boolean connectives, modal operators (necessity/possibility), and temporal operators (past/future). This layer implements the bimodal logic TM with task semantics.

**Operators**:
- Boolean: `¬`, `∧`, `∨`, `→`, `↔`, `⊥`, `⊤`
- Modal: `□` (necessity), `◇` (possibility)
- Temporal: `P` (past), `F` (future), `H` (always past), `G` (always future)
- Bimodal: `△` (always), `▽` (sometimes)

**Axioms**: 8 axiom schemata (MT, M4, MB, T4, TA, TL, MF, TF)

**Implementation**: See [ARCHITECTURE.md](ARCHITECTURE.md) for complete technical specification.

**Implementation Status**: See [IMPLEMENTATION_STATUS.md](../ProjectInfo/IMPLEMENTATION_STATUS.md) for current progress.

### Layer 1 (Explanatory): Counterfactual, Constitutive, Causal

Layer 1 extends the Core Layer with operators for explanatory reasoning, enabling AI systems to understand and reason about counterfactual scenarios, constitutive relationships, and causal connections.

**Operators**:
- Counterfactual: `□→` (would), `◇→` (might)
- Constitutive: `≤` (grounding), `⊑` (essence), `≡` (identity), `≼` (relevance)
- Causal: `○→` (causation)

**Application Domains**: Medical treatment planning, causal analysis, constitutive explanation

**Implementation Status**: Planned for future development. See [Research/LAYER_EXTENSIONS.md](../Research/LAYER_EXTENSIONS.md) for specifications.

### Layer 2 (Epistemic): Belief, Probability, Knowledge

Layer 2 extends the Core Layer with operators for reasoning under uncertainty, enabling AI systems to represent and reason about beliefs, probabilities, and knowledge states.

**Operators**:
- Belief: `B` (agent belief)
- Probability: `Pr` (probability quantification)
- Epistemic modals: `Mi` (might), `Mu` (must)
- Indicative conditional: `⟹`

**Application Domains**: Legal evidence analysis, reasoning under uncertainty, multi-agent belief modeling

**Implementation Status**: Planned for future development. See [Research/LAYER_EXTENSIONS.md](../Research/LAYER_EXTENSIONS.md) for specifications.

### Layer 3 (Normative): Obligation, Permission, Preference

Layer 3 extends the Core Layer with operators for ethical and cooperative reasoning, enabling AI systems to represent and reason about obligations, permissions, and preferences.

**Operators**:
- Deontic: `O` (obligation), `P` (permission)
- Preference: `≺` (preference ordering)
- Normative explanatory: `⟼` (normative grounding)

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

**For detailed RL training architecture**, see [Research/DUAL_VERIFICATION.md](../Research/DUAL_VERIFICATION.md).

## Combination Principles

**Any combination of extensions can be added to the Core Layer**:
- Core only: Boolean, modal, temporal reasoning
- Core + Layer 1: Adds explanatory reasoning
- Core + Layer 2: Adds epistemic reasoning
- Core + Layer 3: Adds normative reasoning
- Core + Layers 1,2: Explanatory + epistemic
- Core + Layers 1,3: Explanatory + normative
- Core + Layers 2,3: Epistemic + normative
- Core + Layers 1,2,3: Complete Logos

Applications select operator combinations matching domain requirements, optimizing for needed expressiveness without unnecessary overhead.

## Implementation Status

See [IMPLEMENTATION_STATUS.md](../ProjectInfo/IMPLEMENTATION_STATUS.md) for current progress including:
- Layer 0 (Core TM) implementation status
- Metalogic completion (soundness, completeness)
- Perpetuity principles (P1-P6)
- Automation tactics
- Planning for Layers 1-3

## References

### Research Foundations

**Brast-McKie, B.** (2025). "Counterfactual Worlds" - Theoretical foundations for state-based hyperintensional semantics underlying both verification systems.

**Fine, K.** - Research on hyperintensional semantics and propositional structure providing philosophical foundations for the Logos architecture.

### Implementation Repositories

**Logos**: https://github.com/benbrastmckie/Logos - LEAN 4 implementation of formal verification for Logos.

**ModelChecker**: https://github.com/benbrastmckie/ModelChecker - Z3-based semantic verification for Logos (v0.9.26).

## Related Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md) - Layer 0 (Core TM) technical specification
- [Research/LAYER_EXTENSIONS.md](../Research/LAYER_EXTENSIONS.md) - Layers 1-3 extension specifications
- [Research/DUAL_VERIFICATION.md](../Research/DUAL_VERIFICATION.md) - RL training architecture
- [Research/PROOF_LIBRARY_DESIGN.md](../Research/PROOF_LIBRARY_DESIGN.md) - Theorem caching design
- [IMPLEMENTATION_STATUS.md](../ProjectInfo/IMPLEMENTATION_STATUS.md) - Current implementation progress

---

_Last updated: December 2025_
