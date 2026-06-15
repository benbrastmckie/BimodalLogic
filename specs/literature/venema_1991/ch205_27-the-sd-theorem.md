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
