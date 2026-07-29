# Phase 7, twelfth dispatch — sub-phase 7.1d closed: the dense milestone

## Outcome

**7.1d is COMPLETE.** The signed truth lemma is sorry-free at every one of the six `Formula`
constructors at a dense carrier, and both headline results — `not_validDense_of_hasOpen` (ℚ) and
`not_validDedekindDense_of_hasOpen` (ℝ) — are sorry-free. Six green commits, each verified by
`git show --stat` for content rather than exit status.

Phase 7 now owes 7.2 and 7.3, in that order.

## The question the dispatch was asked to settle first

Whether the dense negative case's non-placed evaluation point needs a new gate row. The answer is
**yes — and so does the positive case**. Both candidates were measured on the engine corpus in the
exact shape to be adopted, beside the rows they strengthen, before either was written into
`temporalWitnessCheck`. That discipline has now changed the conclusion in nine consecutive
dispatches; here it did so twice, in both directions.

- **Rows 5 and 6 generalised** (`untlNegRegionUp`/`snceNegRegionDn`). Measured `uNRU`: `true` on
  all eight gate-accepted corpus rows, single `false` exactly where the row it strengthens (`uRL`)
  already fails and `regionLabelCheck` already rejects. It **subsumes** the two rows it replaces —
  at `j = 0` the rank side condition is vacuous and the first reach is old row 5 verbatim — so the
  gate did not grow here. `untlNegRay_low` survives as the `j = 0` instance and `snceNegRay_up` as
  the `j = n` instance.
- **Rows 11 and 12 added** (`untlPosRegion`/`sncePosRegion`). Measured `uPR`/`sPR`: `true` on all
  eight gate-accepted rows. These do **not** subsume rows 3, 9 and 10, so they were adopted beside
  them and the gate went from ten rows to twelve. The `self` diagnostic column is what established
  that the disjunction is load-bearing: `self` alone is `false` on every genuine-until row, and the
  `known` disjunct alone is unsatisfiable at the top region, where no known time has rank `n`.

Each row was stated in the same commit as the lemma that consumes it, so no unvalidatable dead
weight was added to 7.3's obligation.

## Two findings that changed the size of the work

**The dense negative halves are smaller than ℤ's, not larger.** ℤ's are seven leaves apiece with
three vacuous; the dense ones are **four leaves and none vacuous**. Because `regionLabel_untlNeg`
is `j`-generic, a non-placed point reads `regionLabel … (cutIndex (regionCode f s))` whether it is
in an interior gap or on a ray, so the case split is simply *placed or not*, twice, with no ray
analysis anywhere. `RayOnly`, `RaySplit`, `Stepped`, `upperRay_of_gt`, `lowerRay_of_lt` and
`isPlacedCode_of_between` appear nowhere in the dense file. What replaces the ray analysis is
arithmetic on the cut index: three counting lemmas, one per side condition.

**The positive halves differ from ℤ's in exactly one word.** At ℤ the upper-ray leaf *vanishes*
its guard interval — `Stepped` gives an immediate successor, so nothing lies strictly between. At
ℚ/ℝ no point has a successor, the interval is always inhabited, and the guard must be **carried
across a whole region** instead. That is what row 11's `self` disjunct demands and what no ℤ row
ever did; it is the one place the dense milestone genuinely costs more than the discrete one.
`exists_gt_sameRegion` supplies the witness `Stepped` used to, and `sameRegion_convex` does the
work `upperRay_of_gt` did.

## A landed row consumed for the first time, at zero cost

`regionLabel_untlGuard` / `regionLabel_snceGuard` close the sub-leaf where a placed-to-placed
witness's guard interval meets a non-placed point — a sub-leaf contiguity made empty at ℤ.
Consuming them adds **no** obligation to 7.3, because `untlGuards`/`snceGuards` are already rows of
`regionLabelCheck`, which is already a hypothesis. The general principle is worth keeping:
consuming an already-gated row is free and is always preferable to adding a new one.

## The instantiation is a cast, not a construction

ℚ and ℝ reuse `intPlace` composed with `Int.cast`. `Function.Injective`, `OrderFaithful` and
`OrderReflecting` all transport along any strictly monotone map (`orderFaithful_comp`,
`orderReflecting_comp`). What does *not* transport is `RayOnly`/`RaySplit`/`Stepped` — that is
`not_exists_gt_sameRegion_int` read the other way round, and it is exactly why this was a separate
sub-phase rather than a corollary of the ℤ one.

## Verification

| Check | Result |
|-------|--------|
| `lake build FormalSystem.Metalogic.Decidability` | green, 1116 jobs |
| `lake build` (full default target) | green, **1939 jobs**, zero errors |
| `lake env lean` on `Bridge/DenseTruth.lean`, `Bridge/TemporalGate.lean`, `Tests/BimodalTest/TemporalWitnessProbe.lean` | green |
| `lean-sorry-census.sh … --cross-check` | `sorry_count: 0`, compiler `0`, stripper `0`, **MATCH** |
| Vacuous-definition grep | 0 |
| `^axiom ` grep | 0 |
| `git show --stat` after each of six commits | +163, +150/−48, +147, +176, +161/−6, +201, +155, +103/−3 — all matching intent |

## Deviations from the plan

None. The plan's 7.1d text called for consuming `Interpolate`'s
`exists_gt_sameRegion`/`exists_lt_sameRegion`, which is what the positive halves do. The two new
gate rows are inside 7.1d's scope, not a scope change: the plan's own process rule requires any new
row to be measured before it is stated, and both were.

## One signature change to landed ℤ work

`branchTruthAt_snce_neg` gained `hV : branchOrderValid b ord = true`. Cause: `snceNegRay_up` is now
the `j = n` instance of generalised row 6, whose rank side condition at region `n` is *derived*
from `branchRank_lt_length` rather than vacuous as it is at region `0`. The caller
`branchTruthAt_snce` already carried `hV`, so the ripple was two lines and no proof was re-derived.
