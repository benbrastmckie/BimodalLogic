## 10 Using Contemporaneity on the Integers

As another application of our main theorem 5 on Prior structures we shall use the technique to axiomatize the integers.

The system **US/Z** has the orthodox rules as well as the following axioms:

- all classical tautologies,
- the six Burgess--Xu axioms along with each of their duals,
- plus axioms for discreteness and no end points:
  $U(\top, \bot)$ and $S(\top, \bot)$,
- and suitable versions of Prior:

$$\text{Prior-UZ:} \quad Fp \to U(p, \neg p)$$

$$\text{Prior-SZ:} \quad Pp \to S(p, \neg p)$$

**Theorem 8.** *The system **US/Z** is sound and weakly complete for the semantics of until and since over the integers.*

**Proof.** The proof follows closely that for the reals. Soundness is clear. To show completeness we just put together the steps as before with the observation that we can build a Prior structure and then use the following counterpart of Doets' theorem. $\blacksquare$

**Theorem 9.** *Suppose that $M$ is a temporal structure in a finite language whose flow of time is countable, discrete and without end points.*

*Suppose further that for any contemporaneous equivalence relation $\sim$ on $M$, the $\sim$ classes do not end in gaps.*

*Then for all $k < \omega$, there is a temporal structure with flow of time the integers satisfying the same monadic first-order sentences of quantifier depth at most $k$ as $M$ does.*

**Proof.** First some preliminaries. Fix $k \geq 3$.

Here a *structure* will mean a linear temporal structure in our finite language.

If $M$ and $N$ are structures we write $M \equiv_k N$ if and only if $M$ and $N$ agree on the truth of monadic sentences of quantifier depth at most $k$. Note that since $k \geq 3$, if $M \equiv_k N$ then $M$ and $N$ either both have a right (respectively left) hand end point or both do not have a right (resp. left) hand end point. Discreteness is also preserved.

If $a$ is an element of a discrete structure $M$ then we write $a - 1$ for its immediate predecessor if it has one and $a + 1$ for its immediate successor, if it has one.

Say that $M$ is *good* if and only if there is some $N \equiv_k M$ such that the flow of time of $N$ is an interval of the integers.

Say that $M$ is *very good* if and only if, for all $t \leq u$ in $M$, the substructure $M \mid [t, u]$ is good.

**Lemma 14.** *If $N$ is countable and very good then it is good.*

**Proof.** All finite structures are good so suppose that $N$ has countably infinite domain. If $N$ has two end points then it is clearly good. First consider the case when $N$ has a beginning $a_0$ but no (right hand) end.

Choose $a_i \in N$ for each positive integer $i$ such that $i < j$ implies $a_i < a_j$ and for all $t \in N$, there is $j$ such that $t < a_j$. Since $N$ is very good, $N \mid [a_i, a_{i+1} - 1]$ is good. For $i = 0, 1, \ldots$, take $Z_i \equiv_k N \mid [a_i, a_{i+1} - 1]$ with a finite interval of $\mathbb{Z}$ as a flow.

Because $\equiv_k$ is preserved under lexicographic sums,

$$N \equiv_k \Sigma_{i \in \mathbb{N}} Z_i$$

the latter having flow isomorphic to a (half) subinterval of $\mathbb{Z}$.

If $N$ has an end but no beginning then the proof is similar. If $N$ has no end points then choose $a_0 \in N$, use the above arguments on $(-\infty, a_0]$ and $[a_0 + 1, +\infty)$, and then use the lexicographic sum result to add appropriate structures together. $\blacksquare$

Define $\sim_M$ on a temporal structure $M$ by, for any $a, b \in M$, $a \sim_M b$ if and only if

- $a = b$,
- $a < b$ and $M \mid [a, b]$ is very good or
- $b < a$ and $M \mid [b, a]$ is very good.

**Lemma 15.** *$\sim_M$ is a contemporaneous equivalence relation on the domain of any $M$.*

**Proof.** There are only finitely many logically inequivalent maximal consistent conjunctions $\gamma$ of sentences of quantifier depth $\leq k$. Any structure is a model of just one such $\gamma$, so if $N_1 \models \gamma$ then $N_2 \equiv_k N_1$ iff $N_2 \models \gamma$. Only some will be true of good structures -- $\{\gamma_1, \ldots, \gamma_s\}$ say. $N$ is good iff $N \models \bigvee_{i \leq s} \gamma_i$.

Let $\gamma(z, t)$ be the result of relativising the quantifiers of $\bigvee_{i \leq s} \gamma_i$ to $[z, t]$, where $z$ and $t$ are new variables.

Then

$$\varepsilon(x, y) = \quad x < y \to \forall z t(x \leq z \leq t \leq y \to \gamma(z, t))$$
$$\quad \wedge \quad y < x \to \forall z t(y \leq z \leq t \leq x \to \gamma(z, t))$$

is a formula defining $\sim_M$.

To show that $\sim$ is contemporaneous, we first show that it is an equivalence relation. The difficult part is transitivity. Suppose that $a < b < c$ are in $M$ and $a \sim_M b$ and $b \sim_M c$. We show that $M \mid [a, c]$ is very good by showing that if $a \leq t < u \leq c$ then $M \mid [t, u]$ is good.

If $t$ and $u$ are on the same side of $b$ then this is clear. If $b = t$ or $b = u$ then use a lexicographic sum.

So assume that $a \leq t < b < u \leq c$. Now $M \mid [t, b]$ and $M \mid [b + 1, u]$ are both good. Choose $Z_1 \equiv_k M \mid [t, b]$ and $Z_2 \equiv_k M \mid [b + 1, u]$ each with flow a subset of $\mathbb{Z}$. Then we know that $M \mid [t, u] \equiv_k Z_1 + Z_2$ whose flow is isomorphic to an interval of $\mathbb{Z}$.

That the $\sim_M$ classes are intervals follows from the fact that very goodness is inherited by substructures on subintervals.

Contemporaneity then follows from the fact that the definition of $\sim_M$ is in terms of exactly the right substructure. $\blacksquare$

Now let us turn to the proof of the main theorem.

If $M$ is good then we are done. So suppose not. Thus $M$ is not very good. So there is $a < b \in M$ such that $M \mid [a, b]$ is not good. Thus $M \mid [a, b]$ is not very good and we have two disjoint $\sim$ classes.

Now $a$'s class can not end at a gap on the right so it must include a point $c$ but not the successor $c + 1$ of $c$. This can not be because $M \mid [c, c + 1]$, like all finite structures, is very good and $\sim$ is transitive. $\blacksquare$

Axiomatizing $U$ and $S$ over the natural numbers can be done in a similar manner.

## References

[1] Johan van Benthem, *The Logic of Time*, Reidel, Dordrecht, 1982.

[2] J.P. Burgess, *Axioms for tense logic I: "Since" and "Until"*, Notre Dame J. Formal Logic 23 no. 2 (1982) 367--374.

[3] J.P. Burgess and Y. Gurevich, *The decision problem for linear temporal logic*, Notre Dame J. Formal Logic 26 no. 2 (1985) 115--128.

[4] Kees Doets, *Completeness and Definability*, Dissertation, Mathematical Institute, Univ. of Amsterdam, 1987.

[5] Kees Doets, *Monadic $\Pi_1^1$-theories of $\Pi_1^1$-properties*, Notre Dame J. Formal Logic 30 no. 2 (1989), 224--240.

[6] D.M. Gabbay, *An irreflexivity lemma*, in: Aspects of Philosophical Logic, ed. U. Monnich, Reidel, Dordrecht, 1981, 67--89.

[7] D.M. Gabbay in collaboration with I.M. Hodkinson and M.A. Reynolds, *Temporal Logic: Mathematical Foundations and Computational Aspects*, O.U.P. to be published 1992.

[8] D.M. Gabbay and I.M. Hodkinson, *An axiomatization of the temporal logic with Until and Since over the real numbers*, J. Logic and Computation 1 (1990) 229--259.

[9] D.M. Gabbay, I.M. Hodkinson and M.A. Reynolds, *Temporal expressive completeness in the presence of gaps*, in Proceedings ASL European Meeting, 1990, Helsinki, vol 1 of Lecture Notes in Logic, Springer-Verlag 1991.

[10] D.M. Gabbay, A. Pnueli, S. Shelah and J. Stavi, *On the temporal analysis of fairness*, 7th ACM Symposium on Principles of Programming Languages, Las Vegas, 1980, 163--173.

[11] D.M. Gabbay and M.A. Reynolds, *Inheriting expressive completeness*, Logic and Computation Research Report, Dept Comp., Imperial College, in preparation.

[12] I.M. Hodkinson, *Notes on the irreflexivity rule*, Logic and Computation Research Report, Dept Comp., Imperial College, in preparation.

[13] J.A.W. Kamp, *Tense Logic and the theory of linear order*, Ph.D. Thesis, University of California, 1968.

[14] S. Kuhn, *The domino relation: flattening a two-dimensional logic*, Journal of Philosophical Logic, 18 (1989) 173--195.

[15] J.G. Rosenstein, *Linear Orderings*, Academic Press, New York, 1982.

[16] Y. Venema, *Modal derivation rules*, ITLI prepublication, Instit. for Lang., Logic and Information, University of Amsterdam, 1991.

[17] Y. Venema, *Completeness via Completeness: Since and Until*, in: Colloquium on Modal Logic 1991, ed. M. de Rijke, ITLI-Network Publication, Instit. for Lang., Logic and Information, University of Amsterdam, to appear.

[18] M. Xu, *On some U,S-tense logics*, J. of Philosophical Logic 17 (1988) 181--202.

[19] A. Zanardo, *A complete deductive system for Since-Until branching time logic*, J. of Philosophical Logic 20 (1991) 131--148.

---

Department of Computing, Imperial College, London SW7 2BZ, United Kingdom.

*Received October 22, 1991*
