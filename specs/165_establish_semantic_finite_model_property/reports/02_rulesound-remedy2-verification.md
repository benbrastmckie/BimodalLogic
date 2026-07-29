# RuleSound Remedy 2 — Adversarial Verification Report

- **Dispatch**: adversarial verification / divergence audit (H4 + H5)
- **Session**: `sess_1785337808_19a89c_165v`
- **Mode**: READ-ONLY on all `.lean` files. No `lake build`, no elaboration, no edits.
- **Subject**: the remedy-2 well-formedness hypothesis proposed for `RuleSound`
  (`FormalSystem/Metalogic/Decidability/Verified/Decidable.lean:957`)
- **Scope of evidence**: `Tableau.lean`, `Verified/Decidable.lean`, `SignedFormula.lean`,
  `Verified/RuleSpec.lean`, `Verified/Bridge/BranchOrder.lean`, `Saturation.lean`. Every claim
  below carries a `file:line` citation. Nothing was verified by elaboration.

---

## VERDICT (up front)

**AUTHORIZE WITH CORRECTION.**

Remedy 2 as stated —

```lean
∀ p ∈ ord.constraints, p.1 < b.nextTime ∧ p.2 < b.nextTime
```

— is **not an inductive invariant of the tableau construction**. It is preserved by 35 of the 36
`TableauRule` constructors and refuted by the third arm of `timeLinearity`
(`Tableau.lean:1388`), the single non-additive step in the engine. A concrete counterexample is
given in §4.

The correction is to strengthen the bound to a **membership** condition, which is what the
codebase's own `BranchOrder.lean:52-65` already assumes informally:

```lean
∀ p ∈ ord.constraints, p.1 ∈ b.knownTimes ∧ p.2 ∈ b.knownTimes
```

Call this `OrdWithin b ord`. It is:

- **strictly stronger** than remedy 2 (§5.1), so everything remedy 2 buys for the six fresh-time
  producers it still buys — in particular `b.nextTime ∉ times(ord)`, which is the one fact the
  one-point-update proof actually consumes;
- **preserved by every arm of `applyRule`, including `timeLinearity` arm 3** (§3, §5.2);
- **discharged at the root** by `TimeOrdering.empty` exactly as remedy 2 is
  (`SignedFormula.lean:679`, `Saturation.lean:931`);
- **the same cost**: one appended `intro` name per proof site, same statement position.

Two further corrections to the remedy-2 pricing, neither fatal:

- The cost is **19 sites, not 18**. `RuleSound.mono` (`Decidable.lean:265-269`) is a consumer of
  `RuleSound` and needs both an extra `intro` and an extra argument in its `exact` term (§2.2).
- The hypothesis **must be the last hypothesis** in `RuleSound`'s statement, after
  `SatState M Om hist tv b ord`. Any earlier position silently misbinds `hst` in all 18 existing
  `intro` lines (§2.3).

---

## 1. What was checked, and against what

`RuleSound` (`Decidable.lean:253-259`) currently reads:

```lean
def RuleSound (C : CarrierProp) (r : TableauRule) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D],
    C D → ∀ (F : TaskFrame D) (M : TaskModel F) (Om : Set (WorldHistory F))
      (hist : WorldIndex → WorldHistory F) (tv : TimeIndex → D)
      (b : Branch) (sf : SignedFormula) (ord : TimeOrdering),
      sf ∈ b → SatState M Om hist tv b ord →
      SatResult M Om b (applyRule r sf b ord).1 (applyRule r sf b ord).2
```

The load-bearing question posed to this dispatch was claim (c) generalized: **can the assembly
induction re-supply the hypothesis at every successor step?** That is a question about
`applyRule`'s successor `(b', ord')` pairs, not about `RuleSound` in isolation, so the audit ran
rule-by-rule over `applyRule` and then over the engine's expansion tails.

### 1.1 The successor pairs, precisely

`SatResult` (`Decidable.lean:188-194`) fixes what the successor is in each case:

| `RuleResult` | successor branch | successor ordering |
|---|---|---|
| `.linear fs` | `fs ++ b` | the returned `ord` |
| `.persistent fs` | `fs ++ b` | the returned `ord` |
| `.branching bss` | `br ++ b` for some `br ∈ bss` | the returned `ord` |
| `.branchingOrdered brs` | `p.1` for some `p ∈ brs` | `p.2` — **a replacement, not a delta** |
| `.notApplicable` | — | `True` |

The engine agrees verbatim: `expandOnce` (`Tableau.lean:2055-2063`), `expandOnceUnblocked`
(`Tableau.lean:2102-2106`), `expandOnceNoFresh` (`Tableau.lean:2142-2145`) and the factored tail
`pick_extended` (`Tableau.lean:2350-2360`) all build `fs ++ b` and pass `.branchingOrdered`
through as `.splitOrdered branches` untouched.

**This is the crux.** Four of the five arms are *additive*: `b ⊆ b'`, hence
`b.maxTime ≤ b'.maxTime` (`Tableau.lean:2465`, `le_maxTime`), hence
`b.nextTime ≤ b'.nextTime` (`SignedFormula.lean:380-381`). Under additivity the remedy-2 bound is
monotone and survives for free. The fifth arm, `.branchingOrdered`, is documented as the one
place where the payload is "a list of replacement branches, not of deltas … because the
identification arm of `timeLinearity` has to *remove* a time from `Branch.knownTimes`"
(`Tableau.lean:217-222`). Removing a time can **lower** `nextTime`, and the remedy-2 bound has
`b.nextTime` on the *right* of a `<`, so lowering it breaks the bound.

---

## 2. Claim (a) MONO-SURVIVAL and claim (b) COST

### 2.1 Claim (a): survives `SatState.mono`

`SatState.mono` (`Decidable.lean:161-165`) weakens `b` to `b'` under `∀ sf ∈ b', sf ∈ b` and
does not mention `nextTime` at all. Remedy 2 adds a hypothesis to **`RuleSound`**, not a fifth
field to **`SatState`**, so `SatState.mono`'s statement and proof are *literally untouched*. The
polarity reasoning in the handoff is correct as far as it goes: the hypothesis is **consumed**
(to the left of the final `→`, discharged by the caller) rather than **produced** (in `mono`'s
conclusion, where remedy 1's fifth field would sit and where it demonstrably fails).

**CONFIRMED — but the conclusion drawn from it is too strong.** Remedy 2 does not *dissolve* the
anti-monotonicity that blocks remedy 1; it *relocates* it from `SatState.mono` to the assembly's
successor step. Wherever the construction shrinks the branch, someone must still re-establish a
`b`-positive predicate against a smaller `b`. `SatState.mono` is not that place; `timeLinearity`
arm 3 is. The handoff's blocker note calls the mono obstruction "the single most reusable fact
found this dispatch" (`.orchestrator-handoff.json`, `carry_forward` item (c)) — the reusable form
of that fact is *"any `b`-positive predicate is fragile at every branch-shrinking step"*, and
remedy 2 was priced as though the only such step were `mono`.

### 2.2 Claim (b): "costs the 18 already-landed rule proofs one intro each"

The 18 landed proofs all open with the identical line

```
intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst
```

at `Decidable.lean:311, 337, 370, 400, 425, 453, 476, 496, 568, 594, 624, 743, 776, 1063, 1087,
1113, 1139, 1222` — exactly 18 sites. Each needs one appended name.

**There is a 19th site the estimate omits.** `RuleSound.mono` (`Decidable.lean:265-269`) is
itself a consumer:

```lean
theorem RuleSound.mono … (h : RuleSound C r) : RuleSound C' r := by
  intro D _ _ _ _ hC F M Om hist tv b sf ord hmem hst
  exact h D (hle D hC) F M Om hist tv b sf ord hmem hst
```

It needs an extra `intro` name **and** an extra argument in the `exact` term. It is not a rule
proof, so "the 18 rule proofs" does not cover it, and it is the lemma the entire frame-class
family is reused through (`Decidable.lean:261-264`). Cost: **19 sites, one of which takes two
edits.**

Outside `Verified/`, the only other occurrences of `RuleSound` are in prose docstrings
(`Decidability.lean:106`, `Decidable.lean:66-90`) and in two test probes
(`Tests/BimodalTest/BoxNegPreservationProbe.lean:12,46,125`,
`BoxNegReachabilityProbe.lean:14`), which mention it in comments only. No further proof sites.

### 2.3 Position in the statement is load-bearing and was not specified

All 18 `intro` lines bind exactly 16 names positionally. If the new hypothesis is inserted
anywhere *before* `SatState M Om hist tv b ord` — e.g. between `sf ∈ b` and `SatState …`, the
reading a "well-formedness hypothesis on the (branch, ordering) pair" most naturally suggests —
then `hst` silently binds to the well-formedness proof, the `SatState` hypothesis is left
un-introduced in the goal, and all 18 proofs fail downstream with errors that do not point at
the cause. The hypothesis **must go last**:

```lean
      sf ∈ b → SatState M Om hist tv b ord →
      (∀ p ∈ ord.constraints, p.1 ∈ b.knownTimes ∧ p.2 ∈ b.knownTimes) →
      SatResult M Om b (applyRule r sf b ord).1 (applyRule r sf b ord).2
```

With that placement the "one appended `intro` name" pricing is accurate.

---

## 3. PRESERVATION, rule by rule (all 36 constructors)

`TableauRule` has **36** constructors (`Tableau.lean:73-191`, enumerated). `allRules` has **26**
entries (`Tableau.lean:1437-1456`), `denseRules` 2 (`:1461-1464`), `discreteRules` 3
(`:1469-1472`), `dedekindRules` 3 (`:1483-1485`), and `serialityRule` / `timeLinearity` sit
outside `allRulesForFC` by construction (`:1492-1504`, `RuleSpec.lean:310-343`).

Groups below are by *code path*, as permitted.

| # | Group | Rules | ord change | branch change | Remedy-2 bound preserved? |
|---|---|---|---|---|---|
| G1 | Truth-functional decomposers | `andPos andNeg orPos orNeg impPos impNeg negPos negNeg` | none | `fs ++ b`, existing labels | **CONFIRMED** |
| G2 | Label-preserving modal | `boxPos` (`:567`), `diamondNeg` (`:593`), `boxTemporal` (`:623`) | none | additive | **CONFIRMED** |
| G3 | Fresh-**world** producers | `boxNeg` (`:742`), `diamondPos` (`:775`) | none | additive, times unchanged | **CONFIRMED** |
| G4 | Temporal universals | `allFuturePos` (`Tableau.lean:677-683`), `allPastPos` (`:717-723`), `someFutureNeg` (`:789-797`), `somePastNeg` | none (`timeOrd` returned verbatim) | additive at existing ord times | **CONFIRMED** |
| G5 | `orderTrichotomy` | `orderTrichotomy` (`Tableau.lean` `.orderTrichotomy` arm, returns `(.branching …, timeOrd)`) | none | additive at `t0 ∈ pastOf l.time` | **CONFIRMED** |
| G6 | Fresh-**time** producers | `allFutureNeg` (`:686-714`), `allPastNeg` (`:726-754`), `someFuturePos` (`:757-785`), `somePastPos` (`:801-…`) | one `addFuture`/`addPast` with `freshTime = branch.nextTime` | `witness :: …` **unfiltered** at `freshTime` | **CONFIRMED** (§3.1) |
| G7 | `untlPos` / `sncePos` | `:847-886`, `:892-931` | one `addFuture`/`addPast` | both arms carry an unfiltered formula at `freshLabel` (`:854,856,899,901`) | **CONFIRMED** |
| G8 | `untlNeg` / `snceNeg` **passive** arms | `:998-1005`, past mirror | none (`timeOrd` returned) | additive at `t' ∈ futureOf l.time` | **CONFIRMED** |
| G9 | `untlNeg` / `snceNeg` **active** arms | `:950-994`, `:1024-…` | one `addFuture`/`addPast` | `branch1`/`branch2` both lead with an unfiltered formula at `freshLabel` (`:991-993`) | **CONFIRMED** |
| G10 | `denseIndicatorClosure` | `:1200-1203` | none | `.linear []` → `b' = b` | **CONFIRMED** |
| G11 | `densityRule` | `:1206-1253` | **two** constraints in one step (`:1241`) | `.persistent (witness :: gProps)`, witness unfiltered at `freshTime` (`:1243`) | **CONFIRMED** (§3.2) |
| G12 | Discrete | `priorUZ` (`:1256-1263`), `priorSZ` (`:1266-1273`), `z1Rule` (`:1276-…`) | none | `.persistent [newSf]` at `l` | **CONFIRMED** |
| G13 | Dedekind | `priorUGap`, `priorSGap`, `sepRule` (`:1340-1347`) | none | `.persistent [newSf]` at `l` | **CONFIRMED** |
| G14 | `serialityRule` | `:1354-1358` | none | `.persistent outs` at `l` | **CONFIRMED** |
| G15 | `timeLinearity` arms 1–2 | `:1386-1387` | `addFuture t₁ t₂` with `t₁,t₂ ∈ b.knownTimes` (`:420-427`) | branch passed through unchanged | **CONFIRMED** |
| G16 | `timeLinearity` arm 3 | `:1388` | `ord.identifyTime t₂ t₁` | **`branch.identifyTime t₂ t₁` — removes a time** | **REFUTED** (§4) |

### 3.1 Why G6 is safe — and it is safe for the reason the invariant is *about*

Counterexample-hunt target 4 was: *"a minted constraint uses a time equal to the current
`nextTime` while the successor's `nextTime` is not strictly larger."* This is a real hazard for
this family, because most of each rule's output list is `filterMap`-guarded against
`branch.contains` (`:693-711`, `:733-751`, `:766-782`) and can come back empty. If the *whole*
output were guarded, the successor branch would carry no formula at `freshTime`, `b'.nextTime`
would equal `b.nextTime = freshTime`, and the minted constraint `(l.time, freshTime)` would
violate `p.2 < b'.nextTime` immediately.

The hazard does not fire, because in every one of the six the witness is **consed on
unguarded**: `witness :: gProps ++ fNegProps ++ modalProps` (`:714`, `:754`, `:785`) and
`[SignedFormula.pos event freshLabel] ++ autoProp` (`:854`, `:899`), `[SignedFormula.neg event
freshLabel, sf] ++ autoProp` (`:991`). So `freshTime ∈ knownTimes(b')` always, giving
`b'.maxTime ≥ b.maxTime + 1` and `b'.nextTime ≥ b.maxTime + 2 > freshTime`. The old constraints
are bounded by `b.nextTime < b'.nextTime`, and `l.time ≤ b.maxTime` by `le_maxTime`
(`Tableau.lean:2465`) since `sf ∈ b`. Preserved.

**This is fragile-by-construction and worth recording**: the invariant survives G6 only because
of an unguarded cons in six separate rule bodies. A future edit that wraps the witness in the
same `branch.contains` guard the propagated formulas carry would break the invariant silently.

### 3.2 Why G11 (`densityRule`) is safe — the two-constraint case

`densityRule` is the only rule that mints two constraints in one step:

```lean
let newOrd := (timeOrd.addFuture l.time freshTime).addFuture freshTime t'   -- Tableau.lean:1241
```

Counterexample-hunt target 4's second half was: *"two constraints are minted and only one bound
is refreshed."* Checked and clear. The new pairs are `(freshTime, t')` and `(l.time, freshTime)`.
`freshTime = branch.nextTime` is in `knownTimes(b')` via the unfiltered `witness` at `:1243`.
`t'` comes from `gapTargets ⊆ futureTimes = timeOrd.futureOf l.time` (`:1231-1237`), and
`futureOf` is `reachableForward ord [t] [] fuel` with `visited` starting empty and only ever
extended by `directFutureOf` outputs (`SignedFormula.lean:741-748, 776-777`) — so **every element
of `futureOf t` is the second component of an existing constraint**. Under the hypothesis it is
therefore `< b.nextTime < b'.nextTime`. Both bounds are refreshed. Preserved.

Note this is the one place where the *hypothesis itself* is what makes preservation go through:
without a bound on `t'`, `densityRule` would be a second independent counterexample.

---

## 4. THE COUNTEREXAMPLE — `timeLinearity` arm 3

### 4.1 The code

```lean
| .timeLinearity, _, _ =>
    match firstIncomparablePair branch timeOrd with
    | none => (.notApplicable, timeOrd)
    | some (t₁, t₂) =>
        (.branchingOrdered
          [ (branch, timeOrd.addFuture t₁ t₂)
          , (branch, timeOrd.addFuture t₂ t₁)
          , (branch.identifyTime t₂ t₁, timeOrd.identifyTime t₂ t₁) ],
         timeOrd)                                        -- Tableau.lean:1381-1389
```

`firstIncomparablePair` (`Tableau.lean:420-427`) draws both times from `b.knownTimes`.
`Branch.identifyTime` (`SignedFormula.lean:364-367`) relabels everything at `src` to `tgt` and
`src` "disappears from `knownTimes` (nothing is left carrying it)" (`:355-357`).
`TimeOrdering.identifyTime` (`:705-710`) substitutes `src := tgt` throughout the constraint list,
dropping only pairs that collapse to `(t,t)`.

### 4.2 The witness

Take any two signed formulas `f₀` at time `0` and `f₇` at time `7`, and

```
b   = [f₀, f₇]                    -- knownTimes = [0, 7], maxTime = 7, nextTime = 8
ord = ⟨[(5, 7)]⟩
```

**The remedy-2 hypothesis holds for `(b, ord)`**: `5 < 8` and `7 < 8`.

Now trace `firstIncomparablePair b ord`:
- `ts = b.knownTimes = [0, 7]`;
- for `t₁ = 0`: `directFutureOf 0 = []` (the only constraint's first component is `5`), so
  `futureOf 0 = []` (`SignedFormula.lean:741-748` returns `visited = []` when the first frontier
  step is empty); `directPastOf 0 = []` likewise, so `pastOf 0 = []`;
- the inner `ts.find?` picks `t₂ = 7`, since `7 ≠ 0` and `7` is in neither list;
- result: `some (0, 7)`, so `t₁ = 0`, `t₂ = 7`.

Arm 3's successor pair:
- `b' = b.identifyTime 7 0` — both formulas now sit at time `0`; `knownTimes(b') = [0]`,
  `maxTime = 0`, **`b'.nextTime = 1`**;
- `ord' = ord.identifyTime 7 0` — the pair `(5, 7)` maps to `(5, 0)`; `5 ≠ 0`, so it is **kept**,
  not dropped.

**The hypothesis fails for `(b', ord')`**: it requires `5 < b'.nextTime = 1`.

### 4.3 What this does and does not refute

It refutes **inductiveness**, not soundness. Under the stronger `OrdWithin` the state
`(b, ⟨[(5,7)]⟩)` is unreachable, because `5 ∉ b.knownTimes`. But that is exactly the point: at
the `timeLinearity` step the induction hypothesis hands the assembly *only* the remedy-2 bound,
and the remedy-2 bound is not enough to rule this state out or to re-derive the bound afterwards.
The proof cannot be closed; the theorem being proved is not thereby false.

### 4.4 Why this reaches the assembly even though `timeLinearity ∉ allRulesForFC`

This is the objection I expected to be the way out, and it is not one.

`timeLinearity` and `serialityRule` are provably outside `allRulesForFC` at every frame class
(`RuleSpec.lean:310-312, 337-343`), so the literal 7.2 statement
`∀ r ∈ allRulesForFC fc, RuleSound C r` never mentions `timeLinearity`. But the **engine applies
it**: it is the third stage of both `expandOnce` (`Tableau.lean:2049-2050`) and
`expandOnceUnblocked` (`Tableau.lean:2095-2097`), via `linearityRules` /
`findApplicableLinearityRule` / `findUnexpandedLinearity` (`Tableau.lean:1602-1623`), and the
docstring records it as live: "`timeLinearity` is now wired into `expandOnce` /
`expandOnceUnblocked` as the third stage" (`Tableau.lean:1553`). Its `.splitOrdered` output has
five live consumers in the fuel loop and the post-blocking pass (`Saturation.lean:467, 666, 763,
851, 1713`; also `CancellableExpansion.lean:112, 227`), each recursing on the matched pair
`(pair.1.1, pair.1.2)` (`Saturation.lean:851-863`).

Track A's direction — the assembly propagates satisfiability *forward* from a satisfied root
along the construction to a satisfied leaf, contradicting `allClosed` — means the induction runs
over the **engine's** steps, not over `allRulesForFC` as a set. Every engine step must preserve
whatever the induction carries. So the invariant must survive `timeLinearity`, whether or not
`RuleSound` is ever stated for it.

The handoff's own observation that "`SatResult`'s `.branchingOrdered` arm has no consumer"
(`.orchestrator-handoff.json`, `next_obligations` item 5) is therefore not a reason the arm can
be ignored — it is a **second, pre-existing gap**: the assembly as currently scoped does not yet
cover two rules the engine actually fires. Remedy 2 is being priced against an assembly that
does not yet exist in the shape it will need.

---

## 5. THE CORRECTION

### 5.1 `OrdWithin` implies the remedy-2 bound

```lean
def OrdWithin (b : Branch) (ord : TimeOrdering) : Prop :=
  ∀ p ∈ ord.constraints, p.1 ∈ b.knownTimes ∧ p.2 ∈ b.knownTimes
```

`t ∈ b.knownTimes → t < b.nextTime` is a three-line lemma with both halves already in tree:
`Branch.knownTimes = (b.map (·.label.time)).eraseDups` (`SignedFormula.lean:349-350`), so
`List.mem_eraseDups` + `List.mem_map` produces `sf ∈ b` with `sf.label.time = t` (this is the
converse of `mem_knownTimes_of_mem`, `Bridge/BoxSaturation.lean:261-264`, whose proof is exactly
those two lemmas in the other direction), and `le_maxTime` (`Tableau.lean:2465-2467`) plus
`Branch.nextTime = maxTime + 1` (`SignedFormula.lean:380-381`) finishes it.

So the six fresh-time producers get everything remedy 2 gave them. Specifically, the fact their
proof consumes is `freshTime ∉ times(ord)` — because `freshTime = b.nextTime` is strictly above
every constraint time, the one-point update of `tv` at `freshTime` disturbs no existing
`ordResp` obligation, and `not_mem_of_time_nextTime` (`Tableau.lean:2476-2482`) already gives the
matching branch-side freshness for `sat`. The refutation in tree
(`addFuture_nextTime_cycle_unsatisfiable`, `Decidable.lean:971`) is defused because its witness
`ord.constraints = [(b.nextTime, l.time)]` fails `OrdWithin` for the same reason it fails the
remedy-2 bound: `b.nextTime ∉ b.knownTimes`.

### 5.2 `OrdWithin` is preserved by all 36, including arm 3

G1–G5, G8, G10, G12–G15: ordering unchanged, branch additive, so
`times(ord) ⊆ knownTimes(b) ⊆ knownTimes(b')`. G6, G7, G9: new pair is `(l.time, freshTime)` (or
its mirror); `l.time ∈ knownTimes(b)` by `mem_knownTimes_of_mem` from `sf ∈ b`, and
`freshTime ∈ knownTimes(b')` by the unfiltered witness (§3.1). G11: additionally
`t' ∈ times(ord) ⊆ knownTimes(b)` by the `futureOf` argument of §3.2.

**G16, the case that refutes remedy 2:**
`knownTimes(b.identifyTime t₂ t₁) = (knownTimes(b) \ {t₂}) ∪ {t₁}` — `t₂` disappears
(`SignedFormula.lean:355-357`) and `t₁` survives, since `t₁ ∈ b.knownTimes` by
`firstIncomparablePair`'s construction (`Tableau.lean:421`) and nothing at `t₁` is moved. Every
time in `ord.identifyTime t₂ t₁` is either an unchanged time of `ord` other than `t₂`, or `t₁`
(`SignedFormula.lean:705-710`). By the induction hypothesis those unchanged times are in
`knownTimes(b)` and, being `≠ t₂`, are in `knownTimes(b')`. So `OrdWithin b' ord'` holds. **The
membership formulation is stable under exactly the operation the numeric bound is not.**

### 5.3 Independent corroboration already in tree

`Bridge/BranchOrder.lean:52-65` argues the indexing choice for `BranchTime` and states this
invariant in prose, including the historical counterexample that motivated it:

> Pre-2.5 the engine's destructive expansion could consume every formula sitting at a time, and
> that time then vanished from `knownTimes` even though `ord.constraints` still mentioned it. The
> measured symptom (report 04 §Q2.2) was `constraints = [(0,2),(0,1)]` with `knownTimes = [2,1]`
> … 2.5's non-destructive expansion removed the cause … so `knownTimes` is now closed under
> "mentioned by a live constraint" for the constraints that matter.

That is `OrdWithin`, asserted informally and **hedged** ("for the constraints that matter"). The
hedge is the tell: the file relies on the invariant without proving it. Making it `RuleSound`'s
explicit hypothesis converts an assumed property of a downstream bridge into a stated one, at no
extra cost over remedy 2 — which is a strict improvement in the tree's overall accounting, not
merely a fix for this blocker.

Note also `BranchOrder.lean:88-91`: "**identification shrinks `knownTimes`**" — the file already
knows the operation that breaks the numeric bound, and treats it as the load-bearing fact of the
unwinding argument.

### 5.4 Residual risk this dispatch could not close

`BranchOrder.lean:67-86` describes time-**blocking** repair as also proceeding by identification.
Grep shows the only `Branch.identifyTime` *call site* in `FormalSystem/` is `Tableau.lean:1388`
(all other hits are docstrings, `#eval` gate rows at `BranchOrder.lean:459-465`, a `Fuel.lean`
gate row at `:1180`, and `SubformulaProperty.lean:437-442, 666-689`), so blocking's
identification appears to be a semantic reading rather than an engine call. If a future dispatch
finds a second call site, it must be re-checked against `OrdWithin` — the check is the §5.2 G16
argument verbatim and should go through, but it has not been performed against code that does
not exist yet.

---

## 6. H5 DIVERGENCE AUDIT

### 6.1 Divergence table

| Target | Churn | Last-attempted approach | Failure reason |
|---|---|---|---|
| `RuleSound carrierBase .boxNeg` / `.diamondPos` | 3+ cycles; entered then **withdrawn** from the do-not-re-attempt register | prove as stated | Register entry rested on the group-3 engine blocks; another task removed them; the entry read as authoritative while false. Both went green first try once rechecked. |
| The six fresh-time producers | 2 cycles | prove as stated | Genuinely false as stated (`Decidable.lean:971` and its past mirror). Not a proof failure — a statement defect. |
| Remedy 1 (fifth `SatState` field) | 1 cycle | add `b`-positive field | `SatState.mono` (`Decidable.lean:161-165`) weakens `b`; field is in the conclusion. Correctly closed. |
| Remedy 2 (RuleSound hypothesis) | this cycle | numeric `< b.nextTime` bound | **Not an inductive invariant** — `timeLinearity` arm 3 (§4). |
| "18 of 28" denominator | 3+ cycles, carried forward unexamined | — | Wrong denominator (§6.2). |

### 6.2 Root cause: a *stale-value* failure mode, repeating in a new register

The plan's own process lesson names it precisely — "a measurement has a value and a meaning, and
reusing the value reopens the question of the meaning" — and this cycle it recurred twice more.

**First, the rule count.** The handoff reports progress as "18 of 28"
(`.orchestrator-handoff.json`, `rules_sound`) in five separate places. The plan already warns
against exactly this figure at line 177: *"Do NOT size case analyses against the charter's '28
rules'."* The actual counts, from source:

- `TableauRule` has **36** constructors (`Tableau.lean:73-191`);
- `allRules` has **26** entries (`Tableau.lean:1437-1456`) — the plan's line 108 says 25, also
  stale by one;
- `+ denseRules` 2 `+ discreteRules` 3 `+ dedekindRules` 3 = **34** rules reachable through
  `allRulesForFC` across all frame classes;
- `+ serialityRule + timeLinearity` = **36** the engine actually fires.

So 7.2's true denominator is **34** for the literal statement and **36** for an engine-faithful
assembly. "18 of 28" overstates completion by presenting 53% as 64%, and — more seriously —
the six rules the wrong denominator hides are precisely the frame-class-gated ones, one of which
(`densityRule`) is a fresh-time producer that this very blocker governs. The blocker note's own
`next_obligations` item 4 flags `densityRule` as "a fresh-time producer too", which is
inconsistent with a denominator that does not include it.

**Second, the remedy-2 pricing.** The measured fact "`SatState.mono` blocks any `b`-positive
`SatState` field" was correct. Its *meaning* — "any `b`-positive predicate is fragile at every
branch-shrinking step" — was not carried across when the fact was reused to clear remedy 2. The
reuse checked the one shrinking step that had been measured (`mono`) and did not enumerate the
others (`timeLinearity` arm 3, the one the engine actually takes).

Root cause, one sentence: **the register carries values without their scopes, and the scope is
what generalizes.** A do-not-re-attempt entry naming a cause is checkable in one grep; a measured
obstruction naming one *site* is not evidence about the other sites of the same kind.

### 6.3 Sorry inventory

| Identifier | State | Type | Why stuck |
|---|---|---|---|
| — | — | — | Census over `FormalSystem/Metalogic/Decidability/Verified/` reports **0** sorries (`.orchestrator-handoff.json`, `verification.sorry_count`). Nothing was added this dispatch; no `.lean` file was touched. |

### 6.4 Type-mismatch analysis

| Theorem | Expected (as stated) | Actual (as provable) | Mismatch |
|---|---|---|---|
| `RuleSound C r`, six fresh-time producers | `sf ∈ b → SatState … → SatResult …` | needs a fourth hypothesis relating `ord`'s times to `b`'s | Statement defect, proved by `addFuture_nextTime_cycle_unsatisfiable` (`Decidable.lean:971`) |
| remedy-2 form of that hypothesis | `∀ p ∈ ord.constraints, p.1 < b.nextTime ∧ p.2 < b.nextTime` | not preserved by `Tableau.lean:1388` | Not an inductive invariant (§4) |
| corrected form | `∀ p ∈ ord.constraints, p.1 ∈ b.knownTimes ∧ p.2 ∈ b.knownTimes` | preserved by all 36 (§5.2) | — |

### 6.5 Corrected Lean-ready targets

Exact signatures for the next dispatch. **No `.lean` file was edited by this dispatch; these are
proposals, not landed code.**

```lean
/-- Every time recorded in the ordering is a time the branch knows. Discharged at the root by
`TimeOrdering.empty` and preserved by every arm of `applyRule`, including the identification
arm of `timeLinearity`, which the numeric `< b.nextTime` bound does not survive. -/
def OrdWithin (b : Branch) (ord : TimeOrdering) : Prop :=
  ∀ p ∈ ord.constraints, p.1 ∈ b.knownTimes ∧ p.2 ∈ b.knownTimes

theorem lt_nextTime_of_mem_knownTimes {b : Branch} {t : TimeIndex}
    (h : t ∈ b.knownTimes) : t < b.nextTime

theorem OrdWithin.bound {b : Branch} {ord : TimeOrdering} (h : OrdWithin b ord) :
    ∀ p ∈ ord.constraints, p.1 < b.nextTime ∧ p.2 < b.nextTime

theorem OrdWithin.empty (b : Branch) : OrdWithin b TimeOrdering.empty

theorem OrdWithin.append {b : Branch} {ord : TimeOrdering} {fs : List SignedFormula}
    (h : OrdWithin b ord) : OrdWithin (fs ++ b) ord

theorem OrdWithin.identifyTime {b : Branch} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (h : OrdWithin b ord) (h₁ : t₁ ∈ b.knownTimes) :
    OrdWithin (b.identifyTime t₂ t₁) (ord.identifyTime t₂ t₁)
```

and `RuleSound` with the hypothesis **last**:

```lean
def RuleSound (C : CarrierProp) (r : TableauRule) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D],
    C D → ∀ (F : TaskFrame D) (M : TaskModel F) (Om : Set (WorldHistory F))
      (hist : WorldIndex → WorldHistory F) (tv : TimeIndex → D)
      (b : Branch) (sf : SignedFormula) (ord : TimeOrdering),
      sf ∈ b → SatState M Om hist tv b ord → OrdWithin b ord →
      SatResult M Om b (applyRule r sf b ord).1 (applyRule r sf b ord).2
```

Edit sites: 18 `intro` lines (`Decidable.lean:311, 337, 370, 400, 425, 453, 476, 496, 568, 594,
624, 743, 776, 1063, 1087, 1113, 1139, 1222`) plus `RuleSound.mono` (`:268` intro and `:269`
`exact`).

Recommended landing order (each independently green, per the commit-per-green-substep mandate):
`OrdWithin` + the five lemmas above → `RuleSound` statement change + 19 `intro` sites (one commit,
the tree is red in between) → the four fresh-time existentials → `untlPos`/`sncePos` and the
`untlNeg`/`snceNeg` active arms → `densityRule`.

---

## Adversarial Self-Verification

Every load-bearing claim, with the counterexample that would refute it and the method used.
Verification methods available to this dispatch were **plain file reads and greps only** — no
`lake build`, no elaboration, per the dispatch constraint. Nothing below was checked by the
compiler; anything that would require elaboration to settle is marked
`UNVERIFIABLE-WITHOUT-BUILD` rather than asserted.

| Claim | Source / Counterexample | Verification Method | Verdict | Confidence |
|---|---|---|---|---|
| **(a)** Remedy 2 survives `SatState.mono` | `SatState.mono` (`Decidable.lean:161-165`) does not mention `nextTime`; remedy 2 touches `RuleSound`, not `SatState`. Would be refuted by a `mono`-like lemma producing the hypothesis — none exists (only 5 `.mono` hits in the file, `:48, 72, 161, 265, 954`). | file read + grep `\.mono\b` | **CONFIRMED** | High |
| **(a′)** …but mono-survival does not imply assembly-survival | The anti-monotonicity relocates to the successor step; `timeLinearity` arm 3 shrinks `b` (`Tableau.lean:1388`, `SignedFormula.lean:355-357`) | file read | **CONFIRMED** (correction to (a)) | High |
| **(b)** Costs the 18 landed proofs one `intro` each | 18 `intro D _ _ _ _ _ F M Om hist tv b sf ord hmem hst` lines enumerated by grep | grep `intro D ` over `Decidable.lean` | **CONFIRMED** | High |
| **(b′)** …but the count is 19, not 18 | `RuleSound.mono` (`:265-269`) is a 19th consumer needing intro **and** an extra `exact` argument | grep `RuleSound` repo-wide (only other hits are docstrings and two test-probe comments) | **CONFIRMED** (correction to (b)) | High |
| **(b″)** Position matters: hypothesis must be last | All 18 intro lines bind 16 names positionally; an earlier insertion misbinds `hst` | file read of the intro lines vs. `RuleSound`'s binder order (`:253-259`) | **CONFIRMED** by code reading; the exact failure message is **UNVERIFIABLE-WITHOUT-BUILD** | High (mechanism) / Medium (symptom) |
| **(c)** Discharged at the assembly from `TimeOrdering.empty` — *root* | `TimeOrdering.empty := { constraints := [] }` (`SignedFormula.lean:679`); root call `expandBranchWithFuel initialBranch fuel TimeOrdering.empty fc` (`Saturation.lean:931`) | file read | **CONFIRMED** | High |
| **(c′)** Discharged at the assembly — *inductively, at every successor* | **REFUTED.** Counterexample §4.2: `b = [f₀, f₇]`, `ord = ⟨[(5,7)]⟩` satisfies the bound; `timeLinearity` arm 3 yields `b'.nextTime = 1` with constraint `(5,0)` surviving | file read of `Tableau.lean:1381-1389, 420-427`, `SignedFormula.lean:349-367, 705-710, 741-748` | **REFUTED** | High (by code reading); a Lean `example` witnessing it is **UNVERIFIABLE-WITHOUT-BUILD** |
| Preservation, G1–G5 (13 rules: truth-functional 8, `boxPos`, `diamondNeg`, `boxTemporal`, temporal universals, `orderTrichotomy`) | All return `timeOrd` verbatim and are additive. Refuted if any returned a modified ordering — grep for `addFuture\|addPast` shows no hit in their arms | grep `addFuture\|addPast\|nextTime\|identifyTime\|maxTime` over all of `Tableau.lean` (11 ordering-mutating sites total, all accounted for) | **CONFIRMED** | High |
| Preservation, G6/G7/G9 (fresh-time producers, 8 arms) | Each mints one constraint at `freshTime = branch.nextTime` and emits an **unfiltered** formula there (`:714, 754, 785, 854, 856, 899, 901, 991, 993`). Refuted if the witness were `branch.contains`-guarded like the propagated formulas | file read of each arm | **CONFIRMED** | High |
| Preservation, G11 `densityRule` (two constraints, one step) | `Tableau.lean:1241`; `t'` bounded because `futureOf` only returns constraint endpoints (`SignedFormula.lean:741-748, 776-777`). Refuted if `futureOf` could return an unconstrained time | file read of `reachableForward` | **CONFIRMED** | High |
| Preservation, G10/G12/G13/G14 (7 rules) | `.linear []` / `.persistent [newSf]` at existing label `l`, `timeOrd` returned (`:1203, 1262, 1272, 1344, 1358`) | file read | **CONFIRMED** | High |
| Preservation, G15 `timeLinearity` arms 1–2 | `t₁,t₂ ∈ b.knownTimes` (`:420-427`), branch unchanged | file read | **CONFIRMED** | High |
| `timeLinearity` reaches the assembly despite `∉ allRulesForFC` | Wired as stage 3 of `expandOnce` (`:2049-2050`) and `expandOnceUnblocked` (`:2095-2097`); `.splitOrdered` has 7 live consumers (`Saturation.lean:467, 666, 763, 851, 1713`; `CancellableExpansion.lean:112, 227`) | grep `splitOrdered`, `timeLinearity` | **CONFIRMED** | High |
| `identifyTime` is the *only* non-additive engine path | Every expansion tail builds `fs ++ b` (`Tableau.lean:2055-2063, 2102-2106, 2142-2145, 2350-2360`); `Branch.identifyTime`'s sole call site in `FormalSystem/` is `Tableau.lean:1388` | grep `identifyTime` repo-wide + read of all four tails | **CONFIRMED** | High |
| `OrdWithin` implies the remedy-2 bound | `knownTimes` def (`SignedFormula.lean:349-350`) + `le_maxTime` (`Tableau.lean:2465`) + `nextTime = maxTime+1` (`:380-381`); converse direction of `mem_knownTimes_of_mem` (`BoxSaturation.lean:261-264`) | file read of all four | **CONFIRMED** as a mathematical step; the three-line Lean proof is **UNVERIFIABLE-WITHOUT-BUILD** | High / Medium |
| `OrdWithin` is preserved by all 36, incl. arm 3 | §5.2. Refuted if `t₁ ∉ b.knownTimes` — but `firstIncomparablePair` draws it from `b.knownTimes` (`:421`) | file read | **CONFIRMED** by code reading | Medium-High (**UNVERIFIABLE-WITHOUT-BUILD**) |
| Rule denominator is 34/36, not 28 | 36 constructors (`Tableau.lean:73-191`), 26 in `allRules` (`:1437-1456`), 2+3+3 gated (`:1461-1485`), 2 excluded (`RuleSpec.lean:310-343`). Plan line 177 already warns against "28"; plan line 108's "25 base" is also off by one | enumerated by script over the source ranges | **CONFIRMED** | High |
| The blocker's own refutation (`addFuture_nextTime_cycle_unsatisfiable`) is defused by `OrdWithin` | Its witness `ord.constraints = [(b.nextTime, l.time)]` (`.orchestrator-handoff.json` blocker) has `b.nextTime ∉ b.knownTimes` by `not_mem_of_time_nextTime` (`Tableau.lean:2476-2482`) | file read | **CONFIRMED** | High |
| Remedy 1 remains blocked | Not re-derived — taken from the handoff's measurement per its do-not-re-attempt entry; independently consistent with `SatState.mono`'s conclusion polarity (`:161-165`) | file read (consistency check only) | **CONFIRMED (inherited, not re-measured)** | Medium |

### Contradiction log

**Resolved.** The handoff asserts (blocker `isolation`) that "ONLY the six fresh-TIME producers
are affected", and separately (`next_obligations` item 4) that "the density rule … is a
fresh-time producer too", making seven. Precedence: source code over handoff prose. Resolution:
there are **nine** fresh-time-minting arms —
`allFutureNeg`/`allPastNeg`/`someFuturePos`/`somePastPos` (4), `untlPos`/`sncePos` (2), the
active arms of `untlNeg`/`snceNeg` (2), and `densityRule` (1) — at `Tableau.lean:687, 727, 760,
804, 850, 895, 957, 1030, 1238`. The "six" figure counts the untl/snce active arms as two rather
than four and omits `densityRule`. This does not change any verdict (all nine preserve both
invariants) but it does change the remaining-work estimate.

**Resolved.** The handoff calls remedy 2 "discharged at the assembly by induction from
`TimeOrdering.empty`" and simultaneously records that `.branchingOrdered` "has no consumer".
Precedence: the engine source over the assembly's current scope. Resolution: the two statements
are consistent only if the assembly never covers `timeLinearity`, and the engine fires it
(`Tableau.lean:2049`), so the first statement is false for any assembly that covers the engine.
This is the substance of §4.4.

**No unresolved contradictions.**

### Recommendations modified after verification

1. Verdict moved from a provisional AUTHORIZE (after §3, when 35 of 36 groups had come back
   clean) to **AUTHORIZE WITH CORRECTION**, on finding G16.
2. Cost estimate revised 18 → 19 sites, plus a statement-position constraint that was not in the
   original proposal.
3. Added §6.2's denominator finding, which was not in this dispatch's brief but is a direct
   consequence of enumerating all 36 constructors to answer question 1.

---

## Appendix: what a future dispatch must NOT re-derive from this report

- The nine fresh-time-minting arms and their line numbers (§ contradiction log).
- That every expansion tail is `fs ++ b` and `Branch.identifyTime`'s only call site is
  `Tableau.lean:1388`. Grepped repo-wide.
- That `futureOf` returns only constraint endpoints (`SignedFormula.lean:741-748`). This is what
  makes `densityRule`'s `t'` bounded and is reusable for any future ordering invariant.
- The `OrdWithin` preservation argument for arm 3 (§5.2). It turns entirely on `t₁` surviving
  `Branch.identifyTime` and on `TimeOrdering.identifyTime` introducing no time other than `t₁`.
- That the rule denominator is 34 (statement) / 36 (engine). Counted from source, twice.
