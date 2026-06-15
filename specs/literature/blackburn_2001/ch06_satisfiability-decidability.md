<!-- Source: Blackburn, de Rijke & Venema (2001). Modal Logic. Cambridge University Press. Chapter 6: Computability and Complexity, §6.1-6.3 Computing Satisfiability, Decidability via Finite Models, and Decidability via Interpretations (pages 334-357). BibKey: Blackburn2001 -->

6.1 Computing Satisﬁability
ﬁnite models for proving decidability results. Three basic theorems are
proved, and many of the logics discussed in Chapter 4 are shown to be
decidable.
Section 6.3: Decidability via Interpretations (Basic track). Another way of prov-
ing modal decidability results is via interpretations in powerful decidable
theories such as monadic second-order theories of trees. This technique
is useful for showing the decidability of logics without the ﬁnite model
property.
Section 6.4: Decidability via Quasi-models and Mosaics (Basic track).
For log-
ics lacking the ﬁnite model property it may also be possible to prove de-
cidability results by computing with more abstract kinds of ﬁnite structure;
quasi-models and mosaics are important examples of such structures.
Section 6.5: Undecidability via Tiling (Basic track). In this section we show just
how easily undecidable — and even highly undecidable — modal logics
can arise. We do so by introducing an important proof method: tiling
arguments.
Section 6.6: NP (Advanced track). This section introduces the concept of NP al-
gorithms, illustrates the modal content of this idea using some simple ex-
amples, and then proves Hemaspaandra’s Theorem: every normal logic
extending S4.3 is NP-complete.
Section 6.7: PSPACE (Advanced track). The key complexity class for the basic
modal language is PSPACE, the class of problems solvable in polynomial
space. We give a PSPACE algorithm for the satisﬁability problem for K,
and prove Ladner’s Theorem: every normal logic between K and S4 is
PSPACE-hard.
Section 6.8: EXPTIME (Advanced track). We show that the satisﬁability prob-
lem for PDL is EXPTIME-complete. EXPTIME-hardness is shown by
reduction from a tiling problem, and the EXPTIME algorithm introduces
an important technique called elimination of Hintikka sets.
6.1 Computing Satisﬁability
The work of this chapter revolves around satisﬁability and validity problems. Here
is an abstract formulation.
Deﬁnition 6.1 (Satisﬁability and Validity Problems) Let
 be a modal similar-
ity type,
 be a
-formula and M a class of
-models. The M-satisﬁability problem
is to determine whether or not
 is satisﬁable in some model in M. The M-validity
problem is to determine whether or not
 is true in all models in M; that is, whether
or not
M

. (We call this the validity problem because we are mostly interested



6 Computability and Complexity
in cases where M is the class of all models over some class of frames.) The M-
validity and M-satisﬁability problem are each other’s duals.
a
In fact, as far as discussions of computability (or non-computability) are concerned,
we are free to talk in terms of either satisﬁability or validity problems.
Lemma 6.2 Let
 be a modal similarity type, and suppose that M is a class of
-models. Then there is an algorithm for solving the M-satisﬁability problem iff
there is an algorithm for solving the M-validity problem.
Proof. As
: is not satisﬁable in M iff
M

, given an algorithm for M-satis-
ﬁability, we can test for the validity of
 by giving it the input
:. In a similar
fashion, an algorithm for M-validity can be used to test for M-satisﬁability.
a
This argument does not give us any interesting information about the relative com-
plexity of dual satisﬁability and validity problems; and indeed, they may well be
different.
How do the themes of this chapter relate to the normal modal logics introduced
in Section 1.6 and discussed in Chapters 4 and 5? Clearly we should investigate
the following two problems.
Deﬁnition 6.3 Let
 be a modal similarity type,
 be a normal modal logic in a
language for
, and
 a
-formula. The problem of determining whether or not
 is
-consistent is called the
-consistency problem, and the problem of determining
whether or not

`
 is called the
-provability problem.
a
Note that
-consistency and
-provability problems are satisﬁability and validity
problems in disguise. In particular, if
 is a normal modal logic, and
M is any
class of models such that

=

M, then the
-consistency problem is the
M-
satisﬁability problem, and the
-provability problem is the
M-validity problem. As
every normal modal logic is determined by at least one class of models (namely, the
singleton class containing its canonical model; see Theorem 4.22), we are free to
think of consistency and provability problems in terms of satisﬁability and validity
problems. We do so in this chapter, and to emphasize this we usually call the
-
consistency problem the
-satisﬁability problem, and the
-provability problem
the
-validity problem.
Our discussion so far has given an abstract account of the problems we will ex-
plore, and most of our results will be stated, proved, and discussed at this level. But
what does it mean to have an algorithm for solving (say) a validity problem? And
what does it mean to talk about the complexity of (say) a satisﬁability problem?
After all, computation is the ﬁnitary manipulation of ﬁnite structures — but both
formulas and models are abstract set-theoretical objects. To show that our abstract



6.1 Computing Satisﬁability
account really makes sense, we need to choose a well-understood method of com-
putation and show that formulas and models can be represented in a way that is
suited to our method.
We have chosen Turing machines (Section C) as our fundamental model of com-
putation. The most relevant fact about Turing machines for our purposes is that
they compute by manipulating ﬁnite strings of symbols; hence we need to rep-
resent models and formulas as symbol strings. As far as mere computability is
concerned, the key demand is that these symbol string representations be ﬁnite.
For complexity analyses more is required: representations must also be efﬁcient.
Let’s discuss these requirements.
Clearly modal formulas can be represented as ﬁnite strings over a ﬁnite set of
symbols: proposition letters can be represented by a single symbol (say,
p) fol-
lowed by (the representation of) a number. Thus, instead of working with an inﬁ-
nite collection of primitive symbols we could work with (say)
p1,
p10,
p11,
p100
and so on, where the numeric tail is represented in binary. Fine — but what about
models? Models are set-theoretic entities of the form
(W
;
R
;
V
), and each com-
ponent may be inﬁnite. However, the difﬁculty is more apparent than real. For a
start, when evaluating a formula
 in some model, the only relevant information in
the valuation is the assignments made to propositional letters actually occurring in
 (see Exercise 1.3.1). Thus, instead of working with
V , we can work with the ﬁ-
nite valuation
V
0 which is deﬁned on the (ﬁnite) language consisting of exactly the
proposition letters in
, and which agrees with
V on these letters. Secondly, much
of our work will revolve around models based on ﬁnite frames (or more generally,
the frames of ﬁnite character deﬁned below).
We already know quite a lot about ﬁnite models and their logics. For a start,
in Section 2.3 we introduced two techniques for building ﬁnite models (selection
and ﬁltration) and deﬁned the ﬁnite model property for the basic modal language.
In Section 3.4 we introduced the ﬁnite frame property (again, for the basic modal
language) and proved Theorem 3.28: a normal modal logic has the ﬁnite frame
property iff it has the ﬁnite model property. Since then we have learned what a
normal modal logic in a language of arbitrary similarity type is (Deﬁnition 4.13),
so let’s now deﬁne the ﬁnite frame property and the ﬁnite model property for modal
languages of arbitrary similarity type, and generalize Theorem 3.28.
Deﬁnition 6.4 Let
 be a modal similarity type. A frame of type
 has ﬁnite char-
acter if it contains ﬁnitely many states, and ﬁnitely many non-empty relations. If
 is a normal modal logic in a language for
, and
F is a class of
-frames of ﬁnite
character, and

=

F, then
 is said to have the ﬁnite frame property (f.f.p.) with
respect to F. If

=

F for some class of
-frames F of ﬁnite character, then
 has
the ﬁnite frame property.
A class of
-models M is ﬁnitely based
if every model in M is based on a
-



6 Computability and Complexity
frame of ﬁnite character. If
 is a normal modal logic in a language for
, and
M is a class of ﬁnitely based
-models, and

=

M, then
 has the ﬁnite model
property (f.m.p.) with respect to M. If

=

M for some class of of ﬁnitely based
-models M, then
 has the ﬁnite model property.
a
A few remarks may be helpful. First, the concept of ﬁnite character is a natural way
of coping with similarity types containing inﬁnitely many relations. Second, note
that the way the ﬁnite frame property is deﬁned here (where we simply insist that

=

F) is somewhat simpler than that used in Deﬁnition 4.13 (where we insisted
that
F

, and for every formula
 such that

 there is some
F
F such that
 is falsiﬁable on
F). It is easy to see that these deﬁnitions are equivalent Finally, a
class of frames of ﬁnite character (or indeed, a class of ﬁnite frames) may well be
a proper class. Nonetheless, up to isomorphism, there are only denumerably many
frames in any such class; hence, if
 has the ﬁnite frame property, it has the ﬁnite
frame property with respect to a denumerably inﬁnite set of frames, and we take
this for granted without further comment throughout the chapter.
Given this deﬁnition, it is straightforward to generalize Theorem 3.28.
Theorem 6.5 Let
 be a modal similarity type. Any normal modal logic in a lan-
guage for
 has the ﬁnite model property iff it has the ﬁnite frame property.
Proof. This is a matter of verifying that the proof of Theorem 3.28 extends to
arbitrary similarity types; see Exercise 6.1.1.
a
There are many ways to represent a frame of ﬁnite character, together with a val-
uation
V
0 deﬁned on ﬁnitely many proposition letters, as a ﬁnite symbol string.
While any such ﬁnitization is sufﬁcient for discussions of computability, we need
to exercise more care when it comes to complexity. Complexity theory measures
the difﬁculty of problems in terms of the resources required to solve them — and
these are measured as a function of the size of the input. A highly inefﬁcient rep-
resentation of the input can render such resource measures vacuous, so we must be
careful not to smuggle in sources of inefﬁciency. For the complexity classes we
will be dealing with, this is pretty much a matter of common sense, but the follow-
ing point should be made explicit: we must not represent the numeric subscripts
on propositional variables and states in unary notation.
The point is this. Even binary representations (which are longer than the more
familiar decimal representations) are exponentially more compact than unary ones.
For example, the representation of the number 64 in unary is a string of 64 con-
secutive ones, whereas its representation in binary is 1000000. If we represent our
subscripts in unary, we are using a highly inefﬁcient representation of the problem.
For this reason we will regard modal formulas (for the basic modal language)
as strings over the alphabet
fp,
0,
1,
(,
),
^,
:,
3g, and proposition letters will



6.1 Computing Satisﬁability
be represented by strings consisting of
p followed by the binary representation of
a number (without leading zeroes). Similarly, we will regard models as strings
over the alphabet
fw,
p,
0,
1,
;,
h,
ig. A state in a model will be represented by
w followed by the binary representation of a number (without leading zeroes), and
the representation of proposition letters (which we need to encode the valuation)
will be as just described. A string representing a model will have the following
form:

hw
;
:
:
:
;
w
n
i;
hhw
i
;
w
j
i;
:
:
:
;
hw
k
;
w
l
ii;
hhp
x
;
hw
r
;
:
:
:
;
w
s
ii;
:
:
:
;
hp
y
;
hw
t
;
:
:
:
;
w
u
ii

;
where

i,
j,
k,
l,
r,
s,
t,
u

n. Such triples represent models in the obvious
way: the ﬁrst component gives the states, the second the relation, and the third the
valuation. The subscripted
w’s and
p’s are metavariables over our representations
of states and proposition letters, respectively. We assume that our representations
of models contain no repetitions in any of the three components, and that they sat-
isfy obvious well-formedness conditions (in particular, the third component rep-
resents a function, thus we cannot have the same representation
p
y appearing as
the ﬁrst item in different tuples). Here is a simple example (though to keep things
readable we have represented the numbers in decimal):
A model
q
p
p
   
t
t
@
@
@
I
t

hw
;
w
;
w
i;
hhw
;
w
i;
hw
;
w
ii;
hhp
;
hw
;
w
ii;
hp
;
hw
iii

Its representation
Such representations open the door to all the standard concepts of computability
theory and computational complexity. For a start, it now makes sense to describe
sets of formulas (including normal modal logics), sets of models, and sets of frames
as being recursively enumerable (r.e.), or as being recursive. Saying that a set is
r.e. means that it is possible to write a Turing machine that will successively output
all and only its elements. Saying that a set is recursive means that it is possible to
write a Turing machine which, when given any input, will perform a ﬁnite number
of computation steps, halt, and then correctly tell us whether the input represents
a member of the set or not. (In short, recursive sets are those for which we can
decide membership using a terminating computation.)
Furthermore, it is clearly possible to program a Turing machine so that when it
is presented with (the representations of) a formula, a model, and a point, it will
evaluate (the representation of) the formula in (the representation of) the model at
(the representation of) the point. Admittedly it would be rather painful to write out



6 Computability and Complexity
such a Turing machine in detail — but it is straightforward to write a program to
carry out this task in most high-level programming languages; hence, by Church’s
Thesis (see Section C), it is possible to write a Turing machine to do the job as
well. Thus it makes perfectly good sense to talk about writing Turing machines
which test for the satisﬁability or validity of a formula on a class of ﬁnitely based
models and to inquire about the complexity of such problems.
Apart from asking the reader to generalize the above representation schema to
cover modal languages of arbitrary similarity type (see Exercise 6.1.2) we will not
discuss the issue of representation further. In most of what follows we talk as if the
abstract deﬁnition of satisﬁability and validity problems given earlier was the focus
of our computational investigations. For example, we will often call
jj the size
of the input formula; strictly speaking, it is the size of its representation. Nor do
we mention Turing machines very often. The results of this chapter rest on the fact
that there is an efﬁcient representation which enables us to compute satisﬁability
and validity problems; for many purposes we can ignore the details.
Exercises for Section 6.1
6.1.1 Prove Theorem 6.5. That is, show that for any modal similarity type
, any normal
modal logic in a language for
 has the ﬁnite model property if and only if it has the ﬁnite
frame property. This is simply a matter of verifying that the proof of Theorem 3.28 extends
to arbitrary similarity types — but note that there will be a gap in your proof if you haven’t
yet proved the Filtration Theorem for modal languages of arbitrary similarity type.
6.1.2 Modify the representation schema for models given above so that it can represent
any ﬁnitely based model of any modal similarity type.
6.1.3 Show that if
 is the normal modal logic generated by an r.e. set of formulas, then

itself is an r.e. set. (The reader unfamiliar with this type of proof may ﬁnd it useful to look
at the proof of Lemma 6.12 below.)
6.2 Decidability via Finite Models
Call a normal modal logic
 decidable if the
-satisﬁability (or equivalently:
-
validity) problem is decidable, and undecidable if it is not. How should we estab-
lish decidability results? A lot depends on our ‘access’ to the logic. For example,
we may know
 purely semantically: it is given as the logic of some class of
frames of interest. However, we may also have a syntactic handle on
; in partic-
ular, we may know that it is the logic generated by some set of axioms. Whether
 is semantically or syntactically speciﬁed, establishing that it has the ﬁnite model
property is a useful ﬁrst step towards proving decidability, for if we can prove this,
two plausible strategies for establishing decidability suggest themselves, as we will
now explain.



6.2 Decidability via Finite Models
 Decidability for semantically speciﬁed logics: informal argument. Suppose
we only have a semantic speciﬁcation of
, but that we have been able to prove
that
 possesses a strong form of the ﬁnite model property: not only does

have the f.m.p. with respect to some set of models, but for any formula
 there
is a computable function
f such that
f
(jj) is an upper bound on the size of
these models needed to satisfy
. Write a Turing machine that takes
 as input,
generates all the ﬁnite models belonging to this set up to size
f
(jj), and tests for
the satisﬁability of
 on these models. Because
 is
-satisﬁable iff it is satisﬁed
in a
-model of size at most
f
(jj), and because the machine systematically
examines all these models, our machine decides
-satisﬁability.
 Decidability for syntactically speciﬁed logics: informal argument. Suppose

is given axiomatically, and we have been able to show that
 has the f.m.p. with
respect to some set of models M. First, construct a Turing machine that makes
use of the axiomatization to recursively enumerate the
-validities. Second, con-
struct a Turing machine that recursively enumerates all the ﬁnite models in M.
Given two such machines we can effectively test the
-validity of any formula
: if
 is valid it will eventually be generated by the ﬁrst machine; if it is not,
we will eventually be able to falsify it on a model generated by the second. One
of the machines must eventually settle
’s fate, and thus decide
-validity.
Such arguments underly most applications of the ﬁnite model property to decidabil-
ity. We have deliberately phrased both arguments rather loosely; the fundamental
goal of this section is to explore the underlying ideas more carefully, and formulate
them rigorously. Our investigation will yield three main theorems. The ﬁrst is a
precise formulation of the argument for semantically speciﬁed logics. The second
and third are distinct reformulations of the argument for syntactically speciﬁed log-
ics. We will consider a number of applications of these theorems, and will put both
of the methods introduced in Section 2.3 for constructing ﬁnite models (namely
ﬁltration and selection) to work.
Let us begin by scrutinizing the ﬁrst of the above arguments. This revolves
around a strong form of the ﬁnite model property.
Deﬁnition 6.6 (Strong Finite Model Property)
Let
 be a normal modal logic,
M a set of ﬁnitely based models such that

=
M, and
f a function mapping nat-
ural numbers to natural numbers.
 has the
f
(n)-size model property with respect
to M if every
-consistent formula
 is satisﬁable in a model in M containing at
most
f
(jj) states.
 has the strong ﬁnite model property with respect to M if there is a computable
function
f such that
 has the
f
(n)-size model property with respect to M.
 has
the polysize model property with respect to M if there is a polynomial
p such that
 has the
p(n)-size model property with respect to M.



6 Computability and Complexity
 has the
f
(n)-size model property (respectively, strong ﬁnite model property,
polysize model property) if there is a set of ﬁnitely based models M such that

=
M and
 has the
f
(n)-size model property (respectively, strong ﬁnite model
property, polysize model property) with respect to M.
a
If a logic
 has the polysize model property, any
-satisﬁable formula is satisﬁable
not just on a ﬁnite model, but a genuinely small model. Even this very strong form
of the f.m.p does not guarantee decidability: as the reader is asked to prove in
Exercise 6.2.4, there are uncountably many normal modal logics which possess the
polysize model property but have undecidable satisﬁability problems.
In view of this result, the ﬁrst informal argument sketch is clearly inadequate —
but where does its deﬁciency lie? It makes the following (false) assumption: that
for any set of models, and any natural number
n, it is possible to generate all and
only the models in M of size at most
n. This assumption is warranted only if M
is a recursive set (that is, only if a Turing machine can decide exactly which ﬁnite
models belong to M). But this is the only shortcoming of the informal argument.
Theorem 6.7 If
 is a normal modal logic that has the strong ﬁnite model property
with respect to a recursive set of models M, then
 is decidable.
Proof. First, observe that for any natural number
n it is possible to generate all
distinct (representations of) models in M that have size at most
n: we need simply
write a machine that generates all distinct (representations of) models that have
size at most
n, tests each model (representation) as it is generated to see whether
it belongs to M (this is the key point: we can effectively test for membership in
M precisely because M is a recursive set) and then outputs exactly those models
(representations) which do belong to M. (From now on we drop all mention of
representations, and will speak simply of ‘generating all models’ or ‘generating all
models up to size
n’, and so on.)
So, given
, we use this machine to generate all models of the appropriate set up
to size
f
(), and test whether
 is satisﬁable on any of the models it produces. If

is satisﬁable on at least one of them, it is
-satisﬁable; if not, it is not
-satisﬁable,
for
 has the strong f.m.p. with respect to M.
a
Theorem 6.7 is an important result. If we are to apply it, how do we establish that a
logic has the strong ﬁnite model property? Unfortunately, no fully general answer
to this question is known — nonetheless, both ﬁltration and selection can be useful.
We start by illustrating the utility of ﬁltrations.
Corollary 6.8 K, T, KB, K4, S4, S5, K
t, K
t
4:3 and K
t
Q are decidable.
Proof. First, all these logics have the f.m.p. with respect to the expected sets of
models; for example, K4 has the f.m.p. with respect to the set of ﬁnite transitive



6.2 Decidability via Finite Models
models, and K
t
Q has the f.m.p with respect to the ﬁnite dense unbounded weak
total orders (that is, the ﬁnite DUWTO frames; see Theorem 4.41). The easiest
way to prove this is to use ﬁltrations. In Section 2.3 we deﬁned ﬁltrations for
both the basic modal language and the basic temporal language. Given a model
M
that satisﬁes a formula
 at some state, by ﬁltrating
M through the set of all
’s
subformulas we obtain a ﬁnite model
M
f that satisﬁes
. Of course, we need to be
careful that
M
f has all the right properties; for example, if
M was a K4-model, we
want
M
f to be a K4-model as well. By and large this is straightforward, though the
reader will need to think a little about how to handle density; see Exercise 6.2.1.
Such ﬁltration arguments actually establish the strong f.m.p. for these logics. If
we form
M
f by ﬁltrating
M through the subformulas of
, then
M
f has at most
jj nodes, thus we have a computable (though, unfortunately, exponential) upper
bound on the size of satisfying models for all these logics; see Section 2.3.
It remains to check that the relevant sets of ﬁnite models are recursive. Checking
for membership in these sets boils down to checking that the models possess (vari-
ous combinations of) such properties as reﬂexivity, transitivity, trichotomy, and so
on. It is clearly possible to devise algorithms to test for the relevant properties,
hence (by Church’s thesis) we can program a Turing machine to do so. Thus The-
orem 6.7 applies, and all these logics are decidable.
a
Filtration is a widely used technique for showing that logics have the strong ﬁnite
model property, but it has limitations. Suppose we are working with a modal lan-
guage containing
n unary modal operators (n
>
0) and no others. Let
F
n
1 be the set
of frames for this language such that for each
F
F
n
1, the relation corresponding
to each modality is a partial function, let
M
n
1 be the set of models built over
F
n
1,
and let K
nAlt
1 be its logic. Now, K
nAlt
1 has the strong ﬁnite model property, but
there is no obvious way of using ﬁltrations to show this; see Exercise 6.2.3.
However — at least in the present case — it is straightforward to use selection,
the other method of building ﬁnite models discussed in Section 2.3, to establish the
strong ﬁnite model property.
Corollary 6.9 K
nAlt
1 is decidable.
Proof. We argue as follows. Suppose
M is in
M
n
1 and
M;
w

. Let
M
0 be the
model that is identical to
M save possibly that any relations in
M
0 not correspond-
ing to modal operators in
 are empty. Clearly
M
0 is also in
M
n
1 and
M
;
w

.
Let
m be the degree of
 (that is, the maximal depth of nested modalities; see Deﬁ-
nition 2.28). Let
M
00 be the submodel of
M
0 formed by selecting all and only those
nodes reachable from
w in
m or fewer steps. Clearly
M
00 is in
M
n
1 and
M
;
w

.
Moreover, because each relation is a partial function,
M
00 has only ﬁnitely many
nodes: indeed, it can contain at most
t
m
+
1 nodes, where
t is the number of dis-



6 Computability and Complexity
tinct types of modality that occur in
. Hence K
nAlt
1 has the strong ﬁnite model
property with respect to
M
n
1.
It is clear that the set of ﬁnitely based
M
n
1 models is recursive, for testing whether
a ﬁnite model
M belongs to it essentially boils down to checking that each of
M’s
(ﬁnitely many non-empty) transition relations is a partial function. Decidability
follows by Theorem 6.7.
a
Selection is not as general a method as ﬁltration — but it can be useful, espe-
cially when working with non-transitive models. As we will see when we discuss
NP-completeness, selection is a natural way of turning a ﬁnite model (perhaps pro-
duced via a ﬁltration) into a truly small (that is, polysize) model.
Theorem 6.7, together with such methods as ﬁltration and selection, can be a
useful tool for establishing modal decidability results, for it does not require us to
have an axiomatization. Very often we do have an axiomatization at our disposal,
and it is natural to ask whether (and how) we can make use of it to help establish
decidability. This is what the second informal argument attempts to do. The key
idea it embodies is the following: if a logic is both axiomatizable and has the ﬁnite
model property with respect to some (recursively enumerable) set of models M,
then we should be able to prove decidability. This is an important idea that can be
developed in two different ways, depending on the kind of axiomatization we have,
and what we know about the computational properties of M.
When we discussed completeness in Chapter 4, we viewed axiomatizations very
abstractly: we simply said that if
 was a normal modal logic,
 a set of modal
formulas, and
K (the smallest normal logic generated by
) equaled
, then

was an axiomatization of
. To give computational content to the phrase ‘gener-
ated by’ we need to impose restrictions on
, for under the deﬁnition just given
every normal logic
 generates itself. This is too abstract to be useful here, so we
will introduce various notions of axiomatizability that offer more computational
leverage.
Deﬁnition 6.10 A logic
 is ﬁnitely axiomatizable if it has a ﬁnite axiomatization
; it is recursively axiomatizable if it has a recursive axiomatization
; and it is
axiomatizable if it has a recursively enumerable axiomatization
.
a
Although it won’t play a major role in what follows, there is a neat result called
Craig’s Lemma that readers should know: every axiomatizable logic is recursively
axiomatizable. So the following lemma is essentially Craig’s Lemma for modal
logic:
Lemma 6.11 If
 is axiomatizable, then
 is recursively enumerable.
So, given a computationally reasonable notion of axiomatizability, the idea of using
axiomatizations to generate validities is correct. But how do we use this fact to turn



6.2 Decidability via Finite Models
the informal argument into a theorem? Here’s the most obvious way: demand that
M be an r.e. set. As the following lemma shows, this ensures that we can recursively
enumerate the formulas that are not valid on M.
Lemma 6.12 If M is a recursively enumerable set of ﬁnite models, then the set of
formulas falsiﬁable in M is recursively enumerable.
Proof. As M is an r.e. set, we can construct a machine M1 to generate all its ele-
ments, and clearly we can construct a machine M2 that generates all the formulas.
So, construct a machine M3 that operates as follows: it calls on M1 to generate a
model, and on M2 to generate a formula, and then stores both the model and the
formula. It then tests all stored formulas on all stored models (M3 is not going to
win any prizes for efﬁciency) and outputs any of the stored formulas it can falsify
on some stored model. At any stage there are only ﬁnitely many stored formulas
and models, hence this testing process terminates. When the testing process is ﬁn-
ished, M3 calls on M1 and M2 once more to generate another model and formula,
stores them, performs another round of testing, and so on ad inﬁnitum.
Suppose
 is falsiﬁable on some model
M in M. At some ﬁnite stage both

and
M will be stored by M3, hence
 will eventually be tested on
M, falsiﬁed,
and returned as output. This means that the set of formulas falsiﬁable on
M is
recursively enumerable.
a
Theorem 6.13 If
 is an axiomatizable normal modal logic that has the ﬁnite
model property with respect to an r.e. set of models M, then
 is decidable.
Proof.
 is r.e. by Lemma 6.11. But the set of formulas not in
 is also r.e. for

=
M and the set of formulas that are not M-valid is r.e. by the previous lemma.
Any formula
 must eventually turn up on one of these enumerations, hence
 is
decidable.
a
As an application, we will show that the minimal propositional dynamic logic is
decidable.
Corollary 6.14 PDL is decidable.
Proof. By Theorem 4.91, PDL is complete with respect to the set of all regular
PDL-models. The axioms of PDL clearly form a recursive set, so trivially they
form a recursively enumerable set, thus to be able to apply the Theorem 6.13 it
only remains to show that PDL has the ﬁnite model property with respect to an r.e.
set of models.
This follows easily from our completeness proof for PDL. Recall that we proved
completeness by constructing, for any consistent formula
, a ﬁnite model
P that
satisﬁed
. This gives us what we want, modulo the following glitch: although



6 Computability and Complexity
P contains only ﬁnitely many nodes, it may contain inﬁnitely many non-empty
relations, thus it may not be of ﬁnite character and thus (strictly speaking) our
completeness proof does not establish that PDL has the ﬁnite model property. This
is a triviality: for any formula
, only ﬁnitely many of the relations on
P are
relevant to the satisﬁability of
, namely those that actually occur in
. Let
R
 be
the smallest set that contains all the relations in
P corresponding to modalities in
 and is downward closed under the usual relation constructors (that is, if
R

;
R
 then so are
R
 and
R

0, and analogously for relations deﬁned by union and
transitive closure). Note that
R
 is ﬁnite. Let
P
0 be the model that is identical
to
P save that all the relations not in
R
 are empty; we call
P
0 a reduced model.
Clearly
P
0 is a ﬁnitely based model that satisﬁes
. This shows that PDL has the
ﬁnite model property.
The set of reduced models is a recursive set, since checking that a ﬁnite model is
a reduced model boils down to showing that the relations corresponding to non-
basic modalities really are generated out of simpler relations via composition,
union, or transitive closure, and this is obviously something we can write a program
to do. Hence, the relevant models are recursively enumerable, thus the conditions
of Theorem 6.13 are satisﬁed, and PDL is decidable.
a
We can also show that PDL is decidable by appealing to Theorem 6.7. As we have
just seen, our completeness proof for PDL gives us the ﬁnite model property for
PDL — but in fact it even gives us the strong ﬁnite model property. To see this,
recall that for any consistent
, we constructed
P out of atoms, that is, maximal
consistent subsets of the Fisher-Ladner closure of
fg. As there are at most
cjj
such atoms for some constant
c, we have a computable upper bound on the size of
the models needed to satisfy
. We noted in the proof of Corollary 6.14 that the
relevant ﬁnite models (the reduced models) form a recursive set, hence we have
established everything we need to apply Theorem 6.7.
Theorem 6.13 is a fundamental one and is useful in practice. It does not make
use of axiomatizations in a particularly interesting way: it uses them merely to
enumerate validities. To apply the theorem we need to know that the set of relevant
ﬁnite models is recursively enumerable. We often have much stronger syntactic
information at our disposal: we may know that a logic is ﬁnitely axiomatizable.
Our next theorem is based on the following observation: if a logic with the f.m.p.
is ﬁnitely axiomatizable, we can use the axiomatization not only to recursively
enumerate the validities, but to help us enumerate the non-validities as well.
Theorem 6.15 If
 is a ﬁnitely axiomatizable normal modal logic with the ﬁnite
model property, then
 is decidable.
Proof. As in the proof of Theorem 6.13 we can use the axiomatization to recur-



6.2 Decidability via Finite Models
sively enumerate
, so if we can show that the set of formulas not in
 is also r.e.
we will have proved the theorem.
By Theorem 6.5, if
 has the ﬁnite model property it also has the ﬁnite frame
property, thus there is some set of ﬁnite frames F such that

=
F. Hence,
if

,
 is falsiﬁable in some model based on a frame in
F. Obviously all
such frames must validate every axiom of
, hence if

,
 is falsiﬁable in
some model based on a frame that validates the
 axioms. Now for the crucial
observation: we can write a machine
M which decides whether or not a ﬁnite
frame validates the
 axioms, for as
 has only ﬁnitely many axioms, each frame
can be checked in ﬁnitely many steps. With the help of
M, we can recursively
enumerate the formulas falsiﬁable in some F-based model, but these are just the
formulas which do not belong to
. It follows that
 is decidable.
a
Can Theorem 6.15 be strengthened by replacing its demand for a ﬁnite axiomati-
zation with a demand for a recursive axiomatization? No — in Exercise 6.2.5 we
give an example of an undecidable recursively axiomatizable logic KU
X with the
ﬁnite model property; the result hinges on Craig’s Lemma.
Theorem 6.15 has many applications, for many common modal and tense logics
have the f.m.p. and are ﬁnitely axiomatizable. For example, Theorem 6.15 yields
another proof that K, T, KB, K4, S4, S5, K
t, K
t
4:3, and K
t
Q are decidable, for
all these logics were shown to be ﬁnitely axiomatizable in Chapter 4, and we saw
above that they all have the (strong) ﬁnite model property. However, a more inter-
esting application follows from our work on logics extending S4.3 in Section 4.9.
Corollary 6.16 Every normal logic extending S4.3 is decidable.
Proof. By Bull’s Theorem (Theorem 4.96) every normal logic extending S4.3 has
the ﬁnite model property, and by Theorem 4.101 every normal logic extending
S4.3 is ﬁnitely axiomatizable. Hence the result is an immediate corollary of Theo-
rem 6.15.
a
Corollary 6.16 completes the main discussion of the section. To summarize what
we have learned so far, in Theorems 6.7, 6.13, and 6.15 we have results that pin
down three important situations in which the ﬁnite model property implies decid-
ability — and indeed, most modal decidability results make use of one of these
three theorems.
Exercises for Section 6.2
6.2.1 Provide full proof details for Corollary 6.8. Pay particular attention to showing that
K
t
Q has the f.m.p. with respect to the ﬁnite DUWTO-frames (see Theorem 4.41). Filtra-
tions generally don’t preserve density, so how do we know that this ﬁltration is dense?
(Hint: trichotomy.)



6 Computability and Complexity
6.2.2 Show that if
 is a ﬁnitely axiomatizable normal modal logic with the ﬁnite model
property, then
 has the ﬁnite frame property with respect to a recursive set of frames.
6.2.3 . In this exercise we ask you to show that there is method of ﬁltrating a partial
function that guarantees that the resulting relation is again a partial function.
Consider the model
M
=
(N
;
S;
V
) where
S is the successor relation on the set
N of
natural numbers, and
V makes the proposition letter
p true at precisely the even numbers.
Let
 be the set
f3:p;
3p;
:p;
pg. Prove that no ﬁltration of
M through
 is based on a
frame in which
S
f is a partial function.
6.2.4 In this exercise we ask the reader to prove that there are uncountably many undecid-
able normal modal logics with the polysize model property.
Let
F
suc be the set of all ﬁnite frames
(W
;
R
) such that
W
=
f0;
:
:
:
;
k
g (for some
k
!) and for all

n
<
m

k,
R
nm iff
m
=
n
+
1. (Note that this deﬁnition permits
reﬂexive points. Indeed, any frame in this set is uniquely determined by its size and which
points, if any, are reﬂexive.) Then, for each
j
! deﬁne
F
j to be the set containing: (1) all
the irreﬂexive frames in
F
suc; (2) all the frames in
F
suc whose last point is reﬂexive; and
(3) the (unique)
F
suc frame containing
j
+
1 nodes such that
0 is the only reﬂexive point;
call this frame
F
j. Now deﬁne, for any non-empty
I

!,
F
I as the set
S
i2I
F
i; let

I be
its logic.
Deﬁne

j to be the formula
p
^
3p
^
3(:p
^
j
 1
?).
(a) Prove that

j is satisﬁable in
F
i iff
i
=
j.
(b) Prove that if
 is
F
i-satisﬁable, then it is satisﬁable on a frame in
F
i that contains
at most
m
+
2 points, where
m is the number of modalities in
.
(c) Prove that if
I and
J are distinct (non-empty) subsets of
! then there is a formula
that is satisﬁable in
F
I but not in
F
J.
(d) Prove that each

I has the polysize model property.
(e) Prove that there can only be countably many decidable logics. (This step is actually
the easiest one: after all, how many distinct Turing machines can there be?)
(f) Conclude that there are uncountably many undecidable normal modal logics with
the polysize model property.
6.2.5 Let
X be an r.e. subset of the natural numbers that is not recursive; assume that
X but
X. Then KU
X is the smallest normal modal logic containing the following
formulas:
(U1)
3(3p
^
3q
)
!
33(p
^
q
)
(U2)
3(p
^
?)
^
3(q
^
?)
!
3(p
^
q
)
(U3)
3(p
^
3>)
^
3(q
^
3>)
!
3(p
^
q
)
(U4)
k
(32
?
^33>)
!
k
3>, where
k
X.
Note that by Craig’s Lemma KU
X has a recursive axiomatization.
(a) Use Sahlqvist’s Correspondence and Completeness Theorem to ﬁnd a ﬁrst order
deﬁnable class
U of frames for which KU
X is sound and complete.
(b) Prove that KU
X has the ﬁnite model property.
(c) Show that KU
X is undecidable.
(Hint: prove that any formula U4
j with
j not in
X, is not satisﬁable in
U.)



6.3 Decidability via Interpretations
6.3 Decidability via Interpretations
For all its usefulness, decidability via ﬁnite models has a number of limitations.
One is absolute: as we will shortly see, there are decidable logics that lack the
ﬁnite model property. Another is practical: it may be difﬁcult to establish the ﬁnite
model property, for although ﬁltration or selection work in many cases, no univer-
sal approach is known. Thus we need to become familiar with other techniques
for establishing decidability, and in this section we introduce an important one:
decidability via interpretations, and in particular, interpretations in SnS.
A general strategy for proving a problem decidable is to effectively reduce it to
a problem already known to be decidable. But there are many decidable problems;
which of them can help us prove modal decidability results? Ideally, we would
like to ﬁnd a decidable problem, or class of problems, to which modal satisﬁability
problems can be reduced in a reasonably natural manner. Moreover, we would
like the approach to be as general as possible: not only should a large number of
modal satisﬁability problems be so reducible, but the required reductions should
be reasonably uniform.
A suitable group of problems is the satisﬁability problem for SnS (where
n
!
or
n
=
!), the monadic second-order theory of trees of inﬁnite depth, where each
node has
n successors. Because these problems are themselves satisﬁability prob-
lems — and indeed, satisﬁability problems for monadic second-order languages,
the kinds of language used in correspondence theory — it can be relatively straight-
forward to reduce modal satisﬁability to SnS satisﬁability. Moreover, the various
reductions share certain core ideas; for example, analogs of the standard translation
play a useful role. The method can also be used for strong modal languages, such
as languages containing the until operator
U, see Exercise 2.2.4.
In this section we introduce the reader to such reductions (or better, for reasons
which will become clear, interpretations). We ﬁrst introduce the theories SnS,
note some examples of their expressivity, and state the crucial decidability results
on which subsequent work depends. We then illustrate the method of interpreta-
tions with two examples. First, we prove that KvB, a logic lacking the ﬁnite model
property, is decidable. As KvB is characterized by a single structure (namely, a
certain general frame) this example gives us a relatively straightforward introduc-
tion to the method. We then show how the decidability of S4 can be proved via
interpretation. The result itself is rather unexciting — we already know that S4 has
the ﬁnite model property and is decidable (see Corollary 6.8) — but the proof is
important and instructive. S4 is most naturally characterized as the logic of transi-
tive and reﬂexive frames, but this is a characterization in terms of an uncountable
class of structures. How can this characterization be ‘interpreted’ in SnS? In fact,
it can be done rather naturally, and the ideas involved open the doors to a wide
range of further decidability results.



6 Computability and Complexity
Let us set about deﬁning SnS. If
A is some ﬁxed set (our alphabet), then
A
 is
the set of all ﬁnite sequences of elements of
A, including the null-sequence
. We
introduce the following apparatus:
(i) Deﬁne an ordering
 on
A
 by
x

y if
y
=
xz for some
z
A
. Clearly
this ‘initial-segment-of’ relation is a partial order. If
x

y and
x
6=
y we
write
x
<
y.
(ii) Suppose
A is totally ordered by a relation
<
A. Then we deﬁne
 to be the
lexicographic ordering of
A
 induced by
<
A. That is,
x

y if and only if
x

y, or
x
=
z
au and
y
=
z
bv where
a;
b
A and
a
<
A
b. Note that

totally orders
A
.
(iii) For any
a
A we deﬁne
r
a
:
A

!
A
, the a-th successor function, by
r
a
(x)
=
xa.
Deﬁnition 6.17 (S
nS) For any
n such that
n is a natural number, or
n
=
!, let
T
n be
fi
!
j
i
<
ng
. The structure
N
n is
(T
n
;
r
i
;
;
)
i<n, where
 is the
lexicographic ordering induced by
<
!, the usual ordering of the natural numbers.
N
n is called the structure of
n successor functions. (Note that all these structures
are countably inﬁnite.)
The monadic second-order theory of
n successor functions is the monadic sec-
ond-order theory of
N
n in the monadic second-order language of appropriate signa-
ture (we spell out the details of this language below); this theory is usually referred
to as SnS.
a
Let us spell out the intuitions underlying this machinery. First, note that each
structure
N
n really is an inﬁnite tree where each node has
n immediate succes-
sors (or daughters, in standard tree terminology). For example, consider
N
1; that
is
(f0g

;
r
;
;
). This is the inﬁnite tree in which each node has exactly one
daughter; that is, it is simply an isomorphic copy of the natural numbers in their
usual order. Next, consider
N
2, that is
(f0;
1g

;
r
;
r
;
;
). This is the full bi-
nary tree (that is, the inﬁnite tree in which every node has exactly two daughters).
An initial segment of
N
2 is shown in Figure 6.1. Note that
 is the root node of
the tree depicted in Figure 6.1, and that
r
0 and
r
1 are the ﬁrst daughter and second
daughter relations, respectively. Further, note that
 has a natural tree-geometric
interpretation: it is simply the dominates relation. That is,
x

y iff it is possible
to reach
x by moving upwards in the tree from
y. Similarly,
 is the dominates-or-
to-the-left-of relation. The tree-like nature of these models plays an important role
in the work that follows, and must be properly understood. In particular, the reader
should check that
N
! really is an inﬁnite tree in which every node has
! daughters.
So much for the structures — what about the theories? Each of the theories
SnS is a monadic second-order theory in the appropriate language. For example,
the monadic second-order language appropriate for talking about
N
2 contains two



6.3 Decidability via Interpretations
...
...
...
...





A
A
A
A
A
A
A
A




@
@
@
@
    Fig. 6.1. An initial segment of
N
function symbols for talking about
r
0 and
r
1 (we will be economical with our
notation and use
r
0 and
r
1 for these symbols) and two binary predicate symbols
for talking about
 and
 (we use
 and
 for this purpose). In addition, the
language contains a denumerably inﬁnite set of individual variables
x,
y,
z, . . . , a
denumerably inﬁnite set of predicate (or set) variables
P,
Q,
S, . . . , that range over
subsets of the domain, and the usual quantiﬁers and boolean operators. The syntax
and semantics of the language is standard; see Section A for further discussion of
monadic second-order logic.
Using these languages, we can say many useful things about
N
n. First, note that
although we did not include a primitive equality predicate, an equality predicate is
deﬁnable over
N
n:
x
=
y iff
x

y
^
y

x:
Next, note that we can deﬁne a unary predicate symbol ROOT that is true only of
the root node
:
ROOT
(x) iff
:9y
(y
<
x):
(6.1)
We can deﬁne the unary higher-order predicate ‘P is a ﬁnite set.’ Recall that a
total ordering
R on a set
S is a well-ordering if every non-empty subset of
S has
an
R-least element; it is a standard observation that
S is well ordered by
R iff
S
contains no inﬁnitely descending
R-chains. It follows that a subset
P of
T
n is ﬁnite
iff it is well-ordered by both
 and its converse, for such a set contains no inﬁnitely
descending
-chains and no inﬁnitely ascending
-chains.
FINITE
(P
) iff
(6.2)
8Q
((9x
Qx
^
8y
(Qy
!
P
y
))
!
9u
(Qu
^
8w
(Qw
!
u

w
))
^
9v
(Qv
^
8w
(Qw
!
w

v
))):
(That is,
P is ﬁnite if every non-empty subset of
P has a
-ﬁrst and a
-last



6 Computability and Complexity
element.) In short, monadic second-order logic is an extremely powerful language
for talking about trees — which makes the following result all the more remarkable.
Theorem 6.18 (Rabin) For any natural number
n, or
n
=
!, SnS is decidable.
That is, for any
n, it is possible to write a Turing machine which, when given
a monadic second-order formula (in the language of appropriate signature), cor-
rectly decides whether or not the formula is satisﬁable in
N
n. The proof of this
beautiful result is beyond the scope of this book; we refer the reader to the Notes
for discussion and references.
Given a modal logic
, how can we use the fact of SnS-decidability to estab-
lish
-decidability? Suppose

=
M for some class of countable models M.
The essence of the interpretation method is to attempt to construct, for any modal
formula
, a monadic second-order formula Sat-
() that does three things.
 It must encode the information in
; this is usually achieved by using some
variant of the standard translation.
 It must deﬁne a set of substructures of
N
n (for some choice of
n) which are
isomorphic copies of the models in M.
 It must bring the two previous steps together. That is, Sat-
() must be con-
structed so that it is satisﬁable in
N
n iff (the translation of)
 is satisﬁable in (a
deﬁnable substructure of
N
n that is isomorphic to) a model in
M — that is, iff

is
-satisﬁable.
If such a formula Sat-
() can be constructed, the ramiﬁcations for modal decid-
ability are clear: as SnS is decidable, we can decide whether or not Sat-
() is
satisﬁable on
N
n. As this is equivalent to deciding the
-satisﬁability of
, we will
have established that
 is decidable.
As our ﬁrst example of the method in action, we will prove the decidability of
KvB. We met this logic brieﬂy in Exercise 4.4.2; it is the logic of a certain general
frame
J. The domain
J of
J consists of
N
[
f!
;
!
+
1g (that is, the set of natural
numbers together with two further points), and the relation
R is deﬁned by
R
xy iff
x
6=
!
+
1 and
y
<
x or
x
=
!
+
1 and
y
=
!. The frame
(J
;
R
) is shown in
Figure 6.2.
A, the collection of subsets of
J admissible in
J, consists of all
X

J
such that either
X is ﬁnite and
!
X, or
X is co-ﬁnite and
!
X.
As the reader was asked to show in Exercise 4.4.2, KvB is incomplete; that is, there
is no class of frames F such that
KvB
=
F. By Theorem 6.5 it follows that KvB
lacks the ﬁnite model property. Even though it lacks the ﬁnite model property, KvB
is decidable, and we will demonstrate this via an interpretation in S2S.
Theorem 6.19 KvB is decidable.



6.3 Decidability via Interpretations
:
:
:



a
a
a


a
a
a













)





=
?
v
v
v
v
v
!
!
+
Fig. 6.2. The frame underlying
J. Note that
!
+
1 is related only to
!.
Proof. Let us make two initial assumptions; we will shortly show that both as-
sumptions are correct. First, let us suppose that
J
=
(J
;
R
;
A) can be isomorphi-
cally embedded in
N
2. We will refer to this isomorphic copy as
J; no confusion
should arise because of this double usage. Furthermore, let us suppose that this
isomorphic image is deﬁnable in the monadic second-order language for
N
2. That
is, suppose that there are formulas
b
J
(x),
b
R
(x;
y
) and
b
A(P
) (containing 1 free indi-
vidual variable
x, 2 free individual variables
x and
y, and 1 free predicate variable
P, respectively) such that
J
=
ft
T
j
N
j
=
b
J
(x)[t]g
R
=
f(t;
t
)
T

T
j
N
j
=
b
R(x;
y
)[t;
t
]g
A
=
fU

T
j
N
j
=
b
A(P
)[U
]g:
Given these assumptions, it is easy to reduce the satisﬁability problem for the gen-
eral frame to the satisﬁability problem for S2S. First, with the help of the formula
b
R, we can deﬁne a translation
T from the modal language into the second-order
language:
T
x
(p)
=
P
x
T
x
(:)
=
:T
x
()
T
x
(
^
 
)
=
T
x
()
^
T
x
( 
)
T
x
(3)
=
9y
(
b
R
xy
^
T
y
())
Note that
T
x is just the standard translation with the formula
b
R replacing the use
of a ﬁxed relation symbol. We leave it as an exercise to show that for any modal
formula
 (built out of proposition letters
p
;
:
:
:
;
p
n)
((J
;
R
;
A);
V
);
w

 iff
N
j
=
T
x
()[w
;
V
(p
);
:
:
:
;
V
(p
n
)]:
(6.3)
(See Exercise 6.3.1; the notation
[w
;
V
(p
);
:
:
:
;
V
(p
n
)] means assign the state
w
to the free variable
x, and assign the subset
V
(p
i
) to the predicate variable
P
i.)
For any modal formula
, let Sat-KvB
() be the following monadic second-order
sentence:
9P
:
:
:
9P
n
9x
(
b
A(P
)
^



^
b
A(P
n
)
^
b
J
(x)
^
T
x
()):



6 Computability and Complexity
It follows that
 is satisﬁable in
(J
;
R
;
A) iff
N
j
= Sat-KvB
(). Thus — given our
two initial assumptions — we have effectively reduced the satisﬁability problem
for KvB to the S2S-satisﬁability problem, for
 is satisﬁable on
J iff Sat-KvB
()
belongs to S2S, and by Rabin’s result it is possible to decide the latter.
Hence, to complete the proof that KvB is decidable, it only remains to show that
our assumptions were justiﬁed; that is, to show that
J really does have a deﬁnable
isomorphic image in
N
2. Given the expressive power at our disposal, this is actu-
ally rather easy to do. We will make use of the general predicates
=, ROOT, and
FINITE deﬁned in (6.1) and (6.2). In addition, we will use
x
<
y iff
r
(x)

y
^
:9z
(x

z
^
r
(z
)

y
):
Note that
x
<
y means that
x is a proper initial subsequence of
y such that
y
extends
x by a ﬁnite sequence of 1s — or, in terms of tree geometry, it is possible
to move down from
x to
y by using only the ‘second daughter’ relation.
We will now deﬁne an isomorphic image of
J in
N
2. First, we can deﬁne the
numeric part of the underlying frame as follows:
N
(x) iff ROOT
(x)
_
9y
(ROOT
(y
)
^
y
<
x):
The isomorphism involved should be clear: the natural number zero is taken to be
the empty sequence, and the positive integer
n is taken to be the sequence of
n 1s.
Next, we will represent
! by 0, and
!
+
1 by 00. Deﬁning these choices is easy:
OMEGA
(x)
iff
9y
(ROOT
(y
)
^
x
=
r
(y
))
OMEGA+1
(x)
iff
9y
(ROOT
(y
)
^
x
=
r
(r
(y
))):
Putting it all together, we deﬁne the required predicates
b
J and
b
R as follows:
b
J
(x)
=
N
x
_ OMEGA
(x)
_ OMEGA+1
(x)
b
R(x;
y
)
=
(N
y
^
(y
<
x
_ OMEGA
(x)))
_
(OMEGA
(y
)
^ OMEGA+1
(x)):
Clearly these two formulas deﬁne a subset of the tree domain isomorphic to
(J
;
R
).
Thus it merely remains to deﬁne
A, the class of allowable valuations. With the help
of the FINITE predicate, this is straightforward.
b
A(P
) iff
8x
(P
x
!
b
J
(x))
^
((FINITE
(P
)
^
8z
(OMEGA
(z
)
!
:P
z
))
_
8Q8x
(Qx
$
(J
x
^
:P
x)
!
(FINITE
(Q)
^
8z
(OMEGA
(z
)
!
:Qz
))))
In short, a deﬁnable isomorphic image of
J really does live inside
N
2. We conclude
that KvB is decidable.
a
While the above result is a nice introduction to decidability via interpretation, in
one respect it is rather misleading. KvB is characterized by a single structure (and



6.3 Decidability via Interpretations
a rather simple one at that) thus we only had to deﬁne a single isomorphic image,
and were able to do this fairly straightforwardly using S2S. However, as we saw
in Chapter 4, it is usual to characterize logics in terms of a class of structures; for
example, S4 is usually characterized as the logic of the class of reﬂexive and tran-
sitive models. Do class-based characterizations mesh well with the idea of decid-
ability via interpretations? Classes of models may contain uncountable structures
— and only countable structures can be isomorphically embedded in
N
n. And
why should we expect to be able to isomorphically embed even countable models
in inﬁnite trees?
Two simple observations clear the way. First, in many important cases, only
the countable structures in characterizing classes are required. Second, there is
a standard method for converting a model into a tree-based model, namely the
unraveling method studied in Chapters 2 and 4. Taken together, these observations
enable us to view the classes of structures characterizing many important logics
as a collection of deﬁnable substructures of
N
!. We will illustrate the key ideas
involved by proving the decidability of S4 via interpretation in S!S.
As a ﬁrst step, we claim that S4 is sound and strongly complete with respect to
the class of countable reﬂexive and transitive models. We could prove this directly
(for example, using the step-by-step method discussed in Section 4.6) but it also
follows from the following general observation. (Recall that for the duration of this
chapter, we are only working with countable languages.)
Theorem 6.20 If
 is a normal logic that is sound and strongly complete with re-
spect to a ﬁrst-order deﬁnable class of models M, then
 is also sound and strongly
complete with respect to the class of all countable models in M.
Proof. Left as Exercise 6.3.3.
a
Lemma 6.21 S4 is sound and strongly complete with respect to the class of count-
able (reﬂexive and transitive) trees.
Proof. By Theorems 4.29 and 6.20, S4 is sound and strongly complete with respect
to the class of countable reﬂexive, transitive models; that is, every S4-consistent
set of sentences
 is satisﬁable on such a model
M
=
(W
;
R
;
V
) at some point
w.
Now, (as in the proof of Theorem 4.54) let
~
M
=
(
~
W
;
~
R
;
~
V
) be the unraveling of
M
around
w, and let
M
 be
(
~
W
;
R

;
~
V
), where
R
 is the reﬂexive transitive closure
of
~
R; this model is a reﬂexive transitive tree that veriﬁes
 at its root. Moreover,
it is a countable model, for its nodes are all the ﬁnite sequences of states in
M that
start at
w, and as
M is countable, there are only countably many such sequences.
The result follows.
a
Corollary 6.22 S4 is decidable, and its decidability can be proved via interpreta-
tions.



6 Computability and Complexity
Proof. Let us call a subset of
N
! an initial subtree if it contains
 and is closed
under the inverse of
 (that is, if
y belongs to the subset, and
x

y, then
x
belongs to the subset). If
S is such a subtree, then

S denotes the restriction of
 to
S. Now for the key observation. Let
(
~
W
;
~
R
) be the unraveling of some
countable S4-frame
(W
;
R
) around a point
w, and let
R
 be the reﬂexive transitive
closure of
~
R. Then
(
~
W
;
R

) is isomorphic to a pair
(S;

S
) for some initial subtree
S. To see this, note that we can inductively construct an isomorphism
f from
(
~
W
;
R

) to some initial subtree as follows. First, we stipulate that
f maps the root
of
(
~
W
;
R

) to
. Next, suppose that for some
~
u
~
W
;
f
(
~
u) has been deﬁned to be
m. Now,
f
~
s
~
W
j
~
u
~
R
~
sg is a countable set as
~
W is countable, so we can enumerate
its elements. Then, if
~
s is the
i-th element in this enumeration, we stipulate that
f
(
~
s
)
=
r
i
(m). (That is, the successor of
~
u that is
i-th in our enumeration is mapped
to the
i-th successor of
m.) In short,
N
! is ‘wide enough’ to accommodate a copy
of every branch through a tree-like S4 model in a very obvious way. In fact, it is
precisely because the required isomorphisms are so simple that we have elected to
work with
N
!.
With this observed, the interpretation is easy to deﬁne. First, we deﬁne a predi-
cate ISUBTREE
(S
), which picks out the initial subtrees of
N
!:
ISUBTREE
(S
) iff
9y
(ROOT
(y
)
^
S
y
)
^
8z
8u
((S
z
^
u

z
)
!
S
u)):
Second, we deﬁne a predicate

S that deﬁnes the restriction of
 to a subset
S of
N
! by
x

S
y iff
S
x
^
S
y
^
x

y
:
Third, we deﬁne a translation
T
! from the basic modal language to the monadic
second-order language for
N
!. Like the translation
T we used when proving the
decidability of KvB this translation is a simple variant of the standard translation.
In fact, it is identical to
T save in the clause for modalities, which is given by:
T
!
x;S
(3)
=
9y
(x

S
y
^
T
!
y
;S
()):
Note that as well as containing the free individual variable
x, the translation of
3
contains a free set variable
S; when written in full the above expression becomes:
T
!
x;S
(3)
=
9y
(S
x
^
S
y
^
x

y
^
T
!
y
;S
()):
We need the free variable here because we are not working with one ﬁxed isomor-
phic image (as we were when proving the decidability of KvB). Rather, we have
a separate relation for each initial subtree, and the presence of the free variable
allows all our deﬁnitions to be relativized in the appropriate way.
It simply remains to put it all together. Suppose
 is a modal formula constructed
out of the proposition letters
p
1, . . . ,
p
n. Deﬁne Sat-S4
() to be the following



6.3 Decidability via Interpretations
sentence:
9S
9P
:
:
:
9P
n
9x
 ISUBTREE
(S
)
^
8z
(P
z
!
S
z
)
^



^
8z
(P
n
z
!
S
z
)
^
S
x
^
T
!
x;S
()

:
Recall that
T
!
() contains free occurrences of
S and
x; these become bound in
this sentence. Bearing this in mind, it is clear this sentence asserts the existence of
an initial subtree
S of
N
!, a collection of
n subsets
P
i of this subtree, and a state
x in the subtree, that satisfy the translation of
. That is, it asserts the existence
of a tree-like S4 model for the (translation of)
, and we have reduced the
S4-
satisﬁability problem to the S!S-satisﬁability problem.
a
This completes our discussion of interpretations in SnS — though we should im-
mediately admit that we have barely scratched the surface of the method’s poten-
tial: Rabin’s theorem is very strong, the ideas underlying it make contact with many
branches of mathematics, and it has become a fundamental tool in many branches
of logic and theoretical computer science. Nonetheless, our discussion has un-
earthed themes relevant to modal logic: the importance of establishing complete-
ness results with respect to classes of countable structures, the use of unraveling
to produce tree-like models, and the particular utility of
N
! in allowing reasonably
straightforward isomorphic embeddings. These three ideas enable a wide range of
modal decidability results to be proved via interpretations.
One ﬁnal remark: while SnS is important, it is certainly not the only logical sys-
tem in which modal logics can be interpreted. Many fragments of classical logic,
or theories in classical logics, are known to be decidable, and offer opportunities
for proving modal decidability results. Indeed we have already met a (very simple)
example. We pointed out in Section 2.4 that the basic modal language translates
into the 2 variable fragment of classical logic, (see Proposition 2.49), from which it
immediately follows that K (and some simple extensions such as T) are decidable.
Moreover, on occasions it can be useful to interpret a modal logic in another modal
logic already known to be decidable. See the Notes for further discussion.
Exercises for Section 6.3
6.3.1 We claimed that the general frame for KvB is isomorphically embedded in the tree
domain, and that
b
R deﬁnes the accessibility relation of this isomorphic image. Check this
claim, and show that
((W
;
R
;
A);
V
);
w

 iff
N
j
=
T
x
()[w
;
V
(p
);
:
:
:
;
V
(p
n
)];
for any modal formula
 (see (6.3)).
6.3.2 Show by interpretation in S2S that both the tense logic of the natural numbers, and
the tense logic of the integers, are decidable. Now add the until operator
U to your language
(this operator was deﬁned in Chapter 2 in Exercise 2.2.4). Are the logics of the natural
numbers and the integers in this richer language still decidable?



6 Computability and Complexity
6.3.3 Prove Theorem 6.20. That is, show that if
 is a normal logic that is sound and
strongly complete with respect to a ﬁrst-order deﬁnable class of models M, then
 is also
sound and strongly complete with respect to the class of all countable models in M. (Hint:
use the standard translation and the Downward L¨owenheim-Skolem Theorem.)
