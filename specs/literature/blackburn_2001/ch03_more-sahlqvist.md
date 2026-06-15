<!-- Source: Blackburn, de Rijke & Venema (2001). Modal Logic. Cambridge University Press. Chapter 3: Frames, §3.7 More about Sahlqvist Formulas (pages 168-179). BibKey: Blackburn2001 -->

3.7 More about Sahlqvist Formulas
It is time to step back and think more systematically about the Sahlqvist fragment,
for a number of questions need addressing. For a start, does this fragment con-
tain all modal formulas with ﬁrst-order correspondents? And why did we forbid
disjunctions in the scope of boxes, and occurrences of nested duals of triangles
in Sahlqvist antecedents, while we allowed boxed atoms? Most interesting of all,
which ﬁrst-order conditions are expressible by means of Sahlqvist formulas? That
is, is it possible to prove some sort of converse to the Sahlqvist Correspondence
Theorem?
Limitative results
To set the stage for our discussion, we ﬁrst state (without proof) the principal limi-
tative result in this area: Chagrova’s Theorem. Good presentations of the proof are
available in the literature; see the Notes for references.
Theorem 3.56 (Chagrova’s Theorem) It is undecidable whether an arbitrary ba-
sic modal formula has a ﬁrst-order correspondent.
This implies that, even for the basic modal language, it is not possible to write
a computer program which when presented with an arbitrary modal formula as
input, will terminate after ﬁnitely many steps, returning the required ﬁrst-order
correspondent (if there is one) or saying ‘No!’ (if there isn’t).
Quite apart from its intrinsic interest, this result immediately tells us that the
Sahlqvist fragment cannot possibly contain all modal formulas with ﬁrst-order cor-
respondents. For it is straightforward to decide whether a modal formula is a Sahl-
qvist formula, and to compute the ﬁrst-order correspondents of Sahlqvist formulas.
Hence if all modal formulas with ﬁrst-order correspondents were Sahlqvist, this
would contradict Chagrova’s Theorem.



3.7 More about Sahlqvist Formulas
But a further question immediately presents itself: is every modal formula with
a ﬁrst-order correspondent equivalent to a Sahlqvist formula? (The preceding ar-
gument does not rule this out.) The answer is no: there are modal formulas corre-
sponding to ﬁrst-order frame conditions which are not equivalent to any Sahlqvist
formula.
Example 3.57 Consider the conjunction of the following two formulas:
(M)
3p
!
3p
(4)
33q
!
3q.
(M) is the McKinsey formula we discussed in Example 3.11, and (4) is the transitiv-
ity axiom. It is obvious that M itself is not a Sahlqvist axiom, and by Example 3.11
it does not express a ﬁrst-order condition.
It requires a little argument to show that the conjunction
M
^
4 is not equivalent
to a Sahlqvist formula. One way to do so is by proving that
M
^
4 does not have a
local ﬁrst-order correspondent (cf. Exercise 3.7.1).
Nevertheless, the conjunction
M
^
4 does have a ﬁrst-order correspondent, as we
can prove the following equivalence for all transitive frames
F:
F

M iff
F
j
=
8x9y
(R
xy
^
8z
(R
y
z
!
z
=
y
)):
(3.17)
We leave the right to left direction as an exercise to the reader. To prove the other
direction, we reason by contraposition. That is, we assume that there is a transitive
frame
F
=
(W
;
R
) on which the McKinsey formula is valid, but which does not
satisfy the ﬁrst-order formula given in (3.17). Let
r be a state witnessing that the
ﬁrst-order formula in (3.17) does not hold in
F. That is, assume that each successor
s of
r has a successor distinct from it. We may assume that the frame is generated
from
r, so that
F
j
=
8y
9z
(R
y
z
^
y
6=
z
).
In order to derive a contradiction from this, we need to introduce some terminol-
ogy. Call a subset
X of
W coﬁnal in
W if for all
w
W there is an
x
X such
that
R
w
x. We now claim that
W has a subset
X such that both
X and
W
n
X are coﬁnal in
W
:
(3.18)
From (3.18) we can immediately derive a contradiction by considering the valua-
tion
V given by
V
(p)
=
X. For, coﬁnality of
X implies that
(F;
V
);
r

23p,
while coﬁnality of
W
n
X likewise gives
(F;
V
);
r

23:p. But then
(F;
V
);
r
6
M.
To prove (3.18), consider the collection
C of all pairs of disjoint subsets
Y ,
Z

W satisfying
8y
Y
9z
Z
R
y
z and
8z
Z
9y
Y
R
z
y. This set is non-
empty because
F
j
=
8y
9z
(R
y
z
^
y
6=
z
); order it under coordinate-wise inclusion.
It is obvious that every chain in this partial ordering is bounded above; hence, we



3 Frames
may apply Zorn’s Lemma and obtain a maximal such pair
Y ,
Z. We claim that
Y
[
Z
=
W
(3.19)
Since
Y and
Z are disjoint, this implies that
Z
=
W
n
Y and thus proves (3.18).
Suppose that (3.19) does not hold. Then there is an element
w
W which
belongs neither to
Y nor to
Z. If there were some
z
Z with
R
w
z then the
pair
(Y
[
fw
g;
Z
) would belong to
C, contradicting the maximality of
(Y
;
Z
).
Likewise, there is no
y
Y with
R
w
y. Even so, we will deﬁne non-empty sets
Y
;
Z
0 such that
(Y
[
Y
;
Z
[
Z
)
C, again contradicting the maximality of
(Y
;
Z
). First put
w in
Y
0. Now choose an element
z
1 of
W such that
R
w
z
1 and
w
6=
z
1 and put
z
1 in
Z
0 — remember that
z
Y
[
Z. Then choose an element
y
1 of
W such that
R
z
y
1 and
z
6=
y
1 and put
y
1 into
Y
0. Continue this process
and observe that none of the
y
n
;
z
n will belong to
Y
[
Z; this is by transitivity of
R and our assumption on
w.
The process will ﬁnish if, for instance, some
u has just been put in
Z
0, but all of
its successors have already been put in
Y
[
Z
0 at some earlier state. In such a case
we break off the process; at this moment it is obvious that each
y
Y
[
Y
0 has
a successor in
Z
[
Z
0, and that each
z
Z
[
Z
0 distinct from
u has a successor
in
Y
[
Y
0. To show that
u itself has a successor in
Y
0, let
v be the ﬁrst element
in the sequence
w
R
z
R
y
R
z
:
:
: such that
R
uv. If
v itself does not belong to
Y
0,
it must belong to
Z
0; but since we did not break off the process at this stage, this
means that we could put a successor
y
i of
v in
Y
0; by transitivity,
R
uy
i. The only
other case in which the process may ﬁnish is symmetric to the case described.
Finally, if the process does not ﬁnish in this way we are dealing with an inﬁnite
sequence
w
R
z
R
y
R
z
:
:
:. But then the pair
(Y
[
Y
;
Z
[
Z
) belongs to
C.
a
Obviously, the example begs the question whether there is a modal formula that
locally corresponds to a ﬁrst-order formula without being equivalent to a Sahlqvist
formula. The answer to this question is afﬁrmative: the formula
2M
^
4 is a
counterexample. In Exercise 3.7.1 the reader is asked to show that it has a local
ﬁrst-order correspondent; in Chapter 5 we will develop the techniques needed to
prove that the formula is not equivalent to a Sahlqvist formula, see Exercise 5.6.2.
Thus the Sahlqvist fragment does not contain all modal formulas with ﬁrst-order
correspondents. So the next question is: can the Sahlqvist fragment be further
extended? The answer is yes — but we should reﬂect a little on what we hope
to achieve through such extensions. The Sahlqvist fragment is essentially a good
compromise between the demands of generality and simplicity. By adding further
restrictions it is possible to extend it further, but it is not obvious that the resulting
loss of simplicity is really worth it. Moreover, the Sahlqvist fragment also gives
rise to a matching completeness theorem; we would like proposed extensions to
do so as well. We don’t know of simple generalizations of the Sahlqvist fragment



3.7 More about Sahlqvist Formulas
which manage to do this. In short, while there is certainly room for experiment
here, it is unclear whether anything interesting is likely to emerge.
However, one point is worth stressing once more: the Sahlqvist fragment cannot
be further extended simply by dropping some of the restrictions in the deﬁnition
of a Sahlqvist formula. We forbid disjunctions in the scope of boxes and nested
duals of triangles in Sahlqvist antecedents for a very good reason: these forbidden
combinations easily lead to modal formulas that have no ﬁrst-order correspondent,
as we have seen in Example 3.11 and Exercise 3.6.2.
Kracht’s theorem
Let’s turn to a nice positive result. As has already been mentioned, not only does
each Sahlqvist formula deﬁne a ﬁrst-order class of frames, but when we use one
as an axiom in a normal modal logic, that logic is guaranteed to be complete with
respect to the elementary class of frames the axiom deﬁnes. (This is the content of
the Sahlqvist Completeness Theorem; see Theorem 4.42 for a precise statement.)
So it would be very pleasant to know which ﬁrst-order conditions are the corre-
spondents of Sahlqvist formulas. Kracht’s Theorem is a sort of converse to the
Sahlqvist Correspondence Theorem which gives us this information.
Before we can deﬁne the fragment of ﬁrst-order logic corresponding to Sahl-
qvist formulas we need some auxiliary deﬁnitions; we also introduce some helpful
notation. For reasons of notational simplicity, we work in the basic modal similar-
ity type. First of all, we will abbreviate the ﬁrst-order formula
8y
(R
xy
!
(y
))
to
(8y

x)(y
), speaking of restricted quantiﬁcation and calling
x the restrictor
of
y. Likewise
9y
(R
xy
^
(y
)) is abbreviated to
(9y
x)(y
). We will call the
constructs
(8y

x) and
(9y

x) restricted quantiﬁers. If we wish not to specify
the restrictor of a restricted quantiﬁer we will write
r
y or
r
y. Moreover, if we
don’t wish to specify whether a quantiﬁer is existential or universal we denote it
by
Q (Q
r in the restricted case). Second, for the duration of this subsection it will
be convenient for us to consider formulas of the form
u
6=
u as atomic. Third, in
this subsection we will work exclusively with formulas in which no variable occurs
both free and bound, and in which no two distinct (occurrences of) quantiﬁers bind
the same variable; we will call such formulas clean.
Now we call a formula restrictedly positive if it is built up from atomic formu-
las, using
^,
_ and restricted quantiﬁers only; observe that monadic predicates oc-
cur positively in restrictedly positive formulas. Finally, we assume that the reader
knows how to rewrite an arbitrary positive propositional formula to a disjunctive
normal form or DNF (that is, to an equivalent disjunction of conjunctions of atomic
formulas) and to a conjunctive normal form or CNF (that is, to an equivalent con-
junction of disjunctions of atomic formulas).



3 Frames
The crucial notion in this subsection is that of a variable occurring inherently
universally in a ﬁrst-order formula.
Deﬁnition 3.58 We say that an occurrence of the variable
y in the (clean!) formula
 is inherently universal if either
y is free, or else
y is bound by a restricted quan-
tiﬁer of the form
(8y
x) which is not in the scope of an existential quantiﬁer.
A formula
(x) in the basic ﬁrst-order frame language is called a Kracht formula
if
 is clean, restrictedly positive and furthermore, every atomic formula is either
of the form
u
=
u or
u
6=
u, or else it contains at least one inherently universal
variable.
a
Restricted quantiﬁcation is obviously the modal face of quantiﬁcation in ﬁrst-order
logic; indeed, we could have deﬁned the standard translation of a modal formula
using this notion. As for Kracht formulas, ﬁrst observe that every universal re-
stricted ﬁrst-order formula satisﬁes the deﬁnition. A second example of a Kracht
formula is
(8w

v
)(8xv
)(9y
w
)R
xy: note that it does not matter that the ‘x’
in
R
xy falls within the scope of an existential quantiﬁer; what matters is that the
universal quantiﬁer that binds
x does not occur within the scope of any existen-
tial quantiﬁcation. On the other hand, the formula
(9w
v
)(8xv
)w
=
x is not
a Kracht formula since the occurrence of neither
w nor
x in
w
=
x is inherently
universal:
w is disqualiﬁed because it is bound by an existential quantiﬁer and
x
because it is bound within the scope of the existential quantiﬁer
(9w
v
).
The following result states that Kracht formulas are the ﬁrst-order counterparts
of Sahlqvist formulas — but not only that. As will become apparent from its proof,
from a given Kracht formula we can compute a Sahlqvist formula locally corre-
sponding to it. The reader is advised to glance at the examples provided below
while reading the proof.
Theorem 3.59 Any Sahlqvist formula locally corresponds to a Kracht formula;
and conversely, every Kracht formula is a local ﬁrst-order correspondent of some
Sahlqvist formula which can be effectively obtained from the Kracht formula.
Proof. For the left to right direction, we leave it as an exercise to the reader to
show that the algorithm discussed in the sections 3.5 and 3.6 in fact produces,
given a Sahlqvist formula, a ﬁrst-order correspondent within the Kracht fragment.
We’ll give the proof of the other direction: we’ll show how rewrite a given Kracht
formula to an equivalent Sahlqvist formula.
Our ﬁrst step is to provide special prenex formulas as normal forms for Kracht
formulas. Deﬁne a type 1 formula to be of the form
r
x
:
:
:
r
x
n
Q
r
y
:
:
:
Q
r
m
y
m

(x
;
:
:
:
;
x
n
;
y
;
:
:
:
;
y
m
)
such that
n,
m

0 and each variable is restricted by an earlier variable (that is, the



3.7 More about Sahlqvist Formulas
restrictor of any
x
i is some
x
j with
j
<
i and the restrictor of any
y
i is either some
x
k or some
y
j with
j
<
i. Furthermore we require that
 is a DNF of formulas
u
=
u,
u
6=
u,
R
ux,
u
=
x and
R
xu (that is, we allow all atomic formulas that are
not of the form
R
y
y
0 or
y
=
y
0). Here and in the remainder of this proof we use
the convention that
u and
z denote arbitrary variables in
fx
;
:
:
:
;
x
n,
y
;
:
:
:
;
y
m
g
and
x an arbitrary variable in
fx
;
:
:
:
;
x
n
g.
Clearly then, type 1 formulas form a special class of Kracht formulas. This
inclusion is not proper (modulo equivalence), since we can prove the following
claim.
Claim 1 Every Kracht formula can be effectively rewritten into an equivalent type
1 formula.
Proof of Claim. Let
(x
) be a Kracht formula. By deﬁnition it is built up from
atomic formulas using
^,
_ and restricted quantiﬁers. Furthermore, since
(x
) is
clean, in a subformula of the form
Q
r
v
 the variable
v may not occur outside of
. Hence, we may use the equivalences
(Q
r
v

)
~

$
Q
r
v
(
~

)
(3.20)
(where
~ uniformly denotes either
^ or
_) to pull out quantiﬁers to the front.
However, if we want to remain within the Kracht fragment we have to take care
about the order in which we pull out quantiﬁers.
Without loss of generality we may assume that each inherently universal variable
is named
x
i for some
i, while each of the remaining variables is named
y
j for some
j. This ensures that no atomic subformula of
(x
) is of the form
R
y
y
0 or
y
=
y
(with distinct variables
y and
y
0).
Observe also that in every subformula of the form
((8xu)
)~, the variable
u occurs free. If this
u is not the variable
x
0 then it is a bound variable of
; hence,
the mentioned subformula must occur in the scope of a quantiﬁer
(Q
r
u

x
). This
quantiﬁcation must have been universal, for otherwise, the variable
x could not
have been among the inherently universal ones. But this means that the variable
u itself must be inherently universal as well, so
u is some
x
i. This shows that
by successively pulling out restricted universal quantiﬁers
r
x we end up with a
Kracht formula of the form
r
x
:
:
:
r
x
n

(x
;
:
:
:
;
x
n
;
y
;
:
:
:
;
y
m
);
such that each atomic formula of

0 is of the form
u
=
u or
u
6=
u, or else it
contains some occurrence of a variable
x
i. Furthermore, the restrictor of each
x
i is
some
x
j with
j
<
i.
It remains to pull out the other restricted quantiﬁers from

0. But this can easily
be done using the equivalences of (3.20), since we do not have to worry anymore



3 Frames
about the order in which we pull out the quantiﬁers. In the end, we arrive at a
formula of the form
r
x
:
:
:
r
x
n
Q
r
y
:
:
:
Q
r
m
y
m

(x
;
:
:
:
;
x
n
;
y
;
:
:
:
;
y
m
)
such that the atomic subformulas of

00 satisfy the same condition of those in

(in fact, they are the very same formulas), while in addition,

00 is quantiﬁer free.
Hence, if we rewrite

00 into disjunctive normal form, we are ﬁnished.
a
Enter diamonds and boxes. A type 2 formula is a formula in the second-order frame
language of the form
~
P
:
:
:
~
P
n
~
8Q
:
:
:
~
Q
n
r
x
:
:
:
r
x
n
@
^
0in
ST
x
i
(
i
)
!

A
such that each

i is a conjunction of boxed atoms in
p
i and
q
i, whereas
 is a DNF
of formulas
ST
x
( 
), with
 some modal formula which is positive in each
p
i,
q
j.
Claim 2 Every type 1 formula can be can be effectively rewritten into an equiva-
lent type 2 formula.
Proof of Claim. Now the prominent role of the inherently universal formulas will
come out: they determine the propositional variables of the Sahlqvist formula and
the ‘BOX-AT’ part of its antecedent. Consider the type 1 formula
r
x
:
:
:
r
x
n
Q
r
y
:
:
:
Q
r
m
y
m

(x
;
:
:
:
;
x
n
;
y
;
:
:
:
;
y
m
):
We abbreviate the sequence
r
x
:
:
:
r
x
n by
r

x, and use similar abbreviations for
other sequences of quantiﬁers. Recall that
 is a DNF of formulas
u
=
u,
u
6=
u,
u
=
x
i,
R
ux
i and
R
x
i
u. Our ﬁrst move is to replace such subformulas with the
formulas
ST
u
(>),
ST
u
(?),
ST
u
(p
i
),
ST
u
(3p
i
) and
ST
u
(q
i
), respectively; call
the resulting formula

0.
Our ﬁrst claim is that
r

x
Q
r

y

is equivalent to
~

P

Q
r

x
@
^
0in
ST
x
i
(p
i
^
2q
i
)
!
Q
r

y

A
:
(3.21)
Forbidding as (3.21) may look, its proof is completely analogous to proofs in Sec-
tions 3.5 and 3.6: the direction from right to left is immediate by instantiation,
while the other direction simply follows from the fact that

0 is monotone in each
predicate symbol
P
i and
Q
i.
Two remarks are in order here. First, since
 may contain atomic formulas of the
form
R
x
i
x
j and
x
i
=
x
j (that is, with both variables being inherently universal),



3.7 More about Sahlqvist Formulas
there is some choice here. For instance, the formula
R
x
i
x
j may be replaced with
either
ST
x
i
(3p
j
) or with
ST
x
j
(q
j
). Having this choice can sometimes be of use if
one wants to ﬁnd Sahlqvist correspondents satisfying some additional constraints.
Related to this is our second remark: we don’t need to introduce both proposi-
tional variables
p
i and
q
i for each
x
i. We can do with any supply of variables that is
sufﬁcient to replace all atomic formulas of
 with the standard translation of either
ST
u
(p
i
),
ST
u
(3p
i
) or
ST
u
(q
i
). A glance at the examples below will make this
point clear.
We are now halfway through the proof of Claim 2: observe that

0 is already a
DNF of formulas
ST
u
( 
) with
 positive in each
p
i
;
q
j. It remains to eliminate
the quantiﬁer sequence
Q
r

y. This will be done step by step, using the following
procedure.
Consider the formula
(9y
i+1
z
)
@
_
k
K
^
l
L
k
ST
u
k
l
( 
k
l
)
A
;
(3.22)
where each modal formula
 
k
l is positive in all variables
p
i,
q
j;
z is either an
x or
a
y
j with
j

i; and each
u is either an
x or a
y
j with
j

i
+
1. We ﬁrst distribute
the existential quantiﬁer over the disjunction, yielding a disjunction of formulas
(9y
i+1
z
)
^
l
L
k
ST
u
k
l
( 
k
l
):
(3.23)
We may assume all these variables
u to be distinct (otherwise, replace
ST
u
( 
)
^
ST
u
( 
) with
ST
u
( 
^
 
)); we may also assume that
y
i+1 is the variable
u
l
L
k
(if
y
i+1 does not occur among the
u’s, add a conjunct
ST
y
i+1
(>)). But then (3.23)
is equivalent to the formula
ST
z
(3 
k
L
)
^
^
l
<L
k
ST
u
k
l
( 
k
l
);
whence (3.22) is equivalent to a disjunction of such formulas. Observe further that
y
i+1 does not occur in these formulas.
This shows how to get rid of an existential innermost restricted quantiﬁer of the
prenex
K
r

y. A universal innermost restricted quantiﬁer can be removed dually, by
ﬁrst converting the matrix

0 into a conjunctive normal form; details are left to the
reader. In any case, it will be clear that by this procedure we can rewrite any type
1 formula into an equivalent type 2 formula.
a
We are now almost through with the proof of Theorem 3.59. All we have to do
now is show how to massage arbitrary type 2 formulas into Sahlqvist shape.
Claim 3 Any type 2 formula can be can be effectively rewritten into an equivalent
Sahlqvist formula.



3 Frames
Proof of Claim. Let
~

P

Q
r

x
@
^
0in
ST
x
i
(
i
)
!

A
(3.24)
be an arbitrary type 2 formula.
First we rewrite
 into conjunctive normal form, and we distribute the implica-
tion and the prenex of universal quantiﬁers over the conjunctions. Thus we obtain
a conjunction of formulas of the form
~

P

Q8
r

x
@
^
0in
ST
x
i
(
i
)
!

A
;
(3.25)
where

0 is a disjunction of formulas of the form
ST
x
( 
) with each
 positive in
all
p
i and
q
j. As before, we may assume that each
x
i occurs in exactly one disjunct
of

0, so (3.25) is equivalent to a formula
~

P

Q
r

x
@
^
0in
ST
x
i
(
i
)
!
_
0in
ST
x
i
( 
i
)
A
;
where each

i is a Sahlqvist antecedent and each
 
i is positive. But clearly then,
(3.25) is equivalent to the formula
~

P

Q:9
r

x
^
0in
ST
x
i
(
i
^
: 
i
):
Observe that each modal formula

i
^
: 
i is a Sahlqvist antecedent.
But now, as before, working inside out we may eliminate all remaining restricted
quantiﬁers, step by step. For, observe that the formula
r
x
:
:
:
r
x
k
 1
(9x
k
x
j
)
^
0ik
ST
x
i
(
i
)
is equivalent to
r
x
:
:
:
r
x
k
 1
@
ST
x
j
(
j
^
3
k
+1
)
^
^
0i<k
;i6=j
ST
x
i
(
i
)
A
:
Note that

j
^
3
k
+1 is a Sahlqvist antecedent if

j and

k
+1 are.
It turns out that for some Sahlqvist antecedent
, (3.25) is equivalent to the
second-order formula
~

P

Q
:ST
x
():



3.7 More about Sahlqvist Formulas
But then (3.24) is equivalent to a conjunction of such formulas, and thus equivalent
to a formula
~

P

Q
ST
x
 
_
l

l
!
?
!
;
which is the local second-order frame correspondent of the formula
W
l

l
!
?,
which is obviously in Sahlqvist form.
a
This completes the proof of the third claim, and hence of the theorem.
a
Example 3.60 Consider the formula
(x
)

(8x

x
)(9y
x
)(9y
y
)
R
x
y
:
This is already a type 2 Kracht formula, so we proceed by the procedure described
in the proof of Claim 2 in the proof of Theorem 3.59. According to (3.21),
(x
)
is equivalent to the second order formula
~
Q
(8x

x
)
(ST
x
(2q
)
!
(9y
x
)(9y
y
)ST
y
(q
)):
Then, using the equivalences described further on in the proof of Claim 2 we obtain
the following sequences of formulas that are equivalent to
(x
):
~
Q
(8x

x
)
(ST
x
(2q
)
!
(9y
x
)(9y

y
)ST
y
(q
))
,
~
Q
(8x

x
)
(ST
x
(2q
)
!
(9y
x
)ST
y
(3q
));
,
~
Q
(8x

x
)
(ST
x
(2q
)
!
ST
x
(33q
)):
The last formula is a type 2 formula. Hence, the only thing left to do is to rewrite
it to an equivalent Sahlqvist formula; this we do via the sequence of equivalent
formulas below, following the pattern of the proof of Claim 3.
~
8Q
(
(8x
x
)
(ST
x
(2q
)
!
ST
x
(33q
))
)
,
~
8Q
(
(8x

x
)
:(ST
x
(2q
)
^
:ST
x
(33q
))
)
,
~
8Q
(
(8x

x
)
:(ST
x
(2q
)
^
ST
x
(:33q
))
)
,
~
8Q
(
:(9x
x
)
(ST
x
(2q
)
^
ST
x
(:33q
))
)
,
~
8Q
(
:((9x

x
)ST
x
(2q
)
^
ST
x
(:33q
))
)
,
~
8Q
(
:(ST
x
(32q
)
^
ST
x
(:33q
))
)
,
~
8Q
(
:ST
x
(32q
^
:33q
)
)
,
~
8Q
(
ST
x
((32q
^
:33q
)
!
?)
):
This means that
(x
) locally corresponds to the Sahlqvist formula
(32q
^
:33q
)
!
?, or to the equivalent formula
32q
!
33q
1.
a



3 Frames
Example 3.61 Consider the Kracht formula
(x
)

(8x

x
)(8x
x
)
(R
x
x
_
R
x
x
_
x
=
x
):
According to (3.21),
(x
) is equivalent to
~
P
~
8Q
(8x
x
)(8x
x
)
(ST
x
(p
^
2q
)
!
(ST
x
(q
)
_
ST
x
(3p
)
_
ST
x
(p
)))
and to
~
8P
~
8Q
(8x

x
)(8x
x
)
(ST
x
(p
^
2q
)
!
ST
x
(q
_
3p
_
p
)):
The latter is a type 2 formula; in order to ﬁnd a Sahlqvist equivalent for it, we
proceed as follows:
~
8P
~
Q
(8x

x
)(8x
x
)
(ST
x
(p
^
2q
)
!
ST
x
(q
_
3p
_
p
))
,
~
8P
~
8Q
(8x

x
)(8x
x
)
:(ST
x
(p
^
2q
)
^
:ST
x
(q
_
3p
_
p
))
,
~
8P
~
8Q
(8x

x
)(8x
x
)
:(ST
x
(p
^
2q
)
^
ST
x
(:(q
_
3p
_
p
)))
,
~
8P
~
8Q
:(9x
x
)(9x
x
)
(ST
x
(p
^
2q
)
^
ST
x
(:(q
_
3p
_
p
)))
,
~
8P
~
8Q
:(9x
x
)
(ST
x
(p
^
2q
)
^
(9x

x
)ST
x
(:(q
_
3p
_
p
)))
,
~
8P
~
8Q
:(9x
x
)
(ST
x
(p
^
2q
)
^
ST
x
(3:(q
_
3p
_
p
)))
,
~
8P
~
8Q
:((9x

x
)ST
x
(p
^
2q
)
^
ST
x
(3:(q
_
3p
_
p
)))
,
~
8P
~
8Q
:(ST
x
(3(p
^
2q
))
^
ST
x
(3:(q
_
3p
_
p
)))
,
~
8P
~
8Q
:(ST
x
(3(p
^
2q
)
^
3:(q
_
3p
_
p
)))
From this, the fastest way to proceed is by observing that the last formula is equiv-
alent to
~
8P
~
8Q
(ST
x
(3(p
^
2q
)
!
:3:(q
_
3p
_
p
)));
and hence, to the Sahlqvist formula
3(p
^
2q
)
!
2(q
_
3p
_
p
):
a
Example 3.62 Consider the type 1 Kracht formula
(x
)

(8x
x
)(9y
x
)
y
6=
y
:
According to (3.21), we can rewrite
(x
) into the equivalent
~
8P
(8x

x
)
(ST
x
(p
)
!
(9y

x
)ST
y
(?))



3.7 More about Sahlqvist Formulas
and, hence, to
~
8P
(8x
x
)
(ST
x
(p
)
!
ST
x
(3?))
This is a type 2 formula for which we can ﬁnd a Sahlqvist equivalent as follows:
~
8P
(8x
x
)
(ST
x
(p
)
!
ST
x
(3?))
,
~
8P
(8x
x
)
:(ST
x
(p
)
^
:ST
x
(3?))
,
~
8P
:(9x

x
)
(ST
x
(p
)
^
ST
x
(:3?))
,
~
8P
:
(ST
x
(p
)
^
(9x
x
)ST
x
(:3?))
,
~
8P
:
(ST
x
(p
)
^
ST
x
(3:3?))
,
~
8P
(ST
x
(:(p
^
3:3?))
The latter formula is equivalent to the Sahlqvist formula
p
!
23?. (Obviously,
the latter formula is equivalent to
23? and, hence, to
2?. Our algorithm will not
always provide the simplest correspondents!)
a
This ﬁnishes our discussion of Sahlqvist correspondence. In the next chapter we
will see that Sahlqvist formulas also have very nice completeness properties, in
that any modal logic axiomatized by Sahlqvist formulas is complete with respect
to the class of frames deﬁned by (the global ﬁrst-order correspondents of) the for-
mulas. Here Kracht’s theorem can be useful: if we want to axiomatize a class of
frames deﬁned by formulas of the form
8x
(x) with
(x) a Kracht formula, then
it sufﬁces to compute the Sahlqvist correspondents of these formulas and add these
as axioms to the basic modal logic.
Exercises for Section 3.7
3.7.1
(a) Prove that the conjunction
M
^
4 of McKinsey’s formula
23p
!
32p and
the transitivity formula
3p
!
33p does not have a local ﬁrst-order correspondent.
Conclude that this conjunction is not equivalent to a Sahlqvist formula.
(b) Show that on the other hand, the formula
2M
^
4 does have a local ﬁrst-order
correspondent.
3.7.2 Prove that the local correspondent of a Sahlqvist formula is a Kracht formula.
3.7.3 Find Sahlqvist formulas that locally correspond to the following formulas:
(a)
(8y

x)
R
y
y,
(b)
(8y
x)(8y

x)(8y
x)
(y
=
y
_
y
=
y
_
y
=
y
)
(c)
(8y
x)(8y

y
)
(y
=
y
_
9z
(R
xz
_
(R
y
z
^
R
y
z
))).
(d)
(8x

x)(9y
x)(8y
y
)
(R
y
x
_
(R
xy
^
R
y
x
x
))
3.7.4 Prove that if

!
 is a simple Sahlqvist formula, then
2(
!
 
) is equivalent to
a simple Sahlqvist formula.



3 Frames
3.7.5 Let
 be the basic temporal similarity type. Show that over the class of bidirectional
frames, every simple Sahlqvist formula is equivalent to a very simple Sahlqvist formula.
(Hint: ﬁrst ﬁnd a very simple Sahlqvist formula that is equivalent to the formula
F
Gp
!
GF
p.)
