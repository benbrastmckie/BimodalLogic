# The `haux` census inside the time sweep

Task 483, Phase 1. Every declaration re-located by name, not by line number.

## Declarations re-located

| Declaration | File | Line (at commit f0fc2855f) |
|---|---|---|
| `mem_knownTimes_of_mem_pastOf` | MintBound.lean | 6671 |
| `mem_filterMap_futureOf_time` | MintBound.lean | 6699 |
| `mem_filterMap_pastOf_time` | MintBound.lean | 6709 |
| `applyRule_orderTrichotomy_emitted_time` | MintBound.lean | 6851 |
| `applyRule_emitted_time_mem` | MintBound.lean | 6887 |
| `applyRule_emitted_time_mem_ordTimesKnown_needed` | MintBound.lean | 6993 |
| `untlSnceFree` + six `as…_eq_none_of_untlSnceFree` views | MintBound.lean § D3 | 12630–12678 |
| `pickBranches_knownTimes_subset` (private) | MintBound.lean | 12788 |
| `unorderedSuccessor_knownTimes_subset` | MintBound.lean | 12813 |
| `applyRule` | Tableau.lean | 755 (`.allFuturePos` arm) etc. |

## `haux` occurrence census — mechanical, complete

Counted by extracting the text between `theorem applyRule_orderTrichotomy_emitted_time` and
`theorem applyRule_emitted_timeFinset_mem` and listing every line containing `haux`. Six lines,
two of which are the binder in each theorem's own signature. Four *uses*:

| # | Site | Closer family |
|---|---|---|
| 1 | `applyRule_orderTrichotomy_emitted_time` body | `mem_knownTimes_of_mem_pastOf haux` |
| 2 | `applyRule_emitted_time_mem`, `first`-alternative 2 | `applyRule_orderTrichotomy_emitted_time hsf haux` (delegation, resolves to #1) |
| 3 | `applyRule_emitted_time_mem`, sweep alternative | `mem_filterMap_futureOf_time haux` |
| 4 | `applyRule_emitted_time_mem`, sweep alternative | `mem_filterMap_pastOf_time haux` |

**Exactly three closer families**, as the plan's scope hypothesis asserted. No fourth family.
No `haux` occurs anywhere else between the two theorems.

## Per-arm exclusion table

| Arm | `haux` closer | `applyRule` gate | Excluding fact | Status |
|---|---|---|---|---|
| `.allFuturePos` | `mem_filterMap_futureOf_time haux` | **raw constructor pattern** `\| .allFuturePos, .pos, .allFuture ψ` (Tableau.lean:755); `Formula.allFuture ψ = .imp (.untl (.imp .bot .bot) (.imp ψ .bot)) .bot` | trigger `untlSnceFree` forces the fall-through catch-all `\| _, _, _ => (.notApplicable, timeOrd)` | excluded by `untlSnceFree` |
| `.allPastPos` | `mem_filterMap_pastOf_time haux` | **raw constructor pattern** `\| .allPastPos, .pos, .allPast ψ` (Tableau.lean:795); `allPast` is the `snce` mirror | same, via `snce` | excluded by `untlSnceFree` |
| `.someFutureNeg` | `mem_filterMap_futureOf_time haux` | **`as…?` view**: `\| .someFutureNeg, .neg, φ => match asSomeFuture? φ with …` (Tableau.lean:867) | `asSomeFuture_eq_none_of_untlSnceFree` ⇒ `none` ⇒ `.notApplicable` | excluded by `untlSnceFree` |
| `.somePastNeg` | `mem_filterMap_pastOf_time haux` | **`as…?` view**: `\| .somePastNeg, .neg, φ => match asSomePast? φ with …` (Tableau.lean:911) | `asSomePast_eq_none_of_untlSnceFree` ⇒ `none` ⇒ `.notApplicable` | excluded by `untlSnceFree` |
| `.orderTrichotomy` | `mem_knownTimes_of_mem_pastOf haux` (via `applyRule_orderTrichotomy_emitted_time`) | **branch-level guard**: `fires`'s final conjunct is `ds.any fun d => branch.contains (SignedFormula.neg d l0)` where `ds = disjuncts φ ψ` and every `d` is `Formula.someFuture (…) = Formula.untl Formula.top (…)` (Tableau.lean:1291, 1329) | a branch all of whose formulas are `untlSnceFree` carries no `untl`-headed formula, so `branch.contains (.neg d l0) = false` for every candidate ⇒ `candidates.find? fires = none` ⇒ `.notApplicable` | excluded by `untlSnceFree`, **branch-level** |

## `disjuncts` shape confirmed

`disjuncts x y = [someFuture (and x y), someFuture (and x (someFuture y)), someFuture (and (someFuture x) y)]`
(Tableau.lean:1291–1294). `Formula.someFuture φ = Formula.untl Formula.top φ`
(Syntax/Formula.lean:147). So every member of `disjuncts φ ψ` is `untl`-headed and
`untlSnceFree d = false` for all three, unconditionally in `φ`, `ψ`.

## No sixth arm reads a time off the ordering

This is established by compilation, not by reading. `applyRule_emitted_time_mem`'s proof consumes
`haux` at exactly the four sites above; every other arm of the twenty-seven non-minting
constructors is closed by a `haux`-free alternative in the same `first` chain
(`mem_knownTimes_of_mem`, `mem_filterMap_const_time_mem`, `mem_filterMap_time`,
`mem_identifyTime_time_at_trigger{,_oriented}`). The rules the plan named for explicit check —
`serialityRule` (Tableau.lean:1492, emits at `l` itself), `timeLinearity` (closed by the two
`identifyTime_at_trigger` bridges), `boxTemporal`, `denseIndicatorClosure` (emits `.linear []`),
`priorUZ`/`priorSZ`/`z1Rule`, `priorUGap`/`priorSGap`/`sepRule`, and the
`boxPos`/`diamondNeg`/`boxNeg`/`diamondPos` world family — are therefore all already
`OrdTimesKnown`-free in the landed proof. The docstring's claim is corroborated by the existing
proof term rather than trusted.

## Verdict

All five `haux`-consuming arms are marked *excluded by `untlSnceFree`*. No arm is marked
*not excluded*. `boxFree` is **not** required for the time coordinate — confirming the plan's
first correction. Four exclusions are trigger-level; `.orderTrichotomy` is branch-level, confirming
the plan's second correction.

Route 1 proceeds to Phase 2.
