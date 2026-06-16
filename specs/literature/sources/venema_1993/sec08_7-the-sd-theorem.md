## 7 The SD-theorem

There are some problems involved, mainly of a technical nature, in extending the completeness proof of the SD-theorem to languages having dyadic operators. Note that recently, dyadic modal operators have received some attention in e.g. van Benthem [4], Roorda [30] and Venema [38, 39].

First of all we have to make clear what we mean by a Sahlqvist (tense) formula in a dyadic language. In fact, the definitions and results of section 3 already apply to arbitrary similarity types. The following point is worth some discussion, however: in a similarity type with only diamonds and constants, we allow boxed atoms in the strongly positive formulas. A naive approach to define Sahlqvist triangle formulas would then be to allow duals of dyadic operators too. But de Rijke showed that the formula

$$(p \triangle p) \triangle p \to (p \triangle p) \triangle p$$

is *not acceptable* as a Sahlqvist formula, as it does not have a first order equivalent on the frame level. So for triangle similarity types, the atoms and negative formulas are the only admissible building blocks of Sahlqvist antecedents. This implies that for arbitrary similarity types, the difference between Sahlqvist *tense* formulas and ordinary Sahlqvist formulas is caused by the nature of the *diamonds* alone.

However, we saw in the previous section that there were two reasons to prefer tense similarity types above uni-directional ones: besides a larger set of axioms for which our procedure works, there is also the advantage of a simple, transparent formulation of the non-$\xi$ derivation rules. This second aspect is the same for similarity types having polyadic modal operators, so we have to generalize the concept of 'tense' to an arbitrary similarity type. Hereto we introduce the following notion:

**Definition 7.1** *A* versatile *similarity type is a modal similarity type $S = (O, \rho)$ where the set $O$ of operators is given as a (disjoint) union of sets, $O = \bigcup_{j \in J} O_j$, such that $O_j = \{\nabla_{j0}, \ldots, \nabla_{j,n_j}\}$ and all operators in $O_j$ have the same rank $n_j - 1$.*
*A versatile frame for such an $S$ is an $S$-frame $(W, I)$ where for all $j \in J$, $i \le n_j$ one has*

$$I(\nabla_{j_1}) = \{(w_0, w_1, \ldots, w_{n_j}) \mid (w_1, \ldots, w_{n_j}, w_0) \in I(\nabla_{j,i+1})\}$$

*For a class $\mathsf{K}$ of $S$-frames, we let $\mathsf{K}^v$ denote the class of versatile frames in $\mathsf{K}$.*

We do not exclude the possibility that $O_j = \{\nabla, \ldots, \nabla\}$, i.e. all operators are identical. Note that the notion 'tense' only applies to diamonds: in a tense similarity type $S$ there is no constraint on the operators of rank $> 2$. Only if all operators of $S$ are constants or diamonds, do the concepts of 'tense' and 'versatility' coincide, and do we have $\mathsf{K}^t = \mathsf{K}^v$.

The analogy with the monadic case is the following: if we consider a language and semantics which are not versatile, one irreflexivity rule is not sufficient, but we have to add infinitely many rules, allowing the building in of witnesses at all depths in a formula. To avoid these technical complications, we have to get familiar with the versatile *logic* of polyadic operators.

Let us for the moment consider a similarity type consisting of three dyadic operators $\triangle_0$, $\triangle_1$ and $\triangle_2$. Frames for this similarity type have the form $\mathfrak{F} = (W, R_0, R_1, R_2)$, where $R_i$ is the ternary accessibility relation of $\triangle_i$. Recall that the truth definition of a dyadic operator gives

$$u \models \phi \ \triangle_i \ \psi \iff \text{there are } v, w \text{ with } R_i uvw, \ v \models \phi \text{ and } w \models \psi.$$

In the intended *versatile* semantics, the three $R_i$'s are 'directions' of one ternary relation $R$; as a standard we take $R = R_0$. A frame $\mathfrak{F} = (W, R_0, R_1, R_2)$ is a *versatile* frame if it satisfies the following conditions, for $i = 0, 1, 2$ (we write $2 + 1 = 0$):

$(Qi) \qquad \forall u, v, w \ (R_i uvw \to R_{i+1} vwu)$

Analogous to the monadic case, the class $\mathsf{Fr}^v$ of versatile frames can be quite easily characterized and axiomatized:

**Definition 7.2** *Define the following formulas, for $i = 0, 1, 2$:*

$(Vi) \qquad \big(p \wedge \neg(r \ \triangle_{i+1} \ p) \ \triangle_i \ r\big) \to \bot,$

*and set $V \equiv V1 \wedge V2 \wedge V3$.*
*Let $K_S^v$ be the versatile $S$-logic, i.e. the minimal $S$-logic $K_S$ extended with the axiom $V$.*

Note that $Vi$ is a Sahlqvist formula: $p$ is strongly positive, $\neg(r \ \triangle_{i+1} \ p)$ is negative and $r$ is again strongly positive, so $p \wedge \neg(r \ \triangle_{i+1} \ p) \ \triangle_i \ r$ is untied, and as $\bot$ is positive, we are finished.

This means that we immediately have the following:

**Lemma 7.3** *For $i = 0, 1, 2$: $\mathfrak{F} \models Qi \iff \mathfrak{F} \models Vi$.*

**Proof.**
The proposition is immediate by the Sahlqvist theorem, but we give a direct proof (taking $i = 0$):
($\Rightarrow$) Suppose that for some model $\mathfrak{M}$ on $\mathfrak{F}$, $\mathfrak{M}, u \models p \wedge \neg(r \ \triangle_1 \ p) \ \triangle_0 \ r$. By the truth definition of $\triangle_0$, there are $v, w$ with $R_0 uvw$, $v \models \neg(r \ \triangle_1 \ p)$, $w \models r$, while $u \models p$. $\mathfrak{F} \models Q0$ implies $R_1 vwu$, so by the truth definition of $\triangle_1$ we get $v \models r \ \triangle_1 \ p$ and find the desired contradiction.
($\Leftarrow$) Let $(u, v, w)$ be in $R_0$. We want to show $(v, w, u) \in R_1$. Suppose otherwise and consider a valuation $V$ with $V(p) = \{u\}$, $V(r) = \{w\}$. Then $v \models \neg(r \ \triangle_1 \ p)$, so $u \models \neg(r \ \triangle_1 \ p) \ \triangle_0 \ r$. By $\mathfrak{F} \models V_1$ we then have $u \models \neg p$, contradicting $V(p) = \{u\}$. $\square$

**Theorem 7.4** *$K_S^v$ is strongly sound and complete with respect to the versatile $S$-frames.*

**Proof.**
Immediate by the fact that the axioms are Sahlqvist formulas and lemma 7.3. $\square$

**Lemma 7.5** *The following deduction rule is a derived rule of $K_S^v$:*

$$\vdash \neg(\phi \wedge \psi \ \triangle_i \ \chi) \iff \vdash \neg(\psi \wedge \chi \ \triangle_{i+1} \ \phi).$$

**Proof.**
By the observation that the rule is *sound* in the class of $S$-versatile frames. $\square$

Note that intuitively, $\mathfrak{M} \models \neg(p \wedge q \ \triangle_i \ r)$ denotes the impossibility of a triple $(u, v, w)$ in $R$ with $u \models p$, $v \models q$ and $w \models r$.
We can easily generalize this idea to operators of rank $\ne 2$. For example, for the monadic case we have

$$\vdash \neg(p \wedge \Diamond q) \iff \vdash \neg(q \wedge \Diamond^{-1}p)$$

as a derived rule of the minimal tense logic.

Now we are ready to add monadic tense operators, including the $D$-operator, to the language.

**Definition 7.6** *Let $S$ be a versatile similarity type having constants, monadic tense operators $\{\Diamond_i, \Diamond_i^{-1} \mid i < \alpha\}$ and dyadic operators $\{\triangle_0^j, \triangle_1^j, \triangle_2^j \mid j < \beta\}$.*
*The versatile $S$-logic $K_S^v$ is defined as the extension of the minimal $S$-logic $K_S$ with the tense axiom $CV$ for every diamond pair, and the versatility axiom $V$ for every triple of triangles.*

**Theorem 7.7** *SD-THEOREM*
*Let $S$ be a versatile similarity type containing $D$ and $\Sigma$ a set of Sahlqvist formulas. Then*

$$K_S^v D^+\Sigma \text{ is strongly sound and complete for } \mathsf{K}_\Sigma^{v,\ne}.$$

**Proof.**
For notational simplicity, we assume that $S = \{D, F, P, \triangle_0, \triangle_1, \triangle_2\}$ and that $\Sigma$ is a singleton $\{\sigma\}$. From now on we abbreviate the logic $K_S^t D^+\sigma$ by $\Lambda$. The proof is essentially the same as in section 5, so we only give the following details.

The definition of $W(\chi, \psi, \phi)$ is extended with a clause for dyadic operators:

$$W(\chi, \psi, \phi \ \triangle \ \phi') = W(\chi, \psi, \phi) \ \triangle \ W(\chi, \psi, \phi')$$

We show that for all $\psi \unlhd \phi$ and $q$ not occurring in $\phi$ or $\eta$, we have $\vdash W(Oq, \psi, \phi) \to \eta$ implies $\vdash \phi \to \eta$; consider the case in the induction step where $\phi = \phi_0 \ \triangle_0 \ \phi_1$ and $\psi \unlhd \phi_0$. Then $W(Oq, \psi, \phi) = W(Oq, \psi, \phi_0) \ \triangle_0 \ \phi_1$ and we get

$$\vdash W(Oq, \psi, \phi_0) \ \triangle_0 \ \phi_1 \to \eta \qquad \text{(assumption)}$$
$$\Rightarrow \quad \vdash \neg(\neg\eta \wedge W(Oq, \psi, \phi_0) \ \triangle_0 \ \phi_1) \qquad \text{(propositional logic)}$$
$$\Rightarrow \quad \vdash \neg(W(Oq, \psi, \phi_0) \wedge \phi_1 \ \triangle_1 \ \neg\eta) \qquad \text{(Lemma 7.5)}$$
$$\Rightarrow \quad \vdash \neg(\phi_0 \wedge \phi_1 \ \triangle_1 \ \neg\eta) \qquad \text{(Induction Hypothesis)}$$
$$\Rightarrow \quad \vdash \neg(\neg\eta \wedge \phi_0 \ \triangle_0 \ \phi_1) \qquad \text{(Lemma 7.5)}$$
$$\Rightarrow \quad \vdash \phi \to \eta \qquad \text{(propositional logic)}$$

This ensures that we can prove the analogon of lemma 5.4.

To show the same for lemma 5.5, we prove the following: if $\Gamma$ is distinguishing and $\phi \ \triangle \ \pi \in \Gamma$, then there are d-theories $\Phi$ and $\Pi$ with $\phi \in \Phi$, $\pi \in \Pi$ and $R_\triangle^c \Gamma \Phi \Pi$. For, as $\phi \ \triangle \ \pi$ is in $\Gamma$, we have $(\phi \wedge Of) \ \triangle \ (\pi \wedge Op)$ in $\Gamma$ for some propositional variables $f$ and $p$. We set

$$\Phi = \{\alpha \mid (\alpha \wedge Of) \ \triangle \ Op \in \Gamma\}$$
$$\Pi = \{\psi \mid Of \ \triangle \ (\psi \wedge Op) \in \Gamma\},$$

and the proof that these $\Phi$ and $\Pi$ have the desired properties, runs like in lemma 5.5.

The remainder of the proof is a copy of that in section 5. $\square$

---

## 8 The $SN\Xi$-theorem

We are now ready to prove our main completeness theorem for a versatile logic having other non-$\xi$ rules besides $IR_D$.

**Definition 8.1** *Let $S$ be a versatile similarity type containing the $D$-operator, $\Sigma$ a set of Sahlqvist formulas and $\Xi$ a set of arbitrary formulas. $K_S^v D^+(\Sigma, -\Xi)$ is the logic $K_S^v D^+$ extended with the axioms $\Sigma$ and the non-$\xi$ rules for all $\xi \in \Xi$.*

Recall that the above definition implies that the *rules* of $K_S^v D^+(\Sigma, -\Xi)$ are $MP$, $UG$, $SUB$, $IR_D$ and $\{N\xi R \mid \xi \in \Xi\}$. If the similarity type contains only constants and diamonds, then the system has the following *axioms*:

- $(CT)$ &emsp; all classical tautologies
- $(DB)$ &emsp; $\Box(p \to q) \to (\Box p \to \Box q)$
- $(CV)$ &emsp; $p \to \Box\Diamond^{-1}p$
- $(D1)$ &emsp; $p \to \underline{D}Dp$
- $(D2)$ &emsp; $DDp \to (p \vee Dp)$
- $(D3)$ &emsp; $\Diamond p \to p \vee Dp$
- $(\Sigma)$ &emsp; $\Sigma$

If there are also triangles around, then the system has the versatility axiom $V$ too (cf. 7.2).

With respect to the semantics, note that the class $\mathsf{Fr}_{(\Sigma, -\Xi)}^{v,\ne}$ is defined as the class of $D$-standard versatile $S$-frames with

$$\mathfrak{F} \models \sigma \qquad \text{for all } \sigma \text{ in } \Sigma$$
$$\mathfrak{F}, w \not\models \xi \qquad \text{for all } w \text{ in } \mathfrak{F}, \ \xi \text{ in } \Xi$$

If every $\xi$ has a local first order equivalent $\xi^f(x)$ on the frame level (for example, if all $\xi$'s are Sahlqvist formulas too), then $\mathsf{Fr}_{(\Sigma, -\Xi)}^{v,\ne}$ is elementary, as we have

$$\mathfrak{F} \text{ in } \mathsf{Fr}_{-\xi} \iff \mathfrak{F} \models \forall x \neg\xi^f(x).$$

So, the theory below takes care of many classes of frames, for example the asymmetric or intransitive frames (cf. the characterizations given in the introduction).

**Theorem 8.2** *(SN$\Xi$-THEOREM)*
*Let $S$, $\Sigma$ and $\Xi$ be as in definition 8.1. Then*

$$K_S^v D^+(\Sigma, -\Xi) \text{ is strongly sound and complete for } \mathsf{Fr}_{(\Sigma, -\Xi)}^{v,\ne}.$$

**Proof.**
We can use a straightforward adaptation of the proof in the previous section. There we started with a consistent $\Delta$ and inserted in $\Delta$, for every $\phi \in \Delta$ and $\psi \unlhd \phi$, a formula $W(Op, \psi, \phi)$, in order to witness the $R_D$-irreflexivity of all worlds connected to $\Delta$. Here we will add more formulas (of the form $W(\neg\xi(p_1, \ldots, p_n), \psi, \phi)$)), this time in order to ensure that the canonical-like general frame we end with is not only standard (with respect to $R_D$), but also in $\mathsf{Fr}_{-\Xi}$.

So we call a set $\Delta$ of $S$-formulas *witnessing (against $\Xi$)* if it is distinguishing and for all formulas $\phi \in \Delta$, $\psi \unlhd \phi$ and $\xi \in \Xi$, there are propositional variables $p_1, \ldots, p_n$ with $W(\neg\xi(p_1, \ldots, p_n), \psi, \phi) \in \Delta$.

*W(itnessing)-canonical frames, models*, etc. are defined analogous to distinguishing ones.

Now for completeness, we consider a consistent set $\Delta$, extend it to a witnessing set $\Delta'$, and we construct the witnessing canonical model $\mathfrak{M}$ of which $\Delta'$ is a world. By the truth lemma, every formula in $\Delta'$ is true at $\Delta'$. By an argument like in the previous section, the underlying witnessing canonical frame $\mathfrak{F}$ is versatile, $D$-standard, and it validates the axioms $\Sigma$. By the truth lemma and the fact that every MCS of $\mathfrak{M}$ contains a formula $W(\neg\xi(p_1, \ldots, p_n), \psi, \phi)$, we see that $\mathfrak{F}$ is in $\mathsf{Fr}_{-\Xi}$. This proves the theorem. $\square$

Just like in section 6, we can prove a poorer version of Theorem 8.2 for arbitrary (not versatile) similarity types, but we leave this to the reader.

---

## 9 Conclusions, Remarks and Questions

### 9.1 General Conclusions

This paper was a study in the semantics and (mainly) the axiomatics of non-$\xi$ rules, styled after Gabbay's Irreflexivity Rule.

On the semantic side, we defined $\mathsf{K}_{-\Xi}$ as the class of frames $\mathfrak{F}$ in $\mathsf{K}$ where no $\xi \in \Xi$ holds anywhere, i.e. for no $\xi \in \Xi$ there is a $w$ in $\mathfrak{F}$ with $\mathfrak{F}, w \models \xi$. In general, such a class will not be *definable* by a modal formula. Natural examples are formed by the irreflexive, asymmetric or transitive frames; the phenomenon is abundant in many-dimensional modal logic, and thus, in algebraic logic, cf. Venema [42].

The main result of this paper, the $SN\Xi$-theorem 8.2 states that under certain conditions, classes of the form $\mathsf{K}_{-\Xi}$ are *axiomatizable*, by a derivation system having a non-$\xi$ rule for every $\xi \in \Xi$. In the various sections of this paper we have discussed these conditions.

The most elegant formulation of the $SN\Xi$-theorem is in the case where the similarity type is *versatile* and contains the $D$-operator. For such a similarity type, our result gives a nice derivation system for every class $\mathsf{K}_{-\Xi}$ where $\mathsf{K}$ is a class of $D$-standard, versatile frames which is positively characterized by a set of *Sahlqvist axioms*. For poorer similarity types, there are various options, of which we list a few:

1. If the similarity type is not versatile, we have to add a *schema* of non-$\xi$ rules (cf. section 6).
2. If not all diamonds are tense, only *Sahlqvist tense* formulas are allowed as axioms (cf. sections 6 and 7).
3. If the similarity type $S$ does not contain the $D$-operator, the theorem does not apply directly.

Fortunately, this does not mean that the full power of the $SN\Xi$-theorem is lost for these poorer similarity types; one only has to work a bit harder for it. To give an example: in many cases, over the class $\mathsf{K}_{-\Xi}$ we can *define* the $D$-operator in the poorer formalism, so that we can work with this defined $D'$-operator. Examples of this idea can be found in Venema [43, 42].

So, rather than a theorem, the $SN\Xi$-concept is a *procedure* to find axiomatizations for non-$\xi$ classes:

1. Find the proper characterization of the class (maybe in an extended similarity type).
2. Apply the $SN\Xi$-theorem, immediately obtaining a strongly sound and complete derivation system.
3. Try to simplify this system.

It would be unfair not to mention the fact that axiomatizations using non-$\xi$ rules have some *disadvantages* too: first of all, such axiomatizations may not have all the nice mathematical properties that orthodox axiomatizations have. For example (cf. Goldblatt [15]): define, for a logic $\Lambda$, the corresponding algebraic variety $\mathsf{V}_\Lambda$ of Boolean Algebras with Operators as the class of algebras where the set of equations $\{\phi = 1 \mid \Lambda \vdash \phi\}$ is valid. Now for a finite *orthodox* $\Lambda$, the complement of $\mathsf{V}_\Lambda$ will be closed under ultraproducts, while this need not be the case for an unorthodox $\Lambda$.

Second, by the nature of the derivation rule, it may be necessary to add new propositional variables to the language in order to derive a formula $\phi$, whence we have *less control* on derivations in these unorthodox systems.

These disadvantages take us to the question, in which cases a non-$\xi$ rule can be *eliminated* from a system.
