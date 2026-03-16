# Benchmarks

Performance benchmark data and results.

## Contents

| File | Description |
|------|-------------|
| baseline.json | Baseline benchmark measurements |
| current.json | Current benchmark measurements |

## Purpose

Benchmark data tracks performance of proof search, tactic execution, and
build times. Used for regression detection and optimization.

## Running Benchmarks

```bash
./scripts/run-benchmarks.sh
```

Results are written to `current.json` for comparison against `baseline.json`.

---

*Last Updated: 2026-03-16*
