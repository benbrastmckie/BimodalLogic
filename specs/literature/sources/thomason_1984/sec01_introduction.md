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
