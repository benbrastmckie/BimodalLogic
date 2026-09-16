# Bimodal Performance Targets

Theory-specific performance baselines and regression thresholds for Bimodal TM logic.

> **Methodology**: See [BENCHMARKING_GUIDE.md](../development/BENCHMARKING_GUIDE.md)
> for project-wide benchmarking standards.

*Last updated: 2026-09-16*
*Baseline system: Lean 4 / Mathlib*

## Proof Search Benchmarks

Benchmarks for `FormalSystem.Automation.ProofSearch`:

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

**Benchmark file**: `Tests/BimodalTest/Automation/ProofSearchBenchmark.lean`

## Derivation Construction

Benchmarks for `FormalSystem.ProofSystem.Derivation`:

| Benchmark | Baseline Time | Tree Height | Regression Threshold |
|-----------|---------------|-------------|----------------------|
| Axiom (Modal T) | ~150ns | 0 | 2x time |
| Axiom (Modal 4) | ~150ns | 0 | 2x time |
| Axiom (Modal B) | ~150ns | 0 | 2x time |
| Axiom (Modal-Future) | ~150ns | 0 | 2x time |
| Assumption (single) | ~150ns | 0 | 2x time |
| Assumption (multiple) | ~150ns | 0 | 2x time |
| MP depth 1 | ~150ns | 1 | 2x time |
| MP depth 2 | ~150ns | 2 | 2x time |
| Necessitation (modal) | ~150ns | 1 | 2x time |
| Necessitation (temporal) | ~150ns | 1 | 2x time |
| Temporal duality | ~150ns | 1 | 2x time |
| Double necessitation | ~150ns | 2 | 2x time |
| Weakening (+1 formula) | ~150ns | 1 | 2x time |
| Weakening (+2 formulas) | ~150ns | 1 | 2x time |
| MP with axiom (□p ⊢ p) | ~150ns | 2 | 2x time |

**Benchmark file**: `Tests/BimodalTest/ProofSystem/DerivationBenchmark.lean`

Baselines re-measured 2026-09-16 on the current API and are indicative only: at this scale the
timer resolution dominates, so every construction reads as roughly the same median. `Axiom
(Modal-Future)` replaces the former `Axiom (Temporal 4)` row -- `temp_4` is no longer an axiom
constructor, and its derived replacement is `noncomputable`, so it cannot be run by `#eval`.
`Temporal duality` is now applied to the Modal-Future axiom. The file is not imported by the
test root (its trailing `#eval` would run on every `lake test`); the module-invariants gate
compiles, and so runs, it in isolation.

## Semantic Evaluation

There is currently no semantic-evaluation benchmark. The former suite advertised benchmarks for
`FormalSystem.Semantics.Truth` but never called `TruthAt`; it timed a hand-written `Bool` toy
evaluator instead, so its "Correctness: PASS" baselines checked nothing. It has been retired to
`FormalSystem/Boneyard/SemanticBenchmarkToyEvaluator/`, whose README records what a real
replacement would need.

## Optimization Recommendations

Based on Bimodal-specific benchmark analysis:

1. **Modal-heavy proofs**: Configure `HeuristicWeights.modalBase=3`
2. **Temporal-heavy proofs**: Configure `HeuristicWeights.temporalBase=3`
3. **Deep proofs**: Use IDDFS with `maxDepth≥20`
4. **Complex contexts**: Use BestFirst strategy

## Running Benchmarks

There is no aggregate runner script. Each suite ends in a top-level `#eval`, so elaborating the
file runs it:

```bash
lake env lean Tests/BimodalTest/Automation/ProofSearchBenchmark.lean
lake env lean Tests/BimodalTest/ProofSystem/DerivationBenchmark.lean
```

## Summary Statistics

| Category | Benchmarks | Average Time | Success Rate |
|----------|------------|--------------|--------------|
| Proof Search | 17 | ~300ns | 100% |
| Derivation | 15 | ~150ns | 100% |

## History

| Date | Change | Impact |
|------|--------|--------|
| 2026-01-12 | Initial baseline | First measurements |
| 2026-09-16 | Derivation suite repaired to the current API; semantic suite retired | Derivation baselines re-measured; `Temporal 4` row became `Modal-Future`; semantic section removed |
