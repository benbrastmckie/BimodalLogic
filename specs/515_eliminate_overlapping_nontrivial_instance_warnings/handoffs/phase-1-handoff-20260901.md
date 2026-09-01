# Phase 1 Handoff — FlowFrame.lean

**Next action**: Phase 2 (Decidable.lean, 5 Class A deletions at :2144, :2149, :2162, :2172, :2762).

**State**: FlowFrame.lean edited — ` [Nontrivial D]` deleted from 13 declaration lines
(466, 472, 479, 483, 491, 498, 506, 514, 521, 533, 549, 678, 803). `git diff --stat`: 13 insertions /
13 deletions, one file.

**Evidence**: `lake env lean FormalSystem/Metalogic/Algebraic/FlowFrame.lean` exit 0;
`Overlapping instance parameters` 13 -> 0; `automatically included section variable` 11 -> 1
(residual at :635 `fmcs_box_persistent`, pre-existing and out of scope); total file warnings 24 -> 1;
0 errors.

**Baseline artifacts** (scratchpad `.../scratchpad/t515/`): `baseline-build.log` (full pre-edit
build, 2506 jobs, 21 overlapping, 381 `warning:` occurrences, 97 unusedSectionVars, 0 errors),
`base-warn-loc.txt` / `base-warn-noloc.txt` (sorted warning-header sets for the Phase 4 `comm -13`
gate), pristine copies `FlowFrame.lean.orig`, `Decidable.lean.orig`, `TruthLemma.lean.orig`.

**Decisions**: none beyond the plan. No deviations.
