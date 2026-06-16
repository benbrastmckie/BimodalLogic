# Chapter 9: Expressive Power of One-Dimensional Temporal Connectives: Basic Concepts

## 9.1 Introduction

This chapter deals with the basic concepts and theorems involved in measuring the expressive power of a temporal system. We deal here with one-dimensional temporal logics, those in which the unit for truth value is a point of the flow of time. Below we define the notions and connectives involved.

These definitions are a special case of the definition in chapter 4. We repeat them here for the sake of clarity and relative independence of chapters.

Some of the connectives involved in this and the next four chapters are since ($S$), until ($U$), will ($F$), and was ($P$). Given a flow of time $(T, <, h)$, the truth value of each of the above connectives at a point $t \in T$ is determined as follows:

$$\|Fp\|_t^h = 1 \text{ iff } (\exists s > t)\|p\|_s^h = 1,$$

$$\|Pp\|_t^h = 1 \text{ iff } (\exists s < t)\|p\|_s^h = 1,$$

$$\|U(p, q)\|_t^h = 1 \text{ iff } (\exists s > t)(\|p\|_s^h = 1 \land \forall y(t < y < s \Rightarrow \|q\|_y^h = 1)),$$

$$\|S(p, q)\|_t^h = 1 \text{ iff } (\exists s < t)(\|p\|_s^h = 1 \land \forall y(s < y < t \Rightarrow \|q\|_y^h = 1)).$$

---

<!-- Page 2 -->

Thus:

- $\|Fp\|_t^h = 1$ iff $\chi_F(t, h(p))$ holds in $(T, <)$,
- $\|Pp\|_t^h = 1$ iff $\chi_P(t, h(p))$ holds in $(T, <)$,
- $\|U(p,q)\|_t^h = 1$ iff $\chi_U(t, h(p), h(q))$ holds in $(T, <)$, and
- $\|S(p,q)\|_t^h = 1$ iff $\chi_S(t, h(p), h(q))$ holds in $(T, <)$,

where

$$\chi_F(t, P) = (\exists s > t)P(s),$$

$$\chi_P(t, P) = (\exists s < t)P(s),$$

$$\chi_U(t, P, Q) = (\exists s > t)(P(s) \land \forall y(t < y < s \Rightarrow Q(y))),$$

$$\chi_S(t, P, Q) = (\exists s < t)(P(s) \land \forall y(s < y < t \Rightarrow Q(y))).$$

$\chi_\#$ is called the *truth table* for the connective $\#$. It is a wff in the monadic first-order language---the language allowing for quantification over elements of the domain, with relation symbols $<$ and $=$ and unary predicates (i.e. subsets of $T$) to be used as parameters. (This is the language $\mathcal{L}_{PL}$ of chapter 4.)

**Example 9.1.1** Consider $\chi(t,P) = \exists z \exists y (t < z < y \land \forall s(z < s < y \Rightarrow P(s)))$. $\chi$ says 'There is an interval in the future of $t$ inside which $P$ is true.' This is a table for a connective $F_{int}$: $\|F_{int}(p)\|_t^h = 1$ iff $\chi(t, h(p))$ holds in $(T, <)$.

**Definition 9.1.2**

1. Any wff $\chi(t, Q_1, \ldots, Q_m)$ with one free variable $t$, in the monadic first-order language with predicate variable symbols $Q_i$, is called an *$m$-place truth table* (in one dimension). (See chapter 4.)

2. Given a syntactic symbol $\#$ for an $m$-place connective, we say it has a truth table $\chi(t, Q_1, \ldots, Q_m)$ iff for any $T$, $h$ and $t$, $(\star)$ holds:

$$(\star) \quad \|\#(q_1, \ldots, q_m)\|_t^h = 1 \text{ iff } (T, <) \models \chi(t, h(q_1), \ldots, h(q_m)).$$

This way we can define as many connectives as we want. The complexity of the connective is determined by its truth table. Some connectives are definable using other connectives, for example:

---

<!-- Page 3 -->

**Example 9.1.3** $Fp = U(p, \top)$ and $\Diamond = U(\top, \bot)$ = there exists a next moment.

However, $U$, for example, is not definable using $F$ and $P$. In fact, $\Diamond$ is not definable using $F$ and $P$ over linear time. Whether a connective is definable or not from other connectives depends on the flow of time, as the following example shows.

**Example 9.1.4**

1. Over dense linear time $\Diamond$ is equivalent to $\bot$ and hence is definable from $P$ and $F$.

2. Let $T = \{\ldots -2, -1, 0, 1, 2, \ldots\} \cup \{1/n \mid n = 1, 2, 3, \ldots\}$, with $<$ being the order by magnitude, then $\Diamond$ is not definable using $P$ and/or $F$.

*Proof.*

1. It is simple.

2. Suppose $\Diamond$ is equivalent to $A$ where $A$ is written with $P$ and $F$ and, maybe, atoms. Replace all appearances of atoms by $\bot$ to obtain $A'$. Since $\Diamond \leftrightarrow A$ holds in the structure $(T, <, h')$ with all atoms always false, in this structure $\Diamond \leftrightarrow A \leftrightarrow A'$ holds. As neither $\Diamond$ nor $A'$ contain atoms $\Diamond \leftrightarrow A'$ holds in all other $(T, <, h)$ as well. Now $A'$ contains only $P$ and $F$, $\top$, and $\bot$ and the classical connectives. Since $F\top = P\top = \top$ and $F\bot = P\bot = \bot$, at every point, $A'$ must be equivalent (in $(T, <)$) to either $\top$ or $\bot$ and so cannot equal $\Diamond$ which is true at 1 and false at 0. $\square$

Given a family of connectives, e.g. $\{F, P\}$ or $\{U, S\}$, we can define (using them) as many new connectives as we want. Previously we have seen how to define $H$ and $G$ using $F$ and $P$, for example. In fact, any wff $A = A(q_1, \ldots, q_m)$ of the language of the given initial connectives can be considered as a new connective. For example, $FHq$ has the table $\chi_{FHq} = (\exists s > t)(\forall y < s)Q(y)$ and is definable from $F$ and $P$. So any wff $A$ has a table $\psi_A$:

**Lemma 9.1.5** Let $\#_1(q_1, \ldots, q_{m_1}), \ldots, \#_n(q_1, \ldots, q_{m_n})$ be $n$ connectives with tables $\chi_1, \ldots, \chi_n$. Let $A$ be any wff built up from atoms $q_1, \ldots, q_m$, the classical connectives, and these connectives. Then there exists a monadic $\psi_A(t, Q_1, \ldots, Q_m)$ such that for all $T$ and $h$,

$$\|A\|_t^h = 1 \text{ iff } (T, <) \models \psi_A(t, h(q_1), \ldots, h(q_m)).$$

---

<!-- Page 4 -->

*Proof.* By induction on $A$.

- $\psi_{q_i} = Q_i(t)$,
- $\psi_{\neg A} = \neg \psi_A$,
- $\psi_{A \land B} = \psi_A \land \psi_B$,
- $\psi_{\#_i(A_1, \ldots, A_{m_i})} = \chi_i(t; \psi_{A_1}, \ldots, \psi_{A_{m_i}})$, the right-hand side being notation for the wff obtained, after renaming to avoid variable symbol clashes, by substituting $\psi_{A_j}(z)$ in wherever $Q_j(x)$ appears in $\chi_i$. $\square$

**Example 9.1.6** We have $\psi_{FU(p,q)} = \psi_{F(\psi_{U(p,q)})} = \chi_F(\psi_{U(p,q)}) = \exists s > t\, \psi_{U(p,q)}(s, P, Q)$.

The expressive power of a family of connectives over a flow of time is measured by how many $\psi_A$s it can express over the flow of time. A family of connectives is said to be *fully expressive* (or *functionally complete*) over a flow of time iff all $\psi(t, Q_1, \ldots, Q_m)$ can be obtained as $\psi_A$ (up to equivalence) for suitable $A(q_1, \ldots, q_m)$.

**Definition 9.1.7** A temporal language with one-dimensional connectives is said to be *expressively complete* or, equivalently, *functionally complete*, in one dimension over a class $\mathcal{T}$ of partial orders iff for any monadic $\psi(t, Q_1, \ldots, Q_m)$, there exists an $A$ of the language such that for any $(T, <)$ from $\mathcal{T}$, for any interpretation $h$ for $q_1, \ldots, q_m$,

$$(T, <) \models \forall t (\|A\|_t^h = 1 \leftrightarrow \psi(t, h(q_1), \ldots, h(q_m))).$$

In the cases where $\mathcal{T} = \{(T, <)\}$ we talk of expressive completeness over $(T, <)$. For example, the language of Since and Until is expressively complete over integer time and real number flow of time but not over rational numbers time.

**Definition 9.1.8** A flow of time $(T, <)$ is said to be *expressively complete* (or *functionally complete*) (in one dimension) iff there exists a finite set of (one-dimensional) connectives which is expressively complete over $(T, <)$, in one dimension.

The qualification of one-dimensionality in the definitions above will be explained in the more general terminology of chapter 13.

These notions parallel the definability and expressive completeness of classical logic. We know that in classical logic $\{\neg, \Rightarrow\}$ is sufficient to define

---

<!-- Page 5 -->

all other connectives. Furthermore, for any $n$-place truth table $\psi : 2^n \to 2$ there exists an $A(q_1, \ldots, q_n)$ of classical logic such that for any $h$,

$$\|A\|^h = \psi(h(q_1), \ldots, h(q_n)).$$

This is the expressive completeness of $\{\neg, \Rightarrow\}$ in classical logic.

The question of the existence of a finite expressively complete set of connectives is not trivial. Some flows of time have one and some do not. For example, the class of all branching flows of time (i.e. $<$ irreflexive and transitive) does not allow for any finite expressively complete set of connectives (see chapter 13). The question of expressive completeness is important for applications to computing. In an application area such as the study of execution sequences of parallel programs using temporal logic one may choose to use certain 'natural' temporal connectives. If these can be supplemented to an expressively complete set of connectives then one is assured that one can say whatever one wants on this application area.

## 9.2 The Separation Property for Linear Time

This subsection deals with linear flows of time. So 'equivalent' will mean 'equivalent over linear time', etc.

Consider the wff $Fq$. This formula 'talks' about the future only. Its truth value at any $t$, in any $(T, <, h)$ does not depend on the past or the present. We call such a wff *pure future*. We can similarly talk about *pure past* wffs such as, for example, $Pq$. Some wffs are mixed.

**Example 9.2.1** Consider $F(p \land Hq)$ being true now as pictured in figure 9.1.

```
     now = t        s
     ─────|─────────|───────
       q everywhere    p
```
*Figure 9.1*

$F(p \land Hq)$ is true at $t$ iff $\exists s > t$ such that $p$ is true at $s$ and $q$ is true in all points in the past of $s$. This formula is not pure future because its truth value depends on the past (for it to be true, $q$ must be true at all points in the past of $t$) and so if we change the past of $t$ we may change the value of $F(p \land Hq)$ at $t$. It is also dependent on the future because a point $s$ must

---

<!-- Page 6 -->

be found in the future of $t$. So $F(p \land Hq)$ is neither pure future nor pure past.

It is equivalent (in linear flows), however, to a boolean combination of wffs, each of which is pure future, past, or atomic. In fact, $F(p \land Hq) \equiv Hq \land q \land U(p, q)$.

It seems reasonable of us to conjecture that any wff talking about $t$ should be equivalent to some boolean combination of wffs talking about the future of $t$ only (pure future), past of $t$ only (pure past), and $t$ itself only (pure present). After all, we don't expect that the descriptions of the future and past are dependent. However, we can only do this decomposition if the language is sufficiently expressive. For take a language with $P$, $F$ only. As we have seen, this language cannot express $U$ (for otherwise it could express $\Diamond$). Can we rewrite $F(p \land Hq)$ in a different, separated way using only $F$ and $P$ and not using $U$?

No. The following lemma shows that if we could do that then $F$ and $P$ alone could express $U$. Since we know that they cannot we can deduce that $F(p \land Hq)$ cannot be decomposed into a purely future bit, purely past bit, and some atoms.

**Lemma 9.2.2** If in a temporal logic with $P$, $F$ and possibly other connectives, $F(p \land Hq)$ is equivalent over linear time to a boolean combination of pure future wffs, pure past wffs, and atoms, then $U$ is definable in the logic.

*Proof.* Assume then that $F(p \land Hq) \equiv B(A_i^F(p, q), p, q, A_j^P(p, q))$ where $B$ stands for some boolean combination, the $A_i^F(p, q)$ are pure future, and $A_j^P(p, q)$ are pure past wffs. All wffs are built from $F$, $P$, atoms, and logical connectives only.

Let us replace $p$ and $q$ by truth in each $A_j^P$ to obtain $D_j^P$ and let $B' = B(A_i^F, \top, \top, D_j^P)$. We claim that $B'$ is equivalent to $U(p, q)$.

We must show that the equivalence holds at all times $t$ in all linear $(T, <, h)$. To see this we define two new interpretations: $h'$, which agrees with $h$ in the future of $t$ but makes $p$ and $q$ true on $\{s \mid s \leq t\}$; and $h^*$, which makes $p$ and $q$ true everywhere.

Evaluating $D_j^P$ under $h$ is the same as evaluating $A_j^P$ under $h^*$ but, since $A_j^P$ is pure past and $h^*$ and $h'$ agree on the past of $t$, then that in turn is the same as evaluating $A_j^P$ under $h'$. Similarly, $p$ and $q$ under $h'$ are just $\top$. Finally, $A_i^F$ must agree under $h'$ and $h$ as they reflect the same future. Thus, at $t$, $B'$ under $h$ must agree with $B(A_i^F, p, q, A_j^P)$ under $h'$ and we have $\|B'\|_t^h = \|F(p \land Hq)\|_t^{h'}$.

Now it is not difficult to see that under an interpretation like $h'$ the right-hand side is just $U(p, q)$ under $h'$. But $U(p, q)$, being pure future, agrees under $h'$ and $h$.

---

<!-- Page 7 -->

We have $\|B'\|_t^h = \|U(p, q)\|_t^h$, as required. $\square$

Let us now give formal definitions to the notions we have used.

**Definition 9.2.3**

- Let $h, h'$ be two assignments and $t \in T$. We say that $h, h'$ *agree on the past of $t$*, $h =_{<t} h'$, iff for any atom $q$ and any $s < t$,

  $$s \in h(q) \text{ iff } s \in h'(q).$$

  We similarly define $h =_{\leq t} h'$ and $h =_{>t} h'$.

- Let $\mathcal{T}$ be a class of linear flows of time and $A$ be a wff in a temporal language over $(T, <)$. We say that $A$ is a *pure past wff over $\mathcal{T}$*, iff for all $(T, <)$ in $\mathcal{T}$, for all $t \in T$,

  $$\forall h, h', \quad (h =_{<t} h') \text{ implies that } \|A\|_t^h = \|A\|_t^{h'}.$$

  Similarly, we define *pure future* and *pure present* wffs.

- Let $\mathcal{T}$ be a class of flows of time and $A$ be a wff in a temporal language $L$. We say $A$ is *separable* in $L$ over $\mathcal{T}$ iff there exists a wff in $L$ which is a boolean combination of pure past, pure future, and atomic wffs and is equivalent to $A$ everywhere in any $(T, <)$ from $\mathcal{T}$.

- A set of temporal connectives is said to have the *separation property* over $\mathcal{T}$ iff every wff in the temporal language of these connectives is separable in the language (over $\mathcal{T}$).

Note that all these definitions depend on (the connectives of) the language and on the flow of time.

We show in the next section the main theorem that for a given set of connectives over a linear flow of time, the property of separation and the property of expressive completeness are essentially equivalent. In other words, you can have full separation for every wff over linear time iff you have full expressive power iff the temporal language is essentially the full monadic predicate logic of the linear flow of time.

In chapter 10 we prove separation (syntactically by actually rewriting each $A$) for $\{U, S\}$ over integer time and real number time. Then, in chapter 11, we show separation of a more expressive language over the class of all linear flows of time. Thus we obtain the expressive completeness of these languages for the respective flows.

---

<!-- Page 8 -->
