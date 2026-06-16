## 2. Combinations of Tense and Modalities

In this section, we present the logics that will be considered in the following;
for further references, see [20,29]. The language consists of a set of classical
connectives enriched by the linear temporal operators G and H and by the
path quantifier ∀.

**Definition 2.1.** Given a denumerable set P of propositional symbols, with p ∈
P, the set F of (well-formed) (Ockhamist) formulas is defined by the grammar
A ::= p | ¬A | A ∧A | GA | HA | ∀A.
The set of atomic formulas (or atoms) is P. The complexity of a formula is
the number of occurrences of connectives (¬, ∧), operators (G, H) and path
quantifiers (∀).
The intuitive meaning of G and H is always in the future and always in
the past, respectively, with regard to a single branch. The path quantifier ∀
allows one to switch from a branch to another: intuitively, ∀A holds at a node
s iffA holds in all the branches starting from the node s. Derived connectives,
operators and quantifiers (e.g., ⊥, ⊃, ∨, F, P and ∃) are defined as is standard.
Our development and results are modular with respect both to the prop-
erties of the linear and the branching dimensions of the logics. Next, we settle
their underlying linear temporal semantic structures.

**Definition 2.2.** A (strict) linear order is a pair (W, ≺) where ≺is a transitive
and irreflexive relation on the non-empty set W, such that for all x, y ∈W, if
x ̸= y then either x ≺y or y ≺x.
Other interesting properties of linear orders to be considered are:
(Fst) there exists z ∈W such that for all x ∈W, y ≺x;
(Lst) there exists y ∈W such that for all x ∈W, x ≺y;
(Nfst) for all x ∈W there is y ∈W such that y ≺x;
(Nlst) for all x ∈W there is y ∈W such that x ≺y;
(Dns) for all x, y ∈W, if x ≺y then there is z ∈W such that x ≺z ≺y;
(Udsc) for all x, y ∈W, if y ≺x then there exists z ∈W such that z ≺x and
there is no u ∈W with z ≺u ≺x;
(Ddsc) for all x, y ∈W, if x ≺y then there exists z ∈W such that x ≺z and
there is no u ∈W with x ≺u ≺z.
Fst/Lst guarantee the existence of a first/last (minimal/maximal) ele-
ment, respectively. Reciprocally, Nfst/Nlst respectively guarantee that a
first/last element does not exist. Dns guarantees that the order is dense.
Finally, Udsc/Ddsc guarantee, respectively, downward/upward discreteness,

that is, the existence of an immediate predecessor/successor for non-extremal
elements.
Below, we will often confuse any meaningful (+ separated) sequence C
of these properties with the class of all linear orders that satisfy the condi-
tions in C. Namely, we will use () to denote the class of all strict linear orders
and (Dns+Fst+Nlst) to denote the class of all dense linear orders with a first
element and without a final element.
Let us now introduce also the branching dimension.

**Definition 2.3.** A tree is an irreflexive ordered set T = (W, ≺) in which the set
of the ≺-predecessors of any element of W is linearly ordered by ≺, that is,
for all x, y, z in W, if x ≺z and y ≺z then either x ≺y or y ≺x or x = y.
A path in a tree T is a maximal linearly ordered set of nodes. A branch
in a tree T is any set of nodes {y | y ∈π and x ≺y} for a given path π and a
node x ∈π. The least node x of a branch b is the initial node of b. The set of
all branches in T will be denoted by Br(T). If b and c are branches and b ⊆c,
then we say that b is a sub-branch of c and c is a super-branch of b.
Given a tree T, a bundle B on T is a subset of Br(T) closed under sub-
branches and super-branches and such that every node of T belongs to some
branch in B. A bundled tree is a pair (T, B) where T is a tree and B is a bundle
on T.
By following the terminology of [10], we can define the following classes
of trees and bundled trees.

**Definition 2.4.** Let C be a class of linear orders. We define T (C) as the class of
all trees in which every path is in C, B(C) as the class of bundled trees (T, B)
such that T ∈T (C), B+(C) as the class of all bundled trees (T, B) such that
every path in the bundle B is in C.
The semantics of branching-time logics is commonly defined on the tree-
like structures given above (we refer the reader to, e.g., [29] for a rigorous
presentation). However, when considering bundled trees, such a semantics can
be given in a more traditional Kripkean style by considering the so-called
Ockhamist frames [29] (closely related to the Kamp frames of [25]), i.e., tri-
ples of the form (W, ≺, ≃), in which W corresponds to the set of branches of
the (bundled) tree, ≺is the inclusion relation between branches and ≃is the
equivalence relation of having the same initial node, as illustrated by Fig. 1.

**Definition 2.5.** Let C be a class of linear orders. A C-basic-frame is a triple
(W, ≺, ≃), where (W, ≺) is a non-empty union of linear orders in C and ≃is
an equivalence relation on W.
Other interesting properties of frames to be considered are:
(Dsj) for all x, y ∈W, if x ≃y then x ⊀y;
(Wdc) for all x, y, y′ ∈W, if x ≺y ≃y′ then there exists x′ ∈W such that
x ≃x′ ≺y′;
(Sdc) for all x, y, z, x′, z′ ∈W, if x ≺y ≺z ≃z′ and x ≃x′ ≺z′ then there
exists y′ ∈W such that y′ ≃y and x′ ≺y′ ≺z′;

*Figure 1. A bundled tree (left) and the corresponding*

Ockhamist frame (right)
(Mb) for all x, y ∈W, if x ≃y and x ̸= y, then there exists x′ ∈W such
that x′ ≻x and there is no y′ ∈W with y′ ≻y and x′ ≃y′;
(Mb−) for all x, y ∈W, if x is ≺-maximal and x ≃y then x = y.
The property Dsj stands for disjointness of ≺and ≃, and comes from
the fact that a node in a tree cannot be a descendant of itself. Wdc stands
for weak diagram completion and is a consequence of the linearity of the order
relation in a tree. Sdc is a strong form of Wdc and stands for strong diagram
completion. Finally, the maximality of branches condition Mb models the fact
that two distinct branches in a tree must have disjoint sub-branches. Mb−is
another way of expressing the maximality of branches.
Below, we will often confuse any meaningful (+ separated) sequence D of
these properties with the class of all basic frames that satisfy the conditions in
D. Given a class C of linear orders, the elements of such a class will be dubbed
C-D-frames. The class of Ockhamist frames is usually defined to be the class
of ()-(Dsj+Wdc+Mb)-frames.
As is standard, we obtain an interpretation structure for the logical lan-
guage by providing a frame with a valuation function.

**Definition 2.6.** A C-D-structure is a 4-tuple (W, ≺, ≃, V), where (W, ≺, ≃) is
a C-D-frame and V is a valuation function V : W →2P, where P is the set of
propositional symbols.
In the literature, the semantics of Ockhamist branching-time logics is
sometimes defined by requiring that the valuation function obeys particular
conditions, e.g., as in [20], that points ≃-related satisfy the same set of atoms
(we will sometimes refer to this assumption as atomic harmony). We will see
below how our treatment can be adapted in order to deal with this case too.
The notion of truth with respect to a point in a structure is now easily
definable, having the temporal operators G and H operate along the ≺-lines of
points, and the quantifier ∀within ≃-equivalence classes.

**Definition 2.7.** The satisfaction relation |= for Ockhamist formulas over a C-D-
structure M = (W, ≺, ≃, V) and a point u ∈W is defined by:
M, u |= p
iff
p ∈V(u);
M, u |= ¬A
iff
M, u ̸|= A;
M, u |= A ∧B
iff
M, u |= A and M, u |= B;
M, u |= GA
iff
M, v |= A for all v such that u ≺v;
M, u |= HA
iff
M, v |= A for all v such that v ≺u;
M, u |= ∀A
iff
M, v |= A for all v such that u ≃v.
This notion of C-D satisfaction extends to the notions of C-D-satisfiability,
C-D-validity and C-D-entailment as is standard.
Below, we will write L(C, D) to refer to the logic on the Ockhamist lan-
guage defined by the class of all C-D-structures.

**Lemma 2.8.** Let C be a class of linear orders. Then:
(i) L(C, ()) = L(C, (Dsj));
(ii) L(C, (Dsj+Wdc)) = L(C, (Wdc+Sdc));
(iii) L(C, (Dsj+Wdc+Mb)) = L(C, (Wdc+Sdc+Mb−)) and both coincide also
with the logic defined over bundled trees in the class B+(C).

*Proof.* (i), (ii) and the first equivalence in (iii) can be shown by a trivial
adaptation of analogous results proved in [29] in the case of general linear-
time. We obtain the last equivalence by noticing that there is a one-to-one
correspondence between elements of B+(C), for a given class C of linear orders,
and Ockhamist frames in which every linear component is in C.
$\square$

Given these equivalences, from now on we will focus on the logics L(C, D)
where D is one of our four target branching classes, that is: (), (Wdc),
(Wdc+Sdc) or (Wdc+Sdc+Mb−). This will allow us to span from the logic of
basic frames toward the logic of Ockhamist frames in a stepwise manner.
Moreover, though in the rest of the paper our reference, for what concerns
the semantical structures, will be the C-D-frames of Definition 2.6, Lemma 2.8
will allow us to read our results also in terms of tree-like structures. In partic-
ular, by Lemma 2.8, the final point of our hierarchy of branching classes (the
one given by the combination (Wdc + Sdc + Mb−)) corresponds, for C some
class of linear orders, to the class B+(C) of Definition 2.4. Notice, however,
that many of the classes of linear orders C considered here, i.e., C = (), C =
(Fst), C = (Ddsc), C = (Udsc) and C = (Dns), enjoy closure properties such
that the classes B(C) and B+(C) coincide;1 see [10] for further details and a
proof of this fact. Thus, for such particular Cs, our results indeed extend also
to the logic defined by the class B(C).
1 In particular, B(()) = B+(()) implies that the logic L((), (Wdc + Sdc + Mb−)) coincides
with the Ockhamist logic of general time over bundled trees described in [29].

## 3. The Mosaic Method

In this section, we give an extension of the definition of the mosaic method
for a linear tense logic, given in [14], to the case when an orthogonal modality
is introduced. By considering some interaction properties, a class of bundled
branching-time logics is covered.
Intuitively, the linear temporal (vertical, in our terminology) mosaics of
[14] can be seen as pairs (Γ, Δ) where Γ and Δ refer to two points in a tempo-
ral structure, such that the point associated to Γ precedes (by the relation ≺)
the one associated to Δ. Γ and Δ are indeed sets of formulas, namely formulas
that are satisfied at the corresponding point. Given this basic intuition, it is
reasonable to require that linear temporal mosaics satisfy some local coherence
conditions: as an example, given a mosaic (Γ, Δ), we want that if GA ∈Γ, then
A ∈Δ. Moreover, we are interested in considering particular sets of mosaics,
saturated in such a way that we are able to build a complete model by just
composing the mosaics contained in a given set of that kind. In other words,
we need to define the saturation conditions that a “good” set of mosaics is
required to satisfy. Basically, this amounts to making sure that each counter-
example occurring in the model we are building can be “cured”. In the context
of linear tense logics, a counterexample consists in the presence of a point w
labeled with a formula of the form FA such that all of its successors are labeled
with ¬A. By “curing” it, we mean adding a new point w′ to the structure (as
a successor of w) such that the labeling set of w′ contains A.
We keep here the intuition behind linear temporal mosaics [14] but
need to consider also horizontal mosaics, to take into account the branch-
ing nature of the logics. Expectedly, these will be pairs (Γ, Δ) of compatible
sets of formulas, where the sets now refer to ≃-related points in the structure.
Corresponding coherence and saturation conditions will apply. Namely such
a compatibility will consist primarily in requiring as a coherence condition
that Γ and Δ agree with respect to state formulas (which must include the
propositional symbols in case we adopt the atomic harmony approach). Satu-
ration-wise, there is also the need to deal with “branching counterexamples”,
i.e., points labeled with a formula of the form ∃A such that no ≃-related point
contains A. Of course, further requirements need to be satisfied in order to
cover all the necessary properties, namely regarding the interaction between
horizontal and vertical mosaics.
