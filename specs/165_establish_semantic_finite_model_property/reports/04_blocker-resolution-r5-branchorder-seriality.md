# Blocker Resolution: R5 Certificate Strength, Per-Branch Time Ordering, Seriality

- **Task**: 165 — establish_semantic_finite_model_property
- **Started**: TBD
- **Completed**: TBD
- **Effort**: TBD
- **Dependencies**: TBD
- **Sources/Inputs**: TBD
- **Artifacts**: TBD
- **Standards**: TBD
- **Type**: lean4 (hard mode, blocker research dispatch)
- **Session**: sess_1785198629_c14175
- **Plan under repair**: `specs/165_establish_semantic_finite_model_property/plans/01_tableau-decidability-two-track.md`
- **Inputs**: plan Phase 2 `**BLOCKER**` block (plan:297–334), Phase 2 summary
  (`summaries/02_phase2-calculus-completion-summary.md`), `.orchestrator-handoff.json`,
  `FormalSystem/Metalogic/Decidability/{Saturation,Tableau,SignedFormula}.lean`,
  `Tests/BimodalTest/TableauConformance.lean`
- **Method**: code reading + six executable prototype probes run under `lake env lean` against
  the built project. **No `.lean` file in the repository was modified.** All probe sources live
  in the session scratchpad (`probe1.lean`–`probe3.lean`); every number below is a measured
  `#eval` result, reproducible by re-running those files.

---

## Executive summary

All three questions resolve, and two of the three resolve **against** the direction the plan
and the Phase 2 handoff assumed.

1. **R5 (Q1).** Neither of the plan's two routes is the answer, and the handoff's diagnosis of
   *why* is incorrect in a way that matters. `AppliedRedundant` is not merely unproved — it is
   **false**, measured false on four formulas as simple as `◇(p ∧ q)` and `◇¬¬p`. And the
   handoff's stated obstruction ("several persistent rules return `.persistent fs` even when
   every element of `fs` is already on the branch") is **contradicted by the source**: every
   `.persistent` arm in `applyRule` is already branch-guarded. The real driver of the
   persistent/consumable cycle is **source destruction** by the linear/branching arms. Removing
   destruction and adding the same branch-guard to the linear/branching arms makes
   `findUnexpanded … = none` *reachable* and *equal to genuine downward saturation* — the exact
   truth-lemma hypothesis. A prototype of this engine reproduces all 24 corpus verdicts with
   **zero regressions** and reaches `findUnexpanded' = none` (not "blocked") on every open row.
2. **Phase 5.1 premise (Q2).** Confirmed refuted, now with a measured witness:
   `¬(F(G p) ∧ F(¬p))` at `.Base` yields an open certificate with `knownTimes = [2,1]`,
   `constraints = [(0,2),(0,1)]`, incomparable pair `(1,2)`, unchanged at fuel 200 and 2000.
   A second, independent defect surfaces in the same measurement: the constraint set mentions
   time `0`, which is **not in `knownTimes`**, so the order *induced on `knownTimes`* is empty —
   Phase 5.1's `n = b.knownTimes.length` indexing is broken independently of totality. The
   cheap fallback (partial order + arbitrary Mathlib linear extension) is **unsound**, and that
   same witness is the counterexample.
3. **Seriality (Q3).** Fully resolved with a working, measured design. The missing rule is a
   single persistent `serialityRule` adding `T(F ⊤)` and `T(P ⊤)` at each label — the tableau
   image of `Axiom.serial_future`/`Axiom.serial_past` (`Axioms.lean:113,117`). Its scheduling is
   the whole difficulty and is now pinned by measurement: it must be **globally last** (fire only
   when no other formula on the branch has any applicable rule), not merely last in
   `allRulesForFC`. With globally-last scheduling the prototype hits **24/24 semantic targets at
   `.Base`, at the corpus's existing fuel of 200** — all five seriality rows plus `K2`/`K3` flip
   to CLOSED and every control holds. With per-formula-last scheduling, `C5` and `A` regress.

The consequence for the plan is one restated sub-phase and three new ones, all inside Phase 2's
engine territory (wave 2), plus a rewrite of Phase 5.1 and a hypothesis change in Phase 7.1. The
delta is specified in the final section.

---

## Reference grounding

**Tier 3 (implementation-backed).** There is no external paper being transcribed here; the
"source" is this repository's own engine plus the proof system it must be complete for. The
mapping below is the 5-column form, with the source column naming the in-repo authority.

| Source | Prop / Location | Lean Identifier | Type Signature | Status |
|---|---|---|---|---|
| Engine certificate | `Saturation.lean:56–59` | `ExpandedTableau.hasOpen` | `(openBranch : Branch) → (timeOrdering : TimeOrdering) → (appliedSet : AppliedSet) → (findUnexpandedWithApplied openBranch (timeOrd := timeOrdering) (applied := appliedSet) = none) → ExpandedTableau` | VERIFIED — `fc` argument omitted, so the certified proposition is about `.Base` for every frame class |
| R5 landed predicate | `Saturation.lean:122–129` | `appliedEntryRedundant` | `Branch → TimeOrdering → FrameClass → SignedFormula → Bool` | VERIFIED — measured **false** on the pipeline's own output (§Q1.2) |
| R5 landed predicate | `Saturation.lean:139–141` | `AppliedRedundant` | `Branch → TimeOrdering → FrameClass → AppliedSet → Bool` | VERIFIED — refuted as an invariant |
| Applied-set filter | `Tableau.lean:1380–1398` | `findApplicableRuleWithApplied` | `SignedFormula → Branch → TimeOrdering → FrameClass → AppliedSet → Option (TableauRule × RuleResult × TimeOrdering × List SignedFormula)` | VERIFIED — filters `.persistent` only (1390–1396) |
| Destruction site | `Tableau.lean:1428, 1431` | `expandOnceWithApplied` | `Branch → TimeOrdering → FrameClass → AppliedSet → ExpansionResult × TimeOrdering × List SignedFormula` | VERIFIED — `remaining := b.filter (· != sf)` |
| Split plumbing | `Tableau.lean:1345` | `ExpansionResult.split` | `(branches : List Branch) → ExpansionResult` | VERIFIED — carries no per-branch ordering |
| Split plumbing | `Tableau.lean:179` | `RuleResult.branching` | `(branches : List (List SignedFormula)) → RuleResult` | VERIFIED — carries no per-branch ordering |
| Rule application | `Tableau.lean:380–381` | `applyRule` | `TableauRule → SignedFormula → Branch → TimeOrdering → RuleResult × TimeOrdering` | VERIFIED — one `TimeOrdering` out, for all branches |
| Fuel loop | `Saturation.lean:346–379` | `expandBranchWithFuel` (`.split` arm) | `Branch → Nat → TimeOrdering → FrameClass → EventualityTracker → AppliedSet → Nat → Nat → Option (ClosedBranch ⊕ (Branch × TimeOrdering × AppliedSet))` | VERIFIED — line 375 passes the same `newOrd` to every sub-branch |
| Proof system | `Axioms.lean:113` | `Axiom.serial_future` | `Axiom ((Formula.bot.imp Formula.bot).imp (Formula.someFuture (Formula.bot.imp Formula.bot)))` | VERIFIED — soundness source for the proposed `serialityRule` future arm |
| Proof system | `Axioms.lean:117` | `Axiom.serial_past` | `Axiom ((Formula.bot.imp Formula.bot).imp (Formula.somePast (Formula.bot.imp Formula.bot)))` | VERIFIED — past arm |
| Time reachability | `SignedFormula.lean:739` | `TimeOrdering.futureOf` | `TimeOrdering → TimeIndex → Nat → List TimeIndex` | VERIFIED — transitive since 1.2; used by the witness guards below |
| Branch times | `SignedFormula.lean:349` | `Branch.knownTimes` | `Branch → List TimeIndex` | VERIFIED — `(b.map (·.label.time)).eraseDups`; **omits ordering-only times** (§Q2.2) |
| Corpus rows | `TableauConformance.lean:200–211` | `serialityRows` | `List Row` | VERIFIED — the five rows that must flip |
| Corpus rows | `TableauConformance.lean:217–222` | `seriesRows` | `List Row` | VERIFIED — `K2`–`K6` must flip |

---

## Q1 — R5: which route is provable, and the exact lemma statements

### Q1.1 The handoff's stated obstruction is not what the source says

The handoff and the plan's blocker block both rest on this claim:

> the obvious statement (`every applied entry is on the branch` implies `findUnexpanded = none`)
> is false, because several persistent rules return `.persistent fs` even when every element of
> `fs` is already on the branch.

Every `.persistent` return site in `applyRule` was checked. There are thirteen
(`Tableau.lean:427, 525, 534, 543, 583, 657, 701, 1091, 1102, 1112, 1129, 1148, 1164, 1184`).
Twelve of them are immediately preceded by a branch-presence guard that returns
`.notApplicable` when nothing new remains:

- `boxPos` — `Tableau.lean:423–427` (`filterMap … if branch.contains newSf then none`, then
  `if newFormulas.isEmpty then (.notApplicable, timeOrd)`)
- `diamondNeg` — `521–525`
- `boxTemporal` — `532–534`
- `allFuturePos` — `539–543`
- `allPastPos` — `579–583`
- `someFutureNeg` — `653–657`
- `somePastNeg` — `693–701`
- `priorUZ`, `priorSZ`, `z1Rule`, `priorUGap`, `priorSGap`, `sepRule` — `1099–1184`, each
  `if branch.contains newSf then (.notApplicable, timeOrd) else (.persistent [newSf], timeOrd)`

The thirteenth (`densityRule`, `Tableau.lean:1091`) emits its witness at a *fresh* time, so its
output cannot be on the branch by construction; it carries a different guard
(`existingIntermediates.isEmpty`, `1074–1076`).

The two rules the docstrings call persistent but which in fact return `.branching` —
`untlNeg` (`Tableau.lean:800`) and `snceNeg` (`874`) — are self-guarded too, by their
`unprocessed` filter, and they already **re-include the source formula `sf` in every arm**
(`855–856`, `865`). They are therefore non-destructive today, which is direct in-repo precedent
for change (b) below.

So no persistent rule re-fires on a branch that already carries its output. **The
persistent/consumable cycle is driven entirely by destruction**: `expandOnceWithApplied` deletes
the source of every `.linear`/`.branching` rule (`Tableau.lean:1428, 1431`;
`expandOnce` likewise at `1365, 1369`). `boxPos` produces `T(¬p)`; `negPos` consumes `T(¬p)`;
`boxPos`'s own guard now sees `T(¬p)` missing and re-emits it; `negPos` consumes it again. The
applied set exists solely to paper over that.

This matters because it relocates the fix. The obstruction is not in the persistent rules; it is
in the destructive arms, which are one guard away from being safe.

### Q1.2 `AppliedRedundant` is false, not merely unproved

Measured (`probe1.lean`, `.Base`, fuel 200, `buildTableau` certificates, printing
`AppliedRedundant b ord fc applied` for the pipeline's own output):

| formula | `fullySat` | `applied` | `orphans` | `AppliedRedundant` |
|---|---|---|---|---|
| `◇p` (the plan's named witness) | false | 3 | 3 | **true** |
| `◇(p ∧ q)` | false | 3 | 3 | **false** |
| `◇◇p` | false | 6 | 6 | **false** |
| `◇¬¬p` | false | 3 | 3 | **false** |
| `◇(□(p ∧ q) ∧ ¬p)` | false | 4 | 4 | **false** |
| `◇(U(p,q))` | false | 3 | 3 | true |
| `□p`, `G p`, `F p`, `U(p,q)`, `S(p,q)` | true | 0 | 0 | true (vacuous) |

The `◇p` witness the plan chose is unrepresentative. The mechanism of failure is visible in the
`probe3.lean` Part-A diagnostic: for `◇(p ∧ q)` the single non-redundant entry is
`T(¬(p → ¬q)) @ (0,0)`, absent from the branch, whose rule is `negPos` with output
`F(p → ¬q)` — which is *also* absent, because it too was consumed and decomposed one level
further. `appliedEntryRedundant` (`Saturation.lean:122–129`) is a **one-step** predicate; the
engine decomposes to arbitrary depth. It cannot be an invariant of `expandBranchWithFuel`.

**Therefore the plan's proposed 2.5 sub-phase — "prove `AppliedRedundant` invariant under
`expandBranchWithFuel`, then let `hasOpen` carry it as a field" — would fail.** Any dispatch that
attempts it burns a cycle proving a false statement. This is the single most important output of
this research.

Note also the transitive strengthening (`f ∈ b`, or all of `f`'s rule outputs are
*recursively* redundant, fuel-bounded) is *not* a repair either: `appliedEntryRedundant` reads
`findApplicableRule f b ord fc`, whose `.persistent` output set **grows with the branch** (more
worlds/times ⇒ more outputs), so the predicate is not monotone in `b` and the induction step for
a growing branch does not go through.

### Q1.3 A third, latent defect found while reading the certificate

`ExpandedTableau.hasOpen`'s `saturated` field (`Saturation.lean:56–59`) is

```
findUnexpandedWithApplied openBranch (timeOrd := timeOrdering) (applied := appliedSet) = none
```

`findUnexpandedWithApplied` has signature `(b) (timeOrd := …) (fc : FrameClass := .Base)
(applied := …)` (`Tableau.lean:1408–1411`). `fc` is **not supplied**, and neither is it supplied
at the two `buildTableau` construction sites (`Saturation.lean:667, 676`) nor in
`BranchListResult.foundOpen` (`Saturation.lean:155–158`). So for `.Dense`, `.Discrete` and
`.Dedekind` the certificate certifies saturation **with respect to the base rule set only**.

This is a *latent* defect: probe G over six formulas at `.Discrete` and `.Dedekind` found the
`.Base`-certified branches happened to be fc-saturated too, so no divergence has been exhibited
yet. But the proposition Phase 7.1's four class specialisations would consume is the
`.Base` one regardless of which class they specialise to. The R5 sub-phase must fix this while
it is in the file; the fix is to add `(fc : FrameClass)` as a field of `hasOpen` and pass it.

### Q1.4 The route that is provable, and how it is stated

**Route: uniform branch-guarded, non-destructive expansion; delete the applied set from the
certificate.**

Three changes, none of which touch `applyRule`'s 34 rule arms:

**(a) Guard the linear and branching arms the way the persistent arms are already guarded.**
In `findApplicableRule` (`Tableau.lean:1308–1317`), after `applyRule` returns:

```lean
| .linear fs      => if ruleMintsFreshLabel rule then
                       (if witnessPresent rule sf branch timeOrd then none
                        else some (rule, result, newOrd))
                     else (if fs.all branch.contains then none
                           else some (rule, result, newOrd))
| .persistent fs  => if fs.all branch.contains then none
                     else some (rule, result, newOrd)
| .branching bss  => if bss.any (fun fs => fs.all branch.contains) then none
                     else if ruleMintsFreshLabel rule && witnessPresent rule sf branch timeOrd
                       then none
                     else some (rule, result, newOrd)
```

with two new auxiliary definitions:

```lean
def ruleMintsFreshLabel : TableauRule → Bool
  | .boxNeg | .diamondPos | .allFutureNeg | .allPastNeg
  | .someFuturePos | .somePastPos | .untlPos | .sncePos | .densityRule => true
  | _ => false

def witnessPresent (rule : TableauRule) (sf : SignedFormula) (b : Branch)
    (ord : TimeOrdering) : Bool
```

`witnessPresent` is the only genuinely new semantic content: a fresh-label rule's outputs live at
a label that by construction is not on the branch, so `fs.all b.contains` can never suppress it,
and non-destructive application would mint times forever. The witness guard replaces literal
output-presence with *witness existence*, e.g. for `someFuturePos` on `T(F ψ) @ (w,t)`:
`(ord.futureOf t).any fun t' => b.contains (SignedFormula.pos ψ ⟨w, t'⟩)`. The eight arms needed
are exactly the eight `ruleMintsFreshLabel` constructors other than `densityRule` (whose
`existingIntermediates` guard at `Tableau.lean:1074–1076` already does this job); the full
prototype is `probe3.lean:59–94`.

Each guard is **sound in the tableau sense** (satisfiability-preserving both ways): suppressing a
rule whose conclusion the branch already carries adds nothing, and for the existential rules,
suppressing when a witness already exists is the standard "do not duplicate an existing witness"
restriction.

**(b) Stop destroying the source.** In `expandOnce` and `expandOnceWithApplied`, replace
`remaining := b.filter (· != sf)` (`Tableau.lean:1365, 1369, 1428, 1431`) by `remaining := b`.
With (a) in place this cannot loop: every step strictly adds at least one formula the branch did
not have, so branch length is a strict progress measure.

**(c) Restate the certificate.** `ExpandedTableau.hasOpen` becomes

```lean
| hasOpen (openBranch : Branch) (timeOrdering : TimeOrdering) (fc : FrameClass)
    (saturated : findUnexpanded openBranch (timeOrd := timeOrdering) (fc := fc) = none)
```

and the applied set leaves the certificate. (`AppliedSet` may be retained inside
`expandBranchWithFuel` purely as a performance memo, but nothing may depend on it; simplest is to
delete `findApplicableRuleWithApplied` / `isExpandedWithApplied` / `findUnexpandedWithApplied` /
`expandOnceWithApplied`, `Tableau.lean:1376–1435`, and the `applied` parameter threading in
`Saturation.lean:310–381`.)

**Why this is the provable route.** With (a)+(b), `findUnexpanded b ord fc = none` unfolds to
exactly the Hintikka/downward-saturation condition the truth lemma needs, with no side
conditions and no auxiliary invariant to prove:

```lean
theorem saturated_downward_closed
    {b : Branch} {ord : TimeOrdering} {fc : FrameClass}
    (h : findUnexpanded b ord fc = none)
    {sf : SignedFormula} (hsf : sf ∈ b)
    {rule : TableauRule} (happ : isApplicable rule sf fc = true)
    (hmem : rule ∈ allRulesForFC fc) :
    (∀ fs, (applyRule rule sf b ord).1 = .linear fs →
       (ruleMintsFreshLabel rule = false → ∀ g ∈ fs, b.contains g)
       ∧ (ruleMintsFreshLabel rule = true → witnessPresent rule sf b ord = true))
  ∧ (∀ fs, (applyRule rule sf b ord).1 = .persistent fs → ∀ g ∈ fs, b.contains g)
  ∧ (∀ bss, (applyRule rule sf b ord).1 = .branching bss →
       (∃ fs ∈ bss, ∀ g ∈ fs, b.contains g)
       ∨ (ruleMintsFreshLabel rule = true ∧ witnessPresent rule sf b ord = true))
```

Proof strategy: `findUnexpanded` is `b.find? (fun sf => ¬ isExpanded sf b ord fc)`
(`Tableau.lean:1332–1334`); `List.find?_eq_none` gives `isExpanded sf b ord fc = true` for every
`sf ∈ b`, i.e. `findApplicableRule sf b ord fc = none`; unfold `List.findSome?_eq_none_iff` over
`allRulesForFC fc` and read off each guard branch. This is a **mechanical unfolding lemma**, not
an induction over `expandBranchWithFuel` — that is the whole point of moving the condition from
the applied set into `findApplicableRule`.

The companion lemma the truth lemma also needs (progress, for Phase 4 rather than Phase 7):

```lean
theorem expandOnce_length_lt
    {b : Branch} {ord : TimeOrdering} {fc : FrameClass} {nb : Branch}
    (h : (expandOnce b ord fc).1 = .extended nb) : b.length < nb.length
```

which is immediate from `nb = fs ++ b` with `fs ≠ []` guaranteed by the guards in (a). This is a
strictly *easier* termination story than the current one and directly serves Phase 4.3's
`buildTableau_isSome`.

**Measured evidence (`probe3.lean`, column `protoNoSerial`, `.Base`, fuel 300).** A prototype
implementing (a)+(b) without any applied set, reusing the real `applyRule`, `findClosure`,
`findBlockedTime`, `registerEventualities`, `fulfillEventualities` and
`allocateFuelProportionally`, reproduces **all 24 corpus verdicts exactly** (12 CLOSED, 12 OPEN;
no row moved in either direction), and on **every** open row the terminal branch satisfies
`findUnexpanded' = none` — reported `OPEN-sat`, never `OPEN-blocked`. The certificate the plan
wanted is reachable.

### Q1.5 Residual risk in this route

`saturateBlocked` (`Saturation.lean:596–630`) calls the *unguarded* `expandOnce` (line 607) and
`buildTableau` re-checks saturation of the post-pass branch against the **pre-pass** applied set
(`Saturation.lean:673–678`). Under the new design the applied set is gone and `expandOnce` is
guarded, so this path becomes consistent automatically — but the sub-phase must re-run the
corpus with `saturateBlocked` in place, because the prototype does **not** model it (see Q3.4).

---

## Q2 — Phase 5.1's totality premise

### Q2.1 The premise is refuted structurally and by measurement

Structurally, three type signatures make a per-branch ordering impossible today:

- `RuleResult.branching (branches : List (List SignedFormula))` — `Tableau.lean:179`
- `applyRule … : RuleResult × TimeOrdering` — `Tableau.lean:380–381` (one ordering, all branches)
- `ExpansionResult.split (branches : List Branch)` — `Tableau.lean:1345`

and `expandBranchWithFuel`'s `.split` arm passes the single `newOrd` to every sub-branch
(`Saturation.lean:375`). The handoff's structural claim is correct.

Measured (`probe2.lean`, `.Base`, `buildTableau` open certificates; identical at fuel 200 and
2000):

| formula | `knownTimes` | `constraints` | incomparable pairs |
|---|---|---|---|
| `¬(F(G p) ∧ F(¬p))` | `[2, 1]` | `[(0,2), (0,1)]` | `[(1,2)]` |
| `¬(F p ∧ F q)` | `[2, 1]` | `[(0,2), (0,1)]` | `[(1,2)]` |
| `¬(F(G p) ∧ F(G q))` | `[2, 1]` | `[(0,2), (0,1)]` | `[(1,2)]` |
| `¬(F(¬p) ∧ F(G p))` | `[2, 1]` | `[(0,2), (0,1)]` | `[(1,2)]` |
| `¬(F p ∧ P q)` | `[2, 1]` | `[(2,0), (0,1)]` | `[]` |
| `F p → F F p` | `[1, 0]` | `[(0,1)]` | `[]` |

`orderTrichotomy` does not fire on any of these, and raising fuel tenfold changes nothing. A
saturated open branch routinely carries incomparable times.

### Q2.2 A second, independent defect in Phase 5.1's indexing

In every incomparable row above, `constraints` mentions time `0` while `knownTimes = [2,1]` — the
root time carries no surviving formula, because destruction removed them all
(`Branch.knownTimes` is `(b.map (·.label.time)).eraseDups`, `SignedFormula.lean:349`). So the
order **induced on `knownTimes`** is empty: `1` and `2` are related only *through* a time that
`knownTimes` does not list. Phase 5.1's `BranchOrder b ord : LinearOrder (Fin n)` with
`n = b.knownTimes.length` (plan:388–390) would therefore lose even the ordering facts the branch
*does* have.

Change (b) of the Q1 route fixes this defect as a side effect — with no destruction, the root
time keeps its formulas and stays in `knownTimes`. This is a second, independent reason to land
the Q1 route before Phase 5.

### Q2.3 The cheap fallback is unsound — refuted by the same witness

The natural cheap fix is "take the branch's partial order and extend it to a linear order"
(Mathlib `extend_partialOrder` / `LinearExtension`). **This is unsound**, and row W1 is the
counterexample. In `¬(F(G p) ∧ F(¬p))` the two incomparable siblings `1` and `2` carry `T(G p)`
and `F(p)` respectively. An arbitrary linear extension may place the `T(G p)` time first; the
interpolated model of Phase 6 is then obliged to make `p` true at the later time, which is
exactly where the branch asserts `F(p)`. The truth lemma's `allFuture` case fails on the
extracted model. The formula is genuinely satisfiable (put `¬p` before `G p`), so `OPEN` is the
right verdict — but only *one* of the two extensions produces a model, and nothing in the branch
records which. Any Phase 5.1 design that linearises without the calculus having chosen the order
inherits this hole. **The next dispatch must not spend a cycle on `extend_partialOrder`.**

The same argument kills the variant "propagate universals to incomparable times as well": that
step is not satisfiability-preserving without branching on the order.

### Q2.4 The smaller sound change

**Recommendation: per-branch orderings, introduced additively, staged behind a decidable gate.**
This is smaller than it looks because it needs no change to `applyRule`'s existing 34 arms.

*Types touched (additive; existing constructors keep their meaning):*

```lean
-- Tableau.lean, after RuleResult.branching (line 179)
/-- Branching rule that also constrains the time ordering differently per branch. -/
| branchingOrdered (branches : List (List SignedFormula × TimeOrdering))

-- Tableau.lean:1345
| split (branches : List (Branch × TimeOrdering))
```

*Functions touched:*

| function | file:line | change |
|---|---|---|
| `expandOnce` | `Tableau.lean:1354–1374` | `.branching bss` arm becomes `bss.map (fun fs => (fs ++ remaining, newOrd))`; new `.branchingOrdered` arm zips the per-branch orderings |
| `expandOnceWithApplied` | `Tableau.lean:1417–1435` | same (or is deleted by the Q1 route) |
| `expandBranchWithFuel` | `Saturation.lean:346–379` | `.split` arm zips `(Branch × TimeOrdering)` with `fuelAllocs` and passes each branch its own ordering instead of the shared `newOrd` (line 375) |
| `saturateBlocked` | `Saturation.lean:615–629` | `.split` arm updated identically |
| `expandOnceWithAppliedTracedImpl`, `expandBranchWithFuelTracedImpl` | `Saturation.lean:417–535` | mirror update |
| `expandBranchWithFuelCancellable`, `saturateBlockedCancellable` | `CancellableExpansion.lean` | mirror update (the files are line-for-line transcriptions; the drift warning is at `Saturation.lean:306–308, 593–594`) |

Existing rules are unaffected: `.branching bss` translates to `bss.map (·, newOrd)`, which is the
current behaviour verbatim, so no conformance verdict can move from the plumbing alone.

*New rule (this is where the semantics changes):* a base rule `timeLinearity` triggering on an
incomparable pair `(t₁, t₂)` with a common predecessor and shared world — the trigger
`orderTrichotomy` already computes and which the 2.2 deviation note documents — returning
`.branchingOrdered` with three arms:

1. `([], ord.addFuture t₁ t₂)`
2. `([], ord.addFuture t₂ t₁)`
3. the identification arm: `t₁` and `t₂` are the same instant.

`TimeOrdering` is a `List (TimeIndex × TimeIndex)` and cannot express equality, so arm 3 needs
`Branch.identifyTime (from to : TimeIndex) : Branch` (relabel every `SignedFormula` whose
`label.time = from`) plus `TimeOrdering.identifyTime`. **This machinery is already earmarked**:
plan:390–391 records the SETTLED blocking semantics as "identification/deletion, never edge", so
Phase 5.1 needs `identifyTime` regardless and the trichotomy arm reuses it.

Arm 3 cannot be dropped. `t₁ < t₂ ∨ t₁ = t₂ ∨ t₂ < t₁` is the tautology on a linear order; the
two-arm version forces distinctness and loses models in which the only witness for both
existentials is one instant.

*Relationship to `orderTrichotomy`.* Keep it. It is sound (it branches on `temp_linearity`
instances, `Axiom` BX11) and it fixed counterexample B. It simply does not deliver totality —
its disjuncts create *fresh* witness times rather than ordering the two existing ones, which is
why W1 above stays incomparable even though the rule is present. `timeLinearity` is the
order-level companion, not a replacement, and both can coexist because they emit different things
(formulas vs. ordering constraints).

*Staging gate (cheap, land it first).* Add a decidable predicate and pin it in the corpus, so the
change is measurable before it is made:

```lean
def timeOrderTotal (b : Branch) (ord : TimeOrdering) : Bool :=
  b.knownTimes.all fun t₁ => b.knownTimes.all fun t₂ =>
    t₁ == t₂ || (ord.futureOf t₁).contains t₂ || (ord.futureOf t₂).contains t₁
```

`probe2.lean` is exactly this predicate; pinning it as `#guard_msgs` rows for W1–W7 gives the
implementer a regression signal for `timeLinearity` and an unambiguous done-criterion for the
new sub-phase (every open certificate in the corpus satisfies `timeOrderTotal`).

*Downstream impact.*

- **Phase 5.1** — rewritten. `BranchOrder b ord : LinearOrder (Fin n)` becomes constructible,
  with `timeOrderTotal` as the hypothesis and the `hasOpen` certificate carrying it. `n` must be
  taken over the times appearing in `ord` **union** `b.knownTimes` unless change (b) of Q1 lands
  first (§Q2.2).
- **Phase 5.2** — unchanged. The carrier/embedding work is independent of how totality arrives.
- **Phase 6** — unchanged in statement; the interval-interpolation argument is the reason
  totality is needed at all, so it gets its premise rather than losing one.
- **Phase 7.1** — `not_valid_of_hasOpen` consumes `timeOrderTotal` from the certificate. The
  blocked-branch case (§Q3.4) is the other new hypothesis it must handle.
- **Phase 3** — `TableauRule` gains one constructor (35, not 34); `RuleSpec.lean`'s
  `ruleFrameClass`/`ruleAxioms` must cover `timeLinearity` and gate it to `.Base` with
  `Axiom.temp_linearity`, same as `orderTrichotomy`.
- **Phase 4.1** — `applyRule_subformula_closed` gains one case; `timeLinearity` emits **no
  formulas** in arms 1 and 2 and only relabels in arm 3, so the subformula-closure case is
  trivial. Arm 3's relabelling must be shown label-only.

---

## Q3 — the unowned seriality defect

### Q3.1 The gap, stated precisely

`Axiom.serial_future : ⊤ → F⊤` and `Axiom.serial_past : ⊤ → P⊤` (`Axioms.lean:113, 117`) are
axioms of TM, so all five conformance rows `S1`–`S5` and the whole `F q → Fᵏ⊤` family are
theorems. The corpus records all of them as `[DEFECT] OPEN`
(`TableauConformance.lean:350–361`, and identically in the `.Dense`/`.Discrete`/`.Dedekind`
tables). The reason is stated in the row note and is correct: the calculus has no rule that
manufactures a successor time from nothing. `someFutureNeg` propagates `F(⊤)` to *known* future
times (`Tableau.lean:649–657`), and at the root there are none.

### Q3.2 Confirmation that this is the *only* missing machinery

Measured (`probe1.lean` Q3 block, `.Base`, fuel 200): supplying the seriality instance as an
explicit premise closes every row without any change to the engine.

| row | bare formula | with the seriality instance as a premise |
|---|---|---|
| S1 | `F⊤` — OPEN | `F⊤ → F⊤` — CLOSED |
| S2 | `¬G⊥` — OPEN | `F⊤ → ¬G⊥` — **CLOSED** |
| S3 | `G p → F p` — OPEN | `F⊤ → (G p → F p)` — **CLOSED** |
| S4 | `H p → P p` — OPEN | `P⊤ → (H p → P p)` — **CLOSED** |
| K2 | `F q → F²⊤` — OPEN | `G(F⊤) → (F q → F²⊤)` — **CLOSED** |

Every other rule the closures need — propagation, witness creation, closure detection — is
present and works. K2's premise being `G(F⊤)` rather than `F⊤` is the measured proof that the
rule must fire at **every** label on the branch, not only at the root.

### Q3.3 The rule

```lean
/-- Seriality (BX1/BX1'). At any label, add `T(F ⊤)` and `T(P ⊤)` — the tableau images of
`Axiom.serial_future` and `Axiom.serial_past`. Persistent; self-suppressing once both are on
the branch at that label. Base rule: both are base axioms, so this is sound for every frame
class. -/
| serialityRule
```

`isApplicable .serialityRule _ _ = true` (it is keyed on the *label*, not on the formula's
shape), and

```lean
| .serialityRule, _, _ =>
    let outs := [SignedFormula.pos (Formula.someFuture Formula.top) l,
                 SignedFormula.pos (Formula.somePast   Formula.top) l].filter
                  fun f => !branch.contains f
    if outs.isEmpty then (.notApplicable, timeOrd) else (.persistent outs, timeOrd)
```

Soundness is immediate from the two axioms; `⊤ → X` with `⊤` a theorem gives `X` at every label,
so adding `T(F⊤)`/`T(P⊤)` preserves satisfiability in both directions.

### Q3.4 Scheduling is the whole difficulty, and it is now pinned by measurement

`serialityRule` applies to *every* signed formula, and `findUnexpanded` returns the **first
formula in the branch for which any rule applies** (`Tableau.lean:1332–1334`). Placing the rule
last in `allRulesForFC` is therefore **not** enough: if the first formula in the branch happens to
have no other applicable rule, seriality fires there while real work is still pending further
down the branch, mints a time, and the resulting serial chain trips `findBlockedTime` before the
closure is found.

Measured (`probe3.lean`, `.Base`, prototype with the Q1 engine + seriality):

| scheduling | fuel | result |
|---|---|---|
| last **per formula** (last in `allRulesForFC`) | 300 | `C5 G-K-dist`, `A G p → GG p`, `S4` all regress to open |
| last **per formula** | 3000 | same three still open — not a fuel artefact |
| last **globally** (fire only when no other formula on the branch has any applicable rule) | 3000 | **24/24 rows hit target** |
| last **globally** | 200 | **24/24 rows hit target** |

Globally-last scheduling is a small, local change to `expandOnce`: try
`findUnexpanded`/`findApplicableRule` over the ordinary rule set first, and only if that returns
`none` retry with `serialityRule` enabled. The prototype form is `probe3.lean:133–145`:

```lean
let pick :=
  match findUnexpanded b ord fc with            -- ordinary rules only
  | some sf => findApplicableRule sf b ord fc
  | none    => match findUnexpandedSerial b ord fc with
               | some sf => findApplicableRuleSerial sf b ord fc
               | none    => none
```

The cleanest implementation is to keep `serialityRule` **out of `allRulesForFC`** entirely and
give `expandOnce` this explicit two-stage pick, so the rule cannot be scheduled wrongly by a
future edit to the priority list. (Contrast with the Dedekind rules, which were *prepended* for
the opposite reason — `Tableau.lean:1295–1301`. Both lessons are about scheduling, in opposite
directions, and both deserve the in-code note.)

### Q3.5 Termination interaction with blocking

The chain is real and bounded: `T(F⊤)@t` ⟶ `someFuturePos` mints `t'` with `T(⊤)@t'` ⟶ seriality
at `t'` ⟶ `t''` … Each new time carries the same type `{T(⊤), T(F⊤), T(P⊤)}` plus whatever
universals propagate, so `Branch.isSubsetBlocked` fires within two or three steps and
`findBlockedTime` (`SignedFormula.lean:844–846`) halts the branch. That is exactly what the
measurement shows: with seriality on, **every** genuinely-open row terminates as `OPEN-blocked`
rather than `OPEN-sat`, at every fuel and in every frame class tested.

**This is the one consequence the plan must absorb.** After `serialityRule` lands, no open branch
is ever fully saturated in the `findUnexpanded = none` sense — seriality always has one more
successor to demand. The certificate must therefore be

```lean
saturated : findUnexpanded openBranch (timeOrd := timeOrdering) (fc := fc) = none
            ∨ (findBlockedTime openBranch timeOrdering tracker).isSome
```

and Phase 7.1's truth lemma must handle the blocked disjunct by the loop-unwinding /
identification semantics the plan already SETTLED at plan:390–391. This is the standard shape for
eventuality tableaux over serial time and is not a new obligation in kind — but it *is* now
unavoidable rather than optional, and Phase 7.1's estimate should reflect it.

Two caveats on the measurement, stated plainly:

- The prototype does **not** implement `buildTableau`'s `saturateBlocked` post-pass
  (`Saturation.lean:669–678`). CLOSED results are conclusive (a closure found by the real
  `findClosure` on a branch built by the real `applyRule` is a real closure); `OPEN-blocked`
  results are **not** conclusive, since the post-pass could still close them. The three rows that
  regressed under per-formula-last scheduling recovered entirely under globally-last scheduling,
  so no such row remains at `.Base` — but the implementer must re-measure with the post-pass in.
- At `.Discrete`, `K2` and `K3` remain `OPEN-blocked` at fuel 1000 in the prototype while closing
  in all three other classes. `priorUZ` emits `T(U(φ, ¬φ))` (`Tableau.lean:1096–1102`), which
  interacts with the serial chain. This is the one row-pair the sub-phase must chase; it is a
  `.Discrete`-only residual, not a base-calculus problem.

### Q3.6 Rows that must flip

All four class tables (`TableauConformance.lean:350–361` for `.Base`, and the `.Dense` /
`.Discrete` / `.Dedekind` repetitions at `:380–391`, `:410–421`, `:442–453`):

| row | id | from | to |
|---|---|---|---|
| `F⊤` | `S1 F-top` | OPEN `[DEFECT]` | CLOSED |
| `¬G⊥` | `S2 not-G-bot` | OPEN `[DEFECT]` | CLOSED |
| `G p → F p` | `S3 Gp->Fp` | OPEN `[DEFECT]` | CLOSED |
| `H p → P p` | `S4 Hp->Pp` | OPEN `[DEFECT]` | CLOSED |
| `P⊤` | `S5 P-top` | OPEN `[DEFECT]` | CLOSED |
| `F q → Fᵏ⊤`, `k = 2 … 6` | `K2`–`K6` | OPEN `[DEFECT]` | CLOSED |

That is 10 rows per class table, 40 across the corpus, and it removes every remaining `[DEFECT]`
marker from the seriality and series families. No control row may move; `C1`–`C6`, `D4`, `K0`,
`K1` and counterexample `A` were all measured holding under the globally-last design at fuel 200.

### Q3.7 Which phase owns it

**Phase 2**, as a new sub-phase. The plan's territory contract (plan:205–209) requires all engine
edits to complete in waves 1–2, and `serialityRule` is a rule addition in `Tableau.lean` —
squarely Phase 2's theme and territory. Assigning it to Phase 7 (where it would first *bite*) or
to Phase 3 (which owns only `Verified/RuleSpec.lean`) would break the contract.

---

## Adversarial Self-Verification

Every load-bearing claim above was re-derived against source or re-measured. Contradictions with
the incoming handoff are logged separately below.

| Claim | Source/Counterexample | Verdict |
|---|---|---|
| `AppliedRedundant` is false on pipeline output, not merely unproved | `probe1.lean` Q1 block, `.Base` fuel 200: `◇(p ∧ q)` `redundant=false`; `◇◇p` `false`; `◇¬¬p` `false`; `◇(□(p∧q) ∧ ¬p)` `false` — against `Saturation.lean:139–141` | CONFIRMED — measured `#eval`, four independent witnesses |
| The failure is a two-level decomposition, not a one-off | `probe3.lean` Part A: for `◇(p∧q)` the non-redundant entry's rule is `negPos` and its output `F(p → ¬q)` is itself absent from the branch; `appliedEntryRedundant` (`Saturation.lean:122–129`) is one-step by construction | CONFIRMED — diagnostic printout |
| Handoff claim "several persistent rules return `.persistent fs` when all of `fs` is on the branch" | All 13 `.persistent` sites checked: `Tableau.lean:426–427, 524–525, 533–534, 542–543, 582–583, 656–657, 700–701, 1099–1102, 1109–1112, 1126–1129, 1145–1148, 1161–1164, 1181–1184` each guarded; the sole unguarded one (`1091`, `densityRule`) emits at a fresh time | **REFUTED** — see Contradiction Log C1 |
| `untlNeg`/`snceNeg` are already non-destructive and self-guarded | `Tableau.lean:800, 874`; `unprocessed` filter at `805–808`; source `sf` re-included in every arm at `855–856, 865` | CONFIRMED — in-repo precedent for change (b) |
| The real cycle driver is source destruction | `Tableau.lean:1365, 1369` (`expandOnce`) and `1428, 1431` (`expandOnceWithApplied`): `remaining := b.filter (· != sf)` | CONFIRMED — source-cited |
| Applied entries are exactly the formulas prepended to the branch at insertion time | `Tableau.lean:1396` returns `newFormulas` as the applied delta; `Tableau.lean:1433–1434` prepends the same `newFormulas`. So `applied' ⊆ newBranch` holds *at insertion* and is broken only later, by destruction | CONFIRMED — source-cited; explains why orphans are the *only* failure mode |
| A recursive/transitive strengthening of `appliedEntryRedundant` also fails | `findApplicableRule`'s `.persistent` output set is branch-dependent (`Tableau.lean:539–541`, `422–425`: outputs range over `futureOf`/`knownWorlds`), so the predicate is not monotone in `b` and the growing-branch induction step fails | CONFIRMED — source-derived; not separately measured (flagged Medium) |
| Non-destructive + guarded engine reproduces all verdicts and reaches real saturation | `probe3.lean` column `protoNoSerial`, `.Base` fuel 300, 24 rows: every verdict matches the current engine; every open row reports `OPEN-sat` (`findUnexpanded' = none`), none `OPEN-blocked` | CONFIRMED — measured |
| `hasOpen`'s saturation field is frame-class blind | `Saturation.lean:56–59` omits `fc`; `findUnexpandedWithApplied`'s default is `.Base` (`Tableau.lean:1408–1411`); the two `buildTableau` sites (`Saturation.lean:667, 676`) and `BranchListResult.foundOpen` (`155–158`) also omit it | CONFIRMED as a type-level fact; **latent** — probe G over 6 formulas at `.Discrete`/`.Dedekind` found no divergence yet (Medium confidence that it can produce one) |
| `applyRule` returns one `TimeOrdering` for all branches of a split | `Tableau.lean:380–381` signature; `ExpansionResult.split (branches : List Branch)` `1345`; `RuleResult.branching (branches : List (List SignedFormula))` `179`; `Saturation.lean:375` passes the same `newOrd` to every sub-branch | CONFIRMED — four independent source sites |
| A saturated open branch can carry incomparable times | `probe2.lean`: `¬(F(G p) ∧ F(¬p))`, `¬(F p ∧ F q)`, `¬(F(G p) ∧ F(G q))`, `¬(F(¬p) ∧ F(G p))` each give `incomparable=[(1,2)]` at fuel 200 **and** 2000 | CONFIRMED — measured, fuel-insensitive |
| `orderTrichotomy` does not remove incomparability | Same measurement; the rule is in `allRulesForFC .Base` (landed 2.2) yet the pairs persist. Mechanism: its arms are `temp_linearity` *formulas* (`Tableau.lean:126–132`), which mint fresh witness times rather than ordering `t₁`,`t₂` | CONFIRMED — measured + source |
| The order induced on `knownTimes` can be empty though constraints exist | `probe2.lean` W1: `knownTimes=[2,1]`, `constraints=[(0,2),(0,1)]` — time `0` is not in `knownTimes` (`SignedFormula.lean:349`) | CONFIRMED — measured; breaks plan:388–390's `n = b.knownTimes.length` |
| Arbitrary linear extension of the branch order is unsound | W1: the two incomparable siblings carry `T(G p)` and `F(p)`; the extension placing the `G p` time first forces `p` true where the branch asserts `F(p)`. The formula is satisfiable, so exactly one of the two extensions is a model and the branch does not record which | CONFIRMED — argued from the measured branch content; the killer for `extend_partialOrder` |
| Supplying the seriality instance as a premise closes S1–S4 and K2 | `probe1.lean` Q3 block: `F⊤→F⊤`, `F⊤→¬G⊥`, `F⊤→(Gp→Fp)`, `P⊤→(Hp→Pp)`, `G(F⊤)→(Fq→F²⊤)` all CLOSED with the unmodified engine | CONFIRMED — measured |
| K2 needs the instance at *every* label, not just the root | Same block: `(F⊤ ∧ G(F⊤)) → (F q → F²⊤)` STALLED, but `G(F⊤) → (F q → F²⊤)` CLOSED | CONFIRMED — measured |
| Seriality must be scheduled globally last, not per formula | `probe3.lean`: per-formula-last leaves `C5`, `A`, `S4` open at fuel 300 **and** 3000; globally-last gives 24/24 at fuel 3000 **and** 200 | CONFIRMED — measured, with the fuel confound eliminated |
| Seriality needs no corpus fuel increase | `probe3.lean` block E: all 12 CLOSED targets close at fuel 200, the corpus's existing `conformanceFuel` (`TableauConformance.lean:118`) | CONFIRMED — measured |
| Seriality makes every open branch terminate blocked rather than saturated | `probe3.lean` blocks D/E/F: every OPEN-target row reports `OPEN-blocked` at fuel 200, 500, 1000, 3000 and in all four frame classes | CONFIRMED — measured; drives the Phase 7.1 hypothesis change |
| `.Discrete` `K2`/`K3` are a residual | `probe3.lean` block F, fuel 1000: `Dense=CLOSED`, `Dedekind=CLOSED`, `Discrete=OPEN-blocked`; `priorUZ` emits `T(U(φ,¬φ))` (`Tableau.lean:1096–1102`) | CONFIRMED as measured; **cause is Low confidence** — attributed to `priorUZ` by inspection, not isolated |
| `OPEN-blocked` prototype results are not conclusive | The prototype omits `buildTableau`'s `saturateBlocked` post-pass (`Saturation.lean:669–678`), which can still close a blocked branch | CONFIRMED — stated as a limitation, not worked around |
| `serialityRule` is sound | `Axiom.serial_future` / `Axiom.serial_past` at `Axioms.lean:113, 117` are axioms with antecedent `⊤`; adding their consequents at any label preserves satisfiability both ways | CONFIRMED — source-cited |
| Phase 2 owns the seriality rule | Territory contract plan:205–209 ("all engine edits complete in waves 1-2"); Phase 3 owns only `Verified/RuleSpec.lean` (plan:351) | CONFIRMED — plan-cited |

### Contradiction Log

**C1 — handoff vs. source, on the R5 obstruction.** The handoff (`.orchestrator-handoff.json`,
`blockers[0].what_failed`) and plan:310–312 assert that "several persistent rules return
`.persistent fs` even when every element of `fs` is already on the branch, so
`findApplicableRule` still finds them". Direct inspection of all thirteen `.persistent` return
sites contradicts this. **Resolution: source wins** (precedence: executable/inspected source over
a prose summary). The claim is not merely imprecise — acting on it points the repair at the
persistent rules, where nothing is wrong, instead of at the destructive arms, where the fix is.
The consequence is that the plan's proposed 2.5 sub-phase is aimed at a false statement, which is
why this report replaces it rather than scheduling it.

**C2 — plan vs. measurement, on `AppliedRedundant`.** Plan:325–330 records
`AppliedRedundant` as demonstrated true on the pipeline's output and describes proving it
invariant as "the remaining half of R5". Measurement finds it false on four formulas.
**Resolution: measurement wins**; the `◇p` witness on which the claim was based is
unrepresentative (its three orphans are all one `negPos` step from the branch, so the one-step
predicate happens to succeed). The two `#guard_msgs` probes landed at
`TableauConformance.lean:648–656` remain correct as measurements of `◇p` and `G p → p`
specifically; they simply do not generalise, and the sub-phase that replaces 2.4 should extend
them with the four failing formulas so the corpus records the refutation.

**No unresolved contradictions.**

### Recommendations modified after verification

- The initial working hypothesis was that the fix belonged in the persistent rules (following the
  handoff). Reading all thirteen `.persistent` sites inverted it: the fix belongs in the
  destructive arms. §Q1.4 is the rewritten recommendation.
- An earlier candidate for Q2 was "partial order + Mathlib `extend_partialOrder`", which is the
  cheapest option by a wide margin. It was **withdrawn** after W1's branch content showed it
  unsound; §Q2.3 now records it as a route the next dispatch must not take.
- The seriality rule was first prototyped at the *head* of the priority list (by analogy with the
  Dedekind prepend lesson at `Tableau.lean:1295–1301`) and produced a wholesale regression —
  even `p → p` failed to close. It was then moved to per-formula-last (three rows still
  regressed) and finally to globally-last (24/24). Only the last of the three is recommended.

---

## Recommended plan delta

Everything below is inside Phase 2's existing territory (engine files) except where noted, so the
wave structure at plan:196–209 is unchanged. Four sub-phases are added, one is restated, two
later phases change.

### Phase 2 — restated and extended

**2.4 R5 — certificate strengthening** — *restate the task*. Replace the current text and its
`**BLOCKER**` block with: strengthen `ExpandedTableau.hasOpen` to carry `(fc : FrameClass)` and
the proposition `findUnexpanded openBranch (timeOrd := timeOrdering) (fc := fc) = none ∨
(findBlockedTime openBranch timeOrdering tracker).isSome`; delete the applied set from the
certificate. Depends on 2.5 and 2.6. Keep the "Certificate Strength (R5)" section in
`Saturation.lean:76–113` but rewrite it: record that `AppliedRedundant` was *refuted*, cite the
four failing formulas, and record the corrected diagnosis (destruction, not persistent-rule
re-firing). Retire `appliedEntryRedundant`/`AppliedRedundant` or demote them to documented
historical predicates — nothing may depend on them.

**2.5 (new) — branch-guarded non-destructive expansion.** `Tableau.lean` only.
Add `ruleMintsFreshLabel` and `witnessPresent` (8 arms); guard the `.linear` and `.branching`
results in `findApplicableRule` (`1308–1317`) exactly as the `.persistent` arms already guard
themselves; make `expandOnce` non-destructive (`remaining := b`, lines `1365, 1369`). Delete or
demote the `…WithApplied` family (`1376–1435`) and drop `applied` threading from
`expandBranchWithFuel` (`Saturation.lean:310–381`), the traced mirrors (`417–535`) and
`CancellableExpansion.lean`. Prove `saturated_downward_closed` and `expandOnce_length_lt` (§Q1.4).
Estimated output ~250–400 lines. **Done when**: the full corpus is unmoved (all 24 measured rows
plus the existing `#guard_msgs` tables), every open certificate reports
`findUnexpanded … = none`, `lake build` and `lake build BimodalTest` green.

**2.6 (new) — `serialityRule` with globally-last scheduling.** `Tableau.lean` +
`Saturation.lean`. Add the `serialityRule` constructor, its `isApplicable` and `applyRule` arms
(§Q3.3); keep it **out** of `allRulesForFC` and give `expandOnce` the two-stage pick (§Q3.4),
with an in-code note contrasting it against the Dedekind prepend. Estimated output ~150–250
lines. **Done when**: `S1`–`S5` and `K2`–`K6` are CLOSED in all four class tables at
`conformanceFuel = 200`; every control row and counterexample `A`/`B` holds; the `.Discrete`
`K2`/`K3` residual (§Q3.5) is either closed or documented with its cause isolated.
**Depends on 2.5** (the prototype that produced 24/24 has both changes; seriality on the
destructive engine was not measured and should not be attempted separately).

**2.7 (new) — per-branch time orderings + `timeLinearity`.** `Tableau.lean` + `Saturation.lean` +
`CancellableExpansion.lean`. Additive `RuleResult.branchingOrdered` and
`ExpansionResult.split (List (Branch × TimeOrdering))`; plumbing per the table in §Q2.4;
`Branch.identifyTime` / `TimeOrdering.identifyTime`; the `timeLinearity` base rule with three
arms. Keep `orderTrichotomy`. Estimated output ~300–450 lines — split into 2.7a (plumbing, zero
verdict movement, provable by re-running the corpus) and 2.7b (the rule) if one dispatch is not
enough. **Done when**: `timeOrderTotal` holds of every open certificate in the corpus; W1–W7 are
pinned as `#guard_msgs` rows; no verdict moves except intended ones.

**2.8 (new, cheap — land before 2.7) — the `timeOrderTotal` gate.** Add the decidable predicate
(§Q2.4) and pin W1–W7 in the corpus as currently-failing rows, so 2.7 has a measurable
done-criterion and the regression signal exists before the change. ~60–100 lines, `Saturation.lean`
+ `TableauConformance.lean`.

**Phase 2 timing** becomes ~8 dispatches. Order: 2.8 → 2.5 → 2.6 → 2.7 → 2.4.

### Phase 3 — one line

`TableauRule` will have **36** constructors after 2.6 and 2.7 (34 today + `serialityRule` +
`timeLinearity`), not 34. `RuleSpec.lean` gates both to `.Base`: `serialityRule` to
`Axiom.serial_future`/`Axiom.serial_past`, `timeLinearity` to `Axiom.temp_linearity` (same as
`orderTrichotomy`). Because `serialityRule` is deliberately *not* in `allRulesForFC`,
`mem_allRulesForFC_iff` needs an explicit exclusion clause for it — record this, or the `by
decide` gate will fail confusingly.

### Phase 4 — unchanged in scope, easier in substance

4.1 gains two mechanical cases (`serialityRule` emits `F⊤`/`P⊤`, which must be in the signed
closure — note that `⊤ = ⊥ → ⊥`, so `closureWithNeg` already contains it; `timeLinearity` emits no
formulas). 4.3's `buildTableau_isSome` now has `expandOnce_length_lt` from 2.5 as a genuine
progress measure on a monotone branch, which is a materially simpler argument than the current
fuel-only one.

### Phase 5.1 — rewritten

Replace "from a saturated branch (trichotomy now guarantees totality)" with: *from a saturated
branch carrying `timeOrderTotal` (delivered by `timeLinearity`, 2.7)*. Index `Fin n` over the
times occurring in `ord` **union** `b.knownTimes` — or note that 2.5's non-destructive expansion
keeps the root in `knownTimes` and makes the simple indexing correct (§Q2.2). Add an explicit
non-goal: **do not** attempt a Mathlib linear extension of a partial branch order; §Q2.3 records
the counterexample. Keep the identification/deletion blocking-semantics note — `identifyTime`
now arrives from 2.7 and is shared.

### Phase 7.1 — hypothesis change

`not_valid_of_hasOpen` consumes the restated certificate: `fc`-indexed saturation **or** blocked,
plus `timeOrderTotal`. The blocked disjunct is now the *normal* case for open branches
(§Q3.5), so the loop-unwinding/identification argument is on the critical path rather than a
corner case; budget for it accordingly (the plan's ~250–450 line estimate for 7.1 should be read
as a floor). No change to 7.2 or 7.3 beyond the constructor count.

### Phase 8 — unchanged.

---

## Artifacts

- Report: `specs/165_establish_semantic_finite_model_property/reports/04_blocker-resolution-r5-branchorder-seriality.md`
- Probe sources (session scratchpad, not part of the repository):
  `probe1.lean` (R5 robustness sweep, seriality-premise probes), `probe2.lean` (incomparable-time
  measurement), `probe3.lean` (redundancy diagnostic, prototype engine, corpus comparison, fuel
  sensitivity, frame-class sweep, certificate frame-class probe)
