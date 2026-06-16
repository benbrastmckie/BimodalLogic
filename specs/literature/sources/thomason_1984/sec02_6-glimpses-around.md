6. GLIMPSES AROUND

6.1. Metric Tense Logic

In metric tense logic we assume Time has the structure of an ordered Abelian
group. We introduce variables x, y, z, . . . ranging over group elements, and
simples 0, +, < for the group identity, addition, and order. We introduce
operators ¥ . 2 joining terms for group elements with formulas. Here, for
instance, " (x + ¥)(p A q) means that it will be the case (x +y) time-units
hence that p and q. Metric tense logic is intended to reflect such ordinary-
language quantitative expressionsas ‘100years from now’ or ‘tomorrow about
this time’ or ‘in less than five minutes’. The qualitative F, P of nonmetric
tense logic can be recovered by the definitions Fp «— 3x > 0.Fxp, Pp <
Ix > 0Fxp. Actually, the ‘ago’ operator £ is definable in terms of the
‘hence’ operator ¥ since 2’ xp is equivalent to F-xp. It is not hard to write
down axioms for metric tense logic whose completeness can be proved by a
Henkin-style argument.

But decidability is lost: The decision problem for metric tense logic is
easily seen to be equivalent to that for the set of all universal monadic
(second-order) formulas true in all ordered Abelian groups. We will show
that the decision problem for the validity of first-order formulas involving a
single two-place predicate € ~ which is well known to be unsolvable - is
reducible to the latter: Given a first-order €-formula ¢, fix two one-place
predicate variables U, V. Let g, be the result of restricting all quantifiers in ¢

---

128 JOHN P. BURGESS

to U (i.e. Vx is replaced by Vx(U(x)~...) and 3x by Ix(U(x) A . ..).) Let
1 be the result of replacing each atomic subformula x € y of ¢, by 3z(V(z) A
Viz+x)AV(z+x+y)). Let ¢, be the universal monadic formula
VYUVV(3xU(x) - ¢,). Clearly if ¢ is logically valid, then so is y, and, in par-
ticular, the latter is true in all ordered Abelian groups. If ¢ is not logically
valid, it has a countermodel consisting of the positive integers equipped with
a binary relation E. Consider the product Z x Z where Z is the additive group
of integers; addition in this group is defined by (x, )+ (x', ¥') = (x + x/,
¥ +"); the group is orderable by (x, y) <(x', »') iff x <x' or (x = x' and
y <»"). Interpret U in this group as {(n, 0): n > 0}; interpret V as the set con-
sisting of the (2™3", 0), (2™3", m), arid (2™3", m + n) for those pairs
(m, n) with mEn. This gives a countermodel to the truth of ¢, in Z x Z. Thus
the desired reduction of decision problems has been effected.

Metric tense logic is, in a sense, a hybrid between the ‘regimentation’ and
‘autonomous tense logic’ approaches to the logic of time. Other hybrids of a
different sort — not easy to describe briefly - are treated in an interesting
paper of Bull [1970].

6.2. Time and Modality

As mentioned in the introduction, Prior attempted to apply tense logic to the
exegesis of the writings of ancient and mediaeval philosophers and logicians
(and for that matter of modern ones such as C. S. Peirce and J. L.ukasiewicz)
on future contingents. The relations between tense and mood or modality
is properly the topic of Richmond H. Thomason’s chapter in this volume
(IL3).

We can, however, briefly consider here the topic of so-called Diodorean
and Aristotelian modal fragments of a tense logic L. The former is the set of
modal formulas that become theses of L when op is defined as p A Gp; the
latter is the set of modal formulas that become theses of L when op is
defined as Hp Ap A Gp. Though these seem far-fetched definitions of ‘necess-
ity’, the attempt to isolate the modal fragments of various tense logics
undeniable was an important stimulus for the earlier development of our sub-
ject. Briefly the results obtained can be tabulated as follows. It will be seen
that the modal fragments are usually well-known C. 1. Lewis systems.

---

I.2: BASIC TENSE LOGIC 129

Class of frames Tense logic Diodorean fragment Aristotelian fragment
All frames L, T(=M) B

Partial orders L, S4 B

Lattices L, $4.2 B

Total orders L,L, S4.3 S5

Dense orders

The Diodorean fragment of the tense logic L¢ of discrete orders has been
determined by M. Dummett; the Aristotelian fragment of the tense logic of
trees has been determined by G. Kessler. See also our comments below on
R. Goldblatt’s work.

6.3. Relativistic Tense Logic

The cosmic frame is the set of all point-events of space-time equipped with
the relation of causal accessibility, which holds between u and v if a signal
(material or electromagnetic) could be sent from u to v. The (n + 1)-
dimensional Minkowski frame is the set of (n + 1)-tuples of real numbers
equipped with the relation which holds between (a9, «;, ..., a,) and
(bo, b1, . . ., by)iff:

n

Y (bn—8,) —(bo—a0)*>0 and by >a,.

it
For present purposes, the content of the special theory of relativity is that
the cosmic frame is isomorphic to the 4-dimensional Minkowski frame.

A little calculating shows that any Minkowski frame is a lattice without
maximum or minimum, hence the tense logic of special relativity should at
least include Lo. Actually we will also want some axioms to express the den-
sity and continuity of a Minkowski frame. A surprising discovery of Goldblatt
[1980] is that the dimension of a Minkowski frame influences its tense logic.
Indeed, he shows that for each n there is a formula v,, ,, which is valid in the
(m + 1)-dimensional Minkowski frame iff m <n. For example, writing Ep for
PAFp,y,is:

EpAEGAErA—=E(pAq)A—E(pAT)A—E(@AT)~>
E((Ep AEq) v(Ep A Er) v(Eq A ET)).

On the other hand, he also shows that the dimension of a Minkowski frame
does not influence the Diodorean modal fragment of its tense logic: The

---

130 JOHN P. BURGESS

Diodorean modal logic of special relativity is the same as that of arbitrary
lattices, namely S4.2. Combining Goldblatt’s argument with the ‘trousers
world’ construction in general relativity, should produce a proof that the
Diodorean modal fragment of the latter is the same as that of arbitrary
partial orders, namely S4.

Despite recent advances, the tense logic of special relativity has not yet
been completely worked out; that of general relativity is even less well under-
stood. Burgess [1979] contains a few additional philosophical remarks.

6.4. Thermodynamic Time

One of the oldest metaphysical conceits (found in Hindu theology and pre-
Socratic philosophy, and in modern psychological dress in Nietzsche and
celestial mechanical dress in Poincaré) is that everything that has ever hap-
pened is destined to be repeated over and over again. This leads to a degener-
ate tense logic containing the principles Gp ~ Hp and Gp - p among others.

An antithetical view is that traditionally associated with the Second Law
of Thermodynamics, according to which irreversible changes are taking place
that will eventually drive the Universe to a state of ‘heat-death’, after which
no further change on a macroscopically observable level will take place. The
tense logic of this view, which raises several interesting technical points, has
been investigated by S. K. Thomason [1972]. The first thing to note is that
the principle:

(A10) GFp— FGp

is acceptable for p expressing propositions about macroscopically observable
states of affairs provided these do not contain hidden time references;e.g. p
could be ‘there is now no life on Earth’, but not ‘particle k currently has a
momentum of precisely & gram-meters/second’ or ‘it is now an even number
of days since the Heat Death occurred’. For the antecedent of (A10) says that
arbitrarily far in the future there will be times when p is the case. But for the
p that concern us, the truth-value of p is never supposed to change after the
Heat Death. So in that case, there will come a time after which p is always
going to be true, in accordance with the consequent of (A10).

The question now arises, how can we formalize the restriction of p to a
special class of sentences? In general, propositions are represented in the
formal semantics of tense logic by subsets of X in a frame (X, R). A restricted
class of propositions could thus be represented by a distinguished family &
of subsets of X. This motivates the following definition: An augmented frame

---

I.2: BASIC TENSE LOGIC 131

is a triple (X, R, &) where (X, R) is a frame, & a subset of the power set
F(X) of X closed under complementation, finite intersection, and the oper-

ations:
gA = {x EX:Vy EX(xRy >y €EA)}

hA = {xEX:Vy EX(YRx >y €A)}.

A valuation in (X, R, &) is a function V assigning each variable p; an element
of #. The closure conditions on % guarantee that we will then have
V(a) € & for all formulas a. It is now clear how to define validity. Note that
if & =9°(X), then validity in (X, R,&) reduces to validity in (X, R); other-
wise more formulas may be valid in the former than the latter.

It turns out that the extension L;o of Lg obtained by adding A10 is
(sound and) complete for the class of augmented frames (X, R,.#) in which
(X, R) is a dense total order without maximum or minimum and:

VB € F3Ix(Vy(xRy >y € B) vVy(xRy >y & B))

We have given complete axiomatizations for many intuitively important
classes of frames. We have not yet broached the questions: When does the
tense logic of a given class of frames admit a complete axiomatization? When
does a given -axiomatic system of tense logic correspond to some class of
frames in the sense of being complete for that class? For information on these
large questions, and for bibliographical references, we refer the reader to
Johan van Benthem’s chapter in this volume on so-called ‘Correspondence
Theory’ (I1.4). Suffice it to say here that positive general theorems are few,
counterexamples many. The thermodynamic tense logic L,, exemplifies one
sort of pathology. Though it is not inconsistent, there is no (unaugmented)
frame in which all its theses are valid!

6.5. Quantified Tense Logic

The interaction of temporal operators with universal and existential quanti-
fiers raises many difficult issues, both philosophical (over identity through
changes, continuity, motion and change, reference to what no longer exists
or does not exist, essence, and many, many more) and technical (over
undecidability, nonaxiomatizability, undefinability or multi-dimensional
operators, and so forth) that it is pointless to attempt even a survey of the
subject in a paragraph or two. We therefore refer the reader to Nino
Cocchiarella’s [I1.6] and James W. Garson’s [I1.5] chapters on this subject in
this volume.

Princeton University

---

132 JOHN P. BURGESS

REFERENCES

Aqvist, K.: 1975, ‘Formal semantics for verb tenses as analyzed by Reichenbach’ in
T. A. van Dijk (ed.), Pragmatics of Lanugage and Literature, North Holland, Amster-
dam, pp. 229-236.

Aqvist, L. and Guenthner, F.: 1978, ‘Fundamentals of a theory of verb aspect and events
within the setting of an improved tense logic’, in F. Guenthner and C. Rohrer (eds.)
Studies in Formal Semantics, North Holland, Amsterdam, pp. 167-200.

Aqvist, L. and Guenthner, F., (eds): 1977, ‘Tense logic’ (= Logique et Analyse 80).

Bull, R. A.: 1968, ‘An algebraic study of tense logic with linear time’, J. Symbolic Logic
33,27-38.

Bull, R. A.: 1978, ‘An approach to tense logic’, Theoria 36, 282-300.

Burgess, J. P.: 1979, ‘Logic and time’, J. Symbolic Logic 44, 566-582.

Burgess, J. P.: 1982, ‘Axioms for tense logic’, Notre Dame J. Formal Logic. 23, 367-383.

Burgess, J. P. and Gurevich, Y.: ‘The decision problem for linear temporal logic’ (to
appear).

Gabbay, D. M.: 1975, ‘Model theory for tense logics and decidability results for non-
classical logics’, Ann. Math. Logic 8, 185-295.

Gabbay, D. M.: 1976, Investigations in Modal and Tense Logics with Applications to
Problems in Philosophy and Linguistics, Reidel, Dordrecht.

Gabbay, D. M.: 1981a, ‘Expressive functional completeness in tense logic’ (Preliminary
Report), in U. Monnich (ed.), Aspects of Philosophical Logic, Reidel, Dordrecht,
pp- 91-117.

Gabbay, D. M.: 1981b, ‘An irreflexivity lemma with applications of conditions on tense
frames’, in U. Monnich (ed.), Aspects of Philosophical Logic, Reidel, Dordrecht,
pp. 67-89.

Gabbay, D. M. and Guenthner, F.: 1982, ‘A note on many-dimensional tense logics’, in
T. Pauli (ed.), Philosophical Essays Dedicated to Lennart Aqvist on his Fiftieth Birth-
day, University of Uppsala, pp. 63-70.

Gabbay, D.M. and Guenthner, F.: Elements of Tense Logic and its Applications,
Bibliopolis, Naples (to appear).

Gabbay, D. M., Pnuelli, A., Shelah, S. and Stavi, J.: 1980, ‘On the temporal analysis of
fairness’, Proc. 7th ACM Symp. Principles Prog. Lang., pp. 163-173.

Goldblatt, R.: 1980, ‘Diodorean modality in Minkowski spacetime’, Studia Logica 39,
219-236.

Gurevich, Y.: 1977, ‘Expanded theory of ordered Abelian groups’, 4nn. Math. Logic 12,
192-228.

Humberstone, L.: 1979, ‘Interval semantics for tense logics’, J. Philoosphical Logic 8,
171-196.

Kamp, J. A. W.: 1968, Tense logic and the theory of linear order’, doctoral dissertation,
UCLA.

Kamp, J. A. W.: 1971, ‘Formal properties of “Now”, Theoria 37,227-273.

McArthur, R. P.: 1976, Tense Logic, Reidel, Dordrecht.

Normore, C.: 1982, ‘Future contingents’, in A.Kenny et al. (eds.), The Cambridge
History of Later Medieval Philosophy, University Press, Cambridge.

Pratt, V. R.: 1980, ‘Applications of modal logic to programming’, Studia Logica 39,
257-2174.

---

IL.2: BASIC TENSE LOGIC 133

Prior, A. N.: 1957, Time and Modality, Clarendon Press, Oxford.

Prior, A. N.: 1967, Past, Present and Future, Clarendon Press, Oxford.

Prior, A. N.: 1968, Papers on Time and Tense, Clarendon Press, Oxford.

Quine, W. van O.: 1960, Word and Object, MIT Press, Cambridge, Mass.

Rabin, M. O.: 1966, ‘Decidability of second order theories and automata on infinite
trees’, Trans Amer. Math. Soc. 141, 1-35.

Rescher, N. and Urquhart, A.: 1971, Temporal Logic, Springer, Berlin.

Rohrer, Ch. (ed.): 1980, Time, Tense and Quantifiers, Max Niemeyer, Tiibingen.

Segerberg, K.: 1970, ‘Modal logics with linear alternative relations’, Theoria 36, 301-322.

Segerberg, K. (ed.): 1980, ‘Trends in modal logic’, Studia Logica 39, No. 3. '

Shelah, S.: 1975, ‘The monadic theory of order’, Ann. Math. 102, 379-419.

Thomason, S. K.: 1972, ‘Semantic analysis of tense logic’, J. Symbolic Logic 37,
150-158.

Van Benthem, J. F. A. K.: 1978, ‘Tense logic and standard logic’, Logique et analyse 80,
47-83.

Van Benthem, J. F. A, K.: 1981, ‘Tense logic, second order logic, and natural language’,
in U. MOnnich (ed.), Aspects of Philosophical Logic, Reidel, Dordrecht, pp. 1-20.

Van Benthem, J. F. A. K.: 1983, The Logic of Time, Reidel Dordrecht.

Vlach, F.: 1973, ‘Now and then: a formal study in the logic of tense anaphora’, doctoral
dissertation, UCLA.

---

CHAPTER IL.3

COMBINATIONS OF TENSE AND MODALITY
by RICHMOND H. THOMASON

1. Interactions with time 135
2. Introduction to historical necessity 136
3. Historical necessity 141
4. The technical side of historical necessity 146
5. Deontic logic combined with historical necessity 153
6. Conditional logic combined with historical necessity 157
Notes 159
References 163

1.INTERACTIONS WITH TIME

Physics should have helped us to realize that a temporal theory of a
phenomenon X is, in general, more than a simple combination of two compo-
nents: the statics of X and *he ordered set of temporal instants. The case in
which all functions from times to world-states are allowed is uninteresting;
there are too many such functions, and the theory has not begun until we
have begun to restrict them. And often the principles that emerge from the
interaction of time with the phenomena seem new and surprising. The most
dramatic example of this, perhaps, is the interaction of space with time in
relativistic space-time.

The general moral, then, is that we shouldn’t expect the theory of time
+ X to be obtained by mechanically combining the theory of time and the
theory of X!

Probability is a case that is closer to our topic. Much ink has been spilled
over the evolution of probabilities: take, for instance, the mathematical
theory of Markov processes: (Howard [1971a, b] make a good text), or the
more philosophical question of rational belief change (see, for example,
Chapter 11 of Jeffrey [1965], and Harper [1975].) Again, there is more to
these combinations than can be obtained by separate reflection on probabil-
ity measures and the time axis.

Probability shares many features with modalities and, despite the fact that
(classical) probabilities are numbers, perhaps in some sense probability is a
modality. It is certainly the classic case of the use of possible worlds in

135

D. Gabbay and F. Guenthner (eds.), Handbook of Philosophical Logic, Vol. II, 135-165.
© 1984 by D. Reidel Publishing Company.

---

136 RICHMOND H. THOMASON

interpreting a calculus. (Sample points in a state space are merely possible
worlds under another name.) But the literature on probability is enormous,
and almost none of it is presented from the logician’s perspective. So, aside
from the references I have given, I will exclude it from this survey. However,
it seems that the techniques we will be using can also help to illuminate prob-
lems having to do with probability; this is illustrated by papers such as
D. Lewis [1981] and Van Fraassen [1971a). For lack of space, these are not
discussed in the present essay.
