# Mereology Foundations

> **Scope**: Mathematical foundations of mereology and its connection to lattice theory as used in the Logos constitutive foundation.
> **Current as of**: 2026-02-21
> **Source**: Research task 47, primary sources (IdentityAboutness.tex, counterfactual_worlds.tex)

## Quick Reference

### Core Relations

| Relation | Symbol | Definition | Intuition |
|----------|--------|------------|-----------|
| Parthood | $\sqsubseteq$ | Primitive partial order | $s$ is part of $t$ |
| Proper parthood | $\sqsubset$ | $s \sqsubset t \iff s \sqsubseteq t \land t \not\sqsubseteq s$ | $s$ is a proper part of $t$ |
| Fusion | $\bigsqcup X$ | Least upper bound of $X$ | Combined state of all states in $X$ |
| Binary fusion | $s.t$ | $\bigsqcup\{s, t\}$ | State where both $s$ and $t$ obtain |
| Overlap | $s \circ t$ | $\exists z(z \sqsubseteq s \land z \sqsubseteq t)$ | $s$ and $t$ share at least one part |
| Disjointness | $D(s, t)$ | $\neg(s \circ t)$ | $s$ and $t$ share no parts |
| Compatibility | $s \circ t$ | $s.t \in P$ (fusion is possible) | $s$ and $t$ can co-obtain |

### Core Axioms (Theory M)

| Axiom | Name | Formula | Description |
|-------|------|---------|-------------|
| P.1 | Reflexivity | $\forall x. Pxx$ | Everything is part of itself |
| P.2 | Antisymmetry | $(Pxy \land Pyx) \to x = y$ | Mutual parthood implies identity |
| P.3 | Transitivity | $(Pxy \land Pyz) \to Pxz$ | Parts of parts are parts |

### Supplementation Principles

| Principle | Formula | Description |
|-----------|---------|-------------|
| Weak (P.4) | $PPxy \to \exists z(Pzy \land \neg Ozx)$ | Proper parts leave remainders |
| Strong (P.5) | $\neg Pyx \to \exists z(Pzy \land \neg Ozx)$ | Non-parts have disjoint witnesses |

---

## State Spaces in Logos

### Definition

From the primary sources (IdentityAboutness.tex, counterfactual_worlds.tex):

> "I will follow Fine in taking a *state space* $\mathcal{S} = \langle S, \sqsubseteq \rangle$ to be any complete lattice where $S$ is the set of *states* and $\sqsubseteq$ is the *parthood relation*."

A **state space** is defined as a complete lattice, which ensures:
- Every subset $X \subseteq S$ has a least upper bound (fusion)
- Unrestricted Composition holds by construction
- Fusion is unique (standard lattice theory)

### Key Elements

| Element | Symbol | Definition | Properties |
|---------|--------|------------|------------|
| Null state | $\square$ | $\bigsqcup\varnothing$ | Bottom element, fusion of empty set |
| Full state | $\sqbullet$ | $\bigsqcup S$ | Top element, fusion of all states |

**Null state semantics**: Since a fusion obtains just in case all of its parts obtain, nothing is required for $\square$ to obtain, and so $\square$ obtains trivially and of necessity.

---

## General Extensional Mereology (GEM)

### Unrestricted Composition

The defining principle of GEM:

> For any non-empty collection of entities, there exists a fusion (sum) of those entities.

**Formal statement** (Fusion Axiom Schema):
$$\exists x\phi(x) \to \exists z \forall y(Oyz \leftrightarrow \exists x(\phi(x) \land Oyx))$$

For any satisfiable condition $\phi$, there exists a fusion of all things satisfying $\phi$.

### Logos Approach

The primary sources achieve Unrestricted Composition by requiring state spaces to be complete lattices directly, which guarantees least upper bounds for *all* subsets, including infinite ones.

---

## Connection to Boolean Algebra

### Tarski's Result (1935)

> The parthood relation axiomatized by GEM has the same properties as the set-inclusion relation restricted to non-empty subsets of a set---i.e., **a complete Boolean algebra with the zero element removed**.

This means GEM state spaces are isomorphic to:
- Complete Boolean algebras minus bottom
- Parthood ($\sqsubseteq$) corresponds to subset ($\subseteq$)
- Fusion ($\bigsqcup$) corresponds to union ($\cup$)
- Meet ($\sqcap$) corresponds to intersection ($\cap$)
- Complement exists for each non-null element

### Logos as Complete Lattice

The constitutive foundation (02-ConstitutiveFoundation.tex) explicitly uses complete lattice structure:

```latex
\item $\statespace = \tuple{S, \parthood}$ is a complete lattice of states
```

---

## The Null Element

### Mereological Status

The status of the null element is debated in standard mereology:

**Against** (traditional view):
- Makes everything overlap trivially (null is part of everything)
- Creates a "part of everything" which seems ontologically absurd

**For** (Logos approach):
- Needed for algebraic closure: $\bigsqcup\varnothing$ must exist in a complete lattice
- Provides identity element for fusion: $s.\square = s$
- Represents "nothing obtaining" or "no state of affairs"

### Logos Convention

From spatial-domain.md:

| Macro | Renders As | Usage |
|-------|------------|-------|
| `\nullstate` | $\square$ | Mereological null state (empty state with no parts) |
| `\bot` | $\bot$ | Logical falsity in propositional logic |

**Distinction**: The null state in mereology is conceptually distinct from logical falsity. While both serve as "bottom" elements in their respective lattices, using distinct notation clarifies the intended interpretation.

---

## Atomism and Atomlessness

### Definitions

| Term | Definition | Description |
|------|------------|-------------|
| Atom | $Ax \equiv_{df} \neg\exists y(PPyx)$ | Entity with no proper parts |
| Atomism (P.7) | $\forall x\exists y(Ay \land Pyx)$ | Everything has at least one atomic part |
| Atomlessness (P.8) | $\forall x\exists y(PPyx)$ | Everything has proper parts ("gunky") |

### Logos Position

The primary sources are **neutral** on atomism. State spaces are simply required to be complete lattices, which is compatible with:
- **Atomic** state spaces (finitely generated lattices)
- **Atomless** ("gunky") state spaces (e.g., regions of space-time)
- **Mixed** state spaces (atoms exist but not everything decomposes to them)

This neutrality is appropriate for a general semantic framework.

### Practical Implications

| Scenario | Atomism Status | Notes |
|----------|----------------|-------|
| Finite models | Necessarily atomic | Finite lattices have atoms |
| Completeness proofs | May need atomless models | For theoretical generality |
| Spatial reasoning | Supports both | "Infinite fusions" admitted |

---

## Bilattice Structure

### Extension to Propositions

The primary sources extend the lattice structure to a **bilattice** for propositions:

> "The space of normal propositions $\mathcal{P}_\mathcal{S}$ forms a bilattice, providing hyperintensional analogues of the Boolean lattices familiar from extensional and intensional logics."

The bilattice has:
- **Two orderings**: essence ($\sqsubseteq$) and ground ($\leq$)
- Each ordering forms a complete lattice
- Negation exchanges the orderings: $P \sqsubseteq Q \Leftrightarrow \neg P \leq \neg Q$

**See also**:
- task-semantics.md for bilateral propositions
- `../../math/lattice-theory/bilattice-theory.md` for bilattice algebraic foundations

---

## Key References

### Primary Sources (Logos)

1. **Fine, K. (2016, 2017, 2017a, 2017d)** - "Truthmaker Semantics" series
   - Develops state space semantics and bilateral propositions
   - Introduces modalized state spaces and world spaces

2. **Ginsberg, M. (1988, 1990)** - Bilattice theory
3. **Fitting, M. (1989-2002)** - Distributive bilattice studies

### Standard Mereology

4. **Simons, P. (1987)** - *Parts: A Study in Ontology*
   - Classic systematic treatment of mereological systems

5. **Casati, R. and Varzi, A. (1999)** - *Parts and Places*
   - Comprehensive introduction to mereology and mereotopology

6. **Varzi, A.** - "Mereology" (Stanford Encyclopedia of Philosophy)
   - https://plato.stanford.edu/entries/mereology/

7. **Hovda, P. (2008)** - "What Is Classical Mereology?"
   - Clarifies GEM and Boolean algebra connection

8. **Tarski, A. (1935)** - Boolean algebra correspondence

---

## Related Files

- [bilateral-semantics.md](bilateral-semantics.md) - Exact truthmaker semantics, verifiers/falsifiers, hyperintensionality
- [spatial-domain.md](spatial-domain.md) - Spatial reasoning conventions, null state notation
- [task-semantics.md](task-semantics.md) - Task-based semantics using state spaces
- [kripke-semantics-overview.md](kripke-semantics-overview.md) - Modal semantics comparison
- `latex/subfiles/02-ConstitutiveFoundation.tex` - Logos constitutive chapter
- `latex/subfiles/06-Spatial.tex` - Spatial mereology chapter
