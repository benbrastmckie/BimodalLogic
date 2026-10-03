# Implementation Summary: Task #721

- **Task**: 721 - Review and reconcile the decidability programme across L and L-plus
- **Status**: [COMPLETED]
- **Started**: 2026-10-03T15:25:08Z
- **Completed**: 2026-10-03T15:46:38Z
- **Effort**: 1 implementation dispatch (5 phases; 7 commits)
- **Dependencies**: None (consumes the completed task 718 round, the task 706/710 probe records, and the landed `WitnessFamily/Compression/` layer)
- **Artifacts**: plans/01_decidability-programme-review.md, followup-scope-spec.md, reports/01_decidability-programme-review.md, specs/ROADMAP.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Executed Deliverables 4 and 5 of the review: a revision specification in the
`specs/718_omega_sequence_decidability_full_lplus/followup-scope-spec.md` format of record, and the
reconciliation of `specs/ROADMAP.md` with the tree as it stands. Every anchor the two files cite
was re-verified this round (Section 0 of the specification: 27 declaration/script rows, a
task-record table from `specs/state.json`, a compile record with `#print axioms`), and the
research report's inventory (Deliverables 1-3) was confirmed with one namespace correction and one
stale declaration name found by the Phase 5 sweep. No write was made to `specs/state.json` or
`specs/TODO.md`, and no task was created, revised or abandoned.

## What Changed

- `specs/721_decidability_programme_review_l_and_lplus/followup-scope-spec.md` — Created (~720 lines). Header with the Option A caveat; Section 0 verification record; Sections A-G (tasks 712, 711, 713, 709, 719, 706/710/720, 430/412), each ending in an "Action required" line naming `/revise N`; "The 711 tension" (resolved by REVISE); Section H with five new-task specifications (H1 prose reconciliation, H2 `pinned:C14` grounding, H3 `Decidable (Derivable .ZTime [] φ)`, H4 backward-dual probe E1 with a fold-in rule, H5 re-runnable review); "Ranking ratification" for both languages with per-route hypothesis, falsifier and next experiment, stating where it supersedes 718's ranking; "State-write disclosure"; a trace table.
- `specs/ROADMAP.md` — Reconciled (commit `490140515` on pre-edit SHA `b5affb6e3`, plus one Phase 5 wording fix). Header re-dated with the 563/718 landings; Fronts table (718 and 563 removed from open cells; 720, 721, 711-revised added; tableau-spine row states that Z-time validity of L is already decided); Phase 0 annotated only -- three bullets gained appended evidence sentences with their original text preserved verbatim, one new unchecked item added (confirm/overturn Option A), no checkbox state changed (6 unchecked, 0 checked); Phase 1 (718's four items annotated completed with verdicts, keystone hypothesis `[F.IsRegular]` stated, E1/E2/E3 added, determinization decision quoted verbatim with its evidence condition marked met, Blocked-by and Run updated); Phase 2 (709 re-described as R1's summary step, 706/710 items as Option A library landing, 720 item added, Run block re-ordered); Phase 3 (563 annotated completed, edges updated); Phase 6 (`Compression.decidableValidZTime` stated with its qualifiers; 430 item gains the L-E3 oracle); Open Risks (filtration CLOSED for Z, determinization row rewritten as necessity-shown/device-unselected, "Zero sorries" row gains the companion fact and a corrected `verifyProof` claim, two new rows for H1 and H2, 2EXPTIME row gains its ceiling role); Success Metrics (Option A caveat, `pinned:C14` metric, oracle clause); Recommended Execution Order (563/718 struck, E1 inserted, 709 moved under the gluing route); Maintenance (H5 named as owner-until-filed; inventory baseline named).
- `specs/721_decidability_programme_review_l_and_lplus/plans/01_decidability-programme-review.md` — Phase markers and checklist items updated through all five phases.
- `specs/721_decidability_programme_review_l_and_lplus/progress/phase-{1..5}-progress.json`, `handoffs/phase-{1..4}-handoff-*.md` — Created (tracking artifacts).

## Decisions

- The 711 tension is resolved by REVISE, not by choosing ABANDON or REVIVE: the probes answered device necessity, not the FMP route 711 was filed on nor the closed route the ROADMAP ruled on. The Phase 0 ruling is restated as newly answerable and left to the user.
- Option A (library landing) is carried as the adopted reading of the Success Metric, with the verbatim caveat that it was adopted autonomously under a non-blocking `user_decision`, is not a user ruling, and is re-openable via `/revise`; the ROADMAP's Phase 0 gains an unchecked item asking for confirmation.
- Phase 0 annotations were appended to the existing bullet lines rather than added as new bullets, so the git hunk shows those three lines as modified; the original bullet text is preserved verbatim as a prefix and no checkbox changed. Recorded here rather than described as pure additions.
- Section 0 records line numbers "as of this round"; every citing section uses declaration names and paths only.
- `FormalSystem.Metalogic.BXCanonical.derivable_of_validZTime` is cited by its full name (the report gave only its path); H3 depends on it.

## Plan Deviations

- None (implementation followed plan). One sweep-found correction outside the plan's enumerated edits, permitted by Phase 5's "any typo fix found by the sweeps" scope: the `verifyProof` declaration named by the pre-edit ROADMAP, task 482's description and the research report does not exist in the tree; both ROADMAP occurrences were reworded to checkable claims and the finding was recorded in the specification's Section 0.5.

## Verification

- Build: N/A (no Lean source changed; `lake env lean` on a scratch `#check`/`#print axioms` file succeeded for every headline declaration -- Section 0.1)
- Tests: N/A; `bash scripts/check-evidence-probes.sh` exit 0 (`PASS all 14 wired probe(s) compile`) as the Section 0 baseline
- Files verified: Yes
- Phase 5 sweeps (commands and outputs recorded in the dispatch; results): declaration sweep -- 96 backticked identifiers checked, every one resolves to a definition or is explicitly described as retired/unwritten/Mathlib, except `verifyProof` (corrected as above); hypothesis sweep -- 0 mentions of `seamFibreEquiv`/`seamOmegaEquiv`/`plusStab_iff_rays`/`plusStab_iff_omega` without `IsRegular` in the same paragraph or row, in either file; every `decidableValidZTime` mention qualified by ZTime and `Formula`/no `⊡`; negative-conclusion -- no "open question" wording near `not_sliced_complete`/`not_finite_width_fmp`, WITHDRAWN and REFUTED stated as such; complexity -- every `EXPTIME` hit is the 713 lower-bound ceiling; soundness -- `plusTruth_iff_mem`/`plusRefutes_of_certifies` appear only in Section 0's compile record as untouched anchors; state-write -- `git diff --name-only 03ccb6d49..HEAD` lists only `specs/721_decidability_programme_review_l_and_lplus/**` and `specs/ROADMAP.md`; ROADMAP headers all match `^## Phase (\d+): (.+?) \((\w+) Priority\)`; Phase 0 block 6 unchecked / 0 checked.
- `specs/state.json` and `specs/TODO.md`: read, not written, by this task. The orchestrator's own status-sync writes to those files are outside this task's commits and are not counted against it.

## Impacts

- Every programme-level view of decidability now states the two-statement distinction: the tableau `isValid` biconditional is open at all four frame classes, while `Compression.decidableValidZTime` (ZTime, `Formula`, empty premises) is proved.
- The gluing route's next experiment is fixed as E1 (the backward-dual probe on a time-asymmetric fixture), and 711 is re-described so that device selection is a probe outcome rather than an assumption.
- Tasks 712, 711, 713, 709, 719, 706, 710, 720, 430, 412 each have a concrete `/revise` specification; five new tasks are specified for `/task`.

## Follow-ups

- User rulings (ROADMAP Phase 0, unchanged by this task): 712 terminal status; 711 ABANDON vs REVISE; 713 keep vs abandon; confirm or overturn Option A.
- Execute the specification: `/revise 712`, `/revise 711`, `/revise 713`, `/revise 709`, `/revise 719`, `/revise 710`, `/revise 706`, `/revise 720`, `/revise 430`, `/revise 412`; `/task` for H1, H2, H3, H5 (H4 only if 719 is not dispatched in the cycle).
- Task 482's description names a `verifyProof` stub that does not exist; re-verify at its next `/revise` (out of this task's scope).
- The research report's §1.2 row for proof extraction carries the same stale name; the report is not edited by this task (Section 0.5 records the difference).

## References

- `specs/721_decidability_programme_review_l_and_lplus/reports/01_decidability-programme-review.md` (Deliverables 1-3, the inventory of record)
- `specs/721_decidability_programme_review_l_and_lplus/plans/01_decidability-programme-review.md`
- `specs/721_decidability_programme_review_l_and_lplus/followup-scope-spec.md` (Deliverable 4)
- `specs/ROADMAP.md` (Deliverable 5; commits `490140515` and the Phase 5 fix)
- `specs/718_omega_sequence_decidability_full_lplus/followup-scope-spec.md` (format of record), `.decisions.json` (the determinization decision)
- `specs/721_decidability_programme_review_l_and_lplus/.decisions.json` (Option A, cycle 1)
