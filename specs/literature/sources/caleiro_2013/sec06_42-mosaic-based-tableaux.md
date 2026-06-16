### 4.2. Mosaic-Based Tableaux

It is relatively simple to extract quite appealing semantic tableau systems for
our logics directly from the mosaics definition. The syntactical elements of our
tableaux systems are partial 6-tuples properly labelled with sets of formulas,
plus the particle closed that will stand for an absurd. Rigorously, a partial
6-tuple is simply a partial function Θ : {ul, ur, ml, mr, dl, dr} ̸→2F. The
letters d, m, u and l, r used in naming the elements of the domain of Θ, the
positions, stand for down, middle, up, and left, right, respectively. We will often
depict these partial tuples graphically as shown in Fig. 2, omitting the unde-
fined entries from the graphical representation, and assuming that, whenever
defined, Θ(p) = Θp for p ∈{ul, ur, ml, mr, dl, dr}. In Fig. 2, we also depict
the general form of the (linear only) 3-tuples used in [14], as well as of the
tuples with the upper-right and down-left entries undefined (for illustration
purposes).

*Figure 2. Sample graphical representations of partial tuples*

*Figure 3. General shape of tableau rules*

The semantics is simple. A structure M = (W, ≺, ≃, V) is said to satisfy
a tuple Θ : {ul, ur, ml, mr, dl, dr} ̸→2F, in which case Θ is said to be satis-
fiable, if there exists a function ω : {ul, ur, ml, mr, dl, dr} ̸→W such that the
following conditions hold:
• for every p ∈{ul, ur, ml, mr, dl, dr},
–
ω(p) is defined iffΘ(p) is defined;
–
if ω(p) is defined then M, ω(p) |= Θp;
• for every h ∈{l, r},
–
if Θ(dh) and Θ(mh) are both defined then ω(dh) ≺ω(mh),
–
if Θ(dh) and Θ(uh) are both defined then ω(dh) ≺ω(uh),
–
if Θ(mh) and Θ(uh) are both defined then ω(mh) ≺ω(uh);
• for every v ∈{d, m, u},
–
if Θ(vl) and Θ(vr) are both defined then ω(vl) ≃ω(vr).
We also define the particle closed to be unsatisfiable.
This explains well why we will work, in the general case, with such tuples:
3 vertically related points by 2 horizontally related points are what we need to
be able to express all the mosaic conditions of the previous section (namely, the
most complex one, that is strong diagram completion). Indeed, we can directly
produce tableau rules that correspond to the mosaic conditions, either unary
(αR), or binary (βR) leading to a bifurcation in the tableau, as shown in Fig. 3.
The rules are given in Figs. 4, 5, 6, 7 and 8. Dots represent context around
the highlighted entries of the tuples that is meant to be preserved by the rules,
but which can always be erased (neglected) using the deletion rule DelR in
Fig. 4. In fact, the dots in the rule DelR represent the fact that any entry in a
partial tuple can be deleted. Similarly, for instance, the dots in CutR represent
the fact that we can apply a cut in any entry of a partial tuple, while there

*Figure 4. Propositional and simplification rules*

are rules, such as ∀R2(left) in Fig. 5 or ¬GR in Fig. 7, where the dots specify
that only some of the context is meant to be preserved.
Figure 4 also presents the basic propositional rules stemming (almost)
immediately6 from the definition of point in a mosaic structure, Definition 3.2,
including in particular the unrestricted cut rule CutR and the closure rule
ClsR.
6 The immediate counterparts of condition (L2) in Definition 3.2 are obviously the rule ∧R
and a form of ∧-introduction that could be expressed by a rule such as the one depicted
below.
...
...
...
. . .
Γ, A, B
. . .
...
...
...
...
...
...
. . .
Γ, A, B, A ∧B
. . .
...
...
...
However, in the presence of CutR, it is not difficult to see that this rule turns out to be
equivalent to the much more usual rule ¬∧R, that we include.

*Figure 5. General coherence-based rules*

Notice that a common rule for ¬¬-elimination such as
...
...
...
. . .
Γ, ¬¬A
. . .
...
...
...
¬¬R
...
...
...
. . .
Γ, ¬¬A, A
. . .
...
...
...
is not listed, since it is redundant given the (powerful) presence of CutR.
In Fig. 5, we have the rules corresponding to the coherence conditions
on mosaics, both for what concerns the vertical and the horizontal compo-
nents. In Fig. 6, we find “special” coherence-based rules, namely AtmR rules
capturing the atomic harmony assumption, rules NfstR and NlstR expressing
unboundedness towards the past and towards the future, respectively, and rules
Mb−R corresponding to the property of the maximality of branches. Rules
corresponding to the saturation properties are presented in Fig. 7, where we

*Figure 6. Special coherence-based rules*

*Figure 7. General saturation-based rules*

*Figure 8. Special saturation-based rules*

have rules that mimic the curing of defects of Sect. 3.2, and in Fig. 8, where the
special conditions on boundedness, discreteness and density of linear flows are
captured together with rules that allow for representing the properties Wdc
and Sdc.
We can now define a hierarchy of tableau systems R(C, D) for each of our
logics L(C, D) (but with Udsc, Ddsc not in C), by including:
•
the propositional and simplification rules
DelR, CutR, ClsR, ∧R, ¬∧R,
the linear-time rules7
GR, HR, ¬GR, ¬HR, ¬GR2, ¬HR2,
the branching rules
∀R, ∀R2(left), ∀R2(right), ¬∀R;
•
rules for particular linear flows
CR, for each condition C considered;
•
additional rules for particular target branching classes
–
D=(Wdc)
WdcR;
–
D=(Wdc+Sdc)
WdcR, SdcR;
–
D=(Wdc+Sdc+Mb−)
WdcR, SdcR, Mb−R(left), Mb−R(right).
In the case we assume atomic harmony, the system will also contain the
rules AtmR(left) and AtmR(right).
As usual, in any of these tableau systems, a tableau is a (possibly infi-
nite) tree built from a given root by application of the tableau rules. A tableau
7 Collecting just the propositional and simplification rules, plus the linear-time rules, we get
a tableau system that is essentially the same as the one described in [14].

*Figure 9. A closed tableau for the negation of WdcA*

whose root is a tuple Θ will be dubbed a tableau for Θ. We say that a tab-
leau is closed if all its branches end with the particle closed. Otherwise, the
tableau, as well as the corresponding branch, are said to be open. Further, a
tableau is said to be exhausted if it is open but no further rules can be applied
to its open branches.
In Fig. 9, as an example, we show a closed tableau for the negation of
the axiom WdcA.
The following is a straightforward technical result which will be useful
later on.

**Lemma 4.7.** If there is a closed tableau for a given tuple Θ, then:
(i) there exists a tuple Θ0 for which the exact same tree is also a closed tab-
leau, such that Θ0 is defined at exactly the same positions as Θ and, at
each defined position p, Θ0
p ⊆fin Θp;
(ii) the exact same tree is also a closed tableau for any tuple Θ+ defined at all
the positions where Θ is defined and such that, at each defined position
p, Θp ⊆Θ+
p .

*Proof.* For (i), observe that in each rule of the system the number of “rele-
vant” formulas (i.e., those necessary in order to make the rule applicable) in
the premises is finite. The thesis follows by noticing that the number of rules
applied in a closed tableau is finite. As for (ii), just observe that all the rules
applied in the closed tableau for Θ can still be applied if we have as a root a
tuple Θ+ such that all its positions extend those of Θ.
$\square$

An R(C, D)-tableau is a tableau built by using only rules in R(C, D).
Given a set Γ ⊆F, we say that it is R(C, D)-consistent if there is no closed
R(C, D)-tableau for
Γ . The set Γ is further said to be maximally R(C, D)-
consistent if either A ∈Γ or ¬A ∈Γ for every A ∈F. If Γ is not R(C, D)-con-
sistent, it will be called R(C, D)-inconsistent.

**Theorem 4.8.** For each class C of linear orders such that Udsc and Ddsc are
not in C and each target branching class D, the tableaux system R(C, D) for
the logic L(C, D) is sound.
In order to show soundness (that is, if a set Γ of formulas is inconsistent
then it is not satisfiable by a C-D-structure) it suffices to check, for each tab-
leau rule, that if its numerator is satisfiable then so must be at least one of
the denominators. Also this proof is routine and we thus omit it.

**Theorem 4.9.** For each class C of linear orders such that Udsc and Ddsc are
not in C and each target branching class D, the tableaux system R(C, D) for
the logic L(C, D) is complete.

*Proof.* For completeness, we must prove that if a set Γ of formulas is R(C, D)-
consistent then it is C-D-satisfiable. Taking advantage of mosaics, we will
show that there is a C-D-structure of mosaics for Γ. Concretely, we will define
a unique C-D-structure of mosaics that contains points corresponding to all
R(C, D)-consistent sets.
Let S = (SV , SH) be such that:
• SV contains precisely
– (Δ) for each maximally R(C, D)-consistent set Δ, and
– (Ω, Δ) for each pair of maximally R(C, D)-consistent sets Ω, Δ such that
there is no closed tableau for
Δ
Ω .
• SH contains
–
(Δ) for each maximally R(C, D)-consistent set Δ, and
–
(Ω, Δ) for each pair of maximally R(C, D)-consistent sets Ω, Δ such
that there is no closed tableau for
Ω
Δ .

As Γ is R(C, D)-consistent it can be extended to a maximally R(C, D)-consis-
tent set Γ′, e.g., by considering one of the open branches of a CutR exhausted
C-D-tableau for
Γ . Hence, Γ′ is a point of S. Therefore, all we need to show
is that S is indeed a C-D-structure of mosaics.
The proof will be modular with respect to local, vertical, horizontal and
compositional properties. Namely, one can notice that in what follows each
condition C will be proved to be satisfied by S by using only the rules present
in the systems R(C, D) for those classes C and D such that a C-D-structure of
mosaics is required to satisfy C.
The first part of the proof, concerning local and vertical conditions, fol-
lows from the one in [14]; we will omit most of the details.
Local conditions. First of all, it is easy to notice that any maximally R(C, D)-
consistent set is a point (on F). Condition L1 follows immediately from
maximal consistency. For condition L2, assume B ∧C ∈Γ and either B /∈Γ
or C /∈Γ; by using ∧R, one gets a closing situation, which contradicts the
consistency of Γ. The other direction of L2 is proved similarly by using ¬∧R
and ClsR; condition L3 follows from ∀R and ClsR.
Vertical coherence conditions. As in [14], by using GR, HR and ClsR, we have
that each (Ω, Δ) ∈SV is a vertical mosaic.
Horizontal coherence conditions. To prove that (Ω, Δ) ∈SH is a horizontal
mosaic, we must show that Ω and Δ are state-equivalent (property H1).
We proceed by induction. As a base case, we have that if ∀A ∈Ω and
∀A /∈Δ (or vice-versa, without loss of generality) then ¬∀A ∈Δ. But
by using ∀R2(left/right) we would get to a closing situation on ∀A, which
contradicts (Ω, Δ) ∈SH.
In case we assume atomic harmony, we have a further base case con-
cerning atomic propositions. If p ∈Ω and p /∈Δ (or vice-versa, without loss
of generality) then ¬p ∈Δ. But using AtmR2(left/right) we would get to
a closing situation, which again contradicts (Ω, Δ) ∈SH.
Then we have two step cases, for the boolean connectives ∧and ¬.
Assume that A and B are state-formulas. (i) If A ∧B ∈Ω and A ∧B /∈Δ
(or vice-versa, without loss of generality) then ¬(A ∧B) ∈Δ. Using ∧R
we conclude that A, B ∈Ω and by the induction hypothesis also A, B ∈Δ.
But using ¬∧R both branches would get to a closing situation, which con-
tradicts (Ω, Δ) ∈SH. (ii) If ¬A ∈Ω and ¬A /∈Δ (or vice-versa, without
loss of generality) then A ∈Δ. Using the induction hypothesis also A ∈Ω,
leading to a closing situation, which contradicts (Ω, Δ) ∈SH.
Vertical saturation conditions. Vertical saturation conditions SV1-SV4 can be
proved as in the linear case [14], by using ¬GR, ¬HR, ¬GR2 and ¬HR2,
respectively, plus cutR to get maximally consistent sets.
Conditions on particular linear flows. In the special cases when C includes the
properties Nlst, Lst, Nfst or Fst, we can prove that the maximally R(C, D)-
consistent sets are FU, FB, PU or PB-points, respectively, by using NlstR,
LstR, NfstR and FstR, respectively. We prove the claim for the prop-
erty Nlst. Let Γ be a maximally R(C, D)-consistent set, for C containing
Nlst, and assume for the sake of contradiction that it is not an FU-point,

i.e., that ¬G⊥/∈Γ, which implies G⊥∈Γ. By applying the rule NlstR, we
get a position containing both G⊥and ¬G⊥.
As further vertical saturation conditions, let us consider density (SV-
Dns). Let (Δ, Γ) ∈SV . Then, using DnsR, it is clear that there is also no
closed tableau for
Γ
Δ
. Hence we can use cutR to maximize and obtain a
maximally consistent set Ω such that
Γ
Ω
Δ
can also not be closed, which
guarantees, using DelR, that (Δ, Ω), (Ω, Γ) ∈SV .
Horizontal saturation conditions. We have to prove that S satisfies SH1. Let Δ
be maximally consistent and ¬∀¬A ∈Δ. Using ¬∀R and cutR to maximize
we get a maximally R(C, D)-consistent Ω such that A ∈Ω and (Δ, Ω) ∈SH.
SWdc. Let (Γ, Δ) ∈SH and (Ω, Γ) ∈SV . We first show that there is no
closed tableau for
Γ
Δ
Ω
. If this root could be closed, using Lemma 4.7
there would be finite subsets Δ0 ⊆Δ and Ω0 ⊆Ω such that also
Γ
Δ0
Ω0
could be closed. But (Γ, Δ) ∈SH and (Ω, Γ) ∈SV which implies that
P( Ω0), ∃( Δ0) ∈Γ. Therefore we could also build a closed tableau for
Γ by just using ¬HR, ¬∀R and ∧R, which contradicts the consistency of Γ.
Hence, there is no closed tableau for
Γ
Δ
Ω
. Therefore, we can use
WdcR and then cutR to maximize and obtain a maximally R(C, D)-consis-
tent set Φ such that
Γ
Δ
Ω
Φ can also not be closed, which guarantees, using
DelR, that (Ω, Φ) ∈SH and (Δ, Φ) ∈SV .
STrn. Let (Ω, Γ), (Γ, Δ) ∈SV . To prove that (Ω, Δ) ∈SV we just need to
check that there is no closed tableau for
Δ
Ω . If this root could be closed,
using Lemma 4.7 there would be finite subsets Δ0 ⊆Δ and Ω0 ⊆Ω such
that also
Δ0
Ω0
could be closed. But (Ω, Γ), (Γ, Δ) ∈SV which implies that
P( Ω0), F( Δ0) ∈Γ. Therefore we could also build a closed tableau for
Γ
by just using ¬HR, ¬GR, ∧R and DelR, which contradicts the consistency
of Γ.
SCon. Let (Δ, Γ), (Ω, Γ) ∈SV with Δ ̸= Ω. To prove that (Ω, Δ) ∈SV or
(Δ, Ω) ∈SV we just need to check that there cannot be closed tableaux for
both
Δ
Ω and
Ω
Δ . If that were the case, using Lemma 4.7 there would be
finite subsets Δ′
0, Δ′′
0 ⊆Δ and Ω′
0, Ω′′
0 ⊆Ω such that also
Δ′
0
Ω′
0
and
Ω′′
0
Δ′′
0
could be closed. Notice that Δ ̸= Ω and let B be some formula such that
B ∈Δ and B /∈Ω, i.e., ¬B ∈Ω. Let Δ0 = Δ′
0 ∪Δ′′
0 and Ω0 = Ω′
0 ∪Ω′′
0.
Since (Δ, Γ), (Ω, Γ) ∈SV , we have that P(B ∧( Δ0)), P(¬B ∧
( Ω0)) ∈Γ. Therefore we could also build a closed tableau for
Γ by using
¬HR, ∧R, ¬HR2, DelR, ClsR and CutR on P(¬B∧( Ω0)) and ¬B∧( Ω0)
(see Fig. 10)
SSdc. The construction is similar to that for SWdc. Let (Γ, Δ), (Φ, Ψ) ∈SH
and (Ω, Γ), (Φ, Ω) ∈SV . We first show that there is no closed tableau

*Figure 10. A tableau for the proof of the property SCon*

for
Γ
Δ
Ω
Φ
Ψ
. For the sake of contradiction, let us assume that this root
can be closed. Then, by using Lemma 4.7 there would be finite subsets
Γ0 ⊆Γ, Δ0 ⊆Δ, Φ0 ⊆Φ and Ψ0 ⊆Ψ such that also
Γ0
Δ0
Ω
Φ0
Ψ0
could
be closed. But (Γ, Δ), (Φ, Ψ) ∈SH and (Ω, Γ), (Φ, Ω) ∈SV imply that
F( Γ0 ∧∃ Δ0), P( Φ0 ∧∃ Ψ0) ∈Ω. Therefore we could also build a
closed tableau for
Ω by just using ¬HR, ¬GR, ¬∀R and ∧R, which con-
tradicts the consistency of Ω.
Hence, there is no closed tableau for
Γ
Δ
Ω
Φ
Ψ
. Therefore, we can use
SdcR and then cutR to maximize and obtain a maximally R(C, D)-consis-
tent set Ω′ such that
Γ
Δ
Ω
Ω′
Φ
Ψ
can also not be closed, which guarantees, using
DelR, that (Ω, Ω′) ∈SH and (Ψ, Ω′), (Ω′, Δ) ∈SV .
SMb−. Let Γ, Δ be distinct maximally R(C, D)-consistent sets such that G⊥∈
Γ (without loss of generality). We must show that (Γ, Δ) /∈SH. It suffices
to produce a closed tableau for
Γ
Δ . Notice that as Γ ̸= Δ, there exists
B such that B ∈Γ and B /∈Δ, i.e., ¬B ∈Δ. Thus, using Mb−R(left/right)
we get into a closing situation.
$\square$

Clearly, the unrestricted CutR rule is a problem with respect to imple-
mentations, also preventing us from obtaining tableau-based decision proce-
dures for the logics. However, in certain cases, namely when we consider the

target branching class D = (), it is possible to use only analytical instances of
the cut rule. Let Γ be a finite set of formulas. Given a tableau system R(C, D),
we can define its analytic restriction with respect to Γ as the system RΓ(C, D)
obtained from R(C, D) by replacing CutR with a version of the rule that can
only introduce a formula A ∈Λ, where Λ is the smallest (C, D)-closed set of
formulas containing Γ. Note that in this analytic restriction, discreteness could
be also considered, e.g., by including in the system the following two rules:
. . .
Δ, GA, A
. . .
. . .
Γ, ¬GA
. . .
UdscR
. . .
Δ, GA, A
. . .
¬A, GA
. . .
Γ, ¬GA
. . .
. . .
Γ, ¬HA
. . .
. . .
Δ, HA, A
. . .
DdscR
. . .
Γ, ¬HA
. . .
¬A, HA
. . .
Δ, HA, A
. . .

**Theorem 4.10.** Let C be a class of linear orders and Γ a finite set of formulas.
If Γ is RΓ(C, ())-consistent then it is C-()-satisfiable.

*Proof.* By following the proof of Theorem 4.9, we can modify the definition of
S by requiring the points of S to be RΓ(C, ())-consistent sets maximal in Λ,
where Λ is the smallest (C, ())-closed set of formulas containing Γ. The assert
follows from noticing that in the proof of Theorem 4.9, for showing only the
conditions satisfied by C-()-structures of mosaics, non-analytic cuts are never
used and that all the relevant rules are such that if all the formulas in the
numerator are in Λ then the same happens to all the formulas in the denom-
inator. Finally, we notice that the restricted version of the cut is enough for
maximalizing sets, when required by the proof, with respect to Λ.
$\square$

Theorem 4.10 gives the completeness of the analytic system with respect
to the logic L(C, ()). Its soundness is a trivial consequence of Theorem 4.8.
Notice, instead, that, for proving conditions SWdc, STrans, SConn and
SSdc in Theorem 4.9 (i.e., when we consider target branching classes different
from the basic one), we make essential use of unboundedly complex formulas
and that in proving SConn we even use cuts on such formulas. This prevents
us from obtaining any obvious corresponding analyticity result.
