# Implementation Summary: Task #980

- **Task**: 980 - rereview_pr7_rewriting_and_views_merge_decision
- **Status**: [COMPLETED]
- **Started**: 2026-11-23T03:08:49Z
- **Completed**: 2026-11-23T03:42:00Z
- **Effort**: ~0.6 hours
- **Dependencies**: None
- **Artifacts**: plans/01_pr7-rewriting-views-merge-decision.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The task was created to re-review PR #7 and reach a merge decision. That decision was already
taken before this dispatch ran: PR #7 merged as `3c7197f84297d9ebab2472a89adba19effb72ef6` on
2026-11-22T22:58:00Z at head `6313e693f`. This dispatch executed the plan's close-out instead of
a second review — it attached an outcome to the task's own report, retired the superseded draft
response in place, and handed every residual follow-up to a named owner. No Lean source was
edited, no record was touched, and nothing was posted, pushed or merged.

## What Changed

- `specs/980_rereview_pr7_rewriting_and_views_merge_decision/reports/01_pr7-rewriting-views-merge-decision.md`
  — appended an `## Outcome` section (merge facts, the three conditions by file and line, the
  filing-by-family delivery, the M17 restatement, which claims are now historical and which
  remain live and re-measured), a `### Handover` subsection (five-row residual owner map plus one
  stated gap), and a `#### Verification of this close-out` subsection. The pre-existing 340 lines
  are byte-identical (`sha256` of `head -340` matched before and after).
- `specs/reviews/pr-reviews-2026-11-21/pr7-review.md` — prepended a six-line superseded-draft
  header naming `pr7-approval.md` and the merge commit. The body below it is byte-identical
  (`diff` against a saved copy is empty). Git-excluded locally, so no commit.
- `specs/980_rereview_pr7_rewriting_and_views_merge_decision/plans/01_pr7-rewriting-views-merge-decision.md`
  — phase markers and checklist ticks only.

### Re-measured in the merged tree (not inherited from the report)

- `coreViews` (`FormalSystem/Tactic/FormulaViews.lean:60-64`): four distinct view names across
  seven rows, against **20** entries in `Language.operatorName`
  (`FormalSystem/Tactic/FormulaSyntax.lean:33-85`), 17 of them operators proper.
- `applyView` discards its caught error literally: `catch _ => saved.restore` at
  `FormulaViews.lean:106-107`, generic message at `:108`.
- The `lsimp` per-attempt catch at `Simplification.lean:95-97` swallows the
  `throwError "rule requires unavailable side conditions"` raised at `:91`.
- **11** `fail_if_success` against **4** `#guard_msgs` across the four new family test files; the
  stopped-wrapper message at `Rewriting.lean:402` has no test anywhere.

## Decisions

- Treated the dispatch's premise (a live re-review at head `5f5ad32bf`) as superseded on
  first-hand evidence rather than executing it, as the plan directs; `gh pr view 7` reports
  `MERGED` and `git merge-base --is-ancestor` confirms the merge is in the local tree.
- Left the retired draft's body byte-unchanged rather than rewriting it: it is the record of what
  was asked and why, and the approval that superseded it is a separate file.
- Did not force the git-excluded `pr7-review.md` into the index when `git-commit-scoped.sh`
  returned its exit-8 skip; the skip was predicted by the plan and recorded.
- Did not invent an owner for the one unowned residual; surfaced it as a non-blocking
  `user_decision` instead.

## Plan Deviations

- None (implementation followed plan).

## Verification

- Build: N/A — no `.lean` file was edited or staged at any point in this task.
- Sorry count: 0 (no Lean source touched; nothing added)
- Vacuous count: 0 (no Lean source touched)
- Axiom count: unchanged (no Lean source touched)
- Tests: scoped touched-path check run (`verify-touched.sh`); result recorded as a baseline
  delta, not an absolute pass — selected run 73/8/9 of 90, OWED fallback 84/1/10 of 95. None of
  the nine failing suites greps for `980`, `pr-reviews` or `pr7-review`;
  `test-roadmap-generation.sh` fails with `roadmap-integration.sh not found (mode=source-store)`,
  the standing deploy-only-tree baseline. Full gate set deferred to the batch stage per this
  dispatch's batch-gate deferral directive.
- Files verified: Yes — report prefix hash-matched, draft body diff-matched, `git status --short
  records/` empty, `specs/state.json`'s only diff is the orchestrator's own
  `planned`→`implementing` transition.

## Impacts

- The task's report no longer stands as a live REQUEST CHANGES recommendation against a head that
  no longer exists; a reader of `specs/reviews/pr-reviews-2026-11-21/` can no longer mistake the
  retired draft for the posted response.
- `proof_mode_split_shared_test_and_guide_files` has less to move than its description states:
  the `Congruence/` split and the per-family test split were delivered by the contributor.
- `reconcile_records_and_tasks_after_pr_review_round` is unperturbed — this task edited no
  record, no task description and no `specs/state.json` entry.

## Follow-ups

- **One unowned residual, surfaced as a non-blocking `user_decision`.** `applyView`'s swallowed
  error lives in `FormalSystem/Tactic/FormulaViews.lean`, outside
  `proof_mode_error_message_coverage`'s declared path scope
  (`FormalSystem/Automation/ProofMode/`), and that task is not among the descriptions
  `reconcile_records_and_tasks_after_pr_review_round` is contracted to restate. The two candidate
  homes and the reason neither fits cleanly are set out in the report's Handover subsection.
- The other four residuals are owned: 1 and 5 by `proof_mode_views_tier`, 3 and 4 by
  `proof_mode_error_message_coverage`, each with the obligating sentence quoted.
- Not re-verified here and stated as such in the report: no build, test, lint or `#print axioms`
  run against the merge commit; the filing by family confirmed by directory listing only; the
  import closure not recomputed.

## References

- Plan: `specs/980_rereview_pr7_rewriting_and_views_merge_decision/plans/01_pr7-rewriting-views-merge-decision.md`
- Report (extended by this dispatch): `specs/980_rereview_pr7_rewriting_and_views_merge_decision/reports/01_pr7-rewriting-views-merge-decision.md`
- Posted response: `specs/reviews/pr-reviews-2026-11-21/pr7-approval.md`
- Retired draft: `specs/reviews/pr-reviews-2026-11-21/pr7-review.md`
- M17: `records/proof-mode.md:483-500`
