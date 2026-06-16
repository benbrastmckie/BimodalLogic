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
