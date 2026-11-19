# Implementation Plan: Task #941

- **Task**: 941 - Local aggregator that mirrors ci.yml's check gate
- **Status**: [IMPLEMENTING]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: specs/941_local_verify_all_ci_check_aggregator/reports/01_local-verify-all-aggregator.md
- **Artifacts**: plans/01_local-verify-all-aggregator.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Add `scripts/verify-all.sh`: a sequential local aggregator that runs the nine check
invocations `.github/workflows/ci.yml` runs, continues past every failure, and reports
per-check verdicts plus an aggregate `RESULT:` line with a nonzero exit on any failure —
reproducing CI's verdict before a push rather than after a ~30-minute run. Then document it
in `CONTRIBUTING.md`'s Development Setup block (next to the `install-git-hooks.sh`
instruction) and catalogue it in `scripts/README.md`. Done when the aggregator's per-check
verdicts match CI's for the same commit on a clean tree, a deliberately seeded single-check
failure is reported with a nonzero exit, and both documents reference the script.

### Research Integration

The research report re-derived the nine checks from the live `ci.yml` and found three
discrepancies against the dispatch's drafted list that this plan carries forward as
requirements, not details:

- Check 3 is `bash scripts/check-copyright-headers.sh --strict FormalSystem BimodalTools`
  and check 4 is `bash scripts/readme-lint.sh FormalSystem BimodalTools`. Both scripts
  default to `ROOTS=("FormalSystem")`, so a bare invocation silently drops `BimodalTools`
  from the local gate.
- Check 8 is `lake exe mk_all --lib FormalSystem --check`. The bare `--check` form errors on
  this package's two `srcDir = "Tests"` libraries.
- Check 9 is **three** sub-checks under one reported verdict: `lake exe lint-style`, then an
  executable-bit scan over `git ls-files -s -- '*.lean'`, then a case-insensitive
  tracked-path-collision scan over `git ls-files`. Implementing only the first is a silent
  parity gap.

All nine checks run strictly sequentially in CI, each child script acquiring and releasing
the shared `.lake/build-guard.lock` before the next starts, so a sequential caller introduces
no lock-contention hazard (confirmed against `scripts/README.md`'s "Per-script determinations"
table). `docs/development/CI_CD_PROCESS.md`'s "Wiring a New Check Script" section is the
design precedent for the reporting shape; the aggregator reuses `ci.yml`'s own `Report results`
shell rather than inventing a format.

Verified at plan-authoring time, beyond the report: the nine invocations above are byte-exact
against `.github/workflows/ci.yml` (lines 127-267); all 16 existing `scripts/*.sh` files are
tracked at mode `100755`, so the new script must be executable; `readme-lint.sh`'s roots are
`FormalSystem BimodalTools`, so `scripts/README.md` is outside its scope; and C13's markdown
link resolution covers `docs/` + `README.md` only, so neither `CONTRIBUTING.md` nor
`scripts/README.md` carries a link-resolution gate.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch; no roadmap consultation performed.

## Goals & Non-Goals

**Goals**:
- `scripts/verify-all.sh` runs all nine CI check invocations in `ci.yml`'s order, with
  `ci.yml`'s exact arguments, continuing past each failure.
- Reporting shape mirrors `ci.yml`'s `Report results` step: a per-check `PASS`/`SKIPPED`/`FAIL`
  status line, a reported-count assertion, a final `RESULT: ...` line in one of CI's three
  forms, and exit 1 iff any check failed.
- A future tenth CI check that is added to the script's invocation list but not to its report
  list fails loudly, via the same `expected` count assertion CI uses.
- `CONTRIBUTING.md` and `scripts/README.md` both reference the script, each in its own
  established style.

**Non-Goals**:
- Changing any of the nine checks themselves, or `.github/workflows/ci.yml`.
- Wiring the aggregator into the pre-commit hook (it contains slow, lake-dependent steps).
- Running `lake build` / `lake test` from inside the aggregator (see Decision 2).
- A mechanical `ci.yml`-to-`verify-all.sh` sync checker (out of scope; see Risks).
- Updating `docs/development/CI_CD_PROCESS.md` (the research report's own context-extension
  recommendation, explicitly left to a follow-up).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Check 9 under-implemented as `lake exe lint-style` alone, silently narrowing local coverage vs. CI | M | M | Named as a hard requirement in Phase 1's task list, with its own verification bullet; the seeded-failure test in Phase 3 seeds check 9's executable-bit sub-check specifically |
| Argument drift: `ci.yml` later changes one of the nine invocations without updating the aggregator | M | M | Each check in the script carries a comment naming its `ci.yml` step name and `id`, as a low-cost tripwire; a mechanical sync checker is out of scope and recorded as a follow-up candidate |
| `set -euo pipefail` aborting the script on the first failing check, defeating "report every failure" | H | M | Phase 1 explicitly guards each invocation (`rc=0; <cmd> \|\| rc=$?`) rather than relying on `set -e`; Phase 3's seeded-failure run confirms later checks still execute |
| Stale `.lake` cache making a local run disagree with CI for reasons unrelated to the checks (e.g. C28's documented concurrent-build sensitivity) | L | L | Pre-existing limitation of the underlying checks, not introduced here; Phase 3 verifies on a clean tree, which is where the task's own VERIFICATION step places it |
| Concurrent sibling task 943 editing the shared tree mid-phase (declared scope: `.gitignore`, `ORGANISATION.md`, `Challenge.lean`) | L | L | No scope overlap with this task's three files; still re-read each file immediately before editing, stage only this task's own paths, and never run `git-snapshot.sh` in its reverting default mode |

## Decisions

1. **Check 9's three sub-checks all run, even past a failure, under one reported verdict.**
   CI's single `run:` block uses `set -euo pipefail`, so a mid-step failure there stops the
   later sub-checks; running all three locally is strictly stricter, never laxer, and matches
   scope (A)'s "report every failure" intent at the sub-check level. Check 9 reports `FAIL` if
   any of the three fails, and the script prints which.
2. **The aggregator does not invoke `lake build` or `lake test`.** Scope (A) is the nine check
   steps; CI's build/test steps are separate hard stops above them, and the task's own PROBLEM
   framing assumes the contributor has already run them. The script documents the successful
   build as a precondition in its header and prints a one-line reminder before running, and
   `CONTRIBUTING.md`'s entry states the ordering. This is a planning judgment between two
   workable options, recorded here rather than escalated.
3. **`SKIPPED` is retained in the reporting vocabulary and made reachable.** CI's three-way
   classification exists because a GitHub step outcome can be `skipped`. Locally the useful
   analogue is a missing prerequisite binary: if `lake` is not on `PATH`, checks 8 and 9 report
   `SKIPPED`, not `FAIL`, which mirrors CI's "the three lake-dependent checks are correctly
   skipped when the build itself broke" semantics and keeps all three of CI's `RESULT:` line
   forms producible. Every other check maps exit 0 to `PASS` and any nonzero to `FAIL`.
4. **Documentation placement is one site per file, not both sites in `CONTRIBUTING.md`.** The
   dispatch says "next to the existing git-hook installation instructions", so the new line
   goes in the Development Setup fenced `bash` block after `bash scripts/install-git-hooks.sh`;
   the Verifying Setup block is left alone to avoid a duplicate instruction that would drift.
5. **`scripts/README.md` gets two rows, not one.** A "Gates and ratchets" row (the functionally
   closest existing category for a gate aggregator) and a `No lock` row in the
   "Per-script determinations" table under "Shared `.lake` build lock", because the file's own
   opening sentence asserts that every script under `scripts/` is named below and that table is
   part of how scripts there are catalogued.
6. **`check-paper-definitions.sh`'s `SKIP (neutral): ...` output is reported as `PASS`.** It is
   a script-internal exit-0 message, not a skipped step; CI's own step `outcome` is `success`
   either way.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Write scripts/verify-all.sh [COMPLETED]

**Goal**: A working, executable `scripts/verify-all.sh` that runs all nine CI check
invocations in order, continues past every failure, and reports in `ci.yml`'s `Report results`
shape with a nonzero exit on any failure.

**Tasks**:
- [x] Re-derive the nine invocations from `.github/workflows/ci.yml` before writing anything,
      confirming the Research Integration list above still matches the live file (it is a
      hypothesis as of plan-authoring time, not a fact at implementation time). *(completed:
      re-read lines 100-365 of the live workflow; the Research Integration list matched
      exactly, no discrepancies)*
- [x] Create `scripts/verify-all.sh` with a `#!/usr/bin/env bash` shebang and a header comment
      block in the house style of the other `scripts/*.sh` files: purpose, usage, the
      successful-`lake build` precondition (Decision 2), exit-code contract, and a pointer to
      `.github/workflows/ci.yml` as the source of record for the check list. *(completed)*
- [x] Use `set -uo pipefail` (deliberately **not** `-e`) so a failing check cannot abort the
      run; guard every check invocation as `rc=0; <invocation> || rc=$?` and feed `rc` to the
      reporter. *(completed)*
- [x] Port `ci.yml`'s `report()` function: `seen`/`passed`/`failed`/`skipped` counters,
      `expected=9`, and the three-way classification (exit 0 -> `PASS`; the explicit
      not-run marker -> `SKIPPED`; anything else -> `FAIL`), printing `  PASS     <label>` /
      `  SKIPPED  <label>` / `  FAIL     <label> (exit: N)`. *(completed)*
- [x] Invoke the nine checks in `ci.yml`'s order, each preceded by a comment naming its
      `ci.yml` step name and step `id` (drift tripwire, per Risks): (1)
      `bash scripts/check-evidence-probes.sh`; (2)
      `bash scripts/check-module-invariants.sh --no-build`; (3)
      `bash scripts/check-copyright-headers.sh --strict FormalSystem BimodalTools`; (4)
      `bash scripts/readme-lint.sh FormalSystem BimodalTools`; (5)
      `bash scripts/check-metalogic-cycles.sh`; (6) `bash scripts/typst-sync-check.sh`; (7)
      `bash scripts/check-paper-definitions.sh`; (8)
      `lake exe mk_all --lib FormalSystem --check`; (9) the three-part lint-style check below.
      *(completed)*
- [x] Implement check 9 as three sub-checks run unconditionally in `ci.yml`'s order, with one
      combined verdict (Decision 1): `lake exe lint-style`; then
      `git ls-files -s -- '*.lean' | awk '$1 == "100755" { print $4 }'` must be empty; then
      `git ls-files | tr '[:upper:]' '[:lower:]' | sort | uniq -d` must be empty. Print each
      sub-check's own failure detail, and report check 9 `FAIL` if any failed. *(completed)*
- [x] Apply Decision 3's `SKIPPED` path: if `command -v lake` fails, mark checks 8 and 9
      `SKIPPED` without invoking them. *(completed)*
- [x] Reproduce `ci.yml`'s terminal block verbatim in shape: the `seen -ne expected`
      out-of-sync error and exit 1; `RESULT: FAIL (N failed, M passed, K skipped)` and exit 1
      when `failed > 0`; `RESULT: PASS for all N checks that ran, but K were skipped` and
      exit 0 when `skipped > 0`; otherwise
      `RESULT: PASS (all N checks ran and passed)` and exit 0. Use plain stderr/stdout text,
      not `::error::`/`::group::` GitHub Actions annotations. *(completed)*
- [x] `chmod +x scripts/verify-all.sh` so it is tracked at mode `100755`, matching all 16
      existing `scripts/*.sh` files. *(completed)*

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts nine checks comprising eleven distinct invocations
(the seven `bash scripts/*.sh` calls, `lake exe mk_all --lib FormalSystem --check`, and check
9's three sub-checks), and exactly one new file. Confirm at implementation time by re-reading
`.github/workflows/ci.yml` and counting its `report` lines (`expected=9`) against its check
steps before writing the invocation list; if the live file disagrees with this count, the live
file wins and the script's `expected` is set from it.

**Tier Justification**: `bash .claude/scripts/verify-touched.sh scripts/verify-all.sh` is the
covering check — its selector maps this deploy-consumer path to no suite, so the real coverage
is `bash -n scripts/verify-all.sh` plus an actual run of the script, both of which exercise
the whole single-file deliverable with no other file depending on it yet.

**Files to modify**:
- `scripts/verify-all.sh` - new file; the nine-check sequential aggregator, mode 100755

**Verification**:
- `bash -n scripts/verify-all.sh` parses cleanly.
- `git ls-files -s -- scripts/verify-all.sh` shows mode `100755`.
- `bash scripts/verify-all.sh` runs to completion, printing nine status lines and one
  `RESULT:` line; the run does not abort early even if a check fails.
- `grep -c 'report ' scripts/verify-all.sh` equals the script's own `expected` value.
- Every one of check 9's three sub-checks is present in the script (grep for `lint-style`,
  `100755`, and `uniq -d`).

---

### Phase 2: Document the aggregator in CONTRIBUTING.md and scripts/README.md [COMPLETED]

**Goal**: Both documents reference `scripts/verify-all.sh` in their own established style, so
a contributor finds it where they already look for setup and script information.

**Tasks**:
- [x] Re-read `CONTRIBUTING.md`'s Development Setup section immediately before editing (shared
      tree; sibling task 943 is dispatched this same cycle). *(completed: re-read immediately
      before editing, unchanged from plan-authoring time)*
- [x] Add to the Development Setup fenced `bash` block, after the
      `bash scripts/install-git-hooks.sh` line (Decision 4): a short comment block in the
      style of the adjacent git-hook comment, stating that the script reproduces CI's nine-check
      gate locally, that a successful `lake build` / `lake test` is its precondition
      (Decision 2), and that it is deliberately not wired into the pre-commit hook because it
      contains slow lake-dependent steps; then the `bash scripts/verify-all.sh` line itself.
      *(completed)*
- [x] Re-read `scripts/README.md` immediately before editing. *(completed: unchanged from
      plan-authoring time)*
- [x] Add one `| \`verify-all.sh\` | ... |` row to the "Gates and ratchets" table, matching the
      one-sentence-purpose style of the rows already there and naming
      `.github/workflows/ci.yml` as its source of record. *(completed)*
- [x] Add one row to the "Per-script determinations" table under "Shared `.lake` build lock"
      with determination `No lock` (Decision 5): the aggregator takes no lock of its own; each
      child script acquires and releases the shared lock on its own, and all nine run strictly
      sequentially. *(completed)*
- [x] Confirm `scripts/README.md`'s opening completeness claim ("Every script ... is named
      below; nothing in this directory is undocumented") now holds for the new file.
      *(completed: verify-all.sh is now named in the Gates and ratchets table)*

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts exactly two files edited and exactly three insertion
sites (one `CONTRIBUTING.md` block, two `scripts/README.md` table rows). Confirm by
`git diff --stat` showing only those two paths, and by re-reading both tables to check no
existing row was displaced.

**Tier Justification**: `bash .claude/scripts/verify-touched.sh CONTRIBUTING.md scripts/README.md`
is the covering check, together with the `prose` row's diff read-through — both edits are
markdown prose and table rows with zero compile or elaboration surface, and neither file is in
scope for `readme-lint.sh` (roots `FormalSystem BimodalTools`) or C13 (`docs/` + `README.md`).

**Files to modify**:
- `CONTRIBUTING.md` - exists (verified at plan-authoring time: Development Setup block at lines 18-43, ending in the `install-git-hooks.sh` line); add the aggregator line and its comment block. If that block has moved or been restructured by implementation time, place the line next to whatever the git-hook installation instruction has become rather than recreating the old shape
- `scripts/README.md` - exists (verified at plan-authoring time: "Gates and ratchets" table at line 7, "Per-script determinations" table at line 100); add one row to each. If either table is absent by implementation time, add the entry to whichever table then catalogues gates, and say so in the summary

**Verification**:
- `grep -n 'verify-all.sh' CONTRIBUTING.md scripts/README.md` returns at least one hit in each
  file.
- The new `CONTRIBUTING.md` line sits inside the Development Setup fenced block, immediately
  after the `install-git-hooks.sh` line, and the Verifying Setup block is unchanged.
- Both `scripts/README.md` tables still render as valid markdown tables (column counts match
  their headers).
- `git diff --stat` touches only these two paths.

---

### Phase 3: Verify CI parity, seeded-failure behavior, and cross-references [NOT STARTED]

**Goal**: Discharge the task's own VERIFICATION contract: the aggregator's per-check verdicts
match what CI reports for the same commit, a seeded single-check failure is reported with a
nonzero exit while later checks still run, and the script is referenced from both documents.

**Tasks**:
- [ ] Run `bash scripts/verify-all.sh` on the current tree, capturing full output to the
      scratchpad, and record the nine per-check verdicts and the `RESULT:` line.
- [ ] Compare those nine verdicts against CI's own `Report results` output for the same commit
      (the most recent CI run on this commit, via `gh run view` if available, else the recorded
      expectation that all nine pass on a clean tree). Any disagreement is a finding: record it
      via `issue-record.sh` and state it in the summary rather than adjusting the script to
      agree.
- [ ] Seed a failure in exactly one check and confirm the script reports it, continues through
      the remaining checks, and exits nonzero. Use check 9's executable-bit sub-check
      (`chmod +x` one tracked `.lean` file) because it is instantaneous, needs no rebuild, and
      exercises the sub-check most at risk of being under-implemented.
- [ ] Revert the seed by restoring the file's mode directly (`chmod -x <path>`) and confirm
      `git status --short` is clean for that path. Do **not** use `git checkout --`/`git
      restore`: `guard-destructive-git.sh` blocks the pathspec-discard form on a dirty tree,
      and this tree is shared with a concurrently dispatched sibling task.
- [ ] Re-run `bash scripts/verify-all.sh` after the revert and confirm the verdicts return to
      the clean-tree baseline recorded in the first task.
- [ ] Confirm the cross-references: `grep -n 'verify-all.sh' CONTRIBUTING.md scripts/README.md`.
- [ ] Record at least one `issue-record.sh` entry for this phase (issue or win), or state
      explicitly in the handoff that nothing arose.

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts that its ONE deliberate seed (a mode change on a
single tracked `.lean` file) is fully reverted within the phase, leaving no `.lean` mode change
behind; it does NOT assert that no repository file changes, since a parity gap or a
continue-past-failure defect found here is fixed in `scripts/verify-all.sh` within this same
phase. Confirm with `git status --short` after the revert, showing no stray mode change on any
`.lean` file.

**Files to modify**:
- `scripts/verify-all.sh` - only if a parity gap or a continue-past-failure defect is found; otherwise unchanged
- `specs/941_local_verify_all_ci_check_aggregator/summaries/01_local-verify-all-aggregator-summary.md` - new; the completion summary

**Verification**:
- `bash .claude/scripts/verify-touched.sh scripts/verify-all.sh CONTRIBUTING.md scripts/README.md`
  runs green over this task's touched paths — this phase's own in-dispatch obligation.
- The complete gate set for the repository is **deferred to the orchestration close** (the
  once-per-invocation batch gate stage), not invoked independently here, per
  `plan-format.md`'s batch-aware deferral directive for a `full` phase under `/orchestrate`.
- Captured output shows nine per-check verdicts and one `RESULT:` line on the clean-tree run.
- The seeded run shows exactly one `FAIL` line, all nine checks still reported, and a nonzero
  exit code (`echo $?`).
- `git status --short` shows no residual mode change after the revert.

## Testing & Validation

- [ ] `bash -n scripts/verify-all.sh` parses.
- [ ] Clean-tree run reports nine checks and exits 0 (or reports pre-existing failures that CI
      also reports for the same commit — a disagreement is recorded, not silently absorbed).
- [ ] Seeded single-check failure: reported, later checks still run, exit code nonzero.
- [ ] Seed reverted; `git status --short` clean for the seeded path.
- [ ] Check 9's three sub-checks are all present and all run.
- [ ] `expected` in the script equals its own `report` call count, and the out-of-sync branch is
      reachable (temporarily bump `expected` by one and confirm the error fires, then revert).
- [ ] `verify-all.sh` referenced from both `CONTRIBUTING.md` and `scripts/README.md`.
- [ ] `scripts/verify-all.sh` tracked at mode `100755`.

## Artifacts & Outputs

- `scripts/verify-all.sh` (new, mode 100755)
- `CONTRIBUTING.md` (Development Setup block extended)
- `scripts/README.md` (one "Gates and ratchets" row, one "Per-script determinations" row)
- `specs/941_local_verify_all_ci_check_aggregator/summaries/01_local-verify-all-aggregator-summary.md`
- `specs/941_local_verify_all_ci_check_aggregator/issues.jsonl` (issue/win entries as they arise)

## Rollback/Contingency

Each phase commits its own files, so reverting is a scoped revert of that phase's commit —
`scripts/verify-all.sh` is a new file with no importers, and the two documentation edits are
additive, so removing them restores the prior text exactly.

If a rollback of *uncommitted* work is genuinely needed, follow
`context/contracts/recovery.md`'s rollback rung for the snapshot-then-rollback invocation shape,
including its out-of-scope override flag; never a bare precautionary `git-snapshot.sh 941`, and
never a reverting snapshot while sibling task 943 has uncommitted work on this shared tree. The
Phase 3 seed revert is deliberately a direct `chmod -x`, not a git discard, for exactly this
reason.

Contingency if CI parity cannot be established (e.g. no CI run exists for the current commit):
record the gap, keep the aggregator and both documentation entries (they stand on their own),
and state in the summary that per-check parity was verified against `ci.yml`'s text rather than
against an observed CI run.
