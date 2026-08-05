# Implementation Summary: Task #428 (plan 02, phases 5-11)

- **Plan**: `plans/02_lexicographic-splitordered-measure.md`
- **Outcome**: **PARTIAL**. Phases 5-10 landed sorry-free with a green repo-wide `lake build`.
  Phase 11 is **[BLOCKED]** on a measured, sharply-characterised obstruction. Phases 12-13 depend
  on Phase 11 and were not attempted.
- **Files modified**: `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` only
  (768 insertions, **0 deletions** — purely additive). `Saturation.lean` was not edited, as plan
  02 anticipated.

## What landed

### Phase 5 — closure monotonicity calculus [COMPLETED]

`TimeOrdering.pathN_mono`, `directFutureOf_mono`, `directPastOf_mono`, `futureOf_mono`,
`pastOf_mono`, `mem_futureOf_addFuture`, `mem_pastOf_addFuture`.

Scope Hypothesis CONFIRMED: the whole BFS calculus the plan named is already present and
`Fuel.lean:98`'s `open private` is in force. Nothing was rebuilt. `futureOf_mono` runs at the same
fuel `100` on both sides, exactly as `orderDual_holds` already relies on.

### Phase 6 — the incomparable-pair measure [COMPLETED]

`firstIncomparablePair_spec` (the `some`-direction companion that did not exist), `incomparableB`,
`incompPairs`, `mem_incompPairs`, `incomparableB_mono`, `incompPairs_mono`,
`addFuture_constraints_mono`, `incompPairs_lt_addFuture`.

`incomparableB` transcribes `firstIncomparablePair`'s own test verbatim, so the measure cannot
drift from its trigger. `incompPairs_lt_addFuture` is a conjunction covering **both** `addFuture`
arms under the one name the plan gave it.

### Phase 7 — the identification arm and the lexicographic measure [COMPLETED]

`applyRule_timeLinearity_arms_trigger`, `src_not_mem_knownTimes_identifyTime`,
`knownTimes_identifyTime_subset`, `knownTimes_card_lt_identifyTime`, `splitOrderedMeasure`,
`splitOrderedMeasure_lt_of_timeLinearity`.

Scope Hypothesis CONFIRMED: `timeLinearity` is the sole producer of `.branchingOrdered`
(`Tableau.lean:1513-1520` is its only construction site). G2 is honoured and recorded in-source:
**no fact about `identifyTime`'s output ordering is proved, assumed, or needed anywhere** — arm 3
is discharged entirely on the measure's first component.

`applyRule_timeLinearity_arms_trigger` is an additive strengthening of the landed arms lemma (same
three arms, plus the `firstIncomparablePair` equation). The landed lemma is untouched.

### Phase 8 — strict `.split` cardinality growth [COMPLETED]

`branching_arms_new_of_guard`, `applyRule_branching_arms_fresh`,
`findApplicableRule_branching_guard`, `applyRule_serialityRule_not_branching`,
`applyRule_timeLinearity_not_branching`, `findApplicableSerialRule_not_branching`,
`findApplicableLinearityRule_not_branching`, `expandOnceUnblocked_split_card_lt`.

**R2's sanctioned fallback was not needed and was not used.** All three cases closed. Scope
Hypothesis CONFIRMED: `findApplicableRule`'s `.branching` arm has exactly two guard bypasses
(`ruleSelfGuarded`, then `ruleMintsFreshLabel`), and `findApplicableRule_branching_guard` pins
that to the source rather than to a reading of it. Cases 2 and 3 share one lemma because they
share their witness, `Branch.nextTime`.

One thing the three-case framing did not name: the other two pick stages are unguarded entirely,
so a fourth case would have been needed had they been able to produce `.branching`. They cannot,
and that is now a theorem rather than an assumption.

### Phase 9 — split-fold preservation helpers [COMPLETED]

`expand_split_fold_isSome`, `expand_splitOrdered_fold_isSome`. Both stated over abstract per-arm
hypotheses; neither statement mentions `worldFuel'`, `soundFuel'`, or `NoSplit`.

**Finding, in the direction the plan asked to be reported rather than assumed away**:
`resolveOpenArm = none` is genuinely reachable. By the landed `resolveOpenArm_eq_none_imp` the
only surviving route is its final "still not saturated" arm — precisely the configuration the
refuted unconditional `buildTableau_isSome` died on. It is therefore carried as the named per-arm
hypothesis `hres` on both fold lemmas.

### Phase 10 — the carried time bound and the split-aware fuel figure [COMPLETED]

`TimeBounded`, `incompPairs_card_le`, `splitOrderedRank`, `orderedRunBound`, `splitOrderedRank_le`,
`splitOrderedRank_lt_of_timeLinearity`, `splitPathBound`, `splitAwareFuel`,
`splitPathBound_le_splitAwareFuel`.

Both required in-source deliverables are present: the `NoSplit`-vs-`hT` distinction (R3) and the
"why a naive combination of the two measures fails" record.

**Sanctioned divergence** (the phase's own Scope Hypothesis required deriving the figure and using
the derived value): the plan wrote the ordered-run bound as `Tmax + Tmax²`; the derivation gives
`orderedRunBound Tmax = Tmax*(Tmax*Tmax+1) + Tmax*Tmax` = `Tmax³ + Tmax² + Tmax`. The two
components compose multiplicatively — component 2 is *reset*, not continued, on each drop of
component 1. The derived figure is used; `splitOrderedRank_le` is its machine-checked range
statement; the divergence is recorded on `orderedRunBound`'s docstring.

`soundFuel'` and `worldFuel'` are unmodified. The literal `3` is not baked into `splitAwareFuel`,
which carries `β`.

## Phase 11 — BLOCKED

`expandBranchWithFuel_isSome_of_budget` does not close. Nothing was landed for this phase: no
`sorry`, no narrowed statement, no `NoSplit` reintroduction, no vacuous placeholder.

The landed unsplit induction was reproduced with `hP : NoSplit P fc` deleted and run against the
real proof state. `saturated` and `extended` carry over. Phase 9's fold lemmas match the two split
arms' fold shapes exactly and reduce each arm to two obligations. The **budget** obligation
discharges (`splitBudget_preserved` plus `branches.length ≤ β`). The **fuel-sufficiency**
obligation does not.

Re-establishing it needs a potential preserved at all four arms. The candidate built from exactly
the assets Phases 7-10 supply,

  `Ψ(b, ord) = (|U| − |b|) * (orderedRunBound Tmax + 1) + splitOrderedRank Tmax b ord`,

is preserved at three arms and **rises at `.splitOrdered` arm 3**: `identifyTime` can shrink the
branch, so `(|U| − |b|)` grows by `s * (orderedRunBound + 1)` for the merge count `s`, while the
rank is guaranteed to drop only by `1`. Re-weighting is circular rather than unlucky — making the
`knownTimes` weight dominate fixes arm 3, but then any step that mints one fresh time costs more
than its branch growth pays.

**This corrects the plan's own reading of G4/R1.** The plan carried `hT` on the understanding that
it breaks the circularity, and located the residual risk at Phase 12 (can `hT` be *discharged*?).
The measured finding is that `hT` does not break the circularity even when *granted*: it caps the
ordering dimension's value but does not stop `identifyTime` from returning universe budget to the
branch dimension. The obstruction bites at Phase 11, before Phase 12's question is reached.

What would unblock it: (a) a lower bound on `(b.identifyTime t₂ t₁).toFinset.card` in terms of
`b.toFinset.card`, or (b) an independent bound on fresh-time mints along a path not stated in
terms of branch growth. Neither exists in `Fuel.lean` today; both are new research.

The obstruction is recorded in-source next to `splitAwareFuel` under "MEASURED OBSTRUCTION", so a
future reader meets it where they would otherwise re-attempt it. `splitAwareFuel`, `splitPathBound`
and `orderedRunBound` are correct arithmetic whose **adequacy is open**; no theorem here claims the
engine is total at them.

## Phases 12-13 — not attempted

Both depend on Phase 11 and are unreachable until it resolves. They remain `[NOT STARTED]` rather
than being attempted out of order. In particular the task's terminus
`buildTableauAt_isSome_of_budget` did **not** land, and the `WorldWitness` / `hT` discharge was not
attempted — neither is admitted, asserted, or axiomatised anywhere.

## Plan Deviations

- Phase 10, ordered-run bound: **altered**, under the phase's own Scope Hypothesis clause, which
  required deriving the figure and using the derived value. `Tmax³ + Tmax² + Tmax` replaces
  `Tmax² + Tmax`. Recorded in-source and inline on the plan's checklist item.
- Phase 11: **blocked**, per the phase's escalation clause. Exact goal state recorded in the plan's
  `BLOCKER (Phase 11)` entry.
- No other deviations. Phases 5-9 followed the plan's task sequence, lemma names, and
  decomposition exactly.

## Verification

- `lake build` (full repo) green — 2332 jobs.
- `sorry` count 0 in both `Fuel.lean` and `Saturation.lean` (preservation check, both were 0).
- `^axiom ` count 0 in both files.
- `git diff` on the scope file shows **0 deletions**: every phase was purely additive, so every
  phase commit is independently revertible.
- `buildTableau`'s `fuel := 1000` default and `expandBranchWithFuel`'s `maxBranches := 50000`
  default are byte-identical; `Saturation.lean` was not touched at all in this dispatch.
- The one repo-wide vacuous-pattern hit (`FormalSystem/Examples/TemporalStructures.lean:279`) is
  pre-existing, legitimate (`intTimeHistory.domain t` reduces to `True` definitionally), outside
  `file_scope`, and unrelated to this task.

## Carried divergences, unchanged

`resolveOpenArmCancellable` in `CancellableExpansion.lean` remains out of sync with the repaired
`resolveOpenArm`. It is outside `file_scope`, it was declared as a deliberate unrepaired divergence
by plan 02, and this dispatch did not touch it.

## Note for the consuming task

The replacement for the refuted `buildTableau_isSome` is still **not landed**. Anything planned
against `buildTableauAt_isSome_of_budget` must wait on Phase 11's obstruction being resolved; the
Phase 3 assets (`BudgetedTableau`, `buildTableauAt`, `BudgetedTableau.upgrade`) are available and
sorry-free in the meantime.
