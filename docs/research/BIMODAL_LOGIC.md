# A Bimodal Logic for Tense and Modality

This document provides the authoritative presentation of Bimodal, a complete propositional intensional logic combining S5 modal and linear temporal operators. This implementation provides an excellent starting point for understanding modal-temporal reasoning.

## Overview

Bimodal logic (TM) is a propositional intensional logic implementing Tense and Modality with Kripke-style semantics and **fully verified soundness and completeness proofs**. This is a complete, production-ready implementation.

---

## The Bimodal Theory

### Classification

- **Type**: Propositional intensional logic
- **Order**: Zeroth-order (propositional)
- **Semantic Framework**: Kripke-style possible worlds semantics with temporal extension

### Semantic Primitives

In Bimodal, the fundamental semantic elements are **world-states**:

- **World States (`W`)**: Primitive elements representing possible states of affairs
- **Times (`T`)**: An arbitrary **ordered abelian group** `D` -- a linearly ordered
  `AddCommGroup` with `IsOrderedAddMonoid` -- not fixed to the integers. Dense carriers
  (`DenselyOrdered`) and Dedekind-complete carriers (every nonempty bounded-above set has a
  least upper bound) are explicitly supported; see
  `FormalSystem/Metalogic/StrongCompleteness.lean:165-171`. The four frame classes -- Base,
  Dense, Discrete, Dedekind -- differ exactly in which binders they impose on `D`.
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
| **Temporal (primitive)** | `untl` (until, U), `snce` (since, S) | The only primitive temporal constructors (`FormalSystem/Syntax/Formula.lean:96`, `:106`) |
| **Temporal (derived)** | H (always past), G (always future), P (sometime past), F (sometime future), X (next), K⁺/K⁻, triangle (always), nabla (sometimes) | All defined from `untl`/`snce` |

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

| Component | Status | Details |
|-----------|--------|---------|
| **Syntax** | Complete | Formula, Context, derived operators |
| **Proof System** | Complete | 45 axiom constructors (Base 37 / Dense 2 / Discrete 3 / Dedekind 3), 7 inference rules |
| **Semantics** | Complete | TaskFrame, TaskModel, Truth, Validity |
| **Metalogic** | **Complete** | Soundness, Completeness, Deduction theorem |
| **Automation** | Partial | Core tactics working |

**Key Result**: Bimodal has fully verified soundness proofs and weak completeness proofs for
all four frame classes. Note two qualifications: *strong* completeness (arbitrary infinite
premise sets) is not available uniformly -- it is machine-refuted for Discrete and open for
Base and Dense -- and the decision procedure's proved direction is soundness only. See
[known-limitations.md](../project-info/known-limitations.md).

**Implementation location**: [FormalSystem/README.md](../../FormalSystem/README.md)

---

## When to Use Bimodal

Bimodal is recommended for:

1. **Learning modal-temporal reasoning**: Complete implementation with tutorials and examples
2. **Standard modal reasoning**: Necessity, possibility, and their interactions
3. **Temporal logic**: Past, future, always, eventually operators
4. **Modal-temporal combinations**: Interactions between modality and time
5. **S4/S5 style theorems**: Accessibility relation properties
6. **Propositional proofs**: When zeroth-order logic suffices

---

## Theoretical Background

### Possible Worlds Semantics

Bimodal follows the Kripke tradition:

- Possible worlds as primitive
- Accessibility relations determine modal truth
- Two formulas are equivalent iff true at same worlds

**Reference**: See ["The Construction of Possible Worlds"](https://www.benbrastmckie.com/wp-content/uploads/2025/11/possible_worlds.pdf) (Brast-McKie, 2025) for the theoretical foundation.

### Additional References

- Brast-McKie, B. ["Counterfactual Worlds"](https://link.springer.com/article/10.1007/s10992-025-09793-8) (Journal of Philosophical Logic, 2025)
- Brast-McKie, B. ["Identity and Aboutness"](https://link.springer.com/article/10.1007/s10992-021-09612-w) (Journal of Philosophical Logic, 2021)

---

## The Logos Connection

Bimodal logic is a fragment of the **Logos**, a formal language of thought designed to enable AI systems to reason with mathematical certainty. The Logos provides verified synthetic reasoning data of arbitrary complexity through an extensible system of proof theory and semantics. This repository focuses specifically on the bimodal fragment, which is of independent interest due to its machine-verified weak completeness and its implemented (sound-direction-verified) decision procedure. For more about the Logos project, see [logos-labs.ai](https://logos-labs.ai/).

---

## Navigation

- [Bimodal Implementation](../../FormalSystem/README.md) - Full implementation details
- [Research Documentation](README.md) - Research index
- [Architecture Guide](../user-guide/architecture.md) - System architecture

---

_Last updated: March 2026_
