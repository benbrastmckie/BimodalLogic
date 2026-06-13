# On the Mosaic Method for Many-Dimensional Modal Logics: A Case Study Combining Tense and Modal Operators

**Authors:** Carlos Caleiro, Luca Vigano, and Marco Volpe

**Journal:** Logica Universalis 7 (2013), 33--69

**DOI:** [10.1007/s11787-012-0074-5](https://doi.org/10.1007/s11787-012-0074-5)

**Published:** December 25, 2012

---

## Abstract

We present an extension of the mosaic method aimed at cap-
turing many-dimensional modal logics. As a proof-of-concept, we define
the method for logics arising from the combination of linear tense opera-
tors with an “orthogonal” S5-like modality. We show that the existence
of a model for a given set of formulas is equivalent to the existence of
a suitable set of partial models, called mosaics, and apply the technique
not only in obtaining a proof of decidability and a proof of completeness
for the corresponding Hilbert-style axiomatization, but also in the devel-
opment of a mosaic-based tableau system. We further consider extensions
for dealing with the case when interactions between the two dimensions
exist, thus covering a wide class of bundled Ockhamist branching-time
logics, and present for them some partial results, such as a non-analytic
version of the tableau system.
Mathematics Subject Classification (2010). Primary 03B45, 03C98;
Secondary 03B44, 03B62.
Keywords. Mosaic method, many-dimensional modal logics,
temporal logics, decidability, tableau systems.

## 1. Introduction

The mosaic method has been introduced in algebraic logic as a way of proving
decidability of the theories of some classes of algebras of relations [16,17]. The
basic idea consists in showing that the existence of a model is equivalent to
the existence of a (possibly finite) suitable set of fragments of models, called
mosaics. The power of the method comes from the fact that, given a formula,
one does not need to generate a full model in order to prove its satisfiability: it
is enough to show that there exists such a set of mosaics. As a by-product, one
obtains a decision procedure for the logic whenever such a (finite) set exists.
The mosaic method has been recently applied to prove decidability, com-
plexity results and completeness of Hilbert-style axiomatizations for several

modal logics [12,15,27]. With regard to temporal logics, a first work consider-
ing an adaptation of the technique to the linear temporal logic of general time
is [14], including, as an application, the development of a mosaic-based seman-
tic tableaux system, along with a method for automated theorem proving. The
authors also discuss the generalization of these results to particular flows of
time by suggesting possible modifications of the conditions defining mosaics
and saturated sets of mosaics. Further works using mosaics in temporal logics
established complexity results for the logic of until over general linear time [21]
and the logic using both since and until over the reals [24] (see also [22,23]
for more recent and general accounts on mosaics and complexity topics). In
[19], a variant of the mosaic method has been used to prove decidability of
a so-called temporal logic of parallelism, mentioned also in [25]. In [19], it is
also shown that this logic does not enjoy (the usual form of) the finite model
property and thus that the mosaic method is in some cases a more powerful
tool for proving decidability.
In this paper, we consider the method described in [14] for linear-time
logic as our starting point and propose an extension able to deal with logics
arising from the combination of linear temporal operators with an “orthogo-
nal” S5-like modality. The resulting logic is described in [29] (in the case of
general linear time). Alongside the linear-time mosaics (defined essentially as
in [14]), which we will call vertical mosaics, we will consider also “orthogo-
nal” horizontal mosaics. We will show that, as long as no interaction occurs
between the two dimensions, the results of [14] extend to our case. Namely, we
will prove that the existence of a model for a given set of formulas is equiva-
lent to the existence of a suitable set of mosaics, and will apply the technique
not only in obtaining a completeness proof for the corresponding Hilbert-style
axiomatization, but also in the development of a mosaic-based tableau sys-
tem. We will further show that a finite fragment of the language is enough for
setting up the necessary sets of mosaics, thus obtaining a decision procedure
for the logic, even a tableau-based one, as well as corresponding complexity
bounds.
By following the classification described in [29], we will also define condi-
tions modeling possible interactions between the two dimensions, thus covering
a hierarchy of logics that culminate in the bundled Ockhamist branching tem-
poral logic of general time. This logic corresponds to the logic of Kamp frames
of [20], which differs from the logic of Ockhamist frames described in [29] only
in the fact that the atomic harmony assumption, i.e., the evaluation of atomic
formulas is given with respect to nodes of a tree and not to pairs (node, branch),
is relaxed there. Though our mosaic definitions do not lead to a proof of decid-
ability when interactions between the vertical and the horizontal components
are considered, they still allow for giving non-analytic but interesting tableau
systems for the logics. These tableau systems, inspired by the one described in
[14] for linear-time, are strongly based on mosaics and are thus quite different
from the standard semantic tableau systems for modal logics. The definition
of the tableau rules follows very naturally from the mosaics definitions (each
rule corresponding to a property that the mosaics are required to satisfy), and

allows for an extremely clear and appealing representation of the (counter)
model under construction. Indeed each node of a tableau can be seen as a
snapshot of a fragment (at most six points) of such a model. Soundness and
completeness are proved by exploiting the equivalence between the existence
of a model and the existence of a saturated set of mosaics. We believe that
these features make our tableau systems useful and appealing even in the cases
for which analyticity could not be obtained, and for which some subsequent
form of loop checking, to be better investigated, may perhaps be applied in
order to retry decidability.
The treatment in the whole paper is strongly modular, both in terms of
definitions and proofs, along the two dimensions, i.e., with respect to the possi-
ble restrictions applied to the linear order, e.g., density, discreteness, existence
of starting/final points, and with respect to the interaction properties consid-
ered. Indeed, though many of the results presented here have been shown using
other techniques, we believe that the mosaic method is interesting in itself as
it provides a uniform way of establishing such metaproperties for large classes
of logics.
We also remark that, although our focus here has been on a two-dimen-
sional temporal logic, the approach is more generally suitable to the case of
many-dimensional modal logics [9] and seems to work well as long as possible
extensions concern properties of a single dimension not interacting with the
others. In the case of interactions between the components, only partial results
are achieved and further work needs to be done. This seems to be related to
analogous problems encountered in the field of combination of modal logics
when considering transfer of results, e.g., finite axiomatizability or decidabil-
ity, from the component logics to the combined one [13]. While such results
are generally proved in the case of independent combinations of modal logics,
e.g., in their fusion, very few general transfer results hold when their prod-
uct is considered. Indeed the logics that we consider here are closely related
to examples of products of epistemic and temporal/dynamic logics [5,11] and
the commutativity-like property (weak diagram completion) that we will use
in the next sections roughly corresponds to the perfect recall property of sys-
tems modeling the behavior of agents that “do not forget”. Other examples
of related logics are those based on the so-called T × W frames of Thomason
[4,19,25]. These are more purely two-dimensional logics in the sense that the
semantical structures are based on rectangular frames given by the product
of a linear order (T, <) with a given set W, on which an equivalence rela-
tion ≃t is defined for each t ∈T. The difference with respect to our frames
is that there we have one single linear order and thus all the time-lines are
“synchronized”. Closer to the Ockhamist frames that we use are the Kamp
frames presented in [25], where only the past of ≃-related points is required
to be synchronized.
We proceed as follows. In Sect. 2, we describe the logics of interest, and
delimit the scope of applicability of our method. In Sect. 3, we define the
mosaic method for the target class of logics and prove, modularly, that satisfi-
ability is equivalent to the existence of a suitable set of vertical and horizontal

mosaics. In Sect. 4, we consider applications of the method to the proof of com-
pleteness of Hilbert-style axiomatizations, to the formulation of mosaic-based
tableau systems, and to the proof of decidability and complexity upper bounds.
Finally, in Sect. 5, we discuss the pros and cons of the method, compare it with
the literature, and propose some directions for future work.

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

### 3.1. Mosaics

In the most general case, that is, when, as in Definition 2.6, no particular
assumptions are made on the way atoms are evaluated, it is straightforward
to check that the set of state formulas can be defined recursively as follows:
1. if A is a formula, then ∀A is a state formula;
2. if A and B are state formulas, then A ∧B is a state formula;
3. if A is a state formula, then ¬A is a state formula.

If we are interested in logics where the evaluation of atoms depends only on
the state (and not on the particular path), i.e., if v ≃w implies V(v) = V(w),
then the following further base case needs to be added to the conditions above:
0. if A is an atomic proposition, then A is a state formula.
In any case, it is clear that satisfaction at any ≃-related points in an interpre-
tation structure agrees on state formulas.
The following definitions are essential in supporting the construction of
sets of mosaics based not necessarily on the whole Ockhamist language F,
but on suitable (possibly finite) sublanguages Λ ⊆F. Below, unless otherwise
stated we consider fixed such a set Λ. As a minimal requirement, we will assume
that Λ is closed under subformulas and single negation (of non-negated for-
mulas).

**Definition 3.1.** Let Γ, Δ ⊆Λ. We say that Γ and Δ are Λ-state-equivalent, and
we write Γ ∼Λ Δ, if for each state formula A ∈Λ, A ∈Γ if and only if A ∈Δ.

**Definition 3.2.** A point (on Λ) is a set of formulas Γ ⊆Λ satisfying the following
local conditions:
for every formula A ∈Λ,
(L1) A ∈Γ iff¬A /∈Γ;
(L2) A = B ∧C ∈Γ iff{B, C} ⊆Γ;
(L3) if A = ∀B ∈Γ then B ∈Γ.
A point Γ is further said to be2:
•
future unbounded (or a FU-point) if F⊤∈Γ;
•
future bounded (or a FB-point) if (FG⊥) ∨(G⊥) ∈Γ;
•
past unbounded (or a PU-point) if P⊤∈Γ;
•
past bounded (or a PB-point) if (PH⊥) ∨(H⊥) ∈Γ.

**Definition 3.3.** A mosaic (on Λ) is a pair (Γ, Δ) or just (Γ), where Γ and Δ
are points on Λ. We say that a mosaic (Γ, Δ) is a vertical mosaic iffit satisfies
the following vertical coherence conditions:
for every formula A ∈Λ,
(V1) if A = GB ∈Γ then B ∈Δ;
(V2) if A = HB ∈Δ then B ∈Γ;
(V3) if A = GB ∈Γ then GB ∈Δ;
(V4) if A = HB ∈Δ then HB ∈Γ.
We say that a mosaic (Γ, Δ) is a horizontal mosaic iffit satisfies the following
horizontal coherence condition:
(H1) Γ and Δ are Λ-state-equivalent.
A singular mosaic (Γ) is both a vertical and a horizontal mosaic.
We say that a mosaic is a FU/FB/PU/PB-mosaic if it is composed only
of FU/FB/PU/PB-points, respectively.
Let us now consider sets of mosaics.
2 Notice that the definitions of future/past (un)boundedness require, mutatis mutandis, that
the corresponding formulas F⊤, (FG⊥) ∨(G⊥), P⊤, (PH⊥) ∨(H⊥) ∈Λ.

**Definition 3.4.** The set of points of a set of mosaics S (on Λ) is the set
Points(S) = {Ω ⊆Λ | (Ω) ∈S or there exists (Γ, Δ) ∈S with Ω = Γ or
Ω = Δ}.
Vertical mosaics are subject to the following saturation properties.

**Definition 3.5.** A set S of vertical mosaics (on Λ) is a ()-vertically saturated set
of mosaics (on Λ) (a ()-VSSM for short) if it satisfies the following ()-vertical
saturation conditions:
for every Ω ∈Points(S),
(SV1) if FA ∈Ω then there exists (Ω, Γ) ∈S with A ∈Γ;
(SV2) if PA ∈Ω then there exists (Γ, Ω) ∈S with A ∈Γ;
for every mosaic (Γ, Δ) ∈S,
(SV3) if FA ∈Γ, then:
(i) A ∈Δ or FA ∈Δ; or
(ii) there exist (Γ, Ω), (Ω, Δ) ∈S with A ∈Ω;
(SV4) if PA ∈Δ, then:
(i) A ∈Γ or PA ∈Γ; or
(ii) there exist (Γ, Ω), (Ω, Δ) ∈S with A ∈Ω.
Additional vertical saturation conditions of interest are:
for every mosaic (Γ, Δ) ∈S,
(SVDns) there exists Ω ∈Points(S) such that (Γ, Ω), (Ω, Δ) ∈S;
(SVUdsc) if FA ∈Γ, then:
(i) A ∈Δ or FA ∈Δ; or
(ii) there exist (Γ, Ω), (Ω, Δ) ∈S with {A, ¬FA} ⊆Ω;
(SVDdsc) if PA ∈Δ, then:
(i) A ∈Γ or PA ∈Γ; or
(ii) there exist (Γ, Ω), (Ω, Δ) ∈S with {A, ¬PA} ⊆Ω.
Given a class C of linear structures, S is said to be C-vertically saturated
(a C-VSSM for short) if S is a ()-VSSM that further satisfies the following
conditions, corresponding to each property in C:
•
Fst/Lst/Nfst/Nlst correspond to requiring that S is a set of PB/FB/
PU/FU-mosaics, respectively;
•
Dns corresponds to requiring that SVDns holds;
•
Udsc/Ddsc correspond to requiring SVUdsc/SVDdsc hold, respectively.
Horizontal mosaics are also subject to saturation properties.

**Definition 3.6.** A set S of horizontal mosaics (on Λ) is a horizontally saturated
set of mosaics (on Λ) (a HSSM for short) if it satisfies the following horizontal
saturation condition:
for every Ω ∈Points(S),
(SH1) if ∃A ∈Ω and A /∈Ω then there exists Γ ∈Points(S) such that
(Ω, Γ) ∈S and A ∈Γ.
We now need to consider the joint effect of vertical and horizontal
mosaics.

**Definition 3.7.** Let C be a class of linear orders. A C-basic-structure of mosa-
ics is a pair S = (SV , SH) such that SV is a C-VSSM, SH is an HSSM, and
Points(SV ) = Points(SH ). The set of points of the structure of mosaics S is
precisely Points(S) = Points(SV ) = Points(SH ).
Additional combined conditions of interest are:
– (SWdc) if (Ω, Γ) ∈SV and (Γ, Δ) ∈SH then there exists Φ ∈Points(S)
such that (Φ, Δ) ∈SV and (Ω, Φ) ∈SH;
– (STrn) if (Γ, Δ), (Δ, Ω) ∈SV then (Γ, Ω) ∈SV ;
– (SCon) if (Γ, Ω), (Δ, Ω) ∈SV then either Γ = Δ, or (Γ, Δ) ∈SV or (Δ, Γ) ∈
SV ;
– (SSdc) if (Φ, Ω), (Ω, Γ), (Ψ, Δ) ∈SV and (Φ, Ψ), (Γ, Δ) ∈SH then there
exists Υ ∈Points(S) such that (Ψ, Υ), (Υ, Δ) ∈SV and (Ω, Υ) ∈SH;
– (SMb−) if (Γ, Δ) ∈SH and G⊥∈Γ then Γ = Δ.3
Given one of the target branching classes D, S = (SV , SH) is said to be
a C-D-structure of mosaics if S is a C-basic-structure of mosaics that further
satisfies the following conditions, corresponding to each class D ̸=():
•
D =(Wdc) requires that SWdc, STrn and SCon hold;
•
D =(Wdc+Sdc) requires that SWdc and SSdc;
•
D =(Wdc+Sdc+Mb−) requires SWdc, SSdc and SMb−to hold.
Given a structure of mosaics S and a set of formulas Γ, we say that S is
a structure of mosaics for Γ if there exists Ω ∈Points(S) such that Γ ⊆Ω.

### 3.2. Mosaics and Satisfiability

We will now show that the existence of a saturated set of mosaics for a given
set of formulas corresponds to the existence of a model for such a set.

**Definition 3.8.** Let F = (W, ≺, ≃) be a frame. A chronicle for F on Λ is a
function δ assigning a subset of Λ to every element of W such that the following
conditions are satisfied: for every v, v′ ∈W,
(i) A ∈δ(v) iff¬A /∈δ(v);
(ii) A ∧B ∈δ(v) iff{A, B} ⊆δ(v);
(iii) if ∀A ∈δ(v), then A ∈δ(v);
(iv) if GA ∈δ(v) and v ≺v′, then {A, GA} ⊆δ(v′);
(v) if HA ∈δ(v) and v′ ≺v, then {A, HA} ⊆δ(v′);
(vi) if v ≃v′ then δ(v) ∼Λ δ(v′).
We say that a chronicle δ is based on a structure of mosaics S = (SV , SH),
defined on the same Λ, if:
(vii) if v ≺v′ and there is no v′′ such that v ≺v′′ ≺v′, then (δ(v), δ(v′)) ∈
SV ;
(viiii) if v ≃v′, then there exist v1 ≃· · · ≃vn such that v = v1, v′ = vn and
(δ(vi), δ(vi+1)) ∈SH for 0 < i < n.
Let D be a target branching class and S be a structure of mosaics. Given a
C-D-frame F and a chronicle δ for it, the pair (F, δ) will be referred to as a
C-D-chronicled frame based on S.
3 Notice that the SMb−condition only makes sense if we require that G⊥∈Λ.

Conditions (i)−(vi) are the analogous of the coherence conditions in the
definition of vertical and horizontal mosaics. Conditions (vii) and (viii) ensure
that the chronicle is built out of mosaics from a given structure.

**Definition 3.9.** Let F = (W, ≺, ≃) be a ()-()-frame, v ∈W, δ a chronicle for F
and A a formula. An element ⟨v, FA⟩is a vertical future defect of (F, δ) if:
(i) FA ∈δ(v); and
(ii) (ii) for every v′ ∈W such that v ≺v′, we have A /∈δ(v′).
⟨v, PA⟩is a vertical past defect of (F, δ) if:
(i) PA ∈δ(v); and
(ii) for every v′ ∈W such that v′ ≺v, we have A /∈δ(v′).
Finally, ⟨v, ∃A⟩is a horizontal defect of (F, δ) if:
(i) ∃A ∈δ(v); and
(ii) for every point v′ ∈W, if v ≃v′ then A /∈v′.

**Lemma 3.10.** Let D be a target branching class in {(), (Wdc), (Wdc +
Sdc)}, S = (SV , SH) a ()-D-structure of mosaics, (F = (W, ≺, ≃), δ) a finite
()-D-chronicled frame based on S and α a defect on (F, δ). Then there exists
a finite ()-D-chronicled frame based on S that extends (F, δ) and such that α
is not a defect in it.

*Proof.* The proof proceeds by showing how to cure vertical and horizontal
defects and how to guarantee that the resulting frame is still of the required
type. Notice that if D ̸= (), the procedure may require the addition of more
than one point.
Curing of vertical defects. Vertical defects are cured in the same way as
described in [14]. We recall the case of a linear future defect; the treat-
ment of past defects is just symmetrical. Let α be ⟨v, FA⟩for some v ∈W
and some formula A. We can consider a v′ that is the ≺-maximal element
of W such that FA ∈v′. Since d is a defect of (F, δ), such a v′ exists.
By curing the defect ⟨v′, FA⟩, we will also cure all the defects ⟨w, FA⟩for
w ≺v′. We have two subcases:
(a) v′ is the greatest element of W according to ≺. Then, by the sat-
uration condition SV1, there is a mosaic (Γ′
0, Γ′
1) in S such that
Γ′
0 = δ(v′) and A ∈Γ′
1. We can define a new frame F ′ = {W′, ≺′
≃′} obtained by adding a new element v′′ labeled with Γ′
1. Namely,
we define W′ = W ∪{v′′}, ≺′ as the smallest linear order relation
containing ≺and such that w ≺v′′ for every w ∈W and ≃′=≃
∪{(v′′, v′′)}. We can associate to F ′ a chronicle δ′ that extends δ by
assigning Γ′
1 to v′′.
(b) v′ is not the ≺-greatest element of W. Then, there exists an element
v′′ ∈W such that v′′ is the immediate successor of v′, according to
the relation ≺, and, by the maximality of v′, ¬FA ∈δ(v′′). By the
condition SV3, there exist two mosaics (Δ0, Δ), (Δ, Δ1) ∈S such
that Δ0 = δ(v′), Δ1 = δ(v′′) and A ∈Δ. Then we define an exten-
sion F ′ = {W′, ≺′, ≃′}, by inserting a point v∗between v′ and v′′.

A chronicle δ′ for F ′ is obtained by extending δ with the assignment
δ′(v∗) = Δ.
Curing of horizontal defects. If α is a horizontal defect, i.e., A = ∃A′ for
some A′, then, by the saturation condition SH1, we know that there exists
(Δ, Δ′) ∈SH such that δ(v) = Δ and A ∈Δ′. Then we define a frame
F ′ = (W′, ≺′, ≃′), where W′ = W ∪{v′}, ≺′=≺and ≃′ is the reflexive,
symmetric and transitive closure of ≃∪{(v, v′)}. We can associate to F ′
a chronicle δ′ that extends δ by assigning M ′ to v′.
Preserving relational properties. According to
the
procedure described
above, curing a defect on a ()-(Wdc)-chronicled frame may produce a
chronicled frame that is not of the same type. Namely, the curing of α
could generate in the new frame F ′ = (W′, ≺′, ≃′) a counterexample
to the property Wdc, i.e., three points v1, w1 and w′
1 in W′ such that
v1 ≺′ w1 ≃′ w′
1 but such that there is no point v′
1 in W′ for which
v1 ≃′ v′
1 and v′
1 ≺′ w′
1 hold. Such situations, which will be referred to as
Wdc-defects, need to be repaired in a different way according to the fact
that D also contains Sdc or not.
(a) Let D = (Wdc). Since (F ′, δ′) is based on S, by the transitive closure
ensured by property STrn and by condition (vii) in Definition 3.8,
there exists (δ′(v1), δ′(w1)) ∈SV . Moreover, by condition (viii) in

Definition 3.8, there exists a sequence w1 ≃· · · ≃wn such that
wn = w′
1 and (δ′(wi), δ′(wi+1)) ∈SH for 0 < i < n. By construc-
tion, for 0 < i < n, the sequence v1 ≺′ w1 ≃′ wi also represents a
Wdc-defect. All such defects will be cured by applying, in turn, to
all the 0 < i < n, the following procedure. Let vi be the last point
added to cure a defect (as a base case it will coincide with v1) and
(F ′′, δ′′) the chronicled frame obtained as a result of the (i −1)-th
step (δ′′ = δ′, if i = 1). Then the sequence vi ≺′′ wi ≃′′ wi+1 is a
Wdc-defect. As a result of the (i −1)-th step (or by hypothesis, if
i = 1) we have (δ′′(vi), δ′′(wi)) ∈SV . Then, by the saturation con-
dition SWdc on S, we know that there exists a point Δ ∈Points(S)
such that (Δ, δ′′(wi+1)) ∈SV and (δ′′(vi), Δ) ∈SH. It is then pos-
sible to build a new frame by extending F ′′ with a further point
vi+1 and associate to it a proper chronicle that is the extension of δ′′
assigning Δ to vi+1. Condition SCon allows for positioning the new
point properly along the ≺′′-order. Such a procedure will eventually
cure all the defects in the sequence and thus also the one related to
the triple (v1, w1, w′
1).
(b) Now let D = (Wdc+Sdc). There are three possibilities: (i) the Wdc-
defects arise from the curing of a vertical defect made by inserting
a point in the middle of a linear order (case (b) in the curing of a
vertical defect above); (ii) the Wdc-defects arise from the curing of
a vertical past defect occurring at a point at the bottom of a linear
order; or (iii) the Wdc-defects arise from the curing of a horizontal
defect. In the case (i), we notice that the possible Wdc-defects are
also counterexamples to Sdc, since Wdc and Sdc combined give the

frame the shape of a (partial) grid, with ≺operate vertically and
≃operate horizontally. We can use the saturation condition SSdc
in order to add new points and eliminate such counterexamples. As
an example, consider the case when a point v1 has been inserted
between two points v0 and v2 such that v0 ≃v′
0 and v2 ≃v′
2. The
resulting defect can be cured by adding a point v′
1 between v′
0 and v′
2
such that v1 ≃v′
1. Condition Ssdc ensures that a v′
1 with the proper
labeling exists. In both the cases (ii) and (iii), we deal with sim-
ple Wdc-defects and the frame can be extended by using condition
SWdc, as described in point (a) above.
$\square$

In the following, when not working with the full language, we will anyway
often require that the labeling set of formulas on which mosaics are defined
is closed with respect to some properties. We will let such closure proper-
ties depend on the particular class of linear orders and the particular target
branching class considered.

**Definition 3.11.** Let C be a class of linear orders and D a target branching
class. A set Λ of formulas is said to be C-D-closed if the following conditions
are satisfied:
(i) Λ is closed under subformulas and single negations (of non-negated for-
mulas);
(ii) if Fst is in C, then (PH⊥) ∨(H⊥) ∈Λ;
(iii) if Lst is in C, then (FG⊥) ∨(G⊥) ∈Λ;
(iv) if Nfst is in C, then P⊤∈Λ;
(v) if Nlst is in C, then F⊤∈Λ;
(vi) if Mb−is in D, then G⊥∈Λ.
Now we can use the procedure described in Lemma 3.10 to build, via an
ω-construction, a structure of the given type. The following result from [29]
will be useful in order to ensure that relational properties are preserved during
the construction.

**Lemma 3.12.** Let D be a target branching class and F = {Fλ | λ < μ} a set of
()-D-frames indexed on the ordinal μ such that Fλ ⊆Fλ′ for all λ < λ′ < μ.
Then the union F = 
λ<μ Fλ is a ()-D-frame.

**Theorem 3.13.** Let C be a class of linear orders with C not including any of
Udsc and Ddsc, D a target branching class and Γ a set of formulas. Then, Γ
is C-D-satisfiable iffthere exists a C-D-structure of mosaics for Γ.

*Proof.* (⇒) Let M = (W, ≺, ≃, V) be a C-D-structure satisfying Γ and let
u ∈W be a point such that M, u |= Γ. Given a set Λ′, which contains Γ
and is C-D-closed, we can associate a different fresh atom, i.e., an atom that
is not in Λ′, to each world in W4. Let Λ′′ be the smallest C-D-closed set of
formulas containing such atoms and Λ = Λ′ ∪Λ′′. We associate a subset of
4 By adapting the result from the L¨owenheim–Skolem theorem (see, e.g., [26]), we can
assume, without loss of generality, that W is countable.

Λ to every point of W as follows: for every v ∈W we define Δv = {A ∈
Λ′ | M, v |= A} ∪{pv} ∪{¬p | p ∈Λ′′ and p ̸= pv}, where pv is the atom
associated to v. Then we define the set SV = {(Δv, Δv′) | v, v′ ∈W and v ≺
v′} ∪{(Δv) | v ∈W and for all v′ ∈W we have v ̸≺v′ and v′ ̸≺v}. Similarly,
we define SH = {(Δv, Δv′) | v, v′ ∈W and v ≃v′}. It is easy to verify that
S = (SV , SH) is a C-D-structure of mosaics. In fact, coherence and saturation
conditions are clearly satisfied since the definition of each point in S comes
from the labeling of the corresponding point in a C-D-structure and the use of
fresh atoms ensures that each world in W gives rise to a distinct point in S. Fur-
thermore S is a structure of mosaics for Γ since Γ ⊆Δu and Δu ∈Points(S).
(⇐) Let S be a C-D-structure of mosaics for Γ on a C-D-closed labeling
set Λ of formulas. As in [14], we build a model for Γ step by step by using the
mosaics in S as building blocks. The procedure described in Lemma 3.10 will
be used to cure the defects. Namely, we define a sequence σ containing all the
formulas FA, PA, ∃A in Λ such that each such formula occurs infinitely often
in σ and proceed as follows.
Notice that we cannot guarantee that the result of each step of the con-
struction is a C-D-chronicled frame because some of the properties (both linear
and branching) will only emerge in the limit step. Namely, during the interme-
diate steps of the construction we will work with ()-D-chronicled frames, for
D =(), D =(Wdc) and D=(Wdc+Sdc), and with ()-(Wdc + Sdc)-chronicled
frames if D =(Wdc+Sdc+Mb−).
[STEP 0] First, let us consider a mosaic μ in S such that μ is a mosaic
for Γ (since S is a structure of mosaics for Γ, such a mosaic exists). Moreover,
since by definition Points(SV ) = Points(SH ), we can assume, without loss
of generality, that μ is a vertical mosaic. We can define F0 = {W0, ≺0, ≃0}
as follows. If μ = (Δ0) is a singleton, then we define W0 = {w0}, ≺0= ∅
and ≃0= {w0, w0}. Furthermore, we associate to W0 the chronicle δ0 defined
as δ0(w0) = Δ0. If μ = (Δ0, Δ1) is a vertical mosaic in SV , then we define
W0 = {w0, w1}, ≺0= {(w0, w1)} and ≃0= {(w0, w0), (w1, w1)}. We associate
to W0 the chronicle δ0 defined as δ0(w0) = Δ0 and δ0(w1) = Δ1. In both cases
F0 is a ()-D-frame and δ0 is a chronicle for F0 based on S.
[STEP n + 1] Assume that we have already defined a ()-D-frame (a
()-(Wdc + Sdc)-frame if D=(Wdc+Sdc+Mb−)) Fn and a chronicle δn for Fn
based on S. Then we consider the (n + 1)-th formula A in the enumeration σ.
By using the procedure described in Lemma 3.10, we can define a ()-D-frame
Fn+1 and a chronicle δn+1 for it such that for each defect ⟨w, A⟩in (Fn, δn),
we have that it is not a defect in (Fn+1, δn+1).
Notice that if D=(Wdc+Sdc+Mb−), we just apply the procedure
described for D = (Wdc + Sdc). Moreover, in some cases, depending on the
nature of C, we slightly refine the procedure described in Lemma 3.10. Namely,
if C contains Dns, then, as suggested in [14], when curing vertical defects we
add not only the mosaics specified by the procedure of Lemma 3.10 but also,
between all the neighboring points, all the mosaics that can lay in the middle.
Condition SVDns ensures that there is at least one such mosaic for each pair
of neighboring points.

[STEP ω] Now we can just take the infinite unions F = 
i∈ω Fi and
δ = 
i∈ω δi. The special curing procedure described above for the dense case
guarantees that the process will finally produce a frame which is dense. In the
case of the other linear properties possibly contained in C, it is the definition of
mosaic itself to guarantee that the property is enjoyed by the frame obtained
in the limit step.
Then, by Lemma 3.12, F is a C-D-frame, for D = (), D = (Wdc) or
D = (Wdc + Sdc). In the case when D=(Wdc+Sdc+Mb−), in the interme-
diate steps of the construction we have frames (with associated chronicles)
which enjoy Wdc and Sdc but not necessarily Mb−. However, condition SMb−
ensures that, at each step i, a ≺-maximal point w can be ≃-related to a point v
distinct from w only if G⊥/∈δi(w). But this implies that w contains a vertical
future defect, which in some later step will be cured by inserting some point
above w. Thus in the final construction we have that also Mb−is satisfied.
Furthermore, in all the cases, by the construction we have no defects in (F, δ),
since the enumeration in σ ensures that if a defect becomes actual at some
step, then we cure it in a later step.
We can easily obtain a C-D-structure by endowing F with a valuation
V induced by δ. Namely, let F be (W, ≺, ≃); then we define a structure
M = (W, ≺, ≃, V), where V is such that for all u ∈W and for all atomic
propositions p, p ∈V(u) iffp ∈δ(u). By recalling that we used a mosaic for Γ
as a foundation stone of our construction (STEP 0), we conclude that M is a
C-D-structure that satisfies Γ.
$\square$

**Corollary 3.14.** Let C be a class of linear orders with C not including any of
Udsc and Ddsc, D a target branching class and Γ a set of formulas. Then Γ
is C-(Dis+Wdc)-satisfiable iffthere exists a C-(Wdc+Sdc)-structure of mosa-
ics for Γ. Γ is C-Ockhamist-satisfiable (i.e., by Lemma 2.8, satisfiable in the
logic defined over bundled trees in the class B+(C) [10]) iffthere exists a
C-(Wdc+Sdc+Mb−)-structure of mosaics for Γ.

*Proof.* This follows straightforwardly by combining the result of Theorem 3.13
and the equivalences of Lemma 2.8.
$\square$

In the case where no interactions between the components are considered,
i.e., when D = (), it is possible to give a proof based on a labeling set which
is finite. This observation will be crucial in obtaining a result of decidability
(see Sect. 4.3 below). We remark that in this case we are able to deal also with
discreteness properties.

**Theorem 3.15.** Let C be a class of linear orders and Γ a finite set of formulas.
Then, Γ is C-()-satisfiable iffthere exists a C-()-structure of mosaics for Γ on
a finite labeling set.

*Proof.* (⇒) Since Γ is C-()-satisfiable, there exist M = (W, ≺, ≃, V) and u ∈W
such that M, u |= Γ. Let Λ be the smallest C-()-closed set of formulas contain-
ing Γ. We will show that there exists a structure of mosaics on Λ for Γ.
We can easily infer a set of mosaics on the labeling set Λ from M.
We associate a subset of Λ to every point of W as follows: first we define

Δw = {A ∈Λ | M, w |= A} for every w ∈W. Then we define the sets
SV
= {(Δw, Δ′
w) | w, w′ ∈W and w ≺w′} ∪{(Δw) | w ∈W} and
SH = {(Δw, Δ′
w) | w, w′ ∈W and w ≃w′} ∪{(Δw) | w ∈W}. It is easy
to verify that S = (SV , SH) is indeed a C-()-structure of mosaics. In fact
coherence and saturation conditions are clearly satisfied since the definition
of each point in S comes from the labeling of the corresponding point in a
C-()-structure. Furthermore S is a structure of mosaics for Γ, since Γ ⊆Δu
and Δu ∈Points(S).
(⇐) The thesis follows from a construction analogous to that in the proof
of Theorem 3.13 (right-to-left direction). Clearly, restricting to consider struc-
tures of mosaics based on a finite labeling set does not affect the previous result.
In this case, we can also consider classes of linear orders satisfying Ddsc
and/or Udsc. Namely, if C contains UDsc, then in cases like (b) for the cur-
ing of vertical future mosaics (Lemma 3.10), we proceed by adding a point v∗
between v′ and v′′ such that {A, ¬FA} ⊆δ′(v∗). Condition SVUdsc ensures
that there exists a mosaic allowing that. If C contains DDsc, then we proceed
symmetrically in the case of vertical past defects. The fact that the labeling
set is finite guarantees that only a finite number of formulas of the form FA
or PA occurs in any point. Hence, between any two points, we will insert only
finitely many points during our ω-construction.
$\square$

## 4. Applications

In this section, we study some applications of the mosaic method defined above.
In particular, we describe a mosaic-based proof of completeness for a Hilbert-
style axiomatization for our Ockhamist branching temporal logics, we formu-
late and study mosaic-based tableaux systems, and study the decidability of
some of these logics.

### 4.1. Hilbert-Style Completeness Via Mosaics

One of the possible applications of the mosaic method is in proving the com-
pleteness of a given deduction system (as, e.g., in [14,19]). In fact, Theo-
rem 3.13 can be used to simplify the standard proof of completeness: given
a consistent set of formulas we do not need to create a model satisfying it; a
structure of mosaics will suffice.
A standard [29] proof of completeness for axiomatic systems capturing the
logics presented here consists in taking maximal consistent sets and defining
two relations ≺M and ≃M on them, based on the formulas they contain, i.e.,
Γ ≺M Δ iff{A | GA ∈Γ} ⊆Δ
and
Γ ≃M Δ iff{A | ∀A ∈Γ} ⊆Δ.
The idea is that such relations can be used as the basis for building a structure
by a procedure of elimination of counterexamples [2,3,29]. If we use mosaics,
then part of this procedure is already contained in the assert of Theorem 3.13
and it suffices to show that the structure (SV , SH) is a structure of mosaics
of the given class, where SV is the set of all pairs (Γ, Δ) of maximal consis-
tent sets such that Γ ≺M Δ and SH is the set of all pairs (Γ, Δ) of maximal
consistent sets such that Γ ≃M Δ.

#### 4.1.1. Hilbert-Style Axiomatizations

Here we list some axioms and rules of
inference that will give rise to a hierarchy of Hilbert-style axiomatizations for
the logics considered. Here we will consider strong completeness and, as in

Theorem 3.13, drop the discreteness conditions Udsc and Ddsc. We remark
that, by exploiting the result of Theorem 3.15, a proof of weak completeness
would be possible for axiomatizations capturing also discreteness but in a set-
ting with no interactions between the components, i.e., for D = ().
Vertical axioms (for general linear-time)
(CL)
Any tautology instance of classical propositional logic
(KG)
G(A ⊃B) ⊃(GA ⊃GB)
(KH)
H(A ⊃B) ⊃(HA ⊃HB)
(GP)
A ⊃GPA
(HF)
A ⊃HFA
(L1)
FA ⊃G(FA ∨A ∨PA)
(L2)
PA ⊃H(FA ∨A ∨PA)
(TRANSG) GA ⊃GGA
(TRANSH ) HA ⊃HHA
Axioms for particular linear flows
(FstA)
H⊥∨PH⊥
(LstA)
G⊥∨FG⊥
(NfstA) P⊤
(NlstA) F⊤
(DnsA) FA ⊃FFA ∧PA ⊃PPA
Horizontal axioms (S5 with respect to the operator ∀)
(K∀) ∀(A ⊃B) ⊃(∀A ⊃∀B)
(∀1) ∀A ⊃∀∀A
(∀2) ∀A ⊃A
(∀3) A ⊃∀∃A
Branching axioms (compositional and harmonic properties)
(WdcA) PA ⊃∀P∃A
(Mb−A) G⊥∧∃A ⊃A
(AtmA) p ⊃∀p , for p ∈P.
Rules of deduction
(MP)
If A and A ⊃B then B
(NecG) If A then GA
(NecH) If A then HA
(Nec∀) If A then ∀A
(Irr)
If ((∀p ∧H∀¬p) ⊃A) then A , for p ∈P not occurring in A,
(Irr2)
If ((p ∧H¬p) ⊃A) then A , for p ∈P not occurring in A.
For each of our L(C, D) logics of interest, such that Udsc and Dsc are not
in C, we can obtain an axiomatization H(C, D) by including:

• the vertical axioms for general linear time
(CL, KG, KH , GP, HF, L1, L2, TRANSG, TRANSH ),
the horizontal axioms
(K∀, ∀1, ∀2, ∀3),
and the necessitation rules
(NecG, NecH , Nec∀);
• axioms for particular linear flows
(CA), for each condition C listed in C;
• additional axioms and rules for particular target branching classes
– D=(Wdc)
(WdcA);
– D=(Wdc+Sdc)
(WdcA, Irr);5
– D=(Wdc+Sdc+Mb−)
(WdcA, Irr, Mb−A).
In the case when the atomic harmony assumption is satisfied (see Sect. 2),
a proper axiomatization can be obtained [29] by adding the axiom (AtmA).
Moreover, the rule (Irr) can be reformulated as (Irr2).
Given a class C of linear orders, and a target branching class D, the
notions of H(C, D)-theoremhood, H(C, D)-derivability and H(C, D)-consistency
are defined in the standard way. A set Γ of formulas is further said to be max-
imally H(C, D)-consistent if either A ∈Γ or ¬A ∈Γ for every A ∈F. If Γ is
not H(C, D)-consistent, it will be called H(C, D)-inconsistent.

#### 4.1.2. Completeness Via Mosaics

In the rest of this section, for C a class of
linear orders and D a target branching class, we will denote with MC C,D the
set of maximal consistent sets of formulas generated by the axiomatization
H(C, D). We will prove completeness of the given axiomatizations by using
mosaics and by adapting known results, mainly from [29] and [7], where axio-
matizations very close to ours are presented.

**Theorem 4.1.** Let Ω be a set of formulas and C a class of linear orders such
that Udsc and Ddsc are not in C. If Ω is H(C, ())-consistent, then there exists
a C-()-structure of mosaics for Ω.

*Proof.* We have to show that there is a C-()-structure of mosaics for Ω. Let our
labeling set be the set of all formulas. Then we define the set SV as follows:
5 As an alternative formulation, we notice that in [28], Zanardo proposes the following two
rather complex (but with a standard form) Hilbert-style axioms:
(DW1) P(∀A ∧GB) ∧H¬(B ∧∃C)
⊃∀[GA1 ∧PC ⊃P(A ∧(C ∨PC)) ∧G(C ⊃GA1)]
(DW2) [HA ∧H¬(B ∧∃C ∧F(B ∧A ∧∃C1)) ∧P(∀A1 ∧GB)]
⊃∀[GB1 ⊃P(A1 ∧G(C ⊃G(C1 ⊃GB1)))]
The addition of such axioms to H(C, (Wdc)) gives rise to an axiomatization for the logic
L(C, (Wdc + Sdc)); see [28] for a proof.

SV = {(Γ) | Γ ∈MC C,()} ∪
{(Γ, Δ) | Γ, Δ ∈MC C,() and {A | GA ∈Γ} ⊆Δ}
(4.1)
It is easy to prove that the following definitions are equivalent to (4.1).
SV = {(Γ) | Γ ∈MC C,()} ∪
{(Γ, Δ) | Γ, Δ ∈MC C,() and {A | HA ∈Δ} ⊆Γ}
(4.2)
SV = {(Γ) | Γ ∈MC C,()} ∪
{(Γ, Δ) | Γ, Δ ∈MC C,() and {FA | A ∈Δ} ⊆Γ}
(4.3)
SV = {(Γ) | Γ ∈MC C,()} ∪
{(Γ, Δ) | Γ, Δ ∈MC C,() and {PA | A ∈Γ} ⊆Δ}
(4.4)
Similarly we can define SH as:
SH = {(Γ) | Γ ∈MC C,()} ∪
{(Γ, Δ) | Γ, Δ ∈MC C,() and {A | ∀A ∈Γ} ⊆Δ}
(4.5)
which can be proven to be equivalent to:
SH = {(Γ) | Γ ∈MC C,()} ∪
{(Γ, Δ) | Γ, Δ ∈MC C,() and {∃A | A ∈Δ} ⊆Γ}
(4.6)
Now we define S = (SV , SH) and claim that S is indeed a C-()-structure
of mosaics. By Definition 3.7, we need to prove that:
(i) SV is a C-VSSM;
(ii) SH is an HSSM;
(iii) M ∈Points(S) implies M ∈Points(SV ) and M ∈Points(SH ).
The proof uses the same arguments in the proof of completeness of [29].
Firstly, by using classical tautologies and (∀2), we can show that each Γ ∈
Points(S) is a point. In particular, in the case of C containing Fst, Lst, Nfst or
Nlst, the corresponding axiom directly ensures that each point is a PB-point,
an FB-point, a PU-point or an FU-point, respectively.
Moreover, by (4.1) and (TRANSG), each element of SV is a vertical
mosaic and, by (4.5) and (∀2) (and (AH ) if atomic harmony is assumed),
each element of SH is a horizontal mosaic.
Also, by standard Kripke-style methods (see [29]), one can show that
if FA(PA, ∃A) ∈Γ, then there exists a Δ such that A ∈Δ and (Γ, Δ) ∈
SV ((Δ, Γ) ∈SV , (Γ, Δ) ∈SH). This implies that SV is a ()-VSSM and SH is
an HSSM. With regard to point (i), when C is some particular class of linear
orders, we can refine this result by observing that:
•
in the case of C containing Fst (Lst, Nfst or Nlst), we have automatically
that SV is a set of PB (FB, PU, or FU, respectively)-mosaics and thus a
C-VSSM;
•
in the case when C contains Dns, Udsc or Ddsc, the axioms (DnsA),
(UdscA) or (DdscA) can be used to prove the corresponding saturation
properties on S, by using the standard techniques of, e.g., [1].
Finally, as for (iii), we observe that, by (4.1) and (4.5), Points(SV ) =
MC C,() = Points(SH ).

By considering the standard result [29] according to which every consis-
tent set of formulas is contained in a maximal consistent set of formulas, we
have that there exists a Ω′ such that Ω ⊆Ω′ and Ω′ ∈Points(S) and thus
that S is a structure of mosaics for Ω.
$\square$

**Theorem 4.2.** Let Ω be a set of formulas and C a class of linear orders such
that Udsc and Ddsc are not in C. If Ω is H(C, (Wdc))-consistent, then there
exists a C-(Wdc)-structure of mosaics for Ω.

*Proof.* We can define a structure of mosaics S as in Theorem 4.1. Then, by
using the axiom (WdcA) and standard compactness techniques [29], we have
that S enjoys SWdc. Moreover, as proven in [29], the set SV enjoys transitiv-
ity (STrn) and connectedness (SCon) and is therefore a C-(Wdc)-structure of
mosaics.
$\square$

In the case of (Wdc+Sdc)-structures, we refer to an axiomatization
enriched by the rule (Irr) (see above), which forces the construction of irre-
flexive models [6,7]. Namely, such a rule allows for giving each point a unique
“name”, in the sense that each point is characterized by the fact of being the
≺-minimal point where a certain atom holds.
We can define a structure of mosaics in a way very similar to that of
Theorems 4.1 and 4.2. However, we will now restrict our attention to a subset
of maximal consistent sets, the so-called Irr-sets (see also [7] for an illustration
of their use in proving completeness).

**Definition 4.3.** A set Γ of formulas is an Irr-set ifffor all n ≥0, for all
♦1, . . . , ♦n ∈{F, P, ∃}, for all formulas A0, . . . , An, if
A0 ∧♦1(A1 ∧♦2(A2 ∧· · · ♦n(An) · · · )) ∈Γ
then there is a propositional variable p ∈P such that
A0 ∧♦1(A1 ∧♦2(A2 ∧· · · ♦n(An ∧∃p ∧H¬∃p) · · · )) ∈Γ

**Definition 4.4.** Let C be a class of linear orders. We define the set
IMC C,(Wdc + Sdc) by saying that Γ ∈IMC C,(W dc+Sdc) iffΓ is an Irr-set
and Γ ∈MC C,(W dc+Sdc).

**Theorem 4.5.** Let Ω be a set of formulas and C a class of linear orders such
that Udsc and Ddsc are not in C. If Ω is H(C, (Wdc + Sdc))-consistent, then
there exists a C-(Wdc+Sdc)-structure of mosaics for Ω.

*Proof.* As in Theorems 4.1 and 4.2, we will build a structure of mosaics and
show that it is indeed a C-(Wdc+Sdc)-structure of mosaics for Ω.
Firstly, we notice that if Ω is consistent then it can be extended to a set
Ω′ which is a set in IMC C,(W dc+Sdc), possibly by extending the set of atoms
considered (see, e.g., [7] for a proof of this fact). Let our labeling set be the
set of all formulas in such a (possibly extended) set of atoms. Then, similarly
to the proof of Theorem 4.1, we define the set SV as follows:

SV = {(Γ) | Γ ∈IMC C,(W dc+Sdc)} ∪
{(Γ, Δ) | Γ, Δ ∈IMC C,(W dc+Sdc) and {A | GA ∈Γ} ⊆Δ}
(4.7)
and the set SH as follows:
SH = {(Γ) | Γ ∈IMC C,(W dc+Sdc)} ∪
{(Γ, Δ) | Γ, Δ ∈IMC C,(W dc+Sdc) and {A | ∀A ∈Γ} ⊆Δ}
(4.8)
As in the proof of Theorem 4.1, equivalent definitions are possible (we
omit them). Now we claim that S = (SV , SH) is a C-(Wdc+Sdc)-structure of
mosaics for Ω.
First of all, we notice that it is not difficult to extend the results of
Theorems 4.1 and 4.2 to this case. In particular, we refer the reader to the
treatment in [7]: vertical and horizontal saturation conditions are satisfied as
a direct consequence of [7, Lemma 7.7.6] and SWdc holds because of [7, Lemma
7.7.9].
It remains to show that S enjoys SSdc. We know (as a direct consequence
of Lemma 7.7.7 in [7]) that S enjoys a variant of the property (Dsj) (as defined
in Sect. 2), i.e., if (Γ, Δ) ∈SV and (Δ, Δ′) ∈SH then (Γ, Δ′) /∈SH. Moreover,
as proved in Lemma 7.7.9 of [7], S enjoys S-Wdc. By observing that the two
properties imply S-Sdc, we have the assert.
This shows that S is a C-(Wdc+Sdc+Mb−)-structure of mosaics. Since
Ω ⊆Ω′ and Ω′ ∈IMC C,(W dc+Sdc+Mb−), S is a structure of mosaics for Ω.
$\square$

**Theorem 4.6.** Let Ω be a set of formulas and C a class of linear orders such
that Udsc and Ddsc are not in C. If Ω is H(C, (Wdc+Sdc+Mb−))-consistent,
then there exists a C-(Wdc+Sdc+Mb−)-structure of mosaics for Ω.

*Proof.* We only need to prove that the structure S, defined as in the proof of

Theorem 4.5, but with respect to IMC C,(W dc+Sdc+Mb−), also enjoys SMb−. By
the sake of contradiction, assume there exist Γ, Δ such that G⊥∈Γ, (Γ, Δ) ∈
SH and Γ ̸= Δ. Then there exists A ∈Δ such that A /∈Γ. By (Γ, Δ) ∈SH and
A ∈Δ, it follows ∃A ∈Γ. Then, by using the axiom (Mb−A), we get A ∈Γ
(absurd).
$\square$

### 4.2. Mosaic-Based Tableaux

It is relatively simple to extract quite appealing semantic tableau systems for
our logics directly from the mosaics definition. The syntactical elements of our
tableaux systems are partial 6-tuples properly labelled with sets of formulas,
plus the particle closed that will stand for an absurd. Rigorously, a partial
6-tuple is simply a partial function Θ : {ul, ur, ml, mr, dl, dr} ̸→2F. The
letters d, m, u and l, r used in naming the elements of the domain of Θ, the
positions, stand for down, middle, up, and left, right, respectively. We will often
depict these partial tuples graphically as shown in Fig. 2, omitting the unde-
fined entries from the graphical representation, and assuming that, whenever
defined, Θ(p) = Θp for p ∈{ul, ur, ml, mr, dl, dr}. In Fig. 2, we also depict
the general form of the (linear only) 3-tuples used in [14], as well as of the
tuples with the upper-right and down-left entries undefined (for illustration
purposes).

*Figure 2. Sample graphical representations of partial tuples*

*Figure 3. General shape of tableau rules*

The semantics is simple. A structure M = (W, ≺, ≃, V) is said to satisfy
a tuple Θ : {ul, ur, ml, mr, dl, dr} ̸→2F, in which case Θ is said to be satis-
fiable, if there exists a function ω : {ul, ur, ml, mr, dl, dr} ̸→W such that the
following conditions hold:
• for every p ∈{ul, ur, ml, mr, dl, dr},
–
ω(p) is defined iffΘ(p) is defined;
–
if ω(p) is defined then M, ω(p) |= Θp;
• for every h ∈{l, r},
–
if Θ(dh) and Θ(mh) are both defined then ω(dh) ≺ω(mh),
–
if Θ(dh) and Θ(uh) are both defined then ω(dh) ≺ω(uh),
–
if Θ(mh) and Θ(uh) are both defined then ω(mh) ≺ω(uh);
• for every v ∈{d, m, u},
–
if Θ(vl) and Θ(vr) are both defined then ω(vl) ≃ω(vr).
We also define the particle closed to be unsatisfiable.
This explains well why we will work, in the general case, with such tuples:
3 vertically related points by 2 horizontally related points are what we need to
be able to express all the mosaic conditions of the previous section (namely, the
most complex one, that is strong diagram completion). Indeed, we can directly
produce tableau rules that correspond to the mosaic conditions, either unary
(αR), or binary (βR) leading to a bifurcation in the tableau, as shown in Fig. 3.
The rules are given in Figs. 4, 5, 6, 7 and 8. Dots represent context around
the highlighted entries of the tuples that is meant to be preserved by the rules,
but which can always be erased (neglected) using the deletion rule DelR in
Fig. 4. In fact, the dots in the rule DelR represent the fact that any entry in a
partial tuple can be deleted. Similarly, for instance, the dots in CutR represent
the fact that we can apply a cut in any entry of a partial tuple, while there

*Figure 4. Propositional and simplification rules*

are rules, such as ∀R2(left) in Fig. 5 or ¬GR in Fig. 7, where the dots specify
that only some of the context is meant to be preserved.
Figure 4 also presents the basic propositional rules stemming (almost)
immediately6 from the definition of point in a mosaic structure, Definition 3.2,
including in particular the unrestricted cut rule CutR and the closure rule
ClsR.
6 The immediate counterparts of condition (L2) in Definition 3.2 are obviously the rule ∧R
and a form of ∧-introduction that could be expressed by a rule such as the one depicted
below.
...
...
...
. . .
Γ, A, B
. . .
...
...
...
...
...
...
. . .
Γ, A, B, A ∧B
. . .
...
...
...
However, in the presence of CutR, it is not difficult to see that this rule turns out to be
equivalent to the much more usual rule ¬∧R, that we include.

*Figure 5. General coherence-based rules*

Notice that a common rule for ¬¬-elimination such as
...
...
...
. . .
Γ, ¬¬A
. . .
...
...
...
¬¬R
...
...
...
. . .
Γ, ¬¬A, A
. . .
...
...
...
is not listed, since it is redundant given the (powerful) presence of CutR.
In Fig. 5, we have the rules corresponding to the coherence conditions
on mosaics, both for what concerns the vertical and the horizontal compo-
nents. In Fig. 6, we find “special” coherence-based rules, namely AtmR rules
capturing the atomic harmony assumption, rules NfstR and NlstR expressing
unboundedness towards the past and towards the future, respectively, and rules
Mb−R corresponding to the property of the maximality of branches. Rules
corresponding to the saturation properties are presented in Fig. 7, where we

*Figure 6. Special coherence-based rules*

*Figure 7. General saturation-based rules*

*Figure 8. Special saturation-based rules*

have rules that mimic the curing of defects of Sect. 3.2, and in Fig. 8, where the
special conditions on boundedness, discreteness and density of linear flows are
captured together with rules that allow for representing the properties Wdc
and Sdc.
We can now define a hierarchy of tableau systems R(C, D) for each of our
logics L(C, D) (but with Udsc, Ddsc not in C), by including:
•
the propositional and simplification rules
DelR, CutR, ClsR, ∧R, ¬∧R,
the linear-time rules7
GR, HR, ¬GR, ¬HR, ¬GR2, ¬HR2,
the branching rules
∀R, ∀R2(left), ∀R2(right), ¬∀R;
•
rules for particular linear flows
CR, for each condition C considered;
•
additional rules for particular target branching classes
–
D=(Wdc)
WdcR;
–
D=(Wdc+Sdc)
WdcR, SdcR;
–
D=(Wdc+Sdc+Mb−)
WdcR, SdcR, Mb−R(left), Mb−R(right).
In the case we assume atomic harmony, the system will also contain the
rules AtmR(left) and AtmR(right).
As usual, in any of these tableau systems, a tableau is a (possibly infi-
nite) tree built from a given root by application of the tableau rules. A tableau
7 Collecting just the propositional and simplification rules, plus the linear-time rules, we get
a tableau system that is essentially the same as the one described in [14].

*Figure 9. A closed tableau for the negation of WdcA*

whose root is a tuple Θ will be dubbed a tableau for Θ. We say that a tab-
leau is closed if all its branches end with the particle closed. Otherwise, the
tableau, as well as the corresponding branch, are said to be open. Further, a
tableau is said to be exhausted if it is open but no further rules can be applied
to its open branches.
In Fig. 9, as an example, we show a closed tableau for the negation of
the axiom WdcA.
The following is a straightforward technical result which will be useful
later on.

**Lemma 4.7.** If there is a closed tableau for a given tuple Θ, then:
(i) there exists a tuple Θ0 for which the exact same tree is also a closed tab-
leau, such that Θ0 is defined at exactly the same positions as Θ and, at
each defined position p, Θ0
p ⊆fin Θp;
(ii) the exact same tree is also a closed tableau for any tuple Θ+ defined at all
the positions where Θ is defined and such that, at each defined position
p, Θp ⊆Θ+
p .

*Proof.* For (i), observe that in each rule of the system the number of “rele-
vant” formulas (i.e., those necessary in order to make the rule applicable) in
the premises is finite. The thesis follows by noticing that the number of rules
applied in a closed tableau is finite. As for (ii), just observe that all the rules
applied in the closed tableau for Θ can still be applied if we have as a root a
tuple Θ+ such that all its positions extend those of Θ.
$\square$

An R(C, D)-tableau is a tableau built by using only rules in R(C, D).
Given a set Γ ⊆F, we say that it is R(C, D)-consistent if there is no closed
R(C, D)-tableau for
Γ . The set Γ is further said to be maximally R(C, D)-
consistent if either A ∈Γ or ¬A ∈Γ for every A ∈F. If Γ is not R(C, D)-con-
sistent, it will be called R(C, D)-inconsistent.

**Theorem 4.8.** For each class C of linear orders such that Udsc and Ddsc are
not in C and each target branching class D, the tableaux system R(C, D) for
the logic L(C, D) is sound.
In order to show soundness (that is, if a set Γ of formulas is inconsistent
then it is not satisfiable by a C-D-structure) it suffices to check, for each tab-
leau rule, that if its numerator is satisfiable then so must be at least one of
the denominators. Also this proof is routine and we thus omit it.

**Theorem 4.9.** For each class C of linear orders such that Udsc and Ddsc are
not in C and each target branching class D, the tableaux system R(C, D) for
the logic L(C, D) is complete.

*Proof.* For completeness, we must prove that if a set Γ of formulas is R(C, D)-
consistent then it is C-D-satisfiable. Taking advantage of mosaics, we will
show that there is a C-D-structure of mosaics for Γ. Concretely, we will define
a unique C-D-structure of mosaics that contains points corresponding to all
R(C, D)-consistent sets.
Let S = (SV , SH) be such that:
• SV contains precisely
– (Δ) for each maximally R(C, D)-consistent set Δ, and
– (Ω, Δ) for each pair of maximally R(C, D)-consistent sets Ω, Δ such that
there is no closed tableau for
Δ
Ω .
• SH contains
–
(Δ) for each maximally R(C, D)-consistent set Δ, and
–
(Ω, Δ) for each pair of maximally R(C, D)-consistent sets Ω, Δ such
that there is no closed tableau for
Ω
Δ .

As Γ is R(C, D)-consistent it can be extended to a maximally R(C, D)-consis-
tent set Γ′, e.g., by considering one of the open branches of a CutR exhausted
C-D-tableau for
Γ . Hence, Γ′ is a point of S. Therefore, all we need to show
is that S is indeed a C-D-structure of mosaics.
The proof will be modular with respect to local, vertical, horizontal and
compositional properties. Namely, one can notice that in what follows each
condition C will be proved to be satisfied by S by using only the rules present
in the systems R(C, D) for those classes C and D such that a C-D-structure of
mosaics is required to satisfy C.
The first part of the proof, concerning local and vertical conditions, fol-
lows from the one in [14]; we will omit most of the details.
Local conditions. First of all, it is easy to notice that any maximally R(C, D)-
consistent set is a point (on F). Condition L1 follows immediately from
maximal consistency. For condition L2, assume B ∧C ∈Γ and either B /∈Γ
or C /∈Γ; by using ∧R, one gets a closing situation, which contradicts the
consistency of Γ. The other direction of L2 is proved similarly by using ¬∧R
and ClsR; condition L3 follows from ∀R and ClsR.
Vertical coherence conditions. As in [14], by using GR, HR and ClsR, we have
that each (Ω, Δ) ∈SV is a vertical mosaic.
Horizontal coherence conditions. To prove that (Ω, Δ) ∈SH is a horizontal
mosaic, we must show that Ω and Δ are state-equivalent (property H1).
We proceed by induction. As a base case, we have that if ∀A ∈Ω and
∀A /∈Δ (or vice-versa, without loss of generality) then ¬∀A ∈Δ. But
by using ∀R2(left/right) we would get to a closing situation on ∀A, which
contradicts (Ω, Δ) ∈SH.
In case we assume atomic harmony, we have a further base case con-
cerning atomic propositions. If p ∈Ω and p /∈Δ (or vice-versa, without loss
of generality) then ¬p ∈Δ. But using AtmR2(left/right) we would get to
a closing situation, which again contradicts (Ω, Δ) ∈SH.
Then we have two step cases, for the boolean connectives ∧and ¬.
Assume that A and B are state-formulas. (i) If A ∧B ∈Ω and A ∧B /∈Δ
(or vice-versa, without loss of generality) then ¬(A ∧B) ∈Δ. Using ∧R
we conclude that A, B ∈Ω and by the induction hypothesis also A, B ∈Δ.
But using ¬∧R both branches would get to a closing situation, which con-
tradicts (Ω, Δ) ∈SH. (ii) If ¬A ∈Ω and ¬A /∈Δ (or vice-versa, without
loss of generality) then A ∈Δ. Using the induction hypothesis also A ∈Ω,
leading to a closing situation, which contradicts (Ω, Δ) ∈SH.
Vertical saturation conditions. Vertical saturation conditions SV1-SV4 can be
proved as in the linear case [14], by using ¬GR, ¬HR, ¬GR2 and ¬HR2,
respectively, plus cutR to get maximally consistent sets.
Conditions on particular linear flows. In the special cases when C includes the
properties Nlst, Lst, Nfst or Fst, we can prove that the maximally R(C, D)-
consistent sets are FU, FB, PU or PB-points, respectively, by using NlstR,
LstR, NfstR and FstR, respectively. We prove the claim for the prop-
erty Nlst. Let Γ be a maximally R(C, D)-consistent set, for C containing
Nlst, and assume for the sake of contradiction that it is not an FU-point,

i.e., that ¬G⊥/∈Γ, which implies G⊥∈Γ. By applying the rule NlstR, we
get a position containing both G⊥and ¬G⊥.
As further vertical saturation conditions, let us consider density (SV-
Dns). Let (Δ, Γ) ∈SV . Then, using DnsR, it is clear that there is also no
closed tableau for
Γ
Δ
. Hence we can use cutR to maximize and obtain a
maximally consistent set Ω such that
Γ
Ω
Δ
can also not be closed, which
guarantees, using DelR, that (Δ, Ω), (Ω, Γ) ∈SV .
Horizontal saturation conditions. We have to prove that S satisfies SH1. Let Δ
be maximally consistent and ¬∀¬A ∈Δ. Using ¬∀R and cutR to maximize
we get a maximally R(C, D)-consistent Ω such that A ∈Ω and (Δ, Ω) ∈SH.
SWdc. Let (Γ, Δ) ∈SH and (Ω, Γ) ∈SV . We first show that there is no
closed tableau for
Γ
Δ
Ω
. If this root could be closed, using Lemma 4.7
there would be finite subsets Δ0 ⊆Δ and Ω0 ⊆Ω such that also
Γ
Δ0
Ω0
could be closed. But (Γ, Δ) ∈SH and (Ω, Γ) ∈SV which implies that
P( Ω0), ∃( Δ0) ∈Γ. Therefore we could also build a closed tableau for
Γ by just using ¬HR, ¬∀R and ∧R, which contradicts the consistency of Γ.
Hence, there is no closed tableau for
Γ
Δ
Ω
. Therefore, we can use
WdcR and then cutR to maximize and obtain a maximally R(C, D)-consis-
tent set Φ such that
Γ
Δ
Ω
Φ can also not be closed, which guarantees, using
DelR, that (Ω, Φ) ∈SH and (Δ, Φ) ∈SV .
STrn. Let (Ω, Γ), (Γ, Δ) ∈SV . To prove that (Ω, Δ) ∈SV we just need to
check that there is no closed tableau for
Δ
Ω . If this root could be closed,
using Lemma 4.7 there would be finite subsets Δ0 ⊆Δ and Ω0 ⊆Ω such
that also
Δ0
Ω0
could be closed. But (Ω, Γ), (Γ, Δ) ∈SV which implies that
P( Ω0), F( Δ0) ∈Γ. Therefore we could also build a closed tableau for
Γ
by just using ¬HR, ¬GR, ∧R and DelR, which contradicts the consistency
of Γ.
SCon. Let (Δ, Γ), (Ω, Γ) ∈SV with Δ ̸= Ω. To prove that (Ω, Δ) ∈SV or
(Δ, Ω) ∈SV we just need to check that there cannot be closed tableaux for
both
Δ
Ω and
Ω
Δ . If that were the case, using Lemma 4.7 there would be
finite subsets Δ′
0, Δ′′
0 ⊆Δ and Ω′
0, Ω′′
0 ⊆Ω such that also
Δ′
0
Ω′
0
and
Ω′′
0
Δ′′
0
could be closed. Notice that Δ ̸= Ω and let B be some formula such that
B ∈Δ and B /∈Ω, i.e., ¬B ∈Ω. Let Δ0 = Δ′
0 ∪Δ′′
0 and Ω0 = Ω′
0 ∪Ω′′
0.
Since (Δ, Γ), (Ω, Γ) ∈SV , we have that P(B ∧( Δ0)), P(¬B ∧
( Ω0)) ∈Γ. Therefore we could also build a closed tableau for
Γ by using
¬HR, ∧R, ¬HR2, DelR, ClsR and CutR on P(¬B∧( Ω0)) and ¬B∧( Ω0)
(see Fig. 10)
SSdc. The construction is similar to that for SWdc. Let (Γ, Δ), (Φ, Ψ) ∈SH
and (Ω, Γ), (Φ, Ω) ∈SV . We first show that there is no closed tableau

*Figure 10. A tableau for the proof of the property SCon*

for
Γ
Δ
Ω
Φ
Ψ
. For the sake of contradiction, let us assume that this root
can be closed. Then, by using Lemma 4.7 there would be finite subsets
Γ0 ⊆Γ, Δ0 ⊆Δ, Φ0 ⊆Φ and Ψ0 ⊆Ψ such that also
Γ0
Δ0
Ω
Φ0
Ψ0
could
be closed. But (Γ, Δ), (Φ, Ψ) ∈SH and (Ω, Γ), (Φ, Ω) ∈SV imply that
F( Γ0 ∧∃ Δ0), P( Φ0 ∧∃ Ψ0) ∈Ω. Therefore we could also build a
closed tableau for
Ω by just using ¬HR, ¬GR, ¬∀R and ∧R, which con-
tradicts the consistency of Ω.
Hence, there is no closed tableau for
Γ
Δ
Ω
Φ
Ψ
. Therefore, we can use
SdcR and then cutR to maximize and obtain a maximally R(C, D)-consis-
tent set Ω′ such that
Γ
Δ
Ω
Ω′
Φ
Ψ
can also not be closed, which guarantees, using
DelR, that (Ω, Ω′) ∈SH and (Ψ, Ω′), (Ω′, Δ) ∈SV .
SMb−. Let Γ, Δ be distinct maximally R(C, D)-consistent sets such that G⊥∈
Γ (without loss of generality). We must show that (Γ, Δ) /∈SH. It suffices
to produce a closed tableau for
Γ
Δ . Notice that as Γ ̸= Δ, there exists
B such that B ∈Γ and B /∈Δ, i.e., ¬B ∈Δ. Thus, using Mb−R(left/right)
we get into a closing situation.
$\square$

Clearly, the unrestricted CutR rule is a problem with respect to imple-
mentations, also preventing us from obtaining tableau-based decision proce-
dures for the logics. However, in certain cases, namely when we consider the

target branching class D = (), it is possible to use only analytical instances of
the cut rule. Let Γ be a finite set of formulas. Given a tableau system R(C, D),
we can define its analytic restriction with respect to Γ as the system RΓ(C, D)
obtained from R(C, D) by replacing CutR with a version of the rule that can
only introduce a formula A ∈Λ, where Λ is the smallest (C, D)-closed set of
formulas containing Γ. Note that in this analytic restriction, discreteness could
be also considered, e.g., by including in the system the following two rules:
. . .
Δ, GA, A
. . .
. . .
Γ, ¬GA
. . .
UdscR
. . .
Δ, GA, A
. . .
¬A, GA
. . .
Γ, ¬GA
. . .
. . .
Γ, ¬HA
. . .
. . .
Δ, HA, A
. . .
DdscR
. . .
Γ, ¬HA
. . .
¬A, HA
. . .
Δ, HA, A
. . .

**Theorem 4.10.** Let C be a class of linear orders and Γ a finite set of formulas.
If Γ is RΓ(C, ())-consistent then it is C-()-satisfiable.

*Proof.* By following the proof of Theorem 4.9, we can modify the definition of
S by requiring the points of S to be RΓ(C, ())-consistent sets maximal in Λ,
where Λ is the smallest (C, ())-closed set of formulas containing Γ. The assert
follows from noticing that in the proof of Theorem 4.9, for showing only the
conditions satisfied by C-()-structures of mosaics, non-analytic cuts are never
used and that all the relevant rules are such that if all the formulas in the
numerator are in Λ then the same happens to all the formulas in the denom-
inator. Finally, we notice that the restricted version of the cut is enough for
maximalizing sets, when required by the proof, with respect to Λ.
$\square$

Theorem 4.10 gives the completeness of the analytic system with respect
to the logic L(C, ()). Its soundness is a trivial consequence of Theorem 4.8.
Notice, instead, that, for proving conditions SWdc, STrans, SConn and
SSdc in Theorem 4.9 (i.e., when we consider target branching classes different
from the basic one), we make essential use of unboundedly complex formulas
and that in proving SConn we even use cuts on such formulas. This prevents
us from obtaining any obvious corresponding analyticity result.

### 4.3. Decidability Via Mosaics

Another interesting application of the mosaic technique, which we pursue here,
is in proving the decidability of a given logic and in obtaining an asymptotic
upper-bound on its decision problem. We will show how mosaics can be used
in order to prove decidability of the logics considered in the paper in the par-
ticular case of basic structures. The proof follows the idea of the decidability
proofs in [14] and [19].

**Theorem 4.11.** The problem of checking satisfiability of formulas in the logic
L(C, ()), for C a class of linear orders, is decidable.

*Proof.* Let A be a satisfiable formula. By following the same construction as
in the proof of left-to-right direction of Theorem 3.15 (just consider the finite
set Γ as consisting only of A), we can show that there exists a C-()-structure
of mosaics for A on the smallest C-()-closed set Λ of formulas containing A.

Since Λ is finite, the number of possible mosaics, and thus of structures
of mosaics, on it is also finite. Given that checking coherence and saturation
conditions is decidable, we can take each pair of sets of mosaics in turn and
check whether it is a C-()-structure of mosaics for A.
$\square$

We can obtain an asymptotic upper bound by observing that the cardi-
nality of the set Λ, as defined in the proof of Theorem 4.11, is O(n), where n
is the complexity of A. It follows that the number of possible mosaics on that
set is O(2n) and the number of structures of mosaics is O(22n). Coherence and
saturation conditions can be checked in polynomial time.
It is easy to see that the argument in the proof of Theorem 4.11 does not
extend to the logics L(C, D) for D ̸= (). Namely, when there is some interaction
between the vertical and the horizontal components, the simple translation of
a model into sets of mosaics described in the proof above produces a structure
that does not necessarily satisfy all the saturation conditions required. This is
of course also related to the results of Sect. 4.2, where an analytic version of
the tableau system has been proven to be sound and complete only in the case
of the target branching class being the basic one. The possibility of cutting
with respect to the full language F is necessary there in order to get tableaux
completeness for logics L(C, D) where D ̸= (); analogously, considering mosaics
defined on Λ = F would allow the construction of the proof of Theorem 4.11
to provide a structure of mosaics satisfying all the saturation conditions (but
then the result of decidability would not follow since the number of possible
mosaics on F is infinite).
In order to get a proof of decidability based on mosaics also for the other
classes of logics8, it might be useful to consider a more complex, and branch-
ing-oriented, notion of mosaic (more on this in Sect. 5).
The proof of decidability given here seems extremely appealing because
of its simplicity. We observe that it should also be possible to define a deci-
sion procedure for the C-()-logics based on the tableau system of Sect. 4.2, by
exploiting analyticity of the cut rule in that case and properly avoiding the
repeated curing of the same defect.

## 5. Conclusions

We have proposed an extension of the mosaic method from a class of linear
temporal logics to a two-dimensional logic obtained by adding an “orthogonal”
S5-like component, and we have treated several applications of the method.
Namely we have shown how the mosaic techniques can be used to prove com-
pleteness for the corresponding Hilbert-style axiomatization, to define a sound
and complete tableau system and to obtain a decision procedure for the logic
considered as well as to establish an asymptotic upper-bound on its complexity.
8 We recall that decidability of the logic L((), (Wdc + Sdc + Mb−)) is proved in [1], using
Rabin’s Theorem [18], which states the decidability of the monadic second order theory of
infinite binary trees. In [7], such a proof is adapted to the case with atomic harmony.

In [14] the mosaic method has been proposed for the general linear-time
logics together with some variants capturing particular (i.e., dense, discrete,
bounded/unbounded) linear flows of time. The approach presented here can be
seen as a conservative extension of that method, in the sense that our presen-
tation is modularized with respect to a vertical (linear-time) and a horizontal
(S5-like) component, in such a way that the first one consists of definitions
and proofs just imported from [14].
We have also considered the possibility of having interactions between
the two components, in order to treat logics that capture the idea of branch-
ing-time. To that aim, our treatment has been parameterized along both the
two components: with respect to the class of linear orders considered, ranging
from the general to more specific ones (i.e., dense, discrete, etc.), and with
respect to the class of branching structures, according to a hierarchy leading
from the basic ones, where the two orthogonal components are independent,
to “more branching” ones, like the Ockhamist structures of, e.g., [29].
Namely, by letting C range over classes of linear orders and D over sets of
branching properties, we have considered a broad class of Ockhamist branch-
ing-time logics L(C, D) and defined for them, by means of a fully modular
presentation, an extension of the mosaic method. Indeed, this two-dimensional
view allows for dealing, in a clear way, with the logics defined over Ockhamist
structures where all the vertical components are in the same class of linear
orders, or, which is equivalent, to the class of bundled trees such that all the
paths are in the same class of linear orders. However while, as long as the
vertical and the horizontal component behave independently, all the results
in [14] (proof of Hilbert-style completeness, definition of a complete tableau
system and proof of decidability) can be proved to propagate, in the case when
interactions between the two components are considered we have some restric-
tions: a tableau system can only be defined by allowing a non-analytic version
of the cut rule and thus the proof of decidability does not apply.
We believe that our approach, presented here with a focus on temporal
logics, can be seen as more generally suitable for dealing with many-dimen-
sional modal logics without interactions between the dimensions [9]. In such
a context, mosaics can be seen as an alternative to other techniques typically
used in order to get (the transfer of) decidability or completeness results, such
as fibring [8].
Further work is required in order to capture properly, i.e., in a way that
allows for proving decidability, also logics where interactions are considered,
such as the branching-time logics seen in this paper or several logics of knowl-
edge and time [5,11] which present similar interaction frame properties. Our
future research will consider the possibility of having a more complex notion of
mosaic, in some way taking into account, already in the definition of the basic
components of our structures, the possible interactions between the dimensions
(i.e., in the case of temporal logics, their branching nature). As an example,
we recall the treatment in [19], where the decidability of a logic defined over
rectangular frames consisting of the cross product of a (vertical) linear order
and a (horizontal) set of worlds, is proved by using mosaics that are pairs of

horizontal segments of points. We are aware that, as a trade-off, an approach of
this kind would probably compromise (at least part of) the desirable modular-
ity properties, with respect to the linear treatment of [14], that the presentation
proposed here enjoys.

## Acknowledgements

The authors are grateful to Andrea Masini and Alberto Zanardo for several
fruitful discussions on the subject of this paper, and to the anonymous referee
for valuable remarks on an earlier version of this paper.

## References

[1] Burgess, J.P.: Logic and time. J. Symb. Log. 44(4), 566–582 (1979)
[2] Burgess, J.P.: Decidability for branching time. Stud. Log. 39, 203–218 (1980)
[3] Burgess, J.P.: Axioms for tense logic. I. “Since” and “until”. Notre Dame J.
Form. Log. 23(4), 367–374 (1982)
[4] Di Maio, M.C., Zanardo, A.: Synchronized Histories in Prior-Thomason Repre-
sentation of Branching Time. In: Gabbay, D.M., Ohlbach, H.J. (eds.) ICTL ’94,
LNCS, vol. 827, pp. 265–282. Springer, Berlin, Heidelberg (1994)
[5] Fagin, R., Halpern, J., Moses, Y., Vardi, M.: Reasoning About Knowledge. The
MIT Press, Cambridge-Massachusetts, London-England (1995)
[6] Gabbay, D.M.: An irreflexivity lemma with applications to axiomatizations of
conditions on tense frames. In: M¨onnich, U. (ed.) Aspects of philosophical logic
(T¨ubingen, 1977), vol. 147, pp 67–89. Synthese Library, Reidel, Dordrecht (1981)
[7] Gabbay, D.M., Hodkinson, I., Reynolds, M.: Temporal Logic: Mathematical
Foundations and Computational Aspects, vol. 1. Oxford University Press-
Clarendon Press, Oxford (1994)
[8] Gabbay, D.M., Shehtman, V.B.: Products of Modal Logics, Part 1. Log. J. IGPL
6(1), 73–146 (1998)
[9] Gabbay, D.M., Kurucz, A., Wolter, F., Zakharyaschev, M.: Many-Dimensional
Modal Logics: Theory and Applications. Studies in Logic, vol. 148. Elsevier Sci-
ence (2003)
[10] Goranko, V., Zanardo, A.: From linear to Branching-time temporal logics: trans-
fer of semantics and definability. Log. J. IGPL 15(1), 53–76 (2007)
[11] Halpern, J.Y., Van der Meyden, R., Vardi, M.Y.: Complete axiomatizations for
reasoning about knowledge and time. SIAM J. Comput. 33(3), 674–703 (2004)
[12] Hirsch, R., Hodkinson, I., Marx, M., Mikul´as, S., Reynolds, M.: Mosaics and
step-by-step. Remarks on “A modal logic of relations”. In: Logic at Work. Essays
Dedicated to the Memory of Helena Rasiowa, pp. 158–167. Springer, Berlin,
Heidelberg (1999)
[13] Kurucz, A.: Combining modal logics. In: van Benthem, J., Blackburn, P., Wolter,
F. (eds.) Handbook of Modal Logic, pp. 869–924. Elsevier, Amsterdam (2007)
[14] Marx, M., Mikul´as, S., Reynolds, M.: The mosaic method for temporal logics.
In: Dyckhoff, R. (ed.) TABLEAUX, LNCS, vol. 1847, pp. 324–340. Springer,
Berlin, Heidelberg (2000)

[15] Mikul´as, S.: Taming first-order logic. J. IGPL 6(2), 305–316 (1998)
[16] N´emeti, I.: Free Algebras and Decidability in Algebraic Logic. PhD Thesis, Hun-
garian Academy of Sciences, Budapest (1986)
[17] N´emeti, I.: Decidable versions of first order logic and cylindric-relativized set
algebras. In: Logic Colloquium ’92, pp. 171–241. CSLI Publications, Stanford
(1995)
[18] Rabin, M.O.: Decidability of second-order theories and automata on infinite
trees. Trans. Am. Math. Soc. 141, 1–35 (1969)
[19] Reynolds, M.: A decidable temporal logic of parallelism. Notre Dame J. Form.
Log. 38, 419–436 (1996)
[20] Reynolds, M.: Axioms for branching time. J. Log. Comput. 12(4), 679–697 (2002)
[21] Reynolds, M.: The complexity of the temporal logic with “until” over general
linear time. J. Comput. Syst. Sci. 66(2), 393–426 (2003)
[22] Reynolds, M.: Dense time reasoning via mosaics. In: TIME ’09, pp. 3–10. IEEE
Computer Society, Los Alamitos, CA, USA (2009)
[23] Reynolds, M.: The complexity of decision problems for linear temporal logics. J.
Stud. Log. 3(1), 19–50 (2010)
[24] Reynolds, M.: The complexity of temporal logic over the reals. Ann. Pure Appl.
Log. 161, 1063–1096 (2010)
[25] Thomason, R.H.: Combinations of tense and modality. In: Handbook of Philo-
sophical Logic: Extensions of Classical Logic, pp. 135–165. Reidel, Dordrecht
(1984)
[26] Van Dalen, D.: Logic and Structure. Springer, Berlin, Heidelberg (1994)
[27] Venema, Y., Marx, M.: A modal logic of relations. In: Logic at Work: Essays
Dedicated to the Memory of Helena Rasiowa. Physica-Verlag, Heidelberg, New
York (1999)
[28] Zanardo, A.: A finite axiomatization of the set of strongly valid Ockhamist for-
mulas. J. Philos. Log. 14, 447–468 (1985)
[29] Zanardo, A.: Branching-time logic with quantification over branches: the point
of view of modal logic. J. Symb. Log. 61(1), 1–39 (1996)
Carlos Caleiro and Marco Volpe
Departamento de Matem´atica, Instituto Superior T´ecnico
SQIG, Instituto de Telecomunica¸c˜oes
Universidade T´ecnica de Lisboa
Lisbon, Portugal
e-mail: ccal@math.ist.utl.pt;
mvolpe@math.ist.utl.pt
Luca Vigan`o
Dipartimento di Informatica
Universit`a di Verona
Verona, Italy
e-mail: luca.vigano@univr.it
Received: August 1, 2011.
Accepted: October 20, 2012.
