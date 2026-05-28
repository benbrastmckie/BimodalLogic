# A Proof of Kamp's Theorem

**Alexander Rabinovich** (2014). *Logical Methods in Computer Science* 10(1:14), pp. 1--16. DOI: [10.2168/LMCS-10(1:14)2014](https://doi.org/10.2168/LMCS-10(1:14)2014)

Blavatnik School of Computer Science, Tel Aviv University.

---

## Overview

Provides a simple, self-contained proof of Kamp's theorem (expressive completeness of TL(Until, Since) for FOMLO over Dedekind complete chains) using a **composition-based** approach rather than EF games. The proof avoids games entirely, working instead with a normal form for first-order formulas called "exists-forall formulas" and showing closure under negation via an interval-decomposition argument.

**Key relevance**: Clean template for how the composition method handles sub-interval type splitting when a new point is inserted into a matched configuration on a linear order.

---

## 1. Introduction

- **Temporal Logic (TL)** uses modalities (k-place operators) whose truth tables are FOMLO formulas.
- **FOMLO** = First-Order Monadic Logic of Order: atomic propositions P(x), order relation <, equality =, Boolean connectives, first-order quantifiers.
- **Kamp's Theorem** (Theorem 2.1): TL(Until, Since) is expressively equivalent to FOMLO over Dedekind complete chains.
  - Direction (1): TL -> FOMLO is straightforward structural induction.
  - Direction (2): FOMLO -> TL is the hard direction; this paper's contribution.
- The proof is **constructive**: an algorithm converts any FOMLO formula phi(x) into an equivalent TL(Until, Since) formula over Dedekind complete chains.
- **Non-elementary complexity gap**: for every m, n in N, there is a FOMLO formula of size > n not equivalent to any TL formula of size <= exp(m, |phi|), where exp is iterated exponentiation.

---

## 2. Preliminaries

### 2.1 FOMLO Syntax and Semantics

- **Atoms of Sigma**: unary predicate symbols P, Q, R, ...
- **Sigma-chain**: M = (T, <, I) where T is the domain, < is a linear order on T, and I : Sigma -> P(T) is the interpretation.
- Formulas built from: atomic (x < y, x = y, P(x)), Boolean connectives, quantifiers.
- **Bounded quantifiers**: (exists x)_{>z}(...), (forall x)^{<z}(...), etc.

### 2.2 TL(Until, Since) Syntax and Semantics

- Formulas: F ::= True | P | not F | F1 or F2 | F1 Until F2 | F1 Since F2
- **Strict Until/Since**: M, t |= F1 Until F2 iff there exists t' > t such that M, t' |= F2 and M, t1 |= F1 for all t1 in (t, t').
- **Strict Since**: M, t |= F1 Since F2 iff there exists t' < t such that M, t' |= F2 and M, t1 |= F1 for all t1 in (t', t).
- **Derived operators**:
  - Box F (henceforth) = not(True Until (not F))
  - Overleftarrow-Box F (hitherto) = not(True Since (not F))
  - K+(F) = inf{t' | t' > t and F holds at t'} -- "next occurrence from above"
  - K-(F) = sup{t' | t' < t and F holds at t'} -- "next occurrence from below"

### 2.3 Kamp's Theorem (Statement)

**Theorem 2.1** (Kamp): 
1. Every TL(Until, Since) formula A has a FOMLO formula phi_A(x) equivalent to A over all chains.
2. Every FOMLO formula phi(x) with one free variable has a TL(Until, Since) formula equivalent to phi over Dedekind complete chains.

**Dedekind completeness**: every non-empty subset S of T with a lower bound has inf(S), and with an upper bound has sup(S). Both (N, <) and (R, <) are Dedekind complete; (Q, <) is not.

---

## 3. Exists-Forall Formulas (The Normal Form)

### Definition 3.1 (Exists-Forall formula)

An exists-forall-formula over Sigma is:

    psi(z_0, ..., z_m) := exists x_n ... exists x_1 exists x_0
      (ordering constraints on x_i and z_j)
      AND (each alpha_j(x_j) holds at x_j, for j = 0..n)
      AND (each beta_j holds along (x_{j-1}, x_j), for j = 1..n)
      AND (beta_{n+1} holds everywhere after x_n)
      AND (beta_0 holds everywhere before x_0)

where alpha_j, beta_j are quantifier-free formulas over Sigma.

**Key idea**: This describes an **interval decomposition** of the chain -- existentially chosen points partition the chain into intervals, each labeled by a type.

### Lemma 3.2 (Closure properties)
1. Conjunction of exists-forall formulas is equivalent to a disjunction of exists-forall formulas.
2. Every exists-forall formula is equivalent to a conjunction of exists-forall formulas with at most two free variables.
3. For every exists-forall formula phi, the formula exists x phi is an exists-forall formula.

### Definition 3.3 (Disjunctive exists-forall = "V-exists-forall")
A formula is V-exists-forall if equivalent to a disjunction of exists-forall formulas.

### Lemma 3.4
The set of V-exists-forall formulas is closed under disjunction, conjunction, and existential quantification.

### Proposition 3.5 (Key translation step)
Every V-exists-forall formula with one free variable is equivalent to a TL(Until, Since) formula.

**Proof sketch**: An exists-forall formula with one free variable at position z_k in a sequence x_0 < ... < x_n is equivalent to the conjunction of:
- A_k AND (B_{k+1} Until (A_{k+1} AND (B_{k+2} Until ... (A_n AND Box B_{n+1})...)))
- A_k AND (B_{k-1} Since (A_{k-1} AND (B_{k-2} Since ... (A_0 AND Overleftarrow-Box B_0)...)))

This is the core mechanism: **the interval decomposition directly maps to nested Until/Since**.

---

## 4. Proof of Kamp's Theorem (Main Argument)

### Proposition 4.2 (Closure under negation -- the hard part)
The negation of exists-forall formulas with at most two free variables is equivalent over Dedekind complete chains to a disjunction of exists-forall formulas.

### Proposition 4.3
Every first-order formula is equivalent over Dedekind complete chains to a disjunction of exists-forall formulas.

**Proof by structural induction**:
- **Atomic**: Immediate.
- **Disjunction**: Immediate.
- **Negation**: Uses Proposition 4.2 for the hard case.
- **Exists-quantifier**: Follows from Lemma 3.4.

### Theorem 4.4 (Kamp's Theorem)
For every FOMLO formula phi(x), a TL(Until, Since) formula exists that is equivalent to phi over Dedekind complete chains.

*Proof*: By Proposition 4.3, phi(x) is equivalent to a disjunction of exists-forall formulas. By Proposition 3.5, each is equivalent to a TL formula. QED.

---

## 5. Proof of Proposition 4.2 (The Interval Splitting Core)

This is the **key technical section** for the composition/decomposition method.

### Setup

The negation to handle has the form:

    not [alpha_0, beta_1, alpha_1, ..., beta_n, alpha_n](z_0, z_1)

where the bracket notation denotes an exists-forall formula with existentially chosen points in the interval (z_0, z_1), types alpha_j at points, and types beta_j along sub-intervals.

### Notation 5.2
[alpha_0, beta_1, ..., beta_n, alpha_n](z_0, z_1) abbreviates the exists-forall formula.

### Lemma 5.1 (Main technical lemma)
The negation of a formula of the form (5.1) -- with fixed endpoint types and interval types -- is equivalent over Dedekind complete chains to a disjunction of exists-forall formulas.

### Lemma 5.3 (Base case: all beta_i are True)

    not (exists x_1 ... exists x_n) (z_0 < x_1 < ... < x_n < z_1) AND (each P_i(x_i))

is equivalent to a V-exists-forall formula over Dedekind complete chains.

**Proof by induction on n**:
- **Base**: not (exists x_1)^{<z_1}_{>z_0} P_1(x_1) is equivalent to (forall y)^{<z_1}_{>z_0} not P_1(y).
- **Inductive step**: If P_1 does not occur in (z_0, z_1), done. Otherwise, let r_0 = inf{z in (z_0, z_1) | P_1(z)}.
  - **Key use of Dedekind completeness**: r_0 exists because the chain is Dedekind complete.
  - r_0 is definable by the V-exists-forall formula:
    
        INF(z_0, r_0, z_1, P_1) := z_0 < r_0 < z_1 AND (forall y)^{<r_0}_{>z_0} not P_1(y) AND (P_1(r_0) OR K+(P_1)(r_0))
    
  - **Sub-cases**: r_0 = z_0 or r_0 in (z_0, z_1).
  - In each sub-case, the problem reduces to a negation on a **shorter interval** or with **fewer predicates**, allowing the induction to proceed.

### Corollary 5.4
The formula not (exists z)^{<z_1}_{>z_0} [alpha_0, beta_1, ..., beta_n, alpha_n](z_0, z) is equivalent to a V-exists-forall formula over Dedekind complete chains.

**Proof**: Define F_n := alpha_n and F_{i-1} := alpha_{i-1} AND (beta_i Until F_i). Then [alpha_0, ..., alpha_n](z_0, z) holds iff there is an increasing sequence in (z_0, z_1) with F_0(z_0) holding. The negation reduces via Lemma 5.3 and the observation that F_i are TL-definable.

### The Full Proof of Lemma 5.1

Uses a decomposition into cases based on what goes wrong with the interval pattern:
- **Case 1**: not alpha_0(z_0) or K+(not beta_1)(z_0) -- endpoint failure.
- **Case 2**: alpha_0(z_0) and beta_1 holds along (z_0, z_1) -- guard succeeds but no witness.
- **Case 3**: alpha_0(z_0) AND not K+(not beta_1)(z_0), and there exists x in (z_0, z_1) such that not beta_1(x).

For each case, constructs V-exists-forall formulas Cond_i (describing when the case holds) and Form_i (the resulting equivalent). The negation equals the disjunction of (Cond_i AND Form_i).

**Induction on n**: The A_i^- and A_i^+ formulas decompose the interval at a new point z:
- A_i^-(z_0, z) = [alpha_0, beta_1, ..., beta_i, alpha_i](z_0, z)
- A_i^+(z, z_1) = [alpha_i, beta_{i+1}, ..., beta_{n+1}, alpha_{n+1}](z, z_1)
- A_i(z_0, z, z_1) = A_i^-(z_0, z) AND A_i^+(z, z_1)

By inductive hypothesis, not A_i is a V-exists-forall formula, and the full negation reduces to a conjunction and disjunction of these, which is itself V-exists-forall.

---

## 6. Related Works

Previous proofs of Kamp's theorem:
1. **Kamp's thesis** (1968): > 100 pages.
2. **Gabbay, Pnueli, Shelah, Stavi** (1980): outlined for N, extended to Dedekind complete orders via game arguments.
3. **Gabbay** (1981): proved via the **separation property**.
4. **Hodkinson** (1995): proved by game arguments; simplified in 1999 lecture notes.

**Separation property**: A temporal logic has the separation property if its formulas can be rewritten as Boolean combinations of formulas depending only on past, present, or future. A temporal logic with Box and Overleftarrow-Box has the separation property iff it is expressively complete for FOMLO.

**This paper's approach**: Inspired by [Gabbay-Pnueli-Shelah-Stavi 1980] and [Hodkinson 1999] but avoids games, separating general logical equivalences from temporal arguments.

---

## 7. Future Fragment of FOMLO

- Over **discrete** time (N, <): TL(Until) alone is expressively complete for future FOMLO formulas (Theorem 7.1, Gabbay-Pnueli-Shelah-Stavi).
- Over **continuous** time (R, <): TL(Until) is NOT expressively complete for the future fragment. No finite set of modalities suffices.
- Over **Dedekind complete** chains: every future FOMLO formula is equivalent to a **syntactically future** TL(Until, K^-) formula (Theorem 7.4).
- K^-(P) = sup{t' | t' < t and P holds at t'} -- an "almost future" modality depending only on the near past.

### Key Definitions for Future Fragment

**Definition 7.5**: (z_0, z_1)-exists-forall formulas restrict the interval pattern to a half-open interval (z_0, z_1).

**Definition 7.13**: (z_0, z_1, ..., z_k, infinity)-exists-forall formulas handle multiple reference points extending to infinity.

**Lemma 7.14**: Every future FOMLO formula with bounded quantifiers of the form (forall y)_{>z_0} and (exists y)_{>z_0} is equivalent to a (z_0, z_1, ..., z_k, infinity)-V-exists-forall formula over canonical TL(Until, K^-)-expansions.

---

## Key Insights for Formalization

### 1. The Interval Decomposition Pattern
The exists-forall normal form directly encodes the pattern: "choose n witness points, assert types at points and along intervals between them." This is the same structure needed for the EF game / interval splitting problem.

### 2. How Sub-Interval Types Are Handled
When a new point z is inserted into an interval (z_0, z_1):
- The interval type [alpha_0, ..., alpha_n](z_0, z_1) splits into:
  - A_i^-(z_0, z) = type of the left sub-interval
  - A_i^+(z, z_1) = type of the right sub-interval
- The key constraint is **which i** the new point corresponds to (i.e., which existential witness it replaces or sits between).
- The negation then requires showing that for ALL possible positions i, the conjunction of A_i^- and A_i^+ fails -- which reduces to disjunctions of negated sub-interval types.

### 3. Role of Dedekind Completeness
Dedekind completeness is used in exactly one place: the INF formula (5.2) that defines the infimum point r_0 = inf{z in (z_0, z_1) | P_1(z)}. This point is guaranteed to exist by completeness, and the formula K+(P_1)(r_0) handles the case where the infimum is a limit point (not itself satisfying P_1).

### 4. Composition Structure
The proof has a clear composition structure:
- **Decompose** a formula into interval-typed sub-formulas.
- **Compose** TL formulas from interval types using nested Until/Since.
- **Handle negation** by case-splitting on which sub-interval fails.

This is essentially the Feferman-Vaught composition theorem specialized to linear orders, but presented without the game-theoretic apparatus.

---

## References

[1] Gabbay 1981. Expressive functional completeness in tense logic.
[2] Gabbay, Hodkinson, Reynolds 1994. Temporal logic: Mathematical Foundations.
[3] Gabbay, Pnueli, Shelah, Stavi 1980. On the Temporal Analysis of Fairness.
[4] Hirshfeld, Rabinovich 2003. Future temporal logic needs infinitely many modalities.
[5] Hodkinson 1995. Expressive completeness of Until and Since over Dedekind complete linear time.
[6] Hodkinson 1999. Notes on games in temporal logic.
[7] Hodkinson, Reynolds 2006. Temporal Logic. Handbook of Modal Logic Ch. 11.
[8] Kamp 1968. Tense logic and the theory of linear order. PhD thesis.
[9] Pardo, Rabinovich 2012. A Finite Basis for 'Almost Future' Temporal Logic over the Reals.
[10] Pnueli 1977. The temporal logic of programs.
