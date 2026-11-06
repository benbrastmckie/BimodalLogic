# Implementation Plan: Task #889

- **Task**: 889 - Clear the live C16 (env_linter) gate failure so `scripts/check-module-invariants.sh` exits 0 again
- **Status**: [COMPLETED]
- **Effort**: 1.25 hours
- **Dependencies**: None
- **Research Inputs**: specs/889_ladderchain_c16_unusedarguments_clear/reports/01_ladderchain-c16-unusedarguments-clear.md
- **Artifacts**: plans/01_ladderchain-c16-unusedarguments-clear.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

One live `unusedArguments` finding — `mem_cellAt_of_shift_of_hasForwardSlack`, argument 23
(`hslk`) — makes C16 exit 1 in `scripts/check-module-invariants.sh`, blocking the gate for every
Lean task that runs it. The repair is two small, disjoint edits: extend the reason comment at the
declaration site so it names the *environment* linter and its remedy (the existing comment names
only the frontend `linter.unusedVariables`, which is precisely the gap that let the finding
reach the gate), then append one hand-written row to `scripts/nolints.json` in that file's
existing format. No statement, proof term, or axiom profile changes, and
`lake exe runLinter --update` is never run. Done when
`bash .claude/scripts/lake-build-guard.sh build --timeout 540 -- exe runLinter FormalSystem`
reports `Found 0 errors` and `scripts/check-module-invariants.sh` reports `PASS C16`.

### Research Integration

The research report settles the disposition and supplies the mechanics this plan executes:

- The finding reproduces live (`Found 1 error in 18103 declarations`), the `FormalSystem/` tree is
  clean, and the declaration's `.olean` is current.
- Root cause: line 2135's `set_option linter.unusedVariables false in` silences Lean's **frontend**
  linter only. C16's finding comes from Batteries' `@[env_linter] unusedArguments`, a declaration
  linter reading the compiled environment, which no `set_option linter.*` reaches. One linter was
  silenced; the other was missed.
- Disposition decided: a hand-inserted ledger row plus a repaired reason comment. Binder removal
  is unavailable because the signature is a pinned Challenge statement with `hslk` written out
  verbatim; proof-level consumption is dishonest (it only moves the deadness onto `hgap`, and the
  linter then reports argument 20); the in-source `@[nolint unusedArguments]` route is
  mechanically valid but splits one linter's exemption inventory across two mechanisms. Each
  rejection is recorded on its own merits in the report's Decisions section, and this plan does
  not restate those arguments.
- `scripts/nolints.json` is a flat array of `["unusedArguments", "<fully.qualified.Name>"]` pairs,
  227 rows, whose entire git history is hand-insertion of 1-4 rows at a time. Nothing diffs its
  length against a baseline, so adding a row breaks no second check.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap path was supplied with this dispatch; `specs/ROADMAP.md` was not consulted.

## Goals & Non-Goals

**Goals**:
- `mem_cellAt_of_shift_of_hasForwardSlack` — its environment-linter finding is cleared by one
  hand-inserted row in `scripts/nolints.json`, with its pinned signature, its proof term, and its
  axiom profile all untouched.
- The reason comment at the declaration site names both linters that see this binder and the
  distinct remedy each needs, so the next reader does not repeat the frontend-only mistake.
- `bash scripts/check-module-invariants.sh` exits 0 again, reporting C16 as PASS, so no downstream
  Lean task has to narrow its verification tier or carry a Reasoned Exclusions row for a failure
  it did not cause.

**Non-Goals**:
- Changing the signature of `mem_cellAt_of_shift_of_hasForwardSlack`, or re-pinning it. The
  statement is fixed by an existing Challenge pin; altering it is a deliberate decision about two
  completed tasks' records, not a lint repair, and is out of scope. No
  `## Lean Challenge Statements` section appears in this plan precisely because no statement is
  pinned, introduced, or modified here.
- Running `lake exe runLinter --update`. It rewrites the whole ledger from current findings in a
  different serialization, grandfathering any genuine regression alongside this row.
- Burning down the 227 pre-existing `unusedArguments` rows, or migrating the category to in-source
  `@[nolint unusedArguments]`. Both are separate, larger decisions.
- Repairing the stale "217 findings" header comments in `scripts/check-module-invariants.sh`
  (two occurrences, now understating a live 227). That file is inside concurrent sibling task
  860's declared `file_scope` this cycle, and no check reads those comments, so this task leaves
  them alone rather than contending for the file.
- Writing the plan-authoring guidance for this collision class. That record belongs to task 840,
  in the lean extension's source store; do not write into its file.
- The second, reporting-only half of C16 behind `ENFORCE_C16_ROOTS`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The ledger row is mistaken for grandfathering a genuine regression | M | M | The repaired comment at the declaration says why the dead binder is required, and the commit message states that the rejected alternative (binder removal) is blocked by a pinned signature, not by convenience. |
| A future `--update` run reserializes the ledger and buries the row | M | L | Out of this task's control. The prohibition is restated in the repaired comment itself, so it travels with the declaration rather than living only in task records. |
| `check-module-invariants.sh` fails on a check *other* than C16 because a sibling's in-flight edit landed | M | M | Sibling 860 holds `scripts/check-module-invariants.sh`, three README surfaces, `docs/theorem-index.md` and two `.lean` files this cycle. A non-C16 failure in a file outside this task's `file_scope` is reported, not repaired — see the territory contract. Re-read both target files immediately before editing. |
| `verify-deploy.sh` fails for deploy staleness unrelated to this task | L | M | The dispatch records the deployed `.claude/` tree as stale for five extensions. This task touches no `.claude/**` and no source-store path; a staleness-attributable gate failure is recorded with its cause in the phase's verification notes rather than treated as this task's regression. |
| The comment edit triggers a long rebuild of a large module | L | H | The module's `.olean` is current and the edit is comment-only, but `LadderChain.lean` is large: budget one scoped guarded build and use the bounded single-call wait idiom rather than an unbounded foreground call. |
| Hand-editing JSON produces an invalid ledger | H | L | Validate with `python3 -c "import json; json.load(open('scripts/nolints.json'))"` before running the linter, and confirm the row count moved by exactly one. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 1, 2 |

Phases within the same wave can execute in parallel. Phases 1 and 2 touch disjoint files and are
logically independent; Phase 2 nonetheless depends on Phase 1 for build economy — Phase 1
invalidates the module's `.olean`, so running Phase 1 first lets a single scoped rebuild serve
both, and Phase 2's `runLinter` run then reads current artifacts.

---

### Phase 1: Repair the reason comment at the declaration site [COMPLETED]

**Goal**: The comment above `set_option linter.unusedVariables false in` names both linters that
see `hslk`, the distinct remedy each needs, and the standing prohibition on `--update`.

**Tasks**:
- [ ] Re-read `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` around the
  declaration immediately before editing (a sibling may have moved line numbers), and confirm the
  three-line `--` comment block and the `set_option linter.unusedVariables false in` line are
  where this plan's Scope Hypothesis says they are.
- [ ] Replace the three-line `--` comment block with a block that states: (a) `hslk` is slack the
  `_exact` form does not need once the regime amount is `m · (P + 1)`, so the proof does not read
  it; (b) the statement is kept verbatim because it is a pinned Challenge statement — dropping the
  binder would be same-name-different-signature drift; (c) **two** linters see this binder — the
  frontend `linter.unusedVariables`, silenced by the `set_option ... in` below, and Batteries'
  `@[env_linter] unusedArguments` (what `lake exe runLinter` and C16 run), which no `set_option`
  reaches and which is exempted by the matching row in `scripts/nolints.json`; (d)
  `lake exe runLinter --update` must not be used to regenerate that ledger, because it rewrites
  the whole file from current findings and would grandfather any genuine regression along with
  this row.
- [ ] Keep the `set_option linter.unusedVariables false in` line exactly as it is — `hslk` is
  still an unused binder at the frontend, so removing the suppression reintroduces a build
  warning.
- [ ] Leave the declaration's `/-- ... -/` docstring, its signature, and its proof term byte-identical.
- [ ] Use no task-number reference anywhere in the comment: cite durable facts (a pinned Challenge
  statement, the ledger file's path) rather than "task N". The comment lives outside `specs/**`,
  where `.claude/rules/no-task-references-in-deliverables.md` applies.
- [ ] Confirm the comment-only claim mechanically:
  `git diff -U0 -- FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` shows added
  and removed lines that are all `--` comment lines, with no change to any `theorem`, `set_option`,
  docstring, or term line.
- [ ] Scoped guarded build:
  `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderChain`
  (plain foreground `timeout N <guard call>` with the Bash tool `timeout` raised to `600000` if it
  plausibly fits one call; otherwise detach as a shell-level background job and block with the
  bounded single-call idiom — never `Bash(run_in_background: true)`).
- [x] Commit this green sub-step, staging only
  `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` by explicit path. *(deviation:
  altered -- `typst/generated/status.typ` had to be staged in the same commit. The 11 net added
  comment lines moved `formalsystem-line-count` 388946 -> 388957, and the `typst-sync-check.sh`
  Check 2 pre-commit hook blocks any staged `.lean` change whose line count the committed
  `status.typ` no longer reflects. The drift was self-caused and exactly accounted for, so the
  hook's `--no-verify` bypass -- reserved for drift another writer caused -- was not used;
  `scripts/typst-sync-check.sh --fix` regenerated the file instead.)*

**Timing**: 0.3 hours (dominated by the scoped build).

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: At this plan's authoring the `--` reason comment occupies
`LadderChain.lean:2132-2134`, `set_option linter.unusedVariables false in` is line 2135, the
linter reports the finding at `2136:1`, and `theorem mem_cellAt_of_shift_of_hasForwardSlack`
begins at line 2142. Every one of those line numbers is a hypothesis measured before this
dispatch, not a fact: the implementer re-derives them with
`grep -n 'mem_cellAt_of_shift_of_hasForwardSlack\|set_option linter.unusedVariables' FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean`
and edits by matched text, never by line number alone, correcting the figures in the phase record
where they have moved.

**Tier Justification**: The edit is confined to `--` comment lines inside one module and changes
no externally visible signature, and the covering check is the scoped guarded build
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderChain`,
which re-elaborates the whole module and so catches the `prose` tier's blind spot (a hunk
escaping the comment boundary).

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - the three-line `--` reason
  comment above `set_option linter.unusedVariables false in` is replaced; nothing else in the file
  changes

**Verification**:
- `git diff -U0` on the file shows only `--` comment lines added and removed; no `theorem`,
  `set_option`, docstring, or term line appears in the diff.
- The scoped guarded build exits 0, read from the guard's own `result` output or an un-piped
  captured exit status — never a pipe exit code.
- `grep -c 'unusedArguments' FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean`
  returns at least 1 (the new comment names the environment linter), and
  `grep -n 'runLinter --update'` on the file returns the new prohibition line.
- `set_option linter.unusedVariables false in` is still present exactly once at the declaration.
- `grep -nE 'task [0-9]+|tasks [0-9]+' ` over the changed hunk returns nothing.

---

### Phase 2: Append the ledger row to `scripts/nolints.json` [COMPLETED]

**Goal**: `mem_cellAt_of_shift_of_hasForwardSlack` is exempted from `unusedArguments` by one
hand-inserted row, and `lake exe runLinter FormalSystem` reports `Found 0 errors`.

**Tasks**:
- [ ] Re-read `scripts/nolints.json` immediately before editing and record its row count
  (`python3 -c "import json; print(len(json.load(open('scripts/nolints.json'))))"`).
- [ ] Append, after the final existing entry and in the file's own existing two-element-array
  format and indentation:

  ```json
    [
      "unusedArguments",
      "FormalSystem.Metalogic.Decidability.RaySummary.mem_cellAt_of_shift_of_hasForwardSlack"
    ]
  ```

- [ ] Do **not** run `lake exe runLinter --update`, and do not reformat, re-sort, or re-serialize
  any existing row — the diff must be an addition only.
- [ ] Validate the JSON: `python3 -c "import json; json.load(open('scripts/nolints.json'))"` exits
  0, and the row count is exactly one greater than the figure recorded above.
- [ ] Confirm the addition is the whole diff: `git diff --stat -- scripts/nolints.json` shows
  insertions only, zero deletions.
- [x] Run the finding's own check:
  `timeout 560 bash .claude/scripts/lake-build-guard.sh build --timeout 540 -- exe runLinter FormalSystem`
  and confirm `Found 0 errors` with exit status 0. *(deviation: altered -- the green verdict reads
  `-- Linting passed for FormalSystem.`, not `Found 0 errors`. runLinter prints the
  `Found N errors in M declarations` line only on a FAILING run; the literal string this plan
  asked for cannot appear on a clean run. Exit status 0 from the guard's own `result` record is
  the verdict actually read.)*
- [ ] Commit this green sub-step, staging only `scripts/nolints.json` by explicit path, and state
  in the message both the disposition and the `--update` prohibition.

**Timing**: 0.4 hours (dominated by the `runLinter` run).

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: `scripts/nolints.json` carries 227 rows at this plan's authoring, every one
of linter `unusedArguments`, and `check-module-invariants.sh` is its only consumer across
`scripts/*.sh` and `scripts/lib/*.sh`. Both figures are hypotheses measured before this dispatch:
the implementer re-derives the count with the `python3` one-liner above and re-derives the
consumer set with `grep -rn 'nolints.json' scripts/`, recording any divergence in the phase
record. The expected post-edit count is 228.

**Tier Justification**: The edit appends one row to a single JSON data file with no compile
surface and no externally visible signature, and the covering check is
`timeout 560 bash .claude/scripts/lake-build-guard.sh build --timeout 540 -- exe runLinter FormalSystem`
— the exact command that reports the finding, and the one C16 itself runs.

**Files to modify**:
- `scripts/nolints.json` - one `["unusedArguments", "…mem_cellAt_of_shift_of_hasForwardSlack"]`
  row appended; no existing row touched

**Verification**:
- `python3 -c "import json; json.load(open('scripts/nolints.json'))"` exits 0 and the row count is
  the Phase 2 baseline plus exactly one.
- `git diff --numstat -- scripts/nolints.json` shows 4 insertions and 0 deletions.
- The guarded `exe runLinter FormalSystem` run exits 0 and its output reads `Found 0 errors`, read
  from the guard's `result` output or an un-piped captured status.
- `git log -1 --stat` for this commit lists `scripts/nolints.json` and nothing else.

---

### Phase 3: Close the C16 gate and the full gate set [COMPLETED]

**Goal**: The repo-wide gate that this task exists to unblock exits 0, and the complete gate set
is observed green, with any failure attributable to a sibling's in-flight edit or to deploy
staleness reported as such rather than silently repaired.

**Tasks**:
- [x] Run `bash scripts/check-module-invariants.sh` to completion and confirm exit 0 with C16
  reported PASS. Use a bounded wait (the script runs the full `runLinter` suite); if it must be
  detached, block on it with the bounded single-call idiom and writer liveness via `kill -0` on
  the captured PID. *(completed: `ALL CHECKS PASSED`, exit 0, `PASS C16 env_linter batch ... has
  no un-nolisted finding`.)*
- [x] If any check *other* than C16 fails: check `git log` and `git status --short` to establish
  whether the implicated file is this task's (`LadderChain.lean`, `scripts/nolints.json`) or a
  concurrent sibling's. A failure in a file outside this task's `file_scope` is STOPPED on and
  reported per the territory contract — never repaired here, and never dismissed as noise.
  *(deviation: altered — the first run DID fail a non-C16 group, `FAIL INV 3 file(s) carry a stale
  generated inventory block`, naming the exact three README surfaces this plan's risk table
  attributed to a concurrent sibling. The attribution test ran and overturned that reading: the
  inventory blocks record per-file LINE COUNTS, `LadderChain.lean` recorded at 2,216 against a live
  2,227, so the staleness is this task's own +11-line comment edit cascading up three aggregator
  READMEs; task 860 is `completed` in state.json rather than live, the only contention manifest on
  disk is from an unrelated session and names only `docs/theorem-index.md`, and `git status` showed
  no uncommitted README edits. Self-caused, so repaired rather than reported, with
  `bash scripts/check-module-invariants.sh --emit-inventory` — three one-number diffs, all +11.)*
- [x] Run `bash .claude/scripts/verify-deploy.sh` and read its per-gate output, not merely its
  exit code; confirm no gate is reported as skipped-under-filter. The dispatch records the
  deployed tree as stale for five extensions: a failure traceable to that staleness is recorded
  with its cause in this phase's verification notes, not attributed to this task's edits, and not
  masked by hand-patching anything under `.claude/**`. *(deviation: altered — discharged against a
  SCOPED tier per the dispatch's Batch Gate Deferral directive, which this phase's
  `**Verification Tier**: full` field is not edited by. Narrowing invocation:
  `bash .claude/scripts/verify-deploy.sh --only-gate 4` (the task-reference lint, gate 4) —
  `[PASS] task-reference lint reports no findings`, `PASS -- 1 check(s), 0 failure(s)`, exit 0,
  nothing skipped under filter. Gate 4 is the only verify-deploy gate covering a file this task
  touched: every other gate lints the `.claude/` deploy tree or the agent-system source store, and
  this task touched no path under either. The complete gate set runs once for the whole batch at
  the end of the /orchestrate invocation and is attributed back by this task's `modified_files`;
  it is deferred here, not forgiven. No deploy-staleness-attributable failure was observed in the
  scoped run, so the dispatch's five-extension staleness notice had no bearing on this task's
  verdict.)*
- [x] Run `bash .claude/scripts/validate-artifact.sh specs/889_ladderchain_c16_unusedarguments_clear/plans/01_ladderchain-c16-unusedarguments-clear.md plan`
  and confirm exit 0. *(completed: `[PASS] plan artifact is valid (0 warning(s))`, exit 0.)*
- [x] Run `bash .claude/scripts/check-task-references.sh` and confirm exit 0 — the Phase 1 comment
  edit is the one hunk this task lands outside `specs/**`. *(completed: `PASS: 0 unexempted
  task-reference occurrences`, exit 0. Note the hunk count: this task landed four hunks outside
  `specs/**`, not one — the comment edit plus `typst/generated/status.typ` and three README
  inventory blocks, both cascades of the comment's net line count.)*
- [x] Confirm `git status --short` is clean for this task's two files and that
  `git log --stat` over this task's commits lists only those two. *(deviation: altered — clean for
  all SIX files, not two. `git status --short` is empty for `LadderChain.lean`,
  `scripts/nolints.json`, `typst/generated/status.typ` and the three READMEs, and this task's three
  commits (30fe201d4, 116c6c2af, 0d3454284) list exactly those six files and nothing else. The
  four beyond the planned two are the generated-artifact cascade of the comment edit's net line
  count, each regenerated by its own sanctioned generator rather than hand-patched.)*

**Timing**: 0.55 hours.

**Depends on**: 1, 2

**Verification Tier**: full

**Commit Mode**: per-substep

**Files to modify**:
- None — this phase is verification only.

**Verification**:
- `bash scripts/check-module-invariants.sh` exits 0, with C16 reported PASS in its output.
- `bash .claude/scripts/verify-deploy.sh` exits 0 with no gate skipped under filter, its per-gate
  output read rather than only its status; any staleness-attributable failure is named with its
  cause.
- `bash .claude/scripts/validate-artifact.sh <this plan> plan` exits 0.
- `bash .claude/scripts/check-task-references.sh` exits 0.
- `git status --short` shows nothing uncommitted for `LadderChain.lean` or `scripts/nolints.json`,
  and this task's commits touch no other file.

---

## Testing & Validation

- [ ] `timeout 560 bash .claude/scripts/lake-build-guard.sh build --timeout 540 -- exe runLinter FormalSystem`
      reports `Found 0 errors` and exits 0.
- [ ] `bash scripts/check-module-invariants.sh` exits 0 with C16 PASS.
- [ ] The scoped guarded build of
      `FormalSystem.Metalogic.Decidability.RaySummary.LadderChain` exits 0.
- [ ] `python3 -c "import json; json.load(open('scripts/nolints.json'))"` exits 0; row count is
      the pre-edit count plus one.
- [ ] `mem_cellAt_of_shift_of_hasForwardSlack`'s signature and proof term are byte-identical to
      their pre-task state: `git diff <base>..HEAD -- FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean`
      shows only `--` comment lines.
- [ ] Zero new `sorry` and no axiom-profile change (nothing in this task touches a proof term).
- [ ] `lake exe runLinter --update` appears in no command this task ran.
- [ ] `bash .claude/scripts/verify-deploy.sh` and `bash .claude/scripts/check-task-references.sh`
      both exit 0.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` — repaired reason comment
  naming both linters and their distinct remedies.
- `scripts/nolints.json` — 1 appended `unusedArguments` row.
- `specs/889_ladderchain_c16_unusedarguments_clear/plans/01_ladderchain-c16-unusedarguments-clear.md`
  — this plan.
- `specs/889_ladderchain_c16_unusedarguments_clear/summaries/01_ladderchain-c16-unusedarguments-clear-summary.md`
  — round summary at implementation postflight.

## Rollback/Contingency

Both edits are additive and tiny, so forward repair is almost always the right move: if
`runLinter` still reports a finding after Phase 2, the fully-qualified name in the appended row is
the first thing to check against the linter's own output (`FormalSystem.Metalogic.Decidability.RaySummary.` prefix,
exact spelling of the declaration), and a mismatch is fixed in place rather than reverted.

If a genuine revert is needed, each phase committed separately, so `git revert <sha>` of either
commit restores the prior state with no working-tree discard. Do **not** reach for a
working-tree-discarding rollback here: concurrent siblings are live on this tree this cycle, and
discarding uncommitted work would take their edits with it. Should a snapshot-then-rollback
genuinely become necessary, follow `context/contracts/recovery.md`'s rollback rung for the exact
invocation shape — including its out-of-scope override flag — rather than emitting a bare
`git-snapshot.sh` call as a precaution.

If the finding turns out not to be clearable by a ledger row at all (for instance, the linter
reports a second, different argument after the row lands), mark the phase `[BLOCKED]` and raise
it: the sanctioned response to "the pinned statement itself looks wrong" is escalation, never a
quiet change to the implementation or to the pin.
