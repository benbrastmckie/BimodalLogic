## 7 Separability

Before bringing the axiom Sep into the proof, we might as well first discharge the promise of a validity result for it. We use a lemma (K2) from [12] (based on a result of Doets's, see also [8] Proposition 4.3) to establish its validity over real flows of time.

**Lemma 10.** *Axiom Sep is valid in the class of all structures with real flow.*

**Proof.** Suppose that $R = (\mathbb{R}, <, h)$ is a structure in which Sep does not hold at $t \in \mathbb{R}$. We can choose $s > t$ and put $S = h(p) \cap (t, s)$ so that

- $S$ has neither a first nor a last point,
- $S$ is relatively dense -- i.e. between any two points of $S$ is another -- and
- for each $u \in (t, s)$, there is a (non-singleton) interval $I_u \subseteq (t, s)$ disjoint from $S$ but ending at $u$ on the left or right.

By recursively choosing $\omega$ points from $S$ we can without loss of generality suppose that $S$ is countable and satisfies the three conditions above. As a suborder of $\mathbb{R}$, $S$ is thus isomorphic to $\mathbb{Q}$.

Thus the order $(S, <)$ has an uncountable order $(G, <)$ of gaps. Define a map $r : G \to \mathbb{R}$ as follows: given a gap $\gamma$ in $S$, let $X = \{s \in S \mid s < \gamma\}$. Let $r(\gamma) = \sup(X)$ which exists as $X \subseteq \mathbb{R}$. Clearly $r$ is order preserving and one-to-one.

Furthermore, if $\gamma < \delta$ are gaps of $S$ then there is $u \in S$ between them. Thus $t < r(\gamma) < u < r(\delta) < s$ and $u$ must also be strictly between $I_{r(\gamma)}$ and $I_{r(\delta)}$. These two intervals must be disjoint.

Thus $\{I_{r(\gamma)} \mid \gamma \in G\}$ is an uncountable set of pairwise disjoint non-singleton intervals of $\mathbb{R}$. Impossible. $\blacksquare$

It can be seen from the proof of the lemma that axiom Sep will also be valid in any structure whose underlying flow of time only has open intervals beginning with a copy of the reals. For example, structures with flow the 'long line' of [3], i.e. the open interval $(0, 1)$ followed by $\omega_1$ copies of $[0, 1)$, satisfy Sep. This is not surprising as Burgess and Gurevich show (in [3]) that the 'long line' is a model of the universal monadic theory of the reals but it does mean that Sep does not characterise separability. Nevertheless, returning to the trail of the completeness result and following proposition M8 of [12] we can show a sort of converse.

**Theorem 5.** *Suppose that $M$ is a Prior structure which also satisfies every substitution instance of axiom Sep.*

*Then for every contemporaneous equivalence relation $\sim$ such that $M / {\sim}$ is densely ordered, $M / {\sim}$ has a dense set of singletons.*

**Proof.** From the preceding theorem 4 we know that the $\sim$-classes do not end at gaps. In fact the classes must be closed intervals: if a class has an excluded end point then this point is in the next class and this contradicts density.

Suppose that $c < d$ in $M$ such that $c \not\sim d$. We must show that there is a singleton class between the classes of $c$ and $d$. Without loss of generality, $c$ is the right hand end point of its class.

Let the temporal formula $C$ be true exactly at points who are the left hand end points of their classes. This includes the case of a singleton class. We use expressive completeness here.

Now $C \wedge U(C, \neg C)$ never holds in $M$, so it certainly does not hold soon after $c$, and so $\neg K^+(C \wedge U(C, \neg C))$ holds at $c$.

Also $K^+(C)$ holds at $c$ so we can use axiom Sep to deduce that $K^+(K^+ C \wedge K^- C)$ holds at $c$.

Certainly $K^+ C \wedge K^- C$ must hold at some $e$ between $c$ and $d$ but clearly $e$ must be in a class of its own. $\blacksquare$

## 8 Doets' Theorem

To explain why we need such strange results as those proved in the last two sections let us state an ever so slightly stronger result to that of Doets 3.3.9 in his thesis [4].

**Theorem 6.** *Suppose that $M$ is a temporal structure in a finite language whose flow of time is countable, dense and without end points.*

*Suppose further that for any contemporaneous equivalence relation $\sim$ on $M$,*

**D1):** *the $\sim$ classes do not end in gaps and*

**D2):** *if $M / {\sim}$ is densely ordered, then $M / {\sim}$ has a dense set of singletons.*

*Then for all $k < \omega$, there is a temporal structure with flow of time the real numbers satisfying the same monadic first-order sentences of quantifier depth at most $k$ as $M$ does.*

Doets' result appeared in [4] and [5] but Burgess and Gurevich had used similar techniques in [3]. We closely follow the excellent expositions in [12] and [8] but our statement is slightly stronger and our proof a little different because we use our notion of contemporaneity.

First some preliminaries. Fix $k \geq 2$.

Here a *structure* will mean a linear temporal structure in our finite language.

If $M$ and $N$ are structures we write $M \equiv_k N$ if and only if $M$ and $N$ agree on the truth of monadic sentences of quantifier depth at most $k$. Note that since $k \geq 2$, if $M \equiv_k N$ then $M$ and $N$ either both have a right (respectively left) hand end point or both do not have a right (resp. left) hand end point.

Say that $M$ is *good* if and only if there is some $N \equiv_k M$ such that the flow of time of $N$ is an interval of the reals.

Say that $M$ is *very good* if and only if, for all $t < u$ in $M$, the substructure $M \mid (t, u)$ is non-empty and good.

Next a couple of results from [15]. First, if $(I, <)$ is a linear order then define the *lexicographic sum* $\Sigma_{i \in I} N_i$ of a collection $\{N_i \mid i \in I\}$ of structures $N_i$ by sticking copies of the $N_i$ together end to end in accordance with the ordering of $I$. Clearly, if some of the $N_i$'s are the same (for different $i$'s) then we need disjoint copies of their domains to form the sum's domain. If the index set is finite, we may use the $+$ notation for sums.

It can be shown, using a simple game-theoretic argument (see [15] lemma 6.5) that lexicographic sums (over the same index set) of $k$-equivalent structures are themselves $k$-equivalent.

We will make crucial use of a special type of sum. Now suppose that $S$ is a finite set of structures. Let $\pi : \mathbb{Q} \to S$ be any map such that for any $M \in S$, for any $r, s \in \mathbb{Q}$, there is $t \in \mathbb{Q}$ such that $r < t < s$ and $\pi(t) = M$. We call the structure $\Sigma_{t \in \mathbb{Q}} \pi(t)$ the *shuffle* over $S$. It can be shown to be well defined up to isomorphism.

**Lemma 11** ([8] lemma 6.4). *If $N$ is countable and very good then it is good.*

**Proof.** All one point structures are good and no bigger but finite structures are very good so suppose that $N$ has countably infinite domain. First the case when $N$ has no end points.

Choose $a_i \in N$ for each integer $i$ such that $i < j$ implies $a_i < a_j$ and for all $t \in N$, there is $i, j$ such that $a_i < t < a_j$. Since $N$ is very good, $N \mid (a_i, a_{i+1})$ is good. Take $R_i \equiv_k N \mid (a_i, a_{i+1})$ with an open interval of $\mathbb{R}$ as a flow.

Because $\equiv_k$ is preserved under lexicographic sums,

$$N \equiv_k \Sigma_{i \in \mathbb{Z}}(N \mid \{a_i\} + R_i)$$

and this latter has flow isomorphic to $\mathbb{R}$.

Now if $N$ has one or two end points, then, by the very goodness of $N$, its interior does not have end points so we can use the above result and then use the lexicographic sum result to add appropriate singleton structures to the end(s). $\blacksquare$

Define $\sim_M$ on a temporal structure $M$ by, for any $a, b \in M$, $a \sim_M b$ if and only if

- $a = b$,
- $a < b$ and $M \mid (a, b)$ is very good or
- $b < a$ and $M \mid (b, a)$ is very good.

**Lemma 12.** *There is a monadic formula $\varepsilon(x, y)$ which defines $\sim_M$ as a contemporaneous equivalence relation on the domain of any $M$.*

*Furthermore, there is a finite set $\{\gamma_i \mid i = 1, \ldots, s\}$ of sentences such that $M$ is good if and only if $M \models \gamma_i$ for some $i$.*

**Proof.** There are only finitely many logically inequivalent maximal consistent conjunctions $\gamma$ of sentences of quantifier depth $\leq k$. Any structure is a model of just one such $\gamma$, so if $N_1 \models \gamma$ then $N_2 \equiv_k N_1$ iff $N_2 \models \gamma$. Only some will be true of good structures -- $\{\gamma_1, \ldots, \gamma_s\}$ say. $N$ is good iff $N \models \bigvee_{i \leq s} \gamma_i$.

Let $\gamma(z, t)$ be the result of relativising the quantifiers of $\bigvee_{i \leq s} \gamma_i$ to $(z, t)$, where $z$ and $t$ are new variables. Put $\gamma'(z, t) = \gamma(z, t) \wedge (\exists u(z < u < t))$.

Then

$$\varepsilon(x, y) = \quad x < y \to \forall z t(x < z < t < y \to \gamma'(z, t))$$
$$\quad \wedge \quad y < x \to \forall z t(y < z < t < x \to \gamma'(z, t))$$

is a formula defining $\sim_M$.

To show that $\sim$ is contemporaneous, we first show that it is an equivalence relation. The difficult part is transitivity. Suppose that $a < b < c$ are in $M$ and $a \sim_M b$ and $b \sim_M c$. We show that $M \mid (a, c)$ is very good by showing that if $a < t < u < c$ then $M \mid (t, u)$ is non-empty and good.

If $t$ and $u$ are on the same side of $b$ then this is clear. If $b = t$ or $b = u$ then use a lexicographic sum.

So assume that $a < t < b < u < c$. Now $M \mid (t, b)$ and $M \mid (b, u)$ are both very good so are good. Choose $R_1 \equiv_k M \mid (t, b)$, $R_2 = M \mid \{b\}$ and $R_3 \equiv_k M \mid (b, u)$ each with flow a subset of $\mathbb{R}$. Then we know that $M \mid (t, u) \equiv_k R_1 + R_2 + R_3$ whose flow is isomorphic to $\mathbb{R}$ itself.

That the $\sim_M$ classes are intervals follows from the fact that very goodness is inherited by substructures on subintervals.

Contemporaneity then follows from the fact that the definition of $\sim_M$ is in terms of exactly the right substructure. $\blacksquare$

**Lemma 13.** *For any structure $M$, if there are no $\sim_M$ classes ending at gaps then they are all closed intervals, i.e. of forms $(-\infty, +\infty)$, $(-\infty, b]$, $[b, +\infty)$ or $[b, b']$.*

**Proof.** We know that the classes are intervals, we must rule out the case of a $\sim_M$-class ending at an excluded point of $M$. By considering mirrors we may as well, for contradiction, suppose that $b \in M$ is the right hand end point of $c$'s class $E$ but that $b \notin E$.

Clearly $M \mid E$ is very good so that its substructure $M \mid (c, b)$ is too. This is the contradiction. $\blacksquare$

Now let us turn to the proof of Doets' theorem.

**Proof.** Without loss of generality, $k \geq 2$ as required by the preliminaries. If $M$ is good we are done -- any interval of the reals which does not include its end points is isomorphic to the reals itself. So suppose, for contradiction, that $M$ is not good. By lemma 11, we know that there are at least two $\sim$-classes.

By lemma 13 and D1, we know that between any such classes is a third. Thus we have density of $M / {\sim}$ and D2 says that we have density of singleton classes.

Now for any $\sim$-class $E \subseteq \mathbb{Q}$, $E$ is very good so $E$ is good. Thus there is $i = 1, \ldots, s$ such that $M \mid E \models \gamma_i$. The following choice makes sense.

Choose $a < b$ from $M$ such that

- $a \not\sim b$ and
- $G = \{\gamma_i \mid i = 1, \ldots, s \text{ and } \exists\ \sim\text{-class } E \text{ strictly between } a \text{ and } b \text{ such that } M \mid E \models \gamma_i\}$ has minimal size.

We are going to show that $M \mid (a, b)$ is very good thus producing a contradiction.

So suppose that $a < c < d < b$. We need only show that $M \mid (c, d)$ is good. If $c \sim d$ then this follows from lemma 11. So suppose not.

Since we have density of $M / {\sim}$, the classes in $I = \{E \mid E \text{ is a } \sim\text{-class strictly between } c \text{ and } d\}$ have order type $\mathbb{Q}$. Also, by minimality of $G$, all the $\gamma_i$'s in $G$ are satisfied densely in $I$. This means that as far as $\equiv_k$ is concerned $\bigcup I$ might as well be a shuffle as we now proceed to define.

For each $\gamma \in G$, choose an $N_\gamma \models \gamma$ with flow of time an interval of $\mathbb{R}$. It is clear that for any $E \in I$, $M \mid E \equiv_k N_\gamma$ for one of the $\gamma$'s in $G$. Since lexicographic sums preserve $k$-equivalence we can choose $\sigma : \mathbb{Q} \to \{N_\gamma \mid \gamma \in G\}$ appropriately so that

$$M \mid (\bigcup I) = \Sigma_{E \in I} M \mid E \equiv_k \Sigma_{q \in \mathbb{Q}} \sigma(q),$$

the latter structure being a shuffle over $\{N_\gamma \mid \gamma \in G\}$.

Another simple game argument can be used to show that we can mix into a shuffle many more copies of the same structures without disturbing $k$-equivalence. In particular we will use lots of copies of a degenerate structure. We know that there are singleton classes dense in $M / {\sim}$. Suppose that $\gamma_1$ say appears in $G$ and that $N \models \gamma_1$ only if $N$ has a one-point domain. Now extend $\sigma$ to $\sigma^* : \mathbb{R} \to \{N_\gamma \mid \gamma \in G\}$ by $\sigma^*(i) = N_{\gamma_1}$ if $i \in \mathbb{R} - \mathbb{Q}$. A game will show that $\Sigma_{q \in \mathbb{Q}} \sigma(q) \equiv_k \Sigma_{r \in \mathbb{R}} \sigma^*(r)$.

Let $\mathcal{R} = \Sigma_{r \in \mathbb{R}} \sigma^*(r)$ and let $R$ be the flow of time of $\mathcal{R}$. It is clear that $R$ is dense and does not have end points.

In fact $R$ is Dedekind complete. This is true because any subset bounded above intersects a last summand. Because the $\gamma_i$'s say so the summands themselves are closed intervals of the reals so the supremum of the set exists in this class.

We can also show that $R$ has a countable dense subflow. For each $q \in \mathbb{Q}$ just include the point $\sigma^*(q)$ itself if $\sigma^*(q)$ is a singleton. Otherwise, $\sigma^*(q)$ is an interval and we can find a countable dense subset of this set to include. It turns out that since irrational $r$'s only have singleton $\sigma^*(r)$'s and since $\mathbb{Q}$ is dense in $\mathbb{R}$ we have our claim.

But then $R$ being Dedekind complete, dense, without end points and with a countable dense subset must be isomorphic to the reals.

This is enough to show that $M \mid (c, d)$ is good and finish our proof. Let $c'$ be the right hand end point of $c$'s $\sim$-class and $d'$ be the left hand end point of $d$'s. Thus

$$M \mid (c, d) = M \mid (c, c'] + M \mid \bigcup I + M \mid [d', d).$$

As $c \sim c'$, there is $X \equiv_k M \mid (c, c']$ with flow isomorphic to an interval of $\mathbb{R}$ and similarly there is $Y \equiv_k M \mid [d', d)$. Then

$$M \mid (c, d) \equiv_k X + \mathcal{R} + Y$$

and this latter has flow of time isomorphic to $\mathbb{R}$ as required. $\blacksquare$

## 9 Completeness

Finally

**Theorem 7.** *The system **US/R** is sound and weakly complete for the semantics over structures with real flow.*

**Proof.** Soundness has been proven in lemma 1.

To show weak completeness, we suppose that we are given a formula $A_0$ consistent with **US/R**. We will find a model of it with flow of time the real numbers.

First use Burgess--Xu Corollary 1 to furnish us with a structure $M_0$ such that

1. the flow of time of $M_0$ is the rationals,
2. $M_0 \models A_0(0)$ and
3. all substitution instances of the axioms Prior-U, Prior-S and Sep are valid in $M_0$.

By ignoring all the atoms which don't appear in $A_0$ we have a temporal structure $M$ from a finite language. $M$ is still a model of $A_0$.

The flow of time of $M$ is countable, dense and without end points and D1 and D2 follow from the theorems 4 and 5. Thus we can apply Doets' theorem. Let $k$ be one greater than the quantifier depth of the table $\alpha(t)$ of $A_0$. We have a temporal structure $\mathcal{R}$, with flow of time the reals, satisfying the same monadic sentences of quantifier depth at most $k$ as $M$ does.

Thus $\mathcal{R}$ like $M$ is a model of $\exists t\, \alpha(t)$. Say $b \in \mathcal{R}$ and $\mathcal{R} \models \alpha(b)$.

We have $\mathcal{R} \models A_0(b)$ as promised. $\blacksquare$
