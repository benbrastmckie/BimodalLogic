### 3.2. Mosaics and Satisfiability

We will now show that the existence of a saturated set of mosaics for a given
set of formulas corresponds to the existence of a model for such a set.

**Definition 3.8.** Let F = (W, ≺, ≃) be a frame. A chronicle for F on Λ is a
function δ assigning a subset of Λ to every element of W such that the following
conditions are satisfied: for every v, v′ ∈W,
(i) A ∈δ(v) iff¬A /∈δ(v);
(ii) A ∧B ∈δ(v) iff{A, B} ⊆δ(v);
(iii) if ∀A ∈δ(v), then A ∈δ(v);
(iv) if GA ∈δ(v) and v ≺v′, then {A, GA} ⊆δ(v′);
(v) if HA ∈δ(v) and v′ ≺v, then {A, HA} ⊆δ(v′);
(vi) if v ≃v′ then δ(v) ∼Λ δ(v′).
We say that a chronicle δ is based on a structure of mosaics S = (SV , SH),
defined on the same Λ, if:
(vii) if v ≺v′ and there is no v′′ such that v ≺v′′ ≺v′, then (δ(v), δ(v′)) ∈
SV ;
(viiii) if v ≃v′, then there exist v1 ≃· · · ≃vn such that v = v1, v′ = vn and
(δ(vi), δ(vi+1)) ∈SH for 0 < i < n.
Let D be a target branching class and S be a structure of mosaics. Given a
C-D-frame F and a chronicle δ for it, the pair (F, δ) will be referred to as a
C-D-chronicled frame based on S.
3 Notice that the SMb−condition only makes sense if we require that G⊥∈Λ.

Conditions (i)−(vi) are the analogous of the coherence conditions in the
definition of vertical and horizontal mosaics. Conditions (vii) and (viii) ensure
that the chronicle is built out of mosaics from a given structure.

**Definition 3.9.** Let F = (W, ≺, ≃) be a ()-()-frame, v ∈W, δ a chronicle for F
and A a formula. An element ⟨v, FA⟩is a vertical future defect of (F, δ) if:
(i) FA ∈δ(v); and
(ii) (ii) for every v′ ∈W such that v ≺v′, we have A /∈δ(v′).
⟨v, PA⟩is a vertical past defect of (F, δ) if:
(i) PA ∈δ(v); and
(ii) for every v′ ∈W such that v′ ≺v, we have A /∈δ(v′).
Finally, ⟨v, ∃A⟩is a horizontal defect of (F, δ) if:
(i) ∃A ∈δ(v); and
(ii) for every point v′ ∈W, if v ≃v′ then A /∈v′.

**Lemma 3.10.** Let D be a target branching class in {(), (Wdc), (Wdc +
Sdc)}, S = (SV , SH) a ()-D-structure of mosaics, (F = (W, ≺, ≃), δ) a finite
()-D-chronicled frame based on S and α a defect on (F, δ). Then there exists
a finite ()-D-chronicled frame based on S that extends (F, δ) and such that α
is not a defect in it.

*Proof.* The proof proceeds by showing how to cure vertical and horizontal
defects and how to guarantee that the resulting frame is still of the required
type. Notice that if D ̸= (), the procedure may require the addition of more
than one point.
Curing of vertical defects. Vertical defects are cured in the same way as
described in [14]. We recall the case of a linear future defect; the treat-
ment of past defects is just symmetrical. Let α be ⟨v, FA⟩for some v ∈W
and some formula A. We can consider a v′ that is the ≺-maximal element
of W such that FA ∈v′. Since d is a defect of (F, δ), such a v′ exists.
By curing the defect ⟨v′, FA⟩, we will also cure all the defects ⟨w, FA⟩for
w ≺v′. We have two subcases:
(a) v′ is the greatest element of W according to ≺. Then, by the sat-
uration condition SV1, there is a mosaic (Γ′
0, Γ′
1) in S such that
Γ′
0 = δ(v′) and A ∈Γ′
1. We can define a new frame F ′ = {W′, ≺′
≃′} obtained by adding a new element v′′ labeled with Γ′
1. Namely,
we define W′ = W ∪{v′′}, ≺′ as the smallest linear order relation
containing ≺and such that w ≺v′′ for every w ∈W and ≃′=≃
∪{(v′′, v′′)}. We can associate to F ′ a chronicle δ′ that extends δ by
assigning Γ′
1 to v′′.
(b) v′ is not the ≺-greatest element of W. Then, there exists an element
v′′ ∈W such that v′′ is the immediate successor of v′, according to
the relation ≺, and, by the maximality of v′, ¬FA ∈δ(v′′). By the
condition SV3, there exist two mosaics (Δ0, Δ), (Δ, Δ1) ∈S such
that Δ0 = δ(v′), Δ1 = δ(v′′) and A ∈Δ. Then we define an exten-
sion F ′ = {W′, ≺′, ≃′}, by inserting a point v∗between v′ and v′′.

A chronicle δ′ for F ′ is obtained by extending δ with the assignment
δ′(v∗) = Δ.
Curing of horizontal defects. If α is a horizontal defect, i.e., A = ∃A′ for
some A′, then, by the saturation condition SH1, we know that there exists
(Δ, Δ′) ∈SH such that δ(v) = Δ and A ∈Δ′. Then we define a frame
F ′ = (W′, ≺′, ≃′), where W′ = W ∪{v′}, ≺′=≺and ≃′ is the reflexive,
symmetric and transitive closure of ≃∪{(v, v′)}. We can associate to F ′
a chronicle δ′ that extends δ by assigning M ′ to v′.
Preserving relational properties. According to
the
procedure described
above, curing a defect on a ()-(Wdc)-chronicled frame may produce a
chronicled frame that is not of the same type. Namely, the curing of α
could generate in the new frame F ′ = (W′, ≺′, ≃′) a counterexample
to the property Wdc, i.e., three points v1, w1 and w′
1 in W′ such that
v1 ≺′ w1 ≃′ w′
1 but such that there is no point v′
1 in W′ for which
v1 ≃′ v′
1 and v′
1 ≺′ w′
1 hold. Such situations, which will be referred to as
Wdc-defects, need to be repaired in a different way according to the fact
that D also contains Sdc or not.
(a) Let D = (Wdc). Since (F ′, δ′) is based on S, by the transitive closure
ensured by property STrn and by condition (vii) in Definition 3.8,
there exists (δ′(v1), δ′(w1)) ∈SV . Moreover, by condition (viii) in

Definition 3.8, there exists a sequence w1 ≃· · · ≃wn such that
wn = w′
1 and (δ′(wi), δ′(wi+1)) ∈SH for 0 < i < n. By construc-
tion, for 0 < i < n, the sequence v1 ≺′ w1 ≃′ wi also represents a
Wdc-defect. All such defects will be cured by applying, in turn, to
all the 0 < i < n, the following procedure. Let vi be the last point
added to cure a defect (as a base case it will coincide with v1) and
(F ′′, δ′′) the chronicled frame obtained as a result of the (i −1)-th
step (δ′′ = δ′, if i = 1). Then the sequence vi ≺′′ wi ≃′′ wi+1 is a
Wdc-defect. As a result of the (i −1)-th step (or by hypothesis, if
i = 1) we have (δ′′(vi), δ′′(wi)) ∈SV . Then, by the saturation con-
dition SWdc on S, we know that there exists a point Δ ∈Points(S)
such that (Δ, δ′′(wi+1)) ∈SV and (δ′′(vi), Δ) ∈SH. It is then pos-
sible to build a new frame by extending F ′′ with a further point
vi+1 and associate to it a proper chronicle that is the extension of δ′′
assigning Δ to vi+1. Condition SCon allows for positioning the new
point properly along the ≺′′-order. Such a procedure will eventually
cure all the defects in the sequence and thus also the one related to
the triple (v1, w1, w′
1).
(b) Now let D = (Wdc+Sdc). There are three possibilities: (i) the Wdc-
defects arise from the curing of a vertical defect made by inserting
a point in the middle of a linear order (case (b) in the curing of a
vertical defect above); (ii) the Wdc-defects arise from the curing of
a vertical past defect occurring at a point at the bottom of a linear
order; or (iii) the Wdc-defects arise from the curing of a horizontal
defect. In the case (i), we notice that the possible Wdc-defects are
also counterexamples to Sdc, since Wdc and Sdc combined give the

frame the shape of a (partial) grid, with ≺operate vertically and
≃operate horizontally. We can use the saturation condition SSdc
in order to add new points and eliminate such counterexamples. As
an example, consider the case when a point v1 has been inserted
between two points v0 and v2 such that v0 ≃v′
0 and v2 ≃v′
2. The
resulting defect can be cured by adding a point v′
1 between v′
0 and v′
2
such that v1 ≃v′
1. Condition Ssdc ensures that a v′
1 with the proper
labeling exists. In both the cases (ii) and (iii), we deal with sim-
ple Wdc-defects and the frame can be extended by using condition
SWdc, as described in point (a) above.
$\square$

In the following, when not working with the full language, we will anyway
often require that the labeling set of formulas on which mosaics are defined
is closed with respect to some properties. We will let such closure proper-
ties depend on the particular class of linear orders and the particular target
branching class considered.

**Definition 3.11.** Let C be a class of linear orders and D a target branching
class. A set Λ of formulas is said to be C-D-closed if the following conditions
are satisfied:
(i) Λ is closed under subformulas and single negations (of non-negated for-
mulas);
(ii) if Fst is in C, then (PH⊥) ∨(H⊥) ∈Λ;
(iii) if Lst is in C, then (FG⊥) ∨(G⊥) ∈Λ;
(iv) if Nfst is in C, then P⊤∈Λ;
(v) if Nlst is in C, then F⊤∈Λ;
(vi) if Mb−is in D, then G⊥∈Λ.
Now we can use the procedure described in Lemma 3.10 to build, via an
ω-construction, a structure of the given type. The following result from [29]
will be useful in order to ensure that relational properties are preserved during
the construction.

**Lemma 3.12.** Let D be a target branching class and F = {Fλ | λ < μ} a set of
()-D-frames indexed on the ordinal μ such that Fλ ⊆Fλ′ for all λ < λ′ < μ.
Then the union F = 
λ<μ Fλ is a ()-D-frame.

**Theorem 3.13.** Let C be a class of linear orders with C not including any of
Udsc and Ddsc, D a target branching class and Γ a set of formulas. Then, Γ
is C-D-satisfiable iffthere exists a C-D-structure of mosaics for Γ.

*Proof.* (⇒) Let M = (W, ≺, ≃, V) be a C-D-structure satisfying Γ and let
u ∈W be a point such that M, u |= Γ. Given a set Λ′, which contains Γ
and is C-D-closed, we can associate a different fresh atom, i.e., an atom that
is not in Λ′, to each world in W4. Let Λ′′ be the smallest C-D-closed set of
formulas containing such atoms and Λ = Λ′ ∪Λ′′. We associate a subset of
4 By adapting the result from the L¨owenheim–Skolem theorem (see, e.g., [26]), we can
assume, without loss of generality, that W is countable.

Λ to every point of W as follows: for every v ∈W we define Δv = {A ∈
Λ′ | M, v |= A} ∪{pv} ∪{¬p | p ∈Λ′′ and p ̸= pv}, where pv is the atom
associated to v. Then we define the set SV = {(Δv, Δv′) | v, v′ ∈W and v ≺
v′} ∪{(Δv) | v ∈W and for all v′ ∈W we have v ̸≺v′ and v′ ̸≺v}. Similarly,
we define SH = {(Δv, Δv′) | v, v′ ∈W and v ≃v′}. It is easy to verify that
S = (SV , SH) is a C-D-structure of mosaics. In fact, coherence and saturation
conditions are clearly satisfied since the definition of each point in S comes
from the labeling of the corresponding point in a C-D-structure and the use of
fresh atoms ensures that each world in W gives rise to a distinct point in S. Fur-
thermore S is a structure of mosaics for Γ since Γ ⊆Δu and Δu ∈Points(S).
(⇐) Let S be a C-D-structure of mosaics for Γ on a C-D-closed labeling
set Λ of formulas. As in [14], we build a model for Γ step by step by using the
mosaics in S as building blocks. The procedure described in Lemma 3.10 will
be used to cure the defects. Namely, we define a sequence σ containing all the
formulas FA, PA, ∃A in Λ such that each such formula occurs infinitely often
in σ and proceed as follows.
Notice that we cannot guarantee that the result of each step of the con-
struction is a C-D-chronicled frame because some of the properties (both linear
and branching) will only emerge in the limit step. Namely, during the interme-
diate steps of the construction we will work with ()-D-chronicled frames, for
D =(), D =(Wdc) and D=(Wdc+Sdc), and with ()-(Wdc + Sdc)-chronicled
frames if D =(Wdc+Sdc+Mb−).
[STEP 0] First, let us consider a mosaic μ in S such that μ is a mosaic
for Γ (since S is a structure of mosaics for Γ, such a mosaic exists). Moreover,
since by definition Points(SV ) = Points(SH ), we can assume, without loss
of generality, that μ is a vertical mosaic. We can define F0 = {W0, ≺0, ≃0}
as follows. If μ = (Δ0) is a singleton, then we define W0 = {w0}, ≺0= ∅
and ≃0= {w0, w0}. Furthermore, we associate to W0 the chronicle δ0 defined
as δ0(w0) = Δ0. If μ = (Δ0, Δ1) is a vertical mosaic in SV , then we define
W0 = {w0, w1}, ≺0= {(w0, w1)} and ≃0= {(w0, w0), (w1, w1)}. We associate
to W0 the chronicle δ0 defined as δ0(w0) = Δ0 and δ0(w1) = Δ1. In both cases
F0 is a ()-D-frame and δ0 is a chronicle for F0 based on S.
[STEP n + 1] Assume that we have already defined a ()-D-frame (a
()-(Wdc + Sdc)-frame if D=(Wdc+Sdc+Mb−)) Fn and a chronicle δn for Fn
based on S. Then we consider the (n + 1)-th formula A in the enumeration σ.
By using the procedure described in Lemma 3.10, we can define a ()-D-frame
Fn+1 and a chronicle δn+1 for it such that for each defect ⟨w, A⟩in (Fn, δn),
we have that it is not a defect in (Fn+1, δn+1).
Notice that if D=(Wdc+Sdc+Mb−), we just apply the procedure
described for D = (Wdc + Sdc). Moreover, in some cases, depending on the
nature of C, we slightly refine the procedure described in Lemma 3.10. Namely,
if C contains Dns, then, as suggested in [14], when curing vertical defects we
add not only the mosaics specified by the procedure of Lemma 3.10 but also,
between all the neighboring points, all the mosaics that can lay in the middle.
Condition SVDns ensures that there is at least one such mosaic for each pair
of neighboring points.

[STEP ω] Now we can just take the infinite unions F = 
i∈ω Fi and
δ = 
i∈ω δi. The special curing procedure described above for the dense case
guarantees that the process will finally produce a frame which is dense. In the
case of the other linear properties possibly contained in C, it is the definition of
mosaic itself to guarantee that the property is enjoyed by the frame obtained
in the limit step.
Then, by Lemma 3.12, F is a C-D-frame, for D = (), D = (Wdc) or
D = (Wdc + Sdc). In the case when D=(Wdc+Sdc+Mb−), in the interme-
diate steps of the construction we have frames (with associated chronicles)
which enjoy Wdc and Sdc but not necessarily Mb−. However, condition SMb−
ensures that, at each step i, a ≺-maximal point w can be ≃-related to a point v
distinct from w only if G⊥/∈δi(w). But this implies that w contains a vertical
future defect, which in some later step will be cured by inserting some point
above w. Thus in the final construction we have that also Mb−is satisfied.
Furthermore, in all the cases, by the construction we have no defects in (F, δ),
since the enumeration in σ ensures that if a defect becomes actual at some
step, then we cure it in a later step.
We can easily obtain a C-D-structure by endowing F with a valuation
V induced by δ. Namely, let F be (W, ≺, ≃); then we define a structure
M = (W, ≺, ≃, V), where V is such that for all u ∈W and for all atomic
propositions p, p ∈V(u) iffp ∈δ(u). By recalling that we used a mosaic for Γ
as a foundation stone of our construction (STEP 0), we conclude that M is a
C-D-structure that satisfies Γ.
$\square$

**Corollary 3.14.** Let C be a class of linear orders with C not including any of
Udsc and Ddsc, D a target branching class and Γ a set of formulas. Then Γ
is C-(Dis+Wdc)-satisfiable iffthere exists a C-(Wdc+Sdc)-structure of mosa-
ics for Γ. Γ is C-Ockhamist-satisfiable (i.e., by Lemma 2.8, satisfiable in the
logic defined over bundled trees in the class B+(C) [10]) iffthere exists a
C-(Wdc+Sdc+Mb−)-structure of mosaics for Γ.

*Proof.* This follows straightforwardly by combining the result of Theorem 3.13
and the equivalences of Lemma 2.8.
$\square$

In the case where no interactions between the components are considered,
i.e., when D = (), it is possible to give a proof based on a labeling set which
is finite. This observation will be crucial in obtaining a result of decidability
(see Sect. 4.3 below). We remark that in this case we are able to deal also with
discreteness properties.

**Theorem 3.15.** Let C be a class of linear orders and Γ a finite set of formulas.
Then, Γ is C-()-satisfiable iffthere exists a C-()-structure of mosaics for Γ on
a finite labeling set.

*Proof.* (⇒) Since Γ is C-()-satisfiable, there exist M = (W, ≺, ≃, V) and u ∈W
such that M, u |= Γ. Let Λ be the smallest C-()-closed set of formulas contain-
ing Γ. We will show that there exists a structure of mosaics on Λ for Γ.
We can easily infer a set of mosaics on the labeling set Λ from M.
We associate a subset of Λ to every point of W as follows: first we define

Δw = {A ∈Λ | M, w |= A} for every w ∈W. Then we define the sets
SV
= {(Δw, Δ′
w) | w, w′ ∈W and w ≺w′} ∪{(Δw) | w ∈W} and
SH = {(Δw, Δ′
w) | w, w′ ∈W and w ≃w′} ∪{(Δw) | w ∈W}. It is easy
to verify that S = (SV , SH) is indeed a C-()-structure of mosaics. In fact
coherence and saturation conditions are clearly satisfied since the definition
of each point in S comes from the labeling of the corresponding point in a
C-()-structure. Furthermore S is a structure of mosaics for Γ, since Γ ⊆Δu
and Δu ∈Points(S).
(⇐) The thesis follows from a construction analogous to that in the proof
of Theorem 3.13 (right-to-left direction). Clearly, restricting to consider struc-
tures of mosaics based on a finite labeling set does not affect the previous result.
In this case, we can also consider classes of linear orders satisfying Ddsc
and/or Udsc. Namely, if C contains UDsc, then in cases like (b) for the cur-
ing of vertical future mosaics (Lemma 3.10), we proceed by adding a point v∗
between v′ and v′′ such that {A, ¬FA} ⊆δ′(v∗). Condition SVUdsc ensures
that there exists a mosaic allowing that. If C contains DDsc, then we proceed
symmetrically in the case of vertical past defects. The fact that the labeling
set is finite guarantees that only a finite number of formulas of the form FA
or PA occurs in any point. Hence, between any two points, we will insert only
finitely many points during our ω-construction.
$\square$
