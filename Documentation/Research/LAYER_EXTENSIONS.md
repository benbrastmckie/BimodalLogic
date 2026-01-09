# Logos Layer Extensions

## Overview

The Logos is organized into five semantic layers, each building upon the previous with increasing expressive power. Each layer corresponds to a **semantic frame** that defines the primitive structure needed to interpret logical formulas. The layers are:

1. **Constitutive Layer** - Hyperintensional semantics over mereological state spaces
2. **Causal Layer** - Intensional semantics over world-histories with temporal and modal operators
3. **Epistemic Layer** - Extensions for belief, knowledge, and probability
4. **Normative Layer** - Extensions for obligation, permission, and value
5. **Agential Layer** - Extensions for multi-agent reasoning

**Semantic Progression**: Each layer's frame includes all structure from previous layers. A formula combining operators from multiple layers (e.g., `B_a(F(O(p)))` - "agent a believes that it will be obligatory that p") is evaluated in the most complex frame needed.

See [RECURSIVE_SEMANTICS.md](RECURSIVE_SEMANTICS.md) for full formal semantic specifications, [METHODOLOGY.md](../UserGuide/METHODOLOGY.md) for philosophical methodology, and [GLOSSARY.md](../Reference/GLOSSARY.md) for term definitions.

---

## The Five-Layer Architecture

### Constitutive Layer (Foundation)

The Constitutive Layer provides the foundational mereological structure upon which all other layers build. Its semantics is **hyperintensional**, distinguishing propositions that agree on truth-value across all possible worlds but differ in their verification and falsification conditions.

#### Frame Structure

A *constitutive frame* is a complete lattice ⟨S, ⊑⟩ of states ordered by parthood, providing:
- **Null state** (□): Bottom element (fusion of the empty set)
- **Full state** (■): Top element (fusion of all states)
- **Fusion** (s.t): Least upper bound of states s and t
- **Compatibility** (s ∘ t): States are compatible iff their fusion is possible

#### Model Components

A constitutive model includes an interpretation function that assigns:
- **n-place function symbols** → functions from n states to a state (0-place = constants)
- **n-place predicates** → ordered pairs ⟨verifier function, falsifier function⟩
- **Sentence letters** → ordered pairs ⟨verifier state, falsifier state⟩
- **Variable assignment** → function mapping variables to states

#### Hyperintensional Semantics

The Constitutive Layer provides recursive verification and falsification clauses for:
- **Atomic formulas** F(a₁,...,aₙ)
- **Negation** (¬) - exchanges verification and falsification
- **Conjunction** (∧) - fusion of verifiers, sum of falsifiers
- **Disjunction** (∨) - sum of verifiers, fusion of falsifiers
- **Top** (⊤) and **Bottom** (⊥)
- **Propositional identity** (≡) - identical verifiers and falsifiers

#### Constitutive Operators

| Operator | Notation | Reading |
|----------|----------|---------|
| **Propositional Identity** | A ≡ B | "A just is B" |
| **Grounding** | A ≤ B | "A is sufficient for B" |
| **Essence** | A ⊑ B | "A is necessary for B" |
| **Relevance** | A ≼ B | "A is wholly relevant to B" |

**Note**: Logical consequence at this layer is restricted to propositional identity sentences. Evaluation of contingent atomic sentences requires the Causal Layer.

See [RECURSIVE_SEMANTICS.md](RECURSIVE_SEMANTICS.md) for full verification/falsification clauses.

---

### Causal Layer

The Causal Layer extends the Constitutive Layer with temporal structure and a task relation, enabling evaluation of truth relative to world-histories and times. Semantics at this layer is **intensional** rather than hyperintensional.

#### Frame Extensions

A *causal frame* extends a constitutive frame with:
- **Temporal order** D = ⟨D, +, ≤⟩ - a totally ordered abelian group of times
- **Task relation** ⇒ - constraining possible state transitions with nullity and compositionality

#### State Modality Concepts

| Concept | Definition |
|---------|------------|
| **Possible state** | Has null task from itself to itself |
| **Compatible states** | Fusion is possible |
| **Maximal state** | Contains all compatible states as parts |
| **World-state** | Maximal possible state |
| **World-history** | Function τ from convex time set to world-states respecting task relation |

#### Operators

**Modal Operators**:
| Operator | Notation | Reading |
|----------|----------|---------|
| **Necessity** | □A | "Necessarily A" |
| **Possibility** | ◇A | "Possibly A" |

**Core Tense Operators**:
| Operator | Notation | Reading |
|----------|----------|---------|
| **Always Past** | HA | "It has always been that A" |
| **Always Future** | GA | "It will always be that A" |
| **Past** | PA | "It was the case that A" |
| **Future** | FA | "It will be the case that A" |

**Extended Tense Operators**:
| Operator | Notation | Reading |
|----------|----------|---------|
| **Since** | A S B | "A since B" |
| **Until** | A U B | "A until B" |

**Counterfactual Conditional**:
| Operator | Notation | Reading |
|----------|----------|---------|
| **Would** | A □→ B | "If A were the case, B would be" |
| **Might** | A ◇→ B | "If A were the case, B might be" |

**Temporal Reference Operators**:
| Operator | Notation | Reading |
|----------|----------|---------|
| **Store** | ↑ⁱA | Store current time in register i |
| **Recall** | ↓ⁱA | Evaluate A at stored time i |

**Causal Operator**:
| Operator | Notation | Reading |
|----------|----------|---------|
| **Causation** | A ○→ B | "A causes B" |

#### Bimodal Interaction

The task semantics validates perpetuity principles connecting modal and temporal operators:
- □φ → △φ (Necessary implies always)
- ▽φ → ◇φ (Sometimes implies possible)
- □△φ ↔ △□φ (Commutativity)

#### Planning Applications

The Causal Layer enables AI systems to reason about:
- **Action sequences** via temporal operators
- **Hypothetical interventions** via counterfactuals
- **Causal relationships** via causation operator
- **Cross-temporal reference** via store/recall operators

##### Medical Treatment Planning Example

A physician treating hypertension can model treatment strategies:

**Strategy A (add Drug A)**:
```
Prescribe(DrugA) ∧ Taking(MedicationX) □→ F(Normalize(BloodPressure)) ∧ F(Occur(LiverDamage))
```
Drug A would normalize blood pressure but cause liver damage.

**Strategy B (add Drug B)**:
```
Prescribe(DrugB) ∧ Taking(MedicationX) □→ F(Normalize(BloodPressure)) ∧ ¬F(Occur(LiverDamage))
Prescribe(DrugB) ◇→ F(Occur(Stroke))
```
Drug B would normalize blood pressure, might cause stroke.

Counterfactual operators distinguish necessary (`□→`) from possible (`◇→`) consequences.

See [RECURSIVE_SEMANTICS.md](RECURSIVE_SEMANTICS.md) for full truth conditions.

---

### Epistemic Layer

The Epistemic Layer extends the Causal Layer with structures for reasoning under uncertainty.

[DETAILS]

#### Frame Extension

The epistemic frame extends the causal frame with a credence function assigning probabilities to state transitions.

[QUESTION: What is the exact structure of the credence function? Does it assign probabilities to individual state transitions or to sets of transitions?]

#### Operators

| Operator | Notation | Reading |
|----------|----------|---------|
| **Belief** | B_a(A) | "Agent a believes A" |
| **Knowledge** | K_a(A) | "Agent a knows A" |
| **Probability** | Pr(A) ≥ θ | "Probability of A at least θ" |
| **Epistemic Possibility** | Mi(A) | "It might be that A" |
| **Epistemic Necessity** | Mu(A) | "It must be that A" |
| **Indicative Conditional** | A ⟹ B | "If A then B" (epistemic) |

#### Uncertainty Reasoning Applications

##### Legal Evidence Analysis Example

Prosecutors can model how evidence reveals suspect's beliefs across time:

**Time T₁** (six months before):
```
P(B_suspect([victim threatens job]))
```
Evidence shows suspect believed victim would report misconduct.

**Time T₃** (day of murder):
```
P(B_suspect([victim alone at home]))
```
Phone records show suspect knew victim's schedule.

The system integrates belief operators with temporal operators to establish motive through verified inference chains.

[DETAILS: Full semantic clauses for epistemic operators pending specification]

---

### Normative Layer

The Normative Layer extends the Epistemic Layer with structures for ethical and cooperative reasoning.

[DETAILS]

#### Frame Extension

The normative frame extends the epistemic frame with value orderings over states.

[QUESTION: How are value orderings structured? Are they complete orderings or partial orderings? Are they agent-relative?]

#### Operators

| Operator | Notation | Reading |
|----------|----------|---------|
| **Obligation** | O(A) | "It is obligatory that A" |
| **Permission** | P(A) | "It is permitted that A" |
| **Preference** | A ≺_a B | "Agent a prefers B to A" |
| **Normative Explanation** | A ↦ O(B) | "A grounds obligation B" |

#### Multi-Agent Coordination Applications

##### Multi-Party Negotiation Example

Three organizations negotiate a joint research agreement:

**Organization A (startup)**: Permissive standards, strong preference for speed
```
P([option_IPsharing])
[QuickTimeline] ≺_A [StandardTimeline]
```

**Organization B (university)**: Restrictive standards requiring open publication
```
O(¬[option_ExclusiveRights])
O([option_OpenPublication])
```

**Organization C (government)**: Mixed standards focusing on security
```
O([option_NationalSecurity])
[PublicAccess] ≺_C [ControlledAccess]
```

Finding optimal collective agreement requires intersection of permitted options and aggregated preferences.

[DETAILS: Full semantic clauses for normative operators pending specification]

---

### Agential Layer

The Agential Layer extends the Normative Layer for multi-agent reasoning scenarios.

[DETAILS]

[QUESTION: What frame extensions are required for multi-agent reasoning? Does this layer add agent indices, or agent-relative accessibility relations?]

[QUESTION: How do individual and collective agency interact in the semantic framework?]

---

## Layer Interaction and Composition

When operators from multiple layers combine, evaluation uses the most complex frame required:

**Epistemic + Temporal** (Epistemic + Causal):
```
B_a(Fp) → F(B_a(p) ∨ ¬B_a(p))
```
If agent believes p will be true, then in future either agent believes p or doesn't.

**Normative + Counterfactual** (Normative + Causal):
```
O(p) → (¬p □→ violation)
```
If p is obligatory, then if p were not the case, there would be a violation.

**Belief + Preference** (Epistemic + Normative):
```
B_a([x] ≺_b [y]) → negotiate_toward([y])
```
If agent A believes agent B prefers y, then A negotiates toward y.

---

## Implementation Status

| Layer | Semantic Specification | Implementation Status |
|-------|----------------------|----------------------|
| **Constitutive** | Complete | Partial (proof-checker) |
| **Causal** | Complete | Partial (model-checker) |
| **Epistemic** | [DETAILS] | Not started |
| **Normative** | [DETAILS] | Not started |
| **Agential** | [DETAILS] | Not started |

See [IMPLEMENTATION_STATUS.md](../ProjectInfo/IMPLEMENTATION_STATUS.md) for current progress.

---

## Related Documentation

- [RECURSIVE_SEMANTICS.md](RECURSIVE_SEMANTICS.md) - Full formal semantic specifications
- [METHODOLOGY.md](../UserGuide/METHODOLOGY.md) - Philosophical foundations
- [ARCHITECTURE.md](../UserGuide/ARCHITECTURE.md) - Technical specification
- [GLOSSARY.md](../Reference/GLOSSARY.md) - Term definitions
- [CONCEPTUAL_ENGINEERING.md](CONCEPTUAL_ENGINEERING.md) - Philosophical motivation
- [IMPLEMENTATION_STATUS.md](../ProjectInfo/IMPLEMENTATION_STATUS.md) - Current state

---

_Last updated: January 2026_
