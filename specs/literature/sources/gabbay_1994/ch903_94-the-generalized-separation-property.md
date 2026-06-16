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
