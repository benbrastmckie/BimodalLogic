# Bimodal Performance Targets

Theory-specific performance baselines and regression thresholds for Bimodal TM logic.

> **Methodology**: See [BENCHMARKING_GUIDE.md](../../../docs/Development/BENCHMARKING_GUIDE.md)
> for project-wide benchmarking standards.

*Last updated: 2026-01-12*
*Baseline system: Lean 4 / Mathlib*

## Proof Search Benchmarks

Benchmarks for `Bimodal.Automation.ProofSearch`:

| Benchmark | Baseline Time | Max Visits | Regression Threshold |
|-----------|---------------|------------|----------------------|
| Modal T (□p → p) | ~2μs | 1 | 2x time OR 50% visits |
| Modal 4 (□p → □□p) | ~230ns | 1 | 2x time OR 50% visits |
| Modal 5 (◇□p → □p) | ~170ns | 1 | 2x time OR 50% visits |
| Modal B (p → □◇p) | ~220ns | 1 | 2x time OR 50% visits |
| Modal K dist | ~210ns | 1 | 2x time OR 50% visits |
| Temporal 4 (Gp → GGp) | ~280ns | 1 | 2x time OR 50% visits |
| Temporal A (p → GHp) | ~240ns | 1 | 2x time OR 50% visits |
| Temporal K dist | ~240ns | 1 | 2x time OR 50% visits |
| Prop K | ~270ns | 1 | 2x time OR 50% visits |
| Prop S | ~270ns | 1 | 2x time OR 50% visits |
| Modal-Future (□p → □Gp) | ~250ns | 1 | 2x time OR 50% visits |
| Future-Modal (□p → G□p) | ~250ns | 1 | 2x time OR 50% visits |

**Benchmark file**: `BimodalTest/Automation/ProofSearchBenchmark.lean`

## Derivation Construction

Benchmarks for `Bimodal.ProofSystem.Derivation`:

| Benchmark | Baseline Time | Tree Height | Regression Threshold |
|-----------|---------------|-------------|----------------------|
| Axiom (Modal T) | ~100ns | 0 | 2x time |
| Axiom (Modal 4) | ~80ns | 0 | 2x time |
| Axiom (Modal B) | ~90ns | 0 | 2x time |
| Axiom (Temporal 4) | ~90ns | 0 | 2x time |
| Assumption (single) | ~90ns | 0 | 2x time |
| Assumption (multiple) | ~90ns | 0 | 2x time |
| MP depth 1 | ~90ns | 1 | 2x time |
| MP depth 2 | ~90ns | 2 | 2x time |
| Necessitation (modal) | ~90ns | 1 | 2x time |
| Necessitation (temporal) | ~90ns | 1 | 2x time |
| Temporal duality | ~90ns | 1 | 2x time |
| Double necessitation | ~90ns | 2 | 2x time |
| Weakening (+1 formula) | ~90ns | 1 | 2x time |
| Weakening (+2 formulas) | ~90ns | 1 | 2x time |
| MP with axiom (□p ⊢ p) | ~90ns | 2 | 2x time |

**Benchmark file**: `BimodalTest/ProofSystem/DerivationBenchmark.lean`

## Semantic Evaluation

Benchmarks for `Bimodal.Semantics.Truth`:

| Benchmark | Baseline Time | Correctness | Regression Threshold |
|-----------|---------------|-------------|----------------------|
| Atom p (true) | ~90ns | PASS | 2x time |
| Atom q (false) | ~90ns | PASS | 2x time |
| Bot (false) | ~90ns | PASS | 2x time |
| Box depth 1 (□p) | ~90ns | PASS | 2x time |
| Box depth 3 (□□□p) | ~100ns | PASS | 2x time |
| Box depth 5 (□□□□□p) | ~100ns | PASS | 2x time |
| Gp (all future) | ~90ns | PASS | 2x time |
| Hp (all past) | ~90ns | PASS | 2x time |
| p → p (true) | ~90ns | PASS | 2x time |
| p → q (false) | ~90ns | PASS | 2x time |
| q → p (true) | ~90ns | PASS | 2x time |
| p → (q → p) (true) | ~90ns | PASS | 2x time |
| □p → p (true) | ~90ns | PASS | 2x time |
| p → □p (true) | ~90ns | PASS | 2x time |
| K distribution (true) | ~100ns | PASS | 2x time |

**Benchmark file**: `BimodalTest/Semantics/SemanticBenchmark.lean`

## Optimization Recommendations

Based on Bimodal-specific benchmark analysis:

1. **Modal-heavy proofs**: Configure `HeuristicWeights.modalBase=3`
2. **Temporal-heavy proofs**: Configure `HeuristicWeights.temporalBase=3`
3. **Deep proofs**: Use IDDFS with `maxDepth≥20`
4. **Complex contexts**: Use BestFirst strategy

## Running Benchmarks

```bash
# Run all Bimodal benchmarks
./scripts/run-benchmarks.sh

# Run individual suites
lake env lean --run BimodalTest/Automation/ProofSearchBenchmark.lean
lake env lean --run BimodalTest/ProofSystem/DerivationBenchmark.lean
lake env lean --run BimodalTest/Semantics/SemanticBenchmark.lean
```

## Summary Statistics

| Category | Benchmarks | Average Time | Success Rate |
|----------|------------|--------------|--------------|
| Proof Search | 17 | ~300ns | 100% |
| Derivation | 15 | ~90ns | 100% |
| Semantic | 16 | ~91ns | 100% (16/16 correct) |

## History

| Date | Change | Impact |
|------|--------|--------|
| 2026-01-12 | Initial baseline | First measurements |
