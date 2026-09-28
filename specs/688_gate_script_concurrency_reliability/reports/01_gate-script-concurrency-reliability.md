# Research Report: Task #688

**Task**: 688 - gate_script_concurrency_reliability
**Started**: 2026-09-27T00:00:00Z
**Completed**: 2026-09-27T00:00:00Z
**Effort**: small (one script edit, one new data file, one comment reconciliation)
**Dependencies**: None
**Sources/Inputs**:
- `scripts/check-module-invariants.sh` (the racing script)
- `.claude/scripts/lake-build-guard.sh` (the existing serialization guard, deployed from the
  `core` extension source store at `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/lake-build-guard.sh`)
- `.github/workflows/ci.yml` (records CI's own `--no-build` invocation and a now-stale rationale
  for `nolints-style.txt`'s absence)
- `.lake/packages/mathlib/Mathlib/Tactic/Linter/TextBased.lean` and
  `.lake/packages/mathlib/scripts/lint-style.lean` (vendored Mathlib tool that actually reads
  `scripts/nolints-style.txt`)
- Live filesystem probes (`.lake/build-guard.lock` already present; `flock` on PATH)
**Artifacts**: - this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The race is real and precisely localized: `scripts/check-module-invariants.sh` calls `lake
  build` and `lake build BimodalTest` directly (lines 931 and 937) with no coordination, while a
  serialization guard (`.claude/scripts/lake-build-guard.sh`) already exists and already
  advertises its lock file as a documented, stable convention: `<project-root>/.lake/build-guard.lock`.
- **Recommended fix**: wrap both `lake build` calls in an `flock` acquired on
  `"$REPO_ROOT/.lake/build-guard.lock"` (the exact same path the guard already uses), falling
  back to an unguarded build with a printed notice only when `flock` itself is unavailable. This
  is a repository-local lock that the guard transparently honors too, because `flock()` mutual
  exclusion is cooperative on the file path, not on which binary opened it — no probing of
  `.claude/`, no hardcoded call into the deploy tree, and no behavior change at all for a clone
  with no agent system deployed (the lock still serializes the script's own two builds against
  itself, harmlessly).
- The second item's premise is stale: `.github/workflows/ci.yml` already contains a comment
  recording `scripts/nolints-style.txt`'s absence as **deliberate, documented, intended
  behavior** (added when CI's lint-style step was wired up), directly contradicting task 688's
  framing that this is unaddressed noise. The report recommends creating the file anyway (the
  task's judgment that the warning trains readers to skim linter output is reasonable) but flags
  that the plan/implementation must also update or remove the now-contradicted ci.yml comment,
  not just add the file — otherwise the repository carries two conflicting recorded decisions.
- `check-module-invariants.sh` never mentions `nolints-style.txt` at all; that file is read
  unconditionally by vendored Mathlib code (`lint-style.lean`, `.lake/packages/mathlib/`) invoked
  via `lake exe lint-style` in ci.yml, a wholly separate tool from `check-module-invariants.sh`'s
  own `scripts/nolints.json` (C16, Batteries `env_linter`). "Stop referring to it" is not an
  available option from this repository's side, since the reference lives in a vendored
  dependency; only "create the file" is actionable.

## Context & Scope

Task 688's file_scope is `scripts/check-module-invariants.sh` and `scripts/nolints-style.txt`.
Both items in the task description sit inside `scripts/`. No Lean source changes are implicated.

## Findings

### Codebase Patterns

**The race, exactly.** `scripts/check-module-invariants.sh:929-947` (the "C1: build" section):

```bash
if [ "$RUN_BUILD" -eq 1 ]; then
  BUILD_LOG=$(mktemp)
  if lake build >"$BUILD_LOG" 2>&1; then
    pass C1 "lake build exits 0"
  else
    fail C1 "lake build failed"
    ...
  fi
  if lake build BimodalTest >>"$BUILD_LOG" 2>&1; then
    pass C1 "lake build BimodalTest exits 0"
  else
    fail C1 "lake build BimodalTest failed"
    ...
  fi
  rm -f "$BUILD_LOG"
else
  info C1 "skipped (--no-build)"
fi
```

Neither `lake build` call takes any lock. `RUN_BUILD` is gated only by a leading `--no-build`
flag (`scripts/check-module-invariants.sh:172-173`); CI always passes `--no-build`
(`.github/workflows/ci.yml`, confirmed by the recurring `--no-build and therefore in CI` comments
throughout the script, e.g. lines 109, 125, 4526). **The race therefore only manifests in a full
(non-`--no-build`) local/agent-driven run** — exactly the multi-task orchestration scenario the
task description names — never in CI's own single-runner invocation. This matters for the plan:
the fix does not need to touch CI at all, and a verification pass that only re-runs CI's
`--no-build` mode would prove nothing about the defect, exactly as the dispatch already warns.

**The existing guard already documents the fix's foundation.** `.claude/scripts/lake-build-guard.sh`
is deployed from the `core` extension (source: `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/lake-build-guard.sh`
— per `.claude/rules/source-store-deploy-boundary.md`, any actual edit to the guard itself would
have to go there, not under `.claude/`, but **no edit to the guard is needed**, see Decision
below). Its header comments document the lock path as a stable, public convention:

```
#   - persist any state beyond the lock/result/log/capture files under the resolved project's
#     own .lake/ directory -- by name:
#       <root>/.lake/build-guard.lock    the flock() serialization lock
```

and `init_guard_paths()` (`.claude/scripts/lake-build-guard.sh:378-388`) resolves `<root>` by
walking up from the working directory to the nearest `lakefile.toml`/`lakefile.lean` — identical
to how `check-module-invariants.sh` resolves its own `REPO_ROOT`
(`scripts/check-module-invariants.sh:160-161`, `cd "$(dirname "${BASH_SOURCE[0]}")/.."`). Both
scripts land on the same repository root, hence the same lock path, with zero coordination code
required between them. The guard's own acquisition idiom
(`.claude/scripts/lake-build-guard.sh:679-680`, `:904-905`):

```bash
local fd
exec {fd}<>"$LOCK_PATH"
flock -n "$fd" || flock -w "$timeout" "$fd"
```

is a directly reusable shell idiom requiring only `flock` (present: `/run/current-system/sw/bin/flock`)
and a writable `.lake/` directory (already present and already populated with a live
`.lake/build-guard.lock` from prior guard usage in this very checkout — confirmed live).
The guard's default lock-wait timeout is 600 seconds
(`.claude/scripts/lake-build-guard.sh:239`, `DEFAULT_LOCK_TIMEOUT=600`), a reasonable value to
mirror.

The guard's own degrade-audibly convention for a missing `flock`
(`.claude/scripts/lake-build-guard.sh:886-888`):

```bash
if ! have_flock; then
  echo "lake-build-guard: flock not found on PATH; running unserialized" >&2
  ...
```

is the pattern to mirror for the fallback branch, using the script's own `note`/plain-stderr
style (`pass()`/`fail()`/`info()`/`note()` helpers at `scripts/check-module-invariants.sh:793-796`).

**No existing caller of the guard exists anywhere in the repo** (`grep -rl "lake-build-guard.sh"
--include="*.sh" .` returns nothing) — the guard's own header comment states this explicitly as a
non-goal ("It does not wire itself into any call site... must opt in explicitly"). Task 688 would
make `check-module-invariants.sh` the first adopter, but via the shared lock-file convention, not
via invoking the guard binary.

**`check-module-invariants.sh` is not reachable from anywhere in `.claude/`** — no skill, agent,
or hook invokes it (`grep -rn "check-module-invariants" .claude/` finds nothing beyond
`context/index.json`'s topic listing). It is invoked by developers/agents by hand and by
`.github/workflows/ci.yml` (always `--no-build`). This confirms the fix belongs entirely to
`scripts/check-module-invariants.sh` itself and needs no `.claude/`-side wiring change.

**The `nolints-style.txt` item is a different tool entirely.**
`scripts/check-module-invariants.sh` never references `nolints-style.txt` — only
`scripts/nolints.json` (a distinct file, for C16's Batteries `env_linter` baseline). The
`nolints-style.txt` reference is hardcoded inside vendored Mathlib code,
`.lake/packages/mathlib/scripts/lint-style.lean:262-266`:

```lean
let filename : System.FilePath := ("scripts" / "nolints-style.txt")
let nolints ← try
  IO.FS.lines filename
catch _ =>
  IO.eprintln s!"warning: nolints file could not be read; treating as empty: {filename}"
  pure #[]
```

invoked via `lake exe lint-style` in `.github/workflows/ci.yml`'s "Text-based style linters" step.
`.lake/packages/mathlib/Mathlib/Tactic/Linter/TextBased.lean:257-259` confirms the file format: any
line starting with `--` is a comment and ignored, so a file containing only a `--`-prefixed header
comment is valid and parses to zero exceptions — exactly what "empty and commented" in the task
description asks for.

**The ci.yml comment directly contradicts the task's framing** —
`.github/workflows/ci.yml` (the "Text-based style linters" step preamble) currently reads:

```
# scripts/nolints-style.txt, the per-project exception file, deliberately does not exist:
# the tool warns once ("nolints file could not be read; treating as empty") and proceeds
# with no exceptions, which is the intended state.
```

This is a previously-recorded, deliberate decision to leave the file absent, not an oversight.
Task 688 asks to reverse that decision. Both can be true (the original call was reasonable when
made; the accumulated noise cost across every single invocation, now measured, changes the
calculus) but the plan must not silently create the file while leaving this comment intact and
now-false — that would leave two contradictory statements of intent in the tree, which is exactly
the kind of drift this whole task is about preventing.

### External Resources

Not applicable — this is a self-contained shell/CI concurrency question with no external
dependency beyond `flock` (POSIX/util-linux, already present and already relied upon by the
existing guard).

### Recommendations

**Decision 1 — build-lock design (the "design question"): take a repository-local `flock` on the
guard's own documented lock path, do not modify the guard, do not probe for `.claude/`.**

Concretely, in `scripts/check-module-invariants.sh`'s C1 section (currently lines 929-947):

1. Before the two `lake build` invocations, compute `LOCK_FILE="$REPO_ROOT/.lake/build-guard.lock"`
   and `mkdir -p "$REPO_ROOT/.lake"`.
2. If `command -v flock >/dev/null 2>&1`, open an fd on `LOCK_FILE`
   (`exec {fd}<>"$LOCK_FILE"`), attempt a non-blocking `flock -n "$fd"`, and on contention fall
   through to a blocking `flock -w 600 "$fd"` (mirroring the guard's own idiom and its 600s
   default), printing a short notice on the wait path (e.g. via `note`) so a slow run is
   attributable rather than silently mysterious.
3. Run both `lake build` invocations inside that held lock, exactly as today otherwise
   (unchanged pass/fail reporting).
4. Release is implicit on script exit/`fd` close; no explicit `flock -u` needed (matches the
   guard's own reliance on `flock`'s exit-releases-the-lock semantics).
5. If `flock` is not on PATH, print a single stderr notice (mirroring the guard's own wording
   style, e.g. `check-module-invariants: flock not found on PATH; running lake build
   unserialized`) and fall through to the unguarded build unchanged — this is the only case where
   the race can still occur, and it is now an audible, printed condition rather than a silent one.

Why this option over the other two named in the dispatch:
- **Rejected: "probe for the guard and use it when present, fall back otherwise."** This would
  require detecting `.claude/scripts/lake-build-guard.sh` (a path outside this task's file_scope
  and, per `source-store-deploy-boundary.md`, a disposable deploy artifact this repo-owned script
  must not hardcode a reference to) and would leave the script racing exactly as today in any
  checkout without `.claude/` deployed — which is the very case the task description says must
  keep working. The chosen design instead achieves "use the guard when present" as an emergent
  property of both sides taking the same advisory lock, with no detection logic and no coupling
  at all.
- **Rejected: "have the script refuse to run when it detects a concurrent build."** This would
  turn a transient, resolvable contention (another guarded build finishes in seconds to minutes)
  into a hard failure requiring a re-run, which is a worse gate property than waiting: the task's
  own framing is that a red result must mean "a real defect," and a refusal-to-run is exactly the
  kind of result a reader has to go re-attribute against the commit log, the same cost the task
  is trying to eliminate. Waiting (bounded, at 600s) converts contention into a slower green
  rather than a spurious red.
- **Accepted: "repository-local lock the guard also honors."** This is what the chosen design is,
  realized with zero new coupling: the guard already "honors" any `flock()` on
  `<root>/.lake/build-guard.lock` by construction (advisory locks are per-path, not per-binary),
  so `check-module-invariants.sh` needs only to know the same path convention — which the guard's
  own header comment already publishes as documentation, not as an internal implementation
  detail. No modification to `.claude/scripts/lake-build-guard.sh` (nor its agent-system source
  store) is required; nothing outside the task's declared `file_scope` needs to change for item
  1 to be resolved.

**Decision 2 — `nolints-style.txt`: create it, and reconcile the ci.yml comment.**

- Create `scripts/nolints-style.txt` containing only a `--`-prefixed header comment (per
  `parseStyleExceptions`'s comment convention, confirmed above), e.g. explaining that it is
  intentionally empty and what adding a line to it means (a Mathlib-style lint exception, one per
  line, `--`-prefixed lines ignored).
- Update `.github/workflows/ci.yml`'s "Text-based style linters" step comment, which currently
  asserts the file's absence is "the intended state" — that sentence becomes false the moment the
  file is created, and must be corrected in the same change (either replaced with a short note
  that the file now exists as a deliberately-empty exception list, or removed if it no longer adds
  information). This file is not in task 688's declared `file_scope`, but `file_scope` is
  descriptive rather than enforced (`.claude/context/reference/state-management-schema.md`), and
  leaving a stale, self-contradicting comment in `ci.yml` would be a strictly worse outcome than
  the noise this task exists to remove.

### Verification That Would Actually Settle the First Item

The dispatch is explicit that a single clean serial run proves nothing, since the serial case was
never broken. A verification pass should:

1. Launch a guarded full build in the background via the existing guard
   (`bash .claude/scripts/lake-build-guard.sh build build BimodalTest`, or an equivalent guarded
   invocation) at the same time as a full (non-`--no-build`) `bash scripts/check-module-invariants.sh`
   run, repeated across several trials (the dispatch's own wording: "run ... repeatedly").
2. Confirm across all trials that `check-module-invariants.sh`'s C1 (and any other build-touching
   check, e.g. C2/C6/C16/C24/C25, which read `.lake` state produced by the same build) reports
   its real pass/fail outcome with no failure attributable to `.lake` artifact contention — i.e.
   no failure whose root cause, on inspection of the build log, is a partially-written/truncated
   `.olean`/trace file rather than a genuine compile error.
3. Because a real full build is slow, this is expensive to run many times; the plan should size
   the trial count against actual wall-clock budget (e.g. 3-5 concurrent-pair trials) rather than
   trying to statistically saturate confidence — a small number of concurrent-pair trials that
   were previously guaranteed to race (this task's own measured incident: 3 spurious failures in
   one orchestration run) and now consistently do not is sufficient evidence, given the mechanism
   (mutual exclusion via `flock`) is deterministic once correctly wired, not merely probabilistic.
4. A secondary, cheap check worth adding to the plan: confirm the lock is actually being taken
   (e.g. temporarily instrument with `--verbose`-style output showing "waiting for lock" during a
   deliberately-forced contention, using the guard's own `--timeout` small value against a
   long-`FAKE_LAKE_SLEEP`-style holder) — this is optional and only useful if the real-build
   verification in steps 1-2 is inconclusive on first attempt.

## Decisions

- Build-lock fix: `flock` on the guard's already-documented `<repo-root>/.lake/build-guard.lock`
  path, held around both `lake build` invocations in `check-module-invariants.sh`'s C1 section;
  no modification to the guard or to `.claude/` at all; audible fallback notice only if `flock`
  itself is absent.
- `nolints-style.txt`: create it (empty, `--`-commented), and correct the now-contradicted
  ci.yml comment in the same change.

## Risks & Mitigations

- **Risk**: a blocking `flock -w 600` inside `check-module-invariants.sh` could make a run appear
  to hang with no visible progress if another guarded build is long-running. **Mitigation**:
  print a one-line notice on the contended path (mirroring the guard's own `note` conventions)
  before blocking, so the wait is attributable rather than silent.
- **Risk**: editing `.github/workflows/ci.yml`'s comment touches a file outside the declared
  `file_scope`. **Mitigation**: `file_scope` is documented as descriptive/non-enforced; leaving a
  stale contradictory comment is the worse outcome, and the edit is a comment-only change with no
  behavioral effect on the CI step itself.
- **Risk**: verification requires real, possibly slow, concurrent `lake build` runs.
  **Mitigation**: bound the trial count; the mechanism is deterministic (advisory locking), so a
  small number of trials that previously reliably reproduced the race is sufficient once the fix
  is in place, rather than needing large-sample statistical confidence.

## Context Extension Recommendations

None — this is a `general`/`repo-hygiene` task with no gap in existing `.claude/context/`
documentation; the relevant convention (`<root>/.lake/build-guard.lock` as a public, reusable
lock path) is already documented at the point of use (`.claude/scripts/lake-build-guard.sh`'s own
header comment) and needs no new context file.

## Appendix

- Searches: `grep -rn "lake build\|flock\|BUILD_LOCK" scripts/check-module-invariants.sh`;
  `grep -rln "lake-build-guard.sh" --include="*.sh" .`; `grep -rn "check-module-invariants"
  .claude/`; `grep -rn "nolints-style\|could not be read; treating as empty" .`; `grep -n
  "nolints-style" .lake/packages/mathlib/scripts/lint-style.lean
  .lake/packages/mathlib/Mathlib/Tactic/Linter/TextBased.lean`.
- Live probes: `command -v flock`; `ls .lake/build-guard.*` (confirmed pre-existing lock file
  from prior guard usage in this checkout).
- Key files read: `scripts/check-module-invariants.sh` (lines 1-230, 890-950),
  `.claude/scripts/lake-build-guard.sh` (lines 1-240, 350-410, 650-930),
  `.github/workflows/ci.yml` (lines 1-245), `.lake/packages/mathlib/scripts/lint-style.lean`
  (lines 170-275), `.lake/packages/mathlib/Mathlib/Tactic/Linter/TextBased.lean` (lines 250-535).
