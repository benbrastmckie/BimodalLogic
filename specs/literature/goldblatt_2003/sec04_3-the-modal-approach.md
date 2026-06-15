## 3. The modal approach

We now briefly give a similar argument in purely modal terms. We assume some familiarity with modal logic: modal languages and their semantics, basic frame theory (including bounded morphisms and inner subframes), normal modal logics and notions pertaining to them such as soundness, completeness, canonicity, and the finite model property, and the Jankov--Fine formula encoding the modal diagram of a frame. All the material we need can be found in [2] and [5].

We use a modal language with two boxes, written $\Box$, $\mathsf{A}$. We will write $R_\Box$, $R_\mathsf{A}$ for their accessibility relations, and $\Diamond$, $\mathsf{E}$ for the corresponding diamonds. The operator $\mathsf{A}$ is intended as a global or universal modality (see [2]); frames $F = (W, R_\Box, R_\mathsf{A})$ on which, indeed, $R_\mathsf{A} = W \times W$ will be called *standard*. For $F = (W, R_\Box, R_\mathsf{A})$, we will write $|F|$ for $|W|$.

A *colouring* of a frame $F = (W, R_\Box, R_\mathsf{A})$ is a collection $C$ of subsets of $W$ such that $\bigcup C = W$ and $F \models \neg R_\Box(x, y)$ for all $x, y \in S$ and all $S \in C$. The *chromatic number* $\chi(F)$ of $F$ is the least $m < \omega$ for which there exists a colouring of $F$ of cardinality $m$; we set $\chi(F) = \infty$ if $F$ has no finite colouring. Note that although colourings need not partition the domain of the frame, any finite colouring can be refined to one that does. So if we consider a graph $G = (V, E)$ as a frame $F = (V, E, V \times V)$, the chromatic number of $F$ coincides with the chromatic number of $G$ as usually defined in graph theory (as in Section 1).

$|F|$ and $\chi(F)$ are two 'largeness notions' for frames $F$. They are to an extent modally definable:

> **Lemma 3.1.** *Let $F = (W, R_\Box, R_\mathsf{A})$ be a standard frame, let $n, m < \omega$, and let $p_0, \ldots, p_{n-1}$, $q_0, \ldots, q_{m-1}$ be distinct propositional variables.*
> 1. *The formula $\bigwedge_{i < n} \mathsf{E}(p_i \wedge \bigwedge_{j < i} \neg p_j)$ is satisfiable in $F$ iff $|F| \geq n$.*
> 2. *The formula $\mathsf{A} \bigvee_{i < m} (q_i \wedge \Box \neg q_i)$ is satisfiable in $F$ iff $\chi(F) \leq m$.*

*Proof.* For the first part, assume that $\bigwedge_{i < n} \mathsf{E}(p_i \wedge \bigwedge_{j < i} \neg p_j)$ is satisfiable in $F$ under some assignment $h$ of the variables. For each $i < n$, pick $w_i \in W$ with $(F, h), w_i \models p_i \wedge \bigwedge_{j < i} \neg p_j$. The $w_i$ must clearly be pairwise distinct; so $|F| \geq n$. Conversely, if $|F| \geq n$ then assigning $p_0, \ldots, p_{n-1}$ to distinct singletons in $\wp(W)$ will satisfy the formula.

Assume now, in order to prove part 2 of the lemma, that $\mathsf{A} \bigvee_{i < m} (q_i \wedge \Box \neg q_i)$ is satisfiable in $F$ under some assignment $h$. For each $i < m$, let $S_i = \{w \in W : (F, h), w \models q_i \wedge \Box \neg q_i\}$. Then the $S_i$ witness that $\chi(F) \leq m$. Conversely, assume that there are sets $S_i \subseteq W$ ($i < m$) with union $W$ and such that $F \models \neg R_\Box(x, y)$ for all $x, y \in S_i$ and $i < m$. Assign $q_i$ to $S_i$ (each $i < m$) and observe that the formula is now true at any world of $F$. $\square$

> **Definition 3.2.** For $n, m < \omega$ and distinct propositional variables $p_0, \ldots, p_{n-1}$, $q_0, \ldots, q_{m-1}$, let
> $$\alpha[n, m] = \left(\bigwedge_{i < n} \mathsf{E}(p_i \wedge \bigwedge_{j < i} \neg p_j)\right) \to \mathsf{E} \bigwedge_{i < m} (\Box q_i \to q_i).$$

> **Lemma 3.3.** *Let $F$ be a standard frame. Then $\alpha[n, m]$ is valid in $F$ iff (if $|F| \geq n$ then $\chi(F) > m$).*

*Proof.* The formula $\alpha[n, m]$ is not valid in $F$ iff $\bigwedge_{i < n} \mathsf{E}(p_i \wedge \bigwedge_{j < i} \neg p_j)$ and $\mathsf{A} \bigvee_{i < m} (\Box q_i \wedge \neg q_i)$ are both satisfiable in $F$ (since the truth of these formulas does not depend on the evaluation point). By lemma 3.1, this is iff $|F| \geq n$ and $\chi(F) \leq m$. $\square$

For each $n < \omega$ let $G_n$ be a finite graph with chromatic number $> n$ and no cycles of length $< n$ (see Erdos's paper [9] for their existence). We write $|G_n|$ for the number of nodes of $G_n$. We may suppose that $|G_0| < |G_1| < \cdots$.

> **Definition 3.4.** Let $\mathsf{EG}$ (standing for 'Erdos graphs') be the normal modal logic (in the modal language above) axiomatised by:
> 1. all propositional tautologies,
> 2. normality: $\Box(p \to q) \to (\Box p \to \Box q)$, and $\mathsf{A}(p \to q) \to (\mathsf{A}p \to \mathsf{A}q)$,
> 3. $\{\alpha[|G_n|, n] : n < \omega\}$,
> 4. the axioms $\mathsf{A}p \to \Box p$, $\mathsf{A}p \to p$, and $\mathsf{E}p \to \mathsf{A}\mathsf{E}p$, expressing that $\mathsf{A}$ is a global or universal modality.
>
> Its derivation rules are modus ponens, universal generalisation for each of the two boxes, and uniform substitution (of variables by formulas).

The symmetry axiom $p \to \Box\Diamond p$ can be added if desired, but it is not needed.

> **Lemma 3.5.** *The logic $\mathsf{EG}$ is canonical.*

*Proof.* Fix a set $\mathcal{L}$ of propositional variables. Using formulas written with variables from $\mathcal{L}$, let $M = (K, h)$ be the canonical model of $\mathsf{EG}$, with underlying frame $K$. We show that $K$ is a frame for $\mathsf{EG}$.

Let $C$ be any $R_\mathsf{A}$-cluster of $K$, regarded as a subframe of $K$. $C$ is an inner subframe, so it suffices to check that $C$ is a frame for $\mathsf{EG}$; and since $C$ is a standard frame we need not worry about the axioms dealing with the global modality. Thus it remains to verify that $C$ validates the formulas $\alpha[|G_n|, n]$ for $n < \omega$. If $C$ is finite, this is clear, as any valuation into $C$ is definable in $M$, and the model $M$ validates $\mathsf{EG}$. So assume that $C$ is infinite.

**Claim.** There is $\Gamma \in C$ with $K \models R_\Box(\Gamma, \Gamma)$.

*Proof of claim.* There is a similar argument in Hughes's paper [33]. Pick any $\Delta \in C$. It suffices to show that the set

$$\Gamma_0 = \{\Box\varphi \to \varphi : \varphi \text{ an } \mathcal{L}\text{-formula}\} \cup \{\delta : \mathsf{A}\delta \in \Delta\}$$

is $\mathsf{EG}$-consistent; for any maximal consistent set $\Gamma$ containing it will be $R_\Box$-reflexive and in $C$.

Assume for contradiction that $\Gamma_0$ is inconsistent. So by normality, there are $\mathsf{A}\delta \in \Delta$ and $\mathcal{L}$-formulas $\varphi_0, \ldots, \varphi_{m-1}$ for some $m < \omega$, such that $\mathsf{EG} \vdash \delta \to \neg\bigwedge_{i < m}(\Box\varphi_i \to \varphi_i)$. Applying universal generalisation and normality yields $\mathsf{EG} \vdash \mathsf{A}\delta \to \mathsf{A}\neg\bigwedge_{i < m}(\Box\varphi_i \to \varphi_i)$. Hence,

$$\mathsf{A}\neg\bigwedge_{i < m}(\Box\varphi_i \to \varphi_i) \in \Delta. \tag{1}$$

Now let $n = |G_m|$ and define formulas $\psi_i$ ($i < n$) as follows. Since $C$ is infinite it is not hard to find distinct $\Gamma_0, \ldots, \Gamma_{n-1} \in C$ and formulas $\gamma_{ij} \in \Gamma_i \setminus \Gamma_j$ separating $\Gamma_i$ from $\Gamma_j$. Let $\psi_i = \bigwedge_{j \neq i} \gamma_{ij}$. Then for all $i, j < n$, we have $\psi_i \in \Gamma_j$ iff $i = j$; in fact, we obtain $M, \Gamma_i \models \psi_i \wedge \bigwedge_{j < i} \neg\psi_j$ for each $i < n$.

Since $\Delta \in C$, we have $\bigwedge_{i < n} \mathsf{E}(\psi_i \wedge \bigwedge_{j < i} \neg\psi_j) \in \Delta$ by the truth lemma for $M$. But $\alpha[n, m]$ is an axiom of $\mathsf{EG}$; so we obtain $\mathsf{E}\bigwedge_{i < m}(\Box\varphi_i \to \varphi_i) \in \Delta$. Taken with (1), this contradicts the consistency of $\Delta$, and proves the claim.

Any frame with an $R_\Box$-reflexive point has chromatic number $\infty$, so by lemma 3.3 validates $\alpha[n, m]$ for all $n, m$. This, with the claim, implies that $C$ is a frame for $\mathsf{EG}$. Hence, $K$ is also a frame for $\mathsf{EG}$, as required. $\square$

> **Lemma 3.6.** *$\mathsf{EG}$ is not sound and complete for any elementary class of frames.*

*Proof.* Assume for contradiction that $\mathsf{EG}$ is sound and complete for some elementary class $\mathcal{K}$ of frames. Let $n < \omega$. We regard $G_n$ as a standard frame for the modal type above by interpreting $R_\Box$ as the graph edge relation (and $R_\mathsf{A}$ as the universal relation $G_n \times G_n$). It can be checked using lemma 3.3 that $G_n$ validates $\mathsf{EG}$. Let $\psi_n$ be (essentially) the Jankov--Fine formula of $G_n$ (see, e.g., [2, Section 3.4] and [5, Section 9.4]):

$$\left(\mathsf{A} \bigvee_{x \in G_n} \left(x \wedge \bigwedge_{y \in G_n \setminus \{x\}} \neg y\right)\right) \wedge \left(\bigwedge_{x \in G_n} \mathsf{E}x\right) \wedge \mathsf{A} \bigwedge_{x \in G_n} \left(\Diamond x \leftrightarrow \bigvee_{R_\Box(y, x)} y\right),$$

where we regard each $x \in G_n$ as a propositional variable. Then $\psi_n$ is satisfiable in $G_n$. So $\psi_n$ is $\mathsf{EG}$-consistent, and hence there is $F_n \in \mathcal{K}$ in which $\psi_n$ is satisfiable. Since $F_n$ validates $\mathsf{EG}$, $R_\mathsf{A}$ defines an equivalence relation on it, each equivalence class being an inner subframe of $F_n$. The form of $\psi_n$ now implies that there is an inner subframe $I_n \subseteq F_n$ and a surjective bounded morphism $m_n : I_n \to G_n$ (see, e.g., [2, lemma 3.20] for details).

Now consider the class $\mathcal{T}$ of structures of the form $(A, B, m)$, where $A \in \mathcal{K}$, $B$ is a standard frame disjoint from $A$, and $m \subseteq A \times B$ is a surjective bounded morphism from an inner subframe of $A$ onto $B$. Since $\mathcal{K}$ is elementary, these statements are first-order expressible, and we can find a first-order theory $T$, say, containing first-order sentences that together axiomatise $\mathcal{T}$, and additional sentences stating that '$B$' (above) has at least $n$ elements for each finite $n$, $R_\Box$ is irreflexive and symmetric on $B$, and $B$ has no $R_\Box$-cycles of length $n$ for each finite $n$. Any finite subset of $T$ has a model, namely, $(F_n, G_n, m_n)$ for any large enough $n$. By compactness for first-order logic, we may take $(F, G, m) \models T$. Then $F \in \mathcal{K}$, so $F$ is an $\mathsf{EG}$-frame. The domain of $m$ is an inner subframe of $F$, so also an $\mathsf{EG}$-frame. $G$ is a bounded morphic image of this, so is itself an $\mathsf{EG}$-frame.

But $R_\Box$ is irreflexive and symmetric on $G$ and has no cycles. Hence, $\chi(G) \leq 2$. Also, $G$ is infinite and standard. By lemma 3.3, $G$ does not validate any of the axioms $\alpha[|G_n|, n]$ of $\mathsf{EG}$, and so is not an $\mathsf{EG}$-frame. This contradiction completes the proof. $\square$

> **Remark 3.7.** The same argument shows that the variant of $\mathsf{EG}$ in which the axioms $\alpha[|G_n|, n]$ are replaced by any single axiom of the form $\alpha[m, n]$ ($m \geq 1$, $n \geq 2$) is also not sound and complete for any elementary class of frames. The simplest such axiom is $\alpha[1, 2]$, equivalent to $\mathsf{E}((\Box q_0 \to q_0) \wedge (\Box q_1 \to q_1))$, and expressing that its frames have chromatic number at least 3. However, algebraic results [32, theorem 4.2] can be used to show that no such logic is canonical.

> **Lemma 3.8.** *$\mathsf{EG}$ has the finite model property and, for a suitable choice of the $G_n$, is decidable.*

*Proof.* Let $\varphi$ be an $\mathsf{EG}$-consistent formula; we will show that $\varphi$ is satisfiable in a finite frame for $\mathsf{EG}$.

The consistency of $\varphi$ implies that $\varphi$ is satisfiable in some point $\Gamma$ of the canonical frame $K$. Let $C$ be the cluster of $M$ to which $\Gamma$ belongs; in the proof of lemma 3.5 we already saw that $C$ (seen as a subframe of $K$) is a frame for $\mathsf{EG}$. Hence we are done in the case that $C$ is finite.

If $C$ is infinite then it contains an $R_\Box$-reflexive point. Now let $M_C$ be the canonical model restricted to $C$, and take any filtration $M_C^f$ of $M_C$ through the collection of subformulas of $\varphi$ (as in [2, Section 2.3]). It is a routine exercise to verify that $\varphi$ is satisfiable in $M_C^f$, and that $M_C^f$ is based on a standard, finite frame containing a reflexive world. But any such frame validates $\mathsf{EG}$.

The proof of the second part of the lemma is done in the usual way, by choosing the $G_n$ so that the axioms of $\mathsf{EG}$ are recursively enumerable, and observing that it is then decidable whether a finite frame validates the axioms. See corollary 2.16 and [2, theorem 6.7] for similar arguments. $\square$

> **Remark 3.9.** Fine formulated his theorem concerning the canonicity of elementarily determined modal logics in a monomodal language, i.e., with a single diamond. However, as he mentions in the introduction to [10], his results can be readily extended to polymodal logics, such as tense logics.

Similarly, we have formulated our results for bimodal languages, but it is not hard to transform them to the monomodal setting, using Thomason's simulation method. Thomason [48] showed how normal, polymodal logics can be uniformly simulated by normal, monomodal ones, in a way that preserves negative properties such as incompleteness. A systematic study of the Thomason simulation by Kracht and Wolter [40] brought out that in fact it preserves many properties, both positive and negative. Using their results, it almost immediately follows that the monomodal simulation of the logic $\mathsf{EG}$ is a canonical, but not elementarily determined, modal logic in a monomodal language.

In the companion paper [24], we will discuss examples of monomodal logics above K4, obtained by a direct construction not using the Thomason simulation, which are canonical but not sound and complete for any elementary class of Kripke frames.

---

## 4. Further work

It would be interesting to know whether theorem 2.18 and the results of Section 3 remain true under stronger conditions. In this regard, we point out an observation and two problems. We state them in algebraic terms, but of course the modal approach could be used instead.

> **Proposition 4.1.** *The following are equivalent:*
> 1. *Every finitely axiomatisable canonical variety of BAOs is elementarily generated.*
> 2. *Every variety of BAOs with a canonical equational axiomatisation is elementarily generated.*

*Proof.* It is clear that $(2) \Rightarrow (1)$, since if $\mathcal{V}$ is canonical and axiomatised by finitely many equations $t_1 = u_1, \ldots, t_n = u_n$, then it is in fact axiomatisable by a single equation $(t_1 - u_1) + (u_1 - t_1) + \cdots + (u_n - t_n) = 0$, which must therefore be canonical.

Conversely, assume (1). Let $\mathcal{V}$ be a variety of $L$-BAOs (for some signature $L$) axiomatised by a set $\Sigma$ of canonical equations. (Of course, $\mathcal{V}$ is canonical.) For $\varepsilon \in \Sigma$, let $\mathcal{V}_\varepsilon$ be the variety of all $L$-BAOs satisfying $\varepsilon$. If $L_\varepsilon$ is a finite subsignature of $L$ containing the symbols of $\varepsilon$, then the class $\mathcal{V}'_\varepsilon$ of $L_\varepsilon$-reducts of BAOs in $\mathcal{V}_\varepsilon$ is a finitely axiomatisable canonical variety, and hence by assumption is elementarily generated. By proposition 2.17, there is an elementary class $\mathcal{K}'_\varepsilon$ of $L^a_\varepsilon$-structures satisfying $\operatorname{Cst} \mathcal{V}'_\varepsilon \subseteq \mathcal{K}'_\varepsilon \subseteq \operatorname{Str} \mathcal{V}'_\varepsilon$. Let $\mathcal{K}_\varepsilon$ be the class of $L^a$-structures with $L^a_\varepsilon$-reducts in $\mathcal{K}'_\varepsilon$. It is easily checked that $\operatorname{Cst} \mathcal{V}_\varepsilon \subseteq \mathcal{K}_\varepsilon \subseteq \operatorname{Str} \mathcal{V}_\varepsilon$. Let $\mathcal{K} = \bigcap_{\varepsilon \in \Sigma} \mathcal{K}_\varepsilon$. Certainly, $\mathcal{K}$ is elementary. Moreover, we have

$$\operatorname{Cst} \mathcal{V} \subseteq \bigcap_{\varepsilon \in \Sigma} \operatorname{Cst} \mathcal{V}_\varepsilon \subseteq \bigcap_{\varepsilon \in \Sigma} \mathcal{K}_\varepsilon = \mathcal{K} \subseteq \bigcap_{\varepsilon \in \Sigma} \operatorname{Str} \mathcal{V}_\varepsilon = \operatorname{Str} \bigcap_{\varepsilon \in \Sigma} \mathcal{V}_\varepsilon = \operatorname{Str} \mathcal{V}.$$

By proposition 2.17, $\mathcal{V}$ is generated by $\mathcal{K}$. $\square$

> **Problem 4.2.** *Is every finitely axiomatisable canonical variety of BAOs elementarily generated?*

> **Problem 4.3.** *Is there a variety of BAOs that is (a) canonical, (b) axiomatisable by a set of equations of the form $\Sigma \cup \Xi$, where $\Sigma$ is finite and every equation in $\Xi$ is canonical, and (c) not elementarily generated?*

The $\mathcal{V}$ of theorem 2.18 and the $\mathcal{V}_X$ of theorem 2.19 are not finitely axiomatisable. Indeed, by results in [32], any axiomatisation of them must involve infinitely many non-canonical equations.

---
