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
