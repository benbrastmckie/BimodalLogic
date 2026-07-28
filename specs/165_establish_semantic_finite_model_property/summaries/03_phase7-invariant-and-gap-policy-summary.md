# Phase 7 (third dispatch) — the box invariant and the gap policy, both corrected

- **Task**: 165, establish semantic finite model property
- **Phase**: 7 (Truth Lemma and Track A Decidability) — remains `[PARTIAL]`
- **Plan**: `specs/165_establish_semantic_finite_model_property/plans/01_tableau-decidability-two-track.md`
- **Status**: partial; sorry-free; `lake build FormalSystem.Metalogic.Decidability` and
- **Started**: TBD
- **Completed**: TBD
- **Artifacts**: TBD
- **Standards**: TBD
  `lake build BimodalTest` both green

## What this dispatch found

Both residuals the previous dispatch named were mis-stated. Neither could have been discharged as
written. Each correction is recorded in tree as a theorem, not as prose.

### `BoxContextClosed` is not a construction invariant

The invariant "`T(□φ)` is present at every known label" was named on the strength of
`boxDiamondPersistence` (`Tableau.lean:434`). Reading the six call sites refutes it twice over:

1. Every call site passes `boxDiamondPersistence branch l.world l.time freshTime`, and that
   function reads `branch.boxPosAtWorldTime l.world l.time` — the box formulas at the *triggering*
   label only. A `T(□φ)` at another world is never copied to the fresh time.
2. The world-minting rules copy box formulas' **contents**, not the formulas. `boxNeg` and
   `diamondPos` run `branch.boxPosFormulas.filterMap` with the arm
   `| .box inner => SignedFormula.pos inner { world := freshWorld, time := bsf.label.time }`, so a
   fresh world receives `T(B)` and never `T(□B)`.

Saturation does not repair the gap: `witnessPresent` (`Tableau.lean:1670`) suppresses
`boxNeg`/`diamondPos` on the witness alone, leaving the auto-propagation outputs outside the
applicability test.

### `GapDemands` is vacuous

`GapDemands.future` takes *model* truth of `G φ` at a placed point as its hypothesis, and
`Truth.future_iff` is an `iff` making that hypothesis definitionally its own conclusion. Every gap
policy satisfies it — including the two the same file refutes. `gapDemands_trivial` is that
statement, proved.

## What landed

### `Verified/Bridge/BoxSaturation.lean`

| Declaration | Content |
|---|---|
| `mem_knownWorlds_of_mem`, `mem_knownTimes_of_mem` | label components of a branch formula are known |
| `BoxTemporalSpread` | the corrected invariant: `T(□φ)` puts `T(Gφ)`/`T(Hφ)` at every known world at the box formula's own time |
| `boxTemporalSpread_of_boxContextClosed` | nothing is lost by the weakening |
| `mem_directFutureOf_iff_mem_constraints`, `mem_directPastOf_iff_mem_constraints` | both closures project the same edge set |
| `mem_directFutureOf_iff_mem_directPastOf` | the one-step converse |
| `TimeOrderConverse` | the closure-level converse, carried as an explicit hypothesis |
| `knownTime_trichotomy` | `timeOrderTotal` in the `futureOf`/`pastOf` form the grid argument consumes |
| `sat_box_grid` | **`T(□φ)` reaches every known label**, from `BoxTemporalSpread` + saturation + `timeOrderTotal` |

`BoxTemporalSpread` is what the world-minting rules *do* maintain: they copy
`allFuturePosAtTime l.time` and `allPastPosAtTime l.time` — all worlds — onto the fresh world.

### `Verified/Bridge/Valuation.lean`

| Declaration | Content |
|---|---|
| `gapDemands_trivial` | `GapDemands` constrains nothing |
| `GapAdequate` | the corrected obligation: branch fact in, model truth at gap points out |
| `branchGapVal` | the gap policy, defined outright from the region code and the branch |
| `branchGapVal_gapAdequate` | all three fields discharged |

`branchGapVal w c p` holds when some index in `c.1` (placed points below the gap) carries
`T(G p)`, or some index in `c.2` (above) carries `T(H p)`, or `T(□ p)` is on the branch at all.
It reads only the region code and the branch, importing nothing from an endpoint — so it is
neither of the two machine-refuted copy policies.

## Verification

- `lake build FormalSystem.Metalogic.Decidability` — green (1109 jobs)
- `lake build BimodalTest` — green (1960 jobs)
- `lean-sorry-census.sh FormalSystem/Metalogic/Decidability/` — `sorry_count: 0`
- `#print axioms` for `sat_box_grid`, `boxTemporalSpread_of_boxContextClosed`,
  `knownTime_trichotomy`, `mem_directFutureOf_iff_mem_directPastOf`, `gapDemands_trivial`,
  `branchGapVal_gapAdequate` — `propext` / `Classical.choice` / `Quot.sound` only
- Out-of-territory RED unchanged: full `lake build` still fails at
  `BXCanonical/Chronicle/CounterexampleElimination.lean`, pre-existing and untouched

## What is owed in 7.1

1. `BoxTemporalSpread` for constructed branches — the induction over tableau construction, now over
   an invariant the construction actually maintains.
2. `TimeOrderConverse` — the fuel-bounded BFS duality; the one-step case is proved, the closure
   case is not. Small and self-contained.
3. The truth-lemma induction, with `branchGapVal` fixed as the atom clause's gap arm. The `U`/`S`
   straddling guards belong here, not to the gap policy: a guard is in general compound, and a
   compound formula's value at a gap point is fixed by the induction rather than by `gapVal`.

## Plan deviations

None. Phase 7's task text is unchanged; the two corrections are to residuals introduced by the
previous dispatch's status banner, and are recorded as banner Corrections 5 and 6.
