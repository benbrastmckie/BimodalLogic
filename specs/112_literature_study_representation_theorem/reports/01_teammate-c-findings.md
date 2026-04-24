# Teammate C Findings: Critical Gaps and Overlooked Results

**Task**: 112 - Systematic literature study for representation theorem
**Role**: Critic — identifying gaps, shortcomings, and blind spots
**Completed**: 2026-04-24

---

## Executive Summary

The five literature sources contain several results and warnings that the task 107
research rounds have not adequately engaged with. The most serious omissions are:

1. **Burgess 1984 describes the g-function problem explicitly** — the interval
   function in period-based semantics is the subject of an entire section, and
   Burgess explicitly warns that its treatment is controversial and requires
   careful restriction to "homogeneous valuations." The codebase's `g = ∅` problem
   is not an implementation oversight — it reflects a deep theoretical ambiguity
   that Burgess himself flags as an open problem.

2. **Venema 1993 contains an explicit warning about the irreflexivity rule** that
   is directly relevant to the C5 guard convention mismatch. The open vs.
   half-open issue is not just a convention disagreement — it connects to whether
   the system can be axiomatized with standard (orthodox) rules or requires the
   non-standard IR-rule.

3. **Thomason 1984 identifies an incompleteness result** for the standard
   bimodal axiomatization (Kamp's AK0–AK13 + RK0–RK3) that is precisely of the
   kind the BX construction must avoid. The interpolation property (formula 17)
   is not derivable from standard axioms, and this has direct implications for
   the chronicle construction over branching/modal frames.

4. **Burgess 1982b's "homogeneity" requirement** is a hard prerequisite for the
   period-based completeness proof. If the current chronicle construction does not
   enforce homogeneous valuations, the truth lemma cannot hold even in principle.

5. **Obendrauf 2024 warns that "small implementation choices early in the
   formalization process can have unintended effects later."** The closure
   definition adjustment (adding all subformulas rather than just subformulas of
   the original formula) required to make the truth lemma work in Lean is exactly
   the kind of adjustment that may be needed for the chronicle construction but has
   not been identified as a gap.

---

## Source 1: Burgess 1982b — Axioms for Tense Logic II: Time Periods

### Overlooked Result: The Homogeneity Requirement Is Non-Negotiable

The completeness proof in Burgess 1982b does not work for arbitrary valuations.
It works only for **homogeneous valuations** — those satisfying both distributivity
(C1) and the generic/strongly-cumulative condition (C3/C4 of Section 2.2). This is
stated explicitly at Section 2, final paragraph:

> "For the remainder of the present note we will work only with homogeneous
> valuations."

The task 107 research identifies `g = ∅` as the critical gap (Layer 1), but does
not observe that the REASON the g-function must be non-trivial is exactly to enforce
homogeneity. Burgess shows (Proposition 2.3) that a valuation W in a period
structure is of the form `I(V)` (i.e., admits the "always true during a" reading)
if and only if W is **distributive and weakly cumulative**. The stronger form,
Proposition 2.4, shows that homogeneous valuations correspond exactly to
`J(V)` (the "almost always" reading, using the interior-closure-interior topology).

**The implication for the chronicle construction**: The chronicle's interval
function `g(x,y)` is the MECHANISM by which the "almost always true during [x,y]"
reading is enforced. With `g = ∅`, the chronicle makes no commitments about what
is true during any interval, which means the induced valuation cannot be homogeneous,
which means the truth lemma cannot hold for period-based semantics. This is a deeper
theoretical gap than Layer 1 as diagnosed in the team research — it is not just that
g needs updating, but that the AXIOMS governing g must enforce the C1/C4 conditions
of Burgess 1982b.

**Questions that should be asked**:
- Does the current chronicle definition (C3) correspond to distributivity (C1) or
  weak cumulativity or something else entirely?
- Is BX completeness being proved for period-based semantics at all, or for
  instant-based semantics where g plays a different role?

**Confidence**: High.

### Overlooked Result: Negation in Period Semantics Is NOT Classical

Burgess 1982b Section 3.1 defines:

```
W(~α) = {a : ∀b ⊆ a, b ∉ W(α)}
```

This is the **intuitionistic** negation from Kripke semantics for intuitionistic
logic, NOT classical negation. Burgess explicitly notes that classical truth-function
tautologies are NOT automatically valid (they are valid only because for conjunction
and negation, intuitionistic and classical logic coincide — Lemma 3.3, which invokes
Gödel's theorem).

**The implication for BX**: If the semantics of BX is based on instant-time (not
period-time), this is not a problem. But if the Lean formalization uses `¬a ∈ g(x,y)`
to mean "¬a is always true throughout [x,y]", then the negation is period-based
and must use the intuitionistic reading. The BX9 axiom `(φ U ψ) → (φ ∨ ψ)` has
different status depending on which reading of negation is in use.

**Confidence**: Medium. The issue depends on whether TaskFrame semantics are
instant-based or period-based.

---

## Source 2: Venema 1993 — Since and Until (Completeness via Completeness)

### Key Result Not Raised in Task 107: The Irreflexivity Rule

Venema opens his paper with a critical methodological warning about the
**irreflexivity rule (IR)**:

```
⊢ (q ∧ H¬q) → φ ⟹ ⊢ φ,   for all φ and atoms q not occurring in φ
```

Venema notes that this rule is needed by Gabbay and Hodkinson's completeness
proof for `(R, <)`, but that:

1. IR breaks the "orthodox" paradigm (only MP, TG, SUB)
2. IR "can be seen as a break with the paradigm in modal logic not to use symbols
   referring to worlds/time points"
3. Orthodox axiom systems have better mathematical properties (ultraproduct closure)

**The direct connection to the C5 guard mismatch**: The open vs. half-open guard
problem (Layer 2 in team research) is precisely about whether the starting point
of an Until-interval is included in the guard. This is equivalent to whether the
logic is **reflexive** (t ≤ t) or **irreflexive** (t < t strictly). Venema's paper
shows that for strict (irreflexive) linear orders, completeness WITHOUT the
IR-rule requires significant extra work.

**Overlooked implication**: If the BX semantics use `t < s` (strict Until), but the
proof uses Henkin witnesses at the starting point `t`, the proof is implicitly using
a reflexive reading at the witness-construction stage. This is exactly what the
"C5 weak" problem amounts to. Venema's paper shows that over well-orderings
(WO), completeness IS achievable with orthodox rules — but only because WO has
no gaps. Over dense linear orders (which the chronicle constructs), the situation
is more delicate.

**Overlooked result: Stavi connectives and gaps**

Venema Section 2.3 defines the Stavi connectives `U'` and `S'`, which handle
**gaps** in linear orders — downward-closed sets without a supremum. These
connectives are needed for expressive completeness over arbitrary linear orders.
The fact that the BX chronicle creates a dense linear order by inserting midpoints
means that gap-handling becomes relevant whenever the completeness proof attempts
to extract a model from the chronicle. The task 107 research does not mention Stavi
connectives at all.

**Question that should be asked**:
- Does the BX completeness proof need an analogue of Stavi connectives because the
  chronicle's limit construction may create gaps?

**Confidence**: Medium-high for the IR/guard connection. Low-medium for Stavi
connectives (depends on the details of the limit construction).

### Overlooked Assumption: Discreteness vs. Density

Venema's Theorem 4.3 shows completeness for `(ω, <)` (natural numbers, discrete
order). His Theorem 4.2 is for well-orderings generally. The team research considers
the Int chain (over Z) as an alternative domain. Venema's result shows that discrete
well-ordered frames have complete axiomatizations with standard rules — which
suggests that the Int chain approach is semantically sound for certain classes of
BX validity. But Venema's completeness is for `S` and `U` (Since and Until) only,
NOT for a combined tense + S5 modality system.

**Confidence**: Medium.

---

## Source 3: Obendrauf 2024 — Lean Formalization of Coalition Logic

### Explicit Warning About Closure Definitions

Section 8.2 of Obendrauf 2024 contains the following warning that is directly
applicable to the BX truth lemma:

> "The closure definition thus illustrates that small implementation choices early
> in the formalization process can have unintended effects later in the proof that
> may not be immediately obvious."

The specific issue they encountered was that the closure `cl(φ)` needed to be
closed under ALL subformulas of its elements (not just subformulas of the original
formula φ) in order for the truth lemma induction to work. This required changing
the closure definition from the paper proof.

**The direct application to BX**: The chronicle's current C3–C5 conditions govern
what belongs to the interval `g(x,y)`. If these conditions are not closed under
some operation analogous to Obendrauf's modified `cl`, the truth lemma induction
will get stuck at some complexity level. The specific risk is the **Until/Since
case** — Obendrauf finds the Common Knowledge induction most complex precisely
because it mirrors the Until/Since induction in temporal logic (both involve
iterating through a chain of steps).

**Overlooked result: Three-level data type management**

Obendrauf 2024 notes that the need to work with `Set`, `Finset`, and `List` types
creates significant proof burden. The BX formalization faces an analogous issue:
the chronicle's interval function `g(x,y)` must interact with:
- The infinite limit construction (requires `Set`)
- Finite counterexample elimination steps (requires indexing, closer to `List`)
- The semantic truth predicate (requires extensional equality)

The task 107 research has not identified the **data type impedance** between the
omega-chain construction and the semantic truth predicate as a distinct source of
complexity.

**Confidence**: High for the closure warning. Medium for data type impedance.

### Overlooked Technique: Typeclass Generalization for Reuse

Obendrauf's main contribution is showing that a single canonical model construction
can be **factored through typeclasses** so that results about CL automatically
apply to CLC. The BX project currently uses a parametric approach (over `D`
with `AddCommGroup`). But there is an alternative: prove completeness for a
minimal typeclass, then instantiate. This is precisely what the team research
recommends (a "sparse X" approach), but Obendrauf's implementation shows exactly
HOW to do this in Lean with typeclasses — a technique the task 107 research does
not mention.

**Confidence**: High. This is actionable.

---

## Source 4: Burgess 1984 — Basic Tense Logic

### The Chronicle Construction's Actual Structure

Burgess 1984 Section 2.2 gives the ACTUAL definition of a chronicle and the
Killing Lemma. The key observation is that Burgess's chronicle construction
for total orders differs from the general (Section 1) construction in one critical
way: **a point is inserted BETWEEN two existing points**, not appended at the end.

The Killing Lemma for total orders (Section 2.2, p. 104) inserts a midpoint z
between x and the immediate successor x' by setting:

```
B = chosen MCS with T(x) ⊆ B
Insert z between x and x'
T'(z) = B
```

The **order condition** for the inserted point is:
```
R' = R ∪ {(x,z), (z,x')} ∪ {(v,z) : vRx} ∪ {(z,v) : x'Rv}
```

This is the `PointInsertion` mechanism that appears in the codebase. But notice:
Burgess's Killing Lemma uses `T(x) ⊆ B` (the "successor consequence" relation),
NOT `g_content(f(x)) ⊆ B`. The `g` function (interval function) does NOT appear
in Burgess 1984's chronicle definition at all for the basic G/H/F/P language.

**Critical finding**: The `g` function is a feature of the Until/Since extension
(Section 4A), NOT of the basic chronicle construction. The team research treats
`g = ∅` as a "Layer 1" infrastructure gap, but this conflates two different
components of the construction:

- The basic chronicle (G, H, F, P) does NOT use g
- The Until/Since extension (Section 4A) requires a different mechanism

**Overlooked distinction**: Burgess 1984 Section 4A defines U and S as derived
operators with their own first-order definitions (Examples 4.2, items 5 and 6):

```
U(p, q): ∃y(x < y ∧ P(y) ∧ ∀z(x < z ∧ z < y → Q(z)))
S(p, q): ∃y(y < x ∧ P(y) ∧ ∀z(y < z ∧ z < x → Q(z)))
```

The completeness proof for the U/S logic (Section 4A, p. 120) adds axioms
but does NOT describe a separate chronicle construction with a `g` function.
The reference is to Burgess [1982] (which is not one of the five study sources)
for the axioms, and to expressive completeness (Kamp's theorem) for the
completeness method.

**What this means for the codebase**: The `g` function in `ChronicleTypes.lean`
may be a non-standard extension that is NOT directly traced to Burgess 1984. The
team research does not identify the origin of `g` in the codebase. This is a
significant blind spot.

**Questions that should be asked**:
- Where does the `g` function originate? Is it from Burgess 1982a (not studied)?
  From the BX-specific construction? From a different completeness proof strategy?
- If `g` is not in Burgess 1984's chronicle, what is the theoretical justification
  for using it in the BX chronicle?

**Confidence**: High.

### The Density Lemma Is for MIDPOINT INSERTION, Not Limit Points

Burgess 1984 Section 2.5 gives the density lemma:

> **Lemma**: Let A, B be MCSs with A ⊆ B. Then there exists an MCS C with A ⊆ C
> and C ⊆ B.

This is used to show that between any two adjacent chronicle points, a new point
can be inserted. The key property used is axiom A5a (density: `Gp → GGp` or
equivalently the forward density axiom).

**The problem with the omega-chain limit**: The task 107 research notes the
`GGp → Gp` concern (Layer 3). Burgess's construction NEVER constructs a limit —
it keeps inserting points finitely many times and then appeals to Lindenbaum's
lemma at the omega-limit. The key property of the omega-limit is that any
**single** requirement that was alive at some finite stage was killed at a later
finite stage. The limit itself does not need to satisfy a density requirement —
it is already a dense linear order by construction.

**Overlooked issue**: The concern about `GGp → Gp` failing at limit points is
NOT a concern in Burgess's construction because the construction ensures that
every locally satisfiable formula gets a witness within finitely many steps.
If the codebase's omega-chain construction fails on `GGp → Gp`, this indicates
that the killing strategy is NOT faithful to Burgess's construction.

**Confidence**: Medium-high.

### Irreflexivity and Antisymmetry

Burgess 1984 Section 1 (p. 101) explicitly notes that the completeness proof
works for the class of **antisymmetric** frames (not just any frames). He notes
that the alternative "canonical model" approach (using MCSs as worlds with the
`⊆` relation) produces a non-antisymmetric frame, and that "bulldozing" is
needed to convert it.

The BX chronicle must produce a STRICT linear order (for the semantics to
correctly handle G/H operators). If the chronicle's domain is not antisymmetric,
the semantics are broken before the truth lemma is even attempted.

**Confidence**: High.

---

## Source 5: Thomason 1984 — Combinations of Tense and Modality

### Critical Finding: Standard Axioms Are INCOMPLETE for Bimodal Frames

The most important finding from Thomason 1984 is the incompleteness result
described in Section 4, relating to formula (17):

```
[PE₁(p) ∧ □PE₁(q)] → [P[E₁(p) ∧ P□E₁(q)] ∨ P[□E₁(q) ∧ □E₁(p)] ∨ P[E₁(q) ∧ □E₁(p)]]
```

where `E(φ) = Fφ ∧ G[φ ∨ Pφ]`.

This formula is valid in Kamp frames (Definition 9: worlds with separate linear
orders linked by accessibility relations) but is NOT derivable from Kamp's
axioms AK0–AK13 + RK0–RK3. The missing property is **interpolation** — the
ability to insert an "alternative time" in one world when given corresponding
times in another.

**The direct implication for BX**: BX combines S5 modal operators with tense
operators. The key BX axioms that govern the interaction are the BX-specific
bimodal axioms (not the pure tense or pure modal axioms). Thomason's result shows
that getting the bimodal interaction right requires **additional axioms** beyond
the obvious combination of S5 and linear tense logic.

Specifically, Thomason shows (p. 148–150) that the correct axiomatization requires
either:
- Gabbay's irreflexivity rule (RG1/RG2) — non-orthodox
- Or additional interpolation axioms that are Kamp-valid but not obvious

**The team research does not address this at all.** The chronicle construction
for BX must be extended to handle the bimodal interaction. The standard chronicle
(coherent, prophetic, historic) is for PURE tense logic. For BX, an additional
"modal coherence" condition is needed — analogous to the condition that worlds
accessible via `□` share the same temporal structure.

**Questions that should be asked**:
- What additional conditions does the BX chronicle impose on the modal accessibility
  relation between chronicle points?
- Has anyone verified that the BX axioms are sufficient for the interpolation
  property that Thomason shows is needed?

**Confidence**: High for the existence of this gap. Medium for its exact impact
on the chronicle construction.

### Thomason's Warning: Combining Time and X Is Non-Trivial

Section 1 of Thomason 1984 opens with a general warning (p. 135):

> "The general moral, then, is that we shouldn't expect the theory of time + X
> to be obtained by mechanically combining the theory of time and the theory of X!"

This is directly applicable to BX = tense + S5. The BX project has axioms that
govern the bimodal interaction (AK12 type), but the completeness proof cannot
simply combine a tense chronicle with an S5 canonical model. The interaction
creates new requirements on the construction.

**Thomason's T×W formulation** (Definition 6, p. 146) provides the mathematical
framework: a T×W frame has worlds W, times T, and accessibility relations `~_t`
(historical alternatives). The key validity is AK12:

```
□Pp → P□p
```

This says that if something is modally necessary now, then it was temporally past
that it was modally necessary. In the BX chronicle, this axiom generates a
coherence condition: if `□φ ∈ T(x)` (modally necessary at time x), then there
must exist a y with yRx and `□φ ∈ T(y)`.

**The BX chronicle must handle this** — but the task 107 research treats the
chronicle as primarily about Until/Since witnesses and does not discuss the Box
case of the killing lemma.

**Confidence**: High.

### Thomason's Definition 7: Assignment Restrictions

Thomason notes (Definition 7, p. 146) that in T×W frames, assignments must
satisfy a CONSTRAINT:

> "if w~_t w' and t₁ < t then (t₁, w) ∈ h(p) iff (t₁, w') ∈ h(p)"

This constraint says that at any time, two worlds that are historically
indistinguishable must agree on all atomic facts up to the present. This is the
"shared past" constraint.

**In the BX chronicle**, the modal operator □ corresponds to S5 accessibility.
The shared-past constraint means that if two MCSs M₁ and M₂ are □-accessible from
a common ancestor, they must agree on all "settled" (past) facts. The BX axioms
should enforce this, but the team research does not explicitly verify that
the chronicle construction respects this property.

**Confidence**: Medium.

---

## Cross-Source Critical Assessment

### The Central Blind Spot: What Kind of Construction IS This?

The five sources collectively reveal that there are at least THREE distinct
completeness proof strategies for related logics, and it is not clear which
strategy the BX chronicle is implementing:

1. **Burgess 1984 style** (chronicle = coherent + prophetic + historic):
   - Works for G/H/F/P logic over various classes of total orders
   - Does NOT use a `g` function
   - Uses point insertion (Killing Lemma) to satisfy F-requirements
   - Straightforward, well-documented

2. **Burgess 1982b style** (period semantics with homogeneous valuations):
   - Works for G/H/F/P logic over dense total orders
   - DOES use a homogeneity condition that the `g` function is meant to enforce
   - The interval function encodes "truth throughout a period"
   - More complex, requires the I(V)/J(V) distinction

3. **Venema/Burgess 1982a style** (Until/Since completeness):
   - Works for U/S logic over well-orders or dense orders
   - Uses Lindenbaum constructions with specific U/S witness conditions
   - Completeness proved via expressive completeness (Kamp's theorem) + frame morphism

The BX chronicle appears to mix elements from all three strategies. The `g` function
suggests Strategy 2 (period semantics), but the Killing Lemma structure suggests
Strategy 1. The Until/Since witnesses suggest Strategy 3. **This mixture may be
inherently inconsistent**, or may be a novel approach that has not been properly
documented.

**This is the most serious gap not identified in the team research.**

### Assumption Not Validated: Linearity of the Chronicle

Burgess 1984 Section 2.2 notes that for total-order completeness, the Killing
Lemma must produce a TOTAL order. The proof uses the comparability lemma
(p. 103) to show that any two inserted MCSs are comparable under `⊆`.

The BX chronicle must also produce a linear order (or some analogue). If the
chronicle's insertion mechanism can produce non-linear (partial) orders, the
truth lemma fails for G/H operators.

**The team research has not verified linearity of the omega-chain limit.**

**Confidence**: High.

### Explicit Warning Not Heeded: Decidability Lost with Metric/Modal Combinations

Burgess 1984 Section 6.1 (Metric Tense Logic) explicitly proves that **decidability
is LOST** when tense logic is combined with metric operators (operators that measure
time distances). The proof reduces the decision problem to that of all universal
monadic formulas over ordered Abelian groups, which is unsolvable.

BX uses an `AddCommGroup` structure for the time domain. While BX is not metric
tense logic, the AddCommGroup requirement means the time domain has the structure
of an ordered Abelian group. The team research treats the AddCommGroup as a mere
technical convenience (for `time_shift`), but it may have deeper implications for
the completeness theory.

**Questions that should be asked**:
- Is BX decidable? (The team research does not address this.)
- If BX requires AddCommGroup, does this create any obstacles for constructing
  models over domains where AddCommGroup holds?

**Confidence**: Medium. The concern is theoretical, not immediately blocking.

---

## Summary: Gaps Ranked by Severity

| Gap | Source(s) | Severity | Confidence |
|-----|-----------|----------|------------|
| `g` function has wrong theoretical basis (not from Burgess 1984's chronicle) | Burgess 1984, Burgess 1982b | Critical | High |
| Bimodal interaction requires additional chronicle conditions beyond pure tense | Thomason 1984 | Critical | High |
| Homogeneity requirement is a hard prerequisite for period semantics | Burgess 1982b | Critical | High |
| C5 guard (open vs half-open) connects to irreflexivity rule controversy | Venema 1993 | High | High |
| No verification of linearity in the omega-chain limit | Burgess 1984 | High | High |
| Closure definition for Until/Since may need adjustment (Obendrauf lesson) | Obendrauf 2024 | High | High |
| The construction mixes three distinct proof strategies inconsistently | All five sources | High | Medium |
| Stavi connectives may be needed for gap-handling in limit | Venema 1993 | Medium | Low-Medium |
| Burgess 1984's BX section uses AK12 interaction axiom not in killing lemma | Thomason 1984 | Medium | Medium |
| Decidability implications of AddCommGroup not examined | Burgess 1984 | Low | Medium |

---

## Questions That Should Be Asked But Are Not Being Asked

1. **What is the origin of the `g` function in the BX chronicle?** Which paper
   introduces it, and what properties does it need to satisfy for the truth lemma?

2. **Is the BX chronicle implementing period semantics or instant semantics?**
   If period semantics, homogeneity (Burgess 1982b) is required. If instant
   semantics, `g` is irrelevant and the standard chronicle suffices.

3. **How does the chronicle handle the bimodal interaction (tense + S5)?**
   Thomason 1984 shows this is non-trivial and requires interpolation conditions
   beyond the pure tense killing lemma.

4. **Is the omega-chain limit guaranteed to produce a LINEAR order?**
   Burgess 1984's completeness proof crucially depends on this.

5. **Does the BX completeness proof require the irreflexivity rule, or can it
   use orthodox rules?** The answer affects whether the C5 guard convention
   (open vs. half-open) is a fundamental issue or a fixable implementation detail.
