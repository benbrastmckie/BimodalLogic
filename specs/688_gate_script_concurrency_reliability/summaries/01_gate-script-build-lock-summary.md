# Implementation Summary: Task #688

- **Task**: 688 - gate_script_concurrency_reliability
- **Status**: [COMPLETED]
- **Started**: 2026-09-28T02:00:00Z
- **Completed**: 2026-09-28T03:30:00Z
- **Effort**: ~1.5 hours
- **Dependencies**: None
- **Artifacts**: plans/01_gate-script-build-lock.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

`scripts/check-module-invariants.sh`'s C1 section ran two unserialized `lake build` calls,
racing any concurrently running guarded build for `.lake` artifacts. C1 now takes an `flock` on
`$REPO_ROOT/.lake/build-guard.lock` — the same path `.claude/scripts/lake-build-guard.sh`
already publishes as its own stable convention — around both builds, with an audible
`flock`-absent fallback and an attributable wait notice before a bounded 600s block. The fix was
verified under genuine concurrency: a deterministic external-holder test, plus three overlapping
trials against a real guarded full build (one organic, two deliberate, one exercising the reverse
wait direction), all with zero contention-attributable failures. The smaller second item —
`scripts/nolints-style.txt` not existing, so the style linter printed a harmless-but-desensitizing
warning on every run — is also closed: the file now exists (empty, `--`-commented), and the
`.github/workflows/ci.yml` comment that recorded its absence as deliberate is corrected.

## What Changed

- `scripts/check-module-invariants.sh` — C1 section: new design-rationale comment block (chosen
  design plus the two rejected alternatives, and a note that the lock, once acquired, is held
  until script exit so later `.lake`-reading checks — C16's second half, C25 — inherit the
  protection for free with no extra code); lock acquisition (`exec {fd}<>`, non-blocking `flock
  -n` first, an attributable `note` before a bounded `flock -w 600` wait) around both existing
  `lake build` calls; an audible `flock`-absent fallback; a lock-wait-timeout path that fails C1
  rather than falling through to an unserialized build. Both builds' existing pass/fail/`tail -40`
  reporting is byte-identical to before.
- `scripts/nolints-style.txt` — new file: a `--`-commented header explaining the file is a
  deliberately empty Mathlib text-linter exception list, one exception per line, `--`-prefixed
  lines ignored. Zero exceptions.
- `.github/workflows/ci.yml` — corrected the "Text-based style linters" step's preamble comment,
  which previously stated the file "deliberately does not exist" and that the warning "is the
  intended state"; it now records that the file exists and is deliberately empty.
- `scripts/README.md` — added a `nolints-style.txt` row to the data-file table, alphabetically
  placed between `nolint-attribute-allowlist.txt` and `nolints.json`.

## Decisions

- **Chosen**: repository-local `flock` on `<repo-root>/.lake/build-guard.lock` (the research
  report's and plan's recommendation, adopted verbatim). Advisory locks are keyed on the path, not
  the binary that opened it, so the guard and this script exclude each other with zero coupling:
  no probe for the guard's presence, no hardcoded reference into the disposable, regenerated
  `.claude/` deploy tree, and unchanged behavior in a clone with no agent system deployed at all.
- **Rejected — probe for the guard and call it when present**: would hardcode a repository
  deliverable's reference into a disposable deploy tree, and would still leave a guard-less clone
  racing exactly as before.
- **Rejected — refuse to run when concurrency is detected**: converts transient, self-resolving
  contention into a hard red a reader must re-attribute against the commit log — the exact cost
  this change exists to remove. Bounded waiting turns contention into a slower green instead.
- The lock fd opened in C1 is deliberately never closed with `flock -u`; it stays held until the
  script's own process exits. Since every later `.lake`-reading check in the file (C16's second
  half, C25, plus `lake exe runLinter`/`checkInitImports`) is gated by the identical `RUN_BUILD`
  flag as C1, they all run later in the SAME process and inherit the lock for free — confirmed by
  grepping every `lake build`/`lake exe` call site in the file and checking each one's gating
  before editing (the plan's Scope Hypothesis).
- `nolints-style.txt`'s absence could not be fixed from `check-module-invariants.sh`'s side — the
  reference is hardcoded in vendored Mathlib (`.lake/packages/mathlib/scripts/lint-style.lean`,
  which reads it via `TextBased.lean`'s `parseStyleExceptions`, itself confirmed to treat any
  `--`-prefixed line as a comment) — so "create the file" was the only actionable option, and the
  `ci.yml` comment recording the old absence as intended had to be corrected in the same change to
  avoid leaving two contradictory recorded decisions in the tree.

## Plan Deviations

- **Phase 2's Trial 1** was not the deliberately-launched `lake-build-guard.sh build --no-share --
  build BimodalTest` the plan's task list describes, but an organic, genuinely concurrent guarded
  full build from sibling task 689's own phase-6 gate run that happened to be holding the same
  lock file at the moment the follow-on invariants run was launched. It was recorded as Trial 1
  instead of discarded: it is a real, non-replayed, ~8.6-minute build (`state=complete`,
  `exit_status=0`, no `REPLAY:` marker in `.lake/build-guard.log`), and it is at least as strong
  evidence as a deliberately staged trial — arguably stronger, since it is the exact real-world
  scenario the dispatch's measured defect describes. Trials 2 and 3 used the plan's literal
  `--no-share` procedure; Trial 3 additionally exercised the reverse contention direction (the
  guard blocked on the invariants script's held lock, rather than the other way around), which the
  plan did not explicitly ask for but strengthens the evidence.

## Verification

- Build: Success (three full serial `lake build` + `lake build BimodalTest` runs across the Phase
  2 trials, all `PASS C1`)
- Tests: N/A (this task edits gate infrastructure, not `BimodalTest` content)
- Files verified: Yes — `bash -n` clean; `shellcheck` reports only one pre-existing, unrelated
  SC2034 warning at a line far from this change; `--no-build` unchanged (`INFO C1 skipped
  (--no-build)`); `lake exe lint-style` no longer prints the missing-nolints warning (confirmed by
  toggling the file's presence and observing the warning reappear/disappear)

### Phase 2 trial outcome table

| Trial | Kind | Guard exit | Guard REPLAY marker | Invariants C1 verdict | Other `.lake`-reading checks (C2/C6/C16/C24/C25) | Overall | Contention-attributable failure |
|---|---|---|---|---|---|---|---|
| External-holder | deterministic (`flock -x ... sleep 20`) | n/a | n/a | waited (notice printed), then `PASS` x2 after release | n/a (script exited early for this specific sub-test) | n/a | none |
| 1 | organic (sibling task 689's phase-6 gate-run guard build) | 0 | absent | waited (notice printed), then `PASS` x2 | all `PASS` | ALL CHECKS PASSED | none |
| 2 | deliberate `--no-share`, script waits on guard | 0 | absent | waited (notice printed), then `PASS` x2 | all `PASS` | ALL CHECKS PASSED | none |
| 3 | deliberate `--no-share`, guard waits on script (reverse direction) | 0 | absent | `PASS` x2 (acquired lock first) | all `PASS` | ALL CHECKS PASSED | none |

Zero contention-attributable failures across all three trials plus the deterministic test —
Phase 2's pass bar was met without needing a fourth trial.

## Impacts

- `check-module-invariants.sh`'s red results are now trustworthy under concurrent dispatch: a
  future red C1 (or any check downstream of it in the same run) means a real defect, not a race
  against another guarded build.
- No change to CI: the `--no-build` path (which CI always uses) is untouched; the race only
  manifests in a full local run.
- `.claude/scripts/lake-build-guard.sh` and its source store are unmodified — this task's fix is
  entirely on the repository-deliverable side, per the plan's Non-Goals.

## Follow-ups

- None. The task's two items (the C1 build race and the `nolints-style.txt` warning) are both
  closed and verified.

## References

- Plan: `specs/688_gate_script_concurrency_reliability/plans/01_gate-script-build-lock.md`
- Research report: `specs/688_gate_script_concurrency_reliability/reports/01_gate-script-concurrency-reliability.md`
- Progress files: `specs/688_gate_script_concurrency_reliability/progress/phase-{1,2,3}-progress.json`
- Handoff: `specs/688_gate_script_concurrency_reliability/handoffs/phase-1-handoff-20260928T023800Z.md`
- Commits: `0a7f5c515` (phase 1), `629b6fc12` (phase 3), `bb97ac4d2` (phase 2)
