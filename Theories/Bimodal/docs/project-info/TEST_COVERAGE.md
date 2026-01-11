# Bimodal Test Coverage Report

**Generated**: 2026-01-12
**Script**: `scripts/coverage-analysis.sh`
**Version**: Baseline (initial measurement)

## Summary

| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| Definition Coverage | 42% | 85% | Needs Improvement |
| Total Definitions | 348 | - | - |
| Covered Definitions | 148 | - | - |
| Sorry Placeholders | 5 | 0 | Acceptable (mostly infrastructure-blocked) |

## Module Breakdown

Coverage is measured by checking whether each public definition in Bimodal/ appears somewhere in BimodalTest/. High-coverage modules have well-tested APIs; low-coverage modules may have internal implementation details that don't need direct tests.

### High Coverage (85%+)

| Module | Definitions | Tested | Coverage | Notes |
|--------|-------------|--------|----------|-------|
| Bimodal | 1 | 1 | 100% | Root module |
| Metalogic.Completeness | 6 | 6 | 100% | All completeness infrastructure tested |
| ProofSystem.Axioms | 1 | 1 | 100% | Axiom schema tested |
| Semantics.TaskFrame | 4 | 4 | 100% | Frame structure fully tested |
| Theorems.ModalS4 | 4 | 4 | 100% | S4 theorems tested |
| Syntax.Context | 15 | 16 | 93% | Context operations well tested |

### Medium Coverage (60-84%)

| Module | Definitions | Tested | Coverage | Priority |
|--------|-------------|--------|----------|----------|
| Syntax.Formula | 17 | 21 | 80% | Low - core types well tested |
| Semantics.TaskModel | 3 | 4 | 75% | Medium |
| Theorems.Combinators | 8 | 11 | 72% | Low |
| ProofSystem.Derivation | 6 | 9 | 66% | Medium - key proofs tested |
| Metalogic.Soundness | 11 | 17 | 64% | Medium - core theorems tested |
| Theorems.Perpetuity.Principles | 9 | 15 | 60% | Medium |

### Low Coverage (<60%)

| Module | Definitions | Tested | Coverage | Priority |
|--------|-------------|--------|----------|----------|
| Automation.ProofSearch | 21 | 37 | 56% | Medium - internal helpers |
| Theorems.ModalS5 | 4 | 7 | 57% | Low |
| Theorems.Propositional | 11 | 32 | 34% | Medium |
| Automation.AesopRules | 6 | 19 | 31% | Low - Aesop integration |
| Semantics.Validity | 3 | 10 | 30% | Medium |
| Theorems.Perpetuity.Bridge | 5 | 25 | 20% | Low - internal helpers |
| Automation.Tactics | 5 | 26 | 19% | Medium |
| Semantics.Truth | 2 | 12 | 16% | High - needs tests |
| Semantics.WorldHistory | 3 | 19 | 15% | Low - internal |
| Automation.SuccessPatterns | 3 | 22 | 13% | Low - internal patterns |
| Metalogic.DeductionTheorem | 0 | 4 | 0% | Medium |
| Metalogic.SoundnessLemmas | 0 | 18 | 0% | Low - helper lemmas |
| Theorems.Perpetuity.Helpers | 0 | 6 | 0% | Low - internal |
| Theorems.GeneralizedNecessitation | 0 | 1 | 0% | Low |
| Syntax | 0 | 1 | 0% | Low |

### Coverage Interpretation

**Note on low coverage modules**: Many low-coverage modules contain internal implementation details (helpers, patterns, lemmas) that are tested indirectly through public API tests. For example:
- `Automation.SuccessPatterns` - Pattern matching utilities used by `ProofSearch`
- `Metalogic.SoundnessLemmas` - Lemmas used in soundness proofs
- `Theorems.*.Helpers` - Internal proof helpers

### Priority Recommendations

1. **High Priority**: `Semantics.Truth` (16%) - Core truth evaluation needs direct tests
2. **Medium Priority**:
   - `Metalogic.DeductionTheorem` (0%) - Important infrastructure
   - `Automation.Tactics` (19%) - User-facing automation
   - `Semantics.Validity` (30%) - Validity checking
3. **Low Priority**: Internal helper modules with indirect coverage

## Uncovered Definitions (Sample)

Top 20 uncovered definitions that may benefit from direct tests:

1. `Automation.AesopRules.axiom_modal_t`
2. `Automation.AesopRules.axiom_prop_k`
3. `Automation.AesopRules.axiom_prop_s`
4. `Automation.ProofSearch.SearchResult`
5. `Automation.ProofSearch.CacheKey`
6. `Automation.ProofSearch.SearchStats`
7. `Automation.ProofSearch.box_context`
8. `Automation.ProofSearch.future_context`
9. `Automation.SuccessPatterns.ConjIntro`
10. `Automation.SuccessPatterns.DisjElim`
11. `Automation.Tactics.modal_basics`
12. `Automation.Tactics.temporal_basics`
13. `Metalogic.DeductionTheorem.deduction_lemma`
14. `Metalogic.DeductionTheorem.deduction_theorem`
15. `Metalogic.SoundnessLemmas.valid_at_triple`
16. `Semantics.Truth.truth_at_imp`
17. `Semantics.Truth.truth_at_box`
18. `Semantics.Validity.valid_at_world`
19. `Theorems.Propositional.imp_trans`
20. `Theorems.Propositional.double_neg`

Run `./scripts/coverage-analysis.sh --verbose` for the complete list.

## Sorry Audit

### Files with Sorry Placeholders

| File | Sorries | Status |
|------|---------|--------|
| Metalogic/CompletenessTest.lean | 3 | Blocked by infrastructure |
| Theorems/PerpetuityTest.lean | 1 | Could be completed |
| Theorems/PropositionalTest.lean | 1 | Could be completed |

### Categorization

**Blocked by Infrastructure (3)**:
Cannot be resolved until source implementation completes:
- `CompletenessTest.lean:51,65,83` - Completeness proofs require `Bimodal/Metalogic/Completeness.lean` implementation

**Could Be Completed (2)**:
Could be resolved with additional proof work:
- `PerpetuityTest.lean:76` - `box_conj_intro` proof construction
- `PropositionalTest.lean:193` - Requires deduction theorem

### Total: 5 sorry placeholders

## Regenerating This Report

```bash
# Generate human-readable report
./scripts/coverage-analysis.sh

# Generate with all uncovered definitions
./scripts/coverage-analysis.sh --verbose

# Generate JSON for automated processing
./scripts/coverage-analysis.sh --json > coverage.json
```

## Historical Data

| Date | Coverage | Definitions | Covered | Sorries |
|------|----------|-------------|---------|---------|
| 2026-01-12 | 42% | 348 | 148 | 5 |

## Related Documentation

- [PERFORMANCE_TARGETS.md](PERFORMANCE_TARGETS.md) - Benchmark baselines and performance goals
- [TESTING_STANDARDS.md](../../../docs/development/TESTING_STANDARDS.md) - Test requirements and conventions
- [BimodalTest README](../../../BimodalTest/README.md) - Test organization and running tests
- [IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md) - Module implementation status

## Navigation

- **Up**: [ProjectInfo/](./)
- **Tests**: [BimodalTest/](../../../BimodalTest/)
- **Benchmarks**: [benchmarks/](../../../benchmarks/)
