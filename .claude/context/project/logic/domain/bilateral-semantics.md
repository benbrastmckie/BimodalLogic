# Bilateral Truthmaker Semantics

> **Scope**: Exact truthmaker semantics (bilateral semantics) as used in the Logos constitutive foundation.
> **Current as of**: 2026-02-21
> **Source**: Research task 48, primary sources (IdentityAboutness.tex, counterfactual_worlds.tex)

## Overview

**Bilateral truthmaker semantics** (also called **exact truthmaker semantics**) is a hyperintensional semantic framework that evaluates sentences relative to states rather than possible worlds. Unlike possible worlds semantics where propositions are sets of worlds, bilateral semantics treats propositions as pairs of **verifier** and **falsifier** state sets.

**Key Innovation**: Verification and falsification are treated as equally fundamental, independent semantic relations. A state that verifies $A$ must be "wholly relevant" to $A$---it cannot contain irrelevant parts.

### Primary Sources

- **Fine, K. (2016)** - "Angellic Content"
- **Fine, K. (2017)** - "A Theory of Truthmaker Content I & II"
- **Fine, K. (2017a)** - "Truthmaker Semantics"
- **Fine, K. (2017d)** - Modalized state spaces

---

## Core Concepts

### Exact Verification and Falsification

The bilateral framework distinguishes two fundamental semantic relations:

| Relation | Symbol | Notation | Meaning |
|----------|--------|----------|---------|
| Exact Verification | $\Vdash$ | $\mathcal{M}, s \Vdash A$ | State $s$ exactly verifies sentence $A$ |
| Exact Falsification | $\dashV$ | $\mathcal{M}, s \dashV A$ | State $s$ exactly falsifies sentence $A$ |

**Exactness Constraint**: States must be "wholly relevant" to the sentences they verify or falsify. A verifier cannot contain any parts that are irrelevant to the verified sentence.

### Non-Monotonicity

Unlike classical semantics, exact verification is **non-monotonic**: extending a verifier with additional material may lose relevance.

**Example** (from IdentityAboutness.tex):
- Let $t$ = the state of Julieta thinking
- Let $d$ = the state of Julieta writing
- $t$ exactly verifies "Julieta is thinking"
- $t.d$ (the fusion of $t$ and $d$) **fails** to exactly verify "Julieta is thinking" because $d$ is irrelevant
- But $t.d$ exactly verifies "Julieta is thinking and writing"

### Inclusive Semantics (Semantic Clauses)

The **inclusive** (or **convex**) semantics extends exact verification to allow fusions of verifiers to count as verifiers. This is the standard interpretation used in Logos.

| Connective | Verification | Falsification |
|------------|--------------|---------------|
| Atomic $p$ | $s \in \|p\|^+$ | $s \in \|p\|^-$ |
| Negation $\neg A$ | $\mathcal{M}, s \dashV A$ | $\mathcal{M}, s \Vdash A$ |
| Conjunction $A \wedge B$ | $s = t.d$ where $t \Vdash A$ and $d \Vdash B$ | $s \dashV A$ or $s \dashV B$ or $s \dashV A \vee B$ |
| Disjunction $A \vee B$ | $s \Vdash A$ or $s \Vdash B$ or $s \Vdash A \wedge B$ | $s = t.d$ where $t \dashV A$ and $d \dashV B$ |

**Key Features**:
- Negation swaps verification and falsification
- Conjunction verification requires fusion of component verifiers
- Disjunction falsification requires fusion of component falsifiers
- The inclusive semantics allows conjunctions to verify disjunctions (convexity)

---

## State Space Structure

### Definition

A **state space** $\mathcal{S} = \langle S, \sqsubseteq \rangle$ is a complete lattice where:
- $S$ is the set of **states**
- $\sqsubseteq$ is the **parthood relation** (a partial order)

**See also**: [mereology-foundations.md](mereology-foundations.md) for detailed treatment of state space mereology.

### Key Elements

| Element | Symbol | Definition | Properties |
|---------|--------|------------|------------|
| Parthood | $\sqsubseteq$ | Primitive partial order | Reflexive, antisymmetric, transitive |
| Fusion | $\bigsqcup X$ | Least upper bound of $X$ | Unique for any $X \subseteq S$ |
| Binary fusion | $s.t$ | $\bigsqcup\{s, t\}$ | Commutative, associative |
| Null state | $\square$ | $\bigsqcup \varnothing$ | Bottom element (fusion of empty set) |
| Full state | $\sqbullet$ | $\bigsqcup S$ | Top element (fusion of all states) |

### Modalized State Spaces

A **modalized state space** extends state spaces with possibility:

$$\mathcal{S}^\Diamond = \langle S, P, \sqsubseteq \rangle$$

where:
- $P \subseteq S$ is the set of **possible states**
- **Nonempty**: $P \neq \varnothing$
- **Possibility Downward Closure**: If $s \in P$ and $t \sqsubseteq s$, then $t \in P$

### World States

**World states** are maximal compatible possible states:

$$W = \{w \in P \mid \forall s \circ w (s \sqsubseteq w)\}$$

A state $w$ is a world state iff every state compatible with $w$ is already part of $w$.

### Proposition Structure

**Normal Contents**: Sets closed under fusion:
$$\mathcal{C}_\mathcal{S} = \{X \subseteq S : \bigsqcup Y \in X \text{ for all nonempty } Y \subseteq X\}$$

**Normal Propositions**: Pairs of normal contents:
$$\mathcal{P}_\mathcal{S} = \{\langle V, F \rangle : V, F \in \mathcal{C}_\mathcal{S}\}$$

**Bilateral Propositions**: Normal propositions with additional constraints:
- **Exclusive**: States in $V$ are incompatible with states in $F$
- **Exhaustive**: Every possible state is compatible with some state in $V$ or $F$

---

## Hyperintensionality

### Definition

A theory is **hyperintensional** if it distinguishes propositions that are necessarily equivalent but differ in some other respect (e.g., subject-matter, relevance).

### Motivating Examples

1. **$A$ vs. $A \vee (A \wedge B)$**: Same modal profile, different subject-matter
2. **$A \vee \neg A$ vs. $B \vee \neg B$**: Both necessary, different subject-matters
3. **"Hesperus is rising" vs. "Phosphorus is rising"**: Objectively the same, but may differ representationally

### Rejected Boolean Identities

The following classical Boolean identities **fail** in bilateral semantics due to subject-matter differences:

| Principle | Rejected Form | Reason |
|-----------|---------------|--------|
| #Necs | $(A \vee \neg A) \equiv (B \vee \neg B)$ | Different subject-matters |
| #Imps | $(A \wedge \neg A) \equiv (B \wedge \neg B)$ | Different impossible states |
| #Abs1 | $A \equiv A \vee (A \wedge B)$ | Different relevance relations |
| #Abs2 | $A \equiv A \wedge (A \vee B)$ | Different relevance relations |
| #Dist1 | $A \vee (B \wedge C) \equiv (A \vee B) \wedge (A \vee C)$ | Distribution fails for subject-matter |
| #Dist2 | $A \wedge (B \vee C) \equiv (A \wedge B) \vee (A \wedge C)$ | Distribution fails for subject-matter |

### Propositional Identity

In bilateral semantics, **propositional identity** ($A \equiv B$) holds iff $A$ and $B$ have the same verifiers and the same falsifiers:

$$A \equiv B \iff A^+ = B^+ \text{ and } A^- = B^-$$

This is a finer-grained notion than necessary equivalence ($\Box(A \leftrightarrow B)$).

---

## Logic of Ground

### Two Orderings on Propositions

The bilateral framework supports two fundamental partial orderings on propositions, which can come apart (unlike in Boolean logic where they are converses):

#### 1. Conjunctive-Parthood (Essence)

$$A \sqsubseteq B \colonequals A \wedge B \equiv B$$

**Semantic characterization**:
- For every $b \in B^+$ there is $a \in A^+$ with $a \sqsubseteq b$
- $A^- \subseteq B^-$

**Intuition**: $A$ is an "essential part" of $B$---$B$ is constructed by conjoining $A$ with other content.

#### 2. Disjunctive-Parthood (Ground)

$$A \leq B \colonequals A \vee B \equiv B$$

**Semantic characterization**:
- For every $b \in B^-$ there is $a \in A^-$ with $a \sqsubseteq b$
- $A^+ \subseteq B^+$

**Intuition**: $A$ "grounds" $B$---$B$'s truth is ensured by $A$'s truth.

### Separation from Boolean Logic

In Boolean theories, these orderings are converses: $A \sqsubseteq B \Leftrightarrow B \leq A$.

In bilateral semantics, they can separate:
- $A \sqsubseteq A \wedge B$ is valid, but $A \wedge B \leq A$ may fail
- $A \leq A \vee B$ is valid, but $A \vee B \sqsubseteq A$ may fail

### Bilattice Structure

The space of normal propositions $\mathcal{P}_\mathcal{S}$ forms a **non-interlaced bilattice**:

- **Two orderings**: essence ($\sqsubseteq$) and ground ($\leq$)
- Each ordering forms a complete lattice
- Negation exchanges the orderings: $P \sqsubseteq Q \Leftrightarrow \neg P \leq \neg Q$

This bilattice structure provides hyperintensional analogues of Boolean lattice operations.

### Valid Weakenings of Distribution

While distribution fails as an identity ($\equiv$), weaker forms hold as parthood relations:

| Principle | Form | Interpretation |
|-----------|------|----------------|
| A11 | $A \vee (B \wedge C) \leq (A \vee B) \wedge (A \vee C)$ | Ground-parthood |
| A12 | $A \vee (B \wedge C) \sqsubseteq (A \vee B) \wedge (A \vee C)$ | Essence-parthood |
| A13 | $A \wedge (B \vee C) \leq (A \wedge B) \vee (A \wedge C)$ | Ground-parthood |
| A14 | $A \wedge (B \vee C) \sqsubseteq (A \wedge B) \vee (A \wedge C)$ | Essence-parthood |

---

## Relationship to Possible Worlds Semantics

### Key Distinctions

| Aspect | Possible Worlds | Bilateral Semantics |
|--------|-----------------|---------------------|
| Basic entities | Possible worlds (points) | States (structured, with parts) |
| Propositions | Sets of worlds | Pairs of verifier/falsifier sets |
| Truth at world | $w \in \|A\|$ | $\exists s \sqsubseteq w : s \Vdash A$ |
| Falsity at world | $w \notin \|A\|$ | $\exists s \sqsubseteq w : s \dashV A$ |
| Hyperintensional | No | Yes |
| Subject-matter | Lost | Preserved |

### Deriving Worlds from States

In the Logos approach (counterfactual_worlds.tex), possible worlds are **constructed** from the state space:

1. **States** form a complete lattice $\langle S, \sqsubseteq \rangle$
2. **Task relation** $s \to t$ encodes possible transitions
3. **Possible states** are defined via connectivity: $P = \{s \in S \mid \exists t(s \sim t)\}$
4. **World states** are maximal compatible possible states: $W = \{w \in P \mid \forall s \circ w (s \sqsubseteq w)\}$
5. **World histories** are functions $\alpha: T \to W$ respecting the task relation: $\alpha(x) \to \alpha(x+1)$

### Truth at World-Time Pairs

A sentence is **true at a world-time pair** $(w, t)$ iff there exists a part of the world state at that time which exactly verifies the sentence:

$$w, t \models A \iff \exists s \sqsubseteq w_t : s \Vdash A$$

**See also**: [task-semantics.md](task-semantics.md) for the full temporal semantics.

### Recovering Modal Logic

Standard modal operators can be defined:
- $\Box A$ is true at $w$ iff $A$ is true at all accessible worlds
- $\Diamond A$ is true at $w$ iff $A$ is true at some accessible world

The bilateral framework enriches this by preserving subject-matter information that possible worlds semantics loses.

---

## Notation Conventions

| Symbol | Meaning | LaTeX |
|--------|---------|-------|
| $\sqsubseteq$ | Parthood (states) or essence-parthood (propositions) | `\sqsubseteq` |
| $\bigsqcup$ | Fusion (least upper bound) | `\bigsqcup` |
| $\Vdash$ | Exact verification | `\Vdash` |
| $\dashV$ | Exact falsification | `\dashV` |
| $\square$ | Null state | `\square` |
| $\sqbullet$ | Full state | `\sqbullet` |
| $\equiv$ | Propositional identity | `\equiv` |
| $\leq$ | Disjunctive-parthood (ground) | `\leq` |
| $\circ$ | Overlap/compatibility | `\circ` |
| $.$ | Binary fusion | dot notation |

---

## Key References

### Primary Sources (Fine)

1. **Fine, K. (2016)** - "Angellic Content" - State semantics for analytic equivalence
2. **Fine, K. (2017)** - "A Theory of Truthmaker Content I" - Normal propositions
3. **Fine, K. (2017)** - "A Theory of Truthmaker Content II" - Bilattice structure
4. **Fine, K. (2017a)** - "Truthmaker Semantics" - Modalized state spaces
5. **Fine, K. (2012a, 2012b)** - Imposition semantics for counterfactuals

### Bilattice Theory

6. **Ginsberg, M. (1988, 1990)** - Bilattice foundations
7. **Fitting, M. (1989-2002)** - Distributive bilattice studies

### Logos Implementation

8. `latex/subfiles/02-ConstitutiveFoundation.tex` - Constitutive chapter
9. `IdentityAboutness.tex` - Subject-matter and hyperintensionality paper
10. `counterfactual_worlds.tex` - Task-based construction of worlds

---

## Related Files

- [mereology-foundations.md](mereology-foundations.md) - State space mereology, parthood, fusion
- [task-semantics.md](task-semantics.md) - Task-based temporal semantics using state spaces
- [kripke-semantics-overview.md](kripke-semantics-overview.md) - Comparison point for modal semantics
- [counterfactual-semantics.md](counterfactual-semantics.md) - Imposition and counterfactual evaluation
- `latex/subfiles/02-ConstitutiveFoundation.tex` - Logos constitutive chapter
