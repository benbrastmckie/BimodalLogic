## Page 23

IL.2: BASIC TENSE LOGIC 101

called alive for p if its antecedent is fulfilled but its consequent is not; in
other words, there is no y €X with xRy or yRx as the case may be and
7ET(Y).

It will be called dead for u if its consequent is fulfilled. Perhaps no mem-
ber of M is perfect; but any imperfect member of M can be improved:

1.11. KILLING LEMMA: Let u=(X, R, T) EM. For any requirement of
form 1.8a or b which is alive for , there exists an extension u' = (X',R', T")
€M of u for which that requirement is dead.

Proof. We treat a requirement of form 1.8a. If x €X and Fy € T(x), by
1.7a there is an MCS B with T(x) -3 B and y € B. It therefore suffices to fix
¥ € W-X and set:

@  X'=xu{y}

()  R'=RU{x,»)}

©  T'=Tu{yB} o

1.12. COMPLETENESS THEOREM: L, is complete for ¥,

Proof. Given a consistent formula o, we wish to construct a frame (X, R)
and a perfect chronicle T on it, with yo € T(x,) for some x,. To this end we
fix an enumeration xo, X, X5, . . . of W, and an enumeration yo, 71,72, - . . of
all formulas. To the requirement of form 1.8a (resp. 1.8b) for x = x; and
7y =7, we assign the code number 2'5"7 (resp. 3'5"7). Fix an MCS C, with
Y0 € Co, and let pp = (Xo, Ry, To) where Xo = {xo}, Ro =0, and T = {(xo,
Co)}. If iy, is defined, consider the requirement, which among all those which
are alive for y,, has the least code number. Let y,,,, be an extension of u,, for
which that requirement is dead, as provided by the Killing Lemma. Let
(X, R, T) be the union of the y,, = (X, Ry, Tp,); more precisely, let X be the
union of the X, R of the R,,, and T of the T,,. It is readily verified that T is
a perfect chronicle on (X, R), as required. a

The observant reader may be wondering why in Definition 1.10b the
relation R was required to be antisymmetric. The reason was to enable us to
make the following remark: Our proof actually shows that every thesis of
L, is valid over the class % of all frames, and that every formula consistent
with Ly is satisfiable over the class Fany; of antisymmetric frames. Thus, %,
and Hgn; give rise to the same tense logic; or to put the matter differently,
there is no characteristic axiom for tense logic which ‘corresponds’ to the
assumption that the earlier-later relation on instants of time is antisymmetric.

In this connection a remark is in order: Suppose we let X be the set of all

## Page 24

102 JOHN P. BURGESS

MCSs, R the relation -3, ¥ the valuation V(p;) = {x:p; € x}. Then using 1.6
and 1.7 it can be checked that V(y) = {x:y € x} forall y. In this way we get
a quick proof of the completeness of L, for #g. However, this (X, R) is not
antisymmetric. Two MCSs A and B may be clustered in the sense that 4 3 B
and B -3 A. There is a trick, known as ‘bulldozing’, though, for converting
nonantisymmetic frames to antisymmetric ones, which can be used here to
give an alternative proof of the completeness of Lo for Hgn;. See Bull and
Segerberg [this volume, Chapter I1.1] and Segerberg [1970].

2. AQUICK TRIP THROUGH TENSE LOGIC

The material to be presented in this section was developed piecemeal in the late
1960s. In addition to persons already mentioned, R. Bull and N. Cocchiarella
should be cited as important contributors to this development. Since little
was published at the time, it is now hard to assign credits.

2.1. Partial Orders

Let L, be the extension of Lo obtained by adding (Ala) as an extra axiom.
Let %] be the class of partial orders, that is, of antisymmetric, transitive
frames. We claim L, is (sound and) complete for #;. Leaving the verification
of soundness as an exercise for the reader, we sketch the modifications in the
work of the preceding section needed to establish completeness.

First of all, we must now understand the notions of thesishood and con-
sistency and, hence, of MCS and chronicle, as relative to L,. Next, we must
revise clause 1.10b in the definition of M to read:

(by) R is a partial order on X.

This necessitates a revision in clause 1.11b in the proof of the Killing Lemma.
Namely, in order to guarantee that R' will be a partial order on X', that
clause must now read:

(b)) R =RU{x»}V{(.7):0Rx}.

But now it must be checked that 7", as defined by clause 1.11c, remains a
coherent chronicle under the revised definition of R'. Namely, it must be
checked that if vRx, then T(v)-8 B. To show this (and so complete the
proof) the following suffices:

## Page 25

1.2: BASIC TENSE LOGIC 103

LEMMA: Let A, C, Bbe MCSs. If A 3Cand C -3 B, then A 3 B.

Proof. We use criterion 1.6¢ for 3: Assume Gy € 4, to prove y € B. Well,
by the new axiom (Ala) we have GGy €A. Then since A 3 C, we have
Gy €C, and since C-3 B, we have y €B. a

It is worth remarking that the mirror image Alb of Ala is equally valid
over partial orders, and must thus by the completeness theorem be a thesis
of L. To find a deduction of it is a nontrivial exercise.

2.2. Total Orders

Let L, be the extension of L, obtained by adding (A2a, b) as extra axioms.
Let ¥ be the class of total orders, or frames satisfying antisymmetry, trans-
itivity, and comparability. Leaving the verification of soundness to the reader,
we sketch the modifications in the work of Section 2.1 above, beyond simply
understanding thesishood and related notions as relative to L,, needed to
show L, complete for #;.

To begin with, we must revise clause 1.10b in the definition of M to read:

(bz)  Risatotal order on X.

This necessitates revisions in the proof of the Killing Lemma, for which the
following will be useful:

LEMMA: Let A, B, C be MCSs. If A 3 B and A 3 C, then either B=C or
B3CorC-3B

Proof. Suppose for contradition that the two hypotheses hold but none of
the three alternatives in the conclusion holds. Using criterion 1.6b for -3, we
see that there must exist a yo €C with Fyo ¢ B (else B3 C) and a f, €B
with Fo ¢ C (else C -3 B). Also there must exist a § with & €B, & & C (else
B=C). Let=PoA~Fyon8 €EB,y=79oA "FPoA =85 EC.We have FBE A
(since A 3 B) and Fy €A (since A 3 C). Hence, by A2a, one of F(8 A Fy),
F(FBA7), F(BA7) must belong to A. But this is impossible since all three
are easily seen (using 1.3g) to be inconsistent. m]

Turmning now to the Killing Lemma, consider a requirement of form 1.8a
which is alive for a certain p = (X, R, T) €M. We claim there is an extension
W' =(X', R, T') for which it is dead. This is proved by induction on the
number 7 of successors which x hasin (X, R). We fix an MCS B with T(x) 3 B
and y €B. If n =0, it suffices to define u' as was done in Section 2.1 above.

## Page 26

104 JOHN P. BURGESS

If n>0, let x' be the immediate successor of x in (X, R). We cannot have
Y ET(x') or else our requirement would already be dead for p. If Fy € T(x"),
we can reduce to the case n — 1 by replacing x by x'. So suppose Fy & T(x').
Then we have neither B = T(x") nor T(x')-3 B. Hence, by the Lemma, we
must have B -3 T(x"). Therefore it suffices to fix y € W-X and set:

X' =Xxu{y}
R = RU{(x»),(»,x)}V{(@¥):0Rx} U {(»,7):(xRo)}
T' = TU{(y,B)}.

In other words, we insert a point between x and x', assigning it the set B.
Requirements of form 1.8b are handled similarly, using a mirror image of the
Lemma, proved using (A2b). No further modifications in the work of Section
2.1 above are called for. o

The foregoing argument also establishes the following: Let Lyyee be the
extension of L, obtained by adding A2b as an extra axiom. Let F;ye be the
class of trees, defined for present purposes as those partial orders in which
the predecessors of any element are totally ordered. Then Ly, is complete
for #ree-

It is worth remarking that the following are valid over total orders:

FPp—>PpvpvFp, PFp->PpvpvFp.

To find deductions of them in L, is a nontrivial exercise. As a matter of fact,
these two items could have been used instead of (A2a, b) as axioms for total
orders. One could equally well have used their contrapositives:

HpApnaGp—GHp, HpApAGp—HGp.

The converses of these four items are valid over partial orders.

2.3. Extrema (Maxima, Minima)

2.4. No Extremals (No Maximals, No Minimals)

Let L; (resp. Ly) be the extension of L, obtained by adding (A3a, b) (resp.
(Ada, b)) as extra axioms. Let %; (resp. #3) be the class of total orders hav-
ing (resp. not having) a maximum and a minimum. Beyond understanding the
notions of consistency and MCS relative to L or L, as the case may be, no
modification in the work of Section 2.2 above is needed to prove Ly com-
plete for #; and L, for #;. The following observations suffice:

## Page 27

1L.2: BASIC TENSE LOGIC 105

On the one hand, understanding consistency and MCS relative to Ls, if
(X, R) is any total order and T any perfect. chronicle on it, then for any
X € X, either GL € T(x) itself, or FGL € T(x) and so GL € T() for some y
with xRy - this by (A3a). But if GL € T(z), then any w with zZRw would have
to have 1 € T(w), which is impossible, so z must be the maximum of (X, R).
Similarly, A3b guarantees the existence of a minimum in (X, R). o

On the other hand, understanding consistency and MCS relative to Ly, if
(X, R) is any total order and T any perfect chronicle on it, then for any
x €X we have GT > FT € T(x), and hence FT € T(x), so there must be a y
with (T € T(y) and) xRy - this by (A4a). Similarly, A4b guarantees that for
any x there is ay with yRx. ]

The foregoing argument also establishes that the extension of L, obtained
by adding (A4a, b) is complete for the class of partial orders having no
‘maximal or minimal elements.

It hardly needs saying that one can axiomatize the view (charateristic of
Western religious cosmologies) that Time had a beginning, but will have no
end, by adding (A3b) and (A4a) to L,.

2.5. Density

The extension Ls of L, obtained by adding (ASa) (or equivalently (A5b)) is
complete for the class ¥ of dense total orders. The main modification in the
work of Section 2.2 above needed to show this is that in addition to require-
ments of forms 1.8a, b we need to consider requirements of the form:

(e if xRy, then there exists a z with xRz and zRy.

To ‘kill’ such a requirement, given a coherent chronicle T on a finite total
order (X, R) and x, y € X with y immediately succeeding x, we need to be
able to insert a point z between x and y, and find a suitable MCS to assign
toz. For this the following suffices:

LEMMA: Let A, B be MCSs with A 3 B. Then there exists an MCS C with
A3CandC3B.

Proof. The problem quickly reduces to showing {Pa:a €4} U {FB:BE B}
consistent. For this it suffices to show that if a€A4 and BEB, then
F(Paun FB)EA. Now if BEB, then since A 3 B, FBE A, and by (ASa),
FFBE A. An appeal to 1.3¢ completes the proof. g

## Page 28

106 JOHN P. BURGESS

| HoesGHy
p‘/F e >PGp
~ SSep,
Tp
HPp
Fig. 1.
TABLEI

GGHp ~ GHp FGHp ~ GHp
GFHp ~ GHp FFHp ~ FHp
GPGp ~ Gp FPGp ~ FGp
GPHp =~ PHp FPHp =~ PHp
GFGp ~ FGp FFGp ~ FGp
GHPp ~ HPp FHPp ~ HPp
GGFp ~ GFp FGFp ~ GFp
GGPp ~ GPp FGPp =~ FPp
GHFp ~ GFp FHFp ~ Fp
GFPp ~ FPp FFPp ~ FPp

Similarly, the extension Lq of L, obtained by adding A4a, b and ASa is
complete for the class of dense total orders without maximum or minimum.
A famous theorem tells us that any countable order of this class is isomorphic
to the rational numbers in their usual order. Since our method of proof
always produces a countable frame, we can conclude that Lq is the tense
logic of the rationals. The accompanying diagram (Figure 1) indicates some
implications that are valid over dense total orders without maximum or
minimum, and hence theses of Lq; no further implications among the for-
mulas considered are valid. A theorem of C. L. Hamblin tells us that in Lq
any sequence of Gs, Hs, Fs and Ps prefixed to the variable p is provably
equivalent to one of the 15 formulas in our diagram. It obviously suffices
to prove this for sequences of length three. The reductions listed in the
accompanying Table I together with their mirror images, suffice to prove this.
It is a pleasant exercise to verify all the details.

## Page 29

11.2: BASIC TENSE LOGIC 107

2.6. Discreteness

The extension Lg of L, obtained by adding (A6a, b) is complete for the class
Hj of total orders in which every element has an immediate successor and an
immediate predecessor. The proof involves quite a few modifications in the
work of Section 2.2 above, beginning with:

LEMMA: For any MCS A there exists an MCS B such that:
(a) whenever Fy €A, theny vFy €B.
Moreover, any such MCS further satisfies:

(b) whenever P§ € B, then § vP§ €A,
(c) whenever A -3 C, then either B=CorB 3 C,
(d) whenever C 3 B, then either A = Cor C 3 A.

Proof. (a) The problem quickly reduces to proving the consistency of any
finite set of formulas of the forms Pa for € 4 and y vFy for Fy €A. To
establish this, one notes that the following is valid over total orders, hence a
thesis of (L, and a fortiori of) Ls:

FpoAFpyA...ANFp, >
F((PovFpo) A (PyVFPI)A ... A (D VEP,))

(b) We prove the contrapositive. Suppose 5 VP8 & A. By (A6a), FH—6 €A.
By part (a), H-~8 vFH—8 € B. But FHp - Hp is valid over total orders, hence
a thesis of (L, and a fortiori of) Ls. So H~8 €B and P5 & B as required.

(c) Assume for contradiction that 4 -3 C but neither B =C nor B3 C.
Then there exist a v €C with v, ¢ B and a v, €C with Fy, €B. Let
¥ =7 A7;. Then y € C and since 4 -3 C, Fy EA. But y vFy & B, contrary
to (a).

(d) Similarly follows from (b). a

We write A 3' B to indicate that A, B are related as in the above Lemma.
Intuitively this means that a situation of the sort described by 4 could be
immediately followed by one of the sort described by B.

We now take M to be the set of quadruples (X, R, S, T) where on the one
hand, as always X is a nonempty finite subset of W, R a total order on X, and
T a coherent chronicle on (X, R); while on the other hand, we have:

(d) whenever xSy, then y immediately succeeds x in (X, R),
(e) whenever xSy, then T(x) 3" T(y),
