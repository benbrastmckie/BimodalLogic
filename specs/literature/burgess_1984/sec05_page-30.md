## Page 30

108 JOHN P. BURGESS

Intuitively xSy means that no points are ever to be added between x and y.
We say (X', R', S', T'") extends (X, R, S, T) if on the one hand, as always,
Definition 1.10a’, &', ¢ hold; while on the other hand, $ € ' In addition to
requirements of the forms 1.8a, b we need to consider requirements of the
forms:

(e) there exists a y with xSy,
(@) there exists a y with ySx.

To “kill’ a requirement of form (e), take an MCS B with T(x) 3'B. If x is the
maximum of (X, R) it suffices to fix z € W-X and set:

X' =Xxufz}, R' = RU{(x,2)}U{(v,2):vRx},
§'=85U{(x,2)}, T =TU{EB)}
Otherwise, let y immediately succeed x in (X, R). If B = T(p) set:

' =X, R =R,
S =SU{(x,y)} T =T.

Otherwise, we have B 3 T(»), and it suffices to fix z € W-X and set:

X' = XUz, R' = RU{(x,2),(z,»)}V
U {(v,2):vRx} U {(z,v):yRv},
§' =Su{(x2)} T =TU{@B)}

Similarly, to kill a requirement of form (f) we use the mirror image of the
Lemma above, proved using (A6b).

It is also necessary to check that when xSy we never need to insert a point
between x and y in order to kill a requirement of form 1.8a or b. Reviewing
the construction of Section 2.2 above, this follows from parts (c), (d) of the
Lemma above. The remaining details are left to the reader.

A total order is discrete if every element but the maximum (if any) has an
immediate successor, and every element but the minimum (if any) has an
immediate predecessor. The foregoing argument establishes that we get a
complete axiomatization for the tense logic of discrete total orders by adding
to L, the following weakened versions of (A6a, b):

pAHp->GLvFHp, pAGp—>HLvVPGp.

]

A total order is homogeneous if for any two of its points x, y there exists
an automorphism carrying x to y. Such an order cannot have a maximum or
minimum and must be either dense or discrete. In Burgess [1979] it is indi-
cated that a complete axiomatization of the tense logic is homogeneous orders

## Page 31

I1.2: BASIC TENSE LOGIC 109

is obtainable by adding to L, the following whict®should be compared with
AS5aand A6a, b:

(Fp > FFp) v[(q A Hq ~ FHq) A (q A Gq > PGq)].

2.7. Continuity

A cut in a total order (X, R) is a partition (Y, Z) of X into two nonempty
pieces, such that whenever y €Y and z €Z we have yRz. A gap is a cut
(Y, Z) such that Y has no maximum and Z no minimum. (X, R) is complete
if it has no gaps. The completion (X*, R*) of a total order (X, R) is the com-
plete total order obtained by inserting, for each gap (¥, Z) in (X, R), an
element w(Y, Z) after all elements of Y and before all elements of Z. For
example, the completion of the rational numbers in their usual order is the
real numbers in their usual order. The extension L, of L, obtained by adding
(AT7a, b) is complete for the class ¥; of complete total orders. The proof
requires a couple of Lemmas:

LEMMA: Let T be a perfect chronicle on a total order (X, R), and (Y, Z)a
gap in (X, R). Then if Ga € T(z) for all z €Z, then Ga € T(y) for some
yEY.

Proof. Suppose for contradiction that Ga € T\(z) for all z €Z but Fa~
~Ga€E€T(y) for all yEY. For any yo €Y we have F-~aa FGa € T().
Hence, by A7a, F(Gan HF—a) € T(,), and there is an x with yoRx and
Ga €EHF~a €T(x). But this is impossible, since if x €Y then Ga € T(x),
while if x €Z then HF-a & T(x). m]

LEMMA: Let T be a perfect chronicle on a total order (X, R). Then T can be
extended to a perfect chronicle T* on its completion (X*, R*).
Proof. For each gap (Y, Z) in (X, R), the set:

C(Y,2) = {Pa:3y EY(@ET(y)} U {Fa:3z €Z(a € T(2))}

is consistent. This is because any finite subset, involving only yy, ..., Vm
from Y and zy, ..., z, from Z will be contained in T(x) where x is any
element of Y after all the y; or any element of Z before all the z;. Hence, we
can define a coherent chronicle 7* on (X*, R*) by taking T*(w(Y, Z)) to be
some MCS extending C(Y, Z). Now if Fa € T*(w(Y, Z)), we claim that
Fa € T(z) for some z €Z. For if not, then G~a € T(z) for all z €Z, and by
the previous Lemma, G~a € T(y) for some y € Y. But then PG—a, which

## Page 32

110 JOHN P. BURGESS

implies ~Fa, would belong to C(Y, Z) € T*(w(Y, Z)), a contradiction. It
hardly needs saying that if Fa € T(z), then there is some x with zRx and a
fortiori w(Y,Z)R*x having a € T(x). This shows T* is prophetic. Axiom A7b
gives us a mirror image to the previous Lemma, which can be used to show
T* historic. [m}

To prove the completeness of L, for ¥, given a consistent v, use the
work of Section 2.2 above to construct a perfect chronicle T on a frame
(X, R) such that v, € T(x,) for some x,. Then use the foregoing Lemma to
extend to a perfect chronicle on a complete total order, as required to prove
satisfiability. a

Similarly, Ly, the extension of L, obtained by adding (A4a, b) and (ASa)
and (A7a, b) is complete for the class of complete dense total orders without
maximum or minimum, sometimes called continuous orders. As a matter of
fact, our construction shows that any formula consistent with this theory is
satisfiable in the completion of the rationals, that is, in the reals. Thus Ly, is
the tense logic of real time and, hence, of the time of classical physics.

2.8. Well-Orders

The extension Lg of L, obtained by adding A8 is complete for the class #g of
all well-orders. For the proof it is convenient to introduce the abbreviations
Ip for Ppvp vFp or ‘p sometime’, and Bp for p A—Pp or ‘p for the first
time’. An easy consequence of A8 is /p — IBp: If something ever happens,
then there is a first time when it happens. The reader can check that the
following are valid over total orders; hence, theses of (L, and a fortiori of
Ls):

(1) Ipalg~>IPoAq)vI(paq) vi(pAPq),
) 1(q A Fr).n I(PBp A Bq) > I(p A FY).

Now, understanding consistency, MCS, and related notions relative to Lg, let
8, be any consistent formula and D, any MCS containing it. Let 8y, ..., 8,
be all the proper subformulas of 8,. Let T' be the set of formulas of form

() A ()1 A A ()

where each &; appears once, plain or negated. Note that distinct elements of I'
are truth-functionally inconsistent. Let I' = {y €': Iy € D}. Note that for
each y €T we have IBy € Dy, and that for distinct v, v’ € I" we must by (1)

## Page 33

1L.2: BASIC TENSE LOGIC 111

have either I(PBy A By') or I(PBy' A By) in D,. Enumerate the elements of
' a5 Yo, V1, -+ Yn.s0 that I(PBy; A By;) €Dy iff i <j. We write i< if
I(y; A Fy;) € Do. This clearly holds whenever i <j, but may also hold in other
cases. A crucial observation is:

+) Ifi<j<k and k<li, thenj<qi

This follows from (2).

These tedious preliminaries out of the way, we will now define a set X of
ordinals and a function ¢ from X to I'. Let a, b, c, . .. range over positive
integers:

We put 0 € X and set #(0) = yo.

1f 0<1 0 we also put eacha € X and set #(a) = 7.

We put w € X and set {(w) = 7.

If 111 we also put each £ = w * b € X and set #(¢) = v,.

If 1<10 we also put each £ = w + b +a € X and set £(§) = yo.
We put w? € X and set {(w?) = 7,.

If 2<02 we also put each §=cw?-c€X and set #E)=7,.
If 2<I1 we also puteach £ = w?+ ¢ + w * b €X, and set 1(§) =v,.
If 2<10 we alse put each f=w? *c+w-b+a€X and set
E) =0

And so on.

Using (+) one sees that whenever én € X and & <n, then i<Ij where

t(¢)=1; and t(n) =1;. Conversely, inspection of the construction shows
that:

(a) whenever £ € X and #(¢) =; and j<I k, then there is an n € X
with§ <nand#(n) =17,

(b) whenever £ € X and #(§) =v; and i <j, then there is an n€ X
withn <% and t(n) =7;.

For £ € X let T(¥) be the set of conjuncts of #(£). Using (a) and (b) one sees

that T satisfies all the requirements 1.8a, b, c, d for a perfect chronicle, so far

as these pertain to subformulas of 8. Inspection of the proof of Lemma

1.9 then shows that this suffices to prove 8, satisfiable in the well-order

X, <. u}

Without entering into details here, we remark that variants of Lg provide
axiomatizations of the tense logics of the integers, the natural numbers, and
of finite total orders. In particular, for the natural numbers one uses L,,,, the

## Page 34

112 JOHNP. BURGESS

extension of L, obtained by adding A8 and p A Gp > HL vPGp. L,,, is the
tense logic of the notion of time appropriate for discussing the workings of a
digital computer, or of the mental mathematical constructions of Brouwer’s
‘creative subject’.

2.9. Lattices

The extension Ly of L, obtained by adding (A4a, b) and (A9a, b) is complete
for the class ¥; of partial orders without maximal or minimal elements in
which any two elements have an upper and a lower bound. We sketch the
modifications in the work of Section 2.2 above needed to prove this:
To begin with, we must revise clause 1.10b in the definition of M to read:
(bg) R isa partial order on X having a maximum and a minimum.
This necessitates revisions in the proof of the Killing Lemma, for which the
following will be useful:

LEMMA: Let A, B, C be MCSs. If A3 B and A 3 C, then there exists an
MCS D such that B-3 Dand C-3 D.

Proof. The problem quickly reduces to showing {§:GB € B} U {y:Gy € C}
consistent. For this it suffices (using 1.3d) to show that A v is consistent
whenever GBE B, Gy €C. Now in that case we have FGB, FGy € A, since
A 3B, C. By A9a, we then have GFB € A, and by 1.3b we then have F(FB A
Gy)€EA and FF(BAy)€EA, which suffices to prove Ay consistent as
required. [m)

Turning now to the Killing Lemma, trouble arises when for a given
(X, R, T) EM a requirement of form Definition 1.8a is to be ‘killed’ for some
X other than the maximum y of (X, R) and some Fy € T(x). Fixing an MCS B
with T(x) -3 B and y € B, and az € W-X, we would like to add z to x placing
it after x and assigning it the MCS B. But we cannot simply do this, else the
resulting partial order would have no maximum. (For y and z would be
incomparable.) So we apply the Lemma (with A = T(x), C = T(»)) to obtain
an MCS D with B-3 D and T(y) -3 D. We fix aw € W-X distinct from z, and
set:

X' =XUfz,w),
R = RU{(x,2),(z, W)} U{(v,2):0Rx} U {(v, w):vEX}.
T' = TU{(z,B),(w,D)}.

Similarly, a requirement of form 1.8b involving an element other than the

## Page 35

1.2: BASIC TENSE LOGIC 113

minimum is treated using the mirror image of the Lemma above, proved using
A9b.

Now given a formula 7, consistent with Lo, the construction of Definition
1.10 above produces a perfect chronicle T on a partial order (X, R) with
Yo € T(x,) for some x,. The work of Section 2.4 above shows that (X, R) will
have no maximal or minimal elements. Moreover, (X, R) will be a union of
partial orders (X, R,,) satisfying (by). Then any x, y € X will have an R-upper
bound and an R-lower bound, namely the R,-maximum and R,-minimum
elements of any X,, containing them both. Thus, (X, R) € ¥ and 7, is satis-
fiable over ;. [m}

A lattice is a partial order in which any two elements have a least upper
bound and a greatest lower bound. Actually, our proof shows that Ly is com-
plete for the class of lattices without maximum or minimum. It is worth
mentioning that A9a, b could have been replaced by:

FpAFq—>F(PoaPq),  PoaPq~P(FpnFg).

Weakened versions of these axioms can be used to give an axiomatization for
the tense logic of arbitrary lattices.

3. THE DECIDABILITY OF TENSE LOGICS

All the systems of tense logic we have considered so far are recursively
decidable. Rather than give an exhaustive (and exhausting) survey, we treat
here two examples, illustrating the two basic methods of proving decidability:
One method, borrowed from modal logic, is that of using so-called filtrations
to establish what is known as the finite model property. The other, borrowed
from model theory, is that of using so-called interpretations in order to be
able to exploit a powerful theorem of Rabin [1966].

3.1. THEOREM: L, is decidable.

Proof. Let % be the class of models of (B1) and (B9a, b); thus ¥ is like
Hq except that we do not require antisymmetry. Let %' be the class of
finite elements of #". It is readily verified that Ly is sound for % and a
fortiori for %" We claim that Lo is complete for %" This provides an effec-
tive procedure for testing whether a given formula a is a thesis of Lo or not, as
follows: Search simultaneously through all deductions in the system Ly and
through all members of "'~ or more precisely, of some nice countable sub-
class of %' containing at least one representative of each isomorphism-type.

## Page 36

114 JOHN P. BURGESS

Eventually one either finds a deduction of @, in which case « is a thesis, or
one finds an element of % 'in which —a is satisfiable, in which case by our
completeness claim, « is not a thesis.

To prove our completeness claim, let o be consistent with Ly. We showed
in Section 2.9 above how to construct a perfect chronicle T on a frame
(X, R) € Ky € X having v, € T(x,) for some x,. For x € X, let #(x) be the
set of subformulas of v, in T(x). Define an equivalence relation on Xby:

xoy iff  Hx)=1p).

Let [x] denote the equivalence class of x, X' the set of all [x]. Note that X"
is finite, having no more than 2% elements, where k is the number of sub-
formulas of . Consider the relations on X' defined by:

aR*b iff xRy forsomex Eaandy Eb,
aR'b  iff  for some finite sequence a=co,Cy, . ..,Cp-y,Cp =b
we have ¢;R*c;,, foralli<n.

Clearly R’ is transitive, while R* and, hence, R’ inherit from R the properties
expressed by B9a, b. Thus (X', R')E %" Define a function ¢’ on X' by let-
ting #'(@) be the common value of #(x) for all x €a. In particular for
ao = [xo] we have 7, €(ao). We claim that ¢ satisfies clauses 1.8a, b, ¢, d
of the definition of a perfect chronicle so far as these pertain to subformulas
of 7o As remarked in Section 2.8 above, this suffices to show 7, satisfiable in
(X', R") and, hence, satisfiable over ¥, as required.
In connection with Definition 1.8a, what we must show is:

(a) whenever Fy € #(a) there is a b with aR'b and y € t(b)

Well, let @ = [x], so Fy €t(x) € T(x). There is a y with xRy and y € #(y)
since T is prophetic. Letting b = [y] we have aR*b and so aR'b.
In connection with Definition 1.8¢ what we must show is:

(c')  whenever Gy €#(a) and aR'b, then y € #(b).
For this it clearly suffices to show:
(c*)  whenever Gy € t(a) and aR*b, then y € t(b) and Gy € #(b).

To show this, assuming the two hypotheses, fix x €a and y €b with xRy.
We have Gy €1(x) € T(x), so by Ala, GGy € T(x). Hence, y Et(y) and
Gy E€1(y), since T is coherent — which completes the proof.

Definitions 1.8b, d are treated similarly. o
