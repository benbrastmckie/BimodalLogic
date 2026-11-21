# Research Report: Task #941

**Task**: 941 - Local aggregator that mirrors ci.yml's check gate
**Started**: 2026-11-19T00:00:00Z
**Completed**: 2026-11-19T00:00:00Z
**Effort**: small
**Dependencies**: None
**Sources/Inputs**:
- `.github/workflows/ci.yml` (full read, current tree)
- `docs/development/CI_CD_PROCESS.md` ("Wiring a New Check Script" section, lines 214-320)
- The nine check scripts under `scripts/` (headers, usage comments, exit-code conventions)
- `scripts/README.md` (cataloguing conventions, shared `.lake` lock narrative)
- `CONTRIBUTING.md` (Development Setup / Verifying Setup sections, lines 9-59)
- `lakefile.toml` (confirms `mk_all`/`lint-style` are upstream Batteries/Mathlib executables,
  not locally declared `lean_exe` targets)
- `specs/reviews/review-2026-11-19.md` (Medium-severity source finding, lines 56-64, 182)
**Artifacts**:
- `specs/941_local_verify_all_ci_check_aggregator/reports/01_local-verify-all-aggregator.md` (this report)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The dispatch's nine-check list is **correct in order and script identity** but **wrong in two
  exact invocations** — re-deriving from the live `.github/workflows/ci.yml` (as the dispatch
  itself warns to do) surfaces real argument drift from what a contributor would guess.
- Check 3 is `check-copyright-headers.sh --strict FormalSystem BimodalTools`, not bare
  `--strict`. Check 4 is `readme-lint.sh FormalSystem BimodalTools`, not a bare call. Both
  scripts default to `ROOTS=("FormalSystem")` only, so a bare invocation silently omits
  `BimodalTools` from the gate — exactly the omission CI's own step comments warn about.
- Check 8 is `lake exe mk_all --lib FormalSystem --check`, not `lake exe mk_all --check` — the
  bare form errors on this package's two `srcDir = "Tests"` libraries and would generate a
  `BimodalTools.lean` importing thirteen `main`s, per the step's own comment.
- Check 9 (`lint-style`) is **three sub-checks bundled into one CI step outcome**: `lake exe
  lint-style` itself, plus two inline shell checks (no `.lean` file has the executable bit set;
  no two tracked paths collide case-insensitively). All three must be replicated under one
  aggregate verdict for `verify-all.sh` to report the same pass/fail as CI for check 9 — running
  only `lake exe lint-style` is a parity gap the verification step would not catch unless a
  commit happens to trip the bit/case guard.
- All nine checks run **sequentially** in CI (never in parallel), so there is no lock-contention
  or deadlock hazard for `verify-all.sh` to manage: `check-module-invariants.sh` and
  `check-evidence-probes.sh` each take the shared `.lake` flock and release it on their own exit
  before the next check starts.
- `check-paper-definitions.sh`'s `SKIP (neutral): ...` convention is an internal exit-0 message,
  not a CI "skipped step" — it must be reported as PASS, matching how CI's aggregating gate
  would categorize it (step `outcome: success`).

## Context & Scope

Researched what `scripts/verify-all.sh` must invoke, in what order and with what exact
arguments, to reproduce `ci.yml`'s nine-check gate locally, plus where to document it
(`CONTRIBUTING.md`, `scripts/README.md`) consistent with existing conventions. Implementation,
`ci.yml` changes, and pre-commit-hook wiring are explicitly out of scope per the dispatch.

## Findings

### Codebase Patterns

**The nine checks, re-derived from the live `.github/workflows/ci.yml` (verified against the
dispatch's draft list — two entries differ in exact arguments):**

| # | Step name in ci.yml | Exact invocation | Step `id` | `if:` guard |
|---|---|---|---|---|
| 1 | `check-evidence-probes.sh` | `bash scripts/check-evidence-probes.sh` | `evidence-probes` | none (runs only if prior hard-stop build steps succeeded) |
| 2 | `Check module invariants` | `bash scripts/check-module-invariants.sh --no-build` | `module-invariants` | `${{ !cancelled() }}` |
| 3 | `Check copyright headers` | `bash scripts/check-copyright-headers.sh --strict FormalSystem BimodalTools` | `copyright-headers` | `${{ !cancelled() }}` |
| 4 | `Check README health` | `bash scripts/readme-lint.sh FormalSystem BimodalTools` | `readme-lint` | `${{ !cancelled() }}` |
| 5 | `Check Metalogic directory-level import cycles` | `bash scripts/check-metalogic-cycles.sh` | `metalogic-cycles` | `${{ !cancelled() }}` |
| 6 | `Typst sync check` | `bash scripts/typst-sync-check.sh` | `typst-sync` | `${{ !cancelled() }}` |
| 7 | `Check paper definitions` | `bash scripts/check-paper-definitions.sh` | `paper-definitions` | `${{ !cancelled() }}` |
| 8 | `Check the generated library root` | `lake exe mk_all --lib FormalSystem --check` | `mk-all-check` | none |
| 9 | `Text-based style linters` | `lake exe lint-style`, **then** an executable-bit scan over `git ls-files -s -- '*.lean'`, **then** a case-insensitive tracked-path-collision scan over `git ls-files` | `lint-style` | none |

The `Report results` step (bottom of the job) is the aggregating gate `verify-all.sh` must
mirror in shape: `expected=9`; a `report "<label>" "<outcome>"` call per check classifying
`success` → PASS, `skipped|cancelled|''` → SKIPPED, anything else → FAIL; a final tally printed
as `RESULT: FAIL (...)` / `RESULT: PASS (... skipped ...)` / `RESULT: PASS (all N checks ran and
passed)`; nonzero exit iff `failed > 0`.

**Deviation from the dispatch's own enumerated list** (the dispatch explicitly instructs
re-deriving rather than trusting it, and this is why): checks 3, 4, and 8 above carry arguments
the dispatch's bare-name list omitted. `check-copyright-headers.sh` and `readme-lint.sh` both
default to `ROOTS=("FormalSystem")` (confirmed in both scripts' own usage comments), so a verbatim
bare-name implementation of `verify-all.sh` would silently skip `BimodalTools` on both checks —
a real parity gap with CI, not a cosmetic one. `lake exe mk_all --check` (bare) is a different,
broken invocation per the step's own comment (errors on the two `Tests`-rooted libraries).

**`continue-on-error` and sequential execution.** All nine CI steps carry
`continue-on-error: true`; none of CI's `if:` conditioning depends on another *check* step's
outcome — only on the hard-stop build steps above them (lean-action build/test/lint,
`lake build <exe-root>` for each `lean_exe`, `lake build BimodalTools --wfail`, `lake build
BimodalToolsTest --wfail`). Since `verify-all.sh` is meant to run *after* a contributor has
already run `lake build`/`lake test` locally (per the task's PROBLEM statement), there is no
need to replicate that `if:`/`cancelled()` conditioning inside the script — all nine checks can
run unconditionally, in order, continuing past a failure, exactly as scope (A) specifies. This
also sidesteps any lock-contention concern: `scripts/README.md`'s "Per-script determinations"
table marks `check-module-invariants.sh` and `check-evidence-probes.sh` as **Locked, held to
exit** against the shared `.lake/build-guard.lock`, but since all nine checks run strictly
sequentially (never backgrounded or parallelized) in both CI and the proposed local script, each
lock is acquired and released before the next check starts — no deadlock risk from aggregating
them in one script.

**Exit-code conventions observed per script** (relevant only insofar as `verify-all.sh` treats
any nonzero exit as FAIL, matching CI's `outcome: failure` mapping — no script needs translation
beyond that):
- `check-copyright-headers.sh`: exit 2 on a missing root/usage error, exit 1 on a genuine
  `--strict` violation, exit 0 otherwise.
- `readme-lint.sh`: `set -euo pipefail`; exit 1 on a gated violation (missing README, stale
  date), exit 0 otherwise.
- `check-metalogic-cycles.sh`: `set -uo pipefail`; exit 1 on any of its three assertions failing.
- `check-paper-definitions.sh`: exit 0 on both "paper absent" (prints `SKIP (neutral): ...`) and
  "paper present, no drift"; exit 1 only on genuine drift in a recorded definition block. The
  `SKIP (neutral)` line is a script-internal message distinct from a CI "skipped step" — it must
  be reported as PASS by `verify-all.sh`, matching how `ci.yml`'s own `Report results` step would
  see it (the step's `outcome` is `success` either way).
- `check-module-invariants.sh --no-build`: exits non-zero on any failed invariant (C1/C16-full/
  C25 and C2/C6/C24 are the documented gaps this `--no-build` mode skips, already covered
  elsewhere in the CI job).

**Existing style/convention references for the two documentation deliverables:**
- `CONTRIBUTING.md`'s `### Development Setup` section (lines 18-43) ends with the
  `bash scripts/install-git-hooks.sh` one-time install instruction and its explanatory comment
  block; `### Verifying Setup` (lines 44-59) is a short fenced `bash` block of spot-check
  commands (`lake build`, `lake test`, `lake lint`, `bash scripts/install-git-hooks.sh --check`).
  The dispatch's "next to the existing git-hook installation instructions" instruction fits
  naturally as either an added line inside the Development Setup fenced block (alongside the
  `install-git-hooks.sh` line) or as an added line in the Verifying Setup block/its prose —
  the plan phase should pick one placement rather than duplicating in both.
- `scripts/README.md`'s "Gates and ratchets" table (the first table in the file) is the closest
  existing category by function (a script `verify-all.sh` would be invoked as a drift/regression
  gate), cataloguing each script as a `| Script | Purpose |` row. Scope item (C) asks only for
  "an entry... consistent with how the other scripts there are catalogued" — a new row in this
  table, or a short new subsection analogous to the "Typst synchronization utilities" /
  "Other utilities" groupings, both match the file's established pattern of one Markdown table
  per functional category plus prose explaining non-obvious mechanics (e.g. the "Shared `.lake`
  build lock" section). Given `verify-all.sh` is purely a sequential caller of the nine scripts
  above (no `.lake` read of its own, since each child script manages its own lock), it would earn
  a **No lock** row in the existing "Per-script determinations" table under "Shared `.lake` build
  lock" as well, for completeness.
- `docs/development/CI_CD_PROCESS.md`'s "Wiring a New Check Script" section (lines 214-ca.320)
  documents step-naming, the non-blocking/aggregating-gate convention, the skip-and-report-neutral
  convention, cache-warm placement, and a runtime-budget table. This file is not named in the
  dispatch's SCOPE as a file to update, and the task's scope is explicitly a *local* aggregator,
  not a change to how new CI steps are wired — no edit to this file is implied by the current
  scope, but its "Wiring a New Check Script" convention (step naming mirrors exact invocation;
  aggregating-gate shape; skip-and-report-neutral) is the direct model `verify-all.sh`'s own
  per-check reporting and exit-handling should follow, and is worth citing in the implementation
  plan as the design precedent rather than re-deriving a reporting shape from scratch.

### External Resources

None consulted — this is a purely local, codebase-internal aggregation task with no external
library or API surface.

## Recommendations

1. **Re-derive, don't copy, the dispatch's check list.** Implement `verify-all.sh` against the
   nine invocations in the Findings table above (with the `FormalSystem BimodalTools` arguments
   on checks 3-4 and `--lib FormalSystem --check` on check 8), not the dispatch's bare-name
   enumeration — the dispatch itself flags this as the expected re-derivation step, and the
   argument drift is real and silent if missed.
2. **Treat check 9 as three sub-checks under one reported verdict**, in `ci.yml`'s own order:
   `lake exe lint-style`, then the executable-bit scan, then the case-collision scan. Any one
   failing should mark check 9 FAIL and the script should still continue to produce the final
   aggregate (matching scope's "continue through all checks" requirement at the sub-check level
   too, since CI's own step runs all three bash blocks under one `run:` with `set -euo pipefail`
   — a mid-step failure there actually stops that step's later blocks, so continuing past a
   sub-check failure inside check 9 would be a *stricter*, not laxer, local check; either
   behavior is defensible, but the plan should state which was chosen and why).
3. **No `if:`/`cancelled()` conditioning is needed locally** — run all nine checks unconditionally
   in order on the assumption (stated in the task's own PROBLEM framing) that `lake build`/
   `lake test` already passed. If the plan phase wants to also catch the case where the
   contributor has *not* yet built successfully, it should explicitly decide whether
   `verify-all.sh` invokes `lake build` itself first or documents the build as a precondition —
   this was not raised by the dispatch and is a reasonable question to flag rather than decide
   unilaterally in research.
4. **Reuse the aggregating-gate shape verbatim** from `ci.yml`'s `Report results` step (the
   `report()` shell function, `expected=9`, PASS/SKIPPED/FAIL tally, final `RESULT: ...` line and
   exit code) — this is exactly the "same pass/fail reporting shape" scope (A) asks for, and the
   step's shell is already written and tested; adapting it in place (dropping the GitHub
   Actions-specific `steps.<id>.outcome` interpolation in favor of each local script's own exit
   code) is lower-risk than designing a new reporting format.
5. **Documentation placement**: add one line to `CONTRIBUTING.md`'s Development Setup fenced
   `bash` block (after the `install-git-hooks.sh` line, per the dispatch's "next to" instruction)
   pointing at `scripts/verify-all.sh`, and one new row to `scripts/README.md`'s "Gates and
   ratchets" table (the functionally closest existing category, since `verify-all.sh` is itself a
   gate-aggregator rather than a drift ratchet, dataset utility, or typst-sync utility).

## Decisions

- Confirmed the nine checks' identity and order against the live `.github/workflows/ci.yml`
  rather than the dispatch's drafted list, per the dispatch's own instruction; two argument
  discrepancies (checks 3, 4, 8) and one granularity discrepancy (check 9 is three sub-checks)
  were found and are recorded above rather than silently carried through to planning.
- Determined no lock-contention/sequencing hazard exists for a sequential-caller aggregator
  script, based on `scripts/README.md`'s documented "Per-script determinations" table and the
  fact that both CI and the proposed local script run all nine checks strictly sequentially.

## Risks & Mitigations

- **Risk**: argument drift between `ci.yml` and `verify-all.sh` recurring in the future (a
  maintainer changes `ci.yml`'s invocation of one of the nine scripts without updating
  `verify-all.sh`). *Mitigation*: this is a known class of drift the codebase already guards
  against elsewhere via mechanical sync checks (e.g. `typst-sync-check.sh`); the plan phase
  should consider whether `verify-all.sh`'s own exact invocations can be asserted against
  `ci.yml`'s text mechanically, or whether a comment pointing each check at its `ci.yml` step
  name is a sufficient low-cost tripwire given this task's explicit out-of-scope boundary
  (not changing `ci.yml` itself). This is a forward-looking risk note, not a requirement to
  implement a sync checker now — out of scope per the dispatch.
- **Risk**: check 9's three-sub-check bundling is easy to under-implement (just calling
  `lake exe lint-style` and nothing else), which would silently narrow local coverage relative to
  CI. *Mitigation*: flagged explicitly above and in the Executive Summary; the implementation
  plan should treat this as a named requirement, not an incidental detail.
- **Risk**: a locally red `verify-all.sh` run with a stale `.lake` cache might disagree with a
  clean-runner CI result for reasons unrelated to the checks themselves (e.g. `warning-budget.py`
  / `check-module-invariants.sh`'s C28 is documented elsewhere as producing a spurious finding
  under a concurrent build). *Mitigation*: no action needed from this script — this is a
  pre-existing, documented limitation of the underlying checks themselves, not something
  `verify-all.sh` introduces or must solve, and the task's own VERIFICATION step (run against a
  clean tree) already avoids tripping it.

## Context Extension Recommendations

- **Topic**: local CI-parity tooling.
- **Gap**: `docs/development/CI_CD_PROCESS.md`'s "Wiring a New Check Script" section documents
  how to *add* a step to `ci.yml`, but has no pointer (once `verify-all.sh` exists) to the local
  aggregator that mirrors the resulting check list. A future task wiring a tenth CI check step
  would need to remember, unprompted, to also update `verify-all.sh`'s own check list and its
  `expected=9` count — nothing currently makes that omission loud the way the CI-side
  `Report results` step's own count assertion does.
- **Recommendation**: once `verify-all.sh` exists, consider a one-line addition to the "Wiring a
  New Check Script" section's rule list (a step 5 alongside naming/aggregating-gate/skip-convention/
  cache-placement) naming `scripts/verify-all.sh` as a second place a new check must be added,
  with the same loud-failure property if feasible (e.g. its own `expected` count). Left as a
  recommendation for a follow-up task rather than actioned here, since it is a `docs/` edit beyond
  this task's stated SCOPE of `scripts/verify-all.sh`, `CONTRIBUTING.md`, and `scripts/README.md`.

## Appendix

- Search queries / commands used: `cat .github/workflows/ci.yml`; `grep -n "## Wiring a New
  Check Script" docs/development/CI_CD_PROCESS.md`; `sed -n '214,320p'
  docs/development/CI_CD_PROCESS.md`; `head -20` on each of the seven shell check scripts;
  `grep -n "^set -\|exit [0-9]"` on `check-metalogic-cycles.sh`, `readme-lint.sh`,
  `check-copyright-headers.sh`; `grep -n "^##\|^###" CONTRIBUTING.md`; `grep -n "lint-style"
  lakefile.toml -B3 -A2`; `lake exe mk_all --help`; `grep -n "local aggregator\|verify-all\|ci.yml"
  specs/reviews/review-2026-11-19.md`.
- References: `.github/workflows/ci.yml`; `docs/development/CI_CD_PROCESS.md`;
  `scripts/README.md`; `CONTRIBUTING.md`; `scripts/check-evidence-probes.sh`;
  `scripts/check-module-invariants.sh`; `scripts/check-copyright-headers.sh`;
  `scripts/readme-lint.sh`; `scripts/check-metalogic-cycles.sh`; `scripts/typst-sync-check.sh`;
  `scripts/check-paper-definitions.sh`; `lakefile.toml`; `specs/reviews/review-2026-11-19.md`.
