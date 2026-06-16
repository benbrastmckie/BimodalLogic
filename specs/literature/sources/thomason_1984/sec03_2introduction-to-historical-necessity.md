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
