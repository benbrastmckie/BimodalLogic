# Implementation summary — plan v4, `OrdTimesKnown` strengthening and engine totality

**Plan**: `plans/04_ordtimesknown-strengthening-totality.md`
**Phases**: 17 of 17 `[COMPLETED]`. No phase `[BLOCKED]`.
**Status**: partial — every phase closed and the module green, sorry-free and axiom-free, but the
terminus carries **four named residual hypotheses** and two of the plan's premises did not survive
contact with the source. Both are recorded below and in-source.

## What was built

A single file changed across the whole task: `MintBound.lean`, 1791 → 4512 lines, purely additive.
`Saturation.lean`, `Tableau.lean` and `Fuel.lean` are byte-identical to their pre-task form,
verified by md5 at every phase end.

The terminus is `buildTableauAt_isSome_of_budget`: for a formula `phi`, a frame class `fc`, and a
quantified branch budget, `buildTableauAt` does not report `none` at the derived fuel figure. It
carries no unbranching restriction under any spelling, no undischarged mint bound, and no
`RunInvariant` — that is discharged inside via `runInvariant_initial`, vacuously at
`TimeOrdering.empty`, which is a property of the engine's seed rather than of a narrowed statement.
`buildTableauAt_isSome_at_seed` is the caller-facing form with the mint budget, the time bound and
the branch budget all read off rather than left as obligations.

The route there, in the order the plan laid it out:

* `IrreflOrd` and `OrdTimesKnown` as run invariants across all four result shapes, with the ordered
  split's identification arm supplied by `ordTimesKnown_identifyTime` — the repair for a
  **refuted** `OrdTimesLeMaxTime` preservation, and a strengthening rather than a weakening
  (`ordTimesLeMaxTime_of_ordTimesKnown`).
* The reachability transport stack and witness preservation, including `arm3_preserves_witness`.
* The world dimension and an independent `Tmax` that does not go through the mint chain.
* `mintPotential`, carrying the accumulated renaming `σ` as an explicit parameter so that the index
  set is fixed for the whole run and both step shapes are pointwise subset facts needing no
  injection; `mints_le_eight_mul` composes them over an arbitrary run.
* The once-only bound: the guard before a mint and the witness after one, over all eight
  fresh-label rules, both arms of each branching rule proved individually.
* The counting chain — identifications, shrinkage, extensions — as folds of one lemma in additive
  form, with `Tmax` **derived** (`derivedTmax`, `derivedTmax_spec`) rather than assumed.
* `expandBranchWithFuel_isSome_of_measure`: the fuel induction, free of the unbranching
  restriction, over an abstract carried state, measure and invariant. All four `ExpansionResult`
  shapes discharged; both split folds consumed as the plan specified. This is the piece
  `Fuel.lean`'s "MEASURED OBSTRUCTION" note left open.
* `budgetPotential`, the concrete measure that breaks the recorded circularity: the mint dimension
  pays for the ordered rank's rise at a mint, and `extensionAllowance` absorbs the identification
  arm's branch shrinkage instead of re-opening it.
* The branching non-vacuity witness at `T(p → q)`, decided rather than asserted.
* The do-not-re-attempt register, eight entries.

## For the consuming task

The replacement for the refuted `buildTableau_isSome` is against **`buildTableauAt` /
`BudgetedTableau`**, not `buildTableau` / `ExpandedTableau`. It carries a quantified branch budget,
the derived fuel figure `mintAwareFuel`, and the four residuals listed below. `buildTableau`, its
`fuel := 1000` default, and `expandBranchWithFuel`'s `maxBranches := 50000` default are untouched.

## Residuals carried (all named in-source, none an axiom, none a `sorry`)

1. **`MintPaysForTime`** — the open mathematical core, two obligations in one predicate: the
   σ-hit/time-reuse question (a fresh time can in principle re-issue a value an earlier
   identification retired, because `Branch.nextTime = maxTime + 1` and `identifyTime` can lower
   `maxTime`), and the finding that "not `ruleMintsFreshLabel` implies no new time" is **false** —
   `densityRule` and the active arms of `untlNeg`/`snceNeg` create times without being
   witness-guarded, which is why `expandOnceNoFresh` tests the ordering length rather than the rule
   list.
2. **`PostBlockingSettles`** — the post-blocking pass leaves a blocking-aware saturated branch.
   Covers both `resolveOpenArm`'s `none` and `buildTableauAt`'s.
3. **`UniverseClosed`** — closure of `U` under the engine's steps and under an identification's
   relabelling.
4. **`DifficultyBounded`** with `β ≥ 3` — the two coefficients `splitAwareFuel` already documents
   as an interface, blocked from being computed here by `Saturation.lean`'s `private` counting
   functions.

## Two premises that did not survive

* **`BudgetedTotality` is false as stated** — refuted at `β = 0` by
  `budgetedTotality_beta_zero_false`, and its fuel figure is short: `splitPathBound` bounds
  `#extensions + #identifications`, but fuel is spent by every engine step, and it budgets only
  `|U|+1` branch-growing steps where shrinkage refunds admit `|U| + Tmax·|U|`. The derived figure
  `mintAwareFuel` is used, with `splitAwareFuel_le_mintAwareFuel` recording that it enlarges rather
  than replaces the landed one. This withdraws the previous cycle's "the figure fits, no divergence
  needed" finding, which compared the wrong quantity.
* **The post-blocking `none` arm was not eliminated by the certificate change** — it is still
  textually present in `buildTableauAt`. What the change removed is the *permanent* disagreement,
  not the arm.

## Plan Deviations

1. Phase 10: `mintPotential` carries `σ`; the plan's displayed shape is the `σ = id`
   specialization, which is not preserved at arm 3.
2. Phase 10: `BudgetedTotality` is a `Prop`-valued definition rather than an unproved `theorem`.
3. Phase 13: the induction is on the measure bound, not on `fuel`, and is stated over an abstract
   carried state before being instantiated at the concrete measure.
4. Phase 13: the fuel figure is the derived `mintAwareFuel`, not `splitAwareFuel`.
5. Phase 14: the terminus is at that same derived figure.
6. Phase 14: the post-blocking arm is discharged by a named residual rather than eliminated.

## Verification

`lake build` green repo-wide (2333 jobs, 3m24s wall / 17m08s user). 0 `sorry`, 0 `axiom`, 0
`NoSplit`, 0 vacuous placeholders, 0 task-number citations in `FormalSystem/`. `#print axioms` on
every headline result: exactly `[propext, Classical.choice, Quot.sound]`
(`branchingWitness_splits`, being decided, reports the subset `[propext]`). The three frozen files'
md5s match the plan's recorded baselines.
