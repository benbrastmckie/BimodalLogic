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

## A5. Frames and Algebras

We now have two kinds of semantics for our modalities: relational Kripke structures and Boolean algebras with operators. A framework unifying these approaches is that of general frames, which can be seen as both Kripke frames and complex algebras:

**Definition A17: General Frames and Complex Algebras.**
Let $S = (O, \rho)$ be a similarity type, $\nabla$ an $n$-adic operator in $S$, $\mathfrak{F} = (W, I)$ an $S$-frame. We define the $n$-ary operation $m_\nabla$ on the powerset $P(W)$ of $W$ by

$$m_\nabla(X_1, \ldots, X_n) = \{w \mid \exists w_1 \ldots \exists w_n(\bigwedge_{0 < i \leq n} w_i \in X_i \wedge R_\nabla(w, w_1, \ldots, w_n))\}$$

A *general $S$-frame* is a pair $\mathfrak{G} = (\mathfrak{F}, A)$ where $\mathfrak{F} = (W, I)$ is an $S$-frame and $A \subseteq P(W)$ is closed under Boolean operations and under the operations $m_\nabla$ for all $\nabla$ in $S$.

Let $\mathfrak{G}$ be a general $S$-frame $(\mathfrak{F}, A)$. The *complex algebra* $\mathfrak{Cm}\mathfrak{G}$ of $\mathfrak{G}$ is given as $\mathfrak{A} = (A, \cup, ^c, m_\nabla)_{\nabla \in S}$. The *complex algebra* of a Kripke frame $\mathfrak{F} = (W, I)$ is the complex algebra of the general frame $\mathfrak{G} = (\mathfrak{F}, P(W))$.

For K a class of (general) frames, $\mathbf{Cm}\mathrm{K}$ denotes the class of all complex algebras of frames in K.

We now turn to a comparison of the set of formulas holding in a class of (general) frames with the set of equations valid in the corresponding class of complex algebras.

**Definition A18: Translations.**
Let $Q = \{q_i \mid i < \zeta\}$ and $X = \{x_i \mid i < \zeta\}$ be sets of propositional modal resp. algebraic variables. We assume the existence of a bijection identifying $q_i$ with $x_i$. Thus we are allowed to identify the sets of modal formulas $M(S, Q)$ with the set of algebraic terms $M(S, X)$.

Let $\phi$ be a modal formula. Its *corresponding algebraic equation* $\phi^a$ is given as $\phi = 1$.

Let $\eta$ be an algebraic equation. Seen as a modal formula, its normal term (cf. A13) is called the *corresponding modal formula* of $\eta$, notation: $\eta^\mu$.

For sets $\Sigma$, $E$ of formulas resp. equations, $\Sigma^a$ and $E^\mu$ have their usual meaning.

**Theorem A19.**
Let $\mathfrak{F}$ be a frame, $\phi$ an $S$-formula, K a class of frames. Then

$$\mathfrak{F} \models \phi \iff \mathfrak{Cm}\mathfrak{F} \models \phi = 1$$

$$\Theta(\mathrm{K}) = (\mathit{Equ}(\mathbf{Cm}\mathrm{K}))^\mu.$$

**Definition A20. Atom structures.**
We assume familiarity with the notions of *atoms* in Boolean Algebra and *atomic* BAs. Now let $\mathfrak{A} = (A, +, -, f_\nabla)_{\nabla \in S}$ be an atomic Boolean $S$-algebra. The set of atoms in $\mathfrak{A}$ is denoted by $\mathrm{At}\mathfrak{A}$, the *atom structure* of $\mathfrak{A}$ is the $S$-frame $(\mathrm{At}\mathfrak{A}, R_\nabla)_{\nabla \in S}$ where $R_\nabla$ is given by

$$R_\nabla(a_0, a_1, \ldots, a_n) \iff a_0 \leq f_\nabla(a_1, \ldots, a_n).$$

For a class K of algebras, we let $\mathrm{At}\mathrm{K}$ denote the class of atom structures of atomic algebras in K.

**Theorem A21.**
$\mathfrak{F} \simeq \mathfrak{At}\mathfrak{A} \iff \mathfrak{A} \simeq \mathfrak{Cm}\mathfrak{F}$.

**Definition A22. Canonical structures and embedding algebras.**
Let $\mathfrak{A}$ be a Boolean $S$-algebra.

A subset $F$ of $A$ is a *filter* of $\mathfrak{A}$ if (i) $1 \in F$, (ii) $a, b \in F \Rightarrow a \cdot b \in F$ and (iii) $a \in F$ & $b \geq a \Rightarrow b \in F$. An *ultrafilter* of $\mathfrak{A}$ is a filter $U$ satisfying (iv) $a \notin U \Leftrightarrow -a \in U$.

The *canonical structure* of $\mathfrak{A}$ is the frame $\mathfrak{Cs}\mathfrak{A} = (W, R_\nabla)_{\nabla \in S}$ where $W$ is the set of ultrafilters of $\mathfrak{A}$ and $R_\nabla$ is given by

$$R_\nabla(U_0, \ldots, U_n) \iff f_\nabla(a_1, \ldots, a_n) \in U_0 \text{ for all } a_1 \in U_1, \ldots, a_n \in U_n.$$

The *embedding algebra* $\mathfrak{Em}\mathfrak{A}$ of $\mathfrak{A}$ is the complex algebra of canonical extension of $\mathfrak{A}$: $\mathfrak{Em}\mathfrak{A} = \mathfrak{Cm}\mathfrak{Cs}\mathfrak{A}$.

---

## A6. Modal Logics

**Definition A23: Substitutions.**
A *substitution* is a function $\sigma : Q \mapsto \Phi(M)$. A substitution $\sigma$ can be uniquely extended to a homomorphism $\sigma : \mathfrak{F}\mathfrak{m}_M \mapsto \mathfrak{F}\mathfrak{m}_M$ by setting

$$\sigma(\neg\phi) = \neg\sigma(\phi)$$

$$\sigma(\phi \wedge \psi) = \sigma(\phi) \wedge \sigma(\psi)$$

$$\sigma(\nabla(\phi_1, \ldots, \phi_n)) = \nabla(\sigma\phi_1, \ldots, \sigma\phi_n).$$

Let $\sigma$ be a substitution such that $\sigma p_i = \phi$, $\sigma p_j = p_j$ if $p_j \neq p_i$. In this case, we denote $\sigma\psi$ by $\psi[\phi/p_i]$.

In this thesis we identify logics with derivation systems.

**Definition A24: Derivation Systems.**
A *derivation system* is a pair $MD = (MA, MR)$ with $MA$ a set of formulas called *axioms* and $MR$ a set of derivation rules, a notion for which we only give a semi-formal definition.

A *derivation rule* is usually given in the form '$R : \Delta / \phi$, provided $C$', or, if $\Delta$ is a singleton $\{\psi\}$:

$$(R) \qquad \vdash \psi \Rightarrow \vdash \phi, \text{ provided } C.$$

where $\phi$ and $\psi$ are schemas of formulas and $\Delta$ is a set of such schemas, and $C$ a *constraint* on $R$.

A set $\Sigma$ of formulas is said to be *closed under $R$* if any instantiation of $\phi$ is in $\Sigma$ whenever the corresponding instantiation of $\Delta$ is contained in $\Sigma$ and the constraint $C$ is met.

A derivation rule is called *orthodox* if it is one of the following three, *Modus Ponens*, *Universal Generalization* or *Substitution*:

$(MP)$ If $\phi \in \Lambda$ and $\phi \to \psi \in \Lambda$ then $\psi \in \Lambda$.

$(UG)$ If $\phi \in \Lambda$ and $\nabla$ is an $n$-adic operator in $M$, then $\underline{\nabla}(\phi_1, \ldots, \phi_{i-1}, \phi, \phi_{i+1}, \ldots, \phi_n)$ is in $\Lambda$.

$(SUB)$ If $\phi \in \Lambda$ and $\sigma$ is a substitution then $\sigma\phi \in \Lambda$.

**Definition A25: Logics.**
A *(normal) modal logic* in a language $M$ is a subset $\Lambda$ of $\Phi(M)$ such that

(i) $\Lambda$ contains the following axioms, the *classical tautologies* and *distribution*:

$(CT)$ all classical tautologies

$(DB)$ $\underline{\nabla}(p_1, \ldots, p_{i-1}, p, p_{i+1}, \ldots, p_n) \leftrightarrow \underline{\nabla}(p_1, \ldots, p_{i-1}, p, p_{i+1}, \ldots, p_n) \to \underline{\nabla}(p_1, \ldots, p_{i-1}, p', p_{i+1}, \ldots, p_n)$

(ii) $\Lambda$ is closed under the orthodox derivation rules.

A derivation system is called *orthodox* if it contains no derivation rules besides the orthodox ones.

Let $MA$ be a set of axioms and $MD$ a set of derivation rules; the logic $\Lambda(MA, MD)$ is the least set of formulas in $M$ containing $MA$ which is closed under the derivation rules in $MD$.

For a formula $\sigma$ we let $\Lambda\sigma$ denote the derivation system $\Lambda$ extended with $\sigma$ as an axiom. For a set $\Sigma$ of formulas we have an analogous convention.

**Definition A26: Derivations.**
A *derivation* in $\Lambda$ is a finite sequence $\phi_0, \ldots, \phi_n$ such that every $\phi_i$ is either an axiom (footnote 3) or obtainable from $\phi_0, \ldots, \phi_{i-1}$ by a derivation rule. A *theorem* of $\Lambda$ is any formula that can appear as the last item of a derivation. Theoremhood of a formula $\phi$ in a logic $\Lambda$ is denoted by $\vdash_\Lambda \phi$. A formula $\phi$ is *derivable* in a logic $\Lambda$ from a set of formulas $\Sigma$, notation: $\Sigma \vdash_\Lambda \phi$, if there are $\sigma_1, \ldots, \sigma_n$ in $\Sigma$ with $\vdash (\sigma_1 \wedge \ldots \wedge \sigma_n) \to \phi$.

A formula $\phi$ is *consistent* if its negation $\neg\phi$ is not a theorem. A set of formulas is *consistent* if the conjunction of any finite subset is consistent and *maximal consistent* if it is consistent while it has no consistent proper extension (in the same language). We usually abbreviate 'maximal consistent set' by 'MCS'.

> Footnote 3: Cf. Appendix B for a motivation of this definition.

**Definition A26: Properties of logics.**
Let $\Lambda$ be a logic, K a class of frames. $\Lambda$ is called *sound* with respect to K if $\Lambda \subset \Theta(\mathrm{K})$, and *complete* if $\Theta(\mathrm{K}) \subset \Lambda$. $\Lambda$ is *strongly sound* if $\Sigma \vdash_\Lambda \phi \Rightarrow \Sigma \models_\mathrm{K} \phi$, *strongly complete* if $\Sigma \models_\mathrm{K} \phi \Rightarrow \Sigma \vdash_\Lambda \phi$, for all sets of formulas $\Sigma$ and formulas $\phi$.

If $\Lambda$ is (a derivation system $(A, D)$ which is) sound and complete for a class K of frames, we call $\Lambda$ an *axiomatization* for K.

**Definition A27: Minimal modal logics.**
The *minimal* or *basic* logic $K_S$ of a similarity type $S$ is a defined as having *only* (CT) and (DB) as its axioms, *only* (MP), (UG) and (SUB) as its derivation rules.

**Theorem A28.**
$K_S$ is strongly sound and complete with respect to $\mathrm{Fr}_S$.

---

## A7. Algebraic derivations

**Definition A29. Algebraic derivation systems.**
We assume familiarity with the notion of a *subterm (subformula)* of a given term (formula). Let $X$ be a set of variables, $S$ a similarity type.

An *algebraic derivation system* over $X$ is a pair $AD = (AA, AR)$ consisting of a set $AA$ of *axioms*, i.e. equations over $X$, and a set $AR$ of *derivation rules* (of which notion we will not give a formal definition, but cf. A24). For a derivation system $AD = (AA, AR)$, we define $\mathit{Equ}(AD)$, the set of equations *generated* by $AD$, as the smallest set of equations over $X$ that contains $AA$ and is closed under every rule in $AR$.

If $\Sigma$ is a set of equations over $X$, then the *orthodox $S$-derivation system* $D_S(\Sigma)$ *over* $\Sigma$ is the derivation system defined by the following set $\Sigma^+$ of axioms:

(i) $s = s$ for all $s \in M(X)$.

(ii) Axioms governing the Boolean part of the algebras.

(iii) $N$ and $A$, stating that the $S$-operators are normal resp. additive.

(iv) $\Sigma$.

and the following set $R_S$ of rules:

(i) $s = t$ / $t = s$.

(ii) $r = s$, $s = t$ / $r = t$.

(iii) Replacement: $s = t$ / $r[s/x] = r[t/x]$.

(iv) Substitution: $s = t$ / $s[r/x] = t[r/x]$.

Derivation systems are meant to provide recursive enumerations of the equations that are valid in some variety:

**Definition A30.**
Let $D$ be a derivation system, K a class of algebras, $\Sigma$ a set of equations. $D$ is *sound* for K if $\mathit{Equ}(D) \subseteq \mathit{Equ}(\mathrm{K})$, *complete* if $\mathit{Equ}(\mathrm{K}) \subseteq \mathit{Equ}(D)$. $\Sigma$ is an *axiomatization* for K if $D_S(\Sigma)$ is a sound and complete derivation system for K.

Note that the difference between axiomatizations and derivation systems is that the first may only have the 'orthodox' algebraic derivation rules (i) ... (iv).

We now turn to the relation between modal logics and algebraic derivation systems. For *orthodox* modal derivation systems, this relation is well-known:

**Theorem A31.**
Let $\Lambda = (\Sigma, \{MP, UG, SUB\})$ be an orthodox modal derivation system which is sound and complete with respect to a class of frames K. Then $\Sigma^a$ is an algebraic axiomatization for $\mathbf{Cm}\mathrm{K}$.

For modal axiomatizations having non-orthodox rules, we have to work a little harder:

**Definition A32.**
Let '$R : \Delta$ / $\phi$, provided $C$' be a modal derivation rule. Its *algebraic version* $R^A$ is defined as '$R^A : \Delta^a$ / $\phi^a$, provided $C$'.

Let $\Lambda = (\Sigma, \{R_i \mid i \in I\})$ be a modal derivation system. Its *algebraic version* is defined as the orthodox algebraic derivation system $D_S(\Sigma^a)$ augmented with the algebraic versions of the *non-orthodox* rules $R_i$.

**Theorem A33.**
Let $\Lambda = (\Sigma, D)$ be a modal derivation system which is sound and complete with respect to a class of frames K. Then the algebraic version $\Lambda^A$ of $\Lambda$ is a sound and complete algebraic derivation system for $\mathbf{Cm}\mathrm{K}$.

**Proof sketch.**
For notational simplicity, we assume that '$R : \Delta/\phi$, provided $C$' is the only non-orthodox derivation rule of $\Lambda$.

To prove soundness, it suffices to show that $\mathit{Equ}(\mathbf{Cm}\mathrm{K})$ is closed under $R^A$, because the equations in $\Sigma^a$ hold in $\mathbf{Cm}\mathrm{K}$ by A19, and the ordinary algebraic axioms and derivation rules raise no problems. So assume that $\Delta^a \subseteq \mathit{Equ}(\mathbf{Cm}\mathrm{K})$, and that the constraint $C$ is met. By A.19, $\Delta \subseteq \Theta(\mathrm{K})$, so by soundness of $\Lambda$, $\phi \in \Theta(\mathrm{K})$. But then $\phi^a \in \mathit{Equ}(\mathbf{Cm}\mathrm{K})$ by A.19.

For completeness, assume that the equation $\eta$ is valid in K. Without loss of generality (cf. A.14) we may assume that $\eta$ is in normal form $\phi = 1$. By A.19, $\mathrm{K} \models \phi$, so by completeness of $\Lambda$, $\vdash_\Lambda \phi$.

So it remains to be proved that the algebraic equations corresponding to $\Lambda$-theorems are derivable in $\Lambda^A$. This is easily done by induction to the length of the derivation in $\Lambda$: for the orthodox modal derivation rules the induction step is standard, for the unorthodox $R$ it is immediate by the definition of $R^A$.

---

## A8. Canonical structures

**Definition A34: Canonical Structures.**
For $\Lambda$ a logic in a language $M$, the *$\Lambda$-canonical universe* $W^c_\Lambda$ is the set of all maximal $\Lambda$-consistent sets in $M$. For $\nabla$ an $n$-adic modal operator in $M$, its *canonical accessibility relation* $R^c_\nabla$ is defined on $W^c$ by

$$R^c_\nabla(\Delta_0, \ldots, \Delta_{n-1}) \iff \text{for all } \phi_1 \in \Delta_1, \ldots, \phi_n \in \Delta_n : \nabla(\phi_1, \ldots, \phi_n) \in \Delta_0.$$

The $\Lambda$-*canonical frame* is given as $\mathfrak{F}^c_\Lambda = (W^c_\Lambda, I^c)$, where $I^c$ is the *canonical interpretation* mapping every operator to its canonical accessibility relation. The *canonical $\Lambda$-model* is the pair $\mathfrak{M}^c_\Lambda = (\mathfrak{F}^c_\Lambda, V^c)$, where $V^c_\Lambda$ is the *canonical valuation* assigning to every $p_i \in Q$ the set of MCSs containing $p_i$, i.e.

$$V^c_\Lambda(p_i) = \{\Delta \in W^c_\Lambda \mid p_i \in \Delta\}.$$

The $\Lambda$-*canonical general frame* is the pair $\mathfrak{G}^c_\Lambda = (\mathfrak{F}^c_\Lambda, A^c_\Lambda)$ where $X \in A^c_\Lambda$ iff $X = V^c_\Lambda(\phi)$ for some $\phi \in \Phi(M)$.

If we want to make the set $Q$ of variables for the language $M = (S, Q)$ explicit, we may write $\mathfrak{F}^c_\Lambda(Q)$, etc.

**Theorem A35: Truth Lemma.**

$$\mathfrak{M}^c, \Gamma \models \phi \iff \phi \in \Gamma.$$

**Proof.**
The proof is by induction to the complexity of $\phi$. For the atomic case the claim follows by definition. The only non-standard case in the induction step is where $\phi = \nabla(\psi_0, \ldots, \psi_{n-1})$, $\nabla$ an $n$-adic operator. We assume $n = 2$ and write $\phi = \psi \triangle \chi$.

First, suppose $\mathfrak{M}^c, \Gamma \models \psi\triangle\chi$. By the truth definition, there are MCSs $\Pi, \Sigma$ with $R^c\Gamma\Pi\Sigma$, $\mathfrak{M}, \Pi \models \psi$ and $\mathfrak{M}, \Sigma \models \chi$. By the Induction Hypothesis, $\psi \in \Pi$ and $\chi \in \Sigma$. By definition of $R^c$ then, $\psi\triangle\chi \in \Gamma$.

For the opposite direction it is sufficient to prove the following claim:

> If $\Gamma$ is an MCS and $\psi\triangle\chi \in \Gamma$, then there are MCSs $\Pi$, $\Sigma$ with $R^c\Gamma\Pi\Sigma$, $\psi \in \Pi$ and $\chi \in \Sigma$.

To show this, let $\phi_0, \phi_1, \ldots$ be an enumeration of the formulas in the language. We will define in a simultaneous, Lindenbaum-like construction, two sequences of sets of formulas $\Pi_0 \subset \Pi_1 \subset \ldots$, $\Sigma_0 \subset \Sigma_1 \subset \ldots$ such that $\Pi_0 = \{\psi\}$, $\Sigma_0 = \{\chi\}$, all $\Pi_n$ and $\Sigma_n$ are finite and consistent, $\Pi_{n+1}$ is either $\Pi_n \cup \{\phi_n\}$ or $\Pi_n \cup \{\neg\phi_n\}$ and likewise for $\Sigma_n$. Furthermore, setting $\pi_n$ ($\sigma_n$) as the conjunction of all formulas in $\Pi_n$ ($\Sigma_n$), we will have $\pi_n\triangle\sigma_n \in \Gamma$ for all $n$.

The key observation for the induction step of the definition is the following:

$$\pi_n \triangle \pi_n \in \Gamma$$

$$\Rightarrow \pi_n \wedge (\phi_n \vee \neg\phi_n)\triangle\sigma_n \wedge (\phi_n \vee \neg\phi_n) \in \Gamma$$

$$\Rightarrow ((\pi_n \wedge \phi_n) \vee (\pi_n \wedge \neg\phi_n))\triangle((\sigma_n \wedge \phi_n) \vee (\sigma_n \wedge \neg\phi_n))$$

$$\Rightarrow \text{one of } (\pi_n \wedge \phi_n)\triangle(\sigma_n \wedge \phi_n), \quad (\pi_n \wedge \phi_n)\triangle(\sigma_n \wedge \neg\phi_n),$$

$$(\pi_n \wedge \neg\phi_n)\triangle(\sigma_n \wedge \phi_n), \quad (\pi_n \wedge \neg\phi_n)\triangle(\sigma_n \wedge \neg\phi_n) \quad \text{is in } \Gamma.$$

Now for instance in the second case, we take $\Pi_{n+1} = \Pi_n \cup \{\phi_n\}$ and $\Sigma_{n+1} = \Sigma_n \cup \{\neg\phi_n\}$, etc.

It is then straightforward to prove that the $\Pi_n$, $\Sigma_n$ have the properties mentioned above.

Let $\Pi = \bigcup_{n < \omega} \Pi_n$, $\Sigma = \bigcup_{n < \omega} \Sigma_n$, then one can easily verify that $\Pi$ and $\Sigma$ are MCSs and that $R^c\Gamma\Pi\Sigma$.

**Definition A36: Properties of logics.**
A logic $\Lambda$ is *canonical* if $\Lambda$ is valid not only on its canonical model (which is always the case, by the truth lemma), but on *every* model based on the canonical frame, i.e. if $\mathfrak{F}^c_\Lambda \models \Lambda$. A formula $\phi$ is *canonical* if the logic $K_S\phi$ is canonical.

**Theorem A37.**
Let $\Lambda$ be a canonical logic. Then $\Lambda$ is strongly sound and complete with respect to $\mathrm{Fr}_\Lambda$.

**Definition A38. Free Algebras.**
Let $Q$ be a set of variables, K a class of Boolean $S$-algebras. We assume familiarity with the notion of the *$Q$-generated free algebra* $\mathfrak{A}_\mathrm{K}(Q)$ over K. For a variety axiomatized by a set of equations $H$, we denote the free algebra by $\mathfrak{A}_H(Q)$.

The canonical frames are the canonical extensions of the free algebras:

**Theorem A39.**
Let $\Lambda$ be a modal logic, $Q$ a set of propositional variables. Then

$$\mathfrak{F}^c_\Lambda(Q) = \mathfrak{Cs}\mathfrak{A}_{\Lambda^a}(Q).$$

---

## A9. Versatility

Nearly always, the frames one has in mind for a modal language, satisfy some extra conditions. An important example is formed by tense logic:

**Definition A40. Tense.**
Assume that a subset $T$ of the diamonds of $S$ is given as $T = \{F_j, P_j \mid j \in J\}$. Diamonds in this set are called *tense diamonds*, their duals *tense boxes*. We call $F_j$ the *converse* of $P_j$ and the other way round. If $\Diamond$ is a tense diamond, its converse is denoted by $\Diamond^{-1}$. A diamond that is not in $T$ is called *uni-directional*. If all diamonds of a similarity type are in $T$, we call it a *tense similarity type*.

A frame $(W, R_\nabla)_{\nabla \in S}$ for $S$ is called a *tense frame* if for every $\Diamond \in T$, the accessibility relations of $\Diamond$ and $\Diamond^{-1}$ are each other's converse, i.e. $R_{\Diamond^{-1}} = (R_\Diamond)^{-1}$. For a class K of $S$-frames, we let $\mathrm{K}^t$ denote the class of tense frames in K.

With emphasis, we want to note that the above definition should be understood as to include the case where a modal operator is its *own* converse.

**Definition A41. Tense Logics.**
Let $S, T$ be as above. The *minimal tense logic* $K^t_S$ is the minimal $S$-logic $K_S$ extended with the following axiom for every $\Diamond \in T$:

$(CV)$ $p \to \Box\Diamond^{-1}p$

**Theorem A42.**
$K^t_S$ is strongly sound and complete with respect to the class of all tense frames.

We want to generalize these concepts to operators of higher rank:

**Definition A43: Versatility.**
A *versatile* similarity type is a modal similarity type $S = (O, \rho)$ where the set $O$ of operators is given as a (disjoint) union of sets, $O = \bigcup_{j \in J} O_j$, such that $O_j = \{\nabla_{j0}, \ldots, \nabla_{j,n_j}\}$ and all operators in $O_j$ have the same rank $n_j - 1$.

A *versatile frame* for such an $S$ is an $S$-frame $(W, I)$ where for all $j \in J$, $i \leq n_j$ one has

$$I(\nabla_{ji}) = \{(w_0, w_1, \ldots, w_{n_j}) \mid (w_1, \ldots, w_{n_j}, w_0) \in I(\nabla_{j,i+1})\}$$

For a class K of $S$-frames, we let $\mathrm{K}^v$ denote the class of versatile frames in K.

We do not exclude the possibility that $O_j = \{\nabla, \ldots, \nabla\}$, i.e. all operators are identical. Once we know that a frame is versatile, it is not necessary to give all of its accessibility relations. For example, a frame $\mathfrak{F} = (W, R_\Diamond, R_{\Diamond^{-1}})$ can be identified with $\mathfrak{F} = (W, R_\Diamond)$ if $R_{\Diamond^{-1}} = (R_\Diamond)^{-1}$.

Note that the notion 'tense' only applies to diamonds: in a tense similarity type $S$ there is no constraint on the operators of rank $> 2$. Only if all operators of $S$ are constants or diamonds, do the concepts of 'tense' and 'versatility' coincide, and do we have $\mathrm{K}^t = \mathrm{K}^v$.

The notions of tense and versatile operators are known in the theory of Boolean Algebras with Operators under the names of conjugates and residuals.

---

---

# Appendix B. Consequences of Derivation Systems

## Outline

We discuss an alternative for our notion of semantic consequence ($\Sigma \models \phi$) and show that in the context of non-$\xi$ rules, our option behaves nicer.

---

Recall that we defined a *local* consequence relation for modal formulas by setting

$$\Sigma \models_\mathrm{K} \phi \iff \text{for all models } \mathfrak{M} = (\mathfrak{F}, V) \text{ with } \mathfrak{F} \text{ in K and every world } w \text{ in } \mathfrak{M}: \mathfrak{M}, w \models \Sigma \Rightarrow \mathfrak{M}, w \models \phi.$$

There is a different, *global* paradigm in modal logic, where:

$$\Sigma \models^*_\mathrm{K} \phi \iff \text{for all models } \mathfrak{M} = (\mathfrak{F}, V) \text{ with } \mathfrak{F} \text{ in K}: \mathfrak{M} \models \Sigma \Rightarrow \mathfrak{M} \models \phi.$$

We face an analogous choice in first order logic, if we want to decide what $\Sigma \models \phi$ means, when $\Sigma$ and $\phi$ contain *free variables*. (Note that for the formalism $L^*_\alpha$ the question is not only analogous to, but indeed the very same as for $CML_\alpha$.)

This difference in semantic perspective is reflected in the interpretation of *derivation systems*.

In our approach, $\Sigma \vdash_\Lambda \phi$ holds if there are $\sigma_1, \ldots, \sigma_n \in \Sigma$ with $\vdash_\Lambda (\sigma_1 \wedge \ldots \wedge \sigma_n) \to \phi$, i.e. derivation rules may only be applied to logical theorems.

In the other line of thinking, $\Sigma \vdash^*_\Lambda \phi$ holds if there is a derivation $\phi_0, \ldots, \phi_n = \phi$ such that every $\phi_i$ is either an axiom of $\Lambda$ *or in* $\Sigma$, or obtained from an earlier $\phi_j$ by an application of a derivation rule. In other words: the formulas in $\Sigma$ are to be used as if they were axioms.

In principle, two choices, both out of two alternatives, would give us four possible pairs consisting of a semantic and an axiomatic notion. Of these, the pairs $\{\models^*, \vdash\}$ and $\{\models, \vdash^*\}$ are ruled out if we want the axiomatic relation to be (strongly) sound and complete with respect to the semantic one: the fact that $p \models^* \Box p$ and $p \nvdash \Box p$ implies that $\vdash$ cannot be complete with respect to $\models^*$, and likewise, the pair $\{\models, \vdash^*\}$ will give problems concerning *soundness*, as $p \not\models \Box p$, yet $p \vdash^* \Box p$.

In this appendix we briefly compare the remaining pairs $\{\models, \vdash\}$ and $\{\models^*, \vdash^*\}$, which we will call 'our' or the 'local' paradigm, respectively the '$*$-style' or 'global' paradigm.

For algebraists, the choice for the $*$-style paradigm seems to be obvious, as equations are always implicitly understood to be universally quantified, and one is interested in an algebra as a whole.

In the *possible world semantics* of modal logic however, we have a strong preference for the *local* paradigm, and we believe that our reasons for this opinion could lead algebraic logicians to think that the local perspective is at least *interesting*. Our motivation for the local variant of semantic consequence and derivation systems is threefold:

First, one can show that $\models$ is *more informative* than $\models^*$. For example (abbreviate $\Box^0\phi = \phi$, $\Box^{n+1}\phi = \Box\Box^n\phi$):

$$\{p_0\} \cup \{\Box^n(p_n \to (\neg p_{n+1} \wedge \Diamond p_{n+1})) \mid n \in \omega\} \models_\mathrm{K} \bot \tag{1}$$

provides us with information about the class K, namely that

$$\text{no K-frame contains an infinite sequence } w_0 R w_1 R w_2 \ldots \tag{2}$$

The global version of (1) is vacuously true, so it does not tell us anything. It is not clear to us how to express (2) using $\models^*$, *unless one adds to the language operators enabling a local perspective*, for example the 'only here' operator $O$. Following an idea by Johan van Benthem, we can show that, letting $p$ be a new variable for $\Sigma, \phi$,

$$\Sigma \models \phi \iff \{EOp\} \cup \{p \to \sigma \mid \sigma \in \Sigma\} \models^* p \to \phi.$$

On the other hand, $\models^*$ can always be reduced to $\models$: let us, in the context of this dissertation, assume (footnote 1) that we have an operator $\boxplus$ such that $\boxplus\phi$ holds in a world $w$ iff $\phi$ holds in *every* world somehow accessible from $w$. Define $\boxplus\Sigma = \{\boxplus\sigma \mid \sigma \in \Sigma\}$. Then we have

$$\Sigma \models^* \phi \iff \boxplus\Sigma \models \boxplus\phi, \tag{3}$$

as a simple proof shows.

> Footnote 1: This idea stems from Goranko and Passy [46]; using proposition 2.33 in van Benthem [14], one can reduce $\models^*$ to $\models$ in *any* similarity type.

A second, more philosophical reason to prefer $\vdash$ to $\vdash^*$ is that in our opinion, it is an essential characteristic of modal logic that there is not one single notion of validity, not one single logic. This makes for a distinction between logics and theories and it is not clear to us how to represent this distinction in the $*$-style paradigm. We may identify an (orthodox) derivation system $\Lambda$ with its set of axioms, but there should be a *conceptual difference* between $\Lambda_1 \vdash_{\Lambda_2} \phi$ and $\Lambda_2 \vdash_{\Lambda_1} \phi$. In the $*$-approach however, both $\Lambda_1 \vdash^*_{\Lambda_2} \phi$ and $\Lambda_2 \vdash^*_{\Lambda_1} \phi$ reduce to $\Lambda_1 \cup \Lambda_2 \vdash^*_K \phi$, where $K$ is the minimal modal logic of the similarity type.

Our third and main motivation to focus on the local consequence relation is related to the notion of a non-$\xi$ rule.

Let us consider the simplest case of the irreflexivity rule $IR_D$ for the $D$-operator:

$$(IR_D) \qquad (p \wedge \neg Dp) \to \phi \ / \ \phi, \quad \text{if } p \notin \phi.$$

For this rule, problems will rise concerning *soundness* if we adhere to the $*$-paradigm. For, it lies in the *nature* of the $D$-operator that any standard model $\mathfrak{M}$ can have at most one world where $p \wedge \neg Dp$ is true. This implies that in any non-trivial standard model $\mathfrak{M}$, $\mathfrak{M} \models \neg(p \wedge \neg Dp)$, or equivalently, $\mathfrak{M} \models (p \wedge \neg Dp) \to \bot$. If we want $IR_D$ to be $*$-sound, by the instance $(p \wedge \neg Dp) \to \bot / \bot$ of $IR_D$ we are forced to conclude $\mathfrak{M} \models \bot$, which is clearly undesirable.

So at this particular point, the focus on the *local* consequence relation is *essential*:

> in the global paradigm non-$\xi$ rules make no sense.

Turning to the example of cylindric modal logic and related notions, we can go even further and claim that no finite $*$-style derivation system can be a sound and complete axiomatization for the cylindric modal formulas valid in the cubes, or the $\mathcal{CC}6$-formulas valid in the squares (footnote 2).

> Footnote 2: The same claim applies to the equations holding in representable cylindric algebras, typeless valid formulas, etc.

**Theorem B.1.**
Let $\Lambda = (MA, MD)$ be a derivation system for cylindric modal logic of dimension $n < \omega$, and suppose that $\Lambda$ is $*$-style sound and complete with respect to cube validity, i.e. $\Sigma \models^*_{C_n} \phi \iff \Sigma \vdash^*_\Lambda \phi$.

Then either $MA$ or $MD$ is infinite.

**Proof.**
We will show that unorthodox derivation *rules* can be replaced by *axioms*, in any derivation system which is $*$-style strongly sound and complete with respect to cube validity. Our 'non-finite derivability result' then follows by Monks theorem that $\mathit{Equ}(\mathrm{RCA}_n)$ is not finitely axiomatizable (and hence, it can be strengthened along the lines of Andreka [5], cf. the remarks below definition 4.1.8).

For a sketch of the proof, suppose that $\Lambda = (MA, MR \cup \{R\})$ is a finite derivation system which is $*$-style sound and complete with respect to the cubes, where $R : \alpha / \beta$ is an unorthodox derivation rule. (The proof can easily be adapted for rules having constraints.)

Let $\Lambda^A$ be the derivation system $(MA \cup \{A\}, MR)$, where $A$ is the axiom (schema) $\boxplus\alpha \to \boxplus\beta$. We have to show that

$$\Sigma \vdash^*_\Lambda \phi \iff \Sigma \vdash^*_{\Lambda^A} \phi.$$

To prove ($\Leftarrow$), it is sufficient to show that $\boxplus\alpha' \to \boxplus\beta'$ is a theorem of $\Lambda$, for every instance $(\alpha', \beta')$ of $(\alpha, \beta)$. Now as $\Lambda$ is $*$-style sound, we have $\alpha' \models^* \beta'$, implying $\models^* \boxplus\alpha' \to \boxplus\beta'$ by (3). By the supposed completeness of $\Lambda$, this implies $\vdash^*_\Lambda \boxplus\alpha' \to \boxplus\beta'$.

For ($\Rightarrow$), we have to prove that $\alpha / \beta$ is a derived rule of $\Lambda^A$. This is rather easy, as the following ($*$-style) derivation shows:

| | |
|---|---|
| (1) $\alpha'$ | (assumption) |
| (2) $\boxplus\alpha'$ | (1, $UG$) |
| (3) $\boxplus\alpha' \to \boxplus\beta'$ | (axiom) |
| (4) $\boxplus\beta'$ | (2, 3, $MP$) |
| (5) $\beta'$ | (4, $\boxplus$ is S5) |

This proves Theorem B.1.

**Conclusion.**
The *local* perspective on derivation systems and the semantic consequence relation is *essential* in the idea to use *unorthodox* derivation rules as a means to get round the *non-finite axiomatizability results* in algebraic logic.
