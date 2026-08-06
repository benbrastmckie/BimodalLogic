# Continuation handoff (plan v4) — ALL 17 PHASES CLOSED; four residuals remain open

**Plan**: `plans/04_ordtimesknown-strengthening-totality.md`
**Baseline for this dispatch**: `d3a34a660`. **Head**: `4b936247e`.

This is the **only current handoff**. It supersedes `handoffs/v4-phase-13-handoff-20260805.md`.
Every other file in `handoffs/` is STALE.

## What this cycle closed

| Phase | Marker | Commit |
|---|---|---|
| 13 (the fuel induction, abstract) | sub-step | `791a666ba` |
| 13 (the measure, the derived figure, the branching witness) | `[COMPLETED]` | `1fac329aa` |
| 14 (the terminus, the register, the full gate) | `[COMPLETED]` | `4b936247e` |

**17 of 17** phase headings are now `[COMPLETED]`. No phase is `[BLOCKED]`.

## The status is `partial`, deliberately, and here is exactly why

The module is green, sorry-free, axiom-free, and every phase is closed. What is **not** true is
that the task's central theorem is unconditional. It carries **four named residual hypotheses**,
and one of them is the genuinely open mathematical core of the mint chain. Reporting
`implemented` would state that O1 is closed outright; it is closed **modulo four hypotheses**,
each named in-source with a docstring saying what would discharge it and what stands in the way.

Two further findings contradict premises the plan carried, and both are recorded in-source and
annotated on the plan's own checklist rather than absorbed.

## Finding 1 — `BudgetedTotality` is FALSE as stated, and its figure is short

* **Refuted at `β = 0`** (`budgetedTotality_beta_zero_false`, machine-checked). The `β`-linear
  budget hypothesis `branchesUsed + β · fuel ≤ maxBranches` degenerates at `β = 0` to
  `branchesUsed ≤ maxBranches`, and the engine's first line returns `none` when
  `branchesUsed ≥ maxBranches`. Taking both to be `0` satisfies every hypothesis and refutes the
  conclusion. The landed theorem therefore carries `β ≥ 3` — `≥ 1` to make the budget hypothesis
  strict, `≥ 3` to cover the measured split arity.
* **The figure is short.** Phase 12's `path_le_splitPathBound` checks
  `#extensions + #identifications` against `splitPathBound`, but **fuel is spent by every engine
  step**, including the ordered split's arms 1-2, which are counted by neither summand. Worse,
  `splitPathBound = (|U|+1)·(orderedRunBound Tmax + 1)` budgets only `|U|+1` branch-growing steps,
  whereas shrinkage refunds admit up to `|U| + Tmax·|U|`, and each of up to `8·|U|` mints resets
  the ordered rank. So the previous cycle's "the fuel figure fits, no divergence needed" is
  **withdrawn**: it compared the wrong quantity.
* The landed statements are therefore at the **derived** figure `mintAwareFuel`, with
  `splitAwareFuel_le_mintAwareFuel` proving it is an *enlargement* of the landed figure, not a
  replacement. This follows plan 02's own instruction for `orderedRunBound` (derive the value, use
  the derived one, record the divergence).

## Finding 2 — the post-blocking `none` arm was NOT eliminated by the certificate change

Phase 14's task text asserts that the blocking-aware certificate eliminates `buildTableauAt`'s
`| some _ => none  -- Still not saturated after post-blocking` arm and instructs verifying that in
the proof. Verified against the landed source: **that arm is still there**, textually, in
`Saturation.lean`'s `buildTableauAt`. What the certificate change removed is the *permanent*
disagreement — the literal test counts label-introducing work that `saturateBlocked` refuses by
construction, so it could never stop reporting it at any fuel — and the measured probes confirm the
formulas that died there now settle. It did not prove the arm unreachable.

Note also that `ArmSettlement` alone is **too weak** for the terminus: `resolveOpenArm` tests
`findClosure satBr` before its saturation test and `buildTableauAt` does not. The single residual
`PostBlockingSettles` covers both (`armSettlement_of_postBlockingSettles`), so the terminus carries
one settlement hypothesis rather than two.

## The four residuals, in the order they matter

1. **`MintPaysForTime`** — the open mathematical core. Two obligations in one predicate:
   * *the σ-hit / time-reuse question* the previous cycle handed forward. It did **not** discharge.
     `Branch.nextTime` is `maxTime + 1` and `identifyTime` can lower `maxTime`, so a fresh time can
     in principle re-issue a value an earlier identification retired; if it does, the minting pair
     is not in `σ`'s image and `mintPotential_lt_of_pick_*` do not apply. The live-times
     reformulation carries the identical obligation. Carried as a hypothesis, never assumed.
   * *a new obstruction found this cycle*: "not `ruleMintsFreshLabel` implies no new time" is
     **false** for at least three rules. `densityRule` interpolates a fresh time and is deliberately
     absent from `ruleMintsFreshLabel` (it has its own `existingIntermediates` guard), and the
     active-mode arms of `untlNeg`/`snceNeg` introduce times without being witness-guarded.
     `expandOnceNoFresh` rejects exactly those three by testing `newOrd.constraints.length` rather
     than the rule list — in-repo evidence that the rule-list reading is the wrong one. Discharging
     this needs a time-dimension analogue of `applyRule_emitted_world_mem`, keyed on the
     ordering-length test rather than on `ruleMintsFreshLabel`.
2. **`PostBlockingSettles`** — finding 2 above. Closing it means comparing two blocked sets (the
   engine's threaded tracker vs `armTracker`'s recomputation), not adding fuel.
3. **`UniverseClosed`** — closure of `U` under the engine's steps *and* under an identification's
   relabelling. The second clause is genuinely new: arm 3 relabels the branch, so confinement
   survives only if `U` is closed under merging one time into another. For `U = signedUniverse C L`
   that is a statement about `L`.
4. **`DifficultyBounded`** (with `β ≥ 3`) — the coefficients `splitAwareFuel` already carries as an
   interface. `estimateBranchDifficulty`'s `temporalCount`/`modalCount` are `private` to
   `Saturation.lean`, so a bound **cannot be stated** from this file without editing that one,
   which this task's territory forbids. This is the cheapest of the four to retire, and retiring it
   means widening those two functions' visibility in a follow-up that owns `Saturation.lean`.

## What is landed, and what it provides

* `expandBranchWithFuel_isSome_of_measure` + `StepDecreases` + `fuelFigure` — the fuel induction,
  **free of the unbranching restriction**, over an abstract carried state, measure and invariant.
  All four `ExpansionResult` shapes discharged, both split folds consumed as the plan specified
  (`expand_split_fold_isSome`, `expand_splitOrdered_fold_isSome`,
  `allocateFuelProportionally_ge`, `totalDifficulty_le`, `splitBudget_preserved`). This is the
  piece `Fuel.lean`'s "MEASURED OBSTRUCTION" note left open, and it mentions no branch cardinality,
  no known-time count and no mint potential — so it cannot smuggle in a fact about any of them.
* `budgetPotential` = `2·(Tmax²+1)·mintPotential + extensionAllowance + splitOrderedRank`, with
  `budgetPotential_step_unordered` / `_splitOrdered` and `stepDecreases_budgetPotential`. The
  recorded circularity is broken by the mint dimension paying for the rank rise, and arm 3's branch
  shrinkage is absorbed by `extensionAllowance` (the counting chain's links 2 and 3 as a per-state
  quantity) rather than by re-opening it.
* `expandOnceUnblocked_splitOrdered_rank_lt` — the ordered split's rank drop at engine level, all
  three arms.
* `BudgetedTotalityAt` + `expandBranchWithFuel_isSome_of_budget`.
* `PostBlockingSettles`, `armSettlement_of_postBlockingSettles`, `buildTableauAt_isSome_of_settles`.
* **`buildTableauAt_isSome_of_budget`** — the terminus. `RunInvariant` discharged inside via
  `runInvariant_initial`, absent from the statement. No unbranching restriction under any spelling.
* `buildTableauAt_isSome_at_seed` — the caller-facing form, with the mint budget at `8·|U|`, the
  time bound at `derivedTmax`, and the branch budget at the `β`-linear figure: all three read off.
* `branchingWitness` / `branchingWitness_splits` — the branching non-vacuity witness, at
  `T(p → q)`, decided rather than asserted: the engine's step there is a genuine `.split` with two
  arms.
* The **do-not-re-attempt register**, eight entries (the plan's seven plus the `β = 0` refutation).

## For the consuming task (the plan's Phase 14 record obligation)

The replacement for the refuted `buildTableau_isSome` is against **`buildTableauAt` /
`BudgetedTableau`**, not `buildTableau` / `ExpandedTableau`. It carries a quantified branch budget,
the derived fuel figure `mintAwareFuel` (not `splitAwareFuel` — see finding 1), and the four
residuals above. `buildTableau`, its `fuel := 1000` default, and `expandBranchWithFuel`'s
`maxBranches := 50000` default are byte-identical to their pre-task form.

## Final gate, reported verbatim

```
$ lake build
Build completed successfully (2333 jobs).
real    3m24.678s
user    17m7.636s
sys     0m12.244s
```

```
$ lake env lean <scratch>/ax.lean
'FormalSystem.Metalogic.Decidability.buildTableauAt_isSome_of_budget' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
'FormalSystem.Metalogic.Decidability.buildTableauAt_isSome_at_seed' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
'FormalSystem.Metalogic.Decidability.expandBranchWithFuel_isSome_of_budget' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
'FormalSystem.Metalogic.Decidability.expandBranchWithFuel_isSome_of_measure' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
'FormalSystem.Metalogic.Decidability.budgetedTotality_beta_zero_false' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
'FormalSystem.Metalogic.Decidability.branchingWitness_splits' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.armSettlement_of_postBlockingSettles' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
```

Other gates: `grep -c sorry` → 0; `grep -c '^axiom '` → 0; `grep -c NoSplit` → 0;
`Saturation.lean` `ae47004e06e77f2846cc3e1dfa408382`, `Tableau.lean`
`cfd82332c8e400ac97ab709ece5dfb4a`, `Fuel.lean` `8a395bd7117a682c1f8302a2ac5f0f1f` — all three
still match the plan's recorded baselines. `MintBound.lean` 3524 → 4512 lines, purely additive; no
landed declaration deleted, renamed or edited. No task-number citations anywhere in `FormalSystem/`
introduced by this task.

## Build-time findings (R6 / R8)

| After | wall | user |
|---|---|---|
| Phase 12 (previous cycle) | 161s | 13m30s |
| **Phase 13.1 (the abstract induction)** | **162s** | **14m09s** |
| **Phase 13 (the measure)** | **224s** | **16m06s** |
| **Phase 13 (after prose fix)** | **242s** | **20m03s** |
| **Phase 14, full repo `lake build`** | **205s** | **17m08s** |

The module build rose from 161s to ~240s wall over this cycle's ~990 added lines. **No
`set_option` was raised anywhere**: the two `maxHeartbeats 4000000` sites are Phase 11's and are
untouched. Nothing added this cycle needed one — the whole cycle is `Finset`/`Nat` reasoning and
fold plumbing with **no case split over `TableauRule`**, which is what kept the cost linear-ish.
Iteration was against a scratch file importing `MintBound` (~2s per attempt); five full module
builds across two phases.

## Next steps, in the order that buys the most

1. **`DifficultyBounded`** — cheapest. Needs a follow-up owning `Saturation.lean` to widen
   `temporalCount`/`modalCount` visibility, then a bound on `estimateBranchDifficulty` from
   branch-confinement.
2. **`UniverseClosed`** — instantiate at `U = signedUniverse C L` and prove both clauses from
   `BranchStock`/`ExtendStep` plus a closure condition on `L` under time merging.
3. **`PostBlockingSettles`** — compare `blockedTimes … (armTracker ob)` against the engine's
   threaded tracker. The prose in `Saturation.lean` already argues `armTracker` is the stricter of
   the two; what is missing is what that costs at the saturation test.
4. **`MintPaysForTime`** — the research-grade one. Two independent sub-problems (time reuse, and
   the three non-`ruleMintsFreshLabel` time-creating rules); neither should be attempted without
   its own research pass.

## Deviations

Four this cycle, all annotated inline on their checklist lines:
1. Phase 13: the induction is on the measure bound `N`, not on `fuel`, and is stated over an
   abstract carried state before being instantiated.
2. Phase 13: the fuel figure is the derived `mintAwareFuel`, not `splitAwareFuel` (finding 1).
3. Phase 14: the terminus is at that same derived figure.
4. Phase 14: the post-blocking arm is discharged by a named residual rather than being eliminated
   by the certificate change (finding 2).
