# Implementation Plan: Task #688

- **Task**: 688 - gate_script_concurrency_reliability
- **Status**: [IMPLEMENTING]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: specs/688_gate_script_concurrency_reliability/reports/01_gate-script-concurrency-reliability.md
- **Artifacts**: plans/01_gate-script-build-lock.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

`scripts/check-module-invariants.sh` runs `lake build` and `lake build BimodalTest` directly in
its C1 section with no serialization, so any concurrently running guarded build races it for
`.lake` artifacts — a measured defect that produced three spurious gate failures in a single
orchestration run. The fix wraps both invocations in an `flock` taken on
`<repo-root>/.lake/build-guard.lock`, the lock path `.claude/scripts/lake-build-guard.sh` already
publishes in its own header as a stable convention, so the guard and this script exclude each
other with no coupling, no probe for `.claude/`, and no behavior change in a clone with no agent
system deployed. A second, smaller item creates the missing `scripts/nolints-style.txt` and
reconciles the now-contradicted comment in `.github/workflows/ci.yml` that records its absence as
intended. Done means: a full (non-`--no-build`) invariants run executes its builds under the
shared lock, repeated concurrent trials against a guarded full build produce no contention-
attributable failure, and the style linter no longer prints its missing-nolints warning.

### Research Integration

The research report settles the dispatch's open design question and both of its rejections, and
this plan adopts its recommendation verbatim:

- **Chosen**: repository-local `flock` on `<repo-root>/.lake/build-guard.lock`. Advisory locks are
  keyed on the path, not on the binary that opened it, so "the guard also honors it" is an
  emergent property requiring zero detection logic.
- **Rejected — probe for the guard**: would hardcode a reference from a repository deliverable
  into a disposable deploy tree (`.claude/`), and would leave a guard-less clone racing exactly as
  today.
- **Rejected — refuse to run on detected concurrency**: converts transient, self-resolving
  contention into a hard red that a reader must re-attribute against the commit log, which is the
  precise cost this task exists to remove. Bounded waiting converts contention into a slower
  green instead.

Two facts from the report reshape the second item and must not be lost at implementation time:
(1) `check-module-invariants.sh` never mentions `nolints-style.txt` at all — the reference is
hardcoded in vendored Mathlib (`.lake/packages/mathlib/scripts/lint-style.lean`), so "stop
referring to it" is not available from this repository's side and only "create the file" is
actionable; (2) `.github/workflows/ci.yml` already records the file's absence as deliberate and
intended, so creating the file without correcting that comment would leave two contradictory
recorded decisions in the tree.

The report also fixes the verification shape: the race manifests only in a full local run (CI
always passes `--no-build`), so no CI change is needed and a CI-mode re-run proves nothing.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context; no roadmap consultation was performed.

## Goals & Non-Goals

**Goals**:
- Both `lake build` invocations in `check-module-invariants.sh`'s C1 section run while holding an
  `flock` on `<repo-root>/.lake/build-guard.lock`.
- The chosen design and the two rejected alternatives are recorded in the script's own comment
  block, in the register the rest of the file already uses.
- A missing `flock` binary degrades audibly (one printed notice) rather than silently.
- Lock contention is attributable: a printed notice before the script blocks.
- Repeated concurrent trials against a guarded full build show no contention-attributable failure.
- `scripts/nolints-style.txt` exists, empty and `--`-commented, and the style linter stops warning.
- `.github/workflows/ci.yml`'s comment asserting the file's deliberate absence is corrected in the
  same change.

**Non-Goals**:
- Modifying `.claude/scripts/lake-build-guard.sh` or its agent-system source store. Nothing on the
  guard's side needs to change.
- Wiring `check-module-invariants.sh` into the guard binary, or making it depend on `.claude/`
  existing at all.
- Changing CI's behavior. The `--no-build` path is untouched, and the ci.yml edit is comment-only.
- Serializing anything beyond C1's two builds (the later `.lake`-reading checks inherit the
  benefit because they run after the lock-held builds; no separate locking is added for them).
- Adding any lint exception to `nolints-style.txt`. It ships empty on purpose.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A blocking `flock -w 600` makes a contended run look hung | M | M | Print a one-line notice via the script's own `note` helper before blocking, so the wait is attributable |
| Fd-allocation idiom (`exec {fd}<>`) or subshell scoping silently drops the lock | H | L | Verify lock acquisition directly with the cheap deterministic holder test in Phase 2 (external `flock` holder on the same path), not only by inference from a clean build |
| Concurrent real-build trials are slow and expensive | M | H | Bound to 3 trials; the mechanism is deterministic mutual exclusion, not probabilistic, so a small trial count against a previously reliable reproducer suffices |
| Guard result-sharing replays a prior result instead of really building, making a trial vacuous | M | M | Pass `--no-share` to the guard in every trial and assert the absence of the `lake-build-guard: REPLAY:` stderr marker |
| Creating `nolints-style.txt` while leaving ci.yml's comment intact leaves two contradictory recorded decisions | M | M | Phase 3 treats the ci.yml correction as part of the same change, not a follow-up |
| New comment text cites a task number under `scripts/` | L | L | C9 forbids task-number citations under `FormalSystem/`, `lakefile.toml`, `README.md`, `scripts/`; write durable anchors only, and C9 will catch a slip |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 3 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Serialize C1's builds on the shared lock [COMPLETED]

**Goal**: Both `lake build` invocations in `check-module-invariants.sh`'s C1 section run under an
`flock` on `<repo-root>/.lake/build-guard.lock`, with an audible fallback and an attributable wait.

**Tasks**:
- [x] Re-read `scripts/check-module-invariants.sh`'s C1 section immediately before editing (a
      sibling task may have touched the file; see the dispatch's Territory note). *(completed)*
- [x] Add a comment block immediately above the C1 section, in the file's existing register,
      recording: why the builds are locked, that the path is the guard's own published convention,
      and the two rejected alternatives (probe-for-guard, refuse-on-concurrency) with the one-line
      reason each was rejected. No task-number citations (C9). *(completed)*
- [x] Inside the `RUN_BUILD` branch, before the builds: set
      `LOCK_FILE="$REPO_ROOT/.lake/build-guard.lock"` and `mkdir -p "$REPO_ROOT/.lake"`. *(completed)*
- [x] If `command -v flock >/dev/null 2>&1`: open an fd (`exec {fd}<>"$LOCK_FILE"`), try
      `flock -n "$fd"`; on failure print a one-line `note` naming the wait and the timeout, then
      `flock -w 600 "$fd"`. Mirror the guard's own idiom and its 600s default. *(completed)*
- [x] If the blocking wait itself times out, `fail C1` with a message naming lock-wait timeout
      (never fall through into an unserialized build after having detected contention). *(completed)*
- [x] If `flock` is absent, print one stderr notice in the guard's wording register
      (`check-module-invariants: flock not found on PATH; running lake build unserialized`) and
      run the builds unchanged. *(completed)*
- [x] Leave both builds' existing pass/fail/`tail -40` reporting byte-identical; the only change is
      what surrounds them. Release is implicit on fd close at script exit — do not add `flock -u`. *(completed)*
- [x] Run `bash -n scripts/check-module-invariants.sh` and `shellcheck scripts/check-module-invariants.sh`
      (if available) on the edited file. *(completed)*
- [x] Run `bash scripts/check-module-invariants.sh --no-build` and confirm C1 still reports
      `skipped (--no-build)` and the overall result is unchanged from before the edit. *(completed)*
- [x] Commit this phase's single file. *(completed)*

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: the C1 section contains exactly two unserialized `lake build` invocations
(reported at `scripts/check-module-invariants.sh:931` and `:937`) and they are the only
build-launching calls in the script. Confirm at implementation time with
`grep -n 'lake build\|lake exe\|lake test' scripts/check-module-invariants.sh` and reconcile the
full hit list against this assertion before editing; if a third build-launching call exists
outside C1, state it and decide explicitly whether it belongs inside the same held lock.

**Files to modify**:
- `scripts/check-module-invariants.sh` - C1 section: new design-rationale comment block, lock
  acquisition around the two existing `lake build` calls, `flock`-absent fallback notice,
  lock-wait-timeout failure path.

**Verification**:
- `bash -n` clean; shellcheck (if present) reports no new findings on the changed region.
- `--no-build` run behaves exactly as before (C1 skipped, same exit code).
- The script still resolves and runs from a directory other than the repo root (it `cd`s to
  `REPO_ROOT` at startup; confirm the lock path resolves under the repo's own `.lake/`).

---

### Phase 2: Demonstrate the race is closed under real concurrency [NOT STARTED]

**Goal**: Produce evidence that a concurrent guarded build no longer yields a failure attributable
to `.lake` artifact contention — the only verification the dispatch accepts.

**Tasks**:
- [ ] Cheap deterministic lock test first: in one shell hold the lock externally
      (`flock -x /path/to/repo/.lake/build-guard.lock -c 'sleep 90'`), then start
      `bash scripts/check-module-invariants.sh` and confirm it prints the wait notice and does
      not start building until the holder exits. This proves the lock is actually taken, which a
      clean build alone does not.
- [ ] Trial 1-3 (bounded at 3): start a guarded full build in the background with
      `bash .claude/scripts/lake-build-guard.sh build --no-share -- build BimodalTest`, redirecting
      to a log and capturing its PID; immediately start a full
      `bash scripts/check-module-invariants.sh` run, also logged.
- [ ] Wait on the background build by PID liveness only (`kill -0 "$pid"`), with a hard timeout —
      never `ps | grep` or `pgrep -f`. Read `context/patterns/bounded-build-waiter.md` before
      writing the waiter; one waiter per log.
- [ ] Assert in each trial's guard stderr that the `lake-build-guard: REPLAY:` marker is ABSENT
      (a replayed result means no real build ran and the trial is vacuous — re-run it).
- [ ] For each trial, record the invariants script's C1 verdict and the verdicts of the other
      `.lake`-reading checks (C2, C6, C16, C24, C25). For any failure, inspect the build log and
      classify it: a genuine compile error, or a truncated/partially-written `.olean`/trace
      artifact. Only the second class counts as a contention failure.
- [ ] Record the outcome table (trial, guard exit, invariants exit, failing checks, classification)
      in the implementation summary. Zero contention-attributable failures across three trials is
      the pass bar; one or more is a red result that sends the work back to Phase 1.
- [ ] Do not commit anything from this phase except the recorded evidence in the summary; no
      source changes are expected here.

**Timing**: 1.5 hours (dominated by real `lake build` wall clock)

**Depends on**: 1

**Verification Tier**: full

**Scope Hypothesis**: three concurrent-pair trials suffice. The underlying mechanism is
deterministic mutual exclusion rather than a probabilistic effect, and the pre-fix reproducer was
reliable (three spurious failures in one orchestration run). Confirm at implementation time by
checking that each trial genuinely overlapped — the invariants script's wait notice fired, or its
build window demonstrably overlapped the guard's — and, if no trial actually overlapped, add
trials until at least two did, or report the inability to reproduce overlap rather than claiming a
pass.

**Files to modify**:
- None (verification only). Logs go to the session scratchpad, not the repository.

**Verification**:
- The external-holder test shows the wait notice and a blocked start.
- Three overlapping trials, each with no `REPLAY:` marker, and zero failures classified as
  contention-attributable.

---

### Phase 3: Create nolints-style.txt and reconcile the ci.yml comment [NOT STARTED]

**Goal**: The style linter stops printing its missing-nolints warning, and no stale statement that
the file's absence is intended remains in the tree.

**Tasks**:
- [ ] Re-read `.github/workflows/ci.yml` and `scripts/README.md` immediately before editing.
- [ ] Create `scripts/nolints-style.txt` containing only `--`-prefixed comment lines explaining
      that the file is a deliberately empty Mathlib text-linter exception list, that one exception
      goes on one line, and that `--`-prefixed lines are ignored. No task-number citations (C9
      scopes `scripts/`).
- [ ] Correct the `.github/workflows/ci.yml` comment (the "Text-based style linters" step preamble,
      around lines 230-233) that currently states the file "deliberately does not exist" and that
      the warning "is the intended state" — replace with a short note that the file now exists as a
      deliberately empty exception list, and keep the `lake exe lint-style --fix` sentence.
- [ ] Add a `nolints-style.txt` row to `scripts/README.md`'s data-file table, in the register the
      neighboring rows use.
- [ ] Verify: run the style linter (`lake exe lint-style`) and confirm the
      `nolints file could not be read; treating as empty` warning no longer appears and the
      linter's own findings are otherwise unchanged from a pre-change run.
- [ ] Commit; stage only these three paths explicitly (never a directory or glob pathspec).

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: the ci.yml preamble is the only place in the tree asserting that
`nolints-style.txt`'s absence is intended. Confirm with
`grep -rn "nolints-style" --exclude-dir=.lake .` before editing and reconcile every hit outside
`.lake/packages/` (vendored Mathlib, which must not be edited).

**Files to modify**:
- `scripts/nolints-style.txt` - new file; `--`-commented, zero exceptions.
- `.github/workflows/ci.yml` - comment-only correction in the "Text-based style linters" step.
- `scripts/README.md` - one new data-file table row.

**Verification**:
- `lake exe lint-style` output no longer contains the missing-nolints warning.
- `grep -rn "nolints-style" --exclude-dir=.lake .` shows no remaining claim that the file is
  absent by design.
- `bash scripts/check-module-invariants.sh --no-build` still green (C9 task-number scan and the
  markdown link/path checks cover the two edited markdown/YAML surfaces).

---

## Testing & Validation

- [ ] `bash -n scripts/check-module-invariants.sh` clean.
- [ ] `bash scripts/check-module-invariants.sh --no-build` green, unchanged from the pre-change
      baseline (capture the baseline before Phase 1 starts).
- [ ] External-holder lock test: the invariants script waits, prints its notice, then proceeds.
- [ ] Three overlapping concurrent-pair trials, no `lake-build-guard: REPLAY:` marker, zero
      contention-attributable failures.
- [ ] `lake exe lint-style` no longer emits `nolints file could not be read`.
- [ ] Full (non-`--no-build`) `bash scripts/check-module-invariants.sh` run, serial, green — as a
      regression check only, explicitly not as evidence about the race.

## Artifacts & Outputs

- `scripts/check-module-invariants.sh` (modified) — C1 builds serialized on the shared lock plus
  the recorded design rationale.
- `scripts/nolints-style.txt` (new) — empty, `--`-commented exception list.
- `.github/workflows/ci.yml` (modified) — corrected comment.
- `scripts/README.md` (modified) — one data-file table row.
- `specs/688_gate_script_concurrency_reliability/summaries/01_*-summary.md` — including the Phase 2
  trial table with per-trial classification.

## Rollback/Contingency

Each phase commits its own files, so reverting is a `git revert` of the offending commit; no
working-tree discard is required. If Phase 2 shows the race persists, the fix is wrong rather than
incomplete: revert Phase 1's commit and re-derive the lock acquisition (most likely fd scoping —
confirm the fd is opened in the script's own shell, not in a subshell or a pipeline stage) before
re-running the trials. If a rollback that discards uncommitted work becomes genuinely necessary,
follow `context/contracts/recovery.md`'s rollback rung for the exact snapshot invocation,
including its out-of-scope override flag; do not run a bare reverting snapshot as a routine
checkpoint.
