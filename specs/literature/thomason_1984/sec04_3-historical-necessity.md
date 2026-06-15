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
