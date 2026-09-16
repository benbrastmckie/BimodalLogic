# Implementation Summary: Task #593

- **Task**: 593 - Revise task organization codebase cleanup
- **Status**: [COMPLETED]
- **Started**: 2026-09-16T15:55:00Z
- **Completed**: 2026-09-16T16:30:00Z
- **Effort**: ~0.6 hours
- **Dependencies**: None
- **Artifacts**: plans/01_cleanup-topic-reorganization.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Reorganized the non-proof codebase-improvement backlog into a single `codebase-cleanup` topic
with 19 members and an acyclic six-wave dependency DAG. Only task metadata changed
(`specs/state.json`, `specs/archive/state.json`, `specs/TODO.md`); no Lean, docs, typst, or CI
file was modified. Every state write went through `state-write.sh` (mutex-guarded) because other
implement agents were running at the same time.

## What Changed

- `specs/state.json` — new topic `codebase-cleanup` added to `active_topics`; 15 existing tasks
  re-topicked (506, 540, 569, 578, 581-591)
- `specs/state.json` — four new tasks created: 594 `relocate_in_library_smoke_tests` (lean4),
  595 `establish_durable_records_home` (markdown), 596 `nest_semantics_language_family_files`
  (lean4), 597 `adopt_mathlib_standard_linter_set` (lean4); descriptions label all counts as
  reorganization-time measurements
- `specs/state.json` — 583 rewritten: now wires only the checks that pass today
  (`check-module-invariants.sh`, strict `check-copyright-headers.sh`, `readme-lint.sh`) and
  records the per-script wiring pattern; its dependencies on 581/582/586/590 were removed
- `specs/state.json` — final "wire own script into CI" phases added to 581, 582, 584, 586;
  586 widened to all retired-tactic prose outside `docs/`; 590 widened to a `docs/` staleness
  audit and now owns the `ENFORCE_C9_DOCS=1` flip; 584 absorbs the `MinusLanguage/Axioms.lean:76`
  naming audit; 589 absorbs the 3 broken `specs/` citations; 578 gets the package-name decision
  (cslib precedent); 585 gets the `--wfail --iofail` vs baseline note; 506 gets its ordering note
- `specs/state.json` — 588 absorbs 542's attribute/simp-set reachability step and the
  `release_unfold` dispute (re-verified: registered `@[formula_unfold]`, consumed only by the
  Normalization smoke block and `NormalizationTest.lean`)
- `specs/archive/state.json` — 542 archived as `abandoned` ("merged into 588")
- `specs/state.json` — 56 stale dependency references pruned across 27 active tasks (e.g. 177
  now depends on 428/429/430 only)
- `specs/state.json` — 481 pointer refreshed to `MintBound/ClosureResidual.lean` (definition
  :836, refutation :889, carrying theorem :1139) and `file_scope` updated; status `blocked` and
  `blockers` unchanged. 428 dependencies pruned to [465]; status unchanged
- `specs/TODO.md` — regenerated
- `specs/593_revise_task_organization_codebase_cleanup/state.pre-593.json` — pre-edit backup

Final topic DAG (Kahn layering output, run on the written state):

| Wave | Tasks |
|------|-------|
| 1 | 594, 595, 596, 581, 582, 583, 587, 591, 578 |
| 2 | 584 (582, 591, 596, 595), 586 (591), 590 (595) |
| 3 | 585 (583, 584), 506 (586), 569 (584) |
| 4 | 597 (585), 588 (585, 591, 594, 569) |
| 5 | 540 (588, 597) |
| 6 | 589 (588, 540, 597, 584, 591, 596) |

## Decisions

- Phase 4 ran before Phase 3, following the plan's own wave table, so rescoped descriptions
  could cite the real new task numbers (594-597)
- All four new tasks were created in one atomic `state-write.sh` filter that reads and bumps
  `next_project_number`, so a concurrent writer could not take the same numbers
- 481's historical prose ("DEPENDENCIES: [434]", sequencing note about 462) was kept and a
  dated pointer-refresh paragraph was added, not rewritten
- 589 no longer lists 585 directly (it still depends on it through 588), matching the report's table

## Plan Deviations

- **Phase 1** altered: 56 stale dependency references were found, not the report's 36; all
  point at archived completed tasks and all were pruned
- **Phase 5** altered: `validate-state.sh` exits 1, but the failures are the same 10 schema-drift
  failures the pre-edit backup already had (unknown fields such as `blockers`, `parent_task`,
  `active_goal`). This work added no new failure
- **Phase commits** altered: one commit at the end, as Phase 5 says, instead of one per phase.
  `specs/state.json` is shared with other agents working at the same time, so a commit per phase
  would have repeatedly picked up their in-progress entries

## Verification

- Build: N/A (no Lean file modified)
- Sorry count: 0 introduced (no Lean file modified)
- Vacuous count: 0 introduced
- Axiom count: unchanged
- Topic member count: 19; missing dependency references across all active tasks: 0
- DAG: acyclic, 6 waves, matching the plan table
- 542 absent from `active_projects`, present in the archive as `abandoned`
- 428 and 481 still `blocked`, `blockers` byte-identical to the backup
- `validate-state.sh`: the same failures as the pre-edit baseline, no new ones
- Files verified: Yes

## Impacts

- `/orchestrate` and TODO.md Task Order now show the cleanup work as one topic, with the waves
  running from structural moves and decisions through to line-sensitive work
- Each repair task (581, 582, 584, 586, 590) now wires its own check into CI when it finishes,
  so 583 is no longer the bottleneck

## Follow-ups

- Topic-taxonomy guidance (report "Context Extension Recommendations") belongs in the agent
  source store `agent-system/extensions/**`; not done here (out of scope)
- `validate-state.sh`'s schema drift (10 pre-existing unknown-field failures) is untasked

## References

- specs/593_revise_task_organization_codebase_cleanup/reports/01_cleanup-topic-reorganization.md
- specs/593_revise_task_organization_codebase_cleanup/plans/01_cleanup-topic-reorganization.md
- specs/593_revise_task_organization_codebase_cleanup/.decisions.json
