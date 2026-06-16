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
