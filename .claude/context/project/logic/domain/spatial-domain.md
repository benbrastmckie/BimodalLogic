# Spatial Domain Context

> **Scope**: Conventions and terminology for the spatial reasoning chapter (06-Spatial.tex).
> **Current as of**: 2026-02-20
> **Source**: NOTE: tags in `latex/subfiles/06-Spatial.tex`

## Purpose

This file documents domain-specific conventions for the spatial reasoning chapter of the Logos theory. These conventions may differ from general Logos conventions and are scoped to spatial/mereological contexts.

## Variable Naming Conventions

### Distance vs Duration Variables

In the spatial domain, use distinct variable families to distinguish distances from durations:

| Domain | Variables | Usage |
|--------|-----------|-------|
| **Distances** | `n`, `m`, `k` | Spatial distances between point-located states |
| **Durations** | `x`, `y`, `z` | Time durations (reserved for temporal contexts) |

**Rationale**: Using `n`, `m`, `k` for distances prevents confusion with duration variables `x`, `y`, `z` used elsewhere in Logos for temporal reasoning. This convention enables clear identification of spatial vs temporal quantities in formulas.

**Cross-reference**: See `standards/notation-standards.md` for the general variable naming convention where `t`, `s`, `x`, `y`, `z` are designated for times/durations.

## Macro Usage

### Null State Notation

In spatial contexts, use `\nullstate` instead of `\bot` for the mereological null state:

| Macro | Renders As | Usage |
|-------|------------|-------|
| `\nullstate` | square | Mereological null state (empty state with no parts) |
| `\bot` | falsum | Logical falsity in propositional logic |

**Rationale**: The null state in mereology is conceptually distinct from logical falsity. While both serve as "bottom" elements in their respective lattices, using distinct notation clarifies the intended interpretation:
- `\bot` = the proposition that is always false
- `\nullstate` = the state with no proper parts (mereological empty state)

**LaTeX definition**: The macro is defined in `latex/assets/logos-notation.sty` (line 145):
```latex
\newcommand{\nullstate}{\square}
```

## Terminology Glossary

### State Classification by Location

The spatial chapter uses the following terms to classify states by their locational properties:

| Term | Definition |
|------|------------|
| **Metric state** | A state whose only located parts are exactly two point-located states at a certain distance from each other |
| **Located state** | A point-located state (shorthand for "point-located state") |
| **Unlocated state** | A state with no spatial location whatsoever |
| **Extended state** | A state with distinct located parts (may also have unlocated parts) |

**Hierarchy**: Every state is either unlocated or has located parts. States with located parts are either point-located (a single point location) or extended (multiple distinct located parts).

## Region Structure

### Definition of Regions

A **region** is a mereological fusion of point-located states:

| Notation | Definition | Description |
|----------|------------|-------------|
| Region(L) | fusion{a in L : a point-located} | Region formed by locations in L |
| Located | {a : dist(a,0,a) in P} | Set of all point-located states |

Not every state is a region. A region arises specifically from fusing located parts. States with unlocated components are not regions in this sense.

### Empty Region Semantics

The empty region is the fusion of no locations:

```
Region(empty) = fusion(empty) = null (null state)
```

**Algebraic vs. Geometric Interpretation**:

| Property | Null State |
|----------|------------|
| Algebraic status | Bottom element, legitimate region |
| Located parts | None |
| Geometric meaning | "Nowhere"--no spatial content |

**Pointfree Topology Parallel**: In frame/locale theory, the empty open set is a legitimate frame element representing "nowhere." Similarly, the null state is a legitimate region element representing spatial absence. This resolves the classical mereological controversy over null elements: the null state represents the absence of spatial content rather than "a part contained in everything."

Cross-reference: See mereology-foundations.md Section "The Null Element" for the general mereological status discussion.

### Lattice Operations on Regions

Regions form a structure under parthood with the following operations:

| Operation | Formula | Result |
|-----------|---------|--------|
| Bottom | Region(empty) | Null state |
| Top | Region(Located) | Fusion of all located states |
| Join | Region(L1) join Region(L2) | Region(L1 union L2) |
| Meet | Via state space | May not be a region |

**Caveat**: The meet of two regions may not itself be a region. The region structure is therefore NOT a frame. See topological-foundations-domain.md for details on meet-closure failure.

## Presentation Policy

### Definition Elaboration Requirements

For the spatial reasoning chapter, formal definitions follow a stricter presentation standard:

1. **Elaboration**: No formal statement should be given without carefully elaborating the definitions used
2. **Motivation**: Definitions must be accompanied by explanation of their motivation and guiding intuitions
3. **Functional role**: Each definition should clarify its functional role in the theory
4. **Just-in-time introduction**: Definitions should be introduced immediately before their first use
5. **Cross-referencing**: Already-introduced definitions should be referenced, not re-stated

**Rationale**: This presentation policy ensures the spatial chapter remains accessible by providing readers with necessary conceptual scaffolding before encountering formal machinery.

**Scope note**: This policy is specific to the spatial chapter and may be more stringent than other chapters require.

## Enriched Category Perspective

This section documents the enriched category theory foundation for spatial profiles, enabling systematic treatment of composition and triangle-inequality-based reasoning.

### Lawvere's Metric Space Insight

A metric space is equivalently a category enriched over the monoidal poset `([0, infinity], >=, +, 0)`:

- **Objects**: Points of the metric space
- **Hom-object** `d(a,b)`: The distance from `a` to `b` (an element of `[0, infinity]`)
- **Composition law**: `d(a,b) + d(b,c) >= d(a,c)` (the triangle inequality)
- **Identity**: `0 >= d(a,a)` (distance from a point to itself is zero)

**Key insight**: The triangle inequality `d(a,b) + d(b,c) >= d(a,c)` is exactly the composition law in enriched category theory. This transforms metric concepts into categorical ones:

| Metric concept | Enriched category concept |
|----------------|---------------------------|
| Metric space | Enriched category |
| Distance function | Hom-object |
| Triangle inequality | Composition law |
| Spatial profile | Profunctor (bimodule) |

### Bimodule Axiom Forms

For a spatial profile `delta` from body `s` to body `t` (a D-bimodule from enriched category `Loc(s)` to enriched category `Loc(t)`), the coherence conditions are:

**Left action coherence**:
```
delta(a', b) <= g_s(a', a) + delta(a, b)
```
where `g_s` is the metric on source body `s`. Moving to a nearby source point `a'` increases distance by at most `g_s(a', a)`.

**Right action coherence**:
```
delta(a, b') <= delta(a, b) + g_t(b, b')
```
where `g_t` is the metric on target body `t`. Moving to a nearby target point `b'` increases distance by at most `g_t(b, b')`.

**Purpose**: These axioms ensure profiles compose associatively. They express that spatial profiles respect the metric structure of both source and target bodies.

### Inf-Convolution Composition Formula

The composition of spatial profiles `epsilon: t -> u` and `delta: s -> t` is:

```
(epsilon . delta)(a, c) = inf_{b in Loc(t)} {delta(a, b) + epsilon(b, c)}
```

This is the **inf-convolution** formula from convex analysis. It arises as the specialization of the profunctor composition formula (coend) to metric-like structures:

- The "integral" (coend) becomes an infimum over the indexing set
- The tensor product in `D = ([0, infinity], >=, +, 0)` is ordinary addition

**Intuition**: To get from `a` in body `s` to `c` in body `u` via body `t`, take the best possible intermediate point `b`.

### Key References

- Lawvere, F.W. (1973). "Metric spaces, generalized logic, and closed categories." Reprints in TAC 1 (2002).
- nLab: [Lawvere metric space](https://ncatlab.org/nlab/show/Lawvere+metric+space)
- nLab: [profunctor](https://ncatlab.org/nlab/show/profunctor)

## Derivability Patterns

This section documents the key principles and derivation sketches that establish which spatial axioms are derivable from more fundamental principles. For full formal derivations, see `latex/subfiles/06-Spatial.tex` lines 528-591.

### Location Necessity Principle

The Location Necessity principle is a modal-spatial bridge principle connecting metric states to the necessity operator.

**Statement**: If a metric state `dist(a, n, b)` is part of some possible state `s` in `P`, then `dist(a, 0, a)` is necessary (compatible with every possible state).

**Formal Notation**:
```
(exists s in P. dist(a, n, b) parthood s) implies (forall t in P. dist(a, 0, a) compatible t)
```

**Justification**: If `a` appears as a relatum in any possible metric state, then `a` must be located. Being located means `dist(a, 0, a) in P`. Moreover, the location of `a` should be a stable fact--it does not conflict with any other possible configuration. This captures the intuition that location is not merely a contingent fact but a persistent feature of the spatial structure.

**Mathematical Significance**: This principle connects the metric primitive (`dist`) to the modal primitive (necessity). It asserts that spatial facts about location propagate through the space of possibilities in a coherent way. Location Necessity enables the derivability of axioms L2, R2, and R3 from more fundamental principles.

### Axiom Derivability Summary

The spatial axioms have different derivability statuses. Some are design choices (primitive axioms), while others are derivable from more fundamental principles.

| Axiom | Name | Status | Key Dependencies |
|-------|------|--------|------------------|
| **L1** | Located states compact | Design choice | (not derivable) |
| **L2** | Null state non-location | Derivable | Location Necessity, Uniqueness |
| **L3** | Separation | Design choice | (not derivable) |
| **R1** | Distance completion | Natural | A4 (triangle inequality) |
| **R2** | Distance inheritance | Derivable | Location Necessity, S3 |
| **R3** | Compatible distances complete | Derivable | A4, compatibility closure |
| **R5** | Profile triangle inequality | Derivable | A4 (direct consequence) |

**Design choices** (L1, L3) are primitive axioms that define the character of the spatial structure. They cannot be derived but are justified by their role in the theory.

**Derivable axioms** (L2, R2, R3, R5) follow from Location Necessity and other fundamental principles. Their derivability confirms that the axiom system is coherent.

### Derivation Sketches

The following sketches outline the derivations for axioms L2, R2, and R3. For complete formal derivations, see `latex/subfiles/06-Spatial.tex` lines 554-590.

#### L2: Null State Non-Location

**Axiom**: The null state has no location: `nullstate not in Located`

**Derivation Sketch**:

1. **Assume for contradiction**: The null state is located, i.e., `dist(nullstate, 0, nullstate) in P`

2. **Null state parthood**: By definition, `nullstate parthood a` for every state `a`

3. **Consider distinct located states**: Let `a` and `b` be distinct located states at different locations with `dist(a, n, b) in P` for `n > 0`

4. **Apply Location Necessity**: If nullstate were located, by Location Necessity it would need to be compatible with both `a`'s location and `b`'s location

5. **Uniqueness contradiction**: But no possible state is point-located at more than one place (uniqueness of location)

6. **Conclusion**: Therefore, nullstate cannot be located. QED.

**Key Premises**:
- Location Necessity principle
- Uniqueness of location (no state is point-located at multiple places)
- Existence of at least two distinct located states at different positions

#### R2: Distance Inheritance

**Axiom**: If `s in P`, `dist(a, n, b) parthood s`, `a' parthood a` with `a'` located, `b' parthood b` with `b'` located, then `dist(a', n, b') parthood s`

**Derivation Sketch**:

1. **Given**: `dist(a, n, b) parthood s` with `s in P`

2. **Apply Location Necessity**: Since `dist(a, n, b) parthood s` with `s in P`, both `dist(a, 0, a)` and `dist(b, 0, b)` are necessary

3. **Located parts**: Since `a' parthood a` and `a'` is located, `dist(a', 0, a') in P`

4. **Apply S3 (Monotonicity)**: Since `a' parthood a` and `b' parthood b`, by S3: `dist(a', n, b') parthood dist(a, n, b)`

5. **Transitivity of parthood**: Since `dist(a', n, b') parthood dist(a, n, b) parthood s`, we have `dist(a', n, b') parthood s`. QED.

**Key Premises**:
- Location Necessity principle
- S3 (Monotonicity axiom): If `a parthood a'` and `b parthood b'`, then `dist(a, n, b) parthood dist(a', n, b')`

#### R3: Compatible Distances Complete

**Axiom**: If `dist(a, n, b) compatible dist(b, m, c)`, then there exists `k` in `Q` such that all three metric states are pairwise compatible

**Derivation Sketch**:

1. **Given**: `dist(a, n, b) compatible dist(b, m, c)`

2. **Witness state**: There exists `s in P` with both `dist(a, n, b) parthood s` and `dist(b, m, c) parthood s`

3. **Triangle inequality constraint**: By A4, if all three metric states are parts of `s`, the distances must satisfy `|n - m| <= k <= n + m` for any valid `k`

4. **Existence of third metric state**: Taking `k = n + m` (or any valid `k` in `[|n-m|, n+m]`), the metric state `dist(a, k, c)` exists by the structure of the dist function

5. **Compatibility requirement**: Need to show `dist(a, k, c) compatible s` (and hence with both original metric states)

6. **Conclusion**: By the structure of metric states and S2 (minimality), this compatibility follows. QED.

**Key Premises**:
- A4 (Triangle inequality): For any `s in P` with three metric states as parts, the distances satisfy the triangle inequality
- Compatibility closure property of the state space
- S2 (Minimality): Metric states add no extraneous information

---

**Cross-reference**: For full formal derivations with complete details, see `latex/subfiles/06-Spatial.tex` lines 528-591.

## Related Files

- `standards/notation-standards.md` - General notation conventions
- `domain/kripke-semantics-overview.md` - Modal logic semantics
- `domain/mereology-foundations.md` - Mereological theory (null element discussion)
- `domain/topological-foundations-domain.md` - Topological structure (meet-closure details)
- `latex/assets/logos-notation.sty` - LaTeX macro definitions
