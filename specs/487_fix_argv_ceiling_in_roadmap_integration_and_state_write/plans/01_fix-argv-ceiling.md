# Implementation Plan: Task #487

- **Task**: 487 - Fix 128KB argv ceiling in roadmap-integration.sh and state-write.sh
- **Status**: [NOT STARTED]
- **Effort**: 8.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/487_fix_argv_ceiling_in_roadmap_integration_and_state_write/reports/01_fix-argv-ceiling.md
- **Artifacts**: plans/01_fix-argv-ceiling.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Two shell scripts in the agent-system source store crash with `Argument list too long` (exit 126)
because they pass unbounded JSON payloads through a single argv token, past Linux's
`MAX_ARG_STRLEN` of 131,072 bytes. `roadmap-integration.sh` fails unconditionally against the live
`specs/ROADMAP.md` today; `state-write.sh` fails for any caller whose `--argjson` value is
oversized. Beyond the argv fix, the task's acceptance bar additionally requires making
`--annotate` atomic (a failed run must leave `ROADMAP.md` byte-identical) and tightening the
`explicit_task_ref` heuristic that wrongly checked off a roadmap item. Done means: both scripts
exit 0 on the exact invocations that fail today, a forced mid-run failure mutates nothing,
regression tests exist above the 128KB ceiling for both scripts, and the edits are made in the
source store and redeployed with the `.claude/` copies confirmed matching.

### Research Integration

The research report (`reports/01_fix-argv-ceiling.md`) is the primary input and materially changes
the plan's shape in five ways:

1. **The source store is NOT `agent-system/` under this repo** — that directory does not exist
   here. Confirmed via `.claude-extensions.json`'s per-extension `source_dir`, the real path is
   `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/`. The task description's
   relative path is therefore misleading and every phase below uses the absolute path.
   Independently re-confirmed at plan time: both files exist there and are byte-identical to
   `.claude/scripts/` today (`diff -q` clean).
2. **`--slurpfile` is the established codebase convention** for large single-payload jq inputs
   (used in `install-extension.sh`, `orchestrate-batch-admit.sh`, `orchestrate-triage-classify.sh`,
   `orchestrate-predispatch-review.sh`, `system-defect-record.sh`, `validate-context-budgets.sh`).
   The fix follows that precedent rather than inventing a mechanism.
3. **The fix pattern already exists one call site over inside `roadmap-integration.sh` itself**
   (lines ~363-373, temp files + `json.load()` for the `ROADMAP_STATE`/`ALL_COMPLETED` payloads),
   with an in-file comment forward-referencing "the analogous fix" that was never made at the
   final `jq -n`.
4. **Requirement 2 is a structural redesign, not a side effect of requirement 1.** The annotate
   loop writes each annotation to `$ROADMAP_PATH` in place before the report step runs; removing
   the crash does not make the loop atomic.
5. **Requirement 3 is a data-flow change, not a regex tweak.** The Python matching step has no
   visibility into non-terminal tasks at all — only the completed/archived subset is passed in.

Two design choices the report explicitly left to planning are resolved here (see Decisions below):
transparent auto-spill for `state-write.sh`, and requirement 4 (payload trimming) descoped.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied in the delegation context and `roadmap_flag` was not set, so no
roadmap review/update phases are included. Note the second-order relationship: `specs/ROADMAP.md`
exists in this repo and the tooling repaired by this task is precisely the tooling that reads and
annotates it — so completing this task restores roadmap integration for `/review` and `/todo`
generally, rather than advancing any single roadmap item.

## Goals & Non-Goals

**Goals**:
- `roadmap-integration.sh` exits 0 in both parse-only and `--annotate` modes against the live
  `specs/ROADMAP.md` and full `specs/state.json`.
- Any mid-run failure in `--annotate` mode leaves `ROADMAP.md` byte-identical to its pre-run state.
- `state-write.sh` accepts a >128KB `--argjson` payload in a single call, producing state.json
  byte-identical to the batched workaround.
- `explicit_task_ref` no longer marks an item complete when the item text also references a
  still-non-terminal task.
- Regression tests above the 128KB ceiling exist for both scripts, following existing test
  conventions.
- Edits land in the source store and are redeployed, with `.claude/` copies confirmed identical.

**Non-Goals**:
- **Requirement 4 (per-match payload trimming) is descoped.** It is framed as "consider" in the
  task description; once payloads no longer transit argv the ~20KB-per-match size is not a
  correctness problem, and the annotate loop reads `line_index`/`raw_line`/`status_index` directly
  out of `ROADMAP_MATCHES`, so trimming would require re-plumbing those fields. Recorded here as a
  deliberate, separable exclusion rather than an oversight.
- **No changes to `skill-todo/SKILL.md` or `commands/todo.md`.** The transparent-spill design
  (Decisions, below) makes every existing `--argjson` call site work unchanged, so the report's
  "must be updated in tandem" risk is retired by construction rather than managed.
- No change to `state-write.sh`'s mutex, staging, `--init`, `--state-file`, `--regen-todo`, or
  exit-code (0/1/2/3/4) semantics.
- No change to the JSON report schema `roadmap-integration.sh` emits — `/review` consumes it
  unchanged.
- No hand-editing of `.claude/**` (see `.claude/rules/source-store-deploy-boundary.md`).

## Decisions

**D1 — `state-write.sh` fix shape: transparent auto-spill (report's Shape 2), plus an additive
`--argjson-file NAME PATH` flag.** The report presented two viable shapes. Transparent spill is
chosen because it requires zero changes at any of the ~10 existing call sites and protects future
callers who construct an oversized payload without knowing a special flag exists. `--argjson-file`
is added alongside it purely as a convenience for callers that already have the payload on disk;
it is additive and no caller is migrated onto it in this task.

**D2 — Spill threshold: 100,000 bytes**, comfortably under the 131,072-byte ceiling, leaving
headroom for the rest of the argv vector.

**D3 — Requirement 4 descoped**, per Non-Goals above.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Filter-prefix injection (`($__spill_X[0]) as $X \| <orig>`) changes semantics of some caller's filter | H | L | Phase 2 tests a spilled value used as a scalar binding, inside `select()`, and inside array construction; `.` semantics are unchanged by an `as` binding, but this is tested, not assumed |
| A new `trap` in either script silently clobbers the existing EXIT trap | H | M | Both scripts already install EXIT traps (`roadmap-integration.sh:369`, `state-write.sh:328` via `cleanup`). Phases 1 and 3 extend the existing trap/cleanup function; installing a second bare `trap ... EXIT` is explicitly forbidden |
| `state-write.sh` dry-run path exits before its `cleanup` trap is installed, leaking spill temp files | M | H | Phase 1 must move trap installation before the dry-run branch (or register spill files in a list cleaned by an earlier trap), with `cleanup` made safe when `STAGE_FILE`/mutex are unset |
| Only fixing the argv crash leaves the half-annotated-ROADMAP failure mode intact for any other mid-loop failure | H | M | Phase 4 is a required phase, not optional; its verification is the forced-mid-run-failure byte-identity test |
| Three changes stacked on the same script section obscure each other in review | M | M | Sequenced as separate phases in the order argv-fix -> atomicity -> heuristic, each committed independently |
| `--slurpfile` binds an array, so `$name` must become `$name[0]` in the final `jq -n` filter | M | H | Phase 3 verification diffs the emitted JSON against a pre-change capture on a small fixture to prove shape identity |
| Redeploy overwrites the fix, or `.syncprotect` skips it | H | L | `.syncprotect` was checked at plan time and lists only `context/repo/project-overview.md`; neither script is protected. Phase 7 verifies with `diff -q` after redeploy |
| Live `--annotate` verification mutates the real `specs/ROADMAP.md` | H | M | Phase 7 runs `--annotate` against a *copy* of the live ROADMAP.md first; the real-file run happens only after the copy run is green, and is preceded by a git snapshot |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 3 | -- |
| 2 | 2, 4 | 1, 3 |
| 3 | 5 | 4 |
| 4 | 6 | 5 |
| 5 | 7 | 2, 6 |

Phases within the same wave can execute in parallel.

---

### Phase 1: state-write.sh transparent oversized-payload spill [NOT STARTED]

**Goal**: `state-write.sh` accepts an arbitrarily large `--argjson NAME VALUE` in a single call by
transparently spilling oversized values to a temp file and binding them via `jq --slurpfile`, with
no change required at any existing call site and no change to any documented semantics.

**Tasks**:
- [ ] Read `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/state-write.sh` in
      full before editing; confirm the four `jq` invocation sites (init/non-init x dry-run/real)
      and the existing `cleanup`/`trap cleanup EXIT` placement
- [ ] In the `--argjson` arm of arg parsing, measure `${#3}`; when it exceeds 100000 bytes, write
      the value to a private `mktemp` file, append `--slurpfile "$private_name" "$spill_file"` to
      `JQ_ARGS` instead of `--argjson`, and record the pair `(private_name, NAME)` for filter
      prefixing. Under the threshold, behavior is byte-for-byte unchanged
- [ ] Add an additive `--argjson-file NAME PATH` flag mapping to the same `--slurpfile` +
      filter-prefix mechanism (validate PATH exists and is readable; error exit 1 otherwise)
- [ ] Build an `EFFECTIVE_FILTER` by prefixing `($<private>[0]) as $<NAME> | ` for each spilled
      binding onto `$JQ_FILTER`, so callers' `$NAME` references resolve exactly as before
- [ ] Substitute `EFFECTIVE_FILTER` for `$JQ_FILTER` at **all four** jq call sites (the two in the
      dry-run branch, the two in the real-transform branch), so `--dry-run` no longer crashes on an
      oversized payload either
- [ ] Extend the existing `cleanup` function to remove spill files, and move `trap cleanup EXIT`
      to before the dry-run branch so dry-run exits do not leak temp files; confirm `cleanup`
      is a no-op when `STAGE_FILE` is empty and no mutex is held
- [ ] Do NOT add a second `trap ... EXIT`; extend the existing one
- [ ] Verify by inspection that mutex acquisition, staging, `--init`/`--state-file`/`--regen-todo`
      refusal logic (D3/D4 checks), and the 0/1/2/3/4 exit-code contract are untouched

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts exactly four `jq` invocation sites requiring the
`EFFECTIVE_FILTER` substitution (init and non-init variants inside each of the dry-run and
real-transform branches). Confirm at implementation time with
`grep -n 'jq -n \?"\${JQ_ARGS\|jq "\${JQ_ARGS' state-write.sh` and fix every hit found, not just
four; report the actual count in the phase commit.

**Files to modify**:
- `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/state-write.sh` - argjson
  spill logic, `--argjson-file` flag, `EFFECTIVE_FILTER` assembly, cleanup/trap extension

**Verification**:
- Small-payload regression: an existing small `--argjson` call still applies identically
  (`--dry-run` exits 0, real write produces expected state)
- Oversized payload (>131,072 bytes) via `--argjson` with `--dry-run` exits 0 instead of 126
- `--argjson-file` with a >128KB file exits 0 under `--dry-run`
- `bash -n state-write.sh` clean; no leftover files in `specs/tmp/` after a dry-run

---

### Phase 2: state-write.sh regression test above the 128KB ceiling [NOT STARTED]

**Goal**: A self-contained test suite proves the >128KB single-call path works and produces output
byte-identical to the batched workaround.

**Tasks**:
- [ ] Read `test-state-write-concurrency.sh` first and follow its conventions exactly: copy the
      script under test byte-for-byte into a throwaway `$TMPROOT`, never touch the real `specs/`
      tree, `pass()`/`fail()` counters, exit 0/1 on suite result
- [ ] Create `test-state-write-large-payload.sh` in the source store `scripts/` directory
- [ ] Case A: `--argjson` with a >131,072-byte JSON array in one call exits 0 and writes correct
      state (this is the exact shape that fails today with exit 126)
- [ ] Case B: byte-identity — the same total payload applied in one oversized call vs. split into
      4 smaller calls produces `diff`-identical state.json
- [ ] Case C: filter-semantics — a spilled binding used (i) as a plain scalar/array binding,
      (ii) inside a `select()` predicate, and (iii) inside array construction, each producing the
      expected result (covers the filter-prefix risk)
- [ ] Case D: `--argjson-file NAME PATH` with a >128KB file produces the same result as Case A
- [ ] Case E: under-threshold `--argjson` still takes the plain argv path (assert unchanged
      behavior, not just success)
- [ ] Case F: `--dry-run` with an oversized payload exits 0 and leaves no temp files behind
- [ ] Register the new test in `scripts/tests/run-all.sh` if that runner enumerates top-level
      `test-state-write-*.sh` files; otherwise leave it standalone and note why

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase assumes `scripts/tests/run-all.sh` is the aggregating runner and
that top-level `test-state-write-*.sh` files are (or should be) reachable from it. Confirm by
reading `run-all.sh`'s discovery logic before adding a registration line; if it deliberately does
not collect top-level tests, skip registration and record that in the commit message.

**Files to modify**:
- `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/test-state-write-large-payload.sh` - new
- `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/tests/run-all.sh` - conditional registration

**Verification**:
- `bash test-state-write-large-payload.sh` exits 0 with all cases passing
- Re-running the suite against the *pre-fix* script (temporarily, via `git stash` or a saved copy)
  fails Case A with exit 126 — proving the test actually detects the defect

---

### Phase 3: roadmap-integration.sh final `jq -n` argv fix [NOT STARTED]

**Goal**: The report-building `jq -n` at the end of `roadmap-integration.sh` no longer passes
`ROADMAP_STATE` / `ROADMAP_MATCHES` through argv; the script completes parse-only mode with exit 0
against the live repo, emitting a byte-identical JSON report shape.

**Tasks**:
- [ ] Capture a baseline: run the current script against a *small* fixture roadmap (small enough
      that it does not crash today) and save the emitted JSON for later shape comparison
- [ ] Write `$ROADMAP_STATE` and `$ROADMAP_MATCHES` to `mktemp` files and bind them with
      `jq --slurpfile roadmap_state_arr FILE --slurpfile roadmap_matches_arr FILE`
- [ ] Update the filter body to dereference `$roadmap_state_arr[0]` / `$roadmap_matches_arr[0]`
      (`--slurpfile` always binds an array of the file's JSON values)
- [ ] Leave the small scalar/array payloads (`annotations_made`, `items_skipped`,
      `skipped_reasons`, `high_confidence_matches`, `silent_noop`, counts, `parseable`,
      `warnings`) on `--argjson` — they are bounded and unaffected
- [ ] **Extend** the existing `trap 'rm -f "$TMP_ROADMAP_STATE" "$TMP_ALL_COMPLETED"' EXIT` at
      line ~369 to also remove the two new temp files. Do NOT install a second EXIT trap — it
      would silently replace the first and leak the original two files
- [ ] Update the stale forward-referencing comment near line 172 that promised "the analogous fix"
      so it now points at the fix that actually exists

**Timing**: 45 minutes

**Depends on**: none

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts the final `jq -n` is the *only* remaining argv-based
oversized-payload passthrough in the script. Confirm at implementation time by grepping every
`--argjson` in the file and checking each bound variable's provenance for unbounded growth; if a
second unbounded site is found, fix it in this phase and record the correction.

**Files to modify**:
- `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/roadmap-integration.sh` -
  final `jq -n` block, EXIT trap extension, stale comment

**Verification**:
- `bash <source-store>/roadmap-integration.sh --roadmap specs/ROADMAP.md --state specs/state.json`
  (parse-only, non-destructive) exits **0** — this is the exact invocation that exits 126 today
- Emitted JSON validates: `... | jq empty` succeeds, and top-level keys are exactly
  `roadmap_state`, `roadmap_matches`, `annotation_summary`, `roadmap_structure`, `warnings`
- Small-fixture output is `diff`-identical to the Phase 3 baseline capture
- No temp files left behind after the run

---

### Phase 4: roadmap-integration.sh --annotate atomicity via staging copy [NOT STARTED]

**Goal**: In `--annotate` mode, every annotation is applied to a private staging copy; the real
`ROADMAP.md` is replaced exactly once, only after the JSON report has been fully constructed. Any
mid-run failure leaves `ROADMAP.md` byte-identical.

**Tasks**:
- [ ] Introduce an `ANNOTATE_TARGET` variable: in `--annotate` mode, a `mktemp` file seeded with
      `cp "$ROADMAP_PATH" "$ANNOTATE_TARGET"`; in parse-only mode it is simply `$ROADMAP_PATH`
      (read-only there, so no copy needed)
- [ ] Retarget **every** read and write inside the annotate loop from `$ROADMAP_PATH` to
      `$ANNOTATE_TARGET` — including the `grep -q`/`grep -F`/`grep -qxF` guard reads and the
      `sed -n` on-disk line read, not only the `awk`/`mv` writes. A guard that still reads the
      original file while writes go to the staging copy will make the second annotation in a run
      compare against stale content
- [ ] Restructure the end of the script: build the JSON report into a temp file first; only on
      success `mv "$ANNOTATE_TARGET" "$ROADMAP_PATH"`; then emit the report to stdout. Order is
      load-bearing — report first, then commit the file, then print
- [ ] Add `$ANNOTATE_TARGET` to the existing EXIT trap so a failed run removes the staging copy
      and never touches `$ROADMAP_PATH`
- [ ] Preserve the existing per-iteration `TMPFILE` mktemp/diff/mv mechanics within the loop; they
      now operate against `$ANNOTATE_TARGET` rather than the real file
- [ ] Preserve the `diff -q` no-op detection that currently suppresses counting an unchanged write
      as an annotation

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts the annotate loop touches `$ROADMAP_PATH` at roughly
eight sites (guard greps, the on-disk `sed -n` line read, and the checkbox and table-row
`awk`/`diff`/`mv` blocks). Confirm at implementation time with
`grep -n 'ROADMAP_PATH' roadmap-integration.sh` and retarget every occurrence inside the annotate
loop's line range; a missed guard read is silent, so the count must be confirmed by grep rather
than assumed from this plan.

**Files to modify**:
- `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/roadmap-integration.sh` -
  `ANNOTATE_TARGET` introduction, annotate-loop retargeting, end-of-script commit ordering, trap

**Verification**:
- Against a fixture repo: `--annotate` run completes, exits 0, and the fixture ROADMAP.md carries
  the expected annotations
- Forced mid-run failure (inject a failure after at least one annotation has been applied, e.g. by
  temporarily making the report step fail): the fixture ROADMAP.md is `diff`-identical to a
  pre-run copy, and no staging temp file remains
- Parse-only mode still never writes: `stat`-compare mtime and content of the fixture ROADMAP.md
  before and after a parse-only run

---

### Phase 5: Tighten the explicit_task_ref heuristic [NOT STARTED]

**Goal**: An item is no longer auto-completed on an explicit task reference when the item's own
text also references a task that is still non-terminal, and all task references in the item are
inspected rather than only the first.

**Tasks**:
- [ ] Extend the data flow into the Python matching step: build an `ACTIVE_TASKS` payload from
      `$STATE_PATH` containing every `active_projects[]` entry's `project_number` plus `status`
      (numbers and statuses only — not full records), including non-terminal statuses
      (`not_started`, `researching`, `researched`, `planning`, `planned`, `implementing`,
      `partial`, `blocked`, `pr_ready`)
- [ ] Pass it via a **third temp file** argument to the existing `python3 - "$TMP_ROADMAP_STATE"
      "$TMP_ALL_COMPLETED"` heredoc call (matching the established temp-file convention there,
      not argv), and extend the existing EXIT trap to clean it up
- [ ] In `find_match()` Check 1, replace `re.search(r'\(task (\d+)', ...)` with `re.finditer` so
      **every** `(task N` reference in the item text is collected
- [ ] Reject the high-confidence `explicit_task_ref` verdict when any collected reference resolves
      to a task whose status is non-terminal; fall through to the remaining checks instead of
      returning a match
- [ ] When at least one reference is completed and none is non-terminal, return the completed task
      as today (preserve the existing behavior for the clean case)
- [ ] Treat an unresolvable task number (present in neither the completed set nor the active set —
      e.g. abandoned or renumbered) as non-blocking for the reject rule, but do not let it alone
      produce a high-confidence match
- [ ] Add an inline comment recording the concrete failure this guards against: an item whose text
      says "tasks 314-318 in flight/not-started" was wrongly checked off on a `(task 313)` context
      reference

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts that the Python matching step currently receives only
`ROADMAP_STATE` and `ALL_COMPLETED`, and that `task_by_number` is built exclusively from the
completed/archived set. Confirm by reading the heredoc's `sys.argv` usage and `task_by_number`
construction before adding the third input; if any active-task data already reaches the step by
another route, use it rather than adding a redundant payload.

**Files to modify**:
- `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/roadmap-integration.sh` -
  `ACTIVE_TASKS` construction, third temp-file argument, `find_match()` Check 1

**Verification**:
- Fixture case A: item text references only completed tasks -> still matched `high` /
  `explicit_task_ref` (no regression)
- Fixture case B: item text references one completed and one in-flight task -> NOT matched by
  `explicit_task_ref` (falls through), and in `--annotate` mode the item is not checked off
- Fixture case C: item text references several tasks with only a later one non-terminal -> still
  rejected, proving `finditer` (not `search`) is in effect
- Against the live repo in parse-only mode: the previously mis-matched item no longer appears as a
  high-confidence `explicit_task_ref` match

---

### Phase 6: roadmap-integration.sh regression tests [NOT STARTED]

**Goal**: A test suite covering all three roadmap-integration fixes: the >128KB payload, the
forced-mid-run-failure byte-identity guarantee, and the tightened heuristic.

**Tasks**:
- [ ] Read `scripts/tests/test-roadmap-items-producer.sh` first and follow its fixture-repo
      conventions (build a fixture repo, drive the real matching/annotation chain)
- [ ] Create `scripts/tests/test-roadmap-argv-ceiling.sh`
- [ ] Case A: generate a fixture `ROADMAP.md` with enough phases/checkboxes/table rows to push
      `ROADMAP_MATCHES` past 131,072 bytes, and assert parse-only mode exits 0 with valid JSON
      (the live repo reached ~497KB with 24 matches, ~20KB each, so a fixture needs roughly
      10-30 matching rows carrying long `raw_line` text — size the fixture by measuring, not by
      guessing)
- [ ] Case B: atomicity — run `--annotate` against the oversized fixture with an injected mid-run
      failure and assert the fixture ROADMAP.md is `diff`-identical to a pre-run copy
- [ ] Case C: atomicity, success path — a clean `--annotate` run applies all expected annotations
      in one final move
- [ ] Case D: heuristic — the Phase 5 fixture cases A/B/C as assertions in this suite
- [ ] Case E: no temp-file leakage after each of the above
- [ ] Register in `scripts/tests/run-all.sh`

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts a fixture can be generated large enough to cross the
131,072-byte `ROADMAP_MATCHES` threshold. Confirm by instrumenting the fixture build to print
`${#ROADMAP_MATCHES}` (or measuring the payload directly) and asserting it exceeds the ceiling
before asserting the exit code — a test that silently stays under the ceiling proves nothing.

**Files to modify**:
- `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/tests/test-roadmap-argv-ceiling.sh` - new
- `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/tests/run-all.sh` - registration

**Verification**:
- `bash tests/test-roadmap-argv-ceiling.sh` exits 0 with all cases passing
- Case A fails with exit 126 when run against a pre-fix copy of the script, proving the test
  detects the original defect
- `bash tests/run-all.sh` still exits 0 overall

---

### Phase 7: Redeploy, parity verification, and live acceptance [NOT STARTED]

**Goal**: The source-store fixes are deployed into this repo's `.claude/` tree, the copies are
confirmed identical, and every acceptance criterion in the task description is demonstrated
against the live repo.

**Tasks**:
- [ ] Take a git snapshot before any live-file operation:
      `bash .claude/scripts/git-snapshot.sh 487`
- [ ] Commit the source-store changes in the source-store repository
      (`/home/benjamin/.config/nvim/`) — it is a separate git-tracked location shared across
      projects; do not push
- [ ] Redeploy:
      `bash /home/benjamin/.config/nvim/.claude/scripts/deploy-headless.sh /home/benjamin/Projects/BimodalLogic`
- [ ] Confirm parity: `diff -q <source-store>/roadmap-integration.sh .claude/scripts/roadmap-integration.sh`
      and the same for `state-write.sh`, plus the two new test files
- [ ] Acceptance 1: `bash .claude/scripts/roadmap-integration.sh --roadmap specs/ROADMAP.md
      --state specs/state.json` exits 0 (parse-only, the invocation that fails today)
- [ ] Acceptance 2: copy `specs/ROADMAP.md` to a scratch path, run `--annotate` against the
      **copy** with the full live `specs/state.json`, confirm exit 0 and inspect the diff. Only
      after that is green, run `--annotate` against the real `specs/ROADMAP.md` and review the
      resulting diff before committing anything
- [ ] Acceptance 3: forced mid-run failure against a scratch copy leaves it byte-identical
- [ ] Acceptance 4: run both new test suites from the deployed `.claude/scripts/` copies
- [ ] Record in the implementation summary: the confirmed Scope Hypothesis counts from Phases 1,
      3, 4, 5, and 6, and the descoping of requirement 4

**Timing**: 45 minutes

**Depends on**: 2, 6

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase assumes `.syncprotect` does not protect either script (checked at
plan time: it lists only `context/repo/project-overview.md`) and that `deploy-headless.sh`'s
default non-destructive resync mode suffices. Re-read `.syncprotect` immediately before redeploy
and confirm; if either script has since been added, the redeploy will silently skip it and the
`diff -q` parity check is the detector.

**Files to modify**:
- No source files; this phase deploys and verifies. `.claude/scripts/*` changes are produced by
  the deploy engine, never hand-authored

**Verification**:
- `diff -q` clean for both scripts and both test files between source store and `.claude/scripts/`
- All four acceptance criteria from the task description demonstrated with captured command output
- `git status` shows no unintended working-tree changes in this repo beyond `specs/` artifacts and
  any reviewed `specs/ROADMAP.md` annotation

---

## Testing & Validation

- [ ] `bash -n` clean on both modified scripts
- [ ] `test-state-write-large-payload.sh` exits 0 (all six cases)
- [ ] `test-roadmap-argv-ceiling.sh` exits 0 (all five cases)
- [ ] `tests/run-all.sh` exits 0 overall (no regression in the existing suite)
- [ ] `test-state-write-concurrency.sh` and `test-state-write-regen-timing.sh` still pass —
      mutex/staging/timing semantics unchanged
- [ ] Both new suites demonstrably fail against pre-fix copies of the scripts
- [ ] `roadmap-integration.sh` exits 0 in parse-only AND `--annotate` mode against the live
      `specs/ROADMAP.md` + full `specs/state.json`
- [ ] Forced mid-run failure leaves ROADMAP.md byte-identical
- [ ] `state-write.sh` single >128KB call produces state.json byte-identical to the 4-batch split
- [ ] Deployed `.claude/scripts/` copies `diff -q`-identical to the source store

## Artifacts & Outputs

- `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/state-write.sh` (modified)
- `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/roadmap-integration.sh` (modified)
- `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/test-state-write-large-payload.sh` (new)
- `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/tests/test-roadmap-argv-ceiling.sh` (new)
- `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/tests/run-all.sh` (registration)
- Redeployed `.claude/scripts/` copies of all of the above (produced by the deploy engine)
- `specs/487_fix_argv_ceiling_in_roadmap_integration_and_state_write/summaries/01_*-summary.md`

## Rollback/Contingency

- Source-store changes are committed per-phase in `/home/benjamin/.config/nvim/`; revert the
  offending commit there and re-run `deploy-headless.sh` to restore this repo's `.claude/` tree.
- The pre-work `git-snapshot.sh 487` in this repo covers any accidental `specs/ROADMAP.md`
  mutation during Phase 7 live verification.
- Phases 1 and 3 are independent and independently revertible: `state-write.sh` can ship without
  the roadmap fixes and vice versa.
- If Phase 4's staging redesign proves unstable, Phases 1-3 alone still remove both crash sites
  (satisfying acceptance criteria 1, 3, and part of 4) — but the task would then be `[PARTIAL]`,
  not complete, since criterion 2 (byte-identity on failure) would be unmet. Do not report
  completion in that case.
