# DTT Foundation Standard for the Logos Appendix

**Created**: 2026-02-27
**Purpose**: Establish consistent treatment of DTT as foundational while using set notation for convenience

---

## Overview

The Logos Appendix follows the **Lean/Mathlib documentation style**: present mathematics using familiar set-theoretic notation while acknowledging that all concepts have precise type-theoretic interpretations in the underlying dependent type theory.

This standard codifies how to balance type-theoretic rigor with accessibility throughout the appendix chapters.

---

## Foundational Position

### Core Principle

**Dependent Type Theory is foundational; set notation is presentational.**

As established in Chapter 1, Section 6 ("Sets and Relations in Type Theory"), set-theoretic concepts are definable within type theory:
- Predicates are functions $P : A \to \text{Prop}$
- Subsets are subtypes $\{x : A \mid P(x)\} := \Sigma_{x:A} P(x)$
- Relations are functions $R : A \to B \to \text{Prop}$
- Universal quantification corresponds to Pi types
- Existential quantification corresponds to Sigma types

This means the entire appendix can be understood type-theoretically, with set notation serving as convenient shorthand.

### Convention Statement

Each chapter should reference the following convention, stated explicitly in the preface (Chapter 0):

> The mathematical content of this appendix is presented using standard notation familiar from set theory. As established in Chapter 1, these concepts have precise type-theoretic interpretations. We follow the Lean/Mathlib documentation style: definitions specify types explicitly, while proofs and informal discussion use conventional notation.

---

## Four-Layer Approach

### Layer 1: Preface Declaration

The preface (Chapter 0) contains a single explicit statement about the DTT foundation. This is not repeated in every chapter; instead, each chapter may include a brief reminder in its introduction.

### Layer 2: Type Annotations in Definitions

Formal definitions should include type annotations for the carrier and operations.

**Pattern**:
```typst
#definition("Preorder")[
  A *preorder* on a type $A$ is a relation $\leq : A \to A \to \text{Prop}$ satisfying:
  1. *Reflexivity*: $a \leq a$ for all $a : A$
  2. *Transitivity*: if $a \leq b$ and $b \leq c$, then $a \leq c$
]
```

**Key elements**:
- "on a type $A$" instead of "on a set $A$"
- Operations shown as function types: $\leq : A \to A \to \text{Prop}$
- Quantified variables use typing notation: "for all $a : A$"

### Layer 3: Strategic DTT Highlights

Include DTT remarks at strategic points where they aid understanding:

1. **Definition introductions**: When a concept has interesting type-theoretic character
2. **Lean connections**: When connecting to Mathlib implementations
3. **Dependent types**: When types genuinely depend on values
4. **Constructive considerations**: When classical vs constructive matters

**Pattern**:
```typst
#remark[
  In Lean 4, `Preorder` and `PartialOrder` are type classes. The ordering
  is denoted `LE.le` (for $\leq$) and `LT.lt` (for $<$).
]
```

### Layer 4: Lean Code References

Include explicit Lean source references where they illuminate the mathematical content.

**Pattern**:
```typst
#remark[
  In Lean 4, `Monotone f` is defined in `Mathlib.Order.Monotone.Basic`.
  Many lemmas help prove functions are monotone compositionally.
]
```

---

## Translation Table

| Set-Theoretic | Type-Theoretic | Usage |
|---------------|----------------|-------|
| Set $A$ | Type $A$ | Use "type" in definitions |
| $x \in A$ | $x : A$ | Use $x : A$ in formal definitions |
| Subset $S \subseteq A$ | Subtype $\{x : A \mid P(x)\}$ | "subset" informally, "subtype" precisely |
| Function $f : A \to B$ | Function type $A \to B$ | Same notation |
| $\forall x \in A. P(x)$ | $\Pi_{x:A} P(x)$ | Use "$\forall x : A$" (hybrid) |
| $\exists x \in A. P(x)$ | $\Sigma_{x:A} P(x)$ | Use "$\exists x : A$" (hybrid) |
| Family $(A_i)_{i \in I}$ | Dependent type $B : I \to \mathcal{U}$ | Note dependent type character |
| Relation $R \subseteq A \times B$ | $R : A \to B \to \text{Prop}$ | Use function notation in definitions |
| Empty set $\emptyset$ | Empty type $\bot$ | Set notation acceptable |
| Singleton $\{*\}$ | Unit type $\mathbb{1}$ | Set notation acceptable |

---

## Examples of Properly Written Definitions

### Order-Theoretic Definition

```typst
#definition("Partial Order")[
  A *partial order* on a type $A$ is a preorder $\leq : A \to A \to \text{Prop}$ that also satisfies:
  3. *Antisymmetry*: if $a \leq b$ and $b \leq a$, then $a = b$

  A type equipped with a partial order is called a *partially ordered type* or *poset*.
]
```

### Algebraic Definition

```typst
#definition("Monoid")[
  A *monoid* $(M, \cdot, e)$ consists of:
  - A type $M$
  - A binary operation $\cdot : M \to M \to M$
  - An identity element $e : M$

  satisfying associativity and identity laws.
]

#remark[
  In Lean 4, monoids are defined via the type class `Monoid`. The operation
  is denoted multiplicatively (`*`) or additively (`+`).
]
```

### Topological Definition

```typst
#definition("Topology")[
  A *topology* on a type $X$ is a collection $\tau$ of predicates $U : X \to \text{Prop}$
  (called *open sets*) satisfying the standard axioms.
]

#remark[
  Open sets can be viewed as predicates: $U : X \to \text{Prop}$ assigns to each
  point a proposition "this point is in $U$". The extension $\{x : X \mid U(x)\}$
  is the corresponding subtype.
]
```

---

## What NOT to Do

### Avoid Over-Verbosity

Do NOT add DTT remarks to every definition. The goal is strategic placement, not exhaustive annotation.

**Too verbose**:
```typst
#definition("Upper Bound")[
  An element $u : A$ is an *upper bound* of a subset $S$...
]
#remark[
  In type theory, "an element $u : A$" means $u$ is a term of type $A$,
  and "a subset $S$" means a predicate $S : A \to \text{Prop}$. The
  definition can be expressed as $\forall s : A, S(s) \to s \leq u$.
]
```

**Appropriate**:
```typst
#definition("Upper Bound")[
  An element $u : A$ is an *upper bound* of $S \subseteq A$ if $s \leq u$
  for all $s \in S$.
]
```

The type-theoretic interpretation is clear from the preface convention; no per-definition remark is needed for standard material.

### Avoid Pure Type-Theoretic Notation in Proofs

Keep proofs in standard mathematical style. The DTT annotations belong in definitions and strategic remarks, not throughout every proof step.

---

## Chapter-Specific Guidelines

### Chapter 2: Order Theory

- Use "type $A$" in definition headers
- Add DTT remark connecting directed sets to Scott topology (anticipating Chapter 4)
- Lean references: `Preorder`, `PartialOrder`, `Monotone`

### Chapter 3: Algebra

- Operations as functions: $\cdot : G \to G \to G$
- Note algebraic structures as types with operations
- Lean references: `Monoid`, `Group`, `AddCommGroup`

### Chapter 4: Topology

- Note open sets as predicates where helpful
- Scott topology section naturally connects to dcpos (type-theoretic domain theory)
- Lean references: `TopologicalSpace`, `IsOpen`

### Chapter 5: Lattices

- Meet/join as functions: $\land, \lor : L \to L \to L$
- Complete lattices connect to type-theoretic suprema
- Lean references: `Lattice`, `CompleteLattice`

### Chapter 6: Bilattices

- Minimal changes; already connects to Logos semantics
- Verify existing Lean references

### Chapter 7: Category Theory

- Hom-sets as types; composition as function
- Categories can be viewed type-theoretically
- Lean references: Mathlib category definitions

### Chapter 8: Enriched Categories

- Already type-theoretically sophisticated
- Minimal changes; verify enriched perspective

### Chapter 9: Metric Spaces

- Connect Lawvere metrics to enriched category perspective
- State-valued metrics connect to DTT naturally
- Lean references where appropriate

---

## Quality Checklist for Migration

When reviewing a chapter for DTT consistency:

- [ ] Introduction acknowledges DTT context (brief)
- [ ] Key definitions use "type $A$" rather than "set $A$"
- [ ] Operations shown with function types where appropriate
- [ ] At least one Lean reference remark per major section
- [ ] DTT remarks placed strategically, not exhaustively
- [ ] Set notation preserved for proofs and informal discussion
- [ ] No broken cross-references to Chapter 1

---

## Related Standards

- **textbook-standards.md**: General textbook quality standards (definition ordering, motivation, professional tone)
- **typst-style-guide.md**: Prose conventions (em-dashes, one-sentence-per-line) in Prose Conventions section
- **Chapter 1**: Foundational definitions of type-theoretic interpretations
