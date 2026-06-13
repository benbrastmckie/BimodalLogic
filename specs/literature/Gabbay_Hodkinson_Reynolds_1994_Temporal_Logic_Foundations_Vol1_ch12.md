# Chapter 12: Further Expressive Completeness Results

## 12.1 Introduction

In this chapter we prove the same result as we did in the last. First we will examine the idea of gaps in the flow of time in some detail. Then we will introduce some new connectives to talk about such gaps and use the expressive completeness of the Stavi connectives to deduce expressive completeness results for these new connectives. We also present some axiomatizations of these connectives.

Finally, we prove the expressive completeness of the Stavi connectives again but this time we do not use separation. Instead we present a more direct proof using games. Generalizations of such a proof may be useful in cases where separation is difficult to show.

---

<!-- Page 1 -->

## 12.2 Gaps in the flow of time

We identify gaps in a flow of time with supremum-less, non-empty, proper initial segments of the order and insert the gap in the appropriate place in the order. Dedekind complete orders, then, are those without gaps. The completion $T_*$ of an order $T$ is another order consisting of $T$ and all the gaps in the right places, and is Dedekind complete.

The simplest kind of gap imaginable is an *isolated gap* which exists in an open interval of time which is otherwise gap-free. Taking one point out of the reals or sticking two copies of the integers together are two straightforward ways of producing an isolated gap.

---

<!-- Page 2 -->

We are going to define a hierarchy of kinds of gaps. For any (zero, successor or limit) ordinal $\alpha$, an $\alpha$th-order gap is a gap which is not of lesser order but lies in an open interval which contains, apart from itself, only gaps of order less than $\alpha$. So a zero-order gap is just an isolated gap.

Of course this hierarchy does not include all the possible gaps. For example, nowhere in the rationals is there a gap of any order at all.

We will use the game characterization of unranked gaps. Let $\gamma_0$ be a gap of $T$. Players $\forall$ and $\exists$ move alternately, defining a sequence $\gamma_i$ ($0 < i < \omega$) of gaps. In each round, $\forall$ chooses an open interval $I_i$ containing $\gamma_i$, and $\exists$ chooses $\gamma_{i+1} \in I_i$ with $\gamma_{i+1} \neq \gamma_i$. $\exists$ wins iff the game goes on for $\omega$ moves. $\gamma_0$ is *unranked* iff $\exists$ has a winning strategy for the game.

To see this, one can employ a straightforward transfinite induction to show that if $\gamma_0$ is ranked then $\forall$ has a winning strategy. This simply involves continually choosing open intervals around gap $\gamma_i$ which contain, apart from $\gamma_i$ itself, only gaps of lesser ranks. Conversely it can be seen that if $\gamma_0$ is unranked then every open interval containing it also contains other unranked gaps. $\exists$ can win by always choosing unranked gaps.

It is interesting to note that if all gaps in a flow of time have ordinal order then the cardinality of the flow is at least as great as the cardinality of any of those orders, and for every infinite ordinal $\alpha$, there exists a flow of time of cardinality the same as $\alpha$ with a gap of order $\alpha$.

**Definition 12.2.1** Let $T$ be a linear order of cardinality $\kappa$, and suppose that $\Gamma$ is a set of gaps of $T$. A gap $\gamma$ of $T$ is said to be $\Gamma$-*rich* if every open interval $I$ of $T$ containing $\gamma$ contains $\geq \kappa^+$ gaps from $\Gamma$. Here, $\kappa^+$ is the next largest cardinal after $\kappa$.

**Proposition 12.2.2** *Let $T$ be a linear order of cardinality $\kappa$. Suppose that $\Gamma$ is a set of gaps of cardinality $\geq \kappa^+$. Then there is a $\Gamma$-rich gap $\gamma \in \Gamma$.*

*Proof.* If not, for each $\gamma \in \Gamma$ choose an open interval $I_\gamma$ with endpoints $a_\gamma < b_\gamma$ in $T$, such that $\gamma \in I_\gamma$ and $|I_\gamma \cap \Gamma| \leq \kappa$. As $|\Gamma| > \kappa$, there is $\Gamma' \subseteq \Gamma$ with $|\Gamma'| > \kappa$ and $I_\gamma = I$, say, for all $\gamma \in \Gamma'$. Then $\Gamma' \subseteq I$, a contradiction. $\square$

**Corollary 12.2.3** *Let $T$ be a linear order of cardinality $\kappa$. Then $T$ has at most $\kappa$ ranked gaps.*

*Proof.* Assume not. Let $\Gamma$ be a set of $\kappa^+$ ranked gaps of $T$. We will show that any $\Gamma$-rich gap is unranked; this will contradict the proposition.

Let $\gamma_0$ be a $\Gamma$-rich gap. $\forall$ and $\exists$ will play the game above, starting with $\gamma_0$. $\exists$ will privately construct sets $\Gamma_i$ ($i < \omega$) of $\kappa^+$ ranked gaps, so that each $\gamma_i$ is $\Gamma_i$-rich. She begins by defining $\Gamma_0 = \Gamma$.

---

<!-- Page 3 -->

Inductively assume that $i < \omega$, and $\gamma_i$ is a $\Gamma_i$-rich gap. $\forall$ chooses an interval $I_i = (a, b)$, say, around $\gamma_i$. $I_i$ contains $\kappa^+$ gaps from $\Gamma_i$. Let $\Gamma_{i+1}$ be the gaps from $\Gamma_i$ contained in $(a, \gamma_i)$ if this set has cardinality $\kappa^+$; otherwise let $\Gamma_{i+1}$ be the gaps from $\Gamma_i$ contained in $(\gamma_i, b)$. So in any case, $|\Gamma_{i+1}| = \kappa^+$. By the proposition, $\exists$ can choose a $\Gamma_{i+1}$-rich gap $\gamma_{i+1} \in \Gamma_{i+1}$. If she does this, the game goes on forever and she wins. Hence $\gamma_0$ was unranked, as required. $\square$

**Corollary 12.2.4** *Let $T$ be a linear order of cardinality $\kappa$ and let $\gamma$ be a ranked gap of $T$. Then $|\text{rank}(\gamma)| \leq \kappa$.*

*Proof.* Any gap $\gamma$ of rank $\alpha$ has gaps of rank $\beta$ arbitrarily close, for all $\beta < \alpha$. So if $T$ has a gap of rank $\alpha$ with $|\alpha| > \kappa$, then $T$ has more than $\kappa$ ranked gaps. The result now follows from the preceding corollary. $\square$

---

## 12.3 Connectives to talk about gaps

Recall from section 6.1 that the Stavi connectives $U'$ and $S'$, which, as we have seen in chapter 11, do talk about gaps, have first-order tables. By presenting our new connectives below in terms of $U$, $S$, $U'$, and $S'$ we thus guarantee that they are also first-order.

We start off with some new unary connectives which talk about a single gap located by the vicissitudes of a single temporal formula. First we need to know that there is a gap coming up:

$$\gamma^+(A) = U(\sim A, \top) \land U(A, A) \land \sim U(\sim U(\top, A), A).$$

This is true whenever $A$ holds up until a gap but fails to hold arbitrarily soon afterwards. We call such a gap an $A$ *left gap*: $A$ is true on the left of the gap. See figure 12.1. Dually we can define $\gamma^-$ and $A$ *right gaps*. Notice that $\gamma^\pm$ are expressible in $\{U, S\}$.

Next we specify that the gap coming up is isolated, as far as gaps definable by the same formula and in the same direction go:

$$\gamma_0^+(A) = \gamma^+(A) \land U'(\sim \gamma^+(A), A).$$

---

<!-- Page 4 -->

Dually we can define $\gamma_0^-$. Notice that we use the Stavi connectives here. Now we can recursively define a hierarchy of connectives. For every $n > 0$, define

$$\gamma_{\leq n}^+(A) = \gamma_0^+(A) \lor \cdots \lor \gamma_n^+(A)$$

and

$$\gamma_{n+1}^+(A) = \gamma^+(A) \land \sim \gamma_{\leq n}^+(A) \land U'(\gamma^+(A) \to \gamma_{\leq n}^+(A), A).$$

$\gamma_{\leq n}^-$ and $\gamma_{n+1}^-$ are defined dually.

Notice that there is a distinction between gaps in the flow of time and gaps definable by a particular temporal formula or even by any temporal formula. Thus we need to define another hierarchy of gaps---this time within a temporal structure rather than just in a flow of time. Let $A$ be a temporal formula. For any ordinal $\alpha$, an $\alpha$th-order $A$ *left gap* is an $A$ left gap which is not of lesser order but begins an interval containing only $A$ left gaps of lesser order. Dually we can define $A$ right gaps of each order.

For $\alpha < \omega$, gap $\gamma$ is an $\alpha$th-order $A$ left gap if and only if $\gamma_\alpha^+(A)$ holds in an interval on the left of $\gamma$. We consider the possibility of $\gamma_\alpha^+(A)$ for $\alpha \geq \omega$ later.

We have mentioned the distinction between $\alpha$th-order $A$ gaps and $\alpha$th-order gaps in the flow of time. Nevertheless, it is clear that there is only an $A$ gap when there is a gap in time at the right place and that it is an $A$ gap of order $\beta$ when that gap in time is at least of order $\alpha$ or possibly of non-ordinal order.

### 12.3.1 Construction of a non-ordinal order definable gap

In this subsection we will demonstrate the existence of definable gaps which do not fit into our scheme of classification. The idea is Robin Hirsch's.

We create a flow of time from a certain subset of the set $\mathbb{Q}^*$ of finite sequences of rational numbers. Let $T$ consist of those non-empty sequences in which every rational number but the last is a power of $1/2$ and the last number in the sequence is neither a power of $1/2$ nor zero. We order the sequences as follows: $(a_0, a_1, \ldots, a_m) < (b_0, b_1, \ldots, b_n)$ iff there is some $k \geq 0$ such that $k \leq n$, $k \leq m$, for all $i < k$, $a_i = b_i$, and $a_k < b_k$.

We turn $(T, <)$ into a $\{p\}$-structure by making $T \models p(t)$ if and only if the last number in the sequence $t$ is negative.

---

<!-- Page 5 -->

Each $p$ left gap in $T$ occurs just after the segment $(a \cdot (-1), a \cdot 0)$ where $a$ is a sequence of powers of $1/2$ (possibly the empty sequence).

It is easy to prove that none of these gaps is isolated. Let $(a \cdot 0, t)$ be any open interval after a gap. If $t$ is not of the form $a \cdot q \cdot b$ for some possibly empty sequence $b$ and some rational $q$, then we show that there is a left gap in $(a \cdot 0, a \cdot 1)$ and note that $a \cdot 1$, which is of that form, must be less than $t$. So wlog $t$ is $a \cdot q \cdot b$. Let $r$ be any power of $1/2$ less than $q$. Clearly, all elements of $T$ of the form $a \cdot r \cdot s$ are in the interval $(a \cdot 0, t)$ and so is the gap at $a \cdot r \cdot 0$.

Now a very straightforward transfinite induction proves that

**Lemma 12.3.1** *For any formula $A$ and any non-zero ordinal $\alpha$, each $\alpha$th order $A$ left gap is followed arbitrarily soon by zero-order $A$ left gaps.*

So if a flow has no isolated $p$ left gaps then it has no $p$ left gaps of any order at all and we have our result.

---

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

## 12.6 An axiomatization of $U$, $S$, $\gamma_0^+$, $\gamma_0^-$ using the irreflexivity rule

We first axiomatize $U$, $S$, and $\gamma_0^\pm$ over arbitrary linear flows of time using the irreflexivity rule of [Gabbay, 1981b]. This rule allows simple axiomatizations of many temporal connectives over irreflexive flows of time. We derive some simple consequences and list some open questions. In the next section we will relate some of these questions to the class of scattered flows of time.

In this section, unless otherwise stated, a temporal formula will mean one written with the connectives $U$, $S$, $\gamma_0^+$, $F$, and $\gamma_0^-$. We will use the standard abbreviations $F$, $P$, $H$, and $G$: $Fp$ abbreviates $U(p, \top)$, etc. Recall also that $K^+(q)$ abbreviates $\sim U(\top, \sim q)$ and $\gamma^+(q)$ abbreviates $F\sim q \land U(q, q) \land \sim U(\sim q \lor K^+(\sim q), q)$; and similarly for $K^-$ and $\gamma^-$.

We adopt as axioms the following:

1. All truth functional tautologies.

2. $G(p \to q) \to (Gp \to Gq)$, $H(p \to q) \to (Hp \to Hq)$.

3. $q \to GPq$, $q \to HFq$.

---

<!-- Page 12 -->

4. $FFq \to Fq$ [transitivity].

5. $G(p \land Gp \to q) \lor G(q \land Gq \to p)$, $H(p \land Hp \to q) \lor H(q \land Hq \to p)$ [linearity].

6. $r \land \sim H\sim r \to [U(p, q) \leftrightarrow F(p \land H(Pr \to q))]$, $r \land \sim H\sim r \to [S(p, q) \leftrightarrow P(p \land G(F(r \land H\sim r) \to q))]$.

7. $r \land H\sim r \to [\gamma_0^+(q) \leftrightarrow (\gamma^+(q) \land F(\sim q \land H(P(\sim q \land Pr) \to \sim \gamma^+(q))))]$, $r \land \sim H\sim r \to [\gamma_0^-(q) \leftrightarrow (\gamma^-(q) \land P(\sim q \land G(F(\sim q \land F(r \land H\sim r)) \to \sim \gamma^-(q))))]$.

The rules of inference are:
- modus ponens
- substitution
- generalization: $\vdash A \Rightarrow \vdash GA \land HA$
- irreflexivity: $\vdash Fr \land H\sim r \to A \Rightarrow \vdash A$ (for all $A$ and atoms $r$ not occurring in $A$).

These axioms and rules are valid over irreflexive linear time.

**Definition 12.6.1** If $A$ is a temporal formula, $N$ a temporal structure, and $t$ a point of the flow of time of $N$ (for short, '$t \in N$'), we write $N \models A(t)$ if $A$ holds at $t$ in $N$.

Take any set $\Sigma$ of temporal formulae. A model of $\Sigma$ will be an irreflexive linear temporal structure $N$ such that for some $t \in N$, $N \models A(t)$ for all $A \in \Sigma$.

**Theorem 12.6.2** *(completeness) Given any countable consistent set $\Sigma$ of formulae, there is a countable model $N$ of $\Sigma$ in which all instances of the axioms are valid at every point.*

*Proof (sketch, see chapter 6 for details).* Using standard techniques we can obtain a countable irreflexive linear temporal structure $N$ whose points are maximal consistent sets of temporal formulae. The irreflexivity rule allows us to assume that for each $t \in N$ there is an atom $r$ with $r \land H\sim r \in t$. Further:

- There is $t_0 \in N$ with $\Sigma \subseteq t_0$.
- For all atoms $q$ and all $t \in N$, $N \models q(t)$ iff $q \in t$.
- For each formula $A$ there is an atom $q$ such that $A \leftrightarrow q \in t$ for all $t \in N$.

---

<!-- Page 13 -->

- For all formulae $A$ built using only $F$ and $P$, and all $t \in N$, $A \in t$ iff $N \models A(t)$.

It now easily follows that for all $t \in N$ and all temporal formulae $A$, $N \models A(t)$ iff $A \in t$. The proof is by induction on the structure of $A$ using axioms (6) and (7) (cf. theorem 6.3.5). Hence as $\Sigma \subseteq t_0$, we have constructed a model of $\Sigma$. $\square$

**Question.** Is there an axiomatization of $U$, $S$, and $\gamma_0^\pm$ without using the irreflexivity rule? Burgess axiomatizes $U$ and $S$ over arbitrary linear time in [Burgess, 1982a], without using this rule.

Even if the answer is negative, we still obtain the following corollaries, whose statements do not mention the irreflexivity rule.

**Corollary 12.6.3** *(compactness) Let $\Sigma$ be a set of temporal formulae (of $U$, $S$, $\gamma_0^+$ and $\gamma_0^-$). Suppose that every finite subset of $\Sigma$ has a model. Then $\Sigma$ has a model.*

*Proof.* With the given axioms and finitary rules, no contradiction is derivable from $\Sigma$. Hence by theorem 12.6.2 $\Sigma$ has a model as stated. $\square$

**Corollary 12.6.4**

1. *The connective $\gamma_{\geq \omega}^+(\cdot)$, saying that there is a gap of rank at least $\omega$ coming up on the right, is not definable by any first-order formula.*

2. *Not both of the connectives $\gamma_\omega^+(\cdot)$ and $\gamma_{\text{ordinal}}^+(\cdot)$, saying that coming up on the right is a gap of rank $\omega$, or (respectively) ordinal rank, are first-order definable.*

*Proof.*

1. Assume for contradiction that $\gamma_{\geq \omega}^+(q)$ has a first-order table. Hence by expressive completeness of $\{U, S, \gamma_0^+, \gamma_0^-\}$ (lemma 12.4.8 above) there is already a temporal formula equivalent to $\gamma_{\geq \omega}^+(q)$. So consider $\Sigma = \{\sim \gamma_{\geq \omega}^+(q) \land \gamma_{\leq n}^+(q) : n < \omega\}$. Every finite subset of $\Sigma$ has a model, but $\Sigma$ does not. This contradicts the preceding corollary.

2. We have $\gamma_{\leq \omega}^+(q) = \gamma^+(q) \land \sim \gamma_{\text{ordinal}}^+(q) \lor \gamma_\omega^+(q) \lor \sim U'(\sim \gamma_\omega^+(q), q)$, so the definability of both of $\gamma_\omega^+$ and $\gamma_{\text{ordinal}}^+$ would contradict (1). $\square$

---

<!-- Page 14 -->

**Questions**

1. Is $\gamma_\omega^+$ definable? Note that $\gamma_\omega^+$ is definable from $\gamma_{\geq \omega}^+$ by $\gamma_\omega^+(q) = \gamma_{\geq \omega}^+(q) \land U'(\sim \gamma_{\geq \omega}^+(q), q)$.

2. Is $\gamma_{\text{ordinal}}^+$ first-order definable?

By corollary 12.6.4 (part 2), relevant to the definability of $\gamma_\omega^+$, is the fact that the flows of time in which there are essentially no unranked gaps are essentially exactly the scattered flows: those that do not embed the rationals. They are our next topic.

---

## 12.7 Unranked gaps and scattered flows of time

We will observe that any temporal logic with first-order connectives over the class of all scattered flows of time is decidable. This gives a weak recursive axiomatization of the temporal structures with scattered flows of time, though a strong axiomatization is not possible (cf. the discussion after proposition 12.7.4).

Recall that a $q$-definable gap (one where $\gamma^+(q)$ holds on some interval to the left) is of rank $\infty$ ('unranked') if it is not of rank $\alpha$ for any ordinal $\alpha$. An example of such gaps was given in section 12.3.1. They can also be exhibited by first defining $N_i$ ($i = 0, 1$) to be a structure with flow of time $\mathbb{Q}$, on which $q$ is always true ($i = 1$) or always false ($i = 0$), and then replacing each $i \in \mathbb{Q}$ by a copy of $N_0$ or $N_1$ in such a way that any interval of $\mathbb{Q}$ contains copies of both structures. Let $\mathcal{Q}$ be the resulting temporal structure. Each $i \in \mathbb{Q}$ that is given a copy of $N_1$ yields a pure unranked $q$-gap in $\mathcal{Q}$ corresponding to the 'right-hand end' of that copy. Note that the flow of time of $\mathcal{Q}$ is isomorphic to $\mathbb{Q}$.

We defined unranked gaps of a flow of time in section 12.2. As an example, all gaps in $\mathbb{Q}$ are unranked. Flow-of-time gaps may not be 'definable' by a temporal formula (i.e. detectable by $\gamma^+$). However, note that an unranked definable gap is also an unranked flow-of-time gap.

**Definition 12.7.1**

1. If $I$ is a linear order and $x, y \in I$ we will write $[x, y]$ for the closed interval of $I$ with endpoints $x, y$. This extends the usual notation to the case where $x > y$.

2. An equivalence relation $\equiv$ on a linear ordering $I$ is called a *condensation* if the $\equiv$-classes are convex (i.e. are intervals, but possibly

---

<!-- Page 15 -->

   one-point intervals or with gaps for endpoints). Note that if $\equiv$ is a condensation, the ordering of $I$ induces a canonical linear ordering of $I/{\equiv}$. Strictly speaking, the condensation is this linear ordering, and not the corresponding relation $\equiv$.

3. Recall that $I$ is said to be *scattered* if $\mathbb{Q}$ does not embed into $I$. See [Rosenstein, 1982] for general information on scattered orderings.

**Proposition 12.7.2** *(cf. [Doets, 1989], lemma 2.3) A linear ordering $I$ is scattered iff whenever $\equiv$ is a condensation of $I$, $I/{\equiv}$ is not dense.*

*Proof.*

$(\Rightarrow)$ If $\equiv$ is a dense condensation of $I$, we can use the axiom of choice to choose a set of representatives of the $\equiv$-classes. Some subset of this will have order type $\mathbb{Q}$.

$(\Leftarrow)$ If $\mathbb{Q} \subseteq I$ define $\equiv$ on $I$ by $x \equiv y$ iff $[x, y] \cap \mathbb{Q}$ is finite. Clearly, $I/{\equiv}$ is dense. $\square$

**Theorem 12.7.3** *Let $I$ be a linear ordering.*

1. *Suppose that $I$ is scattered. Then there are no unranked flow-of-time gaps in $I$.*

2. *Assume that $I$ is countable and that no temporal structure $M$ with flow of time $I$ has unranked definable gaps. Then $I$ is scattered.*

*Proof.*

1. Clearly, ($*$) any open interval of $I$ containing an unranked gap contains infinitely many unranked gaps. Suppose that $\gamma_0$ is an unranked gap of $I$. We define a chain of finite sets $S_n \subseteq I$ by induction on $n$ so that for all adjacent points $i < j$ in $S_n$, the open interval $(i, j)$ contains (a) an unranked gap, and (b) a point of $S_{n+1}$.

   Choose $i_0 < \gamma_0 < i_1$ arbitrarily and let $S_0 = \{i_0, i_1\}$. Let $S_n = \{s_0, \ldots, s_k\}$ be given, satisfying (a) and with $s_0 < s_1 < \cdots < s_k$. By ($*$), for each $i < k$ we can take $s_i < t_i < s_{i+1}$ such that both $(s_i, t_i)$ and $(t_i, s_{i+1})$ contain unranked gaps. Define $S_{n+1} = S_n \cup \{t_i : i < k\}$. Clearly, (b) holds now for $S_n$ and (a) holds for $S_{n+1}$.

   Having defined the $S_n$, we observe that $\bigcup_{n < \omega} S_n$ has order type $\mathbb{Q} \cap [0, 1]$, so that $\mathbb{Q}$ embeds into $I$. Hence $I$ is not scattered.

---

<!-- Page 16 -->

   Note that in the case where $I$ is already a temporal structure and $\gamma_0$ is a $q$-definable gap, the same argument shows that the extensions (truth sets) in $I$ of $q$ and of $\sim q$ both embed $\mathbb{Q}$.

2. The example $I = \mathbb{R}$ shows that the theorem can fail if the assumption of countability is discarded. Assume that $I$ is not scattered. Let $\equiv$ be a condensation of $I$ such that $(I/{\equiv}) \cong \mathbb{Q} \cap [0, 1]$ (use proposition 12.7.2, the countability of $I$, and Cantor's theorem). Let $\mathcal{Q}^*$ be obtained from the structure $\mathcal{Q}$ made from $N_0$ and $N_1$ as above, by adding left and right endpoints at which $q$ is false (say). Hence there is an order isomorphism $\theta : I/{\equiv} \to \mathcal{Q}^*$. Define $I$ as a $q$-structure $M$ by: if $m \in I$, $M \models q(m)$ iff $\mathcal{Q}^* \models q(\theta(m/{\equiv}))$. Then each unranked $q$-definable gap of $\mathcal{Q}^*$ gives rise to a similar gap in $M$. $\square$

If the compactness theorem held for the scattered orderings, then non-definability of $\gamma_\omega^+$ (even in the class of scattered orderings) would again follow. For the preceding argument using compactness would show that $\gamma_{\geq \omega}^+$ is not definable even over the scattered orderings. But $\gamma_{\leq \omega}^+(q) = \gamma^+(q) \land [\sim \gamma_{\text{ordinal}}^+(q) \lor \gamma_\omega^+(q) \lor \sim U'(\sim \gamma_\omega^+(q), q)]$, as above. In scattered orderings, because of theorem 12.7.3 we have $\gamma_\pi^+(q) = \gamma^+(q) \lor \gamma^+(\sim \gamma_\omega^+(q))$, so that $\gamma_\omega^+$ being definable would force $\gamma_{\geq \omega}^+$ to be definable, a contradiction.

However, we now show that this is not the case.

**Proposition 12.7.4** *The compactness theorem fails for the class of scattered orderings.*

*Proof.* Introduce propositional atoms $q_i$ ($i \in \mathbb{Q}$). Let $\Sigma = \{P(q_i \land H\sim q_i \land Pq_j) : j < i \text{ in } \mathbb{Q}\}$. Then any finite subset of $\Sigma$ has a scattered model. But if $M$ were a scattered model of $\Sigma$, then $\mathbb{Q}$ would embed into $M$ via $i \mapsto m_i$ where $m_i \in M$ satisfies $M \models (q_i \land H\sim q_i)(m_i)$. $\square$

Now the rules of inference are finitary, so completeness implies compactness. Hence, for the class of scattered orderings, there is no completeness theorem of the form: $\Sigma$ is consistent iff $\Sigma$ has a scattered model. However, there is a weak completeness theorem that deals with the case where $\Sigma$ is finite. That is, there is a recursive set of axioms such that $\vdash A$ iff $\models A$ for all temporal formulae $A$. This follows trivially from the following decidability result.

---

<!-- Page 17 -->

**Proposition 12.7.5**

1. *The monadic second-order theory of the class of countable scattered linear orders is decidable.*

2. *Over scattered flows of time, any temporal logic using connectives with first-order tables is decidable.*

*Proof.*

1. Let $\sigma$ be a monadic second-order sentence in the signature $\{=, <\}$, where quantification over elements and subsets is allowed. Let $Q$ be a new unary relation symbol and let $\sigma^Q$ denote the relativization of $\sigma$ to $Q$ (i.e. the first-order quantifiers $\exists x$, $\forall x$ are replaced by $\exists x \in Q$, $\forall x \in Q$ respectively, and the second-order quantifiers $\exists X$, $\forall X$ by $\exists X \subseteq Q$ and $\forall X \subseteq Q$ respectively. Later we give a formal definition of relativization in the first-order case.) Let $\xi(Q)$ be the formula

   $$\forall R \subseteq Q ([\exists x \exists y (R(x) \land R(y) \land x < y)] \to \exists x \exists y (R(x) \land R(y) \land x < y \land \sim \exists z (x < z < y \land R(z)))).$$

   So $\xi(Q)$ says that the set of points where $Q$ holds is a scattered ordering. Now any countable linear ordering embeds into $(\mathbb{Q}, <)$. So $\mathbb{Q} \models \exists Q (\xi(Q) \land \sigma^Q)$ iff $\sigma$ has a countable scattered model.

   It follows from Rabin's celebrated result [Rabin, 1969] that the monadic second-order theory of $\mathbb{Q}$ is decidable: cf. [Burgess and Gurevich, 1985], theorem 2.6] and section 15.4.5. Hence there is an algorithm to decide whether $\mathbb{Q} \models \exists Q (\xi(Q) \land \sigma^Q)$. This completes the proof.

2. It follows from the downward Löwenheim-Skolem theorem (see [Chang and Keisler, 1990]) that if $A$ is a temporal formula with a first-order table, then $A$ has a scattered model iff $A$ has a countable scattered model. Let $A$ use atoms $p_1, \ldots, p_n$ and have table $\alpha(x, P_1, \ldots, P_n)$, where the $P_i$ are unary relation symbols corresponding to the atoms. Then $A$ has a scattered model iff the monadic second-order sentence

---

<!-- Page 18 -->

   $\exists P_1, \ldots, P_n, \exists x\, \alpha(x, P_1, \ldots, P_n)$

   holds in some countable scattered linear order. By (1) there is an algorithm to decide this question. $\square$

**Remarks 12.7.6**

1. It follows trivially that given any set of connectives with first order tables, there is a recursive axiomatization of the class $K$ of temporal structures with scattered flow of time. We simply take as axioms $\{A : A \text{ is valid in every structure in } K\}$; this set is recursive by proposition 12.7.5. The only proof rule required is substitution.

2. In section 6.9 a finite (not merely recursive) axiomatization of the temporal logic with Until and Since over the real numbers $\mathbb{R}$ was given. In that proof a certain condensation $\sim_r$ (for $r < \omega$) was defined, and the irreflexivity rule used to show that every $\sim_r$-class was a closed interval of the flow of time. The temporal translation $B$ of $\sim \exists y < x (y \sim_r x)$ was then true exactly at the left-hand endpoint of each $\sim_r$-class, so a single axiom could be used to specify properties of the condensation $M/{\sim_r}$, uniformly in $r$. In our case the relevant axiom would be $\phi(B \land FB) \to \phi(B \land U(B, \sim B))$ (cf. proposition 12.7.4), but we have not found a formula true exactly once in each $\sim_r$-class (our proof of proposition 12.7.4 uses the axiom of choice). So this method does not appear to be applicable in the scattered case.

---

## 12.8 Expressive completeness of $U$, $S$ and Stavi connectives over linear time

In this section we will prove theorem 11.5.4 again. That is, we establish expressive completeness of $U$, $S$, and the Stavi connectives for arbitrary linear flows of time. The formal statement follows after some initial definitions. This time we will not use separation. Our argument was sketched in [Gabbay et al., 1980] for the case of $U$ and $S$ over natural numbers time; the generalization to arbitrary linear time was indicated but not proved.

**Definition 12.8.1**

1. We fix an arbitrary finite set $L$ of propositional atoms. We will consider first-order formulae $\phi(x)$ in the 'monadic' language with $=$, $<$, and a unary relation symbol $q$ for every atom $q \in L$. We also consider temporal formulae. Unless otherwise stated, a temporal formula will be one built from the atoms of $L$ using the boolean connectives and the binary temporal connectives $U$, $S$, $U'$, and $S'$ (standing for Until and Since and the Stavi connectives).

---

<!-- Page 19 -->

2. A temporal ($L$-)structure is formally a triple $N = (T, <, h)$, where $(T, <)$ is an irreflexive poset (the flow of time of $N$) and $h : L \to 2^T$ is the assignment map. We will often abuse notation by identifying $N$ with its flow of time $T$. Moreover, as every temporal formula $A$ defines a subset of a structure---the set of time points $h(A)$ where $A$ is true---we will regard $A$ as an extra atom and use it in monadic first-order formulae as a monadic relation symbol. This simplifies the notation a little. So, for example, $N \models \forall x\, U(A, B)(x)$ iff $U(A, B)$ is true at every point of $N$.

3. We will usually use Roman letters for temporal formulae and Greek for classical first-order ones.

In this setting, theorem 11.5.4 becomes:

*For all $L$-formulae $\phi(x)$ there is a temporal formula $A$ such that if $N$ is a linear temporal structure (i.e. one with linear flow of time) in which the atoms of $\phi$ have interpretations then for all $t \in N$, $N \models \phi(t)$ iff $N \models A(t)$. Moreover, $A$ is effectively obtainable from $\phi$ (i.e. by an algorithm).*

This says that the temporal logic with Until, Since, and the Stavi connectives is expressively (functionally) complete over linear time.

Our proof here is based on the sketch in [Gabbay et al., 1980]. The algorithm resulting from separation is probably more efficient than this one.

We begin with some definitions.

**Definition 12.8.2** *(rank)* The rank of a temporal formula $A$ is defined to be the maximum depth of nesting of temporal connectives in $A$.

*Example:* if $p$, $q$ are atoms then $\text{rank}(p \land q) = 0$ and $\text{rank}(\sim U(p, \sim S'(\sim q, q))) = 2$.

Since $L$ is finite, it is easy to show by induction on $r$ that for each $r < \omega$ there is a finite set of temporal formulae of rank $r$ such that every rank $r$ formula is logically equivalent to one of them.

**Definition 12.8.3** *(gaps)* We will use the definition of a gap in a linear order discussed in section 12.2 save that here we also consider there to be a gap at the end (respectively beginning) of the flow of time if there is no last (respectively first) point. We need a few extra notions. Let $M = (M, <, h)$

---

<!-- Page 20 -->

be any linear temporal structure. If $\gamma$ is a gap and $S \subseteq M$, we say that $\gamma = \sup(S)$ if for all $t \in M$, $t > s$ for all $s \in S$ iff $t > \gamma$. We also say that $\gamma = \inf(S)$ if for all $t \in M$, $t < s$ for all $s \in S$ iff $t < \gamma$.

Let $\gamma$ be a gap and let $D$ be a temporal formula. We say that $\gamma$ is *definable on the left by $D$* if $D$ is true at all points of $M$ in some non-empty interval $(t, \gamma)$ on the left of $\gamma$, and not true throughout any non-empty interval $(\gamma, u)$ on the right. The definition of a gap being definable (by $D$) on the right is made in a similar way. If $r < \omega$, an *$r$-definable gap* is one that is definable (on the left or right) by a formula $D$ of rank at most $r$. For $r < \omega$ we let $M_r = M \cup \{r\text{-definable gaps of } M\}$, with the induced ordering $<$. So in general $M \subseteq M_0 \subseteq M_1 \subseteq \cdots$. For example, if $M$ has no last element then $+\infty$ is a gap of $M$ definable on the left by $\top$, so that $+\infty \in M_0 \setminus M$. The situation for $-\infty$ is similar.

**Definition 12.8.4** *(relativized connectives)* There is a natural way of evaluating temporal formulae of the form $\S(A, B)$ for $\S \in \{U, S, U', S'\}$ at gaps. For example, $U(A, B)$ holds at a gap $\gamma$ (i.e. $\gamma \in M_r$ for some $r$) iff there is a point $t > \gamma$ where $A$ holds, with $B$ holding at all points $u \in (\gamma, t)$. To formalize this we relativize our connectives to points.

Fix $r < \omega$ and let $u \in L$ be a new propositional atom. We define $M_r$ as a temporal $L \cup \{u\}$-structure $(M_r, <, h')$ by: $h'(q) = h(q) \subseteq M$ for all $q \in L$; $h'(u) = M$.

We will relativize $U$, $S$, $U'$, and $S'$ to $u$.

Let $\phi(x)$ be any first-order formula in the signature consisting of $=$, $<$, and a unary relation symbol for each atom of $L \cup \{u\}$. We define the *relativization* $\phi^*$ of $\phi$ to $u$ by induction on $\phi$:

- if $\phi$ is quantifier free then $\phi^* = \phi$;
- $(\sim \phi)^* = \sim (\phi^*)$;
- $(\phi \land \psi)^* = \phi^* \land \psi^*$;
- $[\exists y\, \phi(x, y)]^* = \exists y (u(y) \land \phi^*(x, y))$.

We introduce connectives $U^\#$, $S^\#$, $U'^\#$, and $S'^\#$ whose tables are the relativizations to $u$ of the tables of $U$, $S$, $U'$, and $S'$ respectively. We can write formulae using those connectives that are meaningful in any $L \cup \{u\}$-structure. In particular we can interpret them in $M_r$. If $A$ is any formula of $USU'S'$, we let $A^\#$ be the formula obtained by replacing each $U$ in $A$ by $U^\#$, and similarly for $S$, $U'$, and $S'$.

---

<!-- Page 21 -->

**Remark 12.8.5**

1. Let $\alpha(x)$ be the canonical first-order table of the temporal formula $A$, as defined in lemma 9.1.5: in any temporal structure $T$, $\{t \in T : T \models A(t)\} = \{t \in T : T \models \alpha(t)\}$. Then it is easily seen that the table of $A^\#$ is just $\alpha^*$: i.e. for all $t \in M_r$, $M_r \models A^\#(t)$ iff $M_r \models \alpha^*(t)$ (this holds for any $L \cup \{u\}$-structure).

2. If $t \in M$ then $M \models A(t)$ iff $M_r \models A^\#(t)$.

3. Let $A = S'(B, C)$ where $C$ has rank $\leq r$. If $t \in M_r$ and $M_r \models A^\#(t)$, then the gap that $A$ asserts the existence of actually lies in $M_r$ (as $C$ defines it on the right).

The Stavi connectives can express the existence of gaps, but cannot talk directly about what formulae are 'true' at them. So we need to transform properties of a gap into properties of 'real' points. This is done in the following definition and lemma.

**Definition 12.8.6** Let $D$ be any temporal $L$-formula. We define a temporal $L$-formula $\text{left}(A, D)$ by induction on $A$:

- $\text{left}(p, D) = \bot$ for atomic $p$;
- $\text{left}(\sim A, D) = U'(\top, D) \land \sim \text{left}(A, D)$;
- $\text{left}(A \land B, D) = \text{left}(A, D) \land \text{left}(B, D)$;
- $\text{left}(U(A, B), D) = U'(B \land U(A, B), D)$;
- $\text{left}(U'(A, B), D) = U'(B \land U'(A, B), D)$;
- $\text{left}(S(A, B), D) = U(D \land B \land S(A, B) \land U'(\top, B \land D) \land \sim U'(D, B \land D), D)$;
- $\text{left}(S'(A, B), D) = U(D \land B \land S'(A, B) \land U'(\top, B \land D) \land \sim U'(D, B \land D), D)$.

So $\text{rank}(\text{left}(A, D)) \leq \max(\text{rk}(A), \text{rk}(D)) + 2$. We define $\text{right}(A, D)$ similarly by swapping each $U$ with $S$ and $U'$ with $S'$ in the definition above.

The point of this definition is given by the following lemma.

**Lemma 12.8.7** *Let $A$, $D$ be temporal formulae with $D$ of rank at most $r$. Let $m \in M_r$. Then the following are equivalent:*

---

<!-- Page 22 -->

1. *$M_r \models \text{left}(A, D)^\#(m)$.*

2. *There is $\gamma \in M_r \setminus (M \cup \{+\infty\})$, $\gamma$ a gap of $M$ defined by $D$ to the left, with (a) $\gamma > m$, (b) $D$ holds in $M$ on $(m, \gamma)$, and (c) $M_r \models A^\#(\gamma)$.*

*Proof.* Clear. A corresponding result holds for $\text{right}(A, D)$. $\square$

**Definition 12.8.8** *(games)* We will need some results on Ehrenfeucht-Fraïssé games. Let $\Sigma$ be any finite first-order signature without function symbols. Let $M$, $N$ be $\Sigma$-structures. If $n < \omega$ we define a game $G^n(M, N)$ between two players, $\forall$ (male) and $\exists$ (female). The game has $n$ rounds. In each round, $\forall$ chooses an element from whichever of $M$, $N$ he wishes. Then $\exists$ responds by choosing an element of the other structure. After $n$ rounds, two $n$-tuples $\bar{a}$, $\bar{b}$ of elements have been chosen from $M$, $N$ respectively; the order of the elements in each tuple is the order that they were chosen as the game was played. $\exists$ wins this 'play' $(\bar{a}, \bar{b})$ of the game iff for all quantifier-free formulae $\phi(\bar{x})$ of $\Sigma$, $M \models \phi(\bar{a})$ iff $N \models \phi(\bar{b})$. This is slightly stronger than saying that the map $\bar{a} \mapsto \bar{b}$ is a partial isomorphism, since $\Sigma$ may have constant symbols.

A strategy for $\exists$ in a game is a set of rules (not necessarily deterministic) telling her what to do---this can be formalized as a family of functions. The strategy is said to be *winning* if whenever she uses it she wins.

The following is a well-known result of Ehrenfeucht-Fraïssé game theory.

**Proposition 12.8.9** *Let $\Sigma$ be any signature as above. Let $M$, $N$ be $\Sigma$-structures and let $n < \omega$. The following are equivalent:*

1. *$\exists$ has a winning strategy for $G^n(M, N)$.*

2. *$M \models \sigma$ iff $N \models \sigma$ for all $\Sigma$-sentences $\sigma$ of quantifier depth of nesting at most $n$.*

*Proof* (See [Ehrenfeucht, 1961]). As is well known, (2) can fail if $\Sigma$ is assumed infinite or to have function symbols. $\square$

**Notation 12.8.10** If $x < y$ in $M$, we write $(x, y)$ for $\{t \in M : x < t < y\}$, and if $n \leq r$, $(x, y)_n$ for $\{t \in M_n : x < t < y\}$. We write $[x, y]_n$ for $\{t \in M_n : x \leq t \leq y\}$, etc. We do not require that $x, y \in M_n$.

**Definition 12.8.11** *(special games on temporal structures)* We now introduce a modified version of the game defined above. Let $M$ and $N$ be linear temporal structures. The game $G_{n,r}(M, xy; N, x'y')$ for $n, r < \omega$, $x < y$ in $M_r$, and $x' < y'$ in $N_r$, is played as follows. There are only two rounds. $\forall$ begins by choosing $n$ elements $a_1, \ldots, a_n \in [x, y]_r$; $\exists$ responds

---

<!-- Page 23 -->

with elements $a_1', \ldots, a_n' \in [x', y']_r$. Then $\forall$ chooses one more element $b' \in [x', y']$---so $b'$ must not be a gap---and $\exists$ replies with $b \in [x, y]$.

$\exists$ wins iff:

1. the tuples $xyab$ and $x'y'a'b'$ have the same order type,

and if $t \in xyab$ and $t'$ is the corresponding element of $x'y'a'b'$, then:

2. $t$ is a gap of $M$ iff $t'$ is a gap of $N$,
3. for each temporal $L$-formula $A$ of rank at most $r$, $M_r \models A^\#(t)$ iff $N_r \models A^\#(t')$.

**Lemma 12.8.12** *Let $M$, $N$, etc., be as above. Suppose that $\exists$ has a winning strategy $\sigma$ for $G_{n,r}(M, xy; N, x'y')$ for some $n, r < \omega$. Let $n' \leq n$, $r' \leq r$. Then $\sigma$ gives in the natural way a winning strategy for $G_{n',r'}(M, xy; N, x'y')$ provided that $x, y \in M_{r'}$ and $x', y' \in N_{r'}$.*

*Proof.* Recall that $K^+ X$ abbreviates the formula $\sim U(\top, \sim X)$, and $K^- X = \sim S(\top, \sim X)$.

Suppose in a play of $G_{n',r'}(M, xy; N, x'y')$, $\forall$ chooses $a_1, \ldots, a_{n'} \in [x, y]_{r'}$. Then $\exists$ defines $a_{n'+1}, \ldots, a_n$ to be $x$, say. So $a_1, \ldots, a_n \in [x, y]_r$. She applies $\sigma$ to $\bar{a}$ to obtain $\bar{e} \in [x', y']_r$.

We claim that each $e_i \in [x', y']_{r'}$. This is clear if $r' = r$, so assume that $r' < r$. Take $e_i$; certainly if $a_i \in M$ then $e_i \in N$. Otherwise $a_i$ is defined by some formula $\sim D$ of rank $\leq r'$. So letting $D' = (K^+ D \land \sim K^- D) \lor (K^- D \land \sim K^+ D)$, a formula of rank $\leq r' + 1 \leq r$, we have $M_r \models D'^\#(a_i)$. As $\sigma$ is winning, $N_r \models D'^\#(e_i)$. Hence $e_i$ is also a gap defined by $\sim D$; so $e_i \in N_{r'}$.

If $\forall$ now chooses $a' \in [x', y']$ then $\exists$ simply uses $\sigma$ to respond with $e' \in [x, y]$. Then $\bar{a}e'$ and $\bar{e}a'$ satisfy the same order relations and rank $r$ temporal formulae, hence also the same temporal formulae of rank $r'$. Hence $\exists$ has won the play. $\square$

We want to characterize the formulae associated with these games.

**Definition 12.8.13**

1. Let $r < \omega$ and $t \in M_r$ be given. Define $X_t$ to be the conjunction of all temporal $L$-formulae $X$ of rank $\leq r$ with $M_r \models X^\#(t)$. This conjunction is effectively finite, as because $L$ is finite there are up to logical equivalence only finitely many distinct formulae of any rank. Hence $X_t$ can be taken to be a temporal formula of rank $r$.

---

<!-- Page 24 -->

   If $t < u$ in $M_r$, define $X_{(t,u)}$ to be $\bigvee_{v \in (t,u)} X_v$. Again the disjunction is effectively finite, so that $X_{(t,u)}$ can be taken to be a formula of rank $r$. Note that only non-gaps contribute to the disjunction.

2. (This definition is from [Gabbay et al., 1980].) An $n;r$-*decomposition formula* is a first-order formula of the form:

   $$\psi(x_1, x_2) = \exists y_1, \ldots, y_n [x_1 < y_1 < \cdots < y_n < x_2 \land \forall x\, \chi(x_1, x_2, \bar{y}, x)],$$

   where $\chi$ is a conjunction of formulae of the following kinds:

   (a) $\theta(t)$, where $t$ is an element of $x, z, \bar{y}$ and $\theta$ is either $u$, $\sim u$, or $A^\#$ for some temporal $L$-formula $A$ of rank $\leq r$;

   (b) $u(x) \land a < x < b \to B^\#(x)$, where $a < b$ are adjacent elements of the sequence $x_1 y_1 \cdots y_n x_2$, and $B$ is a temporal formula of rank $\leq r$.

   Cf. Definition 12.8.1(2).

**Lemma 12.8.14** *Let $M$, $N$, $x$, $y$, $x'$, $y'$ be as above. Let $n, r < \omega$. Then the following are equivalent:*

1. *$\exists$ has a winning strategy for $G_{n,r}(M, xy; N, x'y')$.*

2. *For all $n;r$-decomposition formulae $\psi(x_1, x_2)$, $M_r \models \psi(x, y) \Leftrightarrow N_r \models \psi(x', y')$.*

*Proof.* $(1) \Rightarrow (2)$---clear.

$(2) \Rightarrow (1)$ Let $\forall$ choose $a_1, \ldots, a_n \in [x, y]$ in his first move. Assume without loss that $x < a_1 < \cdots < a_n < y$. Write $a_0$ for $x$ and $a_{n+1}$ for $y$. Let $\psi(y_0, y_{n+1}) = \exists y_1, \ldots, y_n [y_0 < y_1 < \cdots < y_{n+1} \land \forall x (\bigwedge_i \varphi_{a_i}(y_i) \land \bigwedge_i X_{a_i}^\#(y_i) \land \bigwedge_{i \leq n} (u(x) \land y_i < x < y_{i+1} \to X_{(a_i, a_{i+1})}(x)))]$.

Then $\psi$ is an $n;r$-decomposition formula and $M_r \models \psi(x, y)$. Hence by assumption $N_r \models \psi(x', y')$, and so there are $e_i \in (x', y')$ witnessing the $\exists$s in $\psi$. If $\exists$ chooses the $e_i$ she can easily win the game. $\square$

The main step in our proof is

**Theorem 12.8.15** *Suppose that $M$, $N$ are linear temporal structures. Then $(*)_n$ holds for all $n < \omega$:*

$(*)_n$ *For all $r < \omega$, if $x < y$ in $M_r$, $x' < y'$ in $N_r$, and $\exists$ has a winning strategy for $G_{1+3n, r+4n}(M, xy; N, x'y')$, then $\exists$ has a winning strategy for $G_{n,r}(N, x'y'; M, xy)$.*

---

<!-- Page 25 -->

This says that if $\exists$ has winning strategies for enough 'forward' games $G(M, xy; N, x'y')$ then she has a winning strategy for a given 'backward' game $G(N, x'y'; M, xy)$. The proof does not use compactness and is really a syntactic result---we could equally prove that a certain class of formulae is closed under negation up to equivalence, which is what is done (for the case of $U$ and $S$ over $\mathbb{N}$ and without full proof) in [Gabbay et al., 1980]. However, the game approach, though still complicated, seems rather simpler to present.

Before we prove theorem 12.8.15 we finish our result on expressive completeness.

**Proposition 12.8.16** *Let $M$, $N$ be linear temporal structures and let $x \in M$, $y \in N$. Suppose $r < \omega$ and that $x$ and $y$ satisfy the same temporal formulae of rank $r + 4n + 1$ in their respective structures. Then $\exists$ has a winning strategy for $G_{n,r}(M, -\infty\, x; N, -\infty\, y)$ and $G_{n,r}(M, x\, \infty; N, y\, \infty)$ for all $n < \omega$.*

*Proof (sketch).* Suppose for simplicity that $\forall$ chooses $n$ points $x < a_1 < \cdots < a_n$ in $M$ in the future of $x$. Let $a_0 = x$. Define $C_n$ to be $X_{a_n} \land \sim U(\sim X_{(a_n, \infty)}, \top)$, and for $i < n$, $C_i$ to be $X_{a_i} \land U(C_{i+1}, X_{(a_i, a_{i+1})})$. So $\text{rank}(C_i) = r + n + 1 - i$. Then $M \models C_0(x)$, so that $N \models C_0(y)$. $\exists$ can use the form of $C_0$ to choose points $y = e_0 < e_1 < \cdots < e_n$ in $N$ such that $N \models X_{a_i}(e_i)$ and $N \models X_{(a_i, a_{i+1})}(t)$ for all (non-gaps) $t \in (e_i, e_{i+1})$. If $\forall$ now chooses $t \in (e_i, e_{i+1})$ then $N \models X_u(t)$ for some $u \in (a_i, a_{i+1})$. If $\exists$ responds with such a $u$, she wins the game. The argument for the 'past' game is similar. If some of the $a_i$ are gaps, the idea is the same but the formulae $C$ are more complicated and involve formulae $D$ defining the gaps, together with the formulae $\text{left}(X_v, D)$ or $\text{right}(X_v, D)$---cf. the proof of Cases III and IV of theorem 12.8.15. In all cases we have $\text{rank}(C_0) \leq r + 4n + 1$. $\square$

**Definition 12.8.17** Let $f$, $g$ be any functions on $\omega$ satisfying $f(0) = g(0) = 0$, $f(n+1) \geq (1 + 3f(n))(2k_n) + 1$, and $g(n+1) \geq g(n) + 4f(n)$, where $k_n$ is the number of inequivalent $(1 + 3f(n)); (g(n) + 4f(n))$-decomposition formulae.

**Proposition 12.8.18** *For all $n < \omega$ the following holds. Let $M$, $N$ be linear temporal structures and let $x_1 < \cdots < x_m$, $y_1 < \cdots < y_m$ be increasing $m$-tuples of elements of $M$, $N$ respectively, for arbitrary $m < \omega$. Define $x_0 = -\infty$ and $x_{m+1} = \infty$ in $M_r$. Define $y_0$, $y_{m+1}$ similarly.*

*Suppose that $\exists$ has winning strategies for*

$$G_{f(n),g(n)}(M, x_i, x_{i+1}; N, y_i, y_{i+1})$$

---

<!-- Page 26 -->

*and*

$$G_{f(n),g(n)}(N, y_i, y_{i+1}; M, x_i, x_{i+1})$$

*for all $0 \leq i \leq m$. Then $\exists$ has a winning strategy for the Ehrenfeucht-Fraïssé game $G^n((M, \bar{x}), (N, \bar{y}))$.*

*Proof.* By induction on $n$. If $n = 0$ the result is trivial. Assume it true for $n$, let $r = g(n) + 4f(n) \leq g(n+1)$, and suppose that $\exists$ has a winning strategy for the games $G_{f(n+1),r}(M, x_i, x_{i+1}; N, y_i, y_{i+1})$ and $G_{f(n+1),r}(N, y_i, y_{i+1}; M, x_i, x_{i+1})$.

Let $\forall$ begin $G^{n+1}((M, \bar{x}), (N, \bar{y}))$ by choosing without loss $a \in M$. (If $\forall$ chooses in $N$ the proof is the same as we have complete symmetry.) If $a \in \{x_1, \ldots, x_m\}$ then $\exists$ chooses the corresponding element of $\bar{y}$, and the result then follows using the induction hypothesis and lemma 12.8.12. So let $i \leq m$ be such that $x_i < a < x_{i+1}$. List as $\phi_1, \ldots, \phi_j$ the $[1 + 3f(n)]; r$-decomposition formulae $\phi(u, v)$ such that $M_r \models \phi(x_i, a)$, and as $\psi_1, \ldots, \psi_k$ the $[1 + 3f(n)]; r$-decomposition formulae $\psi(u, v)$ with $M_r \models \psi(a, x_{i+1})$.

Let $\exists$ choose witnesses for the existential quantifiers of each $\phi_s$, $\psi_s$, together with $a$, making at most $n' = (1 + 3f(n))(j + k) + 1 \leq f(n+1)$ points in $(x_i, x_{i+1})_r$ in all. She now applies her winning strategy for $G_{f(n+1),r}(M, x_i x_{i+1}; N, y_i y_{i+1})$. Let $e$ be the point she chooses corresponding to $a$. Clearly (cf. lemma 12.8.12) we have $N_r \models \phi_s(y_i, e)$ for all $s \leq j$ and $N_r \models \psi_s(e, y_{i+1})$ for $s \leq k$. By lemma 12.8.14, $\exists$ has a winning strategy for $G_{1+3f(n),r}(M, x_i a; N, y_i e)$ and for $G_{1+3f(n),r}(M, a x_{i+1}; N, e y_{i+1})$. Crucially, by theorem 12.8.15, she also has winning strategies for

$$G_{f(n),g(n)}(N, y_i e; M, x_i a)$$

and

$$G_{f(n),g(n)}(N, e y_{i+1}; M, a x_{i+1}).$$

By the induction hypothesis, $\exists$ has a winning strategy $\tau$ for $G^n((M, \bar{x} a), (N, \bar{y} e))$.

So in $G^{n+1}((M, \bar{x}), (N, \bar{y}))$, $\exists$ can choose $e$ in response to $\forall$'s choice of $a$ and then follow $\tau$. This strategy wins the game for her. $\square$

**Corollary 12.8.19** *Let $M$, $N$ be linear temporal structures and let $x \in M$, $y \in N$. Suppose that $x$ and $y$ satisfy the same temporal formulae of rank $g(n+1) + 1$ in their respective structures. Then for all monadic first-order formulae $\phi$ (of $L$) of quantifier depth $\leq n$, $M \models \phi(x)$ iff $N \models \phi(y)$.*

*Proof.* By propositions 12.8.9, 12.8.16, and 12.8.18. $\square$

---

<!-- Page 27 -->

Expressive completeness now follows easily. For given $\phi(x)$ of quantifier depth $n$, we may choose a finite $L$ with atoms corresponding to the monadic predicates of $\phi$. Now take a finite set $\Psi$ of temporal formulae of rank $1 + g(n+1)$ such that (1) if $A, B \in \Psi$ and $A \land B$ is consistent then $A = B$; (2) each temporal formula $C$ of rank $1 + g(n+1)$ is equivalent to a disjunction of formulae in $\Psi$. Let $\Psi' = \{B \in \Psi : \text{for some linear } M \text{ and } t \in M, M \models B(t) \text{ and } M \models \phi(t)\}$. Then by corollary 12.8.19, $\phi$ is equivalent over linear time to the rank $1 + g(n+1)$-formula $\bigvee \Psi'$.

Note that by a result of Gurevich ([Burgess and Gurevich, 1985], 2.7(a)), the universal monadic second-order theory of linear order is decidable (cf. theorem 15.4.6). Hence $\Psi'$ is computable by an algorithm, so that the translation of first-order formulae into temporal ones is effective.

---

*Proof (of theorem 12.8.15).* We must prove

$(*)_n$ *For all $r < \omega$, if $x < y$ in $M_r$, $x' < y'$ in $N_r$, and $\exists$ has a winning strategy for $G_{1+3n, r+4n}(M, xy; N, x'y')$, then $\exists$ has a winning strategy for $G_{n,r}(N, x'y'; M, xy)$.*

We prove $(*)_n$ by induction on $n$. For the case $n = 0$ ($r$ is arbitrary), assume that $\exists$ has a winning strategy $\sigma$ for $G_{1,r}(M, xy; N, x'y')$ and that $\forall$ chooses $a \in (x, y)$ in the second round of $G_{0,r}(N, x'y'; M, xy)$ (as $n = 0$ the first round is 'empty'). $a$ is not a gap. $\exists$ simply applies $\sigma$ to choose a response $e \in (x', y')$. Clearly, $\exists$ has won.

Assume $(*)_n$ for $n < \omega$; we prove $(*)_{n+1}$. Fix $r < \omega$, $x < y$ in $M_r$, and $x' < y'$ in $N_r$. Assume that $\exists$ has a winning strategy for

$$G_{4+3n, r+4(n+1)}(M, xy; N, x'y').$$

We will construct a winning strategy for $\exists$ in $G_{n+1,r}(N, x'y'; M, xy)$.

Suppose $\forall$ chooses $n + 1$ points $x' < a_0 < \cdots < a_n < y'$ in $N_r$ (we may assume that they are all distinct, for otherwise the result follows by the inductive hypothesis and lemma 12.8.12). Define the following rank $r$ temporal formulae:

$$A = X_{(a_{n-1}, a_n)}, \quad C = X_{(a_n, y')}$$

where if $n = 0$ we take $a_{n-1}$ in $A$ to be $x'$. Clearly, in $N_r$, $A$ holds on $(a_{n-1}, a_n)$ and $C$ on $(a_n, y')$. Let

$$c = \inf\{t \in [x, y] : M \models C(u) \text{ for all } u \in (t, y)\}.$$

If $c \notin M$ then either $c = x \in M_r$ already, or $c$ is a gap definable on the right by $C$. Hence $c \in M_r$. Define $c' \in N_r$ similarly. See figure 12.2.

---

<!-- Page 28 -->

**Claim 1.** Consider a play of the game $G_{m,r'}(M, xy; N, x'y')$ for arbitrary $r' \geq r$, $m \geq 1$ in which $\exists$ uses a winning strategy. Let $\forall$ begin by choosing $c$ plus $m - 1$ other points, and let $\exists$'s response to $c$ be $d$ (plus $m - 1$ other points). Then $d = c'$.

*Proof of claim.* As the strategy is winning, any rank $r'$ temporal formula satisfied by one of $\forall$'s choices must also be satisfied by the corresponding choice of $\exists$. Now the rank $r + 1$ formula $C' = \sim C \lor K^- \sim C$ satisfies $M_r \models C'^\#(c)$. Hence also $N_r \models C'^\#(d)$, so $d \leq c'$.

If $d < c'$ then $\forall$ can choose $d' \in (d, y')$ with $N \models \sim C(d')$. $\exists$ now has no winning response, a contradiction. Hence $d = c'$. This proves the claim.

**Claim 2.** $\exists$ has a winning strategy for

$$G_{1+3n, r+4(n+1)}(M, xc; N, x'c')$$

and for

$$G_{1+3n, r+4(n+1)}(M, cy; N, c'y').$$

*Proof of claim.* Let $r' = r + 4(n + 1)$. Suppose that $\forall$ chooses $1 + 3n$ elements in the interval $[x, c]_{r'}$. By assumption, $\exists$ has a winning strategy $\sigma$ for the game $G_{4+3n, r'}(M, xy; N, x'y')$. $\exists$ adds $c$ to $\forall$'s choices and applies $\sigma$ (cf. lemma 12.8.12). As the order of $\exists$'s element choices from $\bar{e}$ matches the order of $\forall$'s, Claim 1 ensures that her responses to $\forall$'s choices all lie in $[x', c']_{r'}$. If $\forall$ then chooses in $[x', c']$ then again $\exists$'s strategy will yield an answer in $[x, c]$. The strategy is clearly winning. To sum up, the restriction of $\sigma$ to games in which $\forall$ always chooses in $[x, c]$ and then in $[x', c']$ can

---

<!-- Page 29 -->

yield a winning strategy for $G_{1+3n, r+4(n+1)}(M, xc; N, x'c')$. Similarly for the intervals $[c, y]$, $[c', y']$. This establishes the claim.

Hence by inductive hypothesis $(*)_n$, $\exists$ has winning strategies $\sigma_1$ for the backward games $G_{n, r+4}(N, x'c'; M, xc)$ and $G_{n, r+4}(N, c'y'; M, cy)$.

Now, clearly, $c' \leq a_n$, so that $(x', c')_r$ contains at most $n$ points from $\{a_0, \ldots, a_n\}$. The proof will divide into cases according to whether $a_n$ is a point of $N$, a left- or a right-definable gap.

**Case I:** $a_n < c'$. Then $(c', y')_r$ also contains at most $n$ points from $\{a_0, \ldots, a_n\}$. So as $\exists$ is trying to win $G_{n+1,r}(N, x'y'; M, xy)$, she can use $\sigma_1$ and $\tau$ to choose points $e_0, \ldots, e_n \in M_r$. She applies $\sigma$ to those $a_i$ in $(x', c')_r$, and $\tau$ to the rest using the method of lemma 12.8.12; if an $a_i$ happens to be $c'$ it can be dealt with by either strategy. If $\forall$ then responds in $[x, c)$ she uses $\sigma$, and if in $[c, y]$, $\tau$. If she does this then by lemma 12.8.12 she will win the game.

**Case II:** All the points $a_0, \ldots, a_n$ lie in $(c', y')$, and $a_n \in N$ is not a gap.

Recall that $\exists$ is trying to win $G_{n+1,r}(N, x'y'; M, xy)$, i.e. to preserve all rank $r$ formulae. Define $B = X_{a_n}$, and $b = \sup\{t \in (x, y) : M \models B(t)\} \in M_r$ (as before, either $b \in M$, $b = y$ or $b$ is an $r$-definable gap, defined on the right by $\sim B$). Define $b' \in N_r$ similarly. Then, clearly, $b' > a_n$. See figure 12.3.

As in Claim 1, in any play of $G_{4+3n, r+4(n+1)}(M, xy; N, x'y')$ in which $\exists$ is using her winning strategy and $\forall$ chooses $b$, $c$ among other points, $\exists$ will respond with $b'$, $c'$ among others. Hence again $\exists$ has a winning strategy for $G_{1+3n, r+4(n+1)}(M, cb; N, c'b')$. So by the induction hypothesis $(*)_n$ she has a winning strategy $\tau$ for $G_{n, r+4}(N, c'b'; M, cb)$. She already has a winning strategy $\sigma$ for $G_{n, r+4}(N, x'c'; M, xc)$.

Let her first use $\tau$ in response to $a_0, \ldots, a_{n-1}$. It delivers $n$ points

---

<!-- Page 30 -->

$e_0, \ldots, e_{n-1} \in (c, b)_r$ (cf Lemma 12.8.12). Now clearly

$$N_r \models U(B, A)^\#(a_{n-1});$$

$a_n$ is a witness to this. (This holds even if $a_{n-1}$ is a gap; if $n = 0$ we take $a_{-1}$ to be $c'$ and (see below) $e_{-1}$ to be $c$.) $U(B, A)$ has rank $r + 1$, so as $\tau$ preserves formulae up to rank $r + 4$, $M_r \models U(B, A)^\#(e_{n-1})$. Hence there is $z > e_{n-1}$ in $M$ with $M \models B(z)$ and $M \models A(t)$ for all $t \in (e_{n-1}, z)$. But $e_{n-1} < b$. Hence we can assume that $z \leq b$. $\exists$ defines $e_n$ to be such a $z$, completing her move. Clearly, $e_n$ and $a_n$ satisfy the same temporal formulae of rank $r$, as they both satisfy $B$.

Suppose that $\forall$ continues by choosing $t \in [x, y]$. Recall that by the game rules, $t$ is not a gap. If $t < c$ then $\exists$ uses $\sigma$ to respond, and if $c \leq t \leq e_{n-1}$ she uses $\tau$. If $t \in (e_{n-1}, e_n)$ then $M \models A(t)$. By definition of $A$ there is $t' \in (a_{n-1}, a_n)$ with $M \models X_t(t')$. $\exists$ can then choose any such $t'$ as her response. It follows that $t$ and $t'$ agree on all rank $r$ temporal formulae, as required. If $t = e_n$ then $\exists$ responds with $a_n$. Finally, if $y > t > e_n$ then certainly $t > c$, so $M \models C(t)$. By definition of $C$ there is $t' > a_n$ with $M \models X_t(t')$, and $\exists$ can choose such a $t'$ in response to $t$. If $\exists$ follows these directions she will win.

The remaining cases are similar to Case II, which gave a response $e_n$ to $a_n$ by letting $B$ describe $a_n$ and making $U(B, A)$ true at $e_{n-1}$. But $a_n$ will now be a gap, so we must use the Stavi $U'$---and $U'(B, A)$ does not say that $B^\#$ is true at the gap. So we use the formulae $\text{left}(\cdot, \cdot)$ and $\text{right}(\cdot, \cdot)$ instead.

**Case III:** All the points $a_0, \ldots, a_n$ lie in $(c', y')$, and $a_n$ is a gap defined on the left by some formula $D$ of rank $\leq r$. Clearly, $a_n$ is also defined by $A \land D$, so we can assume that $D \equiv A$.

Write $B$ for $X_{a_n}$, and $\delta$ for $A \land \text{left}(B, D)$. $\delta$ is a formula of rank $\leq r + 2$, and $N_r \models U(\delta, A)^\#(a_{n-1})$ (again we set $a_{n-1}$ to be $c'$ if $n = 0$). Define $d'$, $g'$ by:

- $d' = \sup\{t \in (x', y') : N \models \sim D(t)\}$;
- $g' = \sup\{t \in (x', d') : N \models \delta(t)\}$.

See figure 12.4.

Define $d$, $g$ similarly. Note that as before, all these points lie in $M_{r+2}$, $N_{r+2}$. Clearly, $a_n < d'$ and the fact that $N_r \models U(\delta, A)^\#(a_{n-1})$ is witnessed at a point $t' \in N$ where $\delta$ holds, with $t' < g'$.

Now if $\exists$ uses a winning strategy for $G_{4+3n, r+4(n+1)}(M, xy; N, x'y')$ and adds $c$, $g$, and $d$ to $\forall$'s choices, then, as before, her strategy delivers inter alia $c'$, $g'$, and $d'$ in response. So again, $\exists$ has a winning strategy for $G_{1+3n, r+4(n+1)}(M, cg; N, c'g')$ for all $m$, $r'$. By $(*)_n$, $\exists$ has a winning

---

<!-- Page 31 -->

strategy for $G_{n, r+4}(N, c'g'; M, cg)$. Let her use it to choose $e_0, \ldots, e_{n-1}$ in response to $a_0, \ldots, a_{n-1}$. So as $e_0, \ldots, e_{n-1} \in (c, g)_r$, and as rank $r + 4$ formulae are preserved, $M_r \models U(\delta, A)^\#(e_{n-1})$. As $e_{n-1} < g$ we can choose $t < g$ in $M$ with $M \models \delta(t)$ and such that $A$ holds at all $u \in (e_{n-1}, t]$.

By definition of $\delta$ and lemma 12.8.7, there is a gap $e_n \in (t, d)$, defined by $D$ on the left, and such that $A$ holds between $t$ and $e_n$. Moreover, any rank $r$ formula holds at $e_n$ iff it holds at $a_n$, as they both satisfy $B$. $\exists$ chooses $e_n$ in response to $a_n$, so completing her move. The same argument as in Case I allows $\exists$ to complete the remainder of the game, winning it.

**Case IV:** $a_0, \ldots, a_n \in (c', y')$, $a_n \in N_r$, and $a_n$ is not definable on the left by any formula of rank $\leq r$.

It follows from the case assumption that $A$ holds throughout some interval containing $a_n$. Choose $D$ of rank $\leq r$ defining $a_n$ on the right. Define $B = X_{a_n}$ and $\delta = A \land \sim D \land U(\text{right}(B, D), A)$ (rank $r + 3$). Let $d' = \sup\{t \in (x', y') : N \models \text{right}(B, D)(t)\}$, and then $g' = \sup\{t \in (x', d') : N \models \delta(t)\}$. Define $d$, $g \in M_{r+3}$ similarly.

See figure 12.5.

Clearly, there are $a_{n-1} < t' < a_n < u' < g'$, with $t', u' \in N$, $N \models \delta(t')$, $N \models \text{right}(B, D)(u')$, and $A$ holding on $(t', u')$ (if $n = 0$ we take $a_{-1}$ to be $c'$ as usual). Hence $t' < g'$ and $u' < d'$. As usual, if $\exists$ uses a winning strategy for $G_{4+3n, r+4(n+1)}(M, xy; N, x'y')$ and adds $c$, $g$, and $d$ to $\forall$'s choices she can derive a winning strategy for $G_{1+3n, r+4(n+1)}(M, cg; N, c'g')$. So by $(*)_n$, she has a winning strategy for $G_{n, r+4}(N, c'g'; M, cg)$. Let her use it to respond to $a_0, \ldots, a_{n-1}$ with $e_0, \ldots, e_{n-1}$. So as $U(\delta, A)$ has rank $\leq r + 4$, $M_r \models U(\delta, A)^\#(e_{n-1})$. We can choose $e_{n-1} < t < g$ with $t \in M$, $M \models \delta(t)$, and $A$ holding on $(e_{n-1}, t)$. Then we can choose $u \in M$

---

<!-- Page 32 -->

with $t < u < d$, $M \models \text{right}(B, D)(u)$ and such that $A$ holds in $(e_{n-1}, u)$. By lemma 12.8.7 there is a gap $e_n \in (t, u)$ defined by $D$ and at which the same relativized rank $r$ formulae hold as at $a_n$ in $N_r$. (We have $e_n > t$ because $M \models \sim D(t)$.) Then $\exists$ adds $e_n$ to her choices to complete the move. The remainder of the game is as before.

This ends the proof of the theorem. $\square$
