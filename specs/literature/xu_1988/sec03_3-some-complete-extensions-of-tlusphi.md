## 3. Some Complete Extensions of $TL_{US}(\phi)$

We will present in this section some complete $U,S$-tense logics extending $TL_{US}(\phi)$. To establish the completeness of each of these $U,S$-tense logics, we will make use of the second version of completeness and only sketch the modifications in the work of Section 2, beyond simply understanding the notions of syntactic consequence and consistency, and hence of MCS and DCS, as relative to the logic to be considered.

Let $\mathscr{C}_1$ be the class of all intransitive frames, i.e., of all frames $\mathscr{F}$ satisfying

$$\mathscr{F} \vDash \forall xyz(x < y \land y < z \to \neg(x < z)).$$

Although there is no assumption of intransitivity about the structure of Time, $\mathscr{C}_0$ and $\mathscr{C}_1$ give us the same ordinary $G,H$-tense logic, and hence there is no $G,H$-tense formula defining intransitivity. When we enter the field of $U,S$-tense logics, the situation is different, as the reader will see.

**3.1. THEOREM.** *Let $\Sigma_1$ be the set of a single formula*

$$\text{(5)} \quad U(p, q) \to U(p, r).$$

*Then, $TL_{US}(\Sigma_1) = \mathrm{Th}(\mathscr{C}_1)$.*

*Proof.* Sketched below.

It is easy to verify that for every $\mathscr{F} \in \mathscr{C}_1$, $\mathscr{F} \vDash (5)$ (cf. Section 4), and hence that $TL_{US}(\Sigma_1) \subseteq \mathrm{Th}(\mathscr{C}_1)$. To show that $\mathrm{Th}(\mathscr{C}_1) \subseteq TL_{US}(\Sigma_1)$, we first need the following lemma.

**3.1.1. LEMMA.** *Suppose that $r(A, B, C)$ and $\neg U(\gamma, \beta) \in A$. Then, $\neg\gamma \in C$.*

*Proof.* Let $B^*$ be such that $B \subseteq B^*$ and $R(A, B^*, C)$. We claim that $\bot \in B^*$. This can be verified by showing that $r(A, \psi \land \bot, C)$ for every $\psi \in B^*$. But when $\psi \in B^*$, $U(\varphi, \psi) \in A$ for every $\varphi \in C$. By (5) $U(\varphi, \psi) \to U(\varphi, \psi \land \bot) \in TL_{US}(\Sigma_1)$, and hence $U(\varphi, \psi \land \bot) \in A$ for every $\varphi \in C$.

Suppose that $\gamma \in C$. Then, $U(\gamma, \bot) \in A$ for $\bot \in B^*$. Now it can be shown that $U(\gamma, \bot) \to U(\gamma, \beta)$ belongs to every $U,S$-tense logic, and hence $U(\gamma, \beta) \in A$. $\square$

Next, we need to replace the clause C1 in 2.5 by

- **C1'** $(T, <) \in \mathscr{C}_1$ satisfying $(T, <) \vDash \forall xy \neg(x < y \land y < x)$.

By 3.1.1, every element of $K$ satisfies the condition C5a for the antecedent of C5a is never fulfilled. Then for any $\alpha \notin TL_{US}(\Sigma_1)$ to show that $\alpha \notin \mathrm{Th}(\mathscr{C}_1)$, we need only to apply 2.7 and its dual to handle C6 to construct a frame $\mathscr{F} \in \mathscr{C}_1$ such that $\mathscr{F} \nvDash \alpha$, from which the completeness of $TL_{US}(\Sigma_1)$ follows. $\square$

Let $\mathscr{C}_2$ be the class of all transitive frames, i.e., of all frames $\mathscr{F}$ satisfying

$$\mathscr{F} \vDash \forall xyz(x < y \land y < z \to x < z).$$

**3.2. THEOREM.** *Let $\Sigma_2$ be the set of following formulas*

$$\text{(6)} \quad FFp \to Fp,$$

$$\text{(7)} \quad U(p, q) \to U(p, q \land U(p, q)),$$

$$\text{(8)} \quad S(p, q) \to S(p, q \land S(p, q)).$$

*Then, $TL_{US}(\Sigma_2) = \mathrm{Th}(\mathscr{C}_2)$.*

*Proof.* Sketched below.

It can be easily shown by induction that $TL_{US}(\Sigma_2) \subseteq \mathrm{Th}(\mathscr{C}_2)$ (cf. Section 4). To show that $\mathrm{Th}(\mathscr{C}_2) \subseteq TL_{US}(\Sigma_2)$, we first need the following preliminary lemmas.

**3.2.1. LEMMA.** *Suppose that $R(A, B, C)$. Then we have*

- *(i) for every $\beta \in B$ and every $\gamma \in C$, $U(\gamma, \beta) \in B$, and*
- *(ii) for every $\beta \in B$ and every $\alpha \in A$, $S(\alpha, \beta) \in B$.*

*Proof.* We only prove (i). Suppose for contradiction that $U(\gamma, \beta) \notin B$ for some $\beta \in B$ and $\gamma \in C$. Then by 2.0 there are $\beta' \in B$ and $\gamma' \in C$ such that $\neg U(\gamma', \beta' \land U(\gamma, \beta)) \in A$. It is easy to see that

$$U(\gamma'', \beta'' \land U(\gamma'', \beta'')) \to U(\gamma', \beta' \land U(\gamma, \beta)) \in TL_{US}(\phi),$$

where $\gamma'' = \gamma \land \gamma'$ and $\beta'' = \beta \land \beta'$. Hence by (7), $\neg U(\gamma'', \beta'') \in A$. But by hypothesis $U(\gamma'', \beta'') \in A$ since $\beta'' \in B$ and $\gamma'' \in C$, contrary to our assumption of consistency on $A$. $\square$

**3.2.2. LEMMA.** *Suppose that $r(A, B, C)$, $\neg U(\gamma, \beta) \in A$ and $\gamma \in C$. Then there are $B'$, $D$, $B''$ such that $R(A, B', D)$, $R(D, B'', C)$, $B \subseteq B' \cap D \cap B''$ and $\neg\beta \in D$.*

*Proof.* Let $B^*$ be such that $B \subseteq B^*$ and $R(A, B^*, C)$. Clearly, $\beta \notin B^*$ and hence $B^* \cup \{\neg\beta\}$ is consistent. Let $D$ be a MCS containing $B^* \cup \{\neg\beta\}$. By 3.2.1 and 2.1 we have $r(A, B^*, D)$ and $r(D, B^*, C)$. Hence we can complete the proof by applying 2.0. $\square$

**3.2.3. LEMMA.** *Suppose that $r(A, B', D)$ and $r(D, B'', C)$. Then there is a $B$ such that $r(A, B, C)$ and $B \subseteq B' \cap D \cap B''$.*

*Proof.* Let $B = TL_{US}(\Sigma_2)$. Clearly, $B$ is a DCS and $B \subseteq B' \cap D \cap B''$. By (6) it is easy to see that $r(A, \top, C)$, and hence by the rule of substitution of equivalents, $r(A, \beta, C)$ for every $\beta \in B$. $\square$

Next, we need to replace the clauses C1 and C4 in 2.5 by

- **C1''** $(T, <) \in \mathscr{C}_2$ satisfying $(T, <) \vDash \forall xy \neg(x < y \land y < x)$

and

- **C4''** for all $t, t'', t' \in T$ with $t < t'' < t'$, $g(t, t') \subseteq g(t, t'') \cap f(t'') \cap g(t'', t')$

respectively. And to get through 2.6 and 2.7, we need to replace (b), (c), (d) in 2.6 by

- (b\*) $<' \ = \ < \ \cup \{(t_1, t_3), (t_3, t_2)\} \cup \{(t', t_3) \mid t' < t_1\} \cup \{(t_3, t'') \mid t_2 < t''\}$,
- (c\*) $f' = f \cup \{(t_3, D)\}$,
- (d\*) $g' = g \cup \{((t_1, t_3), B'), ((t_3, t_2), B'')\} \cup \{((t', t_3), TL_{US}(\Sigma_2)) \mid t' < t_1\} \cup \{((t_3, t''), TL_{US}(\Sigma_2)) \mid t_2 < t''\}$

respectively, where $B'$, $D$, $B''$ are obtained by applying 3.2.2 instead of 2.4; and to replace (b'), (c'), (d') in 2.7 by

- (b\*\*) $<' \ = \ < \ \cup \{(t_1, t_2)\} \cup \{(t, t_2) \mid t < t_1\}$,
- (c\*\*) $f' = f \cup \{(t_2, C)\}$,
- (d\*\*) $g' = g \cup \{((t_1, t_2), B)\} \cup \{((t, t_2), TL_{US}(\Sigma_2)) \mid t < t_1\}$

respectively, where $B$ and $C$ are still obtained by applying 2.2. $\square$

Now consider the class $\mathscr{C}_3$ of all frames $\mathscr{F}$ satisfying

$$\mathscr{F} \vDash \forall xyz(x < y \land y < z \to x < z \land \forall u (x < u \land u < z \to u = y \lor u < y \lor y < u)).$$

It can be shown that $\mathscr{C}_2$ and $\mathscr{C}_3$ give us the same $G,H$-tense logic. But as the reader will see, they give us different $U,S$-tense logics.

**3.3. THEOREM.** *Let $\Sigma_3$ be the set of formulas (7), (8) and*

$$\text{(9)} \quad U(q \land U(p, q), q) \to U(p, q).$$

*Then, $TL_{US}(\Sigma_3) = \mathrm{Th}(\mathscr{C}_3)$.*

*Proof.* Sketched below.

It can be easily shown that for every $\mathscr{F} \in \mathscr{C}_3$, $\mathscr{F} \vDash \Sigma_3$ (cf. Section 4), and hence by induction, that $TL_{US}(\Sigma_3) \subseteq \mathrm{Th}(\mathscr{C}_3)$. To show that $\mathrm{Th}(\mathscr{C}_3) \subseteq TL_{US}(\Sigma_3)$, we need to replace C1 in 2.5 by

- **C1\*** $(T, <) \in \mathscr{C}_3$ satisfying $(T, <) \vDash \forall xy \neg(x < y \land y < x)$

and C4 by C4''. Note that all 3.2.1--3.2.3 still hold for $TL_{US}(\Sigma_3)$, and hence, to get through 2.7 we can define $\mu'$ as was done in proving 3.2 but replacing $TL_{US}(\Sigma_2)$ by $TL_{US}(\Sigma_3)$.

Now we turn to 2.6. The following proof of 2.6 is due to John P. Burgess [1]. The proof is by induction on the number $n$ of elements of $\{t \mid t_1 < t \text{ and } t < t_2\}$: Case $n = 0$. We define $\mu'$ as was done in proving 3.2 but replacing $TL_{US}(\Sigma_2)$ by $TL_{US}(\Sigma_3)$. Case $n = m + 1$. By C1\* there is a $t' \in \{t \mid t_1 < t \text{ and } t < t_2\}$ such that no $t \in T$ with $t_1 < t$ and $t < t'$. Now, if $\neg U(\gamma, \beta) \in f(t')$, we can reduce to the case $n = m$ by replacing $t_1$ by $t'$. If $U(\gamma, \beta) \in f(t')$, we must have $\beta \land U(\gamma, \beta) \in f(t')$, otherwise $t_1, t_2, \gamma, \beta$ would not constitute a counterexample to C5a. Since $\neg U(\gamma, \beta) \in f(t_1)$, $\neg U(\beta \land U(\gamma, \beta), \beta) \in f(t_1)$ by (9). Hence we can reduce to the case $n = 0$ by replacing $\gamma$ by $\beta \land U(\gamma, \beta)$ and $t_2$ by $t'$. $\square$

Let $\mathscr{C}_4$ be the class of all linear frames, i.e., of all transitive frames $\mathscr{F}$ satisfying

$$\mathscr{F} \vDash \forall xy(x = y \lor x < y \lor y < x).$$

Burgess has presented in [1] a set $\Sigma$ of axioms such that, in our notation, $TL_{US}(\Sigma) = \mathrm{Th}(\mathscr{C}_4)$. In fact, we could delete some formulas from his set $\Sigma$ of axioms.

Let $\Sigma_4$ be the set of formulas (7), (8), (9) together with

$$\text{(10)} \quad U(p, q) \land U(r, s) \to U(p \land r, q \land s) \lor U(p \land s, q \land s) \lor U(q \land r, q \land s)$$

and

$$\text{(11)} \quad S(p, q) \land S(r, s) \to S(p \land r, q \land s) \lor S(p \land s, q \land s) \lor S(q \land r, q \land s).$$

It can be shown that $TL_{US}(\Sigma_4) = \mathrm{Th}(\mathscr{C}_4)$ by applying the work of Burgess in [1] together with our 3.2.1 and 3.2.2. Note that the adoption of 3.2.1 will yield a little simplification of the proofs of some lemmas in [1] (see 2.7 and 2.8 in [1]). Details are omitted.

Let $\Sigma_5 = \Sigma_4 - \{(10)\}$, and $\mathscr{C}_5$ the class of all transitive frames $\mathscr{F}$ satisfying

$$\mathscr{F} \vDash \forall xyz(y < x \land z < x \to y = z \lor y < z \lor z < y).$$

It can be shown that $TL_{US}(\Sigma_5) = \mathrm{Th}(\mathscr{C}_5)$ by the work (with some modifications) of proving $TL_{US}(\Sigma_4) = \mathrm{Th}(\mathscr{C}_4)$. Details are omitted too.

---
