# Implementation Summary: Task #981

- **Task**: 981 - Re-review PR #8 (temporal rules and the carrying table)
- **Status**: [COMPLETED]
- **Started**: 2026-11-23T04:35:00Z
- **Completed**: 2026-11-23T05:30:00Z
- **Effort**: ~1 hour
- **Dependencies**: Task 980 (PR #7 re-review) — complete; PR #7 merged as `3c7197f84`
- **Artifacts**: plans/01_rereview-pr8-temporal-rules-carrying-table.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Closed out the PR #8 re-review round. The round was planned as an audit of a draft the research
round had already written, but the pull request head moved between planning and this dispatch —
substantially — so Phase 2 escalated to a rewrite, as the plan's own Scope Hypothesis anticipated.
The deliverables are a revised full draft, a postable comment body, a records hand-off note for
the reconciliation pass, and a disposition section on the research report. Nothing was posted,
pushed, merged or approved; no Lean source was edited and `records/` was not touched.

## What Changed

The head is now `5ecc91d63b3a3cdcae1028417d67c3e89907bdad` (was `49a7efe231cf98a488ad107dd98188
1557b1fd96`), `OPEN`, and `mergeable: MERGEABLE` (was `CONFLICTING`). It is a merge commit whose
second parent is `origin/main` (`171021f4b`) exactly — **the contributor did the rebase
themselves**, by merging rather than rebasing — and it additionally lands the view-registry work
the draft had queued as a follow-up.

- `specs/reviews/pr-reviews-2026-11-21/pr8-review.md` — rewritten against the new head
  (12,422 B). Credit section, a measured gate table, a correction the review owes on readme-lint
  attribution, **two** conditions of merging (down from four), four follow-ups, a records
  acknowledgement, and a closing "What I did not verify" paragraph.
- `specs/reviews/pr-reviews-2026-11-21/pr8-comment.md` — new (7,571 B); the postable body.
- `specs/reviews/pr-reviews-2026-11-21/pr8-record-edits.md` — new (4,899 B); restructured to lead
  with what the PR already lands in `records/`, so the reconciliation pass cannot duplicate or
  revert it, then the two genuinely-ours `records/milestones.md` items.
- `specs/reviews/pr-reviews-2026-11-21/FOLLOWUP.md` — exactly two anchored edits: a new post-list
  item 4 for `pr8-comment.md`, and the stale `#8 temporal` bullet replaced with the re-review's
  outcome. Items 2 and 3 and every `#9`/`#10`/`#11` bullet verified byte-unchanged.
- `specs/981_.../reports/01_...md` — a `## Disposition` section appended (+107/−0 on the first
  write, closed with the final head re-check).
- `specs/981_.../handoffs/phase-{1,2,3}-handoff-*.md` — new; per-phase recovery points.

### The thirteen requests, measured on `5ecc91d63`

Done outright: 1 (rebase), 2 (split by family), 3 (views moved out), 5 (leads-to labelled the
strict layer), 6 (`lapply`), 7 (one `integerTimeGate`), 9 (all four smaller fixes), 11 (wording),
12 (client re-proofs, as test examples). Substantially done and then some: 13 (records). Answered
as far as it asked: 4 (backward induction documented; an M4 semantic argument added; the rule not
derived, which it never had to be). Part-done: 8 (the five `… using` forms collapsed; the carrying
table built but still `private` and wrongly keyed) and 10 (tests added; `lprogress` still has one
example exercising `cases` only, TM⁺ still thin).

### Conditions of merging, now two

1. Widen `CarryRule`'s key from `(past, source)` to `(source, target)`, drop `private`, and move
   the table out of `Automation/ProofMode/Temporal.lean:114-128` into a module both tactic
   families import. Only the shape; the `□` rows stay with the scope records.
2. Split the altered acceptance example at `Tests/BimodalTest/Automation/ProofModeTest.lean:129`
   back into its two cases. The `True → FrameClass.ZTime ≤ fc` wrapper makes it pass under the old
   behaviour too, so it pins neither.

**Recommendation: REQUEST CHANGES**, with both conditions small and the rest credit.

## Decisions

- Phase 2 was rewritten rather than anchored-edited. More than a quarter of the draft was
  invalidated by the head move; the plan's Scope Hypothesis names that escalation explicitly. The
  prior draft was preserved to the scratchpad and every still-correct paragraph carried over
  verbatim.
- The rebase recipe, the seven-conflict list and the offer to do the rebase were dropped from both
  the draft and the comment rather than retained as history. They are kept in the report's
  disposition section as the record of what the contributor's own merge had to resolve.
- `pr8-record-edits.md` was inverted: it now leads with "already landed by the PR — check before
  touching" instead of carrying verbatim replacement text for `records/proof-mode-architecture.md`
  open decision 2, because the contributor made that edit inside the PR.
- The readme-lint attribution in the research round's draft ("two are yours, one is mine") was
  withdrawn rather than reworded, because measurement showed the finding set identical on `main`.

## Plan Deviations

- **Phase 1, "if the head has moved"**: altered — the branch fired. Enumerated with
  `git log --oneline origin/main..5ecc91d63` rather than the planned two-dot form, since the move
  was a merge rather than new linear commits.
- **Phase 2, "anchored `Edit` calls, never a whole-file rewrite"**: altered — rewritten, per the
  phase's own escalation clause.
- **Phase 3, "state condition 4 (the records) in the form the contributor can act on"**: altered —
  the contributor had already made that edit, so the ask became an acknowledgement and the
  strike-the-open-decision text moved wholly into `pr8-record-edits.md`.
- **Phase 3, comment length**: altered — 7,571 B against `pr11-comment.md`'s 3,244 B, because both
  surviving conditions need a concrete shape, one of them a Lean code block.
- **Phase 4, probe worktree**: altered — rather than leaving the rebase probe untouched as the
  evidence behind an offer that is now moot, the worktree was repurposed to the contributor's own
  head so the gate table could be measured there. The probe branch is retained, not deleted.

## Verification

- Build: **Success** — `lake build --wfail` green, 3014 jobs, on `5ecc91d63` in the probe
  worktree, routed through `lake-build-guard.sh`, detached with a bounded `kill -0` wait. This
  task edits no Lean file in this repository, so no main-tree build was run.
- Sorry count: 0 (no Lean source touched by this task; `#print axioms` on eighteen contributed
  rules of the reviewed branch shows `propext`, `Classical.choice`, `Quot.sound` and no `sorryAx`)
- Vacuous count: 0
- Axiom count: unchanged (0 added)
- Tests: **Passed** — `lake test` green, 3091 jobs, on the reviewed head
- Files verified: Yes

### Phase verification tiers and the batch deferral

Phases 1–3 declare `**Verification Tier**: prose`; each phase's covering check is recorded above
and in its handoff. Phase 4 declares `full`. Per this dispatch's Batch Gate Deferral directive,
the full gate set is **deferred to the batch stage** and discharged once for the whole
`/orchestrate` invocation; this phase's own obligation is the scoped touched-path check, recorded
under Impacts below. The complete gate set is deferred here, never forgiven.

### Scoped touched-path check: run, and its failures attributed away

`bash .claude/scripts/verify-touched.sh` (no arguments; it derived the 12 touched paths itself)
ran two narrowed batteries: 91 selected suites (74 passed, 8 failed — 1 expected, 7 new) and then
the OWED fallback set at `--cost-class free` (84 passed, 1 failed, 10 skipped, 95 total). The
script's closing line reports a failure.

**None of those failures is attributable to this task.** This task's own paths appear in the log
only in the touched-path resolution lists (lines 8–14 and 117–119) and in no failing-suite output
at all. The failing suites are `test-force-phases.sh`, `test-gate-cache-equivalence.sh`
(pre-marked EXPECTED), `test-gate-out-repair-reporting.sh`, `test-loop-guard-budget-override.sh`,
`test-orchestrate-build-dispatch.sh`, `test-postflight-deploy-gate.sh`,
`test-redeploy-checkpoint-promotion.sh`, `test-roadmap-generation.sh` and
`test-deploy-baseline-lib.sh` — all agent-system harness suites, none of which reads a
`specs/981_*` or `specs/reviews/*` path.

The common cause is on the record: `agent-system/` **does not exist on disk in this checkout**
(`ls -d agent-system` → No such file or directory), and this dispatch's own context states the
deployed `.claude/` tree is stale relative to the source store for extension `core`. The failure
text bears that out directly — repeated `fixture is missing
/tmp/.../fixture/agent-system/extensions/core/...` assertions, plus `rc=127` (command not found)
in the gate-cache control cases. That matches the standing baseline this plan anticipated.
`test-deploy-baseline-lib.sh`'s single failing assertion is a gate-cache warm-skip control, the
same family as the already-EXPECTED `test-gate-cache-equivalence.sh`.

### Known standing baselines, not this task's regressions

- `scripts/readme-lint.sh` is red on `main` with three stale rows. Measured identical on `main`
  and on the PR head, so the pull request adds nothing to it.
- CI's `Check README health` step cannot see that failure at all: `actions/checkout` is shallow by
  default and `readme-lint.sh` skips its stale-date arm under `SHALLOW_CLONE=1`. Run
  `45112191590` printed `Stale dates (info): (skipped: shallow clone, …)` and `RESULT: PASS`.
- `verify-touched.sh` attributes sibling tasks' uncommitted `specs/TODO.md`, `specs/events.jsonl`
  and `specs/state.json` to whichever dispatch is running.

### Git exclusion

`specs/reviews/**` is excluded from git in this checkout (`.git/info/exclude`), and `main` now
also carries a commit removing it from tracking (`29e7b2df2`, "specs: stop tracking
specs/reviews"). The four review deliverables therefore appear in **no commit**. That is expected,
not a gap. This task's own `specs/981_*/` artifacts are committed normally, one commit per phase.

### Probe worktree disposition

- Path `/home/benjamin/Projects/.worktrees/BimodalLogic-pr8`, now on branch `pr8-head-check` at
  `5ecc91d63` — the tree every gate result above was measured in.
- Branch `pr8-rebase-probe` is retained at `4e732c51c`, whose tip parks the generated-surface and
  `open … (Language)` fixes the research round's `git rebase --onto origin/main fc85c61b9` needed.
  It is evidence only; the rebase it demonstrates is no longer the ask.
- Neither branch was pushed and neither is to be pushed. The worktree is deliberately not removed:
  it holds a warm `.lake` for the PR head, which makes re-checking a moved head cheap.

## Impacts

- The user has a postable body ready for PR #8, re-checked against the live head at the close of
  this dispatch (`5ecc91d63`, unchanged, `updatedAt` identical to the Phase 1 read).
- The records-reconciliation pass has an explicit "do not duplicate" note: PR #8 edits
  `records/proof-mode-architecture.md` and `records/proof-mode.md` itself.
- Open decision 3 of `records/milestones.md` (`expand`/`contract`) is settled and is owed a strike;
  open decision 4 (signature layer before or after) is untouched by this review.
- Scoped touched-path check: this task's own touched paths are
  `specs/981_rereview_pr8_temporal_rules_and_carrying_table/**` plus the git-excluded
  `specs/reviews/pr-reviews-2026-11-21/**`. No Lean line count changes, so neither generated
  surface (`check-module-invariants.sh`, `typst-sync-check.sh`) has anything to regenerate here —
  stated rather than assumed.

## Follow-ups

- **Open ruling, non-blocking**: where the re-keyed carrying table lives — a shared non-private
  module (recommended, and what the draft asks for), or a `register_lcarry` registry mirroring the
  merged view table. The draft names the alternative once so the contributor can push back.
- `readme-lint.sh`'s stale-date arm is structurally invisible in CI. Worth a task of its own; it
  means every green CI readme-lint to date is silent on stale dates rather than evidence about
  them.
- The three `records/milestones.md` edits in `pr8-record-edits.md` are owed by the reconciliation
  pass, not by this task.
- `FOLLOWUP.md`'s own title still reads "Follow-up on PRs #9, #10, #11" while the post list now has
  four items. Left as-is deliberately: retitling it is outside the two anchored edits this task's
  guard permitted while a sibling task owns that file.

## References

- `specs/981_rereview_pr8_temporal_rules_and_carrying_table/plans/01_rereview-pr8-temporal-rules-carrying-table.md`
- `specs/981_rereview_pr8_temporal_rules_and_carrying_table/reports/01_rereview-pr8-temporal-rules-carrying-table.md` (`## Disposition`)
- `specs/reviews/pr-reviews-2026-11-21/pr8-review.md`, `pr8-comment.md`, `pr8-record-edits.md`,
  `FOLLOWUP.md`
- `specs/reviews/pr-reviews-2026-11-20/pr8-review.md` (the thirteen requests being answered)
- `specs/reviews/pr-reviews-2026-11-21/pr7-review.md`, `pr7-approval.md`
