# Report 09 (Teammate A) — Rabinovich's Recursion-Carrier Structure

- **Task**: 349 — build recursive `endChar`/`endInterval` (navigated arity-3 endpoint primitive)
- **Angle**: A — EXACT type/structure of the object Rabinovich's recursion carries and produces
- **Mode**: `--hard` (H2/H3/H4/H5), `--lit`. Reference tier: **Tier 1** (literature-backed, lean4 strict)
- **Session**: sess_1783841542_df767b
- **Authority**: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`
  (cited as `md:NNN`). **The paper is the sole authority.** Reports 05/06/07/08 are cross-referenced,
  not repeated; where any of them conflicts with the paper text, the paper wins and the conflict is
  flagged (§5).

---

## 0. Verdict up front (the carrier re-type decision)

Rabinovich's recursion carrier through the hard part of the proof (§5) is a **two-free-variable
object** `[α0, β1, …, αn](z0, z1)` with **exactly two explicit free endpoint variables** `z0, z1`
(`md:207`, `md:219`, Def 7.5 `md:407`). Its interior anchor points `x1 < … < x_{n-1}` are
**existentially bound**, not free (`md:225`). Its interior data are **one-variable quantifier-free
point/interval predicates** `αi, βi` (`md:111`, `md:209`) — NOT closed sentences, NOT two-endpoint
pieces.

- **Nominal type**: a **syntactic** first-order `→∃∀`-formula ("the abbreviated notation … for the
  →∃∀-formula", Notation 5.2 `md:219`; Def 3.1 `md:109-111`).
- **Operational type**: every recursion step (negation, case split, infimum, composition) is defined
  and justified **semantically** — via the satisfaction relation over Dedekind complete chains
  (`md:285-303`, `md:229-247`). The object is *constructed* as a formula but *only ever used through
  its Prop-meaning at the two endpoints* until the free-variable count drops to one.
- **Syntax matters at exactly one place**: the collapse to a `TL(Until,Since)` formula (Proposition
  3.5, `md:137`), whose **precondition is exactly one free variable** and whose **output** is a TL
  formula. This is the recursion's *exit*, not its carrier.

**Faithful Lean carrier verdict**: a **Prop-valued two-endpoint interval predicate** (option D) is
the faithful carrier of the *recursion*, because it (a) enforces the two-free-variable discipline the
paper enforces, (b) realizes composition exactly as Rabinovich's bounded-∃ conjunction (Def 7.13
`md:451`, Fig. 1 `md:299`, Lemma 7.6 `md:413`) with no arity-`m` detour, and (c) needs a *syntactic*
TL formula only at arity 1 (Prop 3.5), the recursion's exit. The **single-point** carrier
(`NormalForm → TemporalPred`, v4/v5) is **refuted** by the paper; the **syntactic `VVecEA2`** carrier
(v6) is **structurally faithful to the bracket** but forces the composition to go through the
arity-`m` `VVecEA_m` family that lacks the `m→2` existential-collapse the paper's composition
actually uses.

---

## 1. Precise statement of the recursion-carrier TYPE (with `md:` citations)

### 1.1 The base normal form is a syntactic formula with a fixed free-variable count

**Definition 3.1** (`md:109-111`): a `→∃∀`-formula has "a prefix of `n+1` existential quantifiers,
with all `αj, βj` **quantifier free formulas with one variable** over Σ", and "`m+1` free variables
`z0,…,zm`". So:

- The carrier is **syntactic** (a first-order formula).
- The `αj, βj` are **one-free-variable** quantifier-free predicates (point predicates). They are
  neither closed sentences nor multi-endpoint objects.
- The **free-variable count is an explicit invariant** of the object (`m+1`).

**Lemma 3.2(2)** (`md:119`): "Every `→∃∀`-formula is equivalent to a **conjunction of `→∃∀` formulas
with at most two free variables**." This is the reduction that drives the whole proof down to the
2-free-variable regime. The reduced object's type: a conjunction of `≤2`-free `→∃∀` formulas
(each conjunct still a syntactic `→∃∀` formula).

### 1.2 The §5 interval bracket: two free variables, existentially-bound interior

**Lemma 5.1 / Notation 5.2** (`md:207-209`, `md:219`): the object of the hard part is
`[α0, β1, …, α_{n-1}, βn, αn](z0, z1)`, an abbreviation "**for the →∃∀-formula as in (5.1)**", where
"`αi, βi` are **quantifier free**" (`md:209`). Reading the alternating list against Lemma 5.3
(`md:225`) and Fig. 1 (`md:299`):

| Symbol | Role | Where it is read |
|---|---|---|
| `α0` | point predicate | at `z0` (= `x0`, a **free** endpoint) |
| `βi` | interval predicate | **along** the open segment `(x_{i-1}, x_i)` |
| `αi` (`0<i<n`) | point predicate | at `xi`, an **existentially bound** interior anchor |
| `αn` | point predicate | at `z1` (= `xn`, the other **free** endpoint) |

**Lemma 5.3** (`md:225`) makes the existential-witness structure explicit for the `βi=True` instance:
`∃x1 … ∃xn (z0 < x1 < … < xn < z1) ∧ ⋀ Pi(xi)`. The interior points are **∃-bound**; only `z0, z1`
are free.

**Definition 7.5** (`md:407`) names this two-free-variable class directly: a formula of the form
`[α0, β1 …, αn](z0, z1)` (or `z0>z1`, `z0=z1`) "is called a **`(z0,z1)`-`→∃∀` formula**". Its free
variables are exactly `z0` and `z1`. **Free-var count of the whole §5 carrier = 2.** ✔ (satisfies the
"≤2" requirement in the mission).

### 1.3 The recursion carries a two-endpoint object and re-anchors one endpoint per step

The recursion of the hard part (Lemma 5.3 induction `n ↦ n+1`, `md:229-247`; Cor 5.4 induction
`md:261-277`; Lemma 5.1 Case-3 induction `md:305-335`) has this invariant:

- **IH provides** at level `n`: `On(P1,…,Pn, z0, z1)` — a **`∨→∃∀` formula** (a syntactic formula,
  `md:225`) with **two free endpoints** `z0, z1` plus predicate parameters `Pi`.
- **Step `n ↦ n+1`** (`md:231-247`): peel the first predicate `P1`; by **Dedekind completeness** let
  `r0 = inf{z ∈ (z0,z1) | P1(z)}` (`md:233`); then **re-anchor the left endpoint** from `z0` to the
  definable interior point `r0` and recurse: `On(P2,…,Pn, r0, z1)` (`md:237`, `md:245`). `r0` is
  itself pinned by a `∨→∃∀` formula `INF` (`md:233`, and `INF^{¬β1}` at `md:303`).
- **Output** `On+1` (`md:239-247`): a **disjunction** of `"(z0,z1) empty"`, `(∀y)_{z0}^{z1} ¬P1`,
  `K⁺(P1)(z0) ∧ On(P2,…, z0, z1)`, and `(∃r0)_{z0}^{z1}[INF ∧ On(P2,…, r0, z1)]`. Still a
  **two-free-variable `∨→∃∀` formula**.

So at **every** step the carried and produced object has **exactly two explicit free endpoints**; the
recursion never reads the object at a single point, and never lets the free count exceed two. The
*construction* is syntactic (a formula is assembled), but the *justification* is entirely semantic
(`inf`, "such `r0` exists by Dedekind completeness", case analysis on satisfaction — `md:231-247`,
`md:285-303`).

### 1.4 Single-point collapse is the EXIT, at arity 1 only

**Proposition 3.5** (`md:137`, `md:139-143`): "Every `∨→∃∀`-formula **with one free variable** is
equivalent to a `TL(Until,Since)` formula." Precondition: **exactly one free variable**; output type:
a **TL formula** (`Ai, Bi` temporal formulas, `md:141`). This is invoked only after the two-endpoint
machinery has reduced the free count to one (Theorem 4.4 `md:185-187`; §5 `k=m` collapse `md:199`).
The single-point object is therefore Rabinovich's **terminal output type**, not his **recursion
carrier type**.

---

## 2. How composition (Def 7.13) works — semantic vs syntactic — and the Lean implication

### 2.1 Def 7.13 is SYNTACTIC conjunction of adjacent two-endpoint pieces

**Definition 7.13** (`md:451`): a `(z0, z1, …, zk, ∞)-→∃∀ formula` is "a **conjunction** `⋀_{i≤k} ϕi`,
where `ϕk` is a `(zk, ∞)-→∃∀` formula and `ϕi` is a `(zi, zi+1)-→∃∀` formula for `i < k`." So the
many-anchor object is a **syntactic conjunction (`∧`) of adjacent two-endpoint pieces**, each piece
being the §5 bracket over its own consecutive endpoint pair `(zi, zi+1)`. The pieces are **glued at
shared anchor variables** `z1, …, zk`.

**Figure 1** (`md:299`) shows the elementary case verbatim:
`B2(z0, z, z1) := [α0, β1, α1, β2, β2](z0, z) ∧ [β2, β2, α2, β3, α3](z, z1)`
— composition of two two-endpoint brackets that **share the middle variable `z`**, combined by
**syntactic `∧`**. Note the shared segment predicate `β2` appearing as both the right segment of the
left piece and the left segment of the right piece (the segment straddling the split point).

### 2.2 Re-collapse to two free variables is by BOUNDED existential quantification

The conjunction in §2.1 has `k+1` free variables (`z0,…,zk`), which **exceeds two**. Rabinovich
re-collapses to the two-free-variable regime by **bounded ∃ over the shared anchor**:

**Lemma 7.6** (`md:413`): "If `ϕ1` is a `(z0,z1)-∨→∃∀` formula and `ϕ2` is a `(z1,z2)-∨→∃∀` formula,
then `(∃z1)_{z0}^{z2}(ϕ1 ∧ ϕ2)` is a `(z0,z2)-∨→∃∀` formula." This is precisely the operation used in
§5 (`Corollary 5.4`, `md:255-259`: `¬(∃z)_{z0}^{z1}[…](z0,z)` etc.) to turn a three-free-variable
conjunction back into a two-free-variable object.

**Implication for the Lean carrier**: the faithful composition primitive is
`compose(P_L, P_R)(z0, z2) := ∃ z1, z0 < z1 < z2 ∧ P_L(z0, z1) ∧ P_R(z1, z2)` — a **bounded-∃
conjunction of two two-endpoint predicates**. This is a *Prop-level* operation (`∃`, `∧`) on
two-endpoint predicates. It is **not** an arity-raising lift into a free `m`-anchor tuple: the shared
anchor is **immediately existentially bound**, never exposed as a persistent free variable.

### 2.3 What this means: syntactic *shape*, semantic *composition law*

- Rabinovich's **piece** is nominally a syntactic bracket formula (Def 7.5, `md:407`).
- Rabinovich's **composition** is `∧` of pieces (syntactic) **immediately followed by bounded `∃`**
  over the join variable (semantic collapse), keeping the composite a two-endpoint object (Lemma 7.6,
  `md:413`; Fig. 1, `md:299`; Cor 5.4, `md:255`).

A Lean carrier is faithful iff its composition primitive is this `∃`-bounded conjunction over the
shared endpoint, restoring arity 2. A carrier whose composition instead *accumulates* free anchors
into an arity-`m` tuple (and defers the `∃`-collapse to a later, general `m→2` bridge) diverges from
the paper's composition law — the paper never holds more than the two working endpoints free.

---

## 3. Faithfulness verdict on each of the 3 carrier options vs. the paper

### Option A — Single-point `NormalForm → TemporalPred` (v4/v5) — **REFUTED**

A `TemporalPred` is read at **one** world. The paper's recursion carrier has **two** free endpoints
throughout §5 (`md:219`, `md:407`) and is never read at a single point until the free count drops to
one at the exit (Prop 3.5, `md:137`). A single-point carrier therefore models **only Prop 3.5's
output** (one free variable), not the recursion. **Confirmed unfaithful.** This matches the paper
directly and matches report 07's verdict and the machine guardrail `endCharN0_correct_infeasible`
(Base.lean:1779, cross-ref report 07/08 — a concrete 2-point countermodel derives `False`; a
one-world object cannot inhabit a two-endpoint target).

### Option v6 — Syntactic `NormalForm → VVecEA2` via `bracketFromLists` — **STRUCTURALLY FAITHFUL to the bracket; composition realized in the WRONG arity family**

- **Bracket shape is faithful.** The codebase `BracketFormula` (VecEAFormula.lean:128-169, verified
  this session) has `pointTypes : Fin n → TemporalPred`, `segmentTypes : Fin (n+1) → TemporalPred`,
  and `holds` = "**there exist** strictly increasing witnesses `x0 < … < x_{n-1}` in `(z0,z1)` such
  that point types hold at witnesses and interval types hold on all segments." This is an **exact**
  transcription of Rabinovich's `[α0,β1,…,αn](z0,z1)` (`md:219`, `md:225`): two fixed endpoints,
  ∃-bound interior anchors, one-variable point/interval predicates.
- **Terminology flag (§5 below).** Report 08 tags these interior `TemporalPred` as "**closed
  formulas**." Per the paper the `αi/βi` are **one-variable** quantifier-free predicates (`md:111`,
  `md:209`), NOT zero-variable sentences. "Closed" is faithful **only** in the sense of *closed with
  respect to the endpoints* (`αi/βi` do not mention `z0,z1`); each is still evaluated at a bound
  witness point, i.e. it is a one-variable predicate. Under that reading v6's interior is faithful.
  The mission's phrasing "interior slots are closed `List TemporalPred`" is therefore accurate as
  *endpoint-independent one-variable predicates*, and the alternative it contrasts against
  ("two-endpoint interior pieces") is **not** what the paper has: interior anchors are single points,
  not sub-intervals with two free ends.
- **Where v6 is contradictory (not a bracket-faithfulness problem):** a *syntactic* `VVecEA2` carrier
  forces (i) a `VVecEA2 → Formula` translation, and (ii) composition through the arity-`m`
  `VVecEA_m.liftInterval` family, whose output is an **arity-`m` free-anchor** object
  (`env : Fin m → carrier`), not the two-fixed-endpoint `VVecEA2` (cross-ref report 08 Q1). The
  paper's composition (Def 7.13 + Lemma 7.6, §2 above) **immediately `∃`-collapses** the join anchor
  back to arity 2; the `VVecEA_m` route instead accumulates free anchors and then lacks any general
  `m→2` existential-collapse bridge (`IsVEA`/`ArityReduction.lean` is an unbuilt existence predicate).
  **Verdict: the bracket carrier is faithful; the v6 *composition realization* diverges from the
  paper's bounded-∃ law.** The fix is to make composition the paper's `∃`-bounded conjunction, not to
  restore `liftInterval`.

### Option D — Prop-valued two-endpoint interval predicate — **MOST FAITHFUL to the recursion**

A `Prop`-valued predicate `P(z0, z1)` over the two explicit endpoints models exactly what §5
manipulates: its **negation** is a `Prop` (Lemma 5.1/Prop 4.2, `md:207`, `md:165`), its
**case analysis** and **infimum** are `Prop`-level over Dedekind complete chains (`md:285-303`), and
its **composition** is the `Prop`-level `∃z (z0<z<z1 ∧ P_L(z0,z) ∧ P_R(z,z1))` of Def 7.13 / Lemma
7.6 (§2 above). It preserves the two-free-variable invariant natively (no arity accumulation, no
`m→2` bridge) and avoids the `VVecEA2→Formula` artifact.

- **Caveat (honest):** Rabinovich's object is *nominally* a syntactic formula (`md:219`), and the
  final TL output must be a *syntactic* TL formula (Prop 3.5, `md:137`). A Prop-valued carrier defers
  syntax to that exit. This is faithful **for the recursion carrier** precisely because the paper's
  recursion is itself entirely semantic (satisfaction-based) and only demands syntax at arity 1. The
  Prop carrier must still be *bridged to a TL formula at arity 1* — which is exactly Prop 3.5's job
  and is where the codebase's `nf_characterizable_temporal_prior` (KampPrior.lean:407, cross-ref
  report 08) lives.

**Ranking against the paper:** D (recursion carrier) ⟹ v6-bracket-shape (faithful shape, wrong
composition family) ≫ A (refuted). The two-endpoint discipline is the load-bearing invariant; both D
and the v6 bracket honor it, and A violates it.

---

## 4. Direct answers to the mission's structural questions

1. **Is `[α0,β1,…,αn](z0,z1)` syntactic, semantic, or a pair?** Nominally **syntactic** (an
   abbreviation for the `→∃∀`-formula, `md:219`); operationally used **semantically** (satisfaction
   over Dedekind complete chains, `md:285-303`). Not a pair. For the Lean *recursion carrier*, its
   semantic (Prop) meaning is what is manipulated.
2. **What are the `αi`/`βi`?** **One-variable quantifier-free predicates** (`md:111`, `md:209`): `αi`
   = **point** predicates at anchor points, `βi` = **interval** predicates holding **along** open
   segments (Fig. 1 `md:299`, "β1 holds along (z0,z1)" `md:285`). Not interval *pieces* with two free
   ends; not closed sentences.
3. **Free-var count of the whole §5 object?** **Exactly 2** (`z0, z1`); interior anchors are ∃-bound
   (Def 7.5 `md:407`, Lemma 5.3 `md:225`). ✔ ≤2.
4. **Lemma 3.2(2) reduced object type?** A **conjunction of `≤2`-free `→∃∀` formulas** (syntactic;
   `md:119`).
5. **Prop 3.5 precondition/output?** Precondition: **exactly one free variable**; output: a
   **`TL(Until,Since)` formula** (`md:137`). This is the recursion EXIT, not the carrier.
6. **Def 7.13 composition?** **Syntactic conjunction** `⋀ ϕi` of adjacent two-endpoint pieces glued
   at shared anchors (`md:451`, Fig. 1 `md:299`), **re-collapsed to two free variables by bounded ∃**
   over each join anchor (Lemma 7.6 `md:413`).
7. **Recursion at `k+1`:** IH provides a **two-endpoint `∨→∃∀` formula** `On(…, z0, z1)`; the `k+1`
   object is built by **re-anchoring one endpoint** to a Dedekind-`inf` interior point `r0` and
   recursing on the two-endpoint object `On(…, r0, z1)` (`md:231-247`) — never leaving arity 2.

---

## 5. Adversarial self-check (H4) — every load-bearing claim grounded in a `md:` citation

| # | Load-bearing claim | Grounding | Status |
|---|---|---|---|
| 1 | Carrier is nominally a syntactic `→∃∀`-formula | `md:219` ("for the →∃∀-formula"), `md:109-111` | GROUNDED |
| 2 | `αi,βi` are one-variable quantifier-free predicates (not closed, not 2-endpoint) | `md:111` ("quantifier free formulas with one variable"), `md:209` | GROUNDED |
| 3 | §5 object has exactly two free variables `z0,z1`; interior anchors ∃-bound | `md:407` (Def 7.5), `md:225` (Lemma 5.3 ∃x1…∃xn) | GROUNDED |
| 4 | Lemma 3.2(2) reduces to conjunction of ≤2-free pieces | `md:119` | GROUNDED |
| 5 | Prop 3.5 = one-free-var precondition → TL output (the EXIT) | `md:137`, `md:141` | GROUNDED |
| 6 | Recursion re-anchors an endpoint to `inf`-point `r0`, stays arity 2 | `md:231-247` (esp. `md:233`, `md:237`, `md:245`) | GROUNDED |
| 7 | Recursion steps are semantic (Dedekind completeness / satisfaction) | `md:233` ("such r0 exists by Dedekind completeness"), `md:285-303` | GROUNDED |
| 8 | Def 7.13 composition = syntactic ∧ of adjacent 2-endpoint pieces | `md:451` | GROUNDED |
| 9 | Composition re-collapses to arity 2 by bounded ∃ over the join anchor | `md:413` (Lemma 7.6), `md:299` (Fig. 1), `md:255` (Cor 5.4) | GROUNDED |
| 10 | v6 `BracketFormula` semantics = ∃ increasing interior witnesses over 2 fixed endpoints | Codebase VecEAFormula.lean:128-169 **cross-checked against** `md:225`, `md:219` | GROUNDED (paper) + codebase-verified |
| 11 | Single-point carrier models only Prop 3.5 output, not the recursion | `md:137` vs `md:219`/`md:407` | GROUNDED |

**Claims NOT purely paper-grounded (flagged):** the codebase-side facts in Option v6/D (VVecEA2 arity
`m` composition gap, `IsVEA` unbuilt, `nf_characterizable_temporal_prior` requires Prior hyps) are
**cross-referenced from reports 07/08 and one direct read of VecEAFormula.lean:128-169**, not from the
paper. They are labeled as codebase facts, and the *faithfulness* judgments they support are anchored
to the paper citations above. No load-bearing *paper* claim rests on an un-cited assertion.

**Paper-vs-report conflict flagged:** Report 08's mapping-table phrase "**point types are CLOSED
formulas** / interior slots are `List TemporalPred` (closed)" is **potentially misleading** against
`md:111`/`md:209`, where `αi/βi` are explicitly **one-variable** quantifier-free predicates. The
reconciliation (§3, Option v6): "closed" is correct **only** as *endpoint-independent* (does not
mention `z0,z1`); each remains a one-variable predicate evaluated at a bound witness. If any codebase
consumer treats them as *zero-variable sentences* evaluated without a witness point, **that** would
diverge from the paper — flagged for the synthesis/plan step to check against `BracketFormula.holds`
(which, as verified, does evaluate each `TemporalPred` at a witness, so it is consistent).

**No forbidden H4 outputs**: no "mathlib likely has this" without a search; no type claim without the
type; the one carrier recommendation (option D for the recursion carrier) is backed by the semantic
composition law (§2) and the two-free-variable invariant (§1), both cited.

---

## 6. One-paragraph handoff for synthesis

The paper's recursion carrier is a **two-free-variable object** — nominally a syntactic `→∃∀`-formula
(`md:219`) but manipulated purely through its **Prop meaning** at the two endpoints (`md:285-303`),
with **one-variable** interior predicates over **∃-bound** anchor points (`md:111`, `md:225`) and a
**bounded-∃ conjunction** composition law (Def 7.13 `md:451` + Lemma 7.6 `md:413`, Fig. 1 `md:299`).
The **single-point** carrier is refuted (it is only Prop 3.5's arity-1 exit, `md:137`). The
**syntactic `VVecEA2`** carrier has the right *bracket shape* but realizes composition in the arity-`m`
`VVecEA_m` family, which lacks the paper's immediate `m→2` `∃`-collapse. A **Prop-valued two-endpoint
interval predicate** (option D) is the carrier that honors the paper's two-free-variable invariant and
composition law natively; syntax (a TL formula) is required only at the arity-1 exit (Prop 3.5).
