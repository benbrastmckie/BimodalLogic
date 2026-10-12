# Implementation Plan: Task #764

- **Task**: 764 - Close the specs/**-only phase verification gap and the repo-wide task-reference lint debt
- **Status**: [IMPLEMENTING]
- **Effort**: 6.25 hours
- **Dependencies**: Task 771 (completed)
- **Research Inputs**: specs/764_specs_only_gate_and_task_reference_lint_debt/reports/01_specs-only-gate-and-lint-debt.md
- **Artifacts**: plans/01_gate4-fix-and-lint-debt-closure.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Two independent verification findings are closed here. Finding (1) — an `--only-gate` selection
that exits 0 having run zero checks — is fixed at two levels: gate 4's SKIP guard in
`verify-deploy.sh` is factually wrong for its own underlying script (`check-task-references.sh`
runs a real scan in any deploy-consumer tree), and the end-of-run summary silently reports
`PASS -- 0 check(s)` whenever every selected gate skipped. Finding (2) — the repo-wide
task-reference lint debt — is already mechanically closed (0 occurrences, independently
re-verified); what remains is to settle and durably record the one open sub-question it left
behind (whether to add a path-level exemption category for archival trees) rather than leaving it
homeless. Every code and guidance edit lands in the agent-system source store resolved via
`.claude-extensions.json` (`/home/benjamin/.config/nvim/agent-system/extensions/core`), never
hand-authored under `.claude/**`.

### Research Integration

The research report's two root causes are both carried into this plan, and its gate-4 evidence is
treated as established: `check-extension-docs.sh` genuinely errors (exit 1) without
`agent-system/extensions`, so gate 3's SKIP guard is correct; `check-task-references.sh` runs a
real scan with no dependency on that directory, so gate 4's copy of the same guard is wrong.
Three facts were re-measured during planning and are used as the plan's own baselines rather than
carried from prose:

- `verify-deploy.sh --skip-slow .` against this repo today: **`PASS -- 14 check(s), 0 failure(s)`,
  exit 0**. This is the pre-fix baseline the final phase compares against.
- `verify-deploy.sh --skip-slow --only-gate 4 .` against this repo today: gate 4 `[SKIP]`,
  `PASS -- 0 check(s)`, exit 0 — the defect, reproduced.
- `verify-deploy.sh --skip-slow --only-gate 3,4 /home/benjamin/.config/nvim` (TARGET = the
  resolved source store): `PASS -- 3 check(s), 0 failure(s)`, exit 0 — both gates run for real
  there. This is the shape the corrected `plan-format.md` guidance must name for a source-store
  edit, and it is also this plan's own covering check for its markdown phases.

One correction to the research report's test recommendation was found during planning and is
carried in Phase 4 instead: `FIXTURE_CHEAP` in `test-verify-deploy-gate-selection.sh` creates its
own empty `.claude/scripts/`, so a de-guarded gate 4 reaches the `fail "check-task-references.sh
not deployed"` branch there, not a passing real check. The new "gate 4 runs for real in a
deploy-consumer tree" case therefore needs its own fixture whose `.claude` is symlinked to a real
deploy tree (the shape `FIXTURE_RICH` already uses) while still omitting
`agent-system/extensions`.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch; ROADMAP.md was not consulted and is not
modified.

## Goals & Non-Goals

**Goals**:
- Make gate 4 run a real `check-task-references.sh` check against `TARGET` in a deploy-consumer
  tree instead of skipping, leaving gate 3's (correct) guard untouched.
- Make any `--only-gate` selection that ends with zero checks run report that loudly and
  non-zero, instead of `PASS -- 0 check(s), 0 failure(s)` / exit 0.
- Give both script changes their own regression cases in
  `test-verify-deploy-gate-selection.sh`.
- Correct `plan-format.md`'s `__FULL_SWEEP__` guidance so it stops recommending a check that is
  vacuous from the dispatch's own cwd, and distinguishes the `specs/**`-only case from the
  source-store case.
- Settle finding (2)'s open taxonomy question with an argued decision recorded where a future
  reader will find it, and re-verify the lint is in fact at zero.

**Non-Goals**:
- Auditing or de-guarding the other 17 source-store-conditioned gates. Only gate 4's guard
  premise was disproved; the rest stay as they are and are explicitly left unaudited.
- Changing any gate's pass criteria beyond gate 4's applicability and the zero-check summary.
- Adding a new lint, a new exit code, or a baseline mode to `check-task-references.sh`.
- Rewriting `Boneyard/**` content, or any further task-number-citation cleanup (already at zero).
- Fixing the stale "20-gate battery" wording in `shell-script-testing.md` — unrelated to either
  finding.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A de-guarded gate 4 surfaces real citation debt in *other* deploy-consumer repos on their next redeploy | M | M | This is the fix working as intended, not a regression. State it plainly in Phase 2's commit message and the task summary; it is not this task's to resolve on other repos' behalf. |
| A future contributor reads "the SKIP pattern is suspect" and strips a guard that is actually correct (gate 5, 8, ...) | H | M | Phase 2 scopes its code comment to gate 4's specific disproved premise and says in the same comment that the other gates' guards are unaudited, not presumed removable. |
| The zero-check detection fires on a legitimate narrow invocation (e.g. `--only-gate 8 --skip-slow`, where the one selected gate is deferred) | M | M | Phase 3 decides this case explicitly rather than by accident, and Phase 4 pins the decision with a test case. A deferred-only selection attests to nothing either, so the loud result is correct — but the message must name *why* (all selected gates skipped / were deferred). |
| Phase 3's summary change reaches every caller of `verify-deploy.sh`, including `deploy-headless.sh`'s inline verify and the orchestrate checkpoints | H | L | The new branch is conditioned on `GATES_FILTER` being non-empty; no caller on the default no-flag path can reach it. Phase 3's verification asserts the no-flag run against this repo is unchanged (14 checks, exit 0) and runs the one other `--only-gate` consumer suite, `test-verify-deploy-context-budget.sh`. |
| The source-store edit is not visible to this repo's `.claude/scripts/` copy until a manual redeploy, so a verification run against the deployed copy would silently test the old code | H | H | Every phase's verification invokes the **source-store** copy of `verify-deploy.sh` explicitly, the same discipline `test-verify-deploy-gate-selection.sh` already documents for itself. Phase 6 performs the redeploy and only then re-runs against the deployed copy. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 2 |
| 3 | 4, 5 | 2, 3 |
| 4 | 6 | 1, 4, 5 |

Phases within the same wave can execute in parallel. Phases 2 and 3 both edit
`scripts/verify-deploy.sh` and are deliberately serialized rather than run in one wave, so the
two changes land as separately reviewable, separately revertible commits in shared file territory.

### Phase 1: Settle and record finding (2)'s taxonomy question [COMPLETED]

**Goal**: Close the one sub-question tasks 766/771 left open — whether the exemption taxonomy
should gain a path-level category for archival trees — with an argued decision recorded in a
durable location, and independently re-confirm the lint is at zero so the decision rests on a
measured state rather than a cited one.

**Tasks**:
- [x] Re-run `bash .claude/scripts/check-task-references.sh` against this repo and record the
      exact output and exit code in the phase's commit message. Expected: `0 occurrence(s)`,
      `PASS`, exit 0. If it is non-zero, STOP and re-scope — the rest of this phase assumes a
      clean tree. *(completed: 0 occurrence(s), PASS, exit 0)*
- [x] Add a decision section to `/home/benjamin/.config/nvim/specs/decisions/no-task-references-enforcement-history.md`
      recording that a path-level exemption category for archival/tombstone trees was considered
      and **declined**, with the three reasons: (a) durable-anchor rewriting was demonstrated
      achievable for every occurrence in that path class across 53 files, so no residual case
      needs excusing; (b) the write-time guard hook already blocks a new citation landing in such
      a tree whether or not a path exemption exists, so the category would close no present gap
      and would only re-permit the pattern going forward; (c) category 1's exemption rests on
      task numbers being the intrinsic subject matter of `specs/**`, a property archival READMEs
      do not share. Write it as a decision on its own merits — no draft-history framing, no
      "formerly/no longer" phrasing (`no-record-versioning-in-deliverables.md`). *(completed)*
- [x] Add one pointer line to the `## Exemption Taxonomy` section of
      `agent-system/extensions/core/context/standards/task-reference-exemptions.md` noting that a
      path-level archival-tree category was considered and declined, citing the decision record by
      filename. The taxonomy table itself stays at 7 categories — no row added, no row changed.
      *(completed)*
- [x] Confirm `scripts/lib/task-reference-patterns.sh` is untouched by this phase (the decision is
      to change nothing mechanical). *(completed: confirmed clean via git status in the
      source-store repo)*

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: `REPO_ROOT=/home/benjamin/.config/nvim bash agent-system/extensions/core/scripts/check-task-references.sh --quiet agent-system/extensions/core/context/standards/task-reference-exemptions.md`
run from the source-store root is the exact lint that governs the one edited non-`specs/**` file,
and the decision record itself is under that repo's `specs/**` (category 1, outside the lint's
scope by design), so no broader check can reach either file.

**Files to modify**:
- `/home/benjamin/.config/nvim/specs/decisions/no-task-references-enforcement-history.md` - new
  decision section recording the declined archival-tree exemption and its three reasons
- `/home/benjamin/.config/nvim/agent-system/extensions/core/context/standards/task-reference-exemptions.md` -
  one pointer line under `## Exemption Taxonomy`; table unchanged

**Verification**:
- `bash .claude/scripts/check-task-references.sh` against this repo: `0 occurrence(s)`, exit 0,
  output quoted in the commit message.
- `REPO_ROOT=/home/benjamin/.config/nvim bash /home/benjamin/.config/nvim/agent-system/extensions/core/scripts/check-task-references.sh --quiet agent-system/extensions/core/context/standards/task-reference-exemptions.md`
  (run from `/home/benjamin/.config/nvim`): exit 0 — the pointer line introduces no citation.
- Diff read-through of both files confirming every changed hunk is prose, and that neither
  introduces a version-label or draft-history phrase.

---

### Phase 2: Correct gate 4's SKIP guard in verify-deploy.sh [NOT STARTED]

**Goal**: Make gate 4 invoke `check-task-references.sh` against `TARGET` unconditionally, so
`--only-gate 4` runs a real check in every deploy-consumer repo rather than attesting to nothing.

**Tasks**:
- [ ] In `scripts/verify-deploy.sh`, remove gate 4's `[ ! -d "$TARGET/agent-system/extensions" ]`
      SKIP branch, promoting the `check-task-references.sh not deployed` branch to the first
      condition — i.e. gate 4 takes the no-guard shape gates 1/2/14/16 already use.
- [ ] Rewrite gate 4's block comment so it no longer says "mirroring the Doc-lint gate above".
      State the disproved premise directly: `check-extension-docs.sh` errors without
      `agent-system/extensions` (gate 3's guard is correct and stays), while
      `check-task-references.sh` is repo-appropriate by construction and scans a consumer repo in
      full. Add one sentence recording that the remaining source-store-conditioned guards on the
      other gates are **unaudited**, not presumed removable by the same argument.
- [ ] `bash -n scripts/verify-deploy.sh`.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: `bash /home/benjamin/.config/nvim/agent-system/extensions/core/scripts/verify-deploy.sh --skip-slow --only-gate 4 /home/benjamin/Projects/BimodalLogic`
exercises exactly the one gate block this phase edits, and its before/after output
(`[SKIP]` + 0 checks, versus `[PASS] task-reference lint reports no findings` + 1 check) is a
direct observation of the change; no other gate's code path is touched.

**Files to modify**:
- `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/verify-deploy.sh` - gate 4
  block: SKIP branch removed, block comment rewritten

**Verification**:
- `bash -n` on the edited script: clean.
- Source-store copy, `--skip-slow --only-gate 4 /home/benjamin/Projects/BimodalLogic`: prints
  `[PASS] task-reference lint reports no findings` and `PASS -- 1 check(s), 0 failure(s)`, exit 0
  — no `[SKIP]` line.
- Source-store copy, `--skip-slow --only-gate 3 /home/benjamin/Projects/BimodalLogic`: still
  `[SKIP]` for gate 3 (its guard is deliberately unchanged).
- Source-store copy, `--skip-slow --only-gate 3,4 /home/benjamin/.config/nvim`: still
  `PASS -- 3 check(s), 0 failure(s)`, exit 0 — the source-store path is unaffected.

---

### Phase 3: Detect a zero-check run under an active --only-gate filter [NOT STARTED]

**Goal**: Make `verify-deploy.sh` report loudly and non-zero when an `--only-gate` selection
completes with zero checks executed, instead of printing `PASS -- 0 check(s), 0 failure(s)` and
exiting 0.

**Tasks**:
- [ ] At the end-of-run summary in `scripts/verify-deploy.sh`, before the existing
      `FAILURES -eq 0` PASS branch, add a branch for `GATES_FILTER` non-empty **and** `CHECKS`
      equal to 0. Emit a distinguishable message to stderr naming the selected gate id(s) and
      stating that every one of them skipped or was deferred, so the run attested to nothing, and
      exit 2 — the script's already-documented "cannot run; an automated gate MUST treat this the
      same as failure" code. No new exit code is introduced.
- [ ] Under `--findings`, emit a `FINDING gate0` line for this condition, matching the existing
      gate0 "could not run" sentinel convention.
- [ ] Decide and record in the code comment how a `--skip-slow --only-gate 8` selection is
      treated: the deferred gate contributes no check, so the run attests to nothing and the new
      branch fires. Say so in the message wording ("skipped or deferred"), so the result is not
      mistaken for the invalid-gate-id error.
- [ ] Extend `verify-deploy.sh`'s header `Exit codes:` / `Gate selection` documentation with the
      new condition, keeping the additive-only framing: with `--only-gate` absent, `GATES_FILTER`
      is empty and the branch is unreachable.
- [ ] `bash -n scripts/verify-deploy.sh`.

**Timing**: 1.25 hours

**Depends on**: 2

**Verification Tier**: interface

**Tier Justification**: the summary block is reached by every caller, so the check is a build of
the changed script plus its enumerated direct dependents — the two suites that consume
`--only-gate` (`scripts/tests/test-verify-deploy-gate-selection.sh`,
`scripts/tests/test-verify-deploy-context-budget.sh`) — plus a no-flag `--skip-slow` run against
this repo asserting the default path is unchanged.

**Files to modify**:
- `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/verify-deploy.sh` -
  end-of-run summary branch, `--findings` sentinel, header documentation

**Verification**:
- `bash -n` on the edited script: clean.
- Source-store copy, `--skip-slow --only-gate 3 /home/benjamin/Projects/BimodalLogic`: exit 2,
  stderr names gate 3 and states nothing was checked; no `PASS -- 0 check(s)` line.
- Source-store copy, `--findings --quiet --skip-slow --only-gate 3 /home/benjamin/Projects/BimodalLogic`:
  emits a `FINDING gate0 ` line for the condition, exit 2.
- Source-store copy, `--skip-slow .` (no filter) against this repo: `PASS -- 15 check(s),
  0 failure(s)`, exit 0 — the no-flag path is unchanged in exit code and reaches the ordinary
  PASS branch. (15, not 14: Phase 2 added one real gate-4 check.)
- `bash /home/benjamin/.config/nvim/agent-system/extensions/core/scripts/tests/test-verify-deploy-context-budget.sh`:
  green (its `--only-gate 20` invocations must still produce real checks).

---

### Phase 4: Regression cases for both script changes [NOT STARTED]

**Goal**: Pin Phase 2's and Phase 3's behavior in `test-verify-deploy-gate-selection.sh` so
neither can silently regress, and so the "all selected gates skipped" decision is encoded as a
test rather than only as a comment.

**Tasks**:
- [ ] Add a third fixture to `scripts/tests/test-verify-deploy-gate-selection.sh`: a
      deploy-consumer shape (no `agent-system/extensions`) whose `.claude` is a symlink to a real
      deploy tree, so `check-task-references.sh` is actually reachable there. Document in the
      fixture comment why `FIXTURE_CHEAP` cannot serve: its hand-built empty `.claude/scripts/`
      makes a de-guarded gate 4 reach the "not deployed" failure branch instead of a real check.
- [ ] Add a case asserting `--only-gate 4` against that fixture produces a real, non-`[SKIP]`,
      passing gate-4 check and a non-zero check count.
- [ ] Add a case asserting an all-SKIP selection (`--only-gate 3` against the same fixture) exits
      2 with the new named message and emits no `PASS -- 0 check(s)` line.
- [ ] Add a case asserting `--findings --only-gate 3` against that fixture emits the
      `FINDING gate0` line for the zero-check condition.
- [ ] Add a case asserting the deferred-gate selection (`--skip-slow --only-gate 8`) reaches the
      same loud result, encoding Phase 3's explicit decision.
- [ ] Re-check case (d)'s assumption: a no-flag run against `FIXTURE_CHEAP` now fails gate 4
      ("not deployed"). Case (d) asserts only that all 22 gate headers print, so it still holds —
      confirm that by running it, and adjust the fixture comment that currently claims gates 3-13
      etc. "all `[SKIP]` unconditionally" so it stays accurate for gate 4.
- [ ] Run the suite.

**Timing**: 1.5 hours

**Depends on**: 2, 3

**Verification Tier**: local

**Tier Justification**: the edit is confined to one test script with no externally visible
signature, and `bash /home/benjamin/.config/nvim/agent-system/extensions/core/scripts/tests/test-verify-deploy-gate-selection.sh`
is itself the covering check for it.

**Scope Hypothesis**: four new cases plus one fixture and one comment correction, in one file.
Confirm at implementation time by running the suite and counting its reported `PASS` lines
against the pre-change count (4 today: cases a, b, c×2, d); a different final shape is fine, but
every bullet above must be represented by an assertion that fails if the corresponding source
change is reverted — test each new case against a reverted copy of `verify-deploy.sh` to confirm
it actually discriminates.

**Files to modify**:
- `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/tests/test-verify-deploy-gate-selection.sh` -
  new fixture, four new cases, fixture-comment correction

**Verification**:
- `bash .../scripts/tests/test-verify-deploy-gate-selection.sh`: all cases pass, exit 0.
- Each new case demonstrated to fail against a temporarily reverted `verify-deploy.sh` (stash the
  source change, run, observe the specific case fail, restore) — the case discriminates rather
  than merely passing.
- The suite still invokes the source-store copy of `verify-deploy.sh`, never the deployed one.

---

### Phase 5: Correct plan-format.md's __FULL_SWEEP__ guidance [NOT STARTED]

**Goal**: Replace the single "ordinarily `--only-gate 3,4`" recommendation with a three-way
distinction, so a planner following the guidance names a check that actually runs.

**Tasks**:
- [ ] In `context/formats/plan-format.md`'s `## Verification Tiers` section, rewrite the
      `__FULL_SWEEP__` bullet to distinguish three sub-cases: (a) a phase whose touched paths lie
      entirely under `specs/**` — the honest check is `bash .claude/scripts/validate-artifact.sh
      <path> <type>` for a report/plan/summary, or the `prose` row's diff read-through for any
      other `specs/**` file; gate 3/4 is never it, because `specs/**` is the task-reference lint's
      own exempt tree by design and doc-lint has no bearing on `specs/**` content; (b) a
      source-store, non-`specs/**` markdown edit — a gate subset remains right, but the guidance
      must require an explicit `TARGET` naming the resolved `source_dir`, because
      `verify-deploy.sh`'s `TARGET` defaults to `$(pwd)`, which for any ordinary dispatch is the
      consumer repo root, not the source store; (c) a deploy-consumer-tree path with no mapped
      suite — `--only-gate 4` is now a real check there, gate 3 still correctly skips, so the
      subset is `4`, not `3,4`.
- [ ] Give sub-case (b) a concrete, copy-pasteable invocation shape with the explicit TARGET
      argument in the position `verify-deploy.sh` expects it.
- [ ] Keep the surrounding honesty constraints verbatim: the sentinel means no suite covers the
      file and the justification must not claim one; a narrowed pass is never equivalent to the
      full run for the phase's own purpose; neither narrowing mechanism is a fifth tier.
- [ ] Check whether any sibling file duplicates the "ordinarily `--only-gate 3,4`" recommendation
      rather than pointing at this section (`agents/planner-agent.md` points by reference and
      needs no edit; grep to confirm no other copy exists). Edit only genuine duplicates.

**Timing**: 1 hour

**Depends on**: 2, 3

**Verification Tier**: prose

**Tier Justification**: `bash /home/benjamin/.config/nvim/agent-system/extensions/core/scripts/verify-deploy.sh --skip-slow --only-gate 3,4 /home/benjamin/.config/nvim`
is the real covering check for a source-store `context/**` markdown edit (both gates run there:
measured `PASS -- 3 check(s)`), and it is the very invocation shape this phase's own sub-case (b)
prescribes — the guidance is checked by using it.

**Files to modify**:
- `/home/benjamin/.config/nvim/agent-system/extensions/core/context/formats/plan-format.md` -
  `__FULL_SWEEP__` bullet in `## Verification Tiers`

**Verification**:
- Source-store copy, `--skip-slow --only-gate 3,4 /home/benjamin/.config/nvim`:
  `PASS -- 3 check(s), 0 failure(s)`, exit 0 — doc-lint and the task-reference lint both clean on
  the edited file.
- Diff read-through: every changed hunk is prose inside the one bullet; the surrounding
  non-negotiable-invariant and tie-break paragraphs are byte-unchanged.
- `grep -rn -- "--only-gate 3,4" /home/benjamin/.config/nvim/agent-system/extensions/` returns
  only the corrected text (plus any intentionally quoted historical reference), confirming no
  stale duplicate of the old recommendation survives.

---

### Phase 6: Redeploy and full-gate verification [NOT STARTED]

**Goal**: Land the source-store changes in this repo's deployed tree and confirm, against the
measured pre-fix baseline, that the full battery is green with exactly one additional real check
and no new failures.

**Tasks**:
- [ ] Capture a pre-redeploy findings snapshot:
      `bash <source-store>/scripts/verify-deploy.sh --findings --quiet --skip-slow .` in this
      repo, saved to the scratchpad.
- [ ] Redeploy the source store into this repo per `context/patterns/regeneration-is-manual-only.md`
      (regeneration is manual-only; do not improvise an alternative sync path).
- [ ] Re-run the full battery against this repo using the **deployed** copy,
      `bash .claude/scripts/verify-deploy.sh --skip-slow .`, and diff its findings set against the
      pre-redeploy snapshot (`grep '^FINDING ' | sort -u`), not exit codes alone.
- [ ] Confirm the deployed `.claude/scripts/verify-deploy.sh` and
      `.claude/context/formats/plan-format.md` contain the Phase 2/3/5 changes (the edit reached
      the deploy tree, not just the source store).
- [ ] Run `bash .claude/scripts/check-task-references.sh` once more post-redeploy and record the
      result.

**Timing**: 1 hour

**Depends on**: 1, 4, 5

**Verification Tier**: full

**Files to modify**:
- None (deploy and verification only; the redeploy regenerates `.claude/**`, which is a
  disposable deploy artifact and never hand-authored)

**Verification**:
- `bash .claude/scripts/verify-deploy.sh --skip-slow .` (deployed copy, this repo):
  `PASS -- 15 check(s), 0 failure(s)`, exit 0 — exactly one more check than the measured pre-fix
  baseline of 14, with gate 4 now a real `[PASS]` and gate 3 still `[SKIP]`.
- Findings diff pre- versus post-redeploy: no new `FINDING` line.
- `bash .claude/scripts/verify-deploy.sh --skip-slow --only-gate 3 .`: exit 2 with the named
  zero-check message (the deployed copy carries Phase 3's change).
- `bash .claude/scripts/verify-deploy.sh --skip-slow --only-gate 4 .`: real `[PASS]`,
  `1 check(s)`, exit 0.
- `bash <source-store>/scripts/tests/test-verify-deploy-gate-selection.sh` and
  `.../test-verify-deploy-context-budget.sh`: both green.
- `bash .claude/scripts/check-task-references.sh`: `0 occurrence(s)`, exit 0.
- Full `verify-deploy.sh` gate set is the declared tier's complete check; `--skip-slow` is used
  for gate 8 only and, per `plan-format.md`, is not read as evidence for doc-sync pins — if any
  doc-sync pin is implicated by the redeploy's findings diff, run the full battery without
  `--skip-slow` before closing.

---

## Testing & Validation

- [ ] `--only-gate 4` against a deploy-consumer tree runs a real check and reports a non-zero
      check count (previously `[SKIP]`, 0 checks, exit 0).
- [ ] `--only-gate 3` against a deploy-consumer tree exits 2 with a named "nothing was checked"
      message instead of `PASS -- 0 check(s)`, exit 0.
- [ ] A no-flag `verify-deploy.sh --skip-slow` run is unchanged in shape and exit code, with
      exactly one additional check versus the pre-fix baseline of 14.
- [ ] `test-verify-deploy-gate-selection.sh` green, with each new case shown to fail against a
      reverted source change.
- [ ] `test-verify-deploy-context-budget.sh` green (the other `--only-gate` consumer).
- [ ] `check-task-references.sh` exits 0 repo-wide, before and after.
- [ ] Doc-lint and the task-reference lint both clean against the source store after the
      markdown edits (`--only-gate 3,4 <source_dir repo>`, 3 real checks).
- [ ] No file under `.claude/**` was hand-authored at any point; every edit was made in the
      source store and reached this repo only through the redeploy in Phase 6.

## Artifacts & Outputs

- `scripts/verify-deploy.sh` (source store): gate 4 de-guarded; zero-check-under-filter detection
  in the end-of-run summary; header documentation extended.
- `scripts/tests/test-verify-deploy-gate-selection.sh` (source store): new deploy-consumer
  fixture with a reachable deploy tree, four new cases.
- `context/formats/plan-format.md` (source store): corrected `__FULL_SWEEP__` guidance with the
  three-way sub-case distinction and an explicit-`TARGET` requirement.
- `context/standards/task-reference-exemptions.md` (source store): pointer to the declined
  archival-tree exemption decision; taxonomy table unchanged at 7 categories.
- `specs/decisions/no-task-references-enforcement-history.md` (source-store repo): the declined
  exemption decision and its three reasons.
- This repo's `.claude/**`: regenerated by the Phase 6 redeploy, not hand-authored.

## Rollback/Contingency

- Each phase is a separate, scoped commit, so any one can be reverted independently. Phases 2 and
  3 touch the same file in sequence, so revert them in reverse order if both must go.
- The script changes are additive-and-narrow: reverting gate 4's block restores the `[SKIP]`
  behavior exactly, and reverting the summary branch restores the prior `PASS -- 0 check(s)` path
  (the branch is unreachable with `GATES_FILTER` empty, so no default-path state must be undone).
- If the Phase 6 redeploy produces an unexpected findings-diff entry, do not close the task:
  leave the status `[PARTIAL]`, record the new finding, and treat the redeploy as the failing
  step rather than retro-fitting an explanation. The source store is a git repo; the source-side
  revert plus a clean redeploy is the recovery path.
- If `check-task-references.sh` is found non-zero at Phase 1, the premise of finding (2)'s
  disposition is void: stop, record the measured count, and re-scope that half rather than
  proceeding on the "already closed" assumption.
