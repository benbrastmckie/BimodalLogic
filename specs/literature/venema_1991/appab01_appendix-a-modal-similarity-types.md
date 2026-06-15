# Appendix A. Modal Similarity Types

## Outline

This appendix is a summary of the background knowledge presupposed for reading this dissertation.

---

## A1. Introduction

This dissertation treats many different modal-like formalisms, as well as their companions in the theory of Boolean Algebra with Operators. Instead of introducing notions like zigzagmorphism or embedding algebras for every formalism separately, we felt it might be useful for the reader to have a systematic overview. For the abstract notion ranging over all formalisms we use the term *modal similarity type*.

This appendix intends to give a listing of all the notions and facts that we assume as background knowledge for reading this dissertation.

We aimed at a systematic, uniform presentation of the *concepts* involved, not at a complete covering of even the major results in the field.

The material was more or less obtained by amalgamating results from or listed in the following literature, to which we refer for more details, background information, etc.

- J.F.A.K. van Benthem, *Modal Logic and Classical Logic* [14], for correspondence theory and general background in the theory of modal logic.
- S. Burris and H.P. Sankappanavar, *A Course in Universal Algebra* [24], for universal algebra.
- R. Goldblatt, *Varieties of Complex Algebras* [43], for duality theory and modal model theory.
- L. Henkin, J.D. Monk and Tarski, *Cylindric Algebras* [53], the standard reference to algebraic logic.
- I. Nemeti, *Algebraizations of Quantifier Logics: an Introductory Overview* [89], for indeed, an introductory overview to algebraic logic.

---

## A2. Similarity types

**Definition A1: Similarity types.**
A *modal similarity type* is a pair $S = (O, \rho)$ with $O$ a set of *modal operators*, and $\rho : O \mapsto \omega$ a map assigning to each operator of $O$ a finite *rank* or *adity*. Modal operators of rank 0 are called *constants*, monadic operators: *diamonds*, and dyadic ones: *triangles*.

We usually assume the rank of operators known and make no distinction between $S$ and $O$. As variables ranging over operators we use $\nabla, \nabla_1, \ldots$. If the operators are zero-adic or constants, we use $\delta, \lambda, \pi, \sigma, \ldots$, for monadic symbols we use $\Diamond, \Diamond_1, F, P, D, \ldots$, and for dyadics we take $\triangle, \triangle_1, \circ, \ldots$.

In the following, we assume familiarity with the Boolean connectives and constants; as basics we take $\neg$ and $\vee$.

**Definition A2. Modal languages.**
A *modal language* is a pair $M = (S, Q)$, where $S$ is a similarity type and $Q$ is a set of *propositional variables*. When no confusion arises we write $M(S)$, $M(Q)$ or $M$. The set $\Phi(M)$ of *formulas in* $M$ is inductively defined as follows:

(0) The modal and boolean constants and the propositional variables are the *atomic* formulas in $M$.

(1) If $\phi$ and $\psi$ are formulas in $M$, then so are $\neg\phi$ and $\phi \vee \psi$.

(2) If $\phi_1, \ldots, \phi_n$ are formulas in $M$ and $\nabla$ is a modal operator of rank $n$, then $\nabla(\phi_1, \ldots, \phi_n)$ is a formula in $M$.

We assume familiarity with the notion of a *formula algebra*; the formula algebra of the language $M$ is denoted by $\mathfrak{F}\mathfrak{m}_M$. If the variable $p$ does not occur in $\phi$, we write $p \notin \phi$. A formula is *closed* if no variables occur in it, only constants.

For an operator $\nabla$, we abbreviate

$$\underline{\nabla}(\phi_1, \ldots, \phi_n) = \neg\nabla(\neg\phi_1, \ldots, \neg\phi_n)$$

and call $\underline{\nabla}$ the *dual* of $\nabla$. Duals of diamonds are called *boxes*: $\Box\phi = \neg\Diamond\neg\phi$.

To increase readability, we will suppress brackets. We list the operators by decreasing priority: (i) monadic operators ($\neg$, $\Diamond$, $\Box$), (ii) polyadic modal operators, (iii) $\{\wedge, \vee\}$, (iv) $\{\to, \leftrightarrow\}$.

**Definition A3: Classical Languages.**
Let $M = (S, Q)$ be a modal language, with $S = \{\nabla_i \mid i < \xi\}$, $Q = \{p_j \mid j < \zeta\}$. The *correspondence map* $\ell$ assigns an *accessibility* relation symbol $\ell(\nabla_i)$ of adity $\rho(\nabla_i) + 1$ to each operator $\nabla_i$ of $S$ and a monadic relation symbol $P_j$ to each propositional variable $p_j$ in $Q$.

The *corresponding (classical) frame language* $L_S$ has as its predicate symbols the set $\{\ell(\nabla) \mid \nabla \in O\}$. The *corresponding (classical) model language* $L_M$ is $L_S$ extended with all monadic symbols $P_j$, $j < \zeta$.

Unless otherwise stated, all definitions in this appendix are understood with respect to a fixed modal similarity type $S$, c.q. a fixed modal language $M = (S, Q)$.

---

## A3. Frames, models and correspondence

**Definition A4: Frames.**
An *$S$-frame* is a pair $\mathfrak{F} = (W, I)$, which is a structure for $L_S$ in the sense of ordinary first order model theory, i.e. $W$ is a set called the *universe* and $I$ is presented as an interpretation function associating an $n+1$-ary *accessibility relation* with each $S$-operator of rank $n$. Elements of $W$ are called *possible worlds*. If $S = \{\nabla_i \mid i < \xi\}$ we may present a frame as $\mathfrak{F} = (W, R_i)_{i<\xi}$ or $\mathfrak{F} = (W, R_\nabla)_{\nabla \in S}$.

**Definition A5: Models.**
An *$M$-model* is a pair $\mathfrak{M} = (W, I')$, which is a structure for $L_M$ in the sense of ordinary first order model theory. We usually present a model $\mathfrak{M}$ as a pair $\mathfrak{M} = (\mathfrak{F}, V)$ with $\mathfrak{F} = (W, I)$ an $S$-frame and $V$ a *valuation*, i.e. a function mapping proposition letters in $Q$ to subsets of $W$. This presentation can be brought in accordance with the formal definition by setting $I' = I \cup V$.

$V$ can be extended to a map assigning sets of possible worlds to *all* $M$-formulas, by the following inductive definition:

$$V(\phi \vee \psi) = V(\phi) \cup V(\psi)$$

$$V(\neg\phi) = W - V(\phi)$$

$$V(\nabla(\phi_1, \ldots, \phi_n)) = \{w_0 \mid \text{there are } w_1, \ldots, w_n \text{ in } W \text{ with } R_\nabla(w_0, \ldots, w_n) \text{ and for all } 0 < i < n\colon w_i \in V(\phi_i)\}.$$

**Definition A6: Truth and validity.**
Using the terminology of the previous definition, we can define the notion of *truth*: a formula $\phi$ is *true* at $w$ in $\mathfrak{M}$, notation: $\mathfrak{M}, w \models \phi$, if $w \in V(\phi)$. The formula $\phi$ is *true in/holds in* $\mathfrak{M}$, notation: $\mathfrak{M} \models \phi$, if $\mathfrak{M}, w \models \phi$ for all $w$ in $\mathfrak{M}$. $\phi$ *is valid in* a frame $\mathfrak{F}$ ($\mathfrak{F} \models \phi$) if $(\mathfrak{F}, V) \models \phi$ for all valuations $V$; $\phi$ is *valid* in a class K of frames if $\mathfrak{F} \models \phi$ for all $\mathfrak{F}$ in K.

For K a class of models or frames, let $\Theta_S(\mathrm{K})$ be the set of $S$-formulas holding in K. For $\Sigma$ a set of formulas, let $\mathrm{Fr}_\Sigma$ be the class of frames in which $\Sigma$ holds. For a formula $\phi$, we write $\mathrm{Fr}_\phi$ instead of $\mathrm{Fr}_{\{\phi\}}$.

A formula $\phi$ is a *semantic consequence* (footnote 1) of a set of formulas $\Sigma$ *over* a class of frames K, notation: $\Sigma \models_\mathrm{K} \phi$ if for every model $\mathfrak{M}$ based on a frame in K, and every world $w$ in $\mathfrak{M}$, $\mathfrak{M}, w \models \phi$ if $\mathfrak{M}, w \models \sigma$ for all $\sigma \in \Sigma$.

A set of formulas $\Sigma$ *characterizes* a class of frames K if $\mathrm{K} = \mathrm{Fr}_\Sigma$.

> Footnote 1: In Appendix B we discuss the 'global' alternative to this definition, and we give a motivation for choosing our 'local' paradigm.

**Definition A7: Correspondents.**
Let $M = (S, Q)$ be a modal language. By induction to the complexity of formulas in $M$ we define, for every modal formula $\phi$ in $M$ its classical *local model correspondent* $\phi^1(x_0)$ in $L_M$:

$$(p_i)^1 = P_i x_0 \quad (\text{where } P_i = \ell(p_i))$$

$$(\neg\phi)^1 = \neg\phi^1$$

$$(\phi \vee \psi)^1 = \psi^1 \vee \psi^1$$

$$(\nabla(\phi_1, \ldots, \phi_n))^1 = \exists x_1 \ldots x_n (R_\nabla(x_0, x_1, \ldots, x_n) \wedge \bigwedge_{0 < i \leq n} \phi_i^1(x_i/x_0)).$$

The *(classical) local frame correspondent* is defined as the second order formula

$$\phi^2(x_0) \equiv \tilde{\forall}P_1 \ldots \tilde{\forall}P_m \phi^1(x_0),$$

where the second order quantification takes place over these predicates $P_i = \ell(p_i)$ with $p_i$ occurring in $\phi$.

The *global* correspondents are defined by a universal first order quantification over the appropriate local correspondent, so the *global model correspondent* is $\forall x_0 \phi^1(x_0)$ and the *global frame correspondent* is $\forall x_0 \phi^2(x_0)$.

Modal formulas and their classical correspondents are equivalent on the appropriate level:

**Theorem A8: Correspondence.**
For all models $\mathfrak{M}$, frames $\mathfrak{F}$ and worlds $w$ in $\mathfrak{M}$ resp. $\mathfrak{F}$, and formulas $\phi$:

(i) $\mathfrak{M}, w \models \phi \iff \mathfrak{M} \models \phi^1[x_0 \mapsto w]$

(ii) $\mathfrak{M} \models \phi \iff \mathfrak{M} \models \forall x_0 \phi^1$

(iii) $\mathfrak{F}, w \models \phi \iff \mathfrak{F} \models \phi^2[x_0 \mapsto w]$

(iv) $\mathfrak{F} \models \phi \iff \mathfrak{F} \models \forall x_0 \phi^2$.

**Definition A9: Structural Operations on frames.**
Let $\mathfrak{F} = (W, I)$ be an $S$-frame and $\nabla$ an $S$-operator. A subset $W' \subseteq W$ is *$S$-hereditary* if for all $\nabla \in O$, $w \in W'$ and $(w, w_1, \ldots, w_n) \in I(\nabla)$ imply $w_i \in W'$, $1 \leq i \leq n$. Let $\mathfrak{F} = (W, I)$ and $\mathfrak{F}' = (W', I')$ be two $S$-frames, then $\mathfrak{F}'$ is a *generated subframe* of $\mathfrak{F}$ if $W'$ is a $\nabla$-hereditary subset of $W$, and $I'(\nabla)$ is $I(\nabla)$ restricted to $W'$, for all $\nabla$ in $S$.

Let $\mathfrak{F} = (W, I)$ and $\mathfrak{F}' = (W', I')$ be two $S$-frames, then $f : W \mapsto W'$ is a *homomorphism* if

$$(w_0, \ldots, w_n) \in I(\nabla) \Rightarrow (fw_0, \ldots, fw_n) \in I'(\nabla)$$

for all $w_0, \ldots, w_{n-1}$ and $\nabla$. A map $f : W \mapsto W'$ is a *zigzagmorphism* (footnote 2) if $f$ is a homomorphism which satisfies, for each operator $\nabla$, the $\nabla$-*zigzagcondition*

$$(ZZ_\nabla) \qquad (fw_0, w_1', \ldots, w_n') \in I'(\nabla) \Rightarrow \text{there are } w_1, \ldots, w_n \text{ such that } (w, w_0, \ldots, w_n) \in I(\nabla) \text{ and } fw_i = w_i' \text{ for all } i.$$

> Footnote 2: This notion is also known under the names p-morphism and bounded morphism.

Let $\{\mathfrak{F}_i \mid i \in J\}$ be a family of pairwise disjoint $S$-frames, i.e. $W_i \cap W_j = 0$ if $i \neq j$. The *disjoint union* of the $\mathfrak{F}_i$'s is the frame $\Sigma_{i \in J}\mathfrak{F}_i = (W, I)$ given by $W = \bigcup_{i \in J} W_i$, $I(\nabla) = \bigcup_{i \in J} I_i(\nabla)$.

For a class K of frames, we define $\mathbf{S}_f\mathrm{K}$, $\mathbf{H}_f\mathrm{K}$ and $\mathbf{P}_f\mathrm{K}$ as the classes containing resp. the generated subframes, zigzagmorphic images and disjoint unions of frames in K.

---

## A4. Boolean $S$-Algebras

**Definition A10: Boolean $S$-Algebras.**
We assume familiarity with the notion of a *Boolean Algebra* (short: BA). As basic operations of a BA we take *addition* ($+$) and *complementation* ($-$). *Multiplication* ($\cdot$) and the constants 0 and 1 can then be seen as derived operations.

Now let $\mathfrak{A} = (A, +, -, )$ be a Boolean Algebra.

An $n$-ary operation $f : A^n \mapsto A$ is called *normal in the $i$-th coordinate* ($0 < i \leq n$) if

$$f(a_1, \ldots, a_{i-1}, 0, a_{i+1}, \ldots, a_n) = 0.$$

An $n$-ary operation $f : A \mapsto A$ is called *additive in the $i$-th coordinate* ($0 < i \leq n$) if

$$f(a_1, \ldots, a_{i-1}, a_i + a_i', a_{i+1}, \ldots, a_n) = f(a_1, \ldots, a_{i-1}, a_i, a_{i+1}, \ldots, a_n) + f(a_1, \ldots, a_{i-1}, a_i', a_{i+1}, \ldots, a_n).$$

Such an operator is *normal (additive)* if it is normal (additive) in all its coordinates.

Now let $S = (O, \rho)$ be a modal similarity type. A *Boolean Algebra with $S$-operators*, or *Boolean $S$-Algebra*, is an algebra $\mathfrak{A} = (A, +, -, f)$ where $f$ is a map interpreting every $\nabla \in O$ as a normal, additive operation $f_\nabla$ of rank $\rho(\nabla)$ on the Boolean Algebra $(A, +, -)$.

Such an algebra is also denoted as $\mathfrak{A} = (A, +, -, f_\nabla)_{\nabla \in S}$.

The class of Boolean $S$-Algebras is denoted by $\mathbf{BAO}_S$. Boolean $S$-algebras are sometimes called the *modal* algebras of the similarity type.

Boolean $S$-algebras form an alternative semantics for modal languages:

**Definition A11. Terms.**
Let $S$ be a similarity type, $X$ a set of objects called *variables*. In an algebraic context, formulas of the language $M(S, X)$ may be called *$S$-terms in $X$*, or shortly: *terms*. An *$S$-equation* is a pair $(s, t)$ of $S$-terms, usually denoted as $s = t$. In an algebraic context, we usually write $+, \cdot, -$ for $\vee, \wedge, \neg$. We abbreviate $s \leq t$ for $-s + t = 1$.

**Definition A12. Algebraic Semantics.**
An *assignment* of the variables $X$ in an algebra $\mathfrak{A}$ is a map $h : X \mapsto A$. Such a map can be uniquely extended to a homomorphism $\mathfrak{F}\mathfrak{m}_{M(S,X)} \mapsto \mathfrak{A}$ associating an element of $A$ with *every* term. This extension is also denoted by $h$.

An equation $s = t$ is *valid* in an algebra $\mathfrak{A}$ if for *every* assignment $h : X \mapsto A$, $h(s) = h(t)$. An equation $\eta$ is *valid in a class* K of algebras if for all $\mathfrak{A}$ in K, $\eta$ is valid in $\mathfrak{A}$.

All kinds of validity are denoted by $\models$.

The set of equations valid in K is denoted by $\mathit{Equ}(\mathrm{K})$, the class of algebras where a set of equations $E$ holds, by $(\mathbf{V}_E)$. A class K of algebras is *equational* if $\mathrm{K} = \mathbf{V}_E$ for some set of equations $E$.

**Definition A13.**
Let $\eta$ be the equation $r = s$. The *normal term* of $\eta$ is defined as $r \cdot s + {-r} \cdot {-s}$. The *normal form* of $\eta$ is set as $r \cdot s + {-r} \cdot {-s} = 1$. For a set $\Sigma$ of equations we define $\Sigma^{nf}$ as the set of normal forms of the equations in $\Sigma$.

**Convention A14.**
We will be quite sloppy about the difference between equations and their normal forms. For example, we will use $\mathit{Equ}^{nf}(\mathrm{K})$ as the set of all equations holding in K. This is justified by the facts that in the context of Boolean Algebras, an equation $\eta$ is equivalent to its normal form, the sets $\Sigma$ and $\Sigma^{nf}$ characterize the very same class of algebras, etc.

**Definition A15. Structural algebraic operations.**
Let $\mathfrak{A} = (A, +, -, f)$ and $\mathfrak{A}' = (A', +', -', f')$ be two Boolean $S$-algebras.

$\mathfrak{A}'$ is a *subalgebra* of $\mathfrak{A}$ if $A' \subseteq A$ and the operations $+'$, $-'$ and $f'_\nabla$ of $\mathfrak{A}$ are precisely the $+$, $-$ and $f_\nabla$ of $\mathfrak{A}$, restricted to $A'$.

A *homomorphism* from $\mathfrak{A}$ to $\mathfrak{A}'$ is a map $\beta : A \mapsto A'$ such that

$$\beta(a + b) = \beta(a) +' \beta(b)$$

$$\beta(-a) = -'\beta_a$$

$$\beta(f_\nabla(a_1, \ldots, a_n)) = f'_\nabla(\beta a_1, \ldots, \beta a_n).$$

If the homomorphism $\beta : \mathfrak{A} \mapsto \mathfrak{A}'$ is surjective, we call $\mathfrak{A}'$ a *homomorphic image* of $\mathfrak{A}$.

Let $(\mathfrak{A}_i)_{i \in I}$ be an indexed family of Boolean $S$-Algebras. The *direct product* $\prod_{i \in I} \mathfrak{A}_i$ is the Boolean $S$-Algebra $\mathfrak{A} = (A, +, -, f)$ with universe $A = \prod_{i \in I} A_i$ such that

$$(a + b)(i) = a(i) + b(i)$$

$$(-a)(i) = -(a(i))$$

$$(f_\nabla(a_1, \ldots, a_n))(i) = (f_i)\nabla(a_1(i), \ldots, a_n(i)).$$

For a class of algebras K, we denote by $\mathbf{S}\mathrm{K}$, $\mathbf{H}\mathrm{K}$ and $\mathbf{P}\mathrm{K}$ the classes of respectively all subalgebras, homomorphic images and products of algebras in K.

$\mathbf{V}\mathrm{K}$ is the least class containing K which is closed under $\mathbf{S}$, $\mathbf{H}$ and $\mathbf{P}$.

A class K is a *variety* if $\mathrm{K} = \mathbf{V}\mathrm{K}$.

**Theorem A16.**

(i) $\mathbf{V}\mathrm{K} = \mathbf{HSP}\mathrm{K}$.

(ii) V is a variety iff V is an equational class.

---
