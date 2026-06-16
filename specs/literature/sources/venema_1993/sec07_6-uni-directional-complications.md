## 6 Uni-directional Complications

In this section, which is not needed for understanding the sequel, we will see where our proof fails for a similarity type $S$ which contains uni-directional diamonds. It suffices to take the case where we have only one diamond $F$ besides $D$. We would like to extend the results of the previous section to this case, but there seem to be two problems:

The first of these was already noted by Gabbay [8] and is also discussed in Gargov & Goranko [12]. The point is the following: in the previous section we saw that it is not sufficient to prove completeness by purging the canonical frame of $R_D$-reflexive points: their predecessors also need to be thrown out, and the predecessors of those, ad infinitum. In our 'constructive' approach this problem arises in the following way: it is not sufficient to show that $Op \wedge \phi$ is consistent if $\phi$ is so, we must also prove that $\phi_0 \wedge \Diamond_1(Op \wedge \phi_1)$ is all right if $\phi_0 \wedge \Diamond_1 \phi_1$ is, etc. In the tense-logical situation, we can do this by changing our 'perspective' on the formula, namely by moving the $\phi_1$-position to the top level: we look at $\phi_1 \wedge \Diamond_1^{-1}\phi_0$ (which is consistent iff $\phi_0 \wedge \Diamond_1 \phi_1$ is so), then we insert $Op$, obtaining $(Op \wedge \phi_1) \wedge \Diamond_1^{-1}\phi_0$. Returning to the old 'perspective' we see that indeed $\phi_0 \wedge \Diamond_1(\phi_1 \wedge Op)$ is consistent if $\phi_0 \wedge \Diamond_1 \phi_1$ is consistent. It will be clear that *tense operators* are indispensable instruments for this surgery.

We will now prove that it really goes wrong in the uni-directional case:

**Definition 6.1** *Assume that we have a uni-directional similarity type with two operators: $F$ and $D$.*
*Let $\rho$ be the formula $G(p \to Dp)$, $\rho'$ the formula $\rho \wedge F\top$.* $\square$

Note that $\rho$ is a Sahlqvist formula (cf. the footnote to definition 3.1), its equivalent $\rho^{s'}$ is $\forall x \forall y(Rxy \to R_D yy)$. So $\rho$ says: all $R$-successors are $R_D$-reflexive.

Now, recall that $K_F D^+\rho'$ is the axiom system with as axioms: $CT$, $DB$, the $D$-axioms and $\rho'$. Its derivation rules are $MP$, $UG$, $SUB$ and $IR_D$. If we had an analogon of theorem 5.1 for this logic, $K_F D^+\rho'$ should be inconsistent, for we have

**Lemma 6.2** $\mathsf{K}_{\rho'}^\ne = \emptyset$.

**Proof.**
It suffices to show that $\rho'$ cannot be valid in a standard frame. Assume $\mathfrak{F} \models \rho'$, where $\mathfrak{F} = (W, R, R_D)$ and $w$ is a world of $\mathfrak{F}$. By $\mathfrak{F}, w \models F\top$, $w$ has a successor $v$, by $\mathfrak{F} \models \rho^{s'}(w)$, $v$ is $R_D$-reflexive. But then $\mathfrak{F}$ is not standard. $\square$

But, $K_F D^+(\rho')$ is *not* inconsistent, as we can easily show by considering non-standard frames again:

**Lemma 6.3** $K_F D^+(\rho') \nvdash \bot$.

**Proof.**
Consider the following non-standard frame $\mathfrak{F} = (W, R, R_D)$:

$$W = \{w_n | n \in \omega\} \cup \{v\}$$
$$R = W \times \{v\}$$
$$R_D = \{(s,t) | s \ne t\} \cup \{(v, v)\},$$

and set $\Delta = \{\phi \mid \mathfrak{F}, w_0 \models \phi\}$. Clearly then $\bot \notin \Delta$. We show that $\Delta$ contains the axioms of $K_F D^+\rho'$ and is closed under its rules. For the axioms, this is fairly trivial: for instance, $\rho'$ is in $\Delta$ as $\mathfrak{F}, w_0 \models \forall y(Rxy \to R_D yy)$. Concerning the rules: $\Delta$ is closed under $IR_D$, as $w_0$ is $R_D$-irreflexive.

To show that $\Delta$ is closed under Universal Generalization, it suffices to prove that $\mathfrak{F}, w_0 \models \phi$ implies (1) $\mathfrak{F}, v \models \phi$ and (2) $\mathfrak{F}, w_n \models \phi$, for all $n$. The second claim is trivial by symmetry; for (1) we define a p-morphism $f : \mathfrak{F} \to \mathfrak{F}$ such that $f(w_0) = v$, and then we use the well-known p-morphism lemma giving $\mathfrak{F}, x \models \psi \Rightarrow \mathfrak{F}, fx \models \psi$. The map $f$ is given by

$$f(w_0) = v, f(w_{n+1}) = w_n \text{ and } f(v) = v.$$

It is left to the reader to check that $f$ is indeed a p-morphism. $\square$

This problem is not difficult to mend: a close inspection of the completeness proof in the previous section reveals that the essential property that we need to prove the extension lemma 5.4 and which tense logics automatically give us, is the following:

**Definition 6.4** *A derivation system $\Lambda$ has the* deep insertion property *iff*

$(DIP) \qquad \vdash W(Op, \psi, \phi) \to \eta \ \Rightarrow \ \vdash \phi \to \eta$
&emsp;&emsp;&emsp;&emsp;&emsp; *for all $\psi \unlhd \phi$ and $p$ not occurring in $\phi$ or $\eta$.*

The idea is now to extend the definition of the irreflexivity rule so as to obtain a logic in which the extension lemma holds again:

**Definition 6.5** *Define the following set of derivation rules:*

$(IR_D^*) \qquad \vdash \neg W(Op, \psi, \phi) \ \Rightarrow \ \vdash \neg\phi$
&emsp;&emsp;&emsp;&emsp;&emsp; *provided $\psi \unlhd \phi$ and $p \notin \phi$.*

**Lemma 6.6** *Let $\Lambda$ be a logic having $IR_D^*$. Then $\Lambda$ has DIP.*

**Proof.**
By the following chain of consequences (where we assume that $p$ does not occur in $\phi$ or in $\eta$):

$$\vdash W(Op, \psi, \phi) \to \eta \qquad \text{(assumption)}$$
$$\Rightarrow \quad \vdash \neg(\neg\eta \wedge W(Op, \psi, \phi)) \qquad \text{(proplog)}$$
$$\Rightarrow \quad \vdash \neg W(Op, \psi, \neg\eta \wedge \phi) \qquad \text{(evaluation of } W\text{)}$$
$$\Rightarrow \quad \vdash \neg(\neg\eta \wedge \phi) \qquad (IR_D^*)$$
$$\Rightarrow \quad \vdash \phi \to \eta \qquad \text{(proplog)} \qquad \dashv$$

So for a similarity type where not all diamonds have converses, it is necessary to have the rule $IR_D^*$ instead of $IR_D$. This was already noted by Gabbay [8] and by Gargov & Goranko [12], from which we derived the above example. It is not yet clear whether this extension is also *sufficient* to prove the analogon of the $SD$-theorem, at least if we want to consider axiom systems with *arbitrary* Sahlqvist axioms. For, there is another difference between the tense logical case and the unidirectional one.

This second problem seems to be more serious; assume that, analogous again to the previous section, we have constructed a d-canonical model $\mathfrak{M}^d$ for a MCS $\Sigma$. We want to prove $\mathfrak{F}^d \models \sigma$, where $\sigma$ is the Sahlqvist axiom added to the logic $K_S D^+$. In the tense logical case, we could do this, by using a special kind of valuations which we called *rudimentary*. We showed that for such a valuation $\mathfrak{F}^d, V \models \sigma$. This path however can only be taken if we have the converse diamond of $\mathfrak{F}$ in the language (cf. the proof of Lemma 3.12); in the uni-directional case, rudimentary valuations need not be *admissible*. It even turns out that the 'discrete persistency result' (Theorem 3.5) does not hold for arbitrary Sahlqvist formulas in a uni-directional similarity type:

**Lemma 6.7** *There is a Sahlqvist formula $\gamma$ and a discrete general frame $\mathfrak{G} = (\mathfrak{F}, A)$ such that $\mathfrak{G} \models \gamma$, $\mathfrak{F} \not\models \gamma$.*

**Proof.**
Let $\gamma$ be the formula $\sigma = FGp \to GFp$.
We have already met $\gamma$ in section 3; its first order equivalent is the *Church-Rosser* formula

$$\gamma^*(x) = \forall y \forall z(Rxy \wedge Rxz \to \exists t(Ryt \wedge Rzt)).$$

Consider the following (standard) frame $\mathfrak{F} = (W, R)$:
The set of possible worlds is given as $W = \{u, v, w, x\} \cup \{v_n, w_n \mid n \in \omega\}$. The accessibility relation $R$ holds as follows: $Ruv$, $Ruw$, $Rvv_n$ and $Rww_n$, all $n$, $Rv_n x$ and $Rw_n x$, all $n$, and $Rxx$.

Finally, we base a general frame $\mathfrak{G} = (\mathfrak{F}, A)$ on $\mathfrak{F}$, by defining $A$ as the set of finite and cofinite subsets of the universe $W$.

To check that $\mathfrak{G}$ is indeed a general frame, the key observation is that for any $X \subseteq W$, $m_F(X)$ is finite if $x \notin X$, cofinite if $x \in X$. In order to prove that $\mathfrak{G} \models \gamma$, it suffices to look at $w$. Suppose that for some admissible $V$, $FGp$ holds at $w$. Without loss of generality we may assume that $\mathfrak{F}, V, v \models Gp$, so $p$ holds at all $v_i$. Then $V(p)$ is not finite and hence co-finite. So there are (co-finitely many) $w_i$ with $\mathfrak{F}, V, w_i \models p$. But then $Fp$ holds at $w$ and thus $GFp$ at $u$.

It is easy to show that $\mathfrak{F} \not\models \gamma$, by considering the valuation $V(p) = \{v_n \mid n \in \omega\}$. Here $\mathfrak{F}, V, u \models FGp$ as $\mathfrak{F}, V, v \models Gp$, but $\mathfrak{F}, V, u \not\models GFp$, as $\mathfrak{F}, V, w \not\models Fp$. $\square$

Sahlqvist *tense* formulas however are still persistent for discrete general frames. Note that for a uni-directional similarity type, atoms are the only strongly positive formulas, so the set of St-formulas is rather small. Still, for this restricted set we do have a completeness theorem:

**Definition 6.8** *Let $S$ be an arbitrary similarity type of constants and diamonds. $K_S D^*$ is the basic $S$-logic extended with the set of rules $IR_D^*$.*

**Theorem 6.9** *Let $S$ be an arbitrary similarity type of constants and diamonds, and $\Sigma$ a set of Sahlqvist tense formulas. Then*

$$K_S D^*\Sigma \text{ is strongly sound and complete for } \mathsf{K}_\Sigma^\ne.$$

**Proof.**
An copy of the proof in section 5, using lemma 6.6 instead of lemma 5.4. $\square$

We conjecture that for any *individual* set of Sahlqvist axioms, the completeness like in Theorem 6.9 can be shown to hold, but we are doubtful whether there is a uniform proof (analogous to that of Theorem 5.1) taking care of all Sahlqvist axiomatizations at once. On the other hand, Goranko [17] announces a general *weak completeness proof*, for arbitrary canonical formulas.

---
