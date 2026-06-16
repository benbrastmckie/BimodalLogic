# Sahlqvist's Theorem for Boolean Algebras with Operators with an Application to Cylindric Algebras

**Maarten de Rijke**$^1$ and **Yde Venema**$^{1,\, 2}$

$^1$ CWI, P.O. Box 4079, 1009 AB Amsterdam
$^2$ Department of Mathematics and Computer Science, Free University, Amsterdam, de Boelelaan 1081, 1081 HV Amsterdam

Version 5, June 1994

## Abstract

For an arbitrary similarity type of Boolean Algebras with Operators we define a class of *Sahlqvist identities*. Sahlqvist identities have two important properties. First, a Sahlqvist identity is valid in a complex algebra if and only if the underlying relational atom structure satisfies a first-order condition which can be effectively read off from the syntactic form of the identity. Second, and as a consequence of the first property, Sahlqvist identities are *canonical*, that is, their validity is preserved under taking canonical embedding algebras. Taken together, these properties imply that results about a Sahlqvist variety V can be obtained by reasoning in the elementary class of canonical structures of algebras in V.

We give an example of this strategy in the variety of Cylindric Algebras: we show that an important identity called *Henkin's equation* is equivalent to a simpler identity that uses only one variable. We give a conceptually simple proof by showing that the first-order correspondents of these two equations are equivalent over the class of cylindric atom structures.

## 1. Introduction

The aim of this note is to explain how a well-known result from Modal Logic, Sahlqvist's Theorem, can be applied in the theory of Boolean Algebras with Operators to obtain a large class of identities, called *Sahlqvist identities*, that are preserved under canonical embedding algebras. These identities can be specified as follows. Let $\sigma = \{ f_i : i \in I \}$ be a set of (normal) additive operations. Let an *untied term* over $\sigma$ be a term that is either

(i) negative (i.e., in which every variable occurs in the scope of an odd number of complementation signs $-$ only), or

(ii) of the form $g_1(g_2 \ldots (g_n(x)) \ldots)$, where the $g_i$s are duals of unary elements of $\sigma$ (i.e., $g_i$ is defined by $g_i(x) = -f_i(-x)$ for some unary operator in $\sigma$), or

(iii) closed (i.e., without occurrences of variables; note that this case is covered by (i)), or

(iv) obtained from terms of type (i), (ii) or (iii) by applying $+$, $\cdot$ and elements of $\sigma$ only.

Then, an equality is called a *Sahlqvist equality* if it is of the form $s = 1$, where $s$ is obtained from complemented untied terms $-u$ by applying duals of elements of $\sigma$ to terms that have no variables in common, and $\cdot$ only.

Before proceeding, let us give some examples and non-examples of Sahlqvist identities in algebraic logic. First of all, the axioms governing normal, additive Boolean Algebras with Operators $\{ f_i : i \in I \}$ ($f_i(x + y) = f_i x + f_i y$ and $f_i 0 = 0$) are Sahlqvist identities. This should be obvious for the later axiom, while the former is equivalent to

$$f_i(x + y) \cdot -(f_i x + f_i y) \leq 0 \quad \text{and} \quad (f_i x + f_i y) \cdot -f_i(x + y) \leq 0,$$

or

$$-[f_i(x + y) \cdot -(f_i x + f_i y)] = 1 \quad \text{and} \quad -[(f_i x + f_i y) \cdot -f_i(x + y)] = 1.$$

Now, finally, both $f_i(x + y) \cdot -(f_i x + f_i y)$ and $(f_i x + f_i y) \cdot -f_i(x + y)$ are untied terms, as required.

Next, recall that *closure algebras* are normal, additive Boolean algebras with a single operator $(\cdot)^c$ satisfying

$$x \leq x^c \quad \text{and} \quad x^{cc} \leq x^c.$$

These inequalities are equivalent to $-[x \cdot -x^c] = 1$ and $-[x^{cc} \cdot -x^c] = 1$, respectively; and clearly, both of these are Sahlqvist identities.

As a further example, *all* axioms for both relation and cylindric algebras can be brought in a Sahlqvist form.

| RA | CA |
|---|---|
| $(x + y); z = x; z + y; z$ | $c_i 0 = 0$ |
| $(x + y)^{\smile} = x^{\smile} + y^{\smile}$ | $x \leq c_i x$ |
| $(x; y); z = x; (y; z)$ | $c_i(x \cdot c_i y) = c_i x \cdot c_i y$ |
| $x; 1' = x$ | $c_i c_j x = c_j c_i x$ |
| $(x^{\smile})^{\smile} = x$ | $d_{ii} = 1$ |
| $(x; y)^{\smile} = y^{\smile}; x^{\smile}$ | $d_{ij} = c_k(d_{ik} \cdot d_{kj})$ |
| $x^{\smile}; -(x; y) \leq -y$ | $c_i(d_{ij} \cdot x) \cdot c_i(d_{ij} \cdot -x) = 0$ |

Let's consider the RA axioms first. Using the tricks demonstrated above, it should be obvious by now that the first six RA axioms are equivalent to (pairs of) Sahlqvist identities. As for the last RA axiom, Johan van Benthem observed that it has a Sahlqvist equivalent

$$-[(x^{\smile}; -(x; y)) \cdot y)] = 1.$$

Now, what about the CA axioms? The first five CA axioms are clearly (equivalent to) Sahlqvist identities, while the sixth one is equivalent to the conjunction of $d_{ij} \cdot -c_k(d_{ik} \cdot d_{kj}) = 0$ and $-d_{ij} \cdot c_k(d_{ik} \cdot d_{kj}) = 0$, or, equivalently, to the conjunction of $-[d_{ij} \cdot -c_k(d_{ik} \cdot d_{kj})] = 1$ and $-[-d_{ij} \cdot c_k(d_{ik} \cdot d_{kj})] = 1$. And the latter two are Sahlqvist identities. The last CA axiom is equivalent to $-[c_i(d_{ij} \cdot x) \cdot c_i(d_{ij} \cdot -x)] = 1$, which, again, is a Sahlqvist identity.

Let's move on now to an example of an identity that is not (equivalent to) Sahlqvist equations. There are several reasons why an identity $-t = 1$ need not be a Sahlqvist identity, one of which is that $t$ is a non-negative term that fails to be an untied one because some additive operator $f$ in $t$ is in the scope of a dual operator $g$. As an example demonstrating that such violations of the Sahlqvist requirements may quickly lead to *failure* of preservation of canonical embedding algebras, consider the so-called *McKinsey axiom* from modal logic:

$$\Box\Diamond p \to \Diamond\Box p \quad \text{or} \quad \Box\Diamond x \cdot \Diamond\Box x = \Box\Diamond x,$$

(Note that the latter is an identity between positive terms.) This axiom/identity is not a Sahlqvist identity as the subterm $\Box\Diamond x$ is not an untied one, precisely because of the above reason. Due to a recent result of Goldblatt's the McKinsey axiom is not preserved under canonical embedding algebras (cf. [4, Cor. 5]).

In fact, Sahlqvist proved *two* results concerning Sahlqvist identities. Reformulated in algebraic terms, the *correspondence* theorem states the existence of an algorithm that, given a Sahlqvist identity $\eta$, produces a first order formula $\eta^s$ such that for any relational structure $\mathfrak{F}$, $\eta^s$ holds in $\mathfrak{F}$ iff $\eta^s$ holds in the complex algebra $\mathfrak{Cm}\,\mathfrak{F}$ of $\mathfrak{F}$. In the *canonicity* part it is proved that Sahlqvist identities are canonical, i.e. they are preserved under taking canonical embedding algebras. The main ideas behind these results can already be found in Jonsson-Tarski [9]. In particular, with some additional effort the canonicity theorem can be derived as a consequence of Theorem 3.10 of that paper. (For a more detailed and up to date exposition of this matter we refer to Jonsson [8], which also contains new material.)

Nevertheless, we feel that algebraic logicians might find some new and potentially interesting ideas in the modal side of the field. Here we are thinking mainly of the correspondence part of the theory. Basically, its effect is that in the setting of Sahlqvist identities, there are useful results concerning relational structures that one may transfer to the corresponding variety of BAO's. For instance, the equivalence of two equations may be proved or disproved by reasoning on *modal frames* (or *atom structures*) rather then by manipulating these equations themselves. Note that this strategy of reducing algebraic issues to questions about atom structures has appeared before in the literature on algebraic logic, cf. [1, 7, 10]. The intended contribution of this paper is to show how Sahlqvist's theorem offers a more general, systematic and unified perspective on this strategy.

As this note is aimed primarily at algebraists, we assume that the reader is familiar with basic algebraic notions and facts; for algebraic details not explained in this note we refer the reader to [3]. We will be somewhat more explicit concerning the modal logical results and definitions we will need; most of them will be presented in Section 2. After that, in Section 3, we describe the modal counterparts of the above Sahlqvist equalities, and partially prove a Sahlqvist Theorem, which says that Sahlqvist formulas are both *canonical* and *first order*. From this the preservation of Sahlqvist equalities under canonical embedding algebras is easily derived. Finally, Section 4, which is essentially a part of the second author's dissertation [16], contains a detailed demonstration of the usefulness of the Sahlqvist Theorem. By reasoning on the modal frames, we can give a very simple proof that Henkin's equation in cylindric algebras is equivalent to an identity in a simpler form. Up till now, no purely algebraic proof for this simplification is known to us.

The reader is advised to skip Section 2 upon a first reading, and only to return to it later on to look up a definition.

We would like to thank Johan van Benthem for stressing the importance of Sahlqvist's Theorem, Andreka Hajnal, Nemeti Istvan and Sain Ildiko for encouraging us to write this note, and Prof. B. Jonsson for helpful suggestions concerning the earlier report version of this paper [12].

## 2. Preliminaries

A *Boolean algebra with operators* (BAO) is an algebra $\mathfrak{B}$ of type $\{ +, \cdot, -, 0, 1 \} \cup \{ f_i : i \in I \}$ such that $(B, +, \cdot, -, 0, 1)$ is a Boolean algebra, and the operators $\{ f_i : i \in I \}$ are *(finitely) additive* (join preserving) in every argument; a BAO is called *normal* if for every $f_i$, $f_i(\vec{x}) = 0$ whenever one of the terms $x_j = 0$.

Let us quickly move on to the Stone Representations of BAO's, the so-called general frames. First, a *modal similarity type* is a pair $S = (O, \rho)$, where $O = \{ \nabla_i : i \in I \}$ is a set of *modal operators*, and $\rho$ is a rank function for $O$. As variables ranging over modal operators we use $\nabla, \nabla_1, \ldots$; for monadic modal operators we use $\Diamond, \Diamond_1, \ldots$. For $\nabla_i \in S$ its *dual* operator $\lhd_i$ is defined as $\lhd_i(\phi_1, \ldots, \phi_{\rho(i)}) \equiv \neg\nabla_i(\neg\phi_1, \ldots, \neg\phi_{\rho(i)})$; the dual of a monadic operator $\Diamond_i$ is denoted $\Box_i$. A *modal language* is a pair $M = (S, Q)$, where $S$ is a modal similarity type, and $Q$ is a set whose elements are called proposition letters. From the modal and Boolean constants, and the proposition letters, the modal formulas are built up in the obvious way, using $\neg$, $\wedge$, and the operators in $S$. When no confusion arises we write $M(S)$ or even $M$ rather than $M(S, Q)$.

A *general frame* $\mathfrak{F}$ of similarity type $S$ is a tuple $(W, \{ R_i : i \in I \}, \mathcal{W})$ where $W \neq \emptyset$, $R_i \subseteq W^{\rho(i)+1}$, and $\mathcal{W} \subseteq \mathrm{Sb}(W)$ contains $\emptyset$, and is closed under $\cdot$, $-$, and the operators $\{ f_{R_i} : i \in I \}$, where $f_{R_i} : \mathrm{Sb}(W)^{\rho(i)} \to \mathrm{Sb}(W)$ is defined by

$$(1) \qquad f_{R_i}(Y_1, \ldots, Y_{\rho(i)}) = \left\{ x_0 : \exists x_1 \ldots x_{\rho(i)} \left( R_i(x_0, x_1, \ldots, x_{\rho(i)}) \wedge \bigwedge_{1 \leq j \leq \rho(i)} (x_i \in Y_i) \right) \right\}.^1$$

> $^1$ Algebraists may be accustomed to seeing the argument places reversed in the definition of the function $f_{R_i}(Y_1, \ldots, Y_{\rho(i)})$ as $\{ x_0 : \exists x_1 \ldots x_{\rho(i)} (R_i(x_0, x_1, \ldots, x_{\rho(i)}) \wedge \bigwedge_{1 \leq j \leq \rho(i)} (x_i \in Y_i)) \}$ in (1). Being modal logicians we like to think that the modal notation is the more elegant one.

For future use we also define $g_{R_i} : \mathrm{Sb}(W)^{\rho(i)} \to \mathrm{Sb}(W)$, by putting $g_{R_i}(Y_1, \ldots, Y_{\rho(i)}) = -f_{R_i}(-Y_1, \ldots, -Y_{\rho(i)})$. A *Kripke frame* or *atom structure* of similarity type $S$ is a tuple $(W, \{ R_i : i \in I \})$, with $W$ and $\{ R_i : i \in I \}$ as before. A general frame $\mathfrak{F}$ defines a Kripke frame $\mathfrak{F}_\#$ via the forgetful functor $(\cdot)_\# : (W, \{ R_i : i \in I \}, \mathcal{W}) \mapsto (W, \{ R_i : i \in I \})$. A Kripke frame $\mathfrak{F}$ defines the general frame $\mathfrak{F}^\#$ via $(\cdot)^\# : (W, \{ R_i : i \in I \}) \mapsto (W, \{ R_i : i \in I \}, \mathrm{Sb}(W))$.

Given a general frame $\mathfrak{F} = (W, \{ R_i : i \in I \}, \mathcal{W})$ its *complex algebra* is the BAO $\mathfrak{F}^+ = (\mathcal{W}, \cup, \cap, \emptyset, W, -, \{ f_{R_i} : i \in I \})$, where $f_{R_i} : \mathrm{Sb}(W)^{\rho(i)} \to \mathrm{Sb}(W)$ is defined as in (1).

Given a BAO $\mathfrak{B}$ with operators $\{f_i : i \in I\}$, the general frame $\mathfrak{B}_+$ is the tuple $(X_\mathfrak{B}, \{ R_{f_i} : i \in I \}, \mathcal{W})$, where $X_\mathfrak{B}$ is the set of ultrafilters on $\mathfrak{B}$, $R_{f_i} \subseteq X_\mathfrak{B}^{\rho(i)+1}$ is defined by

$$R_{f_i}(a_0, a_1, \ldots, a_{\rho(i)}) \quad \text{iff} \quad \forall j\, (1 \leq j \leq \rho(i) \to x_j \in a_j) \text{ implies } f_i(x_1, \ldots, x_{\rho(i)}) \in a_0,$$

and $\mathcal{W} \subseteq \mathrm{Sb}(X_\mathfrak{B})$ is $\{ \hat{x} : x \in B \}$ for $\hat{x} = \{ a \in X_\mathfrak{B} : x \in a \}$. The *canonical structure* $\mathfrak{Cs}\,\mathfrak{B}$ of $\mathfrak{B}$ is the structure $(\mathfrak{B}_+)_\#$. By definition the complex algebra of the canonical structure of $\mathfrak{B}$ is called the *canonical embedding algebra* of $\mathfrak{B}$: $\mathfrak{Em}\,\mathfrak{B} = (\mathfrak{Cs}\,\mathfrak{B})^+$.$^2$ By a *canonical* variety we mean one that is closed under canonical embedding algebras.

> $^2$ In [6] the canonical embedding algebra of $\mathfrak{B}$ is called the *Stone extension* of $\mathfrak{B}$; in [9] and [7] it is called the *perfect extension* of $\mathfrak{B}$.

A *valuation* on a general frame $\mathfrak{F}$ is a function $V$ taking proposition letters to elements of $\mathcal{W}$; a valuation on a Kripke frame $\mathfrak{F}$ is a valuation on $\mathfrak{F}^\#$. In algebraic terms: a valuation is an *assignment* to the variables of elements of $\mathcal{W}$, where $\mathcal{W}$ is the carrier of a subalgebra of $\mathfrak{F}^\#$. Truth of a modal formula in a *model* $(\mathfrak{F}, V)$ is then defined as follows: $(\mathfrak{F}, V), w_0 \models p$ iff $w_0 \in V(p)$; $(\mathfrak{F}, V), w_0 \models \neg\phi$ iff $(\mathfrak{F}, V), w_0 \not\models \phi$; $(\mathfrak{F}, V), w_0 \models \phi \wedge \psi$ iff both $(\mathfrak{F}, V), w_0 \models \phi$ and $(\mathfrak{F}, V), w_0 \models \psi$; and $(\mathfrak{F}, V), w_0 \models \nabla_i(\phi_1, \ldots, \phi_{\rho(i)})$ iff $\exists w_1, \ldots, w_{\rho(i)}\, (R_i(w_0, w_1, \ldots, w_{\rho(i)}) \wedge \bigwedge_{1 \leq j \leq \rho(i)} (\mathfrak{F}, V), w_j \models \phi_j)$. We write $(\mathfrak{F}, V) \models \phi$ for: for all $w \in W$, $(\mathfrak{F}, V), w \models \phi$; $\mathfrak{F}, w \models \phi$ is short for: for all valuations $V$ on $\mathfrak{F}$, $(\mathfrak{F}, V), w \models \phi$; and $\mathfrak{F} \models \phi$ is short for: for all $w \in W$, $\mathfrak{F}, w \models \phi$.

A modal formula $\phi$ in $n$ proposition letters induces an $n$-ary polynomial $h_\phi(x_1, \ldots, x_n)$ which may be defined as follows:

$$\begin{aligned}
h_{p_j}(x_1, \ldots, x_n) &\equiv x_j \\
h_{\neg\phi}(x_1, \ldots, x_n) &\equiv -h_\phi(x_1, \ldots, x_n) \\
h_{\phi \wedge \psi}(x_1, \ldots, x_n) &\equiv h_\phi(x_1, \ldots, x_n) \cdot h_\psi(x_1, \ldots, x_n) \\
h_{\nabla_i(\phi_1, \ldots, \phi_{\rho(i)})}(x_1, \ldots, x_n) &\equiv f_{R_i}(h_{\phi_1}(x_1, \ldots, x_n), \ldots, h_{\phi_{\rho(i)}}(x_1, \ldots, x_n)).
\end{aligned}$$

And conversely, each polynomial in a similarity type of BAO's is of the form $h_\varphi$ for some modal formula $\phi$ in a modal language of the appropriate type. This identification of formulas and terms is made explicit in the following proposition.

**Proposition 2.1.** *Let $S$ be a modal similarity type. Let $\mathfrak{F}$ be a general frame of type $S$. Let $\phi$ be a formula in $M(S)$. Then $\mathfrak{F} \models \phi$ iff $(\mathfrak{F})^+ \models h_\phi = 1$.*

A *(normal) modal logic* in a language $M(S)$ is a subset $\Lambda$ of the set of formulas in $M(S)$ that contains as axioms all propositional tautologies (PL), as well as

$$(DB) \qquad \nabla_i(p_1, \ldots, p_{j-1}, p, p_{j+1}, \ldots, p_{\rho(i)}) \vee \nabla_i(p_1, \ldots, p_{j-1}, p', p_{j+1}, \ldots, p_{\rho(i)}) \leftrightarrow \nabla_i(p_1, \ldots, p_{j-1}, p \vee p', p_{j+1}, \ldots, p_{\rho(i)}),$$

and that is closed under the following derivation rules:

- (MP) if $\phi, \phi \to \psi \in \Lambda$ then $\psi \in \Lambda$
- (UG) if $\phi \in \Lambda$ then $\neg\nabla_i(\phi_1, \ldots, \phi_{j-1}, \neg\phi, \phi_{j+1}, \ldots, \phi_{\rho(i)}) \in \Lambda$
- (SUB) if $\phi \in \Lambda$ then all substitution instances of $\phi$ are in $\Lambda$.

For a logic $\Lambda$ a *canonical general frame* for $\Lambda$ is defined by $\mathfrak{F}_\Lambda(\alpha) = (\mathfrak{A}_\Lambda(\alpha))_+$, where $\mathfrak{A}_\Lambda(\alpha)$ is the free algebra (on $\alpha$ generators) of the variety $\mathsf{V}_\Lambda$, where $\mathfrak{A} \in \mathsf{V}_\Lambda$ iff $\mathfrak{A} \models h_\varphi = 1$, for all $\varphi \in \Lambda$. For a class of general or Kripke frames K, let $\mathrm{Th}(\mathsf{K}) = \{ \phi : \text{for all } \mathfrak{F} \in \mathsf{K}, \mathfrak{F} \models \phi \}$. We call a logic $\Lambda$ *sound* with respect to a class of general or Kripke frames K if $\Lambda \subseteq \mathrm{Th}(\mathsf{K})$, and *complete* with respect to K if $\mathrm{Th}(\mathsf{K}) \subseteq \Lambda$. A logic $\Lambda$ is called *canonical* if $(\mathfrak{F}_\Lambda(\alpha))_\# \models \Lambda$, for every canonical general frame $\mathfrak{F}_\Lambda(\alpha)$.

$L_0(S)$ is the first order language of type $S$; it has relation symbols $R_i$ ($i \in I$) of arity $\rho(i) + 1$. $L_1(S)$ is $L_0(S)$ extended with unary predicate symbols $P_j$ corresponding to the proposition letters of our modal language. $L_2(S)$ is the language of monadic second order logic with relation symbols $R_i$ ($i \in I$) of arity $\rho(i) + 1$, and variables $P_j$s ranging over sets. A modal formula $\phi$ *locally corresponds* to a formula $\alpha(x)$ if for all Kripke frames $\mathfrak{F}$ of the appropriate type, $\mathfrak{F}, w \models \phi$ iff $\mathfrak{F} \models \alpha[w]$. A modal formula $\phi$ *corresponds* to a sentence $\alpha$ if for all Kripke frames $\mathfrak{F}$ of the appropriate type, $\mathfrak{F} \models \varphi$ iff $\mathfrak{F} \models \alpha$. When interpreted on frames modal formulas correspond to $L_2(S)$-formulas (cf. [2]).

## 3. A Sahlqvist Theorem

To describe the modal counterparts of the earlier Sahlqvist equalities we need the following definition.

**Definition 3.1.** Let $S$ be a modal similarity type. *Positive* and *negative* occurrences of a proposition letter $p$ are defined as usual by: (i) $p$ occurs positively in $p$, (ii) a positive (negative) occurrence of $p$ in $\phi$ is a negative (positive) occurrence of $p$ in $\neg\phi$ and in $\phi \to \psi$, and a positive (negative) one in $\phi \vee \psi$, $\phi \wedge \psi$, $\nabla_i(\phi_1, \ldots, \phi, \ldots, \phi_{\rho(i)})$, $\lhd_i(\phi_1, \ldots, \phi, \ldots, \phi_{\rho(i)})$ ($\nabla_i \in S$). A formula $\phi$ in $M(S)$ is *positive* (*negative*) if every proposition letter occurs only positively (negatively) in $\phi$. $\phi$ is *monotone* in the proposition letter $p$ if for every model $(\mathfrak{F}, V)$ and every valuation $V'$ on $\mathfrak{F}$ with $V(p) \subseteq V'(p)$ and otherwise the same as $V$, $(\mathfrak{F}, V), w \models \varphi$ implies $(\mathfrak{F}, V'), w \models \varphi$.

Note that in a positive formula *negations* of modal or Boolean constants are allowed. Also, if $\phi$ is positive then $\phi$ is monotone in all proposition letters.

**Definition 3.2.** Fix a modal similarity type $S$. A formula $\phi$ in $M(S)$ is a *Sahlqvist antecedent* if it is built up from formulas that are either negative, closed (i.e., without occurrences of proposition letters), or of the form $\Box_{i_1} \ldots \Box_{i_n} p$, using only $\vee, \wedge$ and $\nabla_i$, where $\Diamond_{i_1}, \ldots, \Diamond_{i_n}, \nabla_i \in S$.

Define the set of *Sahlqvist formulas* in $M(S)$ as being the smallest set $X$ such that if $\phi$ is a Sahlqvist antecedent, and $\psi$ is a positive formula, then $\phi \to \psi \in X$; if $\sigma_1, \sigma_2 \in X$ then $\sigma_1 \wedge \sigma_2 \in X$; and if $\sigma_1, \ldots, \sigma_{\rho(i)} \in X$ have no proposition letters in common, then $\lhd_i(\sigma_1, \ldots, \sigma_{\rho(i)}) \in X$.

For a modal similarity type $S$ that contains only unary operators several definitions exist of what it is for a formula in $M(S)$ to be a Sahlqvist formula; however, all are equivalent to (or are covered by) the restriction of 3.2 to such similarity types.

We believe that the generalization to arbitrary similarity types is in fact ours. One may wonder whether this is the obvious generalization from the 'unary case', e.g., why are boxes (i.e., duals of unary normal, additive operations) allowed in Sahlqvist antecedents, while for $n \geq 2$ duals of $n$-ary operations in $S$ are not? The reason why we are interested in Sahlqvist formulas is that they may be shown to be complete and to define certain first order properties of the underlying relations in (generalized) frames. A look at the kind of formulas forbidden in Sahlqvist antecedents in the unary case in order to guarantee these properties, shows that they typically include combinations of the form $\Box(\ldots \vee \ldots)$, or, in first order terms, $\forall(\ldots \vee \ldots)$. But these are precisely the combinations that pop up when we have $n$-ary boxes ($n \geq 2$) around! (In fact, if $\nabla$ is a binary modal operator, and $\lhd$ is its dual, then $(p \lhd p) \lhd p \to (p \nabla p) \nabla p$ may already be shown to be non-elementary.)

Before proving an important property of Sahlqvist formulas we recall that for a binary relation $R$, $\breve{R} = \{ (y, x) : Rxy \}$. To each modal formula $\phi$ we associate a set operator $F^\phi$ as follows. Let $P_1, \ldots, P_k$ be sets and let $\vec{P}$ abbreviate $P_1, \ldots, P_k$. $F^{p_j} = P_j$ ($1 \leq j \leq k$), while $F^{\neg\phi}(\vec{P}) = (F^\phi(\vec{P}))^c$, and $F^{\phi \wedge \psi}(\vec{P}) = F^\phi(\vec{P}) \cap F^\psi(\vec{P})$. $F^{\nabla_i(\phi_1, \ldots, \phi_{\rho(i)})}(\vec{P}) = f_{R_i}(F^{\phi_1}(\vec{P}), \ldots, F^{\phi_{\rho(i)}}(\vec{P}))$, while $F^{\lhd_i(\phi_1, \ldots, \phi_{\rho(i)})}(\vec{P}) = g_{R_i}(F^{\phi_1}(\vec{P}), \ldots, F^{\phi_{\rho(i)}}(\vec{P}))$. We assume that the set operator corresponding to Boolean or modal constants is provided by the context in which these constants occur.

**Theorem 3.3.** *Let $S$ be a modal similarity type. Let $\chi$ be a Sahlqvist formula in $M(S)$. Then $\chi$ corresponds to an $L_0(S)$-sentence $\alpha_\chi$ effectively obtainable from $\chi$.*

*Proof.* This is more or less similar to the proof of [13, Theorem 8] (cf. also [2, Theorem 9.10]). Assume that $\chi$ has the form $\phi \to \psi$.

Let $p_1, \ldots, p_k$ be the proposition letters occurring in $\chi$. Having $\mathfrak{F} = (W, \{ R_i : i \in I \}) \models \chi$ means having $\mathfrak{F} \models \forall\vec{P}\,\forall x\, (x \in F^\chi(\vec{P}))$. By assumption the latter formula has the form

$$(2) \qquad \forall\vec{P}\,\forall x\left( x \in F^\phi(\vec{P}) \to x \in F^\psi(\vec{P}) \right),$$

where $\phi$ is a Sahlqvist antecedent, and $\psi$ is a positive formula. Next, using such equivalences as

$$(3) \qquad \forall \cdots \left( (\Phi \wedge x \in F^{\phi_1 \vee \phi_2}(\vec{P})) \to \Psi \right) \leftrightarrow \bigwedge_{j=1,2} \forall \cdots \left( (\Phi \wedge x \in F^{\phi_j}(\vec{P})) \to \Psi \right),$$

$$(4) \qquad \forall \cdots \left( (\Phi \wedge x \in F^{\nabla_i(\phi_1, \ldots, \phi_{\rho(i)})}(\vec{P})) \to \Psi \right) \leftrightarrow$$
$$\forall \cdots \forall y_1 \ldots y_{\rho(i)} \left( (\Phi \wedge R_i x y_1 \ldots y_{\rho(i)} \wedge \bigwedge_j (y_j \in F^{\phi_j}(\vec{P}))) \to \Psi \right),$$

and

$$(5) \qquad \forall \cdots \left( (\Phi \wedge x \in F^\nu(\vec{P})) \to \Psi \right) \leftrightarrow \forall \cdots \left( \Phi \to (\Psi \vee x \in F^{\neg\nu}(\vec{P})) \right),$$

(2) can be rewritten as a conjunction of formulas of the form

$$(6) \qquad \forall\vec{P}\,\forall x\,\forall\vec{y}\,\vec{z}\left( \Phi \wedge \bigwedge_{j=1}^{k} \bigwedge_{l=1}^{m_j} (y_{lj} \in g_{R_{n_{lj}}} \ldots g_{R_{1_{lj}}}(P_j)) \to \bigvee_{j=1}^{h} (z_j \in F^{\psi_j}(\vec{P})) \right),$$

where $\Phi$ is a quantifier free $L_0$-formula ordering its variables in a certain way, and where all the $\psi_j$s are monotone. If a predicate variable $P$ occurs only in the consequent $\bigvee_{j=1}^{h}(z_j \in F^{\psi_j}(\vec{P}))$ in (6), then, by the monotonicity of the $\psi_j$s, it can be replaced by $\bot$, and the quantifier binding $P$ may be deleted. Thus we may assume that every predicate letter occurs in the consequent of (6) only if it occurs in the antecedent of (6).

By an easy argument we have that $\bigwedge_{l=1}^{m_j}(y_{lj} \in g_{R_{n_{lj}}} \ldots g_{R_{1_{lj}}}(P_j))$ if and only if we have $\bigcup_{l=1}^{m_j} f_{\breve{R}_{1_{lj}}} \ldots f_{\breve{R}_{n_{lj}}}(\{ y_{lj} \}) \subseteq P_j$. Thus by universal instantiation (6) implies the first order formula

$$(7) \qquad \forall x\,\forall\vec{y}\,\vec{z}\left( \Phi \to \bigvee_{j=1}^{h} z_j \in F^{\psi_j}\!\left( \bigcup_{l=1}^{m_1} f_{\breve{R}_{1_{l1}}} \ldots f_{\breve{R}_{n_{l1}}}(\{ y_{l1} \}), \ldots, \bigcup_{l=1}^{m_k} f_{\breve{R}_{1_{lk}}} \ldots f_{\breve{R}_{n_{lk}}}(\{ y_{lk} \}) \right) \right).$$

But, conversely, by the monotonicity of the functions $F^{\psi_j}$ (7) implies (6), and we are done.

To prove the general case one may argue inductively. If the Sahlqvist formulas $\chi_1, \chi_2$ have been shown to correspond to $\alpha_1, \alpha_2$, respectively, then $\chi_1 \wedge \chi_2$ corresponds to $\alpha_1 \wedge \alpha_2$; and if $\chi_1, \ldots, \chi_{\rho(i)}$ are Sahlqvist formulas that have no proposition letters in common, and that have been shown to correspond to $\forall x\, \alpha_1, \ldots, \forall x\, \alpha_{\rho(i)}$, then $\lhd_i(\chi_1, \ldots, \chi_{\rho(i)})$ corresponds to $\forall x\,\vec{y}\, (R_i x y_1 \ldots y_{\rho(i)} \to \alpha_1(y_1) \vee \ldots \vee \alpha_{\rho(i)}(y_{\rho(i)}))$. $\dashv$

Two remarks are in order. First, in the above result we may in fact replace 'corresponds' by 'locally corresponds'. But given the algebraic application we have in mind the *global* version is more natural. Second, although the algorithm in the above general proof may seem somewhat intractable or even obscure, in particular examples it is quite manageable, as is witnessed in Section 4.

**Theorem 3.4.** *Let $S$ be a modal similarity type. For $j \in J$, let $\chi_j$ be Sahlqvist formulas in $M(S)$. Let $\Lambda$ be the modal logic axiomatized by $\{ \chi_j : j \in J \}$. Then $\Lambda$ is canonical. Hence $\Lambda$ is complete with respect to the class of Kripke frames defined by $\{ \alpha_{\chi_j} : j \in J \}$.*

*Proof.* There are various ways to prove this result. The case where $S$ contains only unary modal operators is [13, Theorem 19]. To prove the general case one may use the same arguments together with the canonical frame construction for modal logics of arbitrary similarity type as found in [16, Appendix A]. An alternative proof of the unary case may be found in [14]. Finally, Goldblatt [5] proves that any variety of BAOs is canonical whenever it is generated by a frame class which is closed under ultraproducts; therefore, Theorem 3.4 is an immediate consequence of Theorem 3.3. $\dashv$

We leave it to the reader to check that every Sahlqvist formula induces a Sahlqvist identity, and conversely.

**Theorem 3.5.** *Let $\Sigma$ be a set of Sahlqvist equalities. Let $\mathsf{V}_\Sigma$ be the variety defined by $\Sigma$. Then $\mathsf{V}_\Sigma$ is canonical.*

*Proof.* Let $\widehat{\Sigma}$ be the set of modal translations of the elements of $\Sigma$. So $\widehat{\Sigma}$ is a set of Sahlqvist formulas. Now, to prove the theorem, let $\mathfrak{B} \in \mathsf{V}_\Sigma$. Let $\mathfrak{A}_\Sigma(|B|)$ be the free $\Sigma$-algebra on $|B|$ generators. Then $\mathfrak{A}_\Sigma(|B|) \twoheadrightarrow \mathfrak{B}$, and hence $\mathfrak{Em}\,\mathfrak{A}_\Sigma(|B|) \twoheadrightarrow \mathfrak{Em}\,\mathfrak{B}$, by [3, Corollary 3.2.5(6)]. So we are done once we have shown that $\mathfrak{Em}\,\mathfrak{A}_\Sigma(|B|) \in \mathsf{V}_\Sigma$.

**Figure 1.**

$$\begin{array}{ccc}
\mathfrak{B} & \twoheadleftarrow & \mathfrak{A}_\Sigma(|B|) & \qquad \mathfrak{A}_\Sigma(|B|)_+ \\
\downarrow & & \downarrow & \qquad \vdots \downarrow \\
\mathfrak{Em}\,\mathfrak{B} & \twoheadleftarrow & \mathfrak{Em}\,\mathfrak{A}_\Sigma(|B|) & \qquad (\mathfrak{A}_\Sigma(|B|)_+)_\#
\end{array}$$

Since $\mathfrak{A}_\Sigma(|B|) \models \Sigma$, $\mathfrak{A}_\Sigma(|B|)_+ \models \widehat{\Sigma}$. So by 3.4 $\mathfrak{Cs}\,\mathfrak{A}_\Sigma(|B|) = (\mathfrak{A}_\Sigma(|B|)_+)_\# \models \widehat{\Sigma}$. But then $\mathfrak{Em}\,\mathfrak{A}_\Sigma(|B|) = ((\mathfrak{A}_\Sigma(|B|)_+)_\#)^+ \models \Sigma$, i.e. $\mathfrak{Em}\,\mathfrak{A}_\Sigma(|B|) \in \mathsf{V}_\Sigma$. $\dashv$

**Remark 3.6.** For a description of the current state of the art concerning canonicity and the relation with notions like first-order definability, we refer the reader to [4].

**Remark 3.7.** Although Theorem 3.5 describes a large part of the class of identities that are preserved under canonical embedding algebras, the Sahlqvist identities do not describe this class exhaustively. The conjunction of the McKinsey axiom ($\Box\Diamond p \to \Diamond\Box p$) and the transitivity axiom ($\Diamond\Diamond p \to \Diamond p$) from modal logic is a case in point: this formula is not a Sahlqvist formula, but it is preserved under canonical embedding algebras.

As an application of Theorems 3.3 and 3.5, let us substantiate our earlier claim that when dealing with Sahlqvist equations we can move back and forth between modal frames and algebras, in the sense that to prove that two Sahlqvist equations are equivalent over a canonical variety V, it suffices to establish the equivalence (in $\mathbf{At}\,\mathsf{V}$) of their first order translations. This means that reasoning can be done in the Kripke frames, which is usually much easier than manipulating algebraic equations.

**Theorem 3.8.** *Let $\mathsf{V}$ be a canonical variety, and $\eta_1$ and $\eta_2$ two Sahlqvist equations with first order correspondents $\alpha_1$ and $\alpha_2$. Then*

$$\mathbf{At}\,\mathsf{V} \models \alpha_1 \leftrightarrow \alpha_2 \iff \mathsf{V} \models \eta_1 \leftrightarrow \eta_2.$$

*Proof.* From left to right: let $\mathfrak{A}$ be an algebra in $\mathsf{V}$ with $\mathfrak{A} \models \eta_i$. By the fact that $\eta_i$ is a Sahlqvist equation, $\eta_i$ holds in $\mathfrak{Em}\,\mathfrak{A} = (\mathfrak{Cs}\,\mathfrak{A})^+$. This gives $\mathfrak{Cs}\,\mathfrak{A} \models \alpha_i$, so by assumption $\mathfrak{Cs}\,\mathfrak{A} \models \alpha_j$. But then again $\mathfrak{Em}\,\mathfrak{A} \models \eta_j$, so $\eta_j$ holds in $\mathfrak{A} \leq \mathfrak{Em}\,\mathfrak{A}$.

From right to left: let $\mathfrak{F}$ be a frame in $\mathbf{At}\,\mathsf{V}$ with $\mathfrak{F} \models \alpha_i$. Then $\mathfrak{F}^+ \models \eta_i \Rightarrow \mathfrak{F}^+ \models \eta_j \Rightarrow \mathfrak{F} \models \alpha_j$. $\dashv$

## 4. An Example: Simplifying Henkin's Equation

We assume familiarity with the notion of a cylindric algebra (cf. [11], [7]), but we modify some notation and definitions. Without loss of generality we may confine ourselves to the two-dimensional case. The algebraic language $\mathcal{L}_2$ has a constant $d_{01}$ and two unary operators $c_0$ and $c_1$, which we write as $\Diamond_0$ and $\Diamond_1$, respectively, if we want to stress the modal aspects of the subject. A cylindric-type *frame* is a quadruple $\mathfrak{F} = (W, \sim_0, \sim_1, D)$ with $\sim_i$ a binary accessibility relation (for $\Diamond_i$) on $W$, and $D$ the subset of $W$ where $d_{01}$ holds. In the following table we list the modal versions of the axioms governing the variety of cylindric algebras, together with their first order equivalents ($i \in \{0, 1\}$):

| | Algebraic | | First-Order |
|---|---|---|---|
| $(C1_i)$ | $x \leq c_i x$ | $(N1_i)$ | $\forall u\, (u \sim_i u)$ |
| $(C2_i)$ | $x \leq -c_i - c_i x$ | $(N2_i)$ | $\forall u v\, (u \sim_i v \to v \sim_i u)$ |
| $(C3_i)$ | $c_i x \leq c_i c_i x$ | $(N3_i)$ | $\forall u v w\, ((u \sim_i v \wedge v \sim_i w) \to u \sim_i w)$ |
| $(C4_i)$ | $c_i c_j x \leq c_j c_i x$ | $(N4_i)$ | $\forall u v w\, ((u \sim_i v \wedge v \sim_j w) \to \exists u'(u \sim_j u' \wedge u' \sim_i w))$ |
| $(C5_i)$ | $c_i d_{01}$ | $(N5_i)$ | $\forall u \exists v\, (u \sim_i v \wedge Dv)$ |
| $(C6_i)$ | $c_i(d_{01} \cdot x) \leq -c_i(d_{01} \cdot -x)$ | $(N6_i)$ | $\forall u v w\, ((u \sim_i v \wedge u \sim_i w \wedge Dv \wedge Dw) \to v = w)$ |

We define $C1 = C1_0 \wedge C1_1$, etc. A *cylindric algebra* is an algebra $\mathfrak{A} = (A, +, -, c_0, c_1, d_{01})$ such that $(A, +, -)$ is a Boolean Algebra, $c_0$ and $c_1$ are normal and additive, and $C1, \ldots, C6$ are valid in $\mathfrak{A}$. The variety of cylindric algebras is denoted by **CA**.

A *cylindric frame* is a cylindric type frame $\mathfrak{F}$ such that $N1, \ldots, N6$ are valid in $\mathfrak{F}$. So a frame $\mathfrak{F} = (W, \sim_0, \sim_1, D)$ is cylindric iff $\sim_0$ and $\sim_1$ are equivalence relations ($N1$, $N2$ and $N3$ for respectively reflexivity, symmetry and transitivity), every $\sim_i$-equivalence class contains precisely one 'diagonal' element in $D$ ($N5$ for existence, $N6$ for unicity), and $\sim_0$ and $\sim_1$ permute ($N4$); below these facts may be used without notice. Cylindric frames are called 'cylindric atom structures' in parts of the literature on algebraic logic, cf. [7].

The following proposition is immediate by the Sahlqvist form of $C1, \ldots, C6$, and Theorems 3.3 and 3.4; the result is known from the literature on algebraic logic, cf. [7, Section 2.7].

**Proposition 4.1.** *(i) $\mathfrak{F}$ is a cylindric frame iff $\mathfrak{F}^+$ is a cylindric algebra.*
*(ii) **CA** is a canonical variety.*

Besides the axioms $C1, \ldots, C6$ governing the variety of cylindric algebras, additional equations play an important role, especially *Henkin's equation*$^3$

$$(\eta) \qquad c_0(x \cdot -y \cdot c_1(x \cdot y)) \leq c_1(-d_{01} \cdot c_0 x).$$

> $^3$ The earliest reference to this equation seems to be in L. Henkin, Cylindric algebras of dimension 2, *Bull. Amer. Math. Soc.* 63:26, 1957. A further reason to ascribe this equation to Henkin can be found [15, Vol. 4, p. 65, footnote 27].

For example, it can be shown that adding $\eta$ (and the version of $\eta$ where $c_0$ and $c_1$ are interchanged) to $C1, \ldots, C6$, one obtains a complete equational axiom system for the set of equations valid in the variety of *representable* cylindric algebras, cf. [7, Theorem 3.2.65]. (This is only true in the two-dimensional case; in the higher dimensional case the role of $\eta$, though important, is not decisive; cf. Theorems 4 and 5.1 of [11].) One might wonder why the authors of [7] decided against giving $\eta$ the status of a CA-axiom. One of the reasons may have been that $\eta$ is less transparent than the other seven. In the remainder of this section we will show that $\eta$ has a simpler equivalent (over the variety **CA**), and that the equivalence is very easy to prove using the Sahlqvist form of the equations.

So let us define the intended simplification of Henkin's equation:

$$(\eta') \qquad d_{01} \cdot c_0(-x \cdot c_1 x) \leq c_1(-d_{01} \cdot c_0 x).$$

Clearly both $\eta$ and $\eta'$ are Sahlqvist equations. Let us compute their first order equivalents.

**Definition 4.2.** Let $\alpha$, $\alpha'$ be the formulas

$$(\alpha) \qquad \forall u \forall v \forall w \Big( (u \sim_0 v \sim_1 w \wedge v \neq w) \to \exists x(\neg Dx \wedge u \sim_1 x \wedge (x \sim_0 v \vee x \sim_0 w)) \Big)$$

$$(\alpha') \qquad \forall u \forall v \forall w \Big( (Du \wedge u \sim_0 v \sim_1 w \wedge v \neq w) \to \exists x(\neg Dx \wedge u \sim_1 x \sim_0 w) \Big).$$

*[Figures 2 and 3 in the original illustrate the meaning of $\alpha$ and $\alpha'$ for cylindric frames as diagrams showing the relationships between worlds $u, v, w, x$ with labeled edges for the $\sim_0$ and $\sim_1$ relations and membership/non-membership in $D$.]*

**Proposition 4.3.** *Let $\mathfrak{F}$ be a frame of the appropriate type. Then $\mathfrak{F} \models \alpha \iff \mathfrak{F}^+ \models \eta$ and $\mathfrak{F} \models \alpha' \iff \mathfrak{F}^+ \models \eta'$.*

*Proof.* For $\eta$, we will spell out the algorithm of theorem 3.3 to find its first order correspondent. First consider its modal variant

$$(\chi) \qquad \Diamond_0(p \wedge \neg q \wedge \Diamond_1(p \wedge q)) \to \Diamond_1(\neg d_{01} \wedge \Diamond_0 p).$$

Let $\phi$ and $\psi$ be respectively the antecedent $\Diamond_0(p \wedge \neg q \wedge \Diamond_1(p \wedge q))$ and the consequent $\Diamond_1(\neg d_{01} \wedge \Diamond_0 p)$ of this formula. Clearly $\chi$ is a Sahlqvist formula, as $\phi$ is a Sahlqvist antecedent and $\psi$ is positive.

Now let $\mathfrak{F} = (W, \sim_0, \sim_1, D)$ be a Kripke frame for the language, then $\mathfrak{F} \models \chi$ iff

$$(8) \qquad \mathfrak{F} \models \forall x \forall P \forall Q (x \in F^\chi(P, Q)).$$

Now the formula $x \in F^\chi(P, Q)$ is by definition equivalent to

$$(9) \qquad x \in F^\phi(P, Q) \to x \in F^\psi(P, Q).$$

Step by step we will rewrite (9), abbreviating $u \in P$ by $Pu$. Starting with the antecedent of (9), we obtain

$$\exists y_1 (x \sim_0 y_1 \wedge y_1 \in F^{p \wedge \neg q \wedge \Diamond_1(p \wedge q)}(P, Q)) \to x \in F^\psi(P, Q),$$

or better

$$\forall y_1 \Big( (x \sim_0 y_1 \wedge y_1 \in F^{p \wedge \neg q \wedge \Diamond_1(p \wedge q)}(P, Q)) \to x \in F^\psi(P, Q) \Big),$$

yielding the effect of (4). Then we get

$$\forall y_1 \Big( (x \sim_0 y_1 \wedge Py_1 \wedge \neg Qy_1 \wedge y_1 \in F^{\Diamond_1(p \wedge q)}(P, Q)) \to x \in F^\psi(P, Q) \Big),$$

and (5) gives

$$\forall y_1 \Big( (x \sim_0 y_1 \wedge Py_1 \wedge y_1 \in F^{\Diamond_1(p \wedge q)}(P, Q)) \to (x \in F^\psi(P, Q) \vee Qy_1) \Big).$$

Using (4), we obtain

$$(10) \qquad \forall y_1 \forall y_2 \Big( (x \sim_0 y_1 \wedge Py_1 \wedge y_1 \sim_1 y_2 \wedge Py_2 \wedge Qy_2) \to (x \in F^\psi(P, Q) \vee Qy_1) \Big).$$

So we have $\mathfrak{F} \models \chi$ iff the following formula holds in $\mathfrak{F}$:

$$\forall x \forall P \forall Q \forall y_1 \forall y_2 \Big( (x \sim_0 y_1 \wedge y_1 \sim_1 y_2 \wedge Py_1 \wedge Py_2 \wedge Qy_2) \to (x \in F^\psi(P, Q) \vee Qy_1) \Big).$$

Comparing this formula with (6), we observe that for both $y_1$ and $y_2$ the sequence $g_{R_{n_{lj}}} \ldots g_{R_{1_{lj}}}$ of (6) is empty, so the universal instantiation mentioned just above (7) simply means replacing $Pu$ by $u \in \{y_1, y_2\}$ (or better, by $(u = y_1 \vee u = y_2)$), and $Qu$ by $(u = y_2)$.

So (10) is equivalent to the following instance of (7), viz.

$$\forall x \forall y_1 \forall y_2 \Big( (x \sim_0 y_1 \wedge y_1 \sim_1 y_2) \to (x \in F^\psi(\{y_1, y_2\}, \{y_2\}) \vee (y_1 = y_2)) \Big),$$

which really means

$$\forall x \forall y_1 \forall y_2 \Big( (x \sim_0 y_1 \wedge y_1 \sim_1 y_2) \to$$
$$\big( y_1 = y_2 \vee \exists z_1(x \sim_1 z_1 \wedge \neg Dz_1 \wedge \exists z_2(z_1 \sim_0 z_2 \wedge (z_2 = y_1 \vee z_2 = y_2))) \big) \Big).$$

Transporting $(y_1 = y_2)$ back to the antecedent, and after some straightforward formula manipulation, we finally obtain

$$\forall x \forall y_1 \forall y_2 \Big( (x \sim_0 y_1 \wedge y_1 \sim_1 y_2 \wedge y_1 \neq y_2) \to \exists z_1(x \sim_1 z_1 \wedge \neg Dz_1 \wedge (z_1 \sim_0 y_1 \vee z_1 \sim_0 y_2)) \Big),$$

which is what we were after. $\dashv$

We now arrive at the main result of this section, which states that over the variety of cylindric algebras the equations $\eta$ and $\eta'$ are equivalent. Note that this result applies to cylindric algebras of arbitrary dimension.

**Proposition 4.4.** *Let $\mathfrak{A}$ be a cylindric algebra. Then $\mathfrak{A} \models \eta \iff \mathfrak{A} \models \eta'$.*

*Proof.* By the previous two propositions it is sufficient to show that for a cylindric frame $\mathfrak{F}$, $\mathfrak{F} \models \alpha \iff \mathfrak{F} \models \alpha'$.

($\Leftarrow$) Assume that $\mathfrak{F} \models \alpha'$. To prove that $\mathfrak{F} \models \alpha$, let $u, v$ and $w$ be worlds in $\mathfrak{F}$ with $u \sim_0 v \sim_1 w$ and $v \neq w$. We have to find an $x$ with $x \notin D$, $u \sim_1 x$ such that $x$ is in the 0-equivalence class with $v$ or with $w$. Distinguish the following cases:

*Case 1:* $u \in D$.
Then $\mathfrak{F} \models \alpha'$ immediately gives us the desired $x$, with $x \sim_0 w$.

*Case 2:* $u \notin D$.
Then $u$ itself is the desired $x$, as $u \sim_0 v$ and $u \sim_1 u$.

($\Rightarrow$) For the other direction, we assume that $\mathfrak{F} \models \alpha$, we consider arbitrary $u, v$ and $w$ in $\mathfrak{F}$ with $u \in D$, $u \sim_0 v \sim_1 w$ and $v \neq w$, and set ourselves the task to find an $x$ with $x \notin D$ and $u \sim_1 x \sim_0 w$, viz. Figure 3.

Since $\mathfrak{F} \models \alpha$, there is a $y \notin D$ with $u \sim_1 y$ and $y \sim_0 v$ or $y \sim_0 w$. Distinguish

*Case 1:* $y \sim_0 w$.
This means we are finished immediately: take $x = y$.

*Case 2:* $y \sim_0 v$.
Since $\mathfrak{F} \models N4$, there is a $z$ in $\mathfrak{F}$ with $y \sim_1 z \sim_0 w$, as in Figure 4.

*[Figures 4 and 5 in the original show diagrams illustrating the case analysis with worlds $u, v, w, y, z$ and their relationships.]*

Distinguish

*Case 2.1:* $z \notin D$.
Again we are finished: take $x = z$.

*Case 2.2:* $z \in D$.
This implies $z = u$ because $\mathfrak{F} \models N6$, so we have the situation depicted in Figure 5. We now have $w \sim_0 z = u \sim_0 v \sim_0 y$, so $y \sim_0 w$ after all, and we are back in case 1: take $x = y$. $\dashv$

## Acknowledgment

We would like to thank the Netherlands Organization for Scientific Research (NWO), project NF 102/62-356 'Structural and Semantic Parallels in Natural Languages and Programming Languages' for financial support during the preparation of the final version of the paper.

## References

[1] H. Andreka and R. Thompson. A Stone-type representation theorem for algebras of relations of higher ranks. *Transactions of Amer. Math. Soc.*, 309:671--682, 1988.

[2] J. van Benthem. *Modal Logic and Classical Logic*. Bibliopolis, Naples, 1983.

[3] R.I. Goldblatt. Varieties of complex algebras. *Annals of Pure and Applied Logic*, 38:173--241, 1989.

[4] R.I. Goldblatt. The McKinsey axiom is not canonical. *The Journal of Symbolic Logic*, 56:554--562, 1991.

[5] R.I. Goldblatt. On closure on canonical embedding algebras. In H. Andreka, J.D. Monk, and I. Nemeti, editors, *Algebraic Logic*, pages 217--229, North-Holland, Amsterdam, 1991.

[6] L. Henkin. Extending Boolean operations. *Pacific Journal of Mathematics*, 32:723--752, 1970.

[7] L. Henkin, J.D. Monk, and A. Tarski. *Cylindric Algebras. Part 1. Part 2*. North-Holland, Amsterdam, 1971, 1985.

[8] B. Jonsson. On the canonicity of Sahlqvist identities. Preprint 94-012, Department of Mathematics, Vanderbilt University, 1994.

[9] B. Jonsson and A. Tarski. Boolean algebras with operators, Part I. *American Journal of Mathematics*, 73:891--939, 1952. (Also in [15, Vol. 3].)

[10] R. Maddux. Some varieties containing relation algebras. *Transactions of Amer. Math. Soc.*, 272:501--526, 1982.

[11] I. Nemeti. Algebraizations of quantifier logics, an introductory overview. *Studia Logica*, 50:485--570, 1991. (A version extended with proofs, intuitive explanations, new developments, is available as Mathem. Inst. Budapest, Preprint 1994.)

[12] M. de Rijke and Y. Venema. Sahlqvist's Theorem for Boolean Algebras with Operators. Technical report ML-91-10, ITLI, University of Amsterdam, September 1991.

[13] H. Sahlqvist. Completeness and correspondence in the first and second order semantics for modal logic. In S. Kanger, editor, *Proceedings of the Third Scandinavian Logic Symposium. Uppsala 1973*, pages 110--143, Amsterdam, 1975. North-Holland.

[14] G. Sambin and V. Vaccaro. A topological proof of Sahlqvist's theorem. *The Journal of Symbolic Logic*, 54:992--999, 1989.

[15] A. Tarski. *Collected Papers*. Birkhauser Verlag, 1986.

[16] Y. Venema. *Many-Dimensional Modal Logic*. PhD thesis, Department of Mathematics and Computer Science, University of Amsterdam, 1991.
