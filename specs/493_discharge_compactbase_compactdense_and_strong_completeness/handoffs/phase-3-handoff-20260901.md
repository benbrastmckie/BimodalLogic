# Phase 3 Handoff — task 493

## Immediate next action
Phase 4 (paper-side record and author-memo retirement), then Phase 5 (C14 wiring, acceptance).

## State
Seven documentation files corrected. The re-grep of the six declaration names across
`README.md`, `docs/`, and `FormalSystem/Metalogic/README.md` returns no hit co-occurring with
`open` / `obligation` / `unsettled` / `undischarged`.

## Key decisions
- Every `SetConsequence.lean` line-number citation was RE-DERIVED live, not copied. The plan's
  own "live values" (`:209/:217/:255/:262`) were themselves stale by the time of implementation.
  Actual: `StrongCompletenessBase` :306, `CompactBase` :314, `ModelExistenceBase` :335,
  `StrongCompletenessDense` :352, `CompactDense` :359, `ModelExistenceDense` :379,
  `not_setConsistent_of_setDerivable_bot` :280.
- `known-limitations.md`'s `Metalogic.lean:83-101` anchor re-derived to `:98-116`.
- `FormalSystem/Metalogic/README.md` line counts all re-derived (`StrongCompleteness.lean` is
  943, not the plan's 924); the "Six loose files" count became "Seven".
- `API_REFERENCE.md` gained a whole `Compactness` module section, not just table rows.
- `FormalSystem/Semantics/README.md` confirmed (not assumed) to need no change: line 24 already
  carries the `Ultraproduct/` row.

## Known pre-existing lint state (NOT caused by this task)
`scripts/readme-lint.sh` exits 1 on a missing `FormalSystem/Semantics/Ultraproduct/README.md`
(landed without one by the prior ultraproduct work) and on `FormalSystem/Automation/README.md`
inventory gaps. Check 2 does NOT list `Compactness.lean`, so this task's own obligation there
is met.

## Deviations
None.
