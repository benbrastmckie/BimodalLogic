# Cauchy Completion

**Purpose**: Enriched Cauchy completion for agent domain knowledge in enriched category theory and metric space tasks.

---

## Overview

**Cauchy completion** is the enriched-categorical generalization of adding limit points to metric spaces. In the enriched setting, it is characterized via profunctors with right adjoints, idempotent splitting, or absolute colimits. For symmetric Lawvere metric spaces, enriched Cauchy completion coincides with classical metric space completion.

---

## Classical Motivation

For metric spaces, Cauchy completion adds limit points of Cauchy sequences.

A sequence $(x_n)$ in a metric space $(X, d)$ is **Cauchy** if:
$$\forall \epsilon > 0. \exists N. \forall m, n > N. \quad d(x_m, x_n) < \epsilon$$

The completion $\bar{X}$ consists of equivalence classes of Cauchy sequences, where two sequences are equivalent if their "distance" converges to zero.

---

## Enriched Cauchy Completion

### Definition via Profunctors

Let $V$ be a monoidal category (or quantale $Q$).

**Definition**: The **Cauchy completion** $\bar{\mathcal{C}}$ of a V-category $\mathcal{C}$ is the full V-subcategory of V-profunctors $p : \mathbf{1} \rightsquigarrow \mathcal{C}$ that admit a **right adjoint** in the bicategory of profunctors.

Equivalently, $\bar{\mathcal{C}}$ consists of certain V-presheaves $p : \mathcal{C}^{op} \to V$ that are "representable up to splitting idempotents."

### Yoneda Embedding

The **Yoneda embedding** $\mathcal{C} \hookrightarrow \bar{\mathcal{C}}$ sends each object $a \in \mathcal{C}$ to the representable presheaf $\mathcal{C}(-, a)$.

---

## Characterizations of Cauchy Completeness

A V-category $\mathcal{C}$ is **Cauchy complete** if and only if any of the following equivalent conditions hold:

### 1. Idempotent Splitting

Every **idempotent** morphism in $\mathcal{C}$ splits.

An idempotent is a morphism $e : a \to a$ with $e \circ e = e$. It splits if there exist $r : a \to b$ and $s : b \to a$ with $s \circ r = e$ and $r \circ s = \mathrm{id}_b$.

### 2. Yoneda Equivalence

The Yoneda embedding $\mathcal{C} \hookrightarrow \bar{\mathcal{C}}$ is an equivalence of V-categories.

### 3. Absolute Colimits

Every **absolute colimit** exists in $\mathcal{C}$.

Absolute colimits are colimits preserved by all V-functors. In Set-enriched categories, these are precisely the split coequalizers.

---

## Metric Space Specialization

For Lawvere metric spaces (enriched over $[0,\infty]$):

### Forward Cauchy Sequences

A **forward Cauchy sequence** in a Lawvere metric space $(X, d)$ satisfies:
$$\lim_{m \to \infty} \lim_{n \to \infty} d(x_m, x_n) = 0$$

Note: This is a directed limit, not symmetric. For asymmetric distances, this captures convergence "in one direction."

### Enriched vs Classical Completion

The enriched Cauchy completion of a Lawvere metric space consists of equivalence classes of forward Cauchy sequences.

**Key Theorem (Lawvere, 1973)**: For a **symmetric** Lawvere metric space, the enriched Cauchy completion coincides with the classical metric space completion.

For asymmetric spaces, the enriched completion may differ from classical constructions.

---

## Connection to Representable Presheaves

Points of the Cauchy completion are V-presheaves that are:

| Property | Description |
|----------|-------------|
| **Connected** | Not decomposable as a coproduct |
| **Projective** | The functor $\hom(p, -)$ preserves coequalizers |
| **Tiny** (Lawvere) | $\hom(p, -)$ preserves small coproducts |

These "tiny" or "atomic" presheaves generalize the notion of point to the enriched setting.

---

## Adjoint Profunctors and Cauchy Completeness

A V-profunctor $\Phi : \mathcal{C} \rightsquigarrow \mathcal{D}$ has a **right adjoint** $\Psi : \mathcal{D} \rightsquigarrow \mathcal{C}$ if:
$$\iota_{\mathcal{C}} \leq \Psi \circ \Phi \quad \text{and} \quad \Phi \circ \Psi \leq \iota_{\mathcal{D}}$$

The Cauchy completion $\bar{\mathcal{C}}$ is characterized as the V-category of profunctors from the unit category with right adjoints.

---

## Application to Spatial Reasoning

In spatial reasoning contexts:
- Cauchy completion provides a canonical way to "fill in" missing spatial points
- Idempotent splitting corresponds to collapsing redundant spatial configurations
- The completion preserves the enriched distance structure

---

## See Also

- **lawvere-metric-spaces.md** - Lawvere metric spaces (primary application)
- **profunctors.md** - Profunctor composition and adjoints
- **enriched-categories.md** - V-enriched category foundations

---

## References

- Lawvere, F.W. (1973). "Metric spaces, generalized logic, and closed categories." TAC Reprints No. 1.
- Stewart, N. "From Q to R: a leisurely review of Cauchy completion."
- nLab: [Cauchy complete category](https://ncatlab.org/nlab/show/Cauchy+complete+category)
