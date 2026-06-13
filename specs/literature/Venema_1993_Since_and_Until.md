# Completeness via Completeness: Since and Until

**Yde Venema**
Faculteit der Wiskunde en Informatica, Universiteit van Amsterdam
Plantage Muidergracht 24, 1018 TV Amsterdam

> **Abstract.** In this paper we give finite axiomatizations of the set of all valid formulas in the formalism with $S$ and $U$, for the class of the well-ordered flows of time and for the frame consisting of the natural numbers. These axiom systems are orthodox in the sense that they only use the standard derivation rules of Modus Ponens, Temporal Generalization and Substitution. An essential use is made of the fact that the language with $S$ and $U$ is expressively complete over the frames involved.

*Published in: de Rijke, M. (ed.), Diamonds and Defaults, Synthese Library 229, Kluwer Academic Publishers, 1993.*

---

## 1. Introduction

In the context of temporal logic the word "completeness" is heavily overused, having at least three different meanings: first of all, a flow of time is called (Dedekind-)complete if every set of time points which is bounded to the right has a supremum. Secondly, a set of temporal operators is called functionally, or expressively, complete over a class $\mathcal{C}$ of temporal structures, if it has the same expressive power over $\mathcal{C}$ as monadic first order logic. And thirdly, an axiomatization is complete with respect to a class $K$ of flows of time, if it recursively enumerates the set of formulas that are valid in $K$. In this paper, we will show that in the case of the formalism with $S$ and $U$, the three notions of completeness are interwoven.

In his thesis [K], Hans Kamp introduced the operators $S$ and $U$, and he showed that over the class of complete linear temporal orders, the formalism is expressively complete. Burgess gave complete axiomatizations for several classes of frames in [B]. Recently, Gabbay and Hodkinson axiomatized the set of formulas valid on the temporal order consisting of the real numbers ([GH]). In their completeness proof, for an arbitrary consistent formula $\varphi$ a model $\mathcal{M}$ is built up which has 'almost' the intended flow of time. Using techniques from [BG] and [D], they proceed to show that "for formulas at most as complex as $\varphi$, this model is equivalent to one with the correct flow of time". In this paper we pick up this idea and apply it to the class of well-orderings and to $(\omega, <)$, the flow of time consisting of the natural numbers with the usual ordering. We use the results from [D] to show that axiomatic completeness of the $SU$-logics can be obtained via the expressive completeness of the language.

This would be a straightforward adaptation of the work done by Gabbay and Hodkinson, were it not that there is one crucial difference between their approach and ours, worth some discussion:

A special feature of their axiom system is that it uses the so-called irreflexivity rule IR:

$$\vdash (q \wedge H\neg q) \to \varphi \;\Rightarrow\; \vdash \varphi, \quad \text{for all formulas } \varphi \text{ and atoms } q \text{ not occurring in } \varphi$$

In our opinion the introduction of rules of this kind forms a considerable enrichment of the theory of temporal logics, making simple, finite axiomatizations possible in many different contexts (cf. [G], [V], for some generalizations). On the other hand we feel it is still worthwhile to look for orthodox axiom systems (i.e. with only MP, TG and SUB as derivation rules) wherever possible, because the IR-rule has certain disadvantages too: one can see IR as a way to let an atomic proposition (viz. $q$ in the antecedent of $(q \wedge H\neg q) \to \varphi$) perform the task of individual variables of predicate logic. In this sense, using the irreflexivity rule can be seen as a break with the paradigm in modal logic not to use symbols referring to worlds/time points. Besides that, unorthodox axiomatizations do not have all the nice mathematical properties that orthodox systems have. (For example, in the closely connected area of Boolean algebras with operators, the orthodoxity of the derivation system is needed to ensure that the complement of a finitely axiomatizable class of algebras is closed under ultraproducts, cf. [V].) Finally, we simply think it is interesting to find out how far orthodox axiomatizations can get us.

## 2. Definitions

### 2.1. Syntax

$(SU)$-formulas are built up using infinitely many propositional variables $p, q, \ldots$, boolean connectives $\neg$, $\wedge$ and the binary modal operators $S$ and $U$. As abbreviations we have, besides the usual classical operators $\vee$ and $\to$, the following:

$$G\varphi \equiv U(\bot, \varphi), \qquad F\varphi \equiv \neg G\neg\varphi$$
$$H\varphi \equiv S(\bot, \varphi), \qquad P\varphi \equiv \neg H\neg\varphi$$
$$\Diamond\varphi \equiv P\varphi \vee \varphi \vee F\varphi, \qquad \Box\varphi \equiv \neg\Diamond\neg\varphi$$

The *mirror image* of $\varphi$ is obtained by simultaneously replacing $S$ by $U$ and $U$ by $S$, everywhere in $\varphi$.

### 2.2. Semantics

A *flow of time*, *temporal order* or *frame* is a pair $\mathcal{F} = (T, <)$ with $T$ a set of time points and $<$ a binary relation on $T$. A *valuation* $V$ is a function assigning each $p_i$ a subset of $T$. A *model* is a pair $\mathcal{M} = (\mathcal{F}, V)$ with $\mathcal{F}$ a frame and $V$ a valuation on $\mathcal{F}$.

The truth relation $\models$ is defined in the usual way:

$$\mathcal{M}, t \models p_i \quad \text{if } t \in V(p_i)$$

$$\mathcal{M}, t \models \neg\varphi \quad \text{if } \mathcal{M}, t \not\models \varphi$$

$$\mathcal{M}, t \models \varphi \wedge \psi \quad \text{if } \mathcal{M}, t \models \varphi \text{ and } \mathcal{M}, t \models \psi$$

$$\mathcal{M}, t \models U(\varphi, \psi) \quad \text{if there is a } v > t \text{ such that } \mathcal{M}, v \models \varphi \text{ and for all } u \text{ with } t < u < v, \; \mathcal{M}, u \models \psi$$

$$\mathcal{M}, t \models S(\varphi, \psi) \quad \text{if there is a } v < t \text{ such that } \mathcal{M}, v \models \varphi \text{ and for all } u \text{ with } v < u < t, \; \mathcal{M}, u \models \psi$$

We assume the reader's familiarity with notions like linearity, density or discreteness of frames. A flow of time is called *(Dedekind) complete* if every subset with an upper bound has a least upper bound, *well-ordered* if every non-empty subset has a smallest element. We denote the classes of linear, complete and well-ordered frames by resp. $\mathbf{LO}$, $\mathbf{DO}$ and $\mathbf{WO}$.

### 2.3. The Stavi Connectives

A shortcut in our completeness proof involves an extension of the language $SU$ with the so-called *Stavi connectives*. The language $S'U'$ has two new binary connectives $S'$ and $U'$; to define their semantics, we first need the following notion:

A *gap* of a frame $\mathcal{F} = (T, <)$ is a proper subset $g \subset T$ which is downward closed (i.e. $t \in g$ and $s < t$ imply $s \in g$), but which does not have a supremum. Informally we can think of a gap as a hole in the Dedekind-incomplete structure.

Now $U'(\varphi, \psi)$ holds at a point $t$ of $T$ if there are a point $s \in T$ and a gap $g$ of $T$ with $t \in g$, $s \notin g$, such that:

1. $\psi$ holds everywhere between $t$ and $g$,
2. $\varphi$ holds everywhere between $g$ and $s$, and
3. $\neg\psi$ is true arbitrarily soon after the gap.

The definition of $S'$ is likewise.

We want to stress that, although we have only given an informal definition of $U'$ in terms of second order logic (gaps), there is also a first order definition of the semantics of the Stavi-connectives (cf. [G]).

### 2.4. Correspondence

Let $\mathcal{L}$ be the first order language with infinitely many monadic predicate symbols $P_0, P_1, \ldots$ and one binary relation symbol $<$. $\mathcal{L}(x)$ denotes the set of $\mathcal{L}$-formulas having one free variable $x$.

Models can be seen as structures for $\mathcal{L}$, in the ordinary sense of first order model theory. It is well-known that there exists a straightforward inductively defined translation $c$ from any modal language to the set of $\mathcal{L}(x)$-formulas such that for all models $\mathcal{M} = ((T, <), V)$ and $t \in T$:

$$\mathcal{M}, t \models \varphi \iff \mathcal{M} \models \varphi^c(t)$$

(Here the first $\models$ denotes the modal truth relation, the second $\models$ the first order one.)

For example, the clause for the modal operator $U$ is:

$$(U(\varphi, \psi))^c \equiv \exists z(x < z \wedge \psi^c(z) \wedge \forall y(x < y < z \to \varphi^c(y)))$$

Now suppose we have a modal language $\mathcal{L}$ that is special in the sense that, over the class of all models which are based on a certain class $K$ of frames, the converse of the above proposition holds, i.e. every $\mathcal{L}(x)$-formula $\varphi$ has an equivalent $\varphi'$, over $K$, in the modal language. In such a case we call $\mathcal{L}$ *expressively complete* over $K$.

## 3. Preliminaries

The preliminary facts that we use are of three kinds. As was said in the introduction, we prove axiomatic completeness via expressive completeness; so first of all, we need the following results:

### 3.1. Theorem: Expressive Completeness

1. (Kamp) $SU$ is expressively complete over $\mathbf{DO}$ (and hence over $\mathbf{WO}$).
2. (Stavi) $S'U'$ is expressively complete over $\mathbf{LO}$.

**Proof.** The proofs of these results can be found in [G]. $\square$

Secondly, we take Burgess' axiomatic completeness results as a basis for ours:

### 3.2. Definition

Consider the following formulas:

| | |
|---|---|
| (A1a) | $G(p \to q) \to (U(p, r) \to U(q, r))$ |
| (A2a) | $G(p \to q) \to (U(r, p) \to U(r, q))$ |
| (A3a) | $p \wedge U(q, r) \to U(q \wedge S(p, r), r)$ |
| (A4a) | $U(p, q) \wedge \neg U(p, r) \to U(q \wedge \neg r, q)$ |
| (A5a) | $U(p, q) \to U(p, q \wedge U(p, q))$ |
| (A6a) | $U(q \wedge U(p, q), q) \to U(p, q)$ |
| (A7a) | $U(p, q) \wedge U(r, s) \to U(p \wedge r, q \wedge s) \vee U(p \wedge s, q \wedge s) \vee U(q \wedge r, q \wedge s)$ |
| (Aib) | the mirror image of Aia |
| (D) | $F\top \to U(\top, \bot) \wedge P\top \to S(\top, \bot)$ |
| (L) | $H\bot \vee PH\bot$ |
| (W) | $Fp \to U(p, \neg p)$ |

### 3.3. Lemma

Let $\mathcal{F}$ be a linear frame. Then

1. $\mathcal{F} \models D \iff \mathcal{F}$ is a discrete ordering
2. $\mathcal{F} \models W \wedge L \iff \mathcal{F}$ is a well-ordering
3. $\mathcal{F} \models D \wedge W \wedge L \iff \mathcal{F} \cong (\omega, <)$

**Proof.** (i) is immediate, (iii) is a corollary of (i) and (ii), so we only need to prove (ii):

The direction from right to left is straightforward, so for the converse, assume $\mathcal{F} \models W \wedge L$ and let $X$ be a non-empty subset of $T$. $\mathcal{F} \models L$ implies that $\mathcal{F}$ has a smallest element $0$. If $0 \in X$ we are finished, otherwise let $V$ be a valuation on $\mathcal{F}$ with $V(p) = X$. Then $\mathcal{F}, V, 0 \models Fp$, so by $\mathcal{F}, V, 0 \models W$ we get $\mathcal{F}, V, 0 \models U(p, \neg p)$. This immediately yields a smallest element in $V(p) = X$. $\square$

### 3.4. Definition: Axiom Systems

Let the axiom systems $\mathbf{B}$, $\mathbf{BW}$ and $\mathbf{BN}$ be defined as follows:

$\mathbf{B}$ has as its axioms: all classical tautologies and A1a&b, ..., A7a&b. The axioms of $\mathbf{BW}$ are those of $\mathbf{B}$, extended with $W$, and $\mathbf{BN}$ has all the axioms of $\mathbf{BW}$, together with $D$.

All three derivation systems have as derivation rules, Modus Ponens (MP), Temporal Generalization (TG) and Substitution (SUB), given by:

- **MP:** from $\varphi$ and $\varphi \to \psi$, infer $\psi$.
- **TG:** from $\varphi$, infer $G\varphi$ and $H\varphi$.
- **SUB:** from $\varphi$, infer $\varphi[\psi/p]$, where the latter formula is obtained by replacing the atomic $p$ by $\psi$, everywhere in $\varphi$.

Notions like derivation, consistent formulas and sets of formulas, or maximal consistent sets, are defined as usual (cf. [B]).

Derivability of $\varphi$ in $\mathbf{A}$, where $\mathbf{A}$ ranges over $\mathbf{B}$, $\mathbf{BW}$ and $\mathbf{BN}$, is denoted by $\vdash_{\mathbf{A}} \varphi$. A model $\mathcal{M}$ is an $\mathbf{A}$-model if it has $\mathcal{M} \models \varphi$ for all $\mathbf{A}$-theses.

### 3.5. Theorem: Completeness (Burgess)

For all sets of formulas $\Sigma$ and formulas $\varphi$:

$$\Sigma \vdash_{\mathbf{B}} \varphi \iff \Sigma \models_{\mathbf{LO}} \varphi.$$

**Proof.** We refer to [B], theorems 1.4 and 1.5. $\square$

Finally, we use a result about second-order definable properties. Well-foundedness is a condition on linear frames which cannot be defined in first order logic, involving an essentially second order quantification over the set of all subsets of the universe: every subset $X \subseteq T$ which is not empty should have a smallest element. However, we can approximate the condition by stating that all *definable* subsets $X$ must have a smallest element. Frames meeting this constraint are very much like well-orderings, as was shown by Kees Doets in his dissertation (we will refer to the more accessible [D]). An important issue is, in which language we are talking about the structure. As we are concerned with the $SU$-formalism, we must confine ourselves to the set of first order formulas with one free variable. This means that we have to adapt the proofs given by Doets, since he allows parametrical definitions of subsets of $T$.

### 3.6. Definition

Let $\varphi$ be a formula in $\mathcal{L}(x)$, $\mathcal{M} = (T, <, V)$ a structure for $\mathcal{L}$. We define $X_\varphi$ to be the set $\{t \in T \mid \mathcal{M} \models \varphi(t)\}$. $\mathcal{M}$ is called *definably well-ordered* if for all $\varphi \in \mathcal{L}(x)$, the set $X_\varphi$ has a smallest element.

### 3.7. Definition

Two $\mathcal{L}$-structures $\mathcal{M}$ and $\mathcal{M}'$ are *$n$-equivalents*, notation $\mathcal{M} \equiv_n \mathcal{M}'$, if for all sentences $\varphi \in \mathcal{L}$ of quantifier depth $\leq n$, $\mathcal{M} \models \varphi \iff \mathcal{M}' \models \varphi$.

### 3.8. Theorem (Doets)

If $\mathcal{M}$ is a definably well-ordered linear model, then $\mathcal{M}$ has $n$-equivalents for all $n < \omega$.

**Proof.** Let $\mathcal{M} = (T, <, V)$ be a definably well-ordered linear order. For $a, b$ elements of $T$ with $b < a$, let $[b, a\rangle$ be the set $\{t \in T \mid b \leq t < a\}$, and $T^{<a}$ the set $\{t \in T \mid t < a\}$. Both sets can be seen as linear $\mathcal{L}$-models in their own right. Now define

$$Z = \{a \in T \mid \forall b < a\;([b, a\rangle \text{ has a well-ordered } n\text{-equivalent})\}$$

Just like in all the examples of [D], it is not hard to prove that $Z$ is a definable set, whence $\bar{Z}$ (i.e. the complement of $Z$) is definable too. We will prove that $\bar{Z}$ is empty.

For otherwise, $\bar{Z}$ has a smallest element $a$. Using an argument like in Theorem 3.1 of [D], we can show that for every $b < a$, the interval $[b, a\rangle$ has a well-ordered $n$-equivalent. But then, by definition of $Z$, $a \in Z$, which is a contradiction.

But if $\bar{Z} = \emptyset$, we get $Z = T$, so every interval $[b, a\rangle$ of $T$ has an $n$-equivalent in $\mathbf{WO}$. We can now use the same argument as above to prove that $\mathcal{M}$ itself must have a well-ordered equivalent. $\square$

## 4. Completeness

We can now proceed to prove our completeness results; first we need the following lemma:

### 4.1. Lemma

Every $\mathbf{BW}$-model is definably well-ordered.

**Proof.** Let $\mathcal{M} = (T, <, V)$ be a linear model satisfying $\mathcal{M} \models \mathbf{BW}$. We will prove that every $\mathcal{L}(x)$-definable subset of $T$ has a smallest element, via a roundabout through the language $S'U'$.

By 3.2 we know that every $\mathcal{L}(x)$-definable subset of $T$ also has a defining formula in $S'U'$. So it is sufficient to show that every formula $\varphi$ in $S'U'$ has an equivalent in $SU$ over $\mathcal{M}$. This we will do by induction on the complexity of $\varphi$:

The only non-trivial case is where $\varphi \equiv U'(\psi, \chi)$ (or its mirror image). We claim that $\varphi$ is equivalent to $\bot$ over $\mathcal{M}$. By the induction hypothesis, we may assume $\psi$ and $\chi$ to be $SU$-formulas. Suppose $\mathcal{M}, t \models U'(\psi, \chi)$. Then there is a gap $g$ coming after $t$, such that (1) $\chi$ holds everywhere between $t$ and $g$, and (2) $\chi$ is false arbitrarily soon after $g$.

(1) implies $\mathcal{M}, t \models F\chi$, so by axiom $W$ being valid in $\mathcal{M}$, $U(\neg\chi, \chi)$ holds at $t$. But this clearly contradicts (2). $\square$

### 4.2. Theorem (Soundness and Completeness)

$$\vdash_{\mathbf{BW}} \varphi \iff \mathbf{WO} \models \varphi$$

**Proof.** Soundness ($\Rightarrow$) is straightforward.

For completeness, let $\varphi$ be a $\mathbf{BW}$-consistent formula. By an ordinary Lindenbaum procedure we construct a maximal $\mathbf{BW}$-consistent set $\Phi$ with $\varphi \in \Phi$. As $\mathbf{BW}$ is a strengthening of $\mathbf{B}$, $\Phi$ is also $\mathbf{B}$-consistent, so by 3.5 there is a linear model $\mathcal{M} = (T, <, V)$ in which $\Phi$ is satisfiable. For all $\psi$ in $SU$, $\Box W(\psi)$ is in $\Phi$, so $\mathcal{M}$ is a $\mathbf{BW}$-model. By the previous lemma then, $\mathcal{M}$ is definably well-ordered.

Let $n$ be the quantifier depth of $\varphi^c$. By 3.8, $\mathcal{M}$ has an $n+1$-equivalent $\mathcal{M}'$. This means both $\mathcal{M}$ and $\mathcal{M}'$ satisfy $\exists x\, \varphi^c(x)$, so $\mathcal{M}'$ is the desired well-ordered model for $\varphi$. $\square$

Now completeness for $(\omega, <)$ comes very easily:

### 4.3. Theorem (Soundness and Completeness for $(\omega, <)$)

$$\vdash_{\mathbf{BN}} \varphi \iff (\omega, <) \models \varphi$$

**Proof.** For completeness, let $\varphi$ be $\mathbf{BN}$-consistent, then the formula $\varphi \wedge \Box D$ is $\mathbf{BW}$-consistent, so it has a well-ordered model $\mathcal{M} = (\mathcal{F}, V)$. Now $\mathcal{M} \models \Box D$ implies $\mathcal{F} \cong (\omega, <)$ by 3.3(iii). $\square$

## 5. Literature

- [B] Burgess, John P., "Axioms for Tense Logic: I. 'Since' and 'Until'", *Notre Dame Journal of Formal Logic*, 23 (1982) 367--374.
- [D] Doets, Kees, "Monadic $\Pi^1_1$-Theories of $\Pi^1_1$-Properties", *Notre Dame Journal of Formal Logic*, 30 (1989) 224--240.
- [G] Gabbay, Dov M., *Handbook of Temporal Logic*, forthcoming.
- [GH] Gabbay, D.M. and I.M. Hodkinson, "An axiomatization of the temporal logic with Until and Since over the real numbers", *Journal of Logic and Computation*, 1 (1990) 229--259.
- [K] Kamp, J.A.W., *Tense Logic and the Theory of Linear Order*, doctoral dissertation, University of California at Los Angeles, 1968.
- [V] Venema, Yde, *Many-dimensional modal logics*, forthcoming doctoral dissertation, Universiteit van Amsterdam, 1991.
