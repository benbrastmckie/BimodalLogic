# Performance Benchmarking Guide

Project-wide standards for performance benchmarking in ProofChecker.

## Purpose

Performance benchmarks serve three goals:

1. **Regression detection** - Catch slowdowns before they reach main
2. **Optimization guidance** - Identify bottlenecks worth optimizing
3. **Baseline documentation** - Track performance evolution

## Benchmark Categories

All theories should benchmark these operation types:

| Category | What to Measure | Example |
|----------|-----------------|---------|
| Proof Search | Time, visits, depth | Finding proofs for axiom schemas |
| Derivation | Construction time, tree height | Building proof trees |
| Semantics | Evaluation time, correctness | Truth/validity checking |

## Implementation Standards

### Timing

- Use wall-clock timing (`IO.monoNanosNow`)
- Run **100+ iterations** and take **median** for stability
- Report in appropriate units (ns/μs/ms)

Example timing utility:

```lean
/-- Run an IO action and measure wall-clock time in nanoseconds. -/
def timed {α : Type} (action : IO α) : IO (α × Nat) := do
  let start ← IO.monoNanosNow
  let result ← action
  let stop ← IO.monoNanosNow
  return (result, stop - start)
```

### Correctness Validation

- Semantic benchmarks **MUST** validate expected results
- Compile-time type checking validates derivation benchmarks
- Report `correct: true/false` in results

Example validation pattern:

```lean
structure SemanticBenchmarkResult where
  name : String
  expectedResult : Bool
  actualResult : Bool
  evaluationTimeNs : Nat
  correct : Bool := (expectedResult == actualResult)
```

### Output Format

- **Human-readable output** for development
- **JSON output** for CI integration

Human-readable example:
```
Atom p (true): expected=true, actual=true, time=90ns ✓
```

JSON example:
```json
{"name":"Atom p","expected":true,"actual":true,"timeNs":90,"correct":true}
```

### Regression Thresholds

| Metric | Threshold | Action |
|--------|-----------|--------|
| Time | **>2x slowdown** | Triggers regression |
| Visits (proof search) | **>50% increase** | Triggers regression |
| Correctness | **Any failure** | Blocks merge |

## Theory-Specific Targets

Each theory maintains its own baseline measurements:

- **Bimodal**: [PERFORMANCE_TARGETS.md](../../Bimodal/docs/project-info/PERFORMANCE_TARGETS.md)
- **Logos**: (planned)

## Benchmark File Organization

Benchmark files follow this structure:

```
{Theory}Test/
├── Automation/
│   └── ProofSearchBenchmark.lean    # Proof search benchmarks
├── ProofSystem/
│   └── DerivationBenchmark.lean     # Derivation benchmarks
└── Semantics/
    └── SemanticBenchmark.lean       # Semantic benchmarks
```

## CI Integration

### Running Benchmarks

```bash
# Run all benchmarks for a theory
./scripts/run-benchmarks.sh

# Run individual benchmark suites
lake env lean --run BimodalTest/Automation/ProofSearchBenchmark.lean
lake env lean --run BimodalTest/ProofSystem/DerivationBenchmark.lean
lake env lean --run BimodalTest/Semantics/SemanticBenchmark.lean
```

### Regression Detection

See `scripts/check-regression.sh` for automated regression detection.

The script:
1. Runs current benchmarks
2. Compares against baseline
3. Exits with error if regression detected

### Baseline Management

- Baselines stored in `benchmarks/baseline.json`
- Update baseline only intentionally (e.g., after optimization)
- Document baseline changes in commit message

## Adding New Benchmarks

### Step 1: Create Benchmark File

Create `{Theory}Test/{Category}/{Name}Benchmark.lean`:

```lean
import Theory.Module
import TheoryTest.Automation.ProofSearchBenchmark  -- For timing utilities

namespace TheoryTest.Category.Benchmark

-- Import timing utilities
open TheoryTest.Automation.Benchmark (timed formatNanos)

-- Define benchmark result structure
structure BenchmarkResult where
  name : String
  timeNs : Nat
  -- Add category-specific fields
  deriving Repr

-- Implement benchmarks
def runBenchmarks : IO (List BenchmarkResult) := do
  -- ...

-- JSON output for CI
def resultToJson (r : BenchmarkResult) : String :=
  "{" ++ s!"\"name\":\"{r.name}\",\"timeNs\":{r.timeNs}" ++ "}"

end TheoryTest.Category.Benchmark

#eval TheoryTest.Category.Benchmark.runBenchmarks
```

### Step 2: Document Baselines

Add baselines to theory's `PERFORMANCE_TARGETS.md`:

```markdown
| Benchmark | Baseline Time | Regression Threshold |
|-----------|---------------|----------------------|
| New Benchmark | {measured} | 2x time |
```

### Step 3: Add to CI Runner

Update `scripts/run-benchmarks.sh` to include new benchmark.

## Best Practices

### Do

- Benchmark representative operations
- Use stable, reproducible test cases
- Run sufficient iterations for statistical significance
- Validate correctness alongside timing
- Document what each benchmark measures

### Don't

- Benchmark trivial operations (noise dominates)
- Use non-deterministic inputs
- Include I/O in timed sections
- Commit failing benchmarks
- Change baselines without review

## Interpreting Results

### Normal Variation

Expect ±20% variation between runs due to:
- System load
- CPU thermal throttling
- Memory pressure

Use median of 100+ runs to reduce noise.

### Investigating Regressions

1. Run benchmark multiple times to confirm
2. Check for code changes in affected area
3. Profile with `lake env lean --profile`
4. Compare before/after commits

### Optimization Guidance

Prioritize optimizations by:
1. **Impact**: How much time is spent in this operation?
2. **Frequency**: How often is this operation called?
3. **Feasibility**: How hard is the optimization?

## References

- [QUALITY_METRICS.md](QUALITY_METRICS.md) - Overall quality standards
- [TESTING_STANDARDS.md](TESTING_STANDARDS.md) - Testing requirements
- [Bimodal Performance Targets](../../Bimodal/docs/project-info/PERFORMANCE_TARGETS.md) - Theory-specific baselines
