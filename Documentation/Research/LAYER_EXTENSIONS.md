# Layer Extensions: Explanatory, Epistemic, Normative Operators

## Overview

The Logos is organized into a series of expressive layers, each corresponding to a semantic frame of increasing complexity. A **semantic frame** defines the primitive semantic structure needed to interpret logical formulas—it specifies what kinds of entities exist in the semantic domain and how truth conditions are evaluated. Each layer introduces new operators whose meaning is defined through semantic clauses that reference the primitive structure of that layer's frame.

**Semantic Progression**: The layers build systematically:

1. **Core Layer Frame**: Defines domain of individuals, assignment of extensions to predicates/functions, and verifier/falsifier states for propositions. This frame provides semantic clauses for quantifiers, extensional connectives, and constitutive operators (grounding `≤`, essence `⊑`).

2. **Modal Layer Frame**: Extends the Core frame by adding a set of possible worlds (or history/time pairs), accessibility relations between worlds, and similarity orderings for counterfactual evaluation. This enriched frame provides semantic clauses for modal operators (`□`, `◇`), historical operators (`□ₕ`, `◇ₕ`), tense operators (`P`, `F`, `H`, `G`), and counterfactual conditionals (`□→`, `◇→`).

3. **Causal Layer Frame**: Extends the Modal frame by adding temporal ordering and causal production relations between events at different times. This frame provides semantic clauses for the causation operator (`○→`), distinguishing productive temporal causation from timeless constitutive grounding.

4. **Epistemic Layer Frame**: Extends earlier frames by adding information states for each agent, probability distributions over possible worlds, and epistemic accessibility relations. This frame provides semantic clauses for belief operators (`B_a`), probability operators (`Pr`), epistemic modals (`Mi`, `Mu`), and indicative conditionals (`⟹`).

5. **Normative Layer Frame**: Extends earlier frames by adding ideality orderings over worlds (representing which worlds better satisfy norms), deontic accessibility relations, and preference orderings for agents. This frame provides semantic clauses for obligation (`O`), permission (`P`), preference (`≺`), and normative explanation (`⟼`).

**Compositional Semantics**: Each layer's semantic frame includes all structure from previous layers. A formula combining operators from multiple layers (e.g., `B_a(F(O(p)))` - "agent a believes that it will be obligatory that p") is evaluated in the most complex frame needed, which contains all the semantic machinery required for each operator.

**From Semantics to Reasoning**: An **intended model** instantiates one of these semantic frames with concrete structure—specifying which individuals exist, which predicates hold of them, which worlds are accessible, what agents believe, which actions are obligatory, etc. Given an intended model representing a planning scenario:

- The **proof-checker** verifies that proposed action plans follow deductively from the model's specifications
- The **model-checker** searches for alternative models (counterexamples) to test whether proposed strategies are robust
- Operators from different layers interact to support planning: temporal operators represent action sequences, counterfactuals evaluate hypothetical interventions, epistemic operators track what agents know, and normative operators constrain permissible actions

This layered semantic architecture enables AI systems to reason about complex multi-agent planning problems: "If I perform action A (counterfactual), what will other agents believe (epistemic), what obligations will arise (normative), and how does this affect the probability of desired outcomes (epistemic with probability)?"

The Logos thus provides a unified logical framework where each layer contributes semantic structure supporting increasingly sophisticated reasoning needed for AI planning and evaluation under uncertainty. The layers stack together systematically:

The **Core Layer** provides fundamental descriptive resources—predicates and functions for expressing facts, quantifiers for generalizing over individuals, and constitutive operators for expressing what grounds and explains what. This foundational layer enables systems to represent and reason about the basic structure of reality.

Building on this foundation, the **Modal Layer** adds operators for reasoning about possibility, necessity, and counterfactual scenarios. These operators are essential for planning, as they enable systems to evaluate what would happen under different conditions and to reason about contingent futures.

The **Causal Layer** extends modal reasoning with temporal productive relationships, enabling systems to distinguish between timeless constitutive grounding (e.g., being crimson grounds being red) and temporal causal production (e.g., touching a hot stove causes pain).

The **Epistemic Layer** addresses reasoning under uncertainty by providing operators for beliefs, probabilities, and knowledge states. Multi-agent systems must reason not only about what is true, but about what different agents believe to be true.

Finally, the **Normative Layer** provides operators for reasoning about obligations, permissions, and preferences. AI systems operating in human contexts must be able to represent and reason about ethical constraints, legal requirements, and value trade-offs.

This layered architecture reflects the progressive methodology: start with a core logic that works reliably, then extend it systematically with operators needed for increasingly sophisticated reasoning tasks.

This document specifies the design for the following language extensions:

- **Core Layer**: Predicates, functions, lambdas, quantifiers, extensional operators, and constitutive explanatory operators.
- **Modal Layer**: Historical, counterfactual conditional, and tense operators for reasoning about past and future contingency.
- **Causal Layer**: Causal operators for reasoning about the causal connections between earlier and later events.
- **Epistemic Layer**: Epistemic modals, indicative conditionals, and probability, and belief operators for reasoning under uncertainty.
- **Normative Layer**: Permission, obligation, preference, and normative explanatory operators for reasoning about values and laws.

See [ARCHITECTURE.md](../UserGuide/ARCHITECTURE.md) for the technical specification of the Modal Layer, [CONCEPTUAL_ENGINEERING.md](CONCEPTUAL_ENGINEERING.md) for philosophical motivation explaining why these operators are needed for planning under conditions of uncertainty in multi-agent systems, and [IMPLEMENTATION_STATUS.md](../ProjectInfo/IMPLEMENTATION_STATUS.md) for current progress.

## Core Layer

The Core Layer provides first-order and second-order descriptive resources that form the foundation for all higher-layer reasoning. These include basic logical vocabulary (predicates, functions), abstraction and generalization mechanisms (lambdas, quantifiers), truth-functional connectives (extensional operators), and constitutive explanatory operators.

### Predicates and Functions

**Predicates**: Represent properties and relations that can be true or false of individuals.

**Notation**: 
- Unary predicates: `P(x)` - "x has property P"
- Binary predicates: `R(x,y)` - "x stands in relation R to y"
- N-ary predicates: `Q(x₁,...,xₙ)` - "individuals x₁,...,xₙ satisfy relation Q"

**Examples**:
- `Red(x)` - x is red
- `Taller(x,y)` - x is taller than y
- `Between(x,y,z)` - x is between y and z

**Functions**: Map individuals to individuals, enabling reference to specific entities.

**Notation**: `f(x₁,...,xₙ)` denotes the individual that results from applying function f to arguments x₁,...,xₙ.

**Examples**:
- `father(x)` - the father of x
- `sum(x,y)` - the sum of x and y
- `capital(x)` - the capital city of country x

**Type System**: The Logos supports typed predicates and functions, with type checking ensuring well-formed formulas. See [ARCHITECTURE.md](../UserGuide/ARCHITECTURE.md) for the complete type system specification.

### Lambdas and Quantifiers

**Lambda Abstraction** (`λ`): Creates property or relation terms from formulas with free variables.

**Notation**: `λx.φ(x)` denotes the property that holds of y iff φ(y) is true.

**Examples**:
- `λx.Red(x)` - the property of being red
- `λx.λy.Loves(x,y)` - the relation of loving
- `λx.[father(x) = john]` - the property of being John's child

**Application**: Lambda terms can be applied to arguments: `(λx.Red(x))(a)` reduces to `Red(a)`.

**Universal Quantifier** (`∀`): "For all x, φ(x)" - expresses that formula holds for every individual in domain.

**Notation**: `∀x.φ(x)` or `∀x:T.φ(x)` when specifying type T.

**Examples**:
- `∀x.Mortal(x)` - everything is mortal
- `∀x.[Human(x) → Mortal(x)]` - all humans are mortal

**Existential Quantifier** (`∃`): "There exists x such that φ(x)" - expresses that formula holds for at least one individual.

**Notation**: `∃x.φ(x)` or `∃x:T.φ(x)` when specifying type T.

**Examples**:
- `∃x.Prime(x)` - there exists a prime number
- `∃x.[Human(x) ∧ Wise(x)]` - there exists a wise human

**Second-Order Quantification**: The Logos supports quantification over properties and relations, enabling expressive reasoning about concepts themselves.

**Example**: `∀P.∀x.[P(x) → P(x)]` - for any property P and individual x, if x has P then x has P (second-order identity).

### Extensional Operators

The Core Layer includes standard truth-functional connectives that combine formulas based solely on their truth values.

**Negation** (`¬`): "Not A" - reverses truth value.

**Conjunction** (`∧`): "A and B" - true iff both A and B true.

**Disjunction** (`∨`): "A or B" - true iff at least one of A or B true.

**Material Implication** (`→`): "If A then B" - truth-functional conditional, true iff A false or B true.

**Material Biconditional** (`↔`): "A if and only if B" - true iff A and B have same truth value.

**Contrast with Hyperintensional Operators**: These extensional operators are truth-functional (output determined solely by input truth values), unlike the hyperintensional operators (grounding `≤`, essence `⊑`, counterfactuals `□→`) which distinguish between necessarily equivalent propositions based on their metaphysical structure.

**Example**: `[2+2=4] ↔ [water is H2O]` is true (both sides true), but `[2+2=4] ≡ [water is H2O]` is false (different propositions despite same truth value).

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

## Modal Layer

### Counterfactual Operators

**Would Counterfactual** (`□→`): "If it were the case that A, then it would be the case that B" - expresses what necessarily follows in counterfactual scenarios.

**Formal Definition**: `□A := ⊤ □→ A` (necessity definable via counterfactual)

**Semantics**: Truth evaluation using selection functions picking closest possible worlds where antecedent holds, checking if consequent holds in all selected worlds.

**Might Counterfactual** (`◇→`): "If it were the case that A, then it might be the case that B" - expresses what is possible in counterfactual scenarios.

**Formal Definition**: `◇→` is dual of `□→`

**Semantics**: Consequent holds in at least one selected world where antecedent holds.

**Contrast with Material Conditional**: Material implication (`A → B`) is truth-functional (true whenever A false or B true), while counterfactuals (`A □→ B`) require similarity-based evaluation across possible worlds. `¬p → ¬p` is trivially true, but `¬p □→ ¬p` requires checking closest worlds where `¬p` holds.

### Historical and Tense Operators

The Modal Layer includes operators for reasoning about temporal structure and alternative histories, essential for planning and counterfactual reasoning about past and future.

**Historical Necessity** (`□ₕ`): "It is historically necessary that A" - true at time t in history h iff A holds at t in all possible histories.

**Semantics**: Quantifies over all possible histories passing through evaluation point, checking if proposition holds in each.

**Example**: `□ₕ[laws of physics hold]` - the laws of physics are historically necessary (hold across all possible histories).

**Historical Possibility** (`◇ₕ`): "It is historically possible that A" - true at time t in history h iff A holds at t in at least one possible history.

**Semantics**: Dual of historical necessity: `◇ₕA := ¬□ₕ¬A`.

**Example**: `◇ₕ[coin lands heads]` - it is historically possible that the coin lands heads (there exists a history where this occurs).

**Past Tense** (`P`): "It was the case that A" - true at time t iff A holds at some past time t' < t in the same history.

**Semantics**: Quantifies existentially over past times in the current history.

**Examples**:
- `P[raining]` - it was raining (at some past time)
- `P[dinosaurs exist]` - dinosaurs existed (at some past time)

**Future Tense** (`F`): "It will be the case that A" - true at time t iff A holds at some future time t' > t in the same history.

**Semantics**: Quantifies existentially over future times in the current history.

**Examples**:
- `F[sun rises]` - the sun will rise (at some future time)
- `F[meeting occurs]` - a meeting will occur (at some future time)

**Always Past** (`H`): "It has always been the case that A" - true at time t iff A holds at all past times t' < t in the same history.

**Semantics**: Universal quantification over past times: `HA := ¬P¬A`.

**Example**: `H[laws of physics hold]` - the laws of physics have always held.

**Always Future** (`G`): "It will always be the case that A" - true at time t iff A holds at all future times t' > t in the same history.

**Semantics**: Universal quantification over future times: `GA := ¬F¬A`.

**Example**: `G[entropy increases]` - entropy will always increase (at all future times).

**Temporal Ordering**: Time points are linearly ordered within each history (`<` relation), but different histories may branch from common past, creating tree structure for historical modality.

**Integration with Counterfactuals**: Counterfactual conditionals (`□→`) select histories that differ minimally from a given history at a specified time, then evaluate consequent at later time in selected histories. This connects historical and temporal operators with counterfactual reasoning.

**Example Analysis**: `If Paul had been home, the child wouldn't have gotten hurt` evaluated at time x in history h:
- There is a past time y < x (past tense)
- Consider all histories j where `Paul is home` at y (historical quantification)
- That differ minimally from h (counterfactual selection)
- In all such histories j, `child is not hurt` at x (counterfactual necessity)

This combines past tense operator (P), historical quantification (□ₕ/◇ₕ), and counterfactual conditional (□→) to express complex temporal-modal reasoning.

## Causal Layer

The Core Layer and Modal Layer provide a foundation for evaluating causal claims which relate a causal event that is earlier in time to an effect that is later in time. For instance, `Pushing the button causes the launch sequence to initiate` relates the truth of `The button is pushed` at one time in a possible history to the truth of `The launch sequence is initiating` at a later time in that history. Since causal claims entail counterfactual conditional claims, testing counterfactual conditional claims may be used to either falsify or support for causal claims. For instance, `If the button is pushed, the launch sequence will initiate` is true at any time `x` in a possible history `h` in which `Pushing the button causes the launch sequence to initiate` is also true. The extent of the range of possible histories in which a causal claim is true at a given time determines the strength of that causal connection as well as the enabling and disabling conditions.

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

## Epistemic Layer

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

## Normative Layer

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

## Operator Interactions

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

## Related Documentation

- [METHODOLOGY.md](../UserGuide/METHODOLOGY.md) - Philosophical foundations and layer overview
- [ARCHITECTURE.md](../UserGuide/ARCHITECTURE.md) - Layer 0 (Core TM) technical specification
- [DUAL_VERIFICATION.md](DUAL_VERIFICATION.md) - RL training architecture
- [PROOF_LIBRARY_DESIGN.md](PROOF_LIBRARY_DESIGN.md) - Theorem caching design
- [IMPLEMENTATION_STATUS.md](../ProjectInfo/IMPLEMENTATION_STATUS.md) - Current state of the project

---

_Last updated: December 2025_
