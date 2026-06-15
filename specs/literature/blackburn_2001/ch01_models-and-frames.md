<!-- Source: Blackburn, de Rijke & Venema (2001). Modal Logic. Cambridge University Press. Chapter 1: Basic Concepts, §1.3 Models and Frames (pages 16-26). BibKey: Blackburn2001 -->

1.3 Models and Frames
Although our discussion has contained many semantically suggestive phrases such
as ‘true’ and ‘intended interpretation’, as yet we have given them no mathemat-
ical content. The purpose of this (key) section is to put that right. We do so by
interpreting our modal languages in relational structures. In fact, by the end of the
section we will have done this in two distinct ways: at the level of models and at
the level of frames. Both levels are important, though in different ways. The level
of models is important because this is where the fundamental notion of satisfaction
(or truth) is deﬁned. The level of frames is important because it supports the key
logical notion of validity.
Models and satisfaction
We start by deﬁning frames, models, and the satisfaction relation for the basic
modal language.
Deﬁnition 1.19 A frame for the basic modal language is a pair
F
=
(W
;
R
) such
that
(i)
W is a non-empty set.
(ii)
R is a binary relation on
W.



1.3 Models and Frames
That is, a frame for the basic modal language is simply a relational structure bearing
a single binary relation. We remind the reader that we refer to the elements of
W
by many different names (see Deﬁnition 1.1).
A model for the basic modal language is a pair
M
=
(F;
V
), where
F is a frame
for the basic modal language, and
V is a function assigning to each proposition
letter
p in
 a subset
V
(p) of
W. Informally we think of
V
(p) as the set of points
in our model where
p is true. The function
V is called a valuation. Given a model
M
=
(F;
V
), we say that
M is based on the frame
F, or that
F is the frame
underlying
M.
a
Note that models for the basic modal language can be viewed as relational struc-
tures in a natural way, namely as structures of the form:
(W
;
R
;
V
(p);
V
(q
);
V
(r
);
:
:
:
):
That is, a model is a relational structure consisting of a domain, a single binary
relation
R, and the unary relations given to us by
V . Thus, viewed from a purely
structural perspective, a frame
F and a model
M based on
F, are simply two re-
lational models based on the same universe; indeed, a model is simply a frame
enriched by a collection of unary relations.
But in spite of their mathematical kinship, frames and models are used very dif-
ferently. Frames are essentially mathematical pictures of ontologies that we ﬁnd
interesting. For example, we may view time as a collection of points ordered by
a strict partial order, or feel that a correct analysis of knowledge requires that we
postulate the existence of situations linked by a relation of ‘being an epistemic
alternative to.’ In short, we use the level of frames to make our fundamental as-
sumptions mathematically precise.
The unary relations provided by valuations, on the other hand, are there to dress
our frames with contingent information. Is it raining on Tuesday or not? Is the
system write-enabled at time
t
6? Is a situation where Janet does not love him an
epistemic alternative for John? Such information is important, and we certainly
need to be able to work with it — nonetheless, statements only deserve the de-
scription ‘logical’ if they are invariant under changes of contingent information.
Because we have drawn a distinction between the fundamental information given
by frames, and the additional descriptive content provided by models, it will be
straightforward to deﬁne a modally reasonable notion of validity.
But this is jumping ahead. First we must learn how to interpret the basic modal
language in models. This we do by means of the following satisfaction deﬁnition.
Deﬁnition 1.20 Suppose
w is a state in a model
M
=
(W
;
R
;
V
). Then we induc-
tively deﬁne the notion of a formula
 being satisﬁed (or true) in
M at state
w as



1 Basic Concepts
follows:
M;
w

p
iff
w
V
(p); where
p

M;
w
?
never
M;
w

:
iff
not
M;
w


M;
w


_
 
iff
M;
w

 or
M;
w

 
M;
w

3
iff
for some
v
W with
R
w
v we have
M;
v

: (1.4)
It follows from this deﬁnition that
M;
w

2 if and only if for all
v
W such
that
R
w
v, we have
M;
v

. Finally, we say that a set
 of formulas is true at a
state
w of a model
M, notation:
M;
w

, if all members of
 are true at
w.
a
Note that this notion of satisfaction is intrinsically internal and local. We evaluate
formulas inside models, at some particular state
w (the current state). Moreover,
3 works locally: the ﬁnal clause (1.4) treats
3 as an instruction to scan states
in search of one where
 is satisﬁed. Crucially, only states
R-accessible from the
current one can be scanned by our operators. Much of the characteristic ﬂavor of
modal logic springs from the perspective on relational structures embodied in the
satisfaction deﬁnition.
If
M does not satisfy
 at
w we often write
M;
w
6
, and say that
 is false or
refuted at
w. When
M is clear from the context, we write
w

 for
M;
w

 and
w
6
 for
M;
w
6
. It is convenient to extend the valuation
V from proposition
letters to arbitrary formulas so that
V
() always denotes the set of states at which
 is true:
V
()
:=
fw
j
M;
w

g:
Deﬁnition 1.21 A formula
 is globally or universally true in a model
M (nota-
tion:
M

) if it is satisﬁed at all points in
M (that is, if
M;
w

, for all
w
W). A formula
 is satisﬁable in a model
M if there is some state in
M at
which
 is true; a formula is falsiﬁable or refutable in a model if its negation is
satisﬁable.
A set
 of formulas is globally true (satisﬁable, respectively) in a model
M if
M;
w

 for all states
w in
M (some state
w in
M, respectively).
a
Example 1.22 (i) Consider the frame
F
=
(fw
1,
w
2,
w
3,
w
4,
w
g,
R
), where
R
w
i
w
j iff
j
=
i
+
1:
s
w
-
s
w
-
s
w
-
s
w
-
s
w
If we choose a valuation
V on
F such that
V
(p)
=
fw
;
w
g,
V
(q
)
=
fw
1,
w
2,
w
3,
w
4,
w
g, and
V
(r
)
=
?, then in the model
M
=
(F;
V
) we have that
M;
w




1.3 Models and Frames
3p,
M;
w
6
3p
!
p,
M;
w

3(p
^
:r
), and
M;
w

q
^
3(q
^
3(q
^
3(q
^
3q
))).
Furthermore,
M

2q. Now, it is clear that
2q is true at
w
1,
w
2,
w
3 and
w
4, but
why is it true at
w
5? Well, as
w
5 has no successors at all (we often call such points
‘dead ends’ or ‘blind states’) it is vacuously true that
q is true at all
R-successors
of
w
5. Indeed, any ‘boxed’ formula
2 is true at any dead end in any model.
(ii) As a second example, let
F be the SPO given in Figure 1.1, where
W
=
f1,
2,
3,
4,
6,
8,
12,
24g and
R
xy means ‘x and
y are different, and
y can be divided
by
x.’ Choose a valuation
V on this frame such that
V
(p)
=
f4;
8;
12;
24g, and
V
(q
)
=
f6g, and let
M
=
(F;
V
). Then
M;

2p,
M;

2p,
M;
6
2p, and
M;

3(q
^
2p)
^
3(:q
^
2p):
(iii) Whereas a diamond
3 corresponds to making a single
R-step in a model,
stacking diamonds one in front of the other corresponds to making a sequence
of
R-steps through the model. The following deﬁned operators will sometimes
be useful: we write
n
 for
 preceded by
n occurrences of
3, and
n
 for

preceded by
n occurrences of
2. If we like, we can associate each of these deﬁned
operators with its own accessibility relation. We do so inductively:
R
xy is deﬁned
to hold if
x
=
y, and
R
n+1
xy is deﬁned to hold if
9z
(R
xz
^
R
n
z
y
). Under this
deﬁnition, for any model
M and state
w in
M we have
M;
w

n
 iff there exists
a
v such that
R
n
w
v and
M;
v

.
(iv) The use of the word ‘world’ (or ‘possible world’) for the entities in
W
derives from the reading of the basic modal language in which
3 is taken to mean
‘possibly
,’ and
2 to mean ‘necessarily
.’ Given this reading, the machinery of
frames, models, and satisfaction which we have deﬁned is essentially an attempt to
capture mathematically the view (often attributed to Leibniz) that necessity means
truth in all possible worlds, and that possibility means truth in some possible world.
The satisfaction deﬁnition stipulates that
3 and
2 check for truth not at all possi-
ble worlds (that is, at all elements of
W) but only at
R-accessible possible worlds.
At ﬁrst sight this may seem a weakness of the satisfaction deﬁnition — but in fact,
it’s its greatest source of strength. The point is this: varying
R is a mechanism
which gives us a ﬁrm mathematical grip on the pre-theoretical notion of access be-
tween possible worlds. For example, by stipulating that
R
=
W

W we can allow
all worlds access to each other; this corresponds to the Leibnizian idea in its purest
form. Going to the other extreme, we might stipulate that no world has access to
any other. Between these extremes there is a wide range of options to explore.
Should interworld access be reﬂexive? Should it be transitive? What impact do
these choices have on the notions of necessity and possibility? For example, if we
demand symmetry, does this justify certain principles, or rule others out?
(v) Recall from Example 1.10 that in epistemic logic
2 is written as
K and
K

is interpreted as ‘the agent knows that
.’ Under this interpretation, the intuitive
reading for the semantic clause governing
K is: the agent knows
 in a situation



1 Basic Concepts
w (that is,
w

K
) iff
 is true in all situations
v that are compatible with her
knowledge (that is, if
v

 for all
v such that
R
w
v). Thus, under this interpre-
tation,
W is to be thought of as a collection of situations,
R is a relation which
models the idea of one situation being epistemically accessible from another, and
V governs the distribution of primitive information across situations.
a
We now deﬁne frames, models and satisfaction for modal languages of arbitrary
similarity type.
Deﬁnition 1.23 Let
 be a modal similarity type. A
-frame is a tuple
F consisting
of the following ingredients:
(i) a non-empty set
W,
(ii) for each
n

0, and each
n-ary modal operator
M in the similarity type
,
an (n
+
1)-ary relation
R
M.
So, again, frames are simply relational structures. If
 contains just a ﬁnite number
of modal operators
M
1, . . . ,
M
n, we write
F
=
(W
;
R
M
1, . . . ,
R
M
n
); otherwise we
write
F
=
(W
;
R
M
)
M2 or
F
=
(W
;
fR
M
j
M

g). We turn such a frame into a
model in exactly the same way we did for the basic modal language: by adding a
valuation. That is, a
-model is a pair
M
=
(F;
V
) where
F is a
-frame, and
V is
a valuation with domain
 and range
P
(W
), where
W is the universe of
F.
The notion of a formula
 being satisﬁed (or true) at a state
w in a model
M
=
(W
;
fR
M
j
M

g;
V
) (notation:
M;
w

) is deﬁned inductively. The clauses
for the atomic and Boolean cases are the same as for the basic modal language (see
Deﬁnition 1.20). As for the modal case, when
(M)
>
0 we deﬁne
M;
w

M(
;
:
:
:
;

n
)
iff
for some
v
1, . . . ,
v
n
W with
R
M
w
v
:
:
:
v
n
we have, for each
i,
M;
v
i


i
:
This is an obvious generalization of the way
3 is handled in the basic modal lan-
guage. Before going any further, the reader should formulate the satisfaction clause
for
O(
;
:
:
:
;

n
).
On the other hand, when
(M)
=
0 (that is, when
M is a nullary modality) then
R
M is a unary relation and we deﬁne
M;
w

M
iff
w
R
M
:
That is, unlike other modalities, nullary modalities do not access other states. In
fact, their semantics is identical to that of the propositional variables, save that the
unary relations used to interpret them are not given by the valuation — rather, they
are part of the underlying frame.
As before, we often write
w

 for
M;
w

 where
M is clear from the
context. The concept of global truth (or universal truth) in a model is deﬁned



1.3 Models and Frames
as for the basic modal language: it simply means truth at all states in the model.
And, as before, we sometimes extend the valuation
V supplied by
M to arbitrary
formulas.
a
Example 1.24 (i) Let
 be a similarity type with three unary operators
hai,
hbi,
and
hci. Then a
-frame has three binary relations
R
a,
R
b, and
R
c (that is, it is a
labeled transition system with three labels). To give an example, let
W,
R
a,
R
b
and
R
c be as in Figure 1.2, and consider the formula
haip
!
hbip. Informally,
this formula is true at a state, if it has an
R
a-successor satisfying
p only if it has
an
R
b-successor satisfying
p. Let
V be a valuation with
V
(p)
=
fw
g. Then the
model
M
=
(W
;
R
a
;
R
b
;
R
c
;
V
) has
M;
w
6
haip
!
hbip.
(ii) Let
 be a similarity type with a binary modal operator
M and a ternary
operator
. Frames for this
 contain a ternary relation
R
M and a 4-ary rela-
tion
S
. As an example, let
W
=
fu;
v
;
w
;
sg,
R
M
=
f(u;
v
;
w
)g, and
S

=
f(u;
v
;
w
;
s)g as in Figure 1.6, and consider a valuation
V on this frame with
V
(p
)
=
fv
g,
V
(p
)
=
fw
g and
V
(p
)
=
fsg. Now, let
 be the formula
:
R
M
uv
w
:
S

uv
w
s
s
p
w
p
v
p
u
      Fig. 1.6. A simple frame
M
(p
;
p
)
!
(p
;
p
;
p
). An informal reading of
 is ‘any triangle of which the
evaluation point is a vertex, and which has
p
0 and
p
1 true at the other two vertices,
can be expanded to a rectangle with a fourth point at which
p
2 is true.’ The reader
should be able to verify that
 is true at
u, and indeed at all other points, and hence
that it is globally true in the model.
a
Example 1.25 (Bidirectional Frames and Models) Recall from Example 1.14
that the basic temporal language has two unary operators
F and
P. Thus, according
to Deﬁnition 1.23, models for this language consist of a set bearing two binary re-
lations,
R
F (the into-the-future relation) and
R
P (the into-the-past relation), which
are used to interpret
F and
P respectively. However, given the intended reading
of the operators, most such models are inappropriate: clearly we ought to insist on
working with models based on frames in which
R
P is the converse of
R
F (that is,
frames in which
8xy
(R
F
xy
$
R
P
y
x)).
Let us denote the converse of a relation
R by
R
. We will call a frame of the



1 Basic Concepts
form
(T
;
R
;
R

) a bidirectional frame, and a model built over such a frame a bidi-
rectional model. From now on, we will only interpret the basic temporal language
in bidirectional models. That is, if
M
=
(T
;
R
;
R

;
V
) is a bidirectional model
then:
M;
t

F

iff
9s
(R
ts
^
M;
s

)
M;
t

P

iff
9s
(R

ts
^
M;
s

):
But of course, once we’ve made this restriction, we don’t need to mention
R
 ex-
plicitly any more: once
R has been ﬁxed, its converse is ﬁxed too. That is, we are
free to interpret the basic temporal languages on frames
(T
;
R
) for the basic modal
language using the clauses
M;
t

F

iff
9s
(R
ts
^
M;
s

)
M;
t

P

iff
9s
(R
st
^
M;
s

):
These clauses clearly capture a crucial part of the intended semantics:
F looks
forward along
R, and
P looks backwards along
R. Of course, our models will
only start looking genuinely temporal when we insist that
R has further properties
(notably transitivity, to capture the ﬂow of time), but at least we have pinned down
the fundamental interaction between the two modalities.
a
Example 1.26 (Regular Frames and Models) As explained in Example 1.15, the
language of PDL has an inﬁnite collection of diamonds, each indexed by a program
 built from basic programs using the constructors
[,
;, and
. Now, according to
Deﬁnition 1.23, a model for this language has the form
(W
;
fR

j
 is a program
g;
V
):
That is, a model is a labeled transition system together with a valuation. However,
given our reading of the PDL operators, most of these models are uninteresting. As
with the basic temporal language, we must insist on working with a class of models
that does justice to our intentions.
Now, there is no problem with the interpretation of the basic programs: any
binary relation can be regarded as a transition relation for a non-deterministic pro-
gram. Of course, if we were particularly interested in deterministic programs we
would insist that each basic program be interpreted by a partial function, but let us
ignore this possibility and turn to the key question: which relations should interpret
the structured modalities? Given our readings of
[,
; and
, as choice, composition,
and iteration, it is clear that we are only interested in relations constructed using
the following inductive clauses:
R

[
=
R

[
R

R

;

=
R

Æ
R

(=
f(x;
y
)
j
9z
(R

xz
^
R

z
y
)g)
R


=
(R

)

; the reﬂexive transitive closure of
R

:



1.3 Models and Frames
These inductive clauses completely determine how each modality should be inter-
preted. Once the interpretation of the basic programs has been ﬁxed, the relation
corresponding to each complex program is ﬁxed too. This leads to the following
deﬁnition.
Suppose we have ﬁxed a set of basic programs. Let
 be the smallest set of
programs containing the basic programs and all programs constructed over them
using the regular constructors
[,
; and
. Then a regular frame for
 is a labeled
transition system
(W
;
fR

j


g) such that
R
a is an arbitrary binary relation
for each basic program
a, and for all complex programs
,
R
 is the binary relation
inductively constructed in accordance with the previous clauses. A regular model
for
 is a model built over a regular frame; that is, a regular model is regular
frame together with a valuation. When working with the language of PDL over the
programs in
, we will only be interested in regular models for
, for these are
the models that capture the intended interpretation.
What about the
\ and
? constructors? Clearly the intended reading of
\ demands
that
R

\
=
R

\
R

2. As for ?, it is clear that we want the following deﬁnition:
R
?
=
f(x;
y
)
j
x
=
y and
y

g:
This is indeed the clause we want, but note that it is rather different from the others:
it is not a frame condition. Rather, in order to determine the relation
R
?, we need
information about the truth of the formula
, and this can only be provided at the
level of models.
a
Example 1.27 (Arrow Models) Arrow frames were deﬁned in Example 1.8 and
the arrow language in Example 1.16. Given these deﬁnitions, it is clear how the
language of arrow logic should be interpreted. First, an arrow model is a structure
M
=
(F;
V
) such that
F
=
(W
;
C
;
R
;
I
) is an arrow frame and
V is a valuation.
Then:
M;
a

1’
iff
I
a;
M;
a



iff
M;
b

 for some
b with
R
ab;
M;
a


Æ
 
iff
M;
b

 and
M;
c

 for some
b and
c with
C
abc:
When
F is a square frame
S
U (as deﬁned in Example 1.8), this works out as
follows.
V now maps propositional variables to sets of pairs over
U; that is, to
binary relations. The truth deﬁnition can be rephrased as follows:
M;
(a
;
a
)

1’
iff
a
=
a
;
M;
(a
;
a
)



iff
M;
(a
;
a
)


M;
(a
;
a
)


Æ
 
iff
M;
(a
;
u)

 and
M;
(u;
a
)

 for some
u
U
:
Such situations can be represented pictorially in two ways. First, one could draw



1 Basic Concepts
the graph-like structures as given in Example 1.8. Alternatively, one could draw
a square model two-dimensionally, as in the picture below. It will be obvious that
the modal constant
1’ holds precisely at the diagonal points and that

 is true at a
point iff
 holds at its mirror image with respect to the diagonal. The formula

Æ
 
holds at a point
a iff we can draw a rectangle
abcd such that:
b lies on the vertical
line through
a,
d lies on the vertical line through
a; and
c lies on the diagonal.
              1’
q

q


              q
c
q
d

 
q
a


Æ
 
q
b


a
Frames and validity
It is time to deﬁne one of the key concepts in modal logic. So far we have been
viewing modal languages as tools for talking about models. But models are com-
posite entities consisting of a frame (our underlying ontology) and contingent in-
formation (the valuation). We often want to ignore the effects of the valuation and
get a grip on the more fundamental level of frames. The concept of validity lets
us do this. A formula is valid on a frame if it is true at every state in every model
that can be built over the frame. In effect, this concept interprets modal formulas
on frames by abstracting away from the effects of particular valuations.
Deﬁnition 1.28 A formula
 is valid at a state
w in a frame
F (notation:
F;
w

)
if
 is true at
w in every model
(F;
V
) based on
F;
 is valid in a frame
F (notation:
F

) if it is valid at every state in
F. A formula
 is valid on a class of frames
F (notation:
F

) if it is valid on every frame
F in
F; and it is valid (notation:

) if it is valid on the class of all frames. The set of all formulas that are valid in
a class of frames
F is called the logic of
F (notation:

F).
a
Our deﬁnition of the logic of a frame class
F (as the set of ‘all’ formulas that
are valid on
F) is underspeciﬁed: we did not say which collection of proposition
letters
 should be used to build formulas. But usually the precise form of this
collection is irrelevant for our purposes. On the few occasions in this book where
more precision is required, we will explicitly deal with the issue. (If the reader is



1.3 Models and Frames
worried about this, he or she may just ﬁx a countable set
 of proposition letters
and deﬁne

F to be
f
F
orm
(
;
)
j
F

g.)
As will become abundantly clear in the course of the book, validity differs from
truth in many ways. Here’s a simple example. When a formula

_
 is true at a
point
w, this means that that either
 or
 is true at
w (the satisfaction deﬁnition
tells us so). On the other hand, if

_
 is valid on a frame
F, this does not mean
that either
 or
 is valid on
F (p
_
:p is a simple counterexample).
Example 1.29 (i) The formula
3(p
_
q
)
!
(3p
_
3q
) is valid on all frames. To
see this, take any frame
F and state
w in
F, and let
V be a valuation on
F. We have
to show that if
(F;
V
);
w

3(p
_
q
), then
(F;
V
);
w

3p
_
3q. So assume that
(F;
V
);
w

3(p
_
q
). Then, by deﬁnition there is a state
v such that
R
w
v and
(F;
V
);
v

p
_
q. But, if
v

p
_
q then either
v

p or
v

q. Hence either
w

3p or
w

3q. Either way,
w

3p
_
3q.
(ii) The formula
33p
!
3p is not valid on all frames. To see this we need to
ﬁnd a frame
F, a state
w in
F, and a valuation on
F that falsiﬁes the formula at
w.
So let
F be a three-point frame with universe
f0;
1;
2g and relation
f(0;
1);
(1;
2)g.
Let
V be any valuation on
F such that
V
(p)
=
f2g. Then
(F;
V
);

33p, but
(F;
V
);
6
3p since 0 is not related to 2.
(iii) But there is a class of frames on which
33p
!
3p is valid: the class
of transitive frames. To see this, take any transitive frame
F and state
w in
F,
and let
V be a valuation on
F. We have to show that if
(F;
V
);
w

33p, then
(F;
V
);
w

3p. So assume that
(F;
V
);
w

33p. Then by deﬁnition there are
states
u and
v such that
R
w
u and
R
uv and
(F;
V
);
v

p. But as
R is transitive, it
follows that
R
w
v, hence
(F;
V
);
w

3p.
(iv) As the previous example suggests, when additional constraints are imposed
on frames, more formulas may become valid. For example, consider the frame
depicted in Figure 1.2. On this frame the formula
haip
!
hbip is not valid; a coun-
termodel is obtained by putting
V
(p)
=
fw
g. Now, consider a frame satisfying
the condition
R
a

R
b; an example is depicted in Figure 1.7.
w
s
-
-
a
b
s
Æ



b
Fig. 1.7. A frame satisfying
R
a

R
b.
On this frame it is impossible to refute the formula
haip
!
hbip at
w, because a
refutation would require the existence of a point
u with
R
a
w
u and
p true at
u, but
not
R
b
w
u; but such points are forbidden when we insist that
R
a

R
b.
This is a completely general point: in every frame
F of the appropriate similarity
type, if
F satisﬁes the condition
R
a

R
b, then
haip
!
hbip is valid in
F. More-



1 Basic Concepts
over, the converse to this statement also holds: whenever
haip
!
hbip is valid on
a given frame
F, then the frame must satisfy the condition
R
a

R
b. To use the
terminology we will introduce in Chapter 3, the formula
haip
!
hbip deﬁnes the
property that
R
a

R
b.
(v) When interpreting the basic temporal language (see Example 1.25) we ob-
served that arbitrary frames of the form
(W
;
R
P
;
R
F
) were uninteresting given the
intended interpretation of
F and
P, and we insisted on interpreting them using a
relation
R and its converse. Interestingly, there is a sense in which the basic tempo-
ral language itself is strong enough to enforce the condition that the relation
R
P is
the converse of the relation
R
F : such frames are precisely the ones which validate
both the formulas
p
!
GP
p and
p
!
H
F
p; see Exercise 3.1.1.
(vi) The formula
F
q
!
F
F
q is not valid on all frames. To see this we need
to ﬁnd a frame
T
=
(T
;
R
), a state
t in
T, and a valuation on
T that falsiﬁes
this formula at
t. So let
T
=
f0;
1g, and let
R be the relation
f(0;
1)g. Let
V be a valuation such that
V
(p)
=
f1g. Then
(T;
V
);

F
p, but obviously
(T;
V
);
6
F
F
p.
(vii) But there is a frame on which
F
p
!
F
F
p is valid. As the universe of the
frame take the set of all rational numbers
Q, and let the frame relation be the usual
<-ordering on
Q. To show that
F
p
!
F
F
p is valid on this frame, take any point
t in it, and any valuation
V such that
(Q
;
<;
V
);
t

F
p; we have to show that
t

F
F
p. But this is easy: as
t

F
p, there exists a
t
0 such that
t
<
t
0 and
t

p.
Because we are working on the rationals, there must be an
s with
t
<
s and
s
<
t
(for example,
(t
+
t
)=2). As
s

F
p, it follows that
t

F
F
p.
(viii) The special conditions demanded of PDL models also give rise to validities.
For example,
h
;

ip
$
h
ih
ip is valid on any frame such that
R

;
=
R

Æ
R

2, and in fact the converse is also true. The reader is asked to prove this
in Exercise 3.1.2.
(ix) In our last example we consider arrow logic. We claim that in any square
arrow frame
S
U, the formula

(p
Æ
q
)
!

q
Æ

p is valid. For, let
V be a
valuation on
S
U, and suppose that for some pair of points
u;
v in
U, we have
(S
U
;
V
);
(u;
v
)


(p
Æ
q
). It follows that
(S
U
;
V
);
(v
;
u)

p
Æ
q, and hence,
there must be a
w
U for which
(S
U
;
V
);
(v
;
w
)

p and
(S
U
;
V
);
(w
;
u)

q.
But then we have
(S
U
;
V
);
(w
;
v
)


p and
(S
U
;
V
);
(u;
w
)


q. This in turn
implies that
(S
U
;
V
);
(u;
v
)


q
Æ

p.
a
Exercises for Section 1.3
1.3.1 Show that when evaluating a formula
 in a model, the only relevant information in
the valuation is the assignments it makes to the propositional letters actually occurring in
. More precisely, let
F be a frame, and
V and
V
0 be two valuations on
F such that
V
(p)
=
V
(p) for all proposition letters
p in
. Show that
(F;
V
)

 iff
(F;
V
)

. Work in the
basic modal language. Do this exercise by induction on the number of connectives in
 (or



