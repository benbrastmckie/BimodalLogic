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
