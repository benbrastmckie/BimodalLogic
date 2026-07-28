# Supplementary Research Report 03 — cslib Tableau & Decidability Survey

**Task**: 165 — Establish semantic finite model property / verified decidability for the TM tableau
- **Started**: TBD
- **Completed**: TBD
- **Effort**: TBD
- **Dependencies**: TBD
- **Sources/Inputs**: TBD
- **Artifacts**: TBD
- **Standards**: TBD
**Scope**: supplementary. Surveys `/home/benjamin/Projects/cslib/` only. A sibling dispatch covers
the BimodalLogic repo itself; this report does not duplicate it.
**Mode**: hard (H2 grounding, H3 Tier 3 implementation-backed, H4 adversarial verification)
**Date**: 2026-07-27

All `Cslib/...` and `specs/...` paths below are relative to `/home/benjamin/Projects/cslib/`.
All `FormalSystem/...` paths are relative to `/home/benjamin/Projects/BimodalLogic/`.

---

## Executive Summary

1. **cslib is not a fork to merge from — it is a laboratory whose failures are the deliverable.**
   cslib's `Cslib/Logics/Bimodal/Metalogic/Decidability/` is a *stale downstream port* of
   BimodalLogic's own tableau (7,439 lines vs BimodalLogic's 9,264; `Saturation.lean` 721 vs
   1,620). Nothing there is ahead. The value is in three *sibling* subsystems built afterwards:
   `Cslib/Foundations/Logic/Tableau/` (914 lines, genuinely logic-generic),
   `Cslib/Logics/Modal/Tableau/` (39,857 lines, six sorry-free `Decidable` instances), and
   `Cslib/Logics/Temporal/Tableau/` (4,257 lines, blocked but with a fully documented postmortem).

2. **Four defects cslib found the hard way are almost certainly latent in BimodalLogic's tableau,
   and each maps to a task-165 work package.** In descending order of consequence:
   - **No seriality rule** → the tableau returns `.openBranch` on *valid* formulas
     (`𝐅⊤`, `𝐆p → 𝐅p`). Refuted by execution, not conjecture (WP1).
   - **Fuel constant is quadratic while the step count is exponential** — a non-sequitur visible
     on the face of the definition, measured to cross over near `k = 12` (WP3).
   - **Blocking recorded as an accessibility *edge* rather than a world *identification*** — this
     is the root cause of a four-route failure in cslib's S4 work and it is what makes soundness
     unprovable against an existentially-quantified model (WP1/WP2/WP4).
   - **An "island" countermodel is systematically biased toward `false`**, which breaks *positive
     universals* `𝐆`/`𝐇`, not (as usually assumed) unfulfilled eventualities (WP4).

3. **The single highest-value directly-portable asset is `Cslib/Foundations/Logic/Tableau/`** — 9
   files, 914 lines, generic over formula type `F` and label type `L`, already exercising
   `L = Unit`, `L = Nat`, `L = WorldIndex`. BimodalLogic has *no* Foundations-level tableau layer
   at all; `L := Label{world,time}` is the obvious instantiation and is exactly the
   frame-class-composability substrate task 165's architecture goal asks for.

4. **The second-highest-value asset is a *pattern*, not code: `RuleApplicationSpec` /
   `RuleApplicationSpecCore`** (`Modal/Tableau/GenericDriver.lean:179,286`) — a structural-
   hypothesis bundle that lets soundness, completeness, termination, and the `Decidable` instance
   be proved *once, generically*, and then discharged per frame class. Six modal systems
   (K/T/B/S5/K5/KB5) ride it. It is **not** formula-generic (hard-typed to
   `Proposition Atom`/`WorldIndex`), so it must be re-derived, not imported — but the *two-tier
   split* (completeness-only core vs full termination bundle) is the design insight worth copying.

5. **Version compatibility is good on toolchain, bad on syntax.** Both repos pin
   `leanprover/lean4:v4.33.0-rc1`. Mathlib revs differ (cslib `169c26b5`, BimodalLogic `79d0395a`
   = tag `v4.33.0-rc1`). The real friction: cslib uses the Lean **module system** (`module`,
   `public import`, `@[expose] public section`) in 684 files; BimodalLogic uses it in **0 of 462**.
   Any file copy needs mechanical but pervasive de-modularization.

---

## 1. The cslib Tableau/Decidability Landscape

| Subsystem | Lines | Status | Relevance to task 165 |
|---|---|---|---|
| `Cslib/Foundations/Logic/Tableau/` (9 files) | 914 | Sorry-free, in use by 3 logics | **Direct port candidate** |
| `Cslib/Logics/Modal/Tableau/` (20 files) | 39,857 | 1 sorry; 6 `Decidable` instances landed | Pattern source (WP2/WP3) |
| `Cslib/Logics/Temporal/Tableau/` (8 files) | 4,257 | 0 sorries, but completeness *unstated* (blocked) | **Closest analogue** (WP1/WP3/WP4) |
| `Cslib/Logics/Propositional/Tableau/` | ~7,000 | Classical complete; Intuitionistic 3 sorries | Truth-lemma template |
| `Cslib/Logics/Bimodal/Metalogic/Decidability/` | 7,439 | Stale port *of* BimodalLogic | **Nothing to harvest** |
| `CslibTests/TableauConformance.lean` | 332 | Executable `#eval` regression corpus | **Method to copy (see §6)** |

Repo-wide code-position sorry census: **28** (command in `Modal/Tableau/LoopChecking.lean:110-120`;
that file also documents why three different "sorry count" definitions circulate and disagree).
Within the tableau subsystems: `Modal/Tableau/FrameSoundness.lean:1276` (the S4 ancestor-redirect
obstruction, §3.3), plus 3 in `Propositional/Tableau/Intuitionistic|Minimal`. Modal `Tableau/`
declares **0** axioms.

### 1.1 Landed decision procedures (verified)

`instDecidableKValid` (`Modal/Tableau/CompletenessLoop.lean:2295`), and `instDecidableTValid`
(`FrameCompleteness.lean:1315`), `instDecidableBValid` (`:1931`), `instDecidableS5Valid`,
`instDecidableFiveValid`, `instDecidableKb5Valid` (all `FrameCompleteness.lean`). Classical
propositional: `classicalTableau_complete`
(`Propositional/Tableau/Classical/Completeness.lean:1310`). Intuitionistic FMP: `int_fmp`
(`Propositional/Metalogic/IntDecidability.lean:440`).

**Contrast with BimodalLogic's current terminus**: `FormalSystem/Metalogic/Decidability/
Correctness.lean:78`, `validity_decidable`, is proved by `exact Classical.em (⊨ φ)` — a
placeholder, not a decision procedure. `validity_has_decision_procedure` (`:88`) is likewise
`by_cases` + `⟨true/false, _⟩`. cslib demonstrates what the real shape looks like: a
`Decidable (fcValid φ)` instance whose evidence *is* the tableau computation.

---

## 2. Directly Portable: the Foundations kernel

`Cslib/Foundations/Logic/Tableau/` is logic-agnostic and small enough to read in one sitting.

| File | Lines | Content |
|---|---|---|
| `Sign.lean` | 111 | `Sign` (pos/neg), `flip`, `ReflBEq`/`LawfulBEq` instances |
| `SignedFormula.lean` | 97 | `SignedFormula F L` — **sign + formula + label**, `deriving DecidableEq, Hashable` |
| `RuleResult.lean` | 94 | `RuleResult F L` — `linear`/`branching`/`persistent`/`notApplicable` |
| `Branch.lean` | 111 | `Branch F L := List (SignedFormula F L)` + `labels`, `formulasAt`, `findContradiction` |
| `Closure.lean` / `ClosureCondition.lean` | 62 + 108 | `ClosureReason F L`; `class ClosureCondition F L` with `findClosure : Branch F L → Option (ClosureReason F L)`; `ClassicalClosure` / `IntuitionisticClosure` instances |
| `PropositionalRules.lean` | 158 | 8 propositional rules parameterized over decomposition functions |
| `Measure.lean` | 137 | **Pure `Nat`/`List` arithmetic**: `geomCap`, `geomCap_add_one_le_pow`, `pow3_two_add_one_le`, `pow3_add_one_le`, `sum_map_le_length_mul` |

Three facts make this a genuine port candidate rather than a curiosity:

- The label type `L` is a free parameter, and `SignedFormula.lean:33-36` explicitly documents
  `L = Unit` (classical), `L = Nat` (intuitionistic/temporal), `L = WorldIndex` (modal). Nothing
  prevents `L := Label` (BimodalLogic's world×time pair) — this is the *same* generalization
  BimodalLogic's `SignedFormula.lean` hard-codes.
- `ClosureCondition` returns `Option (ClosureReason F L)` rather than `Bool`, precisely so
  callers can extract the closure witness for proof extraction and countermodel construction
  (`ClosureCondition.lean:26-30`). BimodalLogic's per-frame-class closure detection is a natural
  instance family here — one instance per frame class, one algorithm.
- `Measure.lean` references no logic at all. `geomCap Sf k = Σ_{i≤k} Sf^i` with
  `geomCap_add_one_le_pow : 2 ≤ Sf → geomCap Sf k + 1 ≤ Sf^(k+1)`, and the two base-3
  strict-decrease facts, are the arithmetic core of any damped-worklist termination argument.
  This is WP3 infrastructure available for the cost of a copy-paste.

**Extraction provenance**: this file was extracted from the modal tableau in cslib task 455
(`specs/archive/455_extract_tableau_measure_arithmetic/`), i.e. it was *proved in anger first,
generalized second* — the failure mode of speculative abstraction was avoided.

---

## 3. Design Lessons (things that worked)

### 3.1 `RuleApplicationSpec`: prove once, discharge per frame class

`Modal/Tableau/GenericDriver.lean` defines a two-tier structural-hypothesis bundle over a rule
function `apply : RuleApply Atom` (`Saturation.lean:108`):

- **`RuleApplicationSpecCore apply`** (`:179`) — 8 fields (`freshLocal`, `outputsSubsetUniverse`,
  `persistentFresh`, `branchingLength`, F8 `localShapeInvariance`, F9 `boxPosNotExpanding`,
  F10 `diaNegNotExpanding`, F11′/F12′ `boxNegWitness'`/`diaPosWitness'`). This is **exactly what
  the completeness/Hintikka chain consumes** — no termination fields.
- **`RuleApplicationSpec apply`** (`:286`) — extends Core with the three per-single-call
  termination facts (`rankStep`, `outDegStep`, `knownWorldsStep`).

The payoff, quoted from `GenericDriver.lean:134-141`: `modalExpandBranchesGen_hintikka` turns *any*
`RuleApplicationSpec` witness into a Hintikka-set-producing top-loop lemma for free; T's
completeness work needed new content "only at the two shapes where T's rule differs from K's."
Soundness is likewise generic via `branchSatisfiableIn FC` / `frameValid FC`
(`FrameSoundness.lean:110`), which generalize the K notions with an **explicit frame-condition
predicate `FC`** — one soundness induction, six frame classes.

**Why the split matters for task 165**: it is the mechanism by which S5's witness-*reuse* rule
`modalApplyOneS5w` (`S5Simplification.lean:543`) can discharge everything completeness needs
(`:2081`) while being unable to discharge the termination fields. This is the exact shape task
165's architecture goal describes — a base tableau plus modular per-frame-class extensions where
each extension pays only for what it changes.

**Two-column caveats, both load-bearing:**
- The F9–F12 payloads are **existentially quantified on purpose** (`:236-238`, `:252-258`). The
  concrete-witness form would exclude any rule that redirects an edge to an already-known world.
  Weaken witness fields to existentials from the start.
- **`RuleApplySt`** — the state-threading generalization (`specs/557/.../reports/01:493-534`)
  proposed after the S4 driver was forced to fork because `keys` could not be returned from
  `apply`. The measured cost of *not* having it: a second redundant `blockingWorldS4Keyed` call
  per step, 85 private lemmas, and *two* preservation lemmas per invariant field (386 lines for
  `outDegEq` alone). **If BimodalLogic's rule function needs to thread `TimeOrdering`, the
  eventuality tracker, and blocking keys, design the state parameter in from day one.**

### 3.2 The `instant : Nat → ℤ` scheme replaces an acyclicity proof (WP1/WP4)

This is the single cleanest transferable idea in the survey.

**The false lemma.** cslib's temporal tableau originally asserted
`ordConstraints_strict : (t,t') ∈ ord.constraints → t < t'` — i.e. that the Nat label order
coincides with semantic "before". It is **false**, with an explicit counterexample:
`addPast t tNew` records `(tNew, t)` while `tNew = branchNextTime b > t` numerically
(`specs/archive/426_.../reports/01_ordconstraints-redesign.md:60-68`).

**What the consumer actually needs.** `branchSat` (`Temporal/Tableau/Soundness.lean:95`)
existentially quantifies over the time domain `D` *and* the assignment `f : TimeIndex → D`. It
never requires `f = id` or `D = Nat`. It needs only *some* order-preserving `f`.

**The fix.** Carry an integer position per label, fixed at creation
(`Temporal/Tableau/TimeOrdering.lean:59-93`):

```
structure TimeOrdering where
  constraints : List (Nat × Nat)
  instant : Nat → ℤ := fun _ => 0
-- addFuture t tNew : instant tNew := instant t + 1
-- addPast   t tNew : instant tNew := instant t - 1
```

with the replacement invariant `InstantStrict ord : ∀ a b, (a,b) ∈ ord.constraints →
ord.instant a < ord.instant b` (`TimeOrdering.lean:225-226`), preserved edge-by-edge by
`instantStrict_addFuture`/`instantStrict_addPast` (`:243`, `:264`) — each an `omega` after a
freshness `if_neg`. `ℤ` supplies `LinearOrder` + `Nontrivial` by `inferInstance`.

**No global acyclicity, no topological sort, no `Mathlib.Order.Extension.Linear` machinery.** The
report explicitly evaluated and rejected both alternatives: Option A (Szpilrajn via
`LinearExtension`/`toLinearExtension`) needs a global forest/antisymmetry invariant; Option C
(post-hoc instant reconstruction) re-introduces the same forest invariant
(`.../01_ordconstraints-redesign.md:126-186`).

**This is the concrete answer to WP1's "branch time-order is partial while TM time is linear."**
The branch order does not have to *be* linear. It has to *embed* order-preservingly into one,
and a locally-maintained integer stamp is the cheapest witness. BimodalLogic's `TimeOrdering`
(`FormalSystem/Metalogic/Decidability/SignedFormula.lean:654-657`) has `constraints` and nothing
else — no `instant` field, no `InstantStrict`-analogue anywhere in the tree (grep confirms).

**Adversarial caveat (see §7)**: the `±1` stamp is a *discrete* construction. It gives `D = ℤ`,
which serves BimodalLogic's Discrete frame class directly and Base indirectly (ℤ is a linear
order), but does **not** by itself deliver Dense (ℚ) or Dedekind (ℝ). For those, the same
*strategy* applies with a different stamp (rational interpolation between existing instants) —
and BimodalLogic already has rational-interpolation machinery in the Chronicle construction, per
its own recent commit log.

### 3.3 Blocking must record an *identification*, not an *edge* (WP1/WP2/WP4)

This is cslib's most expensively-learned lesson, documented at
`specs/557_.../reports/01_tableau-abstraction-boneyard-analysis.md:190-260`.

**What cslib did.** On a blocked minting step, `modalApplyOneS4Keyed`
(`LoopChecking.lean:747-759`) returns `(.linear [], acc.addEdge sf.label wBlock)` — no formula,
one edge.

**Why that edge is fatal.** `acc` feeds two incompatible model notions:
- Completeness *constructs* the model: `extractModelS4 b acc = extractModelWith
  Relation.ReflTransGen b acc` (`FrameCompleteness.lean:143-146`). Worlds are `WorldIndex`,
  `f = id`. An extra edge is just an extra edge; frame conditions are free.
- Soundness *existentially quantifies*: `branchSatisfiableIn FC b acc`
  (`FrameSoundness.lean:110`) is `∃ W (m : Model W Atom) (f : WorldIndex → W), FC m.r ∧
  (∀ w w', acc.hasEdge w w' → m.r (f w) (f w')) ∧ …`. An extra edge is a **new obligation against
  a model nobody constructed**.

The code names the mechanism itself at `FrameSoundness.lean:1183-1190`: the witness model is
"existentially arbitrary; nothing constrains `m.r` to equal the transitive closure of `acc`."
The residual sorry at `FrameSoundness.lean:1276` is this obstruction, and it is machine-witnessed
by a 197-line regression file (`CslibTests/S4LoopGuardRegression.lean`) exhibiting a formula with
a 3-world reflexive-transitive countermodel that the driver nonetheless closes.

**What the literature does instead** (two independent sources, same conclusion): Massacci's
single-step tableaux never add an edge for a blocked step — Pruning Lemma 8.2 *deletes* the
descendant-closed subtree, and Definition 10.2's interpretation `ı()` is explicitly **not
required injective**, so a blocked world is *identified* with its shorter modal copy.
Chagrov & Zakharyaschev's selective filtration builds `S_{n+1} ⊆ R_ambient` and evaluates truth
in the ambient model, making the box-propagation condition immediate by construction.

**Direct bearing on task 165.** WP4 wants to replace the bespoke `branchTruth`
(`FormalSystem/Metalogic/Decidability/CountermodelExtraction.lean:263`) with a real countermodel
over an actual linear order. The moment that happens, WP2's refutation meta-theorem and any
soundness statement will be quantifying over *arbitrary* models of the frame class, and every
blocking decision recorded as a relation edge becomes an unpayable obligation. **Decide now
whether blocking is an identification (quotient / non-injective `f`) or a deletion — before the
semantic bridge is built, not after.**

Secondary finding from the same report: **box-plus (`□⁺φ = φ ∧ □φ`) at the birth-key level** is
the standard repair for the persistence half of the problem, licensed for S4 by name (C&Z
Corollary 5.32), and provably free in the world bound because `modalSubfmls (.box a) =
.box a :: modalSubfmls a` keeps the enlarged key inside the existing codomain. Notably,
**BimodalLogic already has box-plus at the rule level**: `boxDiamondPersistence`, cited by cslib's
own reuse check as prior art (`Bimodal/Metalogic/Decidability/Tableau.lean:344` in cslib's stale
port, corresponding to BimodalLogic's `Tableau.lean`). What is missing is box-plus at the
*key/equivalence-class* level.

### 3.4 Termination: counting over a fixed finite universe, not complexity (WP3)

`Modal/Tableau/FmpMeasure.lean` is the sorry-free termination engine, and its design note
(`:44-50`) states the crux:

> The measure `R` is a *counting* measure over a fixed finite universe, not a complexity measure:
> the persistent modal rules re-fire without shrinking branch complexity, so a `3^complexity`
> exponent is non-decreasing on those rules. Counting against a fixed finite `U(φ)` restores
> strict decrease on every rule kind.

The pieces: `modalWorldBound` (`:146`), `modalUniverse` (`:151`, both signs × all subformulas ×
all world labels `0..W`), `modalWork U b e := |U\b| + |U\e|` (`:195`), `modalExpMeasure :=
Σ 3^(modalWork U bᵢ eᵢ)` (`:200`), and the bridge `modalExpMeasure_entry_le_fuel` (`:212`)
connecting the measure to the closed-form `modalFuel` (`Saturation.lean:98`).

**This is exactly the shape WP3 needs**, and BimodalLogic's persistent rules (box propagation,
`boxDiamondPersistence`) have precisely the non-decreasing-complexity property the note
describes. The `expanded`-set component of `modalWork` is what makes persistent rules count.

**The frame-class caveat is critical, and it is Massacci's, not cslib's**
(`specs/archive/514_.../reports/01:1-30`): the depth-based `1+d` rank-potential argument is
reserved for the **non-transitive** logics `K, D, T, KB, KDB, B` (Massacci2000, Table IV).
For **transitive/euclidean** logics — `K4, S4, K45, KD45, S5` — it provably fails, and cslib
mechanized the failure: `modalApplyOneS5_rankStep_not_dischargeable`
(`S5Simplification.lean:342`, sorry- and axiom-free) proves `RuleApplicationSpec.rankStep` is
*mathematically false* for the universal S5 rule. The replacement is loop-checking with a
pigeonhole world bound `modalWorldBoundS4 φ₀ := 2^(2·|modalSubfmls φ₀|)`
(`LoopChecking.lean:341`).

**TM's modal dimension is S5.** BimodalLogic therefore inherits this: any WP3 termination
argument for the modal dimension must be pigeonhole/loop-checking based, not depth-based.
WP3's stated "pigeonhole on ~2^(2n) time types" is the *right shape* — cslib's contribution is
confirming it is the *only* shape, and supplying the `S4LoopInv` (`LoopChecking.lean:7229`) field
structure that makes it work.

---

## 4. Anti-Lessons (things that failed)

### 4.1 The seriality gap: a tableau can be sorry-free, build-green, and simply wrong

`specs/425_.../reports/04_island-vs-periodic-strategic-decision.md:17-48` opens with a verdict
that reframed the whole task:

> `openBranch_branchSat` is **FALSE as currently stated — not merely unproven.**

Verified by execution against unmodified source:

```
temporalTableau (𝐅⊤)      = OPEN      temporalTableau (𝐆p → 𝐅p) = OPEN
temporalTableau (¬𝐆⊥)     = OPEN      temporalTableau (𝐏⊤)      = OPEN
temporalTableau (p → p)   = CLOSED    (control)
```

All four `OPEN` formulas are `validDiscrete`. Root cause (`:134-156`): the `𝐆` rule maps over
`ord.futureOf t`; with `ord = empty` that list is empty, `newForms` is empty, and the rule returns
`.notApplicable`. **Only the four positive existential rules ever call `addFuture`/`addPast`**, so
a root branch of negative existentials and positive universals is frozen with zero time points.

A second, independent defect: a hard-coded `ord.timeCount > 0 && ord.timeCount < 4` gate in the
`untlNeg`/`snceNeg` arms capped time creation at 4 points. Probe on `φ_k := 𝐅q → 𝐅^k⊤` (valid for
every `k`): `k ≤ 3` CLOSED, `k ≥ 4` OPEN. A bare magic number with no stated justification.
cslib task 552 later added the discriminating measurement (`archive/552_.../reports/01`): at fuel
`20000` vs the shipped `~50-500`, `k ≥ 4` is **still** OPEN — proving it is a rule defect, not
fuel exhaustion.

A *third* defect found by 552: `temporalApplyNeg` had **no `asAllFuture?`/`asAllPast?` arm at all**,
despite the module docstring's rule table advertising `allFutureNeg`/`allPastNeg` "by duality."
Six further linear-order validities returned OPEN.

**Bearing on task 165 / WP1.** BimodalLogic's calculus is 28 rules to cslib's ~14, so the specific
gaps may differ — but the *class* of defect is identical and the detection method is the same
(§6). WP1's suspicion of "possibly missing linearity/trichotomy branching rules" is the right
instinct; cslib's evidence says to check **seriality first**, and to check the *negative* rule
arms for silently-missing duals against the module docstring's own rule table.

The `timeCount < 4` cap has since been removed in favour of the `isTemporallyBlocked` dedup gate;
`TimeOrdering.lean:109-116` retains a "Historical note" recording that `timeCount` "is no longer
consulted by any rule-application site." That kind of in-code divergence record is worth copying
as a practice.

### 4.2 The island countermodel fails on `𝐆`/`𝐇`, not on eventualities (WP4)

The delegation hypothesis at the time was that a finite-branch ("island") model fails because
some eventuality goes unfulfilled. **That is backwards**
(`specs/425_.../reports/04:183-206`):

- For a genuinely saturated branch with an empty eventuality tracker, all *eventualities are
  fulfilled inside the branch by construction*.
- What fails is the dual. `Satisfies (extractModelℤ b ord) 0 (𝐆p)` unfolds to
  `∀ z : ℤ, 0 < z → valuation z p`. The island valuation reads `false` at every instant no branch
  label maps to. The branch is finite; `ℤ` is `NoMaxOrder`; therefore **every** finite branch
  carrying a positive `𝐆` (or `𝐇`) falsifies it.
- Negative eventualities are the ones the island accidentally gets *right*: an all-`false` tail
  vacuously satisfies `F(𝐅p)@t`.

> The island model is systematically biased toward `false`, which is exactly wrong for `𝐆`/`𝐇`.

**Consequence**: a *total* extension of branch content to all of the time domain is mandatory.
Ultimately-periodic (lasso) folding is the standard such extension (Hodkinson & Reynolds,
*Temporal Logic*, Handbook of Modal Logic ch. 11 §5.8). cslib landed both halves —
`extractModelℤPeriodic` (`Temporal/Tableau/Completeness.lean:278`) and
`extractModelℤPeriodicPast` (`:344`) — but they are **two independent models, not a composed
bi-lasso**; the composed bidirectional model is unrecorded work.

A further unrecorded obligation the same report surfaces (`:58`): the lasso requires the loop
window to be **fully populated** so folding lands on real content; `periodicReduce` is the
identity for `z ≤ instNew`, so unpopulated instants inside the window still read `false`.

**Bearing on WP4.** BimodalLogic's `branchTruth`
(`CountermodelExtraction.lean:263-278`) evaluates `.box φ` as `∀ w' ∈ cm.worlds, …` and until/since
over branch time indices — i.e. it is an island semantics with the branch's own finite carrier
substituted for the real domain. Replacing it with a genuine model over ℤ/ℚ/ℝ per frame class will
surface exactly this `𝐆`/`𝐇` failure. Budget for the totalizing construction, not just the domain
swap.

### 4.3 The fuel constant was arithmetically wrong, and stayed wrong for three research rounds

`specs/425_.../reports/04:272-325`. `temporalFuel φ := (4n+4)(n+2)+2 = 4n² + 12n + 10`
(`Temporal/Tableau/Saturation.lean:76-78`), justified by a docstring immediately above it reading
"the number of distinct time types is bounded by `2^n`."

> A quadratic constant cannot cover a `2^n` bound. This is a non sequitur visible on the face of
> the definition — no formalisation was needed to see it, which is why it survived three prior
> research rounds.

Measured on a propositional-tautology family: minimal sufficient fuel fits `1.5·2^k − 2` exactly
on `k ∈ [2,5]`, while `temporalFuel` fits `Θ(k²)`. The curves cross near `k = 12`, beyond which
the tableau reports OPEN on a propositional tautology **purely from fuel exhaustion**.

Available fixes, with opposite costs: (a) raise fuel to `2^Θ(n)` — one-line, keeps decidability,
makes `#eval` impractical, and does not bound the number of *branches*; or (b) add `timeType`
deduplication so the exponential state space is actually collapsed — the mathematically correct
FMP move, but rule/saturation surgery with a soundness re-audit.

**Two scheduling constraints that generalize.** First: *fixing the calculus makes the fuel problem
strictly worse*, because removing an ad-hoc cap removes the only thing currently bounding time
creation — so calculus repair and the fuel decision must be planned **jointly**, not sequentially.
Second: cslib task 317 independently reached the identical diagnosis on the propositional
tableau ("the real defect was a *missing rule*, not a measure").

**Bearing on WP3.** BimodalLogic's fuel is worse-positioned than cslib's: it is a *caller-supplied
default* (`tableauFuel : Nat := 1000` at `DecisionProcedure.lean:128`, `fuel : Nat := 1000` at
`CountermodelExtraction.lean:1095`), not even a formula-indexed function. WP3's "justified uncapped
fuel" is the right target; the lesson is that the justification must be an *exponential* closed
form tied to the pigeonhole bound, and that it should be derived *after* the rule set is settled.

### 4.4 The blocked-witness existence gap: saturation and fuel-exhaustion need different arguments

`Temporal/Tableau/Completeness.lean:63-116` ("Blocked Obligations") is the most directly
transferable postmortem in the survey. The intended design — derive a loop witness `(t_anc, t_new)`
generically from an `isSubsetBlocked` witness produced by any open-branch result — **does not hold
generically**, for two compounding reasons:

1. **Genuinely-saturated open branches never need the loop.** `isTemporalClosed` is re-checked at
   *every* worklist step, not only at the end. If a branch ever satisfies
   `isSubsetBlocked b t t_anc` for a known ancestor with a genuinely pending eventuality, it
   closes *immediately* — it can never survive to be returned open with that witness intact.
   Conversely, genuine saturation requires the tracker to be empty. So the plain island model
   already suffices for this population.
2. **Fuel-exhausted open branches may carry no loop witness at all.** The `fuel = 0` path returns
   the first branch that is not closed, regardless of whether work remains. Such a branch can be
   mid-expansion, cut off before any repeat had a chance to form. Deriving a witness here requires
   an **independent fuel-sufficiency / pigeonhole theorem** — and, in the file's own words, that
   theorem "is not yet formalized anywhere in the codebase; it is the actual mathematical content
   of the tableau's termination argument."

**Bearing on WP1/WP3.** BimodalLogic's `isSubsetBlocked` / `isTemporallyBlocked` /
`findBlockedTime` (`SignedFormula.lean:632`, `:759`, `:771`) is the *same* device — cslib's
temporal version is a direct port of it, with `Label{world,time}` collapsed to `Nat`
(`Temporal/Tableau/Branch.lean:20-23`). WP1's "blocked-branch unwinding" and WP3's pigeonhole are
therefore **the same obligation viewed from two ends**, and the trap is assuming that "open"
uniformly means "saturated". Two populations, two arguments.

### 4.5 The eventuality tracker's `.branching` arm silently under-reported

`temporalStepBranch`'s `.branching` case returned `tracker` **unchanged**, while the `.linear` and
`.persistent` arms ran `registerEventualities |> fulfillEventualities`. Since `untlPos`/`sncePos`
*are* branching rules, the recurring copy `T(U(g,e))@t'` was never registered as pending, so
`tracker.hasPending` under-reported and eventuality-defect closure effectively never fired
(`specs/425_.../reports/04:335-381`; consequence recorded at
`Temporal/Tableau/Completeness.lean:107-117`).

The fix was **not a one-liner**: `temporalStepBranch` returns *one* tracker for *all* output
branches, but `untlPos`'s two branches have genuinely different pending sets (branch1 fulfils,
branch2 defers). It required changing the return type to a per-output-branch tracker list, with
each branch running its own register/fulfil pass. Now landed
(`Temporal/Tableau/Saturation.lean`, `temporalStepBranch_preserves_faithful`,
`WorklistInvFaithful`).

**Bearing on task 165**: BimodalLogic has the same `EventualityTracker`-style machinery feeding
`isTemporallyBlocked` (`SignedFormula.lean:763`, `allEventualitiesFulfilledOrDuplicated`). Check
whether its branching arms thread trackers per-branch. If not, the blocking gate is unsound in the
"reports fewer pending than reality" direction — which makes blocking fire too eagerly.

### 4.6 Vacuous per-frame-class wrappers

`Bimodal/Metalogic/Decidability/FMP/DenseFMP.lean` and `DiscreteFMP.lean` (73 and 72 lines) exist
in cslib but not in BimodalLogic. They are **not** worth porting: `dense_mcs_finite_model_property`
is `:= mcs_finite_model_property phi h_not_provable` — a re-export of the base result, stated over
`FrameClass.Base` derivations, with a docstring conceding "the density condition on the temporal
order does not affect the MCS-based construction."

This is the anti-pattern for task 165's architecture goal: a per-frame-class file that delegates
wholesale is worse than no file, because it *looks* like frame-class coverage in a module listing.
Frame-class composability should be carried by a **parameter** (cslib's `FrameCondition` predicate
in `branchSatisfiableIn FC`, `FrameSoundness.lean:110`), not by per-class file duplication.

---

## 5. Reusability Matrix

Legend — **Port**: copy with mechanical adaptation. **Imitate**: re-derive the pattern; the code
is not type-compatible. **Avoid**: documented failure; do not repeat. **Heed**: a constraint that
should shape the plan.

| cslib asset | Location | WP | Verdict | Note |
|---|---|---|---|---|
| Foundations tableau kernel (`Sign`/`SignedFormula F L`/`RuleResult`/`Branch`/`ClosureCondition`) | `Cslib/Foundations/Logic/Tableau/` (914 ln) | Arch | **Port** | Instantiate `L := Label{world,time}`; BimodalLogic has no such layer |
| `Measure.lean` (`geomCap`, base-3 decrease lemmas) | `Foundations/Logic/Tableau/Measure.lean` | WP3 | **Port** | Zero logic dependencies; pure `Nat`/`List` |
| `ClosureCondition` typeclass returning `Option ClosureReason` | `.../ClosureCondition.lean:47-56` | Arch, WP2 | **Port** | One instance per frame class; witness survives for proof extraction |
| `TimeOrdering.instant : Nat → ℤ` + `InstantStrict` | `Temporal/Tableau/TimeOrdering.lean:59-93,225-279` | **WP1, WP4** | **Port** | Discrete/Base only; see §7.2 for Dense/Dedekind |
| Rejection of `ordConstraints_strict` (Nat-label = semantic order) | `specs/archive/426_.../reports/01:60-68` | WP1 | **Avoid** | Provably false once `addPast` exists |
| `RuleApplicationSpec` / `SpecCore` two-tier bundle | `Modal/Tableau/GenericDriver.lean:179,286` | **Arch, WP2, WP3** | **Imitate** | Hard-typed to `Proposition Atom`/`WorldIndex`; the *split* is the asset |
| `branchSatisfiableIn FC` / `frameValid FC` frame-parameterized soundness | `Modal/Tableau/FrameSoundness.lean:110` | Arch, WP2 | **Imitate** | One induction, N frame classes — the composability mechanism |
| `RuleApplySt` state-threading rule shape | `specs/557_.../reports/01:493-534` | Arch | **Imitate** | Design in from day one if rules thread ordering/tracker/keys |
| Counting measure over fixed finite universe (`modalUniverse`/`modalWork`/`modalExpMeasure`) | `Modal/Tableau/FmpMeasure.lean:146-212` | **WP3** | **Imitate** | The only measure that decreases on persistent rules |
| `S4LoopInv` birth-key pigeonhole, bound `2^(2·|Sf|)` | `Modal/Tableau/LoopChecking.lean:341,7229` | **WP3** | **Imitate** | TM's S5 dimension forces this; depth-based rank is false |
| `modalApplyOneS5_rankStep_not_dischargeable` (mechanized negative result) | `Modal/Tableau/S5Simplification.lean:342` | WP3 | **Heed** | Don't attempt a depth-based measure for the S5 dimension |
| Blocking recorded as `acc.addEdge` | `Modal/Tableau/LoopChecking.lean:747-759` | **WP1, WP2, WP4** | **Avoid** | Creates an obligation against an arbitrary model; use identification/deletion |
| `blockingWorld` + `worldSetsDistinct` (live-set distinctness) | superseded, `LoopChecking.lean:36-41` | WP1, WP3 | **Avoid** | Live relevant sets grow monotonically ⇒ not a loop invariant |
| Box-plus `□⁺` at the **birth-key** level | `specs/557_.../reports/01:262-325` | WP1, WP3 | **Imitate** | Free in the world bound; BimodalLogic already has it at the *rule* level |
| Missing seriality rule for `𝐆`/`𝐇` | `Temporal/Tableau/Rules.lean:227-244` (now repaired) | **WP1** | **Heed** | Repaired arm at `Rules.lean:~262-272` is the reference shape |
| Hard-coded `timeCount < 4` cap | removed; historical note `TimeOrdering.lean:109-116` | WP1, WP3 | **Avoid** | Magic numeric caps mask rule defects and survive fuel raises |
| Missing negative-dual rule arms vs the docstring rule table | `archive/552_.../reports/01` | **WP1** | **Heed** | Audit BimodalLogic's 28 rules against its own rule table |
| Island (`extractModelℤ`) as the final countermodel | `Temporal/Tableau/Completeness.lean:209-216` | **WP4** | **Avoid** | Biased to `false`; breaks positive `𝐆`/`𝐇` |
| `extractModelℤPeriodic` / `…Past` lasso halves | `.../Completeness.lean:278,344` | WP4 | **Imitate** | Two *independent* models; composed bi-lasso is unwritten |
| Two-population blocked-witness analysis (saturated vs fuel-exhausted) | `.../Completeness.lean:63-116` | **WP1, WP3** | **Heed** | Two obligations, two arguments; do not conflate |
| Per-branch eventuality tracker threading | `.../Saturation.lean` (`temporalStepBranch`) | WP1 | **Port** | Check BimodalLogic's branching arms for the same defect |
| Quadratic `temporalFuel` vs `2^n` step count | `.../Saturation.lean:76-78` | **WP3** | **Avoid** | Measure before believing a fuel bound |
| Per-frame-class FMP wrappers that delegate wholesale | `Bimodal/.../FMP/DenseFMP.lean` | Arch | **Avoid** | Use a frame-condition *parameter*, not duplicated files |
| `CslibTests/TableauConformance.lean` executable corpus | 332 ln | **All** | **Port (method)** | See §6 — catches what the type checker cannot |
| cslib's `Bimodal/Metalogic/Decidability/` tree | 7,439 ln | — | **Ignore** | Stale downstream port of BimodalLogic's own code |

---

## 6. The Conformance Harness (method worth adopting immediately)

`CslibTests/TableauConformance.lean:20-27` states the case better than a paraphrase:

> a tableau calculus can be sorry-free and `lake build`-green while still deciding the wrong
> verdict on a textbook-valid formula, because rule-set incompleteness is invisible to the type
> checker.

Every defect in §4.1 was found this way and by no other means. Three mechanical constraints,
empirically settled by cslib (`:29-49`) and worth inheriting rather than rediscovering:

- `decide` / `native_decide` / `rfl` **stall on `WellFounded.fix`** — fuel-based expansion loops
  compile through nested `let rec`s that do not reduce in the kernel. `#eval` *does* reduce (it
  uses the compiler), but only from a test library, not from inside the source tree.
- Result types deriving neither `Repr` nor `BEq` need a `String`-valued verdict adapter, asserted
  via `#guard_msgs in #eval`.
- In cslib, the module system forces **both** `import X` and `public meta import X` for the same
  module. **BimodalLogic does not use the module system, so this constraint does not apply** —
  one fewer obstacle.

Since BimodalLogic already has a `Tests/BimodalTest/` suite and no module-system complication,
a TM conformance corpus is cheaper to build there than it was in cslib. Recommended as the
**first** WP1 phase: it converts "possibly missing linearity rules" from a hypothesis into a
list of specific failing rows before any proof work is planned.

The harness must also pin down which validity notion is being decided. cslib's header (`:51-58`)
records that `temporalTableau` decides `validDiscrete`, **not** `Temporal.valid`, because
`Temporal.valid` quantifies over an arbitrary `[LinearOrder D] [Nontrivial D]` which need not be
serial — `𝐆p → 𝐅p` is false on a two-point linear order. **BimodalLogic's four frame classes make
this strictly harder: each needs its own conformance corpus with its own expected verdicts, and a
row valid for Dedekind may be invalid for Base.**

---

## 7. Adversarial Self-Verification (H4)

I attempted to break the "reusable" claims by checking each against BimodalLogic's actual setting
(S5 modality × linear time with Until *and* Since, four frame classes Base/Dense/Discrete/Dedekind)
rather than plain modal K/S5 or PTL-without-Since.

### 7.1 Claim Verification Table

| Claim | Verification method | Counterexample sought / result | Confidence |
|---|---|---|---|
| cslib's `Bimodal/.../Decidability/` is a stale port, not a source | `wc -l` both trees; cslib file docstrings cite BimodalLogic as origin (`AxiomMatcher.lean` "Ported from BimodalLogic/Automation/ProofSearch/Core.lean"; `DenseFMP.lean` "Ported from BimodalLogic/Theories/...") | cslib has 3 files BimodalLogic lacks; all 3 inspected, none substantive (§4.6) | **High** |
| Foundations kernel is formula- and label-generic | Read all 6 core files in full; signatures are `SignedFormula F L`, `Branch F L`, `RuleResult F L`, `class ClosureCondition F L` | Sought a hidden concrete dependency; found none. `Measure.lean` imports only `Cslib.Init` + `Mathlib.Tactic.Ring` | **High** |
| `RuleApplicationSpec` is *not* directly instantiable for bimodal | Read `GenericDriver.lean:179-278` + `Saturation.lean:108`; `RuleApply Atom` is hard-typed to `SignedFormula (Proposition Atom) WorldIndex → … → Accessibility` | Confirmed: no formula-type or label-type parameter. **Downgraded from "Port" to "Imitate."** | **High** |
| The `instant : Nat → ℤ` scheme transfers to BimodalLogic | Read `TimeOrdering.lean:59-279` + `archive/426` report in full; confirmed BimodalLogic's `TimeOrdering` (`SignedFormula.lean:654-657`) has `constraints` only, and grep for `instant`/`InstantStrict` in `FormalSystem/Metalogic/Decidability/` returns no hits | **Partial counterexample found** — see §7.2. Claim narrowed. | **Medium-High** |
| TM's S5 dimension forbids a depth-based termination measure | `S5Simplification.lean:342` is a *mechanized* negative result (sorry/axiom-free); Massacci Table IV classification quoted in `archive/514_.../reports/01` | Sought an escape via TM's S5 being the *universal* relation rather than K45-style: cslib's S5 rule *is* the universal-propagation rule and it is precisely the one that fails `rankStep` | **High** |
| Blocking-as-edge is fatal once soundness quantifies over arbitrary models | Two independent confirmations: `FrameSoundness.lean:1183-1190` (in-code), and a machine-checked regression `CslibTests/S4LoopGuardRegression.lean` | Sought applicability to BimodalLogic: currently BimodalLogic's `branchTruth` *constructs* its model, so the defect is **latent, not active** — it activates exactly when WP4 lands. Claim restated as conditional. | **High** |
| Island model breaks on positive `𝐆`/`𝐇` | `specs/425_.../reports/04:183-206`, derivation reproduced and checked by hand against `Satisfies.lean:76` | Checked whether TM's `𝐆`/`𝐇`-analogues are primitive in BimodalLogic (they are, per `Defs.lean:268-302` in cslib's temporal port, and BimodalLogic's `branchTruth` has `.box`/until/since arms) — argument transfers | **High** |
| `temporalFuel` is arithmetically insufficient | Report gives a measured table (`k` vs minimal sufficient fuel) plus the definition; the `Θ(k²)` vs `1.5·2^k` gap is checkable from the definition alone | Did **not** re-execute the measurement myself (would require building cslib). Relying on the report's stated methodology. | **Medium** |
| BimodalLogic's `validity_decidable` is a placeholder | Read `Correctness.lean:78-92` directly: `exact Classical.em (⊨ φ)` | None sought; the proof term is conclusive | **High** |
| Toolchain compatible, module-system incompatible | `cat lean-toolchain` both (identical); `grep -rl '^module$'` → cslib 684, BimodalLogic 0 of 462; `lake-manifest.json` mathlib revs differ | Mathlib rev divergence (`169c26b5` vs `79d0395a`) is **unquantified** — I did not diff the two Mathlib trees | **Medium-High** |

### 7.2 Contradiction Log

**Resolved — the `instant` scheme vs BimodalLogic's four frame classes.** My initial framing
("port `instant : Nat → ℤ` to solve WP1") over-claims. cslib's temporal tableau targets
`validDiscrete` — a *discrete, serial* linear order (`Temporal/Tableau/Soundness.lean:95-106`,
`CslibTests/TableauConformance.lean:51-58`). The `±1` stamp bakes discreteness in: two labels
created as successors of the same point collide on one instant, and there is no room to insert a
point strictly between `instant t` and `instant t + 1`. That is fine for Discrete, adequate for
Base (ℤ is a linear order and Base imposes no density/discreteness), and **insufficient as stated
for Dense (ℚ) and Dedekind (ℝ)**.

Resolution by precedence (implementation evidence over narrative): the *strategy* — "carry a
locally-maintained stamp into a known linear order, so the invariant is edge-local and no global
acyclicity proof is needed" — survives unchanged. Only the *stamp arithmetic* is frame-class
specific: `±1` into ℤ for Discrete/Base, midpoint/mediant interpolation into ℚ for Dense, and ℝ
(or ℚ plus a completion step) for Dedekind. This is in fact **more** favourable to task 165's
architecture goal than the flat port would be: the stamp codomain and its two `add*` operations
are precisely the frame-class-varying parameter, with `InstantStrict` and every downstream
order-preservation consumer shared. BimodalLogic's recent Chronicle work
(`ChronicleRealExtension.lean`, "rational interpolation" in the commit log) already contains the
Dense-case arithmetic.

**Resolved — is the blocking-as-edge lesson applicable at all?** BimodalLogic's countermodel is
currently *constructed* (`branchTruth` over a `SemanticCountermodel` with an explicit finite
`cm.worlds`), which is the polarity for which an extra edge is harmless. So the defect is not
present today. It becomes present the moment WP4 replaces `branchTruth` with satisfaction in an
arbitrary model of the frame class — which is WP4's entire point, and is also what WP2's
`Derivable fc [] phi` conclusion implicitly quantifies over. Stated as a conditional throughout
§3.3 and in the matrix.

**Unresolved.** *Whether cslib's specific missing rules correspond to gaps in BimodalLogic's
28-rule calculus.* BimodalLogic's calculus is roughly twice the size and was the *upstream* of
cslib's temporal one, so it may well already contain seriality and the negative duals. I did not
enumerate BimodalLogic's 28 rules — that is the sibling dispatch's territory, and doing it here
would duplicate. **Downstream risk**: if §4.1's defects do not apply, WP1's phase 1 shrinks
substantially. **The resolving check not yet performed**: run a conformance corpus (§6) on
BimodalLogic's `decide` over the five formulas cslib found (`𝐅⊤`, `¬𝐆⊥`, `𝐆p → 𝐅p`, `𝐏⊤`,
`𝐅q → 𝐅^k⊤` for `k = 0..6`), per frame class. This is cheap and settles it definitively.

### 7.3 Recommendations modified after verification

- `RuleApplicationSpec`: **Port → Imitate** (not formula-generic).
- `instant : Nat → ℤ`: **unconditional Port → Port for Discrete/Base, with a frame-class-varying
  stamp codomain for Dense/Dedekind** (§7.2).
- Blocking-as-edge: **active defect → latent defect, activated by WP4** (§7.2).
- Added the conformance harness (§6) as a *first* recommendation rather than a supporting note,
  since it is the only mechanism that found any of §4.1 and it is cheaper in BimodalLogic than it
  was in cslib.

---

## 8. Version Compatibility

| Dimension | BimodalLogic | cslib | Assessment |
|---|---|---|---|
| Lean toolchain | `leanprover/lean4:v4.33.0-rc1` | `leanprover/lean4:v4.33.0-rc1` | **Identical** |
| Mathlib | rev `79d0395a…`, inputRev tag `v4.33.0-rc1` | rev `169c26b52a38…` (bare commit, `lakefile.toml`) | Different commits, same Lean release line. Low but nonzero API-drift risk; unquantified. |
| Build config | `lakefile.lean` | `lakefile.toml` | Cosmetic |
| Module system | **0 of 462 files** use `module` | **684 files** use `module` | **Main friction.** Copied files need `module`, `public import`, `@[expose] public section` stripped, and re-checked for accidental private/public visibility assumptions |
| Namespace root | `FormalSystem.*` | `Cslib.Logic.*` | Mechanical rename |
| Formula type | `Formula` (monomorphic in `Tests`/`Decidability` — `decide (φ : Formula)`) | `Formula Atom` / `Proposition Atom`, universe-polymorphic | cslib's port notes record adaptations "for universe-polymorphic `Formula Atom`" (`AxiomMatcher.lean` docstring). Porting *back* means re-monomorphizing or generalizing BimodalLogic |
| Test idiom | `Tests/BimodalTest/` | `CslibTests/` with `#guard_msgs in #eval` | Compatible; §6 constraints are simpler for BimodalLogic |

Practical consequence: **port the Foundations kernel by re-typing, not by copying.** It is 914
lines of straightforward definitions; a clean re-derivation in BimodalLogic's idiom will be faster
than de-modularizing and will avoid importing cslib's `Cslib.Init` dependency chain.

---

## 9. Recommendations

Ordered by "cheapest thing that most changes the plan" first.

1. **Build a TM conformance corpus before planning WP1** (§6). Run BimodalLogic's `decide` per
   frame class over: `𝐅⊤`, `¬𝐆⊥`, `𝐆p → 𝐅p`, `𝐇p → 𝐏p`, `𝐏⊤`, and `𝐅q → 𝐅^k⊤` for `k = 0..6`,
   plus a handful of `Until`/`Since` linearity rows. This converts WP1's open questions into a
   list of failing rows in hours, and it is the *only* mechanism that surfaced any of §4.1.
   Include an explicit statement of which validity notion each frame class's corpus targets.

2. **Audit BimodalLogic's 28 rules against its own module rule table**, specifically the
   *negative* arms. cslib shipped a docstring advertising `allFutureNeg`/`allPastNeg` "by duality"
   with **no such arm in the code** for months (§4.1). This is a 30-minute read.

3. **Plan the fuel decision jointly with any calculus repair, never after** (§4.3). Also: replace
   the caller-supplied `fuel : Nat := 1000` defaults (`DecisionProcedure.lean:128`,
   `CountermodelExtraction.lean:1095`) with a formula-indexed function *before* attempting any
   sufficiency proof, so the object of the proof exists.

4. **Decide the blocking semantics before WP4 starts** (§3.3): is a blocked step an
   *identification* (non-injective `f`, quotient), a *deletion* (subtree pruning), or an *edge*?
   cslib's four-route failure and residual sorry are the cost of answering this late. The
   literature answer is identification or deletion, never an edge.

5. **Extract a `Foundations`-level tableau layer** (§2), re-typed rather than copied, with
   `L := Label{world,time}` and one `ClosureCondition` instance per frame class. This is the
   substrate for the architecture goal, and cslib's version is small enough to review in full.

6. **Adopt the frame-condition *parameter* pattern, not per-frame-class files** (§3.1, §4.6):
   `branchSatisfiableIn FC` / `frameValid FC` give one soundness induction across six systems in
   cslib. Avoid the `DenseFMP.lean` shape.

7. **For WP3, use a counting measure over a fixed finite universe with an `expanded`-set
   component** (§3.4) — a complexity measure cannot decrease on TM's persistent rules — and expect
   the modal (S5) dimension to require loop-checking with a `2^(2·|Sf|)`-style pigeonhole rather
   than a depth bound (§3.4, mechanized negative result at `S5Simplification.lean:342`).

8. **For WP4, budget for a totalizing construction, not just a domain swap** (§4.2). The island
   model's `false`-bias breaks positive `𝐆`/`𝐇` on any `NoMaxOrder` domain. Note that cslib's two
   lasso halves are *not* a composed bi-lasso, and the loop window must be fully populated.

9. **Separate the two open-branch populations in WP1/WP3** (§4.4): genuinely-saturated branches
   (empty tracker, island suffices for eventualities) and fuel-exhausted branches (may carry no
   loop witness; needs the pigeonhole theorem). Two obligations, two arguments.

10. **Design any state the rules need (`TimeOrdering`, tracker, blocking keys) into the rule
    function's signature from the start** (§3.1, `RuleApplySt`). cslib measured the retrofit cost
    at 386 lines for one invariant field.

---

## Appendix — Reproduction Commands

```
# cslib code-position sorry census (28 repo-wide)
cd /home/benjamin/Projects/cslib
{ grep -rnE '^[[:space:]]*sorry([[:space:]]*--.*)?$' --include='*.lean' Cslib/; \
  grep -rnE '(:=|\bby)[[:space:]]+sorry([[:space:]]*--.*)?$' --include='*.lean' Cslib/; } \
  | sort -u | wc -l

# module-system usage (cslib 684 / BimodalLogic 0 of 462)
grep -rl '^module$' /home/benjamin/Projects/cslib/Cslib/ | wc -l
grep -rl '^module$' /home/benjamin/Projects/BimodalLogic/FormalSystem/ | wc -l
find /home/benjamin/Projects/BimodalLogic/FormalSystem -name '*.lean' | wc -l

# subsystem sizes
find /home/benjamin/Projects/cslib/Cslib/Logics/Modal/Tableau -name '*.lean' | xargs wc -l | tail -1
find /home/benjamin/Projects/cslib/Cslib/Logics/Temporal/Tableau -name '*.lean' | xargs wc -l | tail -1
wc -l /home/benjamin/Projects/cslib/Cslib/Foundations/Logic/Tableau/*.lean

# toolchain / mathlib pins
cat /home/benjamin/Projects/cslib/lean-toolchain /home/benjamin/Projects/BimodalLogic/lean-toolchain
grep -A2 '"name": "mathlib"' /home/benjamin/Projects/BimodalLogic/lake-manifest.json
grep -A3 'name = "mathlib"' /home/benjamin/Projects/cslib/lakefile.toml
```

Per `Modal/Tableau/LoopChecking.lean:80-90`: quote the command with any figure, and re-run the
command rather than trusting the stored number.
