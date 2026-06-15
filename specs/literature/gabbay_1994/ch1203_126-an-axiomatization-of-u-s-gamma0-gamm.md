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
