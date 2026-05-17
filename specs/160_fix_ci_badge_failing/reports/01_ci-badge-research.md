# Research Report: Task #160

**Task**: 160 - Fix failing CI badge in README.md
**Started**: 2026-05-17T19:25:00Z
**Completed**: 2026-05-17T20:00:00Z
**Effort**: 2 hours
**Dependencies**: None
**Sources/Inputs**:
- Local codebase: `.github/workflows/ci.yml`, `lakefile.lean`, `README.md`
- GitHub Actions run history via `gh run list` and `gh run view`
- Actual badge SVG via `curl` (confirmed "CI - failing")
- Official lean-action README (GitHub API fetch)
- Mathlib4 wiki: Setting up linting and testing for your Lean project
- lean-action documentation and source (action.yml)
- GitHub community discussions on badge behavior
- WebSearch: Lean 4 CI best practices, lake testDriver, --wfail, badge failing

**Artifacts**:
- `specs/160_fix_ci_badge_failing/reports/01_ci-badge-research.md` (this file)

**Standards**: report-format.md, artifact-management.md, tasks.md

---

## Executive Summary

- The CI badge shows **"CI - failing"** (confirmed via SVG fetch) due to three distinct root causes working together
- The **direct cause** is `test: true` in `ci.yml` combined with a missing `testDriver` in `lakefile.lean` — every PR-triggered run fails immediately with `lake check-test failed: could not find a test runner`
- A **secondary blocker** is `build-args: "--wfail"`: with 95+ active `sorry` statements generating `declaration uses sorry` warnings, even a corrected test configuration would fail the build
- A **structural issue** makes the badge perpetually stale: the `if:` condition skips all push-to-main runs (no commit in history has `[ci]`) meaning only failed PR runs influence the badge
- The recommended fix involves three coordinated changes: (1) add `testDriver` to `lakefile.lean`, (2) remove `--wfail` from `build-args`, and (3) adjust the trigger/skip logic so CI actually runs on push-to-main

---

## Context & Scope

The project is a Lean 4 formalization of bimodal logic TM (Tense and Modality) using Lean v4.27.0-rc1 with Mathlib v4.27.0-rc1. The repository (`benbrastmckie/ProofChecker`) has a single CI workflow at `.github/workflows/ci.yml` using the `leanprover/lean-action@v1` action. The CI badge on line 3 of `README.md` links to this workflow. Task 158 (README overhaul, completed 2026-05-17) deleted six sorry-laden example files but did not change the CI configuration.

---

## Findings

### Root Cause 1: Missing Test Runner (Direct Cause of Failure)

The CI workflow specifies `test: true`, which instructs `lean-action` to run `lake test`. This requires a `testDriver` to be declared in the `lakefile.lean` package block. The current `lakefile.lean` declares `BimodalTest` as a `lean_lib` but does NOT include a `testDriver` in the `package Logos` declaration.

When `lean-action` runs with `test: true`, it first calls `lake check-test`. This fails immediately with:
```
lake check-test failed: could not find a test runner
```
Exit code 1 terminates the job as a failure.

Evidence from CI run history (confirmed via `gh run view`):
- Run 25008621471 (irr_until PR, 2026-04-27): `lake check-test failed: could not find a test runner`
- Run 25006912693 (irr_until PR, 2026-04-27): same failure
- Run 25006579328 (irr_until PR, 2026-04-27): same failure
- Run 23911178260 (claude branch PR, 2026-04-02): same failure
- Run 23856032470 (claude branch PR, 2026-04-01): same failure

This error predates task 158. The test runner was never configured.

**The fix**: Add `testDriver := "BimodalTest"` to the `package Logos` block in `lakefile.lean`. This wires `BimodalTest` (already declared as `lean_lib`) as the test driver, making `lake test` succeed when all `BimodalTest` files compile without error.

### Root Cause 2: `--wfail` Incompatible with Work-in-Progress Proofs

The CI workflow sets `build-args: "--wfail"`. The `--wfail` flag causes `lake build` to **fail on any Lean warning**. The `sorry` tactic generates a `declaration uses 'sorry'` warning for every theorem that uses it.

Audit of actual `sorry` usage:
- 95 standalone `sorry` lines (one per tactic block)
- 121 total `sorry`-related lines across all files
- Affected directories: `Metalogic/WeakCanonical/`, `Metalogic/BXCanonical/`, `Metalogic/ConservativeExtension/`, `Metalogic/Bundle/`, `Theorems/`
- This is expected for an in-progress formalization project (acknowledged in README)

**If the test issue were fixed**, the build would still fail because `lake build --wfail` would emit warnings for each file containing `sorry`. This is confirmed by the project's own README which acknowledges open completeness proofs with `sorry` placeholders.

**The fix**: Remove `--wfail` from `build-args`. For a research project with intentional `sorry` placeholders, this flag is inappropriate. The build succeeds (files compile correctly) but warns about open proof obligations. For projects that want warning enforcement once sorry-free, `--wfail` can be re-added later.

Alternative: Use `build-args: ""` (default, no extra args).

### Root Cause 3: Conditional Skip Means Badge Never Updates to "Passing"

The `if:` condition on the build job skips execution unless:
1. The trigger is `workflow_dispatch`, OR
2. The trigger is `pull_request`, OR
3. The commit message contains `[ci]`

No commit in the 200+ run history contains `[ci]`. As a result, every push-to-main produces a workflow run with conclusion `skipped`. GitHub's badge algorithm treats a skipped workflow run as neutral/no-status, so the badge continues to display the state of the **last real (non-skipped) run** — which was a PR failure.

Even after fixing issues 1 and 2 above, the badge will remain "failing" until a non-skipped run completes successfully. A `workflow_dispatch` manual trigger would provide immediate verification.

**The fix options**:
- **Option A (Recommended)**: Add a `[ci]` marker to the first commit after fixing the workflow, to trigger an immediate green run on main
- **Option B**: Relax the skip condition so pushes to main always run CI (trades token spend for reliability)
- **Option C**: Use `workflow_dispatch` manually after the fix to get a passing run

### Additional Finding: Node.js 20 Deprecation Warning

Every CI run produces this annotation:
```
Node.js 20 actions are deprecated. actions/checkout@v4 will be forced to run
with Node.js 24 by default starting June 2nd, 2026.
```

This is a warning, not yet a failure. After June 2026, it may start failing. The fix is to update to `actions/checkout@v4` which should support Node.js 24 (verify via the actions/checkout release notes). This is lower priority than the three root causes above.

### Badge URL Correctness

The badge URL in `README.md` line 3 correctly references `benbrastmckie/ProofChecker` (the actual repository). The local git remote also points to `benbrastmckie/ProofChecker`. No URL mismatch issue.

### Task 158's Impact

Task 158 (example file cleanup, 2026-05-17) deleted 6 sorry-laden example files and updated `Examples.lean` to import only 2 sorry-free files. This did NOT cause the CI badge to start failing — the badge was already failing before task 158 due to the missing `testDriver`. Task 158 has no causal relationship to the current CI failure.

---

## Decisions

- Root cause is `test: true` + missing `testDriver` in `lakefile.lean`, not task 158 file deletions
- `--wfail` removal is required in addition to the test runner fix; both must be addressed together
- The `BimodalTest` `lean_lib` is architecturally sound and should be wired as `testDriver`
- The fix should include a `[ci]` commit to trigger a passing run and update the badge

---

## Recommendations

### Priority 1 (Required): Fix `lakefile.lean` — Add `testDriver`

Add `testDriver := "BimodalTest"` to the `package Logos` block:

```lean
package Logos where
  testDriver := "BimodalTest"
```

This makes `lake test` build all `BimodalTest` modules and succeed when they compile.

### Priority 2 (Required): Fix `ci.yml` — Remove `--wfail`

Change `build-args: "--wfail"` to `build-args: ""` (or remove the line entirely):

```yaml
uses: leanprover/lean-action@v1
with:
  build: true
  test: true
  lint: false
  use-mathlib-cache: true
```

The `--wfail` flag is incompatible with an in-progress formalization project that intentionally uses `sorry` as placeholders for open proofs.

### Priority 3 (Required): Trigger a Passing CI Run

After making fixes 1 and 2, push a commit containing `[ci]` in the message (e.g., `"task 160: fix CI configuration [ci]"`). This will:
- Trigger a non-skipped CI run on main
- Execute the corrected workflow
- Show a green result
- Update the badge from "failing" to "passing"

### Priority 4 (Optional): Update `actions/checkout@v4` for Node.js 24

Before the June 2026 deadline, update the workflow to use a version of `actions/checkout` that supports Node.js 24. Check the [actions/checkout releases](https://github.com/actions/checkout/releases) for the correct version tag.

### Best Practice Recommendations (from research)

The following improvements align with Lean 4 CI community standards:

1. **Use `auto-config: true` instead of explicit `test: true`**: With `auto-config: true`, `lean-action` auto-detects whether a test driver exists. If the driver is misconfigured, the CI won't hard-fail — it will simply skip the test step. This is safer for iterative development. However, once `testDriver` is properly set, explicit `test: true` is fine.

2. **Mathlib cache is correctly configured**: `use-mathlib-cache: true` is correct. This calls `lake exe cache get` before building, dramatically reducing build time. Keep this as-is.

3. **Consider a cron job CI run**: A scheduled `workflow_dispatch` or cron trigger ensures the badge stays current even if no `[ci]` commits are pushed.

4. **`build-args` options for warning enforcement**: Once sorry-free completeness proofs are achieved, re-add `--wfail` to enforce warning-free builds. This is a good long-term target.

5. **Concurrency control**: For projects with heavy Mathlib builds, add `concurrency` to cancel in-progress runs when new commits are pushed (saves GitHub Actions minutes).

---

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| `testDriver := "BimodalTest"` compiles but some BimodalTest files have errors | Medium | Run `lake build BimodalTest` locally before pushing to verify |
| Removing `--wfail` allows warnings to silently accumulate | Low | Acceptable trade-off for in-progress formalization; document in CLAUDE.md |
| `[ci]` commit triggers long Mathlib build in CI (~20-40 min) | High | Expected and acceptable; this is the first full build run ever |
| Node.js 20 deprecation causes failure on June 2, 2026 | High | Update `actions/checkout` before that date |
| BimodalTest files themselves contain errors or sorry that cause test failure | Medium | Test `lake build BimodalTest` locally before the `[ci]` push |

---

## Context Extension Recommendations

- **Topic**: CI configuration for Lean 4 projects with in-progress proofs
- **Gap**: No documented guidance on handling `sorry`-laden builds in CI, or when `--wfail` is appropriate vs. inappropriate
- **Recommendation**: Add a note to `.claude/context/repo/project-overview.md` documenting the CI design decisions (test: true requires testDriver, --wfail is disabled intentionally)

---

## Appendix

### Search Queries Used
- "GitHub Actions Lean 4 CI lake test runner configuration 2026"
- "lean-action lake check-test could not find a test runner fix lean4"
- "Lean 4 lake testDriver lakefile.lean example Mathlib testing 2025"
- "GitHub Actions badge skipped shows failing all jobs skipped CI workflow badge status 2025"
- "Lean 4 Mathlib downstream project CI best practices sorry build-args 2025 github actions"

### References
- [lean-action GitHub Action](https://github.com/leanprover/lean-action)
- [lean-action README](https://github.com/leanprover/lean-action/blob/main/README.md)
- [Mathlib4 wiki: Setting up linting and testing](https://github.com/leanprover-community/mathlib4/wiki/Setting-up-linting-and-testing-for-your-Lean-project)
- [GitHub community: Badge showing failing](https://github.com/orgs/community/discussions/25846)
- [GitHub community: Failing badge filters](https://github.com/orgs/community/discussions/24986)
- [lean4 testDriver documentation](https://lean-lang.org/doc/reference/latest/Build-Tools-and-Distribution/Lake/)

### Confirmed CI Run Failures
| Run ID | Branch | Event | Failure |
|--------|--------|-------|---------|
| 25008621471 | irr_until | pull_request | lake check-test failed: could not find a test runner |
| 25006912693 | irr_until | pull_request | lake check-test failed: could not find a test runner |
| 25006579328 | irr_until | pull_request | lake check-test failed: could not find a test runner |
| 23911178260 | claude/... | pull_request | lake check-test failed: could not find a test runner |
| 23856032470 | claude/... | pull_request | lake check-test failed: could not find a test runner |

### Current lakefile.lean (relevant excerpt)
```lean
package Logos
-- Missing: testDriver := "BimodalTest"

lean_lib BimodalTest where
  srcDir := "Tests"
  roots := #[`BimodalTest]
  leanOptions := theoryLeanOptions
```

### Current ci.yml Issues
```yaml
# Issue 1: test: true without testDriver in lakefile
test: true
# Issue 2: --wfail incompatible with 95+ sorry statements
build-args: "--wfail"
```
