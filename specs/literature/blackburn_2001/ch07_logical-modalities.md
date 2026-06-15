<!-- Source: Blackburn, de Rijke & Venema (2001). Modal Logic. Cambridge University Press. Chapter 7: Extended Modal Logic, §7.1 Logical Modalities (pages 415-427). BibKey: Blackburn2001 -->

7.1 Logical Modalities
Pure ﬁrst-order logic has a signiﬁcant expressive weakness: it’s not strong enough
to express the concept of equality in arbitrary structures. But because equality is
such an important relation, logicians introduce a special binary relation symbol
(namely =) and stipulate that it denotes the equality relation. As the interpretation
of = is ﬁxed, and as the relation it denotes is so fundamental, the equality symbol
is called a logical predicate.
Logical modalities trade on the same idea. Are there important relations which
ordinary modal languages cannot express? Very well then: let’s add new modal-
ities and stipulate that they be interpreted by the relation in question.
In this
section we’ll discuss two of the most important logical modalities: the global
modality (which is interpreted by the relation
W

W) and the difference oper-
ator (which is interpreted by
6=, the inequality relation). We’ll also make a few
remarks about Boolean Modal Logic (BML), a system containing an entire family
of logical modalities.
But before going any further, let’s get one thing absolutely clear: we’ve been
using logical modalities all through the book. Here’s the simplest example. Sup-
pose we are working with the basic modal language. Now, for many purposes we
may be happy simply using
3 to talk about the relation
R — but sometimes we
may want to talk about
R
, the converse of
R, as well. Now, we know (see Exer-
cise 2.1.2) that this can’t be done in the basic modal language, so we have to add
a new backward-looking modality as a primitive; doing so, of course, gives us the



7.1 Logical Modalities
basic temporal language. But note: we don’t have to bring in the concept of time
to justify this extension. If a binary relation
R is important, its converse is likely
to be too — so it’s simply common sense to consider adding a diamond for
R
. In
short, the ‘temporal operator’
P is really a logical modality.
The other important example is PDL. To motivate PDL we told a story about pro-
grams and transition systems — but a more abstract motivation is not only possible,
it’s more satisfying. The point is this. As soon as we ﬁx a collection of relations
R
, regular algebra is staring us in the face: we can combine these relations using
union and composition, and form transitive closures. Any model containing the
initial
R
 relations implicitly contains many other interesting relations as well —
so it’s natural to add extra modalities to deal with them explicitly, and doing so
yields PDL. As this example shows, we can go way beyond the idea of adding a
single new logical modality: we can add an entire algebra of diamonds. We’ll see
another example of this when we discuss BML.
The global modality
Throughout the book we’ve emphasized the locality of modal logic, and for many
purposes local languages are ideal. For example, suppose we’re working with a
modal language for talking about computer networks, and in this language
 means
Server 1 is active and
 means Server 2 is active. Then we can
check whether the network makes it possible for Server 1 to be active by check-
ing whether
 is satisﬁable, and we can check whether it is possible for Server
2 to be inactive by testing for the satisﬁability of
: .
But suppose we want to know if whenever Server 1 is active, then so is
Server 2. There’s no obvious way to test this. Testing for the satisﬁability
of

!
 does not answer this question: if

!
 is satisﬁable, this only means
that there is a state where either
 is false or
 is true. We want to know whether
every state that makes
 true is also a state that makes
 true. This is clearly a
global query. What are we to do?
Here’s an elegant answer: enrich the language language with the global modal-
ity. To keeps things simple, suppose we’re working in the basic modal language
over some ﬁxed choice of proposition letters; let’s call this language ML(3). We’ll
now add a second diamond, written E, and call the resulting language ML
(3; E
).
The interpretation of E is ﬁxed: in any model
M
=
(W
;
R
;
V
), E must be inter-
preted using the relation
W

W. That is:
M;
w
 E
 iff there is a
u
W such that
M;
u

:
Thus E scans the entire model for a state that satisﬁes
. Its dual A
:=
:E
: has
the following interpretation:
M;
w
 A
 iff
M;
u

; for all
u
W.



7 Extended Modal Logic
That is, A
 asserts that
 holds at all points in the model. In effect, A brings the
metatheoretic notion of global truth in a model down into the object language: for
any model
M, and any formula
, we have that
M

 iff A is satisﬁable in
M. We’ll call E the global diamond, and A the global box. When it’s irrelevant
whether we mean E or its dual, we’ll simply say global modality.
It should now be clear how to handle the computer network problem: to test
whether Server 2 is active whenever Server 1 is, we test the satisﬁability
not of

!
 , but of A(
!
 
). This query has exactly the global force required.
Well — this looks appealing. But what are the properties of this (obviously
richer) new language? Maybe introducing the global modality destroys the prop-
erties that make model logic attractive in the ﬁrst place! We’ve made an important
change, and we need to take a closer look at the consequences.
Now, we could begin by discussing the sublanguage ML(E) — but this is not
very interesting (it’s easy to see that E is just an S5 modality). Anyway (as our
server example shows) the main reason for adding logical modalities is to have
them available as additional tools. So the real question is: what does ML(3; E
)
offer that ML
(3) doesn’t? The most obvious answer is expressivity. Let’s ﬁrst
consider expressivity at the level of frames:
(R
=
W
2)
Ep
!
3p
(R
6=
?)
E3>
(9x8y
:R
xy)
E2
?
(8x9y
R
y
x)
p
! E
3p
(jW
j
=
1)
Ep
!
p
(jW
j

n)
V
n+1
i=1 E
p
i
!
W
i6=j E
(p
i
^
p
j
)
(R is trichotomous)
(p
^
2q
)
! A(q
_
p
_
3p)
(R
 is well-founded) A(2p
!
p)
!
p
None of the frame classes listed is deﬁnable in ML
(3), but (as we ask the reader
to check in Exercise 7.1.1) the ML
(3; E) formulas to their right do deﬁne the cor-
responding property.
Where does this extra frame expressivity come from? From trivializing the no-
tion of generated submodel (generating on
W

W always yields
W

W) and
rendering inapplicable the notion of disjoint union (for any disjoint frames
(W
;
R
)
and
(W
;
R
),
(W

W
)
]
(W

W
)
6=
(W
]
W
)

(W
]
W
)). By insisting
that E be interpreted using
W

W, we’ve trashed two of the classic modal preser-
vation results and thereby bought ourselves more expressivity. How much more?
For ﬁrst-order deﬁnable frame classes, the answer is elegant:
Theorem 7.1 A ﬁrst-order deﬁnable class of frames is deﬁnable in ML(3; E
) iff it
is closed under taking bounded morphic images, and reﬂects ultraﬁlter extensions.



7.1 Logical Modalities
This is exactly the Goldblatt-Thomason Theorem — minus closure under disjoint
unions and generated subframes.
There is also a gain of expressivity at the level of models (the server example
makes this clear, and we already know from Section 2.1 that the global modality
is not deﬁnable in the basic modal language). Moreover, we can measure the gain
using our old friends: bisimulations. It’s an easy exercise to adapt the deﬁnition
of bisimulation for the basic modal language to ML
(3; E), and a rather more de-
manding one to prove a van Benthem style characterization result for the language.
The reader is asked to attend to these matters in Exercises 7.1.3 and 7.1.4.
What about completeness? The set of valid ML
(3; E
) formulas can be axioma-
tized as follows. Take the minimal normal logic in
3 and E (that is, apply Deﬁni-
tion 4.13 to this two-diamond similarity type), and add the following axioms:
(reﬂexivity)
p
! E
p
(symmetry)
p
! AEp
(transitivity) EE
p
! E
p
(inclusion)
3p
! E
p
Note that ﬁrst three axioms are the familiar T, B, and 4 axioms (written in E and A
rather than
3 and
2). We discussed Inclusion in Example 1.29(4). We’ll call this
logic
K
g.
Theorem 7.2 K
g is strongly complete with respect to the class of all frames.
This theorem says that to lift the minimal logic K (for the basic modal language)
to ML
(3; E), we need merely treat the global modality as a normal operator that
satisﬁes four further axioms. In fact, we can lift any canonical ML
(3) logic in
this way. If
K  is a normal modal logic in ML
(3), let
K
g
  be the normal modal
logic in ML(3; E
) obtained by treating E as a normal operator and adding the four
axioms listed above. Then:
Theorem 7.3 Let
  be a set of ML(3) formulas, and let F be the class of frames
that
  deﬁnes. If
K  is canonical, then
K
g
  is strongly complete with respect to
F.
Proof. Let
M
=
(W
;
R
;
RE
;
V
) be the canonical model for
K
g
 . Note that as
K 
K
g
 , we have that
(W
;
R
) belongs to
F, for
K  is canonical. Indeed, any
generated subframe of
(W
;
R
) belongs
F, for validity in the basic modal language
is closed under generated subframes.
Given a
K
g
 -consistent set of sentences
, use Lindenbaum’s Lemma to ex-
pand it to an
K
g-MCS

+. By the Canonical Model Theorem,
M;

+

.
Now, (reﬂexivity), (symmetry), and (transitivity) are canonical formulas, thus
RE
is an equivalence relation. And although there is no guarantee that
RE is
W

W,



7 Extended Modal Logic
this is easy to correct: let
M
=
(W
;
R
;
R
E
;
V
) be the submodel of
M gener-
ated by

+ using the
RE-relation. Then
R
E
=
W

W
0, so we have the global
relation we need. Furthermore, because of Inclusion,
R

RE, thus
M
0 is also a
generated submodel of
M with respect to
R
3, hence
M
;

+

. It only remains
to observe that (by our initial remarks)
(W
;
R
) is in
F, hence the result follows.
(Theorem 7.2 is the special case in which
 =
?.)
a
Example 7.4 Suppose we’re working with ML(3) over transitive frames (so the
relevant logic is K4, which is canonical). Now, we may want to state global con-
straints on models, or insist that certain information holds somewhere or other, and
of course we can do this if we add the global modality. But how do we obtain a
complete logic for transitive frames in the enriched language?
Simply enrich K4 by treating the global modality as a normal operator and
adding the (reﬂexivity), (transitivity), (symmetry), and (inclusion) axioms. Doing
so yields K
g4, and by the theorem just proved this logic is strongly complete with
respect to the class of transitive frames.
a
What about decidability and complexity? We brieﬂy met the global modality in
Section 6.5, and we saw that its global reach makes it possible to force the exis-
tence of gridlike models. This led to undecidability results for languages contain-
ing several diamonds, and it’s not difﬁcult to adapt these arguments to ﬁnd frame
classes with decidable ML(3) logics and undecidable ML
(3; E
) logics (we give
such an example in Exercise 7.1.5). Moreover, although undecidability does not
strike over the class of all frames, K
g is probably more complex than K, for K
g has
an EXPTIME-complete satisﬁability problem (the reader was asked to prove this in
Exercises 6.8.1 and 6.8.2) while K is PSPACE-complete (see Section 6.7). On the
other hand, there is a rather nice transfer result concerning the ﬁltration method:
if we can prove the decidability of a ML
(3) logic by using ﬁltrations to establish
establish the strong ﬁnite frame property, then we can also do so after adding the
global modality. For example, it follows that the logic K
g4 (see Example 7.4) is
decidable. We’ll state and prove a stronger version of this result when we discuss
the difference operator.
All in all, the global modality is a strikingly natural extension of modal logic —
and at ﬁrst glance this seems surprising. How can something so obviously global
blend so well with the locality of modal logic? Basically, because the enriched
language still takes an internal perspective on relational structure. Although we
now have a global operator at our disposal, we still place formulas inside models
and evaluate them at a particular state. To put it another way, the intuition that
a modal formula is an automaton scanning accessible states is remarkably robust:
even if we add a special automaton programmed to regard all states as accessible,
we retain much of the characteristic ﬂavor of ordinary modal logic.



7.1 Logical Modalities
A lot more could be said about the global modality. For a start, it’s natural
when viewed from an algebraic perspective (it gives rise to discriminator vari-
eties). Moreover, the global modality can be added to many richer modal systems,
including PDL and the hybrid and multi-dimensional logics discussed later in the
chapter, often without raising the computational complexity (for example PDL is
EXPTIME-complete, and adding E doesn’t change this). But for more information
the reader will have to consult the Notes and Exercises, for it’s time to discuss an
even more powerful logical modality.
The difference operator
At the bottom of every toolbox lies a heavy cast-iron hammer. It’s not the sort
of tool we use every day — for delicate jobs it’s inappropriate, and we may feel
slightly embarrassed about using it at all. Still, there’ll always come a time when
something simply won’t budge, and then we ﬁnd ourselves reaching for it. Think
of the difference operator as that hammer.
Once again, we’ll start with ML
(3). We’ll add a second diamond D, the differ-
ence operator, and call the resulting language ML
(3; D). The interpretation of D
is ﬁxed: in any model
M
=
(W
;
R
;
V
), D must be interpreted using the inequality
relation
6=. That is:
M;
w
 D iff there is a
u
6=
w such that
M;
u

:
Thus the difference operator scans the entire model looking for a different state that
satisﬁes
. Its dual D
:=
:D
: has the following interpretation
M;
w
 D iff
M;
u

 for all
u
6=
w.
In what follows we discuss ML
(3; D
), but the sublanguage ML
(D) is quite inter-
esting in its own right, and we ask the reader is asked to explore it in Exercise 7.1.6.
Using the difference operator, we can deﬁne the global modality: E
:=

_D
.
Thus all our earlier examples of frame classes deﬁnable in ML
(3; E
) are deﬁnable
in ML
(3; D) too. But ML
(3; D
) can deﬁne even more:
(irreﬂexivity)
3p
! D
p
(antisymmetry)
(p
^
:D
p)
!
2(3p
!
p)
(9xy
(x
6=
y
))
D>
(jW
j
>
n)
A(
W
1in
p
i
)
! E
W
1in
(p
i
^ D
p
i
)
None of these frame classes is closed under bounded morphic images hence (by
Theorem 7.1) none of them is deﬁnable in ML
(3; E); but it is easy to see that the
listed ML
(3; D) formulas successfully capture them. Incidentally, we have already
seen that ML
(3; E
) can deﬁne
jW
j

n, thus as ML
(3; D
) can deﬁne
jW
j
>
n,
the difference operator can count states, at least as far as frames are concerned; in



7 Extended Modal Logic
Exercise 7.1.7 we ask the reader to investigate whether it can count over models as
well. Furthermore, note the
p
^
:D
p antecedent in the deﬁnition of antisymmetry.
This is only true when
p is true at exactly one state in the model: in effect we are
using the power of D to force
p to act as ‘name’ for a state; we’ll put this power to
good use shortly.
What about completeness? The set of valid ML
(3; D) formulas can be axioma-
tized as follows. Take the minimal normal logic in
3 and D, and add the following
axioms:
(symmetry)
p
! DD
p
(pseudo-transitivity) DD
p
!
(p
_ D
p)
(D-inclusion)
3p
!
p
_ Dp
We’ll call this logic
K
d. Now, it’s not particularly difﬁcult to prove the complete-
ness of
K
d (we ask the reader to do so in Exercise 7.1.8) — but it’s harder than
with
K
g (we have to do more than simply take a generated submodel) and the
result doesn’t extend to stronger logics so easily (there’s no obvious analog of The-
orem 7.3). Moreover, it’s easy to ﬁnd frame incompleteness results, indeed we can
even ﬁnd them in the sublanguage ML(D)! Things aren’t looking too good . . .
Enter the hammer. When we discussed rules for the undeﬁnable (Section 4.7) we
learned that proof rules which rely on ‘names’ can lead to general frame complete-
ness results. And as we noted above, the difference operator is powerful enough
to simulate state names, thus we can formulate the following rule of proof (the
D-rule):
`
(p
^
:D
p)
!

`

(Here
p is a proposition letter that doesn’t occur in
. The intuitions underlying
this rule are analogous to those underlying the IRR rule discussed in Section 4.7,
and we’ll leave it to the reader to verify that it preserves validity.) And now for a
remarkable result. The
D-rule neatly meshes with our earlier work on Sahlqvist
formulas to yield one of the most general completeness results known in modal
logic, the D-Sahlqvist theorem.
Here we only formulate a version in the basic temporal language. Consider the
language with operators
F,
P and D; let, for a set
 of axioms in this logic,
K
td

be the normal modal logic generated by the axioms of basic temporal logic, the
D-axioms and D-rule given above, and the formulas in
.
Theorem 7.5 Let
 be a collection of Sahlqvist formulas in the basic temporal
language. Then
K
td
 is strongly sound and complete with respect to the class of
bidirectional frames deﬁned by (the ﬁrst-order frame correspondents of) the axioms
in
.



7.1 Logical Modalities
Proof. We will prove weak completeness only. The ﬁrst step of the proof is to
prove the existence of a collection
W of maximal consistent sets such that
(i) each
  in
W contains a name, that is, a formula of the form

^
:D,
(ii) for each
  in
W and each formula
F
 
 , there is a
 in
W such that
  and
 are in the canonical accessibility relation
R
c
F for
F; and likewise,
for the operators
P and D.
(iii) for each pair of distinct points
  and
 in
W we have
R
c
D
 .
All of this can be proved in the style of Proposition 4.71.
It easily follows from (i) and (iii) above that
R
c
D is the inequality relation on
W.
But then the model on
W given by
V
(p)
=
f 2
W
j
p
 g is named; that
is, for every point in the model there is a formula which is true only at this point,
see Deﬁnition 4.76. However, condition (ii) allows us to prove a Truth Lemma
which implies that all axioms of the logic are true throughout the model. But then
it follows from Theorem 4.77 that the Sahlqvist axioms are valid on the underlying
frame as well.
a
The pinch of Theorem 7.5 lies in the fact that the ﬁrst-order frame correspondents
it mentions use inequality for the ‘relation symbol’ referring to the accessibility
relation of D. This means that we can automatically axiomatize frame properties
like irreﬂexivity or antisymmetry. The reader doubt the usefulness of this: isn’t
the logic of the class of irreﬂexive frames is identical to the logic of the class of
all frames? True, but this may change when we consider irreﬂexivity in addition
with other properties. Conditions like irreﬂexivity, undeﬁnable in themselves, may
nevertheless have ‘side effects’ so to speak. What we mean is that there are frame
classes
K such that the logic of
K differs from the logic of the irreﬂexive frames in
K. In such cases the above theorem can be of tremendous help.
In a surprisingly large number of cases we ﬁnd ourselves in the situation that
over a certain class of frames, the difference operator is deﬁnable in the underlying
modal language. For example, over the class of strict linear orders, the temporal
formula
F
p
_
P
p holds at a point if and only if
p holds at a different point. In
general, we say that a formula
Æ
(p) acts as D on a frame
F if
F

Æ
(p)
$ Dp; if
Æ
(p) acts as the difference operator on every frame in a class
K then we say that
Æ
deﬁnes D over
K.
Deﬁnability of the difference operator is of great use for axiomatizability, as the
following result shows. For a formula
Æ
(p), let
K
tÆ
 be the ‘Æ’-version of
K
td,
that is, the logic in the language without the D-operator obtained by replacing, in
all axioms and derivation rules of
K
td every formula D with
Æ
().
Theorem 7.6 Let
 be a collection of Sahlqvist formulas. Then
K
tÆ
 is strongly
sound and complete with respect to the class of those bidirectional frames on which
 is valid and on which
Æ acts as the difference operator.



7 Extended Modal Logic
In the section on multi-dimensional modal logic we will see an application of this
theorem; for a proof, we refer the reader to Exercise 7.1.9. We will examine another
name-driven proof rule (called PASTE) in detail when we discuss hybrid logic. First
we turn to decidability issues concerning the difference operator.
ML(3; D
) is a strong language. As it can deﬁne the global modality,
K
d must
have an EXPTIME-hard satisﬁability problem (in fact, the problem is EXPTIME-
complete; see Exercise 7.1.10) and it is even easier to ﬁnd undecidable logics
than in ML
(3; E
). Nonetheless, decidability is often retained. In particular, if
the ML
(3) logic of a class of frames can be proved decidable by using a ﬁltration
argument to establish the strong ﬁnite frame property, then the ML
(3; D
) logic of
that same frame class can be proved decidable in the same way. Let’s prove this.
Deﬁnition 7.7 Let
 be a logic, and let
F be a class of frames for
. We say that
 admits ﬁltrations on
F if for any model
M which is based on a frame in F, and
for any ﬁnite subformula closed set
 of ML
(3) formulas, there is a ﬁltration
M
f
of
M through
 which is based on a frame in
F.
a
Theorem 7.8 Suppose that
F is a class of frames, and that

F (the set of all
ML
(3)-formulas valid on
F) admits ﬁltrations on
F. Then the logic

d
F (the set
of all ML(3; D
)-formulas valid on
F) has the strong ﬁnite frame property with
respect to
F.
Proof. Let
 be a ML
(3; D)-formula satisﬁable in a model
M
=
(W
;
R
;
V
) of
which the underlying frame
(W
;
R
) is in
F. We want to show that
 is satisﬁable in
an
F-frame of bounded size.
Let
 be the set of subformulas of
. First consider the relation

 which holds
between two points if they satisfy the same formulas in
. As the points of our
ﬁnite model we would like to take the equivalence classes of this relation but this
would not work out well (it is instructive to see how the proof of the ﬁltration
lemma fails in the inductive step of the difference operator). The key idea of the
proof of the theorem is to solve this problem by splitting each equivalence class
in two parts — unless the original class is a singleton. To achieve this we add a
new proposition letter
d to the language and we make
d true at exactly one point of
each equivalence class. We would then like to ﬁltrate the new model according the
equivalence relation


[fdg.
There is still a problem however: we can only guarantee that the underlying
frame of the ﬁltrated model is in
F if we ﬁltrate through a set of ML(3) formulas.
But
 may contain formulas with occurrences of D. In order to get rid of these, we
employ a little technical trick. For every formula of the form D in
, choose a
distinct propositional variable
q
 that does not occur in any formula in
. Let
V
0 be
the valuation that differs from
V , if at all, only in that
V
(q
 
)
=
fw
j
M;
w
 D
 
g
and that
V
(d) is as indicated above. Let
M
0 be the model
(W
;
R
;
V
).



7.1 Logical Modalities
Now deﬁne the set

0 as follows. It is not difﬁcult to see that for every

 there is a unique ML
(3) formula

0 such that
 can be obtained from

0 by
replacing in

0 every proposition letter
q
 by D . Put

=
f
j


g
[
fd;
q
 
j D
 

g:
Observe that the formulas in

0 are D-free and that

0 is subformula closed. The
model
M
0 is (or can be seen as) an ML
(3)-model satisfying
M;
s

 iff
M
;
s


(7.1)
for all formulas
 in
. Let


0 hold between two points iff they satisfy the same
formulas in

0; it is easy to see that every

-equivalence class
jsj splits into
either one or two


0-equivalence classes, depending on whether
jsj has one or
more elements.
In any case, it follows from the assumption in the theorem that there is a ﬁltration
M
f through

0 which is based on a frame in
F. Note that by deﬁnition, the points
of
M
f are the


0-equivalence classes. We claim that this model
M
f satisﬁes the
following property for all ML
(3; D
)-formulas
 in
 and all states
s in
M:
M;
s

 iff
M
f
;
jsj

:
(7.2)
From this, the theorem is almost immediate.
The proof of (7.2) proceeds by a formula induction of which we omit the stan-
dard inductive steps concerning the boolean operators; the clauses for
3 are fairly
easy as well — but note that for one direction, one needs (7.1). For the case that
 is of the form D
 we also omit the easy right-to-left direction of (7.2). For the
other direction, suppose that
M;
s
 D . Then there is a point
s
6=
s such that
M;
s

 . If
jsj and
js
j are distinct then we are ﬁnished, so suppose otherwise.
But from
s


s
0 it follows on the one hand that
M;
s

d iff
M;
s

d, and
on the other hand, that
s and
s
0 belong to the same

-equivalence class. Since
we chose exactly one point in each

-class to satisfy
d, this means that neither
s nor
s
0 can be this special point. Hence, there must be another point
s
00 in this

-equivalence class which does make
d true. From
s


s
00 it follows that
M;
s

 , so by the inductive hypothesis we have that
M
f
;
js
j

 . But
js
j is
distinct from
jsj since
d holds at
s
00 and not at
s. This gives that
M
f
;
jsj
 D , as
required.
a
How does decidability follow? Any logic
 that admits ﬁltrations on F has the
strong ﬁnite frame property with respect to F — so if F is recursive we can apply
Theorem 6.7 and conclude that

F is decidable. But then by the result just proved,
we know that

d
F also has the strong ﬁnite frame property with respect to F, so we
can apply the model enumeration idea underlying the proof of Theorem 6.7 to for-
mulas of the richer languages. As D is always interpreted by the inequality relation,



7 Extended Modal Logic
and as this relation is obviously computable on ﬁnite structures, the decidability of

d
F follows.
A great deal more could be said about the difference operator (in particular,
bisimulations are easily adapted to cope with D, and a van Benthem style charac-
terization result is forthcoming; see Exercises 6.8.1 and 6.8.2) but it’s time to take
a brief look at a system containing a whole family of logical modalities.
Boolean modal logic
As we have remarked, as soon as we ﬁx a collection of relations
R
, we can form
the regular algebra over this base; building an algebra of diamonds corresponding
to these leads to PDL. But an even more obvious algebra demands attention: we can
also form the boolean algebra over base relations
R
. Why not deﬁne an algebra
of diamond corresponding to
1,
 ,
\, and
[? Doing so leads to Boolean Modal
Logic (BML).
We deﬁne the language of BML as follows. As with PDL, we ﬁx a set of primitive
relation symbols
a,
b,
c, . . . , and in addition a distinguished relation symbol
1.
From these we build complex relations using the relation constructors
 ,
\ and
[:
that is, if
 and
 are relation symbols, then so are
:,

\
, and

[
. BML
is the modal language containing a diamond
hi for each relation symbol
. In
principle we can interpret BML on any model of appropriate similarity type — that
is triples
M
=
(W
;
fR

j
 is a relation symbol
g;
V
) — but most such models
are inappropriate. We are only interested in boolean models, the models in which
R
=
W

W, and such that, for all relation symbols
 and
,
R
 
=
R
 (that
is,
(W

W
)
n
R
),
R
\
=
R

\
R
, and
R
[
=
R

[
R
.
BML is an expressive language — for a start, it contains the global modality
— and it may seem that we’ve bitten off more than we can chew. While the
[
constructor is well behaved (in particular
F

h
[

ip
$
hi
_
h
ip iff
R
[
=
R

[
R
), the
\ constructor is difﬁcult to work with. However, as we will now
see, with the help of the
  constructor we can get an exact grip on the relations of
interest.
First we deﬁne the following operator (often called window): for any relation
symbol
:
[
jj
]
:=
[ ]::
That is:
M;
w

[
jj
] iff
8u(M;
u


)
R

w
u):
Window is an extremely natural operator — once you’ve seen it, you wonder how
you ever managed without it. For example, if we read
[] as saying that all
executions of program
 lead to a
 state, then
[
jj
] says that only executions of



7.1 Logical Modalities
program
 can lead to a
 state, and it has other useful readings too (see the Notes)
But what concerns us here is the following result: window allows very smooth
deﬁnitions of the relations we are interested in.
Proposition 7.9 Let
F be a frame
(W
;
fR

j
 is a relation symbol
g). Then:
(i)
F

[ ]p
$
[
jj
]:p iff
R


R

(ii)
F

[]:p
$
[
j
 j
]p iff
R


R

(iii)
F

[
j
\

j
]p
$
[
jj
]p
^
[
j
j
]p iff
R
\
=
R

\
R
.
Proof. We prove the third claim. The right to left direction is trivial. For the left
to right direction, assume that
F

[
j
\

j
]p
$
[
jj
]p
^
[
j
j
]p. We need to show
that
R
\
=
R

\
R
. To see that
R
\

R

\
R
, suppose that
R
\
w
u, and
let
V be any valuation on
F such that
V
(p)
=
fug. Then
(F;
V
);
w

[
j
\

j
]p.
As
F

[
j
\

j
]p
$
[
jj
]p
^
[
j
j
]p we have
(F;
V
);
w

[
jj
]p
^
[
j
j
]p. But
u is the
only point satisfying
p, hence
R

w
u and
R

w
u. A similar argument shows that
R

\
R


R
\.
a
In a sense, the relations are divided into two kingdoms: the ordinary
[] modalities
govern relations built with
[, the widow modalities
[
jj
] govern the relations built
with
\, and the
  constructor acts as a bridge between the two realms. Moreover
the bridging function of
  also ﬁnds expression in a new rule of proof, BR. Unlike
the other additional rules discussed in this book, BR is not name-driven:
`
[]p
!
([
]p
!
[
]p)
`
[]p
!
([
j
j
]:p
!
[
j
j
]:p)
(BR
)
While it is possible to prove a completeness result for BML without using BR, its
use leads to an elegant axiomatization, for it enables us to thread negations through
the structured modalities.
A ﬁnal surprise is in store. In Theorem 6.31 we showed that the fragment con-
taining the
\ constructor and the global modality was undecidable over determin-
istic frames. Nonetheless, the minimal logic in BML actually turns out to be de-
cidable. All in all, BML is a fascinating system. For more information, see the
Notes.
Exercises for Section 7.1
7.1.1 We listed numerous frame conditions deﬁnable in ML
(3; E
) and ML(3; D
) which
were not deﬁnable in ML(3). Show that these deﬁnability claims are correct.
7.1.2 Show that ML
(3; E
) validity is preserved under bounded morphisms and reﬂects
ultraﬁlter extensions. (That is, show the easy direction of the Goldblatt-Thomason style
result for ML
(3; E
) stated in Theorem 7.1.) Can you prove the (far more demanding)
converse?



7 Extended Modal Logic
7.1.3 Extend the standard translation to the global modality and the difference opera-
tor. Extend the notion of bisimulation for the basic modal language to ML(3; E
) and
ML(3; D
), and show prove that your deﬁnition leads to an invariance result.
7.1.4 Building on the previous exercise, characterize the expressivity of ML
(3; E
) and
ML(3; D
) over models.
7.1.5 Let 2-3 be the class of frames
(W
;
R
) such that every state has 2
R-successors, and
R-successors of
R-successors. First show that the satisﬁability problem in ML(3) over
2-3 is decidable (note: this cannot be proved using a ﬁltration argument). Then show that
the satisﬁability problem in ML(3; E
) over 2-3 is undecidable. (It may be helpful to note
that this exercise is related to Exercise 6.5.2.)
7.1.6 Show that a class of frames is deﬁnable in ML
(D) if and only if it is deﬁnable in
the ﬁrst-order language over
= (that is, the ﬁrst-order language of equality). What is the
complexity of the satisﬁability problem for ML
(D)?
7.1.7 Clearly we can deﬁne in ML
(3; D
) an operator
Q with the following satisfaction
deﬁnition: for any model
M, any state
w in
M, and any formula
,
M;
w
j
=
Q iff there
is exactly one state
u in
M such that
M;
u
j
=
Q. But it is also possible in to deﬁne
modalities
Q
,
Q
,
Q
, and so on, that are satisﬁed when
 holds at precisely
Q
n
states
(n

2) in the model?
7.1.8 Show that
K
d is complete with respect to the class of all frames. (No need to try
anything fancy here — just ﬁddle with the canonical model.)
7.1.9 Prove Theorem 7.6. That is, let
 be a collection of Sahlqvist formulas in the basic
modal language. Show that
K
tÆ
 is strongly sound and complete with respect to the class
of those frames on which
 is valid and on which
Æ acts as the difference operator.
(Hint: use an auxiliary logic
K
tÆ

+ in the temporal language expanded with the difference
operator. Simply deﬁne this logic as having both the D and the
Æ versions of the D-axioms
and rules. Now ﬁrst use Theorem 7.5 to prove that this logic is sound and strongly complete
with respect to the class of
-frames on which
Æ acts as the difference operator. Then,
prove that
K
tÆ

+ is conservative over
K
tÆ
; that is, show that for every purely temporal
formula
, we have that
 belongs to
K
tÆ
 iff it belongs to
K
tÆ

+.)
7.1.10 Use an elimination of Hintikka sets argument to show that the
K
d satisﬁability
problem is solvable in EXPTIME.
