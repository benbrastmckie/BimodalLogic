# Implementation Summary: Task #846

- **Task**: 846 - membership_based_task_number_allocation
- **Status**: [COMPLETED]
- **Started**: 2026-11-03T20:03:00Z
- **Completed**: 2026-11-03T23:15:00Z
- **Effort**: ~3.25 hours
- **Dependencies**: None
- **Artifacts**: plans/01_membership-based-allocation.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md,
  source-store-deploy-boundary.md, no-task-references-in-deliverables.md,
  no-record-versioning-in-deliverables.md

## Overview

Replaced the max-based `--allocate-into` bound in `state-write.sh` and `validate-state.sh`'s
Check 12 with a membership-based bound: the allocator now issues the smallest number absent from
the in-use set (active plus archived, excluding `specs/vault/**`) that is strictly greater than
the maximum active `project_number`, never the smallest unused number counting from 1. Both sites
consume a single new shared library (`lib/project-number-inuse.sh`) rather than each computing
the bound independently. `next_project_number` is now a regenerable cache rather than the
allocation authority: the issued number is always derived, the counter is still validated
fail-closed (absent, non-numeric, or itself in-use refuses with no write), and it is rewritten to
the freshly-derived free number after each successful allocation. The repository's live counter
was repaired from 1055 to the dense value 847.

## What Changed

All production edits land in the source store
(`/home/benjamin/.config/nvim/agent-system/extensions/core`) and reach `.claude/**` only by
`deploy-headless.sh`.

- `scripts/lib/project-number-inuse.sh` — new shared library: `pnum_active_numbers`,
  `pnum_archive_numbers`, `pnum_inuse_set`, `pnum_active_max`, `pnum_next_free`,
  `pnum_location`, exported as jq `def` source text for splicing into a caller's own jq program.
- `manifest.json` — one new `provides.scripts` entry.
- `scripts/state-write.sh` — sources the new library; the `--allocate-into` allocation prefix
  now binds the derived `pnum_next_free` to the caller's `$NAME` instead of the counter, with a
  membership check (not a max comparison) on the existing counter; the former monotonic
  counter-advance assertion is replaced by a recording assertion (the issued number must appear
  in the staged result's own in-use set) plus an in-mutex cache-regeneration step that rewrites
  `next_project_number` to the fresh derived value after the caller's transform, on both the
  main write path and the `--dry-run` preview path. Header comment and worked example updated.
- `scripts/validate-state.sh` — sources the new library via the same multi-candidate pattern as
  `status-vocabulary.sh`/`file-scope-overlap.sh`; Check 12 is now a single jq invocation that
  FAILs only when the counter is absent, non-numeric, or itself in use (never merely below some
  maximum), and PASSes otherwise, naming the derived free number as the repair target on FAIL.
  Header comment and checks inventory updated.
- `scripts/test-state-write-concurrency.sh` — lib allow-list extended; Cases 11-13 realigned to
  the membership bound and the recording assertion; new Case 15 covers the "smallest unused
  number counting from 1" trap at the allocator layer.
- `scripts/tests/test-validate-state.sh` — lib allow-list unaffected (uses the deployed/
  source-store validator directly); Fixtures (a)-(d) and (g) realigned (two inverted outcomes,
  three reworded), new Fixture (h) (two parts) covers the same trap at the validator layer.
- `scripts/test-state-write-spill-names.sh`, `scripts/test-state-write-large-payload.sh`,
  `scripts/test-state-write-regen-timing.sh`, `scripts/tests/test-orchestrate-cycle-plan.sh` —
  lib allow-list extended only (no allocation-semantics change).
- `context/reference/state-management-schema.md` — `next_project_number` field description
  rewritten to state it is a regenerated cache, not an authority.
- `specs/state.json` — counter repaired from 1055 to 847, via `state-write.sh` under the mutex.

## Decisions

- Counter-advance wrinkle (required by the task description): resolved as the counter becoming a
  regenerable cache (option (b)), not the allocation authority. The rejected alternative (keep
  the counter as authority, weaken the advance assertion) is recorded on its own merits in the
  plan's Design Decision section — it would require every caller to re-derive the free number
  itself, reintroducing the exact drift a single shared definition exists to remove.
- A heredoc-read exit-status hazard in the new library (`read -d ''` returns 1 on EOF with no
  NUL delimiter) was discovered and fixed with a trailing `|| true`, since `state-write.sh`
  sources it under `set -euo pipefail` and would otherwise abort at source time.

## Plan Deviations

- Phase 4's trap-case fixture for `test-validate-state.sh` was split into two sub-fixtures
  (h-i, h-ii) rather than written as one, since Check 12 has no reportable "next free" value on
  its PASS path — see the plan's Phase 4 body for the full reasoning.
- Phase 2's plan enumeration named Fixtures (b)/(c)/(d)/(g) for text/outcome realignment; Fixture
  (a)'s PASS-line text also needed updating (outcome unchanged) once Check 12's PASS message was
  reworded — discovered and completed in Phase 4.

## Verification

- Build: N/A (shell scripts)
- Tests: `test-state-write-concurrency.sh` 15/15; `test-validate-state.sh` 72/72 (deployed copy);
  `test-state-write-spill-names.sh`, `test-state-write-large-payload.sh`,
  `test-state-write-regen-timing.sh`, `test-orchestrate-cycle-plan.sh` all green, unchanged.
  Full `run-all.sh` sweep: 130/156 pass; the 26 failures are 2 pre-existing baseline entries plus
  24 sharing one single pre-existing, unrelated cause (see Phase 5's Reasoned Exclusions record
  in the plan) — none touch any file this task edited.
- Files verified: Yes (byte-identical diff between source store and deployed tree for every
  propagated file, confirmed after each of the three deploys this task performed)

## Impacts

- Allocating a new task number in this repository (or any other deploying this source store) now
  issues the smallest number above the active max that is not already in use, rather than one
  past the largest number ever seen across active and archived history — closing the gap that let
  the live counter drift to 1055 while only 846-850 remained meaningfully contested.
- `next_project_number` is no longer a value any caller should treat as an allocation input; it
  is a read-only, self-correcting cache. No production caller currently reads it for anything
  other than display, so this is a non-breaking narrowing of its contract.
- `specs/vault/**` exclusion, the fail-closed posture, the mutex scope, and archive append-only
  immutability are all unchanged.

## Follow-ups

- None required by this task. The 24 pre-existing, unrelated `run-all.sh` failures (absent local
  `agent-system/extensions` directory in this repository) are a candidate for a separately
  spawned record if that gap is ever worth closing; this task does not spawn one, since it is
  outside the owning record's scope and the dispatch did not ask for it.

## References

- Plan: `specs/846_membership_based_task_number_allocation/plans/01_membership-based-allocation.md`
- Progress files: `specs/846_membership_based_task_number_allocation/progress/phase-{1..5}-progress.json`
- Handoffs: `specs/846_membership_based_task_number_allocation/handoffs/`
- Owning record: `821` (`state_counter_archive_numbering_reconciliation`)
