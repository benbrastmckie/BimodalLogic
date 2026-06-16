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
