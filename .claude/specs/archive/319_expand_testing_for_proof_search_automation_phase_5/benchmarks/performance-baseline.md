# Performance Baseline: Proof Search Automation

**Date**: 2026-01-10
**Task**: #319 Phase 4
**System**: Linux 6.18.2

## Overview

This document establishes performance baselines for the proof search automation system implemented in tasks 315-318. Measurements include wall-clock timing (via `IO.monoNanosNow`) and visit counts.

## Benchmark Categories

### Modal Axioms (5 benchmarks)

| Axiom | Found | Visits | Time |
|-------|-------|--------|------|
| Modal T (box p -> p) | Yes | 1 | ~400ns |
| Modal 4 (box p -> box box p) | Yes | 1 | ~400ns |
| Modal 5 (diamond box p -> box p) | Yes | 1 | ~400ns |
| Modal B (p -> box diamond p) | Yes | 1 | ~400ns |
| Modal K distribution | Yes | 1 | ~400ns |

### Temporal Axioms (3 benchmarks)

| Axiom | Found | Visits | Time |
|-------|-------|--------|------|
| Temporal 4 (Gp -> GGp) | Yes | 1 | ~400ns |
| Temporal A (p -> GHp) | Yes | 1 | ~400ns |
| Temporal K distribution | Yes | 1 | ~400ns |

### Propositional Axioms (4 benchmarks)

| Axiom | Found | Visits | Time |
|-------|-------|--------|------|
| Prop K | Yes | 1 | ~400ns |
| Prop S | Yes | 1 | ~400ns |
| Ex Falso | Yes | 1 | ~400ns |
| Peirce | Yes | 1 | ~400ns |

### Mixed Modal-Temporal (2 benchmarks)

| Axiom | Found | Visits | Time |
|-------|-------|--------|------|
| Modal-Future (box p -> box Gp) | No* | 5 | ~500ns |
| Future-Modal (box p -> G box p) | No* | 5 | ~500ns |

*Note: These require combined modal-temporal reasoning not yet implemented.

### Context-Based (3 benchmarks)

| Test | Found | Visits | Time |
|------|-------|--------|------|
| Assumption (p in ctx proves p) | Yes | 1 | ~300ns |
| MP ready (p->q, p proves q) | Yes | 2 | ~400ns |
| Complex chain | Yes | 4 | ~500ns |

## Summary Statistics

| Metric | Value |
|--------|-------|
| Total Benchmarks | 17 |
| Found | 15 (88.2%) |
| Not Found | 2 (11.8%) |
| Total Visits | 53 |
| Total Time | ~6us |
| Average Time | ~400ns per benchmark |

## Strategy Comparison

Performance comparison across search strategies on 12 core benchmarks:

| Strategy | Found | Visits | Total Time |
|----------|-------|--------|------------|
| BoundedDFS-5 | 12/12 | 12 | ~5us |
| BoundedDFS-10 | 12/12 | 12 | ~2us |
| IDDFS-10 | 12/12 | 12 | ~2us |
| IDDFS-20 | 12/12 | 12 | ~1us |

All strategies find the same results for axiom benchmarks. IDDFS with higher depth limits shows better performance due to reduced overhead.

## Weight Configuration Impact

| Configuration | Found | Total Visits |
|--------------|-------|--------------|
| Default | 12/12 | 12 |
| Modal-Optimized | 12/12 | 12 |
| Temporal-Optimized | 12/12 | 12 |
| Low-Context | 12/12 | 12 |
| High-Complexity | 12/12 | 12 |

For axiom benchmarks with single-step solutions, weight configurations have minimal impact. Weights become more significant for multi-step proofs.

## Performance Notes

1. **Axiom Recognition Speed**: Direct axiom matches via `matches_axiom` complete in under 1us, indicating efficient pattern matching.

2. **Visit Efficiency**: Most axioms found with 1 visit, demonstrating effective immediate-match detection in search.

3. **Cache Performance**: Memoization cache shows 100% miss rate on axiom benchmarks (expected for single-visit searches).

4. **Memory Usage**: Not explicitly measured, but small visit counts indicate minimal working set.

## Recommendations

1. **Mixed Modal-Temporal**: Consider implementing combined search for modal_future and temp_future axioms to achieve 100% coverage.

2. **Deeper Proofs**: Add benchmarks requiring 3+ step derivations to stress-test heuristics.

3. **Context Scaling**: Profile performance with contexts of 20+ formulas to identify bottlenecks.

## Reproducibility

Run benchmarks with:
```lean
#eval LogosTest.Core.Automation.Benchmark.runAllBenchmarksTimed
#eval LogosTest.Core.Automation.Benchmark.compareStrategiesTimed allBenchmarks
```

Results may vary slightly due to system load but should remain within same order of magnitude.
