## 2. Minimal $U,S$-Tense Logic $TL_{US}(\phi)$

A simple induction will show that for every set $\Sigma$ of formulas and every formula $\alpha$, $\alpha \in TL_{US}(\Sigma)$ only if $\Sigma \vDash \alpha$, and in particular, $\alpha \in TL_{US}(\phi)$ only if $\phi \vDash \alpha$. We show in this section that for every $\alpha$, $\alpha \notin TL_{US}(\phi)$ only if $\phi \nvDash \alpha$. This means that $TL_{US}(\phi) = \mathrm{Th}(\mathscr{C}_0)$ for the class $\mathscr{C}_0$ of all frames, and hence makes $TL_{US}(\phi)$ deserve the title of minimal $U,S$-tense logic. Our proof is similar to the one given by John P. Burgess in [1] for an axiomatization of $U,S$-tense logic for the class of all linear frames, using maximally consistent sets as well as deductively closed sets.

In the following we use $A, B, C, D, \ldots$, to range over sets of formulas. We say that $\alpha$ is a syntactic consequence of $A$ (with respect to $TL_{US}(\phi)$) if there are $\alpha_1, \ldots, \alpha_n \in A$ such that $\alpha_1 \land \ldots \land \alpha_n \to \alpha \in TL_{US}(\phi)$. Taking $n = 0$, every element of $TL_{US}(\phi)$ is a syntactic consequence of $A$. $A$ is consistent (with respect to $TL_{US}(\phi)$) if $\bot$ is not a syntactic consequence of $A$. A maximally consistent set (MCS) is any consistent set $A$ satisfying $\alpha \in A$ iff $\neg\alpha \notin A$ for every $\alpha$. A deductively closed set (DCS) is any $A$ containing all its syntactic consequences.

Let $A$, $C$ be any MCSs. Following Burgess, we write $r(A, \beta, C)$ to indicate that $U(\gamma, \beta) \in A$ for every $\gamma \in C$, and $r(A, B, C)$ that $B$ is a DCS and $r(A, \beta, C)$ holds for every $\beta \in B$, and $R(A, B, C)$ that $r(A, B, C)$ holds but $r(A, B', C)$ never holds for any proper extension $B'$ of $B$.

**2.0. Notes.** (i) Whenever $r(A, \beta, C)$ holds, there is a $B$ such that $r(A, B, C)$ and $\beta \in B$. (ii) Whenever $r(A, B, C)$ holds, there is a $B'$ such that $B \subseteq B'$ and $R(A, B', C)$. (iii) Whenever $R(A, B, C)$ holds and $\beta \notin B$, there is a $\beta' \in B$ such that $r(A, \gamma \land \beta', C)$ does not hold.

The following two lemmas are due to John P. Burgess [1].

**2.1. LEMMA.** *Let $A$, $C$ be any MCSs and $\beta$ any formula. Then $r(A, \beta, C)$ holds iff $S(\alpha, \beta) \in C$ for every $\alpha \in A$.*

**2.2. LEMMA.** *Suppose that $A$ is a MCS and $U(\gamma, \beta) \in A$. Then there are $B$, $C$ such that $R(A, B, C)$, $\gamma \in C$ and $\beta \in B$.*

Note that 2.2 has a dual: Suppose that $A$ is a MCS and $S(\gamma, \beta) \in A$. Then there are $B$, $C$ such that $R(C, B, A)$, $\gamma \in C$ and $\beta \in B$. In the following we will omit all formulations of such duals.

**2.3. LEMMA.** *Suppose that $R(A, B, C)$. Then (i) $S(\alpha, \top) \in B$ for every $\alpha \in A$, and (ii) $U(\gamma, \top) \in B$ for every $\gamma \in C$.*

*Proof.* We only prove (i). Suppose that $S(\alpha, \top) \notin B$ for some $\alpha \in A$. Then by 2.0 (iii) there are $\beta \in B$ and $\gamma \in C$ such that $\neg U(\gamma, \beta \land S(\alpha, \top)) \in A$. But this is impossible. For it is not hard to see by (1) and (3) that $\alpha \land U(\gamma, \beta) \to U(\gamma, \beta \land S(\alpha, \top)) \in TL_{US}(\phi)$, and by hypothesis $\alpha \land U(\gamma, \beta) \in A$, and hence $U(\gamma, \beta \land S(\alpha, \top)) \in A$. $\square$

**2.4. LEMMA.** *Suppose that $r(A, B, C)$, $\neg U(\gamma, \beta) \in A$ and $\gamma \in C$. Then there are $B'$, $D$, $B''$ such that $R(A, B', D)$, $R(D, B'', C)$ and $B \cup \{\neg\beta\} \subseteq D$.*

*Proof.* Let $B^*$ be such that $B \subseteq B^*$ and $R(A, B^*, C)$. Clearly $\beta \notin B^*$, and hence $B^* \cup \{\neg\beta\}$ is consistent. Let $D$ be a MCS containing $B^* \cup \{\neg\beta\}$. By 2.3 and 2.1 we have $r(A, \top, D)$ and $r(D, \top, C)$. Hence we can complete the proof by applying 2.0. $\square$

**2.5. DEFINITION.** Fix a denumerable infinite set $T^*$. Let $K$ be the set of all quadruples $(T, <, f, g)$ such that

- **C0** $T$ is a finite subset of $T^*$
- **C1** $(T, <)$ is a frame satisfying $(T, <) \vDash \forall xy \neg(x < y \land y < x)$
- **C2** $f$ is a function from $T$ to the set of all MCSs, and $g$ is a function from $\{(t, t') \mid t, t' \in T \text{ and } t < t'\}$ to the set of all DCSs
- **C3** for all $t, t' \in T$ with $t < t'$, $r(f(t), g(t, t'), f(t'))$
- **C4** for all $t, t' \in T$ with $t < t'$, $g(t, t') \subseteq f(t'')$ for every $t'' \in T$ with $t < t''$ and $t'' < t'$.

We want to have some $(T, <, f, g)$ satisfying all C1--C4 as well as the following conditions and their duals (labelled C5b and C6b respectively)

- **C5a** for all $t, t' \in T$ with $t < t'$, if $\neg U(\gamma, \beta) \in f(t)$ and $\gamma \in f(t')$, there is a $t'' \in T$ with $t < t''$ and $t'' < t'$ and $\neg\beta \in f(t'')$

- **C6a** for all $t \in T$, if $U(\gamma, \beta) \in f(t)$, there is a $t' \in T$ with $t < t'$, $\gamma \in f(t')$ and $\beta \in g(t, t')$.

Note that by 2.1, if any $(T, <, f, g)$ satisfies C5a, it satisfies C5b as well, and vice versa.

Obviously, the elements of $K$ cannot in general satisfy C5 and C6. Let $\mu = (T, <, f, g)$ and $\mu' = (T', <', f', g')$ be elements of $K$. We say that $\mu'$ is an extension of $\mu$ if (when relations and functions are identified with sets of ordered pairs) $T \subseteq T'$, $< \ = \ <' \cap T^2$, $f \subseteq f'$ and $g \subseteq g'$.

**2.6. LEMMA.** *Let $\mu = (T, <, f, g) \in K$ and suppose that $t_1, t_2, \gamma, \beta$ constitute a counterexample to C5a for $\mu$. Then there is an extension $\mu' = (T', <', f', g') \in K$ of $\mu$ for which $t_1, t_2, \gamma, \beta$ do not constitute a counterexample to C5a.*

*Proof.* We apply 2.4 to $A = f(t_1)$, $B = g(t_1, t_2)$ and $C = f(t_2)$ to obtain $B'$, $D$, $B''$, and then fix $t_3 \in T^* - T$ and set

- (a) $T' = T \cup \{t_3\}$,
- (b) $<' \ = \ < \ \cup \{(t_1, t_3), (t_3, t_2)\}$,
- (c) $f' = f \cup \{(t_3, D)\}$,
- (d) $g' = g \cup \{((t_1, t_3), B'), ((t_3, t_2), B'')\}$. $\square$

**2.7. LEMMA.** *Let $\mu = (T, <, f, g) \in K$ and suppose that $t_1, \gamma, \beta$ constitute a counterexample to C6a for $\mu$. Then there is an extension $\mu' = (T', <', f', g') \in K$ of $\mu$ for which $t_1, \gamma, \beta$ do not constitute a counterexample to C6a.*

*Proof.* We apply 2.2 to $A = f(t_1)$ to obtain $B$, $C$, and then fix $t_2 \in T^* - T$ and set

- (a') $T' = T \cup \{t_2\}$,
- (b') $<' \ = \ < \ \cup \{(t_1, t_2)\}$,
- (c') $f' = f \cup \{(t_2, C)\}$,
- (d') $g' = g \cup \{((t_1, t_2), B)\}$. $\square$

**2.8. THEOREM.** *For every $\alpha$, if $\alpha \notin TL_{US}(\phi)$, then $\phi \nvDash \alpha$.*

*Proof.* Assume that $\alpha \notin TL_{US}(\phi)$. We construct a frame $\mathscr{F}$ such that $\mathscr{F} \nvDash \alpha$.

Let $A_0$ be any MCS containing $\neg\alpha$. Choose a $t_0 \in T^*$ and define $\mu_0 = (T_0, <_0, f_0, g_0) \in K$ by setting $T_0 = \{t_0\}$, $<_0 = \phi$, $f_0 = \{(t_0, A_0)\}$ and $g_0 = \phi$. By repeatedly applying 2.5, 2.6 and the dual of 2.6, we can form a sequence $\{\mu_n\}$ of elements of $K$ in such a way that for each $n$, $\mu_{n+1}$ is an extension of $\mu_n$, and whenever we have a counterexample to C5a or C6a or C6b for a given $\mu_n$, there will be a $\mu_m$ in the sequence with $n < m$ for which it is no longer a counterexample. Details are omitted. Finally, let $T$ be the union of all $T_n$, and $<$ of all $<_n$, and $f$ of all $f_n$, and $g$ of all $g_n$. Clearly $(T, <, f, g)$ satisfies all the conditions C1--C6.

Let $V$ be a valuation on $\mathscr{F} = (T, <)$ such that for every propositional variable $p$ and every $t \in T$, $t \in V(p)$ iff $p \in f(t)$. Then it can be shown by induction that $(\mathscr{F}, V) \vDash \beta[t]$ iff $\beta \in f(t)$ for every $\beta$ and every $t \in T$, from which $\mathscr{F} \nvDash \alpha$ follows immediately. $\square$

The restriction C1 in 2.5 enables us to have the following

**2.9. THEOREM.** *There is no formula defining any of the following first-order sentences:*

- *(i)* $\forall xy \neg(x < y \land y < x)$,
- *(ii)* $\forall x \neg(x < x)$,
- *(iii)* $\forall xy(x < y \land y < x \to x = y)$. $\square$

Now it is convenient to insert some remarks about some properties of all $U,S$-tense logics.

A model $\mathscr{M}$ is a frame $\mathscr{F} = (T, <)$ equipped with a valuation $V$ on it. For any model $\mathscr{M} = (T, <, V)$ and formula $\alpha$, $\alpha$ is valid for $\mathscr{M}$, denoted by $\mathscr{M} \vDash \alpha$, if $\mathscr{M} \vDash \alpha[t]$ for every $t \in T$. $\mathscr{M}$ is said to be a model for a $U,S$-tense logic $TL_{US}$ if $\mathscr{M} \vDash \alpha$ for every $\alpha \in TL_{US}$. A $TL_{US}$ is complete for the class of all its models if whenever $\alpha \notin TL_{US}$ there is a model $\mathscr{M}$ for $TL_{US}$ such that $\mathscr{M} \nvDash \alpha$.

**2.10. Remark.** Every $U,S$-tense logic is complete for the class of all its models.

This statement can be verified by noting that if we replace $TL_{US}(\phi)$ by an arbitrary $TL_{US}$ throughout the whole work before 2.8 in this section, we can obtain a proof, similar to that for 2.8, for that whenever $\alpha \notin TL_{US}$, there is a model $\mathscr{M}$ such that $\mathscr{M} \nvDash \alpha$ and $\mathscr{M} \vDash \beta$ for all $\beta \in TL_{US}$.

A general frame $\mathscr{G}$ (or a first-order structure) is a frame $\mathscr{F} = (T, <)$ equipped with a subset $E$ of the power set of $T$ which is closed under Boolean operations as well as the following operations (with $X, Y \in E$):

$$f_U(X, Y) = \{t \in T \mid \exists t' \in T(t < t' \land t' \in X \land \forall t'' \in T(t < t'' \land t'' < t' \to t'' \in Y))\},$$

$$f_S(X, Y) = \{t \in T \mid \exists t' \in T(t' < t \land t' \in X \land \forall t'' \in T(t' < t'' \land t'' < t \to t'' \in Y))\}.$$

For any general frame $\mathscr{G} = (T, <, E)$, we say that a model $\mathscr{M} = (T, <, V)$ is a model based on $\mathscr{G}$ if $V$ is a valuation satisfying $V(p) \in E$ for every propositional variable $p$, and that $\alpha$ is valid for $\mathscr{G}$, denoted by $\mathscr{G} \vDash \alpha$, if $\mathscr{M} \vDash \alpha$ for every model $\mathscr{M}$ based on $\mathscr{G}$, and that $\mathscr{G}$ is a general frame for a $U,S$-tense logic $TL_{US}$ if $\mathscr{G} \vDash \alpha$ for every $\alpha \in TL_{US}$. A $TL_{US}$ is complete for the class of all its general frames if whenever $\alpha \notin TL_{US}$ there is a general frame $\mathscr{G}$ for $TL_{US}$ such that $\mathscr{G} \nvDash \alpha$.

**2.11. Remark.** Every $U,S$-tense logic is complete for the class of all its general frames. We prove this sketchily as follows.

Given any $TL_{US}$ and $\alpha$ with $\alpha \notin TL_{US}$. By 2.10, there is a model $\mathscr{M} = (T, <, V)$ for $TL_{US}$ such that $\mathscr{M} \nvDash \alpha$. Let $\|\beta\|^{\mathscr{M}} = \{t \in T \mid \mathscr{M} \vDash \beta[t]\}$ for every formula $\beta$, and $E = \{\|\beta\|^{\mathscr{M}} \mid \beta \text{ is a formula}\}$, and $\mathscr{G}^* = (T, <, E)$. It is easy to verify that $E$ is a subset of the power set of $T$ closed under Boolean operations and $f_U$ and $f_S$, and hence $\mathscr{G}^*$ is a general frame. Consider any formula $\gamma(p_1, \ldots, p_k)$ (all propositional variables occurring in $\gamma$ are among $p_1, \ldots, p_k$) with $\mathscr{G}^* \nvDash \gamma$ for some model $\mathscr{M}^* = (T, <, V^*)$ based on $\mathscr{G}^*$. Clearly, $V^*(p_1) = \|\beta_1\|^{\mathscr{M}}, \ldots, V^*(p_k) = \|\beta_k\|^{\mathscr{M}}$ for some formulas $\beta_1, \ldots, \beta_k$. It is easy to show by induction that for every $t \in T$, $\mathscr{M}^* \vDash \gamma(p_1, \ldots, p_k)[t]$ iff $\mathscr{M} \vDash \gamma(\beta_1/p_1, \ldots, \beta_k/p_k)[t]$ where the slash ($/$) denotes uniform substitution. It follows that $\mathscr{M} \nvDash \gamma(\beta_1/p_1, \ldots, \beta_k/p_k)$. Since $TL_{US}$ is closed under the rule of uniform substitution and all substitution instances of any element of $TL_{US}$ are valid for $\mathscr{M}$, it then follows that $\gamma \notin TL_{US}$. Hence $\mathscr{G}^*$ is a general frame for $TL_{US}$. Clearly, $\mathscr{M}$ itself is a model based on $\mathscr{G}^*$. It follows that $\mathscr{G}^* \nvDash \alpha$. $\square$

---
