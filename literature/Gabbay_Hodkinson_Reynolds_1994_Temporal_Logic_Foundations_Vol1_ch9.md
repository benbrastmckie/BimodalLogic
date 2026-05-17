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

## 9.3 Separation Equals Expressive Completeness over Linear Flows

**Theorem 9.3.1** Let $L$ be a temporal language built from any number (finite or infinite) of connectives in which $P$ and $F$ are definable over a class $\mathcal{T}$ of linear flows of time. Then $L$ has the separation property over $\mathcal{T}$ implies that $L$ is expressively complete over $\mathcal{T}$.

*Proof.* Assume $L$ has separation. We will show that $L$ is expressively complete. This is trivial if $\mathcal{T}$ is empty so suppose not. We have to show that for any $\varphi(t, \bar{Q})$ in the monadic theory of linear order with predicate variable symbols $\bar{Q} = (Q_1, \ldots, Q_n)$, there exists a wff $A = A(q_1, \ldots, q_n)$ in the temporal language such that for all flows of time $(T, <)$ from $\mathcal{T}$, for all $h$, $t$,

$$\|A\|_t^h = 1 \text{ iff } (T, <) \models \varphi(t, h(q_1), \ldots, h(q_n)).$$

We denote this wff by $A[\varphi]$ and proceed by induction on the depth $m$ of nested quantifiers in $\varphi$.

**$m = 0$:** In this case, $\varphi(t)$ is quantifier free. Just replace each appearance of $t = t$ by $\top$, $t < t$ by $\bot$, and each $Q_i(t)$ by $q_i$ to obtain $A[\varphi]$.

**$m > 0$:** Assume now that for any wff $\varphi(t, \bar{Q})$, with any number of $Q_i$ and depth of nested quantifiers at most $m$, there exists wff $A[\varphi]$. This is the induction hypothesis. We now want to show that the hypothesis holds for $m + 1$. It is enough to treat the case of $\exists z\, \psi(t, z, \bar{Q})$ where $\psi$ has quantifier depth $\leq m$.

Assuming that we do not use $t$ as a bound variable symbol in $\psi$ and that we have replaced all appearances of $t = t$ by $\top$ and $t < t$ by $\bot$ then the atomic wffs in $\psi$ which involve $t$ have one of the following forms: $Q_i(t)$, $t < y$, $t = y$, or $y < t$, where $y$ could be $z$ or any other variable letter occurring in $\psi$.

If we regard $t$ as fixed, the relations $t < y$, $t = y$, $t > y$ become unary. Introduce new unary predicates

- $R_=(y) = (t = y)$,
- $R_>(y) = (t > y)$, and
- $R_<(y) = (t < y)$.

Then $\psi$ can be rewritten equivalently as

$$\psi'(z, \bar{Q}, R_=, R_>, R_<),$$

---

<!-- Page 9 -->

in which $t$ appears only in the form $Q_i(t)$. Since $t$ is free in $\psi$, we can go further and prove (by induction on the quantifier depth of $\psi'$) that $\exists z\, \psi'$ can be equivalently rewritten as

$$\bigvee_j [\alpha_j(t) \land \exists z\, \psi_j(z, \bar{Q}, R_=, R_>, R_<)],$$

where

- $Q_i(t)$ appear only in $\alpha_j(t)$ and not at all in $\psi_j$,
- $\alpha_j(t)$ is quantifier free,
- and each $\psi_j$ has quantifier depth $\leq m$.

Each $\psi_j$ is a wff with at most $m$ nested quantifiers and hence by the induction hypothesis there exists a temporal wff $A_j = A_j(q, r_=, r_>, r_<)$ such that for any $h$, $z$,

$$\|A_j\|_z^h = 1 \text{ iff } (T, <) \models \psi_j(z, h(q_1), \ldots, h(q_n), h(r_=), h(r_>), h(r_<)).$$

Now let $Q_\exists$ be an abbreviation for temporal wffs equivalent (over $\mathcal{T}$) to $Pq \lor q \lor Fq$ whose existence in $L$ is guaranteed in the statement of the theorem. Then let $B(q, r_=, r_>, r_<) = \bigvee_j (A[\alpha_j] \land Q_\exists A_j)$. $A[\alpha_j]$ can be obtained from the quantifier free case.

In any structure $(T, <)$ from $\mathcal{T}$ for any $h$ interpreting the atoms $q, r_=, r_>$ and $r_<$, we have

$$\|B\|_t^h = 1$$
$$\text{iff } \|\bigvee_j (A[\alpha_j] \land Q_\exists A_j)\|_t^h = 1$$
$$\text{iff } \bigvee_j (\|A[\alpha_j]\|_t^h = 1 \land \|Q_\exists A_j\|_t^h = 1)$$
$$\text{iff } \bigvee_j (\alpha_j(t) \land \exists z\, (\|A_j\|_z^h = 1))$$
$$\text{iff } \exists z\, \bigvee_j (\alpha_j(t) \land \psi_j(z, h(q_1), \ldots, h(q_n), h(r_=), h(r_>), h(r_<)))$$

Now provided we interpret the $r$ atoms as the appropriate $R$ predicates, i.e. provided that:

- $h^*(r_=) = \{t\}$,
- $h^*(r_<) = \{s \mid t < s\}$, and
- $h^*(r_>) = \{s \mid s < t\}$,

---

<!-- Page 10 -->

we can continue and obtain

$$\|B\|_t^{h^*} = 1 \text{ iff } \exists z\, \psi(t, z, h^*(q_1), \ldots, h^*(q_n)).$$

$B$ is almost the $A[\varphi]$ we need except for one problem. $B$ contains, besides the $q_i$, also three other atoms, $r_=$, $r_>$, and $r_<$, and equation $(\star)$ from definition 9.1.2 above is valid for any $h^*$ which is arbitrary on the $q_i$ but very special on $r_=, r_>, r_<$. We are now ready to use the separation property (which we haven't used so far in the proof). We use separation to eliminate $r_=, r_>, r_<$ from $B$. Since we have separation $B$ is equivalent to a boolean combination of atoms, pure past wffs, and pure future wffs.

So there is a boolean combination $\beta = \beta(B_+, B_-, B_0)$ such that

$$B \equiv \beta(B_{+i}, B_{-j}, B_0),$$

where $B_0$ is a combination of atoms, $B_{+i}$ are pure future, and $B_{-j}$ are pure past wffs.

Therefore,

$$\|B\|_t^{h^*} = \|\beta(B_{+i}, B_{-j}, B_0)\|_t^{h^*}.$$

Consider now $B_{-j}(q, r_>, r_=, r_<)$.

Let the interpretation $g^*$ be defined as $h^*$ on the $q_i$ but also by

- $g^*(r_>) = T$
- $g^*(r_<) = g^*(r_=) = \emptyset$.

So $g^*$ agrees with $h^*$ on the past of $t$. Therefore,

$$\|B_{-j}(q, r_>, r_=, r_<)\|_t^{h^*} = \|B_{-j}(q, r_>, r_=, r_<)\|_t^{g^*},$$

but under $g^*$, $r_>$ is $\top$, and $r_=, r_<$ are $\bot$. Substitute these values in $B_{-j}$ and obtain $B^*_{-j}$, i.e. $B^*_{-j} = B_{-j}(q, \top, \bot, \bot)$, and obtain that

$$\|B_{-j}\|_t^{h^*} = \|B_{-j}\|_t^{g^*} = \|B^*_{-j}\|_t^h.$$

We can similarly argue this for $B^*_{+i} = B_{+i}(q, \bot, \top, \bot)$ where we substitute $r_> = \bot$, $r_< = \top$, $r_= = \bot$ in $B_{+i}$ and for $B^*_0$, where we obtain a similar equation by letting $r_= = \top$ and $r_< = r_> = \bot$.

---

<!-- Page 11 -->

Let $B^* = \beta(B^*_{+i}, B^*_{-j}, B^*_0)$. Then we obtain for any $h^*$,

$$\|B^*\|_t^{h^*} = \|\beta(B^*_{+i}, B^*_{-j}, B^*_0)\|_t^{h^*} = \|\beta(B_{+i}, B_{-j}, B_0)\|_t^{h^*} = \|B\|_t^{h^*}.$$

Hence

$$\|B^*\|_t^{h^*} = 1 \text{ iff } (T, <) \models \varphi(t, h^*(\bar{Q})).$$

This equation holds for any $h^*$ arbitrary on $\bar{Q}$, but restricted on $r_<, r_>, r_=$. But $r_<, r_>, r_=$ do not appear in it at all and hence we obtain that for any $h$, $\|B^*\|_t^h = 1$ iff $(T, <) \models \varphi(t, h^*(\bar{Q}))$.

Let $A[\varphi] = B^*$ and we have completed the induction step and the proof of the theorem. $\square$

Now we want to prove the other direction, namely that if $L$ is expressively complete it is separated. The idea is to use lemma 9.1.5.

Given $A$, we take $\psi_A$ (its table), which is a wff of the monadic theory of $(T, <)$. We separate $\psi_A$, using properties of the first-order theory of $(T, <)$ and then we use the expressive completeness to find suitable $A_i^{+/-}$ for the separated parts. Thus we achieve separation for $A$. We therefore need some lemmas on the monadic first-order language of $(T, <)$ that will show how to separate any $\psi_A$.

**Lemma 9.3.2** Let $\varphi$ be a wff of the monadic language. Then for any set $\{x_1, \ldots, x_n\}$ of variable symbols containing all of $\varphi$'s free ones, under the assumption $x_1 < x_2 < \ldots < x_n$, we have $\varphi$ equivalent to a disjunction of conjunctions of wffs of the form

$$\bigvee_l (\varphi[l, < x_1] \land \varphi[l, x_1] \land \varphi[l, x_1, x_2] \land \varphi[l, x_2] \land \ldots \land \varphi[l, x_n] \land \varphi[l, > x_n]),$$

where

- in $\varphi[i, y]$ only $y$ is free and $\varphi$ is quantifier free.
- $\varphi[i, < y]$ is a wff in which only $y$ is free and all quantifiers are relativized to $< y$.
- Similarly, $\varphi[i, > y]$.

---

<!-- Page 12 -->

- $\varphi[i, x < y]$ is a wff with only $x, y$ free and all quantifiers are relativized to between $x$ and $y$.

*Proof.* Proceed by induction on the quantifier depth of $\varphi$. We assume $x_1 < x_2 < \ldots < x_n$ is some ordering of distinct variables including all of $\varphi$'s free ones.

**The quantifier free case:** Here, by putting $\varphi$ in disjunctive normal form, we see that $\varphi$ is equivalent to a disjunction (over $l$) of conjunctions of the form $\varphi[i, x_1] \land \varphi[i, x_2] \land \ldots \land \varphi[i, x_n]$.

**Inductive case:** Here, we may assume that $\varphi$ is an existentially quantified wff. Otherwise write $\varphi$ as a boolean combination of such wffs (just rearrange the top level boolean connectives so as not to change any quantifier depths), use the proof below to rewrite each of the boolean constituents, and put the whole resulting wff into disjunctive normal form. This will be in the right form as $\neg\varphi$ is an acceptable conjunct exactly when $\varphi$ is.

So suppose $\varphi = \exists y\, \psi(y, x_1, \ldots, x_n)$. Since we can assume $x_1 < x_2 < \ldots < x_n$ we have

$$\exists y\, \psi \equiv (\exists y < x_1)\psi \lor \bigvee_{i=1}^{n} \psi(x_i, x_1, \ldots, x_n) \lor \bigvee_i \exists y((x_i < y < x_{i+1}) \land \psi) \lor (\exists y > x_n)\psi.$$

Assume $x_1 < \ldots < x_i < y < x_{i+1} < \ldots < x_n$. Then $\psi(y, x_1, \ldots, x_n)$ is equivalent by the induction hypothesis to $\bigvee_k \varphi_k$ where

$$\varphi_k = \ldots \land \varphi[k, x_i, y] \land \varphi[k, y] \land \varphi[k, y, x_{i+1}] \land \ldots$$

Hence $\exists y(x_i < y < x_{i+1} \land \bigvee_k \varphi_k)$ is equivalent to

$$\bigvee_k [\varphi[k, < x_1] \land \varphi[k, x_1] \land \ldots \land \varphi[k, x_i] \land \exists y(x_i < y < x_{i+1} \land \varphi[k, x_i, y] \land \varphi[k, y] \land \varphi[k, y, x_{i+1}]) \land \varphi[k, x_{i+1}, x_{i+2}] \land \ldots]$$

We can obtain a similar expression for $(\exists y < x_1)\psi$, $(\exists y > x_n)\psi$ and for the cases when $y$ is equal to some $x_i$.

We thus obtain $\varphi$ equivalent to a disjunction of the required form. This completes the induction step. $\square$

---

<!-- Page 13 -->

**Corollary 9.3.3** Let $\psi(t)$ be a wff with $t$ free only. Then $\psi$ is equivalent to a disjunction of conjunctions of the form

$$\bigvee_k (\varphi[k, < t] \land \varphi[k, t] \land \varphi[k, > t]).$$

**Theorem 9.3.4** Let $L$ be expressively complete over linear time. Then $L$ is separated.

*Proof.* Assume $L$ is expressively complete and show $L$ has separation. Let $A$ be any wff of $L$. Then there exists, by lemma 9.1.5 of section 1, a monadic $\psi(t, \bar{Q})$ such that for any $(T, <, h)$,

$$\|A\|_t^h = 1 \text{ iff } (T, <) \models \psi(t, h(\bar{Q})).$$

We have shown above that the $\psi$ can be separated. Thus $\psi$ is equivalent to

$$\bigvee_k \varphi[k, < t] \land \varphi[k, t] \land \varphi[k, > t].$$

By the expressive completeness of $L$ let

$$A^* = \bigvee_k (A[\varphi[k, < t]] \land A[\varphi[k, t]] \land A[\varphi[k, > t]]),$$

which is equivalent to $A$, since for all $h$ and $t$,

$$\|A\|_t^h = 1 \text{ iff } (T, <) \models \psi(t, h(\bar{Q})) \text{ iff } \|A^*\|_t^h = 1.$$

By examining the forms of their tables (e.g. $\varphi[k, < t]$) we deduce that each $A[\varphi[k, < t]]$ is pure past, each $A[\varphi[k, t]]$ pure present, and each $A[\varphi[k, > t]]$ pure future. We thus also have that $A^*$ is separated. $\square$

## 9.4 The Generalized Separation Property

By careful examination of the separation theorem, we can extract the relevant ideas and prove a general separation theorem which will allow us to deduce expressive completeness of a language over any class of---even non-linear---flows of time provided that we can demonstrate a generalized separation property. A proof of the result below appears in [Amir, 1985]. To do this, we will have to have some relations which, playing the role of $<$, $>$ and $=$ in the linear case, separate time into disjoint regions like past, present and future.

**Definition 9.4.1** Let $\varphi_i(x, y)$, $i = 1, \ldots, n$ be $n$ given formulae in the monadic language with $<$ and let $\mathcal{T}$ be a class of flows of time. Assume the following:

---

<!-- Page 14 -->

- for every $t$ in each $(T, <)$ in $\mathcal{T}$ the sets $T(\varphi_i, t) = \{s \in T \mid \varphi_i(s, t)\}$ for $i = 1, \ldots, n$ are mutually exclusive and $\bigcup_i T(\varphi_i, t) = T$;

- for each $i$ there is a formula $\beta_i(t, x)$ such that $\varphi_i(t, x)$ and $\beta_i(t, x)$ are equivalent over $\mathcal{T}$ and $\beta_i$ is a boolean combination of some $\varphi_j(x, t)$; and

- $<$ and $=$ can be equivalently expressed (over $\mathcal{T}$) as boolean combinations of the $\varphi_i$.

Then we have the following series of definitions:

- For any $t$ from any $(T, <)$ in $\mathcal{T}$, for any $i = 1, \ldots, n$, we say that truth functions $h$ and $h'$ *agree on $T(\varphi_i, t)$* if and only if $h(q)(s) = h'(q)(s)$ for all $s$ in $T(\varphi_i, t)$ and all atoms $q$.

- We say that a formula $A$ is *pure $\varphi_i$* over $\mathcal{T}$ if for any $(T, <)$ in $\mathcal{T}$, any $t \in T$ and any two truth functions $h$ and $h'$ which agree on $T(\varphi_i, t)$, we have

  $$\|A\|_t^h = \|A\|_t^{h'}.$$

- The logic $L$ has the *generalized separation property* over $\mathcal{T}$ iff every formula $A$ of $L$ is equivalent over $\mathcal{T}$ to a boolean combination of pure formulae.

**Theorem 9.4.2 (Generalized Separation Theorem)** If $L$ has the generalized separation property over a class $\mathcal{T}$ of flows of time and if each of the 1-place connectives $\#_i$ defined below can be expressed equivalently in $L$ then $L$ is expressively complete over $\mathcal{T}$.

For $i = 1, \ldots, n$ define $\#_i$ by

$$\|\#_i(p)\|_t^h = 1 \text{ iff } \exists s\, (\varphi_i(s, t) \text{ holds in } (T, <) \text{ and } \|p\|_s^h = 1).$$

*Proof.* In the proof let 'equivalent' be read as 'equivalent over $\mathcal{T}$'.

It is clear that because of the first condition we have assumed holds on the $\varphi_i$, any boolean combination of these formulae is equivalent to a disjunction of them. It follows that there are subsets $K_=$ and $K_<$ and $J_i$ for each $i$ of $\{1, \ldots, n\}$ such that $x = y$ is equivalent to $\bigvee_{k \in K_=} \varphi_k$, $x < y$ is equivalent to $\bigvee_{k \in K_<} \varphi_k$, and for each $i$, $\varphi_i(t, s)$ is equivalent to $\bigvee_{j \in J_i} \varphi_j(s, t)$.

In fact, without loss of generality we may assume that $\varphi_1(x, y)$ is $x = y$. To see this just throw away all the $\varphi_k$ for $k \in K_=$ and use $x = y$ for $\varphi_1(x, y)$. The generalized separation property is preserved as any formula which was pure $\varphi_k$ for some old $k \in K_=$ is now pure $\varphi_1$.

---

<!-- Page 15 -->

Next we note that we are best using a slightly different language than the usual monadic one. We suppose that instead of $=$, $<$ and $Q_i(x)$ our atomic formulae are now $\varphi_i$ or $Q_i(x)$. To prevent confusion we use a binary symbol $c_i$ instead of each $\varphi_i$. $(T, <)$ becomes a $\{c_1, \ldots, c_n\}$-structure just by interpreting $c_i$ as $\varphi_i$. It is clear that appearances of $=$ and $<$ can be equivalently rewritten in the new language and vice versa.

We are going to show that any monadic formula in $\{=, <\}$ with one free variable $t$ has a temporal equivalent in $L$ by induction on $m$ using the following hypothesis:

- for every formula $\varphi(t, Q_1, \ldots, Q_k)$ using the language with $c_1, \ldots, c_n$ but having quantifier depth at most $m$ there is a temporal formula $A$ in $L$ such that $\|A\|_t^h = 1$ if and only if $(T, <) \models \varphi(t, h(q_1), \ldots, h(q_n))$.

**Base Case:** First assume $\varphi(t)$ is quantifier free. Just replace each appearance of $c_1(t, t)$ by $\top$, $c_i(t, t)$ for $i > 1$ by $\bot$, and $Q_i(t)$ by $q_i$ and we have $A$ as required. There are no other atomic formulae.

**Induction Case:** Assume that the induction hypothesis holds for $m$. We need only consider the case when $\varphi$ is $\exists z\, \psi(t, z, Q_1, \ldots, Q_k)$ and when the depth of nesting of quantifiers in $\psi$ is not greater than $m$.

Since $t$ is free in $\varphi$, we can prove (by induction on the quantifier depth of $\psi$) that $\exists z\, \psi(t, z)$ is equivalent to

$$\bigvee_l [\alpha_l \land \exists z\, (\psi_l)],$$

where

- $Q_i(t)$ appear only in $\alpha_l(t)$ and not at all in $\psi_l$,
- $\alpha_l(t)$ is quantifier free,
- and each $\psi_l$ has quantifier depth $\leq m$.

We can also suppose that $t$ is not used as a bound variable symbol. Further, by replacing $c_1(t, t)$ by $\top$ and $c_i(t, t)$ for $i > 1$ by $\bot$ and by rewriting each appearance of $c_i(t, y)$ as a boolean combination (hence not effecting the quantifier depth) of some $c_j(y, t)$ we can guarantee that the only atomic formulae in $\psi_l$ are

- $Q_i(y)$ for $i = 1, \ldots, k$,
- $c_i(y, t)$ for $i = 1, \ldots, n$, and
- $c_i(y, y')$ for $i = 1, \ldots, n$,

---

<!-- Page 16 -->

where $y$ and $y'$ are variables different from $t$. So the only atoms in $\psi_l$ which include the variable $t$ are $c_i(y, t)$ for $i = 1, \ldots, n$.

We are going to proceed for a while now as if $t$ is fixed. This will allow us to pretend that we only have a free variable $z$ and to use the induction hypothesis. To do this, introduce monadic symbols $R_1, \ldots, R_n$ and substitute $R_i(y)$ for each $c_i(y, t)$ in $\psi_l$ to obtain $\psi_l'(z, \bar{Q}, R_1, \ldots, R_n)$. As the quantifier depth in $\psi_l'$ is not greater than $m$ the induction hypothesis tells us that there is a formula

$$B_l(q, r_1, \ldots, r_n)$$

in $L$ such that

$$\|B_l\|_z^g = 1 \text{ iff } (T, <) \models \psi_l'(z, g(q_1), \ldots, g(q_k), g(r_1), \ldots, g(r_n)).$$

If each $g(r_i)$ is just the extension of $\varphi_i(\cdot, t)$ which is $T(\varphi_i, t)$ then we have $\|B_l\|_z^g = 1$ iff $(T, <) \models \psi_l(t, z, g(q_1), \ldots, g(q_k))$.

Now, as in the linear case, we are going to use separation to show that we do not really need the atoms $r_1, \ldots, r_n$ anyway.

First we reduce our considerations to one new atom $r$. Replace $r_1$ in $B_l$ by $r$ and each $r_i$ for $i > 1$ by $\bigvee_{j \in J_i} \#_j(r)$ to obtain $A_l$ where we recall that $\varphi_i(t, s) = \bigvee_{j \in J_i} \varphi_j(s, t)$.

Now, given a valuation $h$ of the original atoms and $r$, and a $t \in T \in \mathcal{T}$ such that

$$(\star) \quad h(\{r\}) = \{t\}$$

then we can extend $h$ to $g$ on $r_1, \ldots, r_n$ by $g(r_i) = T(\varphi_i, t)$. Thus

$$\|r\|_s^h = 1$$
$$\text{iff } s \in T(\varphi_1, t)$$
$$\text{iff } \varphi_1(s, t) \text{ holds in } (T, <)$$
$$\text{iff } \bigvee_{j \in J_1} \varphi_j(t, s) \text{ holds in } (T, <)$$
$$\text{iff for some } j \in J_1, \varphi_j(t, s) \text{ holds in } (T, <)$$
$$\text{iff } \exists u \in T, \varphi_j(t, s) \text{ holds in } (T, <) \text{ and } \|r\|_u^h = 1$$
$$\text{iff } \exists j \in J_1, \|\#_j(r)\|_s^h = 1$$
$$\text{iff } \|\bigvee_{j \in J_1} \#_j(r)\|_s^h = 1.$$

A simple induction on the construction of $B_l$ then shows that $\|B_l\|_z^g = 1$ if and only if $\|A_l\|_z^h = 1$.

If we now take $A = \bigvee_l (D_l \land \bigvee_{i=1,\ldots,n} \#_i(A_l))$ where $D_l$ is obtained from $\alpha_l$ by replacing $Q_i(t)$ with $q_i$.

---

<!-- Page 17 -->

Then, for all $h, t$ such that $h(r) = \{t\}$,

$$\|A\|_t^h = 1$$
$$\text{iff } \exists l, \|D_l\|_t^h = 1 \text{ and } \exists i = 1, \ldots, n \text{ s.t. } \|\#_i(A_l)\|_t^h = 1$$
$$\text{iff } \exists i = 1, \ldots, n, \exists s \in T, \varphi_i(s, t) \text{ holds in } (T, <) \text{ and } \|A_l\|_s^h = 1$$
$$\text{iff } \exists l, \exists s \in T, \varphi_i(s, t) \text{ and } \|B_l\|_z^g = 1$$
$$\text{iff } \exists l, (T, <) \models \alpha_l(t, h(\bar{Q}))$$
$$\text{and } \exists l, \exists s\, \varphi_i(s, t) \text{ and } (T, <) \models \psi_l(t, s, h(\bar{Q}))$$
$$\text{iff } (T, <) \models \bigvee_l (\alpha_l \land \exists z\, \psi_l(t, z))$$
$$\text{iff } (T, <) \models \varphi$$

as required.

Finally we get rid of $r$.

Because of the separation property, $A$ is equivalent to a boolean combination $B(E_1, \ldots, E_L)$ of pure formulae $E_i$.

We define a new formula $E_i^*$ for each $E_i$. There are two cases. If $E_i$ is pure $\varphi_1$ then make $E_i^*$ by replacing each occurrence of $r$ by $\top$. If $E_i$ is pure $\varphi_j$ for some $j > 1$ then replace $r$ by $\bot$ to obtain $E_i^*$. It is easy to see that because of their purity we have in either case $\|E_i\|_t^h = 1$ iff $\|E_i^*\|_t^h = 1$ for any valuation $h$ which satisfies $(\star)$. For such a valuation we have $\|B(E_1, \ldots, E_L)\|_t^h = 1$ iff $(T, <) \models \varphi(t, h(\bar{Q}))$. But now the temporal formula $B(E_1^*, \ldots, E_L^*)$ does not contain $r$ and so we can drop the restriction on valuations and we have finished our induction step.

This completes the proof of the theorem. $\square$

## 9.5 Separation for General Time

As an example of the use of the generalized separation theorem of the last section let us prove a more specific result after choosing certain $\varphi_i$. For each $i = 1, \ldots, 4$, let $\varphi_i$ be given as follows:

- $\varphi_1(x, y) = (x = y)$,
- $\varphi_2(x, y) = (x < y)$,
- $\varphi_3(x, y) = (y < x)$, and
- $\varphi_4(x, y) = (x \neq y) \land \neg[(x < y) \lor (y < x)]$.

---

<!-- Page 18 -->

**Definition 9.5.1** Let $D$ be the connective given by

$$\|Dq\|_t^h = 1 \text{ iff } \exists s\, (\|q\|_s^h = 1).$$

and $\mathcal{T}$ be any class of flows of time. Then $A$ is said to be *pure parallel* over a class $\mathcal{T}$ of flows of time iff for all $t$ from any $(T, <)$ from $\mathcal{T}$, for all $h =_{\neq t} h'$,

$$\|A\|_t^h = \|A\|_t^{h'},$$

where $h =_{\neq t} h'$ iff $\forall s \neq t\, \forall q\, (s \in h(q) \Leftrightarrow s \in h'(q))$.

It is clear what separation means in the context of pure present, past, future, and parallel.

**Corollary 9.5.2** Let $L$ be a language with $F$, $P$, $D$ over any class of flows of time. Then $L$ has separation implies $L$ is expressively complete.

*Proof.* It is simple to check that the $\varphi_i$ satisfy the general separation property and other preconditions for using the generalized separation theorem.

Thus the theorem gives us our result immediately. $\square$
