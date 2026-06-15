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
