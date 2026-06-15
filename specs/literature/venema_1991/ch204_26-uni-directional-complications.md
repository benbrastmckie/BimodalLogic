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
