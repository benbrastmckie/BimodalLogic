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
