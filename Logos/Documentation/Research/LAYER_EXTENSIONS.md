# Logos Extensions

## Overview

Logos is organized into semantic extensions, each building upon the previous with increasing expressive power. Each extension corresponds to a **semantic frame** that defines the primitive structure needed to interpret logical formulas. The extensions are:

1. **Constitutive Foundation** - Hyperintensional semantics over mereological state spaces
2. **Explanatory Extension** - Intensional semantics over world-histories with temporal and modal operators
3. **Epistemic Extension** - Extensions for belief, knowledge, and probability
4. **Normative Extension** - Extensions for obligation, permission, and value
5. **Spatial Extension** - Extensions for spatial reasoning and location
6. **Agential Extension** - Extensions for multi-agent reasoning (requires at least one middle extension)

**Semantic Progression**: Each extension's frame includes all structure from previous extensions. A formula combining operators from multiple extensions (e.g., `B_a(F(O(p)))` - "agent a believes that it will be obligatory that p") is evaluated in the most complex frame needed.

See [RECURSIVE_SEMANTICS.md](RECURSIVE_SEMANTICS.md) for full formal semantic specifications, [METHODOLOGY.md](../UserGuide/METHODOLOGY.md) for philosophical methodology, and [GLOSSARY.md](../Reference/GLOSSARY.md) for term definitions.

---

## Extension Architecture

### Constitutive Foundation

The Constitutive Foundation provides the foundational mereological structure upon which all other extensions build. Its semantics is **hyperintensional**, distinguishing propositions that agree on truth-value across all possible worlds but differ in their verification and falsification conditions. This foundation is non-modal: possibility and compatibility cannot be defined at this level since they require the task relation introduced in the Explanatory Extension.

#### Syntactic Primitives

The Constitutive Foundation interprets these syntactic primitives:
- Variables, individual constants, n-place function symbols, n-place predicates
- Sentence letters (0-place predicates)
- Lambda abstraction: λx.A (binding variable x in formula A)
- Logical connectives: ¬, ∧, ∨, ⊤, ⊥, ≡

#### Frame Structure

A *constitutive frame* is a complete lattice ⟨S, ⊑⟩ of states ordered by parthood, providing:
- **Null state** (□): Bottom element (fusion of the empty set)
- **Full state** (■): Top element (fusion of all states)
- **Fusion** (s.t): Least upper bound of states s and t

#### Model Components

A constitutive model includes an interpretation function that assigns:
- **n-place function symbols** → functions from n states to a state (0-place = constants)
- **n-place predicates** → ordered pairs ⟨verifier function, falsifier function⟩
- **Sentence letters** → ordered pairs ⟨verifier state, falsifier state⟩
- **Variable assignment** → function mapping variables to states

#### Hyperintensional Semantics

The Constitutive Foundation provides recursive verification and falsification clauses for:
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

Logical consequence at this foundation is restricted to propositional identity sentences. Evaluation of contingent atomic sentences requires the Explanatory Extension.

See [RECURSIVE_SEMANTICS.md](RECURSIVE_SEMANTICS.md) for full verification/falsification clauses.

---

### Explanatory Extension

The Explanatory Extension extends the Constitutive Foundation with temporal structure and a task relation, enabling evaluation of truth relative to world-histories and times. Semantics at this extension is **intensional** rather than hyperintensional.

#### Syntactic Primitives

The Explanatory Extension interprets these additional syntactic primitives:
- Modal operators: □ (necessity), ◇ (possibility)
- Temporal operators: H (always past), G (always future), P (some past), F (some future)
- Extended temporal operators: ◁ (since), ▷ (until)
- Counterfactual conditional: □→ (would-counterfactual)
- Store/recall operators: ↑ⁱ (store), ↓ⁱ (recall)

#### Frame Extensions

A *core frame* extends a constitutive frame with:
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

The Explanatory Extension enables AI systems to reason about:
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

### Epistemic Extension

The Epistemic Extension extends the Explanatory Extension with structures for reasoning under uncertainty.

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

### Normative Extension

The Normative Extension extends the Epistemic Extension with structures for ethical and cooperative reasoning.

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

### Agential Extension

The Agential Extension extends the Normative Extension for multi-agent reasoning scenarios.

[DETAILS]

[QUESTION: What frame extensions are required for multi-agent reasoning? Does this extension add agent indices, or agent-relative accessibility relations?]

[QUESTION: How do individual and collective agency interact in the semantic framework?]

---

## Extension Interaction and Composition

When operators from multiple extensions combine, evaluation uses the most complex frame required:

**Epistemic + Temporal** (Epistemic + Core):
```
B_a(Fp) → F(B_a(p) ∨ ¬B_a(p))
```
If agent believes p will be true, then in future either agent believes p or doesn't.

**Normative + Counterfactual** (Normative + Core):
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

| Extension | Semantic Specification | Implementation Status |
|-----------|----------------------|----------------------|
| **Constitutive Foundation** | Complete | Partial (proof-checker) |
| **Explanatory Extension** | Complete | Partial (model-checker) |
| **Epistemic Extension** | [DETAILS] | Not started |
| **Normative Extension** | [DETAILS] | Not started |
| **Spatial Extension** | [DETAILS] | Not started |
| **Agential Extension** | [DETAILS] | Not started |

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
