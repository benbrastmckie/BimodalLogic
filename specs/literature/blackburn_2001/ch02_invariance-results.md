<!-- Source: Blackburn, de Rijke & Venema (2001). Modal Logic. Cambridge University Press. Chapter 2: Models, §2.1 Invariance Results (pages 50-63). BibKey: Blackburn2001 -->

2.1 Invariance Results
the model constructions introduced in the ﬁrst section are all special cases
of bisimulation, learn that modal equivalence does not always imply bisim-
ilarity, and examine an important special case in which it does.
Section 2.3: Finite Models (Basic track). Here we show that modal languages en-
joy the ﬁnite model property. We do so in two distinct ways: by the se-
lection method (ﬁnitely approximating a bisimulation), and by ﬁltration
(collapsing a model into a ﬁnite number of equivalence classes).
Section 2.4: The Standard Translation (Basic track). We start our study of cor-
respondence theory. By deﬁning the standard translation, we link modal
languages to ﬁrst-order (and other classical) languages and raise the two
central questions that dominate later sections: What part of ﬁrst-order logic
does modal logic correspond to? And which properties of models are de-
ﬁnable by modal means?
Section 2.5: Modal Saturation via Ultraﬁlter Extensions (Basic track). The ﬁrst
step towards obtaining some answers is to introduce ultraﬁlter extensions,
the last of the big four modal model constructions. We then show that al-
though modal equivalence does not imply bisimilarity, it does imply bisim-
ilarity somewhere else, namely in the ultraﬁlter extensions of the models
concerned.
Section 2.6: Characterization and Deﬁnability (Advanced track).
We prove the
two main results of this chapter. First, we prove van Benthem’s theorem
stating that modal languages are the bisimulation invariant fragments of
ﬁrst-order languages. Second, we show that modally deﬁnable classes of
(pointed) models are those that are closed under bisimulations and ultra-
products and whose complements are closed under ultrapowers.
Section 2.7: Simulations and Safety (Advanced track). We prove two results that
give the reader a glimpse of recent work in modal model theory. The ﬁrst
describes the properties that are preserved under simulations (a one-way
version of bisimulation), the second characterizes the ﬁrst-order deﬁnable
operations on binary relations which respect bisimilarity.
2.1 Invariance Results
Mathematicians rarely study structures in isolation. They are usually interested in
the relations between different structures, and in operations that build new struc-
tures from old. Questions that naturally arise in such a context concern the struc-
tural properties that are invariant under or preserved by such relations and opera-
tions. We’ll not give precise deﬁnitions of these notions, but roughly speaking, a
property is preserved by a certain relation or operation if, whenever two structures
are linked by the relation or operation, then the second structure has the property



2 Models
if the ﬁrst one has it. We speak of invariance if the property is preserved in both
directions.
When it comes to this research topic, logic is no exception to the rule — indeed,
logicians add a descriptive twist to it. For instance, modal logicians want to know
when two structures, or perhaps two points in distinct structures, are indistinguish-
able by modal languages in the sense of satisfying the same modal formulas.
Deﬁnition 2.1 Let
M and
M
0 be models of the same modal similarity type
, and
let
w and
w
0 be states in
M and
M
0 respectively. The
-theory (or
-type) of
w is
the set of all
-formulas satisﬁed at
w: that is,
f
j
M;
w

g. We say that
w and
w
0 are (modally) equivalent (notation:
w
!
w
0) if they have the same
-theories.
The
-theory of the model
M is the set of all
-formulas satisﬁed by all states
in
M: that is,
f
j
M

g. Models
M and
M
0 are called (modally) equivalent
(notation:
M
!
M
0) if their theories are identical.
a
We now introduce three important ways of constructing new models from old ones
which leave the theories associated with states unchanged: disjoint unions, gen-
erated submodels, and bounded morphisms. These constructions (together with
ultraﬁlter extensions, which we introduce in Section 2.5) play an important role
throughout the book. For example, in the following chapter we will see that they
lift to the level of frames (where they preserve validity), we will use them repeat-
edly in our work on completeness and complexity, and in Chapter 5 we will see
that they have important algebraic analogs.
Disjoint Unions
Suppose we have the following two models:
'
&
$
%
t
w

	


'
&
$
%
t
v
t
v
t
v
t
v
-
-
-
M
N
Don’t worry that we haven’t speciﬁed the valuations — they’re irrelevant here. All
that matters is that
M and
N have disjoint domains, for we are now going to lump
them together to form the model
M
]
N:
t
w

	


t
v
t
v
t
v
t
v
-
-
-
M
]
N
'
&
$
%
The model
M
]
N is called the disjoint union of
M and
N. It gathers together
all the information in the two smaller models unchanged: we have not altered the
way the points are related, nor the way atomic information is distributed. Suppose



2.1 Invariance Results
we’re working in the basic modal language, and suppose that a formula
 is true at
(say)
v
1 in
N: is
 still true at
v
1 in
M
]
N? More generally, is modal satisfaction
preserved from points in the original models to the points in the disjoint union?
And what about the reverse direction: if a modal formula is true at some state in
M
]
N, is it also true at that same state in the smaller model it came from?
The answer to these questions is clearly yes: modal satisfaction must be invariant
(that is, preserved in both directions) under the formation of disjoint unions. Modal
satisfaction is intrinsically local: only the points accessible from the current state
are relevant to truth or falsity. If we evaluate a formula
 at (say)
w, it is completely
irrelevant whether we perform the evaluation in
M or
M
]
N;
 simply cannot
detect the presence or absence of states in other islands.
Deﬁnition 2.2 (Disjoint Unions)
We ﬁrst deﬁne disjoint unions for the basic
modal language. We say that two models are disjoint if their domains contain
no common elements. For disjoint models
M
i
=
(W
i,
R
i,
V
i
) (i
I), their
disjoint union is the structure
U
i
M
i
=
(W
;
R
;
V
), where
W is the union of
the sets
W
i,
R is the union of the relations
R
i, and for each proposition letter
p,
V
(p)
=
S
i2I
V
i
(p).
Now for the general case. For disjoint
-structures
M
i
=
(W
i
;
R
Mi
;
V
i
)
M2
(i
I) of the same modal similarity type
, their disjoint union is the structure
U
i
M
i
=
(W
;
R
M
;
V
)
M2 such that
W is the union of the sets
W
i; for each
M
,
R
M is the union
S
i2I
R
Mi; and
V is deﬁned as in the basic modal case.
If we want to put together a collection of models that are not disjoint, we ﬁrst
have to make them disjoint (say by indexing the domains of these models). To use
the terminology introduced shortly, we simply take mutually disjoint isomorphic
copies of the models we wish to combine, and combine the copies instead.
a
Proposition 2.3 Let
 be a modal similarity type and, for all
i
I, let
M
i be a
-model. Then, for each modal formula
, for each
i
I, and each element
w
of
M
i, we have
M
i
;
w

 iff
U
i2I
M
i
;
w

. In words: modal satisfaction is
invariant under disjoint unions.
Proof. We will prove the result for the basic similarity type. The proof is by in-
duction on
 (we explained this concept in Exercise 1.3.1). Let
i be some index;
we will prove, for each basic modal formula
, and each element
w of
M
i, that
M
i
;
w

 iff
M;
w

, where
M is the disjoint union
U
i2I
M
i.
First suppose that
 contains no connectives. Now, if
 is a proposition letter
p, then we have
M
i
;
w

 iff
w
V
i
(p) iff (by deﬁnition of
V )
w
V
(p)
iff
M;
w

. On the other hand,
 could be
? (for the purposes of inductive
proofs it is convenient to regard
? as a propositional letter rather than as a logical
connective). But trivially
? is false at
w in both models, so we have the desired
equivalence here too.



2 Models
Our inductive hypothesis is that the desired equivalence holds for all formulas
containing at most
n connectives (where
n

0). We must now show that the
equivalence holds for all formulas
 containing
n
+
1 connectives. Now, if
 is of
the form
: or
 
_
 this is easily done — we will leave this to the reader — so
as we are working with the basic similarity type, it only remains to establish the
equivalence for formulas of the form
3 . So assume that
M
i
;
w

3 . Then
there is a state
v in
M
i with
R
i
w
v and
M
i
;
v

 . By the inductive hypothesis,
M;
v

 . But by deﬁnition of
M, we have
R
w
v, so
M;
w

3 .
For the other direction, assume that
M;
w

3 holds for some
w in
M
i. Then
there is a
v with
R
w
v and
M;
v

v. It follows by the deﬁnition of
R that
R
j
w
v for
some
j, and by the disjointness of the universes we must have that
j
=
i. But then
we ﬁnd that
v belongs to
M
i as well, so we may apply the inductive hypothesis;
this yields
M
i
;
v

 , so we ﬁnd that
M
i
;
w

3 .
a
We will use Proposition 2.3 all through the book — here is a simple application
which hints at the ideas we will explore in Chapter 7.
Example 2.4 Deﬁned modalities are a convenient shorthand for concepts we ﬁnd
useful. We have already seen some examples. In this book
2, the ‘true at all ac-
cessible states modality’, is shorthand for
:3:, and we have inductively deﬁned
a ‘true somewhere
n-steps from here’ modality
n for each natural number
n (see
Example 1.22). But while it is usually easy to show that some modality is deﬁnable
(we need simply write down its deﬁnition), how do we show that some proposed
operator is not deﬁnable? Via invariance results! As an example, consider the
global modality. The global diamond E has as its (intended) accessibility relation
the relation
W

W implicitly present in any model. That is:
M;
w
 E iff
M;
v

 for some state
v in
M
:
Its dual, A, the global box, thus has the following interpretation:
M;
w
 A iff
M;
v

 for all states
v in
M:
Thus the global modality brings a genuinely global dimension to modal logic. But
is it deﬁnable in the basic modal language? Intuitively, no: as
3 and
2 work
locally, it seems unlikely that they can deﬁne a truly global modality over arbitrary
structures. Fine — but how do we prove this?
With the help of the previous proposition. Suppose we could deﬁne A. Then
we could write down an expression
(p) containing only symbols from the basic
modal language such that for every model
M,
M;
w

(p) iff
M

p. We
now derive a contradiction from this supposition. Consider a model
M
1 where
p holds everywhere, and a model
M
2 where
p holds nowhere. Let
w be some
point in
M
1. It follows that
M
;
w

(p), so as (by assumption)
(p) contains



2.1 Invariance Results
only symbols from the basic modal language, by Proposition 2.3 we have that
M
]
M
;
w

(p). But this implies that
M
]
M
;
v

p for every
v in
M
2,
which, again by Proposition 2.3, in turn implies that
M

p: contradiction. We
conclude that the global box (and hence the global diamond) is not deﬁnable in the
basic modal language.
So, if we want the global modality, then we either have to introduce it as a
primitive (we will do this in Section 7.1), or we have to work with restricted classes
of models on which it is deﬁnable (in Exercise 1.3.3 we worked with a class of
models in which we could deﬁne A in the basic temporal language).
a
Generated submodels
Disjoint unions are a useful way of making bigger models from smaller ones — but
we also want methods for doing the reverse. That is, we would like to know when it
is safe to throw points away from a satisfying model without affecting satisﬁability.
Disjoint unions tell us a little about this (if a model is a disjoint union of smaller
models, we are free to work with the component models), but this is not useful in
practice. We need something sharper, namely generated submodels.
Suppose we are using the basic modal language to talk about a model
M based
on the frame
(Z;
<), the integers with their usual order. It does not matter what the
valuation is — all that’s important is that
M looks something like this:




...
t
 3
t
 2
t
 1
t
t
t
t
...
-
-
-
-
-
-
-
-
First suppose that we form a submodel
M
  of
M by throwing away all the positive
numbers, and restricting the original valuation (whatever it was) to the remaining
numbers. So
M
  looks something like this:




...
t
 3
t
 2
t
 1
t
-
-
-
-
The basic modal language certainly can see that
M and
M
  are different. For
example, it sees that 0 has successors in
M (note that
M;

3>) but is a dead
end in
M
  (note that
M
 ;
6
3>). So there’s no invariance result for arbitrary
submodels. But now consider the submodel
M
+ of
M that is formed by omitting
the negative numbers, and restricting the original valuation to the numbers that
remain:




t
t
t
t
...
-
-
-
-



2 Models
Suppose a basic modal formula
 is satisﬁed at some point
n in
M. Is
 also
satisﬁed at the same point
n in
M
+? The answer must be yes. The only points that
are relevant to
’s satisﬁability are the points greater than
n — and all such points
belong to
M
+. Similarly, it is clear that if
M
+ satisﬁes a basic modal formula
 at
m, then
M must too.
In short, it seems plausible that modal invariance holds for submodels which
are closed under the accessibility relation of the original model. Such models are
called generated submodels, and they do indeed give rise to the invariance result
we are looking for.
Deﬁnition 2.5 (Generated Submodels) We ﬁrst deﬁne generated submodels for
the basic modal language. Let
M
=
(W
;
R
;
V
) and
M
=
(W
;
R
;
V
) be two
models; we say that
M
0 is a submodel of
M if
W

W,
R
0 is the restriction of
R
to
W
0 (that is:
R
=
R
\
(W

W
)), and
V
0 is the restriction of
V to
M
0 (that is:
for each
p,
V
(p)
=
V
(p)
\
W
0). We say that
M
0 is a generated submodel of
M
(notation:
M

M) if
M
0 is a submodel of
M and for all points
w the following
closure condition holds:
if
w is in
M
0 and
R
w
v, then
v is in
M
0.
For the general case, we say that a model
M
=
(W
;
R
M
;
V
)
M2 is a generated
submodel of the model
M
=
(W
;
R
M
;
V
)
M2 (notation:
M

M) whenever
M
is a submodel of
M (with respect to
R
M for all
M
), and the following closure
condition is fulﬁlled for all
M

if
u
W
0 and
R
M
uu
:
:
:
u
n, then
u
;
:
:
:
;
u
n
W
0.
Let
M be a model, and
X a subset of the domain of
M; the submodel generated
by
X is the smallest generated submodel of
M whose domain contains
X (such a
model always exists: why?). Finally, a rooted or point generated model is a model
that is generated by a singleton set, the element of which is called the root of the
frame.
a
Proposition 2.6 Let
 be a modal similarity type and let
M and
M
0 be
-models
such that
M
0 is a generated submodel of
M. Then, for each modal formula
 and
each element
w of
M
0 we have that
M;
w

 iff
M
;
w

. In words: modal
satisfaction is invariant under generated submodels.
Proof. By induction on
. The reader unused to such proofs should write out the
proof in full. In Proposition 2.19 we provide an alternative proof based on the
observation that generated submodels induce a bisimulation.
a
Four remarks. First, note that the invariance result for disjoint unions (Proposi-
tion 2.3) is a special case of the result for generated submodels: any component of



2.1 Invariance Results
a disjoint union is a generated submodel of the disjoint union. Second, using an
argument analogous to that used in Example 2.4 to show that the global box can’t
be deﬁned in the basic modal language, we can use Proposition 2.6 to show that we
cannot deﬁne a backward looking modality in terms of
3; see Exercise 2.1.2. Thus
if we want such a modality we have to add it as a primitive — which is exactly what
we did, of course, when deﬁning the basic temporal language. Third, although we
have not explicitly discussed generated submodels for the basic temporal language,
PDL, or arrow logic, the required concepts are all special cases of Deﬁnition 2.5,
and thus the respective invariance results are special cases of Proposition 2.6. But
it is worth making a brief comment about the basic temporal language. When we
think explicitly in terms of bidirectional frames (see Example 1.25) it is obvious
that we are interested in submodels closed under both
R
F and
R
P. But when work-
ing with the basic temporal language we usually leave
R
P implicit: we work with
ordinary models
(W
;
R
;
V
), and use
R
, the converse of
R, as
R
P . Thus a tem-
poral generated submodel of
(W
;
R
;
V
) is a submodel
(W
;
R
;
V
) that is closed
under both
R and
R
. Finally, generated submodels are heavily used throughout
the book: given a model
M that satisﬁes a formula
 at a state
w, very often the
ﬁrst thing we will do is form the submodel of
M generated by
w, thus trimming
what may be a very unwieldy satisfying model down to a more manageable one.
Morphisms for modalities
In mathematics the idea of morphisms or structure preserving maps is of funda-
mental importance. What notions of morphism are appropriate for modal logic?
That is, what kinds of morphism give rise to invariance results? We will approach
the answer bit by bit, introducing a number of important concepts on the way. We
will start by considering the general notion of homomorphism (this is too weak to
yield invariance, but it is the starting point for better attempts), then we will deﬁne
strong homomorphisms, embeddings, and isomorphisms (these do give us invari-
ance, but are not particularly modal), and ﬁnally we will zero in on the answer:
bounded morphisms.
Deﬁnition 2.7 (Homomorphisms) Let
 be a modal similarity type and let
M and
M
0 be
-models. By a homomorphism
f from
M to
M
0 (notation:
f
:
M
!
M
0)
we mean a function
f from
W to
W
0 with the following properties.
(i) For each proposition letter
p and each element
w from
M, if
w
V
(p),
then
f
(w
)
V
(p).
(ii) For each
n
>
0 and each
n-ary
M
, and
(n
+
1)-tuple
w from
M, if
(w
0, . . . ,
w
n
)
R
M then
(f
(w
), . . . ,
f
(w
n
))
R
M (the homomorphic
condition).



2 Models
We call
M the source and
M
0 the target of the homomorphism.
a
Note that for the basic modal language, item (ii) is just this:
if
R
w
u then
R
f
(w
)f
(u).
Thus item (ii) simply says that homomorphisms preserve relational links.
Are modal formulas invariant under homomorphisms? No: although homomor-
phisms reﬂect the structure of the source in the structure of the target, they do
not reﬂect the structure of the target back in the source. It is easy to turn this
observation into a counterexample, and we will leave this task to the reader as
Exercise 2.1.3.
So let us try and strengthen the deﬁnition. There is an obvious way of doing
so: turn the conditionals into equivalences. This leads to a number of important
concepts.
Deﬁnition 2.8 (Strong Homomorphisms, Embeddings and Isomorphisms) Let
 be a modal similarity type and let
M and
M
0 be
-models. By a strong homo-
morphism of
M into
M
0 we mean a homomorphism
f
:
M
!
M
0 which satisﬁes
the following stronger version of the above items (i) and (ii):
(i) For each proposition letter
p and element
w from
M,
w
V
(p) iff
f
(w
)
V
(p).
(ii) For each
n

0 and each
n-ary
M in
 and
(n
+
1)-tuple
w from
M,
(w
0,
. . . ,
w
n
)
R
M iff
(f
(w
), . . . ,
f
(w
n
))
R
M (the strong homomorphic
condition).
An embedding of
M into
M
0 is a strong homomorphism
f
:
M
!
M
0 which is
injective. An isomorphism is a bijective strong homomorphism. We say that
M
is isomorphic to
M
0, in symbols
M

=
M
0, if there is an isomorphism from
M to
M
0.
a
Note that for the basic modal language, item (ii) is just:
R
w
u iff
R
f
(w
)f
(u).
That is, item (ii) says that relational links are preserved from the source model to
the target and back again. So it is not particularly surprising that we have a number
of invariance results.
Proposition 2.9 Let
 be a modal similarity type and let
M and
M
0 be
-models.
Then the following holds:
(i) For all elements
w and
w
0 of
M and
M
0, respectively, if there exists a
surjective strong homomorphism
f
:
M
!
M
0 with
f
(w
)
=
w
0, then
w
and
w
0 are modally equivalent.



2.1 Invariance Results
(ii) If
M

=
M
0, then
M
!
M
0.
Proof. The ﬁrst item follows by induction on
; the second one is an immediate
consequence.
a
None of the above results is particularly modal. For a start, as in all branches of
mathematics, ‘isomorphic’ basically means ‘mathematically identical’. Thus, we
do not want to be able to distinguish isomorphic structures in modal (or indeed,
any other) logic. Quite the contrary: we want to be free to work with structures
‘up to isomorphism’ — as we did, for example, in our discussion of disjoint union,
when we talked of taking isomorphic copies. Item (ii) tells us that we can do this,
but it isn’t a surprising result.
But why is item (i), the invariance result for strong homomorphisms, not ‘gen-
uinely modal’? Quite simply, because there are many morphisms which do give
rise to invariance, but which fail to qualify as strong homomorphisms. To ensure
modal invariance we need to ensure that some target structure is reﬂected back in
the source, but strong morphisms do this in a much too heavy-handed way. The
crucial concept is more subtle.
Deﬁnition 2.10 (Bounded Morphisms — the Basic Case) We ﬁrst deﬁne bound-
ed morphisms for the basic modal language. Let
M and
M
0 be models for the
basic modal language. A mapping
f
:
M
=
(W
;
R
;
V
)
!
M
=
(W
;
R
;
V
) is a
bounded morphism if it satisﬁes the following conditions:
(i)
w and
f
(w
) satisfy the same proposition letters.
(ii)
f is a homomorphism with respect to the relation
R (that is, if
R
w
v then
R
f
(w
)f
(v
)).
(iii) If
R
f
(w
)v
0 then there exists
v such that
R
w
v and
f
(v
)
=
v
0 (the back
condition).
If there is a surjective bounded morphism from
M to
M
0, then we say that
M
0 is a
bounded morphic image of
M, and write
M

M
0.
a
The idea embodied in the back condition is utterly fundamental to modal logic —
in fact, it is the idea that underlies the notion of bisimulation — so we need to get
a good grasp of what it involves right away. Here’s a useful example.
Example 2.11 Consider the models
M
=
(W,
R,
V
) and
M
=
(W
0,
R
0,
V
),
where

W
=
N (the natural numbers),
R
mn iff
n
=
m
+
1, and
V
(p)
=
fn
N
j
n is even
g

W
=
fe;
og,
R
=
f(e;
o);
(o;
e)g, and
V
(p)
=
feg.



2 Models




t
t
t
t
t
t
...
-
-
-
-
-
-




t
-
t

e
o
?
?
...
Fig. 2.1. A bounded morphism
Now, let
f
:
W
!
W
0 be the following map:
f
(n)
=

e
if
n is even
o
if
n is odd
Figure 2.1 sums this all up in a simple picture.
Now,
f is not a strong homomorphism (why not?), but it is a (surjective) bounded
morphism from
M to
M
0. Let’s see why. Trivially
f satisﬁes item (i) of the deﬁ-
nition. As for the homomorphic condition consider an arbitrary pair
(n;
n
+
1) in
R. There are two possibilities:
n is either even or odd. Suppose
n is even. Then
n
+
1 is odd, so
f
(n)
=
e and
f
(n
+
1)
=
o. But then we have
R
f
(n)f
(n
+
1),
as required. The argument for
n odd is analogous.
And now for the interesting part: the back condition. Take an arbitrary element
n of
W and assume that
R
f
(n)w
0. We have to ﬁnd an
m
W such that
R
nm
and
f
(m)
=
w
0. Let’s assume that
n is odd (the case for even
n is similar). As
n is odd,
f
(n)
=
o, so by deﬁnition of
R
0, we must have that
w
=
e. But then
f
(n
+
1)
=
w
0 since
n
+
1 is even, and by the deﬁnition of
R we have that
n
+
is a successor of
n. Hence,
n
+
1 is the
m that we were looking for.
a
Deﬁnition 2.12 (Bounded Morphisms — the General Case) The deﬁnition of
a bounded morphism for general modal languages is obtained from the above by
adapting the homomorphic and back conditions of Deﬁnition 2.10 as follows:
(ii)
0 For all
M
,
R
M
w
v
:
:
:
v
n implies
R
M
f
(w
)f
(v
)
:
:
:
f
(v
n
).
(iii)
0 If
R
M
f
(w
)v
:
:
:
v
n then there exist
v
:
:
:
v
n such that
R
M
w
v
:
:
:
v
n and
f
(v
i
)
=
v
i (for

i

n).
a
Example 2.13 Suppose we are working in the modal similarity type of arrow
logic; see Example 1.16 and 1.27. Recall that the language has a modal constant
1’, a unary operator

 and a single dyadic operator
Æ. Semantically, to these oper-
ators correspond a unary relation
I, a binary
R and a ternary
C. We will deﬁne a



2.1 Invariance Results
bounded morphism from a square model to a model based on the addition of the
integer numbers. We will use the following notation: if
x is an element of
Z

Z,
then
x
0 denotes its ﬁrst component, and
x
1 its second component.
Consider the two models
M
=
(W
;
C
;
R
;
I
;
V
) and
M
=
(W
;
C
;
R
;
I
;
V
)
where

W
=
Z

Z,
C
xy
z iff
x
=
y
0,
y
=
z
0 and
z
=
x
1,
R
xy if
x
=
y
and
x
=
y
0,
I
x iff
x
=
x
1, and ﬁnally, the valuation
V is given by
V
(p)
=
f(x
;
x
)
j
x
 x
0 is even
g,

W
=
Z,
C
stu iff
s
=
t
+
u,
R
st iff
s
=
 t,
I
s iff
s
=
0, and the valuation
V
0 is given by
V
(p)
=
fs
Z
j
s is even
g.
This example is best understood by looking at Figure 2.2. The left picture shows a
fragment of the model
M; the points of
Z

Z are represented as disks or circles,
depending on whether
p is true or not. The diagonal is indicated by the dashed
diagonal line. The picture on the right-hand side shows the image under
f of the
points in
Z

Z.
            a
a
a
a
q
q
q
q
q
a
a
a
a
a
a
q
q
q
q
q
a
a
a
a
a
a
q
q
q
q
q
a
a
a
a
...
...
    
    	
     
     	
     
     	
-1
     
     	
-2
    
    	
...
...
Fig. 2.2. Another bounded morphism.
We claim that the function
f
:
Z

Z
!
Z given by
f
(z
)
=
z
 z
is a bounded morphism for this similarity type. The clause for the propositional
variables is trivial. For the unary relation
I we only have to check that for any
z in
Z

Z,
z
=
z
1 iff
z
 z
=
0. This is obviously true. We leave the case of the
binary relation
R to the reader.
So let’s turn to the clauses for the ternary relation
C. To check item (ii)
0 (the
homomorphic condition), assume that
C
xy
z holds for
x,
y and
z in
W. That is,
we have that
x
=
y
0,
y
=
z
0 and
z
=
x
1. But then we ﬁnd that
f
(x)
=
x
 x
=
z
 y
=
z
 z
+
y
 y
=
f
(z
)
+
f
(y
);



2 Models
so by deﬁnition of
C
0 we do indeed ﬁnd that
C
f
(x)f
(y
)f
(z
).
For item (iii)
0 (the back condition) assume that we have
C
f
(x)tu for some
x
Z

Z and
t;
u
Z. In other words, we have that
x
 x
=
t
+
u. Consider
the pairs
y
:=
(x
;
x
+
t) and
z
:=
(x
+
t;
x
). It is obvious that
C
xy
z; we also
ﬁnd that
f
(y
)
=
t and
f
(z
)
=
x
 (x
+
t)
=
(x
 x
)
 t
=
u. Hence
y and
z
are the elements of
W that we need to satisfy item (iii)
0.
a
Deﬁnition 2.12 covers the basic temporal language, PDL, and arrow logic, as spe-
cial cases — but once more it is worth issuing a warning concerning the basic
temporal language. Although
R
P is usually presented implicitly (as the converse
of the relation
R in some model
(W
;
R
;
V
)) we certainly cannot ignore it. Thus
a temporal bounded morphism from
(W
;
R
;
V
) to
(W
;
R
;
V
) is a bounded
morphism from
(W
;
R
;
R

;
V
) to
(W
;
R
;
R

;
V
).
Proposition 2.14 Let
 be a modal similarity type and let
M and
M
0 be
-models
such that
f
:
M
!
M
0. Then, for each modal formula
, and each element
w of
M we have
M;
w

 iff
M
;
f
(w
)

. In words: modal satisfaction is invariant
under bounded morphisms.
Proof. Let
M,
M
0 and
f be as in the statement of the proposition. We will prove
that for each formula
 and state
w,
M;
w

 iff
M
;
f
(w
)

. The proof is
by induction on
. We will assume that
 is the basic similarity type, leaving the
general case to the reader.
The base step and the boolean cases are routine, so let’s turn to the case where
 is of the form
3 . Assume ﬁrst that
M;
w

3 . This means there is a state
v with
R
w
v and
M;
v

 . By the inductive hypothesis,
M
;
f
(v
)

 . By the
homomorphic condition,
R
f
(w
)f
(v
), so
M
;
f
(w
)

3 .
For the other direction, assume that
M
;
f
(w
)

3 . Thus there is a successor
of
f
(w
) in
M
0, say
v
0, such that
M
;
v

 . Now we use the back condition
(of Deﬁnition 2.10). This yields a point
v in
M such that
R
w
v and
f
(v
)
=
v
0.
Applying the inductive hypothesis, we obtain
M;
v

 , so
M;
w

3 .
a
Here is a simple application: we will now show that any satisﬁable formula can be
satisﬁed in a tree-like model. To put it another way: modal logic has the tree model
property.
Let
 be a modal similarity type containing only diamonds (thus if
M is a
-model, it has the form
(W
;
R
;
R
;
:
:
:
;
V
), where each
R
i is a binary rela-
tion on
W). In this context we will call a
-model
M tree-like if the structure
(W
;
S
i
R
i
;
V
) is a tree in the sense of Example 1.5.
Proposition 2.15 Assume that
 is a modal similarity type containing only dia-
monds. Then, for any rooted
-model
M there exists a tree-like
-model
M
0 such
that
M

M. Hence any satisﬁable
-formula is satisﬁable in a tree-like model.



2.1 Invariance Results
Proof. Let
w be the root of
M. Deﬁne the model
M
0 as follows. Its domain
W
consists of all ﬁnite sequences
(w,
u
1, . . . ,
u
n
) such that
n

0 and for some modal
operators
ha
i, . . . ,
ha
n
i
 there is a path
w
R
a
u



R
a
n
u
n in
M. Deﬁne
(w
;
u
;
:
:
:
;
u
n
)R
a
(w
;
v
;
:
:
:
;
v
m
) to hold if
m
=
n
+
1,
u
i
=
v
i for
i
=
1;
:
:
:
;
n,
and
R
a
u
n
v
m holds in
M. That is,
R
a relates two sequences iff the second is an
extension of the ﬁrst with a state from
M that is a successor of the last element
of the ﬁrst sequence. Finally,
V
0 is deﬁned by putting
(w
;
u
;
:
:
:
;
u
n
)
V
(p)
iff
u
n
V
(p). As the reader is asked to check in Exercise 2.1.4, the mapping
f
:
(w
;
u
:
:
:
;
u
n
)
7!
u
n deﬁnes a surjective bounded morphism from
M
0 to
M,
thus
M
0 and
M are equivalent.
But then it follows that any satisﬁable
-formula is satisﬁable in a tree-like
model. For suppose
 is satisﬁable in some
-model at a point
w. Let
M be
the submodel generated by
w. By Proposition 2.3,
M;
w

, and as
M is rooted
we can form an equivalent tree-like model
M
0 as just described.
a
The method used to construct
M
0 from
M is well known in both modal logic
and computer science: it is called unravelling (or unwinding, or unfolding). In
essence, we built
M
0 by treating the paths through
M as ﬁrst class citizens: this
untangles the (possibly very complex) way information is stored in
M, and makes
it possible to present it as a tree. We will make use of unravelling several times in
later work; in the meantime, Exercise 2.1.7 asks the reader to extend the notion of
‘tree-likeness’ to arbitrary modal similarity types, and generalize Proposition 2.15.
Exercises for Section 2.1
2.1.1 Suppose we wanted an operator D with the following satisfaction deﬁnition: for any
model
M and any formula
,
M;
w
 D iff there is a
u
6=
w such that
M;
u

. This
operator is called the difference operator and we will discuss it further in Section 7.1. Is
the difference operator deﬁnable in the basic modal language?
2.1.2 Use generated submodels to show that the backward looking modality (that is, the
P
of the basic temporal language) cannot be deﬁned in terms of the forward looking operator
3.
2.1.3 Give the simplest possible example which shows that the truth of modal formulas is
not invariant under homomorphisms, even if condition 1 is strengthened to an equivalence.
Is modal truth preserved under homomorphisms?
2.1.4 Show that the mapping
f deﬁned in the proof of Proposition 2.15 is indeed a surjec-
tive bounded morphism.
2.1.5 Let
B
=
(B
;
R
) be the transitive binary tree; that is,
B is the set of ﬁnite strings
of
0s and
1s, and
R

 holds if
 is a proper initial segment of
. Let
N
=
(N
;
<) be the
frame of the natural numbers with the usual ordering.



2 Models
(a) Let
V
0 be the valuation on
N given by
V
(p)
=
f2n
j
n
N
g for each proposition
letter
p. Deﬁne a valuation
U
0 on
B and a bounded morphism from
(B;
U
) to
(N;
V
).
(b) Let
U
1 be the valuation on
B given by
U
(p)
=
f1
j

B
g for each proposition
letter
p. Give a valuation
V
1 on
N and a bounded morphism from
(B;
U
) to
(N;
V
).
(c) Can you also ﬁnd surjective bounded morphisms?
2.1.6 Show that every model is the bounded morphic image of the disjoint union of point-
generated (that is: rooted) models. This exercise may look rather technical, but in fact it is
very straightforward — think about it!
2.1.7 This exercise generalizes Proposition 2.15 to arbitrary modal similarity types.
(a) Deﬁne a suitable notion of tree-like model that works for arbitrary modal similarity
types. (Hint: in case of
R
M
s
s
:
:
:
s
n, think of
s
0 as being the parent node and of
s
;
:
:
:
;
s
n as the children.)
(b) Generalize Proposition 2.15 to arbitrary modal similarity types.
