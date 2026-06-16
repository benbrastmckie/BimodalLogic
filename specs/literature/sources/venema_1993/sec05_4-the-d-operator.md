## 4 The $D$-operator

An important role in this paper is played by the so-called *difference* operator $D$. This operator is special in having the *inequality* relation as its intended accessibility relation:

**Definition 4.1** *Let $S$ be a similarity type containing the monadic modal operator $D$. An $S$-frame $\mathfrak{F} = (W, R_\nabla)_{\nabla \in S}$ is called $(D$-)standard if*

$$R_D = \{(s,t) \in {}^2W \mid s \ne t\}.$$

*As abbreviations we use $\underline{D}\phi \equiv \neg D\neg\phi$, $O\phi \equiv \phi \wedge \underline{D}\neg\phi$, $E\phi \equiv \phi \vee D\phi$.*
*For $\mathsf{K}$ a class of $S$-frames, we denote the class of standard frames in $\mathsf{K}$ by $\mathsf{K}^\ne$.*

When referring to standard frames, we will suppress mentioning the inequality relation $R_D$. Thus we may identify standard frames for $S$ with the frames for the similarity type obtained by dropping $D$ from $S$. In the sequel we will frequently omit the adjective 'standard' when referring to the intended semantics, explicitly using the term 'non-standard' for the frames with $R_D \ne \{(s,t) \in {}^2W \mid s \ne t\}$. Note that in a standard model we have

- $\mathfrak{M}, w \models D\phi$ &emsp; iff &emsp; there is a $v \ne w$ with $\mathfrak{M}, v \models \phi$,
- $\mathfrak{M}, w \models O\phi$ &emsp; iff &emsp; $w$ is the *only* world with $\mathfrak{M}, w \models \phi$,
- $\mathfrak{M}, w \models E\phi$ &emsp; iff &emsp; there is a world $v$ with $\mathfrak{M}, v \models \phi$.

In many examples the $D$-operator is *definable* in the poorer language; for example, over the class $\mathsf{LI}$ of irreflexive linear orderings we have

$$\mathsf{LI} \models D\phi \leftrightarrow (F\phi \vee P\phi).$$

The $D$-operator was introduced independently by various authors, including, in (probably) chronological order: Sain [32, 33], Koymans [20] and Gargov-Passy-Tinchev [13]. A nice feature of this new operator, and the main reason for its introduction, is the fact that it greatly increases the expressive power of the language. For example, *irreflexivity* is easily seen to be characterized by the formula $\Diamond p \to Dp$. Maarten de Rijke proved many results on the expressiveness and completeness of modal and tense logics having a $D$-operator, cf. [28]. We only need the following:

**Definition 4.2** *Let $S$ be a similarity type containing $D$. For $\Lambda$ an $S$-logic, $\Lambda D$ denotes the logic $\Lambda$ extended with the following axioms:*

- $(D1)$ &emsp; $p \to \underline{D}Dp$
- $(D2)$ &emsp; $DDp \to (p \vee Dp)$
- $(D3_\nabla)$ &emsp; $\nabla(p_1, \ldots, p_n) \to \bigwedge Ep_i$.

*$\Lambda D^+$ is the logic $\Lambda D$ extended with the irreflexivity rule for $D$:*

$(IR_D) \qquad \vdash Op \to \phi \ \Rightarrow \ \vdash \phi, \text{ if } p \notin \phi.$

*Instead of $K_{\{D\}}$ (the minimal $D$-logic), we write $K_D$, instead of $K_D D$: $KD$.*

Note that the rule $IR_D$ is an example of a non-$\xi$ rule.

**Theorem 4.3** *For any similarity type $S$, both $K_S D$ and $K_S D^+$ are strongly sound and complete with respect to the class of standard $S$-frames.*

**Proof.**
Cf. de Rijke [28]. $\square$

As a corollary of this completeness theorem some nice semantic properties of the operators are also *provable*:

**Lemma 4.4** *Let $S$ be a similarity type containing the $D$-operator and $\nabla$. Then*
**(i)** &emsp; $KD^{(+)} \vdash E(Op \wedge \phi) \wedge E(Op \wedge \neg\phi) \to \bot$.
**(ii)** &emsp; $K_S D^{(+)} \vdash (\nabla(\ldots, Op \wedge \phi, \ldots) \wedge \nabla(\ldots, Op \wedge \neg\phi, \ldots)) \to \bot$.
**(iii)** &emsp; $K_S D^{(+)} \vdash \bigwedge_i \nabla(\ldots, Op \wedge \phi_i, \ldots) \to \nabla(\ldots, Op \wedge \bigwedge_i \phi_i, \ldots)$.

**Proof.**
By showing that the above schemes of formulas are semantically *valid* in standard frames, and then using the completeness theorem for $KD^{(+)}$. $\square$

*Combining* the notions of Sahlqvist (tense) formulas and the $D$-operator, we seem to have two options. Because of the general result on Sahlqvist correspondence, we know that every Sahlqvist formula $\sigma$ has a local correspondent $\sigma^{s'}(x_0)$ in the language $L_S$ where $R_D$ is the symbol for the accessibility relation of $D$. However, we are almost exclusively interested in the way this equivalence works out for the *standard* $S$-frames; this means that we will only consider interpretations where $R_D$ is the inequality relation. It is then very natural to let this preference be reflected in the syntax, by a slight abuse of notation:

**Definition 4.5** *Let $S$ be a similarity type and $\sigma$ a Sahlqvist formula. If $S$ does not contain the $D$-operator, $\sigma^s(x_0)$ denotes the ordinary first order Sahlqvist equivalent of $\sigma$ given in Definition 3.15. If $S$ does contain $D$, $\sigma^{s'}(x_0)$ denotes this ordinary first order equivalent, $\sigma^s(x_0)$ is $\sigma^{s'}(x_0)$ with every occurrence of $R_D$ replaced by $\ne$.*

As an example, the Sahlqvist correspondent of $\Diamond p \to Dp$ is not $\forall x_1(Rx_0 x_1 \to R_D x_0 x_1)$, but $\forall x_1(Rx_0 x_1 \to x_0 \ne x_1)$, (or even better: $\neg Rx_0 x_0$.) With this notation we have equivalence of $\sigma$ and $\sigma^s$ for the standard frames:

**Theorem 4.6** *Let $\sigma$ be a Sahlqvist formula, $w$ a world in a standard frame $\mathfrak{F}$. Then*

$$\mathfrak{F}, w \models \sigma \iff \mathfrak{F} \models \sigma^s(w_0).$$

**Proof.**
Straightforward by Theorem 3.2 and the definitions of $\sigma^s$ and standard frames. $\square$

However, by restricting our attention to standard frames we lose the automatic completeness of Sahlqvist's theorem: where we do have, for a set of Sahlqvist axioms $\Sigma$,

> $K_S D\Sigma$ is strongly sound and complete w.r.t. $\mathsf{Fr}_\Sigma$,

we are not (yet) sure whether

> $K_S D^+\Sigma$ is strongly sound and complete w.r.t. $\mathsf{Fr}_\Sigma^\ne$.

In the next section we will prove the above statement, for Sahlqvist *tense* axioms.

---
