# CI/CD Process

This document describes the Continuous Integration and Continuous Deployment (CI/CD) pipeline for the ProofChecker project.

## Overview

The ProofChecker project uses GitHub Actions to automatically build, test, and lint the codebase on every push to `main` and on all pull requests. This ensures code quality and prevents regressions from being merged.

### Pipeline Summary

```
Push/PR → GitHub Actions → Build → Test → Lint → lean_exe roots →
  check-module-invariants.sh --no-build → check-copyright-headers.sh --strict →
  readme-lint.sh → Results
```

**Typical CI runtime**: 7-10 minutes (with Mathlib cache), plus roughly 40s for the three
check-script steps documented below (see "Runtime Budget" in "Wiring a New Check Script").

## Workflow Configuration

The CI workflow is defined in `.github/workflows/ci.yml` and uses the official [leanprover/lean-action](https://github.com/leanprover/lean-action) GitHub Action.

### Triggers

| Event | Trigger |
|-------|---------|
| Push to `main` | Automatic |
| Pull request to `main` | Automatic |
| Manual dispatch | Via GitHub Actions UI |

### Jobs

The workflow runs a single job named "Build, Test, and Lint" with the following steps:

1. **Checkout**: Clone the repository
2. **lean-action**: Build, test, and lint using Lake with Mathlib caching

### Configuration Options

```yaml
uses: leanprover/lean-action@v1
with:
  build: true          # Run lake build
  test: true           # Run lake test
  lint: true           # Run lake lint
  use-mathlib-cache: true  # Download Mathlib cache
  build-args: "--wfail"    # Treat warnings as failures
```

## CI Steps Explained

### Build Step

**Command**: `lake build`

The build step compiles all Lean source files in the project:

- `Logos` library (main logic implementation in `FormalSystem/`)
- `Bimodal` library (TM logic implementation)
- `BimodalTest` test library
- All executable scripts

**What it checks**:
- Lean syntax correctness
- Type checking
- Import resolution
- Elaboration success

**With `--wfail`**: Compiler warnings are treated as errors, ensuring clean code.

### Test Step

**Command**: `lake test`

The test step runs the project's test suite using the configured test driver (`lake exe test`).

**What it runs**:
- Unit tests for formula construction, contexts, operators
- Integration tests for soundness, proof workflows
- Property tests using the plausible library
- Example derivation tests

See [TESTING_STANDARDS.md](TESTING_STANDARDS.md) for detailed test organization.

### Lint Step

**Command**: `lake lint`

The lint step runs the project's lint driver (`lintAll`) which orchestrates:

1. **Environment linters** (`runEnvLinters`): Post-compilation checks on declarations
2. **Style linters** (`lintStyle`): Text-based checks including:
   - Trailing whitespace
   - Line length (100 character limit)
   - Non-breaking spaces

**Auto-fixing**: Run `lake lint -- --fix` locally to auto-fix some issues.

### Compile lean_exe Roots Step

**Step name**: `Compile lean_exe roots (outside the library closures)`

**Command**: for each `root :=` target scraped from `lakefile.lean`, `lake build "$root"`.

Every `lean_exe` root sits outside both library root closures (`FormalSystem`, `BimodalTest`),
so the lean-action build step above never elaborates any of them on its own. This step compiles
each one as a MODULE target (elaboration and C emission, no linking), reusing the Lake cache the
lean-action step already populated. It exists because an executable root broke without CI
noticing, since nothing else observed it. The local counterpart is `check-module-invariants.sh`'s
C25, which scrapes the same root list; CI runs the check script's structural (`--no-build`) pass
instead of its full mode, so C25 is skipped there as redundant with this step (see the "Known
Not-in-CI Gaps" subsection below).

### Check Module Invariants Step

**Step name**: `Check module invariants (scripts/check-module-invariants.sh --no-build)`

**Command**: `bash scripts/check-module-invariants.sh --no-build`

**What it gates**: the structural subset of the 26-check module-invariant suite (import
resolution, copyright/task-reference/path checks, sorry inventory, docstring coverage, README
duplication, and more) that does not require a fresh `lake build`. It runs after the lean-action
and lean_exe steps so the Lake cache is warm for the checks that do call `lake`/`lean`.

**Run locally**: `bash scripts/check-module-invariants.sh --no-build` (or the full form, `bash
scripts/check-module-invariants.sh`, to also run the build-dependent checks — see "Known
Not-in-CI Gaps" below).

### Check Copyright Headers Step

**Step name**: `Check copyright headers (scripts/check-copyright-headers.sh --strict)`

**Command**: `bash scripts/check-copyright-headers.sh --strict --exclude '*/Boneyard/*' FormalSystem`

**What it gates**: every live (non-`Boneyard`) `.lean` file under `FormalSystem/` carries a
conforming copyright header. The bare invocation (no `--strict`) always exits 0 regardless of
findings, so only this strict, live-set form is a real gate — never wire the bare form.

**Run locally**: the exact command above.

### Check README Health Step

**Step name**: `Check README health (scripts/readme-lint.sh)`

**Command**: `bash scripts/readme-lint.sh`

**What it gates**: Checks 1 (every directory with `.lean` files has a README) and 3 (every
relative markdown link in a `FormalSystem/**/README.md` resolves). These are the only two of
the script's four checks that affect its exit code.

**Informational only (never fails CI)**: Check 2 (files not listed in a README's own file
table — 91 such entries as of this wiring) and Check 4 (README front-matter dates stale or
missing relative to the directory's last change — 3 such entries). Do not read either as a
failure signal; the script's own `RESULT: PASS`/`FAIL` line, not the presence of these
`INFO`-level lines, is authoritative.

**Run locally**: `bash scripts/readme-lint.sh`.

## Wiring a New Check Script

This is the convention every task that adds a new gating step to `.github/workflows/ci.yml`
follows. It was established when `check-module-invariants.sh --no-build`,
`check-copyright-headers.sh --strict`, and `readme-lint.sh` were first wired in, alongside the
independently-wired `check-evidence-probes.sh` and `check-metalogic-cycles.sh` steps.

### 1. Step Naming

The step's `name:` contains the script's path (or its exact invocation, when a flag
distinguishes the gated form from a non-gating one, e.g. `--strict`), so the Actions UI
identifies which script failed without opening the log. The step body is:

```yaml
- name: <Human label> (scripts/<script>.sh <relevant flags>)
  run: |
    set -euo pipefail
    echo "::group::bash scripts/<script>.sh <exact args>"
    bash scripts/<script>.sh <exact args>
    echo "::endgroup::"
```

`set -euo pipefail` and the `::group::`/`::endgroup::` wrapping match the existing `Compile
lean_exe roots` step's convention.

### 2. Skip-and-Report-Neutral Convention

When a check's input may legitimately be absent in CI (for example, an external paper the repo
does not vendor), the step or script must detect that case explicitly, print a line starting
`SKIP (neutral): <reason>`, and exit 0. A missing input must never be reported as a failure, and
a present-but-wrong input must never be silently skipped — the skip path is for a genuinely
absent input only, not a shortcut around a real check.

**Known non-conforming script**: `check-paper-definitions.sh` currently exits 2 when its input
is missing. That is a failure exit, not a neutral skip, so it must adopt this convention (an
explicit "input present?" check that prints `SKIP (neutral): ...` and exits 0 when absent)
before it can be wired into CI.

### 3. Cache-Warm Placement

Any check that calls `lake`/`lean` is placed after the lean-action step and after the `Compile
lean_exe roots` step, so it reuses the Lake cache both already populated rather than triggering
a cold build. A check with no `lake`/`lean` dependency (pure `bash`/`grep`/`python3` text
scanning) has no placement constraint of its own, but by convention every new step is still
appended directly before `Report results`, so the step list reads top-to-bottom in the order
checks were wired.

### 4. Runtime Budget

Measured locally on a warm Lake cache (`lake build` already run), 2026-09-16. The two "Local"
columns are two independent measurements of the same commands: "full env" is a normal shell
run; "minimal env, extracted body" re-derives the exact `run:` body from the committed YAML
(never retyped) and runs it under a minimal `env -i` PATH, as a rough local approximation of the
`ubuntu-latest` runner:

| Step | Local, full env | Local, minimal env (extracted body) | Actions-measured |
|------|------------------|--------------------------------------|-------------------|
| `Check module invariants (scripts/check-module-invariants.sh --no-build)` | 23.6s | 20.3s | _(fill in from a confirmation run — see the implementation summary's remote-confirmation checklist)_ |
| `Check copyright headers (scripts/check-copyright-headers.sh --strict)` | 10.98s | 4.5s | _(pending)_ |
| `Check README health (scripts/readme-lint.sh)` | 7.34s | 4.7s | _(pending)_ |
| **Sum (added local delta)** | **~41.9s** | **~29.5s** | _(pending)_ |

A task that wires a new check step updates this table in the same change, adding its own row
and re-summing.

### Known Not-in-CI Gaps

CI runs `check-module-invariants.sh` in `--no-build` (structural) mode rather than its full
mode, to avoid duplicating work the lean-action and lean_exe steps already do and to keep the
added runtime near the budget above rather than the full mode's roughly 2-minute warm-cache
cost. Three checks are consequently not run in CI at all:

- **C2** — axiom-baseline drift detection
- **C6** — unreachable-module compile-checking (the manifest check itself still runs; only the
  compile-check half is skipped)
- **C24** — transitive `Init` import check

**Upgrade path**: drop `--no-build` from the `Check module invariants` step's command (a
one-line edit) once the added ~2 minutes is judged worth the coverage.

`readme-lint.sh`'s Check 4 (README date freshness) is also distorted in CI specifically: it
calls `git log -1 -- "$dir"`, and under `actions/checkout@v4`'s default `fetch-depth: 1`, every
directory resolves to the same single commit (the checkout commit itself), so CI's Check 4
output will not match a local run against full history. This is accepted, not fixed — Check 4
is informational only (see "Check README Health Step" above), and the workflow does not set
`fetch-depth: 0` solely to make an informational check's dates accurate.

## Caching Strategy

### Mathlib Cache

The lean-action automatically downloads prebuilt Mathlib binaries using `lake exe cache get`. This reduces build time from ~40 minutes to ~5 minutes.

**Cache key factors**:
- Mathlib version (from `lake-manifest.json`)
- Lean toolchain version (from `lean-toolchain`)

### GitHub Actions Cache

Build artifacts are cached between workflow runs:

- **Primary key**: OS + architecture + manifest + commit hash
- **Fallback key**: OS + architecture + manifest

**To disable caching** (for debugging):
```yaml
use-github-cache: false
```

## Interpreting CI Results

### Success

All checks pass:
```
Build status: SUCCESS
Test status: SUCCESS
Lint status: SUCCESS
```

A green checkmark appears on the PR/commit.

### Failure

One or more checks fail. Check the GitHub Actions log for details:

**Build failure**: Compilation error in Lean code
**Test failure**: One or more tests did not pass
**Lint failure**: Code style violations

### Output Variables

The workflow outputs status variables for each step:
- `build-status`: "SUCCESS" | "FAILURE"
- `test-status`: "SUCCESS" | "FAILURE"
- `lint-status`: "SUCCESS" | "FAILURE"

## Common Failures and Fixes

### Build Failures

| Error | Cause | Fix |
|-------|-------|-----|
| "unknown identifier" | Missing import | Add the required import |
| "type mismatch" | Type error | Check types with `#check` |
| "failed to synthesize" | Missing instance | Add instance or import |
| Warning (with --wfail) | Unused variable, etc. | Address the warning |

### Test Failures

| Error | Cause | Fix |
|-------|-------|-----|
| "#guard failed" | Assertion failed | Fix the logic being tested |
| "example failed" | Proof doesn't type-check | Fix the proof |
| Timeout | Test takes too long | Optimize or skip |

### Lint Failures

| Error | Cause | Fix |
|-------|-------|-----|
| "Trailing whitespace" | Whitespace at line end | Run `lake lint -- --fix` |
| "Line exceeds 100 chars" | Long line | Break line manually |
| "Non-breaking space" | Wrong space character | Replace with regular space |

## Running CI Locally

Before pushing, verify your changes locally:

```bash
# Build the project
lake build --wfail

# Run tests
lake test

# Run linters
lake lint

# Auto-fix lint issues
lake lint -- --fix

# Check module invariants (structural pass, matches the CI step)
bash scripts/check-module-invariants.sh --no-build

# Check copyright headers (strict, live-set form -- the bare form always exits 0)
bash scripts/check-copyright-headers.sh --strict --exclude '*/Boneyard/*' FormalSystem

# Check README health
bash scripts/readme-lint.sh
```

## Branch Protection (Recommended)

To require CI to pass before merging, configure GitHub branch protection:

1. Go to **Settings** → **Branches** → **Branch protection rules**
2. Click **Add rule** for `main`
3. Enable:
   - **Require status checks to pass before merging**
   - Select the "Build, Test, and Lint" check
   - **Require branches to be up to date before merging**

## Future Improvements

### Code Coverage

Code coverage reporting is not currently implemented. There is no production-ready code coverage tool for Lean 4 as of 2026. This will be added when tooling becomes available.

### Documentation Builds

LaTeX documentation builds could be added as a separate CI job if needed:

```yaml
# Example (not implemented)
- name: Build LaTeX docs
  run: cd latex && latexmk -pdf BimodalReference.tex
```

### Automated Mathlib Updates

The [oliver-butterley/lean-update](https://github.com/oliver-butterley/lean-update) action can automate Mathlib version updates.

## References

- [leanprover/lean-action](https://github.com/leanprover/lean-action) - Official GitHub Action
- [TESTING_STANDARDS.md](TESTING_STANDARDS.md) - Test organization and requirements
- [Lake Documentation](https://lean-lang.org/doc/reference/latest/Build-Tools-and-Distribution/Lake/) - Build system reference
