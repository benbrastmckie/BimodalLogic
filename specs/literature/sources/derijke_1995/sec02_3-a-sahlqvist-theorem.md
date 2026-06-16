## 3. A Sahlqvist Theorem

To describe the modal counterparts of the earlier Sahlqvist equalities we need the following definition.

**Definition 3.1.** Let $S$ be a modal similarity type. *Positive* and *negative* occurrences of a proposition letter $p$ are defined as usual by: (i) $p$ occurs positively in $p$, (ii) a positive (negative) occurrence of $p$ in $\phi$ is a negative (positive) occurrence of $p$ in $\neg\phi$ and in $\phi \to \psi$, and a positive (negative) one in $\phi \vee \psi$, $\phi \wedge \psi$, $\nabla_i(\phi_1, \ldots, \phi, \ldots, \phi_{\rho(i)})$, $\lhd_i(\phi_1, \ldots, \phi, \ldots, \phi_{\rho(i)})$ ($\nabla_i \in S$). A formula $\phi$ in $M(S)$ is *positive* (*negative*) if every proposition letter occurs only positively (negatively) in $\phi$. $\phi$ is *monotone* in the proposition letter $p$ if for every model $(\mathfrak{F}, V)$ and every valuation $V'$ on $\mathfrak{F}$ with $V(p) \subseteq V'(p)$ and otherwise the same as $V$, $(\mathfrak{F}, V), w \models \varphi$ implies $(\mathfrak{F}, V'), w \models \varphi$.

Note that in a positive formula *negations* of modal or Boolean constants are allowed. Also, if $\phi$ is positive then $\phi$ is monotone in all proposition letters.

**Definition 3.2.** Fix a modal similarity type $S$. A formula $\phi$ in $M(S)$ is a *Sahlqvist antecedent* if it is built up from formulas that are either negative, closed (i.e., without occurrences of proposition letters), or of the form $\Box_{i_1} \ldots \Box_{i_n} p$, using only $\vee, \wedge$ and $\nabla_i$, where $\Diamond_{i_1}, \ldots, \Diamond_{i_n}, \nabla_i \in S$.

Define the set of *Sahlqvist formulas* in $M(S)$ as being the smallest set $X$ such that if $\phi$ is a Sahlqvist antecedent, and $\psi$ is a positive formula, then $\phi \to \psi \in X$; if $\sigma_1, \sigma_2 \in X$ then $\sigma_1 \wedge \sigma_2 \in X$; and if $\sigma_1, \ldots, \sigma_{\rho(i)} \in X$ have no proposition letters in common, then $\lhd_i(\sigma_1, \ldots, \sigma_{\rho(i)}) \in X$.

For a modal similarity type $S$ that contains only unary operators several definitions exist of what it is for a formula in $M(S)$ to be a Sahlqvist formula; however, all are equivalent to (or are covered by) the restriction of 3.2 to such similarity types.

We believe that the generalization to arbitrary similarity types is in fact ours. One may wonder whether this is the obvious generalization from the 'unary case', e.g., why are boxes (i.e., duals of unary normal, additive operations) allowed in Sahlqvist antecedents, while for $n \geq 2$ duals of $n$-ary operations in $S$ are not? The reason why we are interested in Sahlqvist formulas is that they may be shown to be complete and to define certain first order properties of the underlying relations in (generalized) frames. A look at the kind of formulas forbidden in Sahlqvist antecedents in the unary case in order to guarantee these properties, shows that they typically include combinations of the form $\Box(\ldots \vee \ldots)$, or, in first order terms, $\forall(\ldots \vee \ldots)$. But these are precisely the combinations that pop up when we have $n$-ary boxes ($n \geq 2$) around! (In fact, if $\nabla$ is a binary modal operator, and $\lhd$ is its dual, then $(p \lhd p) \lhd p \to (p \nabla p) \nabla p$ may already be shown to be non-elementary.)

Before proving an important property of Sahlqvist formulas we recall that for a binary relation $R$, $\breve{R} = \{ (y, x) : Rxy \}$. To each modal formula $\phi$ we associate a set operator $F^\phi$ as follows. Let $P_1, \ldots, P_k$ be sets and let $\vec{P}$ abbreviate $P_1, \ldots, P_k$. $F^{p_j} = P_j$ ($1 \leq j \leq k$), while $F^{\neg\phi}(\vec{P}) = (F^\phi(\vec{P}))^c$, and $F^{\phi \wedge \psi}(\vec{P}) = F^\phi(\vec{P}) \cap F^\psi(\vec{P})$. $F^{\nabla_i(\phi_1, \ldots, \phi_{\rho(i)})}(\vec{P}) = f_{R_i}(F^{\phi_1}(\vec{P}), \ldots, F^{\phi_{\rho(i)}}(\vec{P}))$, while $F^{\lhd_i(\phi_1, \ldots, \phi_{\rho(i)})}(\vec{P}) = g_{R_i}(F^{\phi_1}(\vec{P}), \ldots, F^{\phi_{\rho(i)}}(\vec{P}))$. We assume that the set operator corresponding to Boolean or modal constants is provided by the context in which these constants occur.

**Theorem 3.3.** *Let $S$ be a modal similarity type. Let $\chi$ be a Sahlqvist formula in $M(S)$. Then $\chi$ corresponds to an $L_0(S)$-sentence $\alpha_\chi$ effectively obtainable from $\chi$.*

*Proof.* This is more or less similar to the proof of [13, Theorem 8] (cf. also [2, Theorem 9.10]). Assume that $\chi$ has the form $\phi \to \psi$.

Let $p_1, \ldots, p_k$ be the proposition letters occurring in $\chi$. Having $\mathfrak{F} = (W, \{ R_i : i \in I \}) \models \chi$ means having $\mathfrak{F} \models \forall\vec{P}\,\forall x\, (x \in F^\chi(\vec{P}))$. By assumption the latter formula has the form

$$(2) \qquad \forall\vec{P}\,\forall x\left( x \in F^\phi(\vec{P}) \to x \in F^\psi(\vec{P}) \right),$$

where $\phi$ is a Sahlqvist antecedent, and $\psi$ is a positive formula. Next, using such equivalences as

$$(3) \qquad \forall \cdots \left( (\Phi \wedge x \in F^{\phi_1 \vee \phi_2}(\vec{P})) \to \Psi \right) \leftrightarrow \bigwedge_{j=1,2} \forall \cdots \left( (\Phi \wedge x \in F^{\phi_j}(\vec{P})) \to \Psi \right),$$

$$(4) \qquad \forall \cdots \left( (\Phi \wedge x \in F^{\nabla_i(\phi_1, \ldots, \phi_{\rho(i)})}(\vec{P})) \to \Psi \right) \leftrightarrow$$
$$\forall \cdots \forall y_1 \ldots y_{\rho(i)} \left( (\Phi \wedge R_i x y_1 \ldots y_{\rho(i)} \wedge \bigwedge_j (y_j \in F^{\phi_j}(\vec{P}))) \to \Psi \right),$$

and

$$(5) \qquad \forall \cdots \left( (\Phi \wedge x \in F^\nu(\vec{P})) \to \Psi \right) \leftrightarrow \forall \cdots \left( \Phi \to (\Psi \vee x \in F^{\neg\nu}(\vec{P})) \right),$$

(2) can be rewritten as a conjunction of formulas of the form

$$(6) \qquad \forall\vec{P}\,\forall x\,\forall\vec{y}\,\vec{z}\left( \Phi \wedge \bigwedge_{j=1}^{k} \bigwedge_{l=1}^{m_j} (y_{lj} \in g_{R_{n_{lj}}} \ldots g_{R_{1_{lj}}}(P_j)) \to \bigvee_{j=1}^{h} (z_j \in F^{\psi_j}(\vec{P})) \right),$$

where $\Phi$ is a quantifier free $L_0$-formula ordering its variables in a certain way, and where all the $\psi_j$s are monotone. If a predicate variable $P$ occurs only in the consequent $\bigvee_{j=1}^{h}(z_j \in F^{\psi_j}(\vec{P}))$ in (6), then, by the monotonicity of the $\psi_j$s, it can be replaced by $\bot$, and the quantifier binding $P$ may be deleted. Thus we may assume that every predicate letter occurs in the consequent of (6) only if it occurs in the antecedent of (6).

By an easy argument we have that $\bigwedge_{l=1}^{m_j}(y_{lj} \in g_{R_{n_{lj}}} \ldots g_{R_{1_{lj}}}(P_j))$ if and only if we have $\bigcup_{l=1}^{m_j} f_{\breve{R}_{1_{lj}}} \ldots f_{\breve{R}_{n_{lj}}}(\{ y_{lj} \}) \subseteq P_j$. Thus by universal instantiation (6) implies the first order formula

$$(7) \qquad \forall x\,\forall\vec{y}\,\vec{z}\left( \Phi \to \bigvee_{j=1}^{h} z_j \in F^{\psi_j}\!\left( \bigcup_{l=1}^{m_1} f_{\breve{R}_{1_{l1}}} \ldots f_{\breve{R}_{n_{l1}}}(\{ y_{l1} \}), \ldots, \bigcup_{l=1}^{m_k} f_{\breve{R}_{1_{lk}}} \ldots f_{\breve{R}_{n_{lk}}}(\{ y_{lk} \}) \right) \right).$$

But, conversely, by the monotonicity of the functions $F^{\psi_j}$ (7) implies (6), and we are done.

To prove the general case one may argue inductively. If the Sahlqvist formulas $\chi_1, \chi_2$ have been shown to correspond to $\alpha_1, \alpha_2$, respectively, then $\chi_1 \wedge \chi_2$ corresponds to $\alpha_1 \wedge \alpha_2$; and if $\chi_1, \ldots, \chi_{\rho(i)}$ are Sahlqvist formulas that have no proposition letters in common, and that have been shown to correspond to $\forall x\, \alpha_1, \ldots, \forall x\, \alpha_{\rho(i)}$, then $\lhd_i(\chi_1, \ldots, \chi_{\rho(i)})$ corresponds to $\forall x\,\vec{y}\, (R_i x y_1 \ldots y_{\rho(i)} \to \alpha_1(y_1) \vee \ldots \vee \alpha_{\rho(i)}(y_{\rho(i)}))$. $\dashv$

Two remarks are in order. First, in the above result we may in fact replace 'corresponds' by 'locally corresponds'. But given the algebraic application we have in mind the *global* version is more natural. Second, although the algorithm in the above general proof may seem somewhat intractable or even obscure, in particular examples it is quite manageable, as is witnessed in Section 4.

**Theorem 3.4.** *Let $S$ be a modal similarity type. For $j \in J$, let $\chi_j$ be Sahlqvist formulas in $M(S)$. Let $\Lambda$ be the modal logic axiomatized by $\{ \chi_j : j \in J \}$. Then $\Lambda$ is canonical. Hence $\Lambda$ is complete with respect to the class of Kripke frames defined by $\{ \alpha_{\chi_j} : j \in J \}$.*

*Proof.* There are various ways to prove this result. The case where $S$ contains only unary modal operators is [13, Theorem 19]. To prove the general case one may use the same arguments together with the canonical frame construction for modal logics of arbitrary similarity type as found in [16, Appendix A]. An alternative proof of the unary case may be found in [14]. Finally, Goldblatt [5] proves that any variety of BAOs is canonical whenever it is generated by a frame class which is closed under ultraproducts; therefore, Theorem 3.4 is an immediate consequence of Theorem 3.3. $\dashv$

We leave it to the reader to check that every Sahlqvist formula induces a Sahlqvist identity, and conversely.

**Theorem 3.5.** *Let $\Sigma$ be a set of Sahlqvist equalities. Let $\mathsf{V}_\Sigma$ be the variety defined by $\Sigma$. Then $\mathsf{V}_\Sigma$ is canonical.*

*Proof.* Let $\widehat{\Sigma}$ be the set of modal translations of the elements of $\Sigma$. So $\widehat{\Sigma}$ is a set of Sahlqvist formulas. Now, to prove the theorem, let $\mathfrak{B} \in \mathsf{V}_\Sigma$. Let $\mathfrak{A}_\Sigma(|B|)$ be the free $\Sigma$-algebra on $|B|$ generators. Then $\mathfrak{A}_\Sigma(|B|) \twoheadrightarrow \mathfrak{B}$, and hence $\mathfrak{Em}\,\mathfrak{A}_\Sigma(|B|) \twoheadrightarrow \mathfrak{Em}\,\mathfrak{B}$, by [3, Corollary 3.2.5(6)]. So we are done once we have shown that $\mathfrak{Em}\,\mathfrak{A}_\Sigma(|B|) \in \mathsf{V}_\Sigma$.

**Figure 1.**

$$\begin{array}{ccc}
\mathfrak{B} & \twoheadleftarrow & \mathfrak{A}_\Sigma(|B|) & \qquad \mathfrak{A}_\Sigma(|B|)_+ \\
\downarrow & & \downarrow & \qquad \vdots \downarrow \\
\mathfrak{Em}\,\mathfrak{B} & \twoheadleftarrow & \mathfrak{Em}\,\mathfrak{A}_\Sigma(|B|) & \qquad (\mathfrak{A}_\Sigma(|B|)_+)_\#
\end{array}$$

Since $\mathfrak{A}_\Sigma(|B|) \models \Sigma$, $\mathfrak{A}_\Sigma(|B|)_+ \models \widehat{\Sigma}$. So by 3.4 $\mathfrak{Cs}\,\mathfrak{A}_\Sigma(|B|) = (\mathfrak{A}_\Sigma(|B|)_+)_\# \models \widehat{\Sigma}$. But then $\mathfrak{Em}\,\mathfrak{A}_\Sigma(|B|) = ((\mathfrak{A}_\Sigma(|B|)_+)_\#)^+ \models \Sigma$, i.e. $\mathfrak{Em}\,\mathfrak{A}_\Sigma(|B|) \in \mathsf{V}_\Sigma$. $\dashv$

**Remark 3.6.** For a description of the current state of the art concerning canonicity and the relation with notions like first-order definability, we refer the reader to [4].

**Remark 3.7.** Although Theorem 3.5 describes a large part of the class of identities that are preserved under canonical embedding algebras, the Sahlqvist identities do not describe this class exhaustively. The conjunction of the McKinsey axiom ($\Box\Diamond p \to \Diamond\Box p$) and the transitivity axiom ($\Diamond\Diamond p \to \Diamond p$) from modal logic is a case in point: this formula is not a Sahlqvist formula, but it is preserved under canonical embedding algebras.

As an application of Theorems 3.3 and 3.5, let us substantiate our earlier claim that when dealing with Sahlqvist equations we can move back and forth between modal frames and algebras, in the sense that to prove that two Sahlqvist equations are equivalent over a canonical variety V, it suffices to establish the equivalence (in $\mathbf{At}\,\mathsf{V}$) of their first order translations. This means that reasoning can be done in the Kripke frames, which is usually much easier than manipulating algebraic equations.

**Theorem 3.8.** *Let $\mathsf{V}$ be a canonical variety, and $\eta_1$ and $\eta_2$ two Sahlqvist equations with first order correspondents $\alpha_1$ and $\alpha_2$. Then*

$$\mathbf{At}\,\mathsf{V} \models \alpha_1 \leftrightarrow \alpha_2 \iff \mathsf{V} \models \eta_1 \leftrightarrow \eta_2.$$

*Proof.* From left to right: let $\mathfrak{A}$ be an algebra in $\mathsf{V}$ with $\mathfrak{A} \models \eta_i$. By the fact that $\eta_i$ is a Sahlqvist equation, $\eta_i$ holds in $\mathfrak{Em}\,\mathfrak{A} = (\mathfrak{Cs}\,\mathfrak{A})^+$. This gives $\mathfrak{Cs}\,\mathfrak{A} \models \alpha_i$, so by assumption $\mathfrak{Cs}\,\mathfrak{A} \models \alpha_j$. But then again $\mathfrak{Em}\,\mathfrak{A} \models \eta_j$, so $\eta_j$ holds in $\mathfrak{A} \leq \mathfrak{Em}\,\mathfrak{A}$.

From right to left: let $\mathfrak{F}$ be a frame in $\mathbf{At}\,\mathsf{V}$ with $\mathfrak{F} \models \alpha_i$. Then $\mathfrak{F}^+ \models \eta_i \Rightarrow \mathfrak{F}^+ \models \eta_j \Rightarrow \mathfrak{F} \models \alpha_j$. $\dashv$
