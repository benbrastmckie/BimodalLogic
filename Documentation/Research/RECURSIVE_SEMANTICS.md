# Recursive Semantics for the Logos Layered Logic System

**Related Documents**:
- [LAYER_EXTENSIONS.md](LAYER_EXTENSIONS.md) - Layer architecture overview
- [METHODOLOGY.md](../UserGuide/METHODOLOGY.md) - Philosophical methodology
- [GLOSSARY.md](../Reference/GLOSSARY.md) - Term definitions

---

## Introduction

This document provides the formal recursive semantics for the Logos layered logic system. The semantics proceeds through increasingly expressive layers, each extending the frame and evaluation mechanisms of the previous layer:

1. **Constitutive Layer**: Hyperintensional semantics over a mereological state space
2. **Causal Layer**: Hyperintensional and intensional semantics over a task space
3. **Epistemic Layer**: Extensions for belief, knowledge, and probability [DETAILS]
4. **Normative Layer**: Extensions for obligation, permission, and value [DETAILS]
5. **Agential Layer**: Extensions for multi-agent reasoning [DETAILS]

The Constitutive Layer provides the foundational mereological structure with bilateral propositions (verifier/falsifier pairs). The Causal Layer extends this foundation with temporal structure (a totally ordered abelian group) and a task relation constraining possible state transitions, enabling evaluation of truth relative to world-histories and times.

---

## Constitutive Layer: Hyperintensional Semantics

FIX: specify what syntactic primitives will be interpreted in this layer including lambda abstraction, updating the GLOSSARY.md accordingly

The Constitutive Layer provides the foundational semantic structure based on exact truthmaker semantics. Evaluation is hyperintensional, distinguishing propositions that agree on truth-value across all possible worlds but differ in their exact verification and falsification conditions.

### Constitutive Frame

A *constitutive frame* is a structure **F** = ⟨S, ⊑⟩ where:

| Component | Description |
|-----------|-------------|
| **State Space** | A nonempty set S of states |
| **Parthood** | A partial order ⊑ on S making ⟨S, ⊑⟩ a complete lattice |

The lattice structure provides:
- **Null state** (□): The bottom element (fusion of the empty set)
- **Full state** (■): The top element (fusion of all states)
- **Fusion** (s.t): The least upper bound of s and t
- **Compatibility** (s ∘ t): States s and t are compatible iff their fusion s.t is possible

### Constitutive Model

A *constitutive model* is a structure **M** = ⟨S, ⊑, I⟩ where: FIX: use '| |' for the interpretation function consistently rather than 'I'

| Component | Description |
|-----------|-------------|
| **Frame** | ⟨S, ⊑⟩ is a constitutive frame |
| **Interpretation** | I assigns meanings to non-logical vocabulary |

The interpretation function I assigns: FIX: use '| |' instead of 'I'
- **n-place function symbols** f → functions from Sⁿ to S (0-place = individual constants mapping to states)
- **n-place predicates** F → ordered pairs ⟨v_F, f_F⟩ where: FIX: replace v_F and f_F with |F|⁺ and |F|⁻ where these are both sets of functions of the kind indicated for v_F and f_F below
  - v_F : Sⁿ → S is the verifier function
  - f_F : Sⁿ → S is the falsifier function
- **Sentence letters** (0-place predicates) p → ordered pairs ⟨|p|⁺, |p|⁻⟩ of verifier and falsifier states

### Variable Assignment

FIX: greek letters are used for world-histories; use 'a', 'b',... for variable assignments (preferable with a bar above them 'a', 'b',... will also work as they are if no unicode characters are available for 'a', 'b',... with a bar over them)

A *variable assignment* σ is a function from variables to states: σ : Var → S

The **extension** of a term relative to model M and assignment σ:
- **Variable** x: ⟦x⟧^σ_M = σ(x)
- **Function application** f(a₁,...,aₙ): ⟦f(a₁,...,aₙ)⟧^σ_M = I(f)(⟦a₁⟧^σ_M, ..., ⟦aₙ⟧^σ_M) FIX: use '|f|' instead of 'I(f)'

### Verification and Falsification Clauses

FIX: instead of '⊩⁻', it would be better to have '⊩' reversed if there is such a symbol, and then use '⊩' for verification by itself. If there is no reversed turnstile, then keep the verification and falsification symbols as they are.

A state s **verifies** (s ⊩⁺ A) or **falsifies** (s ⊩⁻ A) a formula A relative to model M and assignment σ:

#### Atomic Formulas

FIX: it is important to include the model M and variable assignment a alongside the state where f is some verifying/falsifying function as follows:
  M, a, s ⊩⁺ F(a₁,...,aₙ) iff there is some f in |F|⁺ where s = f(⟦a₁⟧^σ_M, ..., ⟦aₙ⟧^σ_M)
  M, a, s ⊩⁻ F(a₁,...,aₙ) iff there is some f in |F|⁺ where s = f(⟦a₁⟧^σ_M, ..., ⟦aₙ⟧^σ_M)

| | Condition |
|---|-----------|
| s ⊩⁺ F(a₁,...,aₙ) | iff s = v_F(⟦a₁⟧^σ_M, ..., ⟦aₙ⟧^σ_M) |
| s ⊩⁻ F(a₁,...,aₙ) | iff s = f_F(⟦a₁⟧^σ_M, ..., ⟦aₙ⟧^σ_M) |

FIX: include semantic clauses for lambda abstraction

#### Negation (¬)

FIX: include the model M and variable assignment a in all of the semantic clauses below.

| | Condition |
|---|-----------|
| s ⊩⁺ ¬A | iff s ⊩⁻ A |
| s ⊩⁻ ¬A | iff s ⊩⁺ A |

#### Conjunction (∧)

| | Condition |
|---|-----------|
| s ⊩⁺ A ∧ B | iff s = t.u for some t, u where t ⊩⁺ A and u ⊩⁺ B |
| s ⊩⁻ A ∧ B | iff s ⊩⁻ A, or s ⊩⁻ B, or s = t.u for some t, u where t ⊩⁻ A and u ⊩⁻ B |

#### Disjunction (∨)

| | Condition |
|---|-----------|
| s ⊩⁺ A ∨ B | iff s ⊩⁺ A, or s ⊩⁺ B, or s = t.u for some t, u where t ⊩⁺ A and u ⊩⁺ B |
| s ⊩⁻ A ∨ B | iff s = t.u for some t, u where t ⊩⁻ A and u ⊩⁻ B |

#### Top (⊤) and Bottom (⊥)

| | Verification | Falsification |
|---|-------------|---------------|
| ⊤ | s ⊩⁺ ⊤ for all s ∈ S | s ⊩⁻ ⊤ iff s = ■ (full state) |
| ⊥ | Never: s ⊮⁺ ⊥ for all s | s ⊩⁻ ⊥ iff s = □ (null state) |

#### Propositional Identity (≡)

| | Condition |
|---|-----------|
| s ⊩⁺ A ≡ B | iff s = □ and {t : t ⊩⁺ A} = {t : t ⊩⁺ B} and {t : t ⊩⁻ A} = {t : t ⊩⁻ B} |
| s ⊩⁻ A ≡ B | iff s = □ and ({t : t ⊩⁺ A} ≠ {t : t ⊩⁺ B} or {t : t ⊩⁻ A} ≠ {t : t ⊩⁻ B}) |

### Bilateral Propositions

A *bilateral proposition* is an ordered pair ⟨V, F⟩ where:
- V and F are subsets of S closed under fusion
- ⟨V, F⟩ is **exclusive**: states in V are incompatible with states in F
- ⟨V, F⟩ is **exhaustive**: every possible state is compatible with some state in V or F

**Propositional Operations**:

| Operation | Definition |
|-----------|------------|
| **Product** | X ⊗ Y := {s.t : s ∈ X, t ∈ Y} |
| **Sum** | X ⊕ Y := X ∪ Y ∪ (X ⊗ Y) |
| **Conjunction** | ⟨V,F⟩ ∧ ⟨V',F'⟩ := ⟨V ⊗ V', F ⊕ F'⟩ |
| **Disjunction** | ⟨V,F⟩ ∨ ⟨V',F'⟩ := ⟨V ⊕ V', F ⊗ F'⟩ |
| **Negation** | ¬⟨V,F⟩ := ⟨F, V⟩ |

### Logical Consequence (Constitutive)

Logical consequence at the Constitutive Layer is restricted to propositional identity sentences:

> Γ ⊨ A iff for any model M and assignment σ: if M, σ, □ ⊩⁺ B for all B ∈ Γ, then M, σ, □ ⊩⁺ A

That is, A is a consequence of Γ iff the null state verifies A in any model where it verifies all premises.

[QUESTION: How exactly does evaluation transition from constitutive to causal semantics for non-identity sentences? The constitutive semantics cannot evaluate atomic sentences about contingent matters since world-states are not yet defined.] ANSWER: evaluation is entirely distinct for the two layers. The Constitutive Layer is an important foundation and worth defining a logic for propositional identity, but this is not yet a useful layer in and of itself. Nevertheless, the same theorems of the logic for the Constitutive Layer will still be valid in the Causal Layer, though the definition of logical consequence for the Causal Layer is distinct, quantifying over all world-histories and times in addition to all models and variable assignments.

---

## Causal Layer: Intensional Semantics

FIX: the semantics is intensional insofar as it determines truth-values relative to the contextual parameters (this includes a world-history, time, variable assignment) but this is not instead of being hyperintensional since the hyperintensional semantics is still the foundation. Rather, the intensional layer sits on top of the hyperintensional foundation in order to assign truth-values to sentences given an adequate range of contextual parameters needed to determine the truth-values of all sentences of the Causal Layer.

The Causal Layer extends the Constitutive Layer with temporal structure and a task relation, enabling evaluation of truth relative to world-histories and times. Semantics at this layer is intensional rather than hyperintensional.

### Causal Frame

A *causal frame* is a structure **F** = ⟨S, ⊑, D, ⇒⟩ where:

| Component | Description |
|-----------|-------------|
| **State Space** | ⟨S, ⊑⟩ is a constitutive frame |
| **Temporal Order** | D = ⟨D, +, ≤⟩ is a totally ordered abelian group |
| **Task Relation** | ⇒ is a ternary relation on S × D × S satisfying constraints below |

The task relation s ⇒_d t (read: "there is a task from s to t of duration d") satisfies:

FIX: the Nullity constraint should be removed and instead we will have the definition of the possible states as any state s where s ⇒_0 s

| Constraint | Formulation |
|------------|-------------|
| **Nullity** | s ⇒_0 s for all possible states s |
| **Compositionality** | If s ⇒_x t and t ⇒_y u, then s ⇒_{x+y} u |
| **Parthood (Left)** | If d ⊑ s and s ⇒_x t, then d ⇒_x r for some r ⊑ t |
| **Parthood (Right)** | If r ⊑ t and s ⇒_x t, then d ⇒_x r for some d ⊑ s |

FIX: add the containment constraints from section sub:Containment in /home/benjamin/Projects/Philosophy/Papers/Counterfactuals/JPL/counterfactual_worlds.tex to the constraints above. Also add the Maximality constraint from sub:TaskSpace in the same paper.

### State Modality Definitions

FIX: 'Connected' is no longer needed since the possibility of a state s is defined directly as s ⇒_0 s. Fix 'Possible state' accordingly.

| Term | Definition |
|------|------------|
| **Connected** | s ~ t iff s ⇒_d t or t ⇒_d s for some d |
| **Possible state** | s ∈ P iff s ~ t for some t (equivalently: s ⇒_0 s) |
| **Impossible state** | s ∉ P iff s is not connected to any state |
| **Compatible states** | s ∘ t iff s.t ∈ P |
| **Maximal state** | s is maximal iff for every t ∘ s, we have t ⊑ s |
| **World-state** | w ∈ W iff w is a maximal possible state |
| **Necessary state** | s ∈ N iff s ~ t implies s = t |

### World-History

A *world-history* over a causal frame F is a function τ : X → W where:
- X ⊆ D is a convex subset of the temporal order
- τ(x) ⇒_{y-x} τ(y) for all times x, y ∈ X where x ≤ y

The set of all world-histories over F is denoted H_F.

**Note**: World-histories assign world-states to times in a way that respects the task relation. The constraint ensures that consecutive world-states are connected by appropriate tasks.

### Causal Model

A *causal model* is a structure **M** = ⟨S, ⊑, D, ⇒, I⟩ where:
- ⟨S, ⊑, D, ⇒⟩ is a causal frame
- I is an interpretation as in the Constitutive Layer

### Truth Conditions

Truth is evaluated relative to a model M, world-history τ, time x ∈ dom(τ), and assignment σ:

#### Atomic Sentences

| | Condition |
|---|-----------|
| M, τ, x ⊨ F(a₁,...,aₙ) | iff there exists s ⊑ τ(x) where s ⊩⁺ F(a₁,...,aₙ) |
| M, τ, x ⊭ F(a₁,...,aₙ) | iff there exists s ⊑ τ(x) where s ⊩⁻ F(a₁,...,aₙ) |

#### Extensional Connectives

| Operator | Truth Condition |
|----------|-----------------|
| **¬A** | M, τ, x ⊨ ¬A iff M, τ, x ⊭ A |
| **A ∧ B** | M, τ, x ⊨ A ∧ B iff M, τ, x ⊨ A and M, τ, x ⊨ B |
| **A ∨ B** | M, τ, x ⊨ A ∨ B iff M, τ, x ⊨ A or M, τ, x ⊨ B |
| **A → B** | M, τ, x ⊨ A → B iff M, τ, x ⊭ A or M, τ, x ⊨ B |

#### Modal Operators

| Operator | Truth Condition | Reading |
|----------|-----------------|---------|
| **□A** | M, τ, x ⊨ □A iff M, σ, x ⊨ A for all σ ∈ H_F | "Necessarily A" |
| **◇A** | M, τ, x ⊨ ◇A iff M, σ, x ⊨ A for some σ ∈ H_F | "Possibly A" |

**Equivalence**: ◇A ≡ ¬□¬A

**Note**: Metaphysical necessity can also be defined via counterfactuals: □A := ⊤ □→ A. This yields an S5 modal logic.

#### Core Tense Operators

| Operator | Truth Condition | Reading |
|----------|-----------------|---------|
| **HA** | M, τ, x ⊨ HA iff M, τ, y ⊨ A for all y ∈ D where y < x | "It has always been that A" |
| **GA** | M, τ, x ⊨ GA iff M, τ, y ⊨ A for all y ∈ D where y > x | "It will always be that A" |
| **PA** | M, τ, x ⊨ PA iff M, τ, y ⊨ A for some y ∈ D where y < x | "It was the case that A" |
| **FA** | M, τ, x ⊨ FA iff M, τ, y ⊨ A for some y ∈ D where y > x | "It will be the case that A" |

**Equivalences**:
- PA ≡ ¬H¬A
- FA ≡ ¬G¬A

**Derived Operators**:
- **△A** := HA ∧ A ∧ GA ("Always A" - at all times)
- **▽A** := PA ∨ A ∨ FA ("Sometimes A" - at some time)

#### Extended Tense Operators: Since and Until

| Operator | Truth Condition |
|----------|-----------------|
| **A S B** (Since) | M, τ, x ⊨ A S B iff there exists z < x where M, τ, z ⊨ B and M, τ, y ⊨ A for all y where z < y < x |
| **A U B** (Until) | M, τ, x ⊨ A U B iff there exists z > x where M, τ, z ⊨ B and M, τ, y ⊨ A for all y where x < y < z |

**Reading**:
- "A since B" means B was true at some past time, and A has been true ever since
- "A until B" means B will be true at some future time, and A is true until then

#### Counterfactual Conditional (□→)

**Mereological formulation**:

> M, τ, x ⊨ φ □→ C iff for all t ∈ |φ|⁺ and β ∈ H_F: if s.t ⊑ β(x) for some maximal t-compatible part s ∈ τ(x)_t, then M, β, x ⊨ C

Where:
- |φ|⁺ is the set of exact verifiers for φ
- τ(x)_t is the set of maximal t-compatible parts of τ(x)
- s ∈ τ(x)_t is maximal iff s ⊑ τ(x), s ∘ t, and for all s' where s ⊑ s' ⊑ τ(x) and s' ∘ t, we have s' ⊑ s

**Intuitive reading**: A counterfactual "if φ were the case, then C" is true at world τ and time x iff the consequent C is true in any world β at x where β(x) is the result of minimally changing τ(x) to make the antecedent φ true.

**Imposition notation**: We write t ▷_w w' ("imposing t on w yields w'") iff there exists maximal t-compatible part s ∈ w_t where s.t ⊑ w'.

#### Store and Recall Operators (↑, ↓)

For cross-temporal reference within counterfactual evaluation, the context is extended with a vector v⃗ = ⟨v₁, v₂, ...⟩ of stored times:

| Operator | Truth Condition | Effect |
|----------|-----------------|--------|
| **↑ⁱA** | M, τ, x, v⃗ ⊨ ↑ⁱA iff M, τ, x, v⃗[x/vᵢ] ⊨ A | Store: replaces vᵢ with current time x |
| **↓ⁱA** | M, τ, x, v⃗ ⊨ ↓ⁱA iff M, τ, vᵢ, v⃗ ⊨ A | Recall: shifts evaluation to stored time vᵢ |

**Example** (tensed counterfactuals):
- ↓¹(B □→ FH) - "If B had occurred at the stored time, then H would have occurred at some future time"
- ↑²↓¹(B □→ ↓²H) - "Store now, recall past time, if B then H at the stored present"

### Bimodal Interaction Principles

The task semantics validates these perpetuity principles connecting modal and temporal operators:

| Principle | Formula | Reading |
|-----------|---------|---------|
| **P1** | □φ → △φ | Necessary implies always |
| **P2** | ▽φ → ◇φ | Sometimes implies possible |
| **P3** | □△φ ↔ △□φ | Necessary-always commutativity |
| **P4** | ◇▽φ ↔ ▽◇φ | Possible-sometimes commutativity |
| **P5** | □φ → □△φ | Necessary implies necessary-always |
| **P6** | ▽◇φ → ◇φ | Sometimes-possible implies possible |

### Temporal Frame Constraints

Different temporal structures yield different valid principles. The framework does not assume discrete time:

| Constraint | Description | Corresponding Axiom |
|------------|-------------|---------------------|
| **Dense** | Between any two times there is another | GGφ → Gφ |
| **Complete** | Every bounded set has a least upper bound | △(Hφ → FHφ) → (Hφ → Gφ) |
| **Unbounded Past** | No earliest time | P⊤ |
| **Unbounded Future** | No latest time | F⊤ |

### Logical Consequence (Causal)

> Γ ⊨ A iff for any model M, world-history τ ∈ H_F, time x ∈ dom(τ), and assignment σ: if M, τ, x ⊨ B for all B ∈ Γ, then M, τ, x ⊨ A

### Counterfactual Logic Axiom Schemata

**Core Rules**:

| Axiom | Schema | Name |
|-------|--------|------|
| **R1** | If Γ ⊢ C, then φ □→ Γ ⊢ φ □→ C | Closure under deduction |
| **C1** | φ □→ φ | Identity |
| **C2** | φ, φ □→ A ⊢ A | Counterfactual Modus Ponens |
| **C3** | φ □→ ψ, φ ∧ ψ □→ A ⊢ φ □→ A | Weakened Transitivity |
| **C4** | φ ∨ ψ □→ A ⊢ φ ∧ ψ □→ A | Disjunction-Conjunction |
| **C5** | φ ∨ ψ □→ A ⊢ φ □→ A | Simplification (Left) |
| **C6** | φ ∨ ψ □→ A ⊢ ψ □→ A | Simplification (Right) |
| **C7** | φ □→ A, ψ □→ A, φ ∧ ψ □→ A ⊢ φ ∨ ψ □→ A | Disjunction Introduction |

**Modal Axioms**:

| Axiom | Schema |
|-------|--------|
| **M1** | ⊤ |
| **M2** | ¬⊥ |
| **M3** | A → □◇A |
| **M4** | □A → □□A |
| **M5** | □(φ → A) ⊢ φ □→ A |

---

## Epistemic Layer

[DETAILS]

The Epistemic Layer extends the Causal Layer with structures for belief, knowledge, and probability.

### Frame Extension

[DETAILS]

The epistemic frame extends the causal frame with a credence function assigning probabilities to state transitions.

[QUESTION: What is the exact structure of the credence function? Does it assign probabilities to individual state transitions or to sets of transitions?]

### Operators

| Operator | Intended Reading |
|----------|------------------|
| **B_a φ** | Agent a believes that φ |
| **K_a φ** | Agent a knows that φ |
| **Pr(φ) ≥ r** | The probability of φ is at least r |

[DETAILS: Full semantic clauses for epistemic operators pending specification]

### Indicative Conditionals

[DETAILS]

[QUESTION: How do indicative conditionals relate to counterfactual conditionals in the semantic framework?]

---

## Normative Layer

[DETAILS]

The Normative Layer extends the Epistemic Layer with structures for obligation, permission, and value.

### Frame Extension

[DETAILS]

The normative frame extends the epistemic frame with value orderings over states.

[QUESTION: How are value orderings structured? Are they complete orderings or partial orderings? Are they agent-relative?]

### Operators

| Operator | Intended Reading |
|----------|------------------|
| **O φ** | It ought to be that φ |
| **P φ** | It is permitted that φ |
| **φ ≻ ψ** | φ is preferred to ψ |

[DETAILS: Full semantic clauses for normative operators pending specification]

### Normative Explanation

[DETAILS]

[QUESTION: How does normative explanation relate to causal explanation?]

---

## Agential Layer

[DETAILS]

The Agential Layer extends the Normative Layer for multi-agent reasoning.

### Frame Extension

[DETAILS]

[QUESTION: What frame extensions are required for multi-agent reasoning? Does this layer add agent indices, or agent-relative accessibility relations?]

### Multi-Agent Operators

[DETAILS]

[QUESTION: How do individual and collective agency interact in the semantic framework?]

---

## References

### Academic Sources
- Fine, K. (2017). "Truthmaker Semantics" - Foundation for hyperintensional propositions
- Brast-McKie, B. "Possible Worlds" (JPL) - Task semantics, bimodal logic
- Brast-McKie, B. "Counterfactual Worlds" (JPL) - Counterfactual conditional semantics

### Related Documentation
- [LAYER_EXTENSIONS.md](LAYER_EXTENSIONS.md) - Layer architecture overview
- [GLOSSARY.md](../Reference/GLOSSARY.md) - Term definitions
- [METHODOLOGY.md](../UserGuide/METHODOLOGY.md) - Philosophical methodology
