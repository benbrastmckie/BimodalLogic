# Implementation Summary: Task #595

- **Task**: 595 - Establish durable records home
- **Status**: [COMPLETED]
- **Started**: 2026-09-16T16:59:12Z
- **Completed**: 2026-09-16T19:26:00Z
- **Effort**: ~2.5 hours
- **Dependencies**: None
- **Artifacts**: plans/01_durable-records-home.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Moved the two durable-record families out of the ephemeral `specs/` tree into `docs/`:
`paper-definitions-of-record.md` to `docs/reference/`, and the two decision records
(`total-history-validity-decisions.md`, `untl-snce-argument-order.md`) to `docs/architecture/`.
Repointed every live referrer (Lean docstrings, two scripts, docs, typst comments,
`references.bib`, in-library READMEs), cleared the new gate exposure the move introduced
(`check-module-invariants.sh`'s C12/C15/C20 tier 2/C9D), and recorded the placement rule and
rationale in the docs READMEs so future records land in the right place.

## What Changed

- `docs/reference/paper-definitions-of-record.md` — moved from `specs/`, git history preserved
  (`git mv`); internal cross-refs, stale slash paths (`BaseLanguage/Axioms.lean` ->
  `Syntax/MinusLanguage/Axioms.lean`, `WorldHistory.lean` -> `ConvexHistory.lean`), `file.lean:NNN`
  citations converted to declaration names, and task-number citations rewritten to durable anchors
- `docs/architecture/total-history-validity-decisions.md`, `docs/architecture/untl-snce-argument-order.md`
  — moved from `specs/decisions/`, same treatment (stale/hypothetical slash paths reworded,
  `file.lean:NNN` citations converted, task-number citations rewritten)
- `scripts/check-paper-definitions.sh` — `RECORD_DEFAULT` and comment mentions repointed to the
  new path
- `scripts/check-module-invariants.sh` — `C15_RECORD` and comment mentions repointed; C15's
  cited-anchor walk now excludes the record file itself (it is the resolution source, not a
  citer), which is what let the anchor count return to 58 after the move
- `docs/theorem-index.md`, `docs/development/MODULE_INVARIANTS.md` — repointed (the two
  `theorem-index.md` links use the relative `reference/...` form, not the repo-root form)
- ~30 Lean docstrings under `FormalSystem/`/`Tests/`, 4 in-library READMEs, 5 typst files,
  `references.bib` — plain string substitutions of the old paths, comments/docstrings only
- `docs/reference/README.md` — new "Records of Record" table row
- `docs/architecture/README.md` — table renamed "Specification and Decision Documents" with two
  new rows; one-line pointer to the placement rule
- `docs/README.md` — new "Durable Records Placement" section with the full rule and rationale

## Decisions

- Both record families go under `docs/`, not `docs/decisions/` (already forbidden by
  `docs/architecture/README.md`'s single-ADR-convention rule): decision records in
  `docs/architecture/`, reference manifests in `docs/reference/`
- C15's cited-anchor walk excludes the record file itself rather than adding per-anchor
  KNOWN-ANCHORS rows for its own illustrative prose — the record is the resolution source, not a
  citer, and the decision records stay in scope (a real defect there still fails the gate)
- For each stale C12 slash path, distinguished "content moved" (cite the current path/successor
  module, e.g. `ConvexHistory.lean`) from "quoted text that no longer matches any live location"
  (reword without a slash path or line number, e.g. the struck-through original `untl`/`snce`
  argument-order argument) rather than mechanically repointing every citation to a same-shaped
  current path
- Left the pre-existing C13 `../../data/` failures, C9D's pre-existing 142 count, and all MANIFEST
  rows/hash values untouched, per the plan's non-goals

## Plan Deviations

- Phase 1's referrer-grep filter (`grep -v '^\./specs/'`) does not exclude `specs/**` on this
  system because `grep -r .` does not prefix `./`; used `grep -v '^specs/'` throughout instead to
  achieve the same exclusion
- `docs/development/MODULE_INVARIANTS.md`'s C15-wording edit and one hunk each in
  `FormalSystem/Semantics.lean`, `FormalSystem/Syntax/Formula.lean`,
  `scripts/check-module-invariants.sh`, and `docs/reference/paper-definitions-of-record.md` were
  swept into concurrently-running tasks' own commits (594's C27 work, 596's module-restructuring
  and Automation renames) rather than this task's phase commits, despite per-hunk isolation via
  `git apply --cached` performed immediately before each commit — a concurrent `git add` on the
  same shared file re-staged the full working-tree diff in the brief window before this task's own
  `git commit` executed. Content in every case is correct and consistent; only commit attribution
  is shared with tasks 594 and 596. See the Phase 2/3 progress files for the specific commits and
  files affected.
- Phase 4's full (build-gated) `check-module-invariants.sh` run was skipped: this task's edits are
  comment/prose-only, a full `lake build` is slow, and multiple other tasks were building
  concurrently in the same working tree, so a full run would have mostly measured their state
  rather than this task's

## Verification

- Build: N/A (comment/prose-only changes; no `.lean` code changed outside comments/docstrings)
- Tests: N/A
- Files verified: Yes — `grep -rnE "specs/paper-definitions-of-record|specs/decisions/" ... | grep -v '^specs/'` is empty; `bash scripts/check-paper-definitions.sh` matches the pre-move baseline (exit 1, same drift class, same dangling anchor); `bash scripts/check-module-invariants.sh --no-build` shows C12/C15 (both assertions, anchor count 58)/C20 (both tiers)/C13/C18/C9D all green or back at baseline, with zero FAIL in this task's scope; `git log --follow` on both moved paths shows pre-move history intact

## Impacts

- The two record families are no longer one `specs/` cleanup or vault operation away from
  breaking 43+ live citations
- `check-module-invariants.sh`'s C15 SCOPE note and comment now document that the record file is
  excluded from its own cited-anchor walk, which the paper-vocabulary reconciliation task
  (downstream of this one) inherits directly
- Future durable records have a documented, discoverable home (`docs/README.md`'s "Durable
  Records Placement") rather than an implicit convention

## Follow-ups

- One unrelated, pre-existing `check-module-invariants.sh --no-build` FAIL remains: "INV 3
  file(s) carry a stale generated inventory block" (`FormalSystem/Automation/README.md`,
  `FormalSystem/Syntax/README.md`, `README.md`), caused by concurrently-running tasks' in-flight
  module moves (not this task). Left for the owning tasks to resolve
  (`scripts/check-module-invariants.sh --emit-inventory` regenerates it once their moves land)
- `typst-sync-check.sh` reports 4 pre-existing/unrelated violations in
  `typst/chapters/p4-proof-automation.typ` (stale `AesopRules.lean`/`Tactics/Helpers.lean` paths),
  unrelated to this task's scope
- The paper-vocabulary reconciliation task (named in this task's ordering note) should re-pin
  `docs/reference/paper-definitions-of-record.md`'s MANIFEST against the current paper now that
  the file's new home is established

## References

- `specs/595_establish_durable_records_home/plans/01_durable-records-home.md`
- `specs/595_establish_durable_records_home/reports/01_durable-records-home.md`
- `specs/595_establish_durable_records_home/progress/phase-{1,2,3,4}-progress.json`
- `docs/README.md` ("Durable Records Placement" section)
