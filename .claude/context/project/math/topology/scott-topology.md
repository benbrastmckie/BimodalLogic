# Scott Topology

## Overview

Scott topology is a fundamental construction in domain theory that connects order theory and topology. Named after Dana Scott, who developed it in the 1970s for denotational semantics of programming languages, Scott topology provides a natural way to equip partially ordered sets with a topological structure that reflects their order-theoretic properties.

The key insight is that Scott topology captures the notion of "approximation" or "convergence from below" - a set is Scott-open if it is closed under approximation (upward) and cannot be reached by limits of directed families without passing through the set at some finite stage.

**Applications**:
- Domain theory and denotational semantics
- Fixed point theory (Kleene chains, Scott induction)
- Spatial reasoning (Logos chapter 06 T1/T2 axioms)
- Continuous lattice theory

## Directed Complete Partial Orders (dcpos)

### Directed Sets

A **directed set** (or directed subset) is a non-empty subset where every pair of elements has an upper bound within the set.

**Definition**: Let (P, <=) be a partially ordered set. A non-empty subset D of P is **directed** if for all x, y in D, there exists z in D such that x <= z and y <= z.

**Key properties**:
- Every singleton {x} is directed (x is an upper bound for itself)
- Every chain (linearly ordered subset) is directed
- Finite sets with a maximum element are directed
- The union of an ascending chain of directed sets is directed

**Examples**:
- In the natural numbers (N, <=), any chain {n, n+1, n+2, ...} is directed
- In a lattice, {a, b, a join b} is directed
- The set of all finite approximations to a function is directed

### dcpo Definition

A **directed complete partial order (dcpo)** is a partially ordered set where every directed subset has a supremum.

**Definition**: A poset (P, <=) is a **dcpo** if for every directed subset D of P, the supremum sup(D) exists in P.

**Key properties**:
- Every complete lattice is a dcpo (since all sets have suprema)
- Not every dcpo is a complete lattice (may lack arbitrary meets)
- Every finite poset is trivially a dcpo
- dcpos are the natural domain for Scott topology

**Relationship to complete lattices**:

| Structure | Has directed sups | Has all sups | Has all infs |
|-----------|------------------|--------------|--------------|
| dcpo | Yes | Not necessarily | Not necessarily |
| Complete lattice | Yes | Yes | Yes |

**Examples**:
1. **Natural numbers with infinity**: (N union {infinity}, <=) is a dcpo
2. **Power sets**: (P(X), subset) is a dcpo (and a complete lattice)
3. **Partial functions**: The set of partial functions from N to N ordered by graph inclusion is a dcpo
4. **Scott domain**: The ideal completion of any poset is a dcpo

## Scott Topology

### Scott-Open Sets

The **Scott topology** on a poset P consists of all subsets satisfying two conditions.

**Definition**: A subset U of a poset P is **Scott-open** if:
1. **Upper set condition**: U is an upper set (if x in U and x <= y, then y in U)
2. **Inaccessibility condition**: For every directed set D with sup(D) in U, there exists d in D such that d in U

**Intuition**: A Scott-open set is one that:
- Contains everything "above" its elements (upward closed)
- Cannot be "sneaked into" by a directed limit - if the limit is in U, some approximation must already be in U

**Examples**:
- In any dcpo, the empty set is Scott-open (vacuously)
- The whole space P is Scott-open
- For any element a, the set {x | a << x} (strictly way-above a) is Scott-open
- The principal filter {x | a <= x} is generally NOT Scott-open (fails inaccessibility)

### Scott-Closed Sets

**Scott-closed sets** are the complements of Scott-open sets, characterized dually.

**Definition**: A subset C of a poset P is **Scott-closed** if:
1. **Lower set condition**: C is a lower set (if y in C and x <= y, then x in C)
2. **Directed closure**: If D is a directed subset of C, then sup(D) in C

**Intuition**: A Scott-closed set is:
- Downward closed under the order
- Closed under directed suprema (limits of directed approximations stay in the set)

**Examples**:
- The empty set and the whole space are Scott-closed
- Any principal ideal {x | x <= a} is Scott-closed
- In Logos chapter 06: The possibility set P is Scott-closed (axiom T2)

### Properties

**Separation axioms**:
- Scott topology is always T0 (Kolmogorov): Distinct points are topologically distinguishable
- Scott topology is generally NOT T1: Singletons {x} are only closed if x is minimal
- Scott topology is generally NOT Hausdorff: Cannot separate points with disjoint open neighborhoods

**Relationship to specialization order**:
- The specialization preorder of Scott topology coincides with the original order
- x <= y in the order iff x is in the closure of {y}

**Compactness**:
- Scott topology is generally not compact
- An element k is compact in the order-theoretic sense iff {x | k << x} is a neighborhood of k

## Scott Continuity

### Definition

A function between dcpos is **Scott-continuous** if it preserves directed suprema.

**Definition**: Let P and Q be dcpos. A function f: P -> Q is **Scott-continuous** if for every directed set D in P:
- The image f(D) = {f(d) | d in D} is directed in Q
- sup(f(D)) = f(sup(D))

Equivalently: f preserves directed suprema.

### Key Properties

**Monotonicity**:
- Every Scott-continuous function is monotonic (order-preserving)
- If x <= y then f(x) <= f(y)
- The converse is false: not every monotonic function is Scott-continuous

**Topological equivalence**:
- A function f: P -> Q is Scott-continuous (preserves directed sups) iff it is continuous for the Scott topologies on P and Q
- This justifies the name "Scott-continuous"

**Composition**:
- The composition of Scott-continuous functions is Scott-continuous
- The identity function is Scott-continuous
- Scott-continuous maps form a category

**Fixed points**:
- If f: P -> P is Scott-continuous and P has a bottom element, then f has a least fixed point
- The least fixed point is the supremum of the Kleene chain: bot, f(bot), f(f(bot)), ...

## Mathlib Support

### Available Definitions

Mathlib provides partial support for Scott topology concepts:

| Concept | Mathlib Location | Notes |
|---------|------------------|-------|
| `DirectedOn` | `Mathlib.Order.Directed` | Directed subsets of a preorder |
| `ScottContinuous` | `Mathlib.Order.ScottContinuity` | Preservation of directed sups |
| `Scott.topologicalSpace` | `Mathlib.Topology.OmegaCompletePartialOrder` | Scott topology construction |
| `OmegaCompletePartialOrder` | `Mathlib.Order.OmegaCompletePartialOrder` | Chains have sups (omega-cpos) |

**Important distinction**: Mathlib uses `OmegaCompletePartialOrder` (omega-cpo) which requires that *chains* (linearly ordered subsets) have suprema. This is weaker than dcpo, which requires all *directed* sets to have suprema.

**Terminology clarification**:
- **omega-cpo**: Suprema exist for *countable* chains (omega-chains)
- **dcpo**: Suprema exist for *all* directed sets (may be uncountable)
- In practice: For countable posets or when working with recursive definitions over naturals, omega-cpo suffices. Full dcpo is needed for uncountable directed families.

### Code Examples

```lean
import Mathlib.Order.Directed
import Mathlib.Order.ScottContinuity
import Mathlib.Topology.OmegaCompletePartialOrder

-- Directed subset predicate
#check DirectedOn
-- DirectedOn : (α → α → Prop) → Set α → Prop

-- Scott-continuous function
#check ScottContinuous
-- ScottContinuous : (α → β) → Prop

-- Example: Identity is Scott-continuous
example {α : Type*} [Preorder α] : ScottContinuous (id : α → α) :=
  ScottContinuous.id

-- Composition preserves Scott continuity
example {α β γ : Type*} [Preorder α] [Preorder β] [Preorder γ]
    {f : β → γ} {g : α → β}
    (hf : ScottContinuous f) (hg : ScottContinuous g) :
    ScottContinuous (f ∘ g) :=
  hf.comp hg
```

### Mathlib Imports

```lean
-- Core directed set theory
import Mathlib.Order.Directed

-- Scott continuity
import Mathlib.Order.ScottContinuity

-- Omega-complete partial orders and Scott topology
import Mathlib.Topology.OmegaCompletePartialOrder

-- Complete lattices (for dcpo-like structures)
import Mathlib.Order.CompleteLattice
```

## Applications

### Domain Theory

Scott topology is the foundation of domain theory, which provides mathematical semantics for:

- **Programming language semantics**: Types are dcpos, programs are Scott-continuous functions
- **Recursion theory**: Fixed points of recursive definitions exist by Scott's fixed point theorem
- **Approximation**: Partial information is ordered, computation approaches complete values

### Spatial Reasoning (Logos)

In Logos chapter 06, Scott topology connects to the mereological structure:

**Axiom T1**: The natural topology on state space S is the Scott topology arising from the parthood ordering. A subset U of S is Scott-open if:
- U is upward closed under parthood
- U is inaccessible by directed suprema

**Axiom T2**: The possibility set P is Scott-closed, meaning:
- P is downward closed (parts of possible states are possible)
- P is closed under directed limits (directed limits of possible states remain possible)

**Axiom T3**: The metric topology refines the Scott topology - every Scott-open set is metric-open, but not vice versa.

## See Also

- **topological-spaces.md** - Classical point-set topology, separation axioms
- **../lattice-theory/lattices.md** - Complete lattices, way-below relation, continuous lattices
- **../order-theory/partial-orders.md** - Basic order theory, monotone functions

## References

- Dana Scott, "Outline of a Mathematical Theory of Computation" (1970)
- Abramsky & Jung, "Domain Theory" in Handbook of Logic in Computer Science (1994)
- Gierz et al., "Continuous Lattices and Domains" (Cambridge, 2003)
- nLab: [dcpo](https://ncatlab.org/nlab/show/dcpo), [Scott topology](https://ncatlab.org/nlab/show/Scott+topology)
- Mathlib documentation: `Mathlib.Order.ScottContinuity`
