# Chapter 2. Rules for the Undefinable

**Source:** Yde Venema, *Many-Dimensional Modal Logics*, Ph.D. dissertation, University of Amsterdam, 1991, Chapter 2 (pp. 5--41).

---

## Outline

In this chapter we prove a meta-theorem on completeness, for modal axiom systems having unorthodox derivation rules styled after Gabbay's Irreflexivity Rule.

In the introduction we sketch the problem, defining the notions of a non-$\xi$ rule and the class of frames that it characterizes. Section 2 gives some preliminary facts on the Sahlqvist theorem and its algebraic meaning. In section 3 we define the formulas that our meta-theorem admits as axioms, and an alternative version of canonical structures; we prove a persistence result relating these definitions. For a nice formulation of our result, we need the difference operator: this matter is dealt with in section 4. The sections 5, 7 and 8 are devoted to the proof of the main theorem: section 5 treats the simplest case, where all operators are diamonds and the only non-$\xi$ rule is $D$-irreflexivity. Later we extend the result to similarity types with polyadic operators (section 7) and axiom systems with arbitrary many non-$\xi$ rules (section 8). In section 6 we discuss why tense diamonds behave better than uni-directional ones. In the last section 9, we draw our conclusions and mention some questions for further research.

---

## 2.1 Introduction

Let us for the moment consider the simplest tense similarity type with two operators $F$ and $P$. It is well-known that the logic $K^t4$, being the extension of the basic tense logic $K^t$ with the axiom (4): $FFp \to Fp$, completely axiomatizes the class $\mathrm{Fr}^t_4$ of transitive tense frames, i.e. frames $\mathfrak{z} = (W, R_F)$ where $R_F$ is transitive (and $R_P = (R_F)^{-1}$). Adding the axiom (T): $Gp \to p$ then gives a complete axiomatization of the class $\mathrm{Fr}^t_{4T}$ of *reflexive* transitive tense frames.

Now suppose we want to axiomatize the class $\mathrm{Fr}^t_{i4}$ of *irreflexive* transitive tense frames. There is no modal or tense formula corresponding to irreflexivity in the same manner as (4) and (T) correspond to resp. transitivity and reflexivity. So for $\mathrm{Fr}^t_{i4}$ it is (in principle) less clear how to find an axiomatization than for $\mathrm{Fr}^t_4$ or $\mathrm{Fr}^t_{4T}$. The usual procedure, establishing the completeness of $K^t4$ itself$^1$ for $\mathrm{Fr}^t_{i4}$, consists of starting with some model $\mathfrak{M}$ for a consistent set of formulas $\Sigma$ and then transforming $\mathfrak{M}$ into an *irreflexive* model $\mathfrak{M}'$ for $\Sigma$.

A different road was taken by Gabbay in [31], where he suggested to add (to a similar logic) a special derivation rule, which he baptized the *irreflexivity rule*. This rule can be formulated as follows:

$(IR) \qquad \vdash \neg(Gp \to p) \to \phi \ \Rightarrow\ \vdash \phi, \text{ if } p \notin \phi.$

Gabbay's completeness proof then consists of constructing a transitive irreflexive model right away, without passing models that may be bad in the sense that they have reflexive points.

This idea was followed by many authors who wanted to give axiomatizations for classes of frames defined by conditions which are not directly expressible in the intensional language. Examples include Burgess [23], Zanardo [140] for branching-time temporal logics, Kuhn [68] and Venema [131, 130, 132, 133] for many-dimensional modal logics (of intervals), and Gabbay and Hodkinson [36], de Rijke [104], Roorda [107]. There is an independent Bulgarian line of papers: Passy-Tinchev [95], Gargov and Goranko [39], Gargov, Passy and Tinchev [41] where similar rules are used in a context of enriched modal formalisms. Finally, in the first order temporal logic of program verifications there is a related concept called 'clock rule' (cf. Sain [117], Andreka, Nemeti and Sain [10] and the references therein). Gabbay [35] contains a lot of new material concerning the irreflexivity and related rules, for example giving a general procedure to find axiomatizations for *any* first order definable temporal connective, over the class of linear orders.

So the question naturally arises whether anything general can be said about logics having rules like the irreflexivity rule. Let us first have a closer look at $IR$; we suggest to concentrate on the 'converse' statement, i.e.

> If $\phi$ is consistent and does not use $p$,
> then $\phi \land \neg(Gp \to p)$ is consistent.

In other words, to a consistent formula $\phi$ we may always add a conjunct of the form $\neg(Gp \to p)$ *witnessing* irreflexivity.

More general, for an arbitrary similarity type, we set

**Definition 2.1.1.**
Let $\xi$ be a modal formula in the proposition letters $p_0, \ldots, p_{n-1}$. For a class K of frames, set $\mathrm{K}_{-\xi}$ as the class of *non-$\xi$ frames* in K, i.e. the frames $\mathfrak{z} = (W, I)$ in K such that for no world $w$ in $W$, $\mathfrak{z}, w \models \xi$. For $\Xi$ a set of formulas, $\mathrm{K}_{-\Xi}$ is the intersection of the $\mathrm{K}_{-\xi}$, $\xi \in \Xi$. $\square$

Recall that for a formula $\phi$, $\mathrm{Fr}_\phi$ is defined as the class of frames where $\phi$ is valid. Note that in general, the following three classes of frames, all defined using the negation of $\xi$, are *distinct*:

- (i) $\mathrm{Fr}_{-\xi}$ (i.e. the class of frames with $F \models \neg\xi$),
- (ii) $\overline{\mathrm{Fr}_\xi}$ (i.e. the complement of $\mathrm{Fr}_\xi$),
- (iii) $\mathrm{Fr}_{-\xi}$.

For, $\mathfrak{z}$ is in $\mathrm{Fr}_{-\xi}$ iff *for all* valuations $V$ and *all* worlds $w$, $\mathfrak{z}, V, w \models \neg\xi$; $\mathfrak{z}$ is in the second class iff *there are* a valuation $V$ and a world $w$ with $\mathfrak{z}, V, w \models \neg\xi$, and $\mathfrak{z} \in \mathrm{Fr}_{-\xi}$ means that *for every* world $w$ *there is* a valuation $V$ with $\mathfrak{z}, V, w \models \neg\xi$.

This means, so to speak, that $-\xi$ 'corresponds' to the second order formula

$$\forall x_1 \exists P_0 \ldots P_n \neg \xi^1(x_0),$$

where $\xi^1(x_0)$ is the local model correspondent of $\xi$, every monadic predicate $P_i$ being the first order counterpart of the propositional variable $p_i$ in $\xi$. Thus we are studying classes of frames that are definable in a version of second order logic where we have the possibility to use existential quantification over monadic predicates.

As an example, consider the formula $\xi = Gp \to Pp$ which is locally equivalent on the frame level to $\exists y(Rxy \land R^{-1}xy)$. So $\mathrm{Fr}_{-\xi}$ is the class of frames $\mathfrak{z}$ with $\mathfrak{z} \models \forall x \forall y(Rxy \to \neg R^{-1}xy)$ i.e. the class of *asymmetric* frames, while $\overline{\mathrm{Fr}_\xi}$ is the class of frames with $\mathfrak{z} \models \exists x \forall y(Rxy \to \neg R^{-1}xy)$. The negation $Gp \land H \neg p$ of $\xi$ can be shown to be globally equivalent to the formula $\neg \exists x \exists y Rxy$, so $\mathrm{Fr}_{-\xi}$ finally is the class of frames with empty $R$. As another example, one can show $\mathrm{Fr}_{-(Gp \to FFp)}$ to be the class of *intransitive* frames. In these two examples the second order definition of $\mathrm{Fr}_{-\xi}$ can be replaced by a first order one, but this need not always be the case.

Now suppose we want to axiomatize the logic $\Theta(\mathrm{Fr}_{-\xi})$ consisting of all formulas valid in $\mathrm{Fr}_{-\xi}$. Let $\phi$ be a $\Theta(\mathrm{Fr}_{-\xi})$-consistent formula, then there is a model $\mathfrak{M} = (\mathfrak{z}, V)$ such that $\mathfrak{z}$ is in $\mathrm{Fr}_{-\xi}$ and with a world $w$ in $\mathfrak{M}$ where $\mathfrak{M}, w \models \phi$. Let $p_0, \ldots, p_{n-1}$ be *new* propositional variables, in the sense that they are not elements of $Dom(V)$. As $\mathfrak{z}, w \not\models \xi$, there is a valuation $V'$ such that $\mathfrak{z}, V', w \models \neg\xi(p_0, \ldots, p_{n-1})$. Now let $V''$ be defined by

$$\begin{aligned}
V''(q) &= V(q) \quad \text{if } q \in Dom(V) \\
V''(p_i) &= V'(p_i) \quad \text{for } i = 0, \ldots, n-1.
\end{aligned}$$

then clearly we have $(\mathfrak{z}, V''), w \models \phi \land \neg\xi$.

This means that

> $\phi \land \neg\xi(p_0, \ldots, p_{n-1})$ is $\Theta(\mathrm{Fr}_{-\xi})$-consistent if $\phi$ is $\Theta(\mathrm{Fr}_{-\xi})$-consistent and none of the $p_i$ occurs in $\phi$.

Taking the converse again of the above proposition, we have a formulation of the $\neg\xi$-consistency rule. (This rule is called the $I\xi$-rule in Gabbay [35].)

**Definition 2.1.2.**
Let $\xi(p_0, \ldots, p_{n-1})$ be a modal formula. The $\neg\xi$- *consistency rule*, or shorter: the *non-$\xi$ rule* is the following derivation rule:

$(N\xi R) \qquad \vdash \neg\xi(p_0, \ldots, p_{n-1}) \to \phi \ \Rightarrow\ \vdash \phi, \text{ if } \vec{p} \notin \phi.$

If $\Lambda$ is a derivation system and $\xi$ a formula ($\Xi$ a set of formulas), then $\Lambda(-\xi)$ ($\Lambda(-\Xi)$) denotes the system $\Lambda$ extended with the non-$\xi$ rule (all non-$\xi$ rules, $\xi \in \Xi$). $\square$

The paragraph above definition 2.1.2 can be seen as a proof of the *soundness* of $N\xi R$ with respect to $\mathrm{Fr}_{-\xi}$: if $\mathrm{Fr}_{-\xi} \models \neg\xi(p_0, \ldots, p_{n-1}) \to \phi$ and no $p_i$ occurs in $\phi$, then $\mathrm{Fr}_{-\xi} \models \phi$.

The aim however is of course to try and show *completeness* for non-$\xi$ rules; this will be the main subject of this chapter. We should note at this moment that in general we do not have an isolated $N\xi R$ added to a minimal (tense) logic, but a situation in which we add possibly more than one $N\xi R$ to a logic having other axioms besides the basics.

So the general question, raised by Gabbay [31, 35] is the following: we have a similarity type $S$, an $S$-logic $\Lambda$ which is (strongly) sound and complete with respect to a class of frames K, and a set of formulas $\Xi$. The question now is the following

> Is $\Lambda(-\Xi)$ strongly complete with respect to $\mathrm{K}_{-\Xi}$ ?

Gabbay proves a generalized irreflexivity lemma stating that a $\Lambda(-\xi)$-consistent set $\Sigma$ of formulas has a model $\mathfrak{M}$ with $\mathfrak{M} \models \Theta(\mathrm{Fr}_{\Lambda, -\Xi})$. Unfortunately, this is not enough to prove completeness, for we have to find a model $\mathfrak{M}$ such that the underlying *frame* is in $\mathrm{Fr}_{-\Xi}$.

In general this seems to be difficult and maybe even impossible to establish. Therefor we concentrate on logics with a special, nice kind of axioms, viz. so-called Sahlqvist formulas. For some of these logics we can get a positive answer to the above question. The answer we obtain is partial because our proof method will turn out to be highly sensitive to the similarity type of the logic. In particular, and maybe surprisingly, there is a striking difference in our approach between *tense* similarity types (i.e. where the language has a 'converse' operator for each of its diamonds) and uni-directional ones (where no operator has a converse).

Furthermore, we feel our proofs become more perspicuous if we add a special operator, the so-called *difference operator*, to the language. We would like to stress the point, that in many applications (in fact for *all* logics discussed here), this will turn out to be only an apparent extension of the language because the operator is *definable* in the old language, at least over the class of frames that we want to axiomatize.

---

## 2.2 Sahlqvist Theorems

It is well-known that on the level of frames every formula $\phi$ locally and globally has a second order equivalent $\phi^2$. In many important cases however, it turns out that this formula $\phi^2$ has a much simpler first order equivalent (in the corresponding frame language $L_S$). Well-known examples include reflexivity for $p \to \Diamond p$ and the Church-Rosser property for $\Diamond\Box p \to \Box\Diamond p$. A general theorem in this direction was found by Sahlqvist (cf. [111]). The *correspondence* part of Sahlqvist's theorem gives a decidable set of modal $S$-formulas having a local equivalent in $L_S$. In [14], van Benthem provides a quite perspicuous algorithm to find this first order correspondent $\phi^s$ of a Sahlqvist formula $\phi$. (At the end of section 3, we will give our version of this *substitution method*.) The second, *completeness* part of the Sahlqvist theorem states that adding a set $\Sigma$ of Sahlqvist axioms to the minimal $S$-logic $K_S$, we obtain a complete axiomatization for the class of frames $\mathrm{Fr}_\Sigma$. An accessible version of the proof of this part can be found in Sambin-Vaccaro [118], from which we took some terminology. The correspondence and completeness part of Sahlqvist's theorem are closely connected; in Kracht [66] they are studied in a unifying framework.

**Definition 2.2.1**
A *strongly positive formula* is a conjunction of formulas $\Box_1 \ldots \Box_m p_i$ ($m \geq 0$). A formula is *positive* (*negative*) if every propositional variable occurs under an even *(odd)* number of negation symbols. A modal formula is *untied* if it is obtained from strongly positive formulas and negative ones by applying only $\land$ and arbitrary existential modal operators. Formulas of the form $\phi \to \psi$ with $\phi$ a tense formula and $\psi$ a positive one, are called *Sahlqvist formulas*$^2$. $\square$

**Theorem 2.2.2. SAHLQVIST.**
Let $\sigma$ be a Sahlqvist formula. Then

- **(i)** $\sigma$ is canonical: $\mathfrak{z}^c_{K_S\sigma} \models \sigma$.
- **(ii)** $K_S\sigma$ is strongly sound and complete with respect to $\mathrm{Fr}_\sigma$.
- **(iii)** There is an effectively obtainable $L_S$-formula $\sigma^s(x_0)$ such that for all $\mathfrak{z}$ in Fr, $w$ in $\mathfrak{z}$:

$$\mathfrak{z}, w \models \sigma \iff \mathfrak{z} \models \sigma^s[x_0 \mapsto w].$$

**Proof.**
For (i) we refer to Sambin-Vaccaro [118]; (ii) is immediate by (i). The last part (iii) will be proved in the next section, where we will also give the algorithm to find $\sigma^s(x_0)$. $\square$

A typical example of a formula which is *not* Sahlqvist, is $\Box\Diamond p \to \Diamond\Box p$. A typical example of a Sahlqvist formula is $\Diamond\Box p \to \Box\Diamond p$; its first order correspondent is $\forall y_0 y_1((Rxy_0 \land Rxy_1) \to \exists z(Ry_0 z \land Ry_1 z))$.

The remainder of this section, which is the result of joint work with Maarten de Rijke, is not needed for understanding the rest of Chapter 2.

Although the Sahlqvist theorem is a very nice and important instrument in proving modal completeness, it seems not to belong to the standard luggage of modal logicians. It will then hardly come as a surprise that the result is virtually unknown in algebraic logic. Quite deplorably so, because it has very interesting consequences for the theory of Boolean Algebras with operators, consequences which are almost trivial to obtain, by a suitable arrangement of known results.

**Definition 2.2.3.**
Let $S$ be a modal similarity type. All notions defined in 2.2.1 apply to (algebraic) $S$-terms as well as to (modal) $S$-formulas, cf. Appendix A11. A *Sahlqvist equation* is an equation of the form$^3$ $r \leq t$ where $r$ is an untied term and $t$ a positive one. A *Sahlqvist variety* is a variety axiomatized by Sahlqvist equations. The *Sahlqvist correspondent* of a Sahlqvist equation $\eta$: $r \leq t$ is given as the $L_S$-formula $\forall x_0 \sigma^s$ where $\sigma$ is the *underlying modal formula* $(r \to t)$ of $\eta$. $\square$

These equations are abundant in algebraic logic: *all* axioms of cylindric and relation algebras are Sahlqvist equations (or have such equivalents). For example, we can rewrite the RA-axiom $x\check{\ };-(x;y) \leq -y$ as $x\check{\ };-(x;y) \land y \leq 0^4$. The Sahlqvist correspondent of the Sahlqvist equation $\eta$ is the universal closure of the Sahlqvist correspondent of the underlying modal formula of $\eta$: the correspondent of the 'Church-Rosser equation' $\Diamond - \Diamond - x \leq -\Diamond - \Diamond x$ is $\forall x y_0 y_1((Rxy_0 \land Rxy_1) \to \exists z(Ry_0 z \land Ry_1 z))$.

Our main result about Sahlqvist equations is that they are preserved under taking *canonical embedding algebras*. This theorem forms a considerable strengthening of a result by Henkin, Monk and Tarski in [53]: they call a term *positive in the wider sense* if no subterm beginning with the negation symbol contains a variable. A *positive equation in the wider sense* is of the form $r = t$ with $r$ and $t$ positive terms. In section 2.7 of [53] the authors prove that positive equations are preserved under taking canonical embedding algebras. It is straightforward to verify that splitting up a positive equation $r = t$ into $r \leq t$ and $t \leq r$, we obtain two Sahlqvist equations. On the other hand, there are many Sahlqvist equations that are not positive, for example the 'Church-Rosser equation' mentioned above.

The following result is immediate by 2.2.2 and the definitions:

**Theorem 2.2.4.**
Let $S$ be a modal similarity type, $\mathfrak{z}$ a frame and $\eta$ a Sahlqvist equation. Then

$$\mathfrak{Cm}\mathfrak{z} \models \eta \iff \mathfrak{z} \models \eta^s.$$

**Theorem 2.2.5.**
Let $\mathfrak{A}$ be a Boolean Algebra with Operators and $\eta$ a Sahlqvist equation. Then

$$\mathfrak{A} \models \eta \iff \mathfrak{Cm}\mathfrak{A} \models \eta.$$

**Proof.**
Let $\eta$ be valid in $\mathfrak{A}$; assume $\eta$ is of the form $\phi \leq \psi$. Set $\mathfrak{A}_\eta$ as the free algebra (of suitable cardinality) over the variety $\mathrm{V}_\eta$. Let $K_S\eta$ be the extension of the minimal $S$-logic $K_S$ with the axiom $\phi \to \psi$, and set $\mathfrak{z}_\eta$ as the canonical frame of this logic, then $\mathfrak{z}_\eta = \mathfrak{Cs}\mathfrak{A} - \eta$ by A39.
Now by canonicity of Sahlqvist formulas, cf. Theorem 2.2.2, $\mathfrak{z}_\eta \models \phi \to \psi$. This implies $\mathfrak{Cm}\mathfrak{z}_\eta \models \eta$, and as $\mathfrak{Cm}\mathfrak{z}_\eta = \mathfrak{Cm}\mathfrak{A}_\eta$, the theorem follows by the observation (cf. Goldblatt [43], 3.2.5(6)) that $\mathfrak{Cm}\mathfrak{A}$ is a homomorphic image of $\mathfrak{Cm}\mathfrak{A}_\eta$. $\square$

Maybe the nicest aspect of the above theorem is that it frees us from giving tedious algebraic derivations for Sahlqvist equations, allowing us to focus on reasoning in *atom structures*. The following example of this feature will be used in chapter 4:

**Corollary 2.2.6.**
Let V be a Sahlqvist variety and $\eta_1, \eta_2$ two Sahlqvist equations. Then

$$\mathrm{AtV} \models \eta_1^s \leftrightarrow \eta_2^s \iff \mathrm{V} \models \eta_1 \leftrightarrow \eta_2.$$

**Proof.**
($\Rightarrow$) Let $\mathfrak{A}$ be an algebra in V with $\mathfrak{A} \models \eta_i$. By Theorem 2.2.5, $\eta_i$ holds in $\mathfrak{Cm}\mathfrak{A} = \mathfrak{Cm}\mathfrak{Cs}\mathfrak{A}$. So by Theorem 2.2.4 $\eta_i^s$ is valid in the canonical structure $\mathfrak{Cs}\mathfrak{A}$. By assumption then, $\eta_j^s$ is valid in $\mathfrak{Cs}\mathfrak{A}$ as well. But then again $\mathfrak{Cm}\mathfrak{A} \models \eta_j$, so $\eta_j$ holds in $\mathfrak{A}$ as $\mathfrak{A}$ is a subalgebra of $\mathfrak{Cm}\mathfrak{A}$.

($\Leftarrow$) Let $\mathfrak{z}$ be a frame in AtV with $\mathfrak{z} \models \eta_i^s$. Then $\mathfrak{Cm}\mathfrak{z} \models \eta_i \Rightarrow \mathfrak{Cm}\mathfrak{z} \models \eta_j \Rightarrow \mathfrak{z} \models \eta_j^s$. $\square$

---
