# Enriched Categories

**Purpose**: V-enriched category definitions for agent domain knowledge in categorical and spatial reasoning tasks.

---

## Overview

An **enriched category** generalizes ordinary categories by replacing hom-sets with hom-objects in a monoidal category V. This abstraction captures algebraic, topological, and metric structures uniformly.

---

## Definition: V-Enriched Category

A **V-enriched category** (or **V-category**) over a monoidal category $(V, \otimes, I)$ consists of:

1. **Objects**: A set $\mathrm{Obj}(\mathcal{C})$

2. **Hom-objects**: For each pair $(a, b)$ of objects, an object $\mathcal{C}(a, b) \in \mathrm{Obj}(V)$

3. **Composition**: For each triple $(a, b, c)$, a morphism in $V$:
   $$\circ_{a,b,c} : \mathcal{C}(b, c) \otimes \mathcal{C}(a, b) \to \mathcal{C}(a, c)$$

4. **Identity**: For each object $a$, a morphism in $V$:
   $$j_a : I \to \mathcal{C}(a, a)$$

### Enrichment Axioms

**Associativity**: The following diagram commutes (using the associator $\alpha$ of $V$):
$$
(\mathcal{C}(c,d) \otimes \mathcal{C}(b,c)) \otimes \mathcal{C}(a,b)
\xrightarrow{\alpha}
\mathcal{C}(c,d) \otimes (\mathcal{C}(b,c) \otimes \mathcal{C}(a,b))
$$
with both paths to $\mathcal{C}(a,d)$ equal.

**Unit Laws**: Composition with identity morphisms acts as left and right identity via the unitors of $V$:
$$I \otimes \mathcal{C}(a,b) \xrightarrow{j_b \otimes \mathrm{id}} \mathcal{C}(b,b) \otimes \mathcal{C}(a,b) \xrightarrow{\circ} \mathcal{C}(a,b)$$
equals the left unitor $\lambda : I \otimes \mathcal{C}(a,b) \to \mathcal{C}(a,b)$, and similarly for right units.

---

## Standard Examples of Enriching Categories

| Enriching Category $V$ | Tensor $\otimes$ | Unit $I$ | Resulting Structure |
|------------------------|-----------------|----------|---------------------|
| **Set** (sets, functions) | Cartesian product | singleton | Locally small categories |
| **Ab** (abelian groups) | Tensor product $\otimes_\mathbb{Z}$ | $\mathbb{Z}$ | Ringoids / preadditive categories |
| **Vect** (vector spaces) | Tensor product | base field | Linear categories / algebroids |
| **Top** (topological spaces) | Product topology | point | Topologically enriched categories |
| **Cat** (small categories) | Product | terminal category | Strict 2-categories |
| **Chain** (chain complexes) | Tensor of complexes | base ring | DG-categories |
| **$([0,\infty], \geq, +, 0)$** | Addition | 0 | Lawvere metric spaces |
| **2** (two-element poset) | $\land$ (meet) | $\top$ | Preorders |

---

## Key Insight

The passage from ordinary categories to enriched categories replaces:
- **Hom-sets** $\mathrm{Hom}(a,b)$ with **hom-objects** $\mathcal{C}(a,b) \in V$
- **Function composition** with **V-morphism composition**
- **Identity functions** with **V-morphisms from the unit**

This allows the "distance" or "relation" between objects to carry additional structure (algebraic, order-theoretic, topological, or metric).

---

## V-Functors

A **V-functor** $F : \mathcal{C} \to \mathcal{D}$ between V-categories consists of:
- An object function $F : \mathrm{Obj}(\mathcal{C}) \to \mathrm{Obj}(\mathcal{D})$
- For each pair $(a,b)$, a V-morphism $F_{a,b} : \mathcal{C}(a,b) \to \mathcal{D}(Fa, Fb)$

preserving composition and identities.

---

## See Also

- **basics.md** - Category fundamentals: categories, functors, natural transformations
- **monoidal-categories.md** - Monoidal structure required for enrichment
- **lawvere-metric-spaces.md** - Metric spaces as Cost-enriched categories
- **profunctors.md** - Bimodules between enriched categories

---

## References

- Kelly, G.M. (1982). *Basic Concepts of Enriched Category Theory*. LMS Lecture Notes 64. TAC Reprints No. 10.
- nLab: [enriched category](https://ncatlab.org/nlab/show/enriched+category)
