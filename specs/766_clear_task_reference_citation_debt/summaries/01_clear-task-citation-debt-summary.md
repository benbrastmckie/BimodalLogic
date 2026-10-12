# Implementation Summary: Task #766

- **Task**: 766 - Clear the repo-wide task-number citation debt that fails check-task-references.sh
- **Status**: [COMPLETED]
- **Started**: 2026-10-12T10:26:42Z
- **Completed**: 2026-10-12T11:30:00Z
- **Effort**: ~1 hour
- **Dependencies**: None
- **Artifacts**: plans/01_clear-task-citation-debt.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

`bash .claude/scripts/check-task-references.sh` previously exited 1 on 198 pre-existing
unexempted task-number citations, making the unscoped gate useless as a regression signal. All
198 occurrences across 53 files (`Boneyard/**` tombstone READMEs and retired `.lean` module
comments, `Tests/BimodalTest/**` and `Tests/BimodalToolsTest/` property-suite and quarantine
comments, and one illustrative-string occurrence in `scripts/check-module-invariants.sh`) were
resolved via durable-anchor rewrites. The gate now exits 0 with
`PASS: 0 unexempted task-reference occurrences`.

## What Changed

- `Boneyard/**/README.md` (24 files) — Archival header, "Why Archived"/"What Was Removed"
  prose, and cross-reference sections rewritten to drop `Task N` identifiers while keeping
  dates, filenames, and named refactors as the durable anchor. `## Task Cross-References` /
  `## References` sections retitled to `## Change History`; contentless identifier-only bullets
  (e.g. `- Task 130: This archival`) folded into the header's existing `Archived:` date instead
  of surviving as empty bullets.
- `Boneyard/**/*.lean` (9 files) — `Task #N` section headings and inline issue-attribution prose
  cleared. Where an attribution carried real content (the F-persistence counterexample), the
  durable anchor `f_preserving_seed_consistent` in `UltrafilterChain.lean` was named in its
  place.
- `Tests/BimodalTest/{Syntax,Semantics,ProofSystem,Property}/**` (6 files) — The two dominant
  quarantine-note comment templates (`-- (Task 365) quarantined:` / `-- NOTE (Task 365):
  quarantined`) bulk-rewritten via anchored `sed`; residual definition-provenance comments and
  section headings hand-fixed.
- `Tests/BimodalTest/{Automation,Integration,Theorems}/**` and `Tests/BimodalToolsTest/C5SmokeTest.lean`
  (13 files) — Same quarantine templates plus denser hand-fixed prose: `blocked by task 315`
  references replaced with the named blocker ("proof-term construction") rather than the
  tracker row; `**Phase N Tests (M-M)**` test-index ranges preserved verbatim since they are not
  matched by `TASK_PATTERN`.
- `scripts/check-module-invariants.sh` — The quoted illustrative forbidden form `"task 42"`
  converted to the `"task {N}"` placeholder (taxonomy category 5), which `TASK_PATTERN`
  structurally cannot match.

## Decisions

- Durable-anchor rewrites were used exclusively; zero `task-ref-ok` markers were added anywhere
  in the task, confirmed by a marker-delta audit (`git diff main -- . | grep -c 'task-ref-ok'`
  returned 0).
- Where an attribution's only content was the task identifier, the bullet was dropped entirely
  (not retained as a contentless line) when the surrounding header already carried the relevant
  date.
- Pre-existing record-versioning language unrelated to task citations (e.g. "previously
  problematic" in `C5SmokeTest.lean`) was left untouched — only the task-identifier clause
  adjacent to it was excised, per the minimal-excision principle and this task's scope boundary.

## Plan Deviations

- None (implementation followed plan). The plan's phasing reference to "API Grift/Drift Notes"
  in `Generators.lean` was a paraphrase of the file's actual heading text ("API Drift Notes"),
  matched by content/intent per the dispatch's matching contract — not a literal mismatch and
  not recorded as a deviation.

## Verification

- Build: Success (`lake build` 2841 jobs, `lake build BimodalTest` 2904 jobs,
  `lake build BimodalToolsTest` 1965 jobs — all "Build completed successfully")
- Tests: N/A beyond the build runs above (no test behavior was changed; comment/docstring-only
  edits)
- Files verified: Yes — `bash .claude/scripts/check-task-references.sh` exits 0 with
  `PASS: 0 unexempted task-reference occurrences`; `git diff --stat` against the pre-task
  baseline confirms changes confined to `Boneyard/**`, `Tests/**`, and
  `scripts/check-module-invariants.sh`

## Impacts

- The unscoped `check-task-references.sh` gate is now a live regression signal rather than
  permanently failing on standing debt — a future citation introduced anywhere in the repo will
  now be caught.
- `bash .claude/scripts/verify-deploy.sh` passes with 14 checks, 0 failures (gate 4, the
  task-reference lint gate, correctly `[SKIP]`s on this deploy-consumer tree; the direct lint
  invocation stands as the authoritative acceptance evidence).

## Follow-ups

- None.

## References

- Plan: `specs/766_clear_task_reference_citation_debt/plans/01_clear-task-citation-debt.md`
- Taxonomy: `.claude/context/standards/task-reference-exemptions.md`
- Progress files: `specs/766_clear_task_reference_citation_debt/progress/phase-{1..5}-progress.json`
- Handoffs: `specs/766_clear_task_reference_citation_debt/handoffs/phase-{1..5}-handoff-*.md`
