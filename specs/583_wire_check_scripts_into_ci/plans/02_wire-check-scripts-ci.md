# Implementation Plan: Task #583

- **Task**: 583 - Wire the check scripts that are green today into `.github/workflows/ci.yml`, and establish the per-script wiring pattern every later check follows
- **Status**: [COMPLETED]
- **Effort**: 3.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/583_wire_check_scripts_into_ci/reports/02_wire-check-scripts-ci.md (primary); specs/583_wire_check_scripts_into_ci/reports/01_uncalled-check-scripts.md (pre-rescope sweep, background)
- **Artifacts**: plans/02_wire-check-scripts-ci.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Add three named `run:` steps to `.github/workflows/ci.yml`, placed after the existing
"Compile lean_exe roots" step and before "Report results":
`scripts/check-module-invariants.sh --no-build`,
`scripts/check-copyright-headers.sh --strict --exclude '*/Boneyard/*' FormalSystem`, and
`scripts/readme-lint.sh`. Record the per-script wiring pattern (step naming, skip-and-report-neutral,
cache-warm placement, runtime budget) as a new section of `docs/development/CI_CD_PROCESS.md`,
with a short pointer from the workflow's header comment. Then prove each wired step fails, under
its own step name, on a deliberate violation, and record the measured wall-clock delta.

### Research Integration

- All three scripts were re-run green in round 2 of research: invariants `--no-build` 20.9s,
  invariants full ~2m11s warm, copyright strict 11.5s (520/520), readme-lint 7.1s.
- The existing lean_exe step is the template to copy: a named step, `set -euo pipefail`, and
  `::group::`/`::endgroup::` wrapping.
- The bare copyright invocation exits 0 no matter what, so only the strict live-set form is valid.
- `readme-lint.sh` gates only Checks 1 and 3. Checks 2 and 4 (91 NOT-LISTED entries, 3
  stale or missing dates) are informational only and must be documented so nobody mistakes them
  for failures.
- `check-paper-definitions.sh` currently exits 2 when its input is missing. That is a failure,
  not a neutral skip, so the recorded skip-neutral convention must say what 584's final phase
  has to change.
- The CI_CD_PROCESS.md "CI Steps Explained" section covers only the lean-action steps. The
  lean_exe step is undocumented there, so the new section is the natural home for the pattern.

Planning-time additions (checked in this dispatch):
- The three scripts need only `bash`, `find`, `awk`, `git`, `jq`, `python3` with stdlib-only
  imports (`os`, `re`, `sys`, plus the repo-local `scripts/lib/live_walk`), and `lake`/`lean`.
  None needs `rg` or a pip package. `ubuntu-latest` ships everything outside the Lean
  toolchain, and `lean-action` installs the toolchain onto PATH.
- `readme-lint.sh` Check 4 calls `git log -1 -- "$dir"`. Under `actions/checkout@v4`'s
  default `fetch-depth: 1`, every directory gets the same single commit date. Check 4 is
  informational, so this cannot fail CI, but its CI output will differ from a local run. This
  is documented, not fixed (see Decisions).

### Decisions

- **Invariants invocation: `--no-build`.** The task description allows either the full run or
  `--no-build`, and its runtime framing ("total under a minute") only holds for `--no-build`.
  The full run adds about 2 minutes, and it largely repeats checks CI already runs: C1 repeats
  the lean-action build, most of C16 repeats lean-action lint, and C25 repeats the lean_exe
  step. The coverage given up is C2 (axiom-baseline drift), C6 (unreachable modules), and C24
  (transitive `Init` import). CI_CD_PROCESS.md will list these three as known not-in-CI gaps,
  which is the upgrade path if a later task decides the ~2 minutes is worth it. This choice can
  be reversed with a one-line edit, so it needs no user decision.
- **Shallow clone kept.** The workflow will not set `fetch-depth: 0` just to make an
  informational check's dates accurate. The cost is documented instead.
- **Remote CI confirmation belongs to the user.** Per `.claude/rules/pr-prohibition.md`, the
  implementer must not push. The task's Verify criterion needs a real CI run: a violation branch
  fails under a named step, a clean run is green, and the CI wall-clock delta is measured. Phase
  4 therefore verifies locally by running the exact `run:` bodies taken from the edited YAML,
  and hands the user a scripted remote-confirmation checklist. The measured local delta is
  recorded now, and the Actions-measured delta is left as a labeled slot for the user to fill.

### Prior Plan Reference

No prior plan. (Round 1 produced a report only; the task was rescoped before any plan was written.)

### Roadmap Alignment

No roadmap consulted (no `roadmap_path` in this dispatch).

## Goals & Non-Goals

**Goals**:
- `ci.yml` runs the three scripts as separate steps, each with a `name:` that identifies its script.
- A short wiring-pattern convention exists in `docs/development/CI_CD_PROCESS.md`, and the
  workflow header comment points to it.
- Line 48's prose comment about `check-module-invariants.sh` is replaced with a reference to the
  new step.
- A deliberate violation of each wired check is shown to fail that step with a nonzero exit
  code. A clean tree passes all three. The runtime delta is measured and recorded.

**Non-Goals**:
- Wiring `check-evidence-probes.sh` (owned by 581), `check-metalogic-cycles.sh` (582),
  `check-paper-definitions.sh` (584), or `typst-sync-check.sh` (586).
- Flipping `ENFORCE_C9_DOCS=1` (590) or adding the compiler-warning gate (585).
- Changing any check script's behavior, including making `check-paper-definitions.sh`
  skip-neutral.
- Pushing branches or opening PRs (the user does this).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A script passes locally but fails on the runner (missing tool, locale, or path assumption) | H | L | Phase 1 enumerates tool dependencies. Phase 4 runs the extracted step bodies under `env -i` with a minimal PATH (the Lean toolchain plus system bins) to approximate the runner. The user's remote confirmation is the final check. |
| A script turns red between research and implementation because of concurrent work on main | M | M | Phase 1 re-runs all three before anything is wired. If one is red, stop, wire only the green ones, and record the red one as a blocker instead of wiring a failing step. |
| Invariants `--no-build` needs artifacts that exist only locally | M | L | Placement after lean-action and the lean_exe step means the Lake cache is warm. Phase 4's minimal-env run exercises this. |
| readme-lint's informational noise (91 NOT-LISTED entries, dates distorted by the shallow clone) is read as a failure | L | M | CI_CD_PROCESS.md states that Checks 2 and 4 are informational only, and explains the shallow-clone date effect. |
| Concurrent edits to `ci.yml` by 581/582/585/586/590 | M | M | Keep this change to a contiguous block of new steps plus one comment edit. The recorded pattern tells later tasks to append their step directly before "Report results". |
| A deliberate-violation edit leaks into a commit | H | L | Phase 4 makes each violation in a scratch copy or reverts it immediately with a targeted `git diff --quiet -- <file>` check, and never stages violation files. |
| The wall-clock delta measured locally differs from GitHub runners | L | H | Record the local figure labeled as local. Leave a labeled "Actions-measured" slot for the user's confirmation run. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Re-verify green status and runner prerequisites [COMPLETED]

**Goal**: Confirm, on the current tree, that all three scripts exit 0 in their exact CI form,
and that nothing they need is missing from `ubuntu-latest` plus lean-action.

**Tasks**:
- [x] Run `lake build` (warm the cache), then time each exact command:
  `bash scripts/check-module-invariants.sh --no-build`;
  `bash scripts/check-copyright-headers.sh --strict --exclude '*/Boneyard/*' FormalSystem`;
  `bash scripts/readme-lint.sh`. Record the exit code and `real` time for each. *(completed:
  lake build success; invariants 0/23.6s after a transient first-run FAIL, copyright 0/10.98s,
  readme-lint 0/7.34s)*
- [x] Grep the three scripts, and any `scripts/lib/` helper they source or import, for external
  commands and Python imports. Confirm there is no non-stdlib Python and no tool missing from
  `ubuntu-latest`. *(completed: bash/find/awk/git/jq/python3/lake/lean only; sole sourced
  helper scripts/lib/live_walk.py imports stdlib `os` only)*
- [x] If any script is red, stop wiring that script, record the failure output in the phase
  notes, and continue with the green ones only. *(completed: not triggered -- the one FAIL
  observed was a transient race with concurrent tasks 581/582/587 editing FormalSystem/Metalogic/**
  at that instant; a re-run 5s later was clean)*

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: All three scripts are still green (research measured them green on
2026-09-16). Confirm by the exit codes from this phase. The dependency list (bash, find, awk,
git, jq, python3 stdlib, lake/lean) is the planning-time grep result. Confirm by re-grepping,
including sourced helpers under `scripts/lib/`.

**Files to modify**:
- None (verification only; results go in the phase notes and feed Phases 3 and 4)

**Verification**:
- Three exit codes of 0 recorded with timings; dependency list recorded.

---

### Phase 2: Wire the three steps into ci.yml [COMPLETED]

**Goal**: Add the three check steps using the existing lean_exe step's conventions, and make
the workflow's comments agree with what it runs.

**Tasks**:
- [x] After "Compile lean_exe roots (outside the library closures)" and before "Report
  results", add three steps, in this order:
  - `name: Check module invariants (scripts/check-module-invariants.sh --no-build)`
  - `name: Check copyright headers (scripts/check-copyright-headers.sh --strict)`
  - `name: Check README health (scripts/readme-lint.sh)`

  Each body is `set -euo pipefail`, then `echo "::group::<script>"`, then the exact command,
  then `echo "::endgroup::"`. *(completed: placed directly before "Report results"; tasks
  581/582 had already committed their own steps -- check-evidence-probes.sh and
  check-metalogic-cycles.sh -- in that same slot, so the three new steps land after those two,
  still before "Report results", matching the recorded append-before-Report-results
  convention)*
- [x] Put the script path inside each step `name:`, so the Actions UI identifies the script
  without opening the log. This is the Verify criterion's "failing step names the script".
  *(completed)*
- [x] Replace the sentence at current lines 47-48 ("The local counterpart is invariant C25
  ... at run time") with a line saying C25 is the full-mode counterpart, while CI runs the
  structural (`--no-build`) pass in the "Check module invariants" step below. *(completed)*
- [x] Add a short comment above the first new step, or at the top of the file, that points
  to `docs/development/CI_CD_PROCESS.md`'s wiring-pattern section and says new checks go
  directly before "Report results". *(completed: added at the top of the file, above `name:
  CI`)*
- [x] Leave "Report results" as the last step. Do not change `if: always()` or the lean-action
  outputs. *(completed: unchanged)*

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: interface

**Files to modify**:
- `.github/workflows/ci.yml` - three new steps, one comment rewritten, one pointer comment added

**Verification**:
- `python3 -c "import yaml,sys; yaml.safe_load(open('.github/workflows/ci.yml'))"` succeeds. If
  PyYAML is absent, use `nix run nixpkgs#yq-go -- e '.' .github/workflows/ci.yml` or any YAML
  parser that is available.
- The step order parsed from the YAML is: checkout, lean-action, lean_exe, invariants,
  copyright, readme, report.
- `git diff .github/workflows/ci.yml` shows no change to existing steps other than the
  intended comment edit.
- No task-number references are added (`.claude/rules/no-task-references-in-deliverables.md`).

---

### Phase 3: Record the per-script wiring pattern in CI_CD_PROCESS.md [COMPLETED]

**Goal**: Write the convention every later CI-wiring phase follows, in the doc that already
holds CI step explanations and the runtime budget.

**Tasks**:
- [x] Under "CI Steps Explained", add a subsection for the existing "Compile lean_exe roots"
  step, which is currently undocumented, plus one subsection per new check step. Each subsection
  gives the step name, the exact command, what it gates, and how to run it locally. *(completed)*
- [x] Add a "Wiring a New Check Script" section with four parts:
  1. **Step naming**: the step `name:` contains the script path, and the body uses
     `set -euo pipefail` with `::group::` around the command.
  2. **Skip-and-report-neutral**: when a check's input may be absent in CI (for example an
     external paper), the step or script detects that case explicitly, prints a line starting
     `SKIP (neutral): <reason>`, and exits 0. A missing input must never be reported as a
     failure, and a present-but-wrong input must never be skipped. The section notes that
     `check-paper-definitions.sh` currently exits 2 when its input is missing, so it must adopt
     this convention before it is wired.
  3. **Cache-warm placement**: any check that calls `lake`/`lean` goes after the lean-action
     step and after the lean_exe step. New steps are appended directly before "Report
     results".
  4. **Runtime budget**: a table of per-step wall-clock times (filled in Phase 4), plus the
     rule that a task wiring a new step updates the table in the same change. *(completed:
     table populated now with Phase 1's local measurements rather than deferred to Phase 4,
     since those numbers were already in hand; Phase 4 re-derives timings from the extracted
     step bodies and will reconcile/update this same table rather than adding a second one --
     deviation noted in the progress file)*
- [x] Document the known gaps: C2, C6, and C24 are not run in CI because of `--no-build`, and
  the doc gives the one-line upgrade path. Also document that readme-lint Checks 2 and 4 are
  informational only, and that the shallow clone distorts Check 4's dates. *(completed)*
- [x] Update the "Pipeline Summary" and "Running CI Locally" sections to list the three
  commands. *(completed)*

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: prose

**Files to modify**:
- `docs/development/CI_CD_PROCESS.md` - new step subsections, wiring-pattern section, gaps note,
  updated summary and local-run commands

**Verification**:
- Read the diff: every command string matches `ci.yml` exactly (step names and flags).
- Every relative link in the changed sections resolves. `bash scripts/readme-lint.sh` still
  passes, and the invariants `--no-build` run passes, because C10 checks doc paths.
- No task-number references.

---

### Phase 4: Deliberate-violation verification, runtime measurement, and handoff [COMPLETED]

**Goal**: Show that each wired step fails on a violation and passes on a clean tree, record the
measured delta, and give the user an exact remote-confirmation checklist.

**Tasks**:
- [x] Extract each new step's `run:` body from the edited `ci.yml` with a YAML parser. Do not
  retype it. Write the bodies to scratch scripts. *(completed: via `python3 -c "import yaml..."`,
  written to scratch as invariants.sh/copyright.sh/readme.sh)*
- [x] Clean run: execute the three extracted bodies in order on the clean tree under
  `env -i HOME="$HOME" PATH="$HOME/.elan/bin:/usr/bin:/bin:$(dirname "$(command -v python3)"):$(dirname "$(command -v jq)")"`.
  Every body must exit 0. Time each one with `/usr/bin/time` or `date +%s.%N` deltas. *(completed
  with a deviation: this dev machine is NixOS, not the Ubuntu-shaped `/usr/bin:/bin` the
  template assumes -- `command -v` was used per-tool instead to build the minimal PATH
  (lake/bash/git/jq/python3 dirs). All three bodies exited 0: invariants 20.3s, copyright 4.5s,
  readme-lint 4.7s)*
- [x] Violation runs, one at a time. Revert after each and confirm with
  `git diff --quiet -- <file>`:
  - Invariants: introduce a violation of a `--no-build` structural invariant, such as a
    task-number citation in a `FormalSystem/` comment (C9) or a stale `docs/` path. The
    invariants body must exit nonzero and print that check's failure. The write-time
    `validate-no-task-references.sh` hook may block a C9 violation made with Write or Edit. In
    that case, apply it with a shell `sed` on a scratch edit, or use the C10 stale-path
    violation instead. *(completed: used the C10 stale-path violation, exactly the documented
    fallback -- added a `FormalSystem/docs/old-path.md` reference to root README.md, confirmed
    FAIL on C10 (and C12) with exit 1, reverted from backup, confirmed
    `git diff --quiet -- README.md`)*
  - Copyright: strip the header from one live `FormalSystem/**/*.lean` file (not under
    Boneyard). The copyright body must exit nonzero. *(completed: stripped the header from
    `FormalSystem/Syntax/SubformulaClosure.lean`, confirmed exit 1 (missing: 1), reverted from
    backup, confirmed `git diff --quiet`)*
  - readme-lint: add a broken relative link to one `FormalSystem/**/README.md` (Check 3). The
    readme body must exit nonzero. *(completed: added a broken link to
    `FormalSystem/Syntax/README.md`, confirmed Check 3 FAIL with exit 1, reverted from backup,
    confirmed `git diff --quiet`)*
- [x] After all reverts, confirm `git status --short` shows only the intended ci.yml and
  CI_CD_PROCESS.md changes, then re-run the clean pass once more. *(completed: `git status
  --short` showed none of the three violation files dirty (only concurrent tasks'
  files and this plan file); re-ran all three extracted bodies once more, all exit 0)*
- [x] Fill Phase 3's runtime-budget table with local figures labeled "local, warm cache", plus
  their sum as the added delta. Add an empty "Actions-measured" column for the user.
  *(completed: added a second "Local, minimal env (extracted body)" column alongside Phase 3's
  full-env column rather than replacing it, since both measurements are informative; Actions-
  measured column left pending for the user)*
- [x] In the implementation summary, give the user a remote-confirmation checklist. For each
  check, push a branch carrying that check's violation and confirm that the step named after
  the script fails. Push a clean branch and confirm the run is green. Compare the job duration
  with a recent main run, and fill in the Actions-measured column. *(completed: see
  summaries/02_wire-check-scripts-ci-summary.md's "Follow-ups" section)*

**Timing**: 1.25 hours

**Depends on**: 2, 3

**Verification Tier**: full

**Scope Hypothesis**: Each of the three violations above trips its gate. C9 enforcement is on
by default (`ENFORCE_C9=1`) and runs under `--no-build`, and copyright Check 1 and readme
Check 3 are the gated checks. Confirm by observing a nonzero exit from each extracted body. If
a chosen violation does not trip its gate, pick another gated check from that script's header
instead of weakening the criterion.

**Files to modify**:
- `docs/development/CI_CD_PROCESS.md` - fill the runtime-budget figures
- (temporary, reverted, never committed) one FormalSystem `.lean` file and one README for the
  violations

**Verification**:
- Clean pass: 3 of 3 bodies exit 0. Violation pass: 3 of 3 bodies exit nonzero, each under the
  step whose name contains the script path.
- `git status --short` is clean apart from the two deliverable files.
- Full final gate before closing: `lake build` plus the full `bash scripts/check-module-invariants.sh`
  (not `--no-build`) both green.

## Testing & Validation

- [x] `ci.yml` parses as YAML, and the step order is lean-action, then lean_exe, then the three
  checks, then Report results. *(completed: order is lean-action, lean_exe,
  check-evidence-probes.sh, the three new checks, check-metalogic-cycles.sh, Report results --
  the two concurrently-wired steps sit between lean_exe and the three checks / after them, per
  the append-before-Report-results convention)*
- [x] Each new step `name:` contains its script path. *(completed)*
- [x] The three extracted step bodies exit 0 on a clean tree in a minimal environment.
  *(completed: 20.3s / 4.5s / 4.7s, all exit 0)*
- [x] Each extracted step body exits nonzero on its deliberate violation, and every violation is
  reverted. *(completed)*
- [x] CI_CD_PROCESS.md documents all four wiring-pattern parts, the C2/C6/C24 gap, readme-lint's
  informational checks, and the measured runtime delta. *(completed)*
- [x] Full gate: `lake build` and the full `scripts/check-module-invariants.sh` are green.
  *(completed: lake build 2653 jobs success; full invariants ALL CHECKS PASSED, 2m14s)*
- [ ] (User, remote) A violation branch fails the named step, a clean branch is green, and the
  Actions wall-clock delta is recorded. *(deferred to user -- see summary's Follow-ups)*

## Artifacts & Outputs

- `.github/workflows/ci.yml` (modified)
- `docs/development/CI_CD_PROCESS.md` (modified)
- `specs/583_wire_check_scripts_into_ci/summaries/02_wire-check-scripts-ci-summary.md` (with the
  remote-confirmation checklist)

## Rollback/Contingency

All changes sit in two files. To roll back, revert the task's commits
(`git revert <sha>`), or delete the three step blocks from `ci.yml`. If one script turns out to
be red on the runner once the user pushes, remove only that step, or add
`continue-on-error: true` to it with a comment naming the blocker. Record this in
CI_CD_PROCESS.md's gaps list rather than leaving CI red. The other two steps stay wired.
