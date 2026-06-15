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