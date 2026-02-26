# Dependent Type Theory

> **Scope**: Foundational dependent type theory as a mathematical framework. This file covers the conceptual/mathematical aspects; for Lean 4 syntax and implementation, see `lean4/domain/dependent-types.md`.
> **Current as of**: 2026-02-24

## Purpose

This context file provides foundational background on dependent type theory (DTT) as a mathematical framework for constructive mathematics and proof assistants. It covers the core concepts without language-specific syntax.

### When to Load

Load this context when:
- Working on foundational type-theoretic proofs
- Understanding the mathematical basis of Lean's type system
- Researching type-theoretic constructions (Pi, Sigma, identity types)
- Comparing type-theoretic and set-theoretic foundations

---

## Quick Reference

### Type Formers Summary

| Type Former | Notation | Intuition | Logic Correspondence |
|-------------|----------|-----------|---------------------|
| Pi type | $\Pi_{x:A} B(x)$ | Dependent functions | Universal quantification |
| Sigma type | $\Sigma_{x:A} B(x)$ | Dependent pairs | Existential quantification |
| Identity type | $\text{Id}_A(a,b)$ | Propositional equality | Equality predicate |
| Inductive type | $\text{Ind}(...)$ | Freely generated types | Data types |
| Universe | $\mathcal{U}_i$ | Type of types | Stratified type hierarchy |

### Judgment Forms

| Judgment | Written | Meaning |
|----------|---------|---------|
| Type formation | $\Gamma \vdash A : \mathcal{U}$ | $A$ is a type in context $\Gamma$ |
| Term introduction | $\Gamma \vdash a : A$ | $a$ is a term of type $A$ |
| Definitional equality | $\Gamma \vdash a \equiv b : A$ | $a$ and $b$ are definitionally equal |

---

## Core Concepts

### Contexts and Judgments

A **context** $\Gamma$ is a sequence of variable-type declarations:
$$\Gamma = x_1 : A_1, x_2 : A_2(x_1), \ldots, x_n : A_n(x_1, \ldots, x_{n-1})$$

Each type $A_i$ may depend on previous variables. This dependency is the defining feature of dependent type theory.

**Well-formed contexts** satisfy:
- The empty context $\cdot$ is well-formed
- If $\Gamma \vdash A : \mathcal{U}$ (A is a type in context Gamma), then $\Gamma, x : A$ is well-formed

### Function Types

#### Simple Function Types

For types $A$ and $B$ (where $B$ does not depend on elements of $A$):
$$A \to B$$

Terms are functions $f : A \to B$ with application $f(a) : B$ for $a : A$.

#### Dependent Function Types (Pi Types)

For a type $A$ and a type family $B : A \to \mathcal{U}$:
$$\Pi_{x:A} B(x)$$

A term $f : \Pi_{x:A} B(x)$ is a function assigning to each $a : A$ an element $f(a) : B(a)$.

**Key properties**:
- The return type $B(x)$ depends on the input $x$
- When $B$ is constant, $\Pi_{x:A} B \cong A \to B$
- Corresponds to universal quantification in the propositions-as-types interpretation

**Formation rule**:
$$\frac{\Gamma \vdash A : \mathcal{U} \quad \Gamma, x : A \vdash B(x) : \mathcal{U}}{\Gamma \vdash \Pi_{x:A} B(x) : \mathcal{U}}$$

**Introduction rule** (lambda abstraction):
$$\frac{\Gamma, x : A \vdash b(x) : B(x)}{\Gamma \vdash \lambda x. b(x) : \Pi_{x:A} B(x)}$$

**Elimination rule** (application):
$$\frac{\Gamma \vdash f : \Pi_{x:A} B(x) \quad \Gamma \vdash a : A}{\Gamma \vdash f(a) : B(a)}$$

**Computation rule** (beta reduction):
$$(\lambda x. b(x))(a) \equiv b(a)$$

### Dependent Pair Types (Sigma Types)

For a type $A$ and a type family $B : A \to \mathcal{U}$:
$$\Sigma_{x:A} B(x)$$

A term $(a, b) : \Sigma_{x:A} B(x)$ consists of:
- A first component $a : A$
- A second component $b : B(a)$

**Key properties**:
- The type of the second component depends on the value of the first
- When $B$ is constant, $\Sigma_{x:A} B \cong A \times B$ (Cartesian product)
- Corresponds to existential quantification in the propositions-as-types interpretation

**Formation rule**:
$$\frac{\Gamma \vdash A : \mathcal{U} \quad \Gamma, x : A \vdash B(x) : \mathcal{U}}{\Gamma \vdash \Sigma_{x:A} B(x) : \mathcal{U}}$$

**Introduction rule** (pairing):
$$\frac{\Gamma \vdash a : A \quad \Gamma \vdash b : B(a)}{\Gamma \vdash (a, b) : \Sigma_{x:A} B(x)}$$

**Elimination rules** (projections):
$$\frac{\Gamma \vdash p : \Sigma_{x:A} B(x)}{\Gamma \vdash \pi_1(p) : A} \quad \frac{\Gamma \vdash p : \Sigma_{x:A} B(x)}{\Gamma \vdash \pi_2(p) : B(\pi_1(p))}$$

### Identity Types (Propositional Equality)

For a type $A$ and terms $a, b : A$:
$$\text{Id}_A(a, b) \quad \text{or} \quad a =_A b$$

This is the type of **proofs that a and b are equal**. It is central to homotopy type theory and proof-relevant mathematics.

**Key properties**:
- A term $p : a =_A b$ is evidence that $a$ equals $b$
- There may be multiple proofs of equality (path structure)
- Reflexivity: for any $a : A$, there is $\text{refl}_a : a =_A a$

**Formation rule**:
$$\frac{\Gamma \vdash A : \mathcal{U} \quad \Gamma \vdash a : A \quad \Gamma \vdash b : A}{\Gamma \vdash \text{Id}_A(a, b) : \mathcal{U}}$$

**Introduction rule** (reflexivity):
$$\frac{\Gamma \vdash a : A}{\Gamma \vdash \text{refl}_a : \text{Id}_A(a, a)}$$

**Elimination rule** (path induction / J):
Given $C : \Pi_{x,y:A} (x =_A y) \to \mathcal{U}$ and $c : \Pi_{x:A} C(x, x, \text{refl}_x)$,
for any $a, b : A$ and $p : a =_A b$:
$$J(C, c, a, b, p) : C(a, b, p)$$

**Computation rule**:
$$J(C, c, a, a, \text{refl}_a) \equiv c(a)$$

### Inductive Types

Inductive types are types defined by specifying their **constructors**. The general principle:

1. **Constructors** specify how to build terms of the type
2. **Recursor/eliminator** specifies how to use terms of the type
3. **Computation rules** specify how eliminator interacts with constructors

**Examples**:

**Natural numbers**:
- Constructors: $\text{zero} : \mathbb{N}$ and $\text{succ} : \mathbb{N} \to \mathbb{N}$
- Recursor: For any $C : \mathbb{N} \to \mathcal{U}$, given $c_0 : C(\text{zero})$ and $c_s : \Pi_{n:\mathbb{N}} C(n) \to C(\text{succ}(n))$, we get $\text{rec}_\mathbb{N}(C, c_0, c_s) : \Pi_{n:\mathbb{N}} C(n)$

**Boolean**:
- Constructors: $\text{true} : \text{Bool}$ and $\text{false} : \text{Bool}$
- Eliminator: Case analysis on the two constructors

**Lists**:
- Constructors: $\text{nil} : \text{List}(A)$ and $\text{cons} : A \to \text{List}(A) \to \text{List}(A)$

### Universe Stratification

To avoid paradoxes (like Russell's), types are stratified into universes:
$$\mathcal{U}_0 : \mathcal{U}_1 : \mathcal{U}_2 : \cdots$$

**Typing rules**:
- Each $\mathcal{U}_i$ is a type in $\mathcal{U}_{i+1}$
- If $A : \mathcal{U}_i$, then $A : \mathcal{U}_j$ for all $j > i$ (cumulativity)
- Type formers respect universe levels

**In Lean 4**:
- `Prop` is the universe of propositions (proof-irrelevant)
- `Type u` is the universe at level `u`
- `Sort u` is the general universe (includes `Prop`)

---

## Propositions as Types

The **Curry-Howard correspondence** interprets logical propositions as types:

| Logic | Type Theory |
|-------|-------------|
| Proposition $P$ | Type $P$ |
| Proof of $P$ | Term $p : P$ |
| Implication $P \Rightarrow Q$ | Function type $P \to Q$ |
| Conjunction $P \land Q$ | Product type $P \times Q$ |
| Disjunction $P \lor Q$ | Sum type $P + Q$ |
| Negation $\neg P$ | $P \to \bot$ (function to empty type) |
| Universal $\forall x. P(x)$ | Pi type $\Pi_{x:A} P(x)$ |
| Existential $\exists x. P(x)$ | Sigma type $\Sigma_{x:A} P(x)$ |
| Equality $a = b$ | Identity type $\text{Id}(a, b)$ |

This correspondence is **constructive**: to prove an existential, you must exhibit a witness; to prove a disjunction, you must prove one of the disjuncts.

---

## Type-Theoretic vs Set-Theoretic Foundations

| Aspect | Set Theory (ZFC) | Type Theory |
|--------|-----------------|-------------|
| Foundation | Sets as primitive | Types as primitive |
| Membership | $x \in A$ (can ask for any $x, A$) | $a : A$ (well-typed by construction) |
| Equality | Extensional (same elements) | Intensional (by construction) |
| Functions | Sets of pairs | Primitive notion |
| Proofs | External to the system | Internal (terms of proposition types) |
| Computation | Not inherent | Built-in (beta reduction) |

**Advantages of type theory**:
- Proofs are computational objects
- Type checking is decidable
- Natural basis for proof assistants

---

## See Also

- **../lean4/domain/dependent-types.md** - Lean 4 syntax and dependent types in practice
- **../lean4/patterns/tactic-patterns.md** - Lean tactics for type-theoretic proofs

---

## References

1. **Martin-Lof, P. (1984)** - *Intuitionistic Type Theory*. Bibliopolis. The foundational text.
2. **The Univalent Foundations Program (2013)** - *Homotopy Type Theory*. Institute for Advanced Study.
3. **Nordstrom, B., Petersson, K., Smith, J. (1990)** - *Programming in Martin-Lof's Type Theory*. Oxford.
4. **Constable, R. et al. (1986)** - *Implementing Mathematics with the Nuprl Proof Development System*. Prentice-Hall.
5. **nLab**: [dependent type theory](https://ncatlab.org/nlab/show/dependent+type+theory), [identity type](https://ncatlab.org/nlab/show/identity+type)
