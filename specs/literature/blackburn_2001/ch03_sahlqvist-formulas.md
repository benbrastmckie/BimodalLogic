<!-- Source: Blackburn, de Rijke & Venema (2001). Modal Logic. Cambridge University Press. Chapter 3: Frames, §3.6 Sahlqvist Formulas (pages 157-167). BibKey: Blackburn2001 -->

3.6 Sahlqvist Formulas
element assigned to
x belongs to the subset assigned to
P. For example, if
P is as-
signed the empty set,
P
x will be false no matter what
x is assigned. Now suppose
we substitute
(u:
u
6=
u) for
P in
P
x. This yields the expression
(u:
u
6=
u)x.
Read this as ‘apply the function denoted by
u:
u
6=
u to the state denoted by
x’.
Clearly this yields the value 0 (that is, false). The process of
-conversion men-
tioned in the proof is essentially a way of rewriting such functional applications
to simpler but equivalent forms; for more details, consult one of the introductions
cited in the Notes. Newcomers to
-notation should try Exercise 3.5.1 right away.
Exercises for Section 3.5
3.5.1 Explain why we could have used the following predicate deﬁnitions in the proof of
Theorem 3.38: for every
P occurring in
ST
x
(), deﬁne

(P
)


u:
?;
if
ST
x
() is positive in
P
u:
>;
if
ST
x
() is negative in
P
:
If you have difﬁculties with this, consult one of the introductions to
-calculus cited in the
notes before proceeding further.
3.5.2 Let
 be a modal formula which is positive in all propositional variables. Prove that
 can be rewritten into a normal form which is built up from proposition letters, using
^,
_,
3 and
2 only.
3.5.3 Prove Lemma 3.37. That is, show that if a modal formula
 is positive in
p, then it
is upward monotone in
p, and that if it is negative in
p, then it is downward monotone in
p.
3.6 Sahlqvist Formulas
In the proof of Theorem 3.40 we showed that uniform formulas correspond to ﬁrst-
order conditions by ﬁnding a suitable instantiation for the universally quantiﬁed
monadic second-order variables in their second-order translation and appealing to
monotonicity. This is an important idea, and the rest of this section is devoted to
extending it: the Sahlqvist fragment is essentially a large class of formulas to which
this style of argument can be applied.
Very simple Sahlqvist formulas
Roughly speaking, Sahlqvist formulas are built up from implications

!
 ,
where
 is positive and
 is of a restricted form (to be speciﬁed below) from which
the required instantiations can be read off. We now deﬁne a limited version of the
Sahlqvist fragment for the basic modal language; generalizations and extensions
will be discussed shortly.



3 Frames
Deﬁnition 3.41 We will work in the basic modal language. A very simple Sahl-
qvist antecedent over this language is a formula built up from
>,
? and proposi-
tion letters, using only
^ and
3. A very simple Sahlqvist formula is an implication

!
 in which
 is positive and
 is a very simple Sahlqvist antecedent.
a
Examples of very simple Sahlqvist formulas include
p
!
3p and
(p
^
33q
)
!
23(p
^
q
).
The following theorem is central for understanding what Sahlqvist correspon-
dence is all about. Its proof describes and justiﬁes an algorithm for converting
simple Sahlqvist formulas into ﬁrst-order formulas; the algorithms given later for
richer Sahlqvist fragments elaborate on ideas introduced here. Examples of the al-
gorithm in action are given below; it is a good idea to refer to these while studying
the proof.
Theorem 3.42 Let

=

!
 be a very simple Sahlqvist formula in the basic
modal language
ML(
;
). Then
 locally corresponds to a ﬁrst-order formula
c

(x) on frames. Moreover,
c
 is effectively computable from
.
Proof. Our starting point is the formula
8P
:
:
:
8P
n
(ST
x
()
!
ST
x
( 
)), which
is the local second-order translation of
. We assume that this translation has
undergone a pre-processing step to ensure that no two quantiﬁers bind the same
variable, and no quantiﬁer binds
x. Let us denote
ST
x
( 
) by POS; that is, we
have a translation of the form:
8P
:
:
:
8P
n
(ST
x
()
! POS
):
(3.9)
We will now rewrite (3.9) to a form from which we can read off the instantiations
that will yield its ﬁrst-order equivalent.
Step 1. Pull out diamonds.
Use equivalences of the form
(9x
i
(x
i
)
^

)
$
9x
i
((x
i
)
^

)
and
(9x
i
(x
i
)
!

)
$
8x
i
((x
i
)
!

)
(in that order) to move all existential quantiﬁers in the antecedent
ST
x
() of (3.9)
to the front of the implication. Note that by our deﬁnition of Sahlqvist antecedents,
the existential quantiﬁers only have to cross conjunctions before they reach the
main implication. Of course, the above equivalences are not valid if the variable
x
i occurs freely in
, but by our assumption on the pre-processing of the formula,
this problem does not arise.
Step 1 results in a formula of the form
8P
:
:
:
8P
n
8x
:
:
:
8x
m
(REL
^ AT
! POS
);
(3.10)



3.6 Sahlqvist Formulas
where REL is a conjunction of atomic ﬁrst-order statements of the form
R
x
i
x
j cor-
responding to occurrences of diamonds, and AT is a conjunction of (translations of)
proposition letters. It may be helpful at this point to look at the concrete examples
given below.
Step 2. Read off instances.
We can assume that every unary predicate
P that occurs in the consequent of the
matrix of (3.10), also occurs in the antecedent of the matrix of (3.10): otherwise
(3.10) is positive in
P and we can substitute
u:
u
6=
u for
P (that is, make use of
the substitution used in the proof of Theorem 3.40) to obtain an equivalent formula
without occurrences of
P.
Let
P
i be a unary predicate occurring in (3.10), and let
P
i
x
i
;
:
:
:
;
P
i
x
i
k be all
the occurrences of the predicate
P
i in the antecedent of (3.10). Deﬁne

(P
i
)

u:
(u
=
x
i
_



_
u
=
x
i
k
):
Note that

(P
i
) is the minimal instance making the antecedent REL
^ AT true; this
lambda expression says that if a node
u has property
P
i, then
u must be one of the
nodes
x
i
1,
x
i
2, . . . or
x
i
k explicitly stated to have property
P
i in the antecedent. But
this is nothing else than saying that if some model
M makes the formula AT true
under some assignment, then the interpretation of the predicate
P must extend the
set of points where

(P
) holds:
M
j
=
A
T
[w
w
:
:
:
w
m
] implies
M
j
=
8y
(
(P
i
)(y
)
!
P
i
y
)[w
w
:
:
:
w
m
] (3.11)
This observation, in combination with the positivity of the consequent of the Sahl-
qvist formula, forms the key to understanding why Sahlqvist formulas have ﬁrst-
order correspondents.
Step 3. Instantiating.
We now use the formulas of the form

(P
i
) found in Step 2 as instantiations; we
substitute

(P
i
) for each occurrence of
P
i in the ﬁrst-order matrix of (3.10). This
results in a formula of the form
[
(P
)=P
;
:
:
:
;

(P
n
)=P
n
]8x
:
:
:
8x
m
(REL
^ AT
!
POS
):
Now, there are no occurrences of monadic second-order variables in REL. Further-
more, observe that by our choice of the substitution instances

(P
), the formula
[
(P
)=P
;
:
:
:
;

(P
n
)=P
n
]AT will be trivially true. So after carrying out these
substitutions we end up with a formula that is equivalent to one of the form
8x
:
:
:
8x
m
(REL
!
[
(P
)=P
;
:
:
:
;

(P
n
)=P
n
]POS
):
(3.12)
As we assumed that every unary predicate occurring in the consequent of (3.10)
also occurs in its antecedent, (3.12) must be a ﬁrst-order formula involving only
=
and the relation symbol
R. So, to complete the proof of the theorem it sufﬁces to



3 Frames
show that (3.12) is equivalent to (3.10). The implication from (3.10) to (3.12) is
simply an instantiation. To prove the other implication, assume that (3.12) and the
antecedent of (3.10) are true. That is, assume that
M
j
=
8x
:
:
:
8x
m
(REL
!
[
(P
)=P
;
:
:
:
;

(P
n
)=P
n
]POS
)
and
M
j
=
REL
^
A
T[w
w
:
:
:
w
m
]:
We need to show that
M
j
=
POS
[w
w
:
:
:
w
m
]. First of all, it follows from the
above assumptions that
M
j
=
[
(P
)=P
;
:
:
:
;

(P
n
)=P
n
]POS[w
w
:
:
:
w
m
]:
As POS is positive, it is upwards monotone in all unary predicates occurring in
it, so it sufﬁces to show that
M
j
=
8y
(
(P
i
)(y
)
!
P
i
y
)[w
w
:
:
:
w
m
]. But, by
the essential observation (3.11) in Step 2, this is precisely what the assumption
M
j
= AT
[w
w
:
:
:
w
m
] amounts to.
a
Example 3.43 First consider the formula
p
!
3p. Its second-order translation is
the formula
8P
(
P
x
|{z}
A
T
!
9z
(R
xz
^
P
z
)):
There are no diamonds to be pulled out here, so we can read off the minimal in-
stance

(P
)

u:
u
=
x immediately. Instantiation gives
(u:
u
=
x)x
!
9z
(R
xz
^
u:
u
=
x)z
);
Which (either by
-conversion or semantic reasoning) yields the following ﬁrst-
order formula.
x
=
x
!
9z
(R
xz
^
z
=
x):
Note that this is equivalent to
R
xx.
Our second example is the density formula
3p
!
33p, which has
8P
(9x
(R
xx
^
P
x
)
!
9z
(R
xz
^
9z
(R
z
z
^
P
z
))):
as its second-order translation. Here we can pull out the diamond
9x
1:
8P
8x
(R
xx
|
{z
}
REL
^
P
x
|{z}
A
T
!
9z
(R
xz
^
9z
(R
z
z
^
P
z
))):
Instantiating with

(P
)

u:
u
=
x
1 gives
8x
(R
xx
^
x
=
x
!
9z
(R
xz
^
9z
(R
z
z
^
z
=
x
)));
which can be simpliﬁed to
8x
(R
xx
!
9z
(R
xz
^
R
z
x
)).



3.6 Sahlqvist Formulas
Our last example of a very simple Sahlqvist formula is
(p
^
33p)
!
3p. Its
second-order translation is
8P
(P
x
^
9x
(R
xx
^
9x
(R
x
x
^
P
x
))
!
9z
(R
xz
^
P
z
)):
Pulling out the diamonds
9x
1 and
9x
2 results in
8P
8x
8x
(R
xx
^
R
x
x
|
{z
}
REL
^
P
x
^
P
x
|
{z
}
A
T
!
9z
(R
xz
^
P
z
)):
Our minimal instantiation here is:

(P
)

u:
(u
=
x
_
u
=
x
). After instanti-
ating we obtain
8x
8x
(R
xx
^
R
x
x
^
(x
=
x
_
x
=
x
)
^
(x
=
x
_
x
=
x
)
!
9z
(R
xz
^
(z
=
x
_
z
=
x
))).
This formula simpliﬁes to
8x
8x
(R
xx
^
R
x
x
!
(R
xx
_
R
xx
)).
a
Simple Sahlqvist formulas
What is the crucial observation we need to make about the preceding proof? Sim-
ply this: the algorithm for very simple Sahlqvist formulas worked because we were
able to ﬁnd a minimal instantiation for their antecedents. We now show that min-
imal instantiations can be found for more complex Sahlqvist antecedents. First a
motivating example.
Example 3.44 Consider the formula
p
!
p; we will show that this
formula locally corresponds to a kind of local conﬂuence (or Church-Rosser) prop-
erty of
R
1 and
R
2:
8x
z
(R
xx
^
R
xz
!
9z
(R
x
z
^
R
z
z
)):
The reason for the apparently unnatural choice of variable names will soon become
clear, as will the somewhat roundabout approach to the proof that we take. The
name ‘conﬂuence’ is explained by the following picture:
u
x
u
x
u
z
u
z





*
H
H
H
H
H
j
H
H
H
H
j




*
Let
F
=
(W
;
R
;
R
) be a frame and
w a state in
F such that
F;
w

p
!
p, and let
v be a state in
F such that
R
w
v. A sufﬁcient condition for a



3 Frames
valuation to make
p true at
w would be that
p holds at all
R
2-successors of
v. So a minimal such valuation can be deﬁned as
V
m
(p)
=
fx
W
j
R
v
xg:
That is,
V
m makes
p true at precisely the
R
2-successors of
v. As
F;
w

p
!
p, we have
(F;
V
m
);
w

p, but what does this tell us about the (ﬁrst-
order) properties of
F? The crucial observation is that by the choice of
V
m:
(F;
V
m
);
w

p iff
(F;
V
m
)
j
=
8z
(R
xz
!
9z
(R
x
z
^
R
z
z
))[w
v
];
(3.13)
which yields that
F
j
=
8x
z
(R
xx
^
R
xz
!
9z
(R
x
z
^
R
z
z
))[w
].
Conversely, assume that
F has the conﬂuence property at
w. In order to show that
F;
w

p
!
p, let
V be a valuation on
F such that
(F;
V
);
w

p.
We have to prove that
w

p. By the truth deﬁnition of
1,
w has an
R
1-
successor
v satisfying
R
w
v and
v

p. Now we use the minimal valuation
V
m
again; ﬁrst note that by the deﬁnition of
V
m, we have
V
m
(p)

V
(p). Therefore,
Lemma 3.37 ensures that it sufﬁces to show that
p holds at
w under the
valuation
V
m. But this is immediate by the assumption that
F is conﬂuent and
(3.13).
a
This example inspires the following deﬁnitions.
Deﬁnition 3.45 Let
 be a modal similarity type. A boxed atom is a formula of the
form
i



i
k
p (k

0), where
i
1, . . . ,
i
k are (not necessarily distinct) boxes
of the language. In the case where
k
=
0, the boxed atom
i



i
k
p is just the
proposition letter
p.
a
Convention 3.46 In the sequel, it will be convenient to treat sequences of boxes
as single boxes. We will therefore denote the formula
i



i
k
p by

p, where
 is the sequence
i
:
:
:
i
k of indices. Analogously, we will pretend to have a
corresponding binary relation symbol
R
 in the frame language
L
. Thus the
expression
R

xy abbreviates the formula
9y
(R
i
xy
^
9y
(R
i
y
y
^



^
9y
k
 1
(R
i
k
 1
y
k
 2
y
k
 1
^
R
i
k
y
k
 1
y
)
:
:
:
)):
Note that this convention allows us to write the second-order translation of the
boxed atom

p as
8y
(R

xy
!
P
y
).
If
k
=
0,
 is the empty sequence
; in this case the formula
R

xy should be
read as
x
=
y. Note that the Second-Order Translation of

p (that is, of the
proposition letter
p) can indeed be written as
8y
(R

xy
!
P
y
).
Deﬁnition 3.47 Let
 be a modal similarity type. A simple Sahlqvist antecedent



3.6 Sahlqvist Formulas
over this similarity type is a formula built up from
>,
? and boxed atoms, using
only
^ and existential modal operators (3 and
M). A simple Sahlqvist formula is
an implication

!
 in which
 is positive (as before) and
 is a simple Sahlqvist
antecedent.
a
Example 3.48 Typical examples of simple Sahlqvist formulas are
3p
!
33p,
2p
!
22p,
p
!
p,
p
!
p and
(2
p)M(3
p
^
q
)
!
(q
Mp).
Typically forbidden in a simple Sahlqvist antecedent are:
(i) boxes over disjunctions, as in
H
(r
_
F
q
)
!
G(P
r
^
P
q
),
(ii) boxes over diamonds, as in
23p
!
32p,
(iii) dual-triangled atoms, as in
p
O
p
!
p.
a
Theorem 3.49 Let
 be a modal similarity type, and let

=

!
 be a simple
Sahlqvist formula over
. Then
 locally corresponds to a ﬁrst-order formula
c

(x)
on frames. Moreover,
c
 is effectively computable from
.
Proof. The proof of this theorem is an adaptation of the proof of Theorem 3.42.
Consider the universally quantiﬁed second-order transcription of
:
8P
:
:
:
8P
n
(ST
x
()
!
ST
x
( 
)):
(3.14)
Again, we ﬁrst make sure that no two quantiﬁers bind the same variable, and that
no quantiﬁer binds
x. As before, the idea of the algorithm is to rewrite (3.14) to a
formula from which we can easily read off instantiations which yield a ﬁrst-order
equivalent of (3.14).
Step 1. Pull out diamonds.
This is the same as before. This process results in a formula of the form
8P
:
:
:
8P
n
8x
:
:
:
8x
m
(REL
^ BOX-AT
!
ST
x
( 
));
(3.15)
where REL is a conjunction of atomic ﬁrst-order statements of the form
R
x
i
x
j cor-
responding to occurrences of diamonds, and BOX-AT is a conjunction of (transla-
tions of) boxed atoms, that is, formulas of the form
8y
(R

x
i
y
!
P
y
).
Step 2. Read off instances.
Let
P be a unary predicate occurring in (3.15), and let

(x
i
), . . . ,

k
(x
i
k
) be
all the (translations of the) boxed atoms in the antecedent of (3.10) in which the
predicate
P occurs. Observe that every

j is of the form
8y
(R

j
x
i
j
y
!
P
y
),
where

j is a sequence of diamond indices (recall Convention 3.46). Deﬁne

(P
)

u:
(R

x
i
u
_



_
R

k
x
i
k
u):
Again,

(P
), . . . ,

(P
n
) form the minimal instances making the antecedent
REL
^
BOX-AT true.



3 Frames
The remainder of the proof is the same as the proof of Theorem 3.42, with the
proviso that all occurrences of ‘AT’ should be replaced by ‘BOX-AT’.
a
As in the case of very simple Sahlqvist formulas, the algorithm is best understood
by inspecting some examples:
Example 3.50 Let us investigate some of the formulas given in Example 3.48. The
simple Sahlqvist formula
p
!
p has the following second-order transla-
tion:
8P
(8y
(R
xy
!
P
y
)
|
{z
}
BOX-AT
!
8z
(R
xz
!
P
z
)):
There are no diamonds to be pulled out here, so we can read off the required sub-
stitution instance

(P
)

u:
R
xu immediately. Carrying out the substitution
we obtain
8y
(R
xy
!
R
xy
)
!
8z
(R
xz
!
R
xz
);
which is equivalent to
8z
(R
xz
!
R
xz
).
Next we consider the conﬂuence formula
p
!
p, whose second-
order translation is
8P
(9x
(R
xx
^
8y
(R
x
y
!
P
y
))
!
8z
(R
xz
!
9z
(R
z
z
^
P
z
))):
Pulling out the existential quantiﬁcation
9x
1 yields
8P
8x
(R
xx
|
{z
}
REL
^
8y
(R
x
y
!
P
y
)
|
{z
}
BOX-AT
!
8z
(R
xz
!
9z
(R
z
z
^
P
z
))):
The minimal instance making BOX-AT true is

(P
)

u:
R
x
u. After instanti-
ating we obtain
8x
(R
xx
^
8y
(R
x
y
!
R
x
y
)
!
8z
(R
xz
!
9z
(R
z
z
^
R
x
z
)));
which can be simpliﬁed to
8x
8z
(R
xx
^
R
xz
!
9z
(R
z
z
^
R
x
z
)):
As our ﬁnal example, let us treat a formula using a dyadic modality
M:
(2
p)M(3
p
^
q
)
!
(q
Mp):
We use a ternary relation symbol
T for the triangle
M. Its second-order translation
is the rather formidable looking
8P
8Q
(9x
x
(T
xx
x
^
8y
(R
x
y
!
P
y
)
^
9x
(R
x
x
^
P
x
)
^
8y
(R
x
y
!
Qy
))
!
9z
(R
xz
^
9z
z
(T
z
z
z
^
Qz
^
P
z
)));



3.6 Sahlqvist Formulas
from which we can pull out the diamonds
9x
1,
9x
2 and
9x
3. This leads to
8P
8Q8x
x
8x
(
REL
z
}|
{
T
xx
x
^
R
x
x
^
BO
X A
T
z
}|
{
8y
(R
x
y
!
P
y
)
^
P
x
^
8y
(R
x
y
!
Qy
)
!
9z
(R
xz
^
9z
z
(T
z
z
z
^
Qz
^
P
z
))):
Now we can easily read off the required instantiations:

(P
)

u:
(R
x
u
_
u
=
x
)

(Q)

u:
(R
x
u):
Performing the substitution
[
(P
)=P
;

(Q)=Q] and deleting the tautological parts
from the antecedent gives
8x
x
8x
(T
xx
x
^
R
x
x
!
9z
(R
xz
^
9z
z
(T
z
z
z
^
R
x
z
^
(R
x
z
_
z
=
x
))):
a
Sahlqvist formulas
We are now ready to introduce the full Sahlqvist fragment and the full version of
the Sahlqvist-van Benthem algorithm.
Deﬁnition 3.51 Let
 be a modal similarity type. A Sahlqvist antecedent over
 is
a formula built up from
>,
?, boxed atoms, and negative formulas, using
^,
_ and
existential modal operators (3 and
M). A Sahlqvist implication is an implication

!
 in which
 is positive and
 is a Sahlqvist antecedent.
A Sahlqvist formula is a formula that is built up from Sahlqvist implications by
freely applying boxes and conjunctions, and by applying disjunctions only between
formulas that do not share any proposition letters.
a
Example 3.52 Both simple and very simple Sahlqvist formulas are examples of
Sahlqvist formulas, as are
(p
!
3p),
p
^
3:p
!
3p, and
(3

p
!

p)
^

(p
!
p). As with simple Sahlqvist formulas, typically forbidden
combinations in Sahlqvist antecedent are ‘boxes over disjunctions,’ ‘boxes over di-
amonds,’ and ‘dual-triangled atoms’ as in
p
O
p
!
p (see Example 3.48).
a
The following lemma is instrumental in reducing the correspondence problem for
arbitrary Sahlqvist formulas, ﬁrst to that of Sahlqvist implications, and then to to
that of simple Sahlqvist formulas.
Lemma 3.53 Let
 be a modal similarity type, and let
 and
 be
-formulas.



3 Frames
(i) If
 and
(x) are local correspondents, then so are


 and
8y
(R

xy
!
[y
=x]).
(ii) If
 (locally) corresponds to
, and
 (locally) corresponds to
, then

^
 
(locally) corresponds to

^
.
(iii) If
 locally corresponds to
,
 locally corresponds to
, and
 and
 have
no proposition letters in common, then

_
 locally corresponds to

_
.
Proof. Left as Exercise 3.6.3.
a
The local perspective in part one and three of the Lemma is essential. For instance,
one can ﬁnd a modal formula
 that globally corresponds to a ﬁrst-order condition
8x
(x) without
2 globally corresponding to the formula
8x8y
(R
xy
!
(y
));
see Exercise 3.6.3.
Theorem 3.54 Let
 be a modal similarity type, and let
 be a Sahlqvist formula
over
. Then
 locally corresponds to a ﬁrst-order formula
c

(x) on frames. More-
over,
c
 is effectively computable from
.
Proof. The proof of the theorem is virtually the same as the proof of Theorem 3.49,
with the exception of the use of Lemma 3.53 and of the fact that we have to do some
pre-processing of the formula
.
By Lemma 3.53 it sufﬁces to show that the theorem holds for all Sahlqvist im-
plications. So assume that
 has the form

!
 where
 is a Sahlqvist antecedent
and
 a positive formula. Proceed as follows.
Step 1. Pull out diamonds and pre-process.
Using the same strategy as in the proof of Theorem 3.49 together with equivalences
of the form
((
_

)
!

)
$
(
(
!

)
^
(
!

)
)
and
:
:
:
(
^

)
$
(
:
:
:

^
:
:
:

);
we can rewrite the second-order translation of

!
 into a conjunction of formu-
las of the form
8P
:
:
:
8P
n
8x
:
:
:
8x
m
(REL
^ BOX-AT
^ NEG
!
ST
x
( 
));
(3.16)
where REL is a conjunction of atomic ﬁrst-order statements of the form
R
M
~
x cor-
responding to occurrences of diamonds and triangles, BOX-AT is a conjunction of
(translations of) boxed atoms, and NEG is a conjunction of (translations of) neg-
ative formulas. By Lemma 3.53(ii) it sufﬁces to show that each formula of the
form displayed in (3.16) has a ﬁrst-order equivalent. This is done by using the
equivalence
(
^ NEG
!

)
$
(
!

_
:NEG
);



3.6 Sahlqvist Formulas
where
:NEG is the positive formula that arises by negating the negative formula
NEG. Using this equivalence we can rewrite (3.16) to obtain a formula of the form
8P
:
:
:
8P
n
8x
:
:
:
8x
m
(REL
^ BOX-AT
! POS
);
and from here on we can proceed as in Step 2 of the proof of Theorem 3.49.
a
Example 3.55 By way of example we determine the local ﬁrst-order correspon-
dents of two of the modal formulas given in Example 3.52. To determine the
ﬁrst-order correspondent of the Sahlqvist formula
(p
!
3p) we ﬁrst recall that
the local ﬁrst-order correspondent of
p
!
3p is
R
xx. So, by Lemma 3.53(i)
(p
!
3p) locally corresponds to
8y
(R
xy
!
R
y
y
).
Next we consider the Sahlqvist formula
(p
^
3:p)
!
3p. Its translation is
8P
(P
x
^
9y
(R
xy
^
:P
y
)
!
9z
(R
xz
^
P
z
)):
Pulling out the diamond produces
8P
8y
(
P
x
|{z}
BOX-AT
^
R
xy
|
{z
}
REL
^
:P
y
|
{z
}
NEG
!
9z
(R
xz
^
P
z
))
|
{z
}
;
and moving the negative part
:P
y to the consequent we get
8P
8y
(
P
x
|{z}
BOX-AT
^
R
xy
|
{z
}
REL
!
P
y
_
9z
(R
xz
^
P
z
)
|
{z
}
POS
):
The minimal instantiation to make
P
x true is
u:
u
=
x. After instantiation we
obtain
8y
(R
xy
!
y
=
x
_
9z
(R
xz
^
z
=
x));
which can be simpliﬁed to
8y
(R
xy
^
x
6=
y
!
R
xx).
a
Exercises for Section 3.6
3.6.1 Compute the ﬁrst-order formulas locally corresponding to the following Sahlqvist
formulas:
(a)
p
!
p,
(b)
(p
^
2p
^
22p)
!
3p,
(c)
k
l
p
!
m
n
p, for arbitrary natural numbers
k,
l,
m and
n,
(d)
(2p)M(2p)
!
pOp,
(e)
3(:p
^
3(p
^
q
))
!
3(p
^
q
),
(f)
2((p
^
2:p
^
q
)
!
3q
)).
3.6.2
(a) Show that the formula
2(p
_
q
)
!
3(2p
_
2q
) does not locally correspond
to a ﬁrst-order formula on frames. (Hint: modify the frame of Example 3.11.)
(b) Use this example to show that dual-triangled atoms cannot be allowed in Sahlqvist
antecedents.



3 Frames
3.6.3 Prove Lemma 3.53:
(a) Show that if
 and
(x) locally correspond, so do


 and
8y
(R

xy
!
(y
)).
(b) Prove that if
 (locally) corresponds to
(x), and
 (locally) corresponds to

(x),
then

^
 (locally) corresponds to
(x)
^

(x).
(c) Show that if
 locally corresponds to
,
 locally corresponds to

(x), and

and
 have no proposition letters in common, then

_
 locally corresponds to
(x)
_

(x).
(d) Prove that (a) and (c) do not hold for global correspondence, and that the condition
on the proposition letters in (c) is necessary as well. (Hint: for (a), think of the
modal formula
33p
!
3p and the ﬁrst-order formula
8xy
z
(R
y
z
^
R
z
x
!
R
y
x).)
