# Quality Metrics for Logos

This document defines quality targets, measurement methods, and compliance requirements for the Logos project.

## 1. Code Coverage Targets

### Overall Coverage
| Metric | Target | Measurement |
|--------|--------|-------------|
| Statement coverage | ≥85% | Lines executed / Total lines |
| Branch coverage | ≥80% | Branches taken / Total branches |
| Function coverage | ≥90% | Functions called / Total functions |

### Per-Module Coverage

| Module | Target | Rationale |
|--------|--------|-----------|
| `Syntax/` | ≥90% | Core data structures, heavily used |
| `ProofSystem/` | ≥95% | Critical correctness, axiom coverage |
| `Semantics/` | ≥90% | Truth evaluation must be correct |
| `Metalogic/` | ≥95% | Soundness/completeness are theorem-critical |
| `Theorems/` | ≥90% | Perpetuity principles must be verified |
| `Automation/` | ≥80% | Tactics are complex, some edge cases acceptable |

### Critical Path Coverage
These functions MUST have 100% coverage:

- `Derivable` inductive type (all constructors)
- `truth_at` function (all formula cases)
- `soundness` theorem (all axiom cases)
- Axiom validity lemmas (all axioms)

## 2. Lint Compliance

### Required Lint Checks
All code must pass these lint checks with zero warnings:

| Lint Check | Description | Fix |
|------------|-------------|-----|
| `docBlame` | All public definitions have docstrings | Add `/-- ... -/` docstring |
| `docBlameThm` | All public theorems have docstrings | Add `/-- ... -/` docstring |
| `unusedVariable` | No unused variables | Remove or prefix with `_` |
| `unreachableTactic` | No unreachable tactic code | Remove dead code |

### Running Lint
```bash
# Run all lint checks
lake lint

# Run lint on specific file
lake env lean --run Mathlib.Tactic.Lint <path/to/file.lean>
```

### Lint Configuration
Custom lint rules can be disabled with justification:

```lean
-- Only when truly necessary, document why
@[nolint docBlame] -- Internal helper, not part of public API
def internal_helper := ...
```

## 3. Documentation Completeness

### Documentation Requirements

| Item | Requirement | Example |
|------|-------------|---------|
| Module | Module docstring at top | `/-! # Module Name ... -/` |
| Public `def` | Declaration docstring | `/-- Description -/` |
| Public `theorem` | Declaration docstring | `/-- Description -/` |
| Public `lemma` | Declaration docstring | `/-- Description -/` |
| Public `structure` | Declaration + field docstrings | `/-- Description -/` |
| Public `inductive` | Declaration + constructor docstrings | `/-- Description -/` |

### Documentation Quality Metrics

| Metric | Target |
|--------|--------|
| Public definitions documented | 100% |
| Public theorems documented | 100% |
| Modules with module docstrings | 100% |
| Examples in docstrings | ≥50% of complex definitions |
| Cross-references working | 100% |

### Documentation Checklist

For each public definition, docstring should include:
- [ ] Brief description (first line)
- [ ] Detailed explanation (if complex)
- [ ] Parameter descriptions (if not obvious)
- [ ] Return value description (if not obvious)
- [ ] Example usage (for complex definitions)
- [ ] References to related definitions
- [ ] Mathematical statement (for theorems)

## 4. Performance Benchmarks

> **Full methodology**: See [BENCHMARKING_GUIDE.md](BENCHMARKING_GUIDE.md) for comprehensive
> benchmarking standards, implementation patterns, and CI integration.

### Benchmark Coverage

| Operation | Required | Target |
|-----------|----------|--------|
| Proof search | Yes (if applicable) | All search strategies benchmarked |
| Derivation construction | Yes | All inference rules benchmarked |
| Semantic evaluation | Yes | All formula types benchmarked |

### Regression Policy

- Regressions >2x are blocking for merge
- Theory-specific targets in each theory's PERFORMANCE_TARGETS.md

### Build Performance

| Metric | Target | Action if Exceeded |
|--------|--------|-------------------|
| Full build time | <2 minutes | Profile imports, reduce dependencies |
| Incremental build (1 file) | <30 seconds | Check for expensive computations |
| Clean build | <3 minutes | Normal for fresh builds |

### Test Performance

| Metric | Target | Action if Exceeded |
|--------|--------|-------------------|
| Full test suite | <30 seconds | Parallelize tests, optimize slow tests |
| Single test file | <5 seconds | Simplify test, reduce proof complexity |
| CI total time | <5 minutes | Cache dependencies, optimize workflow |

### Runtime Performance

| Metric | Target | Action if Exceeded |
|--------|--------|-------------------|
| Proof search (simple) | <100ms | Optimize search strategy |
| Proof search (complex) | <1 second | Add depth limits, caching |
| Truth evaluation | <10ms per formula | Memoize, simplify evaluation |
| Validity check | <100ms | Use decision procedures |

### Measuring Performance
```bash
# Time full build
time lake build

# Time tests
time lake test

# Profile specific file
lake env lean --profile <path/to/file.lean>
```

## 5. Complexity Limits

### Function Complexity

| Metric | Limit | Rationale |
|--------|-------|-----------|
| Lines per function | ≤50 | Readability, testability |
| Cyclomatic complexity | ≤10 | Maintainability |
| Parameter count | ≤6 | API simplicity |
| Nesting depth | ≤4 | Readability |

### Module Complexity

| Metric | Limit | Rationale |
|--------|-------|-----------|
| Lines per file | ≤1000 | Manageability |
| Definitions per file | ≤30 | Focus |
| Import count | ≤15 | Dependency management |
| Namespace depth | ≤4 | Navigation |

### Proof Complexity

| Metric | Limit | Rationale |
|--------|-------|-----------|
| Tactics per proof | ≤20 | Comprehensibility |
| Proof length (lines) | ≤50 | Reviewability |
| `sorry` count | 0 | Completeness |
| Case split depth | ≤5 | Tractability |

### Refactoring Triggers
Refactor when:
- Function exceeds 50 lines
- Module exceeds 1000 lines
- Proof exceeds 20 tactics
- Cyclomatic complexity exceeds 10

## 6. Quality Dashboard

### Key Metrics Summary

```
Logos Quality Dashboard
==============================

Coverage
--------
Overall:        87% (target: ≥85%) ✓
Metalogic/:     94% (target: ≥95%) ⚠
ProofSystem/:   96% (target: ≥95%) ✓

Lint
----
Warnings:       0 (target: 0) ✓
Errors:         0 (target: 0) ✓

Documentation
-------------
Public defs:    100% documented ✓
Modules:        100% have docstrings ✓

Performance
-----------
Build time:     1m 45s (target: <2m) ✓
Test time:      22s (target: <30s) ✓

Complexity
----------
Max function:   42 lines (limit: 50) ✓
Max module:     890 lines (limit: 1000) ✓
Max proof:      15 tactics (limit: 20) ✓
```

### Monitoring Frequency

| Metric | Frequency | Owner |
|--------|-----------|-------|
| Coverage | Every PR | CI |
| Lint | Every commit | CI |
| Build time | Weekly | Maintainers |
| Complexity | Monthly | Maintainers |

## 7. Compliance Enforcement

### CI Requirements
All PRs must pass:
- [ ] `lake build` succeeds
- [ ] `lake test` passes (all tests)
- [ ] `lake lint` has zero warnings
- [ ] Coverage does not decrease
- [ ] Build time does not increase >10%

### Review Checklist
Reviewers verify:
- [ ] New code has tests
- [ ] New public definitions have docstrings
- [ ] No `sorry` in committed code
- [ ] Complexity limits respected
- [ ] Performance acceptable

### Exception Process
To request an exception:
1. Document the reason in PR description
2. Get approval from 2 reviewers
3. Create tracking issue for remediation
4. Set deadline for coming into compliance

## 8. Quality Improvement Process

### Continuous Improvement

1. **Measure**: Track metrics automatically in CI
2. **Analyze**: Review trends monthly
3. **Improve**: Address gaps in priority order
4. **Verify**: Confirm improvements in next cycle

### Priority Order for Fixes

1. **Critical**: `sorry` removal, failing tests, lint errors
2. **High**: Coverage gaps in critical modules, documentation gaps
3. **Medium**: Performance issues, complexity violations
4. **Low**: Minor style issues, optional improvements

### Technical Debt Management

- Track technical debt items in GitHub issues
- Label with `tech-debt`
- Allocate 20% of development time to debt reduction
- Review debt backlog quarterly

## References

- [Benchmarking Guide](BENCHMARKING_GUIDE.md)
- [Testing Standards](TESTING_STANDARDS.md)
- [LEAN Style Guide](LEAN_STYLE_GUIDE.md)
- [Module Organization](MODULE_ORGANIZATION.md)
- [Contributing Guide](CONTRIBUTING.md)
