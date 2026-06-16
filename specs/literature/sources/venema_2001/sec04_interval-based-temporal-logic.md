### Interval-based Temporal Logic

Just as in the case for point-based temporal logics, we may choose a class of period structures, design a formal language to talk about it, and study the resulting temporal logic.

For instance, suppose that we are working with intervals in point-based flows of time, as described above. Taking the modal approach, we find ourselves in a multi-dimensional setting; that is, we want to evaluate formulas at *pairs* of points representing the beginning and the end point of the interval, respectively. Typical modal operators are $\langle D \rangle$ and $\circ$ with truth tables given by

$$
\begin{aligned}
\mathcal{M}, [s, t] \Vdash \langle D \rangle\varphi &\quad \text{if} \quad \mathcal{M}, [u, v] \Vdash \varphi \text{ for some } t, u \text{ with } s \leq u \leq v \leq t, \\
\mathcal{M}, [s, t] \Vdash \varphi \circ \psi &\quad \text{if} \quad \mathcal{M}, [s, u] \Vdash \varphi \text{ and } \mathcal{M}, [u, t] \Vdash \psi \text{ for some } u \text{ with } s \leq u \leq t.
\end{aligned}
$$

In words, $\langle D \rangle\varphi$ holds at an interval if $\varphi$ holds at some interval *during* it, while $\varphi \circ \psi$ holds at an interval if it can be chopped into a $\varphi$- and a $\psi$-part. In period terms, one would say that $\sqsubseteq$ and $C$ are the accessibility relations of $\langle D \rangle$ and $\circ$, respectively.

For such modal systems, one may investigate meta-logical properties like completeness and decidability. The general picture here is that one has a price to pay for the increase in expressivity: complete axiomatizations are scarce and hard to find, and undecidability is the rule rather than the exception. On a technical level, the modal logic of time periods thus seems to be more complex (and hence, more intriguing) than point logics over the same flows of time, but the *kinds* of questions that are asked do not differ much.

Hence, let us finish this section mentioning some issues that are of specific interest to period logics. To start with, period logics differ from point logics in the sense that in many cases it is natural to correlate the interpretation of atomic propositions. A condition that one often encounters is that of *homogeneity* requiring that an atomic proposition holds at a period if and only if it holds at each of its parts. It is obvious that such a condition only has intuitive appeal for the propositions corresponding to the event categories of states and activities. And even in the latter case, one may raise objections to the 'only if' part of this condition: I can truthfully say that I have been *walking* through town for hours when in fact, I have paused a couple of times to take a coffee.

Now suppose that we are implementing this condition on some interval structure $\mathcal{I}(\mathcal{T})$ induced by the flow of time $\mathcal{T}$ by demanding that for each propositional variable $p$ and each point-based valuation $\pi$ we have

$$
(\mathcal{I}(\mathcal{T}), \pi), [s, t] \Vdash p \text{ iff } \pi(u)(p) = 1 \text{ for all } u \text{ with } s \leq u \leq t.
\tag{6}
$$

Observe that thus we have effectively reduced period predicates to point predicates. Such a reduction would have considerable computational advantages, something that can easily be explained by taking a first order perspective. It is obvious that the particular proposal (6) is rather naive: Zeno's moving arrow will lead us into trouble. But perhaps there are more inventive modellings in which formulas can be evaluated at periods, while the valuations remain point-based?

In any case, regardless of the technical advantages of reducing period predicates to point predicates, it is clear that there is a rather general philosophical issue at stake here, namely the problem of which *kinds* of predicates apply to periods and points, respectively, and how these are correlated. This issue is in fact a matter of ongoing, and at times heated, debate.

## 6 Temporal Logic Now

As we mentioned before, temporal logic has become a vast and active research area with applications in many disciplines. In this section we will briefly sketch some of these recent developments. Since not all of the work mentioned here is covered by the monographs mentioned at the end of the next section, we provide references to the literature.

**Richer ontological structures.** One common trend in temporal logic is to study logics of richer ontological structures since it is obvious that for serious real-world applications the kind of temporal logics that we have been describing until now are far too simple. For example, one shortcoming of standard temporal logics is that they only deal with qualitative timing properties, whence they are inadequate for applications such as reasoning about real-time behaviour of software. In order to overcome this deficiency, people have designed logics for describing two-sorted structures consisting of a linear flow of time connected with some metric domain. Such approaches can be found both in the point-based and in the period-based paradigm, cf. [16] and [10], respectively. Another example of a multiple sorted ontology we have already met in the semantics of Ockhamist branching time logic, where branches appeared as a second kind of entities, next to points. One might vary on this 'standard' Ockhamist logic by admitting only some instead of all branches, perhaps a collection satisfying some addition constraints [24]. Applying this idea of using multiple sorted temporal ontologies to the discussion of the previous section, one can envisage structures in which points, periods and events co-exist, linked by suitable relations [18]. One possibility for such a link involves the notion of granularity: atomic objects might suddenly turn out to be divisible when approached at a different level. This obviously ties up with our way of classifying periods of time (months, weeks, days); modal logics for such layered structures are described in [15].

**Temporal logic at work.** Turning temporal logics into actual working systems has created a number of interesting problems and challenges. For instance, one of the most fundamental contributions that Artificial Intelligence has made to the field of temporal logic, is that of identifying the *frame problem*. This is the problem of formalizing the properties of an application area that are unaffected by the performance of some action without explicitly summing up *all* such properties. This problem appears to be independent of the particular formalism employed, and has to be faced by anyone wishing to give a formal account of reasoning about change [19]. The computer science literature on modal logics of time has yielded an interesting perspective on the modal truth relation $(\mathcal{M}, t \Vdash \varphi)$ between a model $\mathcal{M}$, which is supposed to be finite, and a formula $\varphi$; in this perspective $\varphi$ represents some property of a program and $\mathcal{M}$ some implementation of the program. For obvious reasons then, a considerable amount of effort has been devoted to finding fast *model checking* algorithms deciding whether a given formula holds in a given finite model [21]. As a last example we mention the *dynamic turn* which research in the semantics of natural language has taken. In this way of thinking, the meaning of a formula does not lie so much in its truth condition; linguistic expressions are rather like programs that update the information state of some agent. For instance, in Discourse Representation Theory [12] temporal expressions in natural language are used to extend and refine temporal representations of the discourse; these representations on their turn are syntactic items themselves that can be interpreted in standard models.

**Temporal logic in context.** There is an increasing tendency to study modal formalisms not as isolated systems but in connection with other branches of logic, as in *Correspondence Theory* which relates modal logic to first and second order logic. For instance, the use of game-theoretic methods has deepened our understanding of the relative expressive power of modal logics of time: in particular, variants of Ehrenfeucht-Fraisse games have provided an interesting perspective on expressive completeness results such as Theorem 4.1 [11, 22]. Recent approaches to decidability questions concerning modal and temporal logics use insights from algebraic logic and automata theory. This has lead to the identification of a variety of decidable fragments of first order logic, each of which is obtained from atomic formulas using all boolean connectives but allowing only a specific, guarded pattern of quantification [1]. As a last example we mention the emergence of so-called hybrid languages which aim to boost the expressive power of modal languages by adding some features from first order logic like 'names' (special variables that are to be true at a single state), over which quantification is allowed [9, 4].

## 7 Epilogue

What then, is temporal logic?

In the narrowest sense temporal logic comprises the design and study of specific systems for representing and reasoning about time, such as Prior's tense logic. These enterprises may have both an applied and a theoretical side, the former consisting of designing a system (that is, making choices in the fields of ontology, syntax and semantics), formalizing temporal phenomena in it, and then putting it to work (perhaps through implementing it). On the theoretical side, one aims at proving formal properties of the system, such as completeness or decidability.

On a slightly wider scale, temporal logicians may thus provide a supply of general tools and techniques for answering questions pertaining to specific systems. As an example we mention the method of filtration which is a quite general method of proving decidability of a temporal logic, and the canonical model method which is very useful in proving completeness results.

A more ambitious aim for temporal logicians is to come up with frameworks for comparing and connecting different modellings of time. This aim can be realized both at a technical and at a philosophical level. As an example of the first, think of the game-theoretic analysis of the expressive power of modal languages, or of the duality between point and period-based representations of time, respectively. On a philosophical level, a thorough classification of event types and of the correlation between predicates pertaining to points and to periods, respectively, would be an extremely useful tool in any discussion on formal representations of temporal phenomena.

Since all of this is relevant for each of the disciplines where formal reasoning about time is needed, Temporal Logic forms a prime example of the growing role of Logic as a source and channel of ideas and techniques applicable in related disciplines. Ultimately, one would hope that temporal logic can provide a unifying perspective on our sometimes confusing thoughts about this highly puzzling thing we call time.

### Suggested Further Reading

In this chapter we have only scratched the surface of Temporal Logic. The following monographs, each surveying part of the field of temporal logic, would form a good start for a bibliography. Concerning the philosophy of time I do not believe there is one standard reference, but Whitrow [23] is a very comprehensive study of the concept of time, while Le Poidevin & MacBeath [13] brings together some seminal articles on the subject. Ohrstrom & Hasle [17] gives a good treatment of philosophical aspects of temporal logic from a historical perspective. In Goldblatt [8] the reader finds a concise and very accessible treatment of the most important modal logics of time; Gabbay et alii [5] is a more extensive mathematical treatment. Manna & Pnueli [14] is a classic on applications of temporal logic in computer science; Gabbay et alii [6] gives a good overview of the applications of temporal logic in artificial intelligence. There seems to be no monograph on the treatment in formal linguistics of temporal aspects of natural language, but Steedman [20] surveys the field well. Van Benthem [3] is a stimulating blend of much of the above. Finally, for an overview of recent developments in temporal logic the reader is referred to the proceedings of the first two conferences devoted solely to temporal logic, ICTL'94 [7] and ICTL'97 [2].

### Acknowledgements

The research of the author has been made possible by a fellowship of the Royal Netherlands Academy of Arts and Sciences. Personal thanks are due to Johan van Benthem for helpful comments on a draft version of this chapter, to Marco Aiello for a scrutinous reading of the manuscript, and to Lou Goble for extensive help in cutting the manuscript to an acceptable size.

## References

[1] H. Andreka, J. van Benthem, and I. Nemeti. Modal logics and bounded fragments of predicate logic. *Journal of Philosophical Logic*, 27:217--274, 1998.

[2] H. Barringer, M. Fisher, D. Gabbay, and G. Gough, editors. *Proceedings of the Second International Conference on Temporal Logic -- ICTL'97*, to appear.

[3] J. van Benthem. *The Logic of Time*. Kluwer, Dordrecht, second edition, 1991.

[4] P. Blackburn and M. Tzakova. Hybrid languages and temporal logic. *Logic Journal of the IGPL*, to appear.

[5] D.M. Gabbay, I. Hodkinson, and M. Reynolds. *Temporal Logic: Mathematical Foundations and Computational Aspects*. Oxford Logic Guides. Oxford University Press, 1994.

[6] D.M. Gabbay, C.J. Hogger, and J.A. Robinson, editors. *Handbook of Logic in AI and Logic Programming*, volume 4 (Epistemic and Temporal Reasoning). Oxford University Press, Oxford, 1995.

[7] D.M. Gabbay and H.J. Ohlbach, editors. *Temporal Logic. Proceedings of the First International Conference, ICTL'94*, volume 827 of *Lecture Notes in Computer Science*, Berlin, 1994. Springer.

[8] R. Goldblatt. *Logics of Time and Computation*. CSLI Lecture Notes. Center for the Study of Language and Information, Stanford University, second edition, 1987.

[9] V. Goranko. Temporal logic with reference pointers. In Gabbay and Ohlbach [7], pages 133--148.

[10] M. Hansen and Zhou Chaochen. Duration Calculus: logical foundations. *Formal Aspects of Computing*, 9:283--330, 1997.

[11] N. Immerman and D. Kozen. Definability with bounded number of bound variables. In *Proceedings of the Conference on Logic in Computer Science (LICS'87)*, Washington, 1987. Computer Society Press.

[12] H. Kamp and U. Reyle. *From Discourse to Logic*. Kluwer Academic Press, Dordrecht, 1993.

[13] R. Le Poidevin and M. MacBeath, editors. *The Philosophy of Time*. Oxford University Press, Oxford, 1993.

[14] Z. Manna and A. Pnueli. *The Temporal Logic of Reactive and Concurrent Systems*. Springer Verlag, 1991.

[15] A. Montanari. *Metric and Layered Temporal Logic for Time Granularity*. PhD thesis, Institute for Logic, Language and Computation, University of Amsterdam, 1996.

[16] A. Montanari and M. de Rijke. Two-sorted metric temporal logic. *Theoretical Computer Science*, 183:187--214, 1997.

[17] P. Ohrstrom and P. Hasle. *Temporal Logic: From Ancient Ideas to Artificial Intelligence*. Studies in Linguistics and Philosophy. Kluwer Academic Publishers, Dordrecht, 1995.

[18] C. Gardent P. Blackburn and M. de Rijke. Back and forth through time and events. In Gabbay and Ohlbach [7], pages 225--237.

[19] E. Sandewall and Y. Shoham. Non-monotonic temporal reasoning. In Gabbay et al. [6], pages 439--498.

[20] M. Steedman. Temporality. In J. van Benthem and A. ter Meulen, editors, *Handbook of Logic and Language*, pages 895--938. Elsevier Scientific Publishers, Amsterdam, 1997.

[21] C. Stirling. Bisimulation, modal logic, and model checking games. *Logic Journal of the IGPL*, to appear.

[22] Y. Venema. Expressiveness and completeness of an interval tense logic. *Notre Dame Journal of Formal Logic*, 31:529--547, 1990.

[23] G.J. Whitrow. *The Natural Philosophy of Time*. Clarendon Press, Oxford, 1980.

[24] A. Zanardo. Branching-time logic with quantification over branches. *Journal of Symbolic Logic*, 61:1--39, 1996.
