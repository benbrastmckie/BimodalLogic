# Implementation Summary: Task #540

- **Task**: 540 - Docstring coverage for class, instance, and lemma declarations
- **Status**: [COMPLETED]
- **Started**: 2026-09-18T18:27:27-07:00
- **Completed**: 2026-09-18T18:45:00-07:00
- **Effort**: ~20 minutes
- **Dependencies**: None
- **Artifacts**: plans/01_instance-docstring-coverage.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

C19 now reports refined docstring coverage per keyword. Every one of the 79 live `instance` declarations has a docstring, up from 59. `class` was already at 21/21, and `lemma` has 0 live declarations because C23 forbids them. All three named categories therefore meet the 90% floor individually. C19's counting rule did not change.

## What Changed

- `scripts/check-module-invariants.sh`: C19 keeps a per-keyword tally of refined documented/total and prints one `INFO  C19  per-keyword (refined): ...` line per keyword, in a fixed order. A keyword with zero declarations prints `n/a`, and a keyword below the floor is flagged. The change is reporting-only: `FAILURES` is untouched and no `ENFORCE_` flag was added. The header comment's stale per-keyword figures were replaced by a pointer to the new output, and the historical aggregate figures are labeled "at adoption".
- 20 new instance docstrings, all in the three-register style: what the instance is, plus the caller trap where one exists.
  - `FormalSystem/Metalogic/Decidability/BiLasso/Decide.lean` has 6. `instDecidableClauseAt`, `instDecidableLocalCoherentAt`, `instDecidableEventClauseAt` and `instDecidableFulfilAt` are documented plainly. The `instDecidableUntlOblB` and `instDecidableSnceOblB` docstrings add a trap: only the bounded form is decidable, so decide the unbounded obligation through `untlObl_iff_bounded` or `snceObl_iff_bounded`.
  - `FormalSystem/Metalogic/Decidability/BiLasso/Enumerate.lean`: `instDecidableIsLasso`.
  - `FormalSystem/Metalogic/Decidability/Verified/Bridge/BranchOrder.lean`: `instDecidableBranchLT`, which `linearOrderOfSTO` needs.
  - `FormalSystem/Metalogic/Bundle/LimitMCS.lean` has 2, `limitFilterBelow_neBot` and `limitFilterAbove_neBot`. Trap: the named filters are `def`s, so instance search cannot see through them to `limitFilter`.
  - `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/Defs.lean` has 2, `instInStructureClassUnrestricted` and `instInStructureClassCountableDense`. Trap: a bare `CountableDense` proof is not picked up by instance search.
  - `FormalSystem/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` and `.../RealModel/GoodDense.lean`: the two `intervalCarrierLinearOrder` instances. The real-line one's docstring says why it is `noncomputable`.
  - `FormalSystem/Metalogic/WeakCanonical/NormalForm.lean` has 3. `atomKindDecEq` is documented plainly. The `normalFormFintype` and `normalFormDecEq` docstrings add a trap: the two instances are built jointly and cannot be derived separately.
  - `FormalSystem/Semantics/LexCarrier.lean` has 2, `instSuccOrder` and `instPredOrder`. The existing plain `/- -/` rationale now sits above the new `/--`.
  - `FormalSystem/Semantics/Ultraproduct/IndexFilter.lean`: `tailFilter_neBot`.
- Citation shift, a consequence of the docstrings: 34 `NormalForm.lean:NNN` and `GoodDense.lean:NNN` line citations in 14 live WeakCanonical files were renumbered by the number of lines inserted above their targets. Every shifted citation was asserted to land on the same source text as before the edit.

## Decisions

- **Citations were shifted, not renamed.** C20 recommends replacing line citations with declaration names. Many of the affected citations were already approximate before this task; for example, `NormalForm.lean:201` pointed at a section header. Choosing a declaration for each one would mean guessing the author's intent, so each citation was shifted to keep exactly what it pointed at before. Boneyard citations were left alone, since they cite archive-era text and C20 did not flag them.
- **No instance was made `private`.** Instance resolution consumes all 20, which follows the plan's non-goal.

## Plan Deviations

- **Phase 1**, re-run check altered: a concurrent task added a Lean file mid-phase, so the full-script baseline drifted. Aggregate identity was verified instead by running the HEAD and edited C19 heredocs on the same tree snapshot. The aggregate lines were byte-identical, 10202/10876.
- **Phase 4**, unplanned fix: the inserted docstrings shifted line numbers that other files cite, which made C20 tier 1 fail 9 citations. All 34 affected live citations were renumbered, and C20 now passes. This work was committed with Phase 4.

## Verification

- Build: Success. Full `lake build` is green, re-run after the citation edits.
- C19 per-keyword (refined):
  - class 21/21 = 100.00%
  - instance 79/79 = 100.00%
  - lemma n/a (0 declarations; C23 forbids lemma)
  - theorem 91.03%, def 99.29%, abbrev 100%, structure 99.47%, inductive 100%
- C19 aggregate (refined): 10234/10888 = 93.99%, at least the 92.34% bound.
- C19 counting rule: unchanged. The HEAD and edited heredocs give identical aggregates on the same tree.
- C20: PASS on both tiers. C23: PASS.
- C28: FAIL. The cause is an unrelated file, `FormalSystem/Metalogic/Independence/LimitClosureCountermodel.lean` (6 `linter.style.show` warnings, no baseline entry), added by a concurrent task in commit 92a66a17c. It does not come from this task's changes.
- Sorry count: 0 new. All census hits are in the Boneyard.
- Vacuous count: 0 new. The one pattern hit, `FormalSystem/Examples/TemporalStructures.lean:481`, predates this task and is a theorem whose goal is `True`.
- Axiom count: 15, unchanged.
- `git diff` of the Lean files shows only comment additions and citation renumbering.

## Impacts

- C19 now shows category-level gaps on every run, so a regression in a small category is no longer hidden by the theorem-dominated aggregate.

## Follow-ups

- The C28 warning-budget failure belongs to the concurrent Independence work. Its owner needs to fix the `linter.style.show` warnings or add a justified budget entry.
- Line citations of the form `file.lean:NNN` break whenever a file above the cited line is edited. Converting the WeakCanonical citations to declaration names would remove that fragility.

## References

- specs/540_docstring_coverage_class_instance_lemma/plans/01_instance-docstring-coverage.md
- specs/540_docstring_coverage_class_instance_lemma/reports/01_docstring-coverage-gaps.md
