# Research Report: Task #175

**Task**: Establish CI/CD pipeline with automated testing and linting
**Date**: 2026-01-11
**Focus**: Include an explanation of the advantages and workflow once this task is complete

## Summary

This research establishes that the ProofChecker project should use the official `leanprover/lean-action` GitHub Action for CI/CD, leveraging its built-in support for Mathlib caching, testing, and linting. The project already has well-developed lint infrastructure (`lake lint`, `lake exe lintStyle`) and test infrastructure (`lake test`) that can be integrated into automated workflows.

## Findings

### 1. Official Lean CI/CD Tooling

The **leanprover/lean-action** GitHub Action is the standard solution for Lean 4 projects:

| Input | Default | Description |
|-------|---------|-------------|
| `build` | `"default"` | Run `lake build` |
| `test` | `"default"` | Run `lake test` |
| `lint` | `"default"` | Run `lake lint` |
| `use-mathlib-cache` | `"auto"` | Download Mathlib cache via `lake exe cache get` |
| `use-github-cache` | `"true"` | Enable GitHub Actions caching |
| `build-args` | `""` | Additional arguments (e.g., `--wfail` for warnings as failures) |
| `lean4checker` | `"false"` | Run lean4checker (Lean 4.8+) |

Basic workflow:
```yaml
name: CI
on:
  push:
    branches: ["main"]
  pull_request:
    branches: ["main"]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: leanprover/lean-action@v1
```

**Sources**: [leanprover/lean-action](https://github.com/leanprover/lean-action), [lean-action README](https://github.com/leanprover/lean-action/blob/main/README.md)

### 2. Current Project Infrastructure

The ProofChecker project already has substantial infrastructure in place:

**Build Configuration** (`lakefile.lean`):
- Main target: `Logos` library (srcDir: `Theories`)
- Secondary target: `Bimodal` library
- Test libraries: `LogosTest`, `BimodalTest`
- Test executable: `lake exe test`
- Lint driver: `lake lint` (via `@[lint_driver]` on `lintAll`)
- Style linter: `lake exe lintStyle`
- Environment linter: `lake exe runEnvLinters`

**Test Structure** (42 test files in `Tests/`):
- `BimodalTest/` - Comprehensive tests for Bimodal TM logic
- `LogosTest/` - Tests for Logos core library
- Unit, integration, property, and benchmark tests

**Lint Infrastructure** (`scripts/`):
- `LintAll.lean` - Main lint driver orchestrating all linters
- `LintStyle.lean` - Text-based style checks (trailing whitespace, line length, non-breaking spaces)
- `RunEnvLinters.lean` - Environment/post-build linters

**Toolchain**: `leanprover/lean4:v4.27.0-rc1` with Mathlib `v4.27.0-rc1`

### 3. Linting Options for Lean 4

**Built-in Lake Support**:
- `lake lint` invokes the package's configured `lintDriver`
- ProofChecker has `@[lint_driver]` on `lintAll` executable
- `lintDriverArgs` can pass default arguments

**Mathlib-style Linting**:
- Mathlib uses `lake exe lint-style` for text-based checks
- Environment linters check declarations post-compilation
- `lake exe runLinter` for declaration-level linting

**Current ProofChecker Linters**:
1. `lintStyle` - Trailing whitespace, line length (100 chars), non-breaking spaces
2. `runEnvLinters` - Post-build environment checks (not fully implemented)

### 4. Code Coverage Limitations

**Key Finding**: There is no production-ready code coverage tool for Lean 4 as of 2025-2026.

Community discussions indicate interest in:
- Execution path tracing
- Test coverage metrics
- No-op tactic detection

**Recommendation**: Defer coverage reporting until tooling matures. Focus on:
- Compilation success as primary quality gate
- Test pass rate
- Lint compliance

### 5. Mathlib CI Patterns

Mathlib4 uses sophisticated CI patterns that inform best practices:

1. **Multi-stage caching**: Initial cache test → conditional full fetch
2. **Security sandboxing**: `landrun` isolation for untrusted code (not needed for this project)
3. **Parallel builds**: Archive and Counterexamples built separately
4. **Post-build validation**: `mk_all --check`, olean inspection

Relevant patterns for ProofChecker:
- GitHub cache for build artifacts
- Mathlib cache for dependencies
- Warning-as-failure mode (`--wfail`)

## Advantages Once Complete

### For Contributors
1. **Immediate feedback**: PRs show build/test/lint status before review
2. **Prevent regressions**: Failing tests block merge
3. **Consistent environment**: CI runs on clean Ubuntu, avoiding "works on my machine"
4. **Faster iterations**: Mathlib cache reduces build time from ~40 minutes to ~5 minutes

### For Maintainers
1. **Quality gates**: Merge blocking ensures main branch stability
2. **Automated checks**: No manual `lake build && lake test && lake lint` before merge
3. **PR status badges**: Visual confidence in PR readiness
4. **Build history**: Track build health over time

### Workflow Once Complete

**Developer Workflow**:
```
1. Create branch, make changes
2. Push → CI runs automatically
3. PR shows ✓ Build ✓ Test ✓ Lint
4. Review proceeds with confidence
5. Merge when approved and CI passes
```

**CI Pipeline**:
```
Push/PR → checkout → lean-action:
  ├── Fetch Mathlib cache (~1-2 min)
  ├── Build project (~3-5 min)
  ├── Run tests (~1-2 min)
  └── Run lints (~1 min)
Total: ~7-10 minutes
```

**Failure Handling**:
- Build failure → Fix compilation errors
- Test failure → Fix broken tests
- Lint failure → Run `lake lint --fix` or manual fixes

## Recommendations

### Recommended CI Configuration

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: ["main"]
  pull_request:
    branches: ["main"]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build and Test
        uses: leanprover/lean-action@v1
        with:
          build: true
          test: true
          lint: true
          use-mathlib-cache: true
          build-args: "--wfail"
```

### Optional: Separate Lint Workflow

```yaml
# .github/workflows/lint.yml
name: Lint

on:
  push:
    branches: ["main"]
  pull_request:
    branches: ["main"]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Lean
        uses: leanprover/lean-action@v1
        with:
          auto-config: false
          build: false
          test: false
          lint: true
```

### Implementation Notes

1. **Single workflow preferred**: `lean-action` handles build/test/lint in one job efficiently
2. **Coverage deferred**: No reliable tooling; document in CI_CD_PROCESS.md as future work
3. **Documentation builds**: Add separate job if LaTeX docs need CI validation
4. **Branch protection**: Configure GitHub to require CI pass before merge

### Files to Create

1. `.github/workflows/ci.yml` - Main CI workflow
2. `docs/development/CI_CD_PROCESS.md` - Process documentation

### Potential Challenges

1. **Build time**: First run without cache may take 30-40 minutes
2. **Mathlib updates**: Cache invalidation on Mathlib version bumps
3. **Flaky tests**: Property tests may have randomness (plausible library)
4. **Runner limits**: GitHub Actions free tier has time limits

## References

- [leanprover/lean-action](https://github.com/leanprover/lean-action)
- [lean-action README](https://github.com/leanprover/lean-action/blob/main/README.md)
- [oliver-butterley/lean-update](https://github.com/oliver-butterley/lean-update)
- [Lake Documentation](https://lean-lang.org/doc/reference/latest/Build-Tools-and-Distribution/Lake/)
- [Mathlib4 CI Workflows](https://github.com/leanprover-community/mathlib4/tree/master/.github/workflows)
- [Lean 4 Zulip - Coverage Discussion](https://leanprover-community.github.io/archive/stream/270676-lean4/topic/Coverage.20and.20executed.20code.html)

## Next Steps

1. Create `.github/workflows/ci.yml` with lean-action configuration
2. Create `docs/development/CI_CD_PROCESS.md` documenting the process
3. Test workflow on a branch before merging to main
4. Configure GitHub branch protection rules to require CI pass
