# Theory Comparison: Bimodal vs Logos

This document compares the two logical systems developed in parallel within the ProofChecker project, highlighting their theoretical foundations, semantic structures, and intended applications.

## Overview

The ProofChecker project contains two distinct logical theories developed in parallel:

1. **Logos** (primary): A second-order hyperintensional logic that extends beyond possible worlds semantics. This is the primary research direction with layered extensions for explanatory, epistemic, and normative reasoning.

2. **Bimodal** (comparison baseline): A propositional intensional logic implementing TM (Tense and Modality) with Kripke-style semantics. Bimodal serves as an excellent starting point for understanding modal-temporal reasoning and as a comparison baseline demonstrating the boundaries of purely intensional semantics.

## Bimodal Theory

### Classification

- **Type**: Propositional intensional logic
- **Order**: Zeroth-order (propositional)
- **Semantic Framework**: Kripke-style possible worlds semantics with temporal extension

### Semantic Primitives

In Bimodal, the fundamental semantic elements are **world-states**:

- **World States (`W`)**: Primitive elements representing possible states of affairs
- **Times (`T`)**: Discrete temporal points (implemented as integers `ℤ`)
- **Task Relation (`R`)**: Accessibility relation over world-state/time pairs

### Interpretation

Sentence letters (atomic formulas) are interpreted as sets of world-states:

```
V : Atom → Set WorldState
```

A sentence letter `p` is true at world `w` iff `w ∈ V(p)`.

### Operators

| Operator | Symbol | Meaning |
|----------|--------|---------|
| Necessity | `□` | True at all accessible worlds |
| Possibility | `◇` | True at some accessible world |
| Future | `△` | True at all future times |
| Past | `▽` | True at all past times |
| Eventually | `◊△` | True at some future time |
| Previously | `◊▽` | True at some past time |

### Implementation Status

- **Syntax**: Complete (Formula, Context, derived operators)
- **Proof System**: Complete (14 axiom schemata, 7 inference rules)
- **Semantics**: Complete (TaskFrame, TaskModel, Truth, Validity)
- **Metalogic**: Partial (Soundness proven, Completeness infrastructure only)
- **Automation**: Partial (Core tactics working)

### Location

Primary implementation in `/Bimodal/`:
- Syntax: `Bimodal/Syntax/`
- Proof System: `Bimodal/ProofSystem/`
- Semantics: `Bimodal/Semantics/`
- Metalogic: `Bimodal/Metalogic/`

## Logos Theory (Planned)

### Classification

- **Type**: Second-order hyperintensional logic
- **Order**: Second-order (quantification over properties and relations)
- **Semantic Framework**: State-based hyperintensional semantics

### Semantic Primitives

In Logos, the fundamental semantic elements are **states** (more fine-grained than worlds):

- **States**: Primitive elements that are more fine-grained than possible worlds
- **State Space**: Structure organizing states with composition operations

### Interpretation

Unlike Bimodal's set-theoretic interpretation, Logos interprets:

- **Functions**: Via state-dependent mappings
- **Constants**: As state-indexed values
- **Predicates**: Through variable assignments over first and second-order domains

### Key Differences from Bimodal

| Aspect | Bimodal | Logos |
|--------|---------|-------|
| Semantic grain | World-states (coarse) | States (fine-grained) |
| Logical order | Propositional (0th) | Second-order |
| Interpretation | Sets of worlds | Variable assignments |
| Hyperintensionality | No | Yes |
| Quantification | None | First and second-order |

### Hyperintensional Distinctions

Logos is designed to capture distinctions that possible worlds semantics cannot:

- **Propositional Attitudes**: "Believes that P" vs "Believes that Q" even when P and Q
  are necessarily equivalent
- **Explanatory Relations**: "P explains Q" is hyperintensional
- **Content**: Distinguishing propositions with same truth conditions

### Hyperintensional Advantages

The contrast between Bimodal's intensional semantics and Logos's hyperintensional foundation demonstrates several key advantages of hyperintensional approaches:

1. **Propositional Attitude Distinctions**: In intensional semantics, believing P and believing Q are equivalent whenever P and Q are necessarily equivalent. Hyperintensional semantics distinguishes these, capturing the intuition that one can believe "2+2=4" without believing "Fermat's Last Theorem is true" even though both are necessary truths.

2. **Explanatory Relations**: Grounding, essence, and constitution are hyperintensional---what grounds what cannot be captured by truth conditions alone. "Being crimson grounds being red" differs from arbitrary necessary connections.

3. **Fine-Grained Content**: Hyperintensional semantics distinguishes propositions that have the same truth conditions but differ in what they are *about*. This enables more expressive reasoning about content and aboutness.

4. **Layered Expressivity**: Logos's hyperintensional foundation supports a wider range of operators including explanatory, epistemic, and normative operators that require distinguishing necessarily equivalent propositions.

### Implementation Status

Currently `/Logos/` serves as a **re-export layer** for Bimodal:
- Re-exports Bimodal modules under `Logos` namespace
- Contains stubs for planned extensions (Epistemic, Normative, Explanatory)
- Full implementation is future work

## When to Use Each

### Start with Bimodal

Bimodal is recommended as a starting point for:

1. **Learning modal-temporal reasoning**: Complete implementation with tutorials and examples
2. **Standard modal reasoning**: Necessity, possibility, and their interactions
3. **Temporal logic**: Past, future, always, eventually operators
4. **Modal-temporal combinations**: Interactions between modality and time
5. **S4/S5 style theorems**: Accessibility relation properties
6. **Propositional proofs**: When zeroth-order logic suffices

### Use Logos For

Logos is appropriate when you need:

1. **Propositional attitude reports**: Belief, knowledge, desire contexts
2. **Explanation and grounding**: Hyperintensional relations
3. **Second-order quantification**: Properties of properties
4. **Fine-grained content**: Distinguishing necessarily equivalent propositions
5. **Layered extensions**: Epistemic, normative, and explanatory operators

## Theoretical Background

### Possible Worlds Semantics (Bimodal)

Bimodal follows the Kripke tradition:

- Possible worlds as primitive
- Accessibility relations determine modal truth
- Two formulas are equivalent iff true at same worlds

**Reference**: See "The Construction of Possible Worlds" for the theoretical foundation.

### Hyperintensional Semantics (Logos)

Logos will extend beyond possible worlds:

- States as more fine-grained than worlds
- Structured propositions preserve more content
- Two formulas can have same truth conditions but different content

**References**:
- Brast-McKie, B. "The Logic of Hyperintensional Belief"
  (Journal of Philosophical Logic, DOI: 10.1007/s10992-025-09793-8)
- Brast-McKie, B. "Identity and Aboutness"
  (Journal of Philosophical Logic, DOI: 10.1007/s10992-021-09612-w)

## Navigation

- [Bimodal README](../../Bimodal/README.md) - Bimodal implementation details
- [Logos README](../../Logos/README.md) - Logos (re-export layer) details
- [Project Documentation](../README.md) - Documentation hub
- [Architecture](../user-guide/ARCHITECTURE.md) - System architecture
