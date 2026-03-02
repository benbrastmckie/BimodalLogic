# Category Theory Basics

> **Scope**: Foundational category theory serving as prerequisite for enriched categories and profunctors. Covers categories, functors, natural transformations, and universal properties.
> **Current as of**: 2026-02-24

## Purpose

This context file provides fundamental category theory definitions and concepts. It serves as the foundational layer for the enriched category theory covered in `enriched-categories.md` and `monoidal-categories.md`.

### When to Load

Load this context when:
- Working on categorical reasoning tasks
- Understanding functor and natural transformation patterns
- Learning prerequisites for enriched category theory
- Working with universal properties and limits

---

## Quick Reference

### Core Vocabulary

| Term | Definition | Example |
|------|------------|---------|
| Category | Objects + morphisms + composition + identities | **Set** (sets and functions) |
| Functor | Structure-preserving map between categories | $\text{List} : \textbf{Set} \to \textbf{Set}$ |
| Natural transformation | Map between functors respecting naturality | $\text{head} : \text{List} \Rightarrow \text{Maybe}$ |
| Universal property | Characterization by a mapping-out/mapping-in property | Initial/terminal objects |

### Standard Categories

| Category | Objects | Morphisms | Composition |
|----------|---------|-----------|-------------|
| **Set** | Sets | Functions | Function composition |
| **Grp** | Groups | Group homomorphisms | Function composition |
| **Ring** | Rings | Ring homomorphisms | Function composition |
| **Top** | Topological spaces | Continuous maps | Function composition |
| **Vect**$_k$ | $k$-vector spaces | Linear maps | Function composition |
| **Poset** | Posets | Monotone functions | Function composition |
| **Cat** | Small categories | Functors | Functor composition |

---

## Definition: Category

A **category** $\mathcal{C}$ consists of:

1. **Objects**: A collection $\text{Ob}(\mathcal{C})$ of objects
2. **Morphisms**: For each pair of objects $A, B$, a set $\text{Hom}_\mathcal{C}(A, B)$ of morphisms (or arrows) from $A$ to $B$
3. **Composition**: For each triple $A, B, C$, a function
   $$\circ : \text{Hom}(B, C) \times \text{Hom}(A, B) \to \text{Hom}(A, C)$$
4. **Identity**: For each object $A$, an identity morphism $\text{id}_A : A \to A$

### Axioms

**Associativity**: For composable morphisms $f : A \to B$, $g : B \to C$, $h : C \to D$:
$$(h \circ g) \circ f = h \circ (g \circ f)$$

**Unit laws**: For any morphism $f : A \to B$:
$$f \circ \text{id}_A = f = \text{id}_B \circ f$$

### Notation

| Notation | Meaning |
|----------|---------|
| $f : A \to B$ | Morphism $f$ from $A$ to $B$ |
| $\text{Hom}(A, B)$ or $\mathcal{C}(A, B)$ | Set of morphisms from $A$ to $B$ |
| $g \circ f$ | Composition (read "g after f") |
| $\text{id}_A$ or $1_A$ | Identity morphism on $A$ |

### Opposite Category

For any category $\mathcal{C}$, the **opposite category** $\mathcal{C}^{\text{op}}$ has:
- Same objects as $\mathcal{C}$
- Morphisms reversed: $\text{Hom}_{\mathcal{C}^{\text{op}}}(A, B) = \text{Hom}_\mathcal{C}(B, A)$
- Composition reversed

---

## Definition: Functor

A **functor** $F : \mathcal{C} \to \mathcal{D}$ between categories consists of:

1. **Object mapping**: A function $F : \text{Ob}(\mathcal{C}) \to \text{Ob}(\mathcal{D})$
2. **Morphism mapping**: For each pair $A, B \in \mathcal{C}$, a function
   $$F : \text{Hom}_\mathcal{C}(A, B) \to \text{Hom}_\mathcal{D}(FA, FB)$$

### Axioms

**Preservation of composition**:
$$F(g \circ f) = F(g) \circ F(f)$$

**Preservation of identity**:
$$F(\text{id}_A) = \text{id}_{FA}$$

### Types of Functors

| Type | Definition | Example |
|------|------------|---------|
| Covariant | Standard definition (preserves direction) | Forgetful functors |
| Contravariant | $F : \mathcal{C}^{\text{op}} \to \mathcal{D}$ (reverses arrows) | $\text{Hom}(-, X)$ |
| Endofunctor | $F : \mathcal{C} \to \mathcal{C}$ (same domain/codomain) | List, Maybe |
| Faithful | Injective on hom-sets | Forgetful $U : \textbf{Grp} \to \textbf{Set}$ |
| Full | Surjective on hom-sets | Inclusion of subcategory |
| Fully faithful | Bijective on hom-sets | Embedding |

### Examples

**Forgetful functor** $U : \textbf{Grp} \to \textbf{Set}$:
- Maps each group to its underlying set
- Maps each homomorphism to its underlying function

**Free functor** $F : \textbf{Set} \to \textbf{Grp}$:
- Maps each set $X$ to the free group on $X$
- Left adjoint to the forgetful functor

**Power set functor** $\mathcal{P} : \textbf{Set} \to \textbf{Set}$:
- Maps each set to its power set
- Maps $f : X \to Y$ to direct image $f_* : \mathcal{P}(X) \to \mathcal{P}(Y)$

---

## Definition: Natural Transformation

A **natural transformation** $\alpha : F \Rightarrow G$ between functors $F, G : \mathcal{C} \to \mathcal{D}$ consists of:

For each object $A \in \mathcal{C}$, a morphism $\alpha_A : FA \to GA$ in $\mathcal{D}$

### Naturality Condition

For every morphism $f : A \to B$ in $\mathcal{C}$, the following diagram commutes:

```
       alpha_A
  FA ---------> GA
   |             |
Ff |             | Gf
   v             v
  FB ---------> GB
       alpha_B
```

That is: $G(f) \circ \alpha_A = \alpha_B \circ F(f)$

### Terminology

| Term | Definition |
|------|------------|
| Component | $\alpha_A$ is the component of $\alpha$ at $A$ |
| Natural isomorphism | All components are isomorphisms |
| Identity transformation | $\text{id}_F : F \Rightarrow F$ with components $\text{id}_{FA}$ |

### Examples

**Identity on lists**: The natural transformation $\text{id} : \text{List} \Rightarrow \text{List}$ with $\text{id}_A = \text{id}_{\text{List}(A)}$.

**Head of list**: The natural transformation $\text{head} : \text{List} \Rightarrow \text{Maybe}$ extracts the first element (if any).

**Currying isomorphism**: For fixed $A$, there is a natural isomorphism
$$\text{Hom}(A \times -, B) \cong \text{Hom}(-, B^A)$$

---

## Universal Properties

Universal properties characterize objects uniquely (up to unique isomorphism) by their relationship to all other objects.

### Initial and Terminal Objects

**Initial object**: An object $0$ such that for every object $A$, there is exactly one morphism $0 \to A$.
- In **Set**: The empty set $\emptyset$
- In **Grp**: The trivial group $\{e\}$

**Terminal object**: An object $1$ such that for every object $A$, there is exactly one morphism $A \to 1$.
- In **Set**: Any singleton set $\{*\}$
- In **Grp**: The trivial group $\{e\}$

### Products

A **product** of objects $A$ and $B$ is an object $A \times B$ with projections $\pi_1 : A \times B \to A$ and $\pi_2 : A \times B \to B$ satisfying:

For any object $C$ and morphisms $f : C \to A$, $g : C \to B$, there exists a unique morphism $\langle f, g \rangle : C \to A \times B$ making both triangles commute.

```
           C
          /|\
         / | \
      f /  |  \ g
       /   |   \
      v    v    v
     A <-- AxB --> B
        pi1   pi2
```

### Coproducts

A **coproduct** of objects $A$ and $B$ is an object $A + B$ with injections $\iota_1 : A \to A + B$ and $\iota_2 : B \to A + B$ satisfying the dual universal property.

- In **Set**: Disjoint union
- In **Grp**: Free product
- In **Vect**: Direct sum

### Pullbacks and Pushouts

**Pullback** (fibered product): Given $f : A \to C$ and $g : B \to C$, the pullback $A \times_C B$ is the limit of this diagram.

**Pushout** (fibered coproduct): Dual construction.

---

## The Hom Functor

For a category $\mathcal{C}$ and object $A$, there are two important functors:

**Covariant hom-functor** $\text{Hom}(A, -) : \mathcal{C} \to \textbf{Set}$:
- Maps $B$ to $\text{Hom}(A, B)$
- Maps $f : B \to C$ to postcomposition: $f_* : \text{Hom}(A, B) \to \text{Hom}(A, C)$

**Contravariant hom-functor** $\text{Hom}(-, B) : \mathcal{C}^{\text{op}} \to \textbf{Set}$:
- Maps $A$ to $\text{Hom}(A, B)$
- Maps $f : A \to A'$ to precomposition: $f^* : \text{Hom}(A', B) \to \text{Hom}(A, B)$

### Yoneda Lemma

For any functor $F : \mathcal{C} \to \textbf{Set}$ and object $A$:
$$\text{Nat}(\text{Hom}(A, -), F) \cong F(A)$$

Natural transformations from the representable functor $\text{Hom}(A, -)$ to $F$ correspond bijectively to elements of $F(A)$.

**Corollary** (Yoneda embedding): The functor $\mathcal{C} \to [\mathcal{C}^{\text{op}}, \textbf{Set}]$ given by $A \mapsto \text{Hom}(-, A)$ is fully faithful.

---

## Mathlib Support

Mathlib provides extensive category theory support:

### Key Imports

```lean
import Mathlib.CategoryTheory.Category.Basic      -- Category definition
import Mathlib.CategoryTheory.Functor.Basic       -- Functors
import Mathlib.CategoryTheory.NatTrans            -- Natural transformations
import Mathlib.CategoryTheory.Limits.Shapes.Products  -- Products
import Mathlib.CategoryTheory.Limits.Shapes.Terminal  -- Terminal objects
import Mathlib.CategoryTheory.Yoneda               -- Yoneda lemma
```

### Core Types

| Mathlib Type | Mathematical Concept |
|--------------|---------------------|
| `Category` | Category typeclass |
| `Functor C D` | Functor from C to D |
| `NatTrans F G` | Natural transformation F => G |
| `Iso X Y` | Isomorphism between X and Y |
| `HasProduct X Y` | Existence of product |
| `HasTerminal C` | Existence of terminal object |

---

## See Also

- **monoidal-categories.md** - Monoidal structure, tensor products, coherence
- **enriched-categories.md** - Categories enriched over monoidal categories
- **profunctors.md** - Bimodules between categories

---

## References

1. **Mac Lane, S. (1998)** - *Categories for the Working Mathematician*. 2nd ed. Springer. The classic reference.
2. **Awodey, S. (2010)** - *Category Theory*. 2nd ed. Oxford. Accessible introduction.
3. **Riehl, E. (2016)** - *Category Theory in Context*. Dover. Modern treatment with applications.
4. **nLab**: [category](https://ncatlab.org/nlab/show/category), [functor](https://ncatlab.org/nlab/show/functor), [natural transformation](https://ncatlab.org/nlab/show/natural+transformation)
5. **Mathlib documentation**: `Mathlib.CategoryTheory`
