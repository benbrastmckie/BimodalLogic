# Phase 1 handoff — task 633

- **Commit**: `7e5fd0fd8` — task 633 phase 1: create the Tactic/ layer and merge the attribute modules
- **Immediate next action**: Phase 3 (move `Metalogic/Core/DeductionTheorem.lean` to `Theorems/`),
  then Phase 4, then Phase 2, then 5, then 6. Phase order is 1, 3, 4, 2, 5, 6 per the plan's
  parallelism caveat (`move-modules.py` rewrites tree-wide, so the wave-1 phases run serially).

## State at handoff

- `FormalSystem/Tactic/Attr.lean` (new, `import Lean` only) carries all five attribute/simp-set
  declarations; `FormalSystem/Init.lean` imports it; `FormalSystem/Tactic.lean` aggregator imports
  `Init` + `Tactic.Attr`; `FormalSystem/FormalSystem.lean` imports `FormalSystem.Tactic`.
- `Automation/{TruthNormAttr,NormalizationAttr,LemmaDB}.lean` deleted; all 13 import lines deleted.
- `scripts/CheckInitImportsMain.lean` has the third exception (`FormalSystem.Tactic.Attr`).

## Measurements at handoff

| Gate | Result |
|---|---|
| `lake build` | exit 0 (2655 jobs) |
| `check-module-invariants.sh` (full, build-inclusive) | ALL CHECKS PASSED |
| `measure-refactor-partitions.py upward-edges` | 59 total, 4 into Automation (all `Metalogic ->`); zero from Syntax/Semantics/ProofSystem/Theorems |
| `readme-lint.sh` | 21 broken refs (== baseline), 0 missing READMEs |

## Recorded red baselines (for the "no new rows" bar)

- `readme-lint.sh`: 21 broken references, 0 missing READMEs, 3 missing dates.
- `typst-sync-check.sh`: `TOTAL_VIOLATIONS=9`, `MISMATCH_COUNT=2` (`sorry-total committed=4
  live=0`, `sorry-table[WeakCanonical/...] committed=4 live=0`), `MODULE_MAP_MISMATCHES=0`,
  `MA_COUNT_MISMATCHES=0`.

## Key decisions

- "eleven minimal elements" -> "eight" is correct: the phrase counts direct importers of
  `FormalSystem.Init`, measured at 11 before and 8 after (the three deleted modules were three of
  the eleven).
- C20 line-number citations into `Syntax/Formula.lean` and `ProofSystem/DerivedAxioms.lean` shifted
  by one when the import lines were deleted; corrected by decrement (198->197, 149->148, 159->158,
  136->135, 211->210, DerivedAxioms 85->84), not by rewriting the citation style.

## Deviations

None. Phase 1 followed the plan.

## Operational note

Foreground `Bash` calls over ~600s are auto-moved to the background by the harness. Recovery that
works: `timeout 570 tail --pid=$(pgrep -f '<cmd>' | head -1) -f /dev/null`, repeated, which blocks
without ending the turn.
