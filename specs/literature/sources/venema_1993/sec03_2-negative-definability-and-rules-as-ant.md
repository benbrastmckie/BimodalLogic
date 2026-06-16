## 2 Negative definability and rules as anti-axioms

In this section we give more formal definitions of the notions introduced in the previous section, and we state the main problem addressed in the paper.

**Definition 2.1** *For a modal formula $\phi$ resp. a set $\Phi$ of modal formulas we define $\mathsf{Fr}_\phi$ (resp. $\mathsf{Fr}_\Phi$) as the class of frames where $\phi$, resp. $\Phi$ is valid. For $\mathsf{Fr}_\top$, the class of all frames, we write $\mathsf{Fr}$. If we want to distinguish this kind of characterization from other sorts, we call it a* positive *characterization.*

*Now let $\xi$ be a modal formula, $\mathsf{K}$ a class of frames. We define $\mathsf{K}_{-\xi}$ as the class of non-$\xi$ frames in $\mathsf{K}$, i.e. those $\mathfrak{F} = (W, I)$ in $\mathsf{K}$ satisfying*

*for every world $w$ there is a valuation $V$ such that $\mathfrak{F}, V, w \models \neg\xi$.*

*For $\Xi$ a set of formulas, we define $\mathsf{K}_{-\Xi}$ as the intersection of all $\mathsf{K}_{-\xi}$, $\xi \in \Xi$. Classes of the form $\mathsf{Fr}_{-\Xi}$ we call* negatively *definable.*

Informally, a frame $\mathfrak{F}$ is a non-$\xi$ frame iff "everywhere in $\mathfrak{F}$, we can get $\xi$ false", by choosing a suitable valuation. Note that this is not the same as saying that we can get $\xi$ "false everywhere": the valuation needed may depend on the particular world where we want to make $\xi$ false.

In fact, we can distinguish *three* classes of frames, all defined using the negation of $\xi$:

1. $\mathsf{Fr}_{\neg\xi}$ (i.e. the class of frames where $\neg\xi$ is valid)
2. $\overline{\mathsf{Fr}_\xi}$ (i.e. the complement of $\mathsf{Fr}_\xi$)
3. $\mathsf{Fr}_{-\xi}$.

These classes need not be identical, for $\mathfrak{F}$ is in $\mathsf{Fr}_{\neg\xi}$ iff *for all* valuations $V$ and *all* worlds $w$, $\mathfrak{F}, V, w \models \neg\xi$; $\mathfrak{F}$ is in the second class iff *there are* a valuation $V$ and a world $w$ with $\mathfrak{F}, V, w \models \neg\xi$, and $\mathfrak{F} \in \mathsf{Fr}_{-\xi}$ means that *for every* world $w$ *there is* a valuation $V$ with $\mathfrak{F}, V, w \models \neg\xi$.

This means, so to speak, that $-\xi$ 'corresponds' to the second order formula

$$\forall x_1 \exists P_0 \ldots P_n \neg\xi^1(x_0),$$

where $\xi^1(x_0)$ is the local model correspondent[^3] of $\xi$, every monadic predicate $P_i$ being the first order counterpart of the propositional variable $p_i$ in $\xi$. Thus we are studying classes of frames that are definable in a version of second order logic where we have a restricted possibility to use existential quantification over monadic predicates.

[^3]: cf. subsection 1.2, or van Benthem [2, 3].

As an example from tense logic, consider the formula $\xi = Gp \to Pp$ (for a definition of our conventions in tense logic, we refer to subsection 1.2), which is locally equivalent on the frame level to $\exists y(Rxy \wedge R^{-1}xy)$. So $\mathsf{Fr}_{-\xi}^t$ is the class of frames $\mathfrak{F}$ with $\mathfrak{F} \models \forall x \forall y(Rxy \to \neg R^{-1}xy)$ i.e. the class of *asymmetric* frames, while the tense frames in $\overline{\mathsf{Fr}_\xi}$ are those frames $\mathfrak{F}$ with $\mathfrak{F} \models \exists x \forall y(Rxy \to \neg R^{-1}xy)$. The negation $Gp \wedge H\neg p$ of $\xi$ can be shown to be globally equivalent to the formula $\neg\exists x \exists y Rxy$, so $\mathsf{Fr}_{-\xi}^t$ finally is the class of frames with empty $R$. As another example, one can show $\mathsf{Fr}_{-(Gp \to FFp)}$ to be the class of *intransitive* frames.

To mention some other examples: let $\mathfrak{F} = (W, R_0, R_1)$ be a frame where we want $R_0$ and $R_1$ to be each others *complement*. One requirement to $R_0$ and $R_1$ is that their intersection is empty. It is easy to verify that this disjointness property is negatively characterized by the formula $\Box_0 p \to \Diamond_1 p$.

Negative definability is abundant in (multi-)modal formalisms with a many-dimensional flavour, cf. the references mentioned in the introduction. The problematic properties needed to be characterized here usually have to do with the fact that the dimensions of the system should not overlap, and are thus often related to the 'disjointness'-property mentioned above.

In all these examples the second order definition of $\mathsf{Fr}_{-\xi}$ can be replaced by a first order one, but this need not always be the case: consider the formula $\delta \equiv (Fp \wedge FG\neg p) \to F(HFp \wedge G\neg p)$, which characterizes the Dedekind-complete frames among the linear orderings. The class $\mathsf{Fr}_{-\delta}$ cannot be elementary, since its intersection with the class of linear frames consists of those $\mathfrak{F} = (W, <)$ having a 'gap' above each point (a gap above $t \in W$ is a partition $X, Y$ of $W$ with $X$ downward closed and $t \in X$, such that $X$ does not have a maximum, nor $Y$ a minimum).

On the other hand, $\mathsf{Fr}_{-\xi}$ may be first order definable while $\mathsf{Fr}_\xi$ is not: consider the Lob formula $L = (\Box(\Box p \to p) \to \Box p)$. It is well-known that $\mathsf{Fr}_L$ consists of the frames $\mathfrak{F} = (W, R)$ with $R$ transitive and its converse well-founded. However (as Johan van Benthem observed), $\mathsf{Fr}_{-L}$ contains precisely the frames where every world has a successor, i.e. $\mathsf{Fr}_{-L} = \mathsf{Fr}_{\Diamond\top}$.

It is still a matter of research, whether we can give a structural characterization of negative definability, analogous to the Goldblatt-Thomason result (cf. [16]) for positive definability.

We now turn to axiomatics; we are interested in the logic $\Theta(\mathsf{Fr}_{-\xi})$ consisting of all formulas valid in $\mathsf{Fr}_{-\xi}$. For a generalization of the irreflexivity rule, we follow Gabbay [8], though we use the name 'non-$\xi$ rule' instead of his '$I\xi$-rule':

**Definition 2.2** *Let $\xi(p_0, \ldots, p_{n-1})$ be a modal formula. The $\neg\xi$-consistency rule, or shorter: the non-$\xi$ rule is the following derivation rule:*

$(N\xi R) \qquad \vdash \neg\xi(p_0, \ldots, p_{n-1}) \to \phi \ \Rightarrow \ \vdash \phi, \quad \text{if } \vec{p} \notin \phi.$

*If $\Lambda$ is a derivation system and $\xi$ a formula ($\Xi$ a set of formulas), then $\Lambda(-\xi)$ ($\Lambda(-\Xi)$) denotes the system $\Lambda$ extended with the non-$\xi$ rule (all non-$\xi$ rules, $\xi \in \Xi$).*

Just like for the irreflexivity rule, the best way to understand the non-$\xi$ rule is by its soundness over the class of non-$\xi$ frames:

**Lemma 2.3** *If $\mathsf{Fr}_{-\xi} \models \neg\xi(p_0, \ldots, p_{n-1}) \to \phi$ and no $p_i$ occurs in $\phi$, then $\mathsf{Fr}_{-\xi} \models \phi$.*

**Proof.**
We will prove the lemma by showing that

> If $\phi$ is $\Theta(\mathsf{Fr}_{-\xi})$-consistent and none of the $p_i$ occurs in $\phi$, then the formula $\phi \wedge \neg\xi(p_0, \ldots, p_{n-1})$ is $\Theta(\mathsf{Fr}_{-\xi})$-consistent.

Let $\phi$ be a $\Theta(\mathsf{Fr}_{-\xi})$-consistent formula, then there is a model $\mathfrak{M} = (\mathfrak{F}, V)$ with $\mathfrak{F}$ is in $\mathsf{Fr}_{-\xi}$, and a world $w$ in $\mathfrak{M}$ where $\mathfrak{M}, w \models \phi$. Let $p_0, \ldots, p_{n-1}$ be *new* propositional variables, in the sense that they are not elements of $Dom(V)$. As $\mathfrak{F}, w \not\models \xi$, there is a valuation $V'$ such that $\mathfrak{F}, V', w \models \neg\xi(p_0, \ldots, p_{n-1})$. Now let $V''$ be defined by

$$V''(q) = V(q) \quad \text{if } q \in Dom(V)$$
$$V''(p_i) = V'(p_i) \quad \text{for } i = 0, \ldots, n-1.$$

then clearly we have $(\mathfrak{F}, V''), w \models \phi \wedge \neg\xi$, which proves the lemma. $\square$

The aim however is of course to try and show *completeness* for non-$\xi$ rules; this is the main subject of this paper. As we have already mentioned in the introduction, in general we do not have an isolated $N\xi R$ added to a minimal (tense) logic, but a situation in which we add possibly more than one $N\xi R$ to a logic having other axioms besides the basics.

So the general situation, described by Gabbay [8, 10] is the following: we have a similarity type $S$, an $S$-logic $\Lambda$ which is (strongly) sound and complete with respect to a class of frames $\mathsf{K}$, and a set of formulas $\Xi$. The question now is the following

> Is $\Lambda(-\Xi)$ strongly complete with respect to $\mathsf{K}_{-\Xi}$ ?

Gabbay proves a 'generalized irreflexivity lemma' stating that a $\Lambda(-\xi)$-consistent set $\Sigma$ of formulas has a model $\mathfrak{M}$ with $\mathfrak{M} \models \Theta(\mathsf{Fr}_{\Lambda, -\Xi})$. Unfortunately, this is not enough to prove completeness, for we have to find a model $\mathfrak{M}$ such that the underlying *frame* is in $\mathsf{Fr}_{-\Xi}$.

In general this seems to be difficult and maybe even impossible to establish. Therefore we concentrate on logics with a special, nice kind of axioms, viz. so-called Sahlqvist tense formulas, which form the topic of the next section.

---
