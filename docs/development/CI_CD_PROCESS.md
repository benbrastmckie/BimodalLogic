# CI/CD Process

This document describes the Continuous Integration and Continuous Deployment (CI/CD) pipeline for the ProofChecker project.

## Overview

The ProofChecker project uses GitHub Actions to automatically build, test, and lint the codebase on every push to `main` and on all pull requests. This ensures code quality and prevents regressions from being merged.

### Pipeline Summary

```
Push/PR → GitHub Actions → Build → Test → Lint → Results
```

**Typical CI runtime**: 7-10 minutes (with Mathlib cache)

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

- `Logos` library (main logic implementation in `Theories/`)
- `Bimodal` library (TM logic implementation)
- `LogosTest` and `BimodalTest` test libraries
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
  run: cd Theories/Bimodal/latex && latexmk -pdf BimodalReference.tex
```

### Automated Mathlib Updates

The [oliver-butterley/lean-update](https://github.com/oliver-butterley/lean-update) action can automate Mathlib version updates.

## References

- [leanprover/lean-action](https://github.com/leanprover/lean-action) - Official GitHub Action
- [TESTING_STANDARDS.md](TESTING_STANDARDS.md) - Test organization and requirements
- [Lake Documentation](https://lean-lang.org/doc/reference/latest/Build-Tools-and-Distribution/Lake/) - Build system reference
