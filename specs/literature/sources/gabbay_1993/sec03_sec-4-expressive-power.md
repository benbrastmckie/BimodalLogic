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