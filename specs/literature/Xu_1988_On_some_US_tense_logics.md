# On Some $U,S$-Tense Logics

**Ming Xu**

*Journal of Philosophical Logic* **17** (1988) 181--202.

---

## 1. Introduction

In his thesis [1], John P. Burgess presented a series of $U,S$-tense logics for the case of linear time. The aims of this paper are (i) to show how the methods of proving completeness for $U,S$-tense logics developed in [1] could be applied to the general case of (possibly) non-linear time; and (ii) to present some results concerning the expressibility of $U,S$-tense language.

To achieve (i), we will first show in Section 2 that the minimal $U,S$-tense logic does exist, and then show in Section 3 how to establish logics for "branching time", such as the logics for the classes of all transitive frames and of all transitive and left-connected frames.

At the end of Section 2, we will show sketchily that every $U,S$-tense logic is complete for the class of all its "models" as well as for the class of all its "general frames".

The reader may be familiar with the fact that the expressibility of $U,S$-tense language is stronger than that of ordinary $G,H$-tense language. But in fact, it is not strong enough to yield any $U,S$-tense formula corresponding to first-order conditions such as irreflexiveness, asymmetry and antisymmetry -- all three of which are of interest to logicians working on tense logic. The stronger expressibility of $U,S$-tense language does give us some formulas corresponding to certain first-order conditions to each of which no $G,H$-tense formula can correspond, as will be shown in Sections 3 and 4. But it also makes it easy to find incomplete tense logics, as will be shown in Section 4.

We begin with the following preliminaries.

$U,S$-tense formulas (briefly, formulas) are constructed from propositional variables $p, q, r, s, \ldots$, using connectives $\neg$ (negation) and $\to$ (material implication), and binary tense operators $U$ (until) and $S$ (since). As usual, $\top$ (constant true), $\bot$ (constant false), $\lor$, $\land$, $\leftrightarrow$ and $F$, $P$, $G$, $H$ can be introduced as abbreviations. We will use $\alpha, \beta, \gamma, \ldots$ to range over formulas.

A frame $\mathscr{F}$ is an ordered couple $(T, <)$ consisting of a nonempty set $T$ with a binary relation $<$ on $T$. A valuation on a frame $\mathscr{F}$ is any function $V$ assigning each propositional variable a subset of $T$. For a valuation $V$ on a frame $\mathscr{F}$, a formula $\alpha$ and an element $t$ of $T$, $(\mathscr{F}, V) \vDash \alpha[t]$ is defined recursively as follows:

- (i) $(\mathscr{F}, V) \vDash p[t]$ iff $t \in V(p)$, for every propositional variable $p$

- (ii) $(\mathscr{F}, V) \vDash \neg\beta[t]$ iff $(\mathscr{F}, V) \nvDash \beta[t]$ (i.e., not $(\mathscr{F}, V) \vDash \beta[t]$)

- (iii) $(\mathscr{F}, V) \vDash \beta \to \gamma[t]$ iff if $(\mathscr{F}, V) \vDash \beta[t]$, then $(\mathscr{F}, V) \vDash \gamma[t]$

- (iv) $(\mathscr{F}, V) \vDash U(\beta, \gamma)[t]$ iff for some $t' \in T$ with $t < t'$, $(\mathscr{F}, V) \vDash \beta[t']$ and for every $t'' \in T$ with $t < t''$ and $t'' < t'$, $(\mathscr{F}, V) \vDash \gamma[t'']$

- (v) $(\mathscr{F}, V) \vDash S(\beta, \gamma)[t]$ iff for some $t' \in T$ with $t' < t$, $(\mathscr{F}, V) \vDash \beta[t']$ and for every $t'' \in T$ with $t' < t''$ and $t'' < t$, $(\mathscr{F}, V) \vDash \gamma[t'']$.

$\alpha$ is valid for $\mathscr{F}$, denoted by $\mathscr{F} \vDash \alpha$, if $(\mathscr{F}, V) \vDash \alpha[t]$ for every $t \in T$ and every valuation $V$ on $\mathscr{F}$. Let $\Sigma$ be a set of formulas. We write $\mathscr{F} \vDash \Sigma$ to indicate that $\mathscr{F} \vDash \alpha$ for every $\alpha \in \Sigma$. $\alpha$ is a semantic consequence of $\Sigma$, denoted by $\Sigma \vDash \alpha$, if for every frame $\mathscr{F}$, $\mathscr{F} \vDash \Sigma$ only if $\mathscr{F} \vDash \alpha$.

Let $\alpha$ be a formula and $\alpha^*$ a sentence of a first-order language with $=$ and a binary predicate constant $<$. We say that $\alpha$ defines $\alpha^*$ if the following holds:

$$\text{For every frame } \mathscr{F}, \ \mathscr{F} \vDash \alpha \text{ iff } \mathscr{F} \vDash \alpha^*,$$

where, at the right hand, $\mathscr{F}$ serves as a structure for the first-order language described above, and $\vDash$ as the usual satisfaction relation of model theory.

---

## Axioms and Logics

A $U,S$-tense logic is a set $TL_{US}$ of formulas which (i) contains all classical tautologies together with the following

$$\text{(1)} \quad G(p \to q) \to (U(r, p) \to U(q, r)) \land (U(r, p) \to U(r, q))$$

$$\text{(2)} \quad H(p \to q) \to (S(p, r) \to S(q, r)) \land (S(r, p) \to S(r, q))$$

$$\text{(3)} \quad p \land U(q, r) \to U(q \land S(p, r), r)$$

$$\text{(4)} \quad p \land S(q, r) \to S(q \land U(p, r), r),$$

and (ii) is closed under the rules of Uniform Substitution, Modus Ponens and Temporal Generalization (i.e., from $\alpha$ to infer $G\alpha$ and $H\alpha$). We use $TL_{US}(\Sigma)$ to denote the smallest $U,S$-tense logic containing the set $\Sigma$ of formulas. Note that every $U,S$-tense logic is closed under the (derived) rule of Substitution of Equivalents (cf. [1]).

For any set $\Sigma$ of formulas, $TL_{US}(\Sigma)$ is complete if

$$\text{for every } \alpha, \ \Sigma \vDash \alpha \text{ iff } \alpha \in TL_{US}(\Sigma).$$

For any class $\mathscr{C}$ of frames, we write $\mathrm{Th}(\mathscr{C})$ to denote the set $\{\alpha \mid \text{for every } \mathscr{F} \in \mathscr{C}, \ \mathscr{F} \vDash \alpha\}$. Another version of the completeness of $TL_{US}(\Sigma)$ is that

$$\text{for some class } \mathscr{C} \text{ of frames}, \ TL_{US}(\Sigma) = \mathrm{Th}(\mathscr{C}).$$

Clearly, these two versions are equivalent.

---

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

## References

[1] J. P. Burgess, 'Axioms for Tense Logic I. "Since" and "Until"', *Notre Dame Journal of Formal Logic* **23** (1982), pp. 367--374.

[2] J. P. Burgess, 'Basic Tense Logic', in D. M. Gabbay and F. Guenthner (eds.), *Handbook of Philosophical Logic*, vol. II, Reidel, Dordrecht, 1984, pp. 89--133.

[3] S. K. Thomason, 'Semantic Analysis of Tense Logics', *The Journal of Symbolic Logic* **37** (1972), pp. 150--158.

[4] S. K. Thomason, 'An Incompleteness Theorem in Modal Logic', *Theoria* **40** (1974), pp. 30--34.

[5] J. F. A. K. van Benthem, 'Two Simple Incomplete Modal Logics', *Theoria* **44** (1978), pp. 25--37.

[6] J. F. A. K. van Benthem, 'Syntactic Aspects of Modal Incompleteness Theorems', *Theoria* **45** (1979), pp. 63--77.

[7] J. F. A. K. van Benthem, 'Tense Logic, Second-Order Logic and Natural Language', in U. Monnich (ed.), *Aspects of Philosophical Logic*, Reidel, Dordrecht, 1981, pp. 1--20.

[8] J. F. A. K. van Benthem, 'Correspondence Theory', in D. M. Gabbay and F. Guenthner (eds.), *Handbook of Philosophical Logic*, vol. II, Reidel, Dordrecht, 1984, pp. 167--247.

---

*Logic Section,*
*Institute of Philosophy,*
*Chinese Academy of Social Sciences,*
*Beijing, P.R.C.*
