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
