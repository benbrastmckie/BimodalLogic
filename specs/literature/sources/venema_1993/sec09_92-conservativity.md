### 9.2 Conservativity

An interesting point which has not been discussed yet concerns the question whether non-$\xi$ rules add new theorems to a logic. Some scattered results are known:
In the introduction we saw an example where a rule is *admissible*: the logic $K^t 4$ already axiomatizes the class of irreflexive transitive tense frames, so adding $IR$ does not produce any new theorem.

On the other hand, adding $IR$ to $K^t L(Gp \to p)$ makes this logic inconsistent, so here $IR$ is not conservative. In Zanardo [46], Zanardo replaced the irreflexivity rule used in Burgess [6] to axiomatize a branching-time temporal logic, by (infinitely many) axioms. An similar case is found in cylindric modal logic and the modal logic of relation algebras (cf. Venema [42, 43]), where adding a non-$\xi$ rule to a finite set of axioms creates a finite derivation system for a logic which is known not to be finitely axiomatizable when only the orthodox derivation rules $MP$, $UG$ and $SUB$ are allowed. A striking difference between a uni-directional similarity type and its tense counterpart concerns the modal logic of the two-dimensional 'domino relation', where an axiomatization of the uni-directional modal logic needs *both* infinitely many axioms *and* a non-$\xi$ rule (cf. Kuhn [22]), while the tense logic allows a finite and orthodox axiomatization (cf. Venema [41]).

The general question

> Are there natural criteria deciding when a non-$\xi$ rule is admissible over a derivation system?

lies (almost) completely open. We have one minor result: recall that a formula is *closed* if it does not contain propositional variables (only constants).

**Definition 9.1** *A logic $\Lambda$ has the* interpolation property $(IP)$ *if $\Lambda \vdash \phi \to \psi$ implies the existence of an interpolant $\chi$ in the common language of $\phi$ and $\psi$, such that $\Lambda \vdash \phi \to \chi$ and $\Lambda \vdash \chi \to \psi$.*

**Lemma 9.2** *Let $\Lambda$ be a logic and $\xi$ a formula, such that (i) $\Lambda$ has the IP, and (ii) for every closed formula $\gamma$, $\Lambda(-\xi) \vdash \gamma$ implies $\Lambda \vdash \gamma$.*
*Then $N\xi R$ is conservative over $\Lambda$.*

**Proof.**
Assume that $\Lambda$ and $\xi$ satisfy (i) and (ii). Denote derivability in $\Lambda$ by $\vdash$. To show that $N\xi R$ is conservative over $\Lambda$, we must prove

$$\vdash \neg\xi(\vec{p}) \to \phi \ \Rightarrow \ \vdash \phi, \text{ if no } p_i \text{ occurs in } \phi$$

So assume $\vdash \neg\xi(\vec{p}) \to \phi$ where $\vec{p} \notin \phi$. By (i) there is an interpolant $\gamma$ for $\neg\xi(\vec{p})$ and $\phi$; $\gamma$ must be closed, as $\neg\xi(\vec{p})$ and $\phi$ do not share any variables.
As $\vdash \neg\xi(\vec{p}) \to \gamma$, one application of $N\xi R$ shows that $\gamma$ is a $\Lambda(-\xi)$-theorem, so by (ii), $\vdash \gamma$. Now $\vdash \phi$ is immediate by $\vdash \gamma \to \phi$. $\square$

### 9.3 Questions and Remarks

We end this paper with some miscellaneous questions and remarks:

1. The most obvious question is whether the $SN\Xi$-result can be extended to similarity types not having the $D$-operator or tense diamonds, and to arbitrary canonical formulas. Independently from our result, Goranko [17] announces a similar meta-theorem on *weak* completeness, for arbitrary canonical formulas. Hodkinson [10] extends our result to a similarity type where diamonds come in pairs too, here having *complementary* accessibility relations ($R_{-\Diamond} = (R_\Diamond)^c$).

2. Call a class *negatively definable* if it is of the form $\mathsf{Fr}_{-\Xi}$. There seems to be an interesting connection between this notion and what Kracht calls *describable properties*, cf. [21]. Is there a *structural characterization* for negatively definable classes, like there is for modally definable classes? It is not difficult to see that negatively definable classes are closed under disjoint unions and generated subframes; any $\mathsf{Fr}_{-\Xi}$ *reflects* p-morphic images, and if it is elementary, ultrafilter extensions too. Do these preservation properties give the desired characterization for (elementary) negatively definable classes?

3. Let $\Lambda$ be the set of formulas $\Theta(\mathsf{Fr}_{(\Sigma, -\Xi)})$, and $\mathsf{Fr}_\Lambda$ the class of frames where $\Lambda$ is valid. What is the relation between $\mathsf{Fr}_{(\Sigma, -\Xi)}$ and $\mathsf{Fr}_\Lambda$? Note that for $\Sigma = \emptyset$ and $\Xi$ only containing a formula characterizing irreflexivity, we have that $\mathsf{Fr}_\Lambda$ is the class of p-morphic images of $\mathsf{Fr}_{(\Sigma, -\Xi)}$.

4. Consider the tense similarity type with diamonds $\{F, P, D\}$. To axiomatize the irreflexive frames, we now have the choice between the $F$-irreflexivity *rule* and the *axiom* $Fp \to Dp$. When and how can rules be replaced by axioms, and vice versa?

5. An interesting aspect of non-$\xi$ rules is that in some sense they behave like axioms; in the introduction we already saw how they *characterize* the class $\mathsf{K}_{-\xi}$ as the class of frames where $N\xi R$ is *sound*.

   Maybe it is better to use the term *anti-axioms*[^6], however, according to their behaviour in derivation systems: in a logic having a rule $N\xi R$, we strongly want to *avoid* $\xi$ as a theorem; it would go to far to add the negation of $\xi$ as a theorem (for instance, an irreflexive frame can have a reflexive p-morphic image), but a formula $\phi$ that provably implies $\xi$ (under the usual restriction concerning the variables), is so 'bad' that we accept $\neg\phi$ as a theorem.

   In this 'rules as anti-axioms perspective', it might be interesting to investigate non-$\xi$ rules as operators in the lattice of modal (tense) logics.

[^6]: This explains our notation '$-\xi$'

---

## References

[1] H. Andreka, I. Nemeti and I. Sain, "On the strength of temporal proofs", *Theoretical Computer Science* **80** (1991) 125--151.

[2] J.F.A.K. van Benthem, "Correspondence theory", in: [9], 167--247.

[3] J.F.A.K. van Benthem, *Modal Logic and Classical Logic*, Bibliopolis, Naples, 1985.

[4] J.F.A.K. van Benthem, *Language in Action*, North-Holland, Amsterdam, 1991.

[5] P. Blackburn, *Nominal Tense Logic*, PhD Dissertation, University of Edinburgh, Edinburgh, 1989.

[6] J.P. Burgess, "Decidability for branching time", *Studia Logica*, **39** (1980), 203-218.

[7] J. Crossley (ed.), *Algebra and Logic*, Lecture Notes in Mathematics **450**, Springer, Berlin, 1975.

[8] D.M. Gabbay, "An irreflexivity lemma with applications to axiomatizations of conditions on linear frames", in: [24], pp. 67--89

[9] D.M. Gabbay and F. Guenthner, (eds.), *Handbook of Philosophical Logic, vol II*, Reidel, Dordrecht, 1984.

[10] D.M. Gabbay, in collaboration with I. Hodkinson and M. Reynolds, *Temporal Logic: Mathematical Foundations and Computational Aspects*, Oxford University Press, Oxford, 1992, to be published.

[11] D.M. Gabbay and I.M. Hodkinson, "An axiomatization of the temporal logic with Since and Until over the real numbers", *Journal of Logic and Computation* **1** (1990) 229--259.

[12] G. Gargov and V. Goranko, "Modal logic with names", in: [29], 81--103.

[13] G. Gargov, S. Passy and T. Tinchev, "Modal environment for boolean speculations", in: [36], 253--263.

[14] R. Goldblatt, "Metamathematics of modal logic", *Reports on Mathematical Logic*, **6** (1976) 41--77, **7** (1976) 21--52.

[15] R. Goldblatt, "Varieties of complex algebras", *Annals of Pure and Applied Logic*, **44** (1989) 173--242.

[16] R. Goldblatt and S. Thomason, "Axiomatic classes in propositional modal logic", in [7], 163--173.

[17] V. Goranko, "Applications of quasi-structural rules to axiomatizations in modal logic" (abstract), in: [23], p. 119.

[18] B. Jonsson and Alfred Tarski, "Boolean algebras with operators", *American Journal of Mathematics*, **73** (1951) 891--939, **74** (1952) 127--162.

[19] S. Kanger (ed.), *Proc. of the Third Scandinavian Logic Symposium Uppsala 1973*, North-Holland, Amsterdam, 1975.

[20] R. Koymans, *Specifying Message Passing and Time-Critical Systems with Temporal Logic*, PhD Dissertation, Eindhoven University of Technology, 1989.

[21] M. Kracht, "How completeness and correspondence theory got married", in [29], 161--185.

[22] S. Kuhn, "The domino relation: flattening a two-dimensional logic", *Journal of Philosophical Logic*, **18** (1989) 173--195.

[23] Logic Colloquium '91, *Abstracts of the 9th International Congress of Logic, Methodology and Philosophy of Sciences, Uppsala, 1991*, Volume I: Logic.

[24] U. Monnich (ed.), *Aspects of Philosophical Logic*, Reidel, Dordrecht, 1981.

[25] I. Nemeti, "Algebraizations of quantifier logics: an introductory overview", *Studia Logica*, **50** (1991) 485--570.

[26] S. Passy and T. Tinchev, "PDL with Data Constants", *Information Processing Letters*, **20** (1985) 35--41.

[27] M. Reynolds, *Complete Axiomatization for Until and Since over the Reals --- IRR Rule Not Needed*, *Studia Logica*, **51** (1992) 165--194.

[28] M. de Rijke, *The Modal Logic of Inequality*, *Journal of Symbolic Logic*, **57** (1992) 566--584.

[29] M. de Rijke (ed.), *Colloquium on Modal Logic 1991*, Dutch Network for Language, Logic and Information, Amsterdam, 1991.

[30] D. Roorda, *Resource Logics: Proof-theoretical Investigations*, PhD Dissertation, University of Amsterdam, 1991.

[31] H. Sahlqvist, "Completeness and correspondence in the first and second order semantics for modal logic", in: [19], pp. 110--143.

[32] I. Sain, *Successor Axioms Increase the Program Verification Powers of the "Sometime + Next-time" Logic*, Preprint No. **23** (1983), Mathematical Institute of the Hungarian Academy of Sciences, Budapest.

[33] I. Sain, "Is 'Some-Other-Time' sometimes better than 'Sometime' for proving partial correctness of programs?" *Studia Logica*, **47** (1988) 279--301.

[34] I. Sain, "Temporal logics need their clocks", *Theoretical Computer Science*, **95** (1992), 75--96.

[35] G. Sambin and V. Vaccaro, "A new proof of Sahlqvist's theorem on modal definability and completeness", *Journal of Symbolic Logic*, **54** (1989) 992--999.

[36] D. Skordev (ed.), *Mathematical Logic and its Applications*, Plenum Press, New York, 1987.

[37] Y. Venema, "Expressivenes and completeness of an interval tense logic", *Notre Dame Journal of Formal Logic*, **31** (1990) 529--547.

[38] Y. Venema, *Two-dimensional Modal Logics for Relation Algebras and Temporal Logic of Intervals*, ITLI-prepublication series LP-89-03, University of Amsterdam, Amsterdam, 1989.

[39] Y. Venema, "A modal logic for chopping intervals", *Journal of Logic and Computation*, **1** (1991) 453--476.

[40] Y. Venema, "Completeness by completeness: Since and Until", in: [29], 279--285.

[41] Y. Venema, "The tense logic of dominoes", *Journal of Philosophical Logic*, **21** (1992) 173--182.

[42] Y. Venema, "Many-dimensional modal logic", doctoral dissertation, University of Amsterdam, 1991.

[43] Y. Venema, *Cylindric Modal Logic*, 1992, manuscript, submitted.

[44] A. Zanardo, "A finite axiomatization of the set of strongly valid Ockhamist formulas", *Journal of Philosophical Logic*, **14** (1985), 447--468.

[45] A. Zanardo, "A complete deductive system for Since-Until branching-time logic", *Journal of Philosophical Logic*, **20** (1991), 131--148.

[46] A. Zanardo, "Axiomatization of 'Peircean' branching-time logic", *Studia Logica*, **49** (1990) 183--196.
