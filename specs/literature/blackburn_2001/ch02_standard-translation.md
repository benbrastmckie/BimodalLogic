<!-- Source: Blackburn, de Rijke & Venema (2001). Modal Logic. Cambridge University Press. Chapter 2: Models, §2.4 The Standard Translation and §2.5 Modal Saturation via Ultrafilter Extensions (pages 83-99). BibKey: Blackburn2001 -->

2.4 The Standard Translation
2.3.6 Finish the proof of Lemma 2.40. That is, prove that the ﬁltrations
R
s and
R
l are
indeed the smallest and the largest ﬁltration, respectively. In addition, give an example of
a model and a set of formulas for which
R
s and
R
l coincide.
2.3.7 Show that every transitive model
(W
;
R
;
V
) has a transitive temporal ﬁltration. (Take
care to specify what the ﬁltration does to
R
.)
2.3.8 Call a frame or model euclidean if it satisﬁes
8xy
z
((R
xy
^
R
xz
)
!
R
y
z
), and let
E be the class of euclidean models. Fix a formula
, and let
 be the smallest subformula
closed set of formulas containing
 that satisﬁes, for all formulas
 : if
3
, then
23 
. (Recall that
2 is an abbreviation of
:3:.) Note that in general,
 will be
inﬁnite.
(a) Prove that
E

3 
!
23 .
(b) Prove that every euclidean model can be ﬁltrated through
 to a euclidean model.
(c) Show that every euclidean model satisﬁes the following modal reduction principles:
$
33,
$
32,
$
33 and
$
32. That is, prove that
the formulas
333
$
33, ... are true throughout every euclidean model.
Conclude that
 is ﬁnite modulo equivalence on euclidean models.
(d) Prove that the basic modal similarity type has the ﬁnite model property with respect
to the class of euclidean models. Can you prove this result simply by ﬁltrating
through any subformula closed set of formulas containing
?
2.3.9 Show that any ﬁnite ﬁltration of a model based on the rationals with their usual or-
dering is a ﬁnite linear sequence of clusters, perhaps interspersed with singleton irreﬂexive
points, no two of which can be adjacent.
2.3.10 Consider the similarity type

! of arrow logic.
(i) Show that

! has the ﬁnite model property with respect to the class of all arrow
models.
(ii) Consider the class of arrow models based on arrow frames
F
=
(W
;
C
;
R
;
I
) such
that for all
s,
t and
u in
W we have (i)
C
stu iff
C
sut iff
C
tus and (ii)
C
stu and
I
u iff
s
=
t. Prove that arrow formulas have the ﬁnite model property with respect
to this class of arrow models.
(iii) Prove that

! does not have the ﬁnite model property with respect to the class of all
square models. (Hint: try to express that the extension of the propositional variable
p is a dense, linear ordering.)
2.4 The Standard Translation
In the Preface we warned the reader against viewing modal logic as an isolated
formal system (remember Slogan 3?), yet here we are, halfway through Chapter 2,
and we still haven’t linked modal logic with the wider logical world. We now put
this right. We deﬁne a link called the standard translation. This paves the way
for the results on modal expressivity in the sections that follow, for the study of
frames in the following chapter, and for the introduction of the guarded fragment
in Section 7.4.
We ﬁrst specify our correspondence languages — that is, the languages we will
translate modal formulas into.



2 Models
Deﬁnition 2.44 For
 a modal similarity type and
 a collection of proposition
letters, let
L

() be the ﬁrst-order language (with equality) which has unary pred-
icates
P
0,
P
1,
P
2, . . . corresponding to the proposition letters
p
0,
p
1,
p
2, . . . in
, and an
(n
+
1)-ary relation symbol
R
M for each (n-ary) modal operator
M in
our similarity type. We write
(x) to denote a ﬁrst-order formula
 with one free
variable,
x.
a
We are now ready to deﬁne the standard translation.
Deﬁnition 2.45 (Standard Translation) Let
x be a ﬁrst-order variable. The stan-
dard translation
ST
x taking modal formulas to ﬁrst-order formulas in
L

() is
deﬁned as follows:
ST
x
(p)
=
P
x
ST
x
(?)
=
x
6=
x
ST
x
(:)
=
:ST
x
()
ST
x
(
_
 
)
=
ST
x
()
_
ST
x
( 
)
ST
x
(M(
;
:
:
:
;

n
))
=
9y
:
:
:
9y
n
(R
M
xy
:
:
:
y
n
^
ST
y
(
)
^



^
ST
y
n
(
n
));
where
y
1, . . . ,
y
n are fresh variables (that is, variables that have not been used so far
in the translation). When working with the basic modal language, the last clause
boils down to:
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
Note that (to keep notation simple) we prefer to use
R rather than
R
3, and we
will continue to do this. We leave to the reader the task of working out what
ST
x
(O(
;
:
:
:
;

n
)) is, but we will point out that for the basic modal language
the required clause is:
ST
x
(2)
=
8y
(R
xy
!
ST
y
()):
a
Example 2.46 Let’s see how this works. Consider the formula
3(2p
!
q
).
ST
x
(3(2p
!
q
))
=
9y
(R
xy
^
ST
y
(2p
!
q
))
=
9y
(R
xy
^
(ST
y
(2p)
!
ST
y
(q
)))
=
9y
(R
xy
^
(8y
(R
y
y
!
ST
y
(p))
!
Qy
))
=
9y
(R
xy
^
(8y
(R
y
y
!
P
y
)
!
Qy
))
Note that (this version of) the standard translation leaves the choice of fresh vari-
ables unspeciﬁed. For example,
9y
(R
xy
^
(8y
(R
y
y
!
P
y
)
!
Qy
)) is a legitimate translation of
3(2p
!
q
), and indeed there are inﬁnitely



2.4 The Standard Translation
many others, all differing only in the bound variables they contain. Later in the
section we remove this indeterminacy — elegantly.
a
It should be clear that the standard translation makes good sense: it is essentially
a ﬁrst-order reformulation of the modal satisfaction deﬁnition. For any modal for-
mula
,
ST
x
() will contain exactly one free variable (namely
x); the role of this
free variable is to mark the current state; this use of a free variable makes it pos-
sible for the global notion of ﬁrst-order satisfaction to mimic the local notion of
modal satisfaction. Furthermore, observe that modalities are translated as bounded
quantiﬁers, and in particular, quantiﬁers bounded to act only on related states; this
is the obvious way of mimicking the local action of the modalities in ﬁrst-order
logic. Because of its importance it is worth pinning down just why the standard
translation works.
Models for modal languages based on a modal similarity type
 and a collection
of proposition letters
 can also be viewed as models for
L

(). For example,
if
 contains just a single diamond
3, then the corresponding ﬁrst-order language
L

() has a binary relation symbol
R and a unary predicate symbol corresponding
to each proposition letter in
 — and a ﬁrst-order model for this language needs to
provide an interpretation for these symbols. But a (modal) model
M
=
(W
;
R
;
V
)
supplies precisely what is required: the binary relation
R can be used to interpret
the relation symbol
R, and the set
V
(p
i
) can be used to interpret the unary predicate
P
i. This should not come as a surprise. As we emphasized in Chapter 1 (especially
Sections 1.1 and 1.3) there is no mathematical distinction between modal and ﬁrst-
order models — both modal and ﬁrst-order models are simply relational structures.
Thus it makes perfect sense to write things like
M
j
=
ST
x
()[w
], which means
that the ﬁrst-order formula
ST
x
() is satisﬁed (in the usual sense of ﬁrst-order
logic) in the model
M when
w is assigned to the free variable
x.
Proposition 2.47 (Local and Global Correspondence on Models) Fix a modal
similarity type
, and let
 be a
-formula. Then:
(i) For all
M and all states
w of
M:
M;
w

 iff
M
j
=
S
T
x
()[w
].
(ii) For all
M:
M

 iff
M
j
=
8x
ST
x
().
Proof. By induction on
. We leave this to the reader as Exercise 2.4.1.
a
Summing up: when interpreted on models, modal formulas are equivalent to ﬁrst-
order formulas in one free variable. Fine — but what does that give us? Lots!
Proposition 2.47 is a bridge between modal and ﬁrst-order logic — and we can use
this bridge to import results, ideas, and proof techniques from one to the other.
Example 2.48 First-order logic has the compactness property: if
 is a set of
ﬁrst-order formulas, and every every ﬁnite subset of
 is satisﬁable, then so is




2 Models
itself. It also has the downward L¨owenheim-Skolem property: if a set of ﬁrst-order
formulas has an inﬁnite model, then it has a countably inﬁnite model.
It follows that modal logic must have both these properties (over models) too.
Consider compactness. Suppose
 is a set of modal formulas every ﬁnite subset
of which is satisﬁable — is
 itself satisﬁable? Yes. Consider the set
fS
T
x
()
j


g. As every ﬁnite subset of
 has a model it follows (reading item (i) of
Proposition 2.47 left to right) that every ﬁnite subset of
fST
x
()
j


g does
too, and hence (by ﬁrst-order compactness) that this whole set is satisﬁable in some
model, say
M. But then it follows (this time reading item (i) of Proposition 2.47
right to left) that
 is satisﬁable in
M, hence modal satisﬁability over models is
compact.
And there’s interesting trafﬁc from modal logic to ﬁrst-order logic too. For ex-
ample, a signiﬁcant difference between modal and ﬁrst-order logic is that modal
logic is decidable (over arbitrary models) but ﬁrst-order logic is not. By using our
understanding of modal decidability, it is possible to locate novel decidable frag-
ments of ﬁrst-order logic, a theme we will return to in Section 7.4 when we discuss
the guarded fragment.
a
Just as importantly, the standard translation gives us a new research agenda for
investigating modal expressivity: correspondence theory. The central aim of this
chapter is to explore the expressivity of modal logic over models — but how is ex-
pressivity to be measured? Proposition 2.47 suggests an interesting strategy: try to
characterize the fragment of ﬁrst-order logic picked out by the standard translation.
It is obvious on purely syntactic grounds that the standard translation is not
surjective (standard translations of modal formulas contain only bounded quan-
tiﬁers) — but could every ﬁrst-order formula (in the appropriate correspondence
language) be equivalent to the translation of a modal formula? No. This is very
easy to see: whereas modal formulas are invariant under bisimulations, ﬁrst-order
formulas need not be; thus any ﬁrst-order formula which is not invariant under
bisimulations cannot be equivalent to the translation of a modal formula. We have
seen such a formula in Section 2.2, (namely
9y
y
y
(y
6=
y
^
y
6=
y
^
y
6=
y
^
R
xy
^
R
xy
^
R
y
y
^
R
y
y
)), and it is easy to ﬁnd simpler examples.
Thus the (ﬁrst-order formulas equivalent to) standard translations of model for-
mulas are a proper subset of the correspondence language. Which subset? Here’s
a nice observation. The standard translation can be reformulated so that it maps
every modal formula into a very small fragment of
L

(), namely a certain ﬁnite-
variable fragment. Suppose the variables of
L

() have been ordered in some way.
Then the
n-variable fragment of
L

() is the set of
L

() formulas that contain
only the ﬁrst
n variables. As we will now see, by judicious reuse of variables, a
modal language with operators of arity at most
n can be translated into the
n
+
1-
variable fragment of
L

(). (Reuse of variables is the name of the game when



2.4 The Standard Translation
working with ﬁnite variable fragments. For example, we can express the existence
of three different points in a linear ordering using only two variables as follows:
9xy
(x
<
y
^
9x
(y
<
x)).)
Proposition 2.49
(i) Let
 be a modal similarity type that only contains di-
amonds. Then, every
-formula
 is equivalent to a ﬁrst-order formula
containing at most two variables.
(ii) More generally, if
 does not contain modal operators
M whose arity ex-
ceeds
n, all
-formulas are equivalent to ﬁrst-order formulas containing at
most
n
+
1 variables.
Proof. Assume
 contains only diamonds
hai,
hbi, . . . ; proving the general case
is left as Exercise 2.4.2. Fix two distinct individual variables
x and
y. Deﬁne two
variants
ST
x and
ST
y of the standard translation as follows.
ST
x
(p) =
P
x
ST
y
(p) =
P
y
ST
x
(?) =
x
6=
x
ST
y
(?) =
y
6=
y
ST
x
(:) =
:ST
x
()
ST
y
(:) =
:ST
y
()
ST
x
(
_
 
) =
ST
x
()
_
ST
x
( 
)
ST
y
(
_
 
) =
ST
y
()
_
ST
y
( 
)
ST
x
(hai) =
9y
(R
a
xy
^
ST
y
())
ST
y
(hai) =
9x
(R
a
y
x
^
ST
x
()).
Then, for any
-formula
, its
ST
x-translation contains at most the two variables
x and
y, and
S
T
x
() is equivalent to the original standard translation of
.
a
Example 2.50 Let’s see how this modiﬁed standard translation works. Consider
again the formula
3(2p
!
q
).
ST
x
(3(2p
!
q
))
=
9y
(R
xy
^
ST
y
(2p
!
q
))
=
9y
(R
xy
^
(8x
(R
y
x
!
ST
x
(p))
!
Qy
))
=
9y
(R
xy
^
(8x
(R
y
x
!
P
x)
!
Qy
))
That is, we just keep ﬂipping between the two variables
x and
y. The result is
a translation containing only two variables (instead of the three used in Exam-
ple 2.46). As a side effect, the indeterminacy associated with the original version
of the standard translation has disappeared.
a
This raises another question: is every ﬁrst-order formula
(x) in two variables
equivalent to the translation of a basic modal formula? Again the answer is no.
There is even a ﬁrst-order formula in a single variable
x which is not equivalent
to any modal formula, namely
R
xx. To see this, assume for the sake of a con-
tradiction that
 is a modal formula such that
ST
x
() is equivalent to
R
xx. Let
M be a singleton reﬂexive model and let
w be the unique state in
M; obviously
(irrespective of the valuation)
M
j
=
R
xx[w
]. Let
N be a model based on the strict
ordering of the integers; obviously (again, irrespective of the valuation), for every



2 Models
integer
v,
N
j
=
:R
xx[v
]. Let
Z be the relation which links every integer with the
unique state in
M, and assume that the valuations in
N and
M are such that
Z is
a bisimulation (for example, make all proposition letters true at all points in both
models). As
M
j
=
R
xx[w
], it follows by Proposition 2.47 that
M;
w

 (after all,
by assumption
R
xx is equivalent to
ST
x
()). But for any integer
v, we have that
w
$
v, hence
N;
v

. Hence (again by Proposition 2.47 and our assumption
that
ST
x
() is equivalent to
R
xx) we have that
N
j
=
R
xx[v
], contradicting the
fact that
N
j
=
:R
xx[v
].
We will not discuss correspondence theory any further here, but in Section 2.6
we will prove one of its central results, the Van Benthem Characterization Theo-
rem: a ﬁrst-order formula is equivalent to the translation of a modal formula if and
only if it is invariant under bisimulations.
Proposition 2.47 is also going to help us investigate modal expressivity in other
ways, notably via the concept of deﬁnability.
Deﬁnition 2.51 Let
 be a modal similarity type,
C a class of
-models, and
  a
set of formulas over
. We say that
  deﬁnes or characterizes a class
K of models
within
C if for all models
M in
C we have that
M is in
K iff
M

 . If
C is
the class of all
-models, we simply say that
  deﬁnes or characterizes
K; we omit
brackets whenever
  is a singleton. We will say that a formula
 deﬁnes a property
whenever
 deﬁnes the class of models satisfying that property.
a
It is immediate from Proposition 2.47 that if a class of models is deﬁnable by a set
of modal formulas, then it is also deﬁnable by a set a ﬁrst-order formulas — but
this is too obvious to be interesting. The important way in which Proposition 2.47
helps, is by making it possible to exploit standard model construction techniques
from ﬁrst-order model theory. For example, in Section 2.6 we will prove Theo-
rem 2.75 which says that a class of (pointed) models is modally deﬁnable if and
only if it is closed under bisimulations and ultraproducts (an important construc-
tion known from ﬁrst-order model theory; see Appendix A), and its complement
is closed under ultrapowers (another standard model theoretic construction). It
would be difﬁcult to overemphasize the importance of the standard translation; it
is remarkable that such a simple idea can lead to so much.
To conclude this section, let’s see how to adapt these ideas to the basic temporal
language, PDL, and arrow logic. The case of basic temporal logic is easy: all we
have to do is add a clause for translating the backward looking operator
P:
ST
x
(P
)
=
9y
(R
y
x
^
ST
y
()):
Note that we are using the more sophisticated approach introduced in the proof
of Proposition 2.49: ﬂipping between two translations
ST
x and
ST
y. (Thus we
really need to add a mirror clause which ﬂips the variables back.) So, just like



2.4 The Standard Translation
the basic modal language, the basic temporal language can be mapped into a two
variable fragment of the correspondence language. Moreover (again, as with the
basic modal language) not every ﬁrst-order formula in two variables is equivalent
to (the translation of) a basic temporal formula (see Exercise 2.4.3).
Propositional dynamic logic calls for more drastic changes. Let’s ﬁrst look at the
-free fragment — that is, at PDL formulas without occurrences of the Kleene star.
In PDL both formulas and modalities are recursively structured, so we’re going to
need two interacting translation functions: one to handle the formulas, the other to
handle the modalities. The only interesting clause in the formula translation is the
following:
ST
x
(h
i)
=
9y
(ST
xy
(
)
^
ST
y
()):
That is, instead of returning a ﬁxed relation symbol (say
R), the formula translation
ST
x calls on
S
T
xy to start recursively decomposing the program
. Why does this
part of the translation require two free variables? Because its task is to deﬁne a
binary relation.
ST
xy
(a)
=
R
a
xy (and similarly for other pairs of variables)
ST
xy
(
[

)
=
ST
xy
(
)
_
ST
xy
(
)
ST
xy
(
;

)
=
9z
(ST
xz
(
)
^
ST
z
y
(
)):
It follows that we can translate the
-free fragment of PDL into a three variable
fragment of the correspondence language. The details are worth checking; see
Exercise 2.4.4.
But the really drastic change comes when we consider the full language of PDL
(that is, with Kleene star). Recall that a program

 is interpreted using the reﬂex-
ive, transitive closure of
R
. But the reﬂexive, transitive closure of an arbitrary
relations is not a ﬁrst-order deﬁnable relation (see Exercise 2.4.5). So the standard
translation for PDL needs to take us to a richer background logic than ﬁrst-order
logic, one that can express this concept. Which one should we use? There are
many options here, but to motivate our actual choice recall the deﬁnition of the
meaning of a PDL program

:
R


=
[
n
(R

)
n
;
where
R
n
 is deﬁned by
R
xy iff
x
=
y and
R
n+1
xy iff
9z
(R
n
xz
^
R
z
y
):
Thus, if we were allowed to write inﬁnitely long disjunctions, it would be easy to
capture the meaning of an iterated program

:
(R

)

xy iff
(x
=
y
)
_
R

xy
_
_
n1
9z
:
:
:
z
n
(R

xz
^



^
R

z
n
y
):



2 Models
In inﬁnitary logic we can do this. More precisely, in
L
!
! we are allowed to form
formulas as in ﬁrst-order logic, and, in addition, to build countably inﬁnite dis-
junctions and conjunctions. We will take
L
!
! as the target logic for the standard
translation of PDL. We have seen most of the clauses we need: we use the clauses
for the
-free fragment given above, and in addition the following clause to cater
for the Kleene star:
ST
xy
(

)
=
(x
=
y
)
_
ST
xy
()
_
_
n1
9z
:
:
:
z
n
(ST
xz
()
^



^
ST
z
n
y
()):
This example of PDL makes an important point vividly: we cannot always hope
to embed modal logic into ﬁrst-order logic. Indeed in the following chapter we
will see that when it comes to analyzing the expressive power of modal logic at
the level of frames, the natural correspondence language (even for the basic modal
language) is second-order logic.
There is nothing particularly interesting concerning the standard translation for
the arrow language of Example 1.16. However, this changes when we turn to
square models: in Exercise 2.4.6 the reader is asked to prove that on this class of
models, the arrow language corresponds to a ﬁrst-order language with binary pred-
icate symbols, and that, in fact, it is expressively equivalent to the three variable
fragment of such a language.
Exercises for Section 2.4
2.4.1 Prove Proposition 2.47. That is, check that the standard translation really is correct.
2.4.2 Prove Proposition 2.49 for arbitrary modal languages. That is, show that if
 does
not contain modal operators
M whose arity exceeds
n, all
-formulas are equivalent to
ﬁrst-order formulas containing at most
n
+
1 variables.
2.4.3 Show that there are ﬁrst-order formulas
(x) using at most two variables that are not
equivalent to the standard translation of a basic temporal formula.
2.4.4 In this exercise you should ﬁll in some of the details for the standard translation for
PDL.
(a) Check that the translation for the
-free fragment of PDL really does map all such
formulas into the three variable fragment of the corresponding ﬁrst-order language.
(b) Show that in fact, there is a translation into the two variable fragment of this corre-
sponding ﬁrst-order language.
2.4.5 The aim of this exercise is to show that taking the reﬂexive, transitive closure of a
binary relation is not a ﬁrst-order deﬁnable operation.
(a) Show that the class of connected graphs is not ﬁrst-order deﬁnable:



2.5 Modal Saturation via Ultraﬁlter Extensions
(i) For
l
N, let
C
l be the graph given by a cycle of length
l
+
1:
C
l
=
(f0;
:
:
:
;
l
g;
f(i;
i
+
1);
(i
+
1;
i)
j

i
<
l
g
[
f(0;
l
);
(l
;
0)g)
Show that for every
k
N and
l

k the graph
C
l satisﬁes the same ﬁrst-
order sentences of quantiﬁer rank at most
k as the disjoint union
C
l
]
C
l.
(ii) Conclude that the class of connected graphs is not ﬁrst-order deﬁnable.
(b) Use item (a) to conclude that the reﬂexive transitive closure of a relation is not
ﬁrst-order deﬁnable.
2.4.6 Consider the class of square models for arrow logic. Observe that a square model
M
=
(S
U
;
V
) can be seen as a ﬁrst-order model
M

=
(U;
V
(p))
p2 if we let each
propositional variable
p
 correspond to a dyadic relation symbol
P.
(a) Work out this observation in the following sense. Deﬁne a suitable translation
()

mapping an arrow formula
 to a formula


(x
;
x
) in this ‘dyadic correspondence
language’. Prove that this translation has the property that for all arrow formulas

and all square models
M the following correspondence holds:
M;
(a
;
a
)

 iff
M

j
=


(x
;
x
)[a
;
a
]:
(b) Show that this translation can be done within the three variable fragment of ﬁrst-
order logic.
(c) Prove that conversely, every formula
(x
;
x
) that uses only three variables, in a
ﬁrst-order language with binary predicates only, is equivalent to the translation of
an arrow formula on the class of square models.
2.5 Modal Saturation via Ultraﬁlter Extensions
Bisimulations and the standard translation are two of the tools we need to under-
stand modal expressivity over models. This section introduces the third: ultraﬁlter
extensions. To motivate their introduction, we will ﬁrst discuss Hennessy-Milner
model classes and modally saturated models; both generalize ideas met in our ear-
lier discussion of bisimulations. We will then introduce ultraﬁlter extensions as a
way of building modally saturated models, and this will lead us to an elegant result:
modal equivalence implies bisimilarity-somewhere-else.
M-saturation
Theorem 2.20 tells us that bisimilarity implies modal equivalence, but we have
already seen that the converse does not hold in general (recall Figure 2.5). The
Hennessy-Milner theorem shows that the converse does hold in the special case of
image-ﬁnite models. Let’s try and generalize this theorem.
First, when proving Theorem 2.24, we exploited the fact that, between image-
ﬁnite models, the relation of modal equivalence itself is a bisimulation. Classes of
models for which this holds are evidently worth closer study.



2 Models
Deﬁnition 2.52 (Hennessy-Milner Classes) Let
 be a modal similarity type, and
K a class of
-models.
K is a Hennessy-Milner class, or has the Hennessy-Milner
property, if for every two models
M and
M
0 in
K and any two states
w,
w
0 of
M
and
M
0, respectively,
w
!
w
0 implies
M;
w
$
M;
w
0.
a
For example, by Theorem 2.24, the class of image-ﬁnite models has the Hennessy-
Milner property. On the other hand, no class of models containing the two models
in Figure 2.5 has the Hennessy-Milner property.
We generalize the notion of image-ﬁniteness; doing so leads us to the concept of
modally-saturated or (brieﬂy) m-saturated models. Suppose we are working in the
basic modal language. Let
M
=
(W
;
R
;
V
) be a model, let
w be a state in
W, and
let

=
f
;

;
:
:
:
g be an inﬁnite set of formulas. Suppose that
w has successors
v
0,
v
1,
v
2, . . . where (respectively)

0,

^

1,

^

^

2, . . . hold. If there is no
successor
v of
w where all formulas from
 hold at the same time, then the model
is in some sense incomplete. A model is called m-saturated if incompleteness of
this kind does not occur.
To put it another way: suppose that we are looking for a successor of
w at
which every formula

i of the inﬁnite set of formulas

=
f
;

;
:
:
:
g holds.
M-saturation is a kind of compactness property, according to which it sufﬁces to
ﬁnd satisfying successors of
w for arbitrary ﬁnite approximations of
.
Deﬁnition 2.53 (M-saturation) Let
M
=
(W
;
R
;
V
) be a model of the basic
modal similarity type,
X a subset of
W and
 a set of modal formulas.
 is
satisﬁable in the set
X if there is a state
x
X such that
M;
x
j
=
 for all
 in
;
 is ﬁnitely satisﬁable in
X if every ﬁnite subset of
 is satisﬁable in
X.
The model
M is called m-saturated if it satisﬁes the following condition for
every state
w
W and every set
 of modal formulas.
If
 is ﬁnitely satisﬁable in the set of successors of
w,
then
 is satisﬁable in the set of successors of
w.
The deﬁnition of m-saturation for arbitrary modal similarity types runs as follows.
Let
 be a modal similarity type, and let
M be a
-model.
M is called m-saturated
if, for every state
w of
M and every (n-ary) modal operator
M
 and sequence

1, . . . ,

n of sets of modal formulas we have the following.
If for every sequence of ﬁnite subsets



1, . . . ,

n


n there are
states
v
1, . . . ,
v
n such that
R
w
v
:
:
:
v
n and
v


1, . . . ,
v
n


n,
then there are states
v
1, . . . ,
v
n in
M such that
R
w
v
:
:
:
v
n and
v


1, . . . ,
v
n


n.
a
Proposition 2.54 Let
 be a modal similarity type. Then the class of m-saturated
-models has the Hennessy-Milner property.



2.5 Modal Saturation via Ultraﬁlter Extensions
Proof. We only prove the proposition for the basic modal language. Let
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
) be two m-saturated models. It sufﬁces to prove
that the relation
! of modal equivalence between states in
M and states in
M
0 is a
bisimulation. We conﬁne ourselves to a proof of the forth condition of a bisimula-
tion, since the condition concerning the propositional variables is trivially satisﬁed,
and the back condition is completely analogous to the case we prove.
So, assume that
w,
v
W and
w
W
0 are such that
R
w
v and
w
!
w
0.
Let
 be the set of formulas true at
v. It is clear that for every ﬁnite subset
 of
 we have
M;
v

V
, hence
M;
w

V
. As
w
!
w
0, it follows that
M
;
w

V
, so
w
0 has an
R
0-successor
v
 such that
M
;
v


V
. In
other words,
 is ﬁnitely satisﬁable in the set of successors of
w
0; but, then, by
m-saturation,
 itself is satisﬁable in a successor
v
0 of
w
0. Thus
v
!
v
0.
a
Ultraﬁlter extensions
So the class of m-saturated models satisﬁes the Hennessy-Milner property — but
how do we actually build m-saturated models? To this end, we will now introduce
the last of the ‘big four’ model constructions: ultraﬁlter extensions. The ultraﬁlter
extension of a structure (model or frame) is a kind of completion of the original
structure. The construction adds states to a model in order to make it m-saturated.
Sometimes the result is a model isomorphic to the original (for example, when
the original model is ﬁnite) but when working with inﬁnite models, the ultraﬁlter
extension always adds lots of new points. power set algebra of a frame; we have
met this operation already in Section 1.4 when we introduced general frames, but
we repeat the deﬁnition here.
Deﬁnition 2.55 Let
 be a modal similarity type, and
F
=
(W
;
R
M
)
M2 a
-frame.
For each
(n
+
1)-ary relation
R
M, we deﬁne the following two operations
m
M and
m
Æ
M on the power set
P
(W
) of
W.
m
M
(X
;
:
:
:
;
X
n
)
:=
fw
W
j there exist
w
;
:
:
:
;
w
n such that
R
M
w
w
:
:
:
w
n and
w
i
X
i for all
ig
m
Æ
M
(X
;
:
:
:
;
X
n
)
:=
fw
W
j for all
w
;
:
:
:
;
w
n: if
R
M
w
w
:
:
:
w
n,
then there is an
i with
w
i
X
i
g:
a
In the basic modal language
m
(X
) is the set of points that ‘can see’ a state in
X,
and
m
Æ
(X
) is the set of points that ‘only see’ states in
X. It follows that for any
model
M
V
(3)
=
m
(V
()) and
V
(2)
=
m
Æ
(V
()):
Similar identities hold for modal operators of higher arity. Furthermore,
m
M and
m
Æ
M are each other’s dual, in the following sense:



2 Models
Proposition 2.56 Let
 be a modal similarity type, and
F
=
(W
;
R
M
)
M2 a
-
frame. For every
n-ary modal operator
M and for every
n-tuple
X
;
:
:
:
;
X
n of
subsets of
W, we have
m
Æ
M
(X
;
:
:
:
;
X
n
)
=
W
n
m
M
(W
n
X
;
:
:
:
;
W
n
X
n
):
Proof. Left to the reader.
a
We are ready to deﬁne ultraﬁlter extensions. As the name is meant to suggest, the
states of the ultraﬁlter extension of a model
M are the ultraﬁlters over the universe
of
M. Filters and ultraﬁlters are discussed in Appendix A. Readers that encounter
this notion for the ﬁrst time, are advised to make the Exercises 2.5.1–2.5.4.
Deﬁnition 2.57 (Ultraﬁlter Extension) Let
 be a modal similarity type, and
F
=
(W,
R
M
)
M2 a
-frame. The ultraﬁlter extension
ue
F of
F is deﬁned as
the frame
(Uf
(W
);
R
ue
M
)
M2. Here
Uf
(W
) is the set of ultraﬁlters over
W and
R
ue
M
u
u
:
:
:
u
n holds for a tuple
u
;
:
:
:
;
u
n of ultraﬁlters over
W if we have that
m
M
(X
;
:
:
:
;
X
n
)
u
0 whenever
X
i
u
i (for all
i with

i

k).
The ultraﬁlter extension of a
-model
M
=
(F;
V
) is the model
ue
M
=
(ue
F,
V
ue
) where
V
ue
(p
i
) is the set of ultraﬁlters of which
V
(p
i
) is a member.
a
What are the intuitions behind this deﬁnition? First, note that the main ingredients
have a logical interpretation. Any subset of a frame can, in principle, be viewed as
(the extension or interpretation of) a proposition. A ﬁlter over the universe of the
frame can thus be seen as a theory, in fact as a logically closed theory, since ﬁlters
are both closed under intersection (conjunction) and upward closed (entailment).
Viewed this way, a proper ﬁlter is a consistent theory, for it does not contain the
empty set (falsum). Finally, an ultraﬁlter is a complete theory, or as we will call it,
a state of affairs: for each proposition (subset of the universe) an ultraﬁlter decides
whether the proposition holds (is a member of the ultraﬁlter) or not.
How does this relate to ultraﬁlter extensions? In a given frame
F not every state
of affairs need be ‘realized’, in the sense that there is a state satisfying all and
only the propositions belonging to the state of affairs; only the states of affairs that
correspond to the principal ultraﬁlters are realized, namely, as the points of the
frame. We build
ue
F by adding every state of affairs for
F as a new element of the
domain — that is,
ue
F realizes every proposition in
F.
How should we relate these new elements in
ue
F to each other and to the original
elements from
F? The obvious choice is to stipulate that
R
ue
u
u
:
:
:
u
n if
u
‘sees’ the
n-tuple
u
1, . . . ,
u
n. That is, whenever
X
1, . . . ,
X
n are propositions of
u
1, . . . ,
u
n respectively, then
u
0 ‘sees’ this combination: that is, the proposition
m
M
(X
;
:
:
:
;
X
n
) is a member of
u
0. The deﬁnition of the valuation
V
ue is self-
explanatory.



2.5 Modal Saturation via Ultraﬁlter Extensions
One ﬁnal comment: a special role in this section is played by the so-called prin-
cipal ultraﬁlters over
W. Recall that, given an element
w
W, the principal
ultraﬁlter

w generated by
w is the ﬁlter generated by the singleton set
fw
g: that
is,

w
=
fX

W
j
w
X
g. By identifying a state
w of a frame
F with the prin-
cipal ultraﬁlter

w, it is easily seen that any frame
F is (isomorphic to) a submodel
(but in general not a generated submodel) of its ultraﬁlter extension. For we have
the following equivalences (here proved for the basic modal similarity type):
R
w
v
iff
w
m
(X
) for all
X

W such that
v
X
iff
m
(X
)

w for all
X

W such that
X

v
(2.1)
iff
R
ue

w

v
:
Let’s make our discussion more concrete by considering an example.
Example 2.58 Consider the frame
N
=
(N
;
<) (the natural numbers in their usual
ordering):
u
u
u
u
u
. . .
-
-
-
-
-
What is the ultraﬁlter extension of
N? There are two kinds of ultraﬁlters over an
inﬁnite set: the principal ultraﬁlters that are in 1–1 correspondence with the points
of the set, and the non-principal ones which contain all co-ﬁnite sets, and only
inﬁnite sets, cf. Exercise 2.5.4. We have just remarked (see (2.1)) that the principal
ultraﬁlters form an isomorphic copy of the frame
N inside
ue
N. So where are
the non-principal ultraﬁlters situated? The key fact here is that for any pair
u,
u
0 of
ultraﬁlters, if
u
0 is non-principal, then
R
ue
uu
0. To see this, let
u
0 be a non-principal
ultraﬁlter, and let
X
u
0. As
X is inﬁnite, for any
n
N there is an
m such that
n
<
m and
m
X. This shows that
m
(X
)
=
N. But
N is an element of every
ultraﬁlter
u.
This shows that the ultraﬁlter extension of
N looks like a gigantic balloon at the
end of an inﬁnite string: it consists of a copy of
N, followed by an large (uncount-
able) cluster consisting of all the non-principal ultraﬁlters:
t
t
t
t
t
. . .
-
-
-
-
-




t
t
t
t
t
t
t
t
t
t
t
a
We will prove two results concerning ultraﬁlter extensions. The ﬁrst one, Proposi-
tion 2.59, is an invariance result: any state in the original model is modally equiv-
alent to the corresponding principal ultraﬁlter in the ultraﬁlter extension. Then, in
Proposition 2.61 we show that ultraﬁlter extensions are m-saturated. Putting these
two facts together leads us to the main result of this section: two states are modally
equivalent iff their representatives in the ultraﬁlter extensions are bisimilar.



2 Models
Proposition 2.59 Let
 be a modal similarity type, and
M a
-model. Then, for
any formula
 and any ultraﬁlter
u over
W,
V
()
u iff
ue
M;
u

. Hence, for
every state
w of
M we have
w
!

w.
Proof. The second claim of the proposition is immediate from the ﬁrst one by the
observation that
w

 iff
w
V
() iff
V
()

w.
The proof of the ﬁrst claim is by induction on
. The basic case is immediate
from the deﬁnition of
V
ue. The proofs of the boolean cases are straightforward
consequences of the deﬁning properties of ultraﬁlters. As an example, we treat
negation; suppose that
 is of the form
: , then
V
(: 
)
u
iff
W
n
V
( 
)
u
iff
V
( 
)
u
iff
ue
M;
u
6
 
(induction hypothesis)
iff
ue
M;
u

: 
:
Next, consider the case where
 is of the form
3 (we only treat the basic modal
similarity type, leaving the general case as an exercise to the reader). Assume ﬁrst
that
ue
M;
u

3 . Then, there is an ultraﬁlter
u
0 such that
R
ue
uu
0 and
ue
M;
u

 . The induction hypothesis implies that
V
( 
)
u
0, so by the deﬁnition of
R
ue,
m
(V
( 
))
u. Now the result follows immediately from the observation that
m
(V
( 
))
=
V
(3 
).
The left-to-right implication requires a bit more work. Assume that
V
(3 
)
u.
We have to ﬁnd an ultraﬁlter
u
0 such that
V
( 
)
u
0 and
R
ue
uu
0. The latter con-
straint reduces to the condition that
m
(X
)
u whenever
X
u
0, or equivalently
(see Exercise 2.5.5):
u
:=
fY
j
m
Æ
(Y
)
ug

u
:
We will ﬁrst show that
u
0 is closed under intersection. Let
Y ,
Z be members of
u
0. By deﬁnition,
m
Æ
(Y
) and
m
Æ
(Z
) are in
u. But then
m
Æ
(Y
\
Z
)
u, as
m
Æ
(Y
\
Z
)
=
m
Æ
(Y
)
\
m
Æ
(Z
), as a straightforward proof shows. This proves
that
Y
\
Z
u
0.
Next we make sure that for any
Y
u
0,
Y
\
V
( 
)
6=
?. Let
Y be an ar-
bitrary element of
u
0, then by deﬁnition of
u
0,
m
Æ
(Y
)
u. As
u is closed
under intersection and does not contain the empty set, there must be an element
x in
m
Æ
(Y
)
\
V
(3 
). But then
x must have a successor
y in
V
( 
). Finally,
x
m
Æ
(Y
) implies
y
Y .
¿From the fact that
u
0 is closed under intersection, and the fact that for any
Y
u
0,
Y
\
V
( 
)
6=
?, it follows that the set
u
[
fV
( 
)g has the ﬁnite intersection
property. So the Ultraﬁlter Theorem (Fact A.14 in the Appendix) provides us with
an ultraﬁlter
u
0 such that
u
[
fV
( 
)g

u
0. This ultraﬁlter
u
0 has the desired
properties: it is clearly a successor of
u, and the fact that
ue
M;
u

 follows
from
V
( 
)
u
0 and the induction hypothesis.
a



2.5 Modal Saturation via Ultraﬁlter Extensions
Example 2.60 As with the invariance results of Section 2.1 (disjoint unions, gen-
erated submodels, and bounded morphisms), our new invariance result can be used
to compare the relative expressive power of modal languages. Consider the modal
constant
	 whose truth deﬁnition in a model for the basic modal language is
M;
w

	 iff
M
j
=
R
xx[v
] for some
v in
M.
Can such a modality be deﬁned in the basic modal language? No — a bisimulation
based argument given at the end of the previous section already establishes this.
Alternatively, we can see this by comparing the pictures of the frames
(N
;
<) and
its ultraﬁlter extension given in Example 2.58. The former is loop-free (thus in any
model over this frame,
ue
M;

6
	), but the later contains uncountably many
loops (thus
ue
M;


	). So if we want
	 we have to add it as a primitive.
a
Proposition 2.61 Let
 be a modal similarity type, and let
M be a
-model. Then
ue
M is m-saturated.
Proof. We only prove the proposition for the basic modal similarity type. Let
M
=
(W
;
R
;
V
) be a model; we will show that its ultraﬁlter extension
ue
M is m-
saturated. Consider an ultraﬁlter
u over
W, and a set
 of modal formulas which
is ﬁnitely satisﬁable in the set of successors of
u. We have to ﬁnd an ultraﬁlter
u
such that
R
ue
uu
0 and
ue
M;
u

. Deﬁne

=
fV
()
j


g
[
fY
j
m
Æ
(Y
)
ug;
where

0 is the set of (ﬁnite) conjunctions of formulas in
. We claim that the set
 has the ﬁp. Since both
fV
()
j


g and
fY
j
m
Æ
(Y
)
ug are closed
under intersection, it sufﬁces to prove that for an arbitrary


0 and an arbitrary
set
Y

W for which
m
Æ
(Y
)
u, we have
V
()
\
Y
6=
?. But if


0, then
by assumption, there is a successor
u
00 of
u such that
ue
M;
u

, or, in other
words,
V
()
u
00. Then,
m
Æ
(Y
)
u implies
Y
u
00 by Exercise 2.5.5. Hence,
V
()
\
Y is an element of the ultraﬁlter
u
00 and, therefore, cannot be identical to
the empty set.
It follows by the Ultraﬁlter Theorem that
 can be extended to an ultraﬁlter
u
0.
Clearly,
u
0 is the required successor of
u in which
 is satisﬁed.
a
We have ﬁnally arrived at the main result of this section: a characterization of
modal equivalence as bisimilarity-somewhere-else — namely, between ultraﬁlter
extensions.
Theorem 2.62 Let
 be a modal similarity type, and let
M and
M
0 be
-models,
and
w,
w
0 two states in
M and
M
0, respectively. Then
M;
w
!
M
;
w
0 iff
ue
M;

w
$
ue
M
;

w
:



2 Models
Proof. Immediate by Propositions 2.59, 2.61 and 2.54.
a
Three remarks. First, it is easy to deﬁne ultraﬁlter extensions and prove an analog
of Theorem 2.62 for the basic temporal logic and arrow logic; see Exercises 2.5.8
and 2.5.9. With PDL the situation is a bit more complex; see Exercise 2.5.11. (The
problem is that the property of one relation being the reﬂexive transitive closure
of another is not preserved under taking ultraﬁlter extensions.) Second, we have
not seen the last of ultraﬁlter extensions. Like disjoint unions, generated submod-
els, and bounded morphisms, ultraﬁlter extensions are a fundamental modal model
construction technique, and we will make use of them when we discuss frames (in
Chapter 3) and algebras (in Chapter 5). We will shortly see that ultraﬁlter exten-
sions tie in neatly with ideas from ﬁrst-order model theory — and we will use this
to prove a second bisimilarity-somewhere-else result, Lemma 2.66. Finally, some
readers may still have the feeling that taking the ultraﬁlter extension of a model is
a far less natural construction than the other model operations that we have met.
These readers are advised to hold on until (or take a peek ahead towards) Chapter 5,
where we will see that ultraﬁlter extensions are indeed a very natural byproduct of
modal logic’s duality theory.
Exercises for Section 2.5
2.5.1 Let
E be any subset of
P
(W
), and let
F be the ﬁlter generated by
E.
(a) Prove that indeed,
F is a ﬁlter over
W. (Show that in general, the intersection of a
collection of ﬁlters is again a ﬁlter.)
(b) Show that
F is the set of all
X
P
(W
) such that either
X
=
W or for some
Y
1,
...,
Y
n
E,
Y
\



\
Y
n

X
:
(c) Prove that
F is proper (that is: it does not coincide with
P
(W
)) iff
E has the ﬁnite
intersection property.
2.5.2 Let
W be a non-empty set, and let
w be an element of
W. Show that the principal
ultraﬁlter generated by
w, that is, the set
fX
P
(W
)
j
w
X
g, is indeed an ultraﬁlter
over
W.
2.5.3 Let
F be a ﬁlter over
W.
(a) Prove that
F is an ultraﬁlter if and only if it is proper and maximal, that is, it has
no proper extensions.
(b) Prove that
F is an ultraﬁlter if and only if it is proper and for each pair of subsets
X
;
Y of
W we have that
X
[
Y
F iff
X
F or
Y
F.
2.5.4 Let
W be an inﬁnite set. Recall that
X

W is co-ﬁnite if
W
n
X is ﬁnite.
(a) Prove that the collection of co-ﬁnite subsets of
W has the ﬁnite intersection prop-
erty.
(b) Show that there are ultraﬁlters over
W that do not contain any ﬁnite set.



2.5 Modal Saturation via Ultraﬁlter Extensions
(c) Prove that an ultraﬁlter is non-principal if and only if it contains only inﬁnite sets
if and only if it contains all co-ﬁnite sets.
(d) Prove that any ultraﬁlter over
W has uncountably many elements.
2.5.5 Given a model
M
=
(W
;
R
;
V
) and two ultraﬁlters
u and
v over
W, show that
R
ue
uv if and only if
fY
j
m
Æ
(Y
)
ug

v.
2.5.6 Let
B
=
(B
;
R
) be the transitive binary tree; that is,
B is the set of ﬁnite strings of
0s and
1s, and
R

 holds if
 is a proper initial segment of
. The aim of this exercise is
to prove that any non-principal ultraﬁlter over
B determines an inﬁnite string of
0s and
1s.
To this end, let
B
! be the set of ﬁnite and inﬁnite strings of 0s and 1s, and
R
! the relation
on
B
! given by
R

 if
 is an initial segment of
. Deﬁne a function
f
:
Uf
(B
)
!
B
!
such that for all ultraﬁlters over
B we have
uR
ue
v iff
f
(u)R
!
f
(v
).
2.5.7 Give an example of a model
M which is point-generated while its ultraﬁlter exten-
sion is not.
2.5.8 Develop a notion of ultraﬁlter extension for basic temporal logic, and establish an
analog of Theorem 2.62 for basic temporal logic.
2.5.9 Develop a notion of ultraﬁlter extension for the arrow language introduced in Exam-
ple 1.14, and establish an analog of Theorem 2.62 for this language.
2.5.10 Show that, in general, ﬁrst-order formulas are not preserved under ultraﬁlter ex-
tensions. That is, give a model
M, a state
w, and a ﬁrst-order formula
(x) such that
M
j
=
(x)[w
], but
ue
M
6j
=
(x)[
w
], where

w is the principal ultraﬁlter generated by
w.
2.5.11 Consider a modal similarity type with two diamonds,
3 and
hi, and take any
model
M
=
(S;
R
;
R

;
V
) with
S
=
N
[
f1g;
R
=
f(n
+
1;
n);
(1;
n)
j
n
N
g;
R

=
f(m;
n)
j
m;
n
N
;
m

ng
[
(f1g

S
):
Note that
R
 is the reﬂexive transitive closure of
R.
(a) Show that
M;

2hi2?.
(b) Let
u be an arbitrary non-principal ultraﬁlter over
S. Prove that
R
ue

u.
(c) Let
u be an arbitrary non-principal ultraﬁlter over
S. Prove that
u has an
R
ue-
successor in
ue
M, and that each of its
R
ue-successors is again a non-principal
ultraﬁlter.
(d) Now suppose that we add an new diamond
h?i to the language, and that in the
model
ue
M we take
R
? to be the reﬂexive transitive closure of
R
ue. Show that
ue
M;


3[?]3>.
(e) Prove that
R
ue

6=
R
? (hint: use Proposition 2.59), and conclude that the ultraﬁlter
extension of a regular PDL-model need not be a regular PDL-model.
(f) Prove that every non-principal ultraﬁlter over
S has a unique
R
ue-successor.



2 Models
