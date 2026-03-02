# Lattice Theory Concepts for Spatial Reasoning

> **Scope**: Lattice-theoretic concepts supporting spatial chapter implementation (06-Spatial.tex).
> **Current as of**: 2026-02-23
> **Purpose**: Bridge mathematical lattice theory with spatial reasoning applications in Logos.

## Overview

This document covers lattice-theoretic concepts that arise in spatial reasoning, particularly:
- **Compact elements** in complete lattices
- **Algebraic lattices** (compactly generated lattices)
- **Directed sets** and their role in defining compactness
- **Scott topology** connecting topological and order-theoretic structure

These concepts support the spatial axioms (especially L1: "located states are compact") and the topological foundation of the state space.

**Cross-reference**: For basic lattice definitions (join, meet, distributivity), see `../../math/lattice-theory/lattices.md`.

---

## Compact Elements

### Definition

An element `c` in a complete lattice `(L, <=)` is **compact** (also called **finite**) if for every directed subset `D` of `L` with supremum `sup D`, whenever `c <= sup D`, there exists `d` in `D` such that `c <= d`.

**Formal statement**: `c` is compact iff
```
forall D directed subset of L: c <= sup(D) implies exists d in D: c <= d
```

### Intuition

Compact elements cannot be "approximated from below" by directed sets without already being dominated by some member of that set. They represent **finitary, irreducible information** that cannot be obtained as a limit of approximations.

Think of compact elements as "atomic" or "finite" pieces of data:
- In a power set lattice, the compact elements are exactly the finite subsets
- In a lattice of substructures, the compact elements are finitely generated substructures
- In the spatial state space, located states are compact (they represent definite point locations)

### Mathlib Definition

```lean
import Mathlib.Order.CompactlyGenerated.Basic

-- Definition via finite suprema over indexed families
def CompleteLattice.IsCompactElement {alpha : Type*} [CompleteLattice alpha] (k : alpha) : Prop :=
  forall (iota : Type*) (s : iota -> alpha), k <= iSup s -> exists t : Finset iota, k <= t.sup s
```

### Key Theorem (Directed Set Characterization)

The directed-set characterization is equivalent to the indexed family definition:

```lean
theorem CompleteLattice.isCompactElement_iff_le_of_directed_sSup_le (alpha : Type*)
    [CompleteLattice alpha] (k : alpha) :
    IsCompactElement k <->
    (forall (s : Set alpha), s.Nonempty -> DirectedOn (. <=.) s -> k <= sSup s -> exists x in s, k <= x)
```

**Usage note**: When proving compactness in Logos, use the directed-set characterization as it aligns with the intuitive meaning ("cannot be approximated by directed limits from outside").

### Properties of Compact Elements

| Property | Statement |
|----------|-----------|
| Bottom is compact | The bottom element is always compact |
| Closed under finite joins | If `a` and `b` are compact, then `a join b` is compact |
| NOT closed under meets | The meet of compact elements need not be compact |
| Closure downward | If `c` is compact and `d <= c`, `d` need NOT be compact |

### Examples

| Lattice | Compact Elements |
|---------|------------------|
| Power set `P(A)` | Finite subsets of `A` |
| Subgroups of `G` | Finitely generated subgroups |
| Ideals in a ring `R` | Finitely generated ideals |
| Opens of a topological space | Compact-open sets (in spectral spaces) |

---

## Algebraic Lattices

### Definition

A complete lattice `L` is **algebraic** (or **compactly generated**) if every element `x` of `L` is the supremum of the compact elements below `x`.

**Formal statement**: `L` is algebraic iff
```
forall x in L: x = sup{c in L : c compact and c <= x}
```

Equivalently: The compact elements are **join-dense** in `L` -- every element can be expressed as a join of compact elements.

### Key Properties

| Property | Description |
|----------|-------------|
| Completeness | Every algebraic lattice is complete |
| Compact semilattice | The set of compact elements forms a join-semilattice with bottom |
| Domain theory | Algebraic dcpos are central to domain theory |
| Scott topology | Compact elements are "finite points" in Scott topology |

### Mathlib Class

```lean
import Mathlib.Order.CompactlyGenerated.Basic

-- Compactly generated = algebraic
class IsCompactlyGenerated (alpha : Type*) [CompleteLattice alpha] : Prop where
  exists_sSup_eq : forall a : alpha, exists s : Set alpha, (forall x in s, IsCompactElement x) and sSup s = a
```

### Examples

| Structure | Why Algebraic |
|-----------|---------------|
| Power set `P(A)` | Every subset is union of singletons (compact) |
| Finitary closure systems | Elements are closures of finite sets |
| Substructures `Sub(A)` | Elements are joins of finitely generated substructures |
| Ideals in Noetherian ring | Noetherian condition ensures compactly generated |

### Non-Examples

- The lattice of closed subsets of `[0,1]` is NOT algebraic (the interval `[0,1]` cannot be expressed as a join of compact closed sets)
- Continuous lattices need not be algebraic (see Task 81)

---

## Directed Sets

### Definition

A subset `D` of a partial order `(P, <=)` is **directed** if:
1. `D` is non-empty
2. For every `a, b` in `D`, there exists `c` in `D` such that `a <= c` and `b <= c`

**Formal statement**:
```
D directed iff D nonempty and forall a, b in D: exists c in D: a <= c and b <= c
```

### Intuition

Directed sets are "upward-filtering" -- any two elements have a common upper bound within the set. They generalize chains (totally ordered subsets) while retaining the key property needed for approximation arguments.

**Contrast with chains**: Every chain is directed, but not every directed set is a chain. Directed sets allow "branching" paths that eventually merge.

### Mathlib Definition

```lean
import Mathlib.Order.Directed

-- DirectedOn for a set with a relation
def DirectedOn {alpha : Type*} (r : alpha -> alpha -> Prop) (s : Set alpha) : Prop :=
  forall x in s, forall y in s, exists z in s, r x z and r y z
```

### Relationship to Chains

| Property | Chains | Directed Sets |
|----------|--------|---------------|
| Totality | Yes (any two comparable) | No (may have incomparable elements) |
| Upper bound property | Yes | Yes |
| Approximation role | Iterative chains | More general approximation |
| CPO requirement | Chain-complete | dcpo (directed-complete) |

### Role in Compactness

Directed sets are central to defining compact elements:
- Compactness says: if `c <= sup D` for directed `D`, then `c <= d` for some `d in D`
- This captures: compact elements cannot be "reached" by directed approximation from below
- The directed structure ensures the approximation is "convergent" in a suitable sense

---

## Scott Topology

### Definition

The **Scott topology** on a partial order `P` has as open sets all subsets `O` that satisfy:
1. **Upper set**: If `x in O` and `x <= y`, then `y in O`
2. **Inaccessible by directed suprema**: For every directed set `D` with `sup D in O`, there exists `d in D` with `d in O`

**Formal statement**: `O` is Scott-open iff
```
(forall x in O, y: x <= y implies y in O) and
(forall D directed: sup D in O implies exists d in D: d in O)
```

### Intuition

Scott-open sets cannot be "reached" by directed limits from outside. The second condition says: you cannot enter a Scott-open set by taking directed suprema -- you must already be in the set at some finite stage.

This is analogous to how open sets in topology cannot be "reached" by convergent sequences from outside (in sequential spaces).

### Connection to Compact Elements

**Key theorem**: In a complete lattice `L`, an element `c` is compact if and only if its principal upper set `{x : c <= x}` is Scott-open.

This provides a topological characterization of compactness:
- Compact elements are exactly those whose "above set" is topologically open in the Scott topology
- Compactness = topological "detectability" by directed limits

### Scott Continuity

A function `f : P -> Q` between partial orders is **Scott-continuous** if it preserves directed suprema.

**Mathlib Definition**:
```lean
import Mathlib.Order.ScottContinuity

def ScottContinuous {alpha beta : Type*} [Preorder alpha] [Preorder beta] (f : alpha -> beta) : Prop :=
  forall (d : Set alpha), d.Nonempty -> DirectedOn (. <=.) d ->
    IsLUB (f '' d) (f (sSup d))
```

### Properties of Scott Continuity

| Property | Statement |
|----------|-----------|
| Monotonicity | Every Scott-continuous function is monotone |
| Identity | The identity function is Scott-continuous |
| Composition | Composition of Scott-continuous functions is Scott-continuous |
| Fixed points | Scott-continuous functions on pointed dcpos have least fixed points |

### Scott Topology vs. Other Topologies

| Topology | Open Sets | Key Property |
|----------|-----------|--------------|
| Scott | Upper sets inaccessible by directed suprema | Detects approximation |
| Alexandrov | All upper sets | Coarsest T0 topology |
| Lawson | Scott meets lower topology | Hausdorff on domains |

---

## Application to Spatial Reasoning

### Concept Mapping

These lattice-theoretic concepts appear in the spatial chapter as follows:

| Concept | Spatial Application | Reference |
|---------|---------------------|-----------|
| Compact element | L1: Located states are compact | Axiom L1 |
| Complete lattice | State space under parthood | State space structure |
| Directed sets | Approximation via directed families | Compactness definition |
| Algebraic lattice | Regions as joins of located elements | Region structure |
| Scott topology | Topological structure on states | Task 69 |

### Axiom L1: Located States Are Compact

**Statement**: Every located (point-located) state is compact in the state space lattice.

**Interpretation using directed sets**: If `a` is located and `a <= sup D` for a directed set `D` of states, then `a <= d` for some `d in D`.

**Intuition**: A located state represents a definite point position. It cannot be "approximated from below" by states that do not already contain that position. This makes located states "finitary" -- they carry irreducible positional information.

### Connection to Region Structure

Regions are fusions of located states. In an algebraic lattice:
- Every region `r` equals `sup{a : a located and a <= r}`
- The located (compact) elements "generate" all regions
- This is the spatial analog of how finite sets generate the power set

**Caveat**: The region structure is NOT a frame (meets may not preserve arbitrary joins). See `topological-foundations-domain.md` for details.

---

## Mathlib Imports

```lean
-- Compact elements and algebraic lattices
import Mathlib.Order.CompactlyGenerated.Basic

-- Directed sets
import Mathlib.Order.Directed

-- Scott continuity
import Mathlib.Order.ScottContinuity

-- Complete partial orders (dcpos)
import Mathlib.Order.CompletePartialOrder

-- Complete lattices (foundation)
import Mathlib.Order.CompleteLattice
```

---

## External Resources

### Mathematical Literature

- [Compact element - Wikipedia](https://en.wikipedia.org/wiki/Compact_element)
- [Algebraic lattice - PlanetMath](https://planetmath.org/algebraiclattice)
- [nLab: algebraic lattice](https://ncatlab.org/nlab/show/algebraic+lattice)
- [Complete partial order - Wikipedia](https://en.wikipedia.org/wiki/Complete_partial_order)
- [Scott continuity - Wikipedia](https://en.wikipedia.org/wiki/Scott_continuity)
- [Domain theory - Wikipedia](https://en.wikipedia.org/wiki/Domain_theory)

### Textbook References

- J.B. Nation, [Notes on Lattice Theory](https://math.hawaii.edu/~jb/math618/Nation-LatticeTheory.pdf)
- Abramsky & Jung, [Domain Theory Handbook Chapter](https://www.cs.ox.ac.uk/people/samson.abramsky/handbook.pdf) -- comprehensive treatment of domains, Scott topology, and continuous lattices

### Mathlib Documentation

- `Mathlib.Order.CompactlyGenerated.Basic` -- Compact elements, compactly generated lattices
- `Mathlib.Order.ScottContinuity` -- Scott continuity
- `Mathlib.Order.Directed` -- Directed sets
- `Mathlib.Order.CompletePartialOrder` -- Complete partial orders (dcpos)

---

## Related Context Files

- `../../math/lattice-theory/lattices.md` -- Basic lattice definitions (join, meet, complete lattices)
- `../../math/order-theory/partial-orders.md` -- Partial orders, preorders, monotone functions
- `spatial-domain.md` -- Spatial reasoning conventions and axioms
- `topological-foundations-domain.md` -- Topological structure on state space

**Future**: Task 81 will add documentation for continuous lattices (a generalization of algebraic lattices where approximation uses "way-below" instead of compactness).
