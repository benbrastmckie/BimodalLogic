# Implementation Summary: Task #786

- **Task**: 786 - Harden `scripts/check-evidence-probes.sh` against the `.lake` read/write race and give it an environment-failure diagnostic class
- **Status**: [COMPLETED]
- **Started**: 2026-10-14T14:57:14Z
- **Completed**: 2026-10-14T15:25:00Z
- **Effort**: ~0.5 hours wall clock (plan estimated 3.25 hours)
- **Dependencies**: None (the `dependencies[]` edge on 734 was dropped by recorded user decision, 2026-10-14)
- **Artifacts**: plans/01_harden-evidence-probe-driver.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Closed the two driver defects research established in `scripts/check-evidence-probes.sh`: it took
no lock while invoking `lake env lean` 33 times, so its `.lake` reads raced any concurrent guarded
build, and its failure vocabulary had no class for an environment/I/O failure, so a transient
missing-olean error was reported as though a probe's proof had rotted. The script now holds the
already-published `$REPO_ROOT/.lake/build-guard.lock` `flock` for its whole run and names an
absent or half-written `.lake` artifact as an environment failure, distinct from probe rot and
from a file having left version control. The stale header claim that the script is not wired into
CI is replaced by its present wiring. No probe file was touched and the wired manifest is
unchanged.

## What Changed

- `scripts/check-evidence-probes.sh` — the only modified file (154 insertions, 3 deletions):
  - **Shared lock.** `PROBE_LOCK_WAIT_S` (default 600), `REPO_ROOT="$(pwd)"`,
    `LOCK_FILE="$REPO_ROOT/.lake/build-guard.lock"`, `exec {PROBE_LOCK_FD}<>`, `flock -n` then an
    announced `flock -w` on contention, the fd held to process exit (no `flock -u`) so all 33
    `check_probe` calls describe one consistent library snapshot. Absent `flock` degrades
    audibly on stderr; a timed-out wait fails with an environment-class line naming the lock path
    before any probe is attempted. Inserted after the `WIRED`/`WIRED_REPO`/`DEFERRED` arrays so
    `generate-decidability-inventory.sh`'s SRC2 anchors are untouched. The precedent at
    `scripts/check-module-invariants.sh`'s `C1: build` block is reused in shape and
    cross-referenced for its rejected alternatives rather than re-litigated.
  - **Third diagnostic class.** `env_failures` counter; a deliberately narrow
    `probe_env_failure` predicate matching `object file '...' of module ... does not exist` and an
    OS-level `no such file or directory` that also names a `.lake/` path; a
    `FAIL (environment: ...)` branch in `check_probe` that says explicitly this is not probe rot;
    a conditional environment count emitted as a separate line after the byte-identical
    `FAIL  N of M wired probe(s) failed` summary; and a third foot-guidance paragraph. Anything
    unmatched falls through to `FAIL (does not compile)` by construction.
  - **Header.** The CI claim replaced with the present wiring (step id `evidence-probes` in
    `.github/workflows/ci.yml`, `continue-on-error: true`, counted by the aggregating
    `Report results` step which exits 1 on any counted failure); new `WIRED INTO CI`,
    `THREE DIAGNOSTIC CLASSES` (with the triage rule that a missing-object-file error is never
    probe or source rot), and `SERIALIZED AGAINST CONCURRENT BUILDS` subsections; `Exit status:`
    extended to cover the lock-timeout case.

## Decisions

- A reader takes the **writer's exclusive** lock, not a shared one: `lake env` is not audited as
  provably write-free and both existing users of this lock path take it exclusively.
- The lock is joined, not re-specified. No change to `lake-build-guard.sh`,
  `check-module-invariants.sh`, or `.github/workflows/ci.yml`. An advisory path-keyed lock means
  nothing in this repository references the disposable `.claude/` deploy tree.
- The predicate errs toward under-matching. A missed environment failure costs one re-run; genuine
  rot mislabelled as environment is excused and never repaired.
- `PROBE_LOCK_WAIT_S` is documented in place as a test affordance, not a tuning knob — it exists
  so the timeout branch is demonstrable.

## Plan Deviations

- **Phase 2** altered: the dependent-gate expectation "no diff against the committed baseline" was
  measured instead as `generate-decidability-inventory.sh --diff` exit 0 with no `FAIL SRC2`
  anti-silence line. That script prints pre-existing `+/- REFUTED` drift against an archived,
  curated review baseline; since this task edits no array line, SRC2's input is byte-identical to
  the pre-edit file and the drift is pre-existing by construction.
- **Phase 3** altered: the prescribed locator `grep -n 'not wired into CI'` returns no hit — the
  claim is line-wrapped in the source as `is not wired into` / `# CI.`. Followed the phase's own
  stop-and-re-read instruction and edited at the measured two-line location.
- **Phase 4** extended: a fifth negative control (NC5) was added beyond the plan's NC1-NC4,
  because the predicate's second matcher is unreachable from any whole-script control on a healthy
  tree. The function was extracted verbatim and driven directly rather than recorded as
  read-through-verified.

## Verification

- Build: Success — `lake-build-guard.sh build --timeout 1800 -- build`, detached, guard exit 0,
  `Build completed successfully (2844 jobs)`, zero `error:` occurrences in the captured output.
- Sorry count: 0 (`lean-sorry-census.sh` over all eight resolved source roots).
- Vacuous count: 1 — `FormalSystem/Examples/TemporalStructures.lean:495`,
  `theorem int_domain_universal (t : Int) : intTimeHistory.domain t := trivial`. Pre-existing and
  untouched: this task modified **zero** Lean files (`git diff --stat HEAD~3 -- '*.lean'` is
  empty), so the count did not increase. On manual review the single hit is a false positive of
  the single-line grep — a real theorem about the integer history whose correct proof is
  `trivial`, not a placeholder standing in for an unproved obligation.
- Axiom count: 14, unchanged for the same reason (no Lean file modified).
- Tests: N/A for this change; the repository gate set was run in full instead — see below.
- Files verified: Yes.

Gate set, each exit status measured:

| Gate | Exit |
|---|---|
| `bash scripts/check-evidence-probes.sh` | 0 — `PASS  all 33 wired probe(s) compile`, 144 s, stderr empty |
| `bash scripts/generate-decidability-inventory.sh --diff` | 0 — no `FAIL SRC2`; 32 WIRED + 1 WIRED_REPO = 33 |
| `bash scripts/check-module-invariants.sh --no-build` | 0 — `ALL CHECKS PASSED` |
| `shellcheck scripts/check-evidence-probes.sh` | 0 — no output, identical to the pre-edit baseline |
| `bash .claude/scripts/verify-deploy.sh` | 0 — `PASS -- 15 check(s), 0 failure(s)` |
| `bash -n scripts/check-evidence-probes.sh` | 0 |

Five negative controls, all measured (none read-through-only); verbatim output is in
`handoffs/phase-4-handoff-20261014T152215Z.md`:

- **NC1** — a displaced `FormalSystem/Examples.olean` produced 17 `FAIL (environment: ...)` lines
  and **zero** `FAIL (does not compile)` lines, with the environment summary note and the third
  foot paragraph, exit 1. The affected set includes all four probes this record originally named
  as rotted, reproducing the originating misdiagnosis under the correct label. The olean was
  restored from a scratchpad copy (identical size and mtime) and two subsequent full runs
  measured green.
- **NC2** — a bounded background lock holder produced the stderr notice naming the published path
  and the 600 s bound; the run then completed green. Contention becomes a slower green.
- **NC3** — `PROBE_LOCK_WAIT_S=1` against a held lock produced the environment-class timeout
  failure naming the lock path, exit 1, with no probe attempted.
- **NC4** — a shim `PATH` of 2271 symlinks with `flock` removed produced the audible degradation
  notice and an otherwise-green run.
- **NC5** — the extracted predicate matched both intended shapes and rejected all three
  false-positive controls (a genuine elaboration error, a `.lake`-less no-such-file error, and an
  unsolved-goals error), so the narrowness contract holds as measured.

Hard constraint proven: `git diff HEAD~3 -- specs/evidence/` is empty (0 lines); no changed line
touches `WIRED=(`, `WIRED_REPO=(`, or `DEFERRED=` (the single unfiltered `grep -c` hit is a `@@`
hunk-context header); `scripts/check-evidence-probes.sh` is the only non-`specs/**` path changed.

## Impacts

- The `evidence-probes` CI step no longer fails for reasons unrelated to any probe: its `.lake`
  reads are serialized against guarded builds on the same tree, and a residual I/O failure is
  labelled as one.
- A reader triaging a red run now has a triage rule in the header. The misattribution path that
  turned one transient race into two Reasoned Exclusions and a repair record is closed at the
  point where the misreading happened.
- A concurrent guarded build now waits for a probe run (~84-144 s). This is the intended trade and
  the same cost `check-module-invariants.sh` already pays.
- `scripts/generate-decidability-inventory.sh` is unaffected: exit-status verdict, verbatim stdout
  echo, and the SRC2 array anchors all still behave as before.

## Follow-ups

- The research report's recommendation to extend
  `context/project/lean4/operations/long-builds.md` with an "unguarded readers see half-written
  artifacts" section is deliberately out of scope here: it targets the deployed `.claude/` tree,
  whose edits belong in the source store under a separate record.
- `scripts/check-evidence-probes.sh` is also declared in the `file_scope` of two other records
  (one blocked, one partial, both idle with no execution evidence). Neither was disturbed; an
  overlap admitted by recorded decision rather than serialized.

## References

- `specs/786_evidence_probe_compile_failures_repair/plans/01_harden-evidence-probe-driver.md`
- `specs/786_evidence_probe_compile_failures_repair/reports/01_evidence-probe-compile-failures.md`
- `specs/786_evidence_probe_compile_failures_repair/handoffs/phase-1-handoff-20261014T150027Z.md`
- `specs/786_evidence_probe_compile_failures_repair/handoffs/phase-2-handoff-20261014T150404Z.md`
- `specs/786_evidence_probe_compile_failures_repair/handoffs/phase-3-handoff-20261014T150753Z.md`
- `specs/786_evidence_probe_compile_failures_repair/handoffs/phase-4-handoff-20261014T152215Z.md`
- `scripts/check-module-invariants.sh` (`C1: build` block — the lock precedent and its rejected alternatives)
- `.github/workflows/ci.yml` (step id `evidence-probes`; the aggregating `Report results` step)
