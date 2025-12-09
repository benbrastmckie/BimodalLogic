# Layer Extensions: Explanatory, Epistemic, Normative Operators

## Overview

This document specifies the design for Layers 1-3 operator extensions building on the Core Layer (Layer 0).

**Layer 0 (Core TM)**: See [ARCHITECTURE.md](../UserGuide/ARCHITECTURE.md) for Layer 0 (Core TM) technical specification.

**Philosophical Motivation**: For philosophical motivation explaining why these operators are needed for planning under uncertainty, see [CONCEPTUAL_ENGINEERING.md](CONCEPTUAL_ENGINEERING.md).

**Implementation Status**: See [IMPLEMENTATION_STATUS.md](../ProjectInfo/IMPLEMENTATION_STATUS.md) for current progress.

## Layer 1: Explanatory Extension

Layer 1 extends the Core Layer with operators for explanatory reasoning, enabling AI systems to understand and reason about counterfactual scenarios, constitutive relationships, and causal connections.

**Philosophical Foundation**: See [CONCEPTUAL_ENGINEERING.md](CONCEPTUAL_ENGINEERING.md) Section 3 ("From Tense to Counterfactual: Layer 1 Requirements") for philosophical motivation.

### Counterfactual Operators

**Would Counterfactual** (`□→`): "If it were the case that A, then it would be the case that B" - expresses what necessarily follows in counterfactual scenarios.

**Formal Definition**: `□A := ⊤ □→ A` (necessity definable via counterfactual)

**Semantics**: Truth evaluation using selection functions picking closest possible worlds where antecedent holds, checking if consequent holds in all selected worlds.

**Might Counterfactual** (`◇→`): "If it were the case that A, then it might be the case that B" - expresses what is possible in counterfactual scenarios.

**Formal Definition**: `◇→` is dual of `□→`

**Semantics**: Consequent holds in at least one selected world where antecedent holds.

**Contrast with Material Conditional**: Material implication (`A → B`) is truth-functional (true whenever A false or B true), while counterfactuals (`A □→ B`) require similarity-based evaluation across possible worlds. `¬p → ¬p` is trivially true, but `¬p □→ ¬p` requires checking closest worlds where `¬p` holds.

### Constitutive Operators

**Grounding** (`≤`): "A is sufficient for B" or "A grounds B" - represents constitutive explanatory relationships where A metaphysically suffices for B.

**Formal Characterization**:
- Dual to essence: `A ≤ B := ¬A ⊑ ¬B`
- Alternative definition: `A ≤ B := (A ∨ B) ≡ B`

**State-Based Semantics**: In verifier/falsifier state pairs, `A ≤ B` holds when verifiers of A contained in verifiers of B. Every way of making A true already makes B true.

**Examples**:
- `[Sam is crimson] ≤ [Sam is red]` - being crimson grounds being red
- `[Sam is a robin] ≤ [Sam is a bird]` - being a robin grounds being a bird
- `[Having 79 protons] ≤ [Being gold]` - atomic structure grounds gold identity

**Essence** (`⊑`): "A is necessary for B" or "A is essential to B" - represents constitutive necessity where A is metaphysically necessary for B.

**Formal Characterization**:
- Dual to ground: `A ⊑ B := ¬A ≤ ¬B`
- Alternative definition: `A ⊑ B := B ≡ (A ∧ B)`

**State-Based Semantics**: `A ⊑ B` holds when every verifier of B contains some verifier of A as part. No way to verify B without verifying A.

**Examples**:
- `[Having 79 protons] ⊑ [Being gold]` - atomic structure essential to gold
- `[Being extended] ⊑ [Being physical]` - extension essential to physicality
- `[Being trilateral] ⊑ [Being triangular]` - three sides essential to triangle

**Propositional Identity** (`≡`): "A just is B" - strongest constitutive equivalence where A and B mutually ground each other.

**Formal Definition**: `A ≡ B := (A ≤ B) ∧ (B ≤ A)` (mutual grounding)

**Examples**:
- `[Being a vixen] ≡ [Being a female fox]` - propositionally identical definitions
- `[Being trilateral] ≡ [Being triangular]` - having three sides just is having three angles

**Contrast with Weaker Equivalences**:
- Material equivalence (`A ↔ B`): Same actual truth value (weakest)
- Necessary equivalence (`□(A ↔ B)`): Same truth value at all possible worlds (stronger)
- Propositional identity (`A ≡ B`): Same metaphysical structure (strongest)

**Relevance** (`≼`): "A is wholly relevant to B" - interdefinable with ground and essence.

**Definition via Ground**: `A ≼ B := (A ∧ B) ≤ B`

**Definition via Essence**: `A ≼ B := (A ∨ B) ⊑ B`

### Causal Operator

**Causation** (`○→`): Represents productive causal relationships with temporal character.

**Contrast with Grounding**: Grounding (`≤`) is constitutive and timeless, while causation (`○→`) is productive and temporal.

**Examples**:
- `[Sam touches hot stove] ○→ [Sam feels pain]` - temporal causal production
- Contrast: `[Sam is crimson] ≤ [Sam is red]` - timeless constitutive grounding

**Development Status**: Theory developed in "Hyperintensional Causation" paper, implementation pending in model-checker.

### Medical Treatment Planning Example

**Scenario**: Physician treats hypertension patient currently taking medication X. Three treatment strategies available with different risk profiles requiring counterfactual analysis.

**Strategy A (add Drug A)**:
```
Prescribe(DrugA) ∧ Taking(MedicationX) □→ F(Normalize(BloodPressure)) ∧ F(Occur(LiverDamage))
```
Drug A would normalize blood pressure but would cause liver damage due to interaction with medication X (would-counterfactual: certain bad outcome).

**Strategy B (continue medication X alone)**:
```
Continue(MedicationX) □→ F(Persist(Hypertension)) ∧ F(Increase(CardiovascularRisk))
```
Continuing alone would leave hypertension untreated, increasing cardiovascular risk (would-counterfactual: certain continued problem).

**Strategy C (add Drug B)**:
```
Prescribe(DrugB) ∧ Taking(MedicationX) □→ F(Normalize(BloodPressure)) ∧ ¬F(Occur(LiverDamage))
Prescribe(DrugB) ◇→ F(Occur(Stroke))
```
Drug B would normalize blood pressure without liver interaction but might cause stroke with low probability (might-counterfactual: possible but uncertain bad outcome).

**Analysis**: The system weighs expected outcomes:
- Certain liver damage (Strategy A)
- Certain continued cardiovascular risk (Strategy B)
- Uncertain stroke risk (Strategy C)

Counterfactual operators distinguish necessary consequences (`□→` would) from possible consequences (`◇→` might), enabling nuanced risk-benefit analysis. The proof-checker verifies deductive inferences from pharmacological knowledge while model-checker searches for countermodels to proposed treatment strategies.

### Implementation Status

**Layer 1 Status**: Planned for proof-checker

- Syntax extension defined with counterfactual, constitutive, causal operators
- Axiom schemata to be specified based on selection function semantics
- Integration with Layer 0 through operator embedding structure
- Estimated development timeline: Post Layer 0 completion

**Model-Checker Support**: Constitutive operators (`≤`, `⊑`, `≡`) implemented in model-checker v0.9.26, counterfactual operators under development.

## Layer 2: Epistemic Extension

Layer 2 extends the Core Layer with operators for reasoning under uncertainty, enabling AI systems to represent and reason about beliefs, probabilities, and knowledge states.

**Philosophical Foundation**: See [CONCEPTUAL_ENGINEERING.md](CONCEPTUAL_ENGINEERING.md) Section 4 ("Epistemic and Normative Extensions: Layers 2-3 Requirements") for philosophical motivation.

### Belief Operator

**Belief** (`B`): "Agent a believes that A" - represents agent beliefs relative to information state.

**Notation**: `B_a(A)` where subscript a identifies agent

**Context Relativity**: Belief evaluation depends on agent's information state at evaluation context.

**Multiple Agents**: Supports multi-agent scenarios with distinct belief states per agent.

**Example**: `B_Alice([weather is sunny]) ∧ ¬B_Bob([weather is sunny])` - Alice and Bob have different beliefs about weather.

### Probability Operator

**Probability** (`Pr`): Quantifies uncertainty by assigning probability values to propositions.

**Notation**: `Pr(A) ≥ θ` where θ is probability threshold specified in context.

**Evaluation**: Checks whether proposition A exceeds specified probability threshold.

**Integration with Belief**: `B_a(A)` can be analyzed as `Pr_a(A) ≥ θ_belief` where θ_belief is agent's credence threshold for belief.

**Example**: `Pr([rain tomorrow]) ≥ 0.7` - probability of rain tomorrow at least 70%.

### Epistemic Modals

**Epistemic Possibility** (`Mi`): "It might be the case that A" - captures epistemic possibility relative to information state.

**Interpretation**: Compatible with what agent knows or believes.

**Epistemic Necessity** (`Mu`): "It must be the case that A" - captures epistemic necessity relative to information state.

**Interpretation**: Follows from what agent knows or believes.

**Contrast with Metaphysical Modals**:
- Metaphysical necessity (`□`): True in all possible worlds
- Epistemic necessity (`Mu`): True in all epistemically accessible worlds (compatible with knowledge)

**Example**: `Mu([murderer is guilty])` given evidence, versus `□([water is H2O])` as metaphysical necessity.

### Indicative Conditional

**Indicative Conditional** (`⟹`): Expresses expectations given belief state.

**Contrast with Counterfactual**: Indicative evaluates under actual beliefs, counterfactual evaluates under hypothetical scenarios.

**Example**:
- Indicative: "If it's raining, then the ground is wet" (`raining ⟹ wet_ground`)
- Counterfactual: "If it were raining, then the ground would be wet" (`raining □→ wet_ground`)

The indicative evaluates given current information, while counterfactual considers hypothetical alternative.

### Legal Evidence Analysis Example

**Scenario**: Prosecutors build murder case by tracking how evidence reveals suspect's beliefs and motives across time.

**Evidence Timeline** (using epistemic and temporal operators):

**Time T₁** (six months before murder):
```
P(B_suspect([victim threatens job]))
```
Evidence shows suspect believed victim would report misconduct, threatening suspect's career.

**Time T₂** (three months before):
```
P(F(B_suspect([financial ruin inevitable])))
```
Suspect believed financial ruin would follow job loss based on debt documents.

**Time T₃** (day of murder):
```
P(B_suspect([victim alone at home]))
```
Phone records show suspect knew victim's schedule and spouse's absence.

**Times T₄, T₅** (additional evidence):
```
B_witness1([suspect expressed anger])
B_witness2([suspect researched methods])
```
Witnesses establish suspect's emotional state and preparation.

**Analysis**: The system integrates belief operators (`B_a`) with temporal operators (`P`, `F`) to show how suspect's beliefs evolved over time, establishing motive through verified inference chains.

**Proof-Checker Validation**:
```
[B_suspect(threat) ∧ B_suspect(opportunity)] → [Motive(murder)]
```

**Model-Checker Search**: Searches for alternative explanations that could account for the same evidence pattern.

**Epistemic Modeling**: Reveals not just what happened, but what different agents believed at different times, constructing narrative connecting motive to action through transparent logical inference.

### Implementation Status

**Layer 2 Status**: Future development

- Operator syntax to be defined extending Layer 0
- Epistemic semantics requiring information states and accessibility relations
- Belief revision and probabilistic inference integration
- Timeline: Post Layer 1 completion

**Research Foundation**: Theoretical foundations established in formal epistemology literature, implementation specifications to be developed.

## Layer 3: Normative Extension

**Philosophical Foundation**: See [CONCEPTUAL_ENGINEERING.md](CONCEPTUAL_ENGINEERING.md) Section 4 ("Epistemic and Normative Extensions: Layers 2-3 Requirements") for philosophical motivation.

Layer 3 extends the Core Layer with operators for ethical and cooperative reasoning, enabling AI systems to represent and reason about obligations, permissions, and preferences.

### Deontic Operators

**Obligation** (`O`): "It is obligatory that A" - represents what ought to be the case relative to set of laws or norms.

**Context Relativity**: Obligation evaluation depends on normative context (legal system, moral framework, organizational policy).

**Formal Semantics**: Deontic logic with possible worlds and ideality ordering.

**Permission** (`P`): "It is permitted that A" - represents what is permissible relative to set of laws or norms.

**Relationship to Obligation**: `P(A) := ¬O(¬A)` (permitted iff not obligatory to refrain)

**Examples**:
- Legal context: `O([pay taxes])` - obligation to pay taxes
- Moral context: `P([assist others])` - permitted to help others
- Organizational: `O([submit reports])` - obligation to submit reports

### Preference Operator

**Preference** (`≺`): "A is preferred over B" - represents agent preferences.

**Notation**: `A ≺_a B` where subscript a identifies agent

**Ordering Properties**: Preference can be partial order (transitive, asymmetric) or total order (all pairs comparable).

**Multi-Agent Preferences**: Different agents may have different, potentially conflicting preference orderings.

**Aggregation**: Finding collective preferences from individual preferences requires aggregation functions.

**Example**: `[outcome_X] ≺_Alice [outcome_Y]` - Alice prefers Y to X.

### Normative Explanatory

**Normative Explanation** (`⟼`): Connects normative facts to their explanatory grounds.

**Integration with Layer 1**: Combines normative operators with constitutive grounding from explanatory extension.

**Example**: `[promise made] ⟼ O([promise kept])` - making promise grounds obligation to keep it.

### Multi-Party Negotiation Example

**Scenario**: Three organizations negotiate joint research agreement with heterogeneous standards for permissibility and different preference orderings.

**Organization A (startup)**: Permissive standards with strong preferences for speed and flexibility.

**Permissibility**:
```
P([option_IPsharing])
P([option_ExclusiveRights])
P([option_PublicationDelay])
```
Few restrictions - most options permitted.

**Preferences**:
```
[QuickTimeline] ≺_A [StandardTimeline]
[FlexibleTerms] ≺_A [RigidTerms]
```
Strong preference for speed and flexibility.

**Organization B (university)**: Restrictive standards with neutral preferences among remaining options.

**Obligations**:
```
O(¬[option_ExclusiveRights])
O([option_OpenPublication])
O([option_EthicalReview])
```
Many restrictions - requires open publication, ethical review, no exclusive rights.

**Preferences**: Weak `≺_B` ordering - neutral among permissible options.

**Organization C (government)**: Mixed standards with moderate preferences balancing public benefit against control.

**Mixed Norms**:
```
O([option_NationalSecurity])
P([option_IPsharing])
```
Moderate restrictions focusing on security.

**Preferences**:
```
[PublicAccess] ≺_C [ControlledAccess] ≺_C [RestrictedAccess]
```
Ordered preference from public to restricted access.

**Collective Agreement Analysis**:

Finding best collective agreement requires:
```
best_option ∈ (∩[permitted_A, permitted_B, permitted_C]) ∩ max(aggregate[≺_A, ≺_B, ≺_C])
```

The solution must be:
1. In intersection of what all parties permit
2. Maximize aggregated preferences

**Multi-Agent Reasoning**: AI agents negotiate by caring about others' preferences:
```
B_A([option_X] ≺_B [option_Y])
```
Agent A believes agent B prefers Y over X.

This enables seeking solutions balancing everyone's interests through transparent preference aggregation.

**Complexity**: As number of parties increases, finding optimal collective agreements becomes increasingly complex. Rather than providing algorithms for solving such scenarios, the Logos provides expressive resources for modeling them.

### Implementation Status

**Layer 3 Status**: Final extension

- Operator syntax to be defined extending Layer 0
- Deontic semantics with ideality orderings and normative accessibility
- Preference aggregation and social choice integration
- Timeline: Post Layer 2 completion

**Application Domains**: Traffic management, collaborative planning under uncertainty, ethical AI decision-making, multi-agent coordination.

## Combination Principles

The Logos architecture follows a **progressive extension methodology** where semantic extensions can be added to the Core Layer in any combination.

### Combination Flexibility

**Core Principle**: "Any combination of extensions can be added to the Core Layer"

**Valid Combinations**:
- **Core only**: Boolean, modal, temporal reasoning
- **Core + Layer 1**: Adds counterfactual, constitutive, causal reasoning
- **Core + Layer 2**: Adds belief, probability, epistemic reasoning
- **Core + Layer 3**: Adds obligation, permission, preference reasoning
- **Core + Layers 1,2**: Explanatory + epistemic reasoning
- **Core + Layers 1,3**: Explanatory + normative reasoning
- **Core + Layers 2,3**: Epistemic + normative reasoning
- **Core + Layers 1,2,3**: Complete Logos with all extensions

### Domain-Specific Customization

Applications select operator combinations matching domain requirements:

**Medical Planning**: Core + Layer 1
- Boolean logic for medical facts
- Modal logic for necessary conditions
- Temporal logic for treatment progression
- Counterfactual logic for treatment evaluation
- No epistemic or normative operators needed

**Legal Reasoning**: Core + Layer 2
- Boolean logic for evidence evaluation
- Temporal logic for timeline reconstruction
- Belief operators for agent mental states
- Probability for uncertainty quantification
- No counterfactual or normative operators needed (unless analyzing legal obligations)

**Multi-Agent Coordination**: Core + Layers 1,2,3
- All operator families for comprehensive coordination
- Counterfactuals for planning
- Belief operators for theory of mind
- Normative operators for obligations and preferences

### Operator Interactions

When multiple extensions combined, operators from different layers interact:

**Epistemic + Temporal** (Layer 2 + Core):
```
B_a(Fp) → F(B_a(p) ∨ ¬B_a(p))
```
If agent believes p will be true, then in future either agent believes p or doesn't.

**Normative + Counterfactual** (Layer 3 + Layer 1):
```
O(p) → (¬p □→ violation)
```
If p is obligatory, then if p were not the case, there would be a violation.

**Belief + Preference** (Layer 2 + Layer 3):
```
B_a([x] ≺_b [y]) → negotiate_toward([y])
```
If agent A believes agent B prefers y, then A negotiates toward y.

These interactions enable sophisticated multi-domain reasoning combining explanatory, epistemic, and normative capabilities.

### Future Extensions

The progressive methodology supports adding new operator families beyond the three current extensions:

**Potential Future Layers**:
- **Spatial Operators**: Reasoning about location and spatial relationships
- **Computational Operators**: Reasoning about algorithms and computation
- **Resource Operators**: Reasoning about resource consumption and allocation

The architecture provides a **basic methodology** that can be extended as new reasoning domains require formal representation.

## Implementation Status

For Layer 0 completion and planning for Layers 1-3, see [IMPLEMENTATION_STATUS.md](../ProjectInfo/IMPLEMENTATION_STATUS.md).

## Related Documentation

- [METHODOLOGY.md](../UserGuide/METHODOLOGY.md) - Philosophical foundations and layer overview
- [ARCHITECTURE.md](../UserGuide/ARCHITECTURE.md) - Layer 0 (Core TM) technical specification
- [DUAL_VERIFICATION.md](DUAL_VERIFICATION.md) - RL training architecture
- [PROOF_LIBRARY_DESIGN.md](PROOF_LIBRARY_DESIGN.md) - Theorem caching design

---

_Last updated: December 2025_
