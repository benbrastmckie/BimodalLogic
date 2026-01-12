# Implementation Plan: Task #179

**Task**: Extend Bimodal benchmarks with derivation, semantics, and CI integration
**Version**: 001
**Created**: 2026-01-11
**Language**: lean

## Revision Summary

This plan replaces the original task 179 scope (which assumed no benchmarks existed) with a scope that builds on the existing comprehensive benchmark infrastructure.

### Previous Scope (Obsolete)
- Assumed no benchmarks existed (`LogosBench/` new directory)
- 13 hours effort for creating everything from scratch

### Current State
`BimodalTest/Automation/ProofSearchBenchmark.lean` already implements:
- Comprehensive proof search benchmarks (modal, temporal, propositional, mixed)
- Timing utilities with wall-clock measurement
- Benchmark configuration and results structures
- Strategy comparison (BoundedDFS vs IDDFS)
- Weight configuration comparison
- Summary and reporting functions

### New Scope (Current)
Build on existing infrastructure to add:
1. Derivation tree construction benchmarks
2. Semantic evaluation benchmarks
3. Performance targets documentation
4. CI integration for regression testing

## Overview

Extend the Bimodal benchmarking suite to cover all major computational operations: proof search (done), derivation construction, and semantic evaluation. Add CI infrastructure for automated performance regression detection.

## Phases

### Phase 1: Derivation Tree Benchmarks

**Status**: [NOT STARTED]
**Estimated effort**: 3 hours

**Objectives**:
1. Benchmark derivation tree construction performance
2. Measure modus ponens chains of varying depth
3. Benchmark necessitation and generalized K rules

**Files to create**:
- `BimodalTest/ProofSystem/DerivationBenchmark.lean` (new)

**Benchmark categories**:

```lean
-- Category 1: Simple derivations
- Axiom application (single step)
- Assumption retrieval

-- Category 2: Modus ponens chains
- MP depth 1, 2, 3, 5, 10
- Context sizes: 1, 5, 10, 20 formulas

-- Category 3: Modal/temporal rules
- Necessitation (modal and temporal)
- Generalized modal K
- Generalized temporal K

-- Category 4: Combined derivations
- MP + necessitation chains
- Weakening with large contexts
```

**Implementation pattern** (following ProofSearchBenchmark):

```lean
structure DerivationBenchmarkResult where
  name : String
  treeDepth : Nat
  constructionTimeNs : Nat
  deriving Repr

def runDerivationBenchmark (name : String) (derive : Unit → DerivationTree Γ φ) : IO DerivationBenchmarkResult := do
  let (_, timeNs) ← timed (pure (derive ()))
  return { name, treeDepth := computeDepth result, constructionTimeNs := timeNs }
```

**Verification**:
- All benchmark derivations type-check
- Timing measurements are consistent across runs

---

### Phase 2: Semantic Evaluation Benchmarks

**Status**: [NOT STARTED]
**Estimated effort**: 2 hours

**Objectives**:
1. Benchmark formula evaluation in TaskModels
2. Measure validity checking across frame classes
3. Benchmark model construction

**Files to create**:
- `BimodalTest/Semantics/SemanticBenchmark.lean` (new)

**Benchmark categories**:

```lean
-- Category 1: Truth evaluation
- eval on atomic formulas
- eval on nested modal formulas (depth 1, 2, 5)
- eval on nested temporal formulas

-- Category 2: Validity checking
- valid on axiom schemas
- valid on non-valid formulas (should return false quickly)

-- Category 3: Model operations
- TaskFrame construction with varying world counts
- WorldHistory operations
- Context satisfaction checking
```

**Implementation pattern**:

```lean
structure SemanticBenchmarkResult where
  name : String
  result : Bool
  evaluationTimeNs : Nat
  deriving Repr

def runSemanticBenchmark (name : String) (eval : Unit → Bool) : IO SemanticBenchmarkResult := do
  let (result, timeNs) ← timed (pure (eval ()))
  return { name, result, evaluationTimeNs := timeNs }
```

**Verification**:
- Semantic benchmarks return expected results
- Performance scales reasonably with formula complexity

---

### Phase 3: Performance Targets Documentation

**Status**: [NOT STARTED]
**Estimated effort**: 1 hour

**Objectives**:
1. Document baseline performance measurements
2. Define regression thresholds
3. Document optimization recommendations

**Files to create**:
- `Bimodal/docs/project-info/PERFORMANCE_TARGETS.md` (new)

**Content structure**:

```markdown
# Bimodal Performance Targets

## Baseline Measurements

### Proof Search
| Benchmark | Target Time | Max Visits |
|-----------|-------------|------------|
| Modal T axiom | <10μs | <5 |
| Modal 4 axiom | <10μs | <5 |
| Complex bimodal | <1ms | <100 |

### Derivation Construction
| Benchmark | Target Time |
|-----------|-------------|
| Simple axiom | <5μs |
| MP chain (depth 5) | <50μs |

### Semantic Evaluation
| Benchmark | Target Time |
|-----------|-------------|
| Atomic eval | <1μs |
| Modal depth 3 | <20μs |

## Regression Thresholds

A regression is flagged when:
- Time increases by >2x for any benchmark
- Visits increase by >50% for proof search

## Optimization Recommendations

1. For modal-heavy proofs: use modalBase=3
2. For temporal-heavy proofs: use temporalBase=3
3. For deep proofs: increase maxDepth, use IDDFS
```

**Verification**:
- Targets are realistic (run benchmarks to verify)
- Documentation matches actual measurements

---

### Phase 4: CI Integration

**Status**: [NOT STARTED]
**Estimated effort**: 2 hours

**Objectives**:
1. Create benchmark runner script
2. Add baseline storage
3. Implement regression detection

**Files to create/modify**:
- `scripts/run-benchmarks.sh` (new)
- `.github/workflows/benchmark.yml` (new, if CI exists)
- `BimodalTest/Automation/ProofSearchBenchmark.lean` (enhance with JSON output)

**Implementation**:

1. **JSON output for benchmarks**
   ```lean
   def benchmarkResultToJson (result : BenchmarkResult) : String :=
     s!"\{\"name\": \"{result.name}\", \"found\": {result.found}, " ++
     s!"\"visits\": {result.visits}, \"timeNs\": {result.timeNs}\}"
   ```

2. **Benchmark runner script**
   ```bash
   #!/bin/bash
   # Run benchmarks and output JSON
   lake env lean BimodalTest/Automation/ProofSearchBenchmark.lean --run > benchmarks.json

   # Compare with baseline
   python3 scripts/compare-benchmarks.py baseline.json benchmarks.json
   ```

3. **Comparison script** (Python or simple Bash)
   - Load baseline and current results
   - Flag regressions exceeding thresholds
   - Exit with non-zero on regression

4. **CI workflow** (if GitHub Actions exists)
   ```yaml
   name: Benchmarks
   on: [push, pull_request]
   jobs:
     benchmark:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - name: Run benchmarks
           run: ./scripts/run-benchmarks.sh
         - name: Check for regressions
           run: ./scripts/compare-benchmarks.py
   ```

**Verification**:
- Scripts execute without errors
- Regressions are correctly detected
- CI runs successfully (if applicable)

---

## Dependencies

- Phase 1 and Phase 2 can be developed in parallel
- Phase 3 depends on Phase 1 and 2 (needs measurements)
- Phase 4 depends on all prior phases

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Timing variability | Medium | Run multiple iterations, use median |
| CI not configured | Low | Document manual benchmark process |
| Baseline drift | Low | Update baseline explicitly with version |

## Success Criteria

- [ ] DerivationBenchmark.lean covers axiom, MP, and modal rule performance
- [ ] SemanticBenchmark.lean covers eval, valid, and model operations
- [ ] PERFORMANCE_TARGETS.md documents baseline with realistic targets
- [ ] Benchmark runner script produces machine-readable output
- [ ] Regression detection flags >2x slowdowns
- [ ] Project builds without errors after all phases
