## 5 The main proof

This subsection contains the main idea on the proof of the Sahlqvist theorem in a context with non-$\xi$ rules. To keep notation as simple as possible, we consider a tense similarity type $S$ having besides the difference operator $D$ only one pair $\{F, P\}$ of tense operators. We let $\Diamond$ range over the monadic modal operators, $\Box$ is the dual of $\Diamond$, and $\Diamond^{-1}$ is the converse of $\Diamond$, i.e. $F^{-1} = P$, $P^{-1} = F$ and $D^{-1} = D$. Note that for this similarity type there is no distinction between ordinary Sahlqvist formulas and Sahlqvist tense formulas. We intend to prove the following theorem, keeping some generalizations and corollaries for later subsections.

**Theorem 5.1** *(SD-THEOREM --- monadic operators)*
*Let $S$ be a tense similarity type with three diamonds $F$, $P$ and $D$, and let $\sigma$ be a Sahlqvist formula. Then $K^t D^+\sigma$ is strongly sound and complete with respect to $\mathsf{Fr}_{\sigma}^{t,\ne}$.*

Recall that $K^t D^+\sigma$ has the following axioms:

- $(CT)$ &emsp; all classical tautologies
- $(DB)$ &emsp; $\Box(p \to q) \to (\Box p \to \Box q)$
- $(CV)$ &emsp; $p \to HFp$
- $(D1)$ &emsp; $p \to \underline{D}Dp$
- $(D2)$ &emsp; $DDp \to (p \vee Dp)$
- $(D3)$ &emsp; $\Diamond p \to p \vee Dp$
- $(\sigma)$ &emsp; $\sigma$

Its derivation rules are

- $(MP)$ &emsp; Modus Ponens
- $(UG)$ &emsp; Universal Generalization
- $(SUB)$ &emsp; Substitution

and the irreflexivity rule for $D$:

$(IR_D) \qquad \vdash Op \to \phi \ \Rightarrow \ \vdash \phi, \text{ if } p \notin \phi.$

Note that the above theorem is not an automatic corollary of the ordinary Sahlqvist theorem, because of the special interpretation for the accessibility relation of $D$ that we have in mind, namely the inequality relation. A proof of Theorem 5.1 via the ordinary canonical model-method seems to be impossible, as the $K^t D^+\sigma$-canonical frame need not be standard.

As an example, let $\sigma$ express $S5$-behaviour of $F$, and consider a $D$-standard model $\mathfrak{M} = (W, R_F, V)$ with total $R_F$ and two worlds $w, w'$ verifying the same atoms. We easily show that $\mathfrak{M}, w \models \phi \to D\phi$ for all formulas $\phi$. So the set $\Delta = \{\psi | \mathfrak{M}, w \models \psi\}$, being a maximal consistent set and thus a world of the $K^t D^+\sigma$-canonical frame, must be $R_D$-reflexive.

So it turns out that the canonical frame is bad because it may contain $R_D$-reflexive worlds. A naive approach to this problem is to simply throw them out of the canonical universe. This is not sufficient however: consider the set

$$\{p_0 \wedge \underline{D}\neg p_0\} \cup \{F\top\} \cup \{G(\phi \to D\phi) \mid \phi \text{ a formula}\}.$$

Without too many problems, we can again find a $\sigma$ for which this set is $K^t D^+\sigma$-consistent, so it has a maximal consistent extension $\Delta \in W^c$. $\Delta$ itself is not $R_D$-reflexive, but all of its $R_F$-successors are. So $\Delta$, having at least one $R_F$-successor, is an unwelcome inhabitant of the canonical frame too.

Now instead of successively throwing bad MCSs out of the canonical frame, we feel it is better to follow a more constructive path, defining a canonical-like model consisting only of good MCSs. To give this notion of a 'good' MCS, we need some auxiliary definitions, the intuition behind which is the following: suppose we have a MCS $\Gamma$ with a formula $\phi$ of the form

$$\phi_0 \wedge \Diamond_1(\phi_1 \wedge \ldots \Diamond_{n-1}(\phi_{n-1} \wedge \Diamond_n \phi_n)),$$

in $\Gamma$. In the canonical model, we have the existence of the path $\Gamma = \Gamma_0 R_{\Diamond_1} \Gamma_1 \ldots R_{\Diamond_n} \Gamma_n$ such that every $\phi_i \in \Gamma_i$. In our version of the canonical model, we want an additional condition to be satisfied, viz. each $\Gamma_i$ should be $R_D$-irreflexive. The idea is now to envisage this already in $\Gamma$, by demanding that in $\phi$, we can put 'next to' each $\phi_i$, a formula $Op_i$ witnessing this $R_D$-irreflexivity.

**Definition 5.2** *We denote the relation '$\psi$ is a subformula of $\phi$' by $\psi \unlhd \phi$. Assume that we do not identify different occurrences of $\psi$ in $\phi$ (for instance, $\phi$ has two distinct occurrences in $\phi \wedge \phi$.) For notational elegance, instead of $\vee$ we take $\wedge$ as our basic boolean connective.*

Now let $\phi, \psi, \chi$ be formulas such that $\psi \unlhd \phi$. We define $W(\chi, \psi, \phi)$ ('$\phi$ with $\chi$ witnessing at $\psi$') by induction on the structure of $\phi$ above $\psi$ --- i.e., $\psi$ is treated as atomic in $\phi$.

$$W(\chi, \psi, q) = q \quad (\text{provided } \psi \ne q)$$
$$W(\chi, \psi, \psi) = \chi \wedge \psi$$
$$W(\chi, \psi, \neg\phi) = \neg\phi$$
$$W(\chi, \psi, \phi \wedge \phi') = W(\chi, \psi, \phi) \wedge W(\chi, \psi, \phi')$$
$$W(\chi, \psi, \Diamond\phi) = \Diamond W(\chi, \psi, \phi)$$

A maximal consistent set $\Sigma$ is *distinguishing*, or a *d-theory* if for every $\phi$ in $\Sigma$ and every $\psi \unlhd \phi$, there is a propositional variable $p$ with $W(Op, \psi, \phi)$ in $\Sigma$.

Note that as d-theories are MCSs, the canonical accessibility relations $R_F^c$, $R_P^c$ and $R_D^c$ for $F$, $P$ and $D$ have the ordinary meaning:

$$R_\Diamond^c \Sigma \Delta \text{ iff for all } \phi \in \Delta, \ \Diamond\phi \in \Sigma$$

We want to take the d-theories as the possible worlds in our version of the canonical model, the definition ensuring that any d-theory is $R_D$-irreflexive. A minimal constraint which a canonical-ish model must meet is that every consistent set of formulas is somehow to be found as (part of) a possible world. In our setting this means that every consistent set must have a distinguishing extension.

First we need a lemma of a rather technical nature:

**Lemma 5.3** *If $p$ does not occur in $\phi$ or $\eta$, then for any $\psi \unlhd \phi$ we have $\vdash W(Op, \psi, \phi) \to \eta \Rightarrow \vdash \phi \to \eta$.*

**Proof.**
By induction to the structure of $\phi$ above $\psi$.

In the case where $\phi = \psi$, we find $W(Op, \psi, \phi) = Op \wedge \phi$, so we get $\vdash (Op \wedge \phi) \to \eta \Rightarrow \vdash Op \to (\phi \to \eta)$ $\Rightarrow \vdash \phi \to \eta$, where the last step is by one application of $IR_D$.

The induction steps for the Boolean cases we leave to the reader, concentrating on the case where $\phi$ is of the form $\Diamond\phi'$. Note that $W(Op, \psi, \phi) = \Diamond W(Op, \psi, \phi')$. The claim is proved by

$$\Rightarrow \quad \vdash \Diamond W(Op, \psi, \phi')) \to \eta \qquad \text{(assumption)}$$
$$\Rightarrow \quad \vdash W(Op, \psi, \phi') \to \Box^{-1}\eta \qquad \text{(tense logic)}$$
$$\Rightarrow \quad \vdash \phi' \to \Box^{-1}\eta \qquad \text{(induction hypothesis)}$$
$$\Rightarrow \quad \vdash \Diamond\phi' \to \eta \qquad \text{(tense logic)}$$

and we are finished. $\square$

The following propositions form our version of Gabbay's generalized Irreflexivity Lemma (cf. [10]):

**Lemma 5.4** *(Extension Lemma)*
*Let $\Sigma$ be a consistent set in which the variable $p$ does not occur, and $\phi \in \Sigma$. Then $\Sigma \cup \{W(Op, \psi, \phi)\}$ is consistent for all $\psi \unlhd \phi$.*

**Proof.**
Suppose otherwise, then $\vdash W(Op, \psi, \phi) \to \neg\chi$ for some $\psi \unlhd \phi$ and $\chi = \chi_0 \wedge \ldots \wedge \chi_n$, all $\chi_i \in \Sigma$. By lemma 5.3 this would imply $\vdash \phi \to \neg\chi$, contradicting the consistency of $\Sigma$. $\square$

**Lemma 5.5** *If $\Sigma$ is a consistent set, then there is a distinguishing $\Sigma'$ containing $\Sigma$.*

**Proof.**
Let $Q$ be the set of propositional variables in $\Sigma$, assume that $Q$ is countable[^5] and let $p_0, p_1, \ldots$ be mutually distinct propositional variables not in $Q$; set, for $0 \le \xi \le \omega$, $Q_\xi = Q \cup \{p_i \mid i < \xi\}$.

[^5]: This restriction can easily be lifted.

For a set $\Delta$ of formulas in $Q_\omega$, let $PV(\Delta)$ be the set of propositional variables appearing in (formulas of) $\Delta$. A theory $\Delta$ is called an *approximation* if $\Delta$ is consistent, $\Sigma \subseteq \Delta$ and $PV(\Delta) = Q_n$ for some $n < \omega$. In this case $p_n$ is called the *new variable* for $\Delta$ and denoted by $p_\Delta$.

Now let $\Delta$ be an approximation and $(\phi, \psi)$ a *potential shortcoming*, i.e. $\phi$ is a formula in $Q_\omega$ and $\psi \unlhd \phi$. The pair $(\phi, \psi)$ is called a *shortcoming* of $\Delta$ if $\phi \in \Delta$ while no witness $W(Op, \psi, \phi)$ is in $\Delta$. Assume that we have an enumeration $\mathcal{W}$ of the set of potential shortcomings. If $\Delta$ has shortcomings, let $(\phi^\Delta, \psi^\Delta)$ be the first (in $\mathcal{W}$) of $\Delta$'s shortcomings. Now set

$$\Delta^+ = \begin{cases} \Delta & \text{if } \Delta \text{ has no shortcomings} \\ \Delta \cup \{W(Op_\Delta, \psi^\Delta, \phi^\Delta)\} & \text{otherwise} \end{cases}$$

We claim that if $\Delta$ is an approximation, then so is $\Delta^+$:
$\Delta^+$ is consistent by lemma 5.4; the other conditions are straightforward.

We now define the following sequence of theories $\Sigma_0, \Sigma_1, \ldots$; let $\phi_0, \phi_1, \ldots$ be an enumeration of all $Q_\omega$-formulas.

$$\Sigma_0 = \Sigma$$
$$\Sigma_{2n+1} = \begin{cases} \Sigma_{2n} \cup \{\phi_n\} & \text{if } \Sigma_{2n+1} \cup \{\phi_n\} \text{ is consistent} \\ \Sigma_{2n} \cup \{\neg\phi_n\} & \text{otherwise} \end{cases}$$
$$\Sigma_{2n+2} = \begin{cases} (\Sigma_{2n+1})^+ & \text{if } \Sigma_{2n+1} \text{ has shortcomings} \\ \Sigma_{2n+1} & \text{otherwise} \end{cases}$$

and set $\Sigma' = \bigcup_{n < \omega} \Sigma_n$.

It is then straightforward to prove that (1) $(\Sigma_n)_{n < \omega}$ is an increasing sequence, (2) every $\Sigma_n$ is an approximation, (3) for every $Q_\omega$-formula $\phi$, either $\phi$ or $\neg\phi$ is in $\Sigma'$, and (4) for every $Q_\omega$-formula $\phi$ and $\psi \unlhd \phi$, there is a witness $W(Op, \psi, \phi)$ in $\Sigma'$.

This gives all the desired properties of $\Sigma'$. $\square$

The fact that any consistent set is contained in a d-theory, means that in a certain sense there are *enough* distinguishing sets. Note however, that we needed to extend the language to prove lemma 5.5. This could mean that problems might arise if we want to show that every d-theory $\Gamma$ containing a formula $\Diamond\phi$ has a distinguishing $\Diamond$-successor $\Delta$ with $\phi \in \Delta$. For, in context of ordinary maximal consistent sets, this proposition is proved by showing that the set

$$\{\phi\} \cup \{\psi \mid \Box\psi \in \Gamma\}$$

has a maximal consistent extension. We might do the same here, but then we have to show that this set has a distinguishing extension *in the same proposition letters*. We choose a different proof, using the fact that because the language has the $O$-operator, the distinguishing theory $\Gamma$ contains a complete description of $\Delta$:

**Lemma 5.6** *If $\Gamma$ is a d-theory and $\Diamond\phi \in \Gamma$, then there is a d-theory $\Delta$ with $\phi \in \Delta$ and $R_\Diamond^c \Gamma \Delta$.*

**Proof.**
As $\Diamond\phi$ is in $\Gamma$, so is $\Diamond(\phi \wedge Op)$ for some atom $p$. Let $\Delta$ be the set $\{\psi \mid \Diamond(Op \wedge \psi) \in \Gamma\}$. $\Delta$ is consistent, for assume otherwise, then there are $\psi_1, \ldots, \psi_n$ in $\Delta$ with every $\Diamond(Op \wedge \psi_i)$ in $\Gamma$ and

$$\vdash (\bigwedge_i \psi_i) \to \bot$$

By lemma 4.4 we have

$$\vdash \bigwedge_i (\Diamond(Op \wedge \psi_i)) \to \Diamond(Op \wedge \bigwedge_i \psi_i)$$

So $\Diamond(Op \wedge \bigwedge_i \psi_i)$ and hence $\Diamond\bot$ is in $\Gamma$, contradicting its consistency.

As $\Diamond Op \in \Gamma$, for every $\psi$ either $\Diamond(Op \wedge \psi)$ or $\Diamond(Op \wedge \neg\psi)$ is in $\Gamma$, so clearly $\Delta$ is maximal. The fact that $R_\Diamond^c \Gamma \Delta$ is immediate by definition of $\Delta$.

To prove that $\Delta$ is distinguishing, let $\psi \in \Delta$, and $\chi \unlhd \psi$. We have to show that for some $q$, $W(Oq, \chi, \psi)$ is in $\Delta$:

By definition of $\Delta$, $\Diamond(Op \wedge \psi) \in \Gamma$. As $\Gamma$ is distinguishing, by definition there is a $q$ with $W(Oq, \chi, \Diamond(Op \wedge \psi))$ is in $\Gamma$, whence $W(Oq, \psi, \chi) \in \Delta$. $\square$

These two lemmas are sufficient to establish that there are *enough* d-theories. There is still one difference with the ordinary case which we need to discuss: suppose we would take the set of *all* distinguishing sets to form the universe of our canonical model. Then there would be *too many* worlds, for consider two $D$-theories $\Delta, \Delta'$ with $p \wedge \underline{D}\neg p \in \Delta$, $p \wedge \underline{D}p \in \Delta'$. If both were to be in our 'canonical' model, the underlying frame would be non-standard, for $\Delta'$ is not an $R_D$-successor of $\Delta$, while clearly $\Delta \ne \Delta'$. This inspires the following definition:

**Definition 5.7** *Two distinguishing theories $\Gamma$ and $\Delta$ are* connected, *notation: $\Gamma \sim_D \Delta$, if either $\Gamma = \Delta$ or $R_D^c \Gamma \Delta$. A set of d-theories is* connected *if all pairs of its members are.*

**Lemma 5.8** *$\sim_D$ is an equivalence relation.*

**Proof.**
Reflexivity of $\sim_D$ is immediate.
For symmetry, let $\Gamma \sim_D \Delta$. If $\Gamma = \Delta$, we are finished. If not, we have $R_D^c \Gamma \Delta$. Now $R_D^c$ is a symmetric relation (this is an immediate consequence of having the Sahlqvist axiom $D1$ in the logic). So we have $R_D^c \Delta \Gamma$, implying $\Delta \sim_D \Gamma$.
For transitivity of $\sim_D$, it suffices to show that $R_D^c$ is *pseudo-transitive*:

$$\forall x \forall y \forall z ((xRy \wedge yRz) \to (x = z \vee xRz))$$

But this is immediate by the fact that pseudo-transitivity is the Sahlqvist correspondent of axiom $D2$, and the completeness part of Sahlqvist's theorem. $\square$

**Definition 5.9** *A* d(istinguishing)-canonical frame *is of the form $\mathfrak{F}^d = (W^d, R_F^d, R_P^d, R_D^d)$ where $W^d$ is a connected set of distinguishing theories, and the $R^d$'s are the $R^c$'s restricted to $W^d$.*
*Define also* d-canonical models $\mathfrak{M}^d = (\mathfrak{F}^d, V^d)$ *and* d-canonical general frames $\mathfrak{G}^d = (\mathfrak{F}^d, A^d)$, *where $V^d$ is $V^c$ restricted to $W^d$ and $A$ is given by $X \in A^d$ iff $X = V^d(\phi)$ for some $\phi$.*

In the sequel we will have a particular d-canonical model, frame, etc. in mind, viz. the one consisting of all worlds connected to a fixed d-theory $\Sigma$. Therefore, we will frequently speak about *the* d-canonical model, frame, etc.

We need several nice properties of the d-canonical model. The easiest to establish is the truth lemma, via the fact that the d-canonical frame is a tense frame and standard:

**Lemma 5.10** *Let $\mathfrak{F}^d$ be a d-canonical frame, then*
**(i)** *$R_F^d$ and $R_P^d$ are each others converse.*
**(ii)** *$R_D^d$ is the inequality relation.*

**Proof.**
(i) is immediate by the fact that $\mathfrak{F}^d$ is a substructure of the canonical frame.
For (ii), the connectedness of $\mathfrak{F}^d$ implies that $\Gamma \ne \Delta \Rightarrow R_D^d \Gamma \Delta$. The fact that every d-theory contains a witness $p \wedge \underline{D}\neg p$ ensures that no element of $W^d$ is $R_D^d$-reflexive, so $R_D^d$ is contained in the inequality relation. $\square$

**Lemma 5.11** *(TRUTH LEMMA) For all d-canonical models $\mathfrak{M}^d$ and all $w \in \mathfrak{M}^d$:*

$$\mathfrak{M}^d, w \models \phi \quad \text{iff} \quad \phi \in w.$$

**Proof.**
By a formula induction, of which we only give the induction step for the modal operators.

First, let $\phi$ be of the form $F\psi$. By the truth definition, $\mathfrak{M}^d, w \models F\psi$ implies the existence of a $v$ with $R_D^d wv$ and $\mathfrak{F}^d, v \models \psi$. By the induction hypothesis, this gives $\psi \in v$, so by definition of $R_F^d$, $F\psi$ is in $w$. Conversely, by lemma 5.6 $F\psi \in w$ implies the existence of a distinguishing $v$ with $R_F^d wv$ and $\psi \in v$. By axiom $D3$, $R_F^d wv$ gives $R_D wv$ or $w = v$, so $v$ is a world of $\mathfrak{M}^d$. (Note that this is the only place in the proof where we need axiom $D3$.) The induction hypothesis yields that $\mathfrak{M}^d, v \models \psi$, so indeed we obtain $\mathfrak{M}^d, w \models F\psi$.

The proof for $\phi$ of the form $P\psi$ is exactly the same; for $\phi$ of the form $D\psi$ the above procedure gives $D\psi \in w$ iff there is a $v$ with $R_D^d wv$ and $\mathfrak{M}^d, v \models \psi$. This is sufficient, as $R_D$ is identical to the inequality relation by the previous lemma. $\square$

So it is left to prove that the underlying d-canonical frame is in $\mathsf{Fr}_\sigma$, or, equivalently, to show that $\mathfrak{F}^d, V \models \sigma$ for all valuations $V$. This is immediate by the following lemma and Theorem 3.5.

**Lemma 5.12** *Any d-canonical general frame is discrete.*

**Proof.**
Let $w$ be a d-theory or world in a d-canonical general frame $\mathfrak{G}^d = (\mathfrak{F}^d, A^d)$. Let $p$ be a propositional variable such that $Op \in w$, then by the truth lemma $w$ is the *only* d-theory of $\mathfrak{G}^d$ with $Op \in w$. So $\{w\} = V^d(Op) \in A^d$. $\square$

**Proof of theorem 5.1**
Soundness is immediate.
For completeness, suppose $\Sigma \nvdash \phi$, then $\Sigma \cup \{\neg\phi\}$ is consistent, so by lemma 5.5 there is a d-theory $\Sigma'$ with $\Sigma \cup \{\neg\phi\} \subseteq \Sigma'$. Let $\mathfrak{M}^d = (\mathfrak{F}^d, V^d)$ be the d-canonical model with $\Sigma' \in W^d$. By lemma 5.12 and Theorem 3.5, $\mathfrak{F}^d \models \sigma$ and by the truth lemma, $\mathfrak{M}^d, \Sigma \models \psi$ for all $\psi \in \Sigma \cup \{\neg\phi\}$.
So we obtained $\Sigma \not\models_{\mathsf{Fr}_\sigma^\ne} \phi$. $\square$

---
