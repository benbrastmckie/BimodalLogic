# Implementation Summary: Task #990

- **Task**: 990 - Rereview pr11 at rewriteable pointed truth head
- **Status**: [COMPLETED]
- **Started**: 2026-11-23T09:44:10Z
- **Completed**: 2026-11-23T09:52:00Z
- **Effort**: ~10 minutes (the measurement this phase consumes was done by the research dispatch)
- **Dependencies**: None
- **Artifacts**: plans/01_approve-pr11-and-update-followup.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The re-review verdict for pull request #11 at head `b2eb3ac0b` was already measured and settled
by the research dispatch: all three posted conditions met, gates green in a from-scratch review
worktree, recommendation approve. This phase turned that verdict into the two prose deliverables
the task named — a draft approval body and a reconciled follow-up record — after re-confirming,
twice, that the head had not moved. No Lean source, no generated surface and no repository code
was touched, and nothing was posted, pushed, merged or approved.

## What Changed

- `specs/reviews/pr-reviews-2026-11-21/pr11-approval.md` — Created. The draft approval body for
  PR #11 at `b2eb3ac0b`, 61 lines. Addresses all three conditions by name and in order, each
  marked met; states what `At` usability now measurably means (the working idiom is
  `simp only [at_def, TruthEnv.T, <language clause lemma>]`, it works on goals and on hypotheses
  with `... at h` and at L, L⁺ and L⋆ including L⋆'s `ℕ → F.Duration` environment, `at_def` is
  load-bearing because omitting it leaves `simp` with no progress, and `rw` to a clause lemma
  under `At` still does not work because the per-language clause lemma is stated about the
  instance projection); carries three notes marked explicitly as not conditions; credits the
  definitional agreement that landed early; confirms the after-the-merge list stands unchanged;
  and states plainly what the gates certify and what they do not.
- `specs/reviews/pr-reviews-2026-11-21/FOLLOWUP.md` — Modified across all six enumerated #11
  mentions: the preamble heads sentence, item 1's `**Outcome**` extension, a new item 5 for the
  approval, the `## Decided` bullet, the `## Still open` entry, and the `## Backing reports`
  paragraph. The posted-record sentence for `pr11-comment.md` was preserved intact.
- `specs/990_rereview_pr11_at_rewriteable_pointed_truth_head/plans/01_approve-pr11-and-update-followup.md`
  — Phase markers advanced to `[COMPLETED]`, checklist items ticked, three deviation annotations
  applied, and per-phase `**Verification Notes**` blocks added recording the probe output and the
  covering checks.
- `specs/reviews/pr-reviews-2026-11-21/pr11-comment.md` — Deliberately **not** modified. Verified
  byte-unchanged against the values read at planning time: 45 lines, opening "Thank you. This is
  the contribution I asked for".

No `.lean`, `README.md`, `FormalSystem/**` or `typst/generated/**` path was modified.

## Decisions

- The verdict was not re-litigated. The research dispatch's measurement was consumed, not
  reproduced; the one thing that could have overturned it was the head moving, and that was the
  Phase 1 gate rather than a prompt to re-measure.
- The approval is a new file rather than an edit of `pr11-comment.md`, which is the record of what
  was actually posted at 2026-11-23T01:57:16Z against `c6cd983b79842368ae789488d38e488656f98992`.
- The approval was appended to the post list as item 5 rather than inserted at position 2 with the
  list renumbered. Renumbering would have had to edit the #8 entry's own self-reference ("now in
  the post list above as item 4"), which the plan forbade; appending is also this list's
  established convention. Posting order is conveyed inside item 5's own text instead.
- #10's head in the shared preamble sentence was reconciled from the stale `bdaa3b6d0` (draft,
  clean) to `ada7074dd` (no longer draft) — the value the file's own `## Still open` section
  already recorded. Rewriting that sentence while knowingly preserving a contradiction the file
  itself already contradicts was the worse option.
- The `## Still open` re-read item for `pr11-comment.md`'s changed follow-up section was left
  open rather than closed. It belongs to the other #11 review's territory; what was added is the
  measured fact that nothing in this push touches any item on the list, so the list stands
  unchanged against the new head.

## Plan Deviations

- **Phase 1**, stop-condition item skipped: the head matched the pinned sha, so the
  write-nothing-and-return-blocked branch did not fire.
- **Phase 2**, Scope Hypothesis overshot: the body landed at 61 lines against a hypothesised
  35-55. A first draft at 64 was cut to 61; no further cut was made, because every remaining
  paragraph discharges a Phase 2 checklist item and the only route to 55 was rewrapping at a
  wider column, which games the metric rather than cutting substance. Recorded in `issues.jsonl`.
- **Phase 3**, post-list placement altered: appended as item 5 rather than inserted at position 2,
  for the reason given under Decisions.

## Verification

- Build: N/A — no `.lean` path, no generated surface and no repository code was touched by any
  phase. The Lean gate evidence this task relies on (`lake build --wfail` at 3010 jobs,
  `lake test` at 3086, `lake lint`, full `check-module-invariants.sh` ALL CHECKS PASSED, and a
  69-declaration `#print axioms` sweep, all at `b2eb3ac0b` in a from-scratch worktree) was
  measured by the research dispatch and is cited, not reproduced.
- Sorry count: 0 (no Lean source touched)
- Vacuous count: 0 (no Lean source touched)
- Axiom count: unchanged (no Lean source touched)
- Tests: N/A
- Files verified: Yes
- **Scoped discharge of Phase 4's `full` tier**: `bash .claude/scripts/verify-touched.sh`, per the
  dispatch's Batch Gate Deferral directive. The complete gate set is DEFERRED to the orchestration
  close for the whole batch rather than independently run here; the deferral is recorded, not
  forgiven. No unmappable criterion arose.
- **The scoped run was not clean, and the failure is named rather than glossed**: 84 passed, 1
  failed (NEW), 10 skipped, 95 total. The single failure is
  `.claude/scripts/tests/test-deploy-baseline-lib.sh`, case "control: a genuinely matching
  warm-cache entry was expected to skip gate 1 but did not" — the standing, environment-specific
  defect in `verify-deploy.sh`'s gate-cache warm-path logic, already reproduced twice in freshly
  created isolated scratch directories and so not a concurrency artifact. It is not attributable
  to this task: nothing under `modified_files` is a `.claude/**` or `.lean` path. The suite was
  selected only because `verify-touched.sh` derives touched paths from the whole working tree plus
  the committed diff against its own determined base, which under this multi-task batch takes in
  sibling tasks' and prior sessions' changes; it narrowed to 91 suites on that basis, not on this
  task's four files. Recorded in `issues.jsonl`.
- `bash .claude/scripts/validate-artifact.sh <this file> summary` passes.
- Head re-confirmed twice: `b2eb3ac0b57d0f6082235aee0b861d8249bd7687` at 2026-11-23T09:45:17Z
  (Phase 1) and again at 2026-11-23T09:50:58Z (Phase 4), `OPEN`, `MERGEABLE`, `updatedAt`
  2026-11-23T04:33:16Z both times. CI run `45112546558` on that sha: `success`. Zero issue
  comments and zero review comments on #11, so there was no contributor prose to answer.
- `grep -nE '\b[Tt]asks? [0-9]+'` over `pr11-approval.md` returns nothing.
- `git status --short -- specs/reviews/` is empty. `/specs/reviews/` is listed in
  `.git/info/exclude`, so both review deliverables are uncommittable by design and a
  `git-commit-scoped.sh` exit 8/9 skip for those paths is the documented non-failure, not a gap.

## Impacts

- Nothing was posted, pushed, merged or approved. Both review files are local drafts; the user
  posts. The standing pre-post instruction in `FOLLOWUP.md` — re-check each head immediately
  before posting — applies to the approval exactly as to the other items.
- The unblocking of `pointed_semantic_lemmas_after_merge_followups` and
  `promote_next_prev_covby_to_generic_lemmas` is contingent on the user posting the approval and
  the merge actually landing. Neither is unblocked by this task.
- The after-the-merge list in the posted comment is untouched, so the signature-layer work
  (`records/milestones.md` D1) and the `next_iff_covBy`/`prev_iff_covBy` promotion remain exactly
  where they were filed.

## Follow-ups

- `Tests/BimodalTest/Semantics/README.md`'s row for `TemporalRulesTest.lean` no longer describes
  the file now that it carries interval and L⋆ rows. Named as a note in the approval; a one-line
  fix after the merge, not a condition of it.
- The relation shapes `IsoRel`, `AntiIsoRel` and the `Eq` of `plus_iffTransport_stateLocalStab`
  remain unexercised by any transport test row. Recorded in the approval as an acknowledgement,
  since the bar asked for was one per family.
- `.claude/scripts/tests/test-deploy-baseline-lib.sh`'s warm-cache control case fails
  reproducibly and is owned by no task. It is a defect in `verify-deploy.sh`'s gate-cache
  warm-path logic, not in any caller, and every scoped or full battery run in this repository
  will keep reporting one NEW failure until it is fixed or marked expected.
- The research report's two context-extension recommendations are still unfiled: a "copied
  `.lake/build` is not a warm cache" subsection for `long-builds.md`, and a line documenting that
  `lake-build-guard.sh --dir` resolves lock and result-record paths only without chdir-ing.

## References

- `specs/990_rereview_pr11_at_rewriteable_pointed_truth_head/plans/01_approve-pr11-and-update-followup.md`
- `specs/990_rereview_pr11_at_rewriteable_pointed_truth_head/reports/01_rereview-pr11-at-usability-and-tests.md`
- `specs/reviews/pr-reviews-2026-11-21/pr11-approval.md`
- `specs/reviews/pr-reviews-2026-11-21/FOLLOWUP.md`
- `specs/reviews/pr-reviews-2026-11-21/pr11-comment.md`
- `specs/reviews/pr-reviews-2026-11-21/pr7-approval.md` (register precedent)
- `records/milestones.md` D1
