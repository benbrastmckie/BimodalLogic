# Implementation Plan: Fix Failing CI Badge

- **Task**: 160 - Fix failing CI badge in README.md
- **Status**: [NOT STARTED]
- **Effort**: 0.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/160_fix_ci_badge_failing/reports/01_ci-badge-research.md
- **Artifacts**: plans/01_fix-ci-badge.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

The CI badge on README.md line 3 shows "failing" due to three compounding issues: (1) `test: true` in `ci.yml` but no `testDriver` in `lakefile.lean`, causing every run to fail with "could not find a test runner"; (2) `build-args: "--wfail"` causing `lake build` to fail on the 95+ `sorry` warnings inherent to this in-progress formalization; and (3) a conditional skip on push-to-main that keeps the badge showing the last failed PR run. The fix requires adding the test driver declaration, removing the `--wfail` flag, and pushing with `[ci]` in the commit message to trigger a passing run.

### Research Integration

Research report `01_ci-badge-research.md` confirmed all three root causes via CI run history analysis (`gh run view`), SVG badge fetch, lean-action documentation review, and Mathlib CI best practices. The report verified that `BimodalTest` lean_lib already exists at line 23 of `lakefile.lean` and is the correct target for `testDriver`. Task 158 file deletions were ruled out as a contributing factor.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md items are directly advanced by this task. This is an infrastructure/maintenance fix to restore CI health.

## Goals & Non-Goals

**Goals**:
- Fix the `lake check-test` failure by wiring `BimodalTest` as the test driver
- Remove the `--wfail` flag so `sorry`-containing builds succeed in CI
- Trigger a passing CI run on main to update the badge from "failing" to "passing"

**Non-Goals**:
- Eliminating `sorry` statements from the codebase (ongoing formalization work)
- Changing the CI trigger/skip logic beyond what is needed for the badge fix
- Updating `actions/checkout` for Node.js 24 compatibility (separate future task)
- Adding concurrency controls or cron-based CI triggers

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `BimodalTest` files have compilation errors that cause `lake test` to fail | H | L | Run `lake build BimodalTest` locally before pushing |
| CI run takes 20-40 minutes for full Mathlib cache + build | L | H | Expected behavior; no mitigation needed, just patience |
| Badge does not update after passing run | M | L | Verify via `gh run list` and badge SVG curl; GitHub caches badges briefly |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Fix lakefile.lean and ci.yml [NOT STARTED]

**Goal**: Make the CI workflow capable of passing by fixing both the missing test driver and the incompatible build flag.

**Tasks**:
- [ ] Add `testDriver := "BimodalTest"` to the `package Logos` block in `lakefile.lean` (after line 4)
- [ ] Remove or clear `build-args: "--wfail"` from `.github/workflows/ci.yml` (line 35)
- [ ] Run `lake build BimodalTest` locally to verify the test target compiles

**Timing**: 15 minutes

**Depends on**: none

**Files to modify**:
- `lakefile.lean` - Add `testDriver := "BimodalTest"` inside the `package Logos` block
- `.github/workflows/ci.yml` - Remove the `build-args: "--wfail"` line

**Verification**:
- `lake build BimodalTest` completes without error locally
- `lakefile.lean` contains `testDriver := "BimodalTest"` in the package block
- `ci.yml` no longer contains `--wfail`

---

### Phase 2: Push Fix and Verify CI [NOT STARTED]

**Goal**: Push the changes with a `[ci]` commit message to trigger a non-skipped CI run on main, then verify the badge updates to "passing".

**Tasks**:
- [ ] Commit changes with `[ci]` in the commit message (e.g., `task 160: fix CI configuration [ci]`)
- [ ] Push to main
- [ ] Monitor CI run via `gh run list` or `gh run watch`
- [ ] Verify badge shows "passing" after CI completes (check badge SVG or README rendering)

**Timing**: 15 minutes (plus ~20-40 minutes CI run time, unattended)

**Depends on**: 1

**Files to modify**:
- No additional file modifications; this phase is commit + push + verification

**Verification**:
- `gh run list` shows the latest run on main with status "success"
- Badge SVG at `https://github.com/benbrastmckie/ProofChecker/actions/workflows/ci.yml/badge.svg` shows "passing"

## Testing & Validation

- [ ] `lake build BimodalTest` succeeds locally (pre-push)
- [ ] CI run triggered by `[ci]` commit completes with "success" conclusion
- [ ] Badge on README.md line 3 displays "passing" on GitHub

## Artifacts & Outputs

- `plans/01_fix-ci-badge.md` (this plan)
- Modified `lakefile.lean` (testDriver added)
- Modified `.github/workflows/ci.yml` (--wfail removed)
- `summaries/01_fix-ci-badge-summary.md` (post-implementation)

## Rollback/Contingency

If CI still fails after the fix:
1. Check `gh run view <run-id> --log` for the specific failure
2. If `BimodalTest` compilation fails, set `test: false` in `ci.yml` as a temporary workaround
3. If an unexpected `lake build` error occurs, revert the `lakefile.lean` change and investigate
4. All changes are limited to 2 files; `git revert` of the fix commit cleanly undoes everything
