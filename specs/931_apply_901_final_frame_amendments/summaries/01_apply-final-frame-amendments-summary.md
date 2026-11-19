# Implementation Summary: Task #931

- **Task**: 931 - Apply the final-frame amendments to the 901 two-sided Reynolds engine paper-proof report
- **Status**: [COMPLETED]
- **Started**: 2026-11-19T18:06:18Z
- **Completed**: 2026-11-19T18:22:00Z
- **Effort**: 1.25 hours (as estimated)
- **Dependencies**: None
- **Artifacts**: plans/01_apply-final-frame-amendments.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

This is a record correction, not a completeness claim. The 901 two-sided Reynolds engine
paper-proof report (`specs/archive/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md`)
recorded the final-frame step as resting on two unlanded Lean pieces that in fact landed on
2026-11-09, four to six hours after the report was committed. All eight stale surfaces (across
seven physical lines) have been corrected in place by content match, using task 927's verbatim
amendment text, with the report's own refusal to claim the final-frame step preserved exactly
once inside the amended Risks bullet.

## What Changed

- `specs/archive/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md`:
  - **Phase 1 (four drift-only citation corrections, no claim change)**: the compiled-ingredient
    row (`OrientedForest.lean:134`, `HistoryMorphism.lean:589` -> `:880`, `:707`), the §15.3
    route-prose citation (`:134` -> `:880`), the evidence/status table row (same drift), and the
    reads list (`:134` -> `:880`; `:306,589` -> `:335,707`).
  - **Phase 2 (four claim-changing corrections)**: the `**missing**` ingredient row now records
    `exists_orientedForest_cover_of_constraints` (`UniversalCover.lean:591`) and
    `plus_invariance_of_isZTime_of_constraints` (`HistoryMorphism.lean:681`) as **compiled**; the
    weakest-link Risks bullet is replaced by the fully merged `**Amended 2026-11-13.**` text
    (task 927's Finding (3), with the 901 report's own refusal sentence — "This write-up does not
    claim the final-frame step; it claims the engine up to it." — appended as its final
    sentence); the companion Risks bullet's one clause now reads "one step (the final frame), now
    resting on landed pieces"; and §15.3's stale "**The two missing pieces, named.**" paragraph is
    replaced by the same amendment text rendered as a plain paragraph (no list marker, no
    appended refusal sentence — that sentence occurs exactly once, in its Risks home).

## Decisions

- **Adopted the plan's Decision 1 (an eight-anchor, not seven-anchor, work list)**: §15.3's "The
  two missing pieces, named." paragraph (live line 910 at measurement time) is replaced, not left
  standing, per both task 927's Finding (3) and this dispatch's own description, and because
  leaving it would have the report contradict itself two sections apart (line 110 flipped to
  **compiled**, line 910 still calling the same pieces **missing**).
- **Verified all five live Lean citations against source before editing**, rather than trusting
  the plan's figures: `saturation_of_orientedForest` at `OrientedForest.lean:880`,
  `plus_invariance_of_isZTime` at `HistoryMorphism.lean:707`,
  `plus_invariance_of_isZTime_of_constraints` at `HistoryMorphism.lean:681`,
  `exists_preimage_step_neg` at `HistoryMorphism.lean:335`, and
  `exists_orientedForest_cover_of_constraints` at `UniversalCover.lean:591`. All five confirmed
  exact. The `@[nolint unusedArguments]` claim on `plus_invariance_of_isZTime` was also confirmed
  accurate (`HistoryMorphism.lean:699-707`).
- **No `user_decision` raised** — nothing in this task required the user's judgment; the plan's
  own Decision 2 already settled this and nothing arose during implementation to reopen it.

## Plan Deviations

- **Every phase's `git diff` hunk-count verification criterion was replaced with a snapshot-diff
  plus grep-count equivalent.** Discovery made during Phase 1: the sole edit target,
  `specs/archive/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md`,
  lives under `specs/archive/`, which `.gitignore` line 94 excludes wholesale. `git ls-files` and
  `git log` both confirm the file has never been tracked, so `git diff`/`git status` show nothing
  for it regardless of how many edits are made. This was not anticipated by the plan (written
  before the plan-time grep confirmations checked git-tracking status). Substituted throughout:
  before/after full-file snapshots in the session scratchpad plus the grep-count verification
  the plan already specifies for every edit, run after each phase's edits. Recorded non-fatally
  via `issue-record.sh` (class "scope excursion", severity minor) and in each phase's progress
  file `deviations` array. The substance of every verification criterion was still checked and
  passed — only the mechanism (`diff`/grep vs. `git diff`) changed. This is expected, by-design
  behavior for `specs/archive/` (the vault/archive storage area for completed tasks), not a repo
  defect, and no task's own `specs/931_*` artifacts (plan, progress, handoffs, this summary) were
  affected — those remain normally git-tracked and were committed phase-by-phase as usual.
- A related, purely cosmetic point: the plan's Phase 2/3 verification describes "exactly four
  changed hunks" (Phase 2) and "exactly eight changed hunks" (cumulative), counting *anchors*.
  Because two Phase-2 anchors (live lines 1001 and 1002) are textually adjacent with no
  intervening unchanged line, any line-based diff tool — `git diff` or plain `diff` alike —
  merges them into one reported hunk. The snapshot diffs therefore show 3 hunk-groups for Phase 2
  (not 4) and 4 hunk-groups for Phase 1 (whose four anchors are all on non-adjacent lines, so no
  merging occurs there). No edit was missed or extra in either phase; every one of the eight
  anchors was independently confirmed by its own named grep check.

## Verification

- Build: N/A (no `.lean`, `.toml`, or script file touched; `suite_selection_select` returns
  `__FULL_SWEEP__` for the single touched markdown path, so no suite applies).
- Tests: N/A, for the same reason.
- Files verified: Yes.
  - `bash .claude/scripts/validate-artifact.sh specs/archive/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md report` — PASS, 0 warnings.
  - `bash .claude/scripts/validate-artifact.sh specs/931_apply_901_final_frame_amendments/plans/01_apply-final-frame-amendments.md plan` — PASS, 0 warnings.
  - `bash .claude/scripts/validate-state.sh` — PASSED WITH WARNINGS (0 failures; all warnings pre-existing, unrelated to this task).
  - Closure sweep (`OrientedForest.lean:134`, `HistoryMorphism.lean:589`, `HistoryMorphism.lean:306`, and the three stale phrasal forms): zero hits — enumeration closed at exactly eight anchors across seven physical lines (110, 908, 910, 1001, 1002, 1047, 1075); no ninth stale site found.
  - Residual-staleness sweep (`unlanded`, `**unverified**`, `**missing**`): exactly one surviving hit, line 112's unrelated programme-report reference (row 2, `LCU`) — the deliberate, enumerated non-anchor the plan names.
  - Must-not-touch surfaces: §15.2's line-904 "the quotient is not an oriented forest" assessment confirmed byte-unchanged across all snapshots; the refusal sentence occurs exactly once, inside the amended Risks bullet, as added/retained text only; `Recommendation 8`/(O1)/(O3)/(O4) all fall outside every edited line.
  - Report line count unchanged at 1084 throughout; internally consistent (no surface still calls the two pieces missing while another calls them compiled).

## Impacts

- The 901 report's final-frame surfaces now accurately reflect the landed state of
  `exists_orientedForest_cover_of_constraints` and `plus_invariance_of_isZTime_of_constraints`
  (both landed 2026-11-09). A future reader of the Risks section or §15.3 will no longer be
  misled into thinking the universal-cover route rests on unlanded Lean work.
- **This does not make T3 complete and does not advance the completeness programme.** Rows
  17-21 of the 879 programme report's ingredient table remain paper; (O1), (O3), and (O4) are
  untouched; the 901 report's Recommendation 8 (barring formalization of sections 7-15) is
  unaffected and was confirmed byte-unchanged.
- Discovered, and recorded for future tasks touching `specs/archive/**`: that directory is
  wholesale `.gitignore`'d, so any correction to an archived report's content is a local-disk-only
  change, never a git-visible one. Future record-correction tasks on archived artifacts should
  expect the same and plan their verification accordingly (grep/snapshot-diff, not `git diff`).

## Follow-ups

- None. The eight-anchor enumeration is closed (confirmed by Phase 3's closure sweep); no ninth
  stale site was found; no blocker was encountered.

## References

- Plan: `specs/931_apply_901_final_frame_amendments/plans/01_apply-final-frame-amendments.md`
- Research report: `specs/931_apply_901_final_frame_amendments/reports/01_apply-final-frame-amendments.md`
- Source of the verbatim replacement text: `specs/927_final_frame_step_remeasure_against_landed_cover/reports/01_final-frame-step-remeasure.md`, Finding (3)
- Source of the complete eight-anchor work list: `specs/927_final_frame_step_remeasure_against_landed_cover/plans/01_final-frame-step-remeasure.md`, `#### Phase 1 Notes`
- Amended artifact: `specs/archive/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md`
- Progress files: `specs/931_apply_901_final_frame_amendments/progress/phase-{1,2,3}-progress.json`
- Handoffs: `specs/931_apply_901_final_frame_amendments/handoffs/phase-{1,2}-handoff-*.md`
