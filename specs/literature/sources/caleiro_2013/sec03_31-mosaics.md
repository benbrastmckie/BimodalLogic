### 3.1. Mosaics

In the most general case, that is, when, as in Definition 2.6, no particular
assumptions are made on the way atoms are evaluated, it is straightforward
to check that the set of state formulas can be defined recursively as follows:
1. if A is a formula, then ∀A is a state formula;
2. if A and B are state formulas, then A ∧B is a state formula;
3. if A is a state formula, then ¬A is a state formula.

If we are interested in logics where the evaluation of atoms depends only on
the state (and not on the particular path), i.e., if v ≃w implies V(v) = V(w),
then the following further base case needs to be added to the conditions above:
0. if A is an atomic proposition, then A is a state formula.
In any case, it is clear that satisfaction at any ≃-related points in an interpre-
tation structure agrees on state formulas.
The following definitions are essential in supporting the construction of
sets of mosaics based not necessarily on the whole Ockhamist language F,
but on suitable (possibly finite) sublanguages Λ ⊆F. Below, unless otherwise
stated we consider fixed such a set Λ. As a minimal requirement, we will assume
that Λ is closed under subformulas and single negation (of non-negated for-
mulas).

**Definition 3.1.** Let Γ, Δ ⊆Λ. We say that Γ and Δ are Λ-state-equivalent, and
we write Γ ∼Λ Δ, if for each state formula A ∈Λ, A ∈Γ if and only if A ∈Δ.

**Definition 3.2.** A point (on Λ) is a set of formulas Γ ⊆Λ satisfying the following
local conditions:
for every formula A ∈Λ,
(L1) A ∈Γ iff¬A /∈Γ;
(L2) A = B ∧C ∈Γ iff{B, C} ⊆Γ;
(L3) if A = ∀B ∈Γ then B ∈Γ.
A point Γ is further said to be2:
•
future unbounded (or a FU-point) if F⊤∈Γ;
•
future bounded (or a FB-point) if (FG⊥) ∨(G⊥) ∈Γ;
•
past unbounded (or a PU-point) if P⊤∈Γ;
•
past bounded (or a PB-point) if (PH⊥) ∨(H⊥) ∈Γ.

**Definition 3.3.** A mosaic (on Λ) is a pair (Γ, Δ) or just (Γ), where Γ and Δ
are points on Λ. We say that a mosaic (Γ, Δ) is a vertical mosaic iffit satisfies
the following vertical coherence conditions:
for every formula A ∈Λ,
(V1) if A = GB ∈Γ then B ∈Δ;
(V2) if A = HB ∈Δ then B ∈Γ;
(V3) if A = GB ∈Γ then GB ∈Δ;
(V4) if A = HB ∈Δ then HB ∈Γ.
We say that a mosaic (Γ, Δ) is a horizontal mosaic iffit satisfies the following
horizontal coherence condition:
(H1) Γ and Δ are Λ-state-equivalent.
A singular mosaic (Γ) is both a vertical and a horizontal mosaic.
We say that a mosaic is a FU/FB/PU/PB-mosaic if it is composed only
of FU/FB/PU/PB-points, respectively.
Let us now consider sets of mosaics.
2 Notice that the definitions of future/past (un)boundedness require, mutatis mutandis, that
the corresponding formulas F⊤, (FG⊥) ∨(G⊥), P⊤, (PH⊥) ∨(H⊥) ∈Λ.

**Definition 3.4.** The set of points of a set of mosaics S (on Λ) is the set
Points(S) = {Ω ⊆Λ | (Ω) ∈S or there exists (Γ, Δ) ∈S with Ω = Γ or
Ω = Δ}.
Vertical mosaics are subject to the following saturation properties.

**Definition 3.5.** A set S of vertical mosaics (on Λ) is a ()-vertically saturated set
of mosaics (on Λ) (a ()-VSSM for short) if it satisfies the following ()-vertical
saturation conditions:
for every Ω ∈Points(S),
(SV1) if FA ∈Ω then there exists (Ω, Γ) ∈S with A ∈Γ;
(SV2) if PA ∈Ω then there exists (Γ, Ω) ∈S with A ∈Γ;
for every mosaic (Γ, Δ) ∈S,
(SV3) if FA ∈Γ, then:
(i) A ∈Δ or FA ∈Δ; or
(ii) there exist (Γ, Ω), (Ω, Δ) ∈S with A ∈Ω;
(SV4) if PA ∈Δ, then:
(i) A ∈Γ or PA ∈Γ; or
(ii) there exist (Γ, Ω), (Ω, Δ) ∈S with A ∈Ω.
Additional vertical saturation conditions of interest are:
for every mosaic (Γ, Δ) ∈S,
(SVDns) there exists Ω ∈Points(S) such that (Γ, Ω), (Ω, Δ) ∈S;
(SVUdsc) if FA ∈Γ, then:
(i) A ∈Δ or FA ∈Δ; or
(ii) there exist (Γ, Ω), (Ω, Δ) ∈S with {A, ¬FA} ⊆Ω;
(SVDdsc) if PA ∈Δ, then:
(i) A ∈Γ or PA ∈Γ; or
(ii) there exist (Γ, Ω), (Ω, Δ) ∈S with {A, ¬PA} ⊆Ω.
Given a class C of linear structures, S is said to be C-vertically saturated
(a C-VSSM for short) if S is a ()-VSSM that further satisfies the following
conditions, corresponding to each property in C:
•
Fst/Lst/Nfst/Nlst correspond to requiring that S is a set of PB/FB/
PU/FU-mosaics, respectively;
•
Dns corresponds to requiring that SVDns holds;
•
Udsc/Ddsc correspond to requiring SVUdsc/SVDdsc hold, respectively.
Horizontal mosaics are also subject to saturation properties.

**Definition 3.6.** A set S of horizontal mosaics (on Λ) is a horizontally saturated
set of mosaics (on Λ) (a HSSM for short) if it satisfies the following horizontal
saturation condition:
for every Ω ∈Points(S),
(SH1) if ∃A ∈Ω and A /∈Ω then there exists Γ ∈Points(S) such that
(Ω, Γ) ∈S and A ∈Γ.
We now need to consider the joint effect of vertical and horizontal
mosaics.

**Definition 3.7.** Let C be a class of linear orders. A C-basic-structure of mosa-
ics is a pair S = (SV , SH) such that SV is a C-VSSM, SH is an HSSM, and
Points(SV ) = Points(SH ). The set of points of the structure of mosaics S is
precisely Points(S) = Points(SV ) = Points(SH ).
Additional combined conditions of interest are:
– (SWdc) if (Ω, Γ) ∈SV and (Γ, Δ) ∈SH then there exists Φ ∈Points(S)
such that (Φ, Δ) ∈SV and (Ω, Φ) ∈SH;
– (STrn) if (Γ, Δ), (Δ, Ω) ∈SV then (Γ, Ω) ∈SV ;
– (SCon) if (Γ, Ω), (Δ, Ω) ∈SV then either Γ = Δ, or (Γ, Δ) ∈SV or (Δ, Γ) ∈
SV ;
– (SSdc) if (Φ, Ω), (Ω, Γ), (Ψ, Δ) ∈SV and (Φ, Ψ), (Γ, Δ) ∈SH then there
exists Υ ∈Points(S) such that (Ψ, Υ), (Υ, Δ) ∈SV and (Ω, Υ) ∈SH;
– (SMb−) if (Γ, Δ) ∈SH and G⊥∈Γ then Γ = Δ.3
Given one of the target branching classes D, S = (SV , SH) is said to be
a C-D-structure of mosaics if S is a C-basic-structure of mosaics that further
satisfies the following conditions, corresponding to each class D ̸=():
•
D =(Wdc) requires that SWdc, STrn and SCon hold;
•
D =(Wdc+Sdc) requires that SWdc and SSdc;
•
D =(Wdc+Sdc+Mb−) requires SWdc, SSdc and SMb−to hold.
Given a structure of mosaics S and a set of formulas Γ, we say that S is
a structure of mosaics for Γ if there exists Ω ∈Points(S) such that Γ ⊆Ω.
