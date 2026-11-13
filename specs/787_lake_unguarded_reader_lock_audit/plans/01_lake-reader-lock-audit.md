# Implementation Plan: Task #787

- **Task**: 787 - Audit the remaining lake-invoking scripts for the unguarded .lake read hazard
- **Status**: [IMPLEMENTING]
- **Effort**: 3.25 hours
- **Dependencies**: 743 (declared, completed); none technical
- **Research Inputs**: specs/787_lake_unguarded_reader_lock_audit/reports/01_lake-reader-lock-audit.md
- **Artifacts**: plans/01_lake-reader-lock-audit.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Two repository scripts carry the unguarded `.lake` read hazard and gain the shared
`$REPO_ROOT/.lake/build-guard.lock` in the precedent shape: `scripts/typst-status-counts.sh`
(write path) and `scripts/typst-machine-appendix.sh` (default mode). The two dataset runners get
a different shape, a subshell-scoped locked prebuild, because they run for hours and must not
hold the lock to process exit. Every other surveyed script is ruled out, with the reason recorded
in its own header (where editable from this repository) and in one new section of
`scripts/README.md`. Done means: every surveyed script has a recorded determination, each locked
script keeps its exit-status contract and its build-free modes stay lock-free, and the full gate
is green. No probe file, manifest array, Lean source, or `.claude/**` path is touched.

### Research Integration

Integrated from `reports/01_lake-reader-lock-audit.md`:

- The per-script determination table (adopted as the plan's work list).
- The leaf-only rule: a child that re-opens the lock file blocks against its lock-holding parent,
  so the lock is taken at exactly one level of any call chain, and strictly after every
  build-free early exit (`--json`, `--render-only`).
- The hours-long-runner constraint on the dataset scripts.
- The siting finding: deployed (`.claude/scripts/`) candidates resolve to a source store in a
  separate repository (`~/.config/nvim`), so the one deployed script that warrants a change
  (`lean-challenge-snapshot.sh`) is a follow-up for that repository, not an edit made here.

### Premise Re-Validation

Checked at plan authoring against live files (not carried on trust):

| Claim | Source | Result |
|---|---|---|
| `typst-module-map.sh` invokes bare `lake env lean` | task description | FALSE. Only lake mention is the header comment at line 7 stating it needs no built library. Confirms the report. |
| `export-training-data.sh` runs `lake build dataset_generator proof_extractor` | task description | FALSE. Line 88 is an echoed hint inside `check_prereqs`; runtime calls are `lake exe` at 188, 201, 246. Confirms the report. |
| Only three files reference `build-guard.lock` | task description | Holds for non-test scripts under `scripts/`; under `.claude/scripts/` `dispatch-worktree.sh` and two test files also match. Does not change any determination. |
| `typst-status-counts.sh`: `--json` exits (line 264) before the single `lake env lean` (line 301) | report | CONFIRMED. |
| `typst-machine-appendix.sh`: `--render-only` (154-160) and `--json` (163-176) exit before `lake build` (192) and `lake env lean --run` (196) | report | CONFIRMED. |
| `typst-sync-check.sh` has no direct lake call; `--fix` calls `typst-status-counts.sh` write path (line 528) | report | CONFIRMED. |
| `run_dataset_generation.sh` has 9 `lake exe dataset_generator` calls and a `check_prereqs` at 626-627 | report | CONFIRMED (`grep -c` = 9). |
| `scripts/README.md` has no `build-guard`/`flock` mention | report | CONFIRMED (zero hits). |
| The missing-olean race itself | description, precedent header | CARRIED-UNVERIFIED: source is `scripts/check-evidence-probes.sh`'s in-file account; re-measuring needs a deliberately raced build, which would collide with task 803's live builds. No phase depends on re-measuring it. |
| `.lake/build/bin/dataset_generator` and `proof_extractor` exist | plan-time `ls` | CONFIRMED present (Phase 3's verification relies on this; see its Scope Hypothesis). |

### Decisions

- **Dataset runners get the subshell-scoped locked prebuild, not a ruling-out.** The description
  names a scoped build as a plausible cause of the fault; `lake exe` rebuilds implicitly and
  unlocked whenever sources are stale. A prebuild inside a subshell serialises exactly that
  rebuild, and the lock dies with the subshell, so the hours-long run holds nothing. It is placed
  after `check_prereqs`, so the missing-binary contract (exit 1 with the hint) is unchanged.
  Rejected: hold-to-exit lock (starves every guarded build for hours); `flock -u` (the
  precedents deliberately never unlock).
- **`run_dataset_generation.sh` is added to scope.** It has the same shape as
  `export-training-data.sh` and the same single insertion point; leaving it out would leave an
  identical hazard with only a note.
- **`scripts/README.md` is added to scope** as the durable home for the rulings-out, including
  the deployed scripts whose headers cannot be edited from this repository.
- **No shared helper library.** Both precedents inline the block; four more inline copies follow
  them. A sourced helper would be a new coupling the precedents' notes did not adopt.
- **No `.claude/**` or source-store edit.** Settled by the Task Siting rule in
  `.claude/rules/source-store-deploy-boundary.md`; follow-ups are listed, not performed.
- **Verification uses a stub `lake` on `PATH`, never a real build.** Task 803 is running guarded
  builds and owns `typst/generated/status.typ` this cycle. A stub exercises the lock and the
  post-acquisition control flow without writing any generated file or touching `.lake`.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap path was provided in the dispatch; not consulted.

## Goals & Non-Goals

**Goals**:
- Lock `typst-status-counts.sh` (write path) and `typst-machine-appendix.sh` (default mode) in
  the precedent shape, leaf-only, after every build-free early exit.
- Give both dataset runners a subshell-scoped locked prebuild.
- Record a per-script determination for every surveyed script where a future reader finds it.
- Name an environment-class failure as such next to each new lock.

**Non-Goals**:
- Editing any `.claude/**` path or any source-store path.
- Touching probe files, manifest arrays, Lean sources, or any `typst/generated/` file.
- Locking `warning-budget.py`, or closing the C1 lock-timeout residual in
  `check-module-invariants.sh` (follow-ups).
- Claiming the lock closes the hazard: it is advisory and bare `lake build`, `lake serve`, and
  the `lean_build` MCP tool bypass it.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A future nested caller self-deadlocks for the full timeout | H | L | Leaf-only rule stated in each new block's comment and in `scripts/README.md`; Phase 5 proves `typst-sync-check.sh` completes while the lock is held elsewhere |
| A lock lands before a build-free early exit and breaks CI / pre-commit | H | L | Insertion points fixed by this plan; each phase runs the build-free mode under a held lock |
| Verification mutates task 803's `typst/generated/status.typ` or races its builds | M | M | Stub `lake` only; no real generator run; test lock holds bounded to 30 s or less; explicit-file staging |
| `set -euo pipefail` aborts on a failed `flock` | M | M | Write acquisition as `if ! flock ...` as both precedents do |
| Prebuild changes a dataset runner's contract | M | L | Placed after `check_prereqs`, skipped under `--dry-run`; dry-run output diffed before/after |
| Full gate fails for reasons unrelated to this task (deployed tree is stale for `core` and `lean`) | M | M | Classify each failure against this task's file list; report unrelated ones, do not redeploy and do not hand-patch `.claude/**` |
| `check-module-invariants.sh --no-build` reports a spurious C28 during a sibling build | L | M | Known and documented in `warning-budget.py`'s header; re-run once the build is quiet before attributing |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3, 4 | -- |
| 2 | 5 | 1, 2, 3, 4 |

Phases within the same wave can execute in parallel.

**Shared verification harness (used by Phases 1-3 and 5)**. Create in the session scratchpad, not
in the repository: a directory holding an executable named `lake` that appends its arguments to a
log file and exits with the status given by an environment variable (optionally printing a
supplied line to stderr first). Prepend that directory to `PATH` for a single command only. Hold
the lock from a second shell with `flock "$REPO_ROOT/.lake/build-guard.lock" sleep 30 &` (never
longer: a held lock blocks task 803's guarded builds). If the lock is already held by a real
build, use that contention instead of adding a holder.

**The precedent block (Phases 1-3 copy this shape)**: `scripts/check-evidence-probes.sh`'s
`SHARED .lake LOCK` block: `mkdir -p "$REPO_ROOT/.lake"`; if `flock` is on `PATH`,
`exec {FD}<>"$LOCK_FILE"`, then `if ! flock -n`, announce on stderr with the path and bound, then
`if ! flock -w "$WAIT"`; no `flock -u`; an audible stderr notice and unserialized continuation
when `flock` is absent. Each block's comment cross-references the rejected alternatives at
`check-module-invariants.sh`'s `C1: build` block rather than restating them, and states the
leaf-only rule. Comments state the current design only: no task numbers, no draft history.

### Phase 1: Lock the status-counts write path [COMPLETED]

**Goal**: `scripts/typst-status-counts.sh` reads `.lake` only under the shared lock, and names a
raced read as an environment failure.

**Tasks**:
- [x] Re-read the file immediately before editing (shared tree). *(completed)*
- [x] Insert the precedent block immediately before `AX_SRC=$(mktemp --suffix=.lean)`, i.e.
      after the `--json` early exit. Lock path `${REPO_ROOT}/.lake/build-guard.lock` (the script
      has `cd`'d elsewhere; do not use `pwd`). Wait bound from
      `STATUS_COUNTS_LOCK_WAIT_S`, default 600, documented as a test affordance. *(completed)*
- [x] On lock timeout: stderr message in the environment class (no file was read, re-run when the
      concurrent build finishes), exit 1. Nothing is written. *(completed)*
- [x] Split the existing `lake env lean` failure message: capture the raw output; when it matches
      the missing-object-file predicate used by `check-evidence-probes.sh` (locate it there and
      reuse its pattern text), report an environment failure and advise a re-run; otherwise keep
      the existing "Run 'lake build' first" text. Exit status stays 1 in both cases. *(completed)*
- [x] Update the header usage comment to state that the write path takes the shared lock and
      `--json` does not. *(completed)*

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: `suite_selection_select scripts/typst-status-counts.sh` returns `__FULL_SWEEP__` (no suite covers it), so the covering check is `bash -n scripts/typst-status-counts.sh` plus `bash .claude/scripts/verify-deploy.sh --only-gate 4`.

**Scope Hypothesis**: The stub-`lake` runs below never reach the code that writes
`typst/generated/status.typ`, because every stubbed failure exits at the `if ! AX_OUT=...` block.
Confirm by checking `git status --short typst/generated/` is unchanged by this phase's commands
before and after each run; if a run would write the file, stop and do not run it.

**Files to modify**:
- `scripts/typst-status-counts.sh` - lock block before the axiom-report step; failure-message split; header note

**Verification**:
- `bash -n scripts/typst-status-counts.sh` exits 0.
- `bash scripts/typst-status-counts.sh --json` output is byte-identical before and after the
  edit, and completes without waiting while the lock is held from another shell.
- Lock held elsewhere, `STATUS_COUNTS_LOCK_WAIT_S=2`, stub `lake` on `PATH`: the waiting
  announcement appears on stderr, the script exits 1 with the environment-class message, and the
  stub's log is empty (lake never invoked).
- Lock free, stub `lake` exiting 1 with a missing-object-file line: exit 1 with the
  environment-class message. Stub exiting 1 with unrelated text: exit 1 with the original
  "Run 'lake build' first" message.
- `bash scripts/typst-sync-check.sh --counts-only` exit status is unchanged from its pre-edit
  value (record both).
- `bash .claude/scripts/verify-deploy.sh --only-gate 4` exit status checked and recorded.

---

### Phase 2: Lock the machine-appendix default mode [COMPLETED]

**Goal**: `scripts/typst-machine-appendix.sh` runs its scoped build and its interpreter read
under one hold of the shared lock.

**Tasks**:
- [x] Re-read the file immediately before editing. *(completed)*
- [x] Insert the precedent block in the "Default mode" section, after both early-exit modes and
      before `lake build BimodalTools.MachineAppendixMain`, so one hold covers both lake calls.
      Wait bound from `MACHINE_APPENDIX_LOCK_WAIT_S`, default 600. *(completed)*
- [x] On lock timeout: environment-class stderr message, exit 1, before any lake call. *(completed)*
- [x] Update the header mode descriptions: default mode takes the shared lock; `--json` and
      `--render-only` do not and must stay that way (they are called by `typst-sync-check.sh`). *(completed)*

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: `suite_selection_select scripts/typst-machine-appendix.sh` returns `__FULL_SWEEP__` (no suite covers it), so the covering check is `bash -n scripts/typst-machine-appendix.sh` plus `bash .claude/scripts/verify-deploy.sh --only-gate 4`.

**Scope Hypothesis**: With a stub `lake` that exits non-zero, default mode stops at the
`lake build` line under `set -e` and writes nothing under `typst/generated/`. Confirm with
`git status --short typst/generated/` before and after.

**Files to modify**:
- `scripts/typst-machine-appendix.sh` - lock block at the head of default mode; header note

**Verification**:
- `bash -n scripts/typst-machine-appendix.sh` exits 0.
- `--json` and `--render-only typst/generated/machine-appendix.jsonl` (use the script's own
  `JSONL` path) produce byte-identical output before and after the edit, and complete without
  waiting while the lock is held elsewhere.
- Lock held elsewhere, `MACHINE_APPENDIX_LOCK_WAIT_S=2`, stub `lake`: waiting announcement, exit
  1, environment-class message, empty stub log.
- Lock free, stub `lake` exiting 1: stub log shows exactly one call,
  `build BimodalTools.MachineAppendixMain`; script exits non-zero; no generated file changed.
- `bash .claude/scripts/verify-deploy.sh --only-gate 4` exit status checked and recorded.

---

### Phase 3: Scoped locked prebuild in the dataset runners [COMPLETED]

**Goal**: The implicit rebuild behind `lake exe` in both dataset runners happens under the shared
lock, without the runner holding the lock for the generation run.

**Tasks**:
- [x] Re-read both files immediately before editing. *(completed)*
- [x] In `scripts/export-training-data.sh`, directly after the `check_prereqs` call in the
      non-dry-run branch, add a subshell `( <precedent block>; lake build <targets> )` where
      `<targets>` is `dataset_generator` unless `--skip-dataset`, and `proof_extractor` unless
      `--skip-proofs`; skip the subshell entirely when both are skipped. Wait bound from
      `DATASET_LOCK_WAIT_S`, default 600. The lock fd is opened inside the subshell so it closes
      when the subshell exits. *(completed)*
- [x] In `scripts/run_dataset_generation.sh`, the same subshell after its `check_prereqs` call,
      with target `dataset_generator`, same variable name. *(deviation: altered — prebuild gated to generation commands; help/unknown do not build)*
- [x] In both: lock timeout or prebuild failure makes the subshell exit non-zero and the script
      exit 1 with a message naming which of the two happened (timeout is environment-class).
      Under `--dry-run`, print one `[dry-run]` line describing the prebuild instead of running it. *(completed)*
- [x] In both headers: state the shape and why it is not hold-to-exit (the run lasts hours; a
      held lock would starve every guarded build), and that the `lake exe` calls are deliberately
      left outside the lock. *(completed)*

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for both `scripts/export-training-data.sh` and `scripts/run_dataset_generation.sh` (no suite covers either), so the covering check is `bash -n` on each plus `bash .claude/scripts/verify-deploy.sh --only-gate 4`.

**Scope Hypothesis**: (a) Both built binaries exist under `.lake/build/bin/` (true at plan
authoring), so `check_prereqs` passes and the new code is reachable; re-check with `ls` and, if
either is missing, verify only the paths that remain reachable and record the gap. (b) With a
stub `lake` that exits 1 on every call, each script exits at the prebuild, before any `lake exe`
and before writing under `data/`; confirm from the stub log (no `exe` line) and
`git status --short` before and after. Do not run either script with a real `lake`.

**Files to modify**:
- `scripts/export-training-data.sh` - subshell-scoped locked prebuild after `check_prereqs`; header note
- `scripts/run_dataset_generation.sh` - subshell-scoped locked prebuild after `check_prereqs`; header note

**Verification**:
- `bash -n` exits 0 for both files.
- `--dry-run c5` output of each script differs from its pre-edit output by exactly the one added
  `[dry-run]` prebuild line; exit status unchanged.
- Lock held elsewhere, `DATASET_LOCK_WAIT_S=2`, stub `lake`, tier `c5` (and `smoke` for
  `run_dataset_generation.sh`): waiting announcement, exit 1 with the timeout message, empty stub
  log.
- Lock free, stub `lake` exiting 1: stub log shows only the expected `build ...` call with the
  expected targets (check `--skip-proofs` and `--skip-dataset` variants on
  `export-training-data.sh`), script exits 1, no `exe` call logged.
- After any run, `flock -n "$REPO_ROOT/.lake/build-guard.lock" true` succeeds immediately: the
  subshell released the lock.
- `bash .claude/scripts/verify-deploy.sh --only-gate 4` exit status checked and recorded.

---

### Phase 4: Record the rulings-out in the ruled-out scripts' headers [COMPLETED]

**Goal**: The two in-repository scripts that must not take the lock say so, and why, in their own
headers.

**Tasks**:
- [x] Re-read both files immediately before editing. *(completed)*
- [x] `scripts/typst-sync-check.sh`: header note that it takes no lock by design: it never invokes
      lake itself, `--fix` delegates to `typst-status-counts.sh`, which locks, and a lock here
      would block that child for the full timeout because a child re-opening the lock file is
      excluded by its own parent. *(completed)*
- [x] `scripts/typst-sync-check.sh`: extend the `--fix` failure hint (the message after the
      failed `typst-status-counts.sh` call) to name a concurrent build holding the shared lock as
      a second common cause alongside an unbuilt library. Message text only; no control-flow
      change. *(completed)*
- [x] `scripts/typst-module-map.sh`: header note that it takes no lock because it never reads
      `.lake` (source text only). *(completed)*

**Timing**: 0.25 hours

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: `suite_selection_select` over `scripts/typst-sync-check.sh` and `scripts/typst-module-map.sh` together returns `__FULL_SWEEP__` (no suite covers the pair), so the covering check is `bash -n` on both plus `bash .claude/scripts/verify-deploy.sh --only-gate 4`.

**Files to modify**:
- `scripts/typst-sync-check.sh` - header ruling-out note; `--fix` failure hint text
- `scripts/typst-module-map.sh` - header ruling-out note

**Verification**:
- `bash -n` exits 0 for both files.
- `git diff` for both files shows only comment lines plus the one `echo` string in
  `typst-sync-check.sh`'s `--fix` branch.
- `bash scripts/typst-sync-check.sh --counts-only` and `bash scripts/typst-module-map.sh --json`
  exit status and stdout unchanged from pre-edit.
- `bash .claude/scripts/verify-deploy.sh --only-gate 4`: exit status checked and recorded.

---

### Phase 5: Record the convention in scripts/README.md and run the full gate [NOT STARTED]

**Goal**: One durable section names the lock convention and every per-script determination, and
the whole task is verified together.

**Tasks**:
- [ ] Re-read `scripts/README.md` immediately before editing.
- [ ] Add a section (after "Typst synchronization utilities" or as the README's structure best
      admits) covering: the lock path and that `.claude/scripts/lake-build-guard.sh` publishes it;
      the shape (non-blocking try, announced bounded wait, held to process exit, audible
      degradation without `flock`); the leaf-only rule and its mechanism; the subshell-scoped
      variant for long runners; that the lock is advisory and what bypasses it.
- [ ] In that section, a determination table built from the report's per-script table as landed
      by Phases 1-4: locked (`check-module-invariants.sh`, `check-evidence-probes.sh`,
      `typst-status-counts.sh`, `typst-machine-appendix.sh`); scoped prebuild
      (`export-training-data.sh`, `run_dataset_generation.sh`); ruled out with reason
      (`typst-sync-check.sh`, `typst-module-map.sh`, `generate-decidability-inventory.sh`,
      `check-copyright-headers.sh`, `move-modules.py`, `lake_targets.py`,
      `reanchor-lean-citations.py`); deployed scripts by filename with their determination
      (`lean-sorry-census.sh` already guard-routed, `lean-comparator-run.sh` private tree,
      `lean-comparator-landrun-shim.sh`, `plan-file-scope-harvest.sh`, `claude-refresh.sh`,
      `lean-mcp-preflight-check.sh`, `lean-src-roots.sh` no runtime lake use,
      `dispatch-worktree.sh` not a verdict-producing reader).
- [ ] In that section, a short "known unguarded readers" list stating current facts:
      `lean-challenge-snapshot.sh` (bare `lake env lean`; its fix belongs in the source-store
      repository), `warning-budget.py` under `--no-build`, and the lock-timeout branch of
      `check-module-invariants.sh`'s C1.
- [ ] Wording check on every file this task changed: no task numbers, no draft-history phrasing
      ("no longer", "previously", "formerly", version labels).
- [ ] Before writing each table row, confirm it against the landed file, not against the report:
      grep each "locked" script for `build-guard.lock` and each "ruled out" in-repository script
      for its absence.
- [ ] Cross-script check and full gate per Verification below.
- [ ] In the implementation summary, list the three follow-ups (source-store task for
      `lean-challenge-snapshot.sh` and the flock re-entrancy context note; `warning-budget.py`;
      C1 timeout residual) as recommended new tasks.

**Timing**: 1 hour

**Depends on**: 1, 2, 3, 4

**Verification Tier**: full

**Scope Hypothesis**: The determination table's script list is carried from the research report's
survey. Confirm it at implementation time with a sweep that does not reuse the report's patterns:
list every file under `scripts/` (excluding `lib/__pycache__`) and `.githooks/` whose non-comment
lines contain the word `lake` or the string `.lake`, and check each appears in the table or is a
pure data file. Add any script the sweep finds that the table lacks, with its own determination.

**Files to modify**:
- `scripts/README.md` - new section: shared `.lake` build lock convention and per-script determinations

**Verification**:
- `bash .claude/scripts/verify-deploy.sh` (the complete gate set), run with a bounded wait per
  `context/patterns/external-process-wait.md`; exit status checked. Any failing gate is classified
  against this task's seven files; a failure attributable to the stale deployed tree or to a
  sibling's in-flight edit is reported with evidence, not patched under `.claude/**`.
- `bash scripts/check-module-invariants.sh --no-build` (the repository's own CI gate, which
  covers `scripts/` and its README): exit status checked; a C28 failure during a live sibling
  build is re-run once the lock is free before attribution.
- While the lock is held from another shell: `bash scripts/typst-sync-check.sh` and
  `bash scripts/typst-sync-check.sh --counts-only` both complete without waiting, with exit
  status equal to their uncontended values. This is the proof that the build-free modes stayed
  lock-free and that no delegator locks.
- `command grep -ln 'build-guard.lock' scripts/*.sh scripts/*.py` lists exactly the six scripts
  the README table marks as locked or scoped-prebuild, and `scripts/typst-sync-check.sh` /
  `scripts/typst-module-map.sh` only if the match is inside a comment.
- `bash -n` exits 0 for all six edited shell scripts.
- `git status --short` shows no change under `typst/generated/`, `.claude/`, `data/`, or any
  probe/manifest file from this task; staged set is exactly the seven declared files plus this
  task's `specs/` artifacts.

## Testing & Validation

- [ ] Each locked script: waiting announcement, timeout branch (short override), and
      post-acquisition control flow exercised with a stub `lake`; no real build started.
- [ ] Each build-free mode (`typst-status-counts.sh --json`, `typst-machine-appendix.sh --json`
      and `--render-only`, `typst-sync-check.sh` no-argument and `--counts-only`, both dataset
      runners' `--dry-run`) completes without waiting under a held lock.
- [ ] Exit-status contracts unchanged: recorded before/after for every script and mode above.
- [ ] `bash .claude/scripts/verify-deploy.sh` and
      `bash scripts/check-module-invariants.sh --no-build` exit status recorded.
- [ ] No probe file, manifest array, generated typst file, or `.claude/**` path in the diff.

## Artifacts & Outputs

- `scripts/typst-status-counts.sh`, `scripts/typst-machine-appendix.sh` - shared lock added
- `scripts/export-training-data.sh`, `scripts/run_dataset_generation.sh` - scoped locked prebuild
- `scripts/typst-sync-check.sh`, `scripts/typst-module-map.sh` - recorded rulings-out
- `scripts/README.md` - lock convention and per-script determination section
- `specs/787_lake_unguarded_reader_lock_audit/summaries/01_lake-reader-lock-audit-summary.md` -
  including the before/after exit-status table and the three recommended follow-ups

## Rollback/Contingency

Each phase is one commit touching only its declared files, so reverting a phase is a
`git revert` of that commit; phases 1-4 are independent of each other and Phase 5's README section
must then be amended to match. If a lock block proves to break a script's contract and cannot be
fixed within the phase, leave that script unlocked, record it in `scripts/README.md`'s "known
unguarded readers" list with the reason, and close the phase with a Reasoned Exclusion: an
explicit recorded ruling is a complete outcome for that script. Discarding uncommitted work, if
ever needed, follows `context/contracts/recovery.md`'s rollback rung; no reverting snapshot is
taken as a routine checkpoint.
