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
