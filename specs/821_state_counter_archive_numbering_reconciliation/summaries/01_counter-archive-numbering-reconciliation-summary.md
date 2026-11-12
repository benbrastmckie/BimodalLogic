# Implementation Summary: Task #821

- **Task**: 821 - state_counter_archive_numbering_reconciliation
- **Status**: [COMPLETED]
- **Started**: 2026-11-12T17:56:00Z
- **Completed**: 2026-11-12T20:30:00Z
- **Effort**: 3 hours
- **Dependencies**: None
- **Artifacts**: plans/01_counter-archive-numbering-reconciliation.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md,
  source-store-deploy-boundary.md, no-task-references-in-deliverables.md,
  no-record-versioning-in-deliverables.md

## Overview

Attested, with fresh measurements, that the previously-deployed membership-based allocation
bound (`scripts/lib/project-number-inuse.sh`) discharges both consequences the task description
named: `state-write.sh --allocate-into` no longer refuses on the counter-vs-archive relation, and
`validate-state.sh --deep` is no longer permanently red. Declined the second candidate remedy
(relocating the five pre-reset-era archive outliers to `specs/vault/`) with evidence, corrected a
stale cross-reference comment in `state-write.sh`, and added a durable schema subsection so a
future reader does not re-apply the counter-raise this task's evidence rules out.

## What Changed

- `agent-system/extensions/core/scripts/state-write.sh` (source-store repository
  `/home/benjamin/.config/nvim`) — corrected the `Sibling expression that must stay in sync:`
  comment's trailing sentence, which wrongly described Check 12 as computing a combined maximum;
  it now names `scripts/lib/project-number-inuse.sh` as the shared definition both sites consume.
  Comment-only change, verified via `bash -n` and a line-scoped `diff`.
- `agent-system/extensions/core/context/reference/state-management-schema.md` (source-store
  repository) — new `### Archive Numbers Above next_project_number` subsection, between
  `### Top-Level Fields` and `### Retired Top-Level Fields`, documenting that an archive
  `project_number` above the counter is an expected steady state under the membership-based
  allocation bound, not a counter defect.
- `agent-system/extensions/core/index-entries.json` (source-store repository) — reconciled
  `line_count` for the edited schema file (762 -> 782).
- `specs/821_state_counter_archive_numbering_reconciliation/records/01_numbering-remedy-decision.md`
  (new) — the durable decision record: measurement tables, discharge attestation (BEFORE and
  AFTER `validate-state.sh --deep` readings), the five outlier rows' evidence, and the
  vault-relocation remedy decision (DECLINED) with its evidence.
- `specs/821_state_counter_archive_numbering_reconciliation/plans/01_counter-archive-numbering-reconciliation.md`
  — all four phases checked off with completion/deviation annotations.
- This repository's deployed `.claude/` tree — regenerated via `deploy-headless.sh`
  (`RESULT=landed_verify_clean`), propagating both source-store edits above.

No file under `specs/archive/` or `specs/state.json`'s `next_project_number` was modified; both
are confirmed unchanged across the whole task.

## Decisions

- **Vault-relocation remedy (candidate ii): DECLINED.** `project-number-inuse.sh`'s own header
  states the `specs/vault/**` exclusion exists so a vault operation can recycle a *deliberately
  vacated* number range; the five outlier rows are not that — four carry real archived
  directories cited in git history, and relocating them would make their numbers re-issuable,
  risking a future collision with an existing archived directory. No countervailing evidence was
  found. The already-deployed membership-based allocator (candidate i) remains the sole applied
  remedy.
- Deferred the source-store git commit to Phase 4 (after both source-store edits landed), per the
  plan's own structure, rather than committing per-phase in the source-store repository.

## Plan Deviations

- **Task 4.1** (commit source-store edits with an explicit file list) altered: a bare
  `git commit -m` in the source-store repository (after `git add --` of this task's three
  explicit files) swept in one pre-existing, partially-staged foreign hunk
  (`agent-system/extensions/lean/index-entries.json`, one `line_count` value, confirmed correct
  on its face against the actual file). Not reverted — history rewrite on a shared tree with a
  possibly-live foreign writer is prohibited, and the content is benign. Logged via
  `issue-record.sh` (class "scope excursion", severity minor) and reported to the team lead.
- **Task 4.4** (run the complete `verify-deploy.sh` gate set) altered: discharged per this
  dispatch's Batch Gate Deferral directive via its UNMAPPABLE CRITERION path — neither
  `run-all.sh --only` nor `verify-deploy.sh --only-gate`, run from this deploy-consumer
  repository, reaches the source-store-only gates that actually cover this task's edited files
  (they unconditionally `[SKIP]` here). The substantive scoped check is the six-suite
  `run-all.sh --only` subset already run from the source-store repository root in Phase 3 (6
  passed, 0 failed). `deploy-headless.sh`'s own bundled `verify-deploy.sh` run (deploy-consumer
  gates only) is reported separately as the redeploy's own confirmation.
- The plan's own "dense 844-925 (77 values)" estimate was re-measured as 73 archived values in
  that span; corrected in the plan and decision record. Does not change the remedy decision.
- The plan's Phase 1 task wording attributed the fallback-route `jq` read to `commands/task.md`
  Step 6; it is actually Step 1, flowing into Step 6's write via `$next_num`. Corrected in the
  plan annotation; the fallback route itself is confirmed intact either way.

## Verification

- Build: N/A (no Lean/code build affected)
- Tests: `bash .claude/scripts/validate-state.sh --deep specs/state.json` — BEFORE exit 0, AFTER
  exit 0, identical tally (19 passed / 19 warnings / 0 failed), Check 12 PASS both times.
  `state-write.sh --allocate-into --dry-run` probe: derives 926 (dense next-free number); refused
  only by the unrelated audit-evidence gate (exit 5), never by the allocator. `bash -n` on the
  edited `state-write.sh`: exit 0. Six-suite `run-all.sh --only` subset (re-confirmed via
  `suite_selection_select`): 6 passed, 0 failed.
- Files verified: Yes — deployed copies of both edited source-store files confirmed
  byte-identical to their sources; `specs/archive/state.json` confirmed byte-unchanged;
  `specs/state.json`'s `next_project_number` confirmed unchanged (926); `commands/task.md`'s
  fallback route confirmed present and unmodified.

## Impacts

- `state-write.sh --allocate-into` and `validate-state.sh --deep` Check 12 remain correctly
  aligned on the membership-based bound; a future reader of `state-management-schema.md` now has
  a positive, durable statement explaining why an archive row can sit above the counter, closing
  the risk that someone "repairs" this by raising the counter again (which previously cost two
  task numbers' worth of unnecessary allocation, per the task description's own measured
  history).
- The `Sibling expression that must stay in sync:` comment in `state-write.sh` now correctly
  names its sync partner, removing a latent source of confusion for a future editor of either
  side of that pairing.

## Follow-ups

- None. The vault-relocation remedy was considered on its merits and declined with evidence,
  closing that open question rather than deferring it.
- Flag for the team: a foreign, apparently still-in-progress writer's staged change to
  `agent-system/extensions/lean/index-entries.json` was inadvertently included in this task's
  source-store commit (see Plan Deviations, Task 4.1). The content is correct; no action is
  required unless that other writer's own commit expectations are affected.

## References

- Plan: `specs/821_state_counter_archive_numbering_reconciliation/plans/01_counter-archive-numbering-reconciliation.md`
- Decision record: `specs/821_state_counter_archive_numbering_reconciliation/records/01_numbering-remedy-decision.md`
- Source-store commit (repository `/home/benjamin/.config/nvim`): `7635cdcb2`
