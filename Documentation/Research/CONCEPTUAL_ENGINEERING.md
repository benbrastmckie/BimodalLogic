# Conceptual Engineering: Philosophical Foundations for the Logos Layer Architecture

## Metadata
- **Date**: 2025-12-08
- **Status**: Research vision
- **Related**: [Layer Extensions](LAYER_EXTENSIONS.md) | [Methodology](../UserGuide/METHODOLOGY.md) | [Architecture](../UserGuide/ARCHITECTURE.md)

## Introduction: Formal Logic as Conceptual Engineering

### Formal Logic as Conceptual Engineering

Formal logic serves two fundamentally different purposes. The first, more traditional approach is **descriptive**: analyzing existing patterns of reasoning in natural language to formalize valid argument structures we already employ. The second approach is **normative**: stipulating logical operators fit for systematic applications, particularly in verified AI reasoning systems. This second approach constitutes what we call **conceptual engineering**—the normative science of designing operators we ought to have for rigorous reasoning, not merely describing operators we do have.

The Logos adopts conceptual engineering as its guiding methodology. Just as material engineers refine glass from sand or steel from iron ore—transforming raw natural materials into precise substances with engineered properties—philosophical logic engineers theoretical concepts from natural language into formal operators with explicit semantic clauses. Natural language provides the raw ingredients: intuitive notions of necessity, possibility, past, future, causation, knowledge, and obligation. Conceptual engineering refines these intuitions into precise formal operators with clearly defined truth conditions over explicit semantic models.

This engineering perspective has crucial implications for AI reasoning systems. Unlike human reasoning, which can tolerate ambiguity and informal inference, AI systems require operators with precise computational semantics. The descriptive approach—formalizing natural language usage patterns—produces operators whose meaning remains tied to the inconsistencies and context-dependencies of ordinary discourse. The normative approach—stipulating operators fit for verified reasoning—produces operators whose meaning is fixed by explicit semantic clauses independent of natural language usage.

Consider the modal operator `□` (necessity). A descriptive approach asks: "How do humans actually use 'necessarily' in ordinary language?" and attempts to formalize this usage. A normative approach asks: "What truth conditions should the necessity operator have to support verified reasoning about metaphysical modality?" For AI systems requiring proof receipts, the normative question is primary. The Logos specifies `□φ` as true at a model-history-time triple exactly when `φ` holds at all accessible worlds at that time, where accessibility is defined by the task relation's properties. This precise semantic clause enables both theorem proving (LEAN 4 derivations) and model checking (Z3 countermodel search) independent of how humans ordinarily use modal language.

### Normative vs Descriptive Logic

The distinction between normative and descriptive logic reflects a deeper question: what is the purpose of formal logic? If the purpose is understanding human reasoning, descriptive analysis is appropriate. If the purpose is building AI reasoning systems with verified inference and explicit semantics, normative specification is essential.

**Descriptive Logic** analyzes natural language reasoning patterns:
- **Data source**: How humans actually reason in natural language
- **Goal**: Formalize existing argument structures
- **Validity**: An argument is valid if it matches human intuitive standards
- **Semantics**: Truth conditions approximate natural language usage
- **Operators**: Determined by analyzing linguistic data

**Normative Logic** stipulates operators for verified reasoning:
- **Data source**: Requirements from AI applications (planning, verification, oversight)
- **Goal**: Specify operators with precise computational semantics
- **Validity**: An argument is valid if it satisfies formal semantic clauses
- **Semantics**: Truth conditions are engineered for clarity and compositionality
- **Operators**: Determined by reasoning requirements, not linguistic usage

For AI systems, the normative approach has decisive advantages. Human reasoning data is limited, inconsistent, and prone to error. Training language models on human reasoning patterns replicates these inconsistencies at scale. By contrast, operators with explicit semantic clauses provide clean training data: theorem proving generates valid inferences guaranteed by soundness proofs, while model checking generates countermodels refuting invalid claims. This dual verification architecture (see [DUAL_VERIFICATION.md](DUAL_VERIFICATION.md)) produces consistent, verifiable training data not achievable through descriptive formalization of human reasoning.

The conceptual engineering approach also enables **interpretability** crucial for scalable oversight. Each operator in the Logos has explicit truth conditions defined over task semantic models (possible worlds as functions from times to world-states). When an AI system derives `□△φ` (necessarily, always `φ`), the semantic clause specifies precisely what this means: `φ` holds at all accessible worlds at all times in their temporal domains. This explicit semantics allows human overseers to verify whether derivations accurately represent the intended claims, providing transparency unavailable in purely pattern-matching approaches.

### Extensible Operator Methodology

The Logos layer architecture embodies the conceptual engineering approach through **progressive extensibility**: applications select precisely the operators needed for their domain without carrying unused overhead. This methodology treats logical operators as modular components with clear compositional semantics.

**Layer 0 (Core TM)** provides the foundation: S5 modal operators (`□`, `◇` for necessity and possibility) combined with linear temporal operators (`G`, `F`, `H`, `P` for future and past quantification). This bimodal logic TM (Tense and Modality) supports reasoning about metaphysical necessity and temporal evolution. The core layer is complete—all axioms proven sound, all inference rules verified—providing a stable foundation for extensions.

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

The tense operators provide the temporal structure (representing that success occurs in the future), while modal and probabilistic operators enable comparing alternative possible futures. Without tense operators, we cannot distinguish between Plan A succeeding eventually (`F(success)`) versus Plan A succeeding immediately (`success`). Without modal operators, we cannot represent that both plans are possible alternatives to be compared.

### World-Histories and Temporal Evolution

The semantic foundation for planning requires a precise model of **temporal evolution**. The Logos task semantics provides this through **world-histories**: functions from times to world-states representing how a possible world evolves temporally.

Formally, a **world-history** `w` is a function `w: T → S` where:
- `T` is a set of times (convex subset of the real numbers)
- `S` is a set of world-states
- `w(t)` represents the state of world `w` at time `t`

This semantic structure captures the intuitive idea that possible worlds are not static snapshots but **temporal evolutions**. At each time `t`, world `w` has a determinate state `w(t)`, and the sequence of states `{w(t) | t ∈ T}` represents how that world unfolds over time.

**Why this structure matters for planning**: Plans are proposals about how the world should evolve. When an AI system considers Plan A, it is considering a class of world-histories where Plan A is executed and its consequences unfold over time. The world-history `w_A` represents one possible way Plan A could unfold: `w_A(t_0)` is the initial state when Plan A begins, `w_A(t_1)` is the state after the first action, and so forth. Different world-histories in the class represent different possible outcomes of Plan A given environmental uncertainty.

The task relation constrains which world-histories are accessible from a given world-state-time triple. If world `w` is at state `s` at time `t`, the task relation specifies which alternative world-histories are possible continuations from that state-time point. This captures the idea that planning is constrained by current circumstances: from state `s` at time `t`, only certain future evolutions are realistically achievable.

**Tense operators evaluated over world-histories**:
- `Gφ` is true at `(w,t)` iff `φ` is true at `(w,t')` for all `t' > t` in `w`'s temporal domain
- `Fφ` is true at `(w,t)` iff `φ` is true at `(w,t')` for some `t' > t` in `w`'s temporal domain
- `Hφ` is true at `(w,t)` iff `φ` is true at `(w,t')` for all `t' < t` in `w`'s temporal domain
- `Pφ` is true at `(w,t)` iff `φ` is true at `(w,t')` for some `t' < t` in `w`'s temporal domain

These truth conditions explain why world-histories are functions from times to states: evaluating `Gφ` at `(w,t)` requires checking `φ` at all future times in `w`, which presupposes that `w` specifies states for those future times. The temporal structure of world-histories enables tense operators to quantify over future and past times within a single possible world's evolution.

### Expected Value via Counterfactual Comparison

Planning requires comparing the expected value of executed plans against **counterfactual alternatives**—ways the world could have evolved if different actions had been taken. This comparative evaluation is the core of rational decision-making under uncertainty.

The expected value of a plan is not an absolute measure but a **relative comparison**: Plan A has positive expected value relative to Plan B if the likely outcomes of Plan A are preferable to the likely outcomes of Plan B. This comparison is inherently counterfactual: when evaluating Plan A, we ask "How would the world evolve under Plan A compared to how it would evolve under Plan B?"

**Why tense operators are essential**: Counterfactual comparison requires representing alternative temporal evolutions from the same decision point. At time `t_0`, the AI system faces a choice: execute Plan A or Plan B. The expected value comparison requires representing:
1. **Actual evolution under Plan A**: World-histories where Plan A is executed from `t_0`
2. **Counterfactual evolution under Plan B**: World-histories where Plan B is executed from `t_0` instead
3. **Temporal divergence**: Both evolution classes agree on states before `t_0` but diverge after `t_0`

Tense operators enable this representation. Let `plan_A_executed` be true iff Plan A is executed at the current time. Then:
- `plan_A_executed ∧ Fφ_A`: If Plan A is executed, then `φ_A` will hold in the future
- `plan_B_executed ∧ Fφ_B`: If Plan B is executed, then `φ_B` will hold in the future

The counterfactual comparison asks: "Suppose Plan A is executed (actual) versus suppose Plan B is executed (counterfactual)—which future evolution is preferable?" This requires tense operators to represent future evolution under each plan, plus modal or counterfactual operators to represent the comparison between actual and counterfactual evolutions.

**Perpetuity principles and temporal quantification**: The Logos Core Layer includes derived operators `△φ` (always, at all times) and `▽φ` (sometimes, at some time) for temporal quantification. These operators, combined with modal operators, enable expressing claims about persistent properties across temporal evolutions:
- `□△φ`: Necessarily, always `φ` (metaphysical necessity of perpetuity)
- `◇▽φ`: Possibly, sometimes `φ` (metaphysical possibility of occurrence)
- `△◇φ`: Always possibly `φ` (persistent possibility)
- `▽□φ`: Sometimes necessarily `φ` (occurrent necessity)

These bimodal combinations express complex temporal-modal claims crucial for planning. For instance, `△◇φ` represents that `φ` remains persistently possible across all times—even if `φ` is not currently actual, it could be achieved at any future time. This captures the idea of **persistent opportunities**: options that remain available throughout a plan's execution.

The perpetuity principles (P1-P6) formalize relationships between modal and temporal quantification, providing inference rules for reasoning about these bimodal combinations. For details on these principles and their proofs, see [ARCHITECTURE.md](../UserGuide/ARCHITECTURE.md) Section 4.

### From Tense to Modality

Planning under uncertainty requires both temporal and modal operators working in tandem. Tense operators represent temporal evolution within a single possible world, while modal operators represent alternative possible worlds for comparison. This bimodal structure—tense plus modality—is essential for capturing both aspects of planning.

**Why tense alone is insufficient**: Pure temporal logic (tense operators without modality) can represent evolution over time but cannot represent alternative possibilities. If the future is deterministic—only one possible evolution from each state-time point—then planning reduces to prediction. But genuine planning under uncertainty requires representing multiple possible futures, comparing their expected values, and selecting actions likely to produce preferable outcomes. This requires modal operators to represent the space of possibilities.

**Why modality alone is insufficient**: Pure modal logic (modal operators without tense) can represent alternative possible worlds but cannot represent temporal evolution within those worlds. Without temporal structure, we cannot distinguish between "Plan A eventually succeeds" (temporal evolution to success) and "Plan A immediately succeeds" (success at current time). Planning requires representing that actions have temporal consequences: executing action `A` at time `t` affects world-states at later times `t' > t`.

**Bimodal integration**: The TM logic (Tense and Modality) combines both dimensions:
- **Temporal evolution within worlds**: Tense operators (`G`, `F`, `H`, `P`) quantify over times within a world-history
- **Alternative evolutions across worlds**: Modal operators (`□`, `◇`) quantify over alternative world-histories
- **Task semantics coordination**: All world-histories share temporal structure (times from convex real number subsets) and are constrained by the task relation

This bimodal structure enables representing planning claims like:
- `◇Gφ`: Possibly, `φ` will always hold (there exists a plan achieving perpetual `φ`)
- `□Fφ`: Necessarily, `φ` will eventually hold (all plans eventually reach `φ`)
- `G◇φ`: Always, `φ` is possible (persistent possibility throughout temporal evolution)
- `F□φ`: Eventually, `φ` becomes necessary (future certainty)

For the formal axiomatization of TM bimodal logic, including axiom schemata and soundness proofs, see [ARCHITECTURE.md](../UserGuide/ARCHITECTURE.md). The Core Layer implementation provides all axioms and inference rules with verified soundness, creating a stable foundation for the layer extensions discussed in subsequent sections.

## From Tense to Counterfactual: Layer 1 Requirements

### Partial vs Complete World-Histories

The Core Layer task semantics represents plans as classes of complete world-histories: functions `w: T → S` mapping every time in a convex temporal domain to a determinate world-state. This representation is theoretically precise but pragmatically limited: real plans specify only **partial world-histories**, leaving many details of temporal evolution unspecified.

A **partial world-history** specifies world-states for some times but leaves others indeterminate. For example, a plan to "launch product by Q4 2026" specifies:
- **Specified**: Initial state (current product development status), target state (product launched by end of Q4 2026)
- **Unspecified**: Intermediate states (exact development milestones, marketing strategies, resource allocation decisions)

The unspecified aspects are intentionally left open: the plan constrains the overall trajectory without prescribing every implementation detail. This partiality is essential for flexible planning—overly specific plans become brittle when environmental conditions change.

**Approximating partiality via sets of complete world-histories**: The Core Layer approximates partial world-histories by representing a plan as a **set of complete world-histories** agreeing on the specified aspects. The plan "launch product by Q4 2026" corresponds to the set of all world-histories `w` where:
- `w(t_now)` matches the current development status
- `w(t)` for `t ∈ Q4_2026` satisfies "product launched"
- `w(t)` for intermediate times can vary arbitrarily (subject to physical possibility)

This set-based approximation works adequately for Core Layer reasoning: tense and modal operators quantify over these sets, and the task relation constrains which sets are accessible from given state-time points. However, the approximation becomes inadequate when integrating counterfactual operators.

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

Layer 1 extends the Core Layer without replacing it. The tense and modal operators from TM logic continue to operate as defined, but now over semantic models enriched with mereological structure. This integration preserves several key properties:

**Semantic continuity**: Core Layer formulas have identical truth conditions in Layer 1 models when evaluated over complete world-histories. The mereological structure only affects evaluation of formulas involving counterfactual or causal operators.

**Compositional interpretation**: Operators from different layers compose freely. Complex formulas like `□(φ ○→ Fψ)` (necessarily, `φ` causes future `ψ`) embed causal operator (Layer 1) inside modal operator (Core Layer) inside future tense (Core Layer). The semantics compose via standard recursive evaluation.

**Task relation preservation**: The task relation constraining accessible world-histories continues to operate in Layer 1 models. Mereological structure does not alter which world-histories are accessible from given state-time points; it only enriches the internal structure of world-states.

**Progressive extension pattern**: Layer 1 demonstrates the general pattern for extending the Logos: add semantic structure to support new operators, define truth conditions for new operators over enriched models, verify that existing operators retain their semantics, prove soundness of new axioms and inference rules. This pattern enables unbounded layer addition while preserving backward compatibility.

The next section examines Layers 2-3, which build on Layer 1's mereological foundation to add epistemic and normative operators for reasoning under uncertainty and multi-agent coordination.

## Epistemic and Normative Extensions: Layers 2-3 Requirements

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
- **Layer 0 (Core TM)**: Tense and modal operators for temporal evolution and alternative possibilities
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

### Dual Verification Connection

Conceptual engineering provides the foundation for the Logos **dual verification architecture**: combining theorem proving (LEAN 4) with model checking (Z3) to generate clean training data for AI reasoning systems.

**Theorem proving generates valid inferences**: The LEAN 4 implementation proves theorems deriving formulas from axioms via sound inference rules. Each derivation `Γ ⊢ φ` (premises `Γ` derive conclusion `φ`) is a verified proof receipt demonstrating that `φ` follows from `Γ` by valid reasoning. The soundness proofs guarantee that derivable formulas are semantically valid: if `Γ ⊢ φ`, then `Γ ⊨ φ` (semantic consequence).

**Model checking refutes invalid claims**: The Z3 implementation searches for countermodels demonstrating that formulas are not valid. A countermodel for `φ` is a task semantic model where `φ` is false, proving that `φ` is not a logical truth. Countermodels provide concrete refutations: "Here is a specific world-history-time triple where `φ` fails."

**Training data generation**: The dual verification architecture produces training data pairs:
- **Positive examples**: (formula, derivation) pairs where LEAN 4 proves the formula
- **Negative examples**: (formula, countermodel) pairs where Z3 refutes the formula

This training data is qualitatively superior to human reasoning data because:
1. **Consistency**: Soundness guarantees prevent deriving contradictions
2. **Completeness coverage**: Systematic exploration of formula space via proof search
3. **Verifiable receipts**: Each example includes verification (proof or countermodel)
4. **Explicit semantics**: Countermodels demonstrate truth conditions concretely

For detailed dual verification architecture including RL training specification, see [DUAL_VERIFICATION.md](DUAL_VERIFICATION.md). For implementation status and known limitations, see [IMPLEMENTATION_STATUS.md](../ProjectInfo/IMPLEMENTATION_STATUS.md).

### Implementation Status and Future Work

The Logos Core Layer (Layer 0) implementation is complete:
- **12 axioms proven sound**: MT, M4, MB, T4, TA, TL, MF, TF, modal_k_dist, double_negation, prop_k, prop_s
- **8 inference rules proven**: axiom, assumption, modus_ponens, weakening, modal_k, temporal_k, temporal_duality, necessitation
- **Perpetuity principles**: P1-P4 fully proven with zero sorry placeholders, P5-P6 axiomatized
- **Automation tactics**: 12 custom tactics including `tm_auto` (Aesop integration) for proof automation

This complete Core Layer provides a stable foundation for implementing Layers 1-3. The extension specifications in [LAYER_EXTENSIONS.md](LAYER_EXTENSIONS.md) provide detailed operator semantics, axiom schemata, and inference rules ready for LEAN 4 implementation. Future work will:

1. **Implement Layer 1**: Mereological structure, counterfactual and causal operators, soundness proofs
2. **Implement Layer 2**: Epistemic operators, accessibility relations for knowledge/belief, axiomatization
3. **Implement Layer 3**: Normative operators, deontic accessibility, preference orderings
4. **Dual verification integration**: Z3 model checking for Layers 1-3 formulas
5. **RL training pipeline**: Automated training data generation via dual verification

The conceptual engineering methodology ensures that these extensions maintain the same rigorous standards as the Core Layer: explicit semantics, proven soundness, comprehensive testing, and verified automation.

For current implementation status including module-by-module completion and known limitations, see [IMPLEMENTATION_STATUS.md](../ProjectInfo/IMPLEMENTATION_STATUS.md). For contribution guidelines and development standards, see [CONTRIBUTING.md](../Development/CONTRIBUTING.md).
