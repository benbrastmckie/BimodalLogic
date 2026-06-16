## Page 16

94 JOHN P. BURGESS

satisfiable in (X, R) if V(a)# @ for some valuation V in (X, R), or-equiv-
alently if ~a is not valid in (X, R). Further, a is valid over a class % of frames
if it is valid in every (X, R) € ¥; and is satisfiable over ¥'if it is satisfiable in
some (X, R) € %, or equivalently if ~a is not valid over %, A system L in
standard format is sound for ¥ if every thesis of L is valid over % and a
sound system L is complete for % if conversely every formula valid over ¥ is
a thesis of L, or equivalently, if every formula consistent with L is satisfiable
over #. Any set (let us say, finite) ® of first- or second-order axioms about
the earlier-later relation < determines a class #(®) of frames, the class of its
models. The basic correspondence problem of tense logic is, given @ to find
characteristic axioms for a system L that will be sound and complete for
H(®). The next two sections of this survey will be devoted to presenting the
solution to this problem for many important .

0.5. Motivation

But first it may be well to ask, why bother? Several classes of motives for
developing an autonomous tense logic may be cited:

(a) Philosophical motives were behind much of the pioneering work of
A.N. Prior, to whom the following point seemed most important: Whereas
our ordinary language is tensed, the language of physics is mathematical and
so untensed. Thus, there arise opportunities for confusions between different
‘terms of ideas’. Now working in tense logic, what we learn is precisely how
to avoid confusing the tensed and the tenseless, and how to clarify their
relations (e.g. we learn that essentially the same thought can be formulated
tenselessly as, ‘Of any two distinct instants, one /is/ earlier and the other /is/
later’, and tensedly as, ‘Whatever is going to have been the case either already
has been or now is or is sometime going to be the case). Thus, the study of
tense logic can have at least a ‘therapeutic’ value. Later writers have stressed
other philosophical applications, and some of these are treated elsewhere in
this Handbook.

(b) Exegetical applications again interested Prior (see his [1967], Chapter
7). Much was written about the logic of time (especially about future con-
tigents) by such ancient writers as Aristotle and Diodoros Kronos (whose
works are unfortunately lost), and by such mediaeval ones as William of
Ockham or Peter Auriole. It is tempting to try to bring to bear insights from
modern logic to the interpretation of their thought. But to pepper the text of

## Page 17

1.2: BASIC TENSE LOGIC 95

an Aristotle or an Ockham with such regimenters’ phrases as ‘at time ¢’ is an
almost certain guarantee of misunderstanding. For these earlier writers
thought of such an item as ‘Socrates is running’ as being already complete as
it stands, not as requiring supplementation before it could express a propo-
sition or have a truth-value. Their standpoint, in other words, was like that of
modern tense logic, whose notions and notations are likely to be of most use
in interpreting their work, if any modern developments are.

(c) Linguistic motivations are behind much recent work in tense logic. See
Gabbay and Guenthner [to appear] among other items in our bibliography. A
certain amount of controversy surrounds the application of tense logic to
natural language. See, e.g., Van Benthem [1978, 1981] for a critic’s views. To
avoid pointless disputes it should be emphasized from the beginning that
tense logic does not attempt the faithful replication of every feature of the
deep semantic structure (and still less of the surface syntax) of English or
any other language; rather, it provides an idealized model giving the sym-
pathetic linguist food for thought. An example: In tense logic, P and F can be
iterated indefinitely to form, e.g., PPPFp or FPFPp. In English, there are four
types of verbal modifications indicating temporal reference, each applicable
at most once to the main verb of a sentence: Progressive (be + ing), Perfect
(have + en), Past (+ ed), and Modal Auxiliaries (including will, would). Tense
logic, by allowing unlimited iteration of its operators, departs from English,
to be sure. But by doing so, it enables us to raise the question of whether the
multiple compounds formable by such iteration are really all distinct in mean-
ing; and a theorem of tense logic (see section 2.5 below) tells us that on
reasonable assumptions they are not, e.g. PPPFp and FPFPp both collapse to
PFp (which is equivalent to FPp). And this may suggest why English does not
need to allow unlimited iteration of its temporal verb modifications.

(d) Computer Science: Both tense logic itself and, even more so, the closely
related so-called dynamic logic have recently been the objects of much
investigation by theorists interested in program verification. Temporal oper-
ators have been used to express such properties of programs as termination,
correctness, safety, deadlock freedom, clean behavior, data integrity, access-
ibility, responsiveness, and fair scheduling. These studies are mainly con-
cened only with future temporal operators, and so fall technically within
the province of modal logic. See Harel [I1.10], Pratt [1980] among other
items in our bibliography.

## Page 18

96 JOHN P. BURGESS

() Mathematics: Some taste of the purely mathematical interest of tense
logic will, it is hoped, be apparent from the survey to follow. Moreover, tense
logic is not an isolated subject within logic, but rather has important links
with modal logic, intuitionistic logic, and (monadic) second-order logic.

Thus, the motives for investigating tense logic are many and varied.

1. FIRST STEPS IN TENSE LOGIC

Let L, be the system in standard format with characteristic axioms (A0a, b, ¢,
d). Let ¥, be the class of all frames. We will show that L, is (sound and)
complete for ¥, and thus deserves the title of minimal tense logic. The
method of proof will be applied to other systems in the next section.
Throughout this section, thesishood and consistency are understood relative
to Ly, validity and satisfiability relative to %;.

1.1. SOUNDNESS THEOREM: L, is sound for %¥;.

Proof. We must show that any thesis (of Lo) is valid (over %;). For this it
suffices to show that each axiom is valid, and that each rule preserves validity.
The verification that tautologies are valid, and that substitution and MP pre-
serves validity is a bit tedious, but entirely routine.

To check that (AQa) is valid, we must show that for all relevant X, R, V,
and x, if x € V(G(p - q)) and x € V(Gp), then x € V(Gq). Well, the hypoth-
eses here mean, first that whenever xRy and y € V(p), then y € ¥(q); and
second that whenever xRy, then y € V(p). The desired conclusion is that
whenever xRy, then y € ¥(q); which follows immediately. Intuitively, (AOa)
says that if g is going to be the case whenever p is, and p is always going to
be the case, then g is always going to be the case. The treatment of AOb is
similar.

To check that AQc is valid, we must show that for all relevant X, R, V, and
x, if x € V(p), then x € V(GPp). Well, the desired conclusion here is that for
every y with xRy there is a z with zZRy and z € V(p). It suffices to take z = x.
Intuitively, AOc says that whatever is now the case is always going to have
been the case. The treatment of (A0d) is similar.

To check that TG preserves validity, we must show that if for all relevant
X, R, V, and x we have x € V(a), then for all relevant X, R, V, and x we have
xE€V(Ha) and x € V(Ga), in other words, that whenever yRx we have
¥ € V() and whenever xRy we have y € V(). But this is immediate. Intuit-
ively, TG says that if something is now the case for logical reasons alone, then
for logical reasons alone it always has been and is always going to be the case:
Logical truth is eternal. O

## Page 19

I.2: BASIC TENSE LOGIC 97

In future, verifications of soundness will be left as exercises for the reader.
Our proof of the completeness of Ly for g will use the method of maximal
consistent sets, first developed for first-order logic by L. Henkin, adapted to
nonclassical logics by S.Kripke, systematically applied to tense logic by
E.J. Lemmon and D. Scott (in notes never fully published), and refined and
perfected by Gabbay [1975].

Thé completeness of Lo for % is due to Lemmon. We need a number of
preliminaries.

1.2. DERIVED RULES: The following rules of inference preserve
thesishood:

(a) from ay, a, . . . , &, to infer any truth-functional consequence 8

(b) from a > B to infer Ga - G and Ha~ HB

(c) from a < B and 6(c/p) to infer 8(B/p)

(d) from a to infer its mirror image

Proof. (a) To say that 8 is a truth-functional consequence of a;, ay, ...,
@, is to say that (@;A @ A ... Aoy~ f) or equivalently a; > (o > (...
(an = P) ...)) is an instance of a tautology, and hence is an axiom. We then
apply MP.

(b) From a— B we first obtain G(a = f) by TG, and then Ga - Gf by AOa
and MP. Similarly for H.

(c) Here (a/p) denotes substitution of a for the variable p. It suffices to
prove that if a—p and 8->« are theses, then so are f(a/p) > 6(B/p) and
0(B/p) > 0(a/p). This is proved by induction on the complexity of 8, using
part (b) for the cases 8 = Gx and 8 = Hx. In particular, part (c) allows us to
insert and remove double negations freely. We write a ~ § to indicate that
a < B is a thesis.

(d) This follows from the fact that the tense-logical axioms of L, come in
‘mirror-image pairs, (AOa, b) and (AOc, d). Unlike parts (a)~(c), part (d) will
not necessarily hold for every extension of Lo. o

1.3. THESES: We present a deduction in Ly, labeling some theses for future
reference:

(1) G(p~>q)~>G(~q~>~p) from a tautology by 1.2b
(2) G(~q~>-p)~>(G~g~>G-p) (Aa)

@ () Gp->q)~>(Fp~Fq) from 1,2 by 1.2a
(4) Gp~>G(@~pnq) from a tautology by 1.2b

(5) Gla»pnq)~>(Fq~>F(paq) 3

## Page 20

98

JOHN P. BURGESS

(b) (6) Gp AFg->F(pnagq) from 4, 5 by 1.2a
(7) p~>GPp (A0c)
(8) GPpAFq~F(Ppaq) 6
() (9 pAFg~>FPpngq) from 7,8 by 1.2a
(0 gg:g:gz from tautologies by 1.2b
(11) Glg~»prq)~>(Ga~>G(@Aq) (Ada)
(@ (12) Gpa Gg+—G(prq) from 4, 10, 11 by 1.2a
(13) G-pAG~q~>G(-p A—q) 12
(14) G-pAG-q~>G~(pvq) from 13 by 1.3¢

(e) (15) FpvFq<—Flpvq)
(16) Gp~>G(p vq)

from 14 by 1.2a
from tautologies by 1.2b

Gq~>G(pvq)
6 (17) GpvGqa~>G(pvq) from 16 by 1.2a
(18) G-pvG-q~>G(-pv—q) 17

(19) G-pvG~q>G~(pnq)
(® (20) Flpaq)>FpaFq

(21) ~p~>HF-p

(22) ~p>H-Gp
(h) (23) PGp~>p

Also the mirror images of 1.3a-h are theses by 1.2d.
We assume familiarity with the following:

1.4. LINDENBAUM’S LEMMA: Any consistent set of formulas can be
extended to a maximal consistent set.

from 18 by 1.2¢
from 19 by 1.2a
(A0d)

from 21 by 1.2¢
from 22 by 1.2a

1.5. LEMMA: Let A bea maximal consistent set of formulas. For all formulas
we have:

@Ifay,...,0,€A and oyA...A
(b)~a€4 iffadd

(c) (@np)EA iffa€A
(d)(avB)EA iffa€A or

oy, > Bis a thesis, then B € A.

and PEA
BEA

They will be used tacitly below.

Intuitively, a maximal consistent set - henceforth abbreviated MCS -
represents a full description of a possible state of affairs. For MCSs 4, B we
say that 4 is potentially followed by B, and write A -3 B, if the conditions of
Lemma 1.6 below are met. Intuitiviely, this means that a situation of the sort
described by A could be followed by one of the sort described by B.

## Page 21

11.2: BASIC TENSE LOGIC 99

1.6. LEMMA: For any MCSs A, B, the following are equivalent:

(a) whenever o« € A, we have Pa € B,
(b) whenever 3 € B, we have FBE A,
(© whenever Gy € A, we havey €B,
(d) whenever H5 € B, we have § € A.

Proof. To show (a) implies (c): Assume (a) and let Gy € A. Then PGy € B,
50 by Thesis 1.3h we have y € B as required by (c).

To show (c) implies (b): Assume (c) and let § € B. Then ~f ¢ B, so G—f
¢ A, and FB = ~G-BE A as required by (b).

Similarly (b) implies (d) and (d) implies (a). [m]

1.7. LEMMA: Let C be an MCS, y any formula:

(a) if Fy €C, then there exists an MCS B with C 3 Band Y E B,

(b) if Py €C, then there exists an MCS A with A 3 Cand Yy EA.

Proof. We treat (a): It suffices (by criterion Lemma 1.6a) to obtain an
MCS B containing By = {Pa:a € C}U {y}. For this it suffices (by Linden-
baum’s Lemma) to show that B, is consistent. For this it suffices (by the
closure of C under conjunction plus the mirror image of Thesis 1.3g) to show
that for any a €C, Pa Ay is consistent. For this it suffices (since TG guaran-
tees that —F5 is a thesis whenever 8 is) to show that F(Pa A ) is consistent.
And for this it suffices to show that F(Pa A y) belongs to C - as it must by
1.3c. |m}

1.8. DEFINITION: A chronicle on a frame (X, R) is a function T assigning
each x € X an MCS T(x). Intuitively, if X is thought of as representing the set
of instants, and R the earlier-later relation, T should be thought of as provid-
ing a complete description of what goes on at each instant. T is coherent if
we have T(x) T(y) whenever xRy. T is prophetic (resp. historic) if it is
coherent and satisfies the first (resp. second) condition below:

(a) whenever Fy € T(x) there is a y with xRy and ¥ € T(y),
(b) whenever Py € T(x) there is ay with yRx and y € T(»).

T is perfect if it is both prophetic and historic. Note that T is coherent iff it
satisfies the two following conditions:

(c) whenever Gy € T(x) and xRy, theny € T(y),
(d) whenever Hy € T(x) and yRx, then y € T(y).

If V is a valuation in (X, R), the induced chronicle Ty is defined by

## Page 22

100 JOHN P. BURGESS

Ty(x) = {y:x € V(y)}; Tv is always perfect. If T is a perfect chronicle on
(X, R), the induced valuation ¥ is defined by Vr(p;) = {x:p; € T(x)}. We
have:

1.9. CHRONICLE LEMMA: Let T be a perfect chronicle on a frame (X, R).
If V=V is the valuation induced by T, then T = T, the chronicle induced
by V. In other words, for all formulas y we have:

V) = ey T}

In particular, any member of any T(x) is satisfiable in (X, R).
Proof. (+) is proved by induction on the complexity of 7. As a sample,
we treat the induction step for G: Assume (+) for v, to prove it for Gy:
On the one hand, if Gy € T(x), then by Defintion 1.8c, whenever xRy we
have y € T(p) and by induction hypothesis y € V(). This shows x € V(Gy).
On the othe hand, if Gy & T(x), then F~y ~ ~Gy € T(x), so by Definition
1.8a for some y with xRy we have ~y € T(y) and y & T(y), whence by
induction hypothesis, y € V(y). This shows x ¢ V(Gy). o

To prove the completeness of Lo for #, we must show that every con-
sistent formula 7, is satisfiable. Now Lemma 1.9 suggests an obvious strategy
for proving 7, satisfiable, namely to construct a perfect chronicle 7' on some
frame (X, R) containing an X, with 7o € T(x,). We will construct X, R, and T’
piecemeal.

1.10. DEFINITION: Fix a denumerably infinite set W. Let M be the set of
all triples (X, R, T') such that:

(a) X is a nonempty finite subset of W,
(b) R is an antisymmetric binary relation on X,
(c) T is a coherent chronicle on (X, R).

For u=(X, R, T) and &' = (X', R, T') in M we say ' extends u if (when
relations and functions are identified with sets of ordered pairs) we have:

@) xc<x'
®) R=R'NXxX)
(c) T<T

A conditional requirement of form 1.8a or b will be called unborn for
u=(X, R, T)EM if its antecedent is not fulfilled; that is, if x ¢ X or if
X €X but Fy or Py as the case may be does not belong to T(x). It will be
