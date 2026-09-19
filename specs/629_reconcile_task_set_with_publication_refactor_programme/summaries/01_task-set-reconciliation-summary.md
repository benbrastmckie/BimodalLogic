# Implementation Summary: Task #629

- **Task**: 629 - Reconcile task set with publication refactor programme
- **Status**: [COMPLETED]
- **Started**: 2026-09-19T09:30:00Z
- **Completed**: 2026-09-19T11:00:00Z
- **Effort**: ~2.5 hours
- **Dependencies**: None
- **Artifacts**: plans/01_task-set-reconciliation.md, summaries/01_task-set-reconciliation-summary.md (this file)
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Turned the committed publication refactor programme (`docs/development/PUBLICATION_REFACTOR.md`
Sections 7-9, ADR-010, ADR-011) into concrete task-management state: created nine new follow-up
tasks (630-638, corresponding to the programme's letters A-I) with dependencies and `file_scope`,
revised five existing open tasks that collide with the programme, merged one artifact-free task
into the deliverable-hygiene follow-up, and abandoned it with a recorded reason. All writes went
through `.claude/scripts/state-write.sh` (mutex-guarded) followed by `generate-todo.sh`. No file
under `FormalSystem/`, `Tests/`, `docs/`, or `scripts/` was modified — this was task-management
work only, entirely confined to `specs/**`.

## What Changed

- `specs/state.json` — nine new task entries (630-638); `next_project_number` advanced 630 -> 639;
  five existing tasks revised (604, 614, 177, 178, 429); eight categorical-front tasks (563-567,
  616-618) annotated; task 610 removed from `active_projects`.
- `specs/archive/state.json` — task 610 added to `completed_projects` with `status: "abandoned"`
  and a recorded merge reason (untracked by git; not part of any commit diff).
- `specs/TODO.md` — regenerated from `specs/state.json` after each state write.
- `specs/629_reconcile_task_set_with_publication_refactor_programme/progress/phase-{1,2,3}-progress.json` — created.
- `specs/629_reconcile_task_set_with_publication_refactor_programme/summaries/01_task-set-reconciliation-summary.md` — this file.

## Created Tasks (A-I -> 630-638)

| Task | Slug | Type | Dependencies | Programme phase |
|---|---|---|---|---|
| 630 | move_tool_and_boneyard_relocation | lean4 | none | Phases 0+2, ADR-010 |
| 631 | deliverable_hygiene_excluding_specs | general | none | Phase 1 |
| 632 | bimodaltools_split | lean4 | 630 | Phase 3 |
| 633 | upward_edges_by_relocation | lean4 | 630 | Phase 4 |
| 634 | language_extension_directories_and_probe_tests | lean4 | 626, 632, 633 | Phase 5 |
| 635 | expressiveness_extraction | lean4 | 634 | Phase 6, ADR-011 |
| 636 | docstring_and_citation_normalisation | lean4 | 635 | Phase 7 |
| 637 | ci_parity_root_collapse_publication_gate | lean4 | 636 | Phase 8 + publication gate |
| 638 | post_publication_size_splits_and_module_system | lean4 | 637 | Phase 9, optional |

Each description is the Section 9 paste-ready text (substance unchanged) plus a
"Reconciliation notes:" paragraph carrying the collision-resolution addenda below. Each also
carries a `file_scope` array (derived from the programme's own file inventory, not copied from
the document — cross-checked against the live tree during Phase 1) and `topic:
"publication-quality"`.

### A/B ordering (630/631) — resolved: no dependency edge

The document's `0 -> 1 -> 2` chain would literally require task 631 (Phase 1) to land between
task 630's two halves (Phases 0 and 2), which is impossible for a single follow-up task. Resolved
per the research report: ADR-010 itself disclaims dependence on the frozen-LaTeX retirement
Phase 1 performs, and Phase 1's other actions touch no path under `FormalSystem/Boneyard/`.
**No dependency edge exists between 630 and 631** — either may land first. This is recorded on
both tasks' descriptions. Tasks 632 and 633 depend on 630 only, preserving the programme's
`2 -> {3,4}` order without requiring 631.

## Existing-Task Dispositions

| Task | Disposition | Rationale |
|---|---|---|
| 604 | Revised: `dependencies += [631, 632]` | 604's script inventory covers `migrate_schema_v2.py`/`standardize_metadata.py` (deleted by 631) and `FormalSystem/Automation/*Main.lean` exes (re-rooted by 632); depending on both lets 604 write its inventory directly against post-move state instead of being rewritten twice |
| 614 | Revised: narrowed to 42 files, `dependencies += [634]` | 5 of 614's 47 stale-README targets sit in directories 634 merges away (`Syntax/{Plus,Minus,Star}Language/README.md`, `Semantics/{Plus,Minus}Language/README.md`); 634 refreshes those 5 in its own commit, 614 handles the other 42 after 634 lands |
| 177 | Revised: `dependencies += [635, 636]` (keeping 428, 429, 430) | 177's residual scope (drift re-audit plus Axiom Reference update) is materially different from 636's citation-form normalisation, so kept as a separate task rather than merged, but sequenced after both 635 (Expressiveness rename) and 636 (citation form) so its final pass sees the post-refactor state |
| 178 | Revised: `dependencies += [635]` | 178 cites Kamp-named results that 635 renames; 632 also edits `Examples/BimodalProofs.lean` imports, covered transitively via 635's own dependency chain (635 <- 634 <- {632, 633}) |
| 429 | Revised: `file_scope` gains the post-634 path `Tests/BimodalTest/Metalogic/Decidability/TemporalWitnessProbe.lean` alongside the current path; **no dependency edge** | 429 is open-ended mathematics with no fixed timeline (gated behind task 428); blocking 634's mechanical relocation on 429's completion would stall the whole programme behind unrelated open mathematics. At 634's execution time: check 429's live status; if 429 is in flight, exclude `TemporalWitnessProbe.lean` from that pass and relocate it in a small follow-up once 429 lands |
| 563, 564, 565, 566, 567, 616, 617, 618 | Revised: citation-convention note appended, **no dependency edge** | Unrelated categorical-front mathematics; each description now notes adopting 636's `* [Author, *Title*][key]` citation form (against the root `references.bib`) once 636 lands, or migrating to it if drafted first |
| 610 | **Merged into 631, abandoned** | Pure grep-and-fix of stale `lakefile.lean` mentions in `docs/`, the same doc-cleanup class as 631's Phase-1 hygiene work; had zero artifacts (`specs/610_*/` never existed), so no confirmation gate applied. 610's full description body was copied verbatim into 631's own note per the plan's explicit instruction. Archived with `status: "abandoned"` and reason "merged into task 631 ... scope" |

## Scheduling Notes (Not Dependency Edges)

- **632 (BimodalTools split)**: dispatch after tasks 298, 296 and 282 land — all three are
  currently `partial` and actively editing `FormalSystem/Automation/`. This is a scheduling
  recommendation carried in 632's own description addendum, not a `dependencies` array entry,
  because a hard edge would incorrectly block 632 on those three tasks' *eventual* completion
  rather than merely recommending an order.
- **634 vs 429**: see the 429 row above — live-check-then-decide at execution time, not an edge.
- **637 (publication gate) vs 625**: no edge in either direction. Task 625 (`researched`, active
  now) edits `FormalSystem/FormalSystem.lean` directly; 637 replaces that file with an
  `mk_all`-generated aggregator and is programme-terminal (phase 8 of 9), so it will very likely
  be dispatched long after 625 lands regardless, and `mk_all`'s generation is automatic over
  whatever `.lean` files then exist.

## Verified Non-Collisions (No Action)

Confirmed by direct file/description inspection during Phase 1 fresh re-verification (all still
hold): task 257 (`.gitattributes` already empty; 257's own remaining work is HF-Hub-credential
blocked and never touches that file again); task 231 (lake exe target names unchanged by 632);
tasks 298, 296, 282 themselves (their in-flight status is the scheduling fact above, not a graph
edge); the decidability chain (410-412, 428-430, 464, 465, 481, 482 — lives entirely under
`Metalogic/Decidability/Verified/` plus three named files, file-disjoint from 633's touches);
task 412 (its cited `GroupModel/CountermodelBase.lean` stays in the residual 38-file set 635 does
not move); tasks 534 and 559 (no path citations into the Expressiveness-moved subtree; "Kamp" is
mentioned only as a concept name); tasks 125, 497-502 (497 and 499 already cite the archive using
the post-move shorthand, so 630's move improves rather than breaks these citations).

## specs/ Disposition at the Publication Gate

Recorded as a **non-blocking default**, not decided unilaterally: keep `specs/` tracked while the
programme runs; untrack `specs/` and the associated non-deliverable files (`CLAUDE.md`,
`.claude-extensions.json`, `.syncprotect`, `.gitattributes`) in one commit at the publication gate
(task 637). This default and the two alternatives (keep published permanently; move to an
unpublished branch before the gate) are recorded in 637's own description; nothing before 637
acts on this choice, so no work is wasted if the eventual choice differs. **This decision still
requires the user's confirmation before 637's gate commit executes** — see `user_decision` in
`.return-meta.json`.

## Resulting Dependency Graph

```
630 (move tool + Boneyard)  631 (deliverable hygiene)
   |          |                    |
   |          +--------------------+---> 604 (zstd datasets)
   v          v
632 (BimodalTools)   633 (upward edges)
   |______________________|
             v
   634 (language-ext dirs + probes)  <-- 626 (L+ citation repair)
             |
             +----------------------------> 614 (README staleness, narrowed)
             v
   635 (Expressiveness extraction)
             |
             +----------------------------> 178 (examples/demo)
             v
   636 (docstring/citation normalisation)
             |
             +----------------------------> 177 (final doc pass, kept separate)
             v
   637 (CI parity, root collapse, publication gate)
             |
             v
   638 (post-publication splits, optional)
```

Verified via Python topological sort over all 58 active tasks (Phase 4): zero self-edges, zero
dangling dependency references (every `dependencies` entry resolves to an existing active or
archived task), zero cycles.

## Decisions

- A and B (630/631) are independent, no dependency edge (see A/B ordering above).
- C and D (632/633) both depend on A (630) only.
- E (634) depends on C, D and 626 (new edge to 626, justified by direct file overlap); no edge to
  429 (open-ended math must not gate a mechanical hygiene phase).
- F, G, H, I (635-638) form the programme's stated `5 -> 6 -> 7 -> 8 -> 9` chain, unchanged.
- 610 merged into 631's scope, abandoned with reason.
- 604 gains dependencies on 631 and 632.
- 614 narrows to 42 files and depends on 634.
- 177 stays separate from 636 but gains dependencies on 635 and 636.
- 178 depends on 635.
- No dependency edges added for: 257/631, 625/637, the decidability chain/633, 412/635, 534,
  559/635, 125/497-502/630, 231/632, 298/296/282/632 (scheduling fact, not a graph edge).
- specs/ disposition recorded as a non-blocking `user_decision` with a stated default.

## Plan Deviations

- **Phase 3 verification "`validate-state.sh` passes on `specs/state.json` and
  `specs/archive/state.json`"** altered: both files fail `validate-state.sh`, but for reasons
  pre-existing and independent of this task's writes. `specs/state.json` carries 10 pre-existing
  FAIL items (unknown top-level/entry fields such as `blockers`, `parent_task`, `researched`) —
  confirmed identical by running `validate-state.sh` against the pre-task-629 commit
  (`2c7d619f2^`). This task's own writes introduce zero new FAIL items, only advisory
  WARN-level `file_scope`-coarseness notices (expected, since several `file_scope` entries name
  broad directories like `FormalSystem/Automation/`, `docs/`, `scripts/` per the programme's own
  file inventory). `specs/archive/state.json` errors on `validate-state.sh` because that script
  assumes the live `active_projects` schema, while the archive file uses
  `completed_projects`/`archived_projects` — confirmed identical against the archive file's
  pre-task-629 content. Both are tool/schema-scope limitations that predate this task.

## Verification

- Build: N/A (task-management only; no `FormalSystem/`, `Tests/`, `docs/`, or `scripts/` file
  touched — confirmed via `git diff --name-only <baseline>..HEAD | grep -v '^specs/'` returning
  empty).
- Tests: N/A.
- Files verified: Yes — nine new task entries confirmed present with `jq` query
  (`select(.topic=="publication-quality")`); five revised tasks' post-edit `dependencies`
  confirmed by direct `jq` query; task 610 confirmed absent from `active_projects` and present in
  `specs/archive/state.json`'s `completed_projects` with `status: "abandoned"` and a recorded
  reason; dependency graph acyclicity and existence-of-target confirmed via a standalone Python
  topological-sort script over all 58 active tasks; `check-task-references.sh` reports 0
  unexempted occurrences.

## Impacts

- The publication refactor programme now has nine concrete, dependency-ordered, `file_scope`-
  scoped tasks ready for dispatch via `/orchestrate`, starting with 630 and/or 631 (no edge
  between them).
- Five existing open tasks (604, 614, 177, 178, 429) now carry accurate dependencies/file_scope
  notes reflecting the programme's planned file moves, preventing a future dispatch from working
  against stale paths or racing an in-flight move.
- Eight categorical-front tasks (563-567, 616-618) carry a citation-convention note so their
  eventual `## References` sections adopt 636's form without needing separate reconciliation.
- One artifact-free task (610) is retired, its scope preserved verbatim inside 631.
- The `specs/` disposition at the publication gate remains an open, non-blocking question for the
  user, recorded on task 637 and flagged in `.return-meta.json`.

## Follow-ups

- User confirmation needed (non-blocking) on the `specs/` disposition at the publication gate
  (task 637): keep-tracked-then-untrack-at-gate (default), keep published permanently, or move to
  an unpublished branch before the gate.
- At 632's dispatch time: verify tasks 298, 296, 282 have landed (scheduling note, not enforced by
  a dependency edge).
- At 634's dispatch time: live-check task 429's status before moving
  `Tests/BimodalTest/TemporalWitnessProbe.lean` (see 429's row above).

## References

- `docs/development/PUBLICATION_REFACTOR.md` (Sections 7-9) — source of truth for the programme
- `docs/architecture/ADR-010-Boneyard-At-Repository-Root.md`,
  `docs/architecture/ADR-011-Extract-Expressiveness.md` — the two Proposed decisions grounding
  tasks 630 and 635
- `specs/629_reconcile_task_set_with_publication_refactor_programme/reports/01_task-set-reconciliation.md` — research report (round 01)
- `specs/629_reconcile_task_set_with_publication_refactor_programme/plans/01_task-set-reconciliation.md` — implementation plan (round 01)
- `specs/629_reconcile_task_set_with_publication_refactor_programme/progress/phase-{1,2,3}-progress.json` — per-phase progress records
