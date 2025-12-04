# Layer Architecture Requirements

**Report Date**: 2025-12-04
**Analysis Scope**: Layer specifications from README.md and LAYER_EXTENSIONS.md
**Purpose**: Document semantic requirements for Logos layered architecture

## Executive Summary

This report analyzes the four-layer architecture specified in project documentation, identifying the semantic requirements, operator specifications, and critical architectural decisions for each layer. The analysis reveals fundamental semantic differences between layers that will impact the refactoring strategy.

## 1. Logos Architecture Overview

### Core Principle

**"Any combination of extensions can be added to the Core Layer"**

The Logos architecture follows a progressive extension methodology where semantic extensions can be added to Core Layer in any combination, enabling domain-specific customization.

### Four-Layer System

1. **Layer 0 (Core TM)**: Boolean, Modal, Temporal operators (IMPLEMENTED)
2. **Layer 1 (Explanatory)**: Counterfactual, Constitutive, Causal operators (PLANNED)
3. **Layer 2 (Epistemic)**: Belief, Probability, Knowledge operators (PLANNED)
4. **Layer 3 (Normative)**: Obligation, Permission, Preference operators (PLANNED)

### Semantic Foundation

**Shared Basis**: "All layers share a common semantic foundation: hyperintensional task semantics where possible worlds are functions from times to world-states, constrained by task relations."

**Critical Qualification**: While layers share *foundational concepts*, the *interpretation* of key semantic primitives differs between layers.

## 2. Layer 0 (Core TM) - Current Implementation

### 2.1 Operator Inventory

#### Boolean Operators
- `¬` (negation)
- `∧` (conjunction)
- `∨` (disjunction)
- `→` (material implication)
- `↔` (material biconditional)
- `⊥` (falsity)
- `⊤` (truth)

#### Modal Operators (S5 Logic)
- `□` (box/necessity): "It is necessary that φ"
- `◇` (diamond/possibility): "It is possible that φ"

**Semantic Interpretation**: Quantification over all possible worlds (world histories) at given time.

**S5 Axioms**:
- MT: `□φ → φ` (reflexivity)
- M4: `□φ → □□φ` (transitivity)
- MB: `φ → □◇φ` (symmetry)

#### Temporal Operators (Linear Temporal Logic)
- `P` (Past): "It was the case that φ" (universal past)
- `F` (Future): "It will be the case that φ" (universal future)
- `H` (Always Past): "It has always been that φ" (historical necessity)
- `G` (Always Future): "It will always be that φ" (future necessity)
- `past` (sometime past): "It was sometime that φ"
- `future` (sometime future): "It will be sometime that φ"

**Semantic Interpretation**: Quantification over times in same world history's domain.

**Temporal Axioms**:
- T4: `Future φ → Future Future φ` (future transitivity)
- TA: `φ → Future past φ` (temporal accessibility)
- TL: `△φ → Future Past φ` (temporal linearity)

#### Bimodal Operators
- `△` (always/henceforth): "φ at all times" (alias for Future)
- `▽` (sometimes/eventually): "φ at some time" (dual of always)

**Bimodal Interaction Axioms**:
- MF: `□φ → □Future φ` (necessity distributes over future)
- TF: `□φ → Future □φ` (necessity persists through time)

### 2.2 Semantic Structures

#### TaskFrame (Core Layer)

**Definition** (from TaskFrame.lean):
```lean
structure TaskFrame (T : Type) [LinearOrderedAddCommGroup T] where
  WorldState : Type                                    -- CORE INTERPRETATION: Points
  task_rel : WorldState → T → WorldState → Prop       -- Task relation
  nullity : ∀ w, task_rel w 0 w                        -- Identity constraint
  compositionality : ∀ w u v x y,                      -- Composition constraint
    task_rel w x u → task_rel u y v → task_rel w (x + y) v
```

**Critical Semantic Property**: `WorldState` represents **points** (atomic, unstructured world states).

**Task Relation Interpretation**:
- `task_rel w x u`: State `u` reachable from state `w` via task of duration `x`
- Represents possible temporal transitions between world states
- Constrained by nullity (reflexivity) and compositionality (transitivity)

#### WorldHistory (Possible Worlds)

**Definition** (from WorldHistory.lean):
```lean
structure WorldHistory (F : TaskFrame T) where
  domain : T → Prop                                    -- Convex time domain
  convex : ∀ x z, domain x → domain z → x ≤ z →       -- No temporal gaps
    ∀ y, x ≤ y → y ≤ z → domain y
  states : (t : T) → domain t → F.WorldState          -- Maps times to states
  respects_task : ∀ x y, domain x → domain y → x ≤ y →
    F.task_rel (states x hx) (y - x) (states y hy)    -- Task constraint
```

**Critical Semantic Properties**:
1. **Convexity**: Domain cannot have temporal gaps
2. **Task Respect**: Temporal evolution must respect task relation
3. **Point-Based States**: `states` function maps to point-like world states

**Possible World Interpretation**: Function from convex time set to world states, constrained by task dynamics.

#### TaskModel

**Definition** (from TaskModel.lean):
```lean
structure TaskModel (T : Type) [LinearOrderedAddCommGroup T] where
  frame : TaskFrame T
  valuation : String → (τ : WorldHistory frame) → (t : T) →
    (h : τ.domain t) → Prop
```

**Valuation Function**: Maps atomic propositions to truth values at model-history-time triples.

#### Truth Evaluation

**Pattern** (from Truth.lean):
```lean
def truth_at (M : TaskModel T) (τ : WorldHistory M.frame) (t : T)
  (h : τ.domain t) : Formula → Prop
  | Formula.box φ => ∀ (τ' : WorldHistory M.frame) (h' : τ'.domain t),
      truth_at M τ' t h' φ                              -- Quantify over histories
  | Formula.future φ => ∀ (t' : T) (h' : τ.domain t'), t < t' →
      truth_at M τ t' h' φ                              -- Quantify over times
```

**Modal Semantics**: Box quantifies over all world histories at same time.
**Temporal Semantics**: Future quantifies over all future times in same history.

### 2.3 Perpetuity Principles

**Key Theorems** (from Perpetuity.lean):
- **P1**: `□φ → △φ` (necessary implies always)
- **P2**: `▽φ → ◇φ` (sometimes implies possible)
- **P3**: `□φ → □△φ` (necessity of perpetuity) ✓ FULLY PROVEN
- **P4**: `◇▽φ → ◇φ` (possibility of occurrence)
- **P5**: `◇▽φ → △◇φ` (persistent possibility)
- **P6**: `▽□φ → □△φ` (occurrent necessity is perpetual)

**Status**: P3 fully proven (zero sorry), others partial.

### 2.4 Implementation Status

**Completeness**:
- Syntax: 100% complete
- ProofSystem: 100% complete (8 axioms, 7 rules)
- Semantics: 100% complete (zero sorry)
- Soundness: 100% complete (8/8 axioms, 7/7 rules proven, zero sorry)
- Completeness: Infrastructure only (no proofs)
- Tactics: 4/12 implemented

**Source**: IMPLEMENTATION_STATUS.md

## 3. Layer 1 (Explanatory Extension) - Planned

### 3.1 Operator Inventory

#### Counterfactual Operators
- `□→` (would counterfactual): "If it were A, then it would be B"
- `◇→` (might counterfactual): "If it were A, then it might be B"

**Formal Definition**: `□A := ⊤ □→ A` (necessity definable via counterfactual)

**Semantic Requirements**:
- Selection functions picking closest possible worlds where antecedent holds
- Similarity ordering on world states
- Evaluation in selected worlds

**Contrast with Material Conditional**:
- `¬p → ¬p` trivially true (truth-functional)
- `¬p □→ ¬p` requires checking closest worlds where `¬p` holds (hyperintensional)

#### Constitutive Operators
- `≤` (grounding): "A is sufficient for B" or "A grounds B"
- `⊑` (essence): "A is necessary for B" or "A is essential to B"
- `≡` (propositional identity): "A just is B" (mutual grounding)
- `≼` (relevance): "A is wholly relevant to B"

**Formal Interdefinitions**:
- `A ≤ B := ¬A ⊑ ¬B` (duality)
- `A ≤ B := (A ∨ B) ≡ B` (alternative)
- `A ⊑ B := B ≡ (A ∧ B)` (alternative)
- `A ≡ B := (A ≤ B) ∧ (B ≤ A)` (mutual grounding)
- `A ≼ B := (A ∧ B) ≤ B` (via grounding)
- `A ≼ B := (A ∨ B) ⊑ B` (via essence)

**State-Based Semantics Requirements**:
- Verifier/falsifier state pairs for propositions
- Part-whole structure on states
- `A ≤ B`: verifiers of A contained in verifiers of B
- `A ⊑ B`: every verifier of B contains verifier of A as part

**Examples**:
- `[Sam is crimson] ≤ [Sam is red]` (grounding)
- `[Having 79 protons] ⊑ [Being gold]` (essence)
- `[Being a vixen] ≡ [Being a female fox]` (identity)

#### Causal Operator
- `○→` (causation): Productive causal relationships with temporal character

**Contrast with Grounding**:
- Grounding (`≤`): Constitutive and timeless
- Causation (`○→`): Productive and temporal

**Example**: `[Sam touches hot stove] ○→ [Sam feels pain]` (temporal production)

### 3.2 Critical Semantic Differences

#### WorldState Reinterpretation

**Layer 0 (Core)**: WorldState = **Points** (atomic, unstructured)

**Layer 1 (Explanatory)**: WorldState = **Maximal Possible States** (structured, with internal composition)

**Formal Requirement**:
```lean
-- Layer 1 semantic structure (conceptual)
structure MaximalState where
  verifiers : Set StateComponent      -- Positive parts making propositions true
  falsifiers : Set StateComponent     -- Negative parts making propositions false
  part_whole_order : StateComponent → StateComponent → Prop
  maximality : -- constraints ensuring state is maximal
```

**Implication**: Explanatory layer requires different TaskFrame instantiation:
- `Logos.Core.Semantics.TaskFrame` (points-based, current)
- `Logos.Explanatory.Semantics.TaskFrame` (maximal-states-based, future)

#### Selection Functions

**Requirement**: Counterfactual evaluation requires similarity ordering and selection:
```lean
-- Conceptual structure for Layer 1
structure CounterfactualFrame (T : Type) extends TaskFrame T where
  similarity : WorldState → WorldState → WorldState → Prop
  selection : Formula → WorldState → Set WorldState
  -- selection φ w = closest worlds to w where φ holds
```

**Counterfactual Truth Condition**:
```lean
-- A □→ B true at (M, τ, t) iff:
-- For all w' in (selection A (τ.states t)), B holds at w'
```

#### Grounding Relations

**Requirement**: Constitutive operators require proposition structure:
```lean
-- Conceptual structure for Layer 1
structure GroundingModel extends TaskModel where
  proposition_structure : Formula → Set MaximalState × Set MaximalState
  -- Returns (verifiers, falsifiers) for each formula
```

**Grounding Truth Condition**:
```lean
-- A ≤ B true iff verifiers(A) ⊆ verifiers(B)
```

### 3.3 Medical Treatment Planning Example

**Scenario**: Physician evaluates treatment strategies using counterfactuals.

**Strategy A** (certain bad outcome):
```
Prescribe(DrugA) ∧ Taking(MedicationX) □→ F(Normalize(BloodPressure)) ∧ F(Occur(LiverDamage))
```
Would-counterfactual: Drug A necessarily causes liver damage given medication X.

**Strategy C** (uncertain bad outcome):
```
Prescribe(DrugB) ∧ Taking(MedicationX) □→ F(Normalize(BloodPressure)) ∧ ¬F(Occur(LiverDamage))
Prescribe(DrugB) ◇→ F(Occur(Stroke))
```
Would-counterfactual: Drug B would normalize pressure without liver damage.
Might-counterfactual: Drug B might cause stroke (possible but not certain).

**Operator Combination**: Core (Boolean, Modal, Temporal) + Explanatory (Counterfactual)

### 3.4 Implementation Status

**Status**: Planned for future development
**Model-Checker**: Constitutive operators (`≤`, `⊑`, `≡`) implemented in v0.9.26
**Logos**: Not yet started
**Estimated Development**: Post Layer 0 completion

**Source**: LAYER_EXTENSIONS.md Section 1

## 4. Layer 2 (Epistemic Extension) - Planned

### 4.1 Operator Inventory

#### Belief Operator
- `B` (agent belief): "Agent a believes that A"
- **Notation**: `B_a(A)` where subscript identifies agent
- **Context Relativity**: Evaluation depends on agent's information state
- **Multi-Agent**: Supports distinct belief states per agent

**Example**: `B_Alice([sunny]) ∧ ¬B_Bob([sunny])` (different beliefs)

#### Probability Operator
- `Pr` (probability): Quantifies uncertainty
- **Notation**: `Pr(A) ≥ θ` where θ is probability threshold
- **Integration with Belief**: `B_a(A)` analyzable as `Pr_a(A) ≥ θ_belief`

**Example**: `Pr([rain tomorrow]) ≥ 0.7` (at least 70% probability)

#### Epistemic Modals
- `Mi` (epistemic might): "It might be that A" (compatible with knowledge)
- `Mu` (epistemic must): "It must be that A" (follows from knowledge)

**Contrast with Metaphysical Modals**:
- Metaphysical `□`: True in all possible worlds
- Epistemic `Mu`: True in all epistemically accessible worlds (given knowledge state)

**Example**: `Mu([murderer is guilty])` given evidence vs. `□([water is H2O])` metaphysical

#### Indicative Conditional
- `⟹` (indicative): Expresses expectations given belief state

**Contrast with Counterfactual**:
- Indicative: Evaluates under actual beliefs
- Counterfactual: Evaluates under hypothetical scenarios

**Example**:
- `raining ⟹ wet_ground` (indicative: given current information)
- `raining □→ wet_ground` (counterfactual: in closest worlds where raining)

### 4.2 Semantic Requirements

#### Information States

**Requirement**: Agent-relative information partitions:
```lean
-- Conceptual structure for Layer 2
structure EpistemicModel (T : Type) extends TaskModel T where
  agents : Type
  information : agents → WorldHistory frame → T → Set (WorldHistory frame)
  -- For agent a at history τ and time t, gives set of histories indistinguishable to a
```

**Epistemic Accessibility**: Agent cannot distinguish between worlds in their information set.

#### Belief Truth Condition
```lean
-- B_a(φ) true at (M, τ, t) iff:
-- For all τ' in (information a τ t), φ holds at (M, τ', t)
```

#### Probability Measures

**Requirement**: Probability distributions over epistemic possibilities:
```lean
-- Conceptual structure for Layer 2
structure ProbabilisticModel extends EpistemicModel where
  probability : agents → WorldHistory frame → T →
    (WorldHistory frame → Real)
  -- probability a τ t gives probability distribution over histories accessible to a
```

**Probability Truth Condition**:
```lean
-- Pr_a(φ) ≥ θ true at (M, τ, t) iff:
-- Sum of (probability a τ t τ') for all τ' where φ holds ≥ θ
```

### 4.3 Legal Evidence Analysis Example

**Scenario**: Prosecutors track suspect's beliefs across time.

**Time T₁** (six months before murder):
```
P(B_suspect([victim threatens job]))
```
Evidence shows suspect believed victim would report misconduct.

**Time T₂** (three months before):
```
P(F(B_suspect([financial ruin inevitable])))
```
Suspect believed financial ruin would follow job loss.

**Time T₃** (day of murder):
```
P(B_suspect([victim alone at home]))
```
Phone records show suspect knew victim's schedule.

**Proof-Checker Validation**:
```
[B_suspect(threat) ∧ B_suspect(opportunity)] → [Motive(murder)]
```

**Operator Combination**: Core (Boolean, Temporal) + Epistemic (Belief, Probability)

### 4.4 Implementation Status

**Status**: Future development
**Timeline**: Post Layer 1 completion
**Research Foundation**: Formal epistemology literature (established)

**Source**: LAYER_EXTENSIONS.md Section 2

## 5. Layer 3 (Normative Extension) - Planned

### 5.1 Operator Inventory

#### Deontic Operators
- `O` (obligation): "It is obligatory that A"
- `P` (permission): "It is permitted that A"

**Relationship**: `P(A) := ¬O(¬A)` (permitted iff not obligatory to refrain)

**Context Relativity**: Evaluation depends on normative context (legal system, moral framework, organizational policy)

**Examples**:
- Legal: `O([pay taxes])` (obligation to pay)
- Moral: `P([assist others])` (permitted to help)
- Organizational: `O([submit reports])` (obligation to report)

#### Preference Operator
- `≺` (preference): "A is preferred over B"
- **Notation**: `A ≺_a B` where subscript identifies agent

**Ordering Properties**:
- Partial order: Transitive, asymmetric
- Total order: All pairs comparable (optional)

**Multi-Agent**: Different agents may have different, conflicting preferences.

**Example**: `[outcome_X] ≺_Alice [outcome_Y]` (Alice prefers Y to X)

#### Normative Explanatory
- `⟼` (normative explanation): Connects normative facts to explanatory grounds

**Integration with Layer 1**: Combines normative operators with constitutive grounding.

**Example**: `[promise made] ⟼ O([promise kept])` (making promise grounds obligation)

### 5.2 Semantic Requirements

#### Ideality Ordering

**Requirement**: Ordering on worlds by normative ideality:
```lean
-- Conceptual structure for Layer 3
structure DeonticModel (T : Type) extends TaskModel T where
  normative_context : Type
  ideality : normative_context → WorldHistory frame → WorldHistory frame → Prop
  -- For context c, ideality c τ τ' means τ' is at least as ideal as τ
```

**Obligation Truth Condition**:
```lean
-- O(φ) true at (M, τ, t) relative to context c iff:
-- For all ideal worlds τ' according to c, φ holds at (M, τ', t)
```

#### Preference Relations

**Requirement**: Agent-specific preference orderings:
```lean
-- Conceptual structure for Layer 3
structure PreferenceModel extends DeonticModel where
  preference : agents → Formula → Formula → Prop
  -- preference a φ ψ means agent a prefers ψ to φ
  transitivity : ∀ a φ ψ χ, preference a φ ψ → preference a ψ χ → preference a φ χ
```

### 5.3 Multi-Party Negotiation Example

**Scenario**: Three organizations negotiate with different normative standards.

**Organization A** (startup - permissive):
```
P([option_IPsharing]) ∧ P([option_ExclusiveRights])
[QuickTimeline] ≺_A [StandardTimeline]
```
Few restrictions, strong preference for speed.

**Organization B** (university - restrictive):
```
O(¬[option_ExclusiveRights]) ∧ O([option_OpenPublication])
```
Many restrictions, weak preferences.

**Organization C** (government - mixed):
```
O([option_NationalSecurity]) ∧ P([option_IPsharing])
[PublicAccess] ≺_C [ControlledAccess] ≺_C [RestrictedAccess]
```
Moderate restrictions, ordered preferences.

**Collective Agreement**:
```
best_option ∈ (∩[permitted_A, permitted_B, permitted_C]) ∩ max(aggregate[≺_A, ≺_B, ≺_C])
```
Must be in intersection of permissions and maximize aggregated preferences.

**Operator Combination**: Core (Boolean, Modal) + Normative (Obligation, Permission, Preference)

### 5.4 Implementation Status

**Status**: Final extension layer
**Timeline**: Post Layer 2 completion
**Application Domains**: Traffic management, collaborative planning, ethical AI, multi-agent coordination

**Source**: LAYER_EXTENSIONS.md Section 3

## 6. Combination Principles

### 6.1 Valid Combinations

**Core Principle**: "Any combination of extensions can be added to the Core Layer"

**Possible Combinations**:
1. Core only
2. Core + Layer 1 (Explanatory)
3. Core + Layer 2 (Epistemic)
4. Core + Layer 3 (Normative)
5. Core + Layers 1,2 (Explanatory + Epistemic)
6. Core + Layers 1,3 (Explanatory + Normative)
7. Core + Layers 2,3 (Epistemic + Normative)
8. Core + Layers 1,2,3 (Complete Logos)

### 6.2 Domain-Specific Customization

**Medical Planning**: Core + Layer 1
- Boolean, Modal, Temporal (Core)
- Counterfactual (Layer 1)
- No epistemic or normative operators needed

**Legal Reasoning**: Core + Layer 2
- Boolean, Temporal (Core)
- Belief, Probability (Layer 2)
- No counterfactual or normative operators needed (unless analyzing obligations)

**Multi-Agent Coordination**: Core + All Layers
- All operator families for comprehensive coordination

### 6.3 Operator Interactions

**Epistemic + Temporal** (Layer 2 + Core):
```
B_a(Fp) → F(B_a(p) ∨ ¬B_a(p))
```
Belief about future implies future belief state.

**Normative + Counterfactual** (Layer 3 + Layer 1):
```
O(p) → (¬p □→ violation)
```
Obligation implies counterfactual violation if not satisfied.

**Belief + Preference** (Layer 2 + Layer 3):
```
B_a([x] ≺_b [y]) → negotiate_toward([y])
```
Believing another prefers y leads to negotiating toward y.

## 7. Theoretical Foundations

### 7.1 Task Semantics Framework

**Source**: ["The Construction of Possible Worlds"](https://www.benbrastmckie.com/wp-content/uploads/2025/11/possible_worlds.pdf) (Brast-McKie, 2025)

**Key Contributions**:
- Compositional semantics for possible worlds
- Task relation encoding possible transitions between states
- Non-deterministic dynamical systems foundation
- Complete implementation in Semantics/ package (Layer 0)

**Current Implementation**: Fully realized in Logos (TaskFrame, WorldHistory, TaskModel, Truth evaluation)

### 7.2 Hyperintensional Semantics

**Source**: ["Counterfactual Worlds"](https://link.springer.com/article/10.1007/s10992-025-09793-8) (Brast-McKie, 2025)

**Key Contributions**:
- State-based semantics for counterfactuals
- Truthmaker framework extension (Kit Fine's work)
- Defines possible worlds in terms of states, parthood, tasks, and times
- Task relation encodes transitions between states

**Implementation Status**: Foundation for planned Layer 1 (Explanatory extension)

**Critical Semantic Innovation**: World states as structured entities (verifier/falsifier pairs) rather than points, enabling fine-grained hyperintensional distinctions.

### 7.3 Kit Fine's Truthmaker Framework

**Sources**:
- Fine (2012a, 2012b): Truthmaker semantics foundations
- Fine (2017a, 2017b, 2017c): Hyperintensional logic developments

**Key Concepts**:
- States as parts of possible worlds
- Verifiers and falsifiers for propositions
- Grounding relations based on state structure
- Exact truth-makers (minimal states making propositions true)

**Influence on Logos**: Provides theoretical foundation for Layer 1 constitutive operators (`≤`, `⊑`, `≡`)

### 7.4 Hyperintensional Logic Research

**General Framework** (from web search):

**HYPE System**: Hyperintensional logic with:
- State-based evaluation
- Truth value gaps (partiality)
- Truth value gluts (overdeterminedness)
- Incompatibility relations on states
- Partial fusion operations

**Relevance**: Alternative approaches to hyperintensionality provide context for understanding Logos design choices.

**Sources**:
- [Hyperintensionality (Stanford Encyclopedia of Philosophy)](https://plato.stanford.edu/entries/hyperintensionality/)
- [HYPE: A System of Hyperintensional Logic](https://link.springer.com/article/10.1007/s10992-018-9467-0)

## 8. Semantic Architecture Implications

### 8.1 Type Parameterization Strategy

**Current Design**:
```lean
structure TaskFrame (T : Type) [LinearOrderedAddCommGroup T] where
  WorldState : Type                -- Abstract type parameter
```

**Benefit**: Enables different layer interpretations:
- Layer 0: `WorldState = Point` (atomic)
- Layer 1: `WorldState = MaximalState` (structured)

**Limitation**: WorldHistory and Truth evaluation assume point-like semantics in current implementation.

### 8.2 Extension Strategy Options

#### Option 1: Type Parameterization (Preferred)

**Approach**: Keep TaskFrame abstract, provide layer-specific instantiations:

```lean
-- Logos.Core.Semantics
structure TaskFrame (T : Type) (S : Type) [LinearOrderedAddCommGroup T] where
  WorldState := S
  task_rel : S → T → S → Prop
  ...

-- Logos.Core.Semantics.Instances
def CoreTaskFrame (T : Type) [LinearOrderedAddCommGroup T] :=
  TaskFrame T Point

-- Logos.Explanatory.Semantics.Instances
def ExplanatoryTaskFrame (T : Type) [LinearOrderedAddCommGroup T] :=
  TaskFrame T MaximalState
```

**Benefit**: Single unified framework with layer-specific instantiations.

**Challenge**: Truth evaluation may need layer-specific versions.

#### Option 2: Module Specialization

**Approach**: Separate TaskFrame definitions per layer:

```lean
-- Logos.Core.Semantics.TaskFrame
structure CoreTaskFrame (T : Type) [LinearOrderedAddCommGroup T] where
  WorldState : Type         -- Implicitly points
  ...

-- Logos.Explanatory.Semantics.TaskFrame
structure ExplanatoryTaskFrame (T : Type) [LinearOrderedAddCommGroup T]
  extends CoreTaskFrame T where
  verifiers : WorldState → Set StateComponent
  falsifiers : WorldState → Set StateComponent
  ...
```

**Benefit**: Layer-specific semantics explicit.

**Challenge**: Code duplication, harder to prove relationships between layers.

#### Option 3: Hybrid Approach (Recommended)

**Approach**: Abstract core, layer-specific extensions:

```lean
-- Logos.Core.Semantics.TaskFrame (unchanged)
structure TaskFrame (T : Type) [LinearOrderedAddCommGroup T] where
  WorldState : Type
  ...

-- Logos.Explanatory.Semantics.MaximalState
structure MaximalState where
  verifiers : Set Component
  falsifiers : Set Component
  ...

-- Logos.Explanatory.Semantics.TaskFrame
def ExplanatoryTaskFrame (T : Type) [LinearOrderedAddCommGroup T] :=
  TaskFrame T with WorldState := MaximalState
```

**Benefit**: Maintains abstraction while enabling specialization.

### 8.3 Formula Type Extension

**Current Design** (Layer 0):
```lean
inductive Formula : Type
  | atom : String → Formula
  | bot : Formula
  | imp : Formula → Formula → Formula
  | box : Formula → Formula
  | past : Formula → Formula
  | future : Formula → Formula
```

**Extension Pattern** (from ARCHITECTURE.md):
```lean
-- Logos.Explanatory.Syntax.Formula
inductive ExplanatoryFormula : Type
  | core : Logos.Core.Syntax.Formula → ExplanatoryFormula      -- Embed Layer 0
  | boxright : ExplanatoryFormula → ExplanatoryFormula → ExplanatoryFormula
  | ground : ExplanatoryFormula → ExplanatoryFormula → ExplanatoryFormula
  | cause : ExplanatoryFormula → ExplanatoryFormula → ExplanatoryFormula
```

**Strategy**: Each layer embeds previous layer's formula type as constructor.

**Benefit**: Type-safe layer separation with explicit embedding.

## 9. Implementation Roadmap Requirements

### 9.1 Layer 0 (Core) - Current State

**Status**: 95% complete (MVP done, tactics partial)

**Remaining Work**:
1. Complete tactics implementation (8/12 remaining)
2. Completeness proofs (infrastructure only)
3. Documentation refinement

**Refactoring Requirements**:
1. Rename namespace Logos → Logos.Core
2. No semantic changes needed
3. Maintain existing test suite

### 9.2 Layer 1 (Explanatory) - Future Work

**Prerequisites**:
1. Layer 0 complete and refactored
2. MaximalState type definition
3. Selection function framework
4. Grounding relation framework

**Core Components**:
1. ExplanatoryFormula (extends CoreFormula)
2. MaximalState structure
3. ExplanatoryTaskFrame (MaximalState-based)
4. Counterfactual axiom system
5. Constitutive axiom system
6. Soundness proofs for new axioms

**Estimated Timeline**: 3-6 months post Layer 0 completion

### 9.3 Layer 2 (Epistemic) - Future Work

**Prerequisites**:
1. Layer 1 complete (if using counterfactual-epistemic interactions)
2. Information state framework
3. Probability measure framework
4. Multi-agent framework

**Core Components**:
1. EpistemicFormula (extends CoreFormula or ExplanatoryFormula)
2. EpistemicModel (with information partitions)
3. ProbabilisticModel (with probability measures)
4. Epistemic axiom system
5. Probabilistic inference rules
6. Soundness proofs

**Estimated Timeline**: 3-6 months post Layer 1 completion (or parallel with Layer 1 if independent)

### 9.4 Layer 3 (Normative) - Future Work

**Prerequisites**:
1. Layers 1-2 complete (for full operator interactions)
2. Ideality ordering framework
3. Preference relation framework
4. Aggregation function framework

**Core Components**:
1. NormativeFormula (extends previous layers)
2. DeonticModel (with ideality ordering)
3. PreferenceModel (with preference relations)
4. Deontic axiom system
5. Preference logic
6. Soundness proofs

**Estimated Timeline**: 3-6 months post Layer 2 completion

## 10. Critical Refactoring Decisions

### 10.1 Namespace Structure

**Recommended Structure**:
```
Logos/                           # Root namespace
├── Core/                        # Layer 0 (current Logos)
│   ├── Syntax/
│   ├── ProofSystem/
│   ├── Semantics/
│   ├── Metalogic/
│   ├── Theorems/
│   └── Automation/
├── Explanatory/                 # Layer 1 (future)
│   ├── Syntax/
│   ├── ProofSystem/
│   ├── Semantics/
│   └── ...
├── Epistemic/                   # Layer 2 (future)
│   └── ...
├── Normative/                   # Layer 3 (future)
│   └── ...
└── Common/                      # Shared utilities (if needed)
    └── ...
```

### 10.2 Test Suite Organization

**Recommended Structure**:
```
LogosTest/                       # Root test namespace
├── Core/                        # Layer 0 tests
│   ├── Syntax/
│   ├── ProofSystem/
│   └── ...
├── Explanatory/                 # Layer 1 tests (future)
├── Epistemic/                   # Layer 2 tests (future)
├── Normative/                   # Layer 3 tests (future)
└── Integration/                 # Cross-layer integration tests
```

### 10.3 Archive Structure

**Recommended Structure**:
```
Archive/                         # Pedagogical examples
├── Core/                        # Layer 0 examples
│   ├── Modal/
│   ├── Temporal/
│   └── Bimodal/
├── Explanatory/                 # Layer 1 examples (future)
├── Epistemic/                   # Layer 2 examples (future)
└── Normative/                   # Layer 3 examples (future)
```

## 11. Documentation Requirements

### 11.1 Layer-Specific Documentation

**Core Layer** (existing documentation):
- ARCHITECTURE.md (already specifies Layer 0)
- METHODOLOGY.md (philosophical foundations)
- TUTORIAL.md (getting started)
- EXAMPLES.md (usage examples)

**Future Layers** (to be created):
- Logos.Explanatory.ARCHITECTURE.md
- Logos.Epistemic.ARCHITECTURE.md
- Logos.Normative.ARCHITECTURE.md

### 11.2 Integration Documentation

**Required Documents**:
- Logos.LAYER_INTEGRATION.md (how layers interact)
- Logos.OPERATOR_COMBINATIONS.md (valid domain-specific combinations)
- Logos.SEMANTIC_FOUNDATIONS.md (unified semantic framework)

## 12. Research Questions

### 12.1 Semantic Unification

**Question**: How do we formally relate point-based (Layer 0) and maximal-state-based (Layer 1) semantics?

**Approach**: Define embedding or translation between Core and Explanatory models.

**Open Issue**: Can perpetuity principles proven in Layer 0 lift to Layer 1?

### 12.2 Cross-Layer Theorems

**Question**: What theorems hold across all layers? What theorems are layer-specific?

**Examples**:
- Modal axioms (MT, M4, MB): Valid in all layers?
- Perpetuity principles (P1-P6): Valid in all layers?
- Layer 1 specific: Grounding transitivity, counterfactual centering
- Layer 2 specific: Epistemic necessitation, probability axioms
- Layer 3 specific: Deontic necessitation, preference transitivity

### 12.3 Operator Interdefinability

**Question**: How do operators relate across layers?

**Known Interdefinitions**:
- Layer 0: `◇φ := ¬□¬φ` (modal duality)
- Layer 1: `□A := ⊤ □→ A` (necessity via counterfactual)
- Layer 2: `P(A) := ¬O(¬A)` (permission via obligation)

**Open Questions**:
- Can Layer 0 modal operators be defined using Layer 1 counterfactuals?
- Can Layer 1 grounding be defined using Layer 0 + Layer 3 operators?

---

**Report Completion**: 2025-12-04
**Next Report**: 003-renaming-impact-analysis.md
**Sources**:
- README.md (Logos architecture overview)
- LAYER_EXTENSIONS.md (complete layer specifications)
- ARCHITECTURE.md (Layer 0 technical details)
- METHODOLOGY.md (philosophical foundations)
- [Counterfactual Worlds paper](https://link.springer.com/article/10.1007/s10992-025-09793-8)
- [Possible Worlds paper](https://www.benbrastmckie.com/wp-content/uploads/2025/11/possible_worlds.pdf)
- [Stanford Encyclopedia: Hyperintensionality](https://plato.stanford.edu/entries/hyperintensionality/)
- [HYPE System paper](https://link.springer.com/article/10.1007/s10992-018-9467-0)
