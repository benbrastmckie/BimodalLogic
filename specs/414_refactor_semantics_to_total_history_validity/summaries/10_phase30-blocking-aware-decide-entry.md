# Phase 30 — Route `decide` through the blocking-aware entry

**Status**: `[COMPLETED]`
- **Task**: TBD
- **Started**: TBD
- **Completed**: TBD
- **Artifacts**: TBD
- **Standards**: TBD
**Phase**: 30 of 31 (optional)
**Files touched**: `FormalSystem/Metalogic/Decidability/DecisionProcedure.lean` (only)
**Diff shape**: 103 insertions, 0 deletions

## 1. What landed

Two new declarations in `DecisionProcedure.lean`, both additive:

- `extractCountermodelBlocked` — the blocking-aware analogue of `extractCountermodelSimple`.
  Identical extraction (`extractSimpleCountermodel`), but keyed on the witness
  `BudgetedTableau.hasOpen` actually carries, `findUnexpandedUnblockedWith b ord fc
  (blockedTimes b ord fc tracker) = none`, rather than on the literal `findUnexpanded … = none`.
  It is deliberately *not* routed through `extractCountermodelSimple`, since doing so would
  require manufacturing a literal saturation proof the branch does not have.
- `decideBlocking` — arm for arm `decide`, with the tableau call swapped to
  `buildTableauAt φ_n tableauFuel fc maxBranches` and the open arm extracting through
  `extractCountermodelBlocked`. Fast paths (axiom instance, compositional proof, bounded search)
  are unchanged and reached in the same order. `maxBranches` defaults to `50000`, the engine's own
  default in `expandBranchWithFuel`, so `decideBlocking φ` and `decide φ` at default arguments run
  at the same budget and differ only in the certificate they demand.

`decide` itself is byte-identical and still calls `buildTableau`. `Saturation.lean` needed no
widening — `buildTableauAt`, `upgrade`, `armTracker`, and `blockedTimes` all already existed and
were already exported, so the phase's conditional second file was not opened.

## 2. The bridge invariant, confirmed by reading the diff

The plan required that `upgrade` / `upgrade_hasOpen_isSome_iff` remain the **only** path from the
weak certificate to the strong one, confirmed by reading the diff rather than by assertion. Read:

- **Closed arm**: reaches `ExpandedTableau` only via `(BudgetedTableau.allClosed cs).upgrade`.
- **Open arm**: never constructs an `ExpandedTableau` at all. It goes straight to
  `.invalid (extractCountermodelBlocked …)`.
- **Dead arm**: `upgrade = none` on `allClosed` is impossible by the `@[simp]` lemma
  `upgrade_allClosed`. It is discharged with `absurd hup (by simp)` — **not** filled with a
  verdict. Emitting anything there would have been a heuristic verdict; the plan's postmortem
  constraints prohibit exactly that, and no verdict constructor without a saturation proof field
  was added.

So no free path from `BudgetedTableau.hasOpen` to `ExpandedTableau.hasOpen` was introduced.

## 3. No probe row moved

`lake build BimodalTest` exits with exactly **7** `#guard_msgs` mismatches:

| File | Lines |
|------|-------|
| `Tests/BimodalTest/BoxSpreadProbe.lean` | 165 |
| `Tests/BimodalTest/RegionGateProbe.lean` | 299, 330 |
| `Tests/BimodalTest/TableauConformance.lean` | 873, 885, 910, 916 |

This is the same set, at the same line numbers, that
`09_phase29-2-preguard-differential-rebaseline.md` §8 enumerates as the reasoned exclusions left
pinned at Phase 29.2 exit. Nothing under `Tests/` was modified by this phase, so no re-baseline
and no Phase-30 attribution record was owed.

## 4. Verdict-level effect: none — and the plan predicted this

Measured on the live post-guard engine at default arguments:

| Formula | `decide` | `decideBlocking` |
|---------|----------|------------------|
| `(G p) → □(G p)` | `.invalid` | `.invalid` (countermodel `isSome`) |
| `p → p` | `.valid` | `.valid` |
| `p → □p` | `.invalid` | `.invalid` |

The phase describes itself as *a complement, not a substitute* that "does not rescue
`(G p) → □(G p)` without Phase 25". That holds as written, and in the direction that makes the
complement currently inert: Phase 25's `trivialEventWitnessed` guard had **already** rescued that
formula, so `buildTableau` now reaches a literal open certificate on it and `decide` already
answers `.invalid`. There is consequently no formula left, at the default budget, for the
blocking-aware certificate to newly settle.

The honest description is therefore: the complement is **present and functional, not currently
load-bearing**. Its value is structural — it is the entry that stays correct if the engine's
literal saturation test again becomes unreachable for a class of formulas — not a verdict
improvement measurable today.

## 5. The budget parameter is live, not decorative

Sweeping `maxBranches` on `(G p) → □(G p)` at fuel 1000:

| `maxBranches` | 1 | 2 | 4 | 8 | 16 | 32 | 64 | 1000 |
|---------------|---|---|---|---|----|----|----|------|
| `decideBlocking` | exhausted | exhausted | exhausted | exhausted | exhausted | invalid | invalid | invalid |

`decide` returns `.invalid` at every row (it does not take the parameter). The threshold between
16 and 32 is real, which is the evidence that the budget is genuinely threaded through to
`expandBranchWithFuel` rather than shadowed by the engine default.

## 6. Verification actuals

| Gate | Result |
|------|--------|
| `lake build` (tree-wide) | **green**, 2331 jobs |
| `lake build BimodalTest` | 7 mismatches, exactly the Phase 29.2 pinned set (§3) |
| Live-tree sorries | **1** — `Metalogic/WeakCanonical/Transfer.lean:1084`, pre-existing, untouched |
| New sorries introduced | **0** (diff contains no `sorry`) |
| New axioms introduced | **0** (diff contains no `axiom`) |
| Vacuous definitions | **0** (no `:= True` / `:= trivial` / `:= Unit`) |
| `#print axioms decideBlocking` | `propext`, `Classical.choice`, `Quot.sound` — Mathlib baseline only |
