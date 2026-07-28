# Phase 7, tenth dispatch — the positive temporal halves, and 7.1c closes

**Status**: 7.1c COMPLETE. Phase 7 remains PARTIAL (7.1d, 7.1e, 7.2, 7.3 open).
**Sorry census over `FormalSystem/Metalogic/Decidability/Verified/`: 0** (cross-checked against
the compiler: `compiler_sorry_count: 0`, `stripper_sorry_count: 0`, `MATCH`).

## What landed

`branchTruthAt_untl_pos` and `branchTruthAt_snce_pos`, both sorry-free, each on the first compile.
With them `branchTruthAt` is sorry-free at all six `Formula` constructors, and so are
`not_valid_of_hasOpen_int` and `not_validDiscrete_of_hasOpen_int`.

Supporting, all sorry-free:

- **Rows 7-10 of `temporalWitnessCheck`** — `untlPosGuardedWitness`, `sncePosGuardedWitness`,
  `untlRayDnGuard`, `snceRayUpGuard` — with four consumption lemmas in the established
  branch-fact-in / branch-fact-out shape.
- **`Stepped`** (every carrier point has an immediate successor and predecessor) and its `ℤ`
  discharge `stepped_int`.
- **`upperRay_of_gt` / `lowerRay_of_lt`** — the rays are upward/downward closed, *derived* from
  `RayOnly` + `RaySplit`.

## Measured before stated — and the measurement changed the rows

The prior banner called `gw` and `rdG` "measured and adoptable". Walking the proof showed neither
is usable **as measured**, for two independent reasons:

1. `gw` exempts the *whole row* when `ψ = ⊤`, so it asserts nothing on the `someFuture`/`somePast`
   fragment — where the positive case still needs a witness, since `TruthAt … (untl φ ⊤)` demands
   one. The exemption has to sit inside the witness and drop only the guard.
2. `rdG` permitted the escape "the event is at the ray's own label, no guard obligation". That
   does not close the lower-ray leaf: the ray label is itself a known time, so placed points sit
   strictly below it, all of them strictly above the evaluation point and inside the guard
   interval.

Both strengthenings were measured **in the exact adopted form** as `probe4`'s `uGW`, `sGW`, `uRD`,
`sRU`, each reported beside the weaker form it strengthens (the process lesson from the previous
dispatch, applied). Result: all four `true` on all eight rows the region gate accepts — the same
acceptance standard rows 1-6 met — and no adopted column ever differs from its weaker neighbour
anywhere in the twelve, so both strengthenings are free.

## Obstruction 1, resolved

`Stepped`, option 1 of the two the banner named, in its minimal form: a property of the **carrier**
rather than of the placement, because that is all the upper-ray leaf needs — some `s > r`, and a
guard interval it can empty. The banner's other candidate clause, "everything strictly above an
upper-ray point is itself upper-ray", is **derived** (`upperRay_of_gt`) rather than assumed.

Cost: `Stepped` is false at `ℚ`/`ℝ`. So are `RayOnly` and `RaySplit`, and all three are used only
by the temporal cases, which 7.1d replaces wholesale with `Interpolate`'s density lemmas. 7.1d pays
nothing it was not already paying. The alternative — restating the positive halves at `ℤ` only —
was rejected because it would have forced `branchTruthAt` itself to `ℤ`.

## Two things the design owed that turned out not to be needed

- **The earliest-witness iteration** on `b.knownTimes.length - branchRank b ord t'`, the standing
  shape of item 2 since the 2026-07-28l banner, was never written. Row 7 returns the witness *and*
  the guard below it together, so the branch minimises once, decidably. The placed leaf is six
  lines.
- **`sat_untl_pos_future` / `sat_snce_pos_past`** are not called. Their only role was the
  guard-`⊤` case, which row 7 now covers.

## A trimming that is a finding

Neither positive half references `branchOrderValid`, the frame class, `findUnexpanded`,
`findClosure`, `timeOrderTotal`, `boxAnchoredCheck`, `regionLabelCheck`, or the non-empty-worlds
hypothesis. The positive direction is carried by the placement geometry plus rows 3, 7, 9 and 10
alone; `regionLabelCheck` is load-bearing in the **negative** direction only.

## Verification

| Check | Result |
|---|---|
| `lake build FormalSystem.Metalogic.Decidability` | green, 1115 jobs, no `sorry`, no warnings from either file touched |
| `lake env lean Tests/BimodalTest/TemporalWitnessProbe.lean` | green, every `#guard_msgs` row passes including the twelve new `probe4` rows |
| `lean-sorry-census.sh … Verified/ --cross-check` | `sorry_count: 0`, `cross_check: MATCH` |
| vacuous-definition grep over `Decidability/` | 0 |
| `axiom` grep over `Decidability/` | 0 |

`lake build BimodalTest` was deliberately **not** used as this dispatch's gate: two
out-of-territory REDs were named in the dispatch (`BXCanonical/Chronicle/
CounterexampleElimination.lean`, pre-existing; `WeakCanonical/DenseModelSurgery/BadIntervals.lean`
plus an untracked `Dual.lean`, from a concurrent session). Neither was touched or staged. The
probe's compilation was verified separately with `lake env lean` rather than masked by a
target-level result.

## Environment hazard — recorded, not worked around

A concurrent session working task 408 in this same clone twice disturbed the shared worktree: it
moved `HEAD` to a detached commit five back, and separately stashed this task's in-progress
`TemporalGate.lean` edit (stash message: *"re-stashed by t408-p20.4 after accidental pop of
git-snapshot-1785279640"*). Nothing was lost — the commit was recovered from `main`, the edit from
the stash — but **one commit of this task's that reported success had captured only part of the
intended diff**, and the omission surfaced only as an "unknown identifier" error at the consumer
module. Verify committed *content*, not just commit exit status, while another session shares the
clone.

## Still live for 7.3

`regionLabelCheck` reports **false** on the branches the engine builds for `U(p,q) → q` and
`S(p,q) → q` (probe rows H, J, M, N). It is a hypothesis wherever used, so nothing proved is
affected — but 7.3 must discharge it for real engine branches, and `temporalWitnessCheck`, now
**ten** rows, needs the same treatment.

## Commits

| Commit | Content |
|---|---|
| `82b93d62a` | probe4: rows 7-10 measured in the exact form the proof consumes |
| `a9a5635e6` | rows 7-10 of `temporalWitnessCheck` + four consumption lemmas |
| `be1f2c30f` | the positive `untl` half, sorry-free (`Stepped`, `upperRay_of_gt`, `lowerRay_of_lt`) |
| `228cdfb31` | the positive `snce` half; 7.1c closes at census 0 |
| `7256b5ac9` | trim the positive halves to the hypotheses they use |
| `7b0d57170` | docstrings rewritten to what landed |
| `4797304d1` | plan: 2026-07-28o banner, 7.1c marked complete, register additions |
