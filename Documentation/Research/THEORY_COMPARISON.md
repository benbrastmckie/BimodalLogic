# Theory Comparison: Bimodal vs Logos

This document compares the two logical systems implemented in the ProofChecker project,
highlighting their theoretical foundations, semantic structures, and intended applications.

## Overview

The ProofChecker project contains two distinct logical theories:

1. **Bimodal**: A propositional intensional logic implementing TM (Tense and Modality) with
   Kripke-style semantics. This is the actively developed implementation.

2. **Logos**: A second-order hyperintensional logic (planned) that will extend beyond possible
   worlds semantics. Currently serves as a re-export layer for Bimodal.

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

### Implementation Status

Currently `/Logos/` serves as a **re-export layer** for Bimodal:
- Re-exports Bimodal modules under `Logos` namespace
- Contains stubs for planned extensions (Epistemic, Normative, Explanatory)
- Full implementation is future work

## When to Use Each

### Use Bimodal For

1. **Standard modal reasoning**: Necessity, possibility, and their interactions
2. **Temporal logic**: Past, future, always, eventually operators
3. **Modal-temporal combinations**: Interactions between modality and time
4. **S4/S5 style theorems**: Accessibility relation properties
5. **Propositional proofs**: When zeroth-order logic suffices

### Use Logos For (Future)

1. **Propositional attitude reports**: Belief, knowledge, desire contexts
2. **Explanation and grounding**: Hyperintensional relations
3. **Second-order quantification**: Properties of properties
4. **Fine-grained content**: Distinguishing necessarily equivalent propositions

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
- [Architecture](../UserGuide/ARCHITECTURE.md) - System architecture
