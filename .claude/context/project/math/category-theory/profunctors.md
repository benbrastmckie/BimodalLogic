# Profunctors

**Purpose**: Profunctor (bimodule/distributor) definitions for agent domain knowledge in enriched category theory and spatial reasoning tasks.

---

## Overview

**Profunctors** generalize relations between categories. In the enriched setting, Q-profunctors (Q-bimodules) assign quantale values to pairs of objects, satisfying compatibility conditions with the enriched structure. Profunctors compose via a generalized "matrix multiplication" over the quantale.

---

## Terminology

The same concept appears under different names in the literature:

| Name | Emphasis | Common In |
|------|----------|-----------|
| **Profunctor** | Functorial character | Category theory |
| **Distributor** | Distribution of morphisms (Benabou) | French school |
| **Bimodule** | Two-sided action structure | Enriched settings, algebra |
| **Correspondence** | Relational aspect | Some contexts |

This document uses "profunctor" and "bimodule" interchangeably.

---

## Definition: Q-Profunctor

Let $Q$ be a quantale and let $\mathcal{C}$ and $\mathcal{D}$ be Q-categories.

A **Q-profunctor** (or **Q-bimodule**) from $\mathcal{C}$ to $\mathcal{D}$ is a function:
$$\Phi : \mathrm{Obj}(\mathcal{C}) \times \mathrm{Obj}(\mathcal{D}) \to Q$$
satisfying the bimodule axioms below.

**Notation**: $\Phi : \mathcal{C} \rightsquigarrow \mathcal{D}$

**Equivalent view**: A Q-functor $\mathcal{C}^{op} \otimes \mathcal{D} \to Q$.

---

## Bimodule Axioms

For $\Phi : \mathcal{C} \rightsquigarrow \mathcal{D}$:

### Left Action (C acts on left)

For all $a, a' \in \mathcal{C}$ and $b \in \mathcal{D}$:
$$\mathcal{C}(a', a) \otimes \Phi(a, b) \leq \Phi(a', b)$$

### Right Action (D acts on right)

For all $a \in \mathcal{C}$ and $b, b' \in \mathcal{D}$:
$$\Phi(a, b) \otimes \mathcal{D}(b, b') \leq \Phi(a, b')$$

### Metric Interpretation

For the Cost quantale $([0,\infty], \geq, +, 0)$:
- **Left action**: $d_{\mathcal{C}}(a', a) + \Phi(a, b) \geq \Phi(a', b)$
- **Right action**: $\Phi(a, b) + d_{\mathcal{D}}(b, b') \geq \Phi(a, b')$

These express that moving within $\mathcal{C}$ or $\mathcal{D}$ respects the cross-distance bounds. If you can get from $a'$ to $a$ and then to $b$, the total distance to $b$ from $a'$ is bounded accordingly.

---

## Composition of Profunctors

Given profunctors $\Phi : \mathcal{C} \rightsquigarrow \mathcal{D}$ and $\Psi : \mathcal{D} \rightsquigarrow \mathcal{E}$, their composite $\Psi \circ \Phi : \mathcal{C} \rightsquigarrow \mathcal{E}$ is:

$$(\Psi \circ \Phi)(a, c) = \bigvee_{b \in \mathcal{D}} \Phi(a, b) \otimes \Psi(b, c)$$

This is a generalized "matrix multiplication" where:
- Sum becomes join ($\bigvee$)
- Product becomes tensor ($\otimes$)

---

## Inf-Convolution (Metric Case)

For the Cost quantale $([0,\infty], \geq, +, 0)$, the join in the reversed order is an infimum in the standard order:

$$(\Psi \circ \Phi)(a, c) = \inf_{b \in \mathcal{D}} \{\Phi(a, b) + \Psi(b, c)\}$$

This is the **inf-convolution** formula from convex analysis:
- $\Phi$ measures distances from $\mathcal{C}$ to $\mathcal{D}$
- $\Psi$ measures distances from $\mathcal{D}$ to $\mathcal{E}$
- The composite measures the **shortest path distance** via any intermediate point in $\mathcal{D}$

### Connection to Convex Analysis

In convex analysis, the inf-convolution of functions $f, g : \mathbb{R}^n \to \mathbb{R} \cup \{\infty\}$ is:
$$(f \square g)(x) = \inf_y \{f(y) + g(x - y)\}$$

This is the same structure with the intermediate point $y$ playing the role of the object in $\mathcal{D}$.

---

## The Bicategory of Profunctors

Q-categories and Q-profunctors form a **bicategory** $\mathrm{Prof}_Q$:

| Level | Objects |
|-------|---------|
| **0-cells** | Q-categories |
| **1-cells** | Q-profunctors |
| **2-cells** | Pointwise ordering: $\Phi \leq \Psi$ iff $\Phi(a,b) \leq \Psi(a,b)$ for all $a, b$ |

### Identity Profunctor

The identity profunctor $\iota_{\mathcal{C}} : \mathcal{C} \rightsquigarrow \mathcal{C}$ is the hom-functor:
$$\iota_{\mathcal{C}}(a, b) = \mathcal{C}(a, b)$$

This satisfies $\Phi \circ \iota_{\mathcal{C}} = \Phi$ and $\iota_{\mathcal{D}} \circ \Phi = \Phi$ up to isomorphism.

### Representable Profunctors

Every Q-functor $F : \mathcal{C} \to \mathcal{D}$ induces:
- A profunctor $\mathcal{D}(-, F-) : \mathcal{C} \rightsquigarrow \mathcal{D}$
- A profunctor $\mathcal{D}(F-, -) : \mathcal{D} \rightsquigarrow \mathcal{C}$

These form an adjunction in the bicategory $\mathrm{Prof}_Q$.

---

## Application: Spatial Profiles

In the Logos spatial chapter, **spatial profiles** $\delta \in \Pi(s, t)$ are Q-bimodules satisfying:
- Left action: $\gamma_s(a', a) + \delta(a, b) \leq \delta(a', b)$
- Right action: $\delta(a, b) + \gamma_t(b, b') \leq \delta(a, b')$

Composition via inf-convolution:
$$(\epsilon \circ \delta)(a, c) = \inf_{b \in L(t)} \{\delta(a, b) + \epsilon(b, c)\}$$

The identity bimodule $\iota_s$ is the internal geometry $\gamma_s$ itself.

---

## See Also

- **enriched-categories.md** - Q-categories as profunctor endpoints
- **cauchy-completion.md** - Cauchy completion via adjoint profunctors

---

## References

- Benabou, J. (1973). "Les distributeurs." Universite Catholique de Louvain.
- Baez, J.C. Applied Category Theory Course, [Lecture 62: Enriched Profunctors](https://math.ucr.edu/home/baez/act_course/lecture_62.html)
- nLab: [profunctor](https://ncatlab.org/nlab/show/profunctor)
