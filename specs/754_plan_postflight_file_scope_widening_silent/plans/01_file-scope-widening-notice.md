# Implementation Plan: Task #754

- **Task**: 754 - Make the plan-postflight file_scope widening observable instead of silent
- **Status**: [NOT STARTED]
- **Effort**: 2.25 hours
- **Dependencies**: None
- **Research Inputs**: specs/754_plan_postflight_file_scope_widening_silent/reports/01_file_scope_widening_notice.md
- **Artifacts**: plans/01_file-scope-widening-notice.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

The harvest-and-widen mechanism already works; the only residue is that the union-merge is
unannounced on every real write path. This plan implements the dispatch's option (a): a single
non-blocking `[file-scope]` notice emitted from `update-task-status.sh` itself, gated on the
actual post-merge delta rather than the raw forwarded list, at the two points inside
`update_state_json()` where the merge can fire. Tests land in the writer's own suite (whose
existing `Case 11` sub-cases already constitute the delta, no-delta, and partial-overlap
scenarios) plus one end-to-end assertion on the live plan-postflight path. All edits land in the
`core` extension's source store, never the deployed tree.

### Research Integration

Key findings carried into this plan:

- The merge fires in exactly two places inside `update_state_json()`: the `state_is_noop == true`
  branch's dedicated `state-write.sh` call, and the shared status-write `state-write.sh` call
  that closes the function. The existing `--dry-run` echo never executes on either.
- There is exactly **one** live call site reaching the merge: `skill_postflight_update` in
  `scripts/skill-base.sh`. `scripts/orchestrator-postflight.sh`'s parallel Stage 7 branch has no
  live caller (its own header comment says so). This confirms option (b) is the wrong altitude
  and makes a writer-side notice the single choke point covering every present and future caller.
- `FILE_SCOPE_ADD_LEN` is already computed once and already gates every file_scope branch, and is
  mutually exclusive with `RESEARCH_QUESTIONS_LEN` / `HOLD_SET` / `UNHOLD_SET` by the flags' own
  operation and target-status restrictions — so the same variable is the correct gate for the
  notice with no new mutual-exclusion reasoning.
- The file already establishes a bracket-tag, stderr-only, non-blocking notice convention twice
  (`[phase-check]`, `[deploy-check]`), so `[file-scope]` is the matching tag.
- The delta is computable from state already in hand via the same pre-write `jq` lookup pattern
  the `--depends-on-add` dry-run preview already uses.

Independently re-derived during planning, beyond the report:

- **No caller captures this script's output in a command substitution.** A repository-wide sweep
  for `$(... update-task-status.sh ...)` and `update-task-status.sh ... 2>&1` found zero hits, and
  `skill-base.sh` invokes it as a bare statement capturing only `$?`. A stderr line therefore
  cannot be mistaken for parsed output by any existing consumer.
- **`test-update-task-status.sh`'s `Case 11` already contains the exact three scenarios needed**,
  each already redirecting stderr to its own log: `11a` merges two genuinely new paths on the
  real-write branch, `11b` re-forwards an identical array (delta zero — the cry-wolf case), and
  `11c` forwards one already-present and one new path on the no-op branch (delta one). No new
  fixture is required for any of the three assertions.
- **`test-skill-base-lifecycle.sh`'s `Group 4a` already captures the live plan-postflight
  stderr** to `harvest-postflight-stderr.log` while merging two new paths into a null
  `file_scope`, so the end-to-end assertion is one `grep` against an existing log.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap path was provided in this dispatch and no roadmap consultation was requested, so no
roadmap alignment is claimed.

## Goals & Non-Goals

**Goals**:
- Emit one non-blocking, stderr-only `[file-scope]` notice from `update-task-status.sh` whenever
  a `--file-scope-add` merge actually widens the task's `file_scope`, naming the task number, the
  count of genuinely new paths, and those paths.
- Gate that notice strictly on the post-merge delta, so a postflight that forwards only
  already-present paths stays silent.
- Cover both merge sites (the `state_is_noop` branch and the shared real-write branch) from the
  writer, so every present and future caller is covered without duplication.
- Lock the behavior in with assertions for all three cases (delta on the real-write branch, delta
  on the no-op branch, and no notice at zero delta) plus one end-to-end assertion on the live
  plan-postflight path.
- Document the notice at the `--file-scope-add` flag's own header comment and in the `File Scope
  Field` section of the state-management schema reference.

**Non-Goals**:
- No change to `scripts/plan-file-scope-harvest.sh` or to the harvest grammar.
- No change to the union-merge semantics (additive, `unique`, never overwrite) — observability
  only.
- No new gate, no blocking behavior, no exit-code effect, no stdout output.
- No notice duplicated into `skill-base.sh` or `orchestrator-postflight.sh` (option (b)
  rejected), and no durable per-task record of the widening (option (c) rejected: no consumer for
  such a record exists, and a stderr notice fully discharges the three stated consequences).
- No change to the implement-postflight excursion predicate in
  `orchestrate-cycle-postflight.sh`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Notice fires on every postflight regardless of change ("cry wolf"), which the dispatch calls worse than silence | H | M | Gate on the computed delta (`$add - $old \| length > 0`), never on `FILE_SCOPE_ADD_LEN` alone; `11b` asserts the silent case explicitly |
| A new stderr line trips an existing suite that asserts exact or empty stderr around an `update-task-status.sh` call | M | L | Planning sweep found the only empty-stderr assertions belong to unrelated subjects (a region-extraction helper and `skill_lifecycle_notify`), not to this writer; the final phase's full gate run is the backstop |
| Notice miswired into the shared real-write `state-write.sh` call so it also fires for the `research_questions` / `hold` / `unhold` / `depends-on-add` clauses riding the same call | M | L | Gate strictly on `FILE_SCOPE_ADD_LEN -gt 0`, which the file's existing flag validation already makes mutually exclusive with those clauses |
| Notice printed even when the write failed | M | L | Emit only after the `state-write.sh` invocation returns success, on both branches; never alter the function's return value |
| Pre-write delta read races a concurrent widen (TOCTOU) | L | L | The merge is additive-only inside `state-write.sh`'s mutex, so a stale pre-read can only undercount — it can never report a false "nothing changed" |
| Edit lands in the deployed tree and is wiped by the next deploy | H | L | Every edit targets `/home/benjamin/.config/nvim/agent-system/extensions/core/`; the deployed paths are mirrors only, and the final phase redeploys and verifies |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Emit the delta-gated `[file-scope]` notice from the writer [NOT STARTED]

**Goal**: `update-task-status.sh` announces an actual `file_scope` widening on both real write
paths, and stays silent when nothing changed.

**Tasks**:
- [ ] Run `bash .claude/scripts/deploy-headless.sh` and confirm `RESULT=landed_verify_clean`
      before reading or reasoning about the deployed copy.
- [ ] Re-read `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/update-task-status.sh`
      immediately before editing (a sibling task is dispatched this same cycle).
- [ ] Confirm the merge-site hypothesis mechanically: `grep -n 'FILE_SCOPE_ADD_LEN' ` on the
      source-store file, and verify the write-path hits are exactly the `state_is_noop` branch's
      dedicated `state-write.sh` call and the `jq_filter` extension feeding the shared
      `state-write.sh` call that closes `update_state_json()`.
- [ ] Inside `update_state_json()`, after the `DRY_RUN` early-return and before the
      `state_is_noop` branch, compute the delta once, guarded by `FILE_SCOPE_ADD_LEN -gt 0`:
      read the task's current `file_scope` from `$STATE_FILE` with the same keyed `jq` lookup
      shape the `--depends-on-add` dry-run preview uses, then derive the genuinely-new array
      (`$add - $old | unique`) and its length into locals.
- [ ] Add a small local helper that emits the single notice to stderr and returns 0
      unconditionally, so neither call site can affect control flow. Message shape (stable
      substrings `[file-scope]` and the count, so tests need not match the whole line):
      `[file-scope] Task <N>: file_scope widened by <count> new path(s) via --file-scope-add: <json-array> -- proceeding.`
- [ ] Call the helper from the `state_is_noop` branch's file_scope arm, only on a successful
      `state-write.sh` return (the existing `|| { echo "Warning: ..." }` arm must stay the
      failure path and must not emit the notice).
- [ ] Call the helper after the shared `state-write.sh` invocation that closes
      `update_state_json()` returns success, gated on `FILE_SCOPE_ADD_LEN -gt 0` and a non-zero
      delta — placed after the `if ! "$SCRIPT_DIR/state-write.sh" ... then return 1; fi` block so
      a failed write never prints it.
- [ ] Extend the `# Optional flag: --file-scope-add=<json-array>` header comment block to record
      the notice: that a widening is announced on stderr, that the notice reports the post-merge
      delta rather than the forwarded list, and that it is non-blocking with no exit-code or
      stdout effect. Cite durable anchors (file names, function names, field names) only — no
      task numbers, no version language.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: `bash .claude/scripts/tests/run-all.sh --only test-update-task-status`
is the suite that owns `update-task-status.sh`'s own behavior and is the cheapest check covering
an additive stderr line confined to one function of one script.

**Scope Hypothesis**: the merge fires at exactly two sites inside `update_state_json()` (the
`state_is_noop` branch and the shared closing `state-write.sh` call) and nowhere else; the
implementer must confirm this by grepping `FILE_SCOPE_ADD_LEN` across the source-store script
before editing, and widen the edit if a third write-path hit exists.

**Files to modify**:
- `.claude/scripts/update-task-status.sh` - delta computation, notice helper, two emission
  sites, and the `--file-scope-add` header-comment documentation. **Edit target**:
  `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/update-task-status.sh`.

**Verification**:
- `bash -n` on the edited source-store script parses clean.
- `shellcheck` on the edited script reports no new findings relative to its pre-edit output.
- A scratch-fixture probe (two consecutive `postflight <N> research --file-scope-add=...` calls
  with an identical array) shows the notice exactly once, on the first call only, with stdout
  unchanged and exit status 0 on both calls.
- `bash .claude/scripts/tests/run-all.sh --only test-update-task-status` passes (pre-existing
  assertions only at this point; new assertions land in Phase 2).

---

### Phase 2: Assert the notice in the writer's suite and on the live plan-postflight path [NOT STARTED]

**Goal**: all three notice behaviors, plus the end-to-end surfacing through the one live caller,
are locked in by assertions.

**Tasks**:
- [ ] Re-read both test files immediately before editing.
- [ ] In `scripts/tests/test-update-task-status.sh` `Case 11`, add an assertion to `11a` that
      `$WORKDIR/c11a.err` contains a `[file-scope]` notice naming a count of 2 (the real-write
      branch, null `file_scope` gaining both paths).
- [ ] Add an assertion to `11b` that `$WORKDIR/c11b.err` contains **no** `[file-scope]` line (the
      zero-delta cry-wolf case, on the status no-op branch).
- [ ] Add an assertion to `11c` that `$WORKDIR/c11c.err` contains a `[file-scope]` notice naming
      a count of 1 (the no-op branch with one already-present and one genuinely new path).
- [ ] Extend `Case 11`'s header comment to name the notice assertions alongside the merge
      assertions it already describes.
- [ ] In `scripts/tests/test-skill-base-lifecycle.sh` `Group 4a`, add one assertion that
      `$WORKDIR/harvest-postflight-stderr.log` contains a `[file-scope]` notice naming a count of
      2, proving the notice reaches an operator through the actually-live plan-postflight path
      (`skill_postflight_update`), not only through a direct writer invocation.
- [ ] Match on the stable substrings (`[file-scope]` and the count) rather than the full line, so
      a later wording change does not break the suites.

**Timing**: 45 minutes

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: `bash .claude/scripts/tests/run-all.sh --only test-update-task-status,test-skill-base-lifecycle`
runs both suites carrying the new assertions, which is the cheapest check that exercises both
emission sites and the live caller path.

**Scope Hypothesis**: `Case 11`'s existing `11a`/`11b`/`11c` sub-cases already produce delta-2
(real-write), delta-0, and delta-1 (no-op) respectively, and `Group 4a` already produces delta-2
through the live path — so no new fixture is needed. The implementer must confirm each sub-case's
actual pre-call `file_scope` state from the suite source before asserting a specific count, and
add a fixture only if a count differs from the hypothesis.

**Files to modify**:
- `.claude/scripts/tests/test-update-task-status.sh` - three `Case 11` notice assertions and a
  header-comment extension. **Edit target**:
  `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/tests/test-update-task-status.sh`.
- `.claude/scripts/tests/test-skill-base-lifecycle.sh` - one `Group 4a` end-to-end notice
  assertion. **Edit target**:
  `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/tests/test-skill-base-lifecycle.sh`.

**Verification**:
- `bash -n` on both edited suites parses clean.
- `bash .claude/scripts/tests/run-all.sh --only test-update-task-status,test-skill-base-lifecycle`
  passes with the new assertions reported as passes, not skips.
- Temporarily reverting the Phase 1 notice emission makes the three positive assertions fail and
  the `11b` negative assertion still pass, confirming the assertions actually bind to the new
  behavior; restore the emission afterward.

---

### Phase 3: Document the observability surface, redeploy, and run the full gate set [NOT STARTED]

**Goal**: the notice is documented where `file_scope` is specified, the deployed tree matches the
source store, and the complete gate set is green.

**Tasks**:
- [ ] Re-read `context/reference/state-management-schema.md` immediately before editing.
- [ ] Under the `### File Scope Field` section, add a short observability note: the field is
      widened additively at research and plan postflight by `update-task-status.sh`'s
      `--file-scope-add` flag, and a widening that actually adds paths is announced on stderr as
      a non-blocking `[file-scope]` notice naming the count of new paths; a forward whose paths
      are all already present writes nothing and prints nothing. State the current design only —
      no task numbers, no version language, no narration of earlier behavior.
- [ ] Run `bash .claude/scripts/deploy-headless.sh` and confirm `RESULT=landed_verify_clean`
      after the source-store edits.
- [ ] Run the complete gate set and triage every finding to green or to an explicitly reasoned,
      evidenced exclusion.

**Timing**: 30 minutes

**Depends on**: 2

**Verification Tier**: full

**Scope Hypothesis**: `suite_selection_select` maps the touched paths to 20 covering suites, and
the planning sweep found no existing suite asserting exact or empty stderr around an
`update-task-status.sh` invocation that carries `--file-scope-add`. The implementer must confirm
this by the full gate run itself: a failure in any of those suites traceable to the new stderr
line falsifies the hypothesis and must be fixed in the writer or in that suite's assertion, never
by removing the notice.

**Files to modify**:
- `.claude/context/reference/state-management-schema.md` - observability note under
  `### File Scope Field`. **Edit target**:
  `/home/benjamin/.config/nvim/agent-system/extensions/core/context/reference/state-management-schema.md`.

**Verification**:
- `bash .claude/scripts/deploy-headless.sh` reports `RESULT=landed_verify_clean`.
- `bash .claude/scripts/verify-deploy.sh` (the complete gate set, no `--only-gate`, no
  `--skip-slow`) passes, including Gate 8's full shell-suite battery, Gate 3's doc lint, and
  Gate 4's task-reference lint.

---

## Testing & Validation

- [ ] A `--file-scope-add` forward that adds genuinely new paths prints exactly one
      `[file-scope]` notice on stderr, on both the real-write and the status-no-op branch.
- [ ] A `--file-scope-add` forward whose paths are all already present prints nothing.
- [ ] The notice names the count of genuinely new paths, not the length of the forwarded array.
- [ ] Nothing is written to stdout, and `update-task-status.sh`'s exit status is unchanged in
      every case (including the failure arms, where no notice is printed).
- [ ] The notice surfaces through `skill_postflight_update`, the one live plan-postflight caller.
- [ ] `bash .claude/scripts/verify-deploy.sh` is green and the deployed tree verifies clean.

## Artifacts & Outputs

- `[file-scope]` notice emission and delta computation in `update-task-status.sh`
  (`update_state_json()`), plus its `--file-scope-add` header-comment documentation.
- Three `Case 11` assertions in `test-update-task-status.sh` and one `Group 4a` assertion in
  `test-skill-base-lifecycle.sh`.
- An observability note under `### File Scope Field` in `state-management-schema.md`.
- A redeployed, verify-clean `.claude/` tree.
- An execution summary under `specs/754_plan_postflight_file_scope_widening_silent/summaries/`.

## Rollback/Contingency

Every change is additive and confined to four source-store files, so reversion is a per-file
`git revert`/checkout of those hunks in the source store followed by
`bash .claude/scripts/deploy-headless.sh`. Because the notice is stderr-only, non-blocking, and
has no exit-code or stdout effect, an unreverted partial landing degrades to the current silent
behavior rather than to a broken postflight. If an unrelated suite fails on the new stderr line
and cannot be reconciled within the phase, record it in the issue log, keep the notice, and
narrow the failing assertion — removing the notice is not a contingency, since silence is the
defect this plan exists to fix. Do not run `git-snapshot.sh` in its reverting default mode while
a sibling task is dispatched on this same working tree; use `--no-revert` for any defensive
checkpoint.
