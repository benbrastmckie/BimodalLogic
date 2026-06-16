## Page 37

I.2: BASIC TENSE LOGIC 115

3.2. THEOREM: Ly, is decidable.

Proof. We introduce an alternative definition of validity which is useful in
other contexts. To each tense-logical formula o we associate a first-order
formula & as follows: For a sentential variable p; we set p; = Py(x) where P; is
a one-place predicate variable. We then proceed inductively:

(-0)" =g,
@np)’ = anp
(Ga)” = Wy(x<y~>a(yhx),

(Ha)” = Vy(y <x-~>a(y/x)).

Here (y/x) represents the result of substituting for x the alphabetically first
variable y not occurring yet. Given a valuation ¥ in a frame (X, R) we have an
interpretation in the sense of first-order model theory, in which R interprets
the symbol < and ¥(p;) the symbol P;. Unpacking the definitions it is entirely
trivial that we always have:

(*) €V iff (X,R,V(po), V(p1), V(pa),.. )k alx),

Where [ is the usual satisfaction relation of model theory. We now further
define:

o* = VPGVP,. .. VP Vxi(x),

where po, Py, . . ., Py, include all the variables occurring in a. Note that ¢* is a
second-order formula of the simplest kind: It is monadic (all its second-order
variables are one-place predicate variables) and universal (consisting of a string
of universally-quantified second-order variables prefixed to a first-order
formula). It is entirely trivial that:

+) aisvalidin (X,R) iff (X,R)Ea*.

It follows that to prove the decidability of the tense logic of a given class ¥~
of frames it will suffice to prove the decidability of the set of universal
monadic (second-order) formulas true in all members of ¥~

Let 2<w be the set of all finite 0, 1-sequences. Let *0 be the function
assigning the argument s = (i, iy, . . ., i,) € 2<¢ the value s*0 = (ip, iy, . . . ,
ip, 0), and similarly for *1. Rabin proves the decidability of the set S2S of
monadic (second-order) formulas true in the structure (2<¢, x0, *1). He
deduces as an easy corollary the decidability of the set of-monadic formulas
true in the frame (Q, <) consisting of the rational numbers with their usual
order. This immediately yields the decidability of the system Lq of Section
2.5 above. Further corollaries relevant to tense logic are the decidability of

## Page 38

116 JOHN P. BURGESS

the set of monadic formulas true in all countable total orders, and similarly
for countable well-orders.

It only remains to reduce the decision problem for L, to that for Lg. The
work of 2.7 above shows that a formula « is satisfiable in the frame (R, <)
consisting of the real numbers with their usual order, iff it is satisfiable in the
frame (Q, <) by a valuation ¥ with the property:

1) V(o) = Q for every substitution instance & of A7a or b.
Inspection of the proof actually shows that it suffices to have:

? V(o) = Q where & is the conjunction of all instances of A7a or
b obtainable by substituting subformulas of « for vari-
ables.

A little thought shows that this amounts to demanding:
3) V(en GHe') # .

In other words, « is satisfiable in (R, <) iff & A GHo!' is satisfiable in (R, <),
which effects the desired reduction. For the lengthy original proof see Bull
[1969]. Other applications of Rabin’s theorem are in Gabbay [1975]. Rabin’s
proof uses automata-theoretic methods of Biichi; these are avoided by Shelah
[1975].

4. TEMPORAL CONJUNCTIONS AND ADVERBS

4A. Since, Until, Uninterruptedly, Recently, Soon

All the systems discussed so far have been based on the primitives ~, A, G, H.
It is well-known that any truth function can be defined in terms of -, A. Can
we say something comparable about temporal operators and G, H? When this
question is formulated precisely, the answer is a resounding NO.

4.1. DEFINITION: Let ¢ be a first-order formula having one free variable x
and no nonlogical symbols but the two-place predicate < and the one-place
predicates Py, .. ., P,. Corresponding to ¢ we introduce a new n-place con-
nective, the (first-order, one-dimensional) temporal operator O(p). We
describe the formal semantics of O(yp) in terms of the alternative approach of
Theorem 3.2 above: We add to the definition of ~ the clause:

O, - - . n)) = @l@/Py, ..., &n/Pn)

## Page 39

IL2: BASIC TENSE LOGIC 117

Here &/P denotes substitution of the formula & for the predicate variable P.
We then let formula (*) of Theorem 3.2 above define V() for formulas
involving O(p). Examples 4.2 below illustrate this rather involved definition.
If ={0(¢1), - .., O(gx)} is a set of temporal operators, an &-formula is
one built up from sentential variables using -, A, and elements of . A tem-
poral operator O(y) is O-definable over a class ¥ of frames if there is an
O-formula a such that O(g)(py, . .., Pp) <>« is valid over ¥. & is tem-
porally complete over ¥ if every temporal operator is ¢-definable over ¥
Note that the smaller ¥ is - it may consist of a single frame - the easier it is
to be temporally complete over it.

4.2. EXAMPLES:

1O WE<y->P0O),

(@) Vy(y <x->Py(3)),

3) y(x <y AVz(x <z Az <y =>Py(2))),

@) y(y <xaVz(y<zaz<x->Pyz))),

(%) y(x <y AP(Y)AVz(x <z nz <y =>Py2))),
(6) Iy(y <x APy(¥) A Vz(y <z Az <x > Py(2))).

For (1), O(y) is just G. For (2), O(y) is just H. For (3), O(p) will be written
G', and may be read ‘p is going to be uninterruptedly the case for some time’.
For (4), O(y) will be written H', and may be read ‘p has been uninterruptedly
the case for some time. For (5), O(p) will be written U, and U(p, q) may be
read ‘until p, ¢’; it predicts a future occasion of p’s being the case, up until
which g is going to be uninterruptedly the case. For (6), O(y) will be written
S, and S(p, q) may be read ‘since p,q’. In terms of G’ we define F' = ~G'~,
read ‘p is going to be the case arbitrarily soon’. In terms of H' we define
P =-H'-, read ‘p has been the case arbitrarily recently’. Over all frames, Gp
is definable as ~U(—p, T), and G' as U(T, p). Similarly, H and H' are defin-
able in terms of S. The following examples are due to H. Kamp:

4.3. PROPOSITION: G' is not G, H-definable over the frame (R, <).
Sketch of Proof. Define two valuations over that frame by:
V(p) = {0, 1,£2,£3,..}  W(p) = V(p)U{t},2}24,.. )

Then intuitively it is plausible, and formally it can be proved that for any G,
H-formula o we have 0 € V(a) iff 0 € W(a). But 0 € V(G'p) - W(G'p). o

## Page 40

118 JOHN P. BURGESS

4.4. PROPOSITION: U is not G, H, G', H'-definable over the frame (R, <).
Sketch of Proof. Define two valuations by:

V(p) = {+1,£2,£3,4,..} W(p) = {£2,%3,+4,..}
V(g) = W(g) = the union of the open intervals
ey (=5,—4),(=3,-2), (-1, +1),
(+2,+3),(+4,+5),...

Then intuitively it is plausible, and formally it can be proved that for any
G, H, G', H'-formula @ we have 0 € V(a) iff 0 € W(c). But 0 € V(U(p, q)) —
WU(p, 9)- o

Such examples might inspire pessimism, but Kamp [1968] proves:

4.5. THEOREM: The set {U, S} is temporally complete over continous
orders.

We will do no more than outline the difficult proof (in an improved ver-
sion due to Gabbay): Let ¢ be a set of temporal operators, % a class of
frames. An -formula « is purely past over ¥ if whenever (X, R) € ¥ and
x €K and V, W are valuations in (X, R) agreeing before x (so that for all i,
V(p;) N {y:yRx} = W(p;) N {y :yRx}) then x € V() iff x € W(a). Similarly,
one defines purely present and purely future, and one defines pure to mean
purely past, or present, of future. Note that Hp, H'p, S(p, q), are purely past,
their mirror images purely future, and any truth-functional compound of vari-
ables purely present. & has the separation property over ¥ if for every -
formula « there exists a truth-functional compound § of ¢-formulas pure
over ¥ such that a < f is valid over #. O is strong over ¥ if G, H are O-
definable over #. Gabbay [1983] proves:

4.6. CRITERION: Over any given class ¥ of total orders, if  is strong and
has the separation property, then it is temporally complete.

A full proof being beyond the scope of this survey, we offer a sketch: We
wish to find for any first-order formula p(x, <, Py, ..., P,) an J-formula
&Py, - .., Pn) representing it in the sense that for any (X, R) € # and any
valuation ¥ and any @ € X we have:

a€V(® iff (X.R.V(p..... V(p,)) E wla/x).
The proof procedes by induction on the depth of nesting of quantifiers in ¢,

## Page 41

11.2: BASIC TENSE LOGIC 119

the key step being ¢(x) = 3y¥(x, »). In this case, the atomic subformulas of
¥ are of the forms Py(x), Pi(z),z <x,z =x,x<z,z=w,z <w, where z and
w are variables other than x. Actually, we may assume there are no sub-
formulas of form Py(x) since these can be brought outside the quantifier 3y.
We introduce new singulary predicates Q~, Q°, Q* and replace the sub-
formulas of ¥ of forms z <x, z =x, x <z by 07(z), 0°(z), @*(z), to obtain
a formula 8(p, <, P, ...,P,, 0", 0% Q%) to which we can apply our induc-
tion hypothesis, obtaining an Zformula 8 (py, .. .,Pa, 47, ¢°, q*) represent-
ing it. Let ¥(p1, - .. ,Pa) =8Py, . . ., Pn, Fq,q, Pq),and =Py vy vFy. It
is readily verified that for any (X, R) € ¥ and any a, b € X and any valuation
V with V(q) = {a} that we have:

bEV(Y) iff (X,R,V(py),..., V(pa))F Y(alx, b]y),
a€V(p) iff (X,R,V(py),...,V(pn)Ewlalx).

By hypothesis, § is equivalent over ¥ to a truth-functional compound of
purely past formulas §;, purely present ones B, and purely future ones f;. In
each B; (resp. B7) (resp. Bi) replace g by L (resp. T) (resp. 1) to obtain an
O-formula a. 1t is readily verified that « represents .

It ‘only’ remains to show:

4.7. LEMMA: The set {U, S} has the separation property over complete
orders.

Though a full proof is beyond the scope of this survey, we sketch the
method for achieving separation for a formula « in which there is a single
occurrence of an S within the scope of a U. This case (and its mirror image) if
the first and most important in a general inductive proof.

To begin with, using conjunctive and disjunctive normal forms and such
easy equivalences as:

Ulp vq, 1) <> U(p, 1) vU(@, 1),
U(p,q ar) <> U(p,q) A Ulp, ),
=8(q,r) <= 8(-r,~q) vP'-r,
we can achieve a reduction to the case where  has one of the forms:
(a) U(p ~S(a, ), 1)
()  Up.anse,0)

For (a), an equivalent which is a truth-functional compound of pure
formulas is provided by:

## Page 42

120 JOHN P. BURGESS

@) [S@r)ve)aUp,rad] vU@AUlp,rat), 1)
For (b) we have:
®)  {SE, A vrIAUE, ) vUE, DI} VB

where B is: F'=t A U(p, q v S(r, 1)). This, despite its complexity, is purely
future. The observant reader should be able to see how completeness is
needed for the equivalence of (b) and (b').

Unfortunately, U and S take us no further, for Kamp proves:

4.8. PROPOSITION: The set {U, S} is not temporally complete over (@, <).

Without entering into details, we note that one undefinable operator is
O(p) where ¢ says:

Ppx<yaVzx<zaz<y->
(Yw(x <waw<z->P,(W)vVwiz<wa w<y->P,(w))))

Over complete orders O(p)(p, q) amounts to U(G'q A (p vq), p).
Recently J. Stavi has found two new operators U’, ' and proved:

4.9. THEOREM: The set {U, S, U', S'} is temporally complete over total
orders.

Gabbay has greatly simplified the proof: The idea is to try to prove the
separation property over arbitrary total orders, and see what operators one
needs. One quickly hits on the right U’, S'. The combinatorial details cannot
detain us here.

What about axiomatizability for U, S-tense logic? Some years ago Kamp
announced (but never published) finite axiomatizability for various classes of
total orders. Some are treated in Burgess [1982], where the system for dense
orders takes a particularly simple form: We depart from standard format only
to the extent of taking U, S as our primitives. As characteriztic axioms, it
suffices to take the following and their mirror images:

G(p > q) > (U(p,r) > Ulg, ) A (U, p) > UL, 9))

pAUg,r) > UlgnS(p,n, 1),

U(p, q) <= U(p, 4 A U(p, q)) <= Ulq A U(p, ), 9),

U(p,q) A —~U(p,r) > Ulg a -, q),

U(p, ) AU, ) > Upar,qns) vU(pAs, qas)vU@AT, qAs).
A particularly important axiomatizability result is in Gabbay et al. [1980].

## Page 43

1.2: BASIC TENSE LOGIC 121

What about decidability? Rabin’s theorem applies in most cases, the not-
able exceptions being complete orders, continuous orders, and (R, <). Here
techniques of monadic second-order logic are useful. Decidability for the
cases of complete and continuous orders is established in Gurevich [1977,
Appendix]; and for (R, <) in Burgess and Gurevich [to appear]. A fact (due to
Gurevich) from the latter paper worth emphasizing is that the U, S-tense
logics of (R, <) and of arbitrary continuous orders are not the same.

4B. Now, Then

We have seen that simple G, H-tense logic is inadequate to express certain
temporal operators expressible in English. Indeed it turns out to be inade-
quate to express even the shortest item in the English temporal vocabulary,
the word ‘now’. Just what role this word plays is unclear — some incautious
writers have even claimed it is semantically redundant - but Kamp [1971]
gives a thorough analysis. Let us consider some examples:

(0) The seismologist predicted that there would be an earthquake.

[63] The seismologist predicted that there would be an earthquake
now.

(@) The seismologist predicted that there would already have been an
earthquake before now.

3) The seismologist predicted that there would be an earthquake,
but not till after now.

As Kamp says:

The function of the word ‘now’ in (1) is to make the clause to which it applies - i.e.
‘there would be an earthquake’ - refer to the moment of utterance of (1) and not to the
moment of moments (indicated by other temporal modifiers that occur in the sentence)
to which the clause would refer (as it does in (0)) if the word ‘now’ were absent.

4.10. Formal Semantics

To formalize this observation, we introduce a new one-place connective J (for
jetzt). We define a pointed frame to be a frame with a designated element. A
valuation in a pointed frame (X, R, xo) is just a valuation in (X, R). We
extend the definition of 0.4 above to G, H, J-formulas by adding the clause:

Vo) = X ifxo€W(@), 9 ifxoV(a)

is valid in (X, R, x,) if xo € V(«) for all valuations V.

## Page 44

122 JOHN P. BURGESS

An alternative approach is to define a 2-valuation in a frame (X, R) to be
a function assigning each p; a subset of the Cartesian product X2 . Parallel to
0.4 above we have the following inductive definition:

V(~a) = X*—¥(a),

V(enB) = V(@) N V(p),

V(Ge) = {(x,»):Vx'(xRx' > (x', y) € V(@)},
V(Ha), similarly,

Vo) = {(x,):(»,») EV(e)}

isvalid in (X, R) if {(y,y):y € X} € V(o) for all 2-valuations V.

The two alternatives are related as follows: Given a 2-valuation ¥ in the
frame (X, R), for each y € X consider the valuation V', in the pointed frame
(X,R, ) given by V,(py) = {x:(x, ) € V(p;)}. Then we always have (y, y) €
V(a) iffy € Vy(a).

The second approach has the virtue of making it clear that though J is not
a temporal operator in the sense of the preceding section, it is in a sense that
can be made precise a two-dimensional tense operator. This suggests the
project of investigating two- and multi-dimensional operators generally. Some
such operators, for instance the ‘then’ of Vlach [1973], have a natural reading
in English. Among other items in our bibliography, Gabbay [1976] and
Gabbay and Guenthner [1982] contain much information on this topic.

Using J we can express (0)—(3) as follows:

o) P (seismologist says: F (earthquake occurs)),
(1')  P(seismologist says: J (earthquake occurs)),
(2')  P(seismologist says: JP (earthquake occurs)),
3" P (seismologist says: JF (earthquake occurs)).

The observant reader will have noted that (0')~(3') are not really represent-
able by G, H, J-formulas since they involve the notion of ‘saying’ or ‘predict-
ing’), a propositional attitude. Gabbay, too, gives many examples of uses of
‘now’ and related operators, and on inspection these, too, turn out to involve
propositional attitudes. That this is no accident is shown by the following
result of Kamp:

4.11. ELIMINABILITY THEOREM: For any G, H. J-formula « there is a
G, H-formula o* equivalent over all pointed frames.

Proof. Call a formula reduced if it contains no occurrence of aJ within the
scope of a G or an H. Our first step is to find for each formula & an equivalent
reduced formula ag. This is done by induction on the complexity of e, only
