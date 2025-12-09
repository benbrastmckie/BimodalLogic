# Conceptual Engineering: Philosophical Foundations for the Logos Layer Architecture

> NOTE: this document is still full of AI slop, requiring heavy revision

## Introduction: Formal Logic as Conceptual Engineering

### Terminology: README to Technical Mapping

This document expands on the conceptual foundations introduced in [README.md § Motivations](../../README.md#motivations) (lines 61-68). The following terminology mapping connects README's concise formulations to this document's technical exposition:

| README Term (lines 61-68) | Technical Elaboration in This Document |
|----------------------------|----------------------------------------|
| **Historical modal operators** | S5 modal operators (`□`, `◇`) quantifying over alternative world-histories (§ Extensible Operator Methodology) |
| **Tense operators** | Linear temporal operators (`G`, `F`, `H`, `P`) for past/future quantification within world-histories (§ World-Histories and Temporal Evolution) |
| **Future contingency** | Bimodal combinations of tense and historical modal operators representing alternative possible futures (§ From Tense to Modality) |
| **Counterfactual scrutiny** | Comparative evaluation of plan expected values against counterfactual alternatives (§ Expected Value via Counterfactual Scrutiny) |
| **Conceptual engineering** | Normative methodology for stipulating logical operators fit for systematic reasoning applications (§ Formal Logic as Conceptual Engineering) |

For comprehensive definitions, see [GLOSSARY.md](../Reference/GLOSSARY.md). For operator notation, see [OPERATORS.md](../Reference/OPERATORS.md).

### How to Read This Document

**For readers coming from README.md**: This document expands on [README.md § Motivations](../../README.md#motivations) (lines 61-68) and [§ RL TRAINING](../../README.md#rl-training) (lines 45-56). The README provides concise motivations; this document provides philosophical foundations and technical elaboration. Key section mappings:
- README "conceptual engineering" → § Formal Logic as Conceptual Engineering
- README "planning under uncertainty" → § Planning Under Uncertainty: The Pragmatic Motivation
- README "dual verification" → § Dual Verification: Training Signal Architecture
- README "extensible operators" → § Extensible Operator Methodology, § Epistemic and Normative Extensions

**For readers seeking technical specifications**: This document focuses on conceptual motivations, not implementation details. For formal specifications:
- Axiom schemata and soundness proofs → [ARCHITECTURE.md](../UserGuide/ARCHITECTURE.md)
- Layer 1-3 operator semantics → [LAYER_EXTENSIONS.md](LAYER_EXTENSIONS.md)
- Implementation status → [IMPLEMENTATION_STATUS.md](../ProjectInfo/IMPLEMENTATION_STATUS.md)
- LEAN 4 source code → [Logos/Core/](../../Logos/Core/)

**Reading paths**:
- **Overview path**: Read § Introduction and § Conclusion only
- **Planning motivation path**: §§ Introduction, Planning Under Uncertainty, Dual Verification
- **Layer architecture path**: §§ Introduction, Planning Under Uncertainty, From Tense to Counterfactual, Epistemic and Normative Extensions, Conclusion

### Formal Logic as Conceptual Engineering

> **README Context**: This section elaborates on [README.md § Motivations](../../README.md#motivations) lines 61-62, which frames formal logic as conceptual engineering analogous to material science refining raw materials into materials fit for building.

Natural language semantics is **descriptive**: analyzing how reasoning expressions like
"if...then" work in ordinary language to understand their actual usage patterns. By contrast,
formal logic is **normative**: engineering logical operators with precise truth conditions for
systematic reasoning, even when these operators differ from natural language usage. Designing operators we ought to have for rigorous reasoning, not merely describing operators we do
have.

The material conditional (`→`) exemplifies this approach: though counterintuitive as English "if...then" (making "if it is raining, the sky will fall tomorrow" true whenever it is not raining), it enables formal regimentation of universal quantification (`∀x(Human(x) → Mammal(x))`) and truth-functional reasoning—refining natural language into operators with theoretically valuable properties.

Just as material science refine glass from sand or steel from iron ore by transforming raw natural
materials into materials fit for building, philosophical logic engineers theoretical concepts from
natural language into logical operators with recursive semantic clauses. Natural language provides
the raw ingredients: intuitive notions of necessity, possibility, past, future, causation,
knowledge, and obligation. These conceptual targets are then refined into precise logical operators
with clearly defined truth conditions over explicit semantic models.

This engineering perspective has crucial implications for AI reasoning systems. Operators with
precise semantics and axiomatic proof theories generate unlimited clean training signals about valid
and invalid inferences. Theorem proving produces verified derivations guaranteed sound by
metalogical proofs, while model checking produces countermodels refuting invalid claims. This dual
verification architecture provides consistent, verifiable training signals not achievable by
formalizing inconsistent natural language reasoning patterns.

The normative approach preserves context through evaluation parameters—sentences are evaluated at
specific models, times, and worlds—while enabling systematic inference generation. For instance,
tensed sentences require temporal parameters for evaluation: `Fφ` (φ will be true) is evaluated at
model-history-time triple `(M, w, t)` by checking whether `φ` holds at future times in
world-history `w`. Context is made explicit through these parameters, not eliminated.

Consider the modal operator `□` (necessity). A descriptive approach asks: "How do humans actually
use 'necessarily' in ordinary language?" and attempts to formalize this usage. A normative approach
asks: "What truth conditions should the necessity operator have to support verified reasoning about
modality in planning contexts?" For AI systems requiring proof receipts, the normative question is
primary.

The Logos specifies `□φ` as true at a model-history-time triple exactly when `φ` holds at all
accessible world-histories at that time, where accessibility is defined by the task relation's
properties. This implements **historical modality**: the `□` operator quantifies over
task-constrained world evolutions (possible ways the world could unfold given current constraints),
not unrestricted metaphysically possible worlds. World-histories are functions from times to
world-states, representing how possible worlds evolve temporally under task constraints.

This precise semantic clause enables both theorem proving (LEAN 4 derivations) and model checking
(Z3 countermodel search) independent of how humans ordinarily use modal language. The focus on
historical modality—temporal evolutions constrained by tasks—makes the modal operator suitable for
planning applications where necessity means "holds in all achievable futures" rather than "holds in
all metaphysically possible worlds."

### Normative Logic vs Descriptive Semantics

Descriptive logic analyzes natural language reasoning patterns to formalize existing argument structures. Normative logic stipulates operators for verified reasoning based on AI application requirements (planning, verification, oversight). For AI systems, the normative approach has decisive advantages: human reasoning data is limited and inconsistent, while operators with explicit semantic clauses provide clean training signals through dual verification (theorem proving generates valid inferences, model checking generates countermodels). See [DUAL_VERIFICATION.md](DUAL_VERIFICATION.md) for architecture details.

The conceptual engineering approach also enables **interpretability** crucial for scalable oversight. Each operator in the Logos has explicit truth conditions defined over task semantic models (possible worlds as functions from times to world-states). When an AI system derives `□△φ` (necessarily, always `φ`), the semantic clause specifies precisely what this means: `φ` holds at all accessible worlds at all times in their temporal domains. This explicit semantics allows human overseers to verify whether derivations accurately represent the intended claims, providing transparency unavailable in purely pattern-matching approaches.

### Extensible Operator Methodology

The Logos layer architecture embodies the conceptual engineering approach through **progressive extensibility**: applications select precisely the operators needed for their domain without carrying unused overhead. This methodology treats logical operators as modular components with clear compositional semantics.

**Layer 0 (Core TM)** provides the foundation: S5 historical modal operators (`□`, `◇` for necessity and possibility) combined with linear tense operators (`G`, `F`, `H`, `P` for future and past quantification). This bimodal logic TM (Tense and Modality) supports reasoning about metaphysical necessity and temporal evolution. The core layer is complete—all axioms proven sound, all inference rules verified—providing a stable foundation for extensions.

**Layer 1 (Explanatory)** adds counterfactual (`□→`, `◇→`) and causal (`○→`) operators building on the core temporal-modal foundation. These operators require enhanced semantic structure (mereological parthood relations over world-states) but preserve the task semantics framework where possible worlds are functions from times to world-states.

**Layer 2 (Epistemic)** introduces operators for reasoning under uncertainty: belief (`B`), misinformation (`Mi`), uncertainty (`Mu`), and probabilistic reasoning (`Pr`). These operators enable AI systems to represent knowledge states and reason about information available at different world-state-time triples.

**Layer 3 (Normative)** provides deontic operators for obligations (`O`), permissions (`P`), and preference orderings (`≺`) supporting multi-agent coordination and plan evaluation. These operators build on the epistemic layer to represent what ought to be the case given agent knowledge and goals.

This architecture enables applications to select operator combinations matching their requirements:
- **Metaphysical reasoning**: Core Layer only (TM bimodal logic)
- **Planning under uncertainty**: Layers 0-1 (temporal, modal, counterfactual operators)
- **Epistemic planning**: Layers 0-2 (add belief and probability operators)
- **Multi-agent coordination**: Layers 0-3 (full operator suite)

Each layer integrates compositionally: operators from higher layers can embed operators from lower layers in their scope, and semantic clauses compose via explicit recursive definitions. This modularity is the methodological implementation of conceptual engineering—operators are engineered components with precise interfaces, not monolithic descriptions of natural language usage.

The extensibility is **unbounded**: future layers can add operators for additional domains (alethic logic, deontic logic variants, epistemic probability) as application requirements emerge. The conceptual engineering approach treats operator addition as normative specification: What truth conditions should this operator have? What semantic structure must be added to support these truth conditions? How do the new operators compose with existing operators? These questions guide systematic extension independent of natural language usage patterns.

For detailed dual verification architecture supporting this methodology, see [METHODOLOGY.md](../UserGuide/METHODOLOGY.md). For technical layer specifications, see [LAYER_EXTENSIONS.md](LAYER_EXTENSIONS.md). For the Core Layer formal axiomatization, see [ARCHITECTURE.md](../UserGuide/ARCHITECTURE.md).

## Planning Under Uncertainty: The Pragmatic Motivation

> **README Context**: This section elaborates on [README.md § Motivations](../../README.md#motivations) lines 63-66, which identifies planning under uncertainty as the core pragmatic motivation for the Logos architecture.

### Plans as High Expected Value Futures

The Logos layer architecture is motivated by a specific pragmatic requirement: AI systems must plan under uncertainty by selecting actions with highest expected value. This requirement drives the choice of foundational operators and semantic structure.

A **plan** is a proposed sequence of actions intended to achieve desired outcomes. Plans are not certainties but **high expected value futures**—possible courses of action that, given available information, are likely to produce favorable outcomes compared to alternatives. Planning is fundamentally comparative: evaluating whether Plan A has higher expected value than Plan B requires representing both plans as temporal evolutions and comparing their likely consequences.

This comparative evaluation has crucial semantic implications. To represent "Plan A has higher expected value than Plan B," we must represent:
1. **Alternative temporal evolutions**: Different ways the world could unfold depending on which plan is executed
2. **Evaluation at specific times**: The expected value of a plan at the time of decision-making, not retrospectively
3. **Comparison across possibilities**: Assessing how Plan A and Plan B perform across different possible outcomes

These requirements explain why tense operators (`G`, `F`, `H`, `P`) and modal operators (`□`, `◇`) are foundational. Tense operators represent temporal evolution: `Fφ` means `φ` will be true at some future time, while `Gφ` means `φ` will be true at all future times. Modal operators represent alternative possibilities: `◇φ` means `φ` is true at some accessible possible world, while `□φ` means `φ` is true at all accessible worlds. Together, these operators enable representing and comparing alternative temporal evolutions—the core requirement for planning under uncertainty.

Consider an AI system deciding between two plans:
- **Plan A**: Invest resources in Project X
- **Plan B**: Invest resources in Project Y

To evaluate expected value, the system must represent:
- `F(project_x_succeeds)`: Plan A leads to future success of Project X
- `F(project_y_succeeds)`: Plan B leads to future success of Project Y
- `◇F(project_x_succeeds) ∧ ◇F(project_y_succeeds)`: Both outcomes are possible futures
- `Pr(F(project_x_succeeds)) > Pr(F(project_y_succeeds))`: Project X has higher probability of success

The tense operators provide the temporal structure (representing that success occurs in the future), while historical modal and probabilistic operators enable comparing alternative possible futures. Without tense operators, we cannot distinguish between Plan A succeeding eventually (`F(success)`) versus Plan A succeeding immediately (`success`). Without historical modal operators, we cannot represent that both plans are possible alternatives to be compared.

### World-Histories and Temporal Evolution

The semantic foundation for planning requires distinguishing two levels of analysis:

**Semantic Level (World-Histories)**: In the formal semantics, a world-history is a complete function `w: T → S` from convex time subsets to world-states, respecting the task relation. This completeness enables recursive truth evaluation for tense operators. See [WorldHistory.lean](../../Logos/Core/Semantics/WorldHistory.lean) for formal specification.

**Pragmatic Level (Plan Specifications)**: Real-world plans do not specify complete
world-histories. A plan like "launch product by Q4 2026" provides only **partial
constraints**:
- Initial state: current development status
- Target condition: product launched by end of Q4 2026
- Unspecified: intermediate milestones, resource allocations, implementation details

**Core Layer Approximation**: The Core Layer bridges these levels by representing a plan
specification as a **set of complete world-histories** that satisfy the plan's constraints.
The plan "launch product by Q4 2026" corresponds to:

```
Plan = {w : WorldHistory F |
  w(t_now) matches current state ∧
  w(t) satisfies "product launched" for t ∈ Q4_2026}
```

This set contains all physically possible complete temporal evolutions satisfying the
plan's constraints.

**Task Relation as Causal Constraint**: The task relation `F.task_rel : WorldState → T → WorldState → Prop` constrains accessible world-histories to physically achievable temporal evolutions, with nullity (identity task always achievable) and compositionality (sequential task composition). This ensures historical modal operators quantify over achievable plans, not arbitrary mathematical possibilities. See [TaskFrame.lean](../../Logos/Core/Semantics/TaskFrame.lean) for formal properties.

### Truth Conditions for Tense Operators in Planning Contexts

Tense operators quantify over times within a single world-history, representing temporal evolution under a fixed plan: `Gφ` (always in future), `Fφ` (sometime in future), `Hφ` (always in past), `Pφ` (sometime in past). These operators enable intra-world temporal quantification without introducing alternative worlds. For formal truth conditions, see [Truth.lean](../../Logos/Core/Semantics/Truth.lean) lines 110-123.

**Inter-World Plan Comparison via Modal Operators**:

To compare alternative plans, we need historical modal operators quantifying over **different
world-histories**:

- `◇Gφ` (possibly, always φ): There exists a plan where `φ` holds throughout the future
  - **Modal quantification**: There exists world-history `w'` accessible from current
    state
  - **Temporal quantification**: In `w'`, `φ` holds at all future times
  - **Truth Condition**: `∃ w' : WorldHistory F, w'.domain t ∧
    (∀ t' > t, w'.domain t' → truth_at M w' t' φ)`

- `□Fφ` (necessarily, sometime φ): Under all possible plans, `φ` will eventually occur
  - **Modal quantification**: For all world-histories `w'` accessible from current state
  - **Temporal quantification**: In each `w'`, `φ` holds at some future time
  - **Truth Condition**: `∀ w' : WorldHistory F, w'.domain t →
    (∃ t' > t, w'.domain t' ∧ truth_at M w' t' φ)`

**Why Both Are Essential**: Planning requires comparing temporal evolutions (tense)
across alternative scenarios (modal). Pure temporal logic cannot represent alternative
plans; pure modal logic cannot represent temporal evolution within plans. The TM bimodal
logic provides both dimensions.

### Expected Value via Counterfactual Scrutiny

Planning requires comparing the expected value of executed plans against **counterfactual alternatives**—ways the world could have evolved if different actions had been taken. This counterfactual scrutiny is the core of rational decision-making under uncertainty.

The expected value of a plan is not an absolute measure but a **relative comparison**: Plan A has positive expected value relative to Plan B if the likely outcomes of Plan A are preferable to the likely outcomes of Plan B. This comparison is inherently counterfactual: when evaluating Plan A, we ask "How would the world evolve under Plan A compared to how it would evolve under Plan B?"

**Why tense operators are essential**: Counterfactual scrutiny requires representing alternative temporal evolutions from the same decision point. At time `t_0`, the AI system faces a choice: execute Plan A or Plan B. The expected value comparison requires representing:
1. **Actual evolution under Plan A**: World-histories where Plan A is executed from `t_0`
2. **Counterfactual evolution under Plan B**: World-histories where Plan B is executed from `t_0` instead
3. **Temporal divergence**: Both evolution classes agree on states before `t_0` but diverge after `t_0`

Tense operators enable this representation. Let `plan_A_executed` be true iff Plan A is executed at the current time. Then:
- `plan_A_executed ∧ Fφ_A`: If Plan A is executed, then `φ_A` will hold in the future
- `plan_B_executed ∧ Fφ_B`: If Plan B is executed, then `φ_B` will hold in the future

Counterfactual scrutiny asks: "Suppose Plan A is executed (actual) versus suppose Plan B is executed (counterfactual)—which future evolution is preferable?" This requires tense operators to represent future evolution under each plan, plus historical modal or counterfactual operators to represent the comparison between actual and counterfactual evolutions.

**Perpetuity principles and temporal quantification**: The Logos Core Layer includes derived operators `△φ` (always, at all times) and `▽φ` (sometimes, at some time) for temporal quantification. These operators, combined with historical modal operators, enable expressing claims about persistent properties across temporal evolutions:
- `□△φ`: Necessarily, always `φ` (metaphysical necessity of perpetuity)
- `◇▽φ`: Possibly, sometimes `φ` (metaphysical possibility of occurrence)
- `△◇φ`: Always possibly `φ` (persistent possibility)
- `▽□φ`: Sometimes necessarily `φ` (occurrent necessity)

These bimodal combinations express complex temporal-modal claims crucial for planning. For instance, `△◇φ` represents that `φ` remains persistently possible across all times—even if `φ` is not currently actual, it could be achieved at any future time. This captures the idea of **persistent opportunities**: options that remain available throughout a plan's execution.

The perpetuity principles (P1-P6) formalize relationships between modal and temporal quantification, providing inference rules for reasoning about these bimodal combinations. For details on these principles and their proofs, see [ARCHITECTURE.md](../UserGuide/ARCHITECTURE.md) Section 4.

### From Tense to Modality

Planning under uncertainty requires both tense and historical modal operators working in tandem. Tense operators represent temporal evolution within a single possible world, while historical modal operators represent alternative possible worlds for comparison. This bimodal structure—tense plus modality—is essential for capturing both aspects of planning.

**Why tense alone is insufficient**: Pure temporal logic (tense operators without modality) can represent evolution over time but cannot represent alternative possibilities. If the future is deterministic—only one possible evolution from each state-time point—then planning reduces to prediction. But genuine planning under uncertainty requires representing multiple possible futures, comparing their expected values, and selecting actions likely to produce preferable outcomes. This requires historical modal operators to represent the space of possibilities.

**Why modality alone is insufficient**: Pure modal logic (historical modal operators without tense) can represent alternative possible worlds but cannot represent temporal evolution within those worlds. Without temporal structure, we cannot distinguish between "Plan A eventually succeeds" (temporal evolution to success) and "Plan A immediately succeeds" (success at current time). Planning requires representing that actions have temporal consequences: executing action `A` at time `t` affects world-states at later times `t' > t`.

**Bimodal integration**: The TM logic (Tense and Modality) combines both dimensions:
- **Temporal evolution within worlds**: Tense operators (`G`, `F`, `H`, `P`) quantify over times within a world-history
- **Alternative evolutions across worlds**: Historical modal operators (`□`, `◇`) quantify over alternative world-histories
- **Task semantics coordination**: All world-histories share temporal structure (times from convex real number subsets) and are constrained by the task relation

This bimodal structure enables representing planning claims like:
- `◇Gφ`: Possibly, `φ` will always hold (there exists a plan achieving perpetual `φ`)
- `□Fφ`: Necessarily, `φ` will eventually hold (all plans eventually reach `φ`)
- `G◇φ`: Always, `φ` is possible (persistent possibility throughout temporal evolution)
- `F□φ`: Eventually, `φ` becomes necessary (future certainty)

For the formal axiomatization of TM bimodal logic, including axiom schemata and soundness proofs, see [ARCHITECTURE.md](../UserGuide/ARCHITECTURE.md). The Core Layer implementation provides all axioms and inference rules with verified soundness, creating a stable foundation for the layer extensions discussed in subsequent sections.

## Dual Verification: Training Signal Architecture

> **README Context**: This section elaborates on [README.md § RL TRAINING](../../README.md#rl-training) (lines 45-56), which frames dual verification as the methodology for generating clean training signals combining theorem proving (valid inferences) with model checking (countermodel refutations).

### Training Signal Requirements for AI Reasoning

The conceptual engineering approach to logical operators creates unique opportunities for training AI reasoning systems. Unlike natural language reasoning data—which is limited, inconsistent, and prone to error—formal operators with explicit semantic clauses enable **systematic generation of verified training signals**.

**The training signal challenge**: Effective AI reasoning requires both positive signals (examples of valid inferences) and corrective signals (examples of invalid inferences with concrete counterexamples). Human reasoning data provides neither reliably: human inferences may be invalid despite appearing sound, and human error identification rarely includes formal countermodels demonstrating why an inference fails.

**Dual verification solution**: The Logos addresses this through **dual verification architecture** combining:
1. **Theorem proving (LEAN 4)**: Generates positive training signals as verified derivations
2. **Model checking (Z3)**: Generates corrective training signals as countermodels refuting invalid claims

This architecture produces training signals with three essential properties ([README.md § RL TRAINING](../../README.md#rl-training) lines 49-51):
- **Unbounded**: Infinite theorems are derivable from the axiom system
- **Clean**: Soundness guarantees only valid inferences are derivable
- **Justified**: LEAN 4 proofs provide verifiable receipts; Z3 countermodels refute invalid claims

### Dual Verification Implementation

**Theorem proving generates valid inferences**: The LEAN 4 implementation proves theorems deriving formulas from axioms via sound inference rules. Each derivation `Γ ⊢ φ` (premises `Γ` derive conclusion `φ`) is a verified proof receipt demonstrating that `φ` follows from `Γ` by valid reasoning. The soundness proofs guarantee that derivable formulas are semantically valid: if `Γ ⊢ φ`, then `Γ ⊨ φ` (semantic consequence).

**Model checking refutes invalid claims**: The Z3 implementation searches for countermodels demonstrating that formulas are not valid. A countermodel for `φ` is a task semantic model where `φ` is false, proving that `φ` is not a logical truth. Countermodels provide concrete refutations with explicit world-history-time triples where the formula fails, enabling AI systems to understand **why** an inference is invalid.

**Training signal generation**: The dual verification architecture produces training signal pairs:
- **Positive examples**: (formula, derivation) pairs where LEAN 4 proves the formula
- **Negative examples**: (formula, countermodel) pairs where Z3 refutes the formula

These training signals are qualitatively superior to human reasoning data because:
1. **Consistency**: Soundness guarantees prevent deriving contradictions
2. **Completeness coverage**: Systematic exploration of formula space via proof search
3. **Verifiable receipts**: Each example includes verification (proof or countermodel)
4. **Explicit semantics**: Countermodels demonstrate truth conditions concretely over task semantic models

### Scalable Oversight Through Explicit Semantics

Beyond training signal generation, the dual verification architecture enables **scalable oversight** of AI reasoning ([README.md § RL TRAINING](../../README.md#rl-training) line 53). Each operator has explicit truth conditions defined over task semantic models (world-histories as functions from times to world-states). When an AI system derives `□△φ` (necessarily, always `φ`), the semantic clause specifies precisely what this means: `φ` holds at all accessible world-histories at all times in their temporal domains.

This explicit semantics provides interpretability unavailable in pattern-matching approaches:
- **Proof receipts**: Human overseers can verify LEAN 4 derivations step-by-step
- **Countermodel inspection**: Human overseers can examine Z3 countermodels to understand inference failures
- **Semantic grounding**: Operators have precise meanings independent of training data patterns

The combination of verified derivations and refutational countermodels creates a foundation for reliable AI reasoning with human oversight at scale. For detailed dual verification architecture including RL training specification, see [DUAL_VERIFICATION.md](DUAL_VERIFICATION.md).

**Conceptual bridge to Layer 1**: While the Core Layer's dual verification architecture provides clean training signals for tense and historical modal reasoning, extending to counterfactual and causal operators (Layer 1) requires enriched semantic structure. The mereological framework discussed in the next section enables dual verification for counterfactual scrutiny—generating training signals about comparative plan evaluation and causal relationships.

## From Tense to Counterfactual: Layer 1 Requirements

### Partial Plan Specifications vs Complete World-Histories

**Conceptual Distinction**: We must carefully distinguish two concepts that are easily
confused:

1. **Complete World-History (Semantic)**: A total function `w: T → S` specifying the
   world-state at every time in a convex temporal domain. This is the fundamental
   semantic object used in truth evaluation (see WorldHistory.lean lines 69-97).

2. **Partial Plan Specification (Pragmatic)**: A set of constraints on world-states at
   some times, leaving other times and state features unspecified. This is what human
   planners actually create.

**Example**: Consider a plan to "launch product by Q4 2026":

**As Partial Plan Specification** (pragmatic level):
- Constraint at `t_now`: `product_status = "development"`
- Constraint for `t ∈ Q4_2026`: `product_status = "launched"`
- **Unspecified**: Exact development milestones, marketing strategies, resource
  allocations, team compositions, market conditions at intermediate times

**As Set of Complete World-Histories** (semantic level):
```
Plan = {w : WorldHistory F |
  w(t_now) satisfies "product_status = development" ∧
  (∀ t ∈ Q4_2026, w(t) satisfies "product_status = launched")}
```

Each `w ∈ Plan` is a **complete** world-history specifying states at all times in its
domain. The set contains all complete temporal evolutions compatible with the plan's
constraints.

**Why Core Layer Uses Complete World-Histories**:

The recursive truth evaluation for tense operators **requires** complete world-histories:

```lean
-- From Truth.lean lines 110-111
| Formula.all_future φ =>
    ∀ (s : T) (hs : τ.domain s), t < s → truth_at M τ s hs φ
```

To evaluate `Gφ` ("always in the future φ") at world-history `τ` and time `t`, we must:
1. Identify all times `s > t` in `τ`'s domain
2. Evaluate `φ` at each such time-state pair `(τ(s), s)`
3. Check that `φ` holds at **all** such pairs

This quantification is only well-defined if `τ` specifies states for all times in its
domain. A "partial world-history" with "unspecified" times would make this evaluation
undefined.

**Core Layer Approximation Strategy**:

The Core Layer approximates partial plan specifications using **sets of complete
world-histories**:

**Representation**:
```
Partial_Plan_Spec ⟿ {w : WorldHistory F | w satisfies all specified constraints}
```

**Evaluation of Planning Claims**:
- "Under this plan, φ always holds": `∀ w ∈ Plan, truth_at M w t (Gφ)`
- "Under this plan, φ eventually occurs": `∀ w ∈ Plan, truth_at M w t (Fφ)`
- "There exists a way to execute this plan where φ holds":
  `∃ w ∈ Plan, truth_at M w t φ`

**Adequacy for Core Layer**: This approximation works well for temporal and modal
reasoning because tense and historical modal operators naturally quantify over sets:
- Tense operators: quantify over times within each world-history in the set
- Historical modal operators: quantify over alternative world-histories (the set members)

**Inadequacy for Layer 1 Counterfactuals**: The set-based approximation breaks down when
evaluating counterfactuals like "If we had allocated more resources to marketing, the
launch would have succeeded." The problem: which aspects of the plan should be held fixed
(ceteris paribus) and which should vary under the counterfactual supposition?

The set `{w | w satisfies plan constraints}` provides no way to distinguish:
- Plan-relevant features (should vary under counterfactual)
- Plan-independent features (should be held fixed under counterfactual)

This motivates Layer 1's **mereological structure** over world-states, enabling explicit
representation of which state features are specified by the plan versus unspecified (see
Mereological Structure for Counterfactuals section below for details).

### Mereological Structure for Counterfactuals

Counterfactual reasoning requires comparing what actually happens against what would have happened under alternative conditions. The counterfactual conditional `φ □→ ψ` (if it were that `φ`, then it would be that `ψ`) evaluates truth by considering alternative possible worlds where `φ` holds and checking whether `ψ` holds in those alternatives.

The set-based approximation of partial world-histories creates problems for counterfactual semantics. Consider the counterfactual: "If we had allocated more resources to marketing (φ), the product launch would have succeeded (ψ)." To evaluate this counterfactual, we need to consider alternative world-histories where additional marketing resources are allocated, holding other aspects of the plan fixed (ceteris paribus).

But which aspects should be held fixed? The set-based representation provides no principled answer. The plan "launch product by Q4 2026" is approximated by a massive set of complete world-histories varying in arbitrary ways. When evaluating the counterfactual, should we:
1. Hold fixed only the initial state and target deadline?
2. Hold fixed all specified aspects of the current plan?
3. Hold fixed some intermediate milestones?

The set-based approach provides no way to distinguish which aspects of world-histories are **plan-relevant** (should be varied under counterfactual supposition) versus **plan-independent** (should be held fixed). This is the partiality problem: without explicit representation of which world-state features are specified by the plan versus unspecified, we cannot properly evaluate counterfactuals.

**Mereological structure solution**: Layer 1 extends the semantic structure with **mereological parthood relations** over world-states. Each world-state `s` is analyzed as a **fusion of partial states**: `s = s_1 ⊔ s_2 ⊔ ... ⊔ s_n` where:
- Each `s_i` is a partial state specifying some but not all features of the world
- `⊔` is mereological fusion (combining partial states into complete states)
- Parthood relation `s_i ⊑ s` indicates `s_i` is part of `s`

This mereological structure enables representing partial world-histories directly: instead of approximating "launch product by Q4 2026" as a set of complete world-histories, Layer 1 represents it as a **partial world-history** `w_partial` where:
- `w_partial(t_now)` specifies only product development status (leaving other features open)
- `w_partial(t)` for `t ∈ Q4_2026` specifies only product launch status
- `w_partial(t)` for intermediate times may be undefined or specify limited features

Counterfactuals over partial world-histories have well-defined semantics: `φ □→ ψ` is true at `(w_partial, t)` iff all minimal complete extensions of `w_partial` satisfying `φ` also satisfy `ψ`. The mereological structure determines which complete world-histories are **minimal extensions**: those adding just enough detail to make `w_partial` complete while preserving all specified partial states.

For detailed Layer 1 semantic specifications including formal mereological structure and counterfactual truth conditions, see [LAYER_EXTENSIONS.md](LAYER_EXTENSIONS.md) Lines 15-118.

### From Counterfactual to Causal Operators

Mereological structure over world-states creates foundations not only for counterfactual operators but also for **causal operators**. Causation involves productive relationships: event `A` causes event `B` when `A`'s occurrence brings about `B`'s occurrence through some productive mechanism.

Philosophical analysis of causation often reduces causal claims to counterfactual claims: "`A` causes `B`" means "If `A` had not occurred, `B` would not have occurred" (`¬A □→ ¬B`). This counterfactual analysis provides truth conditions for causal claims via comparison of actual and counterfactual world-histories.

However, the counterfactual analysis faces challenges:
1. **Spurious causation**: Correlated effects of common causes satisfy the counterfactual but are not genuine causation
2. **Preemption**: Backup causes that would produce the effect if the actual cause failed
3. **Overdetermination**: Multiple sufficient causes each of which would produce the effect independently

Layer 1 addresses these challenges with explicit **causal operator** `○→` distinct from counterfactual operators. The causal conditional `φ ○→ ψ` (φ causes ψ) has truth conditions requiring not just counterfactual dependence but also **productive connection** via the mereological structure.

Formally, `φ ○→ ψ` is true at `(w,t)` when:
1. `φ` and `ψ` are both true at `(w,t)` (actual occurrence)
2. The world-state parts making `φ` true are **mereologically prior** to parts making `ψ` true
3. There exists a **productive path** through the mereological structure from `φ`-parts to `ψ`-parts

The mereological priority condition ensures temporal/modal asymmetry: causes precede (or are modally prior to) effects. The productive path condition ensures genuine causal connection rather than mere correlation. Together, these conditions provide a semantic foundation for causal reasoning building directly on the mereological structure required for counterfactuals.

**Planning applications**: Causal operators enable AI systems to represent productive relationships in plans. When evaluating "Allocating resources to marketing causes increased sales," the system checks whether the mereological parts of world-states making "marketing resources allocated" true are productively connected to parts making "increased sales" true. This goes beyond counterfactual reasoning ("If we hadn't allocated resources, sales wouldn't have increased") to represent genuine causal mechanisms.

For detailed causal operator semantics and axiomatization, see [LAYER_EXTENSIONS.md](LAYER_EXTENSIONS.md) Lines 79-88.

### Integration with Core Layer

Layer 1 extends the Core Layer without replacing it. The tense and historical modal operators from TM logic continue to operate as defined, but now over semantic models enriched with mereological structure. This integration preserves several key properties:

**Semantic continuity**: Core Layer formulas have identical truth conditions in Layer 1 models when evaluated over complete world-histories. The mereological structure only affects evaluation of formulas involving counterfactual or causal operators.

**Compositional interpretation**: Operators from different layers compose freely. Complex formulas like `□(φ ○→ Fψ)` (necessarily, `φ` causes future `ψ`) embed causal operator (Layer 1) inside modal operator (Core Layer) inside future tense (Core Layer). The semantics compose via standard recursive evaluation.

**Task relation preservation**: The task relation constraining accessible world-histories continues to operate in Layer 1 models. Mereological structure does not alter which world-histories are accessible from given state-time points; it only enriches the internal structure of world-states.

**Progressive extension pattern**: Layer 1 demonstrates the general pattern for extending the Logos: add semantic structure to support new operators, define truth conditions for new operators over enriched models, verify that existing operators retain their semantics, prove soundness of new axioms and inference rules. This pattern enables unbounded layer addition while preserving backward compatibility.

The next section examines Layers 2-3, which build on Layer 1's mereological foundation to add epistemic and normative operators for reasoning under uncertainty and multi-agent coordination.

## Epistemic and Normative Extensions: Layers 2-3 Requirements

> **README Context**: This section elaborates on [README.md § Motivations](../../README.md#motivations) lines 67-68, which identifies the need for explanatory, epistemic, and normative operators as part of the extensible layer architecture.

**Conceptual bridge from Layer 1**: Layer 1's counterfactual and causal operators enable representing plan evaluation and causal mechanisms. However, real-world planning rarely operates with complete information. Layers 2-3 address this limitation by adding epistemic operators (representing knowledge and uncertainty) and normative operators (representing obligations and preferences), enabling AI systems to reason about plans under realistic conditions of incomplete information and multi-agent coordination.

### Causation Under Epistemic Assumptions

Real-world causal reasoning rarely operates with complete information. When an AI system evaluates "Allocating resources to marketing causes increased sales," this causal claim is typically understood **relative to epistemic assumptions**: given what the system knows (or assumes) about market conditions, consumer behavior, and competitive landscape, the causal connection holds.

Layer 1's causal operator `○→` provides truth conditions for causation as productive connection via mereological structure. However, these truth conditions presuppose complete world-histories: to evaluate whether `φ ○→ ψ` holds at `(w,t)`, we must examine the mereological structure of world-state `w(t)` and verify productive paths from `φ`-making parts to `ψ`-making parts. But if the system's knowledge is incomplete—the actual world-history `w` is only partially known—how can causal claims be evaluated?

**Epistemic parameter for causal operators**: Layer 2 addresses this by adding an **epistemic parameter** to causal operators. Instead of bare `φ ○→ ψ`, Layer 2 provides `○→_K(φ,ψ)` (causation relative to knowledge state `K`). The truth conditions become:
- `○→_K(φ,ψ)` is true at `(w,t)` iff in all world-histories epistemically accessible from `(w,t)` (compatible with knowledge state `K`), the mereological structure supports productive connection from `φ` to `ψ`

This epistemic relativity captures how causal reasoning operates under uncertainty: we cannot verify the actual productive connection (which would require complete knowledge), but we can verify that the productive connection holds across all epistemically possible world-histories given current knowledge.

Consider the marketing causation example. The system's knowledge state `K_marketing` might include:
- Market research data on consumer preferences
- Historical sales correlations with marketing spend
- Competitive analysis of similar products
- Budget constraints and resource allocation options

The causal claim `○→_K_marketing(marketing_resources, increased_sales)` is true iff across all world-histories compatible with `K_marketing`, allocating marketing resources creates productive connection to increased sales. This is weaker than claiming absolute causation (which would require complete knowledge of all market factors) but stronger than mere correlation (which wouldn't verify productive connection).

**Planning applications**: Epistemic parameters enable AI systems to reason about causation under realistic knowledge constraints. When evaluating plans, the system need not have complete information about world-evolution; it suffices to verify that causal relationships hold across epistemically possible evolutions given available knowledge. This makes causal reasoning tractable for real-world planning under uncertainty.

For detailed Layer 2 epistemic operators and their integration with causal operators, see [LAYER_EXTENSIONS.md](LAYER_EXTENSIONS.md) Lines 132-228.

### Preference Orderings for Plan Evaluation

Planning requires not only representing alternative temporal evolutions (Core Layer) and causal relationships (Layer 1) but also **evaluating which evolutions are preferable**. The expected value of a plan depends on preference orderings over possible outcomes: Plan A has higher expected value than Plan B when the likely outcomes of Plan A are preferred to the likely outcomes of Plan B.

**Preference operator**: Layer 3 introduces preference ordering `≺` (strict preference) over world-histories or world-state-time triples. The formula `w_A ≺ w_B` (world-history `w_A` is strictly preferred to `w_B`) expresses comparative evaluation: outcomes in `w_A` are more valuable than outcomes in `w_B` according to the agent's preference structure.

Preference orderings have specific formal properties required for rational planning:
1. **Asymmetry**: If `w_A ≺ w_B`, then `¬(w_B ≺ w_A)` (if A is preferred to B, B is not preferred to A)
2. **Transitivity**: If `w_A ≺ w_B` and `w_B ≺ w_C`, then `w_A ≺ w_C` (preference ordering is transitive)
3. **Acyclicity**: No cycles like `w_A ≺ w_B ≺ w_C ≺ w_A` (prevents preference inconsistency)

These properties ensure preference orderings provide well-defined rankings suitable for decision-making. An AI system can use preference orderings to evaluate plans: Plan A is superior to Plan B iff the world-histories where Plan A succeeds are preferred to world-histories where Plan B succeeds, weighted by probability of each evolution.

**Integration with epistemic and causal operators**: Preference orderings interact with epistemic and causal operators to enable sophisticated plan evaluation. Consider the formula:
- `B_agent(○→_K(φ,ψ)) ∧ (w_ψ ≺ w_¬ψ)` (The agent believes `φ` causes `ψ` given knowledge `K`, and `ψ`-worlds are preferred to `¬ψ`-worlds)

This formula represents that the agent believes action `φ` will causally produce desirable outcome `ψ`. The belief operator `B_agent` represents the agent's epistemic state, the causal operator `○→_K` represents productive connection, and the preference operator `≺` represents desirability of outcomes. Together, these operators enable representing the full decision-theoretic structure: beliefs about causal relationships combined with preferences over outcomes.

**Expected value calculation**: Combining preference orderings with probabilistic operators (`Pr`) enables expected value calculation. The expected value of executing action `φ` is:
- `∑_w Pr(w | φ) × V(w)` where `V(w)` is the value assigned to world-history `w` via preference ordering

The probabilistic operator `Pr(w | φ)` represents the probability of world-history `w` conditional on executing `φ`, and the value function `V(w)` is derived from the preference ordering (higher-ranked worlds get higher values). The expected value formula aggregates probable outcomes weighted by their values, providing the decision-theoretic foundation for rational planning.

For detailed preference operator semantics and axiomatization, see [LAYER_EXTENSIONS.md](LAYER_EXTENSIONS.md) Lines 261-273.

### Epistemic Operators for Uncertainty

Layer 2 provides a suite of epistemic operators representing different aspects of knowledge and uncertainty:

**Belief operator** `B_agent(φ)` (agent believes `φ`): Represents the agent's doxastic state. `B_agent(φ)` is true at `(w,t)` iff `φ` holds in all world-histories doxastically accessible from `(w,t)`—world-histories the agent considers possible given their beliefs. Belief is weaker than knowledge: the agent can believe false propositions if their doxastic alternatives include non-actual world-histories.

**Knowledge operator** `K_agent(φ)` (agent knows `φ`): Represents genuine knowledge requiring truth and justification. `K_agent(φ)` is true at `(w,t)` iff:
1. `φ` is true at `(w,t)` (factivity: knowledge requires truth)
2. `φ` holds in all epistemically accessible world-histories from `(w,t)` (justification: knowledge requires ruling out alternatives)

Knowledge is stronger than belief: if the agent knows `φ`, then `φ` must be true and the agent's epistemic state must rule out all `¬φ` possibilities.

**Misinformation operator** `Mi_agent(φ)` (agent has misinformation that `φ`): Represents false beliefs. `Mi_agent(φ)` is true iff the agent believes `φ` but `φ` is false: `B_agent(φ) ∧ ¬φ`. Misinformation represents epistemic error: the agent's doxastic state incorrectly represents reality.

**Uncertainty operator** `Mu_agent(φ)` (agent is uncertain about `φ`): Represents lack of definite belief. `Mu_agent(φ)` is true iff the agent neither believes `φ` nor believes `¬φ`: `¬B_agent(φ) ∧ ¬B_agent(¬φ)`. Uncertainty represents genuine epistemic openness: the agent's doxastic alternatives include both `φ`-worlds and `¬φ`-worlds.

**Probabilistic operator** `Pr_agent(φ) = r` (agent assigns probability `r` to `φ`): Represents degrees of belief. Instead of binary belief/disbelief, probability assigns real-valued credence in `[0,1]` to propositions. Probabilistic reasoning enables expected value calculations and Bayesian updating as evidence arrives.

**Planning applications**: Epistemic operators enable AI systems to represent and reason about their own knowledge states. When evaluating plans under uncertainty, the system can distinguish:
- **Known facts**: `K_agent(φ)` (information the system can rely on)
- **Believed assumptions**: `B_agent(φ) ∧ ¬K_agent(φ)` (working hypotheses that may be false)
- **Uncertain variables**: `Mu_agent(φ)` (factors requiring exploration or information gathering)
- **Probabilistic estimates**: `Pr_agent(φ) = 0.7` (quantified uncertainty)

These distinctions enable sophisticated reasoning: the system can identify knowledge gaps requiring investigation, adjust plans when beliefs are uncertain, and update probability estimates as new evidence arrives.

For detailed epistemic operator specifications including axioms and accessibility relation constraints, see [LAYER_EXTENSIONS.md](LAYER_EXTENSIONS.md) Lines 132-228.

### Normative Operators for Multi-Agent Coordination

Layer 3 extends epistemic reasoning to **normative reasoning**: representing what ought to be the case, what agents are permitted to do, and how agents should coordinate. Normative operators are essential for multi-agent planning where actions must respect obligations, permissions, and shared norms.

**Obligation operator** `O(φ)` (it is obligatory that `φ`): Represents deontic necessity. `O(φ)` is true at `(w,t)` iff `φ` holds in all deontically ideal world-histories accessible from `(w,t)`—world-histories where all obligations are fulfilled. Obligations constrain rational action: agents should choose plans producing world-histories satisfying their obligations.

**Permission operator** `P(φ)` (it is permissible that `φ`): Represents deontic possibility. `P(φ)` is true iff `φ` holds in some deontically ideal world-history accessible from `(w,t)`. Permissions define the space of acceptable actions: agents may choose any action producing permissible outcomes.

**Prohibition operator** `F(φ)` (it is forbidden that `φ`): Defined as `O(¬φ)` (obligatory that not-`φ`). Prohibitions exclude certain actions from consideration: plans producing forbidden outcomes are inadmissible regardless of expected value.

**Deontic-epistemic interaction**: Normative operators interact with epistemic operators to represent **ought-under-ignorance**: what an agent should do given limited knowledge. Consider:
- `B_agent(φ) ∧ O(φ → ψ)`: The agent believes `φ` holds, and there is an obligation that if `φ` then `ψ`

This combination represents that the agent should ensure `ψ` given their belief in `φ` and the conditional obligation. The interaction is crucial for real-world normative reasoning: agents must act on beliefs (not just knowledge), and obligations apply conditionally based on epistemic states.

**Multi-agent coordination**: Normative operators enable representing coordination requirements:
- `O(agent_A_acts → agent_B_responds)`: Conditional obligation for agent B's response to agent A's action
- `P(agent_A_acts) ∧ P(agent_B_acts) ∧ F(agent_A_acts ∧ agent_B_acts)`: Both actions individually permissible but jointly forbidden (coordination constraint)
- `O(K_A(φ) → K_B(φ))`: Obligation for information sharing (agent A's knowledge should be transmitted to agent B)

These coordination formulas enable AI systems to reason about joint action, responsibility distribution, and information sharing requirements in multi-agent planning.

**Preference-deontic integration**: Obligations interact with preference orderings to resolve conflicts between what is preferred and what is required. When `O(φ)` (obligation for `φ`) conflicts with `w_¬φ ≺ w_φ` (preference for `¬φ`-worlds over `φ`-worlds), the obligation takes precedence: rational agents follow obligations even when outcomes are dispreferred. This integration provides a decision-theoretic foundation for deontic constraints.

For detailed normative operator specifications including deontic accessibility relations and axiomatization, see [LAYER_EXTENSIONS.md](LAYER_EXTENSIONS.md) Lines 240-454.

## Conclusion: Progressive Extension Methodology

### Conceptual Engineering Recap

This document has presented the Logos layer architecture through the lens of **conceptual engineering**—the normative science of stipulating logical operators fit for systematic reasoning applications. Unlike descriptive approaches that formalize existing natural language patterns, conceptual engineering asks: What operators should AI systems have for verified reasoning about planning, causation, knowledge, and norms?

The material engineering analogy is instructive. Just as glass is refined from sand through controlled chemical processes that remove impurities and create useful transparency, formal operators are refined from natural language concepts through semantic engineering that removes ambiguities and creates precise truth conditions. Natural language provides intuitive notions of necessity, temporality, causation, and obligation; conceptual engineering transforms these intuitions into operators with explicit semantic clauses suitable for theorem proving and model checking.

This normative approach has decisive advantages for AI systems:
1. **Precision**: Operators have well-defined truth conditions independent of linguistic usage patterns
2. **Compositionality**: Complex formulas compose via recursive semantic evaluation
3. **Verifiability**: Derivations can be proven sound and countermodels can refute invalid claims
4. **Interpretability**: Semantic clauses provide explicit meaning for human oversight
5. **Extensibility**: New operators can be added systematically without disrupting existing semantics

The Logos demonstrates this methodology across four layers:
- **Layer 0 (Core TM)**: Tense and historical modal operators for temporal evolution and alternative possibilities
- **Layer 1 (Explanatory)**: Counterfactual and causal operators building on mereological structure
- **Layer 2 (Epistemic)**: Knowledge, belief, and probabilistic operators for reasoning under uncertainty
- **Layer 3 (Normative)**: Deontic operators for obligations, permissions, and multi-agent coordination

Each layer extends the semantics systematically while preserving backward compatibility with lower layers. This progressive extension pattern exemplifies conceptual engineering: operators are engineered components with precise interfaces, not monolithic descriptions of natural language.

### Unbounded Extensibility

The layer architecture is **unbounded**: future extensions can add operators for any domain requiring formal reasoning. Potential Layer 4+ extensions include:
- **Alethic operators**: Additional modal logics beyond S5 (e.g., S4, K, T) for weaker necessity concepts
- **Dynamic operators**: Program operators for reasoning about state changes and sequential composition
- **Probabilistic refinement**: Quantified probability logics with continuous distributions
- **Game-theoretic operators**: Strategic operators for multi-agent game scenarios
- **Temporal extensions**: Branching time, interval temporal logic, metric temporal logic

The conceptual engineering approach provides a methodology for adding these operators systematically:

1. **Identify pragmatic requirements**: What reasoning tasks require these operators?
2. **Design semantic structure**: What mathematical structure must be added to support truth conditions?
3. **Define truth conditions**: What are the precise semantic clauses for new operators?
4. **Verify compositionality**: How do new operators compose with existing operators?
5. **Prove soundness**: Are the axioms and inference rules sound over the enriched semantics?
6. **Implement verification**: Can theorem provers and model checkers handle the new operators?

This systematic process ensures that layer extensions maintain the quality standards of conceptual engineering: precision, compositionality, verifiability, and interpretability.

**Application-specific operator selection**: The unbounded extensibility enables applications to select precisely the operator combinations needed for their domain. Applications need not adopt all layers; they can choose:
- **Metaphysical reasoning**: Core Layer only (TM bimodal logic)
- **Causal modeling**: Layers 0-1 (temporal, modal, counterfactual, causal operators)
- **Epistemic planning**: Layers 0-2 (add belief and probability for uncertainty)
- **Multi-agent systems**: Layers 0-3 (full operator suite for normative coordination)
- **Custom combinations**: Select specific operators from each layer matching domain needs

This modularity prevents operator bloat: applications carry only the semantic structure and verification overhead required for their actual reasoning tasks.

### Implementation Status and Future Work

Core Layer (Layer 0) implementation is complete with 12 axioms proven sound, 8 inference rules proven, perpetuity principles P1-P6 fully proven, and 12 automation tactics. Future work includes implementing Layers 1-3 (counterfactual/causal, epistemic, normative operators), Z3 model checking integration, and RL training pipeline. See [LAYER_EXTENSIONS.md](LAYER_EXTENSIONS.md) for specifications.

### Related Documentation

This document integrates with the following project documentation:

- **[README.md](../../README.md)**: Project overview with concise motivations for the Logos architecture (§ Motivations lines 61-68, § RL TRAINING lines 45-56)
- **[ARCHITECTURE.md](../UserGuide/ARCHITECTURE.md)**: Formal axiomatization of Core Layer TM bimodal logic with soundness proofs
- **[LAYER_EXTENSIONS.md](LAYER_EXTENSIONS.md)**: Technical specifications for Layers 1-3 (counterfactual, epistemic, normative operators)
- **[DUAL_VERIFICATION.md](DUAL_VERIFICATION.md)**: RL training architecture combining theorem proving (LEAN 4) with model checking (Z3)
- **[IMPLEMENTATION_STATUS.md](../ProjectInfo/IMPLEMENTATION_STATUS.md)**: Module-by-module completion tracking and known limitations
- **[METHODOLOGY.md](../UserGuide/METHODOLOGY.md)**: Philosophical methodology and layer architecture design principles
- **[CONTRIBUTING.md](../Development/CONTRIBUTING.md)**: Contribution guidelines and development standards
