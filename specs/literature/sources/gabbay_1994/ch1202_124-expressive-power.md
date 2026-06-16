## 12.4 Expressive power

From theorem 11.5.4 stating the expressive completeness of $U$, $S$, and the Stavi connectives over linear time, our first result falls out easily:

**Lemma 12.4.1** *Over flows of time with only isolated gaps, $\{U, S\}$ is expressively complete.*

This is because, over such flows,

$$U'(A, B) = \gamma^+(B) \land U(\sim B, \gamma_0^+(B) \lor A).$$

Kamp's pioneering theorem is then a special case of this lemma.

Our next lemma shows that gaps don't have to get much more complicated before Until and Since are not sufficient.

**Lemma 12.4.2** *In general linear time, $\{U, S\}$ is not expressively complete. There are even flows of time with a single non-isolated gap on which $\gamma^+$ is not expressible in terms of $\{U, S\}$.*

*Proof.* We take a flow of time $(T, <)$ with a single non-isolated gap and show that there is no temporal formula built from $\{U, S\}$ which is equivalent to $\gamma_0^+(p)$ on all temporal structures over $T$.

$T$ is constructed in two successive parts: the first one is obtained by taking a copy of $\mathbb{Z}$ for each negative integer and joining them into one long line, and the second has a copy of $\mathbb{Z}$ for each integer arranged in order. There is a gap at the beginning of the whole order and a gap at the end of each copy of $\mathbb{Z}$. The only non-isolated gap is that between the two parts.

A $p$-structure over $T$ will be called *nice* iff

---

<!-- Page 6 -->

- on each little copy of the integers, either $p$ is always true or always false, and
- every point has both $p$ and $\sim p$ true in both its past and future.

An easy induction with several cases shows that for any formula $\phi$ constructed from $p$ in the language $\{U, S\}$, there is a formula $p$, $\sim p$, $\top$ or $\bot$ which is uniformly equivalent to $\phi$ everywhere in all nice structures over $T$. It is easy to show, though, that these four formulae are all distinct in their truth conditions. For example, $U(p, p)$ is always equivalent to $p$.

So suppose, for contradiction, that we can express $\gamma_0^+(p)$ in $\{U, S\}$. By the above argument, we have a formula $\psi$ always equivalent to it over nice structures.

Look now at a particular, nice $p$-structure in which $p$ alternates in truth on copies of $\mathbb{Z}$ but is true in the last copy of the first part. Here $\gamma_0^+(p)$ is false. Thus $\psi$ must be either $\sim p$ or $\bot$.

Look next at a structure in which $p$ alternates in the first part, is true in the last copy of $\mathbb{Z}$ there, is false for an initial segment of the second part, and then alternates again. Here $\gamma_0^+(p)$ is true in the end of the first part. Thus $\psi$ must be either $p$ or $\top$ and we have our contradiction. $\square$

A similar proof to the above readily shows that

**Lemma 12.4.3** *If for all $i$, $m < n_i$ then $\gamma_m^+$ is not expressible over all linear flows by any formula built from $U$, $S$ and any (finite) number of $\gamma_{n_i}^+$.*

It is a little more difficult to prove that any $\gamma_n^+$ can be expressed in terms of $\gamma_m^+$ (in combination with $U$ and $S$) for any $n < m$.

**Lemma 12.4.4** *For any temporal formula $P$ and any $n > 0$,*

$$\gamma_{n+1}^+(P) = \gamma_0^+(P \land \gamma^+(P) \land \sim \gamma_n^+(P)).$$

*The dual result also holds.*

*Proof.* This is immediate from the more informative lemma which follows the next. $\square$

**Lemma 12.4.5** *Let $n > 0$ and $P$ be any temporal formula. We write $Q$ for $P \land \gamma^+(P) \land \sim \gamma_n^+(P)$ and consider the left $P$ gaps in a structure.*

- *Every left $Q$ gap is a left $P$ gap.*
- *No order $n$ left $P$ gap is a left $Q$ gap.*
- *All the other left $P$ gaps are left $Q$ gaps.*

*The dual result also holds.*

---

<!-- Page 7 -->

*Proof.*

- To prove the first claim let us examine a left $Q$ gap $\alpha$ say. $Q$ is true in an interval, containing a point $t$ say, on the left of $\alpha$ and false arbitrarily soon after. $P$, as a conjunct of $Q$, is thus true from $t$ until $\alpha$. If $P$ is false arbitrarily soon after $\alpha$ then we have a left $P$ gap at $\alpha$ as required. Suppose for contradiction that $P$ is instead true for a while after $\alpha$. Thus, like $P$, $\gamma^+(P)$ must stay true for a while after $\alpha$. Finally, look at the third conjunct, $\sim \gamma_n^+(P)$, of $Q$. Since it is also true at $t$, $\alpha$ cannot be an order $n$ left $P$ gap and again the conjunct remains true after $\alpha$, at least as far as $\beta$. We have shown that $Q$ remains true before and after $\alpha$ and we have our desired contradiction.

- The second observation is clear as $\gamma_n^+(P)$ is true arbitrarily recently before an order $n$ left $P$ gap.

- For the third let us look at a non-$n$th-order left $P$ gap. For a while, on the left $P$, $\gamma^+(P)$ and $\sim \gamma_n^+(P)$ are all true. Since $P$, and hence $Q$, is false arbitrarily soon after the gap, we have a left $Q$ gap. $\square$

Now we can actually be more specific about the orders of the gaps involved:

**Lemma 12.4.6** *Let $k$ and $n$ be whole numbers and $P$ be any temporal formula. We write $Q = P \land \gamma^+(P) \land \sim \gamma_n^+(P)$ and consider the left $P$ gaps in a structure.*

*Any order $k$ left $P$ gap is*
- *an order $k$ left $Q$ gap if $k < n$,*
- *not a left $Q$ gap at all if $k = n$, and*
- *an order $k - 1$ left $Q$ gap if $k > n$.*

*Any order $k$ left $Q$ gap is*

---

<!-- Page 8 -->

- *an order $k$ left $P$ gap if $k < n$, and*
- *an order $k + 1$ left $P$ gap if $k \geq n$.*

*The dual result with right substituted for left also holds.*

*Proof.* Fix $n$. Now we proceed by induction on $k$.

**First part.** Suppose that we have an order $k$ left $P$ gap at $\alpha$. If $k = n$ then the preceding lemma gives us our result. So suppose not. Thus $\alpha$ is a left $Q$ gap. We will show that $\alpha$ is an order $K$ left $Q$ gap where

$$K = \begin{cases} k & \text{if } k < n \\ k - 1 & \text{if } k > n \end{cases}$$

Now for a while after $\alpha$ any left $P$ gaps are of order less than $k$. Any left $Q$ gaps which are in this interval are then, by the preceding lemma, left $P$ gaps and so of order less than $k$ as left $P$ gaps. If $k < n$ then these gaps are, by the inductive hypothesis, left $Q$ gaps of the same order less than $k = K$. If $k > n$ then these gaps are, also by the inductive hypothesis, left $Q$ gaps of order one less than their order as $P$ gaps, which is less than $K = k - 1$. In either case, for a while after $\alpha$, all left $Q$ gaps are of order less than $K$.

If $K = 0$ then we have shown that $\alpha$ is an isolated left $Q$ gap. Otherwise, since $\alpha$ is an order $k$ left $P$ gap it must have order $k - 1$ left $P$ gaps arbitrarily soon afterwards. There are three cases:
- if $k < n$ then by the inductive hypothesis these are order $K - 1 = k - 1$ left $Q$ gaps;
- if $k > n + 1$ then these are order $k - 2 = K - 1$ left $Q$ gaps; and
- if $k = n + 1 > 1$ then the order $k - 1 = n > 0$ left $P$ gaps are also followed arbitrarily closely by order $k - 2$ left $P$ gaps which are, by the inductive hypothesis, also order $k - 2 = K - 1$ left $Q$ gaps;
- if $k = n + 1 = 1$ then $K = k - 1 = 0$, which we have supposed not to be the case.

This proves that $\alpha$ is a left $Q$ gap of order $K$.

**Second part.** Suppose that $\alpha$ is an order $k$ left $Q$ gap. It is also a left $P$ gap. We will show that it is also an order $K$ left $P$ gap where

$$K = \begin{cases} k & \text{if } k < n \\ k + 1 & \text{if } k \geq n \end{cases}$$

---

<!-- Page 9 -->

For a while after $\alpha$ all left $Q$ gaps are of orders less than $k$. By our inductive hypothesis they will also be left $P$ gaps of various finite orders. Thus $\alpha$ must be a finite-order left $P$ gap, say, of order $\ell$. We know that $\ell$ is not $n$ for then $\alpha$ wouldn't be a left $Q$ gap at all.

By the first part, if $\ell < n$ then $k = \ell$ so $K = k = \ell$ as required. If $\ell > n$ then $k = \ell - 1 \geq n$ so $K = k + 1 = \ell$ as required. $\square$

Now what if we can use $\gamma_0^\pm$? Let us consider the new set of connectives $\{U, S, \gamma_0^+, \gamma_0^-\}$ and ask about its expressive power. In fact, the connectives which talk of higher-order gaps are redundant. In expressive power, the $\gamma$ hierarchy collapses: for each $n > 0$,

$$\gamma_{n+1}^+(P) = \gamma^+(P) \land \sim \gamma_{\leq n}^+(P) \land \gamma^+(\gamma^+(P) \land \sim \gamma_{\leq n}^+(P)) \land U'(\gamma^+(P) \to \gamma_{\leq n}^+(P), \sim \gamma^+(P) \lor \gamma_{\leq n}^+(P)).$$

Thus one might think that higher-order gaps hold no surprises for $\{U, S, \gamma_0^\pm\}$. In fact we do not even need to stop at finite orders.

**Lemma 12.4.7** *$\{U, S, \gamma_0^\pm\}$ is expressively complete over general linear time.*

*Proof.* We will exhibit a $\{U, S, \gamma_0^\pm\}$ formula which is equivalent to $U'(p, q)$ in any $\{p, q\}$-structure. Because the dual formula will be equivalent to $S'(p, q)$, we will have shown that $\{U, S, \gamma_0^\pm\}$ is expressively complete over such structures.

Let $\phi$ be:

$$\gamma_0^+(q) \land U(U(\sim q, p), q) \lor \gamma^+(q) \land U(\sim q, \gamma_0^+(\sim U(\sim q, p)) \lor p) \land \sim U(\sim q, \sim U(\sim q, p)).$$

Suppose that $B$ is a $\{p, q\}$-structure. We will show that for any $b \in B$, $B \models U'(p, q)(b) \iff B \models \phi(b)$.

$(\Leftarrow)$ Let us assume that $\phi$ holds at $b$. We must show that $U'(p, q)$ is true at $b$. There are two cases.

If the first disjunct holds then it is clear that $U'(p, q)$ does too.

---

<!-- Page 10 -->

Now suppose that the second disjunct of $\phi$ holds at $b$ but that the first does not. The first conjunct guarantees that $q$ is true from $b$ up until a gap which we can call $\beta$. $\sim q$ is true arbitrarily soon after $\beta$.

For contradiction we also suppose that $U'(p, q)$ does not hold at $b$. Thus $p$ is false arbitrarily soon after $\beta$. Since $U(\sim q, \gamma_0^+(\sim U(\sim q, p)) \lor p)$ holds at $b$, we have $\gamma_0^+(\sim U(\sim q, p))$ true arbitrarily soon after $\beta$.

Since $q$ is true up until $\beta$ but $p$ is false arbitrarily soon afterwards, we must have $\sim U(\sim q, p)$ holding from $b$ at least up until $\beta$. But $\sim U(\sim q, \sim U(\sim q, p))$ holds at $b$ so $U(\sim q, p)$ must be true arbitrarily soon after $\beta$.

So $\sim U(\sim q, p)$ is true up until $\beta$ but false arbitrarily soon afterwards. Thus $\gamma^+(\sim U(\sim q, p))$ holds at $b$ and $\beta$ is the $\sim U(\sim q, p)$ left gap involved.

Knowing that both $U(\sim q, p)$ and $\gamma^+(\sim U(\sim q, p))$ are true arbitrarily soon after $\beta$ tells us that there are $\sim U(\sim q, p)$ left gaps arbitrarily soon after $\beta$.

Thus $\beta$ is not an isolated $\sim U(\sim q, p)$ left gap and this contradicts $\gamma_0^+(\sim U(\sim q, p))$ holding at $b$. We are done.

$(\Rightarrow)$ Suppose that $B \models U'(p, q)(b)$. So $q$ is true for a while after $b$ up until a gap, called $\beta$, say. We must show that $\phi$ is true at $b$. There are two cases.

If $p$ is true for a while before $\beta$ as well as after then it is clear that the first disjunct of $\phi$ holds at $b$.

So let us assume that $p$ is false arbitrarily soon before $\beta$.

In this case it is not difficult to see that the second disjunct of $\phi$ holds at $b$. To see that those conjuncts involving $\sim U(\sim q, p)$ hold, one need only notice that $\sim U(\sim q, p)$ holds from $b$ up until $\beta$ and is false for a while afterwards. It is false after the gap, i.e. $U(\sim q, p)$ holds because $p$ is true for a while and $\sim q$ is true arbitrarily soon after $\beta$. $\square$

---

## 12.5 Other connectives

The connective

$$\rho^+(q) = U'(\sim q, q)$$

and its dual $\rho^-$ could equally well have been used in this chapter instead of $\gamma_0^\pm$. We can define

$$\gamma_0^+(p) = \rho^+(\gamma^+(p))$$

---

<!-- Page 11 -->

so that the set $\{U, S, \rho^\pm\}$ is expressively complete.

$U_{ng}(p, q)$ iff $q$ holds until a gap after which it is arbitrarily soon false and after which there are no left $p$ gaps for a while. Dually we define $S_{ng}$. Note that $\gamma_0^+(p)$ equals $U_{ng}(p, p)$. Thus $\{U, S, U_{ng}, S_{ng}\}$ is expressively complete.

We say that a $p$ left gap is *pure* if it is not itself an isolated $p$ left gap but there are no isolated $p$ gaps for a while after the gap. Lemma 12.3.1 above shows that pure gaps have non-ordinal order. The non-ordinal order gaps constructed in the example above are pure. We can define a new connective using purity: $\gamma_\pi^+(q)$ holds iff $\gamma^+(q) \land U(\sim q, \sim \gamma_0^+(q))$ does.

An argument similar to the proof of lemma 12.4.2 shows that $\gamma_\pi^+$ is not expressible in terms of $U$ and $S$. We compare the truth of $\gamma_\pi^+(p)$ before gaps in two different structures. In one $p$ is true up until a gap, after which $p$ is false for a while. In the other $p$ is true up until a gap, after which open intervals of $p$ being true, and open intervals of $p$ being false replace rational numbers in an interval from that ordering.

The proof of lemma 12.4.2 can also be employed to show that $\gamma_0^+$ cannot be expressed in terms of $U$, $S$, or $\gamma_\pi^\pm$. Clearly, $\gamma_\pi^+(p)$ is always false in the structures defined there.

---
