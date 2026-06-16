I.2: BASIC TENSE LOGIC 125

forming, perhaps, the backdrop for other occurrences. These two ways of
looking at death (a popular, if morbid, example) are illustrated by:

When Queen Anne died, the Whigs brought in George.
While Queen Anne was dying, the Jacobites hatched treasonable
plots.

Another feature of linguistic interest is the peculiar nature of accomplishment
verbs, illustrated by:

(1) The Amalgated Conglomerate Building was built during the
period March-August, 1972.

(1" The ACB was built during the period April-July, 1972.

2) The ACB was being built (i.e. was under construction) during the
period March-August, 1972.

2" The ACB was under construction during the period April-July,
1972.

Note that (1) and (1") are inconsistent, whereas (2) implies (2')!

In part, the switch is motivated by a philosophical belief that periods are
somehow more basic than instants. This motivation would be more convinc-
ing were ‘periods’ not assumed (as they are in too many recent works) to have
sharply-defined (i.e. instantaneous) beginnings and ends. It may also be
remarked that at the level of experience some occurrences do appear to be
instantaneous (i.e. we don’t discern stages in them). Thus ‘bubbles when they
burst’ seem to do so ‘all at once and nothing first’. While at the level of reality,
some occurrences of the sort studied in quantum physics may well take place
instantaneously, just as some elementary particles may well be pointlike.
Thus the philosophical belief that every occurrence takes some time (period)
to occur is not obviously true on any level.

Now for the mechanics of the switch: For any frame (X, R) we consider
the set /(X, R) of nonempty bounded open intervals of form {z :xRz A zRy}.
Among the many relations on this set that could be defined in terms of R we
single out two:

Inclusion: aSb iff Vx(x€a->x€D),
Order: a<|b iff VxVy(xE€any€b->xRy).

To any class ¥ of frames we associate the class ¥~ of those structures of
form (I(X, R), €,<1) with (X, R) € %, and the class ¥ " of those structures
(Y, S, T) that are isomorphic to elements of ¥

A first problem in switching from instants to periods as the basis for the

---

126 JOHN P. BURGESS

logic of time is to find each important class % of frames a set of postulates
whose models will be precisely the structures in #*. For the case of dense
total orders without extrema, and for some other cases, suitable postulate
sets are known, though none is very elegant. Of course this first problem is
not yet a problem of tense logic; it belongs rather to applied first- and second-
order logic.

To develop a period-based tense logic we define a valuation in a structure
(Y, S, T) - where S, T are binary relations on Y - to be a function V assign-
ing each p; a subset of Y. Then from among all possible connectives that
could be defined in terms of S and T, we single out the following:

V(-a) = Y— V(o)

V(anB) = Via) N V(B)

V(Va) = {a:Vb(bSa ~ b € V(a))}

V(Aa) = {a:Vb(aSb b € V(a))}
"V(Fa) = {a:3b@Tb A b E V(a))}

V(Pa) = {a:3b(bTa A b € V(a))}.

The main fechnical problem now is, given a class L of structures (Y, S, T)
- for instance, one of form L = % " for some class % of frames - to find a
sound and complete axiomatization for the tense logic of L based on the
above connectives. Some results along these lines have been obtained, but
none as definitive as those of instant-based tense logic reported in Section 2.
Indeed, the choice of relations (S and <), and of admissible classes L (should
we only consider classes of form % *?), and of conncectives (-, A, A, V, F, P),
and of admissible valuations (should we impose restrictions, such as requiring
b € V(p;) whenever a € V(p;) and b € a?) are all matters of controversy.

The main problem of interpretation — one to which advocates of period-
based tense logic have perhaps not devoted sufficient attention — is how to
make intuitive sense of the notion a € V(p) of a sentence p being true with
respect to a time-period a. One proposal is to take this as meaning that p is
true throughout a. Now given a valuation W in a frame (X, R), we can define
a valuation /(W) in I(X, R) by I(W)(p;) = {a:a € W(p;)}. When and only
when V has the form (W) is ‘p is true throughout @’ a tenable reading of
a € V(p). It is not, however, easy to characterize intrinsically those ¥ that
admit a representation in the form V' =I(W). Note that even in this case,
a € V(—p) does not express ‘(—p) is true throughout &’ (but rather ‘~(p is
true throughout a)’). Nor does a € V(p vq) express (p vq) is true through-
outa’.

Another proposal, originating in Burgess [1982] is to read a € V(p) as

---

II.2: BASIC TENSE LOGIC 127

‘+ isalmost always true during a’. This reading is tenable when V has the form
J(W) for some valuation W in (X, R), where J(W)(p;) is by definition {a:a —
W(p;) is nowhere dense in the order topology on (X, R)}. In this case, ‘(—p) is
almost always true during @’ is expressible by @ € V(V-p), and ‘(p vq) is
almost always true during a’ by a € V(V-V~(p vq)). But the whole problem
of interpretation for period-based tense logic deserves more careful thought.

There have been several proposals to redo tense logic on the basis of 3- or
4- of multi-valued truth-functional logic. It is tempting, for instance, to intro-
duce a truth-value ‘unstatable’ to apply to, say, ‘Bertrand Russell is smiling’ in
1789. In connection with the switch from instants to periods, some have pro-
posed introducing new truth-valués ‘changing from true to false’ and ‘chang-
ing from false to true’ to apply to, say, ‘the rocket is at rest’ at take-off and
landing times. Such proposals, along with proposals to combine, say, tense
logic and intuitionistic logic, lie beyond the scope of this survey.

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

2.INTRODUCTION TO HISTORICAL NECESSITY

Modern modal logic began with necessity (or with things definable with
respect to necessity), and the earliest literature, like C. I. Lewis [1918], con-
fuses this with validity. Even in later work that is formally scrupulous about
distinguishing these things, it is sometimes difficult to tell what concepts are
really metalinguistic. Carnap, for instance, on p. 10 of Carnap [1956], begins
his account of necessity by directing our attention to L-truth; a sentence of
a semantical system (or language) is L-true when its truth follows from the
semantical rules of the language, without auxiliary assumptions. This, of
course, is a metalinguistic notion. But later, when he introduces necessity into
the object language (Carnap [1956], p. 174), he stipulates that Oy is true if
and only if ¢ is L-true.

Carnap thinks of the languages with which he is working as fully determin-
ate; in particular, their semantical rules are fixed. This has the consequence
that whatever is L-true in a language is eternally L-true in that language. (See
Schilpp [1963], p. 921, for one passage in which Carnap is explicit on the
point: he says “analytic sentences cannot change their truth-value”.) Combin-
ing this consequence with Carnap’s explication of necessity, we see that?

) op~>HGoy

will be valid in languages containing both necessity and tense operators:
necessary truths will be eternally true. The combination of necessity with
tense would then be trivialized.

But there are difficulties with Carnap’s picture of necessity; indeed, it
seems to be drastically misconceived.®> For one thing, many things appear to
be necessary, even though the sentences that express them can’t be derived
from semantical rules. In Kripke [1972], for instance, published 26 years after
Meaning and Necessity, Saul Kripke argues that it is necessary that Hesperus
is Phosphorous, though ‘Hesperus’ and ‘Phosphorous’ are by no means

---

I.3: COMBINATIONS OF TENSE AND MODALITY 137

synonymous. Also at work in Kripke’s conception of necessity, and that of
many other contemporaries, is the distinction between ¢ expressing a necess-
ary truth, and ¢ necessarily expressing a truth. In a well-known defense of the
analytic-synthetic distinction, Grice and Strawson [1956] write as follows:

Any form of words at one time held to express something true may, no doubt, at
another time come to be held to express something false. But it is not only philosophers
who would distinguish between the case where this happens as the result of a change of
opinion solely as to matters of fact, and the case where this happens at least partly as a
result of a shift in the sense of the words (p. 157).

This distinction, at least in theory, makes it possible that a sentence ¢ should
necessarily (perhaps, because of semantical rules) express a truth, even though
the truth that it expresses is contingent. This idea is developed most clearly in
Kaplan [1978].

On this view of necessity, it attaches not primarily to sentences, but to
propositions. A sentence will express a proposition, which may or may not
be necessary. This can be explicated using possible worlds: propositions take
on truth values in these worlds, and a proposition is necessary if and only if it
is true in all possible worlds.*

This conception can be made temporal without trivializing the results.
Probably the simplest way of managing this is to begin with nonempty sets T
of times and W of worlds;® T is linearly ordered by a relation <. I will call this
the T x W approach.

Recall that a tensed formula, say Fy, is true at {w, ¢), where w € W and
t €T, if and only if p is true at (w, "), for some ¢' such that t <¢'.6 We now
want to ask under what conditions Oy is true at {w, £). (In putting it this way
we are suppressing propositions; this is legitimate, as long as we treat propo-
sitional attitudes as unanalyzed, and assume that sentences express the same
proposition everywhere.)

If we appeal to intuitions about languages like English, it seems that we
should treat formulas like Oy as nontrivially tensed. This is shown most
clearly by sentences involving the adjective ‘possible’, such as ‘In 1932 it was
possible for Great Britain to avoid war with Germany; but in 1937 it was
impossible’. This suggests that when Oy is evaluated at (w, t) we are consider-
ing what is then necessary ; what is true in all worlds at that particular time, ¢.

The rule then is that Oy is true at (w, ¢) if and only if ¢ is true at (w’, ¢) for
all w' € W. If we like, we can make this relational. Let {~,:¢ € T} be a family
of equivalence relations on W, and let O be true at (¢, w) if and only if p is
true at (¢, w') for allw' € W such that waw'.

---

138 RICHMOND H. THOMASON

The resulting theory generates some validities arising from the assumption
that the worlds share a common temporal ordering. Formulas (2) and (3) are
two such validities, corresponding to the principle that one world has a first
moment if and only if all worlds do.

(2) Plpv—yp] <= 0P[pvy]
(3)  Hlpa—p] <= aH[pA~y]

In case ~; is the universal relation for every ¢ (or the relations =, are simply
omitted from the satisfaction conditions) there are other validities, such as
(4) and (5).

) Poy—>oPy
) Foyp—->oFy

As far as I know, the general problem of axiomatizing these logics has not
been solved. But I'm not sure that it is worth doing, except as an exercise.
The completeness proofs should not be difficult, using Gabbay’s techniques
(described in Section 4, below). And these logics do not seem particularly
interesting from a philosophical point of view.

But a more interesting case is near to hand. The tendency we have noted
to bring Carnap’s metalinguistic notion of necessity down to earth has made
room for the reintroduction of one of the most important notions of necess-
ity: practical necessity, or historical necessity.” This is the sort of necessity
that figures in Aristotle’s discussion of the Sea Battle (De Int. 18°25-19°4),
and that arises when free will is debated. It also seems to be an important
background notion in practical reasoning. Jonathan Edwards, in his usual
lucid way, gives a very clear statement of the matter.

Philosophical necessity is really nothing else than the full and fixed connection between
the things signified by the subject and predicate of a proposition, which affirms some-
thing to be true. ... [This connection] may be fixed and made certain, because the exis-
tence of that thing is already come to pass; and either now is, or has been; and so has as
it were made sure of existence. And therefore, the proposition which affirms present and
past existence of it, may be this means be made certain, and necessarily and unalterably
true; the past event has fixed and decided that matter, as to its existence; and has made it
impossible but that existence should be truly predicted of it. Thus the existence of what-
ever is already come to pass, is now become necessary; ‘tis become impossible it should
be otherwise than true, that such a thing has been (Edwards [1754], pp. 152-3).

Historical necessity can be fitted into the T x W framework; it is merely a
matter of adjusting the relations =, so that if wa~,w', then w and w' share the
same past up to and including ¢. So for ¢' <t, atomic formulas must be

---

I.3: COMBINATIONS OF TENSE AND MODALITY 139

treated the same way in w and w'. Furthermore, we have to stipulate that
historical possibilities diminish monotonically with the passage of time: if
t<t', then {w':w~yw'} C {w':w~,w'}. This interaction between time and
relative necessity creates distinctive validities, such as (6) and (7).

(6) ¢ <> Oy, if ¢ contains no occurrences of F
@) Poyp~> 0Py

Formula (8), on the other hand, is clearly invalid.
(8) oPp -~ Pap

These correspond to rather natural intuitions relating the flow of time to the
loss of possibilities.

There is another way of representing historical necessity, which perhaps
will seem less straightforward to logicians steeped in possible worlds. Time
can be treated as nonlinear (branching only towards the future), and worlds
represented as branches on the resulting ordered structure. This corresponds
very closely to the T x W account: (6) and (7) remain valid, and (8) invalid.
But the validities are not the same. This matter will be taken up below, in
Section 4.

So much for necessity; I will deal more briefly with ‘ought’ and con-
ditionals.

As Aristotle points out, we don’t deliberate about just anything; in par-
ticular, we deliberate only about what is in our power to determine.
[NE 1112219f.] But the past, and the instantaneous present, are not in our
power: deliberation is confined to future alternatives.

This suggests that deontic logic, insofar as it investigates practical oughts,
should identify its possibilities with the ones of historical necessity. Unfor-
tunately, this conception played little or no role in the early interpretation
of deontic logic; those who developed the deontic applications of possible
worlds semantics seemed to think of deontic possibilities ahistorically, as
“perfect worlds” in which all norms are fulfilled.® Historical possibilities, on
the other hand, are typically imperfect; life is full of occasions on which we
have to make the best of a bad situation. In my opinion, this is one reason
why deontic logic has seemed to most philosophers to consist largely of a
sterile assortment of paradoxes, and why its influence on moral philosophy
has been so fruitless.

Conditionals have been intensively studied by philosophical logicians over
the last fifteen years, and this has created an extensive literature. Relatively
little of this effort has been devoted to the interaction of conditionals with

---

140 RICHMOND H. THOMASON

tense. But there is reason to think that important insights may be lost if con-
ditionals are studied ahistorically. One very common sort of conditional (the
philosopher’s novel example of a “subjunctive conditional”) is exemplified by

9).

9 If Oswald hadn’t shot Kennedy, then Kennedy would be alive
today.

These conditionals seem to be closely related to historical possibilities; they
envisage courses of events that diverge at some point in the past from the
actual one. And this in turn suggests that there may be close connections
between historical necessity and some conditionals.

Examples like the following four provide evidence of a different sort.

(10)  He would go if she would go.

(11)  He will go if she will go.

(12)  He would have gone if she were to have gone.
(13)  He went if she went.

Sentences (10) and (11) seem hardly to differ in meaning, if (10) has to do
with the future. On the other hand, (12) and (13) are very different. If he
didn’t go, but would have gone if she had, (12) is true and (13) false.

This suggests that there may be systematic connections between tense,
mood, and the truth conditions of conditionals. According to one extreme
proposal, the difference in “mood” between (9) and the past-present con-
ditionals form ‘If Oswald didn’t shoot Kennedy, then Kennedy is alive today’
can be accounted for solely in terms of the interaction of tense operators and
the conditional.® This has in favor of it the grammatical fact that ‘would’ is
the past tense of ‘will’. But the matter is complex, and it is difficult to see
how much merit there is in the suggestion.

There have been Tecent signs of interest in the interaction of tense and
conditionals; the most systematic of these is Thomason and Gupta [1981]. If
this study is any indication, the topic is surprisingly complicated. But the
complications may prove to be of philosophical interest.

The relation between historical necessity and quantum mechanics is a
topic that I will not discuss at any great length. The indeterminacy that is
associated with microphenomena seems at first glance to invite a treatment
using alternative futures; and one of the approaches to the measurement

problem in quantum theory, the “many-worldsinterpretation”, does appear to
do just this. (See DeWitt and Graham [1973] for more information about the

approach.)

---

I1.3: COMBINATIONS OF TENSE AND MODALITY 141

But alternative futures don’t provide in themselves an adequate represen-
tation of the physical situation, because the quantum mechanical probabil-
ities can’t be treated as distributions over a set of fully determinate
worlds.® Some further apparatus would have to be introduced to secure the
right sytem of nonboolean probabilities, and as far as I can see, what is
required would have to go beyond the resources of possible worlds semantics:
there is no escaping an analysis of measurement interactions, or of inter-
actions in general.

Possible worlds semantics may help to make the “many worlds” approach
to quantum indeterminacy seem less frothy; the prose of philosophical
modal realists, such as D. Lewis [1970], is much more judicious than that in
which the physicists sometimes indulge. (See, for instance, DeWitt [1973],
p. 161.) So, modal logic may be of some help in sorting out the philosophical
issues; but this leaves the fundamental problems untouched. Possible worlds
are not in themselves a key to the problem of measurement in quantum
mechanics.

The following sections will aim at fleshing out this general introduction
with further historical information, more detailed descriptions of the relevant
logical theories, and more extensive references to the literature.

3. HISTORICAL NECESSITY

The first sustained discussion of this topic, from the standpoint of modern
tense logic is (as far as [ know) Chapter 7 of Prior [1967], entitled ‘Time and
determinism’.! Prior’s judgment and philosophical depth, as well as his read-
able style, make this required reading for anyone seriously interested in his-
torical necessity.

Prior’s exposition is informal, and sprinkled with historical references to
the philosophical debate over determinism. In this debate he unearths a
logical determinist argument, that probably goes back to ancient times.
According to this argument, if ¢ is true then, at any previous time, F must
have been true. But choose such a time, and suppose that at this earlier time ¢
could have failed to come about; then Fy could not have been true at this
time. It seems to follow that the determinist principle

(14) y¢—>HoFy
holds good.

In discussing the argument and some ways of escaping from it, Prior is
fairly flexible about this object language; in particular, he allows metric tense

---

142 RICHMOND H. THOMASON

operators. Since these complicate matters from a semantic point of view, I
will ignore them, and consider languages whose only modal operators are 0O
and the nonmetric tenses.

Also (and this is more unfortunate), Prior [1967] speaks loosely in
describing models. At the place where his indeterminist models are intro-
duced, for instance, he writes as follows.

... we may define an Ockhamist model as a line without beginning or end which may
break up into branches as it moves from left to right (i.e. from past to future), though
not the other way . . . (p. 126)

From this description it is clear that Prior is representing historical necessity
by means of nonlinear time, rather than according to the T'x W format des-
cribed in Section 2, above. But it is a little difficult to tell exactly what
mathematical structures have been characterized; probably, Prior had in mind
trees whose branches all have the order type of the (negative and nonnegative)
integers.

To bring this into accord with the usual treatment of linear nonmetric
tense logic, we will liberalize Prior’s account.

DEFINITION 1: A treelike frame U for tense logic is a pair (T, <), where T
is a nonempty set and < is a transitive ordering on T such that if #; <t and
ty <t theneithertl =t,0rt, <t2 0rt2<t1.

As in ordinary tense logic, we imagine an assignment of truth values to
atomic formulas at each ¢t € T, and truth-functional connectives are treated in
the usual way. But things become perplexing when you try to interpret future
tense in these structures. Take a very simple branching case, with just three
moments, and imagine that p is true at ¢y and ¢,, and false at ¢, .

.tl

to o—
o,
Is Fp true at t? It is hard to say.

Moreover, as you reflect on the problem, it becomes clear that Prior’s
juxtaposition of this technical problem with bits from figures like Diodorous
Cronus, Peter de Rivo, and Jonathan Edwards is not merely an antiquarian
quirk. There is a genuine connection. These treelike frames represent ways in
which things can evolve indeterministically. A definition of satisfaction for a
language with tense operators that is suited to such structures would auto-
matically provide a way of making tense compatible with indeterministic

---

I1.3: COMBINATIONS OF TENSE AND MODALITY 143

cases. And it is just this that the logical argument for determinism claims
can’t be done. The technical problem can’t be solved without getting to the
bottom of this argument.

If the argument is correct, any definition of satisfaction for these struc-
tures will be incorrect — will generate validities that are at variance with the
intended interpretation. Lukasiewicz’s [1967] earlier three-valued solution is
like this, I believe. Not because it makes some formulas neither true nor false,
but because the formulas it endoreses as valid are so far off the mark. It is
bad enough that Fp v—Fp is invalid, but also the approach would make
[[OFp A O—=Fp] A [OFg A O—Fq]] > [Fp <= Fq] valid, if ¢ is true if and
only if ¢ takes the intermediate truth value.'?

Nor does the logic that Prior calls “Peircian” strike me as more satisfactory,
from a philosophical standpoint, though it does lead to some interesting tech-
nical problems relating to axiomatizability. Here, Fyp is treated as true at ¢ in
case the moments at which ¢ is true bar the future paths through ¢;i.e., every
branch through ¢ contains a moment subsequent to ¢ at which y is true. On
the Peircian approach, Fp v—Fyp is valid, but Fp vF—p is not; nor is
p - PFp.™ As Prior says, sense can be made of this by reading F as ‘will
inevitably’. Though this helps us to see what is going on, it is not the intended
interpretation.

The most promising of Prior’s suggestions for dealing with indeterminist
future tense is the one he calls “‘Ockhamist™. The theory will be easier to pre-
sent if we first work out the satisfaction conditions for Oy in treelike frames.
Intuitively, Oy is true at ¢ if ¢ is true at f no matter what the future is like.
And a way the future can be like will be represented by a fully determinate -
i.e. linear — path beyond ¢. Since the frames are treelike, these correspond to
the branches, or maximal chains, through ¢.

DEFINITION 2: Where (T, <) is a treelike model structure and t €T, a
branch through # is a maximal linearly ordered subset of T containing ¢; By is
the set of branches containing ¢.

To make sense of ¢ being true at ¢ no matter what the future is like, we
will have to think of formulas being satisfied not just at moments ¢, but at
pairs {t,b), where b € B,. Prior explains it this way. On the Ockhamist
approach formulas like Fp are given ‘prima facie assignments’ at ¢; such an
assignment is made by choosing a particular b in B,. His idea seems to be that
there is something more provisional about the selection of » than about that
of t; but this he does not articulate or defend very fully. In the technical

---

144 RICHMOND H. THOMASON

formulation of the theory there is no asymmetry between moments and
branches; it is just that two parameters need to be fixed in evaluating for-
mulas.

Once satisfaction is made relative to pairs (¢, b) for some formulas, it
must be relativized in the same way for all formulas; otherwise the recursive
definition of satisfaction will become snarled. So, except for future tense, the
definition will go like this.

DEFINITION 3: A function /4 assigning each atomic formula a subset of T is
called an (Ockhamist) assignment, as in Chapter 11.2 of this Handbook.

DEFINITION 4: The A-truth value IIgoIIZ't,b) of ¢ at the pair (¢, b) is defined as
follows. We assume here that ”‘P“(’;,b) = 0iff II(pIIf't,b) # 1.

gl »y = 1 iff tEh(p), ifpisatomic,

=@l ey = 1 iff  lloliftp = 0,

loa il py = 1 iff llgllfipy = 1 and WIIGs = 1,
lovll oy = 1 iff loley =1 or IWlfe = 1,
o> Wil py = 1 iff Nl = 0 or WG, = 1,
WPl yy = 1 iff forsomer <z, lolft,s = 1.
ol = 1 iff forallt’ €B,, ol sy = 1.

This definition renders p - op valid, though not every substitution instance
of it is valid. This can be easily changed by letting assignments take atomic
formulas into subsets of {(¢,b): t € T and b € B,}; Prior [1967], pp. 123-124,
discusses the matter.

At this point, the way to handle Fy is forced on us. We use the branch that
is provided by the index.

| Folllk »y =1 iff for some ¢' € b such that t <t llgllfy 5y = 1
(t, (t,b)

The Ockhamist logic is conservative; it’s easy to show that if ¢ contains no
occurrences of O then g is valid for treelike frames if and only if ¢ is valid in
ordinary tense logic. So indeterminist frames can be accommodated without
sacrificing any orthodox validities. This is good for those who (like me) are
not determinists, but feel that these validities are intuitively plausible. Finally,
the Ockhamist solution thwarts the logical argument for determinism by
denying that if ¢ is true at ¢ (i.e. at (b, t), for some selected b in B;) then Oy
is.

This way out of the argument bears down on its weakest joint; but the

---

IL3: COMBINATIONS OF TENSE AND MODALITY 145

argument is so powerful that even this link resists the pressure; it is hard for
an indeterminist to deny that Oy must be true if ¢ is. To a thoroughgoing
indeterminist, the choice of a branch b through ¢ has to be entirely prima
facie; there is no special branch that deserves to be called the “actual” future
through ¢.}* Consider two different branches, b, and b,, through ¢, with
t<t, €b, and t <t, €b,. From the standpoint of ¢,, b, is actual (at least,
up to t;). From the standpoint of ¢,, b, is actual (at least, up to #;). And
neither standpoint is correct in any absolute sense. In exactly the same way,
no particular moment of linear time is “present”.

But then it seems that the Ockhamist theory gives no account of truth
relative to a moment ¢, and it also suggests very strongly that if ¢ is true at ¢
then Oy is also true at . The only way that a thing can be true at a moment
is for it to be settled at that moment.

In Thomason [1970], it is suggested that such an absolute notion of truth
can be introduced by superposing Van Fraassen’s treatment of truth-value
gaps onto Prior’s Ockhamist theory.!s The resulting definition is very simple.

DEFINITION 5
ol = 1 iff llglifspy = 1 forallb €B,,
ol = 0 iff gty = 0 forallb€EB,.

This logic preserves the validities of linear tense logic; indeed, ¢ is Ockhamist
valid if and only if it is valid here. Also, the rule holds good that if [|gll? = 1
then ||logll? = 1.

Thus, this theory endorses the principle (rejected by the Ockhamist
theory) that if a thing is true at ¢ then its truth at ¢ is settled. It may seem at
first that it validates all the principles needed for the logical determinist argu-
ment, but of course (since the logic allows branching frames) it must sever the
argument somewhere. The way in which this is done is subtle. The scheme
¢ = HFp is valid, but this does not mean that if ¢ is true at # then F is true
at any ' < t. That is, it is not the case that if ||gl|? = 1 then || Fl|% = 1 for all
t' < t. The validity of this scheme only means that for all b € B,, if ngllf’t,b) =1
then || Fgllfy 5y =1 for all #'<t. But there may be b' € B, which are not
in Bt-

To put it another way, the fact that Fy is true at ¢ from the perspective of
a later t' does not make Fyp absolutely true at t, and so need not imply that
OFyp is true at ¢.

This maneuver makes use of the availability of truth-value gaps. To make
this clearer, take a future-oriented version of the logical determinist argument:

---

146 RICHMOND H. THOMASON

FpvF-y is true at any ¢; so F is true at £ or = Fy is true at ¢; so OFyp is true
at t or o~ Fy is true at t. The supervaluational theory blocks the second step
of this argument: in any such theory, the truth of Y v~y does not imply
that  is true or —y is true.

Thomason suggests that this logic represents the position endorsed by
Aristotle in De Int. 18°25-194, but his suggestion is made without any
analysis of the very controversial text, or discussion of the exegetical litera-
ture. For a close examination of the texts, with illuminating philosophical dis-
cussion, see Frede [1970]; also see Sorabji [1980]. For a broadly-based exam-
ination of Aristotle’s views that nicely illustrates the value of treelike frames
as an interpretive device, see Code [1976]. The suggestion is also made in
Jeffrey [1979]. For information about the medieval debate on this topic,
see Normore [1982].

4. THE TECHNICAL SIDE OF HISTORICAL NECESSITY

The mathematical dimension of the picture painted in the above section is
still relatively undeveloped. At present, most of the results known to me deal
with axiomatizability in the propositional case.

We have already characterized one important variety of propositional
validity: ¢ is Ockhamist valid if it is satisfied at all pairs {z, b), relative to all
Ockhamist assignments on all treelike frames. (See Definitions 2-4, above.)
The time has come to give an official defintion of T x W validity.

DEFINITION 6: A T x W frame is a quadruple (W, T, <, =), where Wand T
are nonempty sets, < is a transitive relation on T which is also irreflexive and
linear (i.e. t < ¢ for all t €T, and either t <t or ' <t or t =¢ for all, ¢,
' €T), and ~ is a 3-place relation on T x W x W, such that (1) for all £, ~, is
an equivalence relation (i.e. w~,w for all t €T and w € W, etc.), and (2) for
all wy, w, €W and t, t' €T, if wy~w, and ' <t then w,;~,w,. The inten-
tion is that w~,w' if w and w' are historical alternatives through ¢, and so
differ only in what is future to .

DEFINITION 7: A function & assigning each atomic formula a subset of
T x W is an assignment, provided that if w~,w' and ¢, < t then (¢;, w) E h(yp)
iff (¢, w') € h(p).

DEFINITION 8: The A-truth value anllf't,w) of ¢ at the pair (¢, w) is defined
by a recursion that treats truth-functional connectives in the usual way. The
clauses for tense and necessity run as follows.

---

I1.3: COMBINATIONS OF TENSE AND MODALITY 147

Pl wy = 1 iff forsome? <t, llglifuy = 1,
||F¢||Z;f,w) 1 iff for some t' such that ¢ <t', ”R"”?ﬂ,w) =1,
D@l wy = 1 iff for all w' such that waw',  llgllf oy = 1.

A formula is T x W valid if it is satisfied at every pair (¢, w) by every
assignment on every T x W frame.

There are some validities that are peculiar to these T x W frames, and that
arise from the fact that only a single temporal ordering is involved in these
frames: (15) and (16) are examples,

(15)  FG[pArp] »0FG[parp]
(16)  GF[pv~p] »>oGF[pv—p]

Example (15) is valid because its antecedent is true at (¢, w) if an only if there
is a ¢’ that is <-maximal with respect to w; but this holds if and only if there
is a ¢' that is <-maximal absolutely. Example (16) is similar, except that this
time what is at stake is the nonexistence of a maximal time.

Burgess remarked (in correspondence) that T x W validity is recursively
axiomatizable, since it is essentially first-order. But as far as I know the prob-
lem of finding a reasonable axiomatization for T x W validity is open. I would
expect the techniques discussed below, in connection with Kamp validity, to
yield such an axiomatization.

Although (15) and (16) may be reasonable given certain physical assump-
tions, they do not seem so plausible from a logical perspective. After all, if
w=,w', all that is required is that w and w’ should share a certain segment of
the past, and this implies that the structure of time should be the same in w
and w' on this segment. But it is not so clear that w and w' should participate
in the same temporal structure after ¢. Thus suggests a more liberal sort of
T x W frame, first characterized by Kamp [1979].""

DEFINITION 9: A Kamp frame is a triple (.97, W, =), where W is a non-
empty set, .7 is a function from W to transitive, irreflexive linear orderings
(i.e. if we W then .7~ (w) = (T, <), where <, is an ordering on T, asin
T x W frames), and ~ is a relation on {(z, w,w'):w, w' EWand t €.7 (W) N
7 (w")} such that for all ¢, &, is an equivalence relation, and if w=~,w' then
{t,:t, €T, and t,<,t}={t;:t; €T, and t,<,t}. Also, if w~,w' and
t'<,,t thenwyw'.

The definitions of an assignment, and of the A-truth value ||tpl|(ht,w) of p at

the pair (¢, w) (where t € .57, and h is an assignment) are readily adapted
from Definitions 7 and 8.

---

148 RICHMOND H. THOMASON

Besides (AKO) all classical tautologies, Kamp takes as axioms all instances
of the following schemes.'®

(AK1) H[p~>y]~> [Pp~>PY]
(AK2) Glp~>y]~>[Fp~Fy]
(AK3) PPyp— Py

(AK4) FFp~Fyp

(AKS) PGp-—y¢

(AK6) FHp-¢

(AK7) PFp~[PovyvFy]
(AK8) FPp—[PpvyvFy]
(AK9) oly-y¢]- [op~oy]
(AK10) op—¢

(AK11) Op-> 00y

(AK12) OPyp-> POy

(AK13) opvory, if ¢ is atomic

As well as (RKO) modus ponens, Kamp posits the rules given by the
following three schemes.

(RK1) ¢/Hp
(RK2) ¢/Gy
(RK3) /oy

Readers familiar with axioms for modal and tense logic will see that this
list falls into three natural parts. Classical tautologies, modus ponens, (RK1),
(RK?2) and (AK1)-(AKS) are familiar principles of ordinary tense logic with-
out modality. Classical tautologies, modus ponens, (RK3), and (AK9)—-(AK11)
are principles of the modal logic S5. Axiom (AK12) is a principle combining
tense and modality; this principle was explained informally in Section 2. The
validity of (AK13) reflects the treatment of atomic formulas as noncontin-
gent; see the provision in Definition 7. If tense operators were not present,
(AK13) would of course trivialize O, rendering every formula noncontingent.

To establish the incompleteness of (AK0)-(AK13) + (RK0)-(RK3), con-
sider the formula (17), discovered by Kamp, where E(y) is Fo A G[¢ vPy).

(17)  [PE\(p) A OPE\(q)] = [P[E\(p) A POE(q)] v
VP[OE(q) A OE(P)] vP[E () AOE(q)]].

The validity of (17) in Kamp frames follows from the fact that these
frames are closed under the sort of diagram completion in given in Figure 1.
Given ty, t,, I3, t1, t3 and the relations of the diagram, it must be possible to

---

IL.3: COMBINATIONS OF TENSE AND MODALITY 149

w w'

~ ’

t, t
v v
P~ »

tz 3 > 15
v

~ ’

s t

Fig. 1. Interpolation.

interpolate at ¢ in w' alternative to #,, with 3 <#, <t."” Formula (17) is
complicated, but I think I can safely leave the task to checking its Kamp
validity to the reader.

One proof that (17) is independent of (AK0)-(AK13) + (RK0)-(RK3)
makes use of still another sort of frame, which is closer to a Henkin construc-
tion than the T x W frames. If our task is to build models out of maximal
consistent sets of formulas, the ‘times’ of a T x W frame are rather artificial;
they would have to be equivalence sets of maximal consistent sets. In neutral
frames, the basic elements are moments, or instantaneous slices of evolving
worlds, which are organized by intra-world temporal relations, and interworld
alternativeness relations. Neutral frames tend to proliferate, because of the
many conditions that can be imposed on the relations; hence my use of sub-
scripts in describing them.

DEFINITION 10: A neutral frame, is a triple (W, %, =), where (1) W is a
nonempty set, (2) Z is a function whose arguments are members w of W and
whose values are orderings (U,,, <) such that U,, is a nonempty set and <,
is a transitive?® ordering on U, such that for all @, b €U, either a<b or
b<aora=b, (3)if w,w €EWandw#w' then %, and %, are disjoint,
and (4) ~ is an equivalence relation on U{U,,:w € W}, and (5) if a~a' and
b<,a then there is some b' € %, (where a' € Z,;) such that b~b' and
b'<,a'.

Here, each U, corresponds to the set of instantaneous slices of the world
w; =~ is the alternativeness relation between these slices.

The diagram-completion property expressed in (5) looks as shown in
this picture. It’s important to realize that nothing preventsa # b while at the
same time a' = b’ in Figure 2. Of course, in this case we will also havea ~ b,
which would be something like history repeating itself, at least in all respects
that are settled by the past.

---

150 RICHMOND H. THOMASON

w w
a ad ¢ o
\ v
b & __ N b’

Fig. 2. One-way completion.

Everything generated by (AK0)—(AK13) + (RK0)-(RK3) is valid in neutral
frames;. (And in fact the converse holds, so that we have a completeness
result; see Thomason [1981c].) But it is easy to show that (17) is invalid in
neutral frames;.

This proeess can be continued; for instance, stronger conditions of diagram
completion can be imposed on neutral frames, which extend the propo-
sitional validities, and completeness conditions obtained for the resulting
sorts of frames. Details can be found in Thomason [1981c]; but this effort
did not produce an axiomatization of Kamp validity.

Using his method of constructing irreflexive models (see Gabbay [1981]),
Gabbay has shown that all the Kamp validities will be obtained if (AG1) and
(RG1) are added to (AK0)-(AK13) + (RK0)—-(RK3). Some terminology is
needed to formulate (RG1); we need a way of talking, to put it intuitively,
about formulas which record a finite number of steps forwards, backwards,
and sideways in Kamp frames.

DEFINITION 11: Let o; €{P, F, O} for 1 <i<n,n > 0. Thenf(p) = ¢, and

fa, ..... an(‘poy <o ¥Pn-1, ‘Pn)
= oAy [\01 A -Aan—l[‘pn-l '\an‘pn] e ]

SO’ for iHStanceyfF,O,P(p01plsp27p3) isPo AF[pl A 0[p2 Al)p3]] .
The axiom and rule are as follows:

(AG1) [o-pAHopaoy]-=>GoH[[~pAHy] > ]
Joyrsan(0s - - - 0n-1, [on A—D AHD]) > ¢
fa,,...,an(‘POa <9 ¥Pn-1, ‘pn) g ‘l/

In RG2, p must be foreign to Y and gy, . . . , y,.
I leave it to the reader to verify that the axiom and rules are Kamp valid.
It looks as if the ordering properties of linear frames that can be axiomatized

(RG2)

---

IL3: COMBINATIONS OF TENSE AND MODALITY 151

in ordinary tense logic (endlessness towards the past, endlessness towards the
future, density, etc.)?! can be axiomatized against the background of Kamp
frames, using Gabbay’s techniques. But even so, there are still many simple
questions that need to be settled;to take just two examples, it would be nice
to know whether Kamp satisfaction is compact, and whether (RG2) is inde-
pendent.

The situation with respect to treelike frames (i.e. with respect to Ockham-
ist validity) was even less well explored until recently. To begin with, a num-
ber of people have noticed that, although every propositional formula that
is Kamp valid is Ockhamist valid,”? the converse fails. Nishimura [1979b]
points this out, giving (18) as a counterexample.?

(18)  GHuFP[H—p A —p A Gp] = FPOFP[-p A 0Gp]
In 1977, Burgess discovered (19), the simplest counterexample known to me.
(19)  aGOFp - OGFp.

And in 1978, Thomason independently constructed the following counter-
example.

(20)  [pAoGH[p~ Fp]] > GFp

Both examples trade on the fact that any linearly-ordered subset of a tree
can be extended to a branch (a consequence of the Axiom of Choice). If the
antecedent of (20) is true at (¢, b) in a frame (T, <) then there is a linear set
X of moments such that p is true at every member of X, and such that there
is no upper bound to 7 to X. This set X can be extended to a branch »*, and
GFp will be true at (¢, b*).

But the situation shown in Figure 3 can arise in Kamp models, allowing
(19) to be falsified. If we make a Kamp model out of {b;:i € w}, omitting
b, (19) is false at (zy, bo).

Nishimura [1979a, b] seems to feel that these examples show treelike
frames to be inadquate. But the technical results only establish a difference
between the treelike and the T x W approaches. Adequacy has to do with
intuitions about what should be valid. Intuitions may differ, but to me the
natural notion is that of a possible future — not that of a possible course of
events. Thus, (20) strikes me as clearly valid. The metric examples discussed
in Nishimura [1979a] affect me similarly. The person who holds both (21)
and (22) seems to me to have contradicted himself.

(21) Inevitably, life on earth will come to an end at some date in the
future.

---

152 RICHMOND H. THOMASON

Fig. 3.

(22)  For every date in the future, it is not inevitable that life on earth
will have come to an end by that date.

For this reason, it seems to me that the T x W frames do not have the philo-
sophical interest of the treelike ones, though they are certainly interesting for
technical reasons. This makes Ockhamist validity appear worth investigating;
until recently, however, very little was known about it.2* In Burgess [1979],
it is claimed that Ockhamist validity is recursively axiomatizable, and a proof
is sketched. Later (in conversation), Kripke challenged the proof, and Burgess
has been unable to substantiate all the details. Very recently, Gurevich and
Shelah have proved a result implying that Ockhamist validity is decidable.
(See Gurevich and Shelah [to appear].) At present (October, 1982) their
paper is not yet written, and I have not had an opportunity to see their proof.
The main result is that the theory of trees with second-order quantification
over maximal chains is decidable.

Of course, a proof of decidability would allow axioms to be recovered for
Ockhamist validity; but this would be done in Craigian fashion. And unfor-
tunately, Gabbay’s completeness techniques do not seem (at first glance, any-
way) to extend to the treelike case. Burgess’ example [1979], p. 577, of an
Ockhamist invalid formula valid in countable treelike frames, helps to bring
home the complexity of this case.?

There are some interesting technical results regarding logics other than
the treelike and T x W ones that I have stressed here; the most important of
these is Burgess’ [1980] proof that the Peircian validities are decidable.
Burgess has pointed out to me that the method of Section 5 of Burgess
[1980] can be used to prove Kamp validity decidable, as well as T x W

---

IL3: COMBINATIONS OF TENSE AND MODALITY 153

validity with dense time. He also remarks that most interesting technical
questions about the case in which atomic formulas are treated like complex
ones (so that p - op is not valid, and substitution is an admissible rule) are
unresolved, and may prove more difficult.

S.DEONTICLOGIC COMBINED WITH HISTORICAL NECESSITY

For general discussion of deontic logic, with historical background, see
Féllesdal and Hilpinen [1971] and Chapter II.12 of this Handbook. This pre-
sentation will concentrate on combinations of deontic modalities with tem-
poral ones, and, in particular, with historical necessity.

Deontic logic seems to have suffered from a lack of communication. Even
now, papers are written in which the relevant literature is not mentioned and
the authors appear to be reinventing the wheel. In the hope that a survey of
the literature will help to correct this situation, I have tried to make the
bibliographical coverage of the present discussion thorough.

One facet of this lack of communication can be seen at work in the late
1960s. On the one hand, quite sophisticated model theoretic studies were
developed during this time, treating deontic possibilities historically, as
future alternatives. Montague [1968], pp. 116-117 and Scott [1967] repre-
sent the earliest such studies. (Unfortunately, Montague’s presentation is
tucked away in a rather forbidding technical paper that discusses many other
topics, and the publication of the paper was delayed. And Scott’s paper was
never published.) But in 1969 Chellas [1969] appeared, giving an extended
and very readable presentation of the California Theory.?® (Montague’s,
Scott’s, and Chellas’ theories are quite similar variations of the T x W
approach; the treatment of historical necessity is similar, and indeed identical
in all important respects, to Kamp’s.)

But although Chellas’ monograph contains an extensive and valuable
bibliography of deontic logic, including many references to the literature in
moral philosophy and practical reasoning, and though Chellas is evidently
familiar with this literature, there is no attempt in the work to relate the
theory to the more general philosophical issues, or even to discuss its appli-
cation to the “paradoxes” of deontic logic, which by then were well known
Chellas concentrates on the mathematical portion of the task. Thus, although
the presentation is less compressed than Montague’s it remains relatively
impenetrable to most moral philosophers, and there is no advertisement of
the genuine help that the theory can give in dealing with these puzzles.

On the other hand, in the philosophical literature it is easy to find studies

---

154 RICHMOND H. THOMASON

that would have benefited from vigorous contact with logical theories such as
Chellas’. To consider an example almost at random, take Chisholm [1974].
This paper has the word ‘logic’ in its title and deals with a topic that is
thoroughly entangled with Chellas’ investigation, but Chisholm’s paper
has no references to such logical work and seems entirely ignorant of it.
Moreover, the paper is written in an axiomatic style that makes no use of
semantical techniques that had been current in the logical literature for many
years. And Chisholm commits errors that could have been avoided by aware-
ness of these things. (D9 on p. 13 of Chisholm [1974] is an example; com-
pare this with pp. 183-184 of Thomason [1981b].)

To take another example, Wiggins [1973] provides an informal discussion,
within the context of the determinist-libertarian debate in moral philosophy,
of issues very similar to those treated by Chellas [1971] (and, so far as his-
torical necessity goes, in Chapter 7 of Prior [1967]). Again, the paper con-
tains no references to the logical literature. Though Wiggins’ firm intuitive
grasp of the issues prevents his argument from being affected,?” it would have
been nice to see him connect his account to the very relevant model theoretic
work.

There are a number of general discussions of the “paradoxes” of deontic
logic: see, for example, Aqvist [1967], pp. 364-373, Féllesdal and Hilpinen
[1971], pp. 21-26, Hannson [1971], pp. 130-133, Al-Hibri [1978], pp.
22-29, and Van Eck [1981], pp. 28-35. It should be apparent from the
shudder quotes that I prefer not to dignify these puzzles with the same term
that is applied to profoundly deep (perhaps unanswerable) questions like the
Liar Paradox. The puzzles are a disparate assortment, and require a spectrum
of solutions, some of which have little to do with tense. The Good Samaritan
problem, for instance (the problem of reparational obligations), seems from
one point of view to simply be a rediscovery of the frailties of the material
conditional as a formalization of natural language conditionals.

But part of the solution?® of this problem seems to lie in the development
of an ought kinematics,” in analogy to the probability kinematics that is the
topic of Jeffrey [1965], Chapter 11. As we would expect from probability,
where there are interactions (surprisingly complex ones) between the rules
of probability kinematics and locutions that combine conditionality and
probability, we should expect there to be close relationships between ought
kinematics and the semantics of conditional oughts. Nevertheless, we can for-
mulate the kinematics of ought without having to work with conditional
oughts in the object language.

The technical resolution of this problem is very simple, and this is precisely

---

I.3: COMBINATIONS OF TENSE AND MODALITY 155

what the California theory that I referred to above provides: e.g., the theory
of Chellas [1969]. For the sake of variety, I will formulate it with respect to
treelike frames; this is something that, to my knowledge, was first done in
Thomason [1981a].%°

DEFINITION 12: A treelike frame U for deliberative deontic tense logic is a
pair (T, <, 0), where (T, <) is a treelike frame for tense logic and O is a func-
tion on T such that for all # € T, (1) O, is nonempty, (2) O; € B;, and (3) if
t<t' and ¢ €b for some b € O,, then Oy = 0; N By

The satisfaction clause for oughts is as follows.
0@l »y = 1 iffforalld’ €0, gl yy = 1.

We are dealing with the result of extending a propositional language of the
sort we discussed in previous sections (truth-functional connectives, past and
future tense, and historical Oo) by adding a one-place connective O for
ought.3!

Something needs to be said about Condition (3) on frames, which is not
to be found in Thomason [1981a], and, as far as I know, has also been over-
looked by other authors who (like Chellas) formulate the model theory of
ought kinematics. This condition yields validities such as the following two.

(23)  OG[Fp~>-0G—y]
(24)  0Gyp-0GOy

These do strike me as valid in this context, and at any rate are interesting
tense-deontic principles having to do with the coherence of plans. Principle
(23), for instance, disallows an alternative future in O, along which some out-
come will happen, but is forbidden from ever happening. Such an alternative
can’t correspond to a coherent plan.

This setup can readily deal with reparational obligations. Suppose that,
because of a promise to my aunt, at 4:00 I ought to catch an airplane at 5:00,
but that at 5:00 I have broken my promise because of the attractions of the
airport bar. Then at 5:00 I should call my aunt to tell her I won’t be on the
plane. Though this is the sort of situation that is sometimes represented as
paradoxical in the literature, it is easily modeled in ought kinematics, with
no apparent conceptual strain. At one time we have O—Fp true, where p
stands for ‘I tell my aunt I won’t be on the plane’. At alater time (one that
involves the occurrence of something that shouldn’t have happened) OFp is
true.

---

156 RICHMOND H. THOMASON

If we press the account a bit harder, we can change the example; it also is
true at 5:00 that I ought to inform my aunt I won’t be on the plane, and this
can be taken to entail that I ought not to be on the plane, since I can only
inform someone of what is true, and because O[p—> ¢] = [Op—>OY] is a
validity of our logic.

The response to this pressure is, of course, a Gricean maneuver;* it is true
at 5:00 (on the understanding of ‘ought’ in question) that I ought not to be
on the plane. But it is not worth saying at 5:00, and if I were to say it then,
I would be taken to have said something else, something false. And all of this
can be made plausible in terms of general principles of reasonable conver-
sation. I will not give the details here, since they can easily be reconstructed
from D. Lewis [1979b].3 On balance, the approach seems to be well braced
against pressure from this direction. It is hard to imagine a reasonable theory
of truth conditions that will not have to deploy Gricean tactics at some point.
And this can be made to look like a very reasonable place to deploy them.

These linguistic reflections are nicely supported by quite independent
philosophical considerations. Greenspan [1975] is a sustained study of ought
kinematics from a philosophical standpoint, in which it is argued that a time-
bound treatment of oughts is essential to an understanding of their logic, and
that the proper view of deontic detachment is that a conditional ought
licenses a “consequent ought” when the antecedent is unalterably true. The
paper contains many useful references to the philosophical literature, and
provides a good example of the results that can be obtained by combining
this philosophical material with the logical apparatus.

The fact that ‘I ought not to be on the plane’ would ordinarily be taken to
be false at 5:00 in the example we discussed above shows that ‘ought’ has
employments that are not practical or deliberative: ones that perhaps have to
do with wishful thinking. Also, there is its common use to express a kind of
necessity: ‘The butter is warm enough now; it ought to melt’.

Philosophers are inclined to speak of ambiguity in cases like this, but this
is either a failure to appreciate the facts or an abuse of the word ‘ambiguity’.
The word ‘ought’ is indexical or context-sensitive, not ambiguous. The matter
is argued, and some of its consequences are explored, in Kratzer [1977]; see
D. Lewis [1979b] for a study of the consequences in a more general setting.

In Thomason [1981a] this is taken into account by a more general inter-
pretation of O, according to which the relevant alternatives at ¢ need not be
possible futures for £. Probably the most general account would make the
interpretation of O in a context relative to a set of alternatives which are
regarded as possible in some sense relative to that context.

---

I.3: COMBINATIONS OF TENSE AND MODALITY 157

This is of course related to the philosophical debate over whether ‘ought’
implies ‘can’.3* The most sophisticated linguistic account makes the issue
appear rather boring: if we attend to a reasonable distinction between
ambiguity and context-sensitivity, ‘ought’ doesn’t imply ‘can’, since there are
contexts that provide counterexamples. But in practical contexts, when the
one is true the other will be, even if for technical reasons we can’t relate this
to an implication among linguistic forms.3® This result is rather disappointing.
But maybe there are ways of extracting interesting consequences for moral
philosophy from a pragmatic account of oughts and other practical phenom-
ena. An idea that I find intriguing is that manipulation of the context is the
typical — perhaps the only — mechanism of moral weakness. The idea is sug-
gested in Thomason [1981b], but is not much developed.

There seems to be no point in discussing the technical side of temporal
deontic logic here. Not much work has been done in the area, and the best
strategy seems to be to let the matter wait until more is known about the
interpretation of historical necessity.

Strictly speaking, conditional oughts are more closely related to the
combination of conditionals with oughts than that of tense with modalities.
Because the topic is complex and a thorough discussion of it would take up
much space I have decided to neglect it in this article, even though (as Green-
span [1975] makes clear) tense enters into the matter. For an illuminating
discussion of some of the problems, see DeCew [1981].3

6. CONDITIONAL LOGIC COMBINED
WITH HISTORICAL NECESSITY

In the present essay, ‘modality’ has been confined to what can be interpreted
using possible worlds semantics. So here, ‘conditional logic’ has to do with
the modern theories that were introduced by Stalnaker and then by D. Lewis;
see Stalnaker [1968] and D. Lewis [1973].38 For surveys of this work, see
Chapter I1.9 of this Handbook, and Harper [1981] and the volume in which
it appears: Harper et al. [1981].

The interaction of conditionals and historical necessity is a topic that is
only beginning to receive attention.®® As in the case of deontic logic there is a
fairly venerable philosophical tradition, involving issues that are still debated
in the philosophical literature, and a certain amount of technical model theo-
retic work that may be relevant to these issues. But this time, the philo-
sophical topic is causality.*

A conditional like D. Lewis’, which does not satisfy the principle of