# Topological Foundations Domain

> **Scope**: Topological foundations for spatial chapter implementation, covering Scott topology, spatially complete regions, and metric topology generation.
> **Current as of**: 2026-02-23
> **Source**: Task 69 research reports (definitional foundation for spatial chapter)

## Purpose

This file documents the topological layer of the Logos spatial theory, bridging between:
- **Mereology foundations** (complete lattice structure) - see `mereology-foundations.md`
- **Spatial notation** (enriched categories, variable conventions) - see `spatial-domain.md`

The key insight is that spatial completeness provides the constraint needed to generate well-behaved metric topologies from the state space.

---

## 1. Scott Topology Fundamentals

The Scott topology captures "approximation from below" on partially ordered structures. It is the natural topology for domain-theoretic reasoning on the state space.

### 1.1 Directed Sets

**Definition**: A subset D of S is **directed** if:
1. D is non-empty
2. For any s, t in D, there exists u in D with s parthood u and t parthood u

**Notation**: `DirectedOn(<=) D` or `IsDirected D`

**Intuition**: Directed sets are "generalized approximation sequences" - any two partial approximations have a common refinement. In the state space, directed sets represent chains of increasingly informative states.

### 1.2 Scott-Open Sets

**Definition**: A subset U of S is **Scott-open** if:
1. **Upper set**: If s in U and s parthood t, then t in U
2. **Inaccessibility by directed suprema**: For any directed D with sup(D) in U, there exists d in D with d in U

**Formal statement** (Mathlib style):
```
IsScottOpen(U) := IsUpperSet U /\ DirSupInacc U

DirSupInacc(U) := forall D, D.Nonempty -> DirectedOn(<=) D ->
  forall a, IsLUB D a -> a in U -> (D inter U).Nonempty
```

**Key insight**: Scott-open sets cannot be "jumped into" from below by a limit - some approximant must already be inside.

### 1.3 Scott-Closed Sets

**Definition**: A subset C of S is **Scott-closed** if:
1. **Lower set**: If t in C and s parthood t, then s in C
2. **Closed under directed suprema**: For directed D subset C, if sup(D) exists, then sup(D) in C

**Formal statement**:
```
IsScottClosed(C) := IsLowerSet C /\ DirSupClosed C

DirSupClosed(C) := forall D, D.Nonempty -> DirectedOn(<=) D ->
  forall a, IsLUB D a -> D subset C -> a in C
```

**Key theorem**: A set is Scott-closed iff its complement is Scott-open.

**Lemmas** (Mathlib):
```lean
lemma dirSupInacc_compl : DirSupInacc s^c <-> DirSupClosed s
lemma dirSupClosed_compl : DirSupClosed s^c <-> DirSupInacc s
lemma IsUpperSet.dirSupClosed (hs : IsUpperSet s) : DirSupClosed s
lemma IsLowerSet.dirSupInacc (hs : IsLowerSet s) : DirSupInacc s
```

### 1.4 T0 Property and dcpos

**dcpo Definition**: A **directed-complete partial order** (dcpo) is a partial order where every directed subset has a least upper bound.

**Logos connection**: The state space (S, parthood) forms a complete lattice, which is automatically a dcpo. The null state provides bottom; mereological fusion provides joins.

**Separation properties**:

| Property | Status | Description |
|----------|--------|-------------|
| T0 | Yes | Distinct points are topologically distinguishable |
| T1 | No | Points are not closed in general |
| T2 (Hausdorff) | No | Not Hausdorff |

**Specialization order**: In the Scott topology, the specialization order coincides with the original partial order. This is fundamental: topology and order agree.

---

## 2. Spatially Complete Regions

Spatial completeness is the key constraint that prevents "incomplete" regions - fusions of located parts that lack internal metric structure.

### 2.1 The Incomplete Region Problem

**Problem**: A fusion of located parts r = fusion{a, b, c} might NOT contain the distance witnesses dist(a,n,b), dist(b,m,c), dist(a,k,c). Such r has shape but no internal metric structure.

**Example**: If a, b, c are point-located states with known locations, their fusion r = a . b . c is a region with located parts. But r might not "know" the distances between a, b, and c.

**Solution**: Require regions to be **spatially complete**.

### 2.2 Spatial Completeness Definition

**Definition (Spatially Complete)**: A state r is **spatially complete** if:
```
G_r is total on Loc(r) x Loc(r)
```

where G_r(a, b) is the internal distance function on r, defined by:
```
G_r(a, b) = inf{n : dist(a, n, b) parthood r}
```

**Intuition**: r is spatially complete if it "knows" the distance between any two of its located parts.

### 2.3 SCPR (Spatially Complete Possible Regions)

**Definition (SCPR)**: A state r is a **spatially complete possible region** if:
1. r in P (possible)
2. G_r is total on Loc(r) x Loc(r) (spatially complete)
3. Loc(r) is non-empty (has located parts)

**Notation**:
```
SCPR = {r in P : r spatially complete, Loc(r) non-empty}
```

**Why each condition**:
- **r in P**: Regions must be possible (consistent)
- **G_r total**: Prevents incomplete regions
- **Loc(r) non-empty**: Excludes the null state (unlocated by L2)

### 2.4 Properties of SCPR

| Property | Status | Notes |
|----------|--------|-------|
| Contains all point-located states | Yes | For a in Located, dist(a,0,a) in SCPR |
| Closed under parthood | Conditional | Smaller states must inherit completeness |
| Closed under compatible fusion | Conditional | Fusion must remain spatially complete |
| Forms a frame | No | Meet-closure still fails |

---

## 3. Metric Topology

The metric topology on SCPR is generated by spatially complete n-balls, providing a finer topology than Scott.

### 3.1 Diameter Definition

**Definition**: For spatially complete r with non-empty Loc(r):
```
diam(r) = sup{G_r(a,b) : a, b in Loc(r)}
```

For r with empty Loc(r) (unlocated states): diam(r) = 0.

**Properties**:
- diam(r) >= 0 for all r in SCPR
- diam(r) = 0 iff r has at most one located part
- diam(r . s) >= max(diam(r), diam(s)) for compatible r, s

### 3.2 Spatially Complete n-Balls (SCB_n)

**Definition (SCB_n)**: For a in Located and n >= 0 in Q:
```
SCB_n(a) = {r in SCPR : a in Loc(r), diam(r) <= 2n}
```

**Why 2n?**: If a is in the ball and every other point is within distance n of a, the furthest points are at most 2n apart (by triangle inequality from A4).

**Properties**:
- SCB_n(a) is non-empty (contains at least the single point state at a)
- SCB_n(a) subset SCB_m(a) when n <= m (larger balls contain smaller)
- intersection_i SCB_{n_i}(a_i) contains all r with each a_i in Loc(r) and diam(r) <= 2 * min(n_i)

### 3.3 Topology Generation (Subbasis)

**Definition**: The **metric topology** T_metric on SCPR is generated by {SCB_n(a) : a in Located, n >= 0} as a **subbasis**.

**Explicit construction**:
- **Subbasis**: The collection {SCB_n(a) : a in Located, n >= 0}
- **Basis**: All finite intersections of spatially complete n-balls
- **Opens**: All arbitrary unions of basis elements

| Concept | Definition | Example |
|---------|------------|---------|
| **Subbasis** | Collection S such that finite intersections form a basis | {SCB_n(a)} |
| **Basis** | Collection B such that every open = union of basis elements | SCB_n(a) inter SCB_m(b) |
| **Generated topology** | Smallest topology containing S | T_metric |

**Key insight**: The metric topology is finer than Scott on SCPR - it makes more distinctions based on metric properties.

---

## 4. Topology Relationships

This section documents how the various topological approaches relate to each other.

### 4.1 Refinement Definition

**Definition**: A topology T1 **refines** (is finer than) T2 if T2 subset T1 (every T2-open is T1-open).

**Notation**: T1 >= T2 means T1 refines T2.

**Intuition**: A finer topology makes more distinctions - it has more open sets, so it can tell more points apart.

### 4.2 Metric Topology Refines Scott

**Theorem (Expected)**: T_metric refines the Scott topology on (P, parthood) restricted to SCPR.

**Sketch**: Every Scott-open set U satisfies:
- U is an upper set
- U is inaccessible by directed suprema

The SCB_n(a) balls generate opens that satisfy upper set properties. The directed supremum condition requires analysis of how spatial completeness interacts with directed limits.

**Implication**: Any statement provable using Scott-open sets can also be proven using metric-open sets, but the converse is not true.

### 4.3 Comparison of Topological Approaches

| Approach | Primitives | Possibility | Completeness | Forms Topology | Metric Info |
|----------|-----------|-------------|--------------|----------------|-------------|
| Scott on S | Order only | N/A | N/A | Yes (coarse) | No |
| n-Balls (T3 original) | Loc, dist, P | Included | Not required | Yes | Yes |
| Regions | Loc, fusion | Not required | Not required | No (meets fail) | No |
| Possible Regions | Loc, fusion, P | Required | Not required | No (meets fail) | No |
| **SC Balls (recommended)** | Loc, dist, P, SC | Built-in | Built-in | Yes | Yes |

**Legend**:
- **Scott on S**: The Scott topology on the full state space
- **n-Balls**: The original T3 definition using open n-balls
- **Regions**: Fusions of located parts (not requiring possibility)
- **Possible Regions**: Fusions of located parts that are possible
- **SC Balls**: Spatially complete n-balls (SCPR-based) - the recommended approach

### 4.4 Why Regions Don't Form a Frame

**Problem**: The meet of two regions may not be a region.

**Example**: If r1 = fusion{a, b} and r2 = fusion{b, c} where a, b, c are distinct, then r1 meet r2 in S might be the null state or a state with "extra" content that isn't a fusion of located parts.

**Frame requirements and status**:

| Requirement | Status | Explanation |
|-------------|--------|-------------|
| Closure under arbitrary joins | YES | Fusion of union works |
| Closure under finite meets | NO | Meet may not be a region |
| Infinite distributivity | FAILS | Depends on meet-closure |

**Consequence**: Regions (and possible regions, and even SCPR) do not form a frame. This means standard locale-theoretic techniques do not apply directly.

---

## 5. Key Principles

### 5.1 Possibility Equivalence Principle

**Statement**: "r parthood s for some s in P" is equivalent to "r in P".

**Proof**:
- (=>) If r parthood s for some s in P, then by P3 (downward persistence), r in P
- (<=) If r in P, then r parthood r and r in P

**Usage**: Always write "r in P" directly. The awkward phrasing "r parthood s for some s in P" is logically equivalent and should be simplified.

**Application**: When defining membership in SCPR, we can simply say "r in P" rather than requiring r to be a part of some possible state.

### 5.2 Notation Conventions

| Object | Convention | Examples |
|--------|------------|----------|
| States | Lowercase | s, r, t, u |
| Sets of states | Uppercase | S, P, Located, SCPR |
| Located parts | Lowercase | a, b, c |
| Distances | n, m, k | dist(a, n, b) |

**Cross-reference**: See `spatial-domain.md` for the full variable naming conventions, including the distinction between distances (n, m, k) and durations (x, y, z).

### 5.3 Hierarchy Diagram

```
S (all states)
  |
  +-- P (possible states) - Scott-closed in S (by T2)
        |
        +-- SCPR (spatially complete possible regions)
              |
              +-- SCB_n(a) (spatially complete n-balls around a)
```

### 5.4 Mathlib/Lean Connections

#### Types

| Concept | Mathlib Name | Location |
|---------|--------------|----------|
| Scott topology | `Topology.scott` | Mathlib/Topology/Order/ScottTopology.lean |
| Directed supremum inaccessibility | `DirSupInacc` | Mathlib/Topology/Order/ScottTopology.lean |
| Directed supremum closure | `DirSupClosed` | Mathlib/Topology/Order/ScottTopology.lean |
| Upper set | `IsUpperSet` | Mathlib/Order/UpperLower/Basic.lean |
| Lower set | `IsLowerSet` | Mathlib/Order/UpperLower/Basic.lean |
| Complete lattice | `CompleteLattice` | Mathlib/Order/CompleteLattice.lean |
| dcpo | Various | Mathlib/Topology/Order/Basic.lean |

#### Key Lemmas

```lean
-- Complement relationships
lemma dirSupInacc_compl : DirSupInacc s^c <-> DirSupClosed s
lemma dirSupClosed_compl : DirSupClosed s^c <-> DirSupInacc s

-- Upper/lower set properties
lemma IsUpperSet.dirSupClosed (hs : IsUpperSet s) : DirSupClosed s
lemma IsLowerSet.dirSupInacc (hs : IsLowerSet s) : DirSupInacc s

-- Complete lattice is dcpo
-- (implicit: any complete lattice is a dcpo)
```

### 5.5 Key Axiom Connections

| Axiom | Role in Topology |
|-------|------------------|
| P3 (downward persistence) | Lower set property for Scott-closed P |
| T2 (P is Scott-closed) | P closed under directed suprema |
| T3 (metric topology) | SCB_n generate topology refining Scott |
| A4 (triangle inequality) | Diameter bound (2n) is valid |

---

## Related Files

- [mereology-foundations.md](mereology-foundations.md) - Complete lattice structure, parthood axioms, null/full states
- [spatial-domain.md](spatial-domain.md) - Variable naming conventions, enriched category perspective, presentation policy
- [kripke-semantics-overview.md](kripke-semantics-overview.md) - Modal semantics comparison
- [bilateral-semantics.md](bilateral-semantics.md) - Exact truthmaker semantics

## References

- Task 69 research reports (specs/069_define_and_motivate_scott_topology_on_state_space/)
- Mathlib/Topology/Order/ScottTopology.lean (Mathlib 4)
- Abramsky & Jung, "Domain Theory" - Standard reference for Scott topology
- Fine, K. - Truthmaker Semantics series (state space foundations)
