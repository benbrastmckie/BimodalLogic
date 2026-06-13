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

## 2.3 Sahlqvist tense formulas

In the previous section we saw that a Sahlqvist formula is *canonical*: if it holds in a canonical model, then it is valid on *all* models on the underlying canonical frame. In this chapter we develop and use non-standard notions of canonical structures, for which we have to adapt the proof of the Sahlqvist theorem. In fact we will show that van Benthem's substitution method (which deals with Kripke frames) also works for the following class of *general* frames:

**Definition 2.3.1.**
A general frame $\mathfrak{G} = (\mathfrak{z}, A)$ is *discrete* if for all worlds $w$ in $\mathfrak{z}$, $\{w\} \in A$. $\square$

A crucial distinction will be made among the *diamonds* of the similarity type, between the uni-directional ones and those of which the converse diamond also belongs to $S$, cf. Appendix A.40.

**Definition 2.3.2.**
A *Sahlqvist tense formula*, or shortly: an *St-formula* is a Sahlqvist formula satisfying the extra constraint that all boxes occurring in strongly positive formulas are *tense* boxes. $\square$

As an example of a Sahlqvist formula which is not an St-formula, we can take our Church-Rosser formula $\Diamond\Box p \to \Box\Diamond p$ (at least, if $\Diamond$ is not a tense diamond). Our 'tense axiom' $p \to \Box^{-1}\Diamond p$ itself is an St-formula. Note that in a tense similarity type, there is no distinction between Sahlqvist formulas and St-formulas.

The theorem that we need is the following:

**Theorem 2.3.3.**
Let $\mathfrak{G} = (\mathfrak{z}, A)$ be a discrete general tense frame and $\sigma$ a Sahlqvist tense formula such that $\mathfrak{G} \models \sigma$. Then $\mathfrak{z} \models \sigma$.

The remainder of this section is devoted to prove Theorem 2.3.3; as a side result, we can give an easy formulation of the algorithm producing the first order correspondent of a Sahlqvist formula.

The definition of Sahlqvist formulas is a syntactic one, but in fact the important constraint on the consequent is a semantic one, viz. monotonicity:

**Definition 2.3.4.**
Let $V$ and $V'$ be two valuations on a frame $\mathfrak{z}$. $V'$ is *wider than* $V$, notation: $V \leq V'$, if for all atoms $p$, $V(p) \subseteq V'(p)$. A modal formula $\phi$ is *monotone* if for all $\mathfrak{z}, V, V'$ and $w$:

$$\mathfrak{z}, V, w \models \phi \text{ and } V \leq V' \text{ imply } \mathfrak{z}, V', w \models \phi \qquad \square$$

We also need related concepts for the first order model-language.

**Definition 2.3.5.**
Let $Q$ be the set of propositional variables of the language. Recall that $L_{S,Q}$ denotes the first order language with $S$-accessibility predicates and a monadic predicate $P_i$ for every propositional variable $p_i \in Q$. The *sign* of an occurrence of a predicate $T$ in a formula $\phi$ is defined by induction to $\phi$: $T$ occurs positively in the atomic formula $Tx_0 \ldots x_{n-1}$. If $T$ occurs positively (negatively) in $\phi$, then it occurs negatively (positively) in $\neg\phi$, and positively (negatively) in $\phi \lor \psi$ and $\exists x\phi$. An $L_{S,Q}$-formula is *positive (negative)* if all occurrences of $Q$-predicates are positive (negative).

An $L_{S,Q}$-formula $\phi(x_1, \ldots, x_n)$ is *monotone* if for all valuations $V, V'$ and all $n$-tupels $w_1, \ldots, w_n$:

$$\mathfrak{z}, V \models \phi[w_1, \ldots, w_n] \text{ and } V \leq V' \text{ imply } \mathfrak{z}, V' \models \phi[w_1, \ldots, w_n]. \qquad \square$$

Note that in the above definition it does not matter how the *accessibility* predicates occur in a formula. There is a lot to be said about the above concepts, but we confine ourselves to the following facts, of which the proof is standard:

**Lemma 2.3.6.**

- **(i)** If $\phi$ is a positive (negative) formula, then so is $\phi^1$.
- **(ii)** Negations of positive (negative) formulas are equivalent to negative (positive) ones.
- **(iii)** Positive formulas are monotone.

From here until 2.3.13 we fix the St-formula $\sigma$ and the general frame $\mathfrak{G} = (\mathfrak{z}, A)$, $\mathfrak{z} = (W, R_\nabla)_{\nabla \in S}$. To establish the validity of $\sigma$ in $\mathfrak{z}$, we must prove that for every valuation $V$, the model $\mathfrak{z}, V \models \sigma$. So let us start with defining a set of valuations for which we already know that $\mathfrak{z}, V \models \sigma$ (the proof is standard):

**Definition 2.3.7.**
A valuation $V$ is *admissible* if $V(p) \in A$ for all atoms $p$.

**Lemma 2.3.8.**
For all admissible valuations $V$, $\mathfrak{z}, V \models \sigma$. $\square$

We now proceed to define a second kind of valuations, intuitively those forming the *minimal* valuations needed to make the strongly positive formulas, (these being the 'real' antecedent of the Sahlqvist formula $\sigma$,) true in a world of $W$.

**Definition 2.3.9.**
First we define *basic rudimentary formulas*, or short, br-formulas: a basic rudimentary formula of *length* 0 is of the form $\beta(x,y) \equiv x = y$. If $\beta(x, x_n)$ is a basic rudimentary formula of length $n$ and $R_\Diamond$ is the accessibility symbol of a tense diamond, then $\exists x_n(\beta(x, x_n) \land R_\Diamond x_n y)$ is a basic rudimentary formula of length $n + 1$.

A *rudimentary formula*, or short, an r-formula, is of the form

$$\rho(x_1, \ldots, x_n, y) \equiv \bigvee_{1 \leq i \leq n} \beta_i(x_i, y),$$

where every $\beta_i$ is a basic rudimentary formula in $x_i$ and $y$.

A subset $X$ of $W$ is *rudimentary in* $w_1, \ldots, w_n \in W$ if for some rudimentary formula $\rho(x_1, \ldots, x_n, y)$, $X = \{v \in W \mid \mathfrak{z} \models \rho(w_1, \ldots, w_n, v)\}$.

A valuation $V$ is *rudimentary* if for all atoms $p$, $V(p)$ is rudimentary. $\square$

Note that, intuitively, a basic rudimentary formula $\beta(x, y)$ of length $n$ describes the existence of a path from $x$ to $y$ following tense accessibility relations. A rudimentary formula $\rho(x_1, \ldots, x_n, y)$ describes the position of $y$ with respect to $x_1, \ldots, x_n$ in the frame, in terms of 'tense paths' leading from $x_i$ to $y$, for every $x_i$.

**Lemma 2.3.10.**
Rudimentary valuations on discrete general tense frames are admissible.

**Proof.**
It is sufficient to prove that for every r-formula $\rho(x_1, \ldots, x_n, y)$, the sets $X_{\rho,\vec{w}} = \{v \in W \mid \mathfrak{z} \models \rho(w_1, \ldots, w_n, v)\}$ are in $A$ for all $n$-tupels $\vec{w} = (w_1, \ldots, w_n)$ of worlds in $W$. Because $A$ is closed under finite unions, we can do with showing the above for *basic* rudimentary formulas. By induction to the length $k$ of a basic formula $\beta(x, y)$ we prove the following claim:

> For every $w \in W$, $X_{\beta,w} \in A$.

For $k = 0$, we have $X_{\beta,w} = \{w\}$ in $A$ by the discreteness of $\mathfrak{G}$.

For $k = m + 1$, let $\beta(x, y)$ be of the form $\exists x_n(\beta'(x, x_n) \land R_\Diamond x_n y)$ where $\Diamond$ is a tense diamond.

Now $X_{\beta,w} = \{v \in W \mid \mathfrak{z} \models \beta(w, v)\}$ is the set of worlds $v$ such that there is a $u \in W$ with $\mathfrak{z} \models \beta'(w, u)$ and $\mathfrak{z} \models R_\Diamond uv$.

So $X_{\beta,w}$ contains precisely the worlds having an $R_\Diamond$-predecessor in $X_{\beta',w}$, or

$$X_{\beta,w} = \{v \in W \mid v \text{ has an } R_\Diamond^{-1}\text{-successor in } X_{\beta',w}\}.$$

By the induction hypothesis, $X_{\beta',w}$ is in $A$, and the fact that we are in a tense frame, $(R_\Diamond)^{-1}$ is the accessibility relation of $\Diamond^{-1}$. So $X_{\beta,w} = m_{\Diamond^{-1}}(X_{\beta,w}) \in A$, cf. Appendix A.17.

Note that in the above proof it is essential to have *tense* operators in *tense* frames. $\square$

**Lemma 2.3.11.**
Let $\psi$ be an untied formula. Then its first order model-equivalent $\psi^1(x_0)$ is equivalent to

$$\exists x_1 \ldots x_n \Big(\pi \land \bigwedge_{i < k} \forall y(\rho_i(\vec{x}, y) \to P_i y) \land \bigwedge_{j < m} N_j(u_j)\Big).$$

where the $x_i$'s are distinct variables different from $x_0$, all the variables $u_i$ are among $x_0, \ldots, x_n$, $\pi$ is a conjunction of atomic $L_S(x_0, \ldots, x_n)$-formulas (i.e. atomic accessibility formulas of the form $R_\nabla(x_{i_0}, \ldots, x_{i(v_j)})$ with $\nabla$ an arbitrary $S$-operator and every variable in $\{x_0, \ldots, x_n\}$), the $\rho_i$'s are suitable rudimentary formulas, and the $N_j$'s are negative.

**Proof.**
By a straightforward induction to the complexity of untied formulas, cf. Sambin and Vaccaro [118]. $\square$

**Lemma 2.3.12.**
Let $\sigma = \psi_1 \to \psi_2$ be a Sahlqvist formula. Then $\sigma^1(x_0)$ is equivalent to

$$\forall x_1 \ldots x_n \Big(\Big(\pi \land \bigwedge_{i < k} \forall y(\rho_i(\vec{x}, y) \to P_i y)\Big) \to \gamma_2(x_0, \ldots, x_n)\Big).$$

where the antecedent is as in the previous lemma and the consequent $\gamma_2$ is some positive formula.

**Proof.**
Let $N(x_0, \ldots, x_n)$ be the formula $\bigwedge_{j < m} N_j(u_j)$, then $N$ is negative. By lemma 2.3.11, the local model correspondent $\sigma^1(x_0)$ of $\sigma$ is equivalent to

$$\forall x_1 \ldots x_n \Big(\Big(\pi \land \bigwedge_{i < k} \forall y(\rho_i(\vec{x}, y) \to P_i y) \land N\Big) \to \psi_2^1(x_0)\Big).$$

So, by moving the negative $N$ from the antecedent to the consequent, we obtain

$$\forall x_1 \ldots x_n \Big(\Big(\pi \land \bigwedge_{i < k} \forall y(\rho_i(\vec{x}, y) \to P_i y)\Big) \to \Big(\neg N \lor \psi_2^1(x_0)\Big)\Big).$$

where the antecedent is already as desired, and the consequent is positive as it is a disjunction of two positive formulas (cf. 2.3.6). $\square$

**Proof of Theorem 2.3.3.**
Let $\sigma$ be of the form $\psi_1 \to \psi_2$, where $\psi_1$ is untied and $\psi_2$ is positive. We use the notation of the previous lemmas and set

$$\gamma_1(x_0, \ldots, x_n) \equiv \pi \land \bigwedge_{i < k} \forall y(\rho_i(\vec{x}, y) \to P_i y)$$

Obviously, $\sigma^1(x_0)$ is equivalent to $\forall x_1 \ldots x_n(\gamma_1 \to \gamma_2)$, where $\gamma_2$ is positive and hence monotone.

So by the fact that $\mathfrak{G} = (\mathfrak{z}, A) \models \sigma$ we get

$$\text{for all \textit{admissible} valuations } V, \quad \mathfrak{z}, V \models \forall x_0 \ldots x_n(\gamma_1 \to \gamma_2). \tag{1}$$

Our aim is to show that this implies $\mathfrak{z} \models \sigma$, or equivalently

$$\text{for \textit{all} valuations } V, \quad \mathfrak{z}, V \models \forall x_0 \ldots x_n(\gamma_1 \to \gamma_2). \tag{$\dagger$}$$

So let a valuation $V$ be given, together with worlds $w_0, w_1, \ldots, w_n \in W$ for which we have

$$\mathfrak{z}, V \models \gamma_1(w_0, w_1, \ldots, w_n). \tag{2}$$

Now let $V^-$ be the rudimentary valuation that precisely 'fits' in $\gamma_1$, i.e. $V^-(p_i) = \{v \in W \mid \mathfrak{z} \models \rho_i(\vec{w}, v)\}$, then

$$\mathfrak{z}, V^- \models \gamma_1(w_0, w_1, \ldots, w_n). \tag{3}$$

$V^-$ is admissible by lemma 2.3.10, so (1) and (3) give

$$\mathfrak{z}, V^- \models \gamma_2(w_0, w_1, \ldots, w_n). \tag{4}$$

But by (2) and definition of $V^-$, we have $V^- \leq V$. Together with the fact that $\gamma_2$ is monotone, this yields

$$\mathfrak{z}, V \models \gamma_2(w_0, w_1, \ldots, w_n), \tag{5}$$

which ensures ($\dagger$). $\square$

As a matter of fact, from this proof it is only a minor step to give the algorithm producing the correspondent $\sigma^s(x_0)$ of an arbitrary (i.e. not necessarily tense) Sahlqvist formula:

**Definition 2.3.13.**
For a Sahlqvist formula $\sigma$, let $\sigma^s(x_0)$ be the $L_S$-formula

$$\forall x_1 \ldots x_n(\pi \to (\gamma_2(x_0, \ldots, x_n))[\rho_i(\vec{x}, u)/P_i u])$$

(i.e. we substitute, everywhere in $\gamma_2$, $\rho_i(\vec{x}, u)$ for the atomic formula $P_i u$.) $\square$

**Theorem 2.3.14 (SAHLQVIST CORRESPONDENCE).**
Let $\sigma$ be an arbitrary Sahlqvist formula, $w$ a world in a frame $\mathfrak{z}$. Then

$$\mathfrak{z}, w_0 \models \sigma \iff \mathfrak{z} \models \sigma^s[x_0 \mapsto w_0].$$

**Proof.**
($\Rightarrow$) Let $w_1, \ldots, w_n$ be such that $\mathfrak{z} \models \pi[w_0, \ldots, w_n]$. This implies that, with $V^-$ the valuation such that

$$V^-(p_i) = \{v \in W \mid \mathfrak{z} \models \rho_i(\vec{w}, v)\},$$

we have

$$\mathfrak{z}, V^- \models \pi \land \forall y(\rho_i(\vec{x}, y) \to P_i y)[w_0, \ldots, w_n].$$

So by the assumption $\mathfrak{z}, w_0 \models \sigma$, lemma 2.3.12 gives $\mathfrak{z}, V^- \models \gamma_2(x_0, \ldots, x_n)$. By definition of $V^-$ we immediately obtain

$$\mathfrak{z} \models (\gamma_2(x_0, \ldots, x_n))[\rho_i(\vec{x}, u)/P_i u])[w_0, \ldots, w_n],$$

which is what we desired.

($\Leftarrow$) Here we can copy the proof of Theorem 2.3.13, after making the observation that now

$$\mathfrak{z}, V^-, w_0 \models \sigma$$

by definition of $\sigma^s$ and the assumption $\mathfrak{z} \models \sigma^s[w_0]$. $\square$

---

## 2.4 The $D$-operator

An important role in this dissertation is played by the so-called *difference* operator $D$. This operator is special in having the *inequality* relation as its intended accessibility relation:

**Definition 2.4.1.**
Let $S$ be a similarity type containing the monadic operator $D$. An $S$-frame $\mathfrak{z} = (W, R_\nabla)_{\nabla \in S}$ is called *(D-)standard* if

$$R_D = \{(s, t) \in {}^2W \mid s \neq t\}.$$

As abbreviations we use $\underline{D}\phi \equiv \neg D \neg \phi$, $O\phi \equiv \phi \land \underline{D}\neg\phi$, $E\phi \equiv \phi \lor D\phi$.

For K a class of $S$-frames, we denote the class of standard frames in K by $\mathrm{K}^\neq$. $\square$

When referring to standard frames, we will suppress mentioning the inequality relation $R_D$. Thus we may identify standard frames for $S$ with the frames for the similarity type obtained by dropping $D$ from $S$. In the sequel we will frequently omit the adjective 'standard' when referring to the intended semantics, explicitly using the term 'non-standard' for the frames with $R_D \neq \{(s, t) \in {}^2W \mid s \neq t\}$. Note that in a standard model we have

- $\mathfrak{M}, w \models D\phi$ iff there is a $v \neq w$ with $\mathfrak{M}, v \models \phi$,
- $\mathfrak{M}, w \models O\phi$ iff $w$ is the *only* world with $\mathfrak{M}, w \models \phi$,
- $\mathfrak{M}, w \models E\phi$ iff there is a world $v$ with $\mathfrak{M}, v \models \phi$.

In many examples the $D$-operator is *definable* in the poorer language; for example, over the class LI of irreflexive linear orderings we have

$$\mathrm{LI} \models D\phi \leftrightarrow (F\phi \lor P\phi).$$

All of the similarity types studied in this dissertation have the property that over the class of frames to be axiomatized, the $D$-operator is definable.

The $D$-operator was introduced independently by various authors, including, in (probably) chronological order: Sain [113, 116], Koymans [65] and Gargov-Passy-Tinchev [41]. A nice feature of this new operator, and the main reason for its introduction, is the fact that it greatly increases the expressive power of the language. For example, *irreflexivity* is easily seen to be characterized by the formula $\Diamond p \to Dp$. Maarten de Rijke proved many results on the expressiveness and completeness of modal and tense logics having a $D$-operator, cf. [104]. We only need the following:

**Definition 2.4.2.**
Let $S$ be a similarity type containing $D$. For $\Lambda$ an $S$-logic, $\Lambda D$ denotes the logic $\Lambda$ extended with the following axioms:

- $(D1)$ $\quad p \to \underline{D}Dp$
- $(D2)$ $\quad DDp \to (p \lor Dp)$
- $(D3\nabla)$ $\quad \nabla(p_1, \ldots, p_n) \to \Lambda\, Ep_i$.

$\Lambda D^+$ is the logic $\Lambda D$ extended with the *irreflexivity rule for $D$*:

$(IR_D) \qquad \vdash Op \to \phi \ \Rightarrow\ \vdash \phi, \text{ if } p \notin \phi.$

Instead of $K_{\{D\}}$ (the minimal $D$-logic), we write $K_D$, instead of $K_DD$: $KD$. $\square$

**Theorem 2.4.3.**
For any similarity type $S$, $K_SD$ and $K_SD^+$ are both strongly sound and complete with respect to the class of standard $S$-frames.

**Proof.**
Cf. de Rijke [104]. $\square$

As a corollary of this completeness theorem some nice semantic properties of the operators are also *provable*:

**Lemma 2.4.4.**

- **(i)** $\vdash KD^{(+)} \vdash E(Op \land \phi) \land E(Op \land \neg\phi) \to \bot$.
- **(ii)** If $\nabla$ is an $S$-operator, then
  $\vdash K_SD^{(+)} \vdash (\nabla(\ldots, Op \land \phi, \ldots) \land \nabla(\ldots, Op \land \neg\phi, \ldots)) \to \bot$.
- **(iii)** If $\nabla$ is an $S$-operator, then
  $\vdash K_SD^{(+)} \vdash \Lambda_i\, \nabla(\ldots, Op \land \phi_i, \ldots) \to \nabla(\ldots, Op \land \Lambda_i\, \phi_i, \ldots)$.

**Proof.**
By showing that the above schemes of formulas are semantically *valid* in standard $S$-frames, and then using the completeness theorem for $KD^{(+)}$. $\square$

*Combining* the notions of Sahlqvist (tense) formulas and the $D$-operator, we seem to have two options. Because of the general result on Sahlqvist correspondence, we know that every Sahlqvist formula $\sigma$ has a local correspondent $\sigma^{s'}(x_0)$ in the language $L_S$ where $R_D$ is the symbol for the accessibility relation of $D$. However, we are almost exclusively interested in the way this equivalence works out for the *standard* frames; this means that we will only consider interpretations where $R_D$ is the inequality relation. It is then very natural to let this preference be reflected in the syntax, by a slight abuse of notation:

**Definition 2.4.5.**
Let $S$ be a similarity type and $\sigma$ a Sahlqvist formula. If $S$ does not contain the $D$-operator, $\sigma^s(x_0)$ denotes the ordinary first order Sahlqvist equivalent of $\sigma$ given in Definition 2.3.13. If $S$ does contain $D$, $\sigma^{s'}(x_0)$ denotes this ordinary first order equivalent, $\sigma^s(x_0)$ is $\sigma^{s'}(x_0)$ with every occurrence of $R_D$ replaced by $\neq$. $\square$

As an example, the Sahlqvist correspondent of $\Diamond p \to Dp$ is not $\forall x_1(Rx_0x_1 \to R_Dx_0x_1)$, but $\forall x_1(Rx_0x_1 \to x_0 \neq x_1)$, (or even better: $\neg Rx_0x_0$.) With this notation we record the equivalence of $\sigma$ and $\sigma^s$ for the standard frames:

**Theorem 2.4.6.**
Let $\sigma$ be a Sahlqvist formula, $w$ a world in a standard frame $\mathfrak{z}$. Then

$$\mathfrak{z}, w \models \sigma \iff \mathfrak{z} \models \sigma^s(w_0).$$

**Proof.**
Straightforward by Theorem 2.3.14 and the definitions of $\sigma^s$ and standard frames. $\square$

However, by restricting our attention to standard frames we loose the automatic completeness of Sahlqvist's theorem: where we do have, for a set of Sahlqvist axioms $\Sigma$,

> $K_SD\Sigma$ is strongly sound and complete w.r.t. $\mathrm{Fr}_\Sigma$,

we are not (yet) sure whether

> $K_SD^+\Sigma$ is strongly sound and complete w.r.t. $\mathrm{Fr}^\neq_\Sigma$.

In the next section we will prove the above statement, for Sahlqvist *tense* axioms.

---

## 2.5 The main proof

This subsection contains the main idea of the proof on the Sahlqvist theorem in a context with modal derivation rules. To keep notation as simple as possible, we consider a tense similarity type $S$ having besides the difference operator $D$ only one pair $\{F, P\}$ of tense operators. We let $\Diamond$ range over the monadic modal operators, $\Box$ is the dual of $\Diamond$, and $\Diamond^{-1}$ is the converse of $\Diamond$, i.e. $F^{-1} = P$, $P^{-1} = F$ and $D^{-1} = D$. Note that for this similarity type there is no distinction between ordinary Sahlqvist formulas and Sahlqvist tense formulas. We intend to prove the following theorem, keeping some generalizations and corollaries for later subsections.

**Theorem 2.5.1. SD-THEOREM (monadic operators).**
Let $S$ be a tense similarity type with three diamonds $F$, $P$ and $D$, and let $\sigma$ be a Sahlqvist formula. Then $K^tD^+\sigma$ is strongly sound and complete with respect to $\mathrm{Fr}^{t,\neq}_\sigma$.

Recall that $K^tD^+\sigma$ has the following axioms:

- $(CT)$ all classical tautologies
- $(DB)$ $\Box(p \to q) \to (\Box p \to \Box q)$
- $(CV)$ $\phi \to HFp$
- $(D1)$ $p \to \underline{D}Dp$
- $(D2)$ $DDp \to (p \lor Dp)$
- $(D3)$ $\Diamond p \to p \lor Dp$
- $(\sigma)$ $\sigma$

Its derivation rules are

- $(MP)$ Modus Ponens
- $(UG)$ Universal Generalization
- $(SUB)$ Substitution

and the irreflexivity rule for $D$:

$(IR_D) \qquad \vdash Op \to \phi \ \Rightarrow\ \vdash \phi, \text{ if } p \notin \phi.$

Note that the above theorem is not an automatic corollary of the ordinary Sahlqvist theorem, because of the special interpretation for the accessibility relation of $D$ that we have in mind, namely the inequality relation, and the fact that the axiom system has the unorthodox derivation rule $IR_D$. The difference with the ordinary Sahlqvist case shows itself in the fact that the logic $K^tD^+\sigma$ is *not* canonical:

Consider the set $\{\phi \to D\phi \mid \phi \text{ a formula}\}$. This set is consistent, so it must be contained in a maximal consistent set $\Delta$ which is a world in the canonical frame. Clearly however, $\Delta$ is $R_D$-reflexive, so inequality is *not* the canonical $D$-accessibility relation. In other words: the canonical frame is not standard.

So it turns out that the canonical frame is bad because it contains $R_D$-reflexive worlds. A naive approach to this problem is to simply throw them out of the canonical universe.

This is not sufficient however; consider the set

$$\{p_0 \land \underline{D}\neg p_0\} \cup \{F\top\} \cup \{G(\phi \to \underline{D}\phi) \mid \phi \text{ a formula}\}.$$

It is consistent, so it has a MC extension $\Delta \in W^c$. $\Delta$ itself is not $R_D$-reflexive, but all of its $R_F$-successors are. So $\Delta$, having at least one $R_F$-successor, is an unwelcome inhabitant of the canonical frame too.

Now instead of successively throwing bad MCSs out of the canonical frame, we feel it is better to follow a more constructive path, defining a canonical-like model consisting only of good MCSs. To give this notion of a 'good' MCS, we need some auxiliary definitions. The first one is meant to provide us with a unique representation

$$\phi_0 \land \Diamond_1(\phi_1 \land \ldots \Diamond_{n-1}(\phi_{n-1} \land \Diamond_n \phi_n))$$

for every formula $\phi$.

**Definition 2.5.2: Diamond Forms.**
For notational elegance, instead of $\lor$ we take $\land$ as our basic boolean connective, and we add the *dummy diamond* $\odot$ to the set of monadic operators. This operator has the following interpretation:

$$\mathfrak{M}, w \models \odot\phi \iff \mathfrak{M}, w \models \phi.$$

*Formula paths* and their *lengths* are defined by induction:

- (0) If $\phi$ is a formula, $\langle\phi\rangle$ is a formula path of length 0.
- (1) For a formula $\phi$, $\Diamond \in \{F, P, D, \odot\}$ and $t$ a formula path of length $n$, $\langle(\phi, \Diamond), t\rangle$ is a formula path of length $n + 1$.

For $t$ a formula path, the formula $\Phi\mu(t)$ is defined as

- (0) $\Phi\mu(\langle\phi\rangle) = \phi$
- (1) $\Phi\mu(\langle(\psi, \Diamond), t\rangle) = \psi \land \Diamond\Phi\mu(t)$

Notions like 'consistency' apply to formula paths as if they were formulas.

For $\phi$ a formula, its *path representation* $Pr(\phi)$ is the following formula path:

- (at) $Pr(p) = \langle p \rangle$
- ($\neg$) $Pr(\neg\psi) = \langle\neg\psi\rangle$
- ($\land$) $Pr(\psi \land \chi) = \begin{cases} \langle(\psi, \Diamond), Pr(\chi')\rangle & \text{if } \chi \equiv \Diamond\chi', \Diamond \in \{F, P, D\} \\ \langle(\psi, \odot), Pr(\chi)\rangle & \text{otherwise} \end{cases}$
- ($\Diamond$) $Pr(\Diamond\psi) = \langle(\top, \Diamond), Pr(\psi)\rangle$.

The *diamond form* $N(\phi)$ of a formula $\phi$ is a representation of $\phi$ as $\Phi\mu(Pr(\phi))$, viz.

$$\phi_0 \land \Diamond_1(\phi_1 \land \ldots \Diamond_{n-1}(\phi_{n-1} \land \Diamond_n \phi_n))$$

Let $t$ be a formula path, $\zeta$ a formula and $m$ a natural number. By a nested induction to $m$ and $t$ we define $W^p(\zeta, m, t)$ as the following formula path:

$$\begin{aligned}
W^p(\zeta, 0, \langle\phi\rangle) &= \langle\zeta \land \phi\rangle \\
W^p(\zeta, 0, \langle(\psi, \Diamond), t\rangle) &= \langle(\zeta \land \psi, \Diamond), t\rangle \\
W^p(\zeta, m+1, \langle\phi\rangle) &= \langle\phi\rangle \\
W^p(\zeta, m+1, \langle(\psi, \Diamond), t\rangle) &= \langle(\psi, \Diamond), W^p(\zeta, m, t)\rangle.
\end{aligned}$$

For $\zeta$ and $\phi$ formulas and $m$ a natural number, we set$^5$

$$W(\zeta, m, \phi) = \Phi\mu(W^p(\zeta, m, Pr(\phi))). \qquad \square$$

The intuitive meaning of $W(\zeta, m, \phi)$ is the following: let $\phi$ have a diamond form

$$\phi_0 \land \Diamond_1(\phi_1 \land \ldots \Diamond_{n-1}(\phi_{n-1} \land \Diamond_n \phi_n)),$$

then $W(\zeta, m, \phi)$ is $\phi$ with $\zeta$ added as a *witness* at level $m$, viz.

$$\phi_0 \land \Diamond_1(\phi_1 \land \ldots \Diamond_m(\zeta \land \phi_m \land \Diamond_{m+1}(\phi_{m+1} \land \ldots \Diamond_{n-1}(\phi_{n-1} \land \Diamond_n \phi_n) \ldots)),$$

if $m \leq n$. Otherwise $W(\zeta, m, \phi) = \phi$.

As an example, the diamond form of

$$\phi = \Diamond q \land (q \land \Diamond\Diamond r)$$

is

$$\Diamond q \land \odot(q \land \Diamond(\top \land \Diamond r))$$

so

$$\begin{aligned}
W(\zeta, 0, \phi) &= \zeta \land \Diamond q \land \odot(q \land \Diamond(\top \land \Diamond r)) \\
W(\zeta, 1, \phi) &= \Diamond q \land \odot(\zeta \land q \land \Diamond(\top \land \Diamond r)) \\
W(\zeta, 2, \phi) &= \Diamond q \land \odot(q \land \Diamond(\zeta \land \top \land \Diamond r)) \\
W(\zeta, 3, \phi) &= \Diamond q \land \odot(q \land \Diamond(\top \land \Diamond(\zeta \land r))) \\
W(\zeta, 4, \phi) &= \Diamond q \land \odot(q \land \Diamond(\top \land \Diamond r)).
\end{aligned}$$

**Definition 2.5.3.**
A set of formulas $\Sigma$ is *distinguishing*, or a *d-theory* if

- (i) it is maximal consistent and
- (ii) for every $\phi$ in $\Sigma$ and natural number $m$, there is a propositional variable $p$ with $W(Op, m, \phi)$ in $\Sigma$. $\square$

Note that as d-theories are MCSs, the canonical accessibility relations $R^c_F$, $R^c_P$ and $R^c_D$ for $F$, $P$ and $D$ have the ordinary meaning:

$$R^c_\Diamond \Sigma\Delta \text{ iff for all } \phi \in \Delta, \ \Diamond\phi \in \Sigma$$

We want to take the d-theories as the possible worlds in our version of the canonical model. A minimal constraint which a canonical-ish model must meet is that every consistent set of formulas is somehow to be found as (part of) a possible world. In our setting this means that every consistent set must have a distinguishing extension.

First we need a lemma of a rather technical nature:

**Lemma 2.5.4.**
If $p$ does not occur in $\phi$ or $\eta$, then $\vdash W(Op, m, \phi) \to \eta \ \Rightarrow\ \vdash \phi \to \eta$.

**Proof.**
By induction to $m$.

If $m = 0$, $W(Op, m, \phi)$ is equivalent to $Op \land \phi$, so $\vdash W(Op, m, \phi) \to \eta$ implies $\vdash Op \to (\phi \to \eta)$, whence by an application of $IR_D$ we obtain $\vdash \phi \to \eta$.

If $m = k + 1$, distinguish two cases:

If $\phi$ is an atom or a negation, then $W(Op, m, \phi) = \phi$, so the claim is immediate.

In the other case we have $Pr(\phi) = \langle(\psi, \Diamond), Pr(\chi)\rangle$ (where $\Diamond \in \{F, P, D, \odot\}$), so $W(Op, k + 1, \phi) = \psi \land \Diamond W(Op, k, \chi)$. The claim is now proved as follows:

$$\begin{aligned}
&\vdash (\psi \land \Diamond W(Op, k, \chi)) \to \eta & \text{(assumption)} \\
\Rightarrow\quad &\vdash \Diamond W(Op, k, \chi) \to (\psi \to \eta) & \text{(propositional logic)} \\
\Rightarrow\quad &\vdash W(Op, k, \chi) \to \Box^{-1}(\psi \to \eta) & \text{(tense logic)} \\
\Rightarrow\quad &\vdash \chi \to \Box^{-1}(\psi \to \eta) & \text{(induction hypothesis)} \\
\Rightarrow\quad &\vdash \Diamond\chi \to (\psi \to \eta) & \text{(tense logic)} \\
\Rightarrow\quad &\vdash (\psi \land \Diamond\chi) \to \eta & \text{(propositional logic),}
\end{aligned}$$

and we are finished, as an easy proof shows that $\vdash \phi \leftrightarrow (\psi \land \Diamond\chi)$. $\square$

The following propositions form our version of Gabbay's generalized irreflexivity lemma (cf. [35]):

**Lemma 2.5.5.**
Let $\Sigma$ be a consistent set in which the variable $p$ does not occur, and $\phi \in \Sigma$. Then $\Sigma \cup \{W(Op, m, \phi)\}$ is consistent for all $m$.

**Proof.**
Suppose otherwise, then $\vdash W(Op, m, \phi) \to \neg\psi$ for some $m \in \omega$ and $\psi \in \Sigma$. By Lemma 2.5.4 this would imply $\vdash \phi \to \neg\psi$, contradicting the consistency of $\Sigma$. $\square$

**Lemma 2.5.6.**
If $\Sigma$ is a consistent set, then there is a distinguishing $\Sigma'$ containing $\Sigma$.

**Proof.**
Let $Q$ be the set of propositional variables in $\Sigma$, assume that $Q$ is countable$^6$ and let $p_0, p_1, \ldots$ be mutually distinct propositional variables not in $Q$; set, for $0 \leq \xi \leq \omega$, $Q_\xi = Q \cup \{p_i \mid i < \xi\}$.

For a set $\Delta$ of formulas in $Q_\omega$, let $PV(\Delta)$ be the set of propositional variables appearing in (formulas of) $\Delta$. A theory $\Delta$ is called an *approximation* if $\Delta$ is consistent, $\Sigma \subseteq \Delta$ and $PV(\Delta) = Q_n$ for some $n < \omega$. In this case $p_{n+1}$ is called the *new variable* for $\Delta$ and denoted by $p_\Delta$.

Now let $\Delta$ be an approximation and $(\phi, m)$ a *potential shortcoming*, i.e. $\phi$ is a formula in $Q_\omega$ and $m \in \omega$. The pair $(\phi, m)$ is called a *shortcoming* of $\Delta$ if $\phi \in \Delta$ while no witness $W(Op, m, \phi)$ is in $\Delta$. Assume that we have a wellordering $\mathcal{W}$ of the set $\Phi(M(Q_\omega)) \times \omega$ of potential shortcomings. If $\Delta$ has shortcomings, let $(\phi_\Delta, m_\Delta)$ be the first (in $\mathcal{W}$) of $\Delta$'s shortcomings. Now set

$$\Delta^+ = \begin{cases} \Delta & \text{if } \Delta \text{ has no shortcomings} \\ \Delta \cup \{W(Op_\Delta, m_\Delta, \phi_\Delta)\} & \text{otherwise} \end{cases}$$

We claim that if $\Delta$ is an approximation, then so is $\Delta^+$:
$\Delta^+$ is consistent by lemma 2.5.5; the other conditions are straightforward.

We now define the following sequence of theories $\Sigma_0, \Sigma_1, \ldots$:

$$\begin{aligned}
\Sigma_0 &= \Sigma \\
\Sigma_{2n+1} &= \begin{cases} \Sigma_{2n} \cup \{\phi_n\} & \text{if } \Sigma_{2n+1} \cup \{\phi_n\} \text{ is consistent} \\ \Sigma_{2n} \cup \{\neg\phi_n\} & \text{otherwise} \end{cases} \\
\Sigma_{2n+2} &= \begin{cases} (\Sigma_{2n+1})^+ & \text{if } \Sigma_{2n+1} \text{ has shortcomings} \\ \Sigma_{2n+1} & \text{otherwise} \end{cases}
\end{aligned}$$

and set $\Sigma' = \bigcup_{n < \omega} \Sigma_n$.

It is then straightforward to prove the following:

- (0) $(\Sigma_n)_{n < \omega}$ is an increasing sequence.
- (1) Every $\Sigma_n$ is an approximation.
- (2) For every $Q_\omega$-formula $\phi$, either $\phi$ or $\neg\phi$ is in $\Sigma'$.
- (3) For every $Q_\omega$-formula $\phi$ and $m \in \omega$, there is a witness $W(Op, m, \phi)$ in $\Sigma'$.

This gives all the desired properties of $\Sigma'$. $\square$

The fact that any consistent set is contained in a d-theory, means that in a certain sense there are *enough* distinguishing sets. Note however, that we needed to extend the language to prove lemma 2.5.6. This could mean that problems might arise if we want to show that every d-theory $\Gamma$ containing a formula $\Diamond\phi$ has a distinguishing $\Diamond$-successor $\Delta$ with $\phi \in \Delta$ and $R^c_\Diamond\Gamma\Delta$. For, in context of ordinary maximal consistent sets, this proposition is proved by showing that the set

$$\{\phi\} \cup \{\psi \mid \Box\psi \in \Gamma\}$$

has a maximal consistent extension. We might do the same here, but then we have to show that this set has a distinguishing extension *in the same proposition letters*. We choose a different proof, using the fact that because the language has the $O$-operator, the distinguishing $\Gamma$ contains a complete description of $\Delta$:

**Lemma 2.5.7.**
If $\Gamma$ is a d-theory and $\Diamond\phi \in \Gamma$, then there is a d-theory $\Delta$ with $\phi \in \Delta$ and $R^c_\Diamond\Gamma\Delta$.

**Proof.**
As $\Diamond\phi$ is in $\Gamma$, so is $\Diamond(\phi \land Op)$ for some atom $p$. Let $\Delta$ be the set $\{\psi \mid \Diamond(Op \land \psi) \in \Gamma\}$. $\Delta$ is consistent, for assume otherwise, then there are $\psi_1, \ldots, \psi_n$ in $\Delta$ with every $\Diamond(Op \land \psi_i)$ in $\Gamma$ and

$$\vdash (\bigwedge_i \psi_i) \to \bot$$

By lemma 2.4.4 we have

$$\vdash \bigwedge(\Diamond(Op \land \psi_i)) \to \Diamond(Op \land \bigwedge_i \psi_i)$$

So $\Diamond(Op \land \bigwedge_i \psi_i)$ and hence $\Diamond\bot$ is in $\Gamma$, contradicting its consistency.

As $\Diamond Op \in \Gamma$, for every $\psi$ either $\Diamond(Op \land \psi)$ or $\Diamond(Op \land \neg\psi)$ is in $\Gamma$, so clearly $\Delta$ is maximal.

The fact that $R^c_\Diamond\Gamma\Delta$ is immediate by definition of $\Delta$.

To prove that $\Delta$ is distinguishing, let $\psi \in \Delta$, and $m \in \omega$. We have to show that for some $q$, $W(Oq, m, \psi)$ is in $\Delta$:

By definition of $\Delta$, $\Diamond(Op \land \psi) \in \Gamma$. As $\Gamma$ is distinguishing, there is a $q$ with

$$W(Oq, m + 2, \Diamond(Op \land \psi))$$

in $\Gamma$. But a simple calculation shows this formula to be equivalent to

$$\top \land \Diamond(Op \land W(Oq, m, \psi)),$$

whence $W(Oq, m, \psi) \in \Delta$. $\square$

These two lemmas are sufficient to establish that there are *enough* d-theories. There is still one difference with the ordinary case which we need to discuss: suppose we would take the set of *all* distinguishing sets to form the universe of our canonical model. Then there would be *too many* worlds, for consider two $D$-theories $\Delta, \Delta'$ with $p \land \underline{D}\neg p \in \Delta$, $p \land \underline{D}\neg p \in \Delta'$. If both were to be in our 'canonical' model, the underlying frame would be non-standard, for $\Delta'$ is not an $R_D$-successor of $\Delta$, while clearly $\Delta \neq \Delta'$. This inspires the following definition:

**Definition 2.5.8.**
Two distinguishing theories $\Gamma$ and $\Delta$ are *connected*, notation: $\Gamma \sim_D \Delta$, if either $R^c_D\Gamma = \Delta$ or $R^c_D\Gamma\Delta$. A *set* of d-theories is called *connected* if all pairs of its members are. $\square$

**Lemma 2.5.9.**
$\sim_D$ is an equivalence relation.

**Proof.**
Reflexivity of $\sim_D$ is immediate.

For symmetry, let $\Gamma \sim_D \Delta$. If $\Gamma = \Delta$, we are finished. If not, we have $R^c_D\Gamma\Delta$. Now $R^c_D$ is a symmetric relation (this is an immediate consequence of having the Sahlqvist axiom $D1$ in the logic). So we have $R^c_D\Delta\Gamma$, implying $\Delta \sim_D \Gamma$.

For transitivity of $\sim_D$, it suffices to show that $R^c_D$ is *pseudo-transitive*:

$$\forall x \forall y \forall z((xRy \land yRz) \to (x = z \lor xRz))$$

But this is immediate by the fact that pseudo-transitivity is the Sahlqvist correspondent of axiom $D3$, and the completeness part of Sahlqvist's theorem. $\square$

**Definition 2.5.10: d-canonical structures.**
A *d(istinguishing)-canonical frame* is of the form $\mathfrak{z}^d = (W^d, R^d_F, R^d_P, R^d_D)$ where $W^d$ is a connected set of distinguishing theories, and the $R^d$'s are the $R^c$'s restricted to $W^d$.

Define also *d-canonical models* $\mathfrak{M}^d = (\mathfrak{z}^d, V^d)$ and *d-canonical general frames* $\mathfrak{G}^d = (\mathfrak{z}^d, A^d)$, where $V^d$ is $V^c$ restricted to $W^d$ and $A$ is given by $X \in A^d$ iff $X = V^d(\phi)$ for some $\phi$. $\square$

In the sequel we will have a particular d-canonical model, frame, etc. in mind, viz. the one consisting of all worlds connected to a fixed d-theory $\Sigma$. Therefor, we will frequently speak about *the* d-canonical model, frame, etc.

We need several nice properties of the d-canonical model. The easiest to establish is the truth lemma, via the fact that the d-canonical frame is a tense frame and standard:

**Lemma 2.5.11.**
Let $\mathfrak{z}^d$ be a d-canonical frame, then

- **(i)** $R^d_F$ and $R^d_P$ are each others converse.
- **(ii)** $R^d_D$ is the inequality relation.

**Proof.**
(i) is immediate by the fact that $\mathfrak{z}^d$ is a substructure of the canonical frame.

For (ii), the connectedness of $\mathfrak{z}^d$ implies that $\Gamma \neq \Delta \Rightarrow R^c_D\Gamma\Delta$. The fact that every d-theory contains a witness $p \land \underline{D}\neg p$ ensures that no element of $W^d$ is $R^d_D$-reflexive, so $R^d_D$ is contained in the inequality relation. $\square$

**Lemma 2.5.12.**

$$\mathfrak{M}^d \models \phi\ [w] \text{ iff } \phi \in w.$$

**Proof.**
By a formula induction, of which we only give the induction step for the modal operators:

Let $\phi$ be of the form $\Diamond\psi$.

First, suppose $\mathfrak{M}^d, w \models \phi$. We show that this implies the existence of a $v$ with $R^d_\Diamond wv$ and $\mathfrak{M}^d, v \models \psi$: for $\Diamond \in \{F, P\}$ this is immediate by lemma 2.5.7, for $\Diamond = D$ we also need lemma 2.5.11, namely the fact that $v$ is an $R^d_D$-successor of $w$ if $v \neq w$. By the induction hypothesis then, we get: there is a $v$ with $R^c_\Diamond wv$ and $\psi \in v$. So by definition of $R_\Diamond$ we get $\Diamond\psi \in w$.

For the other direction, suppose $\Diamond\psi \in w$. By Lemma 2.5.6 there is a $v$ with $R^d_\Diamond wv$ and $\psi \in v$. By the induction hypothesis $\mathfrak{M}^d, v \models \psi$. Again, for $\Diamond \in \{F, P\}$ this immediately implies $\mathfrak{M}^d, w \models \Diamond\psi$, for $\Diamond = D$ we need lemma 2.5.11 once more (now we use $R_D \subseteq\ \neq$).

In both cases we find the desired $\mathfrak{M}^d, w \models \phi$. $\square$

So it is left to prove that the underlying d-canonical frame is in $\mathrm{Fr}_\sigma$, or, equivalently, to show that $\mathfrak{z}^d, V \models \sigma$ for all valuations $V$. This is immediate by the following lemma and Theorem 2.3.3.

**Lemma 2.5.13.**
Any d-canonical general frame is discrete.

**Proof.**
Let $w$ be a d-theory or world in a d-canonical general frame $\mathfrak{G}^d = (\mathfrak{z}^d, A^d)$. Let $p$ be the propositional variable such that $Op \in w$, then by the truth lemma $w$ is the *only* d-theory of $\mathfrak{G}^d$ with $Op \in w$. So $\{w\} = V^d(Op) \in A^d$. $\square$

**Proof of theorem 2.5.1.**
Soundness is immediate.

For completeness, suppose $\Sigma \not\vdash \phi$, then $\Sigma \cup \{\neg\phi\}$ is consistent, so by lemma 2.5.6 there is a d-theory $\Sigma'$ with $\Sigma \cup \{\neg\phi\} \subseteq \Sigma'$.

Let $\mathfrak{M}^d = (\mathfrak{z}^d, V^d)$ be the d-canonical model with $\Sigma' \in W^d$. By lemma 2.5.13 and Theorem 2.3.3, $\mathfrak{z}^d \models \sigma$ and by the truth lemma, $\mathfrak{M}^d \models \psi$ for all $\psi \in \Sigma \cup \{\neg\phi\}$.

So we obtained $\Sigma \not\models_{\mathrm{Fr}^{t,\neq}_\sigma} \phi$. $\square$

---

## 2.6 Uni-directional Complications

In this section, which is not needed for understanding the sequel, we will see where our proof fails for a monadic similarity type $S$ which is not versatile. It suffices to take the case where we have only one diamond $F$ besides $D$. We would like to extend the results of the previous section to this case, but there seem to be two problems:

The first of these was already noted by Gabbay [31] and is also discussed in Gargov and Goranko [39].

The point is the following. In the previous section we saw that it is not sufficient to prove completeness by purging the canonical frame of $R_D$-reflexive points: their predecessors also needed to be thrown out, and the predecessors of those, ad infinitum. In our 'constructive' approach this problem arises in the following way: it is not sufficient to show that $Op \land \phi$ is consistent if $\phi$ is so, we must also prove that $\phi_0 \land \Diamond_1(Op \land \phi_1)$ is all right if $\phi_0 \land \Diamond_1 \phi_1$ is, etc. In the tense-logical situation, we can do this by changing our 'perspective' on the formula, namely by moving the $\phi_1$-position to the top level: we look at $\phi_1 \land \Diamond_1^{-1}\phi_0$ (which is consistent iff $\phi_0 \land \Diamond_1 \phi_1$ is so), then we insert $Op$, obtaining $(Op \land \phi_1) \land \Diamond_1^{-1}\phi_0$. Returning to the old 'perspective' we see that indeed $\phi_0 \land \Diamond_1(\phi_1 \land Op)$ is consistent. It will be clear that *tense operators* are indispensable instruments for this surgery.

We will now prove that it really goes wrong in the uni-directional case:

**Definition 2.6.1.**
Let $\rho$ be the formula $G(p \to Dp)$, $\rho'$ the formula $\rho \land F\top$. $\square$

Note that $\rho$ is a Sahlqvist formula (cf. the footnote to definition 2.2.1), its equivalent $\rho^{s'}$ is $\forall x \forall y(Rxy \to R_Dyy)$. So $\rho$ says: all $R$-successors are $R_D$-reflexive.

Recall that $K_FD^+\rho'$ is the axiom system with the following axioms:

- $(CT)$ all classical tautologies
- $(DB)$ $\Box(p \to q) \to (\Box p \to \Box q)$
- $(D1)$ $p \to \underline{D}Dp$
- $(D2)$ $DDp \to (p \lor Dp)$
- $(D3)$ $\Diamond p \to p \lor Dp$
- $(\rho')$ $\rho'$

Its derivation rules are $MP$, $UG$, $SUB$ and $IR_D$. If we had an analogon of theorem 2.5.1 for this logic, $K_FD^+\rho'$ should be inconsistent, for we have

**Proposition 2.6.2.**
$\mathrm{K}^{\neq}_{\rho'} = \emptyset$.

**Proof.**
It suffices to show that $\rho'$ only has non-standard frames. Assume $\mathfrak{z} \models \rho'$, where $\mathfrak{z} = (W, R, R_D)$ and $w$ is a world of $\mathfrak{z}$. By $\mathfrak{z}, w \models F\top$, $w$ has a successor $v$, by $\mathfrak{z} \models \rho^{s'}(w)$, $v$ is $R_D$-reflexive. But then $\mathfrak{z}$ is not standard. $\square$

But, $K_FD^+\rho'$ is *not* inconsistent, as we can easily show by considering non-standard frames again:

**Proposition 2.6.3.**
$K_FD^+(\rho') \not\vdash \bot$.

**Proof.**
We will define a $K_FD^+\rho'$-consistent set $\Delta$. Consider the following non-standard frame $\mathfrak{z} = (W, R, R_D)$:

$$\begin{aligned}
W &= \{w, v\} \\
R &= \{(w, v)\} \\
R_D &= \{(w, v), (v, w), (v, v)\},
\end{aligned}$$

and set $\Delta = \{\phi \mid \mathfrak{z}, w \models \phi\}$. Clearly then $\bot \notin \Delta$. We show that $\Delta$ contains the axioms of $K_FD^+\rho'$ and is closed under its rules. For the axioms, this is fairly trivial: for instance, $\rho'$ is in $\Delta$ as $\mathfrak{z} \models \forall y(Rxy \to R_Dyy)[w]$. Concerning the rules, the only thing worth treating is that $\Delta$ is closed under $IR_D$: but this is immediate by the fact that $w$ itself is $R_D$-irreflexive. $\square$

This problem is not difficult to mend: a close inspection of the completeness proof in the previous section reveals that the essential property that we need and which versatile logics automatically give us, is the *deep insertion property*

$(DIP) \qquad \vdash W(Op, m, \phi) \to \eta \ \Rightarrow\ \vdash \phi \to \eta$

$\text{for all } m \in \omega \text{ and } p \text{ not occurring in } \phi \text{ or } \eta.$

The idea is now to extend the definition of the irreflexivity rule so as to obtain a logic in which the extension lemma holds again:

**Definition 2.6.4.**
Define the following set of derivation rules:

$(IR^*_D) \qquad \vdash \neg W(Op, m, \psi) \ \Rightarrow\ \vdash \neg\psi$

$\text{for all } m \in \omega \text{ and } p \notin \psi.$

**Lemma 2.6.5.**
Let $\Lambda$ be a logic having $IR^*_D$. Then $\Lambda$ has DIP.

**Proof.**
By the following chain of consequences (where we assume that $p$ does not occur in $\phi$ or in $\eta$):

$$\begin{aligned}
&\vdash W(Op, m, \phi) \to \eta & \text{(assumption)} \\
\Rightarrow\quad &\vdash \neg(\neg\eta \land W(Op, m, \phi)) & \text{(proplog)} \\
\Rightarrow\quad &\vdash \neg W(Op, m + 1, \neg\eta \land \phi) & \text{(evaluation of } W) \\
\Rightarrow\quad &\vdash \neg(\neg\eta \land \phi) & (IR^*_D) \\
\Rightarrow\quad &\vdash \phi \to \eta & \text{(proplog)} \qquad \square
\end{aligned}$$

So for a similarity type where not all diamonds have converses, it is necessary to have $IR^*_D$ instead of $IR_D$. This was already noted by Gabbay [31] and by Gargov and Goranko [39], from which we derived the above example. It is not clear yet whether this extension is also *sufficient* to prove the analogon of the $SD$-theorem, at least if we want to consider axiom systems with *arbitrary* Sahlqvist axioms. For, there is another difference between the tense logical case and the unidirectional one.

This second problem seems to be more serious; assume that, analogous again to the previous section, we have constructed a d-canonical model $\mathfrak{M}^d$ for a MCS $\Sigma$. We want to prove $\mathfrak{z}^d \models \sigma$, where $\sigma$ is the Sahlqvist axiom added to the logic $K_SD^+$. In the tense logical case, we could do this, by using a special kind of valuations which we called *rudimentary*. We showed that for such a valuation $\mathfrak{z}^d, V \models \sigma$. This path however can only be taken if we have the converse diamond of $\mathfrak{z}$ in the language (cf. the proof of Lemma 2.3.10); in the uni-directional case, rudimentary valuations need not be *admissible*. It even turns out that not every d-canonical frame validates $\sigma$. We consider an example:

**Definition 2.6.6.**
Let $\gamma$ be the formula $\sigma = FGp \to GFp$. $\square$

We have already met $\gamma$ in section 2; its first order equivalent is the *Church-Rosser* formula

$$\gamma^s(x) = \forall y \forall z(Rxy \land Rxz \to \exists t(Ryt \land Rzt))$$

We will give a distinguishing theory $\Delta$ with $\mathfrak{z}^d \not\models \gamma^s(\Delta)$ for the d-canonical frame of $\Delta$.

**Definition 2.6.7.**
Consider the following standard frame $\mathfrak{z} = (W, R)$:

The set of possible worlds is given as $W = \{u, v, w\} \cup \{v_n, w_n, x_n \mid n \in \omega\}$.

The accessibility relation $R$ holds as follows: $Ruv$, $Ruw$, $Rvv_n$ and $Rww_n$, all $n$, $Rv_nx_0$ and $Rw_nx_0$, all $n$, and $Rx_n x_{n+1}$, all $n$, viz. the picture on the next page.

Finally, we define a model $\mathfrak{M}$ on $\mathfrak{z}$. Let the propositional variables of the language be named $p, q, r, p_0, p_1, p_2, \ldots$

The valuation $V$ is defined by

$$\begin{aligned}
V(p) &= \{u\} \quad V(q) = \{v\} \quad V(r) = \{w\} \\
V(p_{3n}) &= \{v_n\} \quad V(p_{3n+1}) = \{w_n\} \quad V(p_{3n+2}) = \{x_n\}. \qquad \square
\end{aligned}$$

**Lemma 2.6.8.**
$\mathfrak{M} \models \sigma\gamma$ for all substitutions $\sigma$.

**Proof.**
It is our aim to show that for all formulas $\phi$ and $t \in U$:

$$\mathfrak{M}, t \models FG\phi \to GF\phi$$

For $t \neq u$ this is immediate by $\mathfrak{z} \models \gamma^s(t)$.

For $t = u$, let $V_\phi = \{n \in \omega \mid \mathfrak{M}, v_n \models \phi\}$ and $W_\phi = \{n \in \omega \mid \mathfrak{M}, w_n \models \phi\}$.

By a straightforward induction to $\phi$ we can show:

> $V_\phi$ and $W_\phi$ are either both finite or both cofinite.

Now assume $\mathfrak{M}, u \models FG\phi$; without loss of generality we suppose that $\mathfrak{M}, v \models G\phi$. So $V_\phi$ contains *all* $v_n$, but then $V_\phi$ and $W_\phi$ are both infinite. This implies $\mathfrak{M}, w \models F\phi$. As we have $\mathfrak{M}, v \models F\phi$ too, we obtain $\mathfrak{M}, u \models GF\phi$. $\square$

**Definition 2.6.9.**
Let for $t \in W$, $\Delta_t$ be the set $\{\phi \mid \mathfrak{M}, t \models \phi\}$. $\square$

**Lemma 2.6.10.**
For every $t$ in $W$, $\Delta_t$ is distinguishing.

**Proof.**
By induction to $m$ we will prove:

> For all $t \in W$, $\phi \in \Delta_t$, there is a $p$ such that $W(Op, m, \phi) \in \Delta_t$.

For $m = 0$, let $t \in W$. By definition of the valuation $V$, there is a propositional variable $p_t$ such that $V(p_t) = \{t\}$. So $\mathfrak{M}, t \models Op_t$, giving $W(Op_t, 0, \phi) \in \Delta_t$.

For $m = k + 1$, let $t \in W$ and $\phi \in \Delta_t$. The only interesting case is where $\phi$ has the form $\psi \land \Diamond\chi$.

If $\mathfrak{M}, t \models \psi \land \Diamond\chi$, there is a $t'$ with $R_\Diamond tt'$ and $\mathfrak{M}, t' \models \chi$. By the induction hypothesis, there is a $p$ with $\mathfrak{M}, t' \models W(Op, k, \chi)$. But this means

$$\psi \land \Diamond W(Op, k, \chi) = W(Op, k + 1, \phi) \in \Delta_t. \qquad \square$$

**Lemma 2.6.11.**
Let $\mathfrak{z}^d$ be the d-canonical frame of $\Delta_u$. Then $\mathfrak{z}^d \not\models \gamma^s(\Delta_u)$.

**Proof.**
It is straightforward to verify that in $\mathfrak{M}^d$, $\Delta_v$ and $\Delta_w$ are $R_F$-successors of $\Delta_u$. Let $\Sigma$ be a maximal consistent $R^c_F$-successor of both $\Delta_v$ and $\Delta_w$. We can prove that such a $\Sigma$ cannot be distinguishing, by showing that for each propositional variable $s$

$$Gs \to s \in \Sigma.$$

For, if $s \in \{p, q, r\} \cup \{p_{3n+1}, p_{3n+2} \mid n \in \omega\}$, we have $G(Gs \to s)$ in $\Delta_v$, so by the truth lemma $\mathfrak{M}^d, \Delta_v \models G(Gs \to s)$, immediately giving the above claim. For $s \in \{p_{3n} \mid n \in \omega\}$ we can prove something similar, now using $\Delta_w$. $\square$

Note that in the situation above, we have an example of a Sahlqvist formula which is not persistent with respect to the class of discrete frames: let $\mathfrak{G} = (\mathfrak{z}, A)$ be the general frame with $\mathfrak{z}$ as defined in 2.6.7 and $X \in A$ if either $X$ or its complement is finite. Then $\mathfrak{G}$ is discrete, $\mathfrak{G} \models \gamma$, while $\mathfrak{z} \not\models \gamma$.

Sahlqvist *tense* formulas however are still persistent for discrete general frames. Note that for a uni-directional similarity type, atoms are the only strongly positive formulas, so the set of St-formulas is rather small. Still, for this restricted set we do have a completeness theorem:

**Definition 2.6.12.**
Let $S$ be an arbitrary similarity type of constants and diamonds. $K_SD^*$ is the basic $S$-logic extended with the set of rules $IR^*_D$. $\square$

**Theorem 2.6.13.**
Let $S$ be an arbitrary similarity type of constants and diamonds, and $\Sigma$ a set of Sahlqvist tense formulas. Then

$$K_SD^*\Sigma \text{ is strongly sound and complete for } \mathrm{K}^{\neq}_\Sigma.$$

**Proof.**
An copy of the proof in section 5, using lemma 2.6.5 instead of 2.5.4.

We conjecture that for any *individual* set of Sahlqvist axioms, the completeness like in Theorem 2.6.13 can be shown to hold, but we are doubtful whether there is a uniform proof (analogous to that of Theorem 2.5.1) taking care of all Sahlqvist axiomatizations at once. On the other hand, Goranko [45] announces a general *weak completeness proof*, for arbitrary canonical formulas.

---

## 2.7 The SD-theorem

There are some problems involved, mainly of a technical nature, in extending the completeness proof of the SD-theorem to languages having dyadic operators.

First of all we have to make clear what we mean by a Sahlqvist formula in a dyadic language. In fact, the definition and all the results in section 2 already apply to arbitrary similarity types. The following point is worth some discussion, however: in a similarity type with only diamonds and constants, we allow boxed atoms in the strongly positive formulas. A naive approach to define Sahlqvist triangle formulas would then be to allow duals of dyadic operators too. But de Rijke showed that the formula

$$(p\triangle p)\triangle p \to (p\triangle p)\triangle p$$

is *not acceptable* as a Sahlqvist formula, as it does not have a first order equivalent on the frame level. So for triangle similarity types, the atoms and negative formulas are the only admissible building blocks of Sahlqvist antecedents. This implies that for arbitrary similarity types, the difference between Sahlqvist *tense* formulas and ordinary Sahlqvist formulas is caused by the nature of the *diamonds* alone.

On the other hand, there is a difference between *versatile* (cf. Appendix A.40) triangle similarity types and uni-directional ones, analogous to the monadic case: if we consider a language and semantics which are not versatile, one irreflexivity rule is not sufficient, but we have to add infinitely many rules, allowing the building in of witnesses at all depths in a formula. To avoid these technical complications, we have to get familiar with the *versatile* logic of dyadic operators. Let us for the moment consider a similarity type consisting of three dyadic operators $\triangle_0$, $\triangle_1$ and $\triangle_2$. Frames for this similarity type have the form $\mathfrak{z} = (W, R_0, R_1, R_2)$, where $R_i$ is the ternary accessibility relation of $\triangle_i$. Recall that the truth definition of a dyadic operator gives

$$u \models \phi\triangle_i q \iff \text{there are } v, w \text{ with } R_iuvw, \ v \models \phi \text{ and } w \models \psi.$$

In the intended *versatile* semantics, the three $R_i$'s are 'directions' of one ternary relation $R$; as a standard we take $R = R_0$.

**Definition 2.7.1.**
A frame $\mathfrak{z} = (W, R_0, R_1, R_2)$ is a *versatile* frame if it satisfies the following conditions, for $i = 0, 1, 2$ (we write $2 + 1 = 0$):

$(Qi) \qquad R_i uvw \to R_{i+1}vwu$

The class of versatile frames is denoted by $\mathrm{Fr}^v$. $\square$

Analogous to the monadic case, $\mathrm{Fr}^v$ can be quite easily characterized and axiomatized:

**Definition 2.7.2.**
Define the following formulas, for $i = 0, 1, 2$:

$(Vi) \qquad p \land \neg(r\triangle_{i+1}p)\triangle_i r \to \bot,$

and set $V \equiv V1 \land V2 \land V3$.

Let $K^v_S$ be the versatile $S$-logic, i.e. the minimal $S$-logic $K_S$ extended with the axiom $V$. $\square$

Note that $Vi$ is a Sahlqvist formula: $p$ is strongly positive, $\neg(r\triangle_{i+1}p)$ is negative and $r$ is again strongly positive, so $p \land \neg(r\triangle_{i+1}p)\triangle_i r$ is untied, and as $\bot$ is positive, we are finished. This means that we immediately have the following:

**Theorem 2.7.3.**
For $i = 0, 1, 2$: $\mathfrak{z} \models Qi \iff \mathfrak{z} \models Vi$.

**Proof.**
The proposition is immediate by the Sahlqvist theorem, but we give a direct proof (taking $i = 0$):

($\Rightarrow$) Suppose that for some model $\mathfrak{M}$ on $\mathfrak{z}$, $\mathfrak{M}, u \models p \land \neg(r\triangle_1 p)\triangle_0 r$. By the truth definition of $\triangle_0$, there are $v, w$ with $R_0 uvw$, $v \models \neg(r\triangle_1 p)$, $w \models r$, while $u \models p$. $\mathfrak{z} \models Q0$ implies $R_1 vwu$, so by the truth definition of $\triangle_1$ we get $v \models r\triangle_1 p$ and find the desired contradiction.

($\Leftarrow$) Let $(u, v, w)$ be in $R_0$. We want to show $(v, w, u) \in R_1$. Suppose otherwise and consider a valuation $V$ with $V(p) = \{u\}$, $V(r) = \{w\}$. Then $v \models \neg(r\triangle_1 p)$, so $u \models \neg(r\triangle_1 p)\triangle_0 r$. By $\mathfrak{z} \models V_1$ we then have $u \models \neg p$, contradicting $V(p) = \{u\}$. $\square$

**Theorem 2.7.4: Soundness and Completeness.**
$K^v_S$ is strongly sound and complete with respect to the versatile $S$-frames.

**Proof.**
Immediate by the fact that the axioms are Sahlqvist formulas and 2.2.2. $\square$

**Corollary 2.7.5.**
The following deduction rule is a derived rule of $K^v_S$:

$$\vdash \neg(p \land q\triangle_i r) \iff \vdash \neg(q \land r\triangle_{i+1}p).$$

**Proof.**
By the observation that the rule is *sound* in the class of $S$-versatile frames. $\square$

Note that intuitively, $\mathfrak{M} \models \neg(p \land q\triangle_i r)$ denotes the impossibility of the existence of a triple $(u, v, w)$ in $R$ with $u \models p$, $v \models q$ and $w \models r$.

We can easily generalize this idea to operators of rank $\neq 2$. For example, for the monadic case we have

$$\vdash \neg(p \land \Diamond q) \iff \vdash \neg(q \land \Diamond^{-1}p)$$

as a derived rule of the minimal tense logic.

Now we are ready to add monadic tense operators, including the $D$-operator to the language.

**Definition 2.7.6.**
Let $S$ be a versatile similarity type having constants, monadic tense operators $\{\Diamond_i, \Diamond_i^{-1} \mid i < \alpha\}$ and dyadic operators $\{\triangle_0^j, \triangle_1^j, \triangle_2^j \mid j < \beta\}$.

The *versatile S-logic* $K^v_S$ is defined as the extension of the minimal $S$-logic $K_S$ with the tense axiom $CV$ for every diamond pair, and the versatility axiom $V$ for every triple of triangles. $\square$

**Theorem 2.7.7. THE SD-THEOREM.**
Let $S$ be a versatile similarity type containing $D$ and $\Sigma$ a set of Sahlqvist formulas. Then

$$K^t_S D^+ \Sigma \text{ is strongly sound and complete for } \mathrm{K}^{t,\neq}_\Sigma.$$

The remainder of this section will be devoted to the proof of this theorem. For notational simplicity, we assume that $S = \{D, F, P, \triangle_0, \triangle_1, \triangle_2\}$ and that $\Sigma$ is a singleton $\{\sigma\}$. From now on we abbreviate $K^t_S D^+(\sigma, -\xi)$ by $\Lambda$. Formulating the notions we defined in the monadic case causes some technical problems. The main idea is exactly the same, however:

**Definition 2.7.8.**
*Formula trees* and their *depth* are inductively defined as follows:

- (0) Formulas are formula trees of depth 0.
- (1) If $\psi$ is a formula, $\Diamond$ is a diamond and $t'$ is a formula tree of depth $n$, then $\langle(\psi, \Diamond), t'\rangle$ is a formula tree of depth $n + 1$.
- (2) If $\psi$ is a formula, $\triangle$ is a triangle and $t_0, t_1$ are formula trees of depths $n_0, n_1$, then $\langle(\psi, \triangle), t_0, t_1\rangle$ is a formula tree of depth $1 + \max(n_0, n_1)$.

For $t$ a formula tree, the formula $\Phi\mu(t)$ is given as

- (0) $\Phi\mu(\langle\phi\rangle) = \phi$
- (1) $\Phi\mu(\langle(\psi, \Diamond), t'\rangle) = \psi \land \Diamond\Phi\mu(t')$
- (2) $\Phi\mu(\langle(\psi, \triangle), t_0, t_1\rangle) = \psi \land \Phi\mu(t_0)\triangle\Phi\mu(t_1)$

For $\phi$ a formula, its *tree representation* $Tr(\phi)$ is the following formula tree:

- (at) $Tr(p) = \langle p \rangle$
- ($\neg$) $Tr(\neg\phi) = \langle\neg\phi\rangle$
- ($\land$) $Tr(\phi \land \psi) = \langle(\phi, \odot), Tr(\psi)\rangle$
- ($\Diamond$) $Tr(\Diamond\psi) = \langle(\top, \Diamond), Tr(\psi)\rangle$
- ($\triangle$) $Tr(\psi\triangle\chi) = \langle(\top, \triangle), Tr(\psi), Tr(\chi)\rangle$ $\square$

Analogous to the monadic case, we want to be able to place $\xi$-witnesses in *every* node of a tree. Different from the monadic case, nodes will now be named by sequences of 0's and 1's (think of going left or right.)

**Definition 2.7.9.**
Let $2^*$ be the set of sequences in the alphabet $\{0, 1\}$. Inductively $2^*$ can be defined by: (i) the empty sequence $\epsilon$ is in $2^*$, and (ii) if $s$ is in $2^*$, then so are $s * 0$ and $s * 1$.

Now let $\zeta$ be a formula, $s$ a sequence and $t$ a formula tree. We define $W(\zeta, s, t)$, the *tree* $t$ *witnessing* $\zeta$ *at node* $s$, by a nested induction to $s$ and $t$:

$$\begin{aligned}
W^t(\zeta, \epsilon, \langle\phi\rangle) &= \langle\zeta \land \phi\rangle \\
W^t(\zeta, \epsilon, \langle(\psi, \Diamond), t'\rangle) &= \langle(\zeta \land \psi, \Diamond), t'\rangle \\
W^t(\zeta, \epsilon, \langle(\psi, \triangle), t_0, t_1\rangle) &= \langle(\zeta \land \psi, \triangle), t_0, t_1\rangle \\
W^t(\zeta, s * i, \langle\phi\rangle) &= \langle\phi\rangle \\
W^t(\zeta, s * i, \langle(\psi, \Diamond), t'\rangle) &= \langle(\psi, \Diamond), W^t(\zeta, s, t')\rangle \\
W^t(\zeta, s * 0, \langle(\psi, \triangle), t_0, t_1\rangle) &= \langle(\psi, \triangle), W^t(\zeta, s, t_0), t_1\rangle \\
W^t(\zeta, s * 1, \langle(\psi, \triangle), t_0, t_1\rangle) &= \langle(\psi, \triangle), t_0, W^t(\zeta, s, t_1)\rangle
\end{aligned}$$

For $\zeta$ and $\phi$ formulas and $s$ a sequence, we set

$$W(\zeta, s, \phi) = \Phi\mu(W^t(\zeta, s, Tr(\phi))). \qquad \square$$

**Definition 2.7.10.**
A set of formulas $\Delta$ is *distinguishing* if it is maximal consistent, and for every $\phi$ in $\Delta$ and $s$ in $2^*$, there is a propositional variable $p$ with $W(Op, s, \phi) \in \Delta$. $\square$

**Lemma 2.7.11.**
If $Op$ has no letters in common with $\phi$ and $\eta$, then for all sequences $s$:

$$\vdash W(Op, s, \phi) \to \eta \ \Rightarrow\ \vdash \phi \to \eta.$$

**Proof.**
We prove the lemma by induction to the length of $s$:

If $s = \epsilon$, then $W(Op, s, \phi) = Op \land \phi$, so the proposition is immediate by $IR_D$:

$$\vdash (Op \land \phi) \to \eta \ \Rightarrow\ \vdash Op \to (\phi \to \eta) \ \Rightarrow\ \vdash \phi \to \eta.$$

If $s$ has a positive length, distinguish the following cases:

(1) $\phi$ is an atom or a negation. As this implies $W(Op, s, \phi) = \phi$, there is nothing to prove.

(2) If $\phi$ has the form $\Diamond\psi$ or $\psi \land \Diamond\chi$, we have a situation analogous to the monadic case, so for the proof we refer to 2.5.4.

(3) So the only interesting case is where $\phi$ has the form $\psi\triangle\chi$. Without loss of generality we may assume $s = s' * 0$ and $\triangle = \triangle_1$.

Abbreviate $W(Op, s * 0, \phi)$ by $\phi'$ and $W(Op, s, \psi)$ by $\psi'$, then $\phi' = \psi'\triangle_1\chi$.

The proof now goes as follows:

$$\begin{aligned}
&\vdash \phi' \to \eta & \text{(assumption)} \\
\Rightarrow\quad &\vdash \psi'\triangle_1\chi \to \eta & \text{(definition)} \\
\Rightarrow\quad &\vdash (\neg\eta \land \psi'\triangle_1\chi) \to \bot & \text{(propositional logic)} \\
\Rightarrow\quad &\vdash (\psi' \land \chi\triangle_2\neg\eta) \to \bot & \text{(Corollary 2.7.5.)} \\
\Rightarrow\quad &\vdash \psi' \to \neg(\chi\triangle_2\neg\eta) & \text{(propositional logic)} \\
\Rightarrow\quad &\vdash \psi \to \neg(\chi\triangle_2\neg\eta) & \text{(Induction Hypothesis)} \\
\Rightarrow\quad &\vdash (\psi \land \chi\triangle_2\neg\eta) \to \bot & \text{(propositional logic)} \\
\Rightarrow\quad &\vdash (\neg\eta \land \psi\triangle_1\chi) \to \bot & \text{(Corollary 2.7.5.)} \\
\Rightarrow\quad &\vdash \psi\triangle_1\chi \to \eta & \text{(propositional logic)} \\
\Rightarrow\quad &\vdash \phi \to \eta & \text{(definition)} \qquad \square
\end{aligned}$$

**Lemma 2.7.12.**
Every consistent set has a distinguishing extension.

**Proof.**
Analogous to lemma 2.5.6. $\square$

**Lemma 2.7.13.**
If $\Gamma$ is distinguishing and $\delta\triangle\pi \in \Gamma$, then there are d-theories $\Delta$ and $\Pi$ with $\delta \in \Delta$, $\pi \in \Pi$ and $R^c_\triangle\Gamma\Delta\Pi$.

**Proof.**
As $\delta\triangle\pi$ is in $\Gamma$, we have $(\delta \land Od)\triangle(\pi \land Op) \in \Gamma$ for some propositional variables $d$ and $p$.

Set

$$\begin{aligned}
\Delta &= \{\phi \mid (\phi \land Od)\triangle(Op) \in \Gamma\} \\
\Pi &= \{\psi \mid Od\triangle(\psi \land Op) \in \Gamma\}
\end{aligned}$$

The argument that $\Delta$ and $\Pi$ are maximal and consistent is just like in 2.5.7. To show that $R^c_\triangle\Gamma\Delta\Pi$, let $\phi \in \Delta$ and $\psi \in \Pi$; we have to prove that $\phi\triangle\psi \in \Gamma$.

As $(\phi \land Od)\triangle Op$ is in $\Gamma$, so is either $(\phi \land Od)\triangle(Op \land \psi)$ or $(\phi \land Od)\triangle(Op \land \neg\psi)$. If the latter were the case, then the formula $Od\triangle(Op \land \neg\psi)$ would be in $\Gamma$ too. But this would imply $\neg\psi$ in $\Pi$, contradicting the consistency of $\Pi$.

The proof that $\Delta$ and $\Pi$ are both distinguishing is again analogous to the monadic case. $\square$

**Definition 2.7.14.**
*Distinguishing canonical structures* are defined as in definition 2.5.10. $\square$

**Lemma 2.7.15.**
Let $\mathfrak{M}^d$ be a d-canonical model, $\Gamma$ a world in $\mathfrak{M}^d$. Then

$$\mathfrak{M}^d, \Gamma \models \phi \iff \phi \in \Gamma.$$

**Proof.**
By a formula induction, of which we only give the step for $\phi = \psi\triangle\chi$:

By the truth definition, $\mathfrak{M}^d, \Gamma \models \psi\triangle\chi$ implies that there are $\Delta, \Pi$ with $R^d\Gamma\Delta\Pi$ and $\mathfrak{M}^d, \Delta \models \psi$, $\mathfrak{M}^d, \Pi \models \chi$. By the induction hypothesis, $\psi$ is in $\Delta$ and $\chi$ is in $\Pi$, so by definition of $R^d$, $\psi\triangle\chi \in \Gamma$.

For the other direction, suppose $\psi\triangle\chi \in \Gamma$. By 2.7.13 there are $\Delta, \Pi$ with $R^c\Gamma\Delta\Pi$ and $\psi \in \Delta$, $\chi \in \Pi$. The induction hypothesis now gives $\mathfrak{M}^d, \Delta \models \psi$, $\mathfrak{M}^d, \Pi \models \chi$, so by the truth definition, $\mathfrak{M}^d, \Gamma \models \psi\triangle\chi$. $\square$

**Lemma 2.7.16.**
Let $\mathfrak{z}$ be a d-canonical frame. Then $\mathfrak{z}$ is in $\mathrm{Fr}^{v,\neq}_\sigma$.

**Proof.**
The proof for $\mathfrak{z}$ in $\mathrm{Fr}^{v,\neq}_\sigma$ is as in section 2.5. $\mathfrak{z}$ is versatile by the fact that $\mathfrak{z}$ is a substructure of the canonical versatile frame $\mathfrak{z}^c$ and the fact that the universal $L_S$-formula defining versatile frames is preserved under taking substructures. $\square$

**Proof of theorem 2.7.7.**
Exactly like the proof of theorem 2.5.1. $\square$

---

## 2.8 The SN$\Xi$-theorem

We are now ready to prove our main completeness theorem for a versatile logic having other non-$\xi$ rules besides $IR_D$.

**Definition 2.8.1.**
Let $S$ be a versatile similarity type containing the $D$-operator, $\Sigma$ a set of Sahlqvist formulas and $\Xi$ a set of arbitrary formulas. $K^v_S D^+(\Sigma, -\Xi)$ is the logic $K^v_S D^+$ extended with the axioms $\Sigma$ and the non-$\xi$ rules for all $\xi \in \Xi$. $\square$

Recall that the above definition implies that the *rules* of $K^v_SD^+(\Sigma, -\Xi)$ are $MP$, $UG$, $SUB$, $IR_D$ and $\{N\xi R \mid \xi \in \Xi\}$.

If the similarity type contains only constants and diamonds, then the system has the following *axioms*:

- $(CT)$ all classical tautologies
- $(DB)$ $\Box(p \to q) \to (\Box p \to \Box q)$
- $(CV)$ $\phi \to \Box\Diamond^{-1}p$
- $(D1)$ $p \to \underline{D}Dp$
- $(D2)$ $DDp \to (p \lor Dp)$
- $(D3)$ $\Diamond p \to p \lor Dp$
- $(\Sigma)$ $\Sigma$

If there are also triangles around, then the system has the versatility axiom $V$ too (cf. 2.7.2).

Note that the class $\mathrm{Fr}^{v,\neq}_{(\Sigma, -\Xi)}$ was defined as the class of standard versatile $S$-frames with

$$\begin{aligned}
\mathfrak{z} &\models \sigma \quad \text{for all } \sigma \text{ in } \Sigma \\
\mathfrak{z}, w &\not\models \xi \quad \text{for all } w \text{ in } \mathfrak{z}, \xi \text{ in } \Xi
\end{aligned}$$

If all $\xi$'s have local first order equivalents $\xi^f(x)$ on the frame level (for example, if every $\xi$ is a Sahlqvist formula too), then $\mathrm{Fr}^{v,\neq}_{(\Sigma, -\Xi)}$ is elementary, as we have

$$\mathfrak{z} \text{ in } \mathrm{Fr}_{-\xi} \iff \mathfrak{z} \models \forall x \neg \xi^f(x).$$

So, the theory below takes care of many classes of frames, for example the asymmetric or intransitive frames (cf. the characterizations given in the introduction).

**Theorem 2.8.2. SN$\Xi$-THEOREM.**
Let $S, \Sigma$ and $\Xi$ be as in definition 2.8.1. Then

$$K^v_SD^+(\Sigma, -\Xi) \text{ is strongly sound and complete for } \mathrm{Fr}^{v,\neq}_{(\Sigma, -\Xi)}.$$

The proof of Theorem 2.8.2 is in fact a straightforward adaptation of the proof in section 2.7. There we started with a MCS $\Delta$ and inserted in $\Delta$, for every $s \in 2^*$ and formula $\phi \in \Delta$, formulas $W(Op, s, \phi)$, in order to witness the $R_D$-irreflexivity of all worlds connected to $\Delta$. Here we will add more formulas (of the form $W(\neg\xi(p_1, \ldots, p_n), s, \phi)$), this time in order to ensure that the canonical-like general frame we end with is not only standard (with respect to $R_D$), but also in $\mathrm{Fr}_{-\Xi}$. So we set

**Definition 2.8.3.**
A set $\Delta$ of $S$-formulas is *witnessing* if it is distinguishing and satisfies that for all sequences $s \in 2^*$, formulas $\phi \in \Delta$ and $\xi \in \Xi$, there are propositional variables $p_1, \ldots, p_n$ with $W(\neg\xi(p_1, \ldots, p_n), s, \phi) \in \Delta$. $\square$

**Lemma 2.8.4.**
Every maximal consistent $\Delta$ has a witnessing extension $\Delta'$.

**Proof.**
An straightforward analogon of 2.7.12. $\square$

**Definition 2.8.5.**
A *w(itnessing)-canonical frame* is of the form $\mathfrak{z}^w = (W^w, R^w_\nabla)_{\nabla \in S}$ where $W^w$ is a $\sim_D$-connected set of witnessing theories and $R^w_\nabla$ is the canonical accessibility relation of $\nabla$, restricted to $W^w$. *Witnessing models* and *witnessing general frames* are also defined in the obvious way. For a w-theory $\Delta$, *the* w-canonical frame (model, etc.) of $\Delta$ is the w-canonical frame with $\Delta \in W^w$. If we want to make the set $\Xi$ explicit, we use the term *w-canonical structure witnessing against* $\Xi$. $\square$

**Lemma 2.8.6: Truth Lemma.**
Let $\mathfrak{M}^w$ be a w-canonical model, $\Delta$ a world of $\mathfrak{M}^w$. Then

$$\mathfrak{M}^w, \Delta \models \phi \iff \phi \in \Delta.$$

**Proof.**
In the same manner as in section 7, we prove that for every w-theory $\Delta$ and for every diamond $\Diamond$, triangle $\triangle$ we have

$$\begin{aligned}
\Diamond\phi \in \Delta &\iff \text{there is a w-theory } \Delta' \text{ with } (\Delta, \Delta') \in R^w_\Diamond \text{ and } \phi \in \Delta', \\
\phi_1\triangle\phi_2 \in \Delta &\iff \text{there are w-theories } \Delta_1, \Delta_2 \text{ with} \\
&\quad (\Delta, \Delta_1, \Delta_2) \in R^w_\triangle \text{ and } \phi_i \in \Delta_i.
\end{aligned}$$

As we can also show that $\mathfrak{z}^w$ is standard, the truth lemma follows by a straightforward formula induction. $\square$

**Lemma 2.8.7.**
Let $\mathfrak{G}^w = (\mathfrak{z}^w, A^w)$ be a w-canonical general versatile frame witnessing against $\Xi$. Then $\mathfrak{z}^w$ is in $\mathrm{Fr}^{v,\neq}_{-\Xi}$.

**Proof.**
Let $\Delta$ be a world of $\mathfrak{z}^w$. As $\Delta$ is a w-theory of the logic, we can find for every $\xi \in \Xi$ propositional variables $\vec{p}$ with $\neg\xi(\vec{p}) \in \Delta$. By the truth lemma then $\mathfrak{M}^w, u \models \neg\xi(\vec{p})$

So $\mathfrak{z}^w, \Delta \not\models \xi$, for all $\xi \in \Xi$. The proof that $\mathfrak{z}^w$ is standard and versatile just runs like in section 7. $\square$

**Proof of theorem 2.8.2.**
Soundness is already proved in the introduction to this chapter. For completeness, let $\Delta$ be a $K^v_SD^+(\Sigma, -\Xi)$-consistent set of formulas. By the extension lemma, $\Delta$ is contained in a w-theory $\Delta'$. Let $\mathfrak{M}^w$ be the w-canonical model of $\Delta'$. By the truth lemma,

$$\mathfrak{M}^w, \Delta' \models \phi \text{ for all } \phi \in \Delta'.$$

A (by now) standard argument shows that $\mathfrak{z}^w$ is versatile, so by lemma 2.8.7, $\mathfrak{z}^w$ is in $\mathrm{Fr}^{v,\neq}_{-\Xi}$. It is in $\mathrm{Fr}_\Sigma$ by the facts that $\mathfrak{G}^w$ is discrete (every w-theory is distinguishing!) and that $\mathfrak{G}^w \models \Sigma$. So we have satisfied $\Delta$ in a model based on a frame in the intended class $\mathrm{Fr}^{v,\neq}_{(\Sigma, -\Xi)}$. $\square$

Just like in section 6, we can prove a poorer version of Theorem 2.8.2 for arbitrary (not versatile) similarity types, but we leave this to the reader.

---

## 2.9 Conclusions, Remarks and Questions

### 2.9.1 General Conclusions

This chapter was a study in the semantics and axiomatics of non-$\xi$ rules, styled after Gabbay's (Generalized) Irreflexivity Rule.

On the semantic side, we defined $\mathrm{K}_{-\Xi}$ as the class of frames $\mathfrak{z}$ in K where no $\xi \in \Xi$ holds anywhere, i.e. for no $\xi \in \Xi$ is there a $w$ in $\mathfrak{z}$ with $\mathfrak{z}, w \models \xi$. In general, such a class will not be *definable* by a modal formula. Natural examples are formed by the irreflexive, asymmetric or transitive frames.

The main result of this chapter, the $SN\Xi$-theorem 2.8.2 states that under certain conditions, classes of the form $\mathrm{K}_{-\Xi}$ are *axiomatizable*, by a derivation system having a non-$\xi$ rule for every $\xi \in \Xi$. In the various sections of this chapter we have discussed these conditions.

The most elegant formulation of the $SN\Xi$-theorem is in the case where the similarity type is *versatile* and contains the $D$-operator. For such a similarity type, our result gives a nice derivation system for every class $\mathrm{K}_{-\Xi}$ where K is a class of $D$-standard, versatile frames which is characterized by a set of *Sahlqvist axioms*. For poorer similarity types, there are various options, of which we list a few:

- (i) If the similarity type is not versatile, we have to add a *schema* of non-$\xi$ rules (cf. sections 6 and 7).
- (ii) If not all diamonds are tense, only *Sahlqvist tense* formulas are allowed as axioms (cf. sections 5 and 6).
- (iii) If the similarity type $S$ does not contain the $D$-operator, the theorem does not apply directly.

Fortunately, this does not mean that the full power of the $SN\Xi$-theorem is lost for these poorer similarity types; one only has to work a bit harder for it. To give an example: in many cases, over the class $\mathrm{K}_{-\Xi}$ we can *define* the $D$-operator in the poorer formalism, so that we can work with this defined $D'$-operator. Each chapter of this thesis contains a worked out example of this idea.

So, more than a theorem, the $SN\Xi$-concept is a *procedure* to find axiomatizations for non-$\xi$ classes:

- (i) Find the proper characterization of the class (maybe in an extended similarity type).
- (ii) Apply the $SN\Xi$-theorem, immediately obtaining a strongly sound and complete derivation system.
- (iii) Try to simplify this system.

This schedule will be used throughout this dissertation.

It would be unfair not to mention the fact that axiomatizations using non-$\xi$ rules have some *disadvantages* too: first of all, such axiomatizations may not have all the nice mathematical properties that orthodox axiomatization have. For example (cf. Goldblatt [43]): define, for a logic $\Lambda$, the corresponding algebraic variety $\mathrm{V}_\Lambda$ of Boolean Algebras with Operators as the class of algebras where the set of equations $\{\phi = 1 \mid \Lambda \vdash \phi\}$ is valid. Now for a finite *orthodox* $\Lambda$, the complement of $\mathrm{V}_\Lambda$ will be closed under ultraproducts, while this need not be the case for an unorthodox $\Lambda$. Second, by the nature of the derivation rule, it may be necessary to add new propositional variables to the language in order to derive a formula $\phi$, whence we have *less control* on derivations in these unorthodox systems.

These disadvantages take us to the question, in which cases a non-$\xi$ rule can be *eliminated* from a system.

### 2.9.2 Conservativity

An interesting point which has not been discussed yet concerns the question whether non-$\xi$ rules add new theorems to a logic.

Some scattered results are known:

In the introduction we saw an example where a rule is *conservative*: the logic $K^t4$ already axiomatizes the class of irreflexive transitive tense frames, so adding $IR$ does not produce any new theorem.

On the other hand, adding $IR$ to $K^tL(Gp \to p)$ makes this logic inconsistent, so here $IR$ is not conservative. In Zanardo [141], Zanardo replaced the irreflexivity rule used in Burgess [23] to axiomatize a branching-time temporal logic, by (infinitely many) axioms. An similar case is found in cylindric modal logic and the modal logic of relation algebras (cf. Venema [131, 132]), where adding a non-$\xi$ rule to a finite set of axioms creates a finite derivation system for a logic which is known not to be finitely axiomatizable when only the orthodox derivation rules $MP$, $UG$ and $SUB$ are allowed. A striking difference between a uni-directional similarity type and its tense counterpart concerns the modal logic of the two-dimensional 'domino relation', where an axiomatization of the uni-directional modal logic needs *both* infinitely many axioms *and* a non-$\xi$ rule (cf. Kuhn [68]), while the tense logic allows a finite and orthodox axiomatization (cf. Venema [135]).

The general question

> Are there natural (syntactic/semantic) criteria deciding when a non-$\xi$ rule is conservative over a derivation system?

lies (almost) completely open. We have one minor result: recall that a formula is *closed* if it does not contain propositional variables (only constants).

**Definition 2.9.1.**
A logic $\Lambda$ has the *interpolation property* $(IP)$ if $\Lambda \vdash \phi \to \psi$ implies the existence of an *interpolant* $\chi$ in the common language of $\phi$ and $\psi$, such that $\Lambda \vdash \phi \to \chi$ and $\Lambda \vdash \chi \to \psi$. $\square$

**Proposition 2.9.2.**
Let $\Lambda$ be a logic and $\xi$ a formula, such that

- (i) $\Lambda$ has the $IP$.
- (ii) for every closed formula $\gamma$, $\Lambda(-\xi) \vdash \gamma$ implies $\Lambda \vdash \gamma$.

Then $N\xi R$ is conservative over $\Lambda$.

**Proof.**
Assume that $\Lambda$ and $\xi$ satisfy (i) and (ii). Denote derivability in $\Lambda$ by $\vdash$. To show that $N\xi R$ is conservative over $\Lambda$, we must prove

$$\vdash \neg\xi(\vec{p}) \to \phi \ \Rightarrow\ \vdash \phi, \text{ if no } p_i \text{ occurs in } \phi$$

So assume $\vdash \neg\xi(\vec{p}) \to \phi$ where $\vec{p} \notin \phi$. By (i) there is an interpolant $\gamma$ for $\neg\xi(\vec{p})$ and $\phi$; $\gamma$ must be closed, as $\neg(\vec{p})$ and $\phi$ do not share any variables. As $\vdash \neg\xi(\vec{p}) \to \gamma$, one application of $N\xi R$ shows that $\gamma$ is a $\Lambda(-\xi)$-theorem, so by (ii), $\vdash \gamma$. Now $\vdash \phi$ is immediate by $\vdash \gamma \to \phi$. $\square$

### 2.9.3 Questions and Remarks

We end this chapter with some miscellaneous questions and remarks:

- (i) The most obvious question is whether the $SN\Xi$-result can be extended to similarity types not having the $D$-operator or tense diamonds, and to arbitrary canonical formulas. Independently from our result, Goranko [45] announces a similar meta-theorem on *weak* completeness, for arbitrary canonical formulas. Hodkinson [35] extends our result to a similarity type where diamonds come in pairs too, here having *complementary* accessibility relations ($R_{-\Diamond} = (R_\Diamond)^c$).

- (ii) Call a class *negatively definable* if it is of the form $\mathrm{Fr}_{-\Xi}$. There seems to be an interesting connection between this notion and what Kracht calls *describable properties*, cf. [66]. Is there a *structural characterization* for negatively definable classes, like there is for modally definable classes? It is not difficult to see that negatively definable classes are closed under disjoint unions and generated subframes; any $\mathrm{Fr}_{-\Xi}$ *reflects* p-morphic images, and if it is elementary, ultrafilter extensions too. Do these preservation properties give the desired characterization for (elementary) negatively definable classes?

- (iii) Let $\Lambda$ be the set of formulas $\Theta(\mathrm{Fr}_{(\Sigma, -\Xi)})$, and $\mathrm{Fr}_\Lambda$ the class of frames where $\Lambda$ is valid. What is the relation between $\mathrm{Fr}_{(\Sigma, -\Xi)}$ and $\mathrm{Fr}_\Lambda$?

- (iv) Consider the tense similarity type with diamonds $\{F, P, D\}$. To axiomatize the irreflexive frames, we now have the choice between the $F$-irreflexivity rule and the *axiom* $Fp \to Dp$. When and how can rules be replaced by axioms, and vice versa?

- (v) An interesting aspect of non-$\xi$ rules is that in some sense they behave like axioms; in the introduction we already saw how they *characterize* the class $\mathrm{K}_{-\xi}$ where $N\xi R$ is *sound*. Maybe it is better to use the term *anti-axioms*$^7$, however, according to their behaviour in derivation systems: an orthodox derivation system $MD = (AX, \{MP, UG, SUB\})$ generates a logic, to be precisely, the *smallest* set of formulas $AX$ which is closed under $MP$, $UG$ and $SUB$. For the set $\Lambda$ of formulas generated by the axiom system $MD(-\xi) = (AX, \{MP, UG, SUB, N\xi R\})$, we may add the clause that $\Lambda$, if consistent, must also be the *least* set of formulas *not containing* the formula $\xi$ (to be more precisely, not containing $\xi$ in any 'existential position', like in $\Diamond(\delta \land \xi)$).

- (vi) In the following chapters we will see *examples* of applications of the $SN\Xi$-theorem in algebraic logic, but there is also a *general* perspective. Recall that in the theory of Boolean Algebras with Operators one is interested in representing algebras over sets, and defines *canonical extensions* for this aim. Now in fact, our 'constructive' way of defining distinguishing and witnessing theories, leading to the notion of distinguishing resp. witnessing canonical frames, constitutes a *new set representation of free algebras* over sets. In this new way of representing algebras, one seems to have *more control* on the properties of the frame than in the ordinary representation over ultrafilters. Obvious questions are to extend the construction to *arbitrary* algebras, and to investigate its (algebraic) properties.

---

$^1$In this sense the example is not representative: For $K^t4$, the irreflexivity rule is *conservative* (cf. section 7).

$^2$In fact, we may even consider the wider set of formulas obtained from (basic) Sahlqvist formulas by applying *duals* of existential modal operators.

$^3$An equivalent definition, which is perhaps more perspicuous from the algebraic point of view, is: a *Sahlqvist equation* is of the form $r = 0$, where $r$ is an *untied term*.

$^4$This important observation was made by Johan van Benthem, cf. section 3.3.5.

$^5$To be precise, we define a function from $S$-formulas to formulas in the extended similarity type with the dummy operator.

$^6$This restriction can easily be lifted.

$^7$This explains our notation '$-\xi$'
