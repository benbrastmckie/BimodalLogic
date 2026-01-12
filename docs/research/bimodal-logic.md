# A Bimodal Logic for Tense and Modality

This document provides the authoritative presentation of Bimodal, a complete propositional intensional logic combining S5 modal and linear temporal operators. Developed in parallel with Logos, Bimodal provides an excellent starting point for understanding modal-temporal reasoning and demonstrates the boundaries of purely intensional semantics.

## Overview

The ProofChecker project contains two distinct logical theories developed in parallel:

1. **Logos** (primary): A second-order hyperintensional logic that extends beyond possible worlds semantics. This is the primary research direction with layered extensions for explanatory, epistemic, and normative reasoning.

2. **Bimodal** (comparison baseline): A propositional intensional logic implementing TM (Tense and Modality) with Kripke-style semantics. Bimodal serves as an excellent starting point for understanding modal-temporal reasoning and as a comparison baseline demonstrating the boundaries of purely intensional semantics.

---

## The Bimodal Theory

### Classification

- **Type**: Propositional intensional logic
- **Order**: Zeroth-order (propositional)
- **Semantic Framework**: Kripke-style possible worlds semantics with temporal extension

### Semantic Primitives

In Bimodal, the fundamental semantic elements are **world-states**:

- **World States (`W`)**: Primitive elements representing possible states of affairs
- **Times (`T`)**: Discrete temporal points (implemented as integers)
- **Task Relation (`R`)**: Accessibility relation over world-state/time pairs

### Interpretation

Sentence letters (atomic formulas) are interpreted as sets of world-states:

```
V : Atom -> Set WorldState
```

A sentence letter `p` is true at world `w` iff `w` is a member of `V(p)`.

### Operators

| Category        | Operators                                                                          | Meaning                     |
| --------------- | ---------------------------------------------------------------------------------- | --------------------------- |
| **Extensional** | not, and, or, implies, iff, bottom, top                                            | Boolean connectives         |
| **Modal**       | necessity (box), possibility (diamond)                                             | S5 historical modality      |
| **Temporal**    | H (always past), G (always future), P (sometime past), F (sometime future), triangle (always), nabla (sometimes) | Linear temporal operators   |

### Axiom Schemas

**S5 Modal Axioms**:

- **MT**: `box phi -> phi` (necessity implies actuality)
- **M4**: `box phi -> box box phi` (necessity iterates)
- **MB**: `phi -> box diamond phi` (actuality implies necessary possibility)

**Temporal Axioms**:

- **T4**: `G phi -> G G phi` (future is transitive)
- **TA**: `phi -> G P phi` (present becomes past)
- **TL**: `triangle phi -> G P phi` (perpetuity implies past occurrence)

**Bimodal Interaction**:

- **MF**: `box phi -> box G phi` (necessity persists forward)
- **TF**: `box phi -> G box phi` (necessity is temporally stable)

### Perpetuity Principles

Six theorems connecting modal and temporal operators:

- **P1**: `box phi -> triangle phi` (necessary truths are perpetual)
- **P2**: `nabla phi -> diamond phi` (occurrence implies possibility)
- **P3**: `box phi -> box triangle phi` (necessity of perpetuity)
- **P4**: `diamond nabla phi -> diamond phi` (possible occurrence implies possibility)
- **P5**: `diamond nabla phi -> triangle diamond phi` (persistent possibility)
- **P6**: `nabla box phi -> box triangle phi` (occurrent necessity is perpetual)

**For formal proofs**: See implementation in the Theorems module.

### Implementation Status

- **Syntax**: Complete (Formula, Context, derived operators)
- **Proof System**: Complete (14 axiom schemata, 7 inference rules)
- **Semantics**: Complete (TaskFrame, TaskModel, Truth, Validity)
- **Metalogic**: Partial (Soundness proven, Completeness infrastructure only)
- **Automation**: Partial (Core tactics working)

**Implementation location**: [Theories/Bimodal/README.md](../../Theories/Bimodal/README.md)

---

## Comparison with Logos

### Intensional vs Hyperintensional Semantics

The contrast between Bimodal's purely intensional semantics and Logos's hyperintensional foundation demonstrates the advantages of hyperintensional semantics for supporting a wider range of operators including explanatory, epistemic, and normative operators that require distinguishing necessarily equivalent propositions.

### Key Differences

| Aspect | Bimodal | Logos |
|--------|---------|-------|
| Semantic grain | World-states (coarse) | States (fine-grained) |
| Logical order | Propositional (0th) | Second-order |
| Interpretation | Sets of worlds | Variable assignments |
| Hyperintensionality | No | Yes |
| Quantification | None | First and second-order |

### Hyperintensional Advantages

Logos is designed to capture distinctions that possible worlds semantics cannot:

1. **Propositional Attitude Distinctions**: In intensional semantics, believing P and believing Q are equivalent whenever P and Q are necessarily equivalent. Hyperintensional semantics distinguishes these, capturing the intuition that one can believe "2+2=4" without believing "Fermat's Last Theorem is true" even though both are necessary truths.

2. **Explanatory Relations**: Grounding, essence, and constitution are hyperintensional---what grounds what cannot be captured by truth conditions alone. "Being crimson grounds being red" differs from arbitrary necessary connections.

3. **Fine-Grained Content**: Hyperintensional semantics distinguishes propositions that have the same truth conditions but differ in what they are *about*. This enables more expressive reasoning about content and aboutness.

4. **Layered Expressivity**: Logos's hyperintensional foundation supports a wider range of operators including explanatory, epistemic, and normative operators that require distinguishing necessarily equivalent propositions.

### When to Use Each

#### Start with Bimodal

Bimodal is recommended as a starting point for:

1. **Learning modal-temporal reasoning**: Complete implementation with tutorials and examples
2. **Standard modal reasoning**: Necessity, possibility, and their interactions
3. **Temporal logic**: Past, future, always, eventually operators
4. **Modal-temporal combinations**: Interactions between modality and time
5. **S4/S5 style theorems**: Accessibility relation properties
6. **Propositional proofs**: When zeroth-order logic suffices

#### Use Logos For

Logos is appropriate when you need:

1. **Propositional attitude reports**: Belief, knowledge, desire contexts
2. **Explanation and grounding**: Hyperintensional relations
3. **Second-order quantification**: Properties of properties
4. **Fine-grained content**: Distinguishing necessarily equivalent propositions
5. **Layered extensions**: Epistemic, normative, and explanatory operators

---

## Future: Repository Separation

Bimodal is planned for extraction into a separate repository in the future. This will allow:

- Independent versioning and releases
- Cleaner dependency management
- Focused documentation and examples
- Use as a standalone modal-temporal logic library

Until then, Bimodal continues to serve as both a complete implementation and a comparison baseline for Logos development.

---

## Theoretical Background

### Possible Worlds Semantics (Bimodal)

Bimodal follows the Kripke tradition:

- Possible worlds as primitive
- Accessibility relations determine modal truth
- Two formulas are equivalent iff true at same worlds

**Reference**: See "The Construction of Possible Worlds" (Brast-McKie, 2025) for the theoretical foundation.

### Hyperintensional Semantics (Logos)

Logos extends beyond possible worlds:

- States as more fine-grained than worlds
- Structured propositions preserve more content
- Two formulas can have same truth conditions but different content

**References**:
- Brast-McKie, B. "Counterfactual Worlds" (Journal of Philosophical Logic, 2025)
- Brast-McKie, B. "Identity and Aboutness" (Journal of Philosophical Logic, 2021)

---

## Navigation

- [Bimodal Implementation](../../Theories/Bimodal/README.md) - Full implementation details
- [Logos Theory](../../Theories/Logos/README.md) - Primary research direction
- [Research Documentation](README.md) - Research index
- [Architecture Guide](../user-guide/ARCHITECTURE.md) - System architecture

---

_Last updated: January 2026_
