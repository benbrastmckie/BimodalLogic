# Research Report: Verified Decidability of TM via the Tableau Stack

| Field | Value |
|-------|-------|
| Task | 165 — `establish_semantic_finite_model_property` (rescoped to tableau decidability) |
| Task type | `lean4` |
| Session | `sess_1785196144_a9bbd7` |
| Date | 2026-07-27 |
| Mode | hard (H2 anti-analysis, H3 reference grounding, H4 adversarial verification, **H5 divergence/audit ACTIVE** via the WP1 adversarial-probe mandate) |
| Grounding tier | Tier 3 (implementation-backed), with Tier 1 cross-references to Prior/Burgess/Reynolds |
| Status | researched |
| Toolchain | Lean v4.33.0-rc1, Mathlib tag `v4.33.0-rc1` (commit `79d0395a`) |
| Prior artifact | `reports/01_semantic-fmp-research.md` — targets the *semantic FMP*, now explicitly out of scope; superseded, not contradicted |

## Executive Summary

**WP1 verdict: the 28/30-rule calculus is NOT adequate. Three independent structural defects
were found, two of them with machine-produced counterexample branches. Every downstream work
package (WP2, WP3, WP4) is blocked until the calculus and the blocking machinery are repaired.**

The probe was run at audit grade: rather than arguing plausibility, I built a blocking-free
saturation driver over the repository's own `expandOnceWithApplied`, ran it on formulas that are
valid over linear time, and captured the resulting open branches verbatim. Two of them provably
admit **no** linear model.

| # | Defect | Evidence | Consequence |
|---|--------|----------|-------------|
| **D1** | `TimeOrdering.futureOf`/`pastOf` return only *immediate* successors/predecessors, so the universal temporal rules never propagate transitively | `Gp → GGp` saturates open with `T p@t1, F p@t2, T(Gp)@t0`, ord `0<1<2`; `applyRule .someFutureNeg` on that branch with an **empty** applied set propagates to `[1]` only | WP4 impossible: open branches are unsatisfiable |
| **D2** | No ordering-trichotomy/linearity branching rule for freshly introduced times; `TimeOrdering` is a forest, TM time is linear | Prior/Burgess linearity instance saturates open with two **incomparable** siblings `t1 ‖ t2`, each refuting the other | WP4 impossible; refutation-incompleteness |
| **D3** | `ancestorTimes` follows **both** backward and forward edges, so every time is its own "ancestor"; `isSubsetBlocked t t` is reflexively true, so blocking fires vacuously the moment one ordering constraint exists | `ancestorTimes ⟨[(0,1)]⟩ 1 = [0, 1]`; `isTemporallyBlocked b 1 ⟨[(0,1)]⟩ = true` while `isSubsetBlocked b 1 0 = false` | Blocking is not a real blocking condition; `blocking_sound` is near-vacuous; the whole termination story rests on an artifact |

Two further gaps, both verified:

- **D4** — `branchTruthLemma` (`CountermodelExtraction.lean:1044`) is an **orphan**: it requires
  `findUnexpanded b = none`, but `ExpandedTableau.hasOpen` only certifies
  `findUnexpandedWithApplied … = none`, which is strictly weaker. `◇p` is a concrete witness of a
  pipeline `hasOpen` whose branch fails the lemma's hypothesis. Grep confirms **no consumer**
  anywhere in the tree.
- **D5** — There is **no Dedekind rule list at all**. `allRulesForFC` (`Tableau.lean:1067`) has
  Base/Dense/Discrete cases only, so `prior_U_gap`, `prior_S_gap`, `sep` (`Axioms.lean:377,387,398`)
  have no tableau counterpart.

Two charter corrections, both material:

1. **Rule count.** `allRules` has **25** entries (`Tableau.lean:1029-1044`), not 23; with 2 dense
   and 3 discrete that is **30** rules, matching the 30 `TableauRule` constructors. Plans sized
   against "~28 admissibility lemmas" will undercount.
2. **The Dedekind gating is correct, not a caveat.** The charter treats
   `Discrete ≰ Dedekind` as a hazard. It is not: the Dedekind completeness terminus the repo
   actually needs is `completeness_dedekind_of_engine` (`StrongCompleteness.lean:308`), whose
   engine consumes **`ValidDedekindDense`** — Dedekind-complete *and* densely ordered. Base+Dense
   rules is exactly the right rule set for that target. The real Dedekind gap is D5.

**Architectural recommendation (the focus prompt's core ask).** Do not build one monolithic
decidability theorem. Split the deliverable into two tracks with a shared, frame-class-indexed
core:

- **Track A — decidability of *validity*** (`Decidable (⊨ φ)` and its three class variants).
  Needs WP1-repair + WP3 (termination) + WP4 (`hasOpen → ¬valid`) + a *semantic* refutation
  soundness (`allClosed → valid`), which is far cheaper than WP2 because the existing `sat_*`
  lemmas in `CountermodelExtraction.lean:333-904` already carry most of it.
- **Track B — decidability of *provability*** (`Decidable (Derivable fc [] φ)`) and the
  completeness corollaries. This is the only thing that genuinely requires WP2
  (`allClosed → Derivable`), and it is the expensive half.

Track A is a complete, publishable result on its own and is a hard prerequisite for Track B.
Sequencing them this way means the first green milestone is reachable without touching the
Hilbert system at all.

---

## 1. Verified Current-State Inventory

All line numbers below were read from the working tree, not carried over from the charter.

### 1.1 The tableau stack

| File | Lines | Key declarations (verified) |
|---|---|---|
| `SignedFormula.lean` | 943 | `Label` :59, `Sign` :108, `SignedFormula` :161, `Branch` :240, `Eventuality` :549, `EventualityTracker` :562, `timeType` :622, `isSubsetBlocked` :632, `TimeOrdering` :654, `futureOf` :676, `pastOf` :681, `ancestorTimes` :707, `allEventualitiesFulfilledOrDuplicated` :732, `isTemporallyBlocked` :759, `findBlockedTime` :771 |
| `Tableau.lean` | 1221 | `TableauRule` :73 (**30 ctors**), `RuleResult` :156, `isApplicable` :274, `applyRule` :345, `AppliedSet` :1019, `allRules` :1029 (**25**), `denseRules` :1049 (2), `discreteRules` :1057 (3), `allRulesForFC` :1067, `findApplicableRuleWithApplied` :1149, `expandOnceWithApplied` :1186 |
| `Closure.lean` | 405 | `checkBotPos` :83, `checkContradiction` :91, `checkAxiomNeg` :102, `findClosure` :122, monotonicity lemmas :188-351 |
| `Saturation.lean` | 1620 | `ExpandedTableau` :50, `expandBranchWithFuel` :242, `saturateBlocked` :516, `buildTableau` :579, `recommendedFuel` :608, `soundFuel` :627, `subformula_property` :1014, status discussion :1025-1079, `expandBranchWithFuel_sound` :1184, `blocking_sound` :1247 |
| `ProofExtraction.lean` | 363 | `proofFromAxiom` :64, `tryAxiomProof` :110, `buildCompositionalProof` :146, `enhancedSearch` :217, `extractProof` :258, `verifyProof` :338 (returns `Bool`, a stub) |
| `CountermodelExtraction.lean` | 1132 | `SemanticCountermodel` :176, `branchTruth` :263, `extractSemanticCountermodel` :311, `sat_*` family :333-904, `branchTruthLemma` :1044 |
| `DecisionProcedure.lean` | 395 | `DecisionResult` :64, `decide` :128, `isValid` :169, `decideAuto` :185 |
| `Correctness.lean` | 153 | `decide_sound` :56, **`validity_decidable` :78 (vacuous)**, **`validity_has_decision_procedure` :91 (vacuous)**, `decide_result_exclusive` :101, `fmp_completeness` :129 |
| `FMP/FMP.lean` | 259 | **`filtered_world_bound` :183 (vacuous)**, `mcs_finite_model_property` :204, `fmp_contrapositive` :217, **`fmp_size_bound` :237 (vacuous)** |

### 1.2 Corrected rule inventory

`allRules` (`Tableau.lean:1029-1044`), in priority order, **25 rules**:

```
negPos negNeg | impNeg | andPos orNeg | boxPos boxNeg diamondPos diamondNeg
boxTemporal | allFuturePos allFutureNeg allPastPos allPastNeg
someFuturePos someFutureNeg somePastPos somePastNeg
untlPos untlNeg sncePos snceNeg | impPos | andNeg orPos
```

`denseRules` :1049 = `denseIndicatorClosure, densityRule`.
`discreteRules` :1057 = `priorUZ, priorSZ, z1Rule`.
`allRulesForFC` :1067 = `base ++ (if Dense ≤ fc then dense) ++ (if Discrete ≤ fc then discrete)`.

Resulting per-class rule sets, given the `FrameClass` order (`Axioms.lean:456-463`, pinned by
`example`s at :489-496):

| Frame class | Rules | Count |
|---|---|---|
| `Base` | base | 25 |
| `Dense` | base + dense | 27 |
| `Discrete` | base + discrete | 28 |
| `Dedekind` | base + dense (Discrete ≰ Dedekind) | 27 |

### 1.3 The Hilbert system it must connect to

`Axiom : Formula → Type` (`Axioms.lean:84-402`) has **45 constructors**, gated by
`Axiom.minFrameClass` (:518-527): Base 37, Dense 2 (`density`, `dense_indicator`),
Discrete 3 (`prior_UZ`, `prior_SZ`, `z1`), Dedekind 3 (`prior_U_gap`, `prior_S_gap`, `sep`).

`DerivationTree (fc : FrameClass) : Context → Formula → Type` (`Derivation.lean:91-167`) with
constructors `axiom` (side condition `h.minFrameClass ≤ fc`), `assumption`, `modus_ponens`,
`necessitation`, `temporal_necessitation`, `temporal_duality`, `weakening`.
`Derivable fc G p := Nonempty (DerivationTree fc G p)` (`Derivable.lean:69`).

Naming trap worth recording in any plan: the five `discrete_*` axioms (`Axioms.lean:276-303`)
are **Base**-class, not `.Discrete`-gated.

### 1.4 Semantics the bridge must reach

`TruthAt` (`Truth.lean:128-137`) — the clauses that matter:

```lean
| Formula.box  φ   => ∀ σ : WorldHistory F, σ ∈ Omega → TruthAt M Omega σ t φ
| Formula.untl φ ψ => ∃ s : D, t < s ∧ TruthAt M Omega τ s φ ∧
                       ∀ r : D, t < r → r < s → TruthAt M Omega τ r ψ
| Formula.snce φ ψ => ∃ s : D, s < t ∧ TruthAt M Omega τ s φ ∧
                       ∀ r : D, s < r → r < t → TruthAt M Omega τ r ψ
```

Until/Since guards are over **open intervals in the ambient `D`**, not over any successor
relation. Every validity predicate (`Validity.lean:79, 169, 187, 231, 255`) quantifies over
`D : Type` with `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]`, plus a
`ShiftClosed Omega` binder; the class-specific binders are `[DenselyOrdered D]` (Dense),
`[SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D]` (Discrete),
and an explicit LUB hypothesis (Dedekind). **Every extra binder is on `D` alone** — confirmed
in the prior report (F5) and re-confirmed here.

---

## 2. WP1 — Adversarial Calculus-Adequacy Probe (H5, audit grade)

### 2.1 Method

The default entry points mask the calculus behind three layers (proof-search fast paths,
blocking, and `extractProof`). To probe the *calculus*, I built a blocking-free driver over the
repository's own `expandOnceWithApplied` / `findClosure`, changing nothing else:

```lean
partial def rawExpand (b : Branch) (fuel : Nat) (ord : TimeOrdering) (fc : FrameClass)
    (applied : AppliedSet) : Option (Unit ⊕ (Branch × TimeOrdering)) := ...
```

Controls passed: `p → p` CLOSED, `p` OPEN, `G p → p` OPEN (correct — `G` is strict),
`F p → F F p` OPEN (correct — genuinely invalid), `G(p→q) → (Gp → Gq)` CLOSED, and the exact
`temp_linearity` axiom instance CLOSED. `matchAxiom` (`ProofSearch/Core.lean:321`) recognizes
only **20 of 45** axioms and `temp_linearity` is **not** among them, so that last closure came
from the rules, not from the `checkAxiomNeg` fast path.

### 2.2 Counterexample A — the transitivity gap (D1)

Input `G p → G G p`, valid over any linear order. Machine-produced open saturated branch:

```
ord = [(1,2), (0,1)]                    -- i.e. t0 < t1 < t2
T @(w0,t1) p
F @(w0,t2) p
F @(w0,t0) F¬p                          -- i.e. T(G p) @ t0
```

**No linear model exists.** In any linear order satisfying `t0 < t1` and `t1 < t2` we have
`t0 < t2`; `G p` at `t0` forces `p` at `t2`, contradicting `F p @ t2`.

**Root cause, isolated adversarially.** My first hypothesis was that the `AppliedSet` had
suppressed re-firing. It had not. Applying the rule directly to that branch with an **empty**
applied set:

```lean
#eval descr (applyRule .someFutureNeg (SignedFormula.neg (someFuture P.neg) ⟨0,0⟩) bA ordA).1
-- "persistent -> times [1]"
#eval ordA.futureOf 0   -- [1]
#eval ordA.futureOf 1   -- [2]
```

`someFutureNeg` reaches time 1 and stops. The cause is `TimeOrdering.futureOf`
(`SignedFormula.lean:676-678`), which filters the constraint list for *direct* edges and
performs no transitive closure. `allFuturePos` (`Tableau.lean:502-508`), `allPastPos` (:542),
`someFutureNeg`, `somePastNeg` all consume it. There is also no `T(GA) → T(G(GA))` propagation
rule to compensate.

### 2.3 Counterexample B — the trichotomy/linearity gap (D2)

Input: the Prior/Burgess linearity schema with disjuncts in a non-axiom-instance order —
`(Fp ∧ Fq) → (F(p ∧ Fq) ∨ F(p ∧ q) ∨ F(q ∧ Fp))`, valid over any linear order.
Machine-produced open saturated branch:

```
ord = [(0,2), (0,1)]                    -- t1 and t2 are INCOMPARABLE siblings
T @(w0,t1) p        F @(w0,t1) q        F @(w0,t1) Fq
T @(w0,t2) q        F @(w0,t2) p        F @(w0,t2) Fp
F @(w0,t0) F(p∧q)   F @(w0,t0) F(p∧Fq)  F @(w0,t0) F(q∧Fp)
```

**No linear model exists**, by exhaustive trichotomy on `t1` vs `t2`:

- `t1 < t2`: `q` holds at `t2` and `t2 > t1`, so `F q` holds at `t1` — contradicts `F(Fq)@t1`.
- `t2 < t1`: `p` holds at `t1` and `t1 > t2`, so `F p` holds at `t2` — contradicts `F(Fp)@t2`.
- `t1 = t2`: `T p@t1` contradicts `F p@t2`.

The calculus never branches on the relative order of two independently created fresh times, so
`TimeOrdering` is a forest. Corroborating evidence of fragility: the *exact* axiom-instance
disjunct order closes, while this logically equivalent permutation does not — closure here is
syntax-sensitive, which is itself a symptom rather than a defence.

### 2.4 Defect D3 — blocking fires vacuously

`ancestorTimes` (`SignedFormula.lean:707-718`) collects `directPredecessors ++ directSuccessors`
and recurses. It is therefore the *connected component*, not the ancestor set, and every time
with at least one incident constraint is reachable from itself in two steps.

```lean
#eval ancestorTimes ⟨[(0,1)]⟩ 1                                    -- [0, 1]   ← contains 1
#eval Branch.isSubsetBlocked b0 1 0                                -- false
#eval isTemporallyBlocked b0 1 ⟨[(0,1)]⟩ EventualityTracker.empty  -- true  (!)
#eval findBlockedTime b0 ⟨[]⟩ EventualityTracker.empty             -- none
```

Since `isSubsetBlocked b t t` is reflexively true, `isTemporallyBlocked b t ord` is true for
every `t` incident to a constraint, regardless of formula content. `expandBranchWithFuel:268`
then immediately returns the branch as a "blocked open branch".

A second, independent defect sits in the same call: `isTemporallyBlocked` (:763) invokes
`allEventualitiesFulfilledOrDuplicated tracker t_anc t`, but the definition's parameters are
`(tracker) (t_new t_anc)` (:732-733) — **the two time arguments are swapped**. The guard checks
"eventualities pending at the ancestor are duplicated at the blocked time" instead of the
converse.

Consequence for the charter's account: the note at `Saturation.lean:1028-1060` says
`blocking_terminates` "was found FALSE". The deeper problem is the opposite one — blocking is
currently *too eager* rather than too weak, so `blocking_sound` (:1247) and any pigeonhole
argument built on it would be measuring an artifact.

### 2.5 What the pipeline actually does today, end to end

With blocking live, both counterexample inputs never reach a verdict:

```lean
#eval (decide gTrans).isTimeout   -- true
#eval (decide linAx).isTimeout    -- true
#eval buildTableau gTrans 100000 .Base   -- none   (fuel is not the issue)
```

`buildTableau` returns `none` at `Saturation.lean:598` ("still not saturated after post-blocking
pass"): blocking declares the branch saturated, `saturateBlocked` then refuses every remaining
rule because it would create a time constraint (:531, :537), and the branch can never saturate.
`decide` maps that to `.timeout` (`DecisionProcedure.lean:152`). Note also that `.timeout` is
returned at :161 when `extractProof` fails on a genuinely *closed* tableau — so `.timeout` today
conflates three distinct situations and must be split before any correctness theorem is stated.

### 2.6 Until-guard interpolation and blocking/unwinding

Two further adequacy observations, from reading `applyRule`:

- **`untlPos` (`Tableau.lean:672-712`) is a discrete step/unwind rule.** `T(U(e,g))@t` branches
  into `T(e)@t'` (fresh `t' > t`) or `T(g)@t' ∧ T(U(e,g))@t'`. Branch 2 presupposes something
  like a successor. Against the repository's `TruthAt`, where the guard must hold on the whole
  *open interval* `(t,s)`, branch 2 is not a decomposition of the semantics — it is an
  approximation that is only faithful on discrete orders. It is refutation-*sound* (branch 1
  alone suffices: take `t'` to be the semantic witness `s`), so this does not break WP2; it
  breaks WP4, and it is the direct source of the eventuality-fulfilment problem.
- **Blocking will require an unwinding argument regardless.** Once D3 is fixed so that blocking
  is a genuine subset condition, a blocked branch is a *loop*, and the countermodel must be built
  by unwinding the loop into an ω-sequence of interpolated times. The `EventualityTracker`
  (`SignedFormula.lean:562`) is the right data structure for the fulfilment side condition, but
  the argument-swap bug must be fixed first.

### 2.7 Verdict

**The calculus is not adequate as-is.** Minimum repairs before WP2-WP4 can be attempted:

| Repair | Where | Kind |
|---|---|---|
| R1 | `TimeOrdering.futureOf`/`pastOf` (`SignedFormula.lean:676,681`) | Replace with fuel-bounded transitive closure (a correct one already exists in the same tree: `isTimeOrderedBefore`, `CountermodelExtraction.lean:198`) |
| R2 | new rule `orderTrichotomy` | Branching rule: for fresh `t'` and each existing `t''` incomparable to it, split on `t' < t''` / `t' = t''` / `t'' < t'`. This is the tableau counterpart of `temp_linearity` / `linear_until` (`Axioms.lean:196,238`) |
| R3 | `ancestorTimes` (`SignedFormula.lean:707`) | Follow predecessor edges only; exclude `t` itself |
| R4 | `isTemporallyBlocked` (`SignedFormula.lean:763`) | Fix the swapped `t_new`/`t_anc` arguments |
| R5 | `ExpandedTableau.hasOpen` (`Saturation.lean:56-59`) | Strengthen the certificate to `findUnexpanded … = none` so `branchTruthLemma`-shaped lemmas apply, or restate the truth lemma against the applied-set predicate and prove the applied-set formulas are semantically redundant |
| R6 | `allRulesForFC` (`Tableau.lean:1067`) | Add a `dedekindRules` list for `prior_U_gap`/`prior_S_gap`/`sep` |
| R7 | `decide` (`DecisionProcedure.lean:128`) | Split `.timeout` into `.fuelExhausted` / `.extractionFailed`, so a closed tableau is never reported as undecided |

R1-R4 are mechanical and each is independently testable by re-running the probes in §2.2-2.4.
R2 is the one genuine calculus extension and is the top risk (it multiplies the branching
factor, which interacts with WP3).

---

## 3. WP2 — Refutation Meta-Theorem (`allClosed → Derivable`)

### 3.1 The obligation the charter understates

`allClosed tableau → Derivable fc [] φ` is not a rule-by-rule induction over 30 admissibility
lemmas alone. The tableau is **labelled** (`Label = (world, time)`, `SignedFormula.lean:59`),
while `Derivable` has no labels. A branch must first be *internalized* into a single formula:
world labels via the S5 modality (`□`/`◇` nesting, sound because `box` is universal over `Omega`
with no accessibility relation), time labels via `F`/`P`/`U`/`S` nesting with the branch's
`TimeOrdering` constraints realised as `U`/`S` guards. Only then does per-rule admissibility make
sense, as: *if the internalization of each child branch is refutable, so is the parent's*.

Recommended statement shape:

```lean
/-- Internalize a labelled branch into one formula of the object language. -/
def Branch.internalize (b : Branch) (ord : TimeOrdering) : Formula

/-- Per-rule admissibility, the induction step. -/
theorem rule_admissible (r : TableauRule) (sf : SignedFormula) (b : Branch) (ord : TimeOrdering)
    (h_fc : ruleFrameClass r ≤ fc) :
    ∀ children ∈ applyRule r sf b ord,
      Derivable fc [] (child.internalize).neg → Derivable fc [] (b.internalize).neg
```

### 3.2 Per-rule difficulty map

| Group | Rules | Difficulty | Existing asset to reuse |
|---|---|---|---|
| Propositional | `negPos negNeg impNeg impPos andPos andNeg orPos orNeg` (8) | Routine | `Theorems/Combinators.lean` (`impTrans` :99, `pairing` :555, `notNotIntro` :589); `deductionTheorem` (`Core/DeductionTheorem.lean:325`) |
| S5 modal | `boxPos boxNeg diamondPos diamondNeg` (4) | Routine-moderate | `Theorems/ModalS5.lean` (`boxConjIff` :465, `s5DiamondBox` :717); `generalizedModalK` (`GeneralizedNecessitation.lean:148`) |
| Modal-temporal | `boxTemporal` (1) | Routine | `modal_future` axiom (`Axioms.lean:268`); `temporalFutureDerived` (`Combinators.lean:653`) |
| Temporal universals | `allFuturePos allPastPos someFutureNeg somePastNeg` (4) | Moderate | `gDistribution`/`hDistribution` (`TemporalDerived.lean:260,268`), `gTransitivity`/`hTransitivity` (:275,283), `generalizedTemporalK`/`generalizedPastK` (:183,223) |
| Temporal existentials | `allFutureNeg allPastNeg someFuturePos somePastPos` (4) | Moderate | `fNegG`/`pNegH` (`TemporalDerived.lean:504,514`), `serial_future`/`serial_past` axioms |
| **Until/Since** | `untlPos untlNeg sncePos snceNeg` (4) | **Hard** | `self_accum_until` (:174), `absorb_until` (:186), `left_mono_until_G` (:123), `right_mono_until` (:134), `enrichment_until` (:156), `F_until_equiv` (:255) |
| **Trichotomy (new)** | `orderTrichotomy` (R2) | **Hard** | `temp_linearity` (:238), `linear_until` (:196), `linear_since` (:205) — these axioms exist precisely to justify this rule |
| Dense | `denseIndicatorClosure densityRule` (2) | Moderate | `density` (:343), `dense_indicator` (:354) |
| Discrete | `priorUZ priorSZ` (2) | Routine (direct axiom images) | `prior_UZ` (:315), `prior_SZ` (:320) |
| **Discrete** | `z1Rule` (1) | **Hard** | `z1` (:332) — an induction axiom; the rule fires on a *pair* of branch formulas, so the admissibility lemma is a two-premise combination, not a decomposition |
| Dedekind (missing) | R6 rules | **Hard** | `prior_U_gap` (:377), `prior_S_gap` (:387), `sep` (:398) |

### 3.3 Strategy for the hard cases

- **`untlPos`.** Branch 1 alone is refutation-sound, so the admissibility lemma is the disjunction
  introduction `U(e,g) → F(e)` — that is `until_F` (`Axioms.lean:226`), already an axiom. The
  work is in branch 2, whose justification is `self_accum_until` (:174):
  `U(ψ,φ) → U(ψ, φ ∧ U(ψ,φ))`. Follow that axiom literally; do not invent a shortcut.
- **`untlNeg`** (the "Reynolds co-decomposition", `Tableau.lean:765-914`). The dual uses
  `absorb_until` (:186) plus `left_mono_until_G` (:123). This is the single largest lemma; budget
  it a phase of its own.
- **`z1Rule`.** Two-premise: `T(G(Gφ→φ))` and `T(F(Gφ))` at the same label yield `T(Gφ)`. This is
  a direct instance of the `z1` axiom followed by two modus ponens steps — *provided* the
  internalization keeps both premises at the same label, which the label-internalization design
  must guarantee. Design the internalization with this constraint in mind rather than retrofitting.
- **`orderTrichotomy`.** The three-way split maps onto the three disjuncts of `temp_linearity`
  (`Fφ ∧ Fψ → F(φ∧ψ) ∨ F(φ∧Fψ) ∨ F(Fφ∧ψ)`). Design the rule so its branches are *syntactically*
  the axiom's disjuncts; this makes admissibility a one-liner and is the single highest-leverage
  design decision in WP2.

### 3.4 Missing infrastructure

There is **no cut rule and no uniform-substitution admissibility** for `DerivationTree` anywhere
in the tree (verified: every `subst_*` result is on `MonadicFormula` or in Boneyard). The
internalization approach above avoids needing substitution; a schema-instantiation approach would
not. This is a decisive argument for the internalization design.

`ModalS4.lean`/`ModalS5.lean`/`TemporalDerived.lean`/`ContextualProofs.lean` are stated at
**Base only** (`⊢ φ`). Reuse at other classes goes through `DerivationTree.lift`
(`Derivation.lean:190`) / `Derivable.lift` (`Derivable.lean:110`) with `FrameClass.base_le`
(`Axioms.lean:530`). Plan for a thin `lift`-wrapper layer rather than restating lemmas.

---

## 4. WP3 — Termination

### 4.1 What exists

`subformula_property` (`Saturation.lean:1014`) is trivial: its hypothesis is
`b = [SignedFormula.neg φ Label.initial]`, so it only says `φ ∈ subformulas φ`. It does not
cover `applyRule` at all.

`soundFuel` (`Saturation.lean:627`) is `min (n * 2^n) 100000` with nothing proved about it. The
docstring's justification cites the FMP `2^|cl(φ)|` bound — which is itself unproven (§7).

### 4.2 Skeleton

Three theorems, in order:

```lean
/-- (T1) Generalized subformula property: 25+ rule cases. -/
theorem applyRule_subformula_closed (r : TableauRule) (sf : SignedFormula)
    (b : Branch) (ord : TimeOrdering) (φ : Formula)
    (h_b : ∀ x ∈ b, x.formula ∈ signedClosure φ) (h_sf : sf ∈ b) :
    ∀ c ∈ (applyRule r sf b ord).1.branches, ∀ x ∈ c, x.formula ∈ signedClosure φ

/-- (T2) Pigeonhole: more times than time-types forces a repeat, hence blocking. -/
theorem blocking_fires_of_card_lt (b : Branch) (ord : TimeOrdering) (φ : Formula)
    (h : 2 ^ (2 * (signedClosure φ).card) < b.knownTimes.length) :
    (findBlockedTime b ord tracker).isSome

/-- (T3) Uncapped, justified fuel. -/
theorem buildTableau_isSome (φ : Formula) (fc : FrameClass) :
    (buildTableau φ (soundFuel' φ) fc).isSome
```

The closure `signedClosure φ` should be the *signed* subformula closure (both signs over
`Formula.subformulas`), not `subformulaClosure` — `applyRule` produces `SignedFormula`s and both
polarities occur. Note `untlPos` branch 2 re-emits `U(e,g)` itself, so plain subformula closure
suffices; no Fischer-Ladner unwinding is required. `densityRule` and `priorUZ`/`priorSZ` are the
cases to check most carefully: `priorUZ` emits `U(φ, ¬φ)`, whose `¬φ` is **not** a subformula of
`F φ`. **T1 as stated is false for `priorUZ`/`priorSZ` unless the closure is negation-closed.**
Use `closureWithNeg` (`Syntax/SubformulaClosure/Closure.lean:71`) for the Discrete class. This is
a concrete, findable trap and should be written into the plan explicitly.

### 4.3 Verified Mathlib support

Verified by elaboration against the live tree (with a deliberate control error to prove the
harness reports failures):

```lean
Finset.exists_ne_map_eq_of_card_lt_of_maps_to :
  ∀ {α β} {s : Finset α} {t : Finset β}, t.card < s.card →
    ∀ {f : α → β}, Set.MapsTo f ↑s ↑t → ∃ x ∈ s, ∃ y ∈ s, x ≠ y ∧ f x = f y
```

This is exactly T2's shape: `s` = branch times, `t` = the (finite) set of time-types, `f` =
`Branch.timeType b`. `Fintype.exists_ne_map_eq_of_card_lt` does **not** exist under that name
(verified: `Unknown constant`).

### 4.4 Dependency on WP1

T2 is meaningless until D3/R3/R4 are fixed — with the current `ancestorTimes`, blocking already
fires with one constraint, so `blocking_fires_of_card_lt` is true for a reason that has nothing to
do with pigeonhole. Conversely, R2 (`orderTrichotomy`) *increases* the branching factor without
increasing the number of time-types, so the pigeonhole bound survives R2 unchanged; only the fuel
constant changes. Sequence WP3 strictly after WP1-repair.

---

## 5. WP4 — Semantic Bridge (`open saturated branch → ¬valid`)

### 5.1 Target statement, per class

```lean
theorem not_valid_of_hasOpen (φ : Formula) (b : Branch) (ord : TimeOrdering)
    (hSat : findUnexpanded b (timeOrd := ord) = none)
    (hOpen : findClosure b .Base = none) : ¬ (⊨ φ)
```

with `ValidDense` / `ValidDiscrete` / `ValidDedekindDense` variants. Note the Dedekind variant
targets **`ValidDedekindDense`**, matching `completeness_dedekind_of_engine`
(`StrongCompleteness.lean:308`) and `consequence_completeness_dedekind_of_engine` (:274).

### 5.2 Construction

Five stages, each a named lemma:

1. **Order the branch times.** The repaired `TimeOrdering` (R1+R2) is, on a saturated branch, a
   finite *total* order. Package it as `BranchOrder b ord : LinearOrder (Fin n)` with
   `n = b.knownTimes.length`.
2. **Embed into the target `D`.** Verified available:
   ```lean
   Order.embedding_from_countable_to_dense (α β) [LinearOrder α] [LinearOrder β]
     [Countable α] [DenselyOrdered β] [Nontrivial β] : Nonempty (α ↪o β)
   ```
   (`Mathlib.Order.CountableDenseLinearOrder`.) A finite order is `Countable`, so this gives
   `Fin n ↪o ℚ` and `Fin n ↪o ℝ` directly — verified to elaborate. It does **not** apply to `ℤ`
   (not densely ordered), so the Discrete class needs a hand-rolled monotone `Fin n → ℤ`; that is
   elementary (enumerate in order) and should be an explicit, separate lemma rather than an
   attempted reuse.
3. **Interpolate the valuation.** This is the mathematical core. Between consecutive image points
   `d_i < d_{i+1}` in `D` lie infinitely many times not on the branch, and the real `untl` clause
   quantifies over all of them. Recommended construction: make the model **constant on the
   half-open intervals** `[d_i, d_{i+1})`, then prove
   ```lean
   theorem interp_invariance (χ ∈ signedClosure φ) (i) (r : D) (h : d i ≤ r) (h' : r < d (i+1)) :
     TruthAt M Om τ r χ ↔ TruthAt M Om τ (d i) χ
   ```
   by induction on `χ`. The `untl` case is where the open-interval guard is discharged, and it
   needs the branch to certify that the guard holds at **every branch time strictly between** the
   source and the witness — an obligation the current `untlPos` does not produce (§2.6) and that
   `orderTrichotomy` (R2) is a prerequisite for even stating.
4. **Build `WorldHistory` and `Omega`.** Use a total `domain := fun _ => True` (the prior report,
   F6, verified this is sound and trivializes `convex`/`respects_task` when paired with a
   universal `TaskRel`). Take `Omega` to be the image closed under `timeShift`;
   `ShiftClosed` then follows from `time_shift_preserves_truth` (`Truth.lean:446`) exactly as in
   the prior report's F9. `Set.univ_shift_closed` (`Truth.lean:339`) is the trivial fallback.
5. **Conclude `¬TruthAt`.** Replace `branchTruth` (`CountermodelExtraction.lean:263`) entirely.
   Its `untl` clause uses `futureOf` (direct successors) and its `box` clause quantifies over a
   finite world list; neither survives contact with `TruthAt`. Retain the `sat_*` lemma family
   (`:333-904`) — those are statements *about the branch* and are reusable verbatim as the
   saturation facts the new truth lemma consumes.

### 5.3 Verified target-order facts

All elaborated against the tree, control error present:

| Fact | Status |
|---|---|
| `∀ s : Set ℝ, s.Nonempty → BddAbove s → ∃ x, IsLUB s x` via `Real.isLUB_sSup hs hb` | Verified (exact shape of `ValidDedekind`'s binder) |
| `DenselyOrdered ℚ`, `DenselyOrdered ℝ` | Verified |
| `IsOrderedAddMonoid ℚ / ℝ / ℤ`, `AddCommGroup` for all three, `Nontrivial ℝ` | Verified |
| `SuccOrder ℤ`, `PredOrder ℤ`, `IsSuccArchimedean ℤ`, `IsPredArchimedean ℤ` (`Mathlib.Data.Int.SuccPred`) | Verified |
| `Order.embedding_from_countable_to_dense T ℚ` and `… T ℝ` for `[LinearOrder T] [Finite T]` | Verified |
| Any modal-logic tableau/filtration content in Mathlib | Verified **absent** (prior report F10, two independent searches) |

Recommended carriers: `Base → ℚ`, `Dense → ℚ`, `Discrete → ℤ`, `Dedekind → ℝ`.

---

## 6. H3 Reference Grounding — Mapping Table

Tier 3 (implementation-backed); literature rows are marked **[lit]** and are advisory only. The
repository's own literature index is thin on this topic — `specs/literature/` holds only
`index.json`/`README.md`/`DEPRECATED.md`, and the prior report records the key survey
(Hodkinson–Reynolds 2006, Handbook ch. 11) as truncated at 3 of 66 pages. **No load-bearing claim
in this report rests on a literature source**; every one rests on compiled Lean or on a
machine-produced branch.

| Source claim | Source location | Target Lean declaration | File | Status |
|---|---|---|---|---|
| Linearity of time requires a trichotomy branching rule for fresh labels | **[lit]** Prior/Burgess linear-time axiomatization; internalized in this repo as `temp_linearity` | `TableauRule.orderTrichotomy` + `orderTrichotomy_admissible` | `Decidability/Tableau.lean` (new ctor), `Refutation/Rules/Trichotomy.lean` | **To create** — counterexample B proves it is required |
| Prior/Burgess linearity schema | `Axioms.lean:238` `temp_linearity`, `:196` `linear_until`, `:205` `linear_since` | (justifies the above) | `ProofSystem/Axioms.lean` | **Exists**, unused by the tableau |
| `G` is transitive on linear orders | Derivable in TM: `gTransitivity` | `TimeOrdering.futureOf` transitive closure | `Decidability/SignedFormula.lean:676` | **Defective** — counterexample A |
| Existing transitive-reachability helper | `CountermodelExtraction.lean:198` `isTimeOrderedBefore` | reuse for R1 | same file | **Exists**, correct, not wired in |
| Reynolds co-decomposition for `F(U(e,g))` | **[lit]** Reynolds 2003 (quasimodels); implemented at `Tableau.lean:765-914` | `untlNeg_admissible` | `Refutation/Rules/UntilSince.lean` | **To create** — hardest WP2 lemma |
| Until unwinding `U(ψ,φ) → U(ψ, φ ∧ U(ψ,φ))` | `Axioms.lean:174` `self_accum_until` | `untlPos_admissible` branch 2 | `Refutation/Rules/UntilSince.lean` | **To create**; axiom exists |
| Until absorption | `Axioms.lean:186` `absorb_until` | `untlNeg_admissible` | same | **To create**; axiom exists |
| `U(ψ,φ) → F(ψ)` | `Axioms.lean:226` `until_F` | `untlPos_admissible` branch 1 | same | **To create**; axiom exists |
| Z1 backward induction | `Axioms.lean:332` `z1` | `z1Rule_admissible` | `Refutation/Rules/Discrete.lean` | **To create**; two-premise lemma |
| Dedekind gap axioms | `Axioms.lean:377,387,398` (`prior_U_gap`, `prior_S_gap`, `sep`; Reynolds 1992 p.168) | `dedekindRules` + admissibility | `Decidability/Tableau.lean`, `Refutation/Rules/Dedekind.lean` | **Missing entirely** (D5) |
| Subformula property over all rules | `Saturation.lean:1014` (initial branch only) | `applyRule_subformula_closed` | `Termination/SubformulaProperty.lean` | **To create**; needs `closureWithNeg` for Discrete |
| Pigeonhole on time types | Mathlib | `Finset.exists_ne_map_eq_of_card_lt_of_maps_to` | Mathlib | **Verified exists** |
| Order embedding of a finite order into a dense order | Mathlib | `Order.embedding_from_countable_to_dense` | `Mathlib.Order.CountableDenseLinearOrder` | **Verified exists** |
| Dedekind completeness of ℝ in `ValidDedekind`'s shape | Mathlib | `Real.isLUB_sSup` | `Mathlib.Algebra.Order.Archimedean.Real.Basic` | **Verified exists** |
| Discrete carrier instances | Mathlib | `SuccOrder ℤ`, `PredOrder ℤ`, `IsSuccArchimedean ℤ`, `IsPredArchimedean ℤ` | `Mathlib.Data.Int.SuccPred` | **Verified exists** |
| Shift-closure transport | `Truth.lean:446` `time_shift_preserves_truth`, `:339` `Set.univ_shift_closed` | `bridgeOmega_shiftClosed` | `Bridge/Omega.lean` | **Reusable** |
| Branch saturation facts | `CountermodelExtraction.lean:333-904` (`sat_imp_neg`, `sat_box_pos/neg`, `sat_untl_pos/neg`, `sat_snce_pos/neg`, …) | consumed by the new truth lemma | same | **Reusable verbatim** |
| Bespoke branch semantics to be replaced | `CountermodelExtraction.lean:263` `branchTruth` | superseded by `TruthAt` | delete or demote to a debugging aid | **To remove** |
| Orphaned truth lemma | `CountermodelExtraction.lean:1044` `branchTruthLemma` | replaced by `not_valid_of_hasOpen` | `Bridge/TruthLemma.lean` | **Orphan** (D4) |
| Deduction theorem / structural rules | `Core/DeductionTheorem.lean:325`, `MCSProperties.lean:68`, `Derivable.lean:110,147` | reused by every admissibility lemma | — | **Reusable**, `{fc}`-polymorphic |
| Generalized necessitation | `GeneralizedNecessitation.lean:148,183,223` | `boxPos`/`allFuturePos`/`allPastPos` admissibility | — | **Reusable** |
| Cut / uniform substitution admissibility | — | — | — | **Verified absent**; avoid designs that need it |
| Mosaic / quasimodel finitisation | **[lit]** Gabbay–Hodkinson–Reynolds 1994; Reynolds 2003 | — | `BXCanonical/Quasimodel/`, `Chronicle/` | Out of scope; advisory |

---

## 7. Hygiene Findings

All four confirmed by direct read.

| Declaration | Location | Verbatim defect | Action |
|---|---|---|---|
| `validity_decidable` | `Correctness.lean:78-82` | `(⊨ φ) ∨ ¬(⊨ φ) := Classical.em (⊨ φ)` | **Delete**, then replace with the real `Decidable (⊨ φ)` from Track A. Deleting before a replacement exists is preferable to keeping a misleading name. |
| `validity_has_decision_procedure` | `Correctness.lean:88-93` | `∃ decision : Bool, decision = true ↔ ⊨ φ`, proved by `by_cases` | **Delete**. Replace with `isValid φ fc = true ↔ ⊨ φ` once Track A lands. |
| `filtered_world_bound` | `FMP/FMP.lean:183-189` | `∃ n, n ≤ 2^(subformulaClosure phi).card ∧ ∀ (_S : FilteredWorld phi), True` | **Replace** with the real bound; the prior report (F8) machine-verified `Nat.card (Set ↥cl) = 2 ^ cl.card` as an *equality*. |
| `fmp_size_bound` | `FMP/FMP.lean:237-242` | `∃ bound, bound = 2^(subformulaClosure phi).card ∧ True` | **Replace**, same. |

Both FMP theorems violate `.claude/rules/lean4.md`'s prohibition on `∧ True`-padded / `trivial`
conclusions, which that rule declares semantically equivalent to `sorry`.

Documentation:

| Location | Defect | Action |
|---|---|---|
| `latex/subfiles/04-Metalogic.tex:351` | States the `2^{\|closure(φ)\|}` bound as established; it is vacuous | Mark as conjectural, or defer the edit until the bound is proved |
| `typst/chapters/p2-decidability-practice.typ:42` | Same bound claim, cites `FMP/FiniteModel.lean:131` | Same |
| `typst/chapters/p2-decidability-practice.typ:70,112` | **Already correct** — explicitly documents `validity_decidable` as "a vacuous classical tautology" | Keep; update the line reference (`:72` → `:78`) when the theorem is deleted |
| `typst/chapters/p2-decidability-practice.typ:26-28` | Records the semantics↔MCS bridge as an open problem | Accurate today; update on Track A completion |

The two typst passages are a good model: the repository already knows how to document a vacuous
result honestly. Extend that treatment to the LaTeX and to the FMP bound.

Repo health baseline: exactly **one** live `sorry` outside `Boneyard/` —
`countermodel_discrete` (`WeakCanonical/Transfer.lean:1242`). All other grep hits are prose
containing "sorry-free". The whole `Decidability/` tree is sorry-free and must stay that way.

---

## 8. Architecture Proposal — Composition Across the Frame-Class Lattice

This is the focus prompt's core ask: the decidability infrastructure should extend across
Base → Dense/Discrete/Dedekind the way the proof system and semantics already do, rather than as
four parallel copies.

### 8.1 What the existing code gets right, and what obstructs

**Supports composition:**

- `allRulesForFC` (`Tableau.lean:1067`) is already `base ++ conditional extensions` — the correct
  shape. It only needs a Dedekind arm (R6).
- `DerivationTree` threads `fc` as a single index with the side condition
  `h.minFrameClass ≤ fc` (`Derivation.lean:98`), and `DerivationTree.lift` (:190) gives free
  monotonicity. Any admissibility lemma stated `{fc} (h_fc : ruleFrameClass r ≤ fc)` inherits this.
- The five validity predicates differ **only** in binders on `D` (`Validity.lean:79,169,187,231,255`).
  A bridge parameterized by the carrier `D` and its instances specializes to all four classes
  with no new mathematics.

**Obstructs composition:**

- The rule lists (`denseRules`, `discreteRules`) are hand-maintained and **disconnected from
  `Axiom.minFrameClass`**. Nothing enforces that a `.Discrete`-gated rule is justified by a
  `.Discrete`-gated axiom. This is the single biggest maintainability risk: adding an axiom does
  not prompt a rule, and mis-gating is silent.
- `ProofExtraction.lean` is **Base-only** (`DerivationTree .Base [] φ` throughout, e.g. :58, :64,
  :338). Nothing in it generalizes over `fc`.
- `Correctness.lean` states everything at `⊨` (Base) only.
- `branchTruth` (`CountermodelExtraction.lean:263`) hard-codes a single, frame-class-agnostic
  bespoke semantics, so per-class work has nowhere to attach.

### 8.2 Proposed layout

A new subtree beside the existing engine, so the executable decision procedure and its
correctness theory stay separable:

```
FormalSystem/Metalogic/Decidability/
├── (existing engine — unchanged public API)
└── Verified/
    ├── RuleSpec.lean          -- `ruleFrameClass : TableauRule → FrameClass`
    │                          --  + `ruleAxioms : TableauRule → List (Σ φ, Axiom φ)`
    │                          --  + the GATE lemma (§8.3)
    ├── Internalize.lean       -- `Branch.internalize`, label→modality encoding
    ├── Refutation/
    │   ├── Core.lean          -- the generic induction, parameterized by RuleSpec
    │   ├── Rules/Propositional.lean   (8 rules)
    │   ├── Rules/Modal.lean           (5 rules)
    │   ├── Rules/Temporal.lean        (8 rules)
    │   ├── Rules/UntilSince.lean      (4 rules — the hard block)
    │   ├── Rules/Trichotomy.lean      (R2)
    │   ├── Rules/Dense.lean           (2)
    │   ├── Rules/Discrete.lean        (3, incl. z1)
    │   └── Rules/Dedekind.lean        (R6)
    ├── Termination/
    │   ├── SubformulaProperty.lean    -- T1, one case per rule
    │   ├── TimeTypeBound.lean         -- T2, pigeonhole
    │   └── Fuel.lean                  -- T3, `soundFuel'` + `buildTableau_isSome`
    ├── Bridge/
    │   ├── Carrier.lean       -- `class TemporalCarrier (fc) (D)`  (§8.4)
    │   ├── BranchOrder.lean   -- finite total order from a saturated branch
    │   ├── Embed.lean         -- `Order.embedding_from_countable_to_dense` + ℤ variant
    │   ├── Interpolate.lean   -- constant-on-intervals model + `interp_invariance`
    │   ├── Omega.lean         -- history + shift-closure
    │   └── TruthLemma.lean    -- `not_valid_of_hasOpen`, generic in the carrier
    ├── Decidable.lean         -- Track A: `Decidable (⊨ φ)` + 3 class corollaries
    ├── Provable.lean          -- Track B: `Decidable (Derivable fc [] φ)` + completeness
    └── README.md
```

### 8.3 The gate that makes composition self-enforcing

The one design element that turns "four parallel copies" into "base plus extensions" is a single
lemma tying the rule lattice to the axiom lattice:

```lean
/-- Every tableau rule declares the frame class it needs and the axioms that justify it. -/
def ruleFrameClass : TableauRule → FrameClass
def ruleAxioms     : TableauRule → List (Σ φ, Axiom φ)

/-- GATE: a rule is never available at a frame class that cannot derive its justifying axioms.
    Provable `by decide` over the finite product of 30 rules × 4 classes. -/
theorem ruleAxioms_minFrameClass_le (r : TableauRule) :
    ∀ a ∈ ruleAxioms r, a.2.minFrameClass ≤ ruleFrameClass r

/-- GATE: `allRulesForFC` agrees with `ruleFrameClass`. Also `by decide`. -/
theorem mem_allRulesForFC_iff (r : TableauRule) (fc : FrameClass) :
    r ∈ allRulesForFC fc ↔ ruleFrameClass r ≤ fc
```

Both are decidable over finite enumerations, so both are cheap to prove and — critically —
**cheap to keep true**. Adding a Dedekind rule without an accompanying Dedekind axiom breaks the
build immediately. This is the mechanism the current hand-maintained lists lack, and it is worth
building before any admissibility lemma is written, because it also fixes the shape those lemmas
must take.

The refutation core is then stated once:

```lean
theorem allClosed_derivable {fc : FrameClass} (φ : Formula) (t : ExpandedTableau)
    (h : t = .allClosed cbs) (h_built : buildTableau φ (soundFuel' φ) fc = some t) :
    Derivable fc [] φ
```

with **one** induction over `allRulesForFC fc`, discharging each rule by its admissibility lemma
and its `ruleFrameClass r ≤ fc` hypothesis. Dense/Discrete/Dedekind instantiate it; they do not
re-prove it.

### 8.4 The carrier class for the semantic bridge

Mirror the same idea on the semantic side. `Bridge/TruthLemma.lean` should be proved once against
an abstract carrier and instantiated four times:

```lean
/-- What the bridge needs of a carrier for a given frame class. -/
class TemporalCarrier (fc : FrameClass) (D : Type)
    [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D] where
  /-- Any finite linear order embeds monotonically. -/
  embed_finite : ∀ (T : Type) [LinearOrder T] [Finite T], Nonempty (T ↪o D)
  /-- The class-specific frame condition, in the shape `Validity.lean` demands. -/
  frame_condition : FrameConditionFor fc D
```

Instances: `TemporalCarrier .Base ℚ`, `.Dense ℚ`, `.Discrete ℤ`, `.Dedekind ℝ`. The first, second
and fourth get `embed_finite` from `Order.embedding_from_countable_to_dense` (verified); the third
needs the elementary hand-rolled `Fin n ↪o ℤ`. This is the only place where the four classes
genuinely diverge, and confining the divergence to four instance declarations is exactly the
"base development plus modular extensions" the focus prompt asks for.

### 8.5 Two-track deliverable

```lean
-- Track A (no Hilbert system involved)
theorem valid_iff_allClosed (φ : Formula) :
    (⊨ φ) ↔ (buildTableau φ (soundFuel' φ) .Base).any ExpandedTableau.isValid
instance : Decidable (⊨ φ)              -- + ValidDense / ValidDiscrete / ValidDedekindDense

-- Track B (needs WP2)
instance : Decidable (Derivable fc [] φ)
theorem completeness_of_decision (fc) (φ) : ValidFor fc φ → Derivable fc [] φ
```

Track A's `allClosed → valid` direction is a *semantic* rule-soundness induction, materially
cheaper than `allClosed → Derivable`, and much of it is already present as the `sat_*` family.
Track B's completeness corollary is what discharges `countermodel_discrete`
(`Transfer.lean:1242`) and supplies the Dedekind engine for `completeness_dedekind_of_engine`
(`StrongCompleteness.lean:308`) — but only Track B does, so the charter's "as a corollary" should
be read as "as a corollary of WP2", not of WP3+WP4.

---

## 9. H4 Adversarial Self-Verification

I re-read the draft with a mandate to refute each load-bearing claim, and ran additional Lean
checks designed to break them. Three claims were revised and one was retracted outright.

### Claim Verification Table

| Claim | Attempted refutation | Verification method | Confidence |
|---|---|---|---|
| `allRules` has 25 entries, total 30 rules (charter says 23/28) | Recounted from source twice; cross-checked against the 30 `TableauRule` constructors | Direct read `Tableau.lean:73-143, 1029-1060` | High |
| Counterexample A's branch has no linear model | Tried to find a linear order satisfying it: `t0<t1<t2` forces `t0<t2`, and `T(Gp)@t0` forces `p@t2` against `F p@t2` | `lean_run_code` produced the branch; unsatisfiability argued from the branch's own constraints | High |
| A's cause is non-transitive `futureOf`, not the `AppliedSet` | **This was my first, wrong attribution.** I suspected the applied set. Ran `applyRule .someFutureNeg` on the branch with an **empty** applied set: still `persistent -> times [1]` | `lean_run_code`, decisive | High |
| Counterexample B's branch has no linear model | Exhaustive trichotomy on `t1` vs `t2`; all three cases contradict | `lean_run_code` produced the branch; three-case argument | High |
| B shows a missing trichotomy rule, not merely a missing axiom | Checked whether the Hilbert system lacks linearity — it does **not**: `temp_linearity` (`Axioms.lean:238`) and `linear_until` (:196) exist. So the gap is on the tableau side only | Subagent inventory + direct read | High |
| B's closure is syntax-sensitive (axiom form closes, permutation does not) | Checked whether `checkAxiomNeg` explains the axiom form's closure: `matchAxiom` recognizes 20 of 45 axioms and `temp_linearity` is **not** among them, so that closure was rule-driven | `grep -o 'Axiom\.[a-z_]*'` over `ProofSearch/Core.lean:321-470` | Medium-High — I did not isolate *which* rule closed it |
| `ancestorTimes` makes every constrained time its own ancestor | Tried to find a constraint set where it does not: the two-step `1→0→1` path is unavoidable for any incident edge | `#eval ancestorTimes ⟨[(0,1)]⟩ 1 = [0,1]` | High |
| Blocking therefore fires vacuously | Constructed a branch where the genuine subset condition **fails** (`isSubsetBlocked b 1 0 = false`) and confirmed `isTemporallyBlocked b 1 ord = true` anyway; also confirmed `findBlockedTime b ⟨[]⟩ = none` (so the ordering is the trigger) | `lean_run_code`, three evals | High |
| `allEventualitiesFulfilledOrDuplicated` arguments are swapped | Compared the definition's binders (`:732-733`, `t_new t_anc`) with the call site (`:763`, `t_anc t`) | Direct read | High |
| `branchTruthLemma` is an orphan whose hypothesis the pipeline never meets | Searched for any consumer; then searched for a concrete pipeline output failing the hypothesis — `◇p` is one | `grep` (no consumer) + `lean_run_code` | High |
| `buildTableau` returning `none` is not a fuel problem | Re-ran at fuel 100000 and traced the `none` to `Saturation.lean:598` (post-blocking non-saturation), not `:583` | `lean_run_code` (`diag` harness distinguishing stage 1 from stage 2) | High |
| No Dedekind rule list exists | Read `allRulesForFC` in full | Direct read `Tableau.lean:1067-1071` | High |
| Mathlib names cited in §4.3/§5.3 exist | **My first verification run was worthless** — `import Mathlib` alone silently elaborates to nothing in this project, so a deliberately bogus `#check` "passed". Re-ran every check under the project import with a control error line present | `lean_run_code` with control; `Fintype.exists_ne_map_eq_of_card_lt` was thereby caught as **nonexistent** | High |
| T1 (subformula property) is false for `priorUZ`/`priorSZ` without negation closure | `priorUZ` emits `U(φ, ¬φ)` from `F φ`; `¬φ` is not a subformula of `F φ` | Read `Tableau.lean:136-139` + `Axioms.lean:315` | Medium-High — argued from the rule's docstring and axiom, not from an executed closure computation |
| Track A can avoid WP2 entirely | Checked whether completeness sneaks back in: it does not for `Decidable (⊨ φ)`, but it **does** for `Decidable (Derivable …)`. Charter's "completeness as a corollary" needs WP2 | Structural argument over the four theorem statements | Medium-High — not machine-checked |
| Dedekind gating (Base+Dense, no Discrete) is correct | Tried to refute by finding a Dedekind terminus needing discreteness: `completeness_dedekind_of_engine` consumes `ValidDedekindDense`, and `Axioms.lean:440-443` explicitly warns that `density`/`dense_indicator` are refutable on ℤ | Direct read `StrongCompleteness.lean:274,308` + `Axioms.lean:440-443` | High |
| Four vacuous theorems | Read all four bodies verbatim | Direct read | High |
| Exactly one live `sorry` outside `Boneyard/` | Re-grepped; all other hits are prose containing "sorry-free" | `grep` + inspection | High |

### Contradiction Log

**C1 — RESOLVED (my own error, caught and corrected).** My initial reading of counterexample A
attributed the failure to `AppliedSet` suppression of persistent rules. Direct application of
`applyRule .someFutureNeg` with an empty applied set refuted this: propagation stops at time 1
regardless. Precedence: machine-checked evaluation over inference. The report now attributes D1
to `TimeOrdering.futureOf` alone, and the `AppliedSet` is explicitly exonerated.

**C2 — RESOLVED (harness artifact, caught).** My first Mathlib verification pass used
`import Mathlib` and reported "zero diagnostics", which I initially read as success. A control
test (`example : True := Order.thisNameDoesNotExist`) also reported zero diagnostics, proving the
pass was vacuous. Every Mathlib claim was re-verified under `import FormalSystem…` plus explicit
module imports, with a control error present in each run. This caught one false name
(`Fintype.exists_ne_map_eq_of_card_lt`, which does not exist) that would otherwise have shipped.
**Every `#check`-style verification in this report was run with a control error.**

**C3 — RESOLVED (charter correction).** The charter frames `Discrete ≰ Dedekind` as a hazard
requiring an adequacy proof. It is instead the correct gating, because the Dedekind terminus the
repo needs is `ValidDedekindDense`. The real Dedekind gap is the absence of any rules for
`prior_U_gap`/`prior_S_gap`/`sep` (D5), which the charter does not mention. Recorded so a planner
does not spend a phase proving something that is already right while missing what is missing.

**C4 — RESOLVED (charter correction).** The charter describes `blocking_terminates` as having
been found FALSE, implying blocking is too weak. The evidence shows the opposite failure mode:
blocking is vacuously too strong (D3), and the observed non-termination of `buildTableau` is a
*consequence* of over-eager blocking colliding with `saturateBlocked`'s refusal to create times.
Any plan phrased as "strengthen blocking" is aimed at the wrong end.

**C5 — PARTIALLY UNRESOLVED.** I did not isolate which rule closes the exact `temp_linearity`
axiom-instance form while the logically equivalent permutation stays open. `matchAxiom` is
excluded, so it is rule-driven, but the specific mechanism is unknown. **Downstream risk:** low
for the WP1 verdict (counterexample B stands on its own — its branch is machine-produced and
provably unsatisfiable), but it means I cannot say how *much* of linearity the current rules
incidentally cover, which affects sizing of the `orderTrichotomy` phase. **Resolving check not
yet performed:** instrument `rawExpand` to log the rule sequence for both forms and diff them.

### Recommendations Modified After Verification

1. **Retracted:** "the AppliedSet suppresses transitive propagation" (C1). Replaced by the
   `futureOf` root cause.
2. **Retracted:** the entire first Mathlib verification pass, including a nonexistent lemma name
   (C2). Replaced by control-verified checks.
3. **Added:** D3 (vacuous blocking) and the `allEventualitiesFulfilledOrDuplicated` argument swap
   — neither was in the charter, and both invalidate WP3 as charted.
4. **Added:** D4 (`branchTruthLemma` orphan) with the `◇p` witness, and D5 (no Dedekind rules).
5. **Added:** the negation-closure trap in T1 for `priorUZ`/`priorSZ`.
6. **Changed:** rule count 28 → 30 (25 base), which resizes WP2.
7. **Changed:** the Dedekind framing (C3) and the blocking framing (C4).
8. **Added:** the two-track split (§8.5), which was not in the charter and which makes a green
   milestone reachable without WP2.

No revision of search direction was required; no `## Revised Direction` section is needed.

---

## 10. Risks

| Risk | Severity | Assessment / mitigation |
|---|---|---|
| `orderTrichotomy` (R2) multiplies branching combinatorially — `k` fresh times against `k` existing ones is `3^k` splits | **High** | The standard mitigation is to only branch against times that are actually incomparable *and* relevant (share a world and a temporal formula). Prototype the rule and re-run the §2 probes before committing to WP3's fuel bound. |
| WP1 repairs invalidate existing proofs | Medium | `expandBranchWithFuel_sound` (`Saturation.lean:1184`), `blocking_sound` (:1247) and the `Closure.lean` monotonicity family all depend on the blocking predicate. R3/R4 will break `blocking_sound`; budget its reproof. |
| Interpolation lemma (§5.2 step 3) is the real mathematical core | **High** | Comparable in weight to canonical-model completeness, as the charter says — but only after R2 exists, because the guard obligation it discharges is not currently produced by any rule. Do not start WP4 before WP1-repair is green. |
| `Branch.internalize` (WP2) may not exist in a usable form | **High** | Labelled-to-unlabelled internalization for S5 + linear time is standard but nontrivial. Mitigation: Track A does not need it at all. If internalization stalls, Track A still delivers. |
| `z1Rule` admissibility needs both premises at the same label | Medium | Design `internalize` with this constraint from the start (§3.3). Retrofitting is expensive. |
| Dedekind rules (R6) have no prior art in the tree | Medium | `prior_U_gap`/`prior_S_gap` use `K⁺`/`K⁻` (`Formula.lean:180,193`), which no current rule touches. Expect a genuine design phase, not a transcription. |
| `soundFuel` uncapping makes the procedure impractically slow | Low-Medium | Keep `soundFuel` (capped, fast) as the *runtime* default and introduce `soundFuel'` (uncapped, justified) used only in the theorem. The two need not coincide. |
| Deleting `validity_decidable` breaks documentation references | Low | `typst/…:70,112` reference it by name; update in the same phase. |
| Literature grounding is thin | Medium | The key survey is truncated in-repo and Goldblatt 1992 is unacquired. Every claim here is Lean-grounded, but the `untlNeg` and Dedekind rule designs would benefit from acquiring Reynolds 1992/2003 before those phases. Recommend a `/literature` acquisition pass before WP2's Until/Since block. |

---

## 11. Recommended Phase Structure

Each phase is sized to one agent run and ends with a `lake build` and a green commit.

| Phase | Deliverable | Gate |
|---|---|---|
| 1 | **R1+R3+R4**: transitive `futureOf`/`pastOf` (reuse `isTimeOrderedBefore`), predecessor-only `ancestorTimes`, fix the swapped eventuality arguments. Re-run the §2 probes as regression `#eval`s. | Counterexample A closes; `isTemporallyBlocked` no longer fires on the §2.4 branch |
| 2 | **R7**: split `.timeout` into `.fuelExhausted` / `.extractionFailed`; reprove `decide_result_exclusive` | Build green |
| 3 | **R2**: `TableauRule.orderTrichotomy` + `applyRule` case + `isApplicable`; branches shaped as `temp_linearity`'s disjuncts | Counterexample B closes; no regression in the `Saturation.lean` `#eval` test suite (lines 700-1600) |
| 4 | **R6**: `dedekindRules` for `prior_U_gap`/`prior_S_gap`/`sep`; `allRulesForFC` Dedekind arm | Build green; Dedekind axiom instances close |
| 5 | `Verified/RuleSpec.lean`: `ruleFrameClass`, `ruleAxioms`, both GATE lemmas `by decide` | Both gates proved |
| 6 | **WP3-T1**: `applyRule_subformula_closed`, all 31 rule cases; `closureWithNeg` for Discrete | Theorem proved sorry-free |
| 7 | **WP3-T2+T3**: pigeonhole via `Finset.exists_ne_map_eq_of_card_lt_of_maps_to`; `soundFuel'`; `buildTableau_isSome` | `buildTableau` totality proved |
| 8 | **R5** + `Bridge/BranchOrder.lean` + `Bridge/Embed.lean` + `Bridge/Carrier.lean` with all four instances | Four `TemporalCarrier` instances elaborate |
| 9 | **WP4 core**: `Bridge/Interpolate.lean` — constant-on-intervals model and `interp_invariance` | The `untl`/`snce` cases proved |
| 10 | **WP4 finish**: `Bridge/Omega.lean` + `Bridge/TruthLemma.lean` — `not_valid_of_hasOpen`, generic in the carrier; delete `branchTruth` | Theorem proved; `sat_*` family reused |
| 11 | **Track A**: semantic rule soundness (`allClosed → valid`) + `valid_iff_allClosed` + `Decidable` instances for all four classes | **Headline result 1** |
| 12 | **Hygiene**: delete `validity_decidable`, `validity_has_decision_procedure`; replace `filtered_world_bound`, `fmp_size_bound` with the real bound; update LaTeX/typst | No vacuous theorems remain in `Decidability/` |
| 13-18 | **Track B / WP2**: `Internalize.lean`; then `Rules/Propositional`, `Rules/Modal`+`Temporal`, `Rules/UntilSince` (own phase), `Rules/Trichotomy`+`Discrete`+`Dense`+`Dedekind`, `Refutation/Core` | `allClosed_derivable` |
| 19 | **Track B finish**: `Decidable (Derivable fc [] φ)`; completeness corollaries; discharge `countermodel_discrete`; supply the Dedekind engine | **Headline result 2** |

Phases 1-4 are the WP1 repair and are non-negotiable prerequisites. Phase 11 is the first
publishable milestone. Phases 13-18 should not start until 1-11 are green.

---

## 12. References

**Tableau engine.**
`Decidability/SignedFormula.lean:59,108,161,240,549,562,622,632,654,676,681,707,732,759,771`;
`Decidability/Tableau.lean:73,156,274,345,502,511,542,551,672,717,765,915,965,1019,1029,1049,1057,1067,1077,1149,1186`;
`Decidability/Closure.lean:83,91,102,122,188-351`;
`Decidability/Saturation.lean:50,242,473,516,579,608,627,646,1014,1025-1079,1184,1247`;
`Decidability/ProofExtraction.lean:58,64,110,146,217,258,338`;
`Decidability/CountermodelExtraction.lean:176,198,263,311,333-904,1044`;
`Decidability/DecisionProcedure.lean:64,128,169,185`;
`Decidability/Correctness.lean:56,78,91,101,129`;
`Decidability/FMP/FMP.lean:183,204,217,237`.

**Proof system.**
`ProofSystem/Axioms.lean:84-402` (45 axiom ctors), `:123,134,156,174,186,196,205,226,238,255,268,276-303,315,320,332,343,354,377,387,398`, `:449-454` (`FrameClass`), `:456-463` (order), `:489-496` (order regression examples), `:518-527` (`minFrameClass`), `:530` (`base_le`);
`ProofSystem/Derivation.lean:91-167,190,223`; `ProofSystem/Derivable.lean:69,99-174`;
`Automation/ProofSearch/Core.lean:321` (`matchAxiom`, 20 of 45 axioms).

**Derived-rule assets for WP2.**
`Metalogic/Core/DeductionTheorem.lean:163,173,184,198,325,447,467`;
`Metalogic/Core/MCSProperties.lean:68`;
`Theorems/GeneralizedNecessitation.lean:95,114,148,183,223`;
`Theorems/Combinators.lean:99,112,555,589,653`;
`Theorems/TemporalDerived.lean:188,244,260,268,275,283,331,457,475,504,514`;
`Theorems/ModalS5.lean:465,717`; `Theorems/ContextualProofs.lean:67-465`.

**Semantics.**
`Semantics/TaskFrame.lean:99-128,293`; `Semantics/TaskModel.lean:49,97`;
`Semantics/WorldHistory.lean:75-104,140,246,302`;
`Semantics/Truth.lean:128-137,333,339,446`;
`Semantics/Validity.lean:79,103,129,154,169,187,231,255,269-303`;
`FrameConditions/FrameClass.lean:88,103,124,148,182`.

**Completeness hooks.**
`Metalogic/StrongCompleteness.lean:274` (`consequence_completeness_dedekind_of_engine`), `:308` (`completeness_dedekind_of_engine`);
`Metalogic/WeakCanonical/Transfer.lean:1225,1242` (the single live `sorry`), `:568-607` (ℤ-interval frame — the closest existing countermodel-construction helper).

**Syntax.** `Syntax/Formula.lean:76-90` (6 primitives), `:118-193,433-529` (derived operators, incl. `kPlus` :180 / `kMinus` :193 used by the Dedekind axioms), `:619` (`swapTemporal`);
`Syntax/SubformulaClosure/Closure.lean:36,71` (`subformulaClosure`, `closureWithNeg`).

**Mathlib (all control-verified).**
`Finset.exists_ne_map_eq_of_card_lt_of_maps_to`;
`Order.embedding_from_countable_to_dense` (`Mathlib.Order.CountableDenseLinearOrder`);
`Order.iso_of_countable_dense`;
`Real.isLUB_sSup` (`Mathlib.Algebra.Order.Archimedean.Real.Basic`);
`SuccOrder ℤ` / `PredOrder ℤ` / `IsSuccArchimedean ℤ` / `IsPredArchimedean ℤ` (`Mathlib.Data.Int.SuccPred`);
`DenselyOrdered ℚ` / `ℝ`, `IsOrderedAddMonoid ℚ` / `ℝ` / `ℤ`.
Verified **nonexistent**: `Fintype.exists_ne_map_eq_of_card_lt`. Verified **absent** from Mathlib: any modal-logic tableau or filtration development.

**Documentation.**
`latex/subfiles/04-Metalogic.tex:351,405`;
`typst/chapters/p2-decidability-practice.typ:19,26-28,42,70,112-113`.

**Prior artifact.** `specs/165_establish_semantic_finite_model_property/reports/01_semantic-fmp-research.md` — the semantic-FMP route, now out of scope. Its F4 (`D` is necessarily infinite), F5 (frame classes constrain only `D`), F6 (six-constructor filtration lemma compiles), F8 (`Nat.card (Set ↥cl) = 2 ^ cl.card`) and F9 (shift-closure transport) remain valid and are reused above in §5.2 and §7.

**Literature (advisory only, no load-bearing claim).**
Prior / Burgess, linear-time axiomatization (internalized as `temp_linearity`, `linear_until`, `linear_since`);
Reynolds 1992 (Dedekind gap axioms, cited at `Axioms.lean:377`);
Reynolds 2003 (quasimodels; the `untlNeg` co-decomposition);
Gabbay–Hodkinson–Reynolds 1994 (mosaics).
The repository's `specs/literature/` contains no processed text for any of these; recommend a `/literature` acquisition pass before the WP2 Until/Since and Dedekind rule phases.
