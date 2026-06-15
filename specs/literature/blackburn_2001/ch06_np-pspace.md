<!-- Source: Blackburn, de Rijke & Venema (2001). Modal Logic. Cambridge University Press. Chapter 6: Computability and Complexity, §6.6 NP and §6.7 PSPACE (pages 375-394). BibKey: Blackburn2001 -->

6.6 NP
At the end of this chapter we will use a 2-player tiling problem to show that the
satisﬁability problem for PDL is EXPTIME-hard.
Exercises for Section 6.5
6.5.1 Show that KRA-satisﬁability is decidable if we have only one atomic program at our
disposal. (This result can be proved via a ﬁnite model property argument.)
6.5.2
(i) Show that the satisﬁability problem of the following ‘tiling’ logic
Tile
1 is
undecidable.
Tile
1 is a normal modal logic with three diamonds
hui;
hr
i and
3,
deﬁned by the following (Sahlqvist) axioms:
huip
!
[u]p and
hr
i
p
!
[r
]
p
(6.11)
hr
i
hui
p
!
[
u]
hr
i
p
33p
!
3p
huip
!
3p and
hr
i
p
!
3p:
(ii) Now use this logic plus the standard translation to conclude that the three variable
fragment of ﬁrst-order logic (without function symbols, but possibly with equality)
is undecidable.
(iii) Let
Tile
2 be obtained from
Tile
1 by omitting axiom (6.11). Show that
Tile
is still undecidable. (Hint: Reduce the satisﬁability problem of
Tile
1 to that of
Tile
2.)
(iv) Conclude that ﬁrst-order logic with three variables, but without equality is unde-
cidable.
(v) Use a similar tiling logic to show that ﬁrst-order logic with one variable, two unary
function symbols, and only unary predicate symbols is undecidable. (Hint: adjust
the standard translation so that it exploits the unary function symbols directly.)
6.6 NP
The interpretation method (and in particular, interpretations in
SnS) is a powerful
and widely applicable way of proving decidability. Nevertheless, it has disadvan-
tages. Reducing the satisﬁability problems of what are often rather simple modal
logics to
SnS is using a sledgehammer to crack a nut. The decision problem for
SnS is non-elementary. This means that the time required to decide whether an
arbitrary formula
 is decidable cannot be bounded by any ﬁnite tower of expo-
nentials of the form
2...
jj
:
The use of ﬁltrations to establish decidability is open to similar objections. A
ﬁltration is typically
jj in the size of the input formula. But it is not feasible to
enumerate all the models up to this size even for quite small values of
jj. And
even a nondeterministic Turing machine, which could ‘guess’ a ﬁltration in one
move (see Appendix C and the discussion below), would still be faced with the



6 Computability and Complexity
immensely costly task of checking that
 was true on this huge structure (to use
the terminology discussed in Appendix C, ﬁltrations typically offer us NEXPTIME
algorithms). Indeed, of the three decidability techniques discussed so far, only
the mosaic method (which ‘deconstructs’ models locally) respects what is special
about modal logic; and as we will learn in Section 7.4, the mosaic method can be
used to give essentially optimal satisfaction algorithms.
But this is jumping ahead. In this section and the three that follow, we will
use concepts drawn from computational complexity theory to present a more ﬁne-
grained analysis of modal satisﬁability. This analysis is interesting for two reasons.
First, by making use of only three central complexity classes (NP, PSPACE and
EXPTIME), we will be able to present a classiﬁcation of modal satisﬁability that
covers many important logics. Secondly, in many cases the techniques involved
have a distinctly modal ﬂavor: essentially, the work boils down to a reﬁned analysis
of the ﬁnite model property.
We begin our analysis with the class NP, the class of problems solvable using
nondeterministic polynomial time algorithms. We ﬁrst review the central ideas
underlying this complexity class and their import for modal satisﬁability problems.
Then, using examples from multi-modal and tense logic, we show how simple
selection arguments can be used to prove NP-completeness results. Finally, we
apply the same method to prove a more general result: every normal modal logic
extending S4.3 has an NP-complete satisﬁability problem.
When a problem
P is said to be complete with respect to a complexity class C,
two things are being claimed. The ﬁrst is that
P belongs to C; that is, there is an
algorithm using only the resources permitted by C that solves
P. For example, if
C
=
NP this means that there exists a non-deterministic polynomial time algorithm
for solving
P. The second claim is that
P is C-hard; that is, any other problem in
C is polynomial time reducible to
P.
Now, as far as the satisﬁability problem for normal modal logics is concerned,
NP-hardness is a triviality: all (consistent) normal modal logics have NP-hard sat-
isﬁability problems. The point is this. The classic NP-hard problem is the satis-
ﬁability problem for propositional logic. But as every normal modal logic is an
extension of propositional logic, every (consistent) normal modal logic has a sat-
isﬁability problem at least as hard as that for propositional logic. Thus — for the
class NP — our work is somewhat simpliﬁed: we are simply looking for normal
modal logics whose satisﬁability problem belongs to NP.
What sort of problems belong to NP? Many problems decompose naturally into
the following two steps: a search for a solution followed by a veriﬁcation of
the solution. In general, search is expensive, but by thinking in terms of non-
deterministic algorithms we can abstract away from this expense: if a solution
exists, such an algorithm will ﬁnd it in one non-deterministic step. (If necessary,
consult Section C for further discussion.) This abstraction leaves us free to concen-



6.6 NP
trate on the veriﬁcation step, and leads us to isolate the class NP: a problem belongs
to NP iff it has the above general proﬁle (that is, a non-deterministic choice of a
solution followed by a veriﬁcation) and moreover the veriﬁcation step is tractable
(that is, solvable in polynomial time).
How do such ideas bear on modal satisﬁability? The key idea we need is em-
bodied in the following lemma.
Lemma 6.35 Let
 be a ﬁnite similarity type. Let
 be a consistent normal modal
logic over
 with the polysize model property with respect to some class of models
M. If the problem of deciding whether
M
M is computable in time polynomial
in
jMj, then
 has an NP-complete satisﬁability problem.
Proof. As noted above, the NP-hardness of the problem is immediate, so it remains
to prove the existence of an algorithm in NP that solves
-satisﬁability. Given
,
non-deterministically choose a model
M whose size is polynomial in the size of
.
Because
M is polysize in
jj, we can check in time polynomial in
jj whether
M
veriﬁes
. For the special case of the basic modal language, this may be seen as
follows.
Let
jjMjj denote the sum of the number states in
M and the number of pairs in
M’s binary relation
R
M. Let
 
1, . . . ,
 
k be an enumeration of the subformulas of
, in increasing length. So
 
k
=
 and if
 
i is a subformula of
 
j, then
i
<
j.
Notice that
k

jj. One can show by induction on
m that we can mark each state
w in
M with
 
j or
: 
j, for
j
=
1, . . . ,
m, depending on whether or not
 
j is
true at
w in time
O
m

jjMjj. The only non-trivial case is if
 
m+1
=
3 
j, for
some
j
<
m
+
1. But in that case we mark
w with
2 
j if some
v with
R
w
v is
marked with
 
j. By our induction hypothesis, every state is already marked with
 
j or
: 
j, this step can be carried out in time
O
jjMjj. Since
M is polysize in
j,
so is
jjMjj. Hence, checking whether
M satisﬁes
 can indeed be done in time
polynomial in
jj.
Finally, then, because membership in M is decidable in time polynomial in
jMj,
and
jMj is polynomial in
jj, we can check in time polynomial in
jj that
M is in
M.
a
Where did we use the assumption that
 is a ﬁnite similarity type in the proof
of Lemma 6.35? Essentially, it allows us to check whether
M veriﬁes
 in time
polynomial in
 and in
jMj. The key point is this: when working with a ﬁxed ﬁnite
similarity type, we are actually working within a ﬁnite-variable fragment, say with
l variables. This allows us to restrict our attention to only ﬁnitely many relations of
arity at most
l in
M. While the total number of tuples in all relations in
M may be
huge, it is nonetheless independent of
; see Exercise 6.6.2 for further elaborations.
Note that the second demand — that M-membership be polynomial time decid-
able — is vital. As the reader was asked to show in Exercise 6.2.4, the polysize



6 Computability and Complexity
model property alone is insufﬁcient to ensure decidability, let alone the existence
of a solution in NP. However, for many important logics this property can be estab-
lished by appealing to the following standard result.
Lemma 6.36 If F is a class of frames deﬁnable by a ﬁrst-order sentence, then the
problem of deciding whether
F belongs to F is decidable in time polynomial in the
size of
F.
Proof. Left as Exercise 6.6.1.
a
We will show that many normal modal logics are NP-complete. The proofs revolve
around one central idea: the construction of polysize models by the selection of
polynomially many points from some given satisfying model.
For our ﬁrst example, we return to the multi-modal language containing
n unary
modal operators discussed earlier (see Corollary 6.9). Recall that
F
n
1 is the class of
frames for this language in which each relation is a partial function,
M
n
1 is the class
of models built over
F
n
1, and K
nAlt
1 is its logic.
Theorem 6.37 K
nAlt
1 has an NP-complete satisﬁability problem.
Proof. We already showed that this logic has the strong f.m.p., but the selection
argument we used generated models exponential in size of the input formula. A
simple reﬁnement of the method shows that K
nAlt
1 actually has the polysize model
property.
Given a formula
 of this language and a model
M
=
(W
;
R
;
V
) we deﬁne a
selection function
s as follows:
s(p;
w
)
=
fw
g
s(:;
w
)
=
s(;
w
)
s(
^
 
;
w
)
=
s(;
w
)
[
s( 
;
w
)
s(hai 
;
w
)
=
fw
g
[
[
fw
jR
a
w
w
g
s( 
;
w
)
Intuitively,
s(;
w
) selects the nodes actually needed when evaluating
 in
M at
w
— and indeed, it follows by induction on the structure of
 that for all nodes
w of
M, and all formulas

M;
w

 iff
M

s(;
w
);
w

:
It is clear that
M

s(;
w
)
M
n
1. So let us look at size of the new model. If
M
M
n
1, we claim that
js(;
w
)j

jj
+
1. To see this, note that only occurrences
of modalities in
 cause new nodes to be adjoined to
s(;
w
). This adjunction of
points is carried out in the fourth clause of the inductive deﬁnition for
s, which tells
us to adjoin every state
w
0 such that
R
a
w
w
0. Because
M
M
n
1, every relation
R
a



6.6 NP
is a partial function; hence if such a
w
0 exists, it is unique. In short, K
nAlt
1 has
the polysize model property: simply counting the number of occurrences of modal
operators in
 and adding one gives us an upper bound on the size of the domain
of the required satisfying model.
By Lemma 6.36, membership in K
nAlt
1 is decidable in polynomial time, for this
is a class of frames deﬁnable by a ﬁrst-order sentence — namely the conjunction
of sentences that say that each of the
n relations is a partial function.
The result follows by Lemma 6.35.
a
The argument for K
nAlt
1 shows the selection method in its simplest form: given
any model for
 we build a new polysize model for
 by making a suitable selection
of polynomially many points. This simple form of argumentation is applicable to a
number of logics, a particularly noteworthy example being S5. Given any S5 model
for
, it is possible to select
m
+
1 points from this model (where
m is the number
of modality occurrences in
) which sufﬁce to construct a new S5 model for
,
and the NP-completeness of S5 follows straightforwardly. We leave the details as
Exercise 6.6.4 and turn our attention to a modiﬁcation of the point selection method
frequently needed in practice: a detour via ﬁnite models.
Both K
nAlt
1 and S5 are very simple logics; in neither case is it difﬁcult to deter-
mine which points should be selected. In other cases, we may not be so fortunate.
Suppose we are trying to show that a logic
 has the polysize model property, and
we already know that
 has the f.m.p. Then, instead of trying to select points from
an arbitrary model, we are free to select points from a ﬁnite model, or even a point-
generated submodel of a ﬁnite model. This often gives us an easy way of zooming
in on the crucial points. In particular, when we are working with models based
on ﬁnite orderings it makes sense to talk of choosing points that are maximal (or
minimal) in the frame ordering that satisfy some subformula; such extremal points
are often the vital ones. As an example of such an argument, let us consider
K
t
4:3,
the temporal logic of linear frames (in the basic temporal language).
Theorem 6.38
K
t
4:3 has an NP-complete satisﬁability problem.
Proof. We will ﬁrst show that
K
t
4:3 has the polysize model property. Let
 be
a formula of the basic temporal language that is satisﬁable on a
K
t
4:3 model.
As
K
t
4:3 has the f.m.p. with respect to the class of weak total orders (see Def-
inition 4.37 and Corollary 6.8), there is a ﬁnite weakly totally ordered model
M
=
(T
;
;
V
) containing a node
t such that
M;
t

. We now build a poly-
sized model for
 by selecting points from
M.
Let
F
 
1, . . . ,
F
 
k and
P

1, . . . ,
P

l be all subformulas of
 of the form
F
 
and
P
, respectively, that are satisﬁed in
M. For each formula
F
 
i choose a point
u
i such that
M;
u
i

 
i and
u
i is a maximal point in the
-ordering with this
property. Similarly, for each formula
P

j choose a point
v
j satisfying

j that is



6 Computability and Complexity
minimal in the
-ordering with respect to this property. Let
M
0 (=
(T
;

;
V
))
be
M

ft;
u
;
:
:
:
;
u
k
;
v
;
:
:
:
;
v
l
g. As
 is a weak total ordering of
T,

0 is
a weak total ordering of
T
0. Furthermore, the number of nodes in
M
0 does not
exceed
m
+
1, where
m is the number of modalities in
, thus
M
0 is a polysize
model in the correct class. It remains to show that
M
;
t

, but this follows
straightforwardly by induction on the structure of
.
As the class of weak total orders is deﬁnable using a ﬁrst-order sentence, the NP-
completeness of
K
t
4:3 follows from Lemma 6.36 and the polysize model property
that we have just established.
a
We are ready to prove a general complexity result for the basic modal language: all
normal logics extending S4.3 have an NP-complete satisﬁability problem. Recall
from our discussion of Bull’s theorem in Section 4.9 that an S4.3 frame is a frame
that is rooted, transitive, and connected (8xy
(R
xy
_
R
y
x)); note that all such
frames are reﬂexive. Bull’s Theorem tells us that all normal modal logics extending
S4.3 have the ﬁnite frame property with respect to a class of S4.3 frames. By
making a suitable selection from models based on such frames, we can prove that
every such logic has the polysize model property. Then, by using the fact that every
normal logic extending S4.3 has a negative characterization in terms of ﬁnite sets of
ﬁnite frames (Theorem 4.103), we will be able to prove that all these satisﬁability
problems are NP-complete.
First we need the following lemma; it is really just Lemma 4.98, which linked
bounded morphisms and covering lists, stated in purely modal terms.
Lemma 6.39 Let
F and
G be two ﬁnite S4.3 frames. Then the following two state-
ments are equivalent:
(i) There exists a surjective bounded morphism from
F to
G.
(ii)
G is isomorphic to a subframe of
F that contains a maximal point of
F.
Proof. First suppose that
f is a surjective bounded morphism from
F to
G. Let
w
max be a maximal point in
F, and let
c
W consist of
w
max together with exactly
one maximal world in
f
 1
[v
] for every point
v of
G such that
v
6=
f
(w
max
). Then
b
F
=
F

c
W is the subframe we want.
Conversely, suppose that
c
W is a subset of the points in
F, such that
c
W contains
a maximal point
w
max, and
F

c
W is isomorphic to
G. We claim that the following
deﬁnes a bounded morphism from
F onto
F

c
W:
f
(w
)
=
w, for
w
c
W; and if
w
c
W, then
f
(w
) is a minimal world
b
w
c
W such that
R
w
b
w (that is, for any
w
0, if
R
w
w
0 then
R
b
w
w
0). Note that such a minimal world must always exist, since
w
max
c
W, thus
f is well deﬁned. (In short,
f maps ‘missing points’ to succes-
sors that are as close as possible. We used the same idea to deﬁne the bounded
morphism in the proof of Bull’s Theorem.) Clearly
f is surjective. So suppose



6.6 NP
R
w
w
0. Since
R
w
f
(w
) and
R is transitive, we have
R
w
f
(w
). By deﬁnition,
f
(w
) is a minimal element in
c
W such that
R
w
f
(w
), thus
R
f
(w
)f
(w
) and
f sat-
isﬁes the forth condition on bounded morphisms. Finally, suppose
R
f
(w
)f
(w
).
As
R
w
f
(w
), by the transitivity of
R we have
R
w
f
(w
). Since
f
(f
(w
))
=
f
(w
),
the back condition for bounded morphisms is also satisﬁed and we have shown that
F

c
W is a bounded morphic image of
F. As
F

c
W is isomorphic to
G,
G is a
bounded morphic image of
F as well.
a
We now show that any normal modal logic extending S4.3 has the polysize model
property.
Lemma 6.40 Let
 be a normal modal logic such that
S4:3

. Any formula

that is satisﬁable on a frame for
 is satisﬁable on a frame for
 that contains at
most
m
+
2 states, where
m is the number of occurrences of modal operators in
.
Proof. Suppose
 is satisﬁable on a frame for
. By Bull’s Theorem,
 has the
ﬁnite frame property, thus there is a ﬁnite model based on a
-frame that satisﬁes
 at some point
w
0. Let
M be the submodel of this model that is generated by
w
0. Clearly
M;
w

, and as formation of generated submodels preserves modal
validity,
M is based on a frame for
.
Now we select points. Let
3 
;
:
:
:
;
3 
k be all the
3-subformulas of
 that are
satisﬁed at
w
0. For each

i

k, select a point
w
i that is maximal with respect
to the property of satisfying
 
i. These are the points needed to ensure that
 is
satisﬁed in the polysize model at
w
0, but if we select only
w
0 and these points, we
have no guarantee that we have constructed a
-frame. However, as we will now
see, we can guarantee this if we glue on a maximal point. So, let
w
k
+1 be such a
point and deﬁne
c
M
:=
M

fw
;
w
;
:
:
:
;
w
k
;
w
k
+1
g:
c
M contains at most
m
+
2 points, where
m is the number of modal operators in
.
Moreover, it is based on a
-frame. To see this, note that the frame underlying
c
M
is a subframe of the frame underlying
M that satisﬁes the requirements of item (ii)
of Lemma 6.39; hence there is a surjective bounded morphism from
M to
c
M. Such
morphisms preserve modal validity, thus as
M is a
-model, so is
c
M.
It remains to ensure that
c
M
;
w

. We prove by induction that for all subfor-
mulas
 of
, and all
i such that

i

k, that
M;
w
i

 iff
c
M;
w
i

 
:
The only interesting step is for formulas of the form
3 . Suppose that
M;
w
i

3 (thus
 
=
 
j for some

j

k). Since
M is point-generated by
w
and transitive, it follows that
R
w
w
i, hence
M;
w

3 . We chose
w
j to be a
world maximal with respect to the property of satisfying
 
j, hence
R
w
i
w
j. By the



6 Computability and Complexity
induction hypothesis,
c
M
;
w
j

 
j. Hence
c
M
;
w
i

3 . The converse implication
is left to the reader.
a
Theorem 6.41 (Hemaspaandra’s Theorem) Every normal modal logic extend-
ing
S4:3 has an NP-complete satisﬁability problem.
Proof. Lemma 6.40 established the polysize model property for
, so it remains to
check that membership for
-frames can be decided in polynomial time. How can
we show this? Recall Theorem 4.103:
For every normal modal logic
 extending S4.3 there is a ﬁnite set
N of ﬁnite
S4.3 frames with the following property: for any ﬁnite frame
F,
F

 iff
F
is an S4.3 frame and there does not exist a bounded morphism from
F onto
any frame in
N.
This gives us a possible strategy: given any frame
F, check whether it is an S4.3
frame, and whether there is a surjective bounded morphism onto any frame in N.
Now, as S4.3 frames are ﬁrst-order deﬁnable, by Lemma 6.36 the ﬁrst part can be
performed in polynomial time. But what about the second? First, note that because
N is a ﬁxed ﬁnite set, we need only ensure that the task of checking whether there
is a bounded morphism from
F to a ﬁxed frame
G can be performed in polynomial
time. But the naive strategy of examining all the functions from
F to
G is com-
pletely unsuitable: the number of such functions is
jGj
jFj, which is exponential in
the size of
F. However, applying Lemma 6.39, we see that the task can be sim-
pliﬁed: we only need to check whether there is a set
c
W of worlds in
F such that
F

c
W is isomorphic to
G and
c
W contains a maximal world. Thus we need to
check less than
jFj
jGj embeddings. But this number is polynomial in the size of
F,
for
G is ﬁxed. By Lemma 6.35, NP-completeness follows.
a
The results of this section tell us something about the complexity of validity prob-
lems. The complement of NP is called co-NP. As a formula
 is not
-satisﬁable iff
: is
-valid, it follows that an NP-completeness result for
-satisﬁability tells us
that
-validity is co-NP complete (see Section C for further discussion). It is stan-
dardly conjectured that NP
6= co-NP, thus the validity and satisﬁability problems
for these logics probably have different complexities.
Exercises for Section 6.6
6.6.1 Prove Lemma 6.36. That is, show that if F is a class of frames deﬁnable by a ﬁrst-
order sentence, then the problem of deciding whether
F belongs to F is decidable in time
polynomial in the size of
F.
6.6.2 Explain why the argument given in the proof of Lemma 6.35 may break down when
we lift the restriction to ﬁnite similarity types. In particular, examine the situation when
the similarity type contains modal operators of arbitrarily high arities.



6.7 PSPACE
6.6.3 Extend the proof of Theorem 6.38 to show that
K
t
Q has the polysize model prop-
erty, and is NP-complete.
6.6.4 Use a selection of points argument to show that S5 has the polysize model property,
and is NP-complete.
6.6.5 Show that if we restrict attention to a ﬁxed ﬁnite set of proposition letters
, then the
satisﬁability problem for S5 is decidable in linear time.
(Hint: if
 is ﬁnite, the number of models we have to check to determine whether a given
formula
 is satisﬁed in them, is independent of
.)
6.7 PSPACE
PSPACE, the class of problems solvable by a deterministic Turing machine us-
ing only polynomial space, is the complexity class of most relevance to the basic
modal language. As we will see, some important modal satisﬁability problems
belong to PSPACE, and many modal logics have PSPACE-hard satisﬁability prob-
lems. This suggests that modal satisﬁability problems are typically tougher than
the satisﬁability problem for propositional calculus, for it is standardly conjectured
that PSPACE-hard problems are not solvable in NP.
The work of this section revolves around trees. We ﬁrst show that K lacks the
polysize model property by forcing the existence of binary-tree-based models using
short formulas. We then take a closer look at K-satisﬁability and show that it is in
PSPACE. The proof also shows that every K-satisﬁable formula is satisﬁable on
a tree-based model of polynomial depth. We then put all this work together to
prove Ladner’s theorem: every normal logic between K and S4 has a PSPACE-
hard satisﬁability problem.
Forcing binary trees
The NP-completeness results of the previous section were proved using polysize
model property arguments. So, before going any further, we will show that K does
not have the polysize model property. We do so by showing that K can force the
existence of binary trees. Many of the ideas introduced here will be reused in the
proof of Ladner’s theorem.
For any natural number
m, we are going to devise a satisﬁable formula

B
(m)
with the following properties:
(i) the size of

B
(m) is polynomial (indeed, quadratic) in
m, but
(ii) when

B is satisﬁed in any model
M at a node
w
0, then the submodel of
M generated by
w
0 contains an isomorphic copy of the binary tree of depth
m.



6 Computability and Complexity
(i)
q
(ii)
(m)
(q
i
!
V
i6=j
:q
j
)
(0

i

m)
(iii)
B
^
2B
^
B
^
B
^



^
m 1
B
m 1
(iv)
2S
(p
;
:p
)
^
S
(p
;
:p
)
^
S
(p
;
:p
)
^



^
m 1
S
(p
;
:p
)
^
S
(p
;
:p
)
^
S
(p
;
:p
)
^



^
m 1
S
(p
;
:p
)
^
S
(p
;
:p
)
^



^
m 1
S
(p
;
:p
)
...
^
m 1
S
(p
m 1
;
:p
m 1
)
Fig. 6.5. The formula

B
(m).
As the binary branching tree of depth
m contains
m nodes, the size of the smallest
satisfying model of

B
(m) is exponential in
j
B
(m)j. Thus we will have shown
that small formulas can force the existence of large models.
We will deﬁne these formulas by mimicking truth tables. For any natural number
m,

B
(m) will be constructed out of the following variables:
q
1, . . . ,
q
m, and
p
1,
. . . ,
p
m. The
q
i play a supporting role. They will be used to mark the level (or
depth) in the model; that is, they will mark the number of upward steps that need to
be taken to reach the satisfying node. But any satisfying model for

B
(m) will give
rise to a full truth table for
p
;
:
:
:
;
p
m: every possible combination of truth values
for
p
;
:
:
:
;
p
m will be realized at some node, and hence any model for

B
(m) must
contain at least
m nodes.
That’s the basic idea.
To carry it out, we ﬁrst deﬁne two macros:
B
i, and
S
(p
i
;
:p
i
). For
i
=
0;
:
:
:
;
m
 1,
B
i is deﬁned as follows:
B
i
:=
q
i
!
(
3(q
i+1
^
p
i+1
)
^
3(q
i+1
^
:p
i+1
))
:
(6.12)
Given that we are going to use the
q
is to mark the levels, the effect of
B
i should be
clear: it will force a branching to occur at level
i, set the value of
p
i+1 to true at
one successor at level
i
+
1, and set
p
i+1 to false at another.
Our other macro is closely related. For
i
=
0;
:
:
:
;
m
 1,
S
(p
i
;
:p
i
) is deﬁned
as follows:
S
(p
i
;
:p
i
)
:=
(p
i
!
2p
i
)
^
(:p
i
!
2:p
i
):
(6.13)
This formula sends the truth values assigned to
p
i and its negation one level down.
The idea is that once
B
i has forced a branching in the model by creating a
p
i+1
and a
:p
i+1 successor,
S
(p
i+1
;
:p
i+1
) ensures that these newly set truth values
are sent further down the tree; ultimately we want them to reach the leaves.
We are ready to deﬁne

B
(m). It is the conjunction of the formulas listed in
Figure 6.5. Note that

B
(m) has the required effect. The ﬁrst conjunct,
q
0, ensures



6.7 PSPACE
that any node that satisﬁes

B
(m) is marked as having level 0. The effect of (ii) is
to ensure that no two distinct level marking atoms
q
i and
q
j can be true at the same
node (at least, this will be the case all the way out to level
m, which is all we care
about). To see this, recall that
(m)
 is shorthand for

^
2
^

^



^
m
.
Thus our level markers are beginning to work as promised.
But the real work is carried out by (iii) and (iv). Because of the preﬁxed blocks
of
2 modalities, the
B
i macros in (iii) force
m successive levels of branching;
and each such branching ‘splits’ the truth value of one of the
p
is. Then, again
because of the preﬁxed
2 modalities, (iv) uses the
S
(p
i
;
:p
i
) macro to send each
of these newly split truth values all the way down to the
m-th level. In short,
(iii) creates branching, and (iv) preserves it. It is worthwhile sitting down with a
pencil and paper to check the details. If you do, it will become clear that

B
(m) is
satisﬁable, and that any satisfying model for

B
(m) must contain a submodel that
is isomorphic to the binary branching tree of depth
m. It follows that any model of

B
(m) must contain at least
m nodes, as we claimed.
In spite of its appearance,

B
(m) is indeed a small formula. To see this, consider
what happens when we increment
m by 1. The answer is: not much. For example
(iii) simply gains an extra conjunct, becoming
2B
^
B
^
B
^



^
m 1
B
m 1
^
m
B
m
:
Similarly, each row in (iv) gains an extra conjunct (as does the next empty row)
thus we gain a new column containing
m formulas. The biggest change occurs
in (ii). If you write (ii) out in full, you will see that it gains an extra row, and
an extra column, and an extra atomic symbol in each embedded disjunct, and this
means that the
j
B
(m)j will increase is
O
(m
log
m) (that is, slightly faster than
quadratically). This is negligible compared with the explosion in the size of the
smallest satisfying model: this doubles in size every time we increase
m by one.
Theorem 6.42 K lacks the polysize model property.
That is, K lacks a property enjoyed by all the NP-complete logics examined in
the previous section, and there is no obvious way of using NP guess-and-check
algorithms to solve K-satisﬁability. What sort of algorithms will work?
A PSPACE algorithm for K
We will now deﬁne a PSPACE-algorithm called Witness whose successful termi-
nation guarantees the K-satisﬁability of the input. It may seem surprising that we
can do this. After all, we have just seen that there are satisﬁable formulas

B
(m)
whose smallest satisfying model contains
m nodes. What happens if we give

B
(m) as input to Witness? Will it be forced to use an exponential amount of



6 Computability and Complexity
space to determine the satisﬁability of

B
(m)? The answer is: no. Witness will
take an exponential amount of time to terminate on difﬁcult input, but it uses space
efﬁciently. As we will see, if a formula
 is satisﬁable in some model, it is sat-
isﬁable in a tree-based model of polynomial depth. While some formulas require
models with exponentially many nodes, we can always ﬁnd a shallow satisfying
model: the length of each branch is polynomial in
jj. Witness tests for the exis-
tence of shallow models, and does so one branch at a time. It does not need to keep
track of the entire model, and hence can be made to run in PSPACE.
Witness is essentially an abstract tableaux system for K: it explores spaces of
Hintikka sets (see Deﬁnition 6.24). Recall that Hintikka sets need not be satisﬁable,
and that we call satisﬁable Hintikka sets atoms. Witness will take two ﬁnite sets
of formulas
H and
 as input, and determine whether or not
H is an atom over
. It does so by looking at the demands that
H makes and recursively calculating
whether all these demands can be met. The following deﬁnition makes the idea of
a demand precise (compare Deﬁnition 4.62).
Deﬁnition 6.43 Suppose
H is a Hintikka set over
, and
3 
H. Then the
demand that
3 creates in
H (notation:
Dem
(H
;
3 
)) is
f 
g
[
f
j
2
H
g:
We use
H
3 to denote the set of Hintikka sets over Cl(Dem
(H
;
3 
)) that contain
Dem
(H
;
3 
). (Recall that for any set of sentences
, Cl(
) denotes the closure
of
; see Deﬁnition 6.23.)
a
Remark 6.44 Suppose that
A is an atom over
, and that
3 
A. As
A is
satisﬁable, so is
Dem
(A;
3 
). From this it follows that there is at least one atom
in
A
3 that contains
Dem
(A;
3 
). For suppose
M;
w

Dem
(A;
3 
). Let
	
be the set of all formulas satisﬁed in
M at
w. Then
	
\ Cl(Dem
(A;
3 
)) is a an
atom over Cl(Dem
(A;
3 
)) that contains
Dem
(A;
3 
).
Furthermore, as the reader can easily ascertain, for any formula
,
 is satisﬁable
iff there is an atom
A over Cl() that contains
.
a
Deﬁnition 6.45 Suppose
H and
 are ﬁnite sets of formulas such that
H is a
Hintikka set over
. Then
H
 Pow(
) is a witness set generated by
H on
 if
H
H and
(i) if
I
H, then for each
3 
I, there is a
J
I
3 such that
J
H.
(ii) if
J
H and
J
6=
H then for some
n
>
0 there are
I
;
:
:
:
;
I
n
H such
that
H
=
I
0,
J
=
I
n, and for each

i
<
n there is some formula
3 
I
i such that
I
i+1
I
i
3 .
The degree of a ﬁnite set of formulas
 is simply the maximum of the degrees of
the formulas contained in
; that is,
deg
(
)
=
max
fdeg
()
j


g.
a



6.7 PSPACE
For all choices of
H and
, any witness set
H generated by
H on
 must be ﬁnite,
for
H
 Pow
(
), which is a ﬁnite set. Further, observe that if
I
;
J
H and
J
I
3 then the degree of
J is strictly less than that of
I. Moreover, observe that
item (ii) of the previous deﬁnition is essentially a ‘no junk’ condition: if
J belongs
to
H, it is there because it is generated by some other elements of
H, and ultimately
by
H itself.
Lemma 6.46 Suppose that
H and
 are ﬁnite sets of formulas such that
H is a
Hintikka set over
. Then
H is an atom iff there is a witness set generated by
H
on
.
Proof. For the left to right direction we proceed by induction on the degree of
.
Let
deg
(
)
=
0, and suppose
H is an atom. Trivially,
H
=
fH
g is a witness set
generated by
H. For the inductive step, suppose the required result holds for all
pairs
H
0 and

0 such that
H
0 is an atom of

0 and
deg
(
)
<
n. Let
H be an atom
of
 such that
deg
(
)
=
n. Then, as we noted in Remark 6.44, for all
3 
H
there exists at least one atom
I
 in
H
3 . As the degree of Cl(Dem
(H
;
3 
))
<
n,
for all
3 
H, the inductive hypothesis applies and every such atom
I
 generates
a witness set
I
 on Cl(Dem
(H
;
3 
)). Deﬁne
H
=
fH
g
[
[
3 
2H
I
 
:
Clearly
H is a witness set generated by
H on
.
For the right to left direction, we will show that if
H is a witness set on

generated by
H, then
H can be satisﬁed in a model
(F;
V
) where
F is a ﬁnite tree
of depth at most
deg
(H
). This is stronger than the stated result, and later it will
help us understand why K-satisﬁability is solvable in PSPACE. Assume we have
a countably inﬁnite set of new entities
W
=
fw
;
w
;
w
;
w
;
:
:
:
g at our disposal.
We will use (ﬁnitely many) elements of
W to build a model for
H, using a ﬁnitary
version of the step-by-step method discussed in Section 4.6. This model will be a
tree, thus showing once again that K has the tree model property.
Deﬁne
W
=
fw
g,
R
=
?,
f
(w
)
=
H. Suppose
W
n,
R
n and
f
n have been
deﬁned. If for all
w
W
n such that
3 
f
n
(w
) there exists a
w
W
n such that
(i)
 
f
n
(w
) and (ii)
f
n
(w
)
f
n
(w
)
3 , then halt the step-by-step construction.
Otherwise, if there is a
w
W
n such that
3 
f
n
(w
), while for no
w
W
n are
these two conditions satisﬁed, then carry on to stage
n
+
1 and deﬁne:
W
n+1
=
W
n
[
fw
n+1
g;
R
n+1
=
R
n
[
f(w
;
w
n+1
)g;
f
n+1
=
f
n
[
f(w
n+1
;
I
)g;



6 Computability and Complexity
where
I
H is such that
I
f
n
(w
)
3 . Note that because
H is a witness set it
will always be possible to ﬁnd such an
I.
This step-by-step procedure halts after ﬁnitely many steps since each
I
H con-
tains only ﬁnitely many formulas of the form
3 (thus ensuring that the tree we
are constructing is ﬁnitely branching), and whenever
R
n
w
w
0, then
deg
(f
n
(w
))
<
deg
(f
n
(w
)) (thus ensuring that the tree is not only ﬁnite, but shallow: it has
depth at most
deg
(H
)). Let
m be the stage at which it halts, and deﬁne
F to
be
(W
m
;
R
m
). To construct the desired model for
H, it only remains to deﬁne a
suitable valuation
V , and we do this as follows: choose
V to be any function from
 to
P
(W
m
) satisfying
w
V
(p) iff
p
f
m
(w
), for all
p
. Let
M
=
(F;
V
).
Exercise 6.7.1 asks the reader to show that
M;
w

H; an immediate consequence
is that
H is an atom.
a
Two remarks. The above proof shows that every atom is satisﬁable in a shallow
tree-based model — a fact which will prove to be important below. Second, we now
have a syntactic criterion — namely the existence or non-existence of witness sets
— for determining whether a Hintikka set is K-satisﬁable. (In short, we have just
proved a completeness result.) Moreover, the criterion is intuitively computable:
witness sets are simple ﬁnite structures, thus it seems reasonable to expect that we
can algorithmically test for their existence. And indeed we can.
We now deﬁne the Witness algorithm. This takes as input two ﬁnite sets of
formulas
H and
 and returns the value true if and only if there is a witness set
generated by
H on
.
*function
Witness
(H
;

) returns boolean*
begin
if
H is a Hintikka set over

and for each subformula
3 
H there is a set of formulas
I
H
3 such that
Witness
(I
; Cl
(Dem
(H
;
3 
)))
then return true
else return false
end
Note that
Witness is an intuitively acceptable algorithm — and hence (by Church’s
thesis) implementable on a Turing machine. Checking that
H is a Hintikka set
over
 involves ascertaining that
 is closed, and that
H satisﬁes the properties
demanded of Hintikka sets; these tasks involve only simple syntactic checking.
Moreover, both the ‘and for each subformula . . . there is’ clause and the recursive
call to
Witness are clearly computable: the ﬁrst involves search through a ﬁnite
space, while the recursive call performs the same tasks on input of lower degree.
Thus
Witness is indeed an algorithm. Moreover, it is correct: if
H and
 are
ﬁnite sets of formulas, then
Witness
(H
;

) returns true iff
H is Hintikka set over



6.7 PSPACE
 that generates a witness set in
. This follows by induction on the degree of
.
The right to left direction is easy, while the left to right direction is similar to the
proof of Lemma 6.46; see Exercise 6.7.2.
We are now ready for the main result.
Theorem 6.47 K-satisﬁability is in PSPACE.
Proof. It follows from Lemma 6.46 and the correctness of
Witness that for any
formula
,
 is satisﬁable iff there is an
H
 Cl() such that

H and
Witness
(H
; Cl
()) returns the value true. Thus, if we can show that
Witness
can be given a PSPACE implementation, we will have the desired result. We will
implement
Witness on a non-deterministic Turing machine. Given any formula
,
this machine will non-deterministically pick a Hintikka set
H in Cl() that con-
tains
, and run
Witness
(H
; Cl()). It will be easy to show that this machine runs
in non-deterministic PSPACE (that is, NPSPACE). But then it follows by an appeal
to Savitch’s Theorem (PSP
A
CE
=
NPSP
A
CE; see Section C) that the required
PSPACE implementation exists.
So how do we implement
Witness on a non-deterministic Turing machine? The
key points are the following:
(i) All sets of formulas used in the execution of the program are subsets of
Cl(), and we can represent any such subset by using pointers to the con-
nectives and proposition letters in
’s representation: a pointer to a propo-
sitional letter will mean that the letter belongs to the subset, and a pointer to
a connective means that the subformula built using that connective belongs
to it. Thus encoding a subset of Cl() requires only space
O
(jj) (that is,
space of the order of the size of
).
(ii) The ‘and for each subformula
3 
H’ part can be handled by treating
each subformula in turn. As any subformula can be represented using a
pointer to
’s representation, we can cycle through all possible subformu-
las, using only polynomial space, by cycling through these pointers. More-
over, as we are using a non-deterministic Turing machine, the ‘there is a set
of formulas . . . ’ clause can be implemented by making non-deterministic
choices. Note that although
H
3 is a set of sets of formulas, to verify
whether
I belongs to it is a rather trivial task, given the deﬁnition of
H
3 .
(iii) To enable the recursive calls to be made, we implement a stack on our
Turing machine. To perform the recursion, we copy the formula
 onto the
stack and point to propositional variables and connectives to indicate the
subsets of interest.
So, suppose we run
Witness on input
H and
. The crucial point that must be
investigated is whether the recursive calls to
Witness cause a blow-up in space



6 Computability and Complexity
requirements. From items (i), (ii) and (iii) it is clear that at each level of recur-
sion we use space
O
(jj). How long does it take for the recursion to bottom out?
Note that after
deg
() recursive calls,

=
?. That is, the depth of recursion is
bounded by
deg
() and hence by
jj. Thus, when we implement
Witness on a
non-deterministic Turing machine the total amount of space required is
O
(jj
),
hence the algorithm runs in NPSPACE. Thus, by Savitch’s theorem, we conclude
that K-satisﬁability is in PSPACE.
a
The appeal to Savitch’s theorem in the above proof can be avoided:
Witness can
be implemented on a deterministic Turing machine. This involves replacing the
non-deterministic choice used in item (iii) by brute force search through subsets
of Cl() that uses only polynomial space, and the reader is asked to do this in
Exercise 6.7.4. But the above proof illustrates why Savitch’s Theorem is so useful
in practice: by freeing us to think in terms of non-deterministic computations, it
reduces the required bookkeeping to a minimum.
Let us try and pin down the key intuition underlying Theorem 6.47. K lacks
the polysize model property, but in spite of this the K-satisﬁability problems can
be determined in PSPACE. Why? The key lies in the proof of Lemma 6.46 which
showed that every atom is satisﬁable in a shallow ﬁnite tree-based model. Such
models make it easy to visualize the explorations that
Witness makes as it tests
the satisﬁability of
: it just works out what each branch of such a model must
contain. While the size of the entire model may be exponential in
jj it is not
necessary to keep track of all this information. The locally relevant information is
simply the information on each branch — and we know that the tree has depth at
most
deg
()
+
1. In short,
Witness exploits the fact that only shallow tree-based
models are needed to determine K-satisﬁability.
PSPACE algorithms have been devised for a number of well-known logics in-
cluding T, K4 and S4, the temporal counterparts of K, T, K4 and S4, and multi-
modal K, T, K4, S4 and S5. While proofs of these results are essentially reﬁne-
ments of the proof Theorem 6.47, some are rather tricky. The reader who does
Exercise 6.7.3, which asks for a PSPACE algorithm for K4, will ﬁnd out why. In
some cases alternative methods are preferable; see the Notes for pointers.
Ladner’s theorem
We are ready to prove the major result of the section: every normal modal logic
between K and S4 is PSPACE-hard, and hence (assuming PSPACE
6= NP) the
satisﬁability problems for all these logics are tougher than the satisﬁability problem
for propositional logic. We prove this by giving a polynomial time reduction of
the validity problem for prenex quantiﬁed boolean formulas to all these modal



6.7 PSPACE
satisﬁability problems. The reduction boils down to forcing the existence of certain
tree-based models, and we will be able to reuse much of our previous work.
Deﬁnition 6.48 The set of quantiﬁed boolean formulas is the smallest set
X con-
taining all formulas of propositional calculus such that if

X and
p is a proposi-
tion letter, then both
8p
 and
9p

2 S. The quantiﬁers range over the truth values
1 (true) and 0 (false), and a quantiﬁed boolean formula without free variables is
valid if and only if it evaluates to 1.
A quantiﬁed boolean formula is said to be in prenex form if it is of the form
Q
p



Q
m
p
m

(p
;
:
:
:
;
p
m
); here
Q is either
8 or
9, and

(p
;
:
:
:
;
p
m
) is a for-
mula of propositional logic. We will refer to such prenex formulas as QBFs.
a
The problem of deciding whether a QBF containing no free variables is valid is
called the QBF-validity problem, and it is known to be PSPACE-complete.
We are going to deﬁne a polynomial time translation
f
L from QBFs to modal
formulas, and prove that it has the following two properties:
(i) If
 is a QBF-validity, then
f
L
(
) is S4-satisﬁable.
(ii) If
f
L
(
) is K-satisﬁable, then
 is a QBF-validity.
These two properties — together with the known PSPACE-hardness of the QBF-
validity problem — will lead directly to the desired theorem.
Let’s think about what is involved in evaluating a QBF. We start by peeling off
the outermost quantiﬁer. If it is of the form
9p we choose one of the truth values
1 or
0 and substitute for the newly freed occurrences of
p. On the other hand, if it
is of the form
8p we must substitute both
1 and
0 for the newly freed occurrences
of
p. In this fashion, we work our way successively through the preﬁxed list of
quantiﬁers until we reach the matrix, a formula of propositional logic.
Abstractly considered we are generating a tree. This tree consists of the root
node, and then — working inwards along the quantiﬁer string — each existential
quantiﬁer extends it by adding a single branch, and each universal quantiﬁer ex-
tends it by adding two branches. Indeed, we are even generating an annotated tree:
we can label each node with the substitution it records. For example, corresponding
to the QBF
8p9q
(p
$
:q
) we have the following annotated tree:
0=q
1=q
1=p
0=p
   
@
@
@
I
t
t
t
t
t



6 Computability and Complexity
(i)
q
(ii)
(m)
(q
i
!
V
i6=j
:q
j
)
(0

i

m)
(iiia)
(m)
(q
i
!
3q
i+1
)
(0

i
<
m)
(iiib)
V
fijQ
i
=8g
i
B
i
(iv)
2S
(p
;
:p
)
^
S
(p
;
:p
)
^
S
(p
;
:p
)
^



^
m 1
S
(p
;
:p
)
^
S
(p
;
:p
)
^
S
(p
;
:p
)
^



^
m 1
S
(p
;
:p
)
^
S
(p
;
:p
)
^



^
m 1
S
(p
;
:p
)
...
^
m 1
S
(p
m 1
;
:p
m 1
)
(v)
m
(q
m
!

)
Fig. 6.6. The formula
f
L
(
).
The information in such annotated trees — we will call them quantiﬁer trees —
will play a crucial role. For a start, QBF-validity is witnessed by certain quantiﬁer
trees:
 is a QBF-validity if and only if there is a quantiﬁer tree for
 such that the
substitutions it records ensure that the matrix evaluates to
1. Moreover, quantiﬁer
trees give us a bridge between the QBF world and the modal world:
f
L
(
) will be
a modal formula that describes the structure of a quantiﬁer tree evaluating
.
We deﬁne the translation
f
L by modifying the way we forced the existence of
binary trees in the proof of Theorem 6.42, and we will reuse the macros
B
i and
S
(p
;
:p
) deﬁned in (6.12) and (6.13), respectively.
Deﬁnition 6.49 Given any QBF

=
Q
p



Q
m
p
m

(p
;
:
:
:
;
p
m
), choose new
propositional variables
q
;
:
:
:
;
q
m. Then
f
L
(
) is the conjunction of the formulas
displayed in Figure 6.6.
a
The idea underlying
f
L is this: for any QBF
,
f
L
(
) describes the peel-of-
quantiﬁers-and-substitute evaluation process for
. (That is, it describes how we
generate a quantiﬁer tree for
.) Moreover, it does so using ideas we have met
already: note that (i), (ii) and (iv) are exactly the same formulas we used when
forcing the existence of binary trees.
In fact, the major difference between these formulas and our earlier work lies in
the word binary. Here we don’t always want binary branching: we only want it
when we encounter the quantiﬁer
8. Thus, instead of the earlier (iii) which forced
branching all the way down to level
m, we have the pair of formulas (iiia) and
(iiib). (iiia) guarantees that if
q
i is true and
i
<
m then there is a next level
q
i+1;
which simply amounts to saying that if
i
<
m then we have not yet peeled off
all the quantiﬁers and a new level will be necessary. But it does not force binary



6.7 PSPACE
branching. The task of forcing binary branching, when necessary, is left to (iiib).
Note that this formula is simply a selection of conjuncts from our earlier (iii). There
is only one other difference: (v) insists that after
m quantiﬁers have been peeled
off, the propositional matrix
 must be true.
Clearly,
f
L
(
) is polysize in
j
j, thus this translation causes no blowup in space
requirements.
Theorem 6.50 (Ladner’s Theorem) If
 is a normal modal logic such that
K


 S4, then
 has a PSPACE-hard satisﬁability problem. Moreover,
 has a
PSPACE-hard validity problem.
Proof. Fix a modal logic
 with
K


 S4. We are going to prove that
f
L is a
(polynomial time) reduction from the QBF-validity problem to the
-satisﬁability
problem. The crucial step in this proof is summarized in the following two state-
ments:
if
 is a QBF-validity, then
f
L
(
) is satisﬁable on a frame for S4;
(6.14)
and
if
f
L
(
) is satisﬁed in a K-model then
 is a QBF-validity
:
(6.15)
From these two statements the desired result follows immediately. For suppose

is a QBF-validity. Then by (6.14)
f
L
(
) is S4-satisﬁable and hence
-satisﬁable.
Conversely, if
f
L
(
) is
-satisﬁable then it is also K-satisﬁable, and by (6.15)
 is a QBF-validity. Thus
-satisﬁability is PSPACE-hard. That the
-validity
problem is also PSPACE-hard follows immediately from the fact that PSPACE =
co-PSPACE.
It remains to prove (6.14) and (6.15). For (6.14), assume that
 is a QBF-validity.
Generate a quantiﬁer tree witnessing the validity of
; if
 is valid, such a tree
must exist. This tree gives rise to an S4-model for
f
L
(
) as follows. First, take
the transitive and reﬂexive closure of the ‘daughter-of’ relation of the tree; this
gives us the S4-frame we require. Then make the variable
q
i true precisely at the
nodes of level
i;
p
i is to be made true at a node of level
j

i iff the substitution
connected to that node, or its predecessor at level
i returns the value 1 for
p
i. (For
nodes at level
j
<
i it does not matter what truth value we choose for
p
i.) It is
straightforward to check that the formula
f
L
(
) is true in this model at the root of
the tree; see Exercise 6.7.5.
For (6.15), suppose that
 is a QBF of quantiﬁer depth
m, and that
f
L
(
) is
K-satisﬁable. Note that
deg
(f
L
(
))
=
m, hence from the proof of Lemma 6.46
we know that
f
L
(
) holds at the root
r of a tree-based model
M
=
(T
;
R
;
V
) of
depth at most
m. Using clauses (iiia) and (iiib) of the deﬁnition of
f
L
(
), it is
easily veriﬁed that we may cut off branches from this tree such that in the resulting



6 Computability and Complexity
tree, a node at level
i
<
m has either one or two successors. This number is one
iff
Q
i+1
=
9. And if
Q
i+1
=
8, then one of the successors satisﬁes
p
i+1 and the
other one,
:p
i+1. But then this reduced tree model is a quantiﬁer tree witnessing
the validity of
.
a
Among other things, Ladner’s theorem tells us that K, T, K4 and S4 have PSPACE-
hard satisﬁability problems. It follows that the temporal counterparts of K, T, K4
and S4, and multi-modal K, T, K4, and S4, are PSPACE-hard too, for they con-
tain the unimodal satisﬁability problems as a special case. Hence, as PSPACE
algorithms are known for these logics, they all have PSPACE-complete satisﬁabil-
ity problems. As PSPACE
= co-PSPACE, these logics have PSPACE-complete
validity problems too.
Exercises for Section 6.7
6.7.1 Show that in the model
M constructed in the proof of Lemma 6.46,
M;
w

H.
6.7.2 We claimed that Witness is a correct algorithm. That is, if
H and
 are ﬁnite sets of
formulas, then
Witness
(H
;

) returns true iff
H is Hintikka set over
 that generates a
witness set in
. Prove this.
6.7.3 Adapt the Witness algorithm so that it decides K4 satisﬁability correctly. (Hint:
since you can’t consider smaller and smaller Hintikka sets (why not?) make use of lists of
Hintikka sets, rather than the single Hintikka sets used in the proof for K, and show that
the length of such lists can always be kept polynomial.)
6.7.4 Show how to avoid the use of Savitch’s Theorem in the proof of Theorem 6.47. That
is, show that the
Witness function can be implemented on a deterministic Turing machine.
(Hint: implement the ‘and for each subformula ...there is’ clause by cycling through all
possible subsets of Cl(). This cycling process has a simple implementation using only
space
O
(jj): generate all binary strings of length
jj, and decide of each whether or not
it encodes a subset of Cl
().)
6.7.5 Supply the missing details in the proof of Ladner’s Theorem.
6.7.6 Show that the satisﬁability problem for bimodal S5 is PSPACE-hard.
6.7.7 In this exercise we examine the effects of bounding the number of proposition letters
and of restricting the degree of formulas.
(a) Show that for any ﬁxed
k, the satisﬁability problem for K with respect to a language
consisting of all formulas whose degree is at most
k, is NP-complete.
(b) Show that, in contrast, the satisﬁability problem for S4 remains PSPACE-complete
for languages consisting of all formulas of degree at most
k (k

2).
(c) Now suppose that
, the set of proposition letters, is ﬁnite. Show that for any ﬁxed
k, the satisﬁability problems for K and S4 with respect to a language consisting of
all formulas whose degree is at most
k, is decidable in linear time.



