<!-- Page 1 -->

TEMPORAL EXPRESSIVE COMPLETENESS
IN THE PRESENCE OF GAPS
D. M. GABBAY, I. M. HODKINSON, and M. A. REYNOLDS
1
Abstract
It is known that the temporal connectives until and since are ex-
pressively complete for Dedekind complete flows of time but that the
Stavi connectives are needed to achieve expressive completeness for
general linear time which may have "gaps" in it. We present a full
proof of this result.
We introduce some new unary connectives which, along with until
and since are expressively complete for general linear time. We ax-
iomatize the new connectives over general linear time, define a notion
of complexity on gaps and show that since and until are themselves
expressively complete for flows of time with only isolated gaps. We
also introduce new unary connectives which are less expressive than
the Stavi connectives but are, nevertheless, expressively complete for
flows of time whose gaps are of only certain restricted types. In this
connection we briefly discuss scattered flows of time.
§1. Introduction: the problem of expressive completeness.
This section will present the problem of expressive completeness of temporal
connectives within the more general model theoretic concept of the existence of
a finite G-basis for m-adic theories. The known results in this area will then be
outlined.
We begin with the ordinary propositional temporal logic. Assume we are given
a flow of time (T, <), where T is the set of moments of time and < is a transitive
and irreflexive relation on T, thought of as the earlier-later relation. We define
the notion of m-dimensional temporal logic on (T, <). An m-dimensional atomic
proposition q on (T, <) can be associated with a subset Q of Γ
m, representing
the set of all m-tuples of moments of time where q is true. The boolean logical
operations on temporal formulas, such as Λ, V, ~ and —» correspond naturally to
operations on these subsets. It is clear that a temporal assignment h to the atoms
associating with atoms ςrt subsets ft(</t) C Γ
m, gives rise to an ordinary model for
(T, <, <3, , =). To be able to express formally the connections between propositional
temporal formulas and subsets of Γ
m, we need to use the m-adic language with
(T, <, <2t, =), where ζ)t Q T
m are m-place predicates and = is equality.
lrΓhe work of M. Reynolds was supported by the U.K. Science and Engineering Research
Council under the MetateM project (GR/F/28526).


<!-- Page 2 -->

90 
D. GABBAY, I. HODKINSON, M. REYNOLDS
DEFINITION 1.1.
1. We define the temporal propositional language Z/[CΊ, . . . , Cn], with con-
nectives CΊ, . . . , Cn as follows:
(a) Any atom q is a wff.
(b) If A and B are wffs so are A Λ B, A V B, ~ A and A -» B.
(c) If Ct is noplace and Aλ, . . . , An. are wffs so is Ci(Al^ . . . , An.).
2. Let (T, <) be a flow of time. Let Π be a set ofm-place predicates. The
m-adic theory (T, <, Π, =) is defined as the language with (<, =, Qt €
Π) and wffs as follows:
(a) Q,(XI, . . . , £m),
 xi =
 xj
 and %i < Xj are wffs, for Xj variables and
αeΠ.
(b) Ifφ and φ are wffs so areφλψ, φVψ, ~φ, φ — > ψ, Vxφ and 3xφ.
3. The temporal language and the m-adic language can be connected in
the following manner.
(a) Enumerate the atomic propositions of L[C1? . . . , Cn] as ςfl5 g2>
and enumerate the m-adic predicates of Π as Qi,Qi,... and as-
sociate qi with Qt.
(b) Associate with the connective C(pι, . . . ,pn), where px, . . . ,pn are
propositional variables, a formula Φc(tiι 
. , tm, /\, . . . , Pn) with
m free variables ίl7 . . . , tm and n m-adic variables P1? . . . , Pn. ψc
is called a table for C.
(c) Any model (Γ, <, Π) of the m-adic language will now give rise to
an m-dimensional temporal model as follows. Let the assignment
h be
Extend ft to all wff by the equations:
h(A/\B] 
= 
h(A)Πh(B)
h(~A) 
= T
m-h(A)
h(C(Aϊy...,An)) 
= {(<,,... ,tm) I (Γ,<,Π)μ
for any connective C.
It is obvious from Definition 1.1 that any formula VK*ι> 
ιtmjQiι 
?Qn)
defines an n-place connective Cφ(ql^ . . . , qn) via the following truth table:
C^(ςfι,...,ί«) holds at ^,...,tm iff φ(tl9. . .,*m,Qι,. . . ,Qn) holds, where Qt =
{(^i, - - - , O I 9, holds at (sl7 . . . , sm)}.
In particular the connectives since (S) and unh7 (U) correspond to the
monadic tables:
<As(ί, Qι,Q3) = 3s


<!-- Page 3 -->

TEMPORAL EXPRESSIVE COMPLETENESS 
91
and
>u>t-> Q2(u))).
Clearly we can use the connectives S(p,q) and U(p,q) to build arbitrary
wffs A(ql,...,qn). 
It is easy to see that for each A, there exists a formula
V>Λ(*>Qι> 
>Φn) °f tne monadic language such that for all t and 
ft,...,9n,
Λ(ft> 
> 0n) hol
ds at * iff Vu(*, <2ι» - - - > Q») holds, where Q, = {5 | ςr, holds at *}.
The family of all ψA can be defined inductively as follows:
DEFINITION 1.2. Let Wi({V>s,^ι/}) be tie smallest set of well formed formulas
of the monadic language with one free variable satisfying the following conditions:
1. Q4(t) € Wl for Qi atomic.
2. Ifφ, ψ € Wl so are φ Λ ψ, ~φ, φ V φ and φ — » ψ.
3. Φu.ΦseW^
4. If ψ(t, Qi, . . . , Qn) € WΊ with t the free variable and Qt the monadic
letters in ψ and if Φi(t) G Wly for i = 1, . . . , n then ψ(t, φ^ . . . , 0n) is
also in Wl9 where ψ(t, ^i, . . , Ψn) is obtained from ψ(t, Qι,..., Qn) by
substituting simultaneously λtψ^t) for λtQ^t), i = 1, . . . , n.
DEFINITION 1.3. In general given formulas V>ι(*ι, - - , *m)> - - , Ψk(tι> - 
? *m)
with m free variables the set Wm({^ . . . , φk}) can be defined in the m-adic lan-
guage as follows:
• Qi(tι, 
, tm) € Wm for Qi atomic.
• Ifφ,ψ€ Wm so are φ Λ ψ, ~φ, φ V ψ and φ —> ψ.
• If V>(*!, . . , *m, Qi, . , Qn) € VΓm witi <!,..., tm exactly tie free vari-
ables of V> and Qi exactly the m-adic predicates in ψ and if ^t*(*ι> 
> ^m)
Wm, for ί = 1, . . . , n tien
j's also in W^, wiere ^(^i, - . - , <m> ^ι> 
> 0n) is obtained from ψ(tl9 . . . , t
Qi, - - , Qn)
 b7 substituting simultaneously λt1? . . . , tmφi(t^ . . . , tm) for
DEFINITION 1.4.
J. Tie problem of expressive completeness for a set of m-adic 
wffs
over a class /C of flows of time is the question of whether Wm({φij . . . ,
is essentially the set of all m-adic wffs over 1C: namely whether for any
ψ there exists φ 6 Wm such that 1C \= φ *-* φ.


<!-- Page 4 -->

92 
D. GABBAY, I. HODKINSON, M. REYNOLDS
2. The problem of finite Gm-basis for the m-adίc language over a class 1C
of Hows (T, <) is whether the m-adic language can be represented as
equal to a Wm({φι,..., φk}} for some finite set [φλ,..., φk}.
3. The problem of expressive completeness of since and until over a class
1C is whether {ΨuiΨs} f°τm a finite G^basis for all monadic wffs over
the class 1C of models (T, <, Π).
The problem of finite basis is a general model theoretic one. Let 1C be a class
of models in some language, e.g. it might be the class Q of all groups.
Let (Q, Qi, <32? ...,=) be the m-adic theory of Q where Qt are new additional
m-ary relational variables. Let φλ,..., φk be m-adic formulas with m free variables.
We can still define Wm({φl,... ,φk}) and ask whether Wm essentially equals the
set of all m-adic wffs over Q. We can thus ask whether the theory of groups admits
a finite Gm-basis for its m-adic theory.
H. Kamp in [K] has shown that since and until form a finite Gα-basis for the
monadic theory of Dedekind complete linear orderings. J. Stavi put forward two
additional connectives which are shown in Theorem 3 to be a finite Gj-basis for
general linear time. A first complete proof of this result is given in this paper.
Schlingloff [S] has produced a finite Gx-basis for binary trees. The current paper
studies finite bases for linear orderings with manageable gaps.
The problem of the existence of a finite Gm-basis for a class of models 1C is
related to the notion of Gabbay's /^-dimension.
DEFINITION 1.5.
1. A theory T is said to have a finite Hm-dimension < n over a ciass of
models 1C iff every wff φ(tl,..., tm, QlJ..., Qk) with at most m free
variables t± and arbitrary number k of m-adic predicates is equivalent
over 1C to a wff φ(tl^..., tm, Q 1 ?..., Qk) where ψ uses no more than n
distinct bound variable letters.
2. The minimal n satisfying '(a) above is called the Hm-dimension ofT.
THEOREM 1 [GHR].
t A class 1C of models has a finite Hm-dimension if it has a finite Gm -basis.
• Let the class 1C have Hm-dimension n, then it has a finite Gm+n-basis.
• There is a class 1C of models with HI -dimension 3 but with no finite
G i-basis.
Another notion of interest is that of weak m/m'-dimensional logic where
1 < m' < m. This notion arises from m dimensional logic where the atoms
Qi(tι,...,tm) depend only on the first m' places. For example for m
7 = 1 the
weak (m/1) m-dimensional temporal logic has the Q{ unary. In this case the
existence of a finite Grbasis implies the existence of a finite Gm/1-basis for any m.


<!-- Page 5 -->

TEMPORAL EXPRESSIVE COMPLETENESS 
93
Of special interest for applications are one or two dimensional temporal logics
over a linear flow of time. In intuitive terms we are evaluating formulas at points or
at intervals (or pairs of points). The problem of finding an expressively complete
set of connectives is of special importance. Such connectives are extensively studied
in [GHR]. We quote one theorem here of relevance.
DEFINITION 1.6. Let 1C be a class of linear flows of time.
1. A formula A of a one-dimensional temporal logic is said to be pure
future (past) iff its truth value at a point of any (T, h) for any T € 1C
and any i, depends only on the value of the atoms at the future (past)
of that point.
2. A set of one-dimensional connectives is said to have the separation
property over 1C iff every formula A can be rewritten equivalently (over
K) as a boolean combination of pure past, atomic and pure future
formulas.
THEOREM 2. A set of one-dimensional connectives {CΊ,..., Ck} has the sep-
aration property over 1C iff it forms a Gl -basis over 1C.
Separation can be combinatorially checked by trying actually to rewrite any
formula into a separated boolean combination. In the case of linear ordering the
presence of gaps seems to be of combinatorial importance. As atoms are true or
false over stretches of time, the first or last point of truth is very useful. If no
such point exists we have a gap. We therefore need to study temporal behaviour
around gaps. The case of Dedekind complete flows is simple. Since and until form
a Gj-basis.
If the flow allows for gaps then a lot depends on the kind of gaps allowed.
It is clear that in the general case new connectives are needed. It is not hard to
show, and indeed our Lemma 3 below shows, that U and S are then not adequate
to express some first-order connectives. However, as mentioned in [GPSS], Stavi
was able to introduce two new connectives U
1 and S
f so that the set {{/, 5, {/', S'}
is expressively complete over all linear time. We present what we believe is the
first full published proof of this result in Section 8.
For the sake of completeness, we consider the question of whether there are
intermediate connectives appropriate for structures in which the gaps are in certain
senses nice. In this paper we classify the gaps appearing in linear orders and are
then able to introduce new connectives to talk about the behaviour of atoms in the
neighbourhood of such gaps. Natural questions arise about the expressive power
of sets of these connectives and we are able to present a fairly comprehensive
(although by no means complete) range of answers.
The authors would like to thank Tony Hunter, Rob Hubbard and Robin Hirsch
for many useful discussions during the development of this work.
§2. Gaps in the flow of time.
We identify gaps in a flow of time with supremum-less non-empty proper
initial segments of the order and insert the gap in the appropriate place in the


<!-- Page 6 -->

94 
D. GABBAY, I. HODKINSON, M. REYNOLDS
order. Dedekind complete orders then are those without gaps. The completion T*
of an order T is another order consisting of T and all the gaps in the right places
and is Dedekind complete.
The simplest kind of gap imaginable is an isolated gap which exists in an
open interval of time which is otherwise gap-free. Taking one point out of the
reals or sticking two copies of the integers together are two straightforward ways
of producing an isolated gap.
We are going to define a hierarchy of kinds of gaps. For any (zero, successor
or limit) ordinal α, an αth order gap is a gap which is not of lesser order but lies
in an open interval which contains, apart from itself, only gaps of order less than
a. So a zero order gap is just an isolated gap.
Of course this hierarchy does not include all the gaps possible. For example,
nowhere in the rationals is there a gap of any order at all.
We will use the game characterisation of unranked gaps. Let 70 be a gap of
T. Players V and Ξ move alternately, defining a sequence 7,- (0 < i < ω) of gaps.
In each round, V chooses an open interval /j containing 7,-, and 5 chooses 7, +1 £ /t
with 7t+1 / 7^. 3 wins iff the game goes on for ω moves. 70 is unranked iff 3 has
a winning strategy for the game.
To see this one can employ a straightforward transfinite induction to show
that if 70 is ranked then V has a winning strategy. This simply involves continually
choosing open intervals around gap 7, which contain, apart from 7, itself, only gaps
of lesser ranks. Conversely it can be seen that if 70 is unranked then every open
interval containing it also contains other unranked gaps. 3 can win by always
choosing unranked gaps.
It is interesting to note that if all gaps in a flow of time have ordinal order
then the cardinality of the flow is at least as great as the cardinality of any of those
orders and for every infinite ordinal α, there exists a flow of time of cardinality
the same as a with a gap of order α. Let us prove the first of these statements.
DEFINITION 2.1. Let T be a linear order of cardinality K, and suppose that Γ
is a set of gaps ofT. A gap 7 ofT is said to be Γ-rich if every open interval I of
T containing 7 contains > /c+ gaps from Γ. Here, /c+ is the next largest cardinal
after K.
PROPOSITION 1. Let T be a linear order of cardinality K. Suppose that Γ is
a set of gaps of cardinality > /c+. Then there is a Γ-rich gap 7 G Γ.
PROOF. If not, for each 7 € Γ choose an open interval IΊ with endpoints
α7 < bΊ in Γ, such that 7 G IΊ and | IΊ Π Γ |< /c. As | Γ |> *, there is Γ' C Γ with
I Γ'|> « and 77 = / say, for all 7 6 Γ'. Then Γ' C /, a contradiction. 
D
COROLLARY 1. Let T be a linear order of cardinality K. Then T has at most
K ranked gaps.
PROOF. Assume not. Let Γ be a set of «;+ ranked gaps of T. We will show
that any Γ-rich gap is unranked; this will contradict the proposition.
Let 70 be an Γ-rich gap. V and 3 will play the game above, starting with
70. 3 will privately construct sets Γt(i < ω) of /c+ ranked gaps, so that each 7,- is


<!-- Page 7 -->

TEMPORAL EXPRESSIVE COMPLETENESS 
95
Γt-rich. She begins by defining Γ0 = Γ.
Inductively assume that i < ω, and 7, is a ΓΓrich gap. V chooses an interval
/, = (α, b) say, around 7,. 7t contains /c+ gaps from I\. Let Γi+1 be the gaps from
Γt contained in (0,7,) if this set has cardinality /c+; otherwise let Γi+l be the gaps
from Γt contained in (7,-, 6). So in any case, | Γ, +1 |= /c+. By the proposition, 5
can choose a Γ^-rich gap 7<+1 G I\+1. If she does this, the game goes on forever
and she wins. Hence 70 was unranked, as required. 
Π
COROLLARY 2. Let T be a linear order of cardinality K, and let 7 be a ranked
gap ofT. Then \rank (7)) < /c.
PROOF. Any gap 7 of rank α has gaps of rank β arbitrarily close, for all
β < α. So if Γ has a gap of rank α with |α| > AC, then T has more than K ranked
gaps. The result follows from the previous corollary now. 
D
§3. Connectives to talk about gaps.
Recall that U'(A, B) is as pictured:
S' is defined dually i.e., with past and future swapped. Despite involving a
gap, ί/' is in fact a first-order connective and its table is given by:
U'(p,q) =
3s 
t<s
Λ 
Vu 
( 
t < u < s ->
([ 
3υ(u < v Λ Vw(t <w<v—> q(w)) 
]
V 
[ 
Vυ(u < v < s -> p(v))
Λ 
3v(t < v < u Λ ^q(v)) 
]))
Λ 3u[t < u < s Λ ~*q(u)]
Λ 
3u[t <u<s/\ Vv(ί < v < u -> q(v))]
By presenting our new connectives below in terms of ί/, 5, U
1 and 5' we thus
guarantee that they are also first-order.
We start off with some new unary connectives which talk about a single gap
located by the vicissitudes of a single temporal formula. First we need to know
that there is a gap coming up.
7+(Λ) = 
ί/(-A,T)Λ U(A,A)
Λ- tf (-iΛ, A) Λ -t/(-t/(T, A), A)
This is true whenever A holds up until a gap but fails to hold arbitrarily soon
afterwards. We call such a gap an A left gap: A is true on the left of the gap.
Dually we can define 7- and A right gaps. Notice that 7* are expressible in
{U,S}.
Next we specify that the gap coming up is isolated, as far as gaps definable
by the same formula and in the same direction go.


<!-- Page 8 -->

96 
D. GABBAY, I. HODKINSON, M. REYNOLDS
Dually we can define 7,7. Notice that we use the Stavi connectives here.
Now we can recursively define a hierarchy of connectives. For every n > 0,
define
and
7<n and 7" are defined dually.
Notice that there is a distinction between gaps in the flow of time and gaps
definable by a particular temporal formula or even by any temporal formula. Thus
we need to define another hierarchy of gaps — this time within a temporal structure
rather than just in a flow of time. Let A be a temporal formula. For any ordinal
α, an αth order A left gap is an A left gap which is not of lesser order but begins
an interval containing only A left gaps of lesser order. Dually we can define A
right gaps of each order.
For a < ω, gap 7 is an αth order A left gap if and only if 7+ (A) holds in an
interval on the left of 7. We consider the possibility of 7+ (A) for a > ω later.
We have mentioned the distinction between αth order A gaps and αth order
gaps in the flow of time. Nevertheless, it is clear that there is only an A gap when
there is a gap in time at the right place and that it is an A gap of order α when
that gap in time is at least of order α or possibly of non-ordinal order.
Let us finish this section by demonstrating the existence of definable gaps
which do not fit into our scheme of classification. The idea is Robin Hirsch's.
We create a flow of time from a certain subset of the set Q* of finite sequences
of rational numbers. Let T consist of those non-empty sequences in which every
rational number but the last is a power of 1/2 and the last number in the se-
quence is neither a power of 1/2 nor zero. We order the sequences as follows:
(α0, α1? . . . , αm) < (60, 61? . . . , bn) iff there is some k > 0 such that k < n, k < m,
for all i < fc, αt = 6t and ak < bk.
We turn (T, <) into a {pj-structure by making T \= p(t) if and only if the
last number in the sequence t is negative.
Each p left gap in T occurs just after the segment (α
Λ(— l),α
Λ0) where α is a
sequence of powers of 1/2 (possibly the empty sequence).
It is easy to prove that none of these gaps is isolated. Let (α
Λ0,tf) be any
open interval after a gap. If t is not of the form α
Λ(/
Λ& for some possibly empty
sequence 6 and some rational q then we show that there is a left gap in (α
Λ0, α
Λl)
and note that α
Λl which is of that form must be less that t. So wlog t is α
Λg
Λ6.
Let r be any power of 1/2 less than q. Clearly all elements of T of the form α
Λr
Λs
are in the interval (α
A0, t) and so is the gap at α
Λr
Λ0.
Now a very straight forward transfinite induction proves that
LEMMA 1. For any formula A and any non-zero ordinal α, each αth order A
left gap is followed arbitrarily soon by zero order A left gaps.


<!-- Page 9 -->

TEMPORAL EXPRESSIVE COMPLETENESS 
97
So if a flow has no isolated p left gaps then it has no p left gaps of any order
at all and we have our result.
§4. Expressive power.
Before we state our new results we mention the theorem which makes our job
a lot easier.
THEOREM 3 [GPSS]. [U,S,U',S'} is expressively complete over all linear
time.
We will prove this in Section 8. From this theorem, our first result falls out
easily:
LEMMA 2. Over flows of time with only isolated gaps, {[/, S} is expressively
complete.
This is because, over such flows,
U'(A, B) = 7+(£) Λ t/(-£,Ί+(B) V A).
Kamp's pioneering theorem is then a special case of this lemma.
Our next lemma shows that gaps don't have to get much more complicated
before until and since are not sufficient.
LEMMA 3. In general linear time, {t/, S} is not expressively complete. There
are even Qows of time with a single non-isolated gap on which 7o~ is not expressible
in terms of {[/, S}.
PROOF. We take a flow of time (T, <) with a single non-isolated gap and
show that there is no temporal formula built from {ί/, 5}which is equivalent to
7o~(p) on a^ temporal structures over T.
T is constructed in two successive parts: the first one is got by taking a copy
of Z for each negative integer and joining them into one long line and the second
has a copy of Z for each integer arranged in order. There is a gap at the beginning
of the whole order and a gap at the end of each copy of Z. The only non-isolated
gap is that between the two parts.
A p-structure over T will be called nice iff
• on each little copy of the integers, either p is always true or always false
and
• every point has both p and -«p true in both its past and future.
An easy induction with several cases shows that for any formula φ constructed
from p in the language {t/,5}, there is a formula p, -ip, T or _L which is uniformly
equivalent to φ everywhere in all nice structures over T. It is easy to show, though,
that these four formulae are all distinct in their truth conditions. For example,
ί/(p,p) is always equivalent to p.
So suppose, for contradiction, that we can express 7o~(p) in {ί/, S}. By the
above argument, we have a formula ψ always equivalent to it over nice structures.


<!-- Page 10 -->

98 
D. GABBAY, I. HODKINSON, M. REYNOLDS
Look now at a particular nice p-structure in which p alternates in truth on
copies of Z but is true in the last copy of the first part. Here 7o"(p) is false. Thus
ψ must be either -»p or J_.
Look next at a structure in which p alternates in the first part, is true in the
last copy of Z there, is false for an initial segment of the second part and then
alternates again. Here 7o~(p) is true in the end of the first part. Thus ψ must be
either p or T and we have our contradiction. 
D
A similar proof to the above readily shows that
LEMMA 4. if for all i, m < nt then 7* is not expressible over all linear flows
by any formula built from U,S and any (finite) number 0/7*.
It is a bit harder to prove that any 7* can be expressed in terms of 7* (in
combination with U and S) for any n < m.
LEMMA 5. For any temporal formula P and any n > 0,
The dual result also holds.
PROOF. This is immediate from the more informative lemma which follows
the next:
LEMMA 6. Let n > 0 and P be any temporal formula. We write Q for
and consider the left P gaps in a structure.
• Every left Q gap is a left P gap.
• No order n left P gap is a left Q gap.
• All the other left P gaps are left Q gaps.
The dual result also holds.
PROOF.
• To prove the first claim let us examine a left Q gap α say. Q is true in an
interval, containing a point t say, on the left of α and false arbitrarily
soon after. P, as a conjunct of Q, is thus true from t until α. If
P is false arbitrarily soon after α then we have a left P gap at α as
required. Suppose for contradiction that P is instead true for a while
after α. Thus, like P , 7+(P) must stay true for a while after α. Finally
look at the third conjunct, ~»7+(.P), of Q. Since it is also true at t, β
can not be an order n left P gap and again the conjunct remains true
after α at least as far as β. We have shown that Q remains true before
and after α and we have our desired contradiction.
• The second observation is clear as 7+(P) is true arbitrarily recently
before an order n left P gap.


<!-- Page 11 -->

TEMPORAL EXPRESSIVE COMPLETENESS 
99
• For the third let us look at a non-nth order left P gap. For a while, on
the left, P 7+(P) and -«7+(P) are all true. Since P, and hence Q, is
false arbitrarily soon after the gap, we have a left Q gap.
Now we can actually be more specific about the orders of the gaps involved:
LEMMA 7. Let k and n be whole numbers and P be any temporal formula.
We write
Q = PΛ7
+(P)Λ-17+(P)
and consider the left P gaps in a structure.
Any order k left P gap is
• an order k left Q gap ifk<n
• not a left Q gap at all ifk = n and
• an order k - 1 left Q gap if k > n.
Any order k left Q gap is
• an order k left P gap if k < n and
• an order k + 1 left P gap if k > n.
The dual result with right substituted for left also holds.
PROOF. Fix n. Now we proceed by induction on k.
First part. Suppose that we have an order k left P gap at α. If k = n then
the previous lemma gives us our result. So suppose not. Thus α is a left Q gap.
We will show that a is an order K left Q gap where
k 
\ik<n
k-l if k > n.
Now for a while after α any left P gaps are of order less than k. Any left
Q gaps which are in this interval are then by the previous lemma, left P gaps and
so of order less than k as left P gaps. If k < n then these gaps are by the inductive
hypothesis, left Q gaps of the same order less than k = K. If k > n then these
gaps are, also by the inductive hypothesis, left Q gaps of order one less than their
order as P gaps which is less than K = k — 1. In either case, for a while after a
all left Q gaps are of order less than K.
If K = 0 then we have shown than a is an isolated left Q gap.
Otherwise, since a is an order k left P gap it must have order fc — 1 left P gaps
arbitrarily soon afterwards. There are three cases:
t if k < n then by the inductive hypothesis these are order K -1 = k -1
left Q gaps;
• if k > n + I then these are order k - 2 = K - 1 left Q gaps and
•{


<!-- Page 12 -->

100 
D. GABBAY, I. HODKINSON, M. REYNOLDS
i f f c = n - f l > l then the order k - 1 = n > 0 left P gaps are also
followed arbitrarily closely by order k - 2 left P gaps which are by the
inductive hypothesis also order k — 2 = K — 1 left Q gaps.
• i f f c = n + l = l then K = k — 1 = 0 which we have supposed to not
be the case.
This proves that a is a left Q gap of order K.
Second part. Suppose that α is an order k left Q gap. It is also a left P gap.
We will show that it is also an order K left P gap where
k 
if k < n
k + l if k > n.
For a while after α all left Q gaps are of orders less than k. By our inductive
hypothesis they will also be left P gaps of various finite orders. Thus a must be a
finite order left P gap say of order /. We know that / is not n for then α wouldn't
be a left Q gap at all.
By part one, if / < n then k = I so K = k = I as required.
If / > n then k = l-l>nsoK = k + l = las required. 
D
Now what if we can use 7*? Let us consider the new set of connectives
{ί/, 5,70 } and ask about its expressive power. In fact, the connectives which
talk of higher order gaps are redundant. In expressive power, the 7* hierarchy
collapses: for each n > 0,
•{
Λ 
7o(7
+(p)Λ-7
Λ ί/(7|n(p),P V t/(7|n(p), -V(P) V 7|n(p)))
Thus one might think that higher order gaps hold no surprises for {ί/, 5, 7*} .
In fact we do not even need to stop at finite orders.
LEMMA 8. {ί/, 5, 7*} is expressively complete over general linear time.
PROOF. We will exhibit a {ί/, 5,7*} formula which is equivalent to U'(p,q)
in any {p, ς^-structure. Because the dual formula will be equivalent to 5'(p, #), we
will have shown that {ί/, 5,7^} is expressively complete over such structures.
Let φ be:
V 
7+(9)
Λ ί/H7,7
+H/
Λ -t/(-ς,-ί/(-9,p))
Λ 7o
+(-tΉ,P))
Suppose that B is a {p, (/}-structure. We will show that for any b G J5,
B\=U'(p,q)(b)
«• 
B |= φ(b)
(<^) Let us assume that φ holds at 6. We must show that U'(p, q) is true at
b. There are two cases.


<!-- Page 13 -->

TEMPORAL EXPRESSIVE COMPLETENESS 
101
If the first disjunct holds then it is clear that U'(p, q) does too.
Now suppose that the second disjunct of φ holds at b but that the first does
not. The first conjunct guarantees that q is true from b up until a gap which we
can call β. ->q is true arbitrarily soon after β.
For contradiction we also suppose that U'(p, q) does not hold at 6. Thus p is
false arbitrarily soon after β. Since t/(~"
1<?,7~
l~(-
|i/(-
|<?,p)) Vp) holds at 6, we have
7+(-'ί/(-'<7,p)) true arbitrarily soon after β.
Since q is true up until β but p is false arbitrarily soon afterwards, we must
have ~'t/(~
l<7,p) holding from b at least up until β. But
-tfH,-tfH,p))
holds at b so U(-*q,p) must be true arbitrarily soon after β.
So -'{/(-'<?, p) is true up until β but false arbitrarily soon afterwards. Thus
7+(-ιf/(- (?,p)) holds at b and β is the -^U(-*q,p) left gap involved.
Knowing that both U(->q,p) and 7"
l"(~
|ί/(-^^,p)) are true arbitrarily soon after
β tells us that there are -*U(-*q,p) left gaps arbitrarily soon after β.
Thus β is not an isolated ~^U(-*q,p) left gap and this contradicts
7+(-ί/(-<Z,p))
holding at b. We are done.
(==>) Suppose that B (= U'(p,q)(b}. So q is true for a while after b up until
a gap, called β say. We must show that φ is true at 6. There are two cases.
If p is true for a while before β as well as after then it is clear that the first
disjunct of φ holds at 6.
So let us assume that that p is false arbitrarily soon before β.
In this case it is not hard to see that the second disjunct of φ holds at 6.
To see that those conjuncts involving ~~*U(-*q,p) hold one need only notice that
-*U(-^q,p) holds from b up until β and is false for a while afterwards. It is false
after the gap, i.e., U(-*q,p) holds, because p is true for a while and -»ςι is true
arbitrarily soon after β. 
D
§5. Other connectives.
The connective
p+(q) = I7'Hr, q)
and its dual p" could equally well have been used in this paper instead of 7*. We
can define
so that the set {17, S,p*} is expressively complete.
Ung(p,q) iff q holds until a gap after which it is arbitrarily soon false and
after which there are no left p gaps for a while. Dually we define Sng. Note that
7o"(p)
 ecl
ual
s Ung(p,p). Thus {U,S,Ung,Sng} is expressively complete.
We say that a p left gap is pure if it is not itself an isolated p left gap but
there are no isolated p gaps for a while after the gap. Lemma 1 above shows that
pure gaps have non-ordinal order. The non-ordinal order gaps constructed in the


<!-- Page 14 -->

102 
D. GABBAY, I. HODKINSON, M. REYNOLDS
example above are pure. We can define a new connective using purity: π+(q) holds
iff 7+(<?) Λ U(^q, -VΪ(q)) does.
An argument similar to the proof of Lemma 2 shows that π+ is not expressible
in terms of U and S. We compare the truth of ττ+(]9) before gaps in two different
structures. In one p is true up until a gap after which p is false for a while. In
the other p is true up until a gap after which open intervals of p being true, and
open intervals of p being false replace rational numbers in an interval from that
ordering.
The proof of Lemma 2 can also be employed to show that 70" can not be
expressed in terms of [7,5 or π
±. Clearly ^(p) is always false in the structures
defined there.
§6. An axiomatisation of [7,5,7* using the irreflexivity rule.
We first axiomatise [7, 5 and 7* over arbitrary linear flows of time using the
irreflexivity rule of [Gl]. This rule allows simple axiomatisations of many temporal
connectives over irreflexive flows of time. We derive some simple consequences and
list some open questions. In the next section we will relate some of these questions
to the class of scattered flows of time.
In this section, unless otherwise stated a temporal formula will mean one writ-
ten with the connectives [7, 5,7o~ and 7^". We will use the standard abbreviations
F, P, H and G: Fp abbreviates UfaΎ) 
etc. Recall also that K+(q) abbrevi-
ates " ί7(T,-ιςf) and 7+(<j) abbreviates F-*q Λ U(q,q) Λ "
|ί7(-^ςf V K+(-*q),q)\ and
similarly for K~ and 7-.
We adopt as axioms the following:
1. All truth functional tautologies.
2. G(p -> q) -+ (Gp -* Gq)
3. q -» GPq, q -> HFq
4. FFq -* Fq [transitivity]
5. G(p Λ <7p -> ςr) V G(q /\Gq^>p)
H(p ΛHp-+q)V H(q t\Hq-*p) [linearity]
6. r Λ H-^r -+ [Ufa q) «-+ F(p Λ H (Pr -> q))}
r Λ ff-r -» [Sfa q) <-> P(p Λ G(F(r Λ Jϊ-.r) -> q))]
7. rMi-,r^ [Ί+(q) ~ (7+(ς) Λ F(^q Λ H(P(-*q Λ Pr) -* -
r Λ ff-ir ->
[7o"(ί) ^ (7-(ϊ) Λ P(^q Λ G(F(^q Λ F(r Λ fΓ-r)) ^ -
The rules of inference are:


<!-- Page 15 -->

TEMPORAL EXPRESSIVE COMPLETENESS 
103
modus ponens
substitution
generalisation: h A =ΦΊ~ GA Λ H A
irreflexivity: h r Λ H-*r — > A =^h Λ
(for all A and atoms r not occurring in Λ).
These axioms and rules are valid over irreflexive linear time.
DEFINITION 6.1. If A is a temporal formula, N a temporal structure, and t a
point of the now of time of N (for short, "t G N"), we write N N A(t) if A holds
at t in N.
Take any set Σ of temporal formulas. A model of Σ will be an irreflexive
linear temporal structure N such that for some t 6 ΛΓ, N N A(t) for all A £ Σ.
THEOREM 4. (Completeness.) Given any countable consistent set Σ of for-
mulas, there is a countable model NofΣ in which all instances of the axioms are
valid at every point.
PROOF (sketch; see e.g. [GH] for details). 
Using standard techniques we
can obtain a countable irreflexive linear temporal structure N whose points are
maximal consistent sets of temporal formulas. The irreflexivity rule allows us to
assume that for each t G N there is an atom r with r Λ H-*r € t. Further:
• there is t0 € N with Σ C t0.
• for all atoms q and all t € ΛΓ, N N q(ί) iff q € t.
• for each formula A there is an atom q such that A <-> q € t for alH € N.
• for all formulas A built using only F and P, and alH G ΛΓ, Λ G t iff
TV N
It now easily follows that for all t € N and all temporal formulas A,Nt A(t) iff
A € £. The proof is by induction on the structure of A using axioms 6 and 7.
Hence as Σ C £0, we have constructed a model of Σ. 
D
QUESTION. Is there an axiomatisation of [7,5 and 7^ without using the
irreflexivity rule? Burgess axiomatises U and S over arbitrary linear time in [B],
without using this rule.
Even if the answer is negative, we still obtain the following corollaries, whose
statements do not mention the irreflexivity rule.
COROLLARY 3. (Compactness.) Let Σ be a set of temporal formulas (of
[/, 5,7o" and 7^"). Suppose that every finite subset of Σ has a model. Then Σ has
a model.
PROOF. With the given axioms and unitary rules, no contradiction is deriv-
able from Σ. Hence by Theorem 4 Σ has a model as stated. 
D


<!-- Page 16 -->

104 
D. GABBAY, I. HODKINSON, M. REYNOLDS
COROLLARY 4.
1. The connective 7>u/(—), saying that there is a gap of rank at least ω
coming up on the right, is not definable by any first order formula.
2. Not both of the connectives 7+ (—) and 7+ ,. 
/(—)? saying that there
is coming up on the right a gap of rank ω, or (respectively) 
ordinal
rank, are first order definable.
PROOF.
1. Assume for contradiction that Ί>ω(q) has a first order table. Hence
by expressive completeness of {t/, S,7o",7<iΓ} (Lemma 8 above) there
is already a temporal formula equivalent to 7>u,(<?). So consider Σ =
{~*Ί>ω(<l) Λ 7>n(<7) : n <
 ω}- Every finite subset of Σ has a model, but
Σ does not. This contradicts the previous corollary.
2. We have 7^(9) = Ί+(q) Λ h7+rdinal(<7) V 7+(ς) V -t/Ήr+(ϊ),9)], so
the definability of both of 7+ and 7
+ j 
i would contradict (1). 
D
QUESTIONS.
1. Is 7+ definable? Note that 7+ is definable from 7^ by 7
+(^) = 7>u,(<?)Λ
U'&ΪMq).
2. Is 7
+ i 
i first order definable?
By Corollary 4(2), relevant to the definability of jω is the fact that the flows
of time in which there are essentially no unranked gaps are essentially exactly the
scattered flows: those that do not embed the rationals. They are our next topic.
§7. Unranked gaps and scattered flows of time.
We will observe that any temporal logic with first order connectives over
the class of all scattered flows of time is decidable. This gives a weak recursive
axiomatisation of the temporal structures with scattered flows of time, though a
strong axiomatisation is not possible.
Recall that a (/-definable gap (one where 7+(<7) holds on some interval to the
left) is of rank oo (
c unranked') if it is not of rank α for any ordinal α. An example
of such gaps was given in Section 3.1. They can also be exhibited by first defining
NΪ (i = 0,1) to be a structure with flow of time Q, on which q is always true
(i = 1) or always false (i = 0), and then replacing each i G Q by a copy of 7V0 or
NI in such a way that any interval of Q contains copies of both structures. Let Q
be the resulting temporal structure. Each i € Q that is given a copy of TVj yields
a pure unranked <?-gap in Q corresponding to the 'right hand end' of that copy.
Note that the flow of time of Q is isomorphic to Q.
We defined unranked gaps of a flow of time in Section 2. As an example, all
gaps in Q are unranked. Flow-of-time gaps may not be 'definable' by a temporal
formula (i.e., detectable by 7). However, note that an unranked definable gap is
also an unranked flow-of-time gap.


<!-- Page 17 -->

TEMPORAL EXPRESSIVE COMPLETENESS 
105
DEFINITION 7.1.
1. If I is a linear order and x, y e / we will write [x,y] for the closed
interval of I with endpoints x,y. This extends the usual notation to
the case where x > y.
2. An equivalence relation = on a linear ordering I is called a condensation
if the —classes are convex (i.e., are intervals, but possibly one-point
intervals or with gaps for endpoints). Note that if = is a condensa-
tion, the ordering of I induces a canonical linear ordering of I/ = .
Strictly speaking, the condensation is this linear ordering, and not the
corresponding relation =.
3. Recall that I is said to be scattered if Q does not embed into I. See [Ro]
for general information on scattered orderings.
PROPOSITION 2 (cf. [D], Lemma 2.3). A linear ordering I is scattered 
iff
whenever = is a condensation of 7, // = is not dense.
PROOF.
=> If = is a dense condensation of /, we can use the axiom of choice to
choose a set of representatives of the = -classes. Some subset of this
will have order type Q.
Φ= If Q C 7 define = on / by x = y iff [x, y] Π Q is finite. Clearly // = is
dense.
THEOREM 5. Let I be a linear ordering.
1. Suppose that I is scattered. Then there are no unranked How-of-time
gaps in I.
2. Assume that I is countable and that no temporal structure M with
flow of time I has unranked definable gaps. Then I is scattered.
PROOF.
1. Clearly (*) any open interval of / containing an unranked gap contains
infinitely many unranked gaps. Suppose that 7 is an unranked gap of
7. We define a chain of finite sets Sn C I by induction on n so that for
all adjacent points i < j in Sn, the open interval ( i , j ) contains (a) an
unranked gap, and (b) a point of 5n+1.
Choose IQ < 7 < iι arbitrarily and let S0 = {i0,h} 
Let Sn =
{s0,...,θΛ} be given, satisfying (a) and with s0 < sl < ••• < sk.
By (*), for each i < k we can take st < t< < st +1 such that both (st,*t)
and (*t ,st +ι) contain unranked gaps. Define Sn+l = Sn U {*, : i < k}.
Clearly (b) holds now for 5n, and (a) holds for 5n+1.


<!-- Page 18 -->

106 
D. GABBAY, I. HODKINSON, M. REYNOLDS
Having defined the 5n, we observe that \Jn<ωSn has order type QΠ [0,1],
so that Q embeds into 7. Hence / is not scattered.
Note that in the case where / is already a temporal structure and 7 is
a (/-definable gap, the same argument shows that the extensions (truth
sets) in / of q and of -*q both embed Q.
2. The example / = R shows that the theorem can fail if the assumption
of countability is discarded. Assume that / is not scattered. Let = be
a condensation of / such that (// =) = QΠ [0,1] (use Proposition 2, the
countability of / and Cantor's theorem). Let Q* be obtained from the
structure Q made from NQ and NI as above, by adding left and right
endpoints at which q is false (say). Hence there is an order isomorphism
θ : I/ =—» Q*. Define / as a (/-structure M by: if m G /, M 1= q(rn) iff
Q* \= q(θ(m/ =)). Then each unranked (/-definable gap of Q* gives rise
to a similar gap in M. 
D
If the compactness theorem held for the scattered orderings, non-definability
of 7^ (even in the class of scattered orderings) would again follow. For the previous
argument using compactness would show that 7>u/ is not definable even over the
scattered orderings. But Ί$u(q) = 7+(ςr) Λ h7^rdmal(<?) Vi+fa) V -f/'(-7+(<ϊ), q)],
as above. 
In scattered orderings, because of Theorem 5 we have J>ω(q) =
Ίu(<l) V T'K""
1!*^))? s° that 7α,'s being definable would force j>ω to be definable,
a contradiction.
However, we now show that this is not the case.
PROPOSITION 3. The compactness theorem fails for the class of scattered
orderings.
PROOF. Introduce prepositional atoms ςf, (i G Q). Let Σ = {P((/t Λ #-•(/, Λ
Pqj) 
: j < i in Q}. Then any finite subset of Σ has a scattered model. But if
M were a scattered model of Σ, then Q would embed into M via i π-» mt where
rat G M satisfies M N (ςrt Λ /ί-•(/,• )(rat ). 
D
Now the rules of inference are finitary, so completeness implies compactness.
Hence, for the class of scattered orderings, there is no completeness theorem of
the form: Σ is consistent iff Σ has a scattered model. However, there is a weak
completeness theorem that deals with the case where Σ is finite. That is, there is
a recursive set of axioms such that h A iff N A for all temporal formulas A. This
follows trivially from the following decidability result.
PROPOSITION 4.
1. The monadic second order theory of the class of countable scattered
linear orders is decidable.
2. Over scattered flows of time, any temporal logic using connectives with
first order tables is decidable.


<!-- Page 19 -->

TEMPORAL EXPRESSIVE COMPLETENESS 
107
PROOF.
1. Let σ be a monadic second order sentence in the signature {=,<},
where quantification over elements and subsets is allowed. Let Q be
a new unary relation symbol and let σ® denote the relativisation of
σ to Q. (I.e., the first order quantifiers 3x,Vx are replaced by 3x €
<3,Vx e Q respectively, and the second order quantifiers 3X,VX by
3X C Q and VX C Q respectively. Later we give a formal definition of
relativisation in the first order case.) Let ξ(Q) be the formula
VΛ C Q([3xy(R(x) Λ R(y) Λ x < y)} ->
3xy(R(x) Λ R(y) Λ x < y Λ ^3z(x < z < y Λ R(z))).
So ξ(Q) says that the set of points where Q holds is a scattered or-
dering. Now any countable linear ordering embeds into (Q, <). So
Q 1= 3Q(ξ(Q) Λ σ^) iff σ has a countable scattered model.
It follows from the celebrated result of Rabin [R] that the monadic
second order theory of Q is decidable: cf. [BG, Theorem 2.6]. Hence
there is an algorithm to decide whether Q \= 3Q(ξ(Q) Λ σQ). 
This
completes the proof.
2. It follows from the downward Lόwenheim-Skolem theorem (see [CK])
that if A is a temporal formula with a first order table, then A has
a scattered model iff A has a countable scattered model. Let A use
atoms pl , . . . , pn and have table a(x, Pl , . . . , Pn), where the Pt are unary
relation symbols corresponding to the atoms. Then A has a scattered
model iff the monadic second order sentence
holds in some countable scattered linear order. By (1) there is an
algorithm to decide this question. 
D
REMARKS.
1. It follows trivially that given any set of connectives with first order
tables, there is a recursive axiomatisation of the class K of temporal
structures with scattered flow of time. We simply take as axioms { A : A
is valid in every structure in K}] this set is recursive by Proposition 4.
The only proof rule required is substitution.
2. In [GH] a finite (not merely recursive) axiomatisation of the temporal
logic with Until and Since over the real numbers R was given. In that
proof a certain condensation ~r (r < ω) was defined, and the irreflexiv-
ity rule used to show that every ~r-class was a closed interval of the flow
of time. (Reynolds [Re] has since eliminated the use of the IRR rule.)
The temporal translation B of -«3j/ < x(y ~r x) was then true exactly


<!-- Page 20 -->

108 
D. GABBAY, I. HODKINSON, M. REYNOLDS
at the left-hand endpoint of each ~-class, so a single axiom could be
used to specify properties of the condensation Mj ~r, uniformly in r.
In our case the relevant axiom would be $(B/\FB) -> θ(SΛί/(J3, -•£))
(cf. Proposition 2), but we have not found a formula true exactly once
in each ~Γ-class (our proof of Proposition 2 uses the axiom of choice).
So this method does not appear to be applicable in the scattered case.
3. 
[BG, Theorem 2.9] proves the decidability of the temporal logic with
Until and Since over the real numbers. Their argument is a variant of
the 'finite model property' approach to decidability, and goes back to
[LL] and [Ra]. Also see [D]. This technique can be used to give another
proof of our Proposition 4(2).
§8. Expressive completeness of [/, S &ε Stavi connectives over linear
time.
In this section we will prove Theorem 3. That is, we establish expressive com-
pleteness of ί/, S and the Stavi connectives for arbitrary linear flows of time. The
formal statement follows after some initial definitions. Our argument was sketched
in [GPSS] for the case of U and S over natural numbers time; the generalisation
to arbitrary linear time was indicated but not proved.
DEFINITION 8.1.
1. We fix an arbitrary finite set L of prepositional atoms. We will consider
first order formulas φ(x) in the 'monadic' language with =, < and a
unary relation symbol Q for every atom q G L. 
We also consider
temporal formulas. 
Unless otherwise stated, a temporal formula will
be one built from the atoms of L using the Boolean connectives and
the binary temporal connectives ί/, 5, U
1 and S' (standing for Until and
Since and the Stavi connectives).
2. A temporal (L-) structure is formally a triple N = (T, <,Λ), where
(Γ, <) is an irrefiexive poset (the flow of time of N) and h : L -> P(T)
is the assignment map. We will often abuse notation by identifying N
with its now of time T. Moreover, as every temporal formula A defines
a subset of a structure—the set of time points h(A) (cf. Definition
LI(3)) where A is true—we will regard A as an extra atom and use
it in monadic first order formulas as a monadic relation symbol. This
simplifies the notation a little. So for example, N *= Vxί/(Λ, B)(x) iff
U(A, B) is true at every point of N.
3. We will usually use Roman letters for temporal formulas and Greek for
classical first order ones.
In this setting, Theorem 3 becomes:
For all L-formulas φ(x) there is a temporal formula A such that if N is a
linear temporal structure (i.e., one with linear flow of time) in which the atoms of


<!-- Page 21 -->

TEMPORAL EXPRESSIVE COMPLETENESS 
109
φ have interpretations then for all t G TV, TV 1= φ(i) iff N 
\= A(t). Moreover, A is
effectively obtainable from φ (i.e., by an algorithm).
This says that the temporal logic with Until, Since and the Stavi connectives
is expressively (functionally) 
complete over linear time. Our proof here is based on
the sketch in [GPSS]; an alternative proof using separation (cf. Theorem 2, and
[G2]) will appear in [GHR]. The algorithm resulting from separation is probably
more efficient than ours.
We begin with some definitions.
DEFINITION 8.2. (Rank.) The rank of a temporal formula A is defined to be
the maximum depth of nesting of temporal connectives in A. Example: if p, q are
atoms then rank(p Λ q) = 0, and rank(->U(p,-ιS'(-*q,q))) = 2. Since L is finite,
it is easy to show by induction on r that for each r < ω there is a finite set of
temporal formulas of rank r such that every rank r formula is logically equivalent
to one of them.
DEFINITION 8.3. (Gaps.) We will use the definition of a gap in a linear order
discussed in Section 2. We need a few extra notions. Let M — (M, <,h) be any
linear temporal structure. If 7 is a gap and S C M, we say that 7 =sup(S) if
for all t G M, t > s for all s G S iff t > 7. We also say that 7 =inf(S) if for all
t G M, t < s for all s G S iff t < 7.
Let 7 be a gap and let D be a temporal formula. We say that 7 is definable
on the left by D if D is true at all points of M in some non-empty interval (t, 7) on
the left of 7, and not true throughout any non-empty interval (7,1*) on the right.
The definition of a gap's being definable (by D) on the right is made in a similar
way. 
If r < ω, an r-definable gap is one that is definable (on the left or right) by
a formula D of rank at most r. For r < ω we let Mr = M U {r—definable gaps
of M}, with the induced ordering <. So in general M C M0 C Ml C 
. For
example, if M has no last element then +00 is a gap of M definable on the left by
Ύ, so that oo G M0\M. The situation for —oo is similar.
We will refer to the elements of M as points.
DEFINITION 8.4. (Relativised connectives.) There is a natural way of eval-
uating temporal formulas of the form j)(A, B) for J G {?/, £, t/', S'} at gaps. For
example, U(A, B) holds at a gap 7 (i.e., 7 G Mn for some n) iff there is a point
t > 7 (so t G M) where A holds, with B holding at all points u G (7,^). To
formalise this we relativise our connectives to points.
Fix r < ω and let μ £ L be a new propositional atom. We define Mr as a
temporal L U {μ}—structure (MΓ, <, h') by:
h'(q) = h(q) C M for all q G L
h'(μ) = M.
We will relativise 17, 5, U
1 and S
1 to μ.
Let φ(x] be any first order formula in the signature consisting of =, < and a
unary relation symbol for each atom of L U {μ}. We define the relativisation φ
μ
of φ to μ by induction on φ :
if φ is quantifier free then φ
μ = φ',


<!-- Page 22 -->

110 
D. GABBAY, I. HODKINSON, M. REYNOLDS
(φ Λ φY = φ» Λ V>";
Λ φ»
We introduce connectives f/
μ, 5
μ, ί/
/μ and 5
/μ whose tables are the relativisa-
tions to μ of the tables off/, 5, ί/' and S
1 respectively. We can write formulas using
these connectives that are meaningful in any L U {μ} -structure. In particular we
can interpret them in Mr. If A is any formula ofUSU'S
1, we let A
μ be the formula
obtained by replacing each U in A by U
μ, and similarly for S, U' and S'.
REMARK.
1. Let α(x) be the canonical first order table of the temporal formula A,
as defined in Definition 1.2: in any temporal structure T, [t G T : T N
A(t)} = {t € T : T N a(t)}. Then it is easily seen that the table of A»
is just α
μ: i.e., for all t e Afr, Mr N A*(t) iff Mr N α"(<) (this holds for
any L U {μ}-structure).
2. If ί € M then M N Λ(<) iff Mr N Λ
μ(ί).
3. Let A = S'(B,C) where C has rank < r. If t € Mr and Mr N A^(ί),
then the gap that A asserts the existence of actually lies in Mr (as C
defines it on the right).
The Stavi connectives can express existence of gaps, but cannot talk directly
about what formulas are 'true' at them. So we need to transform properties of a
gap into properties of 'real' points. This is done in the following definition and
lemma.
DEFINITION 8.5. Let D be any temporal L-formula. 
We define a temporal
L-formula left(Λ, D) by induction on A:
t Jeft(p, D) = -L for atomic p
• Jeft(-.Λ, D) = ί/'(T, D) Λ -./e/*(Λ, D)
• left(A Λ β, D) = Jeftμ, D)Λ Ieft(β, D)
t left(U(A, B), D) = U'(B Λ l/(Λ, B), D)
• left(U'(A, fi), D) = U'(B Λ ί/'(Λ, β), D)
• left(S(A, B), D) = ί/(DΛBΛ5(A, β)Λt/'(T, B/\D)t\-*U'(D, B/\D), D)
, β), D) = U(D Λ β Λ 5'(Λ, β) Λ ί/'(T, β Λ D) Λ -ί/'(I>, β Λ
So ran^]eft(Λ, D)) < max(rA(Λ), rt(JD)) + 2. We define right(Λ, D) si
swapping each U with S and U
1 with S' in the definition above.


<!-- Page 23 -->

TEMPORAL EXPRESSIVE COMPLETENESS 
111
The point of this definition is given by the following lemma.
LEMMA 9. Let A,D be temporal formulas with D of rank at most r. Let
m € Mr. Then the following are equivalent:
2. There is 7 G Mr - (M U {±00}), 7 a gap of M defined by D to the left,
with (a) 7 > m,(b) D holds in M on (m,7), and (c) MΓ N A"(y).
PROOF. Clear. A corresponding result holds for right(A, D). 
D
DEFINITION 8.6. (Games.) We will need some results on Ehrenfeucht-Fraϊsse
games. Let Σ be any finite first order signature without function symbols. Let
M, N be Σ-structures. Ifn<ωwe define a game G
n(M, N) between two players,
V (male) and 3 (female). 
The game has n rounds. In each round, V chooses
an element from whichever of M, N he wishes. Then 3 responds by choosing an
element of the other structure. After n rounds, two n-tuples α, b of elements have
been chosen from M, N respectively; the order of the elements in each tuple is the
order in which they were chosen as the game was played. 3 wins this 'play' (α, 6)
of the game iff for all quantifier-free formulas φ(x) of Σ, M t= φ(α) iff N N φ(b).
This is slightly stronger than saying that the map α ι-» b is a partial isomorphism,
since Σ may have constant symbols.
A strategy for 3 in a game is a set of rules (not necessarily deterministic)
telling her what to do — this can be formalised as a family of functions. 
The
strategy is said to be winning if whenever she uses it she wins.
The following is a well-known result of Ehrenfeucht-Fraϊsse game theory.
PROPOSITION 5. Let Σ be any signature as above. Let Λί, N be Σ-structures
and let n < ω. The following are equivalent:
1. 3 has a winning strategy for G
n(M, N)
2. M N σ iff N N σ for all Σ-sentences σ of quantifier depth of nesting at
most n.
PROOF. See [E]. As is well known, (2) — » (1) can fail if Σ is assumed infinite
or to have function symbols. 
D
NOTATION. If x < y in Mr we write ( x , y ) for (t € M : x < t < y}, and if
n < r,(x,y)n for {t G Mn : x < t < y}. We write [x,y]n for {t € Mn : x < t < y},
etc. We do not require that x,y € Mn.
DEFINITION 8.7. (Special games on temporal structures.) We now introduce a
modified version of the game above. Let M and N be linear temporal structures.
The game Gn.r(M,xy,N,x'y') 
for n,r < ω,x < y in Λfr, and x
1 < y
1 in Nr, is
played as follows. There are only two rounds. V begins by choosing n elements
αl9 . . . , αn 6 [x, y]r; 3 responds with elements α'v . . . , α'n € [#', y']τ. Then V chooses
one more element b
1 € [x1, y
1] — so b1 must not be a gap — and 3 replies with b € [x, y].
3 wins iff:


<!-- Page 24 -->

112 
D. GABBAY, I. HODKINSON, M. REYNOLDS
1. the tuples xyάb and x'y'α'bf have the same order type; 
_
and iίt € xyάb and t' is the corresponding element of x'y'α'tt, then:
2. t is a gap of M iff t' is a gap of N
3. for each temporal L-formula A of rank at most r, Mr N A^(t) iff Nr N
LEMMA 10. Let M, N etc. be as above. Suppose that 3 has a winning strategy
σ for Gn;r(M, xy; TV, x'y'} for some n, r < ω. Let n
1 < ra, r
1 < r. Then σ gives in the
natural way a winning strategy for Gn/;r/(M,xy; TV, x'y
1) provided that x,y G Mr,
and x',y' G Nrι.
PROOF. Recall that K+X abbreviates the formula -»[/(T,--X), and K~X =
Suppose in a play of Gn/;r/(M, xy TV, x
7y'), V chooses α l 9...,α n/ G [x,y]r/.
Then Ξ defines αn/+1, . . . , αn to be x, say. So α1? . . . , αn G [x, y]r. She applies σ to
ά to obtain e G [x
7, y'\r.
We claim that each et G [x
7, y
7]r/. This is clear if r
1 = r, so assume that r' < r.
Take i\ certainly if αt G M then et G Λf. Otherwise αt is defined by some formula
-Ί> of rank < r
7. So letting D
1 = (tf+D Λ ^K~D) V (/^-β Λ ~^/ί
+Z)), a formula
of rank < r
1 + 1 < r, we have Mr N £
/μ(αt ). As σ is winning, Nr \= ^
/μ(et). Hence
et is also a gap defined by -»D; so et G Nrι.
If V now chooses α
; G [x
;, ?/'] then 3 simply uses σ to respond with e
7 G [x,y].
Then άe
1 and eα
7 satisfy the same order relations and rank r temporal formulas,
hence also the same temporal formulas of rank r
7. Hence 3 has won the play. 
D
We want to characterise the formulas associated with these games.
DEFINITION 8.8.
1. Let r < ω and t G Mr be given. Define Xt to be the conjunction
of all temporal L- formulas X of rank < r with Mr N X
μ(t). 
This
conjunction is effectively finite, as because L is finite there are up to
logical equivalence only finitely many distinct formulas of any rank.
Hence Xt can be taken to be a temporal formula of rank r.
Ift<u in Mr, define X(t,u) t° be Vv€(t,u)^v Again the disjunction is
effectively finite, so that X(t,u) can ^e taken to be a formula of rank r.
Note that only points (non-gaps) contribute to the disjunction.
2. (This definition is from [GPSS].) An n r-decomposition formula is a
first order formula of the form:
xl,x2 = y 1,...,y nx 1 < yl < - - - < yn < x2
where \ is a conjunction of formulas of the following kinds:
(a) θ(i), where t is an element of x αx 2y and θ is either μ,-»μ, or
for some temporal L-formula A of rank < r;


<!-- Page 25 -->

TEMPORAL EXPRESSIVE COMPLETENESS 
113
(b) μ(z) Λ a < z < b — > β
μ(z), where a < b are adjacent elements of
the sequence xlyl - 
- j/nx2>
 and B is a temporal formula of rank
<r.
LEMMA 11. Let M,N,x,y,x,' ,y' be as above. Let n,r < ω. Then the
following are equivalent:
L 3 has a winning strategy for Gn;r(M, xy\ TV, x'y
1}.
2. for all n; r- decomposition formulas φ(x1^x2)^Mr 
\= φ(x,y) 
=Φ> Nr 
1=
φ(χ',y'}.
PROOF. (1) =^ (2)— clear.
(2) =Φ> (1) Let V choose αl9 . . . ,αn G [x,y] in his first move. Assume without loss
that x < αx < 
< αn < y. Write α0 for x and αn+1 for y. Let V>(yo>ϊ/n+ι) =
3yi 
' 2/nbθ < 2/1 < ' ' < 2/n+l Λ V^(Λα,6M /*(&) Λ Λβ^Af ^(yf ) Λ Λ,<n+l Xαi (&) Λ
Λ, <n(μ(Ό f\yi < z < 2/t +! -> ^(βifoί+1)(^))]) 
τhen Φ is an n; r- decomposition
formula and Mr N ψ(x,y). Hence by assumption Nr N ^(x',2/')? and so there are
et 6 (x',y'} witnessing the Ξ's in φ. If Ξ chooses the et she can easily win the
game. 
D
The main step in our proof is
THEOREM 6* Suppose that Af, N are linear temporal structures. Then (*)n
holds for all n < ω :
(*)n For all r < ω, i f x < y in Mrx' < y' in Nr, and 3 has a winning strategy
for
Gl+3n;r+4n(M,Zy;7V,Zy),
then 3 has a winning strategy for Gn;r(7V, x'y
1] M,xy).
This says that if 3 possesses winning strategies for enough 'forward' games
G(M,xy\N,x'y'} 
then she has a winning strategy for a given 'backward' game
G(N,x'y']M,xy). 
The proof does not use compactness and is really a syntactic
result — we could equally prove that a certain class of formulas is closed under
negation up to equivalence, which is what is done (for the case of U and S over
N and without full proof) in [GPSS]. However, the game approach, though still
complicated, seems rather simpler to present.
Before we prove Theorem 6 we finish our result on expressive completeness.
PROPOSITION 6. Let M, N be linear temporal structures and let x e M,
y G N. Suppose n, r < ω and that x and y satisfy the same temporal formulas of
rank r + 4n + 1 in their respective structures. Then 3 has a winning strategy for
Gn.r(M, -ooz; TV, -ooy) and Gn.r(M, zoo; N, yoo).
PROOF. 
(Sketch.) Suppose for simplicity that V chooses n points x <
αλ < 
< αn in M in the future of x. 
Let α0 = x. 
Define Cn to be
Xαn Λ -,U(^X(αn^Ύ), and for i < n,C, to be Xαi Λ U(CWjX(αitUw)). 
So rank
(Cf) = r + n + 1 - i. Then M N C0(x), so that N N C0(y). 3 can use the form


<!-- Page 26 -->

114 
D. GABBAY, I. HODKINSON, M. REYNOLDS
of C0 to choose points y = e0 < el < 
< en in N such that N t Xai (e, ) and
N N ^(αi,αi+ι)W f°
Γ all (non-gaps) t € (et ,et +1). If V now chooses t € (et ,et +1)
then N N Xu(t) for some u G (αt ,αi+1). If 3 responds with such a u, she wins the
game. The argument for the 'past' game is similar. If some of the αt are gaps, the
idea is the same but the formulas C are more complicated and involve formulas
D defining the gaps, together with the formulas left(Xα., D) or right(Xαi, D) — cf.
the proof of Cases III, IV of Theorem 6. In all cases we have rank(C0) < r+4n + 1.
D
DEFINITION 8.9. Let f,g be any functions on ω satisfying /(O) = g(Q) =
0,/(n + !)>(! + 3/(n)).(2fcn) + 1, and g(n + 1) > g(n) + 4/(n), wiere kn is the
number of inequivalent (1 + 3/(n)); (g(n) + 4 /(n)) -decomposition formulas.
PROPOSITION 7. For all n < ω the following holds. 
Let M, N be linear
temporal structures and let xl < - - < xm,t/ι < 
< ym be increasing m-tuples
of elements of M, N respectively, for arbitrary m < ω. Define x0 = — oo and
= °° m M> Define yQ,ym+ι similarly.
Suppose that 3 has winning strategies for
and
for all 0 < i < m. Then 3 has a winning strategy for the 
Ehrenfeucht-Fraϊsse
gameG»((M,x),(N,y)).
PROOF. By induction on n. If n = 0 the result is trivial. Assume it true for
n, let r = g(n) + 4/(n) < g(n -f 1), and suppose that 3 has winning strategies for
the games G^^M.x^x^^N.y^y^) and Gn^^N.y^y^^M.x^x^).
Let V begin G
n+1 ((M, x), (ΛΓ, y)) by choosing without loss α € M. (If V chooses
in N the proof is the same as we have complete symmetry.) If α G {a?!, . . . , xm}
then 3 chooses the corresponding element of y, and the result then follows using
the induction hypothesis and Lemma 10. So let i < m be such that x± < α < j?ί+1.
List as <£>!, . . . , ψj the [1 + 3/(n)];r-decomposition formulas φ(u, v) such that Mr N
φ(xi, α), and as V>ι, 
, Ψk-> ^
ne [1 + 3/(n)];r-decomposition formulas ψ(u, v) with
Mr \=φ(α,xi+l).
Let 3 choose witnesses for the existential quantifiers of each φ, ψ, together with
α, making at most n
1 = (1 + 3f(n)).(j + k) + 1 < /(n + 1) elements of (xt, zt +ι)r in
all. She now applies her winning strategy for (7/(n+1);r(Λ/, ztzt +1; TV, ytj/1+1). Let e
be the point she chooses corresponding to α. Clearly (cf. Lemma 11) we have Nr N
V>s(yii
e) f°
Γ aH 5 ^ j an(i ^r ^ 0β(c,y«4.ι) for s < k. By Lemma 11, 3 has a win-
ning strategy for G1+3/(n);r(M, xt α; ty yt e) and for G1+3/(n);r(Af,axt>1;JV,eyi+1).
Crucially, by Theorem 6, she also has winning strategies for
and
eyt +1; M, αzt +1).


<!-- Page 27 -->

TEMPORAL EXPRESSIVE COMPLETENESS 
115
By the induction hypothesis, 3 has a winning strategy σ for
G«((M,xa),(N,ye)).
So in G
fn+1(Λf,x), (N,y)), 3 can choose e in response to V's choice of α and then
follow σ. This strategy wins the game for her. 
D
COROLLARY 5. Let M, N be linear temporal structures and letx€M,y€ 
N.
Suppose that x and y satisfy the same temporal formulas of rank g(n + 1) + 1 in
their respective structures. Then for ail monadic first order formulas φ (of L) of
quantifier depth < n, M £ φ(x) iff N t= φ(y).
PROOF. By Propositions 5, 6, 7. 
D
Expressive completeness now follows easily. For given φ(x) of quantifier depth
n, we may choose a finite L with atoms corresponding to the monadic predicates of
φ. Now take a finite set Φ of temporal formulas of rank 1 +g(n + 1) such that (1)
if A, B 6 Φ and A Λ B is consistent then A = B] (2) each temporal formula C of
rank l+g(n + l) is equivalent to a disjunction of formulas in Φ. Let Φ' = {B 6 Φ :
for some linear M and t e M, M N= B(t) and M N φ(i)}. Then by Corollary 5, φ
is equivalent over linear time to the rank 1 + g(n + l)-formula V Ψ'
Note that by a result of Gurevich [BG, 2.7(a)], the universal monadic second
order theory of linear order is decidable. Hence Φ' is computable by an algorithm,
so that the translation of first order formulas into temporal ones is effective.
PROOF (of Theorem 6). We must prove
(*)n For all r < u>, if x < y in Mrx' < y' in 7Vr, and Ξ has a winning strategy for
Gi+an r+^Wzy ^z'ΐ/'), then 3 has a winning strategy for Gn}r(N,x'y'',M,xy).
We prove (*)n by induction on n. For the case n = 0 (r is arbitrary) assume
that 3 has a winning strategy σ for G1;r(M, xy W, x'y') and that V chooses α €
(x,y) in the second round of G0;r(./V, x'y' M, xy) (as n = 0 the first round is
'empty'), α is not a gap. 3 simply applies σ to choose a response e 6 (x', y').
Clearly 3 has won.
Assume (*)n for n < ω\ we prove (*)n+ι Fix r < ω,x < y in Mτ and x' < y
1
in Nr. Assume that 3 has a winning strategy for
We will construct a winning strategy for 3 in Gn+1;r(J/V,x
/7/
/;M,xt/).
Suppose V chooses n + 1 points x
f < α0 < 
< αn < y
1 in Nr (we may
assume that they are all distinct, for otherwise the result follows by the inductive
hypothesis and Lemma 10). Define the following rank r temporal formulas:
where if n = 0 we take αn^ in A to be x
1. Clearly in ΛΓ, A holds on (αn_l7 αn) and
CΌn(αn,t/') Let
• c = inf {t e [x, y} : M N C(u) for all u € (t, y)}.


<!-- Page 28 -->

116
D. GABBAY, I. HODKINSON, M. REYNOLDS
If c ^ M then either c = x G Mr already, or c is a gap definable on the right
by C. Hence c € Mr. Define c G Nr similarly.
α0
"n-l
Claim 1.
Consider a play of the game Gm;r,(M,z2/; ΛΓ, x'y') for arbitrary r' > r,ra > 1 in
which 3 uses a winning strategy. Let V begin by choosing c plus m - 1 other points,
and let 3's response to c be d (plus m — 1 other points). Then d = d.
Proof of Claim.
As the strategy is winning, any rank r' temporal formula satisfied by one of V's
choices must also be satisfied by the corresponding choice of 3. Now the rank r + 1
formula C
1 = ^C V K—*C satisfies Mr \= O(c). Hence also Nr N O(d), so d < d.
If d < d then V can choose d' 6 (cf, y'} with TV t= -*C(d'). 3 now has no winning
response, a contradiction. Hence a — d. This proves the claim.
Claim 2.
3 has a winning strategy for
Gi+3n;r+4(n+l)(Λ/, ZCJ N, x'd]
and for
Proof of Claim.
Let r
7 = r + 4(n + 1). Suppose that V chooses 1 +3n elements in the interval [x, c]r/.
By assumption 3 has a winning strategy σ for the game G4+3n;r/(Λί,xt/; N,x'y').
3 adds c to V's choices and applies σ (cf. Lemma 10). As the order of 3's element
choices from σ matches the order of V's, Claim 1 ensures that her responses to V's
choices all lie in [x',0
7],./. If V then chooses in [x',d] then again 3's strategy will
yield an answer in [x, c]. The strategy is clearly winning. To sum up, the restriction
of σ to games in which V always chooses in [x,c]Γ/ and then in [x
;, d\ can yield
a winning strategy for G
?
1+3n.r+4(n4.1)(M,α;c; ΛΓ, x'd}. Similarly for the intervals
[c, y], [d,y'\. This establishes the claim. We will use this argument repeatedly.
Hence by inductive hypothesis (*)n, 3 has winning strategies σ, r for the
backward games Gn.^^(N,x'd]M,xc) and Gn;r+4(JV,c
/y
/;M,q/).
Now clearly d < αn, so (x',d\ contains at most n points from {α0,. . .,αn}.
The proof will divide into cases, mainly according to whether αn is a point of JV,
a left- or a right-definable gap.


<!-- Page 29 -->

TEMPORAL EXPRESSIVE COMPLETENESS
117
Case I: α0 < d .
Then (d,y')τ also contains at most n points from {α0, . . .,αn}. So as 3 is
trying to win
she can use σ and r to choose points e0, . . . , en G Mr. She applies σ to those αt in
(x'jC
7),. and r to the rest using the method of Lemma 10; if an αt happens to be
d it can be dealt with by either strategy. If V then responds in [x, c) she uses σ,
and if in [c, y], r. If she does this then by Lemma 10 she will win the game.
Case II: All the points α0, . . . , an lie in (c
7, y'), and αn G TV is not a gap.
Recall that Ξ is trying to win Gn+1;r(-/V, x'y'; Af, xy) — i.e., to preserve all rank
r formulas. Define B = Xαn, and 6 = sup{£ € (x,y) : M N #(*)}. As before,
either b G Af, 6 = y or 6 is an r-definable gap, defined on the right by -•#, so that
b G Mr. Define 6' G 7Vr similarly. Then clearly b' > an.
N'
X
-π(7V K— C
C
B
o 
a ! 
••• 
(
A
2n-l 
α
B
C
i
n
v K-
-β
B
/ 
y'
As in Claim 1, in any play of G4+3n;r+4(n+1)(M,xy; N,x'y') in which 3 is
using her winning strategy and V chooses 6,c amongst other points, 3 will re-
spond with &', d amongst others. 
Hence again 3 has a winning strategy for
^i+sn r+^n+i)^^;^^')- ^o by the induction hypothesis (*)n she has a win-
ning strategy r for Gn]r+A(N, dlt\ Af, c6). She already has a winning strategy σ for
Gn;r+4(7V,xV;M,xc).'
Let her first use r in response to α0,..., αn_α. It delivers n points e0,..., en_x €
(c,6)r (cf. Lemma 10). Now clearly Nr \= U(B,Ay(an^l) 
: an is a witness to this.
(This holds even if αn-1 is a gap; if n = 0 we take α.jto be d and (see below)
e_ι to be c.) U(B,A) has rank r + 1, so as r preserves formulas up to rank
r + 4,Mr N £/(β,Λ)
μ(en_!). Hence there is z > en_ι in M with Af N β(s) and
M 1= A(i) for all ί G (en_1?z). But en_α < 6. Hence we can assume that z < b. 3
defines en to be such a z, completing her move. Clearly en and αn satisfy the same
temporal formulas of rank r, as they both satisfy B.
Suppose that V continues by choosing t G [z,y] 
Recall that by the game
rules, t is not a gap. If t < c then 3 uses σ to respond, and if c < t < tn_λ she uses
T. lite (en_1? cn) then M N A(ί) By definition of A there is *' G (αn_ι, αn) with
Af N ^t'(0 ^ can ^en cnoose any sucn f/ as h
er response. It follows that t and t
1
agree on all rank r temporal formulas, as required. If t = en then 3 responds with


<!-- Page 30 -->

118
D. GABBAY, I. HODKINSON, M. REYNOLDS
an. Finally, if y > t > en then certainly t > c, so M \= C(t). By definition of C
there is t
1 > an with M f= Xt'(t), and 3 can choose such a t' in response to t. If 3
follows these directions she will win.
The remaining cases are similar to Case II, which gave a response en to an
by letting B describe an and making U(B,A) true at en_a. But an will now be a
gap, so we must use the Stavi U'—and U'(B,A) does not say that B» is true at
the gap. So we use the formulas left(-,-) and right(-,-) instead.
Case HI: All the points α0,..., αn lie in (d, j/')r, and αn is a gap defined on the
left by some formula D of rank < r. Clearly αn is also defined by A Λ D, so we
can assume that D h A.
Write B for XΛn, and 6 for Af\ left(#, D). δ is a formula of rank < r + 2, and
Nr 1= U(δ, AY(an_l) (again we set αn_α to be d if n = 0). Define d',g' by:
• d' = sup{* 6 (z',y') : N μ ~-D(t)}
• g
1 = sup{* e (a:', d'} : N t δ(t)}.
_/
A
6 D
V
B
-^D
<•—
^
D
Λi 
ii
1
αn-l
Define €?,(/ similarly. Note that as before, all these points lie in Λfr+2>ΛΓr+2
Clearly, αn < d
1 and the fact that Nr 
f= ί/(<5, Λ)'
i(αn_1) is witnessed at a point
t' E N where δ holds, with t
1 < g
1.
Now if 3 uses a winning strategy for G
r
4+3n;r+4(n+1)(M,a:y;7V,x
/i/') and adds
c,<7 and d to V's choices, then as before, her strategy delivers inter alia d,g
f and
d' in response. So again, 3 has a winning strategy for G
f
1+3n;r+4(n+1)(M,C5f; N,dg')
for all m,r
;. By (*)n, 3 has a winning strategy for Gn;r+4(ΛΓ,cy;M,c0). Let her
use it to choose e0,..., en_\ in response to α0,..., an_lf Then as in Lemma 10,
eo? 
?
 en-ι € (c> #)r? and as rank r+4 formulas are preserved, Mr N {/(£, A^e^j).
As en_! < g we can choose ί < # in Af with M N= ί(^) and such that A holds at all
u£K-ι,*].
By definition of δ and Lemma 9, there is a gap en € (t,d)r defined by D on
the left, and such that A holds between t and en. Moreover, any rank r formula
holds at en iff it holds at αn, as they both satisfy B. 3 chooses en in response to
αn, so completing her move. The same argument as in Case I allows 3 to complete
the remainder of the game, winning it.


<!-- Page 31 -->

TEMPORAL EXPRESSIVE COMPLETENESS
119
Case IV: 
α0,... ,αn 6 (d,y'),an 6 Nr — N, and αn is not definable on the left
by any formula of rank < r.
It follows from the case assumption that A holds throughout some interval
containing αn. Choose D of rank < r defining αn on the right. Define B = Xan
and 6 = A Λ ~^D Λ U(ήght(B,D),A) 
(rank r + 3). Let d' = sup{t 6 (x',y') ":
N ϊήght(B,D)(t)}, and then g' = sup{* € (x',cP) : N N £(*)}. Define c?,0 € Mr+3
similarly.
A 
rt(B,D)
£/
μjμ^
/'
-4
^rt(B, D
f
Clearly there are an_λ < t
f < an < u' < y
1, with t',u' e N, N 
\= 6(t'),
N \= right^DXw'), and A holding on (t',u'} (if n = 0 we take αn_α to be d as
usual). Hence t
1 < g' and u
1 < d
1. As usual, if Ξ uses a winning strategy for
G
f4+3n;r-ι-4(n+ι)(^
:c2/5^
Γί
:r/2/
/) an(ί
 a(^ds c, g and d to V's choices she can derive a
winning strategy for Gλ^n.r^(n^(M,cg\N,dg'}. 
So by (*)n she has a winning
strategy for Gn^r+4(N,dg'',M,cg). 
Let her use it to respond to α0, ...,α n_ 1 with
e0> 
> en_!. So as ί/(ί, A) has rank < r + 4, Mr N [/(£, >l)
μ(en_1). We can choose
en_ι <t<g with t e M,M ϊ= ί(ί), and >1 holding on (en-1, t). Then we can choose
u 6 M with t <u < d,M Nright(J9, -D)(u) and such that A holds in (en_1? u).
By Lemma 9 there is a gap en G (£, w) defined by D and at which the same
relativised rank r formulas hold as at αn in 7Vr. (We have en > t because M N
-*D(t).) Then 3 adds en to her choices to complete the move. The remainder of
the game is as before.
This ends the proof of the theorem. 
D
REFERENCES
[B] J. P. BURGESS, Axioms for tense logic I: "Since" and "Until", Notre
Dame J. Formal Logic, vol. 23 no. 2 (1982), pp. 367-374.
[BG] J. P. BURGESS, Y. GUREVICH, The decision problem for linear tem-
poral logic, Notre Dame J. Formal Logic vol. 26 no. 2 (1985), pp.
115-128.
[CK] C. C. CHANG, H. J. KEISLER, Model Theory, North-Holland, Am-
sterdam, 3rd edn., 1990.


<!-- Page 32 -->

120 
D. GABBAY, I. HODKINSON, M. REYNOLDS
[D] KEES DOETS, Monadic U\-theories ofΐl\-properties, Notre Dame J.
Formal Logic, vol. 30 no. 2 (1989), pp. 224-240.
[E] A. EHRENFEUCHT, An application of games to the completeness prob-
lem for formalized theories, Fund. Math., vol. 49 (1961), pp. 128-141.
[Gl] D. M. GABBAY, An irreflexivity lemma, in Aspects of Philosophical
Logic, ed. U. Monnich, Reidel, Dordrecht, 1981, pp. 67-89.
[G2] D. M. GABBAY, The declarative past and imperative future, in proceed-
ings, Colloquium on Temporal Logic and Specification, Manch-
ester, April 1987, ed. B. Banieqbal et. al., Lecture Notes in Computer
Science 398, Springer-Verlag.
[GHR] D. M. GABBAY, I. M. HODKINSON, M. A. REYNOLDS, Tempo-
ral Logic: Mathematical Foundations and Computational As-
pects, Volume 1, Oxford University Press, 1993.
[GH] D. M. GABBAY, I. M. HODKINSON, An axiomatisation of the temporal
logic with Until and Since over the real numbers, J. Logic Computat.,
vol. 1 no. 2 (1990), pp. 229-259.
[GPSS] D. M. GABBAY, A. PNUELI, S. SHELAH, J. STAVI, On the tempo-
ral analysis of fairness, 7th ACM Symposium on Principles of
Programming Languages, Las Vegas, 1980, pp. 163-173.
[K] J. A. W. KAMP, Tense logic and the theory of linear order, Ph.D.
dissertation, University of California, Los Angeles, 1968.
[LL] H. LAUCHLI, J. LEONARD, On the elementary theory of linear order,
Fund. Math., vol. 59 (1966), pp. 109-116.
[R] M. O. RABIN, Decidability of second order theories and automata on
infinite trees, Trans. Amer. Math. Soc., vol. 141 (1969), pp. 1-35.
[Ra] 
FRANK P. RAMSEY, On a problem of formal logic, Proc. London
Math. Soc., vol. 30 (1930), pp. 264-286.
[Re] MARK A. REYNOLDS, An axiomatization for Until and Since over the
reals without the IRR rule, Studia logica, vol. 51 (1992), pp. 165-193.
[Ro] JOSEPH G. ROSENSTEIN, Linear Orderings, Academic Press, New
York, 1982.


<!-- Page 33 -->

TEMPORAL EXPRESSIVE COMPLETENESS 
121
[S] B.-H. SCHLINGLOFF, Expressive completeness of temporal logic over
trees, J. Applied Non-Classical Logics, vol. 2 (1992), pp. 157-180.
Department of Computing
Imperial College
London SW7 2BZ
United Kingdom
