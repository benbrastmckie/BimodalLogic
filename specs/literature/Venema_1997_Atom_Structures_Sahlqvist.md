# Atom Structures

**Yde Venema**\*

August 8, 2002

> \*Department of Mathematics and Computer Science, Free University, De Boelelaan 1081, 1081 HV Amsterdam.

## Abstract

The atom structure of an atomic boolean algebra with operators is some canonically defined frame or relational structure that is based on the set of atoms of the algebra. We discuss the relation between varieties of boolean algebras with operators and the induced class of atom structures. Our main result states that for a variety $\mathsf{V}$ of boolean algebras with *conjugated* operators, the corresponding class $\mathsf{At\,V}$ of atom structures is elementary; moreover, an (infinite) axiomatization of $\mathsf{At\,V}$ can be generated from the equations defining $\mathsf{V}$.

---

## 1 Introduction

The connection between boolean algebras with operators[^1] (BAOs for short) and relational structures (or frames) has been studied rather intensively, starting with the introduction of the first notion by Jonsson & Tarski in [6]. The most familiar construction in this field, namely that of taking the full complex algebra $\mathfrak{F}^+$ of a relational structure $\mathfrak{F}$, in fact provides one of the two prime examples of a BAO. (The second example is formed by Lindenbaum-Tarski algebras of modal logics.) For an example in the other direction, one could mention the construction of the ultrafilter frame or canonical structure of a BAO. Here, the prime example is that of the canonical frame of a modal logic, which is nothing but the ultrafilter frame of the Lindenbaum-Tarski algebra of the logic. For an overview of the duality theory between BAOs and relational structures the reader is referred to Goldblatt [1].

In this paper we will concentrate on atomic BAOs. For such algebras there is the option to construct a frame in a different way, viz. by taking the *atom structure* of the algebra.[^2]

**Definition 1.1** *Given an $n$-ary operator $f$ on the atomic boolean algebra $\mathfrak{A}$, the $n{+}1$-ary relation $R_f$ on $At\,\mathfrak{A}$ is defined by*[^3]

$$R_f a b_1 \ldots b_n \quad \text{iff} \quad a \leq f(b_1, \ldots, b_n).$$

*The* **atom structure** *of the atomic BAO $\mathfrak{A} = (A, +, -, 0, f_i)_{i \in I}$ is the frame $\mathfrak{At}\,\mathfrak{A} = (At\,\mathfrak{A}, R_{f_i})_{i \in I}$. Given a class $\mathsf{X}$ of BAOs, we define $\mathsf{At\,X}$ as the class of atom structures of atomic algebras in $\mathsf{X}$, in pseudo-set-theoretic notation: $\mathsf{At\,X} = \{\mathfrak{At}\,\mathfrak{A} \mid \mathfrak{A} \text{ is an atomic algebra in } \mathsf{X}\}$.*

It is obvious from the definition that in some sense, taking the atom structure of an atomic BAO is the converse operation of taking the full complex algebra of a frame. Indeed, if we start from some arbitrary frame; take its full complex algebra (which is always atomic!); and then take the atom structure of that algebra: we are back with an isomorphic copy of the original frame --- the isomorphism sends a state $s$ of the original frame to the singleton $\{s\}$. Formally, we have that for any frame $\mathfrak{F}$, $\mathfrak{At}\,\mathfrak{F}^+ \simeq \mathfrak{F}$. This observation is already in Jonsson & Tarski [6] (be it somewhat implicit --- the authors do not explicitly define the notion of an atom structure).

Equally well-known is the fact that in the other direction, the connection is less smooth. In particular, it is *not* the case that taking the full complex algebra of the atom structure of an arbitrary atomic BAO, one arrives back at the algebra that one started from, or even at an isomorphic copy of it. This is easily seen by a simple cardinality argument: for any countably infinite atomic algebra $\mathfrak{A}$, the algebra $(\mathfrak{At}\,\mathfrak{A})^+$ will be uncountable.

This does not indicate however, that in its own right, the construction of taking the atom structure of an arbitrary atomic BAO has received a lot of attention in the literature. Let us briefly mention the few research directions that have been taken up already. For instance, there is the question which *properties* of atomic BAOs are determined by their atom structures. In particular, one may investigate for which varieties of BAOs membership of an atomic BAO is determined by its atom structure. Let us agree to call such varieties *atom-determined*. There are a few results known about this concept: for instance, in Hodkinson [5] it is proved that the well-known variety $\mathsf{RRA}$ of representable relation algebras is not atom-determined, while in Venema [7] examples of very simple equations (like $fx \leq gfx$) are given defining a variety that is not atom-determined. It is also proved in the latter paper that if we confine ourselves to conjugated BAOs, then all Sahlqvist varieties (that is, varieties that are axiomatized by Sahlqvist equations) are atom-determined.

Another line of research is to investigate whether (and if so, how) this operation of taking atom structures might shed new light on familiar concepts and questions in the area of boolean algebras with operators. This road is taken in for instance Goldblatt [2]; one of the main results in that paper is a partial answer to a famous open problem in modal logic, viz. the question whether every canonical variety $\mathsf{V}$ of BAOs is generated by an elementary class $\mathsf{K}$ of frames, in the sense that $\mathsf{V} = \mathsf{H\,S\,P\,Cm\,K}$. Goldblatt provides a positive answer to this question for varieties that are not only canonical but also *atom-canonical*, that is, $(\mathfrak{At}\,\mathfrak{A})^+$ belongs to the variety for every atomic $\mathfrak{A}$ in the variety. Another example is the paper Givant [3]; this author involves the notion of atom structure in his result concerning classes $\mathsf{X}$ of algebras for which $\mathsf{S\,P\,X}$ is a variety.

Both of these research lines seem to be interesting and promising. It seemed to me however, that concerning the relation between (varieties of) boolean algebras with operators and their (classes of) atom structures, some of the very basic issues have not yet been addressed properly. Consider for instance questions like the following. Given a variety $\mathsf{V}$ of BAOs, what does the class $\mathsf{At\,V}$ of associated atom structures look like? Is it always an elementary class? Or, to give a second example: given an atomic BAO $\mathfrak{A}$ with atom structure $\mathfrak{F}$, it is tempting to view $\mathfrak{A}$ as a complex algebra over $\mathfrak{F}$, but is this a justifiable perspective?

It is the aim of this paper to address a number of such basic questions. In order to do so, we define a number of natural properties of varieties of BAOs, all of which concern the relation between the variety and its associated class of atom structures; then, we discuss the relation between these properties.

**Definition 1.2** *Let $\mathsf{V}$ be a variety of boolean algebras with operators. We say that $\mathsf{V}$ is*

- **AE** *atom-elementary if $\mathsf{At\,V}$ is an elementary class,*
- **AD** *atom-determined if for any two atomic algebras $\mathfrak{A}$ and $\mathfrak{B}$, if $\mathfrak{At}\,\mathfrak{A} \simeq \mathfrak{At}\,\mathfrak{B}$, then $\mathfrak{A}$ is in $\mathsf{V}$ iff $\mathfrak{B}$ is in $\mathsf{V}$,*
- **AC** *atom-canonical if $(\mathfrak{At}\,\mathfrak{A})^+$ is in $\mathsf{V}$ for every atomic $\mathfrak{A}$ in $\mathsf{V}$, or equivalently, if $\mathsf{At\,V} \subseteq \mathsf{Str\,V}$,*[^4]
- **AX** *atom-complex if every atomic algebra in $\mathsf{V}$ is isomorphic to a complex algebra over its atom structure,*
- **AO** *atom-corresponding if there is a set $\Delta$ of first order sentences in the frame language such that for all atomic BAOs $\mathfrak{A}$, $\mathfrak{A}$ is in $\mathsf{V}$ iff $\mathfrak{At}\,\mathfrak{A} \models \Delta$.*

Interestingly enough, there is a striking difference between the general picture and the landscape of conjugated varieties. For the general case, we can only prove the following relations between the concepts introduced in the previous definition.

**Theorem 1.3** *The properties AE, AD, AC, AX and AO of varieties of BAOs are related as follows:*

1. *$AO = AD \leq AC < AE$*
2. *$AD \not\leq AX \not\leq AC$*

This theorem should be read as follows. The statement '$AO = AD$' means that an arbitrary variety $\mathsf{V}$ of boolean algebras with operators is atom-corresponding if and only if it is atom-determined. '$AC < AE$' stands for the conjunction of two statements, viz. that $\mathsf{V}$ is atom-canonical only if it is atom-elementary (this result was proved first in Goldblatt [2]); and the proposition that on the other hand, there are varieties that are atom-elementary but not atom-canonical.

In the second part of the paper we turn to the case of conjugated varieties. As we mentioned before, conjugated varieties display a much nicer behavior.

**Theorem 1.4** *The properties AE, AD, AC, AX and AO of conjugated*[^5] *varieties of BAOs are related as follows:*

1. *$AO = AD = AC$, but not all varieties have this property.*
2. *All varieties are atom-complex and atom-elementary. Moreover, given the equational theory of $\mathsf{V}$ there is a recursive definition of the set of axioms defining the class $\mathsf{At\,V}$.*

For an overview of the paper: in the next section we briefly define all the notions that we assume as background knowledge in the paper. In section 3 we make some basic observations concerning atom structures, thus proving the easy parts of Theorem 1. In section 4 we concentrate on the class of weak structures for a given variety; these are the frames of which the so-called singleton algebra belongs to the variety. The main result of the section, and in fact the main technical result of the paper, states that for any variety, the class of weak structures is an elementary class. In section 5 we treat the case of conjugated algebras; this section contains the rather short proof of Theorem 2. We finish the paper with mentioning some open problems, in section 6.

**Acknowledgements.** The research of the author has been made possible by a fellowship of the Royal Netherlands Academy of Arts and Sciences. Personally, I would like to thank H. Andreka, I. Nemeti and S. Givant for asking enough questions to make me write this note. Thanks are also due to I. Hodkinson for stimulating discussions, and to him, Sz. Mikulas and A. Simon for comments on an earlier version of this paper.

---

## 2 Terminology and Notation

In this paper we assume familiarity with boolean algebras and some standard notions pertaining to them, such as the induced ordering relation or infinite sums. We denote the power set of a set $W$ by $\mathcal{P}(W)$, the power set algebra $(\mathcal{P}(W), \cup, -, \varnothing)$ by $\mathfrak{P}(W)$.

Now let $\mathfrak{A} = (A, +, -, 0)$ and $\mathfrak{A}' = (A', +', -', 0')$ be two boolean algebras; a map $r : A \to A'$ is said to preserve infinite sums if $\Sigma'_{i \in I} r(a_i)$ exists and is identical to $r(\Sigma_{i \in I} a_i)$ whenever $\Sigma_{i \in I} a_i$ exists. In the case of preservation of finite sums, it is sufficient to require that $r(\Sigma_{i \in I} a_i) = \Sigma'_{i \in I} r(a_i)$ --- if $I$ is finite, the mentioned sums always exist.

An operation on a boolean algebra $\mathfrak{A} = (A, +, -, 0)$ is nothing but a function $f : A^n \to A$ for some $n \in \omega$. The dual of an operation $f : A^n \to A$ is defined as $f_\delta(a_1, \ldots, a_n) = -f(-a_1, \ldots, -a_n)$. An operation $f$ is *normal* if $f(a_1, \ldots, a_n) = 0$ whenever $a_i = 0$ for one of the arguments $a_i$; *additive* if it preserves (finite) sums in each of its arguments; *completely additive* if it preserves arbitrary sums in each of its arguments; and *monotonic* if it is increasing in each of its arguments. An *operator* is a normal and additive operation.

A similarity type is a pair $\tau = (I, \rho)$ such that $I$ is a set of operation symbols and $\rho : I \to \omega$ is a map assigning to each operation symbol a finite rank. A boolean algebra with $\tau$-operators, short: a $\tau$-BAO, is an algebra $\mathfrak{A} = (A, +, -, 0, f_i)_{i \in I}$ such that each $f_i$ is a $\rho(i)$-ary operator on the boolean algebra $(A, +, -, 0)$. A relational $\tau$-structure or $\tau$-frame is a structure $\mathfrak{F} = (W, T_i)_{i \in I}$ such that each $T_i$ is a $\rho(i){+}1$-ary relation on $W$. Elements of (the universe of) a frame will sometimes be called states.

Notions concerning atoms pertain to a BAO as to its underlying boolean algebra. An atom of a boolean algebra $\mathfrak{A} = (A, +, -, 0)$ is an element $0 \neq a \in A$ for which there is no element $x$ satisfying $0 < x < a$; a boolean algebra is atomic if there is an atom below each non-zero element. The set of atoms of an atomic BAO $\mathfrak{A}$ is denoted by $At\,\mathfrak{A}$.

Any $n{+}1$-ary relation $T$ on a set $W$ induces an $n$-ary operation $m_T$ on $\mathcal{P}(W)$:

$$m_T(X_1, \ldots, X_n) = \{w \in W \mid Tww_1 \ldots w_n \text{ for some } w_i \in X_i\}.$$

Then, given a relational $\tau$-structure $\mathfrak{F} = (W, T_i)_{i \in I}$, the full complex algebra $\mathfrak{F}^+$ of $\mathfrak{F}$ is defined as the structure $(\mathcal{P}(W), \cup, -, \varnothing, m_{T_i})_{i \in I}$; in other words, it is the power set algebra $\mathfrak{P}(W)$ endowed with all operations $m_{T_i}$ corresponding to the relations $T_i$. A complex algebra over $\mathfrak{F}$ is just any subalgebra of $\mathfrak{F}^+$. (Note the difference between *the full* complex algebra *of* $\mathfrak{F}$, which is unique, and *a* complex algebra *over* $\mathfrak{F}$!) Operations of the form $m_T$ are always completely additive operators; hence, every complex algebra is a BAO.

Given a class $\mathsf{K}$ of $\tau$-frames, we define $\mathsf{Cm\,K}$ as the class of full complex algebras of $\mathsf{K}$, in pseudo-set-theoretic notation: $\mathsf{Cm\,K} = \{\mathfrak{F}^+ \mid \mathfrak{F} \in \mathsf{K}\}$. Similar, or familiar, definitions apply to the class operations $\mathsf{H}$, $\mathsf{S}$ and $\mathsf{P}$, corresponding to the operations of taking homomorphic images, subalgebras and direct products. For a class $\mathsf{X}$ of algebras, $\mathsf{Str\,X} := \{\mathfrak{F} \mid \mathfrak{F}^+ \in \mathsf{X}\}$ is the class of structures for $\mathsf{X}$.

Now we turn to the algebraic language to describe $\tau$-BAOs. Besides the boolean symbols, this language has a $\rho(i)$-adic function symbol for each element $i$ of $I$. We may write $f_\mathfrak{A}$ for the interpretation of the function symbol $f$ in the algebra $\mathfrak{A}$, but usually we will be sloppy concerning the distinction between symbols and their interpretations. From these symbols and a set of variables, $\tau$-terms and $\tau$-equations are defined as usual; the set of $\tau$-terms is denoted by $Ter(\tau)$, or by $Ter$ if $\tau$ is clear from context.

For a modal similarity type $\tau$, the (corresponding) frame language is the first order predicate language which has an $n + 1$-ary relation symbol $R_f$ for each $n$-ary modal operator $f$ in $\tau$. Given a set $\Pi$ of algebraic variables, the (corresponding) model language is the extension of the frame language with unary predicates $P_0, P_1, P_2, \ldots$ corresponding to the proposition letters $p_0, p_1, p_2, \ldots$ in $\Pi$. Given such a set $\Pi$, we let $(\mathfrak{F}, a_1, \ldots, a_n)$ denote the expansion of the structure $\mathfrak{F}$ with subsets $a_i$ of the universe of $\mathfrak{F}$; it is our convention that $a_1$ interprets $P_1$, etc.

Two unary operations $f$ and $g$ on $\mathfrak{A}$ are called conjugates if for all $a$, $b$ in $A$ it holds that $a \cdot f(b) = 0$ iff $g(a) \cdot b = 0$. An equivalent characterization is that $a \leq f_\delta(b)$ iff $ga \leq b$ for all $a$ and $b$. The notion of conjugation extends to operations of arbitrary rank, but we only mention the binary case here: three binary operations $f_1$, $f_2$ and $f_3$ are called conjugates if for all $a_1$, $a_2$ and $a_3$, we have: $a_1 \cdot f_1(a_2, a_3) = 0$ iff $a_2 \cdot f_2(a_3, a_1) = 0$ iff $a_3 \cdot f_3(a_1, a_2) = 0$. Conjugation can also be expressed equationally; for unary operations, the two axioms $x \leq fg_\delta x$ and $x \leq gf_\delta x$ suffice. A very nice property of conjugated operations is that they are completely additive. A BAO is conjugated if for each of its operators there are conjugates in the clone of operations generated by the operators; in this paper we always assume to be dealing with the special case in which the operators themselves already come in conjugated tuples.

All results and definitions in this paper are understood to be indexed by a similarity type $\tau$ mentioning of which will be suppressed from now on.

---

## 3 Some Basic Observations

In this section we make some basic observations concerning atom structures; and in doing so, we will prove the easy parts of Theorem 1.

To start with, it is convenient to have an explicit reference to the following simple fact that was already mentioned in the introduction.

**Proposition 3.1** *For any frame $\mathfrak{F}$, $\mathfrak{At}\,\mathfrak{F}^+ \simeq \mathfrak{F}$.*

In the introduction we also mentioned that on the other hand, there are atomic algebras $\mathfrak{A}$ such that $\mathfrak{A} \not\cong (\mathfrak{At}\,\mathfrak{A})^+$. It may be instructive to give a concrete example; consider the frame $\mathfrak{N} = (\mathbb{N}, <)$ where $<$ is the usual ordering on the set $\mathbb{N}$ of natural numbers. It is not difficult to show that the set $\mathcal{P}^*(\mathbb{N})$ of finite and cofinite sets of natural numbers is closed under the operation $m_<$ given by $m_<(X) = \{n \in \mathbb{N} \mid n < x \text{ for some } x \in X\}$. Hence, the structure $\mathfrak{N}^\circ = (\mathcal{P}^*(\mathbb{N}), \cup, -, \varnothing, m_<)$ is a BAO. It is easy to see that $\mathfrak{N}^\circ$ is atomic and that its atom structure is isomorphic to the frame $\mathfrak{N}$. In fact, $\mathfrak{N}^\circ$ and $\mathfrak{N}^+$ are two distinct atomic BAOs with the very same atom structure.

It is not very difficult to check that the equation $M : f_\delta f x \leq f f_\delta x$ holds in $\mathfrak{N}^\circ$, but not in $\mathfrak{N}^+$. This shows that the variety $\mathsf{V}_M$ defined by $M$ is not atom-canonical. In Goldblatt [2] this example is worked out to show that in fact, there is a canonical variety that is not atom-canonical.

The algebra $\mathfrak{N}^\circ$ is a BAO of a rather special kind. We defined it as that complex algebra over $\mathfrak{N}$ which has as its carrier the set of all finite or cofinite subsets of $\mathbb{N}$. Another way of looking at $\mathfrak{N}^\circ$ is that it is the subalgebra of $\mathfrak{N}^+$ that is *generated by the atoms* of $\mathfrak{N}^+$, that is, by the singletons of $\mathcal{P}(\mathbb{N})$. Put in that way, the construction can be generalized to every frame.

**Definition 3.2** *Given a relational structure $\mathfrak{F} = (W, T_i)_{i \in I}$, the* **singleton algebra** *$\mathfrak{F}^\circ$ is the subalgebra of $\mathfrak{F}^+$ that is generated by the atoms of $\mathfrak{F}^+$, that is, by the singletons of $\mathcal{P}(W)$.*

For the particular similarity type of relation algebra, this concept was introduced in Hodkinson [5] under the name 'term algebra'.

There are two caveats in order here, showing that one should not make rash generalizations from the theory of boolean algebras. First, it is wrong to think that every singleton algebra has *only* finite or cofinite subsets as elements of its universe. For instance, let $\mathfrak{T}$ be the binary tree $\mathfrak{T} = (\{0,1\}^*, \geq)$ where $\{0,1\}^*$ is the set of all strings of 0's and 1's, and $s \geq t$ is $t$ is a proper initial segment of $s$. Then $m_\geq(\{0\})$ is the set of all strings that start with an 0. Obviously, $m_\geq(\{0\})$ belongs to the universe of $\mathfrak{T}^\circ$, but it is neither finite nor cofinite.

The second tempting mistake is to assume that every atomic algebra is a complex algebra over its atom structure. In order to see why this is not the case, consider the algebra $\mathfrak{C} = (\mathcal{P}^*(\mathbb{Z}), \cup, -, \varnothing, f)$ where $\mathbb{Z}$ is the set of all integer numbers and $f$ is defined by

$$f(X) = \begin{cases} \{x - 1 \mid x \in X\} & \text{if } X \text{ is finite} \\ \mathbb{Z} & \text{if } X \text{ is cofinite.} \end{cases}$$

We leave it to the reader to verify that $\mathfrak{C}$ is a BAO, i.e., that $f$ is an additive function. $\mathfrak{C}$ is clearly atomic; its atom structure can be identified with the frame $\mathfrak{Z} = (\mathbb{Z}, S)$ with $Syz$ iff $z = y + 1$. However, $\mathfrak{C}$ cannot be isomorphic to a complex algebra over $\mathfrak{Z}$; for, consider a cofinite set $X \neq \mathbb{Z}$. Then $f(X) = \mathbb{Z}$, while in $\mathfrak{Z}^+$, and hence, in each of its subalgebras, $m_S(X) = \mathbb{Z}$ would imply that $X = \mathbb{Z}$. In fact, we have exhibited an example of an algebra $\mathfrak{C}$ and a frame $\mathfrak{Z}$ such that $\mathfrak{Z} \simeq \mathfrak{At}\,\mathfrak{C}$, while $\mathfrak{Z}^\circ \not\leftarrow \mathfrak{C} \not\leftarrow \mathfrak{Z}^+$. In Proposition 5.1 we will see that the problem with $\mathfrak{C}$ is that its operator $f$ is not *completely* additive. Obviously, such examples show that not every variety is atom-complex.

We now turn to proving the positive statements of Theorem 1.

**Proposition 3.3 ($AO \Rightarrow AD$)** *A variety of boolean algebras with operators is atom-corresponding only if it is atom-determined.*

*Proof.* Assume that the variety $\mathsf{V}$ is atom-corresponding; then there is a set $\Sigma$ of formulas in the first-order frame language such that for any atomic algebra $\mathfrak{A}$, $\mathfrak{A}$ is in $\mathsf{V}$ iff $\mathfrak{At}\,\mathfrak{A} \models \Sigma$.

Now consider two atomic algebras $\mathfrak{A}$ and $\mathfrak{B}$ such that $\mathfrak{At}\,\mathfrak{A} \simeq \mathfrak{At}\,\mathfrak{B}$. Then we have the following equivalences:

$$\mathfrak{A} \text{ in } \mathsf{V} \iff \mathfrak{At}\,\mathfrak{A} \models \Sigma \iff \mathfrak{At}\,\mathfrak{B} \models \Sigma \iff \mathfrak{B} \text{ in } \mathsf{V},$$

from which it is immediate that $\mathsf{V}$ is atom-determined. $\square$

**Proposition 3.4 ($(AD$ & $AE) \Rightarrow AO$)** *A variety of boolean algebras with operators is atom-determined and atom-elementary only if it is atom-corresponding.*

*Proof.* Assume that $\mathsf{V}$ is a variety that is both atom-determined and atom-elementary. By the latter property, there is a set $\Sigma$ of formulas in the first-order frame language such that for any frame $\mathfrak{F}$, $(\ast)$ $\mathfrak{F} \models \Sigma$ iff $\mathfrak{F}$ is isomorphic to the atom structure of some atomic algebra $\mathfrak{B}$ in $\mathsf{V}$.

Now let $\mathfrak{A}$ be an arbitrary atomic algebra. We will show that $\mathfrak{A}$ is in $\mathsf{V}$ iff $\mathfrak{At}\,\mathfrak{A} \models \Sigma$ --- this suffices to show that $\mathsf{V}$ is atom-corresponding. The direction from left to right is immediate by $(\ast)$. For the other direction, assume that $\mathfrak{At}\,\mathfrak{A} \models \Sigma$. Then by $(\ast)$ there is an atomic algebra $\mathfrak{B}$ in $\mathsf{V}$ such that $\mathfrak{At}\,\mathfrak{A} \simeq \mathfrak{At}\,\mathfrak{B}$. But then by (AD) $\mathfrak{A}$ is in $\mathsf{V}$ as well. $\square$

The next proposition is almost trivial.

**Proposition 3.5 ($AD \Rightarrow AC$)** *A variety of boolean algebras with operators is atom-determined only if it is atom-canonical.*

*Proof.* Assume that $\mathfrak{A}$ is an atomic algebra in the atom-determined variety $\mathsf{V}$. By Fact 3.1, $\mathfrak{At}\,(\mathfrak{At}\,\mathfrak{A})^+ \simeq \mathfrak{At}\,\mathfrak{A}$. Hence, by (AD) $(\mathfrak{At}\,\mathfrak{A})^+$ is in $\mathsf{V}$, showing that $\mathsf{V}$ is atom-canonical. $\square$

Now we turn to some less trivial observations, namely concerning the conditions under which a variety has an elementary class of atom structures. In order to prove that atom-complex and atom-canonical varieties are atom-elementary, it will be very convenient to use an intermediate property that involves the singleton algebras.

**Definition 3.6** *Given a variety $\mathsf{V}$, a frame $\mathfrak{F}$ is called a* **weak structure** *for $\mathsf{V}$ if $\mathfrak{F}^\circ$ belongs to $\mathsf{V}$; $\mathsf{Wst\,V}$ denotes the class of weak structures for $\mathsf{V}$.*

An easy proof shows the following to hold for every variety $\mathsf{V}$:

$$\mathsf{Str\,V} \subseteq \mathsf{Wst\,V} \subseteq \mathsf{At\,V}.$$

**Definition 3.7** *A variety $\mathsf{V}$ is called*

- **AS** *atom-sensitive if $(\mathfrak{At}\,\mathfrak{A})^\circ$ belongs to $\mathsf{V}$ for every atomic algebra $\mathfrak{A}$ in $\mathsf{V}$, or equivalently, if $\mathsf{At\,V} \subseteq \mathsf{Wst\,V}$.*

In other words, $\mathsf{V}$ is atom-sensitive iff at least *some* complex algebra over the atom structure of each of its atomic algebras is in $\mathsf{V}$. We will first show that both atom-canonicity and atom-complexity imply atom-sensitivity.

**Proposition 3.8 ($AC \leq AS$)** *Let $\mathsf{V}$ be a variety of boolean algebras with operators that is atom-canonical or atom-complex. Then $\mathsf{V}$ is atom-sensitive.*

*Proof.* If $\mathsf{V}$ is atom-canonical, then atom-sensitivity of $\mathsf{V}$ follows immediately by the observation that $\mathfrak{F}^\circ$ is a subalgebra of $\mathfrak{F}^+$ for every frame $\mathfrak{F}$. $\square$

From Proposition 3.8 it will be clear that in order to show that '$AC \leq AE$', it suffices to prove that '$AS \leq AE$'.

**Proposition 3.9 ($AS \leq AE$)** *A variety of boolean algebras with operators is atom-sensitive only if it is atom-elementary.*

*Proof.* Let $\mathsf{V}$ be an atom-sensitive variety; by definition, this gives that $\mathsf{At\,V}$ is included in $\mathsf{Wst\,V}$. Since the converse inclusion holds for every variety, this gives $\mathsf{At\,V} = \mathsf{Wst\,V}$. But then the proposition follows immediately from Theorem 3 below, stating that for every variety $\mathsf{V}$, $\mathsf{Wst\,V}$ is an elementary class. $\square$

So for a proof of Theorem 1 we now have all the ingredients (apart from Theorem 3, that will be discussed in the next section).

**Proof of Theorem 1.** We first prove part 1. The part '$AO \leq AD$' was proved in Proposition 3.3. For the other direction, observe that $AD \leq AE$ by the Propositions 3.5, 3.8 and 3.9. Hence, $AD \leq (AD$ & $AE)$, so by Proposition 3.4, $AD \leq AO$.

The statement '$AD \leq AC$' is the content of Proposition 3.5, while it follows from the Propositions 3.8 and 3.9 that $AC \leq AE$. Finally, the variety $\mathsf{RRA}$ of representable relation algebras is an example of a variety that has AE, but not AC; for a proof of this rather deep result, the reader is referred to Hodkinson [5].

For part 2, we can use the same example: $\mathsf{RRA}$ has AX --- this follows from Theorem 2 --- but not AD. Finally, we already saw that not every atomic algebra is isomorphic to a complex algebra over its atom structure (this was the second 'caveat'); this shows that for instance, the variety of all BAOs (in a given similarity type) is atom-determined but not atom-complex. $\square$

---

## 4 Weak Structures

In this section we will prove the main technical result of the paper, viz., that for any variety of BAOs, the associated class of weak structures forms an elementary class. More precisely formulated, we have the following theorem, which generalizes a result by Hodkinson for the variety $\mathsf{RRA}$.

**Theorem 4.1** *For any variety*[^6] *$\mathsf{V}$, the class $\mathsf{Wst\,V}$ is elementary. Moreover, given the equational theory of $\mathsf{V}$, there is a recursive definition of the set of axioms axiomatizing the class $\mathsf{Wst\,V}$.*

This is not very difficult to see if we take a perspective from modal correspondence theory;[^7] we basically need to combine the following two observations. First, it is not difficult to see that every element of (the universe of) $\mathfrak{F}^\circ$ is a parametrically first order definable subset of $\mathfrak{F}$ --- where the parameters are taken from the elements of $\mathfrak{F}$. And second, the truth of an equation in a complex algebra over a frame under a *given* assignment $V$, can be expressed by first order means over the expansion $(\mathfrak{F}, V(p_1), \ldots, V(p_n))$ of the frame $\mathfrak{F}$ --- a *model* in modal terminology.

**Definition 4.2** *Given a set $P = \{p_0, p_1, \ldots\}$ of algebraic variables, the* **standard translation** *$\sigma_t$ of a term $t$ is a first order formula in the model language that is given by the following inductive definition:*

$$\begin{aligned}
\sigma_{p_i} &:= P_i x \\
\sigma_0 &:= x \neq x \\
\sigma_{-t} &:= \neg \sigma_t \\
\sigma_{t_1 \cdot t_2} &:= \sigma_{t_1} \wedge \sigma_{t_2} \\
\sigma_{f(t_1, \ldots, t_n)} &:= \exists x_1 \ldots x_n\, (R_f x x_1 \ldots x_n \wedge \sigma_{t_1}\langle x_1/x \rangle \wedge \ldots \wedge \sigma_{t_n}\langle x_n/x \rangle).
\end{aligned}$$

*The* **atomic standard translation** *$\alpha_t$ is defined like the standard translation, with the exception of the atomic clause for the algebraic variables:*

$$\alpha_{p_i} := x = y_i.$$

*Now let $\psi$ be a formula in the model language, and let $P$ be a predicate symbol occurring in $\psi$ that does not belong to the frame language; furthermore, let $\varphi$ be a formula in the frame language in which the variable $x$ occurs free. Then $\psi\langle\varphi/P\rangle$ is the formula obtained by replacing each occurrence of an atomic formula $Pz$ by the formula $\varphi\langle z/x\rangle$.*

*Let $k$ be some natural number, and consider some terms $s(p_1, \ldots, p_n)$ and $t_1(q_{1,1}, \ldots, q_{1,m_1})$, $\ldots$, $t_n(q_{n,1}, \ldots, q_{n,m_n})$; as $\alpha^k_{t_i}$ we abbreviate the formula $\alpha_{t_i}$ with each variable $y_j$ replaced by the variable $y_{k,j}$. Then $\delta(s, \vec{t})$ is given by*

$$\delta(s, \vec{t}) := \forall x y_{1,1} \ldots y_{n,m_n}\, \sigma_s\langle\alpha^1_{t_1}/P_1\rangle \ldots \langle\alpha^n_{t_n}/P_n\rangle$$

*Finally, for a given term $s(p_1, \ldots, p_n)$, we let $\Delta_s$ denote the set*

$$\Delta_s := \{\delta(s, \vec{t}) \mid t_1, \ldots, t_n \in Ter\}.$$

Another way of looking at the atomic standard translation is as follows. Given a term $t$, we have

$$\alpha_t = \sigma_t\langle x = y_1/P_1\rangle \ldots \langle x = y_n/P_n\rangle,$$

as a straightforward proof shows.

The following Lemma is the crucial one in the proof of Theorem 3. In this Lemma, we let $s^+$ denote the operation on $\mathfrak{F}^+$ induced by the term $s$; for $s^\circ$ we have a likewise convention (now with respect to the algebra $\mathfrak{F}^\circ$).

**Lemma 4.3** *Let $s(p_1, \ldots, p_n)$ be a term, $\mathfrak{F}$ be some frame and $u$ an arbitrary state in $\mathfrak{F}$. Then the following hold.*

1. *For arbitrary subsets $a_1, \ldots, a_n$ of (the universe of) $\mathfrak{F}$:*

$$u \in s^+(a_1, \ldots, a_n) \iff (\mathfrak{F}, a_1, \ldots, a_n) \models \sigma_s[x \mapsto u].$$

2. *Let $\varphi_1, \ldots, \varphi_n$ be formulas in the frame language such that $x$, $y_{i,1}$, $\ldots$, $y_{i,m_i}$ are the free variables of $\varphi_i$, and let $v_{1,1}, \ldots, v_{n,m_n}$ be a sequence of states in $\mathfrak{F}$. Suppose that for each $i$,*

$$a_i = \{w \mid \mathfrak{F} \models \varphi_i[x \mapsto w, \vec{y_i} \mapsto \vec{v_i}]\}.$$

*Then*

$$u \in s^+(a_1, \ldots, a_n) \iff \mathfrak{F} \models \sigma_s\langle\varphi_1/P_1\rangle \ldots \langle\varphi_n/P_n\rangle[x \mapsto u, \vec{\vec{y}} \mapsto \vec{\vec{v}}].$$

3. *Let $v_1, \ldots, v_n$ be a sequence of states in $\mathfrak{F}$. Then*

$$u \in s^+(\{v_1\}, \ldots, \{v_n\}) \iff \mathfrak{F} \models \alpha_s[x \mapsto u, \vec{y} \mapsto \vec{v}].$$

*Proof.* By a tedious but straightforward term induction on $s$. Note that part 1 of the Lemma is nothing but the familiar correspondence theorem on the model level. Part 2 follows from part 1; part 3 can be proved directly, but it is also a corollary of part 2, since for each $i$,

$$\{v_i\} = \{w \mid \mathfrak{F} \models x = y_i[x \mapsto w, y_i \mapsto v_i]\}.$$

$\square$

**Lemma 4.4** *For any term $s$,*

$$\mathfrak{F}^\circ \models s = 1 \iff \mathfrak{F} \models \Delta_s.$$

*Proof.* We first prove the direction from right to left, and reason by contraposition. Assume that $\mathfrak{F}^\circ \not\models s = 1$; then for some $u$ in $\mathfrak{F}$, and some $a_1, \ldots, a_n$ in (the universe of) $\mathfrak{F}^\circ$, we have $u \notin s^\circ(a_1, \ldots, a_n)$. Since $\mathfrak{F}^\circ$ is a subalgebra of $\mathfrak{F}^+$, this gives

$$u \notin s^+(a_1, \ldots, a_n).$$

By definition of $\mathfrak{F}^\circ$, all elements of $\mathfrak{F}^\circ$ are generated in $\mathfrak{F}^+$ by the singleton sets. Hence, for each $i$ there are a term $t_i(q_{i,1}, \ldots, q_{i,m_i})$ and states $v_{i,1}, \ldots, v_{i,m_i}$ in $\mathfrak{F}$ such that $a_i = t_i^+(\{v_{i,1}\}, \ldots, \{v_{i,m_i}\})$. By Lemma 4.3(3) it follows that for each $i$ and all $w$ in $\mathfrak{F}$,

$$w \in a_i \iff \mathfrak{F} \models \alpha^i_{t_i}[x \mapsto w, \vec{y_i} \mapsto \vec{v_i}].$$

But then by Lemma 4.3(2)

$$\mathfrak{F} \not\models \sigma_s\langle\alpha^1_{t_1}/P_1\rangle \ldots \langle\alpha^n_{t_n}/P_n\rangle[x \mapsto u, \vec{\vec{y}} \mapsto \vec{\vec{v}}].$$

Now, looking at the definition of $\delta(s, \vec{t})$, we clearly have

$$\mathfrak{F} \not\models \delta(s, \vec{t}),$$

which implies

$$\mathfrak{F} \not\models \Delta_s.$$

For the other direction, assume that $\mathfrak{F} \not\models \Delta_s$. It follows that for some terms $t_1, \ldots, t_n$, $\mathfrak{F} \not\models \delta(s, \vec{t})$. This implies the existence of elements $u, v_{1,1}, \ldots, v_{n,m_n}$ such that

$$\mathfrak{F} \not\models \sigma_s\langle\alpha^1_{t_1}/P_1\rangle \ldots \langle\alpha^n_{t_n}/P_n\rangle[x \mapsto u, \vec{\vec{y}} \mapsto \vec{\vec{v}}].$$

Now for each $i$ define $a_i$ by

$$a_i := \{w \in W \mid \mathfrak{F} \models \alpha^i_{t_i}[x \mapsto w, \vec{y_i} \mapsto \vec{v_i}]\}.$$

By Lemma 4.3(3),

$$a_i = t_i^+(\{v_{i,1}\}, \ldots, \{v_{i,m_i}\}),$$

whence each $a_i$ belongs to the universe of $\mathfrak{F}^\circ$. Furthermore, in the same way as before, we can use Lemma 4.3(2) to prove that

$$u \notin s^\circ(a_1, \ldots, a_n).$$

But now it is immediate that $\mathfrak{F}^\circ \not\models s = 1$, which is what we desired to prove. $\square$

**Proof of Theorem 3.** Immediate, by Lemma 4.3 and the fact that varieties can be identified with equational classes. (Since we are in a boolean context, any equation can be brought in the form $s = 1$.) $\square$

---

## 5 Conjugated Varieties

In this short section we provide a proof of Theorem 2. The crucial property of conjugated algebras causing the smooth behavior of conjugated varieties is the fact that their operators are *completely* additive. This will be made clear by the following proposition.

**Proposition 5.1** *Let $\mathfrak{A}$ be an atomic boolean algebra with operators, and let $\mathfrak{F}$ be its atom structure. Then*

1. *The map $r : x \mapsto \{a \in At\,\mathfrak{A} \mid a \leq x\}$ embeds $\mathfrak{A}$ into $\mathfrak{F}^+$ if and only if $\mathfrak{A}$ is completely additive.*
2. *In particular, if $\mathfrak{A}$ is completely additive then $\mathfrak{F}^\circ \hookrightarrow \mathfrak{A} \hookrightarrow \mathfrak{F}^+$.*

*Proof.* First observe that part 2 of the proposition follows from part 1, since $\mathfrak{F}^\circ$ and $\mathfrak{F}^+$ are the smallest and the largest complex algebra over $\mathfrak{F}$, respectively. Of part 1, we leave the easy left-to-right direction of the proof to the reader.

For the other direction, let $\mathfrak{A}$ be an atomic, completely additive boolean algebra with operators. Let $r : A \to \mathcal{P}(At\,\mathfrak{A})$ be the map given in the statement of the Theorem. We claim that $r$ preserves infinite joins and embeds $\mathfrak{A}$ into $\mathfrak{At}\,\mathfrak{A}^+$ --- this is clearly sufficient.

The result that $r$ is an embedding seems to be folklore, (cf. Goldblatt [2]), while Hirsch & Hodkinson [4] prove that $r$ preserves arbitrary joins. Let us just show here that $r$ is a homomorphism with respect to an arbitrary unary operator $f$, i.e., that

$$r(fc) = m_{R_f}(r(c)). \tag{1}$$

First note that

$$r(fc) = r\!\left(f\!\left(\bigvee_{c \geq b \in At\,\mathfrak{A}} b\right)\right) = r\!\left(\bigvee_{c \geq b \in At\,\mathfrak{A}} fb\right), \tag{2}$$

by the fact that $f$ is completely additive. Second, since $r$ preserves arbitrary joins, we have that

$$r\!\left(\bigvee_{c \geq b \in At\,\mathfrak{A}} fb\right) = \bigcup_{c \geq b \in At\,\mathfrak{A}} r(fb). \tag{3}$$

Combining (2) and (3) yields:

$$r(fc) = \{a \in At\,\mathfrak{A} \mid \exists b \in At\,\mathfrak{A}\,(b \leq c \;\&\; a \in r(fb))\}.$$

Thus, using the definitions of the map $r$ and the relation $R_f$ on $At\,\mathfrak{A}$, we obtain

$$\begin{aligned}
r(fc) &= \{a \in At\,\mathfrak{A} \mid \exists b \in At\,\mathfrak{A}\,(b \in r(c) \;\&\; a \leq fb)\} \\
&= \{a \in At\,\mathfrak{A} \mid \exists b \in At\,\mathfrak{A}\,(b \in r(c) \;\&\; R_f ab)\},
\end{aligned}$$

which by definition of $m_{R_f}$ is nothing but $m_{R_f}(c)$. Thus we have proved (1). $\square$

From this Proposition the proof of Theorem 2 is more or less immediate:

**Proof of Theorem 2.** We first prove part 2. Let $\mathsf{V}$ be an arbitrary conjugated variety of BAOs. From Proposition 5.1 and the fact that all conjugated BAOs are completely additive it follows immediately that $\mathsf{At\,V} = \mathsf{Wst\,V}$, or equivalently, that $\mathsf{V}$ is atom-sensitive. Then $\mathsf{V}$ is atom-elementary by Proposition 3.9, while the stronger result concerning the axiomatization of $\mathsf{At\,V}$ follows by Theorem 3.

Finally, we turn to part 1. By Theorem 1 it suffices to show that AC implies AD for conjugated varieties. Hence, assume that $\mathsf{V}$ is a variety of conjugated BAOs which is atom-canonical and consider two atomic algebras $\mathfrak{A}$ and $\mathfrak{B}$ with isomorphic atom structures. In order to prove that $\mathsf{V}$ is atom-determined, it suffices to prove that $\mathfrak{B}$ is in $\mathsf{V}$ if $\mathfrak{A}$ is in $\mathsf{V}$, so assume the latter. Let $\mathfrak{F}$ be the atom structure of $\mathfrak{A}$; it follows from (AC) that $\mathfrak{F}^+$ is in $\mathsf{V}$. But Proposition 5.1 implies that $\mathfrak{B}$ can be embedded in $\mathfrak{F}^+$. It is then immediate that $\mathfrak{B}$ is in $\mathsf{V}$. $\square$

---

## 6 Conclusions and Questions

Let me finish the paper with briefly mentioning some open problems in the field.

1. Most intriguing I find the question, whether *every* variety is atom-elementary. I conjecture that this is not the case, but I do not have a counterexample. Note that it follows by a result of Goldblatt that the class $\mathsf{At\,V}$ of a variety $\mathsf{V}$ is always closed under ultraproducts (cf. Corollary 5.3 in Goldblatt [2]).

2. It also seems worth while to try and find out what the relation is between the concepts introduced here and the notion of canonicity. In particular, I would like to know whether every atom-canonical variety is canonical. And, if the answer to this question is negative, then I would be interested to learn whether every atom-canonical variety with the finite algebra property is canonical.

3. There are a number of concepts defined in this paper (including the notion of atom-sensitivity) of which the precise relation is still unclear. For instance, I do not know whether:
   - (a) $AC = AD$
   - (b) $AX \leq AE$, or $AE \leq AX$

4. Is every variety of BAOs generated by its atomic members? (This question was raised at the conference.)

5. In this paper we have confined ourselves to the relation between algebraic and relational *structures*. One might bring morphisms into the picture as well, and investigate the property of the operation $\mathfrak{At}$ as a map between the *categories* of BAOs with homomorphisms and frames with bounded morphisms.

6. A related question, raised by A. Simon, is how closure properties of a class (not necessarily a variety) of BAOs are reflected in properties of the associated class of atom structures.

---

## References

- [1] R. Goldblatt. Varieties of complex algebras. *Annals of Pure and Applied Logic*, 44:173--242, 1989.

- [2] R. Goldblatt. Elementary generation and canonicity for varieties of boolean algebras with operators. *Algebra Universalis*, 34:551--607, 1995.

- [3] L. Henkin, J. D. Monk, and A. Tarski. *Cylindric Algebras Part I & II*. North-Holland, Amsterdam, 1971 & 1985.

- [4] R. Hirsch and I. Hodkinson. Complete representations in algebraic logic. Technical report, Department of Computing, Imperial College, London, 1994. To appear in *Journal of Symbolic Logic*.

- [5] I. Hodkinson. Atom structures of relation algebras and cylindric algebras. Submitted. Available as manuscript from the Department of Computing, Imperial College, London, 1994.

- [6] B. Jonsson and A. Tarski. Boolean algebras with operators. Parts I and II. *American Journal of Mathematics*, 73:891--939, 1951. and 74:127--162, 1952.

- [7] Y. Venema. Atom structures and Sahlqvist equations. Research Report 96-173, Mathematics Department, Victoria University of Wellington, 1996. To appear in *Algebra Universalis*.

---

[^1]: Most of the unexplained notions are formally defined in section 2.
[^2]: One may also find the notion of atom structure defined for non-atomic BAOs, but we will not do so here.
[^3]: Algebraists tend to write $R_f b_1 \ldots b_n a$ instead of $R_f a b_1 \ldots b_n$.
[^4]: Here $\mathsf{Str\,V}$ denotes the class of structures for $\mathsf{V}$, that is, all frames $\mathfrak{F}$ with $\mathfrak{F}^+$ in $\mathsf{V}$.
[^5]: An inspection of the proof of Theorem 2 reveals that the result can be truly stated for every variety of BAOs in which all operators are *completely additive*. Since conjugacy is the only equational property implying complete additivity that we are aware of, we have refrained from a more general formulation along these lines.
[^6]: In this paper I only consider properties of *varieties* of BAOs. However, many of the questions also apply to larger classes like quasi-varieties or universal classes, and many of the results go through. For instance, the proof of Theorem 3 can easily be adapted to the case of $\mathsf{V}$ being a universal class instead of a variety.
[^7]: The definitions and proofs of this section can be understood without prior exposition to modal correspondence theory.
