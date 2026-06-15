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