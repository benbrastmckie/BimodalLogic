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
