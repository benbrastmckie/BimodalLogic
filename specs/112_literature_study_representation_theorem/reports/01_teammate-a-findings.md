# Teammate A Findings: Literature Study for Task 112

**Task**: 112 — Systematic literature study for task 107 representation theorem
**Date**: 2026-04-24
**Teammate Role**: Primary Angle — cross-source analysis focused on the three-layer infrastructure problem
**Sources Reviewed**: 5 markdown files (see below)

---

## Summary

The five sources divide into two camps. Burgess 1982b and Venema 1993 provide the most directly relevant
technical content: they illuminate the guard convention question (Layer 2) and the domain/density
question (Layer 3) from the perspective of tense logic completeness theory. Obendrauf 2024 provides
Lean 4 engineering patterns for the canonical model construction. Burgess 1984 is a broad survey
chapter that confirms the Layer 3 concern (GGp→Gp and dense vs. discrete orders) and the necessity
of S5-modal structure for the Box case. Thomason 1984 addresses the T×W bimodal combination
architecture but is concerned with branching time and historical necessity, not linear time with Until;
its relevance to BX is indirect.

None of the five sources directly addresses Layer 1 (the g function being trivially empty). This is
an internal implementation gap with no direct counterpart in the paper proofs, which never need to
make the interval-function explicit.

---

## Source 1: Burgess 1982b — Axioms for Tense Logic II: Time Periods

**Reference**: Notre Dame Journal of Formal Logic, Vol. 23, No. 4, October 1982, pp. 375–383.
**File**: `literature/Burgess_1982b_Axioms_for_tense_logic_II_Time_periods.md`

### What this source is about

This is a companion paper to Burgess 1982a (the Since-and-Until axiomatization). It axiomatizes
tense logic over period-based structures rather than instant-based structures. It defines the canonical
period structure I(X, <) from an instant-based dense linear order, introduces homogeneous valuations,
and proves completeness for the period-based tense logic S (which extends J with axiom A5: Gp → p).

### Relevance to Layer 1 (g function trivial)

**Low relevance.** The paper's I(X, <) construction produces periods (open intervals) from instants,
not the other way around. Its "interval function" is the set I(X) = {(x, y) : x < y}, never explicitly
tracked within a chronicle. There is no analogue of the chronicle's g(x, y) field. Burgess treats the
interval content implicitly through homogeneous valuations. The paper provides no technique for
making a g function non-trivial during a Lindenbaum construction.

**Potential indirect insight**: The paper's characterization of which valuations can arise as I(V)
(Section 2.3, distributive + weakly cumulative) defines what it means for a period valuation to be
consistent with an interval content. This could inform the design of what g(x, y) should contain:
it should be precisely the set of formulas holding throughout the interval (x, y) in the eventual
countermodel. But this is a modeling insight, not a construction technique.

### Relevance to Layer 2 (guard convention mismatch: open vs. half-open)

**Medium relevance.** The paper uses open intervals ]x, y[ as its periods (Section 1.2). The order
relation <₁ between periods is defined as ]x, y[ <₁ ]z, w[ iff y < z — i.e., the periods are strictly
disjoint with a gap between them. The G operator is defined as:

> W(Gα) = {a : ∀b ∀c (b ⊆ a ∧ b <₁ c → c ∈ W(α))}

This is an open-guard semantics at the period level: c must strictly follow some sub-period b of a.
The analogous instant-level formula is: Gα is true at x iff α holds at all y with x < y. This is
a half-open [x, ∞) guard at x (the current instant is not required to satisfy α), not the open
(x, ∞) guard that would require a strictly intermediate point.

**Key passage**: Section 4.3, Completeness Theorem proof. Burgess's canonical model for the period
logic satisfies property (3): Gβ ∈ T(x) → β ∈ T(x). This is precisely BX's GGp→Gp equivalent.
It is enforced by working inside S (which includes axiom A5: Gp → p), not inside J. The BX
chronicle construction targets J-completeness (without density/reflexivity axiom); adding A5
would validate GGp→Gp, which BX9 does not. This confirms that the chronicle must avoid the
half-open reflexive guard at the starting point.

**Confidence**: Medium. The paper confirms open-guard semantics is the correct choice for BX
(before adding A5/density), but does not resolve how to bridge from the chronicle's strict open
guard C5 (x < z < y) to the truth-semantics half-open guard [t ≤ r < s).

### Relevance to Layer 3 (domain extension / density: D=Rat validates GGp→Gp)

**High relevance.** Section 4.3 is directly relevant. The completeness proof for the period-logic
S (which includes Gp → p) builds a dense countermodel over Q. Crucially:

- The proof forces the canonical model to satisfy (3a): Gβ ∈ T(x) → β ∈ T(x), which is exactly
  the reflexivity/density condition that BX lacks.
- To achieve (3), Burgess adds the set Λ of all instances of A5 and its mirror image to the
  consistent set, forcing (3) at every point.

For BX (which lacks A5), the correctconstruction must NOT add Λ. The chronicle construction
working over Q would inadvertently validate GGp→Gp for any chronicle f satisfying C1 (forward G
closure), because Q is dense. The sparse X subset of Q (Burgess's approach in the companion paper
1982a) avoids this by ensuring the domain points of the chronicle are non-dense.

**Key passage**: Section 4.3, paragraph 3: "Using the fact that η is actually consistent with S, it
is possible to obtain V and T so that we further have (3): Gβ ∈ T(x) → β ∈ T(x)." The words
"actually consistent with S" are load-bearing: this extra property requires A5. Without A5 (i.e.,
for BX), condition (3) should not hold, and the domain cannot be all of Q.

**Confidence**: High. This source directly confirms that Q-based completeness for BX would
incorrectly validate GGp→Gp, and that A5 (Gp → p) is the culprit.

### Specific techniques potentially adaptable

1. **Homogeneous valuation characterization**: The distributive + weakly cumulative conditions
   (Section 2.3) provide a crisp semantic characterization of what the g function should contain.
   Adapting this: g(x, y) should be exactly the set of formulas φ such that φ holds at every domain
   point strictly between x and y in the eventual model — the interval content.

2. **Property (3) exclusion**: The proof shows exactly how NOT to achieve (3). For BX chronicle
   construction, the Lindenbaum extension must avoid adding instances of Gφ → φ. This is automatic
   if we use BX-consistent MCS rather than S-consistent MCS.

---

## Source 2: Venema 1993 — Completeness via Completeness: Since and Until

**Reference**: In de Rijke (ed.), Diamonds and Defaults, Synthese Library 229, Kluwer, 1993.
**File**: `literature/Venema_1993_Since_and_Until.md`

### What this source is about

This paper proves completeness of SU (Since and Until) logic for well-orderings and for ω using
orthodox axioms (MP, TG, Substitution only, no irreflexivity rule). The proof strategy is: (1)
use Burgess's completeness for linear orders as a base; (2) show every BW-model is definably
well-ordered (using Stavi connectives and Kamp's expressive completeness); (3) apply Doets's
theorem to replace the definably well-ordered model with an actual well-ordered equivalent.

### Relevance to Layer 1 (g function trivial)

**Low relevance.** The paper's construction is at the abstract model level (start with a linear
model, show it is definably well-ordered, replace it) and does not involve an explicit interval
function g. However, the Doets theorem argument (Section 3.8) is structurally interesting: it
shows that for every interval [b, a⟩ of T, there exists a well-ordered n-equivalent. This is
essentially a local coherence argument — for each bounded interval, you can find a better-behaved
replacement. This pattern parallels what fixing g would accomplish: showing that for each interval
(x, y) in the chronicle, the g-content (interval formulas) propagates correctly.

**Confidence**: Low. The structural analogy is interesting but not directly applicable.

### Relevance to Layer 2 (guard convention mismatch: open vs. half-open)

**High relevance.** This is the source most directly relevant to Layer 2. Venema's semantics for
U(φ, ψ) (Section 2.2) is:

> M, t ⊨ U(φ, ψ) if there is a v > t such that M, v ⊨ φ and for all u with t < u < v, M, u ⊨ ψ

This is the **strict/open** guard semantics: the event φ holds at v (strictly after t), the guard ψ
holds at all intermediate u (t < u < v, open on both sides). The starting point t is NOT required
to satisfy ψ. This matches the chronicle's C5 condition exactly: the chronicle's C5 uses an open
guard x < z < y.

**However**, the BX truth semantics uses a half-open guard [t, s): ψ holds at all u with t ≤ u < s.
Venema's semantics is strict; BX semantics includes t.

**Key passage**: The U(φ, ψ) clause in Section 2.2. Comparing with BX's Until definition (which
the team research identifies as using half-open [t, s)), Venema's strict-open semantics aligns
with C5 but not with BX truth. Venema's axiom A3a:

> p ∧ U(q, r) → U(q ∧ S(p, r), r)

expresses that if U(q, r) holds at t (with event r at v and guard q between t and v), and p also
holds at t, then the stronger Until with guard q ∧ S(p, r) also holds. This is a backward
propagation lemma that essentially handles the "starting point satisfies guard" case — not by
requiring p at t to be part of the guard definition, but as a derived fact.

**Potential fix for Layer 2**: BX9 gives φ U ψ → φ ∨ ψ at the starting point. Venema's A3a
pattern suggests that if the starting point satisfies the guard φ (which BX9's disjunction gives
when ψ doesn't hold at t), then the guard can be extended backward to include t. This is the
missing lemma: show that in a BX-MCS containing φ U ψ, either ψ ∈ MCS (event at t) or φ ∈ MCS
(guard includes t), and in the latter case the open guard C5 is sufficient for the half-open truth
semantics because the starting point is separately satisfied.

**Confidence**: High. Venema's strict-open semantics confirms that C5's open guard (x < z < y)
is semantically correct for this style of Until semantics. The half-open vs. open gap can be
bridged by BX9, but the exact Lean argument needs care.

### Relevance to Layer 3 (domain extension / density)

**Medium relevance.** Venema works with well-orderings, not dense linear orders. His completeness
proof for well-orderings avoids the density issue entirely. However, the expressive completeness
technique (Kamp's theorem, Section 3.1) is the tool that makes this possible: because SU is
expressively complete over DO (Dedekind-complete orders), a definably well-ordered model already
"knows" enough about its structure to admit a well-ordered equivalent. For BX, the analogous claim
would be: a chronicle-based countermodel over a sparse X ⊂ Q, if it satisfies enough coherence
conditions (C1–C5), can serve as a valid countermodel without needing density. Venema's proof
validates this approach at the conceptual level.

**Key passage**: Theorem 4.2, Completeness proof. The phrase "there is a linear model M = (T, <, V)
in which Φ is satisfiable" — this linear model comes from Burgess's completeness for LO (Theorem
3.5), and it is the "wrong" flow of time (linear but not well-ordered). Venema then repairs it.
For BX, the analogous step is: Burgess's LO completeness gives a model over some linear order;
the chronicle construction restricts to a sparse X ⊂ Q; the question is whether this sparse X
model is equivalent to the full Q model for formulas of the relevant complexity.

**Confidence**: Medium. The expressive completeness machinery is relevant but BX does not use SU
expressive completeness (it uses modal S5 plus tense), so the exact technique doesn't transfer.

### Specific techniques potentially adaptable

1. **Open vs. half-open reconciliation via A3a**: Venema's A3a shows how the "guard at t" property
   can be derived from the Until without explicitly including t in the guard interval. Adapting:
   for the BX chronicle, the truth lemma case U(φ, ψ) at t can proceed by (a) the open-guard C5
   gives witness v with φ(v) and ψ at all u in (t, v), then (b) BX9 or U's consequence gives φ
   or ψ at t, and (c) the half-open semantics is satisfied because t satisfies the relevant formula.

2. **Definable well-orderedness pattern**: The technique of showing a model is definably well-ordered
   and then replacing it is a "build then repair" strategy. For BX chronicles: build a chronicle over
   Q (dense, but satisfying C1–C5 for the target formula), then argue that the sparse X sub-chronicle
   is an equivalent model for formulas of bounded complexity.

---

## Source 3: Obendrauf 2024 — Lean Formalization of Completeness for Coalition Logic

**Reference**: ITP 2024, LIPIcs, Article No. 28, pp. 28:1–28:18.
**File**: `literature/Obendrauf_2024_Lean_Formalization_Coalition_Logic.md`

### What this source is about

This paper formalizes soundness and completeness of Coalition Logic with Common Knowledge (CLC)
in Lean 4. The completeness proof uses a two-step canonical model construction: (1) build an
infinite canonical coalition model over all MCS, (2) filter through a finite closure cl(φ) to
obtain a finite model, then prove a truth lemma for the finite model.

### Relevance to Layer 1 (g function trivial)

**Medium relevance.** The most applicable pattern from this paper is the **filtered canonical model**
(Section 8.2). The paper defines S^f = {s^f | s ∈ S^C} where s^f = s ∩ cl(φ). This is analogous
to restricting the chronicle to domain points that appear within the omega-chain up to stage n. The
crucial Lean pattern is:

```lean
def S_f {agents form : Type} (m : modelCL agents) [SetLike m.f.states form]
    (cl : form → Finset (form)) (φ : form) : Type :=
  Finset.attach (Finset.filter ...)
```

The `Finset.attach` pattern (pairing a finite set element with a proof of membership) is exactly
what would be needed to define limit_g: for each pair (x, y) in the limit domain, g(x, y) is the
g-value established at the stage where both x and y first appear together.

**Confidence**: Medium. The Lean engineering pattern for finite subsets of MCS spaces is applicable,
but the chronicle's domain structure is a linear order (not a set of MCS filtered by a closure), so
the analogy is structural rather than direct.

### Relevance to Layer 2 (guard convention mismatch)

**Low relevance.** CLC has no Until/Since operators and no guard conventions. The truth lemma in
Section 8.4 is for epistemic and effectivity operators. The C_path inductive structure (Section 8.3)
is a useful pattern for building inductive proofs over temporal paths, but does not speak to the
open vs. half-open guard issue.

**Key passage**: The truth lemma proof for C_G (Section 8.4). The induction is on the length of
the common knowledge path. The important Lean lesson is that the induction base case is a
single-step path, not the empty path — matching the constructor `C_path.done`. For BX's Until
truth lemma, the analogous induction would be on the number of domain points between t and the
witness, with the base case being when the witness is immediately adjacent.

**Confidence**: Low. The structural pattern is interesting but the semantic content is very different.

### Relevance to Layer 3 (domain extension / density)

**Low relevance.** The CLC completeness uses finite models (the finite model property), so there
is no density concern. However, the closure cl(φ) technique is precisely the tool for avoiding
domain extension problems: instead of building a model over all formulas, you restrict to formulas
in cl(φ), ensuring finiteness. For BX, the analogous technique would be: build the chronicle only
for formulas in cl(φ) for the target formula φ, avoiding spurious validations of GGp→Gp.

**Confidence**: Low. The FMP-based approach used by CLC is not available for BX (which targets
infinite linear orders).

### Specific techniques potentially adaptable

1. **SetLike typeclass for MCS-as-state**: The pattern `[SetLike m.f.states form]` (states contain
   sets of formulas) is directly applicable to the BX chronicle: each chronicle point f(x) is an
   MCS. The truth lemma could be parametrized over `[SetLike state (Formula BX)]`.

2. **Finset.attach for paired existence proofs**: When constructing limit_g, pairs (x, y) in the
   limit domain come with a proof that both appeared at some stage n. The `Finset.attach` pattern
   encodes this as a subtype.

3. **Generic typeclass approach for proof reuse**: Obendrauf's `Pformula`/`CLformula`/`Kformula`
   typeclass hierarchy for reusing lemmas across logics is relevant to the BX project's parametric
   truth lemma design. The parametric truth lemma in BX already uses `[AddCommGroup D]` for the
   domain; a similar parametric approach over a typeclass capturing "has-chronicle" properties
   could factor out the Until/Since truth lemma from the specific chronicle construction.

4. **Finite conjunction/disjunction encoding**: The paper's phi_X_list / phi_X_finset / phi_X_set
   triple for handling the same object at different type levels is directly applicable to the BX
   setting where formulas live as `Finset (Formula BX)` in each MCS point.

---

## Source 4: Burgess 1984 — Basic Tense Logic (Handbook Chapter II.2)

**Reference**: Chapter II.2 in Gabbay & Guenthner (eds.), Handbook of Philosophical Logic, Vol. II,
1984, pp. 125–133 (relevant portion reviewed).
**File**: `literature/Burgess_1984_Basic_Tense_Logic.md`

### What this source is about

This is Burgess's survey chapter on tense logic in the Handbook of Philosophical Logic. The file
contains several sections including discussion of period-based tense logic (pp. 125–127 = the
first portion reviewed), metric tense logic (pp. 127–128), and the Diodorean/Aristotelian modal
fragments of tense logic (pp. 128–130). The early section (pp. 125–127) is directly relevant.

**Note**: The file is very large (34k tokens) and was read in sections; the references section
is pp. 132–133. The main technical content is at pp. 125–131.

### Relevance to Layer 1 (g function trivial)

**Low relevance.** The survey confirms that the period-based construction builds I(X, R) as the
set of open intervals (Section at p. 125), but the interval function g is not mentioned explicitly.
The survey frames the completeness question as "given a class L of structures, find a sound and
complete axiomatization" (p. 126), without specifying the internal mechanics of how the chronicle
tracks interval content.

### Relevance to Layer 2 (guard convention mismatch)

**Medium relevance.** The period-based G operator is defined (p. 126):

> V(Gα) = {a : ∀b ∀c (b ⊆ a ∧ b <₁ c → c ∈ V(α))}

This is the same open-guard semantics as Burgess 1982b. The period-based semantics uses:
- b ⊆ a: b is a sub-period of a
- b <₁ c: c strictly follows b (open gap between b and c)
- c ∈ V(α): α holds in the following period c

This confirms that the Burgess period-semantics does NOT require α at the starting period a itself.
The axiom A5 (Gp → p) is the additional axiom needed to get the reflexive/half-open behavior.

**Key passage**: p. 126 discussion of connectives; specifically the paragraph "Another proposal,
originating in Burgess [1982]...". This refers back to the companion paper on homogeneous valuations
and confirms that the correct BX semantics uses J(W) (almost-always), not I(W) (always), for
period satisfaction. Since BX lacks Gp → p, the BX truth semantics should use strict/open guards.

**Confidence**: Medium. This confirms the open-guard semantics is correct for BX-style logic
(without density axiom), but does not provide new techniques beyond what 1982b already shows.

### Relevance to Layer 3 (domain extension / density)

**High relevance.** The table at p. 129 is directly relevant:

| Class of frames | Tense logic | Diodorean fragment | Aristotelian fragment |
|----------------|-------------|-------------------|----------------------|
| Total orders | L_L | S4.3 | S5 |
| Dense orders | — | — | — |

The table shows that for total orders, the Aristotelian fragment (□p ≡ Hp ∧ p ∧ Gp) yields S5.
This is the BX connection: BX combines tense with modal S5. The dense-order Aristotelian fragment
also yields S5, but with the additional density axiom GGp→Gp from the Diodorean fragment S4.3
(which is S4 + the convergence axiom on total orders).

**Key insight**: The chart confirms that BX (tense + S5 modality over strict linear orders) must
correspond to a logic of total (non-dense) orders, not dense orders. Dense orders add GGp→Gp
(Diodorean S4.3 vs. bare S4 for total orders). Since BX does not have GGp→Gp, the chronicle
countermodel must live over a non-dense (sparse) total order.

**Metric tense logic section** (pp. 127–128) is relevant to the AddCommGroup question. Burgess
explicitly states: "In metric tense logic we assume Time has the structure of an ordered Abelian
group." The current BX semantic framework uses AddCommGroup for the TaskFrame (time shifting for
the Box modality). This confirms the AddCommGroup constraint is correct mathematically and not
an artifact of the formalization. The metric tense logic section confirms this is a deliberate
design choice, not a formalization error.

**Confidence**: High for Layer 3; the connection between dense orders and GGp→Gp is explicit.
High for AddCommGroup; Burgess explicitly confirms ordered Abelian groups for metric tense logic.

### Specific techniques potentially adaptable

1. **Augmented frames** (pp. 130–131): The thermodynamic tense logic section introduces augmented
   frames (X, R, F) where F ⊆ P(X) is a distinguished family of "admissible" propositions closed
   under gA and hA operations. This is exactly what the BX chronicle's g function should capture:
   g(x, y) should be a "admissible proposition" set for the interval (x, y). The closure conditions
   on F in augmented frames (closed under complement, finite intersection, gA, hA) map to the
   C1–C5 conditions on g(x, y). This is a strong structural hint for Layer 1 repair.

2. **Diodorean modal fragment** correspondence: For implementing the Box case of the truth lemma,
   the Diodorean fragment result confirms that Box (interpreted as Hp ∧ p ∧ Gp = "always true
   temporally") gives S5 over total orders. The BX Box is the S5 modality; this confirms that the
   Box case must satisfy S5 axioms (T, 4, 5, B) and that the BFMCS approach (ensuring S5
   saturation) is necessary.

---

## Source 5: Thomason 1984 — Combinations of Tense and Modality (Handbook Chapter II.3)

**Reference**: Chapter II.3 in Gabbay & Guenthner (eds.), Handbook of Philosophical Logic, Vol. II,
1984, pp. 135–165 (reviewed pp. 135–162).
**File**: `literature/Thomason_1984_Combinations_of_Tense_and_Modality.md`

### What this source is about

This is Thomason's survey chapter on combining tense with necessity/modality. The chapter focuses
primarily on **historical necessity** (branching-time modality where necessity = truth on all future
branches), not S5 modality. It covers: the T×W framework (time × worlds), Kamp frames (each world
has its own linear time, with cross-world accessibility), neutral frames, and the Ockhamist/super-
valuationist treatments of future contingents.

### Relevance to Layer 1 (g function trivial)

**Very low relevance.** The T×W and Kamp frames have no chronicle construction and no interval
function g. The paper's canonical model is based on "neutral frames" where worlds and moments are
organized by temporal and alternativeness relations, but there is no explicit tracking of interval
content. The diagram-completion property (Definition 10, condition 5) is interesting: it requires
that if a~a' and b <_w a, then there exists b' ~b with b' <_{w'} a'. This is a form of modal
saturation at the boundary between worlds, which is structurally related to the g-function problem
(ensuring that interval content propagates at inserted points), but the analogy is very loose.

**Confidence**: Very low.

### Relevance to Layer 2 (guard convention mismatch)

**Low relevance.** The chapter does not discuss Until/Since operators at all. The modal operators
are O (necessity/historically-necessary) and the usual P, F, H, G tense operators. The satisfaction
conditions for F and P use the standard linear-time semantics with no guard interval. There is no
analogue of the open/half-open guard issue.

**Confidence**: Very low.

### Relevance to Layer 3 (domain extension / density)

**Medium relevance.** The T×W frame definition (Definition 6) and Kamp frame (Definition 9) both
use linear temporal orderings. The Kamp axioms (AK1)–(AK13) provide a relevant model:

- AK5: PGp → p (past of "always in future p" → p holds now) — this is the density-like
  condition that arises when combining tense with modality.
- AK6: FHp → p (future of "always in past p" → p holds now) — mirror image.
- AK10: □p → p (necessity implies actuality) — S5 axiom T.
- AK11: □p → □□p — S5 axiom 4.
- AK12: □Pp → P□p — cross-axiom connecting modality and past tense.

The BX axiom system is exactly this kind of combination. AK12 is analogous to BX's interaction
axioms. **The key insight**: Thomason notes (p. 149) that the T×W system (AK0)–(AK13) + (RK0)–
(RK3) is sound and complete for neutral frames, but NOT for Kamp frames (formula (17) is
independent). Adding Gabbay's irreflexivity rule RG2 gives Kamp completeness.

For BX, this suggests: the chronicle's domain X (a sparse subset of Q) corresponds to a single
"world" in a T×W/Kamp frame. The S5 modality (Box) is the □ operator satisfying AK9–AK11. The
completeness of BX over all strict linear orders (like Burgess's LO completeness) corresponds to
neutral frame completeness. Extending to specific linear orders (like Q or Z) corresponds to
imposing additional axioms.

**The GGp→Gp concern** maps directly to AK5/AK6 in Thomason's framework: if the domain is all
of Q (dense), then p → PFp and p → FPp hold (density axioms), and combined with the modality,
GGp→Gp becomes derivable. Restricting to a sparse X avoids this.

**Confidence**: Medium for Layer 3 conceptual confirmation; Low for providing new techniques.

### Relevance to BX's specific architecture

**Medium direct relevance.** Thomason's Section 4 (technical side) is the most relevant. The
neutral frame completeness result (p. 150) shows that a canonical model built from MCS of the
bimodal language is a neutral frame. BX's BFMCS (Bimodal-Full-Maximal-Consistent-Set) approach
corresponds to building a neutral frame from MCS.

The **Kamp frame interpolation property** (Figure 1, p. 149): given moments t₁ < t₃ in world w
and a moment t₁' in world w' with t₁~t₁', one must be able to interpolate t₃' in w' with t₃~t₃'
and t₁' < t₃'. This is structurally identical to the chronicle's PointInsertion lemmas: given
domain points x and y in the chronicle, and a formula to be witnessed between them, insert a new
point z with the right MCS content. The interpolation requirement in Kamp frames is essentially
the chronicle's counterexample elimination obligation.

**Key passage**: The incompleteness formula (17) (p. 149) and its Kamp validity. This formula
expresses a constraint on the temporal structure that neutral frames don't satisfy but Kamp frames
do. For BX, the analogous formula would involve the interaction of Box with G/H in a way that
requires interpolation. The BX chronicle construction must ensure this interpolation property —
this is exactly what C4/C5 counterexample elimination is for.

**Confidence**: Medium. The Kamp frame interpolation property is structurally analogous to C5
counterexample elimination, providing conceptual validation for the chronicle approach.

---

## Cross-Source Synthesis

### Layer 1: g Function (Critical Gap — No Direct Fix Found)

None of the five sources provides a direct technique for making the chronicle's g function
non-trivial. The closest analogs are:

- **Burgess 1982b, Section 2.3**: The characterization of I(V) valuations as distributive +
  weakly cumulative suggests g(x, y) should be the set of formulas holding "throughout" (x, y).
- **Burgess 1984, augmented frames**: The closure conditions on admissible propositions (gA, hA
  operations) define what interval content should be.
- **Thomason 1984, Kamp interpolation**: The interpolation property in Kamp frames is what the
  g function infrastructure is trying to implement.

The recommended approach (based on report 15's recommendation): define g(x, y) = {φ | Gφ ∈ f(x) ∧
all domain points z with x < z < y have φ ∈ f(z)}. This matches the Burgess homogeneous valuation
characterization and gives a non-trivial g that propagates via C3.

### Layer 2: Guard Convention (Partial Fix via Venema + BX9)

Venema 1993's strict-open Until semantics confirms that C5's open guard (x < z < y) is correct
for the base Until semantics. The bridge to BX's half-open [t, s) semantics requires:

1. At the starting point t: BX9 gives φ U ψ → φ ∨ ψ (or appropriate axiom depending on exact
   BX9 content). If ψ holds at t, the Until is immediately satisfied. If φ holds at t (but not ψ),
   then we have the guard formula φ at the starting point.
2. Venema's A3a pattern: if p holds at t and U(q, r) holds at t (with open guard q between t and
   the witness), then U(q ∧ S(p, r), r) holds at t — the starting-point formula p gets
   incorporated into a strengthened Until.

The practical fix: prove a separate lemma `starting_point_satisfies_guard` showing that if
φ U ψ ∈ f(t) then either ψ ∈ f(t) (immediate truth) or φ ∈ f(t) (guard at t satisfied by MCS
membership). This bridges the open guard C5 to the half-open truth semantics.

### Layer 3: Domain / Density (Confirmed: Sparse X is Correct)

All relevant sources confirm:
- Burgess 1982b: Q-based completeness for S (with Gp → p). Without Gp → p, Q validates it anyway.
- Burgess 1984: Dense orders add GGp→Gp to the Diodorean fragment.
- Thomason 1984: AK5/AK6 in Kamp frames are density-like axioms that arise from Q-based domains.
- Venema 1993: Well-ordering completeness avoids density concerns entirely.

The recommendation is confirmed: the chronicle must be built over a sparse X ⊂ Q (as in Burgess
1982a), not over all of Q.

---

## Recommendations for Implementation Plan v5 (Task 107)

1. **Layer 1 fix (g function)**: Define g(x, y) as the formula content determined by C3 at
   insertion time. Specifically, when inserting z between x and y to witness φ U ψ: set
   g(x, z) = {α | Gα ∈ f(x)} and g(z, y) = {α | Gα ∈ f(z)}. This matches the augmented-frame
   closure conditions from Burgess 1984 and the distributive+weakly-cumulative characterization
   from Burgess 1982b.

2. **Layer 2 fix (guard)**: Use Venema's A3a pattern to prove a `starting_point_guard` lemma.
   The BX9 axiom gives φ U ψ → φ ∨ ψ; this handles the starting point without requiring C5 to
   be half-open. The open-guard C5 is semantically correct for BX (confirmed by Burgess 1982b's
   Gp → p being the distinguishing axiom for period-based vs. instant-based logic).

3. **Layer 3 (domain)**: Sparse X ⊂ Q is confirmed as the correct approach. The Venema 1993
   "build then repair" strategy (build over Q, then transfer to sparse X) is viable if expressive
   equivalence can be established. However, direct construction over sparse X (as Burgess 1982a
   does) avoids the transfer step.

4. **Box case architecture**: Thomason 1984's neutral frame → Kamp frame interpolation pattern
   confirms that the BFMCS construction (with S5 saturation for Box) is the correct approach.
   The interpolation property in Kamp frames is exactly what chronicle counterexample elimination
   provides.

---

## Confidence Summary Table

| Source | Layer 1 | Layer 2 | Layer 3 | Overall Utility |
|--------|---------|---------|---------|----------------|
| Burgess 1982b | Low | Medium | High | High |
| Venema 1993 | Low | High | Medium | High |
| Obendrauf 2024 | Medium | Low | Low | Medium (Lean patterns) |
| Burgess 1984 | Low | Medium | High | Medium |
| Thomason 1984 | Very Low | Low | Medium | Low-Medium |
