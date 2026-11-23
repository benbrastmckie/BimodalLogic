# Implementation Summary: Task #978

- **Task**: 978 - Review collaborator PR #11 (feat/pointed-semantic-lemmas) and prepare a merge recommendation and draft review
- **Status**: [COMPLETED]
- **Started**: 2026-11-23T03:24:06Z
- **Completed**: 2026-11-23T03:52:00Z
- **Effort**: ~30 minutes
- **Dependencies**: None
- **Artifacts**: plans/01_review-pr11-pointed-semantic-lemmas.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The review this task existed to produce was produced by the research round and **acted on before
this implementation dispatch ran**: the user posted the condensed draft to GitHub as a
`CHANGES_REQUESTED` review on PR #11 at `2026-11-23T01:57:16Z`. This dispatch therefore did
record work, not review work — it reconciled the two durable artifacts (the research report and
the long review draft) against what was actually posted, closed the four open rulings with the
disposition the user chose, and gave every named follow-up a task number or an explicit gap. No
Lean file was touched, no build was run, and nothing was posted, pushed, merged or approved.

## What Changed

- `specs/978_review_pr11_pointed_semantic_lemmas/reports/01_review-pr11-pointed-semantic-lemmas.md`
  — appended a `## Disposition (2026-11-22)` section (48 lines, purely additive) recording the
  posted review, the unchanged head, the new `CONFLICTING` state and the scope of the gate
  evidence; and annotated each of the four `### ` headings under `## Items Needing the User's
  Ruling` with a `> **RESOLVED**` block (31 lines, purely additive). No existing finding, table
  row or measurement was deleted: both edits are `+N/-0` in `git diff --stat`.
- `specs/reviews/pr-reviews-2026-11-21/pr11-review.md` — appended a `## Posted disposition`
  section mapping all eight numbered requests onto their outcome. The draft's original 10993
  bytes are byte-unchanged (verified by `head -c 10993`); 4990 bytes were appended.
- `specs/reviews/pr-reviews-2026-11-21/FOLLOWUP.md` — two anchored edits recording that item 1
  was posted, and correcting the now-false "Nothing below has been posted" sentence in the state
  paragraph. Items 2 and 3 were left untouched; they belong to
  `review_pr10_semantic_record_and_pr9_disposition`.
- `specs/978_review_pr11_pointed_semantic_lemmas/summaries/01_...-summary.md` — this file.

Both `specs/reviews/**` files are excluded from git at `.git/info/exclude:20`
(`/specs/reviews/`), so they appear in no commit. This is expected, not a gap.

## The posted disposition of PR #11

Measured live in this dispatch, not carried from the plan:

| | Value | Command |
|---|---|---|
| head | `c6cd983b79842368ae789488d38e488656f98992` — **unchanged** since the review round | `gh pr view 11 --json headRefOid` |
| state | `OPEN`, +793/−12 across 14 files | `gh pr view 11` |
| review | `benbrastmckie`, `CHANGES_REQUESTED`, `submittedAt 2026-11-23T01:57:16Z`, on that same oid | `gh pr view 11 --json reviews` |
| posted text | the condensed `pr11-comment.md`, differing by one blank line | whitespace-normalized `diff` |
| mergeable | **`CONFLICTING`** (was `MERGEABLE` at research time) | `gh pr view 11 --json mergeable` |
| cause | #7 merged `2026-11-22T22:58:00Z` as `3c7197f84297d9ebab2472a89adba19effb72ef6` | `gh pr view 7`; `git merge-base --is-ancestor` confirms it is an ancestor of `origin/main` |

Three conditions of merging were posted: (1) rebase onto `main` and regenerate the three
conflicting files rather than resolving by hand; (2) make `At` usable in tactic proofs, with one
test that rewrites a clause under `At`; (3) tests for the eleven untested lemmas, one transport
factory per family, and one instantiation at L⋆.

The four rulings the research report left open are now closed: ruling 1 (`At`) as option (a);
ruling 2 (named interval operators) as option (a) in substance but **deferred to the signature
layer**, not asked of this PR; ruling 3 (`next_iff_covBy` promotion) as option (c), the user's
own; ruling 4 as REQUEST CHANGES, re-cut from four items to three conditions.

## Follow-up ledger

Each bullet of the posted review's "After the merge, not conditions of it" list, against
`specs/state.json`:

| Posted follow-up | Home |
|---|---|
| Named interval operators (`inclusiveUntil`, `inclusiveSince`, `release`, `trigger`, `weakUntil`, `weakSince`) and one `next`/`prev` encoding, on the signature layer (D1) | **Task 977** `connective_signature_layer_shared_primitives` — its description already names clause (b) "the interval operators are defined once on the signature" and the restatement of the `_iff` lemmas about them |
| `next_iff_covBy` / `prev_iff_covBy` promoted onto the generic `next_iff` / `prev_iff` | **Task 984** `promote_next_prev_covby_to_generic_lemmas`, gated on these modules reaching `main` |
| A positive reading for `release_iff` and `trigger_iff` | **No task yet** — no task in `state.json` mentions `trigger_iff` or a positive reading |
| Module docstring titles for the three generic modules, and one spelling of the `assert_not_exists` lock (`Axiom DerivationTree`) | **No task yet** — task 177 `update_readme_and_module_docstrings` is a post-refactor polish pass gated on the decidability chain landing and does not reach these modules; task 983's `assert_not_exists` mention is about its own module's guard, not this directory's spelling |
| `allFuture_persist` / `allPast_persist` for L⁻, and L⋆ versions of the time-shift and state-local factories | **No task yet** — no task mentions either lemma, `StarStateLocal`, or `timeShift` |

Three gaps, reported for the user to act on with `/task`; no tasks were created by this dispatch.
Separately, records and task-description reconciliation for the whole #7–#11 round is **task
982** `reconcile_records_and_tasks_after_pr_review_round`, which this task deliberately did not
duplicate.

Two items the draft raised are **not** carried by anything, because they were never posted:
request 8 (`Point.history` versus `PointedModel.hist` in `Metalogic/SetConsequence.lean`) and
the `typst/generated/status.typ` `stamp-commit` nit. The instruction that #9 must drop its three
renamed modules on rebase was also not posted; it belongs to task 979's disposition of #9.

## Review worktree — keep it

`git worktree list` confirms `/home/benjamin/Projects/.worktrees/BimodalLogic-pr11`, detached at
`c6cd983b79842368ae789488d38e488656f98992`. Its `.lake` is warm and reusable:

- `.lake/packages` is a symlink to the main tree's (`-> /home/benjamin/Projects/BimodalLogic/.lake/packages`), valid while `lake-manifest.json` and `lean-toolchain` are unchanged.
- `.lake/build/lib` and `.lake/build/ir` are real copies (2.3G total), `build/bin` omitted.
- The five `.lake/build-guard.*` files are the worktree's **own** (mtimes `2026-11-21 15:08–15:09`, against the main tree's `2026-10-17` / `2026-11-19`): they were not copied, they were written in place by the guard's own run there. This is a refinement of the plan's "deliberately not copied" — the outcome the guard's never-hardlink-share rule asks for is achieved, and it is verifiable from the mtimes.

**Keep the worktree.** Condition 1 of the posted review will produce a rebased head to re-review,
and the warm `.lake` is the expensive part of that re-review.

## Decisions

- Recorded request 8 as "not posted at all" rather than mapping it to an after-merge bullet, because the posted text does not contain it in any form. The plan had assumed it moved to the after-merge list with requests 5–7; the plan's own cross-check caught the difference.
- Made two anchored edits to `FOLLOWUP.md` rather than the one the plan specified, because recording the posting leaves the file's "Nothing below has been posted" sentence false. Items 2 and 3 were not touched.
- Did not create follow-up tasks for the three gaps; the plan's Non-Goals reserve that for the user.
- Did not run a Lean build at any phase end. No `.lean` file is touched by this task, so the phase-end full-build gate has no subject; each phase's declared covering check was run instead.

## Plan Deviations

- **Phase 2**, draft-request mapping, **altered**: requests 5, 6 and 7 are on the posted after-merge list as the plan expected, but request 8 is absent from the posted review entirely. Recorded under "Not posted at all" together with three other unposted draft pieces, rather than mapped to a follow-up it does not have. Annotated inline on the plan's checklist item.
- **Phase 3**, `FOLLOWUP.md`, **altered**: two anchored edits rather than one, for the reason under Decisions. No sibling had recorded the posting, so the plan's no-op branch did not apply.
- **Phase 3**, worktree record, **altered**: the plan states `.lake/build-guard.*` was "deliberately not copied"; five such files are present in the worktree. Measured their mtimes and found they are the guard's own, written by the run there — the claim is corrected rather than repeated.

## Verification

- Build: N/A — no `.lean` file touched by this task; `git status --short` shows no `.lean` path and no `.claude/**` path.
- Sorry count: N/A (no Lean source modified)
- Vacuous count: N/A (no Lean source modified)
- Axiom count: N/A (no Lean source modified)
- Tests: N/A
- Files verified: Yes
- `bash .claude/scripts/validate-artifact.sh .../reports/01_...md report` → `[PASS] ... (0 warning(s))`, exit 0, run after each of the two report edits.
- Additivity: `git diff --stat` on the report reported `+48/-0` after Phase 1 and `+31/-0` after Phase 2. The review draft's original 10993 bytes are byte-identical (`head -c 10993` ends exactly at its original closing sentence).
- Counts: the draft carries exactly 8 numbered requests and the report exactly 4 ruling headings (both counted, matching the plan's Scope Hypothesis). All 8 requests have a disposition in the new section; all 4 rulings carry a `> **RESOLVED**` block. "Request 4" is named twice in the section — once in its mapping bullet and once in the elaboration that follows it — so the "exactly one disposition line" criterion holds in substance, with one request named twice inside its own single disposition.
- Scoped tier discharge: see below.

### Scoped verification and batch deferral

Per this dispatch's Batch Gate Deferral directive, Phase 3's declared `full` tier was discharged
**scoped**, not by independently running the complete gate set. The full set runs once for the
whole `/orchestrate` batch at the invocation's close and is attributed back by `modified_files`.

`verify-touched.sh` was run with no arguments, as the directive specifies (it derives touched
paths itself). It derived **9 touched paths**, of which **5 belong to sibling dispatches**:
`specs/TODO.md`, `specs/state.json`, `specs/events.jsonl`,
`specs/980_rereview_pr7.../issues.jsonl`, and two files under
`specs/981_rereview_pr8.../`. Only three are this task's
(`.return-meta.json`, the plan, the summary), and **neither `specs/reviews/**` file appears at
all** — that directory is git-excluded at `.git/info/exclude:20`, so it is invisible to the
derivation in both directions. The sibling attribution pulled in the full 90-suite agent-system
battery for what is a four-file markdown edit. This is the documented behaviour of the tool on a
shared, concurrently-dispatched tree, not a fault of this run.

**Result**: two roots ran. The 90-suite root reported `73 passed, 8 failed (1 expected, 7 NEW),
9 skipped, 90 total`; the OWED fallback root reported `84 passed, 1 failed (0 expected, 1 NEW),
10 skipped, 95 total`. `verify-touched.sh` closed with "touched-path run reported a failure ...
NOT a full-battery pass".

**Every failing suite is this deploy-only tree's standing baseline, not a regression of this
task.** Two independent checks:

1. `agent-system/` does not exist in this repository (`[ -d agent-system ]` is false), and the
   failures say so directly — e.g. `test-orchestrate-build-dispatch.sh`:
   `/home/benjamin/Projects/BimodalLogic/agent-system/extensions/core/context/standards/user-decision-contract.md not found`;
   `test-gate-cache-equivalence.sh` Cases G4 and G22: `fixture is missing .../agent-system/extensions/core/...`.
   The dispatch's own `<deploy-freshness-context>` records the deployed `.claude/` tree as stale
   for `core`, `lean` and `sapience`, which is the same cause for
   `test-deploy-baseline-lib.sh`, `test-postflight-deploy-gate.sh` and
   `test-redeploy-checkpoint-promotion.sh`.
2. Grepping all nine failing suites for `978_review_pr11`, `specs/reviews/` or `pr11` returns
   **zero matches in every one**. No failing suite reads a file this task touched.

Recorded as a PASS for this phase under the directive's narrowed reading. No additional full
sweep was run.

## Impacts

- Task 982's reconciliation round can now read a settled record: the four rulings carry their outcomes, the report states what its gate evidence does and does not cover, and the draft says what was and was not posted.
- Task 984 is unblocked in principle but gated on #11 reaching `main`, which now requires the contributor's rebase first.
- Three follow-ups named in a posted public review have no task; they will be lost unless created.

## Follow-ups

- Create tasks for the three unhomed follow-ups: the positive reading for `release_iff`/`trigger_iff`; the module docstring titles plus the single `assert_not_exists` spelling; and the L⁻ persistence siblings with the L⋆ transport factories.
- Decide whether request 8 (`Point.history` versus `PointedModel.hist`) is worth raising separately, since it was dropped from the posted review.
- The research report's `review-worktree-setup.md` context-extension recommendation **cannot be authored from this repository**: `.claude/**` here is a regenerated deploy artifact, and the lean extension's `source_dir` resolves to `/home/benjamin/.config/nvim/agent-system/extensions/lean`, a different repository with no on-disk `agent-system/` tree here. Per `rules/source-store-deploy-boundary.md`'s Task Siting subsection, that task must be created in the repository that holds the source store. Nothing under `.claude/**` was written by this task.
- Re-review #11 after the rebase, reusing the warm worktree.

## What was not verified in this round

Stated plainly, as ground rule (iii) requires:

- **No Lean build was run and no gate was re-measured.** Every build, linter, invariant and `#print axioms` figure in the research report was measured at `c6cd983b7` against a `main` that did not contain #7. Those figures are true of that commit and are **not** evidence about the rebased tree condition 1 asks for.
- **CI was not re-checked.** `gh pr checks 11` was green at research time; the base has since moved, so that result no longer predicts a post-rebase run.
- **The rebase was not performed and the conflicts were not inspected.** `mergeable: CONFLICTING` is GitHub's verdict, read from the API; which hunks conflict was not examined here.
- **The `#9` overlap was not re-measured** against #9's current head.
- The research report's own "Not verified" list still stands unchanged.

## References

- `specs/978_review_pr11_pointed_semantic_lemmas/plans/01_review-pr11-pointed-semantic-lemmas.md`
- `specs/978_review_pr11_pointed_semantic_lemmas/reports/01_review-pr11-pointed-semantic-lemmas.md`
- `specs/reviews/pr-reviews-2026-11-21/pr11-review.md`, `pr11-comment.md`, `FOLLOWUP.md`
- `.claude/rules/pr-prohibition.md`, `.claude/rules/source-store-deploy-boundary.md`
