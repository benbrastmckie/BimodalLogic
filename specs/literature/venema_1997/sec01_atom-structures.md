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
