# Bilattice Theory

> **Scope**: Algebraic foundations of bilattice theory relevant to propositional identity in Logos constitutive semantics.
> **Current as of**: 2026-02-21
> **Source**: Research task 49, primary sources (Ginsberg 1988, Fitting 1989-2002, Belnap 1975-1977)

## Purpose

This context file documents the mathematical theory of bilattices as it relates to the Logos constitutive foundation. Bilattices provide the algebraic structure underlying propositional identity, where propositions carry both **essence** (content) and **ground** (support) orderings.

### When to Load

Load this context when:
- Working on propositional identity or hyperintensionality tasks
- Implementing bilattice operations in Lean or other formalizations
- Understanding the algebraic structure of bilateral propositions
- Debugging issues with essence/ground orderings or distribution laws

---

## Quick Reference

### Notation Mapping

| Logos Notation | Ginsberg Notation | Meaning | LaTeX Command |
|----------------|-------------------|---------|---------------|
| $\sqsubseteq$ | $\leq_t$ | Essence/Truth order | `\sqsubseteq` |
| $\leq$ | $\leq_k$ | Ground/Knowledge order | `\leq` |
| $\land$ | $\land_t$ | Conjunction (join in essence order) | `\land` |
| $\lor$ | $\lor_t$ | Disjunction (join in ground order) | `\lor` |
| $\otimes$ | $\land_k$ | Common essence (meet in essence order) | `\otimes` |
| $\oplus$ | $\lor_k$ | Common ground (meet in ground order) | `\oplus` |
| $\neg$ | $\neg$ | Involutive negation | `\neg` |
| $\mathsf{ver}$ | $\top$ | Verum (top of essence) | `\mathsf{ver}` |
| $\mathsf{fal}$ | $\bot$ | Falsum (bottom of essence) | `\mathsf{fal}` |
| $\top_\mathcal{P}$ | $t$ | Top of ground | `\top_\mathcal{P}` |
| $\bot_\mathcal{P}$ | $f$ | Bottom of ground | `\bot_\mathcal{P}` |

### Operations Summary

| Operation | Type | Definition | Bilattice Role |
|-----------|------|------------|----------------|
| $\land$ | Binary | Least upper bound w.r.t. $\sqsubseteq$ | Essence join |
| $\lor$ | Binary | Least upper bound w.r.t. $\leq$ | Ground join |
| $\otimes$ | Binary | Greatest lower bound w.r.t. $\sqsubseteq$ | Essence meet |
| $\oplus$ | Binary | Greatest lower bound w.r.t. $\leq$ | Ground meet |
| $\neg$ | Unary | Swaps verifiers/falsifiers | Involution (exchanges orders) |

### Key Relationships

| Property | Formula | Holds in Logos? |
|----------|---------|-----------------|
| Interlacing | Operations preserve both orders | **No** |
| Distributivity | Full 12-law distribution | **No** |
| Weak distribution | $A \lor (B \land C) \leq (A \lor B) \land (A \lor C)$ | Yes (A11) |
| Negation exchange | $A \sqsubseteq B \Leftrightarrow \neg A \leq \neg B$ | Yes |

---

## Core Definitions

### Definition: Bilattice

A **bilattice** is a structure $B = \langle \mathcal{P}, \sqsubseteq, \leq, \neg \rangle$ satisfying:

1. **Essence lattice**: $\langle \mathcal{P}, \sqsubseteq \rangle$ is a complete lattice
2. **Ground lattice**: $\langle \mathcal{P}, \leq \rangle$ is a complete lattice
3. **Non-triviality**: $|\mathcal{P}| \geq 2$
4. **Involution**: $\neg\neg X = X$ for all $X \in \mathcal{P}$
5. **Negation exchange**: For all $X, Y \in \mathcal{P}$:
   - $X \sqsubseteq Y \Leftrightarrow \neg X \leq \neg Y$
   - $X \leq Y \Leftrightarrow \neg X \sqsubseteq \neg Y$

**Lattice Operations**:

| Order | Meet | Join | Top | Bottom |
|-------|------|------|-----|--------|
| $\sqsubseteq$ (essence) | $\otimes$ | $\land$ | $\mathsf{ver}$ | $\mathsf{fal}$ |
| $\leq$ (ground) | $\oplus$ | $\lor$ | $\top_\mathcal{P}$ | $\bot_\mathcal{P}$ |

**Source**: Ginsberg (1988), adapted to Logos notation in `02-ConstitutiveFoundation.tex` Definition 23.

---

### The FOUR Bilattice

The **FOUR bilattice** (Belnap 1975, 1977) is the canonical example, designed for reasoning with incomplete or conflicting information.

**Elements**:

| Element | Symbol | Interpretation | Verifiers | Falsifiers |
|---------|--------|----------------|-----------|------------|
| True | $t$ | Only truth support | Present | Absent |
| False | $f$ | Only falsity support | Absent | Present |
| Both | $\top$ | Contradictory support | Present | Present |
| Neither | $\bot$ | No information | Absent | Absent |

**Truth Order** ($\leq_t$): Orders by degree of truth

```
       t (true)
      / \
     /   \
    /     \
   bot   top
    \     /
     \   /
      \ /
       f (false)
```

- Bottom: $f$; Top: $t$
- $\bot$ and $\top$ are incomparable

**Knowledge Order** ($\leq_k$): Orders by amount of information

```
      top (both)
      /    \
     /      \
    /        \
   t          f
    \        /
     \      /
      \    /
      bot (neither)
```

- Bottom: $\bot$; Top: $\top$
- $t$ and $f$ are incomparable

**Operations on FOUR**:

| Operation | Truth Order Role | Knowledge Order Role |
|-----------|------------------|---------------------|
| $\neg$ | Swaps $t \leftrightarrow f$; fixes $\top, \bot$ | Preserves order |
| $\land_t$ | Meet in truth order | "Skeptical" |
| $\lor_t$ | Join in truth order | "Credulous" |
| $\land_k$ | Preserves truth order | Meet (consensus) |
| $\lor_k$ | Preserves truth order | Join (gullibility) |

**Product Representation**: FOUR $\cong \mathbf{2} \odot \mathbf{2}$ (Ginsberg-Fitting product of two Boolean algebras).

---

### Interlacing Conditions

A bilattice is **interlaced** iff each lattice operation is order-preserving with respect to **both** orderings.

**Formal Definition**: For all $a, b, c \in \mathcal{P}$ and any lattice operation $\star \in \{\land, \lor, \otimes, \oplus\}$:

- If $a \sqsubseteq b$ then $a \star c \sqsubseteq b \star c$
- If $a \leq b$ then $a \star c \leq b \star c$

**The Eight Interlacing Conditions**:

| # | Condition | Meaning |
|---|-----------|---------|
| 1 | $a \sqsubseteq b \Rightarrow a \land c \sqsubseteq b \land c$ | $\land$ preserves $\sqsubseteq$ |
| 2 | $a \sqsubseteq b \Rightarrow a \lor c \sqsubseteq b \lor c$ | $\lor$ preserves $\sqsubseteq$ |
| 3 | $a \sqsubseteq b \Rightarrow a \otimes c \sqsubseteq b \otimes c$ | $\otimes$ preserves $\sqsubseteq$ |
| 4 | $a \sqsubseteq b \Rightarrow a \oplus c \sqsubseteq b \oplus c$ | $\oplus$ preserves $\sqsubseteq$ |
| 5 | $a \leq b \Rightarrow a \land c \leq b \land c$ | $\land$ preserves $\leq$ |
| 6 | $a \leq b \Rightarrow a \lor c \leq b \lor c$ | $\lor$ preserves $\leq$ |
| 7 | $a \leq b \Rightarrow a \otimes c \leq b \otimes c$ | $\otimes$ preserves $\leq$ |
| 8 | $a \leq b \Rightarrow a \oplus c \leq b \oplus c$ | $\oplus$ preserves $\leq$ |

**Note**: Conditions 1, 3, 6, 8 hold automatically by lattice properties. The "cross-order" conditions (2, 4, 5, 7) are the non-trivial requirements.

---

### Product Representation Theorem

**Theorem** (Ginsberg-Fitting): Every interlaced bilattice is isomorphic to a Ginsberg-Fitting product $L_1 \odot L_2$ of two bounded lattices.

**Product Construction** $L_1 \odot L_2$:

- **Elements**: Pairs $(a, b)$ where $a \in L_1$, $b \in L_2$
- **Truth/Essence order**: $(a_1, b_1) \sqsubseteq (a_2, b_2)$ iff $a_1 \leq_{L_1} a_2$ and $b_2 \leq_{L_2} b_1$
- **Knowledge/Ground order**: $(a_1, b_1) \leq (a_2, b_2)$ iff $a_1 \leq_{L_1} a_2$ and $b_1 \leq_{L_2} b_2$
- **Negation**: $\neg(a, b) = (b, a)$

**Intuition**: The first component tracks "positive support" and the second tracks "negative support". Negation swaps them.

**Historical Note**: This theorem was first presented by Czedli, Huhn, and Szabo at a 1980 conference in Szeged, Hungary (published 1983), predating Ginsberg's introduction of bilattices.

---

### Distributive Bilattices

A bilattice is **distributive** iff all twelve possible distributive laws hold among the four lattice operations.

**The Twelve Distributive Laws**:

For any operations $\star, \ast \in \{\land, \lor, \otimes, \oplus\}$ where $\star \neq \ast$:
$$P \star (Q \ast R) = (P \star Q) \ast (P \star R)$$

**Examples**:
- $x \land (y \oplus z) = (x \land y) \oplus (x \land z)$
- $x \lor (y \otimes z) = (x \lor y) \otimes (x \lor z)$

**Key Theorem (Fitting 1990)**:

> Every distributive bilattice is interlaced.

The converse fails: there exist interlaced bilattices that are not distributive.

**Characterization**: A bounded interlaced bilattice $L_1 \odot L_2$ is distributive iff both $L_1$ and $L_2$ are distributive lattices.

---

## Logos-Specific Content

### Essence and Ground Orderings

In the Logos constitutive semantics, bilateral propositions form a bilattice with **essence** ($\sqsubseteq$) and **ground** ($\leq$) orderings.

**Definitions** (from `02-ConstitutiveFoundation.tex` Definition 15):

| Relation | Symbol | Definition | Intuition |
|----------|--------|------------|-----------|
| Essence | $A \sqsubseteq B$ | $A \land B \equiv B$ | "$A$ is conjunctive part of $B$" |
| Ground | $A \leq B$ | $A \lor B \equiv B$ | "$A$ is disjunctive part of $B$" |

**Semantic Characterization**:

**Essence** ($X \sqsubseteq Y$) holds iff:
1. Every verifier for $Y$ has a part that verifies $X$
2. Fusions of verifiers for $X$ and $Y$ also verify $Y$
3. Every falsifier for $X$ also falsifies $Y$

**Ground** ($X \leq Y$) holds iff:
1. Every falsifier for $Y$ has a part that falsifies $X$
2. Fusions of falsifiers for $X$ and $Y$ also falsify $Y$
3. Every verifier for $X$ also verifies $Y$

### Negation Exchange Property

The two orderings are interrelated through negation:

- $A \sqsubseteq B \Leftrightarrow \neg A \leq \neg B$
- $A \leq B \Leftrightarrow \neg A \sqsubseteq \neg B$

This property ensures the bilattice structure is well-defined and allows reasoning about one order via the other.

### Non-Interlacing in Logos

**Key Result**: The bilattice of bilateral propositions $\mathcal{B}_\mathcal{S}$ is **not interlaced**.

Unlike the FOUR bilattice used in AI applications, Logos propositions fail the interlacing conditions because the semantic structure is richer.

**Counterexample** (from `02-ConstitutiveFoundation.tex` Remark 28):

Consider model $\mathcal{M}_D$ with state space $\mathcal{S}_D = \mathcal{P}(\{a,b,c,d,e,f\})$ and sentence letters $p_1, p_2, p_3$ with interpretations:
- $\|p_1\|_{\mathcal{M}_D} = (\{a\}, \{b\})$
- $\|p_2\|_{\mathcal{M}_D} = (\{c\}, \{d\})$
- $\|p_3\|_{\mathcal{M}_D} = (\{e\}, \{f\})$

The distributive identity $A \lor (B \land C) \equiv (A \lor B) \land (A \lor C)$ fails for these propositions.

Since distributivity implies interlacing (Fitting's theorem), failure of distributivity entails failure of interlacing.

### Weak Distribution Laws

Although full distribution fails, the logic $\mathsf{PI}^1$ validates weaker one-directional analogues.

**Weak Distribution Laws** (from `02-ConstitutiveFoundation.tex` Definition 26):

| Law | Formula | Direction |
|-----|---------|-----------|
| A11 | $A \lor (B \land C) \leq (A \lor B) \land (A \lor C)$ | Ground |
| A12 | $A \lor (B \land C) \sqsubseteq (A \lor B) \land (A \lor C)$ | Essence |
| A13 | $A \land (B \lor C) \leq (A \land B) \lor (A \land C)$ | Ground |
| A14 | $A \land (B \lor C) \sqsubseteq (A \land B) \lor (A \land C)$ | Essence |

**Significance**: These laws capture what remains valid when full distributivity fails. They are crucial for reasoning about propositional identity.

### Comparison: FOUR vs Logos

| Property | FOUR Bilattice | Logos Bilateral |
|----------|----------------|-----------------|
| Elements | 4 truth values | Pairs of state sets |
| Interlaced | Yes | **No** |
| Distributive | Yes | **No** |
| Weak distribution | N/A (full holds) | Yes (A11-A14) |
| Application | AI reasoning, truth maintenance | Propositional identity, hyperintensionality |
| Negation behavior | Swaps $t \leftrightarrow f$ | Swaps verifier/falsifier sets |

---

## See Also

- **lattices.md** - Standard lattice theory: semilattices, distributive lattices, complete lattices
- **../logic/domain/bilateral-semantics.md** - Truthmaker semantics and bilateral propositions (Logos application)
- **../logic/domain/mereology-foundations.md** - State space mereology underlying both orderings (Logos application)

## Codebase References

| Concept | Location | Definition |
|---------|----------|------------|
| Bilattice | `latex/subfiles/02-ConstitutiveFoundation.tex` | Definition 23, lines 671-678 |
| Interlaced bilattice | `latex/subfiles/02-ConstitutiveFoundation.tex` | Definition 23, line 679 |
| Distributive bilattice | `latex/subfiles/02-ConstitutiveFoundation.tex` | Definition 23, lines 682-684 |
| Essence/Ground orders | `latex/subfiles/02-ConstitutiveFoundation.tex` | Definition 15, lines 543-548 |
| Weak distribution laws | `latex/subfiles/02-ConstitutiveFoundation.tex` | Definition 26, lines 751-758 |
| Non-distributivity counterexample | `latex/subfiles/02-ConstitutiveFoundation.tex` | Remark 28, lines 710-725 |

## Key References

1. **Ginsberg, M.L. (1988)** - "Multivalued Logics: A Uniform Approach to Inference in Artificial Intelligence" - *Computational Intelligence* 4: 265-316. Introduced bilattices.

2. **Fitting, M. (1989)** - "Bilattices and the Semantics of Logic Programming" - Fixed-point semantics.

3. **Fitting, M. (1990)** - "Bilattices in Logic Programming" - Interlacing and distributivity conditions.

4. **Belnap, N.D. (1975, 1977)** - "How a Computer Should Think" / "A Useful Four-Valued Logic" - The FOUR bilattice.

5. **Bou, F. & Rivieccio, U. (2011)** - "The Logic of Distributive Bilattices" - Algebraic characterization.

6. **Arieli, O. & Avron, A. (1996)** - Bilattice-based reasoning for paraconsistent logic.
