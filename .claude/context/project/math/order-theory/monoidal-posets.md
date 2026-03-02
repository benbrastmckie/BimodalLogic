# Monoidal Posets

**Purpose**: Monoidal poset definitions for Q-enriched categories in spatial and temporal reasoning tasks.

---

## Overview

A **monoidal poset** provides the minimal structure needed to enrich categories over a poset: a poset with a compatible monoid operation. This structure underlies metric spaces, cost structures, and distance/duration reasoning in Chapter 06.

Monoidal posets are "lightweight" compared to full quantales: they require neither complete lattice structure nor distributivity. For Q-enrichment, this minimal structure suffices.

---

## Definition: Monoidal Poset

A **monoidal poset** $(Q, \leq, \otimes, k)$ consists of:

1. A **poset** $(Q, \leq)$
2. A **monoid** $(Q, \otimes, k)$ where $\otimes$ is associative with unit $k$
3. **Compatibility**: $\otimes$ is monotone in both arguments:
   $$a \leq a' \text{ and } b \leq b' \implies a \otimes b \leq a' \otimes b'$$

### Special Cases

| Structure | Definition | Additional Property |
|-----------|------------|---------------------|
| Ordered commutative monoid | $(Q, \leq, +, 0)$, partial order | Commutativity |
| Linearly ordered commutative monoid | $(Q, \leq, +, 0)$, total order | Totality |
| Totally ordered commutative group | $(Q, \leq, +, 0)$, total order with inverses | Inverses |

---

## Mathlib Type Hierarchy

| Structure | Mathlib Type | Key Properties |
|-----------|--------------|----------------|
| Ordered additive comm. monoid | `OrderedAddCommMonoid` | Partial order + add + zero + monotonicity |
| Linear ordered additive comm. monoid | `LinearOrderedAddCommMonoid` | + total order |
| Totally ordered additive comm. group | `LinearOrderedAddCommGroup` | + inverses (subtraction) |
| With top element | `LinearOrderedAddCommMonoidWithTop` | + maximum element (infinity) |
| Extended non-negative reals | `ENNReal` | Concrete $[0, \infty]$ |
| Reals with top | `WithTop Real` | General construction for adding infinity |

### Key Imports

```lean
import Mathlib.Algebra.Order.Monoid.Defs        -- OrderedAddCommMonoid, LinearOrderedAddCommMonoid
import Mathlib.Algebra.Order.Group.Defs         -- LinearOrderedAddCommGroup
import Mathlib.Algebra.Order.Monoid.WithTop     -- LinearOrderedAddCommMonoidWithTop, WithTop
import Mathlib.Data.ENNReal.Basic               -- Extended non-negative reals [0, infinity]
```

---

## Standard Examples

| Example | Structure | Tensor | Unit | Application |
|---------|-----------|--------|------|-------------|
| **Cost** | $([0,\infty], \geq, +, 0)$ | Addition | $0$ | Metric spaces, distances |
| **Bool** | $(\{0, 1\}, \leq, \land, 1)$ | Conjunction | $1$ | Reachability (connected or not) |
| **Tropical** | $(\mathbb{R} \cup \{\infty\}, \min, +, 0)$ | Addition | $0$ | Shortest path algorithms |
| **Unit interval** | $([0,1], \geq, \times, 1)$ | Multiplication | $1$ | Similarity measures |
| **Discrete distances** | $(\mathbb{Z}^{\geq 0}, \leq, +, 0)$ | Addition | $0$ | Discrete spatial reasoning |

### Notes on Examples

**Cost**: The order is reversed ($x \leq_{\mathrm{Cost}} y$ iff $x \geq y$ numerically) so that "smaller distance" is "larger" in the order. This ensures the enrichment composition axiom gives the triangle inequality.

**Bool**: The two-point monoidal poset where Q-enrichment yields preorders. If $d(x,y) = 1$, there is a morphism from $x$ to $y$; if $d(x,y) = 0$, there is not.

**Tropical**: Used in optimization and shortest-path algorithms. The tensor (addition) combines path lengths; the order (min) selects optimal paths.

---

## The Distance/Duration Structure

Chapter 06 uses $\mathcal{Q} = (Q, \leq, +, 0)$, a totally ordered commutative group:

| Interpretation | Variables | Typical Values |
|----------------|-----------|----------------|
| **Distances** | $n, m, k : Q$ | Distances between located parts |
| **Durations** | $x, y, z : Q$ | Durations in task frames |

**Common instantiations**:
- $\mathbb{R}$ (real numbers)
- $\mathbb{Z}$ (integers)
- $[0, \infty]$ (extended non-negative reals)

The same algebraic structure handles both spatial and temporal reasoning.

---

## Q-Enrichment Connection

For a monoidal poset $Q$, a **Q-category** (or Q-enriched category) consists of:

- **Objects**: A set $X$
- **Hom-values**: A function $d : X \times X \to Q$
- **Identity axiom**: $k \leq d(x, x)$ for all $x$
- **Composition axiom**: $d(x,y) \otimes d(y,z) \leq d(x,z)$ for all $x, y, z$

### For the Distance/Duration Structure

When $Q = (Q, \leq, +, 0)$ with additive monoidal structure:

- **Identity becomes**: $0 \leq d(x, x)$ (reflexivity: self-distance is at least zero)
- **Composition becomes**: $d(x,y) + d(y,z) \leq d(x,z)$ (triangle inequality)

When the order is reversed (as in Cost):

- **Composition becomes**: $d(x,y) + d(y,z) \geq d(x,z)$ (standard triangle inequality form)

This is precisely the enriched category perspective on Lawvere metric spaces.

---

## Why Monoidal Posets Suffice

Monoidal posets are "degenerate quantales" lacking complete lattice structure. For Q-enrichment, this minimal structure is sufficient:

### Comparison: Monoidal Poset vs Full Quantale

| Feature | Monoidal Poset | Full Quantale |
|---------|----------------|---------------|
| Poset structure | Required | Required |
| Monoid structure | Required | Required |
| Monotonicity | Required | Required |
| Complete lattice | **No** | Yes |
| Arbitrary suprema | **No** | Yes |
| Sup-distributivity | **No** | Yes |
| Internal hom | Optional | Yes |

### What Q-Enrichment Actually Requires

For a Q-category, we need only:
1. A poset $(Q, \leq)$ for hom-value comparison
2. A monoid $(Q, \otimes, k)$ for composition
3. Monotonicity of $\otimes$

We do **not** need:
- Arbitrary suprema (complete lattice)
- Distributivity over joins
- Internal hom/residuation

### When Full Quantale Is Needed

Full quantale theory is required when:
- Computing arbitrary suprema in composition (inf-convolution over infinite sets)
- Needing internal hom objects $[X \multimap Y]$ (residuation)
- Working with fuzzy logic interpretations

Chapter 06's inf-convolution operates over finite sets (located parts), so completeness is not essential.

---

## Relationship to Quantales

A **quantale** $(Q, \bigvee, \otimes)$ is a complete lattice with a semigroup operation distributing over arbitrary suprema:

$$a \otimes \bigvee_{i \in I} b_i = \bigvee_{i \in I} (a \otimes b_i)$$

### When Is a Monoidal Poset a Quantale?

A monoidal poset $(Q, \leq, \otimes, k)$ is a quantale only when:
1. $Q$ is a complete lattice (all suprema exist)
2. $\otimes$ distributes over arbitrary joins

Most monoidal posets used for Q-enrichment (including Cost) do not satisfy these properties and do not need to.

### Quantale Examples (for contrast)

- **Powerset quantale**: $(\mathcal{P}(M), \subseteq, \cdot, \{e\})$ where $M$ is a monoid
- **Frame/locale**: Any frame is a quantale with $\otimes = \land$
- **[0,1] with t-norm**: Some continuous t-norms on $[0,1]$ form quantales

For further quantale theory, see nLab: [quantale](https://ncatlab.org/nlab/show/quantale).

---

## See Also

- **lawvere-metric-spaces.md** - Cost monoidal poset $([0,\infty], \geq, +, 0)$ and metric space enrichment
- **enriched-categories.md** - V-enriched categories (general framework)

---

## References

- Lawvere, F.W. (1973). "Metric spaces, generalized logic, and closed categories." *Rendiconti del seminario matematico e fisico di Milano* XLIII, 135-166. TAC Reprints No. 1.
- Kelly, G.M. (1982). *Basic Concepts of Enriched Category Theory*. LMS Lecture Notes 64. TAC Reprints No. 10.
- Fong, B. and Spivak, D.I. (2018). *Seven Sketches in Compositionality*. Chapter 2: Monoidal Preorders and Enrichment. Cambridge University Press. arXiv:1803.05316.
- Mathlib: `Mathlib.Algebra.Order.Monoid.Defs`, `Mathlib.Algebra.Order.Group.Defs`, `Mathlib.Data.ENNReal.Basic`
- nLab: [monoidal poset](https://ncatlab.org/nlab/show/monoidal+poset)
