<!-- Source: Blackburn, de Rijke & Venema (2001). Modal Logic. Cambridge University Press. Chapter 7: Extended Modal Logic, §7.4 The Guarded Fragment (pages 448-459). BibKey: Blackburn2001 -->

7.4 The Guarded Fragment
In Chapter 2 we saw that modal languages can be viewed as fragments of ﬁrst-
order logic, and in Chapter 6 we discovered that these fragments have some nice
computational properties. It thus seems natural to try and see how far we can
generalize these properties to larger fragments of ﬁrst-order logic. This will be the
main aim of this section: we will deﬁne and discuss two extensions of the modal
fragment with reasonably nice computational behavior.
In order to isolate such fragments, what properties of the modal fragment of
ﬁrst-order logic should we concentrate on? In particular, what makes modal logic
decidable? If we conﬁne ourselves to the basic modal language, is it perhaps the
fact that the standard translation can be carried out entirely within the two variable
fragment of ﬁrst-order logic (which has a decidable satisﬁability problem)? This
argument immediately breaks down if we consider languages with modal operators
of higher arity: while giving rise to decidable logics as well, these languages have
standard translations that really need more than two variables. But as soon as we
are considering
n-variable fragments of ﬁrst-order logic with
n
>
2, we face an
undecidable satisﬁability problem.
Rather, it seems to be the fact that the modal fragment of ﬁrst-order logic allows
quantiﬁcation only in a very restricted form, as is obvious from the modal clause
in the deﬁnition of the standard translation function:
ST
x
(3)
=
9y
(R
xy
^
ST
y
()):
(7.3)
It is this restricted form of quantiﬁcation which ensures that modal logic is the
bisimulation invariant fragment of ﬁrst-order logic, and bisimulation invariance of
modal truth was critical in the ﬁrst method of proving the ﬁnite model property for
the basic modal language (see Section 2.3). Recall that the starting point of this
method was the observation that modal logic has the tree model property (meaning
that every satisﬁable modal formula is satisﬁable on a tree model), and that bisimu-
lation invariance is pivotal in proving this result. In short, there seems to be a direct
line from the restricted quantiﬁer pattern in (7.3), via bisimulation invariance and
the tree model property, to the ﬁnite model property and decidability.
This provides our ﬁrst search direction: look for ﬁrst-order fragments charac-
terized by restricted quantiﬁcation. It turns out that one can easily relax many
constraints applying to the (basic) modal fragment. For example, we do not have
to conﬁne ourselves to formulas using two variables only, to formulas having pre-
cisely one free variable, or to formulas with predicates of arity at most two. Relax-
ing these constraints naturally leads to the so-called guarded fragment of ﬁrst-order
logic; the idea here is that quantiﬁers may appear only in the following form:
9y
(G(x
;
y
)
^
 
(x;
y
))
(7.4)
in which
G(x
;
y
) is an atomic formula that we will call the guard of the quantiﬁ-



7.4 The Guarded Fragment
cation (or, of the formula). The crucial ingredient that we keep from (7.3) is that
all free variables of
 are also free in the guard
G(x;
y
). And indeed, it can be
shown that the guarded fragment has various nice properties, such as a decidable
satisﬁability problem and the ﬁnite model property.
However, there are some very natural modal-like languages, or alternative but
intuitive interpretations for standard modal languages, that correspond to a decid-
able fragment of ﬁrst-order logic as well, but are not covered by this deﬁnition. For
example, consider the language with the since and until operators: it is straightfor-
ward to turn the truth deﬁnitions for these operators into a standard translation to
ﬁrst-order logic. The interesting clauses are
ST
x
(U
(;
 
))
=
9y
(R
xy
^
ST
y
()
^
8z
((R
xz
^
R
z
y
)
!
ST
z
( 
)));
()
and a similar one for the since operator. We can prove that this kind of clause
takes us outside the guarded fragment of ﬁrst-order logic: the problem concerns
the ‘betweenness conjunct’
8z
((R
xz
^
R
z
y
)
!
ST
z
( 
)) which has a ‘compos-
ite’ guard,
(R
xz
^
R
z
y
). Nevertheless, the language with since and until has a
decidable satisﬁability problem; apparently, some composite guards are admissible
as well.
Examples such as
() lead to extensions of the guarded fragment to fragments
in which one is more liberal in the precise conditions imposed on the guard. One
can be a bit more liberal here because in the ‘direct line’ mentioned earlier there
are some steps that could be skipped on the way. In particular, if we are interested
in decidability rather than the ﬁnite model property, we could just as well settle
for fragments of ﬁrst-order logic to which we may apply the mosaic method of
Section 6.4. Recall that the mosaic method is a way of proving decidability by
‘deconstructing’ a model into a ﬁnite number of ﬁnite pieces, and then using such
ﬁnite toolboxes for constructing models again, models that usually hang together
quite loosely (in a sense to be made precise later). This provides the second di-
rection in our quest: try to ﬁnd fragments of ﬁrst-order logic to which the mosaic
method applies, leading to a loose model property. Implementing this idea one
naturally ﬁnds quantiﬁer restrictions of the form
9y
(
(x
;
y
)
^
 
(x
;
y
))
(7.5)
in which there are constraints on the presence of variables in certain subformulas
of the guard
. For such fragments one may ﬁnd a direct line from the restricted
quantiﬁer pattern in (7.5), via an appropriate notion of bisimulation invariance and
the loose model property, to some ﬁnite mosaic property and decidability.
The particular extension that we discuss in this section is that of the packed
fragment; it ﬁts very nicely in the mosaic approach. On a ﬁrst reading of the
section the reader may choose to skip the parts referring to this packed fragment,
and concentrate on the guarded fragment.



7 Extended Modal Logic
The guarded and the packed fragment
We need some preliminaries. The ﬁrst-order language that we will be working
in is purely relational, with equality; the language contains neither constants nor
function symbols. For a sequence of variables
x
=
x
;
:
:
:
;
x
n, we frequently
write
9x
, which, as usual, has the same meaning as
9x
:
:
:
9x
n
. However,
in this section we view
9x not as an abbreviation, but as a primitive operator. In
particular this means that the subformulas of
9x
 are just
9x
 itself, together with
the subformulas of
. As usual, by writing
(x) we indicate that the free variables
of
 are among
x
;
:
:
:
;
x
n.
Deﬁnition 7.31 We say that a formula
 packs a set of variables
fx
;
:
:
:
;
x
k
g if
(i)
F
r
e
e
()
=
fx
;
:
:
:
;
x
k
g and (ii)
 is a conjunction of formulas of the form
x
i
=
x
j or
R
(x
i
;
:
:
:
;
x
i
n
) or
9y
R
(x
i
;
:
:
:
;
x
i
n
) such that (iii) for every
x
i
6=
x
j,
there is a conjunct in
 in which
x
i and
x
j both occur free.
The packed fragment
PF is deﬁned as the smallest set of ﬁrst order formulas
which contains all atomic formulas and is closed under the boolean connectives
and under packed quantiﬁcation. That is, whenever
 is a packed formula,
 packs
F
r
e
e
(
), and
F
r
e
e
( 
)

F
r
e
e
(
), then
9x
(
^
 
) is packed as well;
 is called
the guard of this formula. The guarded fragment
GF is the subfragment of
PF in
which we only allow guarded quantiﬁcation as displayed in (7.4); that is, packed
quantiﬁcation in which the guard
 is an atomic formula.
PF
n and
GF
n denote the restrictions to
n variables and at most
n-ary predicate
symbols of
PF and
GF, respectively.
a
Examples of guarded formulas are
(i) the standard translation of any modal formula (in any language),
(ii) the standard translation of any formula in the basic temporal language,
(iii) formulas like
8xy
(R
xy
!
R
y
x),
9xy
(R
xy
^
R
y
x
^
(R
xx
_
R
y
y
)), . . .
For an example of a packed formula which is not guarded, consider
9xy
z
((R
xy
^
R
xz
^
R
y
z
)
^
:C
xy
z
). For another example, ﬁrst consider the standard translation
9y
(R
xy
^
P
y
^
8z
((R
xz
^
R
z
y
)
!
Qz
)) of the formula
U
(p;
q
). This formula is
not packed itself, because the guard of the subformula
8z
((R
xz
^
R
z
y
)
!
Qz
))
has no conjunct in which the variables
x and
y occur together. But of course, the
formula is equivalent to
9x
(R
xy
^
P
y
^
8z
((R
xz
^
R
z
y
^
R
xy
)
!
Qz
))
which is packed. It is not hard to convert this example into a proof showing that
every formula in the since and until language is equivalent to a packed formula.
Second, note that the notion of packedness only places meaningful restrictions
on pairs of distinct variables: since the formula
x
=
x packs the set of variables



7.4 The Guarded Fragment
fxg, the formula
9x(x
=
x
^
 
(x)), (that is, with a single quantiﬁcation over the
variable
x) is a packed formula, at least, provided that
 
(x) is packed. Since the
given formula is equivalent to
9x
 
(x) this shows that packedness allows a fairly
mild form of ordinary quantiﬁcation, namely over formulas with one free variable
only. A nice corollary of this is that we may perform the standard translation of the
global diamond
E within the two variable guarded fragment:
ST
x
(E)
=
ST
y
(E)
=
9x
(ST
x
())

9x
(x
=
x
^
ST
x
()):
Finally, not all formulas are packed, or equivalent to a packed formula. For exam-
ple, the transitivity formula
8y
z
((R
xy
^
R
y
z
)
!
R
xz
) is not packed, and neither
is the standard translation of the difference operator:
9y
(x
6=
y
^
P
y
).
Nice properties
Having deﬁned the packed and the guarded fragment of ﬁrst-order logic, let us
see now what we can prove about these fragments. To start with, for each of the
two fragments we can ﬁnd a suitable notion of bisimulation which characterizes
the fragment in the same way as the ordinary bisimulation characterizes the modal
fragment of ﬁrst-order logic. Unfortunately we do not have the space to go into
detail here. Nevertheless, we will show that both fragments have what we call the
loose model property: in Theorem 7.33 we will show that every satisﬁable packed
formula can be satisﬁed on a loose model. What, then, is a loose model?
Deﬁnition 7.32 Let
A
=
(A;
I
) be a ﬁrst-order structure. A tuple
(a
;
:
:
:
;
a
n
) of
objects in
A is called live in
A if either
a
=



=
a
n or
(a
;
:
:
:
;
a
n
)
I
(P
)
for some predicate symbol
P. A subset
X of
A is called guarded if there is some
live tuple
(a
;
:
:
:
;
a
n
) such that
X

fa
;
:
:
:
;
a
n
g. In particular, singleton sets
are always guarded; note also that guarded sets are always ﬁnite.
X is packed or
pairwise guarded if it is ﬁnite and each of its two-element subsets is guarded.
We say that
A is a loose model of degree
k
N if there is some acyclic connected
graph
G
=
(G;
E
) and a function
f mapping nodes of
G to subsets of
A of size
not exceeding
k such that for every live tuple

s from
A, the set
L(s)
=
fg
G
j
s
i
f
(g
) for all
s
i
g, is a non-empty and connected subset of
G.
a
In words, we call a model
A
=
(A;
I
) loose if we can associate a connected graph
G
=
(G;
E
) with it in the following way. Each node
t of the graph corresponds
to a small subset
f
(t) of the model; a good way of thinking about this is that
t
‘describes’
f
(t). One then requires that the graph ‘covers’ the entire model in the
sense that any
a
A belongs to one of these sets (this follows from the fact that
for any
a
A, the ‘tuple’
a is live). The fact that each set
L(a
) is connected when-
ever
a is live, implies that various nodes of the graph will not give contradictory



7 Extended Modal Logic
descriptions of the model. Finally, the looseness of the model intuitively stems
from the acyclicity of
G and the connectedness of the sets
L(a
); for, this ensures
that in walking through the graph we may describe different parts of the model,
but we never have to worry about returning to the same part once we have left it.
Summarizing, we may see the graph as a loose, coherent collection of descriptions
of local submodels of the model. Loose models are the ones for which we can ﬁnd
such a graph.
The following result states that the packed fragment of ﬁrst-order logic has the
loose model property.
Theorem 7.33 Every satisﬁable packed formula can be satisﬁed on a loose model
(of degree at most the number of
9x subformulas of
).
But the big question is of course whether following this looseness principle we
have indeed arrived at a decidable fragment of ﬁrst-order logic. The next theorem
states that we have.
Theorem 7.34 The satisﬁability problems for the guarded and the packed frag-
ment are decidable; both problems are DEXPTIME-complete (complete for doubly
exponential time). However, for a ﬁxed natural number
n, the satisﬁability problem
for formulas in the packed fragment
PF
n is decidable in EXPTIME.
And ﬁnally, what about the ﬁnite model property? Will every satisﬁable packed
formula have a ﬁnite model? Here as well, the packed fragment displays very nice
behavior. Unfortunately, we do not have the space for a proof of the ﬁnite model
property for the packed fragment — sufﬁce it to say that it involves some quite
advanced techniques from ﬁnite model theory. For some further information the
reader is referred to the Notes at the end of the section.
Mosaics
The remainder of the section is devoted to proving the Theorems 7.34 and 7.33.
The main idea behind the proof is to use the mosaic method that we met in Chap-
ter 6. Roughly speaking, this method is based on the idea of deconstructing mod-
els into a ﬁnite collection of ﬁnite submodels, and conversely, of building up new,
‘loose’, models from such parts. We will see that the packed fragment is in a sense
tailored towards making this idea work.
The proof is structured as follows. We start by formally deﬁning mosaics and
some related concepts. After that we state the main result concerning the mosaic
method, namely the Mosaic Theorem stating that a packed formula is satisﬁable if
and only if there is a so-called linked set of mosaics for it, of bounded size. This



7.4 The Guarded Fragment
equivalence enables us to deﬁne our decision algorithm and establish the com-
plexity upper bounds mentioned in Theorem 7.34. We then continue to prove the
Mosaic Theorem. In doing so we obtain the loose model property for the packed
fragment as a spin-off.
For a formal deﬁnition of the concept of a mosaic we ﬁrst need some syntactic
preliminaries. Given a ﬁrst-order formula
, we let
V
ar
(
) and
F
r
e
e
(
) denote
the sets of variables and free variables occurring in
, respectively. Let
V be a
set of variables. A
V -substitution is any partial map

:
V
!
V . The result of
performing the substitution
 on the formula
 is denoted by
 
. (We can and
may assume that such substitutions can be carried out without increasing the total
number of variables involved; more precisely, we assume that if
V
ar
( 
)

V then
V
ar
( 

)

V .)
As usual, we will employ a notion of closure to delineate a ﬁnite set of relevant
formulas, that is formulas that for some reason critically inﬂuence the truth of a
given formula
. Let the single negation
 of a formula
 denote the formula
 
if
 is of the form
: ; otherwise,
 is the formula
:; we say that a set
 of
formulas is closed under single negations if

 whenever

.
Deﬁnition 7.35 Let
 be a set of packed formulas in the set
V of variables.
We call

V -closed if it is closed under subformulas, single negations and
V -
substitutions (that is, if
 belongs to
, then so does
 
 for every
V -substitution
). With
Cl
g
(
) we denote the smallest
V
ar
(
)-closed set of formulas containing
.
a
For the remainder of this section, we ﬁx a packed formula
 — all deﬁnitions to
come should be understood as being relativized to
. The number of variables oc-
curring in
 (free or bound) is denoted by
k; that is,
k is the size of
V
ar
(
). It
can easily be veriﬁed that the sets of guarded and packed formulas are both closed
under taking subformulas; hence, the set
Cl
g
(
) consists of guarded (packed, re-
spectively) formulas. An easy calculation shows that the cardinality of
Cl
g
(
) is
bounded by
k
k

(2j
j
).
The following notion is the counterpart of the atoms that we have met in earlier
decidability proofs (see Lemma 6.29, for instance). All three deﬁning conditions
are fairly obvious.
Deﬁnition 7.36 Let
X

V
ar
(
) be a set of variables. An
X-type is a set
 
Cl
g
(
) with free variables in
X satisfying, for all formulas

^
 ,

,
 in
Cl
g
(
)
with free variables in
X, the conditions (i)

^
 
  iff

  and
 
 ,
(ii)

  iff


  and (iii) if
;
x
i
=
x
j
  then


  for any substitution
 mapping
x
i to
x
j and/or
x
j to
x
i, while leaving all other variables ﬁxed.
a
The next deﬁnition introduces our key tool in proving the decidability of the packed



7 Extended Modal Logic
fragment: mosaics and linked sets of them. Basically, a mosaic consists of a subset
X of
V
ar
(
) together with a set
  encoding the relevant information on some
small part of a model. Here ‘small’ means that its size is bounded by the number of
objects that can be named using variables in
X, and ‘relevant’ refers to all formulas
in
Cl
g
(
) whose free variables are in
X. It turns out that a ﬁnite set of such mosaics
contains sufﬁcient information to construct a model for
 provided that the set links
the mosaics together in a nice way. Here is a more formal deﬁnition.
Deﬁnition 7.37 A mosaic is a pair
(X
;
 ) such that
X

V
ar
(
) and
 
Cl
g
(
).
A mosaic is coherent if it satisﬁes the following conditions:
(C1)
  is an
X-type,
(C2)
if
 
(x
;
z
) and

(x;
z
) are in
 , then so is
9y
(
(x;
y
)
^
 
(x
;
y
)),
(provided that the latter formula belongs to
Cl
g
(
)).
A link between two mosaics
(X
;
 ) and
(X
;
 0
) is a renaming (that is, an injec-
tive substitution)
 with
dom


X and
range


X
0 which satisﬁes, for all
formulas

Cl
g
(
):

  iff


 0.
A requirement of a mosaic is a formula of the form
9y
(
(x
;
y
)
^
 
(x;
y
)) be-
longing to
 . A mosaic
(X
;
 0
) fulﬁlls the requirement
9y
(
(x;
y
)
^
 
(x;
y
))
of a mosaic
(X
;
 ) via the link
 if for some variables
u,
v in
X
0 we have that

(x)
=
u and

(u
;
v
) and
 
(u
;
v
) belong to
 0. A set
S of mosaics is linked if
every requirement of a mosaic in
s is fulﬁlled via a link to some mosaic in
S.
S is
a linked set of mosaics for
 if it is linked and

  for some
(X
;
 ) in
S.
a
Note that a mosaic
(X
;
 ) may fulﬁll its own requirements, either via the identity
map or via some other map from
X to
X.
The key result concerning mosaics is the following Mosaic Theorem.
Theorem 7.38 (Mosaic Theorem) Let
 be a packed formula. Then
 is satisﬁ-
able if and only if there is a linked set of mosaics for
.
Proof. The hard, right to left, direction of the theorem is treated in Lemma 7.39
below; here we only prove the other direction.
Suppose that
 is satisﬁed in the model
A
=
(A;
I
). In a straightforward way
we can ‘cut out’ from
A a linked set of mosaics for
. Consider the set of partial
assignments of elements in
A to variables in
V
ar
(
). For each such
, let
(X

;
 
)
be the mosaic given by
X

=
dom
 and
 
=
f
Cl
g
(
)
j
A
j
=
[]g:
We leave it to the reader to verify that this collection forms a linked set of mosaics
for
.
a



7.4 The Guarded Fragment
When establishing the hard direction of this proposition we will in fact prove some-
thing stronger: starting from a linked set of mosaics for a formula
 we will show,
via a step by step argument, that there is a loose or tree-like model for
. First
however, we want to show that the Mosaic Theorem is the key towards proving
the decidability of the packed fragment, and also for ﬁnding an upper bound for its
complexity.
The decision algorithm and its complexity
The mosaic theorem tells us that any packed formula
 is satisﬁable if and only if
there is a linked set of mosaics for
. Thus an algorithm answering the question
whether a linked set of mosaics exists for
, also decides whether
 is satisﬁable.
By providing such an algorithm we establish the upper complexity bound for the
satisﬁability problem of the packed fragment.
Recall that
k denotes the number of variables occurring in
. The following
observations are fairly straightforward consequences of our deﬁnitions:
(i) up to isomorphism there are at most
k

2j
jk
k mosaics. Using the big
O
notation, this is at most
O
(j
j)2
k
log
k.
(ii) given sets
X
;
  with
jX
j

k and
 
Cl
g
(
) it is decidable in time
polynomial in
k
k and
j
j whether
(X
;
 ) is a coherent mosaic.
(iii) given a set
X of coherent mosaics and a requirement
(x
) it is decidable in
time polynomial in
jX
j and
j(x
)j whether
X fulﬁlls the requirement
(x).
Using methods similar to the elimination of Hintikka sets that we saw in the de-
cidability proof for propositional dynamic logic (see Section 6.8), we now give an
algorithm which decides the existence of a linked set of mosaics for
. Let
S
0 be
the set of all coherent mosaics. By the observations above,
S
0 contains at most
O
(j
j)2
k
log
k elements and can be constructed in time polynomial in
jS
j. We now
inductively construct a sequence of sets of mosaics
S

S

S

S


. If
every requirement of a mosaic
 in a set
S
i is fulﬁlled we call
 happy. If every
mosaic in
S
i is happy then return ‘there is a linked set of mosaics for
’ if
S
i con-
tains a mosaic
(X
;
 ) with

 , and return ‘there is no linked set of mosaics for
’ otherwise. If, on the other hand,
S
i contains unhappy mosaics, let
S
i+1 consist
of all happy mosaics in
S
i and continue the construction. Since our sets decrease in
size at every step, the construction must halt after at most
jS
j many stages. By the
observations above, computing which states in
S
i are happy can be done in time
polynomial in
 and
jS
i
j. Thus the entire computation can be performed in time
polynomial in
jS
j. Clearly the algorithm is correct.
Hence, if we consider a formula
 in a packed fragment with a ﬁxed number of
variables,
jS
j is exponential in
j
j. In general however, the number of variables
occurring in a formula depends on the formula’s length and hence in general,
jS
j



7 Extended Modal Logic
is doubly exponential in
j
j. Thus, pending the correctness of Lemma 7.39 below,
this establishes the complexity upper bounds in the Theorem 7.34.
Loose models
Finally, we show the hard direction of the Mosaic Theorem; as a spin-off we estab-
lish the ‘loose model property’ mentioned in Theorem 7.33.
Lemma 7.39 Let
 be a packed formula. If there is a linked set of mosaics for
,
then
 is satisﬁable in a loose model of degree
jV
ar
(
)
j.
Proof. Assume that
S is a linked set of mosaics for
. Using a step-by-step con-
struction, we will build a loose model for
, together with an acyclic graph asso-
ciated with the model. At each stage of the construction we will be dealing with
some kind of approximation of the ﬁnal model and tree; these approximations will
be called networks and are slightly involved structures.
A network is a quintuple
(A;
G;
;
;

) such that
A
=
(A;
I
) is a model for
the ﬁrst-order language;
G
=
(G;
E
) is a connected, directed and acyclic graph;

:
G
!
S is a map associating a mosaic

t
=
(X
t
;
 t
) in
S with each node
t of
the graph;
 is a map associating an assignment

t
:
X
t
!
A with each node
t of
the graph; and ﬁnally,
 is a map associating with each edge
(t;
t
) of the graph a
link

tt
0 from

t to

t
0 (we will usually simplify our notation by writing
 instead
of

tt
0).
The idea is that each mosaic

t is meant to give a complete description of the
relevant requirements that we impose on a small part of the model-to-be. Which
part? This is given by the assignment

t. And the word ‘relevant’ refers to the
fact that we are only interested in the formulas inﬂuencing the truth of
; that is,
the formulas in
Cl
g
(
). The links between neighboring mosaics are there to ensure
that distinct mosaics agree on the part of the model that they both have access to.
Now obviously, if we want all of this to work properly we have to impose some
conditions on networks. In order to formulate these, we need some auxiliary no-
tation. For a subset
Q

A, let
L(Q) denote the set of nodes in
G that have
‘access’ to
Q; formally, we deﬁne
L(Q)
=
ft
G
j
A

range
(
t
)g. For a
tuple
a
=
(a
;
:
:
:
;
a
n
) of elements in
A we set
L(a)
=
L(fa
;
:
:
:
;
a
n
g). Now
a network is called coherent if it satisﬁes the following conditions (all to be read
universally quantiﬁed):
(C1)
P
x
 t iff
A
j
=
P
x[
t
],
(C2)
x
i
=
x
j
 t iff

t
(x
i
)
=

t
(x
j
),
(C3)
L(Q) is non-empty for every guarded set
Q

A,
(C4)
L(Q) is connected for every guarded set
Q

A,
(C5)
if
E
tt
0 then

tt
(x)
=
x
0 iff

t
(x)
=

t
(x
).



7.4 The Guarded Fragment
A few words of explanation about these conditions: (C1) and (C2) ensure that ev-
ery mosaic is a complete description of the atomic formulas holding in the part of
the model it refers to. Condition (C3) states that no live tuple of the model remains
unseen from the graph, while the conditions (C4) and (C5) are the crucial ones
making that remote parts of the graph cannot contain contradictory information
about the model — how this works precisely will become clear further on. Note
that condition (C5) has two directions: the left-to-right direction states that neigh-
boring mosaics have common access to part of the model, while the other direction
ensures that they agree on their requirements concerning this common part.
The motivation for using these networks is that in the end we want any formula
(x)
Cl
g
(
) to hold in
A under the assignment

t if and only
(x
) belongs
to
 t. Coherence on its own is not sufﬁcient to make this happen. A defect of
a network consists of a formula
9y
(
(x
;
y
)
^
 
(x
;
y
)) which is a requirement of
the mosaic

t for some node
t while there is no neighboring node
t
0 such that

t
fulﬁlls
9y
(
(x
;
y
)
^
 
(x;
y
)) via the link

tt
0. A coherent network
N is perfect if
it has no defects. We say that
N is a network for
 if for some
t
G,

t
=
(X
t
;
 t
)
is such that

 t.
Claim 1 If
N
=
(A;
G;
;
;

) is a perfect network, then
(i)
A is a loose model of degree
jV
ar
(
)
j, and
(ii) for all formulas
(x
)
Cl
g
(
) and all nodes
t of
G:

 t iff
A
j
=
[
t
].
Proof of Claim. For part (i) of the claim, let
N
=
(A;
G;
;
;

) be the perfect
network for
. Let
A
=
(A;
I
). As the function
f mapping nodes of
G to subsets
of
A, simply take the map that assigns the range of

t to the node
t. Since the
domain of each map

t is always a subset of
V
ar
(
), it follows immediately that
f
(t) will always be a set of size at most
jV
ar
(
)
j. Now take an arbitrary live tuple
s in
A; it follows from (C3) and (C4) that
L(s
) is a non-empty and connected part
of the graph
G. Thus
A is a loose model of degree
jV
ar
(
)
j.
We prove part (ii) of the claim by induction on the complexity of
. For atomic
formulas the claim follows by conditions (C1) and (C2), and the boolean case of
the induction step is straightforward (since
 t is an
X–type) and left to the reader.
We concentrate on the case that
(x) is of the form
9y
(
(x;
y
)
^
 
(x
;
y
)).
First assume that
(x)
 t. Since
N is perfect there is a node
t
0 in
G and
variables
u,
v in
X
t
0 such that
E
tt
0,

(u
;
v
) and
 
(u
;
v
) belong to
 t
0, while the
link
 from

t to

t
0 maps
x to
u. By the induction hypothesis we ﬁnd that
A
j
=

(u
;
v
)
^
 
(u
;
v
)[
t
]:
(7.6)
But from condition (C5) it follows that

t
(x
)
=

t
(u), whence (7.6) implies that
A
j
=
9y
(
(x;
y
)
^
 
(x
;
y
))[
t
];



7 Extended Modal Logic
which is what we were after.
Now suppose, in order to prove the converse direction, that
A
j
=
(x
)[
t
]. Let
a
denote

t
(x), then there are
b in
A such that
A
j
=

(x
;
y
)[a
b] and
A
j
=
 
(x;
y
)[ab].
Our ﬁrst aims are to prove that
L(a
b)
6=
?;
(7.7)
and
L(Q) is connected for every
Q

fa
;
bg:
(7.8)
Note that if we are working in the guarded fragment, then

(x;
y
) is an atomic
formula, whence it follows from
A
j
=

(x;
y
)[a
b] that
ab is live. Thus
fa;
b
g is
guarded, and hence (7.7) is immediate by condition (C3). In fact, every
Q

fa;
b
g
is guarded in this case, so (7.8) is immediate by condition (C4).
In the more general case of the packed fragment we have to work a bit harder.
First, observe that it does follow from
A
j
=

(x;
y
)[a
b] and the conditions on

(x;
y
) in the deﬁnition of packed quantiﬁcation, that
fc;
dg is guarded, and thus,
L(c;
d)
6=
?, for every pair
(c;
d) of points taken from
ab. It follows from (C4) that
fL(c;
d)
j
c;
d taken from
abg is a collection of non-empty, connected, pairwise
overlapping subgraphs of the acyclic graph
G. It is fairly straightforward to prove,
for instance, by induction on the size of the graph
G, that any such collection must
have a non-empty intersection. From this, (7.7) and (7.8) are almost immediate.
Thus, we may assume the existence of a node
t
0 in
G such that
fa
;
bg

range

t
0.
Let
u and
v in
X
t
0 be the variables such that

t
(u)
=
a and

t
(v
)
=
b. The
induction hypothesis implies that

(u;
v
) and
 
(u
;
v
) belong to
 t
0, whence
(u)
 t
0 by coherence of

t
0. Since both
t and
t
0 belong to
L(a), it follows from (7.8)
that there is a path from
t to
t
0 within
L(a), say
t
=
s
E
s
E
:
:
:
E
s
n
=
t. Let

i
be the link between the mosaics of
s
i and
s
i+1, and deﬁne
 to be the composition
of these maps. It follows by an easy inductive argument on the length of the path
that
 is a link between

t
0 and

t such that
(u
)
=
x. Hence, by deﬁnition of a
link we have that
(x)
 t
0.
a
By Claim 1, in order to prove the Lemma it sufﬁces to construct a perfect network
for
. This construction uses a step-by-step argument; to start the construction we
need some coherent network for
.
Claim 2 There is a coherent network for
.
Proof of Claim. By our assumption on
 there is a coherent mosaic

=
(X
;
 )
such that

 . Without loss of generality we may assume that
X is the set
fx
;
:
:
:
;
x
n
g (otherwise, take an isomorphic copy of
 in which
X does have this
form). Let
a
;
:
:
:
;
a
n be a list of objects such that for all
i and
j we have that
a
i
=
a
j if and only if the formula
x
i
=
x
j belongs to
 . Deﬁne
A
=
fa
;
:
:
:
;
a
n
g



7.4 The Guarded Fragment
and put the tuple
(a
i
;
:
:
:
;
a
i
k
) in the interpretation
I
(P
) of the
k-ary predicate
symbol
P precisely if
P
x
i
:
:
:
x
i
n
 . Let
A be the resulting model
(A;
I
) and
deﬁne
G as the trivial graph with one node
0 and no edges. Let
(0) be the mosaic
;

:
X
!
A is given by
(x
i
)
=
a
i; and ﬁnally,

00 is the identity map from
X to
X.
We leave it to the reader to verify that the quintuple
(A;
G;
;
;

) is a coherent
network for
.
a
The crucial step of this construction will be to show that any defect of a coherent
network can be repaired.
Claim 3 For any coherent network
N
=
(A;
G;
;
;

) and any defect of
N there
is a coherent network
N
+ extending
N and lacking this defect.
Proof of Claim. Suppose that
(x) is a defect of
N because it is a requirement of
the mosaic

t and not fulﬁlled by any neighboring mosaic

t
0. We will deﬁne an
extension
N
+ of
N in which this defect is repaired.
Since
S is a linked set of mosaics and

t belongs to
S,

t is linked to a mosaic
(X
;
 0
)
S in which the requirement is fulﬁlled via some link
. Let
Y be
the set of variables in
X
0 that do not belong to the range of
; suppose that
Y
=
fy
;
:
:
:
;
y
k
g (with all
y
i being distinct). For the sake of a smooth presentation,
assume that
 0 contains the formulas
:x
=
y for all variables
x
X
0 and
y
Y
(this is not without loss of generality — we leave the general case as an exercise
to the reader). Take a set
fc
;
:
:
:
;
c
k
g of fresh objects (that is, no
c
i is an element
of the domain
A of
A), and let
 be the assignment with domain
X
0 deﬁned as
follows:

(x
)
=


t
(x)
if
x
=
(x);
c
i
if
x
=
y
i
;
and let
t
0 be an object not belonging to
G. Now deﬁne the network
N
+
=
(A
+,
G
+,

+
;

+
;

+
) as follows:
A
+
=
A
[
fc
;
:
:
:
;
c
k
g;
I
+
(P
)
=
I
(P
)
[
fd
j for some
x,
d
=

(x) and
P
x
 0
g;
G
+
=
G
[
ft
g;
E
+
=
E
[
f(t;
t
)g;
while

+,

+ and

+ are given as the obvious extensions of
,
 and
, namely
by putting

+
t
=
(X
;
 0
),

+
t
=
 and

tt
=
.
Since the interpretation
I
+ agrees with
I on ‘old’ tuples it is a straightforward
exercise to verify that the new network
N
+ satisﬁes the conditions (C1)–(C3) and
(C5).
In order to check that condition (C4) holds, take some guarded subset
Q from



7 Extended Modal Logic
A
+; we will show that
L
+
(Q) is a connected subgraph of
G
+. It is rather easy
to see that
L
+
(Q) is identical to either
L(Q) or
L(Q)
[
ft
g; hence by the con-
nectedness of
L(Q) it sufﬁces to prove, on the assumptions that
t
L
+
(Q) and
L(Q)
6=
?, that
t
L(Q). Hence, suppose that
t
L
+
(Q); that is, each
a
Q
is in the range of
. But if
L(Q)
6=
?, each such point
a must be old; hence, by
deﬁnition of
, each
a
Q must belong to
range

t. This gives that
t
L(Q), as
required.
a
As in our earlier step-by-step proofs, the previous two claims show that using some
standard combinatorics we can construct a chain of networks such that their limit
is a perfect network. This completes the proof of the lemma.
a
Exercises for Section 7.4
7.4.1 In the loosely guarded fragment the following quantiﬁcation patterns are allowed:
9x(
(x
;
y
)
^
 
(x
;
y
)) is a loosely guarded formula if
 
(x
;
y
) is loosely guarded,

(x
;
y
)
is a conjunction as in the packed fragment, and any pair
z,
z
0 of distinct variables from
x
y
occurs free in some conjunct of the guard
, unless
z and
z
0 are both from
y. For example,
9x
((R
y
x
^
R
xy
)
^
:C
xy
y
) is loosely guarded, but not packed since there is no conjunct
having both
y and
y
0 free.
Show that for every loosely guarded sentence
 there exists an equivalent packed sen-
tence

0 in the same language.
7.4.2 Deﬁne the universal packed fragment as the fragment of ﬁrst-order logic that is gen-
erated from atoms, negated atoms, conjunction, disjunction, ordinary existential quantiﬁ-
cation, and packed universal quantiﬁcation. (With the latter we mean that
8x
(
!
 
) is
in the fragment if
 is universally packed,
 packs its own free variables, and
F
r
e
e
( 
)

F
r
e
e
(
).)
Show that satisﬁability is decidable for the universal packed fragment.
7.4.3 Fix a natural number
n, and suppose that we are working in an
n-bounded ﬁrst-order
signature; that is, all predicate symbols have arity at most
n. Prove that in such a signature,
every guarded sentence is equivalent to a guarded sentence using at most
n variables. Does
this hold for packed sentences as well? What are the consequences for the complexity of
the respective satisﬁability problems?
7.4.4 Let
 be a packed formula, and suppose that
 is satisﬁable. Prove that
 is satisﬁable
in a loose model with an associated graph
G of which the out-degree is bounded by some
recursive function on
. In particular, this out-degree should be ﬁnite. (The out-degree of
a node
k of a graph
(G;
E
) is deﬁned as the number of its neighbors, or, formally, as the
size of the set
fk
G
j
k
E
k
g; the out-degree of a graph is deﬁned as the supremum of
the out-degrees of the individual nodes.)
