import Logos.Core.Automation.ProofSearch
import Logos.Core.ProofSystem

/-!
# Proof Search Benchmark Suite

Benchmarks for evaluating proof search performance with different heuristic configurations.
Supports comparison of search strategies and tuning of heuristic weights.

## Usage

```lean
-- Run all benchmarks
#eval runAllBenchmarks

-- Run specific benchmark category
#eval runModalBenchmarks
#eval runTemporalBenchmarks
#eval runMixedBenchmarks
```

## Metrics

- **visits**: Total nodes visited during search
- **found**: Whether proof was found
- **depth**: Depth at which proof was found (if any)
-/

namespace LogosTest.Core.Automation.Benchmark

open Logos.Core.Syntax Logos.Core.Automation Logos.Core.ProofSystem

-- Convenience abbreviations
abbrev p : Formula := .atom "p"
abbrev q : Formula := .atom "q"
abbrev r : Formula := .atom "r"

/-- Benchmark result for a single proof attempt. -/
structure BenchmarkResult where
  name : String
  found : Bool
  visits : Nat
  hits : Nat
  misses : Nat
  deriving Repr

/-- Configuration for benchmark runs. -/
structure BenchmarkConfig where
  maxDepth : Nat := 20
  visitLimit : Nat := 1000
  weights : HeuristicWeights := {}
  deriving Inhabited

/-- Run a single benchmark with given configuration. -/
def runBenchmark (name : String) (ctx : Context) (goal : Formula)
    (config : BenchmarkConfig := {}) : BenchmarkResult :=
  let (found, _, _, stats, visits) :=
    search ctx goal (.IDDFS config.maxDepth) config.visitLimit config.weights
  { name, found, visits, hits := stats.hits, misses := stats.misses }

/-- Print benchmark result. -/
def printResult (result : BenchmarkResult) : IO Unit :=
  IO.println s!"{result.name}: found={result.found}, visits={result.visits}, hits={result.hits}"

/-!
## Modal Axiom Benchmarks
-/

/-- Modal axiom benchmarks. -/
def modalBenchmarks : List (String × Context × Formula) := [
  ("Modal T (□p → p)", [], (Formula.box p).imp p),
  ("Modal 4 (□p → □□p)", [], (Formula.box p).imp (Formula.box (Formula.box p))),
  ("Modal 5 (◇□p → □p)", [], (Formula.box p).diamond.imp (Formula.box p)),
  ("Modal B (p → □◇p)", [], p.imp (Formula.box p.diamond)),
  ("Modal K dist", [], (Formula.box (p.imp q)).imp ((Formula.box p).imp (Formula.box q)))
]

def runModalBenchmarks (config : BenchmarkConfig := {}) : IO (List BenchmarkResult) := do
  IO.println "=== Modal Axiom Benchmarks ==="
  let mut results := []
  for (name, ctx, goal) in modalBenchmarks do
    let result := runBenchmark name ctx goal config
    printResult result
    results := result :: results
  return results.reverse

/-!
## Temporal Axiom Benchmarks
-/

/-- Temporal axiom benchmarks. -/
def temporalBenchmarks : List (String × Context × Formula) := [
  ("Temporal 4 (Gp → GGp)", [], (Formula.all_future p).imp (Formula.all_future (Formula.all_future p))),
  ("Temporal A (p → GHp)", [], p.imp (Formula.all_future (Formula.some_past p))),
  ("Temporal K dist", [], (Formula.all_future (p.imp q)).imp ((Formula.all_future p).imp (Formula.all_future q)))
]

def runTemporalBenchmarks (config : BenchmarkConfig := {}) : IO (List BenchmarkResult) := do
  IO.println "=== Temporal Axiom Benchmarks ==="
  let mut results := []
  for (name, ctx, goal) in temporalBenchmarks do
    let result := runBenchmark name ctx goal config
    printResult result
    results := result :: results
  return results.reverse

/-!
## Propositional Axiom Benchmarks
-/

/-- Propositional axiom benchmarks. -/
def propBenchmarks : List (String × Context × Formula) := [
  ("Prop K", [], (p.imp (q.imp r)).imp ((p.imp q).imp (p.imp r))),
  ("Prop S", [], p.imp (q.imp p)),
  ("Ex Falso", [], Formula.bot.imp p),
  ("Peirce", [], ((p.imp q).imp p).imp p)
]

def runPropBenchmarks (config : BenchmarkConfig := {}) : IO (List BenchmarkResult) := do
  IO.println "=== Propositional Axiom Benchmarks ==="
  let mut results := []
  for (name, ctx, goal) in propBenchmarks do
    let result := runBenchmark name ctx goal config
    printResult result
    results := result :: results
  return results.reverse

/-!
## Mixed Modal-Temporal Benchmarks
-/

/-- Mixed modal-temporal benchmarks. -/
def mixedBenchmarks : List (String × Context × Formula) := [
  ("Modal-Future (□p → □Gp)", [], (Formula.box p).imp (Formula.box (Formula.all_future p))),
  ("Future-Modal (□p → G□p)", [], (Formula.box p).imp (Formula.all_future (Formula.box p)))
]

def runMixedBenchmarks (config : BenchmarkConfig := {}) : IO (List BenchmarkResult) := do
  IO.println "=== Mixed Modal-Temporal Benchmarks ==="
  let mut results := []
  for (name, ctx, goal) in mixedBenchmarks do
    let result := runBenchmark name ctx goal config
    printResult result
    results := result :: results
  return results.reverse

/-!
## Context-Based Benchmarks
-/

/-- Benchmarks with non-empty context. -/
def contextBenchmarks : List (String × Context × Formula) := [
  ("Assumption (p ⊢ p)", [p], p),
  ("MP ready (p→q, p ⊢ q)", [p.imp q, p], q),
  ("Complex ctx", [p.imp q, q.imp r, p], r)
]

def runContextBenchmarks (config : BenchmarkConfig := {}) : IO (List BenchmarkResult) := do
  IO.println "=== Context-Based Benchmarks ==="
  let mut results := []
  for (name, ctx, goal) in contextBenchmarks do
    let result := runBenchmark name ctx goal config
    printResult result
    results := result :: results
  return results.reverse

/-!
## Weight Tuning
-/

/-- Predefined weight configurations for comparison. -/
def weightConfigs : List (String × HeuristicWeights) := [
  ("Default", {}),
  ("Modal-Optimized", { modalBase := 3, temporalBase := 7 }),
  ("Temporal-Optimized", { modalBase := 7, temporalBase := 3 }),
  ("Low-Context", { contextPenaltyWeight := 0 }),
  ("High-Complexity", { mpComplexityWeight := 3 })
]

/-- Compare weight configurations on a benchmark suite. -/
def compareWeights (benchmarks : List (String × Context × Formula))
    (configs : List (String × HeuristicWeights)) : IO Unit := do
  IO.println "=== Weight Configuration Comparison ==="
  for (configName, weights) in configs do
    IO.println s!"\n--- {configName} ---"
    let mut totalVisits := 0
    let mut totalFound := 0
    for (name, ctx, goal) in benchmarks do
      let config : BenchmarkConfig := { weights }
      let result := runBenchmark name ctx goal config
      totalVisits := totalVisits + result.visits
      if result.found then totalFound := totalFound + 1
    IO.println s!"Total: {totalFound}/{benchmarks.length} found, {totalVisits} visits"

/-!
## All Benchmarks
-/

/-- Run all benchmark suites. -/
def runAllBenchmarks (config : BenchmarkConfig := {}) : IO Unit := do
  let _ ← runModalBenchmarks config
  let _ ← runTemporalBenchmarks config
  let _ ← runPropBenchmarks config
  let _ ← runMixedBenchmarks config
  let _ ← runContextBenchmarks config
  return ()

/-- Summarize benchmark results. -/
def summarizeBenchmarks (results : List BenchmarkResult) : IO Unit := do
  let found := results.filter (·.found) |>.length
  let total := results.length
  let visits := results.foldl (fun acc r => acc + r.visits) 0
  IO.println s!"\nSummary: {found}/{total} found, {visits} total visits"

end LogosTest.Core.Automation.Benchmark

/-!
## Run Benchmarks
-/

-- Run all benchmarks with default configuration
#eval LogosTest.Core.Automation.Benchmark.runAllBenchmarks

-- Compare weight configurations
#eval do
  let allBenchmarks :=
    LogosTest.Core.Automation.Benchmark.modalBenchmarks ++
    LogosTest.Core.Automation.Benchmark.temporalBenchmarks ++
    LogosTest.Core.Automation.Benchmark.propBenchmarks
  LogosTest.Core.Automation.Benchmark.compareWeights allBenchmarks
    LogosTest.Core.Automation.Benchmark.weightConfigs
