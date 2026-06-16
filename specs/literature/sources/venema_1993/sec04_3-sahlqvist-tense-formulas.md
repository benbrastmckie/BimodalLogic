## 3 Sahlqvist tense formulas

In this section we discuss the formulas that are allowed as axioms in the derivation systems to which our main result on completeness will apply.

It is well-known that on the level of frames every formula $\phi$ locally and globally has a *second order* equivalent $\phi^2$. In many important cases however, it turns out that this formula $\phi^2$ has a much simpler *first order* equivalent (in the corresponding frame language $L_S$). Well-known examples include reflexivity for $p \to \Diamond p$ and the Church-Rosser property for $\Diamond\Box p \to \Box\Diamond p$. A general theorem in this direction was found by Sahlqvist (cf. [31]). The *correspondence* part of Sahlqvist's theorem gives a decidable set of modal $S$-formulas having a local equivalent in $L_S$. In [3], van Benthem provides a quite perspicuous algorithm to find this first order correspondent $\phi^*$ of a Sahlqvist formula $\phi$. (At the end of this section, we will give our version of his *substitution method*.) The second, *completeness* part of the Sahlqvist theorem states that adding a set $\Sigma$ of Sahlqvist axioms to the minimal $S$-logic $K_S$, we obtain a complete axiomatization for the class of frames $\mathsf{Fr}_\Sigma$. An accessible version of the proof of this part can be found in Sambin & Vaccaro [35], from which we took some terminology. The correspondence and completeness part of Sahlqvist's theorem are closely connected; in Kracht [21] they are studied in a unifying framework.

**Definition 3.1** *A* strongly positive formula *is a conjunction of formulas $\Box_1 \ldots \Box_m p_i$ ($m \ge 0$). A formula is* positive (negative) *if every propositional variable occurs under an even (odd) number of negation symbols. A modal formula is* untied *if it is obtained from strongly positive formulas and negative ones by applying only $\wedge$ and arbitrary existential modal operators. Formulas of the form $\phi \to \psi$ with $\phi$ an untied formula and $\psi$ a positive one, are called* Sahlqvist formulas[^4].

[^4]: In fact, we may even consider the wider set of formulas obtained from (basic) Sahlqvist formulas by applying *duals* of existential modal operators.

**Theorem 3.2** *(SAHLQVIST)*
*Let $\sigma$ be a Sahlqvist formula. Then*
**(i)** *$\sigma$ is canonical: $\mathfrak{F}_{K\sigma}^c \models \sigma$.*
**(ii)** *$K\sigma$ is strongly sound and complete with respect to $\mathsf{Fr}_\sigma$.*
**(iii)** *There is an effectively obtainable first order $L_S$-formula $\sigma^*(x_0)$ such that for all frames $\mathfrak{F}$, all $w$ in $\mathfrak{F}$:*

$$\mathfrak{F}, w \models \sigma \iff \mathfrak{F} \models \sigma^*[x_0 \mapsto w].$$

**Proof.**
For **(i)** we refer to Sambin & Vaccaro [35]; **(ii)** is immediate by **(i)**. The last part **(iii)** will be proved at the end of this section, after we have given the algorithm to find $\sigma^*(x_0)$ in 3.15.
$\square$

A typical example of a formula which is *not* Sahlqvist, is $\Box\Diamond p \to \Diamond\Box p$. A typical example of a Sahlqvist formula is $\Diamond\Box p \to \Box\Diamond p$; its first order correspondent is $\forall y_0 y_1((Rxy_0 \wedge Rxy_1) \to \exists z(Ry_0 z \wedge Ry_1 z))$.

In the above theorem we saw that a Sahlqvist formula is *canonical*: if it holds in the canonical model, then it is valid on all models on the underlying canonical frame. In this paper we develop and use non-standard notions of canonical structures, for which we have to adapt the proof of the Sahlqvist theorem. In fact we will show that van Benthem's substitution method (which deals with Kripke frames) also works for the following class of *general* frames:

**Definition 3.3** *A general frame $\mathfrak{G} = (\mathfrak{F}, A)$ is* discrete *if for all worlds $w$ in $\mathfrak{F}$, $\{w\} \in A$.*

For our definitions concerning tense logic, we refer to subsection 1.2.

**Definition 3.4** *A Sahlqvist tense formula, or shortly: an St-formula is a Sahlqvist formula satisfying the extra constraint that all boxes occurring in strongly positive formulas are tense boxes.*

As an example of a Sahlqvist formula which is not an St-formula, we can take the Church-Rosser formula $\Diamond\Box p \to \Box\Diamond p$ (at least, if $\Diamond$ is not a tense diamond). The 'tense axiom' $p \to \Box^{-1}\Diamond p$ itself is an St-formula. Note that in a tense similarity type, there is no distinction between Sahlqvist formulas and St-formulas.

The theorem that we need is the following:

**Theorem 3.5** *Let $\mathfrak{G} = (\mathfrak{F}, A)$ be a discrete general tense frame and $\sigma$ a Sahlqvist tense formula such that $\mathfrak{G} \models \sigma$. Then $\mathfrak{F} \models \sigma$.*

The remainder of this section is devoted to prove Theorem 3.5; as a side result, we can give an easy formulation of the algorithm producing the first order correspondent of a Sahlqvist formula.

The definition of Sahlqvist formulas is a syntactic one, but in fact the important constraint on the consequent is a semantic one, viz. monotonicity:

**Definition 3.6** *Let $V$ and $V'$ be two valuations on a frame $\mathfrak{F}$. $V'$ is* wider *than $V$, notation: $V \le V'$, if for all atoms $p$, $V(p) \subseteq V'(p)$. A modal formula $\phi$ is* monotone *if for all $\mathfrak{F}$, $V$, $V'$ and $w$:*

$$\mathfrak{F}, V, w \models \phi \text{ and } V \le V' \text{ imply } \mathfrak{F}, V', w \models \phi$$

We also need related concepts for the first order model-language.

**Definition 3.7** *Let $Q$ be the set of propositional variables of the language. Recall that $L_{S,Q}$ denotes the first order language with $S$-accessibility predicates and a monadic predicate $P_i$ for every propositional variable $p_i \in Q$. The sign of an occurrence of a predicate $T$ in a formula $\phi$ is defined by induction to $\phi$: $T$ occurs positively in the atomic formula $Tx_0 \ldots x_{n-1}$. If $T$ occurs positively (negatively) in $\phi$, then it occurs negatively (positively) in $\neg\phi$, and positively (negatively) in $\phi \vee \psi$ and $\exists x\phi$. An $L_{S,Q}$-formula is* positive (negative) *if all occurrences of $Q$-predicates are positive (negative).*
*An $L_{S,Q}$-formula $\phi(x_1, \ldots, x_n)$ is* monotone *if for all valuations $V, V'$ and all $n$-tupels $w_1, \ldots, w_n$:*

$$\mathfrak{F}, V \models \phi[w_1, \ldots, w_n] \text{ and } V \le V' \text{ imply } \mathfrak{F}, V' \models \phi[w_1, \ldots, w_n].$$

Note that in the above definition it does not matter how the *accessibility* predicates occur in a formula. There is a lot to be said about the above concepts, but we confine ourselves to the following facts, of which the proof is standard:

**Lemma 3.8** **(i)** *If $\phi$ is positive (negative), then so is its model correspondent $\phi^1$.*
**(ii)** *Negations of positive (negative) formulas are equivalent to negative (positive) ones.*
**(iii)** *Positive formulas are monotone.*

To prove Theorem 3.5, from here until definition 3.15 we fix a St-formula $\sigma$ and a general frame $\mathfrak{G} = (\mathfrak{F}, A)$, $\mathfrak{F} = (W, R_\nabla)_{\nabla \in S}$ such that $\mathfrak{G} \models \sigma$. To establish the validity of $\sigma$ in $\mathfrak{F}$, we must prove that for every valuation $V$, we have $\mathfrak{F}, V \models \sigma$. So, let us start with defining a set of valuations for which we already know that $\mathfrak{F}, V \models \sigma$.

**Definition 3.9** *A valuation $V$ is* admissible *if $V(p) \in A$ for all atoms $p$.*

**Lemma 3.10** *For all admissible valuations $V$, $\mathfrak{F}, V \models \sigma$.*

**Proof.**
Immediate by $\mathfrak{G} \models \sigma$ and the definitions. $\square$

We now proceed to define a second kind of valuations, intuitively those forming the *minimal* valuations needed to make the strongly positive formulas, (these being the 'real' antecedent of the Sahlqvist formula $\sigma$,) true in a world of $W$.

**Definition 3.11** *First we define* basic rudimentary formulas, *or short,* br-formulas: *a basic rudimentary formula of length 0 is of the form $\beta(x, y) \equiv x = y$. If $\beta(x, x_n)$ is a basic rudimentary formula of length $n$ and $R_\Diamond$ is the accessibility symbol of a tense diamond, then $\exists x_n(\beta(x, x_n) \wedge R_\Diamond x_n y)$ is a basic rudimentary formula of length $n + 1$.*

*A* rudimentary formula, *or short, an* r-formula, *is of the form*

$$\rho(x_1, \ldots, x_n, y) \equiv \bigvee_{1 \le i \le n} \beta_i(x_i, y),$$

*where every $\beta_i$ is a disjunction of basic rudimentary formulas in $x_i$ and $y$.*
*A subset $X$ of $W$ is* rudimentary *if it is rudimentary in some $w_1, \ldots, w_n \in W$, i.e. for some rudimentary formula $\rho(x_1, \ldots, x_n, y)$, $X = \{v \in W \mid \mathfrak{F} \models \rho(w_1, \ldots, w_n, v)\}$.*
*A valuation $V$ is* rudimentary *if for all atoms $p$, $V(p)$ is rudimentary.*

Note that, intuitively, a basic rudimentary formula $\beta(x, y)$ of length $n$ describes the existence and form of an path from $x$ to $y$ following tense accessibility relations. A rudimentary formula $\rho(x_1, \ldots, x_n, y)$ describes the position of $y$ with respect to $x_1, \ldots, x_n$ in the frame, in terms of 'tense paths' leading from $x_i$ to $y$, for every $x_i$.

**Lemma 3.12** *Rudimentary valuations on discrete general tense frames are admissible.*

**Proof.**
It is sufficient to prove that for every r-formula $\rho(x_1, \ldots, x_n, y)$, the sets $X_{p,\vec{w}} = \{v \in W \mid \mathfrak{F} \models \rho(\vec{w}, v)\}$ are in $A$ for all $n$-tupels $\vec{w} = (w_1, \ldots, w_n)$ of worlds in $W$. Because $A$ is closed under finite unions, it suffices to show the above for *basic* rudimentary formulas. By induction to the length $k$ of a basic formula $\beta(x, y)$ we prove the following claim:

> For every $w \in W$, $X_{\beta,w} \in A$.

For $k = 0$, we have $X_{\beta,w} = \{w\} \in A$ by the discreteness of $\mathfrak{G}$.
For $k = m + 1$, let $\beta(x, y)$ be of the form $\exists x_n(\beta'(x, x_n) \wedge R_\Diamond x_n y)$ where $\Diamond$ is a tense diamond. Now $X_{\beta,w} = \{v \in W \mid \mathfrak{F} \models \beta(w, v)\}$ is the set of worlds $v$ such that there is a $u \in W$ with $\mathfrak{F} \models \beta'(w, u)$ and $\mathfrak{F} \models R_\Diamond uv$.

So $X_{\beta,w}$ contains precisely the worlds having an $R_\Diamond$-predecessor in $X_{\beta',w}$, or

$$X_{\beta,w} = \{v \in W \mid v \text{ has an } R_{\Diamond^{-1}}\text{-successor in } X_{\beta',w}\}.$$

By the induction hypothesis, $X_{\beta',w}$ is in $A$, and by the fact that we are in a *tense* frame, $(R_\Diamond)^{-1}$ is the accessibility relation of $\Diamond^{-1}$. So $X_{\beta,w} = m_{\Diamond^{-1}}(X_{\beta',w}) \in A$, by definition of a general frame (cf. subsection 1.2). $\square$

Note that in the above proof it is essential to have *tense* operators in *tense* frames.

**Lemma 3.13** *Let $\psi$ be an untied formula. Then its first order model-equivalent $\psi^1(x_0)$ is equivalent to*

$$\exists x_1 \ldots x_n\big(\pi \wedge \bigwedge_{i < k} \forall y(\rho_i(\vec{x}, y) \to P_i y) \wedge \bigwedge_{j < m} N_j(u_j)\big).$$

*where the $x_i$'s are distinct variables different from $x_0$, all the variables $u_i$ are among $x_0, \ldots, x_n$, $\pi$ is a conjunction of atomic $L_S(x_0, \ldots, x_n)$-formulas (i.e. atomic accessibility formulas of the form $R_\nabla(x_{i_0}, \ldots, x_{i_{\rho(\nabla)}})$ with $\nabla$ an arbitrary $S$-operator and every variable in $\{x_0, \ldots, x_n\}$), the $\rho_i$'s are suitable rudimentary formulas, and the $N_j$'s are negative.*

**Proof.**
By a straightforward induction to the complexity of untied formulas, cf. Sambin & Vaccaro [35]. $\square$

**Lemma 3.14** *Let $\sigma = \psi_1 \to \psi_2$ be a Sahlqvist formula. Then $\sigma^1(x_0)$ is equivalent to*

$$\forall x_1 \ldots x_n\Big(\big(\pi \wedge \bigwedge_{i < k} \forall y(\rho_i(\vec{x}, y) \to P_i y)\big) \to \gamma_2(x_0, \ldots, x_n)\Big).$$

*where the antecedent is as in the previous lemma and the consequent $\gamma_2$ is some positive formula.*

**Proof.**
Let $N(x_0, \ldots, x_n)$ be the formula $\bigwedge_{j < m} N_j(u_j)$, then $N$ is negative. By the previous lemma, the local model correspondent $\sigma^1(x_0)$ of $\sigma$ is equivalent to

$$\forall x_1 \ldots x_n\Big(\big(\pi \wedge \bigwedge_{i < k} \forall y(\rho_i(\vec{x}, y) \to P_i y) \wedge N\big) \to \psi_2^1(x_0)\Big).$$

So, by moving the negative $N$ from the antecedent to the consequent, we obtain

$$\forall x_1 \ldots x_n\Big(\big(\pi \wedge \bigwedge_{i < k} \forall y(\rho_i(\vec{x}, y) \to P_i y)\big) \to \big(\neg N \vee \psi_2^1(x_0)\big)\Big).$$

where the antecedent is already as desired, and the consequent is positive as it is a disjunction of two positive formulas (cf. lemma 3.8). $\square$

**Proof of Theorem 3.5**
Let $\sigma$ be of the form $\psi_1 \to \psi_2$, where $\psi_1$ is untied and $\psi_2$ is positive. We use the notation of the previous lemmas and set

$$\gamma_1(x_0, \ldots, x_n) \equiv \pi \wedge \bigwedge_{i < k} \forall y(\rho_i(\vec{x}, y) \to P_i y)$$

Obviously, $\sigma^1(x_0)$ is equivalent to $\forall x_1 \ldots x_n(\gamma_1 \to \gamma_2)$, where $\gamma_2$ is positive and hence monotone.
So by the fact that $\mathfrak{G} = (\mathfrak{F}, A) \models \sigma$ we get

$$\text{for all admissible valuations } V, \quad \mathfrak{F}, V \models \forall x_0 \ldots x_n(\gamma_1 \to \gamma_2). \tag{1}$$

Our aim is to show that this implies $\mathfrak{F} \models \sigma$, or equivalently

$$\text{for all valuations } V, \quad \mathfrak{F}, V \models \forall x_0 \ldots x_n(\gamma_1 \to \gamma_2). \tag{$\dagger$}$$

So let a valuation $V$ be given, together with worlds $w_0, w_1, \ldots, w_n \in W$ for which we have

$$\mathfrak{F}, V \models \gamma_1(w_0, w_1, \ldots, w_n). \tag{2}$$

Now let $V^-$ be the rudimentary valuation that precisely 'fits' in $\gamma_1$, i.e. $V^-(p_i) = \{v \in W \mid \mathfrak{F} \models \rho_i(\vec{w}, v)\}$ and $V^-(q) = \emptyset$ if $q$ is not one of the $p_i$. Then

$$\mathfrak{F}, V^- \models \gamma_1(w_0, w_1, \ldots, w_n). \tag{3}$$

$V^-$ is admissible by lemma 3.12, so (1) and (3) give

$$\mathfrak{F}, V^- \models \gamma_2(w_0, w_1, \ldots, w_n). \tag{4}$$

But by (2) and definition of $V^-$, we have $V^- \le V$. Together with the fact that $\gamma_2$ is monotone, this yields

$$\mathfrak{F}, V \models \gamma_2(w_0, w_1, \ldots, w_n), \tag{5}$$

which ensures ($\dagger$). $\square$

As a matter of fact, from this proof it is only a minor step to give the algorithm producing the correspondent $\sigma^*(x_0)$ of an arbitrary (i.e. not necessarily tense) Sahlqvist formula:

**Definition 3.15** *For a Sahlqvist formula $\sigma$, let $\sigma^*(x_0)$ be the $L_S$-formula*

$$\forall x_1 \ldots x_n(\pi \to (\gamma_2(x_0, \ldots, x_n)[\rho_i(\vec{x}, u)/P_i u]))$$

*(i.e. we substitute, everywhere in $\gamma_2$, $\rho_i(\vec{x}, u)$ for an atomic formula of the form $P_i u$, and $\bot$ for any of the other atomic formulas $Qu$.)*

**Proof of Theorem 3.2(iii)** *(SAHLQVIST CORRESPONDENCE).*
We have to prove, for $\sigma$ an arbitrary Sahlqvist formula, $w$ a world in a frame $\mathfrak{F}$:

$$\mathfrak{F}, w_0 \models \sigma \iff \mathfrak{F} \models \sigma^*[x_0 \mapsto w_0].$$

($\Rightarrow$) Let $w_1, \ldots, w_n$ be such that $\mathfrak{F} \models \pi[w_0, \ldots, w_n]$. This implies that, with $V^-$ the valuation such that

$$V^-(p_i) = \{v \in W \mid \mathfrak{F} \models \rho_i(\vec{w}, v)\},$$

we have

$$\mathfrak{F}, V^- \models \pi \wedge \forall y(\rho_i(\vec{x}, y) \to P_i y)[w_0, \ldots, w_n].$$

So by the assumption $\mathfrak{F}, w_0 \models \sigma$, lemma 3.14 gives $\mathfrak{F}, V^- \models \gamma_2(w_0, \ldots, w_n)$. By definition of $V^-$ we immediately obtain

$$\mathfrak{F} \models (\gamma_2(x_0, \ldots, x_n)[\rho_i(\vec{x}, u)/P_i u])[w_0, \ldots, w_n],$$

which is what we desired.

($\Leftarrow$) Here we can copy the proof of Theorem 3.5, after making the observation that now

$$\mathfrak{F}, V^-, w_0 \models \sigma$$

by definition of $\sigma^*$ and the assumption $\mathfrak{F} \models \sigma^*[w_0]$. $\square$

---
