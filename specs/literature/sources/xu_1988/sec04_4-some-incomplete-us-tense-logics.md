## 4. Some Incomplete $U,S$-Tense Logics

We present below a number of incompleteness theorems of $U,S$-tense logics. For each $\alpha$ to be considered in this section, $\alpha$ is so called first-order definable, i.e., for some first-order sentence $\alpha^*$ (in $=$ and $<$), $\alpha$ defines $\alpha^*$. Therefore, in the proof of each of the following theorems, we will show the first-order definability of each formula considered in the theorem, though it is not necessary to do so.

**4.1. THEOREM.** *Consider the following formulas:*

$$\text{(7)} \quad U(p, q) \to U(p, q \land U(p, q)),$$

$$\text{(12)} \quad U(p, q) \to U(p, U(p, q)).$$

*In fact, (i) $\{(12)\} \vDash (7)$ and (ii) $(7) \notin TL_{US}(\{(12)\})$.*

*Proof.* We first show that both (7) and (12) define

$$\text{(7)*} \quad \forall xyz(x < y \land x < z \land z < y \to \forall u(z < u \land u < y \to x < u)),$$

from which (i) follows. It is easy to see that $\{(7)\} \vDash (12)$. Hence it is sufficient to show that for every frame $\mathscr{F}$, $\mathscr{F} \vDash (7)^*$ only if $\mathscr{F} \vDash (7)$, and $\mathscr{F} \nvDash (7)^*$ only if $\mathscr{F} \nvDash (12)$.

Let $\mathscr{F}$ be any frame and suppose that $\mathscr{F} \vDash (7)^*$. Then for every valuation $V$ on $\mathscr{F}$ and every $t \in T$, if $(\mathscr{F}, V) \vDash U(p, q)[t]$, there is a $t' \in T$ such that $(\mathscr{F}, V) \vDash p[t']$ and $(\mathscr{F}, V) \vDash q[t'']$ for every $t'' \in T$ with $t < t''$ and $t'' < t'$. Now consider any such $t''$ and any $t^* \in T$ with $t'' < t^*$ and $t^* < t'$. By $\mathscr{F} \vDash (7)^*$ we have $t < t^*$ and hence $(\mathscr{F}, V) \vDash q[t^*]$. This implies that $(\mathscr{F}, V) \vDash U(p, q)[t'']$ for every such $t''$, and hence $(\mathscr{F}, V) \vDash U(p, q \land U(p, q))[t]$. Hence, $\mathscr{F} \vDash (7)$.

Suppose that $\mathscr{F} \nvDash (7)^*$. Then there are $t_0, t_1, t_2, t_3 \in T$ such that $t_0 < t_1$, $t_0 < t_3$, $t_3 < t_1$, $t_2 < t_1$, $t_3 < t_1$ but $t_0 \not< t_2$. Let $V$ be a valuation on $\mathscr{F}$ such that $V(p) = \{t_1\}$ and $V(q) = T - \{t_2\}$. Then $(\mathscr{F}, V) \vDash U(p, q)[t_0]$ since $t_0 < t_1$ and $t_0 \not< t_3$, $(\mathscr{F}, V) \nvDash U(p, q)[t_3]$ since $t_3 < t_1$ and $t_2 < t_1$, and hence $(\mathscr{F}, V) \nvDash U(p, U(p, q))[t_0]$ since $t_0 < t_3$ and $t_3 < t_1$. Hence, $\mathscr{F} \nvDash (12)$.

Now we turn to (ii).

Let $V$ be a valuation on a frame $\mathscr{F}$, $\alpha$ a formula, and $t$ an element of $T$. Then $(\mathscr{F}, V) \vDash '\alpha[t]$ is defined recursively as follows:

- (a) $(\mathscr{F}, V) \vDash 'p[t]$ iff $t \in V(p)$, for every propositional variable $p$
- (b) $(\mathscr{F}, V) \vDash '\neg\beta[t]$ iff $(\mathscr{F}, V) \nvDash '\beta[t]$
- (c) $(\mathscr{F}, V) \vDash '\beta \to \gamma[t]$ iff if $(\mathscr{F}, V) \vDash '\beta[t]$, then $(\mathscr{F}, V) \vDash '\gamma[t]$
- (d) $(\mathscr{F}, V) \vDash 'U(\beta, \gamma)[t]$ iff for some $t', t'' \in T$ with $t < t'$, $t < t''$ and $t'' < t'$, $(\mathscr{F}, V) \vDash '\beta[t']$ and $(\mathscr{F}, V) \vDash '\gamma[t'']$
- (e) $(\mathscr{F}, V) \vDash 'S(\beta, \gamma)[t]$ iff for some $t', t'' \in T$ with $t' < t$, $t' < t''$ and $t'' < t$, $(\mathscr{F}, V) \vDash '\beta[t']$ and $(\mathscr{F}, V) \vDash '\gamma[t'']$.

We write $\mathscr{F} \vDash '\alpha$ to indicate that $(\mathscr{F}, V) \vDash '\alpha[t]$ for every $t \in T$ and every valuation $V$ on $\mathscr{F}$.

Let $\mathscr{Q} = (Q, <)$ where $Q$ is the set of rational numbers and $<$ the usual order on $Q$. It can be shown by induction that $\mathscr{Q} \vDash '\alpha$ for every $\alpha \in TL_{US}(\{(12)\})$. Details are omitted.

Now let $V$ be a valuation on $\mathscr{Q}$ such that $V(p) = \{2\}$ and $V(q) = \{1\}$. Clearly, $(\mathscr{Q}, V) \vDash 'U(p, q)[0]$ but $(\mathscr{Q}, V) \nvDash 'U(p, q \land U(p, q))[0]$, and hence $\mathscr{Q} \nvDash '(7)$. It follows that (ii) holds. $\square$

**4.2. THEOREM.** *Consider the following formulas:*

$$\text{(6)} \quad FFp \to Fp,$$

$$\text{(12)} \quad U(p, q) \to U(p, U(p, q)).$$

*In fact, (i) $\{(6)\} \vDash (12)$ and (ii) $(12) \notin TL_{US}(\{(6)\})$.*

*Proof.* The reader may be familiar with the fact that (6) defines transitivity. We have shown in the proof of 4.1 that (12) defines (7)\*. Hence (i) holds.

Let $V$ be a valuation on a frame $\mathscr{F}$, $\alpha$ a formula and $t$ an element of $T$. Then $(\mathscr{F}, V) \vDash ''\alpha[t]$ is defined recursively as follows:

- (a) $(\mathscr{F}, V) \vDash ''p[t]$ iff $t \in V(p)$, for every propositional variable $p$
- (b) $(\mathscr{F}, V) \vDash ''\neg\beta[t]$ iff $(\mathscr{F}, V) \nvDash ''\beta[t]$
- (c) $(\mathscr{F}, V) \vDash ''\beta \to \gamma[t]$ iff if $(\mathscr{F}, V) \vDash ''\beta[t]$, then $(\mathscr{F}, V) \vDash ''\gamma[t]$
- (d) $(\mathscr{F}, V) \vDash ''U(\beta, \gamma)[t]$ iff for some $t' \in T$ with $t < t'$, $(\mathscr{F}, V) \vDash ''\beta[t']$ and for every $t'' \in T$ with $t < t''$ and $t'' < t'$, there is a $t^* \in T$ with $t < t^*$ and $t^* < t''$ and $(\mathscr{F}, V) \vDash ''\gamma[t^*]$
- (e) $(\mathscr{F}, V) \vDash ''S(\beta, \gamma)[t]$ iff for some $t' \in T$ with $t' < t$, $(\mathscr{F}, V) \vDash ''\beta[t']$ and for every $t'' \in T$ with $t' < t''$ and $t'' < t$, there is a $t^* \in T$ with $t' < t^*$ and $t^* < t''$ and $(\mathscr{F}, V) \vDash ''\gamma[t^*]$.

We also write $\mathscr{F} \vDash ''\alpha$ to indicate that $(\mathscr{F}, V) \vDash ''\alpha[t]$ for every $t \in T$ and every valuation $V$ on $\mathscr{F}$.

It can be shown by induction that $\mathscr{Q} \vDash ''\alpha$ for every $\alpha \in TL_{US}(\{(6)\})$, where $\mathscr{Q} = (Q, <)$ as defined in the proof of 4.1. Details are omitted. Let $V$ be a valuation on $\mathscr{Q}$ such that $V(p) = \{2\}$ and $V(q) = \{1/n \mid n > 0\}$. Clearly, $(\mathscr{Q}, V) \vDash ''U(p, q)[0]$ and $(\mathscr{Q}, V) \nvDash ''U(p, q)[t]$ for every $t \in Q$ with $t \neq 0$, and hence $(\mathscr{Q}, V) \nvDash ''U(p, U(p, q))[0]$. Hence $\mathscr{Q} \nvDash ''(12)$. It follows that (ii) holds. $\square$

**4.3. THEOREM.** *Consider the following formulas:*

$$\text{(13)} \quad Fp \to G(p \lor Fp \lor Pp),$$

$$\text{(14)} \quad U(\neg p \land \neg q, \neg p) \to \neg U(p, q).$$

*In fact, (i) $\{(13)\} \vDash (14)$ and (ii) $(14) \notin TL_{US}(\{(13)\})$.*

*Proof.* The reader may be familiar with the fact that (13) defines right-connectedness, i.e.,

$$\text{(13)*} \quad \forall xyz(x < y \land x < z \to y = z \lor y < z \lor z < y).$$

So, it is sufficient for proving (i) to show that (14) also defines (13)\*.

Let $\mathscr{F}$ be any frame and suppose that $\mathscr{F} \vDash (13)^*$. Then for any valuation $V$ on $\mathscr{F}$ and any $t \in T$, if $(\mathscr{F}, V) \vDash U(\neg p \land \neg q, \neg p)[t]$, then, $(\mathscr{F}, V) \vDash \neg p \land \neg q[t']$ for some $t' \in T$ with $t < t'$, and $(\mathscr{F}, V) \vDash \neg p[t'']$ for every $t'' \in T$ with $t < t''$ and $t'' < t'$. Now consider any $t^* \in T$ with $t < t^*$ and $(\mathscr{F}, V) \vDash p[t^*]$. Since $\mathscr{F} \vDash (13)^*$, then $t' < t^*$. But $(\mathscr{F}, V) \nvDash q[t']$, hence $(\mathscr{F}, V) \vDash \neg U(p, q)[t]$. Hence $\mathscr{F} \vDash (14)$.

Suppose that $\mathscr{F} \nvDash (13)^*$. Then there are $t_0, t_1, t_2 \in T$ such that $t_0 < t_1$, $t_0 < t_2$, $t_1 \neq t_2$, $t_1 \not< t_2$ and $t_2 \not< t_1$. Let $V$ be a valuation on $\mathscr{F}$ such that $V(p) = \{t_2\}$ and $V(q) = T - \{t_1\}$. Then, $(\mathscr{F}, V) \vDash U(\neg p \land \neg q, \neg p)[t_0]$ since $t_0 < t_1$, $t_1 \neq t_2$ and $t_2 \not< t_1$, and $(\mathscr{F}, V) \vDash U(p, q)[t_0]$ since $t_0 < t_2$ and $t_1 \not< t_2$. Hence $\mathscr{F} \nvDash (14)$. $\square$

We now turn to (ii).

Let the mapping $\sigma$ on the set of all formulas be defined recursively as follows:

- (a) $\sigma(p) = p$ for every propositional variable $p$
- (b) $\sigma(\neg\alpha) = \neg\sigma(\alpha)$
- (c) $\sigma(\alpha \to \beta) = \sigma(\alpha) \to \sigma(\beta)$
- (d) $\sigma(U(\alpha, \beta)) = U(\sigma(\alpha), \top)$
- (e) $\sigma(S(\alpha, \beta)) = S(\sigma(\alpha), \top)$.

Let $\mathscr{N} = (N, <)$ where $N$ is the set of natural numbers and $<$ the usual order on $N$. It can be shown by induction that $\mathscr{N} \vDash \sigma(\alpha)$ for every $\alpha \in TL_{US}(\{(13)\})$. Details are omitted. Let $V$ be a valuation on $\mathscr{N}$ such that $V(p) = N - \{1\}$ and $V(q) = \phi$. Clearly $(\mathscr{N}, V) \vDash F(\neg p \land \neg q)[0]$ and $(\mathscr{N}, V) \nvDash \neg Fp[0]$, and hence $(\mathscr{N}, V) \nvDash \sigma(14)[0]$. Hence $\mathscr{N} \nvDash \sigma(14)$. It follows that $(14) \notin TL_{US}(\{(13)\})$. $\square$

**4.4. THEOREM.** *Let $\Sigma$ be the set of following formulas:*

$$\text{(8)} \quad S(p, q) \to S(p, q \land S(p, q)),$$

$$\text{(13)} \quad Fp \to G(p \lor Fp \lor Pp).$$

*Consider the formula*

$$\text{(10)} \quad U(p, q) \land U(r, s) \to U(p \land r, q \land s) \lor U(p \land s, q \land s) \lor U(q \land r, q \land s).$$

*In fact, (i) $\Sigma \vDash (10)$ and (ii) $(10) \notin TL_{US}(\Sigma)$.*

*Proof.* It can be easily shown that (8) defines

$$\text{(8)*} \quad \forall xyz(x < y \land x < z \land z < y \to \forall u(x < u \land u < z \to u < y)),$$

just as (7) defines (7)\*. Since (13) defines right-connectedness, it is sufficient for proving (i) to show that (10) defines

$$\text{(10)*} \quad \forall xyz(x < y \land x < z \to y = z \lor (y < z \land \forall u(x < u \land u < y \to u < z)) \lor (z < y \land \forall u(x < u \land u < z \to u < y))).$$

Let $\mathscr{F}$ be any frame and suppose that $\mathscr{F} \vDash (10)^*$. Then for any valuation $V$ on $\mathscr{F}$ and any $t \in T$, if $(\mathscr{F}, V) \vDash U(p, q) \land U(r, s)[t]$, there are $t_1, t_2 \in T$ such that $t < t_1$, $t < t_2$, $(\mathscr{F}, V) \vDash p[t_1]$, $(\mathscr{F}, V) \vDash r[t_2]$, $(\mathscr{F}, V) \vDash q[t']$ for every $t' \in T$ with $t < t'$ and $t' < t_1$, and $(\mathscr{F}, V) \vDash s[t'']$ for every $t'' \in T$ with $t < t''$ and $t'' < t_2$. Since $\mathscr{F} \vDash (10)^*$, we have either (a) $t_1 = t_2$, or (b) $t_1 < t_2$ and $t' < t_2$ for every $t' \in T$ with $t < t'$ and $t' < t_1$, or (c) $t_2 < t_1$ and $t'' < t_1$ for every $t'' \in T$ with $t < t''$ and $t'' < t_2$. If (a) holds, $(\mathscr{F}, V) \vDash U(p \land r, q \land s)[t]$; if (b) holds, $(\mathscr{F}, V) \vDash U(p \land s, q \land s)[t]$; and if (c) holds, $(\mathscr{F}, V) \vDash U(q \land r, q \land s)[t]$. Hence $\mathscr{F} \vDash (10)$.

Suppose that $\mathscr{F} \nvDash (10)^*$. Then there are $t_0, t_1, t_2 \in T$ such that $t_0 < t_1$, $t_0 < t_2$, $t_1 \neq t_2$ and the following (d) and (e) hold:

- (d) $t_1 \not< t_2$ or for some $t' \in T$, $t_0 < t'$ and $t' < t_1$ and $t' \not< t_2$,
- (e) $t_2 \not< t_1$ or for some $t'' \in T$, $t_0 < t''$ and $t'' < t_2$ and $t'' \not< t_1$.

Then, let $V$ be a valuation on $\mathscr{F}$ such that $V(p) = \{t_1\}$, $V(q) = \{t \mid t < t_1\}$, $V(r) = \{t_2\}$ and $V(s) = \{t \mid t < t_2\}$. Obviously, $(\mathscr{F}, V) \vDash U(p, q) \land U(r, s)[t_0]$. Since $t_1 \neq t_2$, $(\mathscr{F}, V) \nvDash U(p \land r, q \land s)[t_0]$. For any $t \in T$ with $t_0 < t$ and $(\mathscr{F}, V) \vDash p \land s[t]$, $t = t_1$ and $t_1 < t_2$. Then by (d) there is a $t' \in T$ with $t_0 < t'$, $t' < t$ and $t' \not< t_2$, and hence $(\mathscr{F}, V) \nvDash q \land s[t']$. Hence $(\mathscr{F}, V) \nvDash U(p \land s, q \land s)[t_0]$. Similarly, we have $(\mathscr{F}, V) \nvDash U(q \land r, q \land s)[t_0]$ by (e). Hence $\mathscr{F} \nvDash (10)$. $\square$

To show that (ii) holds, we make use of the mapping $\sigma$ and the frame $\mathscr{N}$ defined in the proof of 4.3. It can be easily shown by induction that $\mathscr{N} \vDash \sigma(\alpha)$ for every $\alpha \in TL_{US}(\Sigma)$. Let $V$ be a valuation on $\mathscr{N}$ such that $V(p) = \{1\}$, $V(q) = \phi$, $V(r) = \{2\}$ and $V(s) = \phi$. Clearly $(\mathscr{N}, V) \vDash Fp \land Fr[0]$, but neither $(\mathscr{N}, V) \vDash F(p \land r)[0]$ nor $(\mathscr{N}, V) \vDash F(p \land s)[0]$ nor $(\mathscr{N}, V) \vDash F(q \land r)[0]$, and hence $\mathscr{N} \nvDash \sigma(10)$. It follows that $(10) \notin TL_{US}(\Sigma)$. $\square$

**4.5. THEOREM.** *Let $\Sigma$ be the set of following formulas:*

$$\text{(9)} \quad U(q \land U(p, q), q) \to U(p, q),$$

$$\text{(15)} \quad FGp \to GFp.$$

*In fact, (i) $\Sigma \vDash (10)$ and (ii) $(10) \notin TL_{US}(\Sigma)$.*

*Proof.* The reader may be familiar with the fact that (15) defines

$$\text{(15)*} \quad \forall xyz(x < y \land x < z \to \exists u(y < u \land z < u)).$$

Since we have shown in the proof of 4.4 that (10) defines (10)\*, then, for proving (i), it is sufficient to show that (9) defines

$$\text{(9)*} \quad \forall xyz(x < y \land y < z \to x < z \land \forall u(x < u \land u < z \to u = y \lor u < y \lor y < u)).$$

Let $\mathscr{F}$ be any frame and suppose that $\mathscr{F} \vDash (9)^*$. Then for any valuation $V$ on $\mathscr{F}$ and any $t \in T$, if $(\mathscr{F}, V) \vDash U(q \land U(p, q), q)[t]$, there are $t_1, t_2 \in T$ such that $t < t_1$, $t_1 < t_2$, $(\mathscr{F}, V) \vDash q[t_1]$, $(\mathscr{F}, V) \vDash p[t_2]$ and $(\mathscr{F}, V) \vDash q[t']$ for every $t' \in T$ with $t < t'$ and $t' < t_1$, and $(\mathscr{F}, V) \vDash q[t'']$ for every $t'' \in T$ with $t_1 < t''$ and $t'' < t_2$. Clearly, $t < t_2$ for $\mathscr{F} \vDash (9)^*$. Consider any $t^* \in T$ with $t < t^*$ and $t^* < t_2$. Since $\mathscr{F} \vDash (9)^*$, we have either $t^* = t_1$ or $t^* < t_1$ or $t_1 < t^*$, and hence $(\mathscr{F}, V) \vDash q[t^*]$. It follows that $(\mathscr{F}, V) \vDash U(p, q)[t]$. Hence $\mathscr{F} \vDash (9)$.

Suppose that $\mathscr{F} \nvDash (9)^*$. Then there are $t_0, t_1, t_2 \in T$ such that $t_0 < t_1$, $t_1 < t_2$ and either (a) $t_0 \not< t_2$ or (b) there is a $t' \in T$ such that $t_0 < t'$, $t' < t_2$, $t' \neq t_1$, $t' \not< t_1$ and $t_1 \not< t'$. Let $V$ be a valuation on $\mathscr{F}$ such that $V(p) = \{t_2\}$ and $V(q) = \{t_1\} \cup \{t \mid t < t_1\} \cup \{t \mid t_1 < t\}$. It is easy to see that $(\mathscr{F}, V) \vDash U(q \land U(p, q), q)[t_0]$. Now, if (a) holds, trivially $(\mathscr{F}, V) \nvDash U(p, q)[t_0]$. If (a) fails, again $(\mathscr{F}, V) \nvDash U(p, q)[t_0]$ since by (b) there is a $t' \in T$ with $t_0 < t'$ and $t' < t_2$ and $(\mathscr{F}, V) \nvDash q[t']$. Hence $\mathscr{F} \nvDash (9)$. $\square$

To show that (ii) holds, we can make use of the mapping $\sigma$ and the frame $\mathscr{N}$ defined in the proof of 4.3. It can be easily shown by induction that $\mathscr{N} \vDash \sigma(\alpha)$ for every $\alpha \in TL_{US}(\Sigma)$. Since we have shown in the proof of 4.4 that $\mathscr{N} \nvDash \sigma(10)$, it follows that $(10) \notin TL_{US}(\Sigma)$. $\square$

Among all incomplete $U,S$-tense logics, there are some consistent logics having no frames at all.

**4.6. THEOREM.** *Let $\Sigma$ be the set of following formulas:*

$$\text{(6)} \quad FFp \to Fp,$$

$$\text{(16)} \quad U(\top, \bot),$$

$$\text{(17)} \quad FFGp \to p.$$

*Then, (i) $\Sigma \vDash \bot$ and (ii) $\bot \notin TL_{US}(\Sigma)$.*

*Proof.* It is easy to verify that (16) defines

$$\text{(16)*} \quad \forall x \exists y(x < y \land \forall z \neg(x < z \land z < y)),$$

and (17) defines "circulation", i.e.,

$$\text{(17)*} \quad \forall xyz(x < y \land y < z \to z < x).$$

Hence, it can be easily shown that (i) holds.

To show that (ii) holds, we define an "erasure" transformation $\tau$, on the set of all formulas, recursively as follows:

- (a) $\tau(p) = p$ for every propositional variable $p$
- (b) $\tau(\neg\alpha) = \neg\tau(\alpha)$
- (c) $\tau(\alpha \to \beta) = \tau(\alpha) \to \tau(\beta)$
- (d) $\tau(U(\alpha, \beta)) = \tau(\alpha)$
- (e) $\tau(S(\alpha, \beta)) = \tau(\alpha)$.

A simple induction will show that for every $\alpha \in TL_{US}(\Sigma)$, $\tau(\alpha)$ is a classical tautology. Since $\tau(\bot)$ is not a tautology, it follows that $\bot \notin TL_{US}(\Sigma)$. $\square$

**4.7. THEOREM.** *Let $\Sigma$ be the set of following formulas:*

$$\text{(5)} \quad U(p, q) \to U(p, r),$$

$$\text{(6)} \quad FFp \to Fp,$$

$$\text{(18)} \quad F\top.$$

*Then, (i) $\Sigma \vDash \bot$ and (ii) $\bot \notin TL_{US}(\Sigma)$.*

*Proof.* The reader may be familiar with the fact that (18) defines

$$\text{(18)*} \quad \forall x \exists y(x < y).$$

Hence, for proving (i), it is sufficient to show that (5) defines intransitivity, i.e.,

$$\text{(5)*} \quad \forall xyz(x < y \land y < z \to \neg(x < z)).$$

Let $\mathscr{F}$ be any frame and suppose that $\mathscr{F} \vDash (5)^*$. Then for any valuation $V$ on $\mathscr{F}$ and any $t \in T$, if $(\mathscr{F}, V) \vDash U(p, q)[t]$, there is a $t' \in T$ with $t < t'$ and $(\mathscr{F}, V) \vDash p[t']$. Since $\mathscr{F} \vDash (5)^*$, there is no $t'' \in T$ with $t < t''$ and $t'' < t'$, and hence $(\mathscr{F}, V) \vDash U(p, r)[t]$. Hence $\mathscr{F} \vDash (5)$.

Suppose that $\mathscr{F} \nvDash (5)^*$. Then there are $t_0, t_1, t_2 \in T$ such that $t_0 < t_1$, $t_1 < t_2$ and $t_0 < t_2$. Let $V$ be a valuation on $\mathscr{F}$ such that $V(p) = \{t_2\}$, $V(q) = T$ and $V(r) = \phi$. Clearly $(\mathscr{F}, V) \nvDash (5)[t_0]$, and hence, $\mathscr{F} \nvDash (5)$. $\square$

By applying the erasure transformation $\tau$ defined in the proof of 4.6, we can easily obtain (ii). $\square$

The following theorems can be similarly proved. Details are omitted.

**4.8. THEOREM.** *Let $\Sigma$ be the set of following formulas:*

$$\text{(16)} \quad U(\top, \bot),$$

$$\text{(19)} \quad Fp \to FFp.$$

*Then, (i) $\Sigma \vDash \bot$ and (ii) $\bot \notin TL_{US}(\Sigma)$. $\square$*

**4.9. THEOREM.** *Let $\Sigma$ be the set of following formulas:*

$$\text{(16)} \quad U(\top, \bot),$$

$$\text{(20)} \quad Gp \to p.$$

*Then, (i) $\Sigma \vDash \bot$ and (ii) $\bot \notin TL_{US}(\Sigma)$. $\square$*

**4.10. THEOREM.** *Let $\Sigma$ be the set of following formulas:*

$$\text{(5)} \quad U(p, q) \to U(p, r),$$

$$\text{(18)} \quad F\top,$$

$$\text{(19)} \quad Fp \to FFp.$$

*Then, (i) $\Sigma \vDash \bot$ and (ii) $\bot \notin TL_{US}(\Sigma)$. $\square$*

**4.11. THEOREM.** *Let $\Sigma$ be the set of following formulas:*

$$\text{(5)} \quad U(p, q) \to U(p, r),$$

$$\text{(20)} \quad Gp \to p.$$

*Then, (i) $\Sigma \vDash \bot$ and (ii) $\bot \notin TL_{US}(\Sigma)$. $\square$*

---
