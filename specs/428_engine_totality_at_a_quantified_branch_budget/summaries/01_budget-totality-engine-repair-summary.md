# Implementation Summary: Task #428

- **Task**: 428 - engine_totality_at_a_quantified_branch_budget
- **Status**: TBD
- **Started**: TBD
- **Completed**: TBD
- **Artifacts**: TBD
- **Standards**: TBD
- **Plan**: plans/01_budget-totality-engine-repair.md
- **Outcome**: **PARTIAL** — Phases 1-3 COMPLETED, Phase 4 BLOCKED, Phases 5-8 not started
- **Build**: `lake build` green repo-wide (2332 jobs); zero `sorry`, zero new axioms in both
  in-scope files
- **Type**: lean4

## What landed

### Phase 1 — `saturateBlocked_isSome` [COMPLETED]

Lifted verbatim from `assets/saturateBlocked_isSome.lean.txt` (three declarations:
`split_fold_isSome`, `splitOrdered_fold_isSome`, `saturateBlocked_isSome`), stripped of its
import/namespace wrapper and nothing else. The scope hypothesis held exactly: no tactic block
was edited. `lean_verify` reports `[propext, Classical.choice, Quot.sound]`.

Added alongside: `saturateBlocked_ne_none`, plus the two dead-arm corollaries the plan asked
for, stated as lemmas rather than comments:

- `resolveOpenArm_eq_none_imp` — `resolveOpenArm`'s `| none => none  -- Undecided` arm is
  unreachable, so the *only* route to `none` is its final "still not saturated" arm; the lemma
  exhibits the post-blocking branch that arm reached.
- `buildTableau_saturateBlocked_arm_unreachable` — `buildTableau`'s `| none => none  -- Should
  not happen` arm is unreachable.

The in-source deferral note was narrowed to name only the still-deferred `saturateBlocked_sound`.

### Phase 2 — blocking-aware `resolveOpenArm` [COMPLETED]

Both of `resolveOpenArm`'s saturation tests now use the engine's *real* test
(`findUnexpandedUnblocked`) rather than the *literal* one (`findUnexpanded`). The scope
hypothesis held: exactly two sites, confirmed by grep before editing.

**Tracker decision, and a correction made mid-phase.** The plan's first preference was to thread
the enclosing fold's live tracker; that needs a signature change, so the plan's stated fallback
applied. Drafting the fallback with `EventualityTracker.empty` and then *checking* the direction
showed the draft rationale was backwards: `allEventualitiesFulfilledOrDuplicated` quantifies over
`tracker.pendingAtTime`, which is empty under the empty tracker, so the condition holds
**vacuously** and *more* times count as blocked — the permissive extreme, exactly the direction a
blocking engine must not be sloppy in. Both sites therefore use a new `armTracker`, which
recomputes the arm's eventualities from the arm's own branch. That is self-contained (no
signature change) and at least as strict as the engine's own inherited-and-pruned tracker. The
corrected reasoning is written out in the section prose.

**Verdict effects.** Full test suite ran; **no conformance verdict flipped** — every pinned
`#guard_msgs` row in the repo still passes. New probe section `ArmSettlingProbes` pins the
measured rows by running them:

| row | value |
|---|---|
| `expandBranchWithFuel` on `F(G p)` seed, fuel 500 | `isSome = true` (was `none` at every tested fuel/budget) |
| same on `¬G(F p)` | `isSome = true` (was `none`) |
| same on `U(p,q)` (control) | `isSome = true` (unchanged) |
| `buildTableau (F(G p)) 500` | `isSome = false` — top level deliberately still literal |
| `(literal, blocking-aware)` tests at the returned branch | `(true, false)` — the disagreement, exhibited |

**Declared out-of-scope divergence.** `resolveOpenArmCancellable` in `CancellableExpansion.lean`
still tests with the literal `findUnexpanded` at both of its decision points, and its two call
sites inside `expandBranchWithFuelCancellable`'s `.split` and `.splitOrdered` folds are now out
of sync with `Saturation.lean`. That file is outside `file_scope`; the drift is recorded in
`resolveOpenArm`'s docstring naming the function and its call sites, and reported here. The
cancellable path is `IO`-only and feeds no verified result.

### Phase 3 — budget entry point and its certificate [COMPLETED]

All additive. `buildTableau`, its defaults, `expandBranchWithFuel`'s `maxBranches := 50000`
default and `ExpandedTableau.hasOpen`'s proof field are byte-identical to their pre-task form.

- `BudgetedTableau` — blocking-aware twin of `ExpandedTableau`. Its `hasOpen` arm carries
  `findUnexpandedUnblockedWith … = none` **and the tracker as a field**, so the certificate names
  the blocked set it is relative to instead of leaving it to a default. Its docstring states
  precisely how it is weaker than `ExpandedTableau.hasOpen` and why the weaker notion is the
  honest one for a blocking engine.
- `buildTableauAt phi fuel fc maxBranches : Option BudgetedTableau` — arm for arm `buildTableau`,
  with `maxBranches` threaded and both top-level tests blocking-aware.
- `BudgetedTableau.upgrade` + `upgrade_hasOpen_isSome_iff` — the upgrade bridge. A consumer
  needing the strong certificate gets one **iff** the literal condition holds, so the weaker
  certificate buys no free access to the stronger one.
- `findUnexpanded_isSome_of_unblocked_isSome` — the restriction fact the pinning lemma needs.
- `buildTableauAt_allClosed_imp` — the pinning lemma.
- `buildTableauAt_hasOpen_findClosure_none` — top-level closure freedom.
- `BudgetedTableauProbes` — `buildTableauAt (F(G p)) 500 .Base 50000` settles (and reports
  invalid) where `buildTableau (F(G p)) 500` returns `none`.

**Two plan hedges resolved, both downward, both documented in-source:**

1. The pinning `iff` is not merely unproved, it is **false**. `buildTableau` reports `allClosed`
   where `buildTableauAt` reports `hasOpen` exactly when the literal test finds work, the
   blocking-aware test does not, and post-blocking then closes the branch. The implication that
   matters (`buildTableauAt` closed ⟹ `buildTableau` closed) is landed; the converse's failure is
   characterised in the docstring rather than asserted away.
2. `buildTableauAt_hasOpen_findClosure_none` landed as a **two-way disjunction**. The first
   disjunct (branch reported open directly by expansion) is proved outright via
   `expandBranchWithFuel_sound`. The second names the post-blocking route and is *not*
   dischargeable: `saturateBlocked` returning `.inr` does not imply closure-freedom, because its
   `fuel = 0` base case returns the branch unexamined. The concrete refuting shape is in the
   docstring. **This is a latent defect in `buildTableau` too** — identical gap, identical arm,
   inherited rather than introduced; `resolveOpenArm` is the one caller that guards against it.

### Phase 4 — split-arm quantitative prerequisites [BLOCKED]

Landed sorry-free before the blocker, all in `Fuel.lean`:

- `expandOnceUnblocked_split_shape` / `_split_subset` / `_split_card_le` — a `.split` arm is the
  parent branch with a rule arm appended, hence contains it, hence has cardinality at least as
  large. (The **non-strict** half of the plan's task.)
- `applyRule_timeLinearity_arms` — the refutation witness (see blocker).
- `estimateBranchDifficulty_pos`, `allocateFuelProportionally_ge` — every arm's allocation is at
  least `m`, given `T * m ≤ fuel + 1` and `m ≤ fuel`. The `m = 1` case is the already-landed
  `allocateFuelProportionally_pos`.
- `totalDifficulty_le` — `T ≤ D * β`, in the abstract-`D` form. A finer per-formula bound cannot
  be *stated* from `Fuel.lean`: `temporalCount` and `modalCount` are `private` to
  `Saturation.lean`, and making them public is a change to existing declarations that this
  additive work deliberately does not make.
- `applyRule_branching_arity_le` and `expandOnceUnblocked_split_arity_le` — **`β = 3` is now a
  theorem, not a census.** Proved by 36-rule case analysis over `applyRule`, lifted through all
  three pick stages via the existing `findApplicable*_applyRule_eq` extraction lemmas. The
  literal `3` is still not baked in anywhere: `splitBudget_preserved` and its cluster keep
  carrying `β`.

## The blocker

**Task 4.1's second half — "Prove the `.splitOrdered` twin" — is not hard, it is FALSE.**

`timeLinearity` is the only rule producing `.branchingOrdered`, and `applyRule_timeLinearity_arms`
(landed, machine-checked) shows its three arms are

```
[(b, ord.addFuture t₁ t₂), (b, ord.addFuture t₂ t₁), (b.identifyTime t₂ t₁, ord.identifyTime t₂ t₁)]
```

The first two carry the branch **unchanged**; the third *identifies two times*, which can only
merge signed formulas and so cannot raise `toFinset.card` either. `findApplicableRule` states in
its own source comment why no output-presence guard is even possible on that constructor: "the
arms of an ordered split are replacement branches, so 'the branch already contains this arm's
output' is trivially true of every arm". What makes that rule terminate is *self-suppression on
the ordering* — no incomparable pair left, so `.notApplicable` — a comparability measure on
`TimeOrdering`, not a cardinality measure on the branch.

So branch-cardinality growth **cannot** bound split depth across both split constructors, which
is exactly the purpose task 4.1 states for the lemma ("this is what bounds split depth along any
root-to-leaf path by the universe cardinality"). Phase 6's stated approach — "a run of split-depth
`d` needs a figure scaling like `(bound on totalDifficulty) ^ d`, with `d` bounded by Phase 4's
split-growth lemma" — rests on the refuted twin.

**What is needed to unblock**: a second, order-theoretic progress measure for the `.splitOrdered`
arm (e.g. the number of incomparable pairs among `b.knownTimes` under `ord`, shown to strictly
decrease at each `timeLinearity` firing), and a Phase 6 fuel figure built from *both* measures.
That is a re-plan of Phases 4 and 6, not an implementation detail, so it is escalated per
`plan-compliance.md` rather than substituted.

Nothing was papered over: no `sorry`, no vacuous placeholder, no `NoSplit` reintroduced, no
`WorldWitness` admitted, no narrowing of the twin to the `.split` case only.

## Plan Deviations

Per `plan-compliance.md` these are recorded, not silently applied; each is either a plan-sanctioned
fallback or an escalated blocker.

- **Phase 2, tracker argument** — used the plan's own stated fallback (signature-change-free), but
  with `armTracker` rather than the bare `EventualityTracker.empty` default, because the default
  was measured to be the *permissive* direction. Documented in-source.
- **Phase 3, pinning lemma** — the `iff` is false, not merely unprovable; landed the implication
  the plan names as the fallback, with the converse's failure characterised. Plan-sanctioned.
- **Phase 3, closure-freedom lemma** — landed as a disjunction with the post-blocking route named
  and proved non-dischargeable, rather than as an unconditional statement. Documented with the
  refuting shape.
- **Phase 4, task 4.1** — ESCALATED, not deviated. Phase marked `[BLOCKED]`.
- **Phase 4, task 4.3** — `totalDifficulty_le` stated with an abstract per-arm bound `D` rather
  than in terms of `temporalCount`/`modalCount`, which are `private` to `Saturation.lean`. Serves
  the stated purpose (dischargeable from arity and a bounded quantity) without changing an
  existing declaration's visibility.
- **Phases 5-8** — not started, behind the Phase 4 blocker.

## For the task that consumes this work

The replacement for the refuted `buildTableau_isSome` is against `buildTableauAt` /
`BudgetedTableau`, **not** `buildTableau` / `ExpandedTableau`, and it carries a quantified budget
hypothesis. `buildTableauAt_isSome_of_budget` (Phase 8) does **not** exist yet — it is behind the
Phase 4/6 blocker. What does exist and is consumable today: `saturateBlocked_isSome`,
`buildTableauAt`, `BudgetedTableau`, `BudgetedTableau.upgrade` + `upgrade_hasOpen_isSome_iff`,
`buildTableauAt_allClosed_imp`, and the Phase 4 lemma cluster.

The refuted shape stays on the do-not-re-attempt register: `buildTableau_isSome_of_budget` with
`maxBranches` quantified as the only new hypothesis and `soundFuel' φ` as the fuel, refuted by
`φ = F(G p)` at `fuel = 229376`, `maxBranches = 10¹²`.

## Verification

- `lake build` green repo-wide (2332 jobs), run at Phase 2 end, Phase 3 end and Phase 4 end.
- `grep -c sorry` = 0 in both `Saturation.lean` and `Fuel.lean`.
- `grep -c '^axiom '` = 0 in both.
- `saturateBlocked_isSome` and `buildTableauAt_allClosed_imp` each verify with only
  `[propext, Classical.choice, Quot.sound]`.
- Existing `SplitFuelProbes` `#guard_msgs` rows unchanged and passing.
- New `ArmSettlingProbes` and `BudgetedTableauProbes` rows passing.
- `buildTableau`'s signature, its `maxBranches := 50000` default and `ExpandedTableau.hasOpen`'s
  proof field are untouched (`git diff` shows only additions around them).
