import Bimodal.Automation.ProofSearch
import Bimodal.ProofSystem

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

namespace BimodalTest.Automation.Benchmark

open Bimodal.Syntax Bimodal.Automation Bimodal.ProofSystem

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
  timeNs : Nat := 0  -- Wall-clock time in nanoseconds
  deriving Repr

/-!
## Timing Utilities (Task 319 Phase 4)

Wall-clock timing for performance benchmarks.
-/

/-- Run an IO action and measure wall-clock time in nanoseconds. -/
def timed (action : IO α) : IO (α × Nat) := do
  let start ← IO.monoNanosNow
  let result ← action
  let stop ← IO.monoNanosNow
  return (result, stop - start)

/-- Format nanoseconds as human-readable string. -/
def formatNanos (ns : Nat) : String :=
  if ns < 1000 then
    s!"{ns}ns"
  else if ns < 1000000 then
    s!"{ns / 1000}μs"
  else if ns < 1000000000 then
    s!"{ns / 1000000}ms"
  else
    s!"{ns / 1000000000}s"

/-- Configuration for benchmark runs. -/
structure BenchmarkConfig where
  maxDepth : Nat := 20
  visitLimit : Nat := 1000
  weights : HeuristicWeights := {}
  deriving Inhabited

/-- Run a single benchmark with given configuration (pure version). -/
def runBenchmark (name : String) (ctx : Context) (goal : Formula)
    (config : BenchmarkConfig := {}) : BenchmarkResult :=
  let (found, _, _, stats, visits) :=
    search ctx goal (.IDDFS config.maxDepth) config.visitLimit config.weights
  { name, found, visits, hits := stats.hits, misses := stats.misses }

/-- Run a single benchmark with timing (IO version). -/
def runBenchmarkTimed (name : String) (ctx : Context) (goal : Formula)
    (config : BenchmarkConfig := {}) : IO BenchmarkResult := do
  let ((found, _, _, stats, visits), timeNs) ← timed (pure (
    search ctx goal (.IDDFS config.maxDepth) config.visitLimit config.weights))
  return { name, found, visits, hits := stats.hits, misses := stats.misses, timeNs }

/-- Print benchmark result. -/
def printResult (result : BenchmarkResult) : IO Unit :=
  let timeStr := if result.timeNs > 0 then s!", time={formatNanos result.timeNs}" else ""
  IO.println s!"{result.name}: found={result.found}, visits={result.visits}, hits={result.hits}{timeStr}"

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

/-!
## Timed Benchmark Suite (Task 319 Phase 4)

Run benchmarks with wall-clock timing for performance baseline.
-/

/-- Run a benchmark list with timing. -/
def runBenchmarksTimed (category : String) (benchmarks : List (String × Context × Formula))
    (config : BenchmarkConfig := {}) : IO (List BenchmarkResult) := do
  IO.println s!"=== {category} (Timed) ==="
  let mut results := []
  for (name, ctx, goal) in benchmarks do
    let result ← runBenchmarkTimed name ctx goal config
    printResult result
    results := result :: results
  return results.reverse

/-- Run all benchmarks with timing and summary. -/
def runAllBenchmarksTimed (config : BenchmarkConfig := {}) : IO Unit := do
  IO.println "╔══════════════════════════════════════════════════╗"
  IO.println "║     Proof Search Performance Benchmarks          ║"
  IO.println "╚══════════════════════════════════════════════════╝\n"

  let mut allResults := []

  -- Run each category
  let modalResults ← runBenchmarksTimed "Modal Axioms" modalBenchmarks config
  allResults := allResults ++ modalResults
  IO.println ""

  let temporalResults ← runBenchmarksTimed "Temporal Axioms" temporalBenchmarks config
  allResults := allResults ++ temporalResults
  IO.println ""

  let propResults ← runBenchmarksTimed "Propositional Axioms" propBenchmarks config
  allResults := allResults ++ propResults
  IO.println ""

  let mixedResults ← runBenchmarksTimed "Mixed Modal-Temporal" mixedBenchmarks config
  allResults := allResults ++ mixedResults
  IO.println ""

  let ctxResults ← runBenchmarksTimed "Context-Based" contextBenchmarks config
  allResults := allResults ++ ctxResults

  -- Summary with timing
  IO.println "\n═══════════════════════════════════════════════════"
  IO.println "                    SUMMARY"
  IO.println "═══════════════════════════════════════════════════"
  let found := allResults.filter (·.found) |>.length
  let total := allResults.length
  let visits := allResults.foldl (fun acc r => acc + r.visits) 0
  let totalTimeNs := allResults.foldl (fun acc r => acc + r.timeNs) 0
  let avgTimeNs := if total > 0 then totalTimeNs / total else 0
  IO.println s!"Benchmarks: {found}/{total} found"
  IO.println s!"Total visits: {visits}"
  IO.println s!"Total time: {formatNanos totalTimeNs}"
  IO.println s!"Average time per benchmark: {formatNanos avgTimeNs}"

/-- Compare strategies with timing. -/
def compareStrategiesTimed (benchmarks : List (String × Context × Formula)) : IO Unit := do
  IO.println "=== Strategy Comparison (Timed) ==="

  let strategies : List (String × SearchStrategy) := [
    ("BoundedDFS-5", .BoundedDFS 5),
    ("BoundedDFS-10", .BoundedDFS 10),
    ("IDDFS-10", .IDDFS 10),
    ("IDDFS-20", .IDDFS 20),
    ("BestFirst-1000", .BestFirst 1000),
    ("BestFirst-10000", .BestFirst 10000)
  ]

  for (stratName, strat) in strategies do
    IO.println s!"\n--- {stratName} ---"
    let mut totalVisits := 0
    let mut totalFound := 0
    let mut totalTimeNs := 0
    for (_, ctx, goal) in benchmarks do
      let (result, timeNs) ← timed (pure (search ctx goal strat 1000))
      let (found, _, _, _, visits) := result
      totalVisits := totalVisits + visits
      totalTimeNs := totalTimeNs + timeNs
      if found then totalFound := totalFound + 1
    IO.println s!"Found: {totalFound}/{benchmarks.length}"
    IO.println s!"Total visits: {totalVisits}"
    IO.println s!"Total time: {formatNanos totalTimeNs}"

/-!
## Learning-Enabled Benchmarks (Task 176)

Benchmarks that test pattern learning across multiple proof attempts.
-/

/-- Run benchmarks with pattern learning enabled. -/
def runLearningBenchmarks (benchmarks : List (String × Context × Formula))
    (config : BenchmarkConfig := {}) : IO Unit := do
  IO.println "=== Pattern Learning Benchmarks ==="

  -- First pass: no learning
  IO.println "\n--- First Pass (No Learning) ---"
  let mut db := PatternDatabase.empty
  let mut firstPassVisits := 0
  let mut firstPassFound := 0

  for (name, ctx, goal) in benchmarks do
    let result := search_with_learning ctx goal (.IDDFS config.maxDepth) config.visitLimit config.weights db true
    if result.found then
      firstPassFound := firstPassFound + 1
      db := result.patternDb
    firstPassVisits := firstPassVisits + result.visits
    IO.println s!"{name}: found={result.found}, visits={result.visits}"

  IO.println s!"\nFirst pass total: {firstPassFound}/{benchmarks.length} found, {firstPassVisits} visits"
  IO.println s!"Patterns learned: {db.totalPatterns}"

  -- Second pass: with learned patterns
  IO.println "\n--- Second Pass (With Learning) ---"
  let mut secondPassVisits := 0
  let mut secondPassFound := 0

  for (name, ctx, goal) in benchmarks do
    let result := search_with_learning ctx goal (.IDDFS config.maxDepth) config.visitLimit config.weights db false
    if result.found then secondPassFound := secondPassFound + 1
    secondPassVisits := secondPassVisits + result.visits
    IO.println s!"{name}: found={result.found}, visits={result.visits}"

  IO.println s!"\nSecond pass total: {secondPassFound}/{benchmarks.length} found, {secondPassVisits} visits"

  -- Report improvement
  if firstPassVisits > 0 then
    let improvement := (firstPassVisits - secondPassVisits) * 100 / firstPassVisits
    IO.println s!"Visit reduction: {improvement}%"

/-- Compare IDDFS vs BestFirst on various formula types. -/
def compareIDDFSvsBestFirst (config : BenchmarkConfig := {}) : IO Unit := do
  IO.println "=== IDDFS vs BestFirst Comparison ==="

  let benchmarkCategories := [
    ("Modal Axioms", modalBenchmarks),
    ("Temporal Axioms", temporalBenchmarks),
    ("Propositional Axioms", propBenchmarks),
    ("Mixed Modal-Temporal", mixedBenchmarks),
    ("Context-Based", contextBenchmarks)
  ]

  for (category, benchmarks) in benchmarkCategories do
    IO.println s!"\n{category}:"

    -- IDDFS results
    let mut iddfsVisits := 0
    let mut iddfsFound := 0
    for (_, ctx, goal) in benchmarks do
      let (found, _, _, _, visits) := search ctx goal (.IDDFS config.maxDepth) config.visitLimit config.weights
      iddfsVisits := iddfsVisits + visits
      if found then iddfsFound := iddfsFound + 1

    -- BestFirst results
    let mut bfVisits := 0
    let mut bfFound := 0
    for (_, ctx, goal) in benchmarks do
      let (found, _, _, _, visits) := search ctx goal (.BestFirst config.visitLimit) config.visitLimit config.weights
      bfVisits := bfVisits + visits
      if found then bfFound := bfFound + 1

    IO.println s!"  IDDFS:     {iddfsFound}/{benchmarks.length} found, {iddfsVisits} visits"
    IO.println s!"  BestFirst: {bfFound}/{benchmarks.length} found, {bfVisits} visits"

    -- Compare
    if iddfsFound == bfFound && iddfsVisits > 0 && bfVisits > 0 then
      if bfVisits < iddfsVisits then
        let improvement := (iddfsVisits - bfVisits) * 100 / iddfsVisits
        IO.println s!"  BestFirst: {improvement}% fewer visits"
      else if bfVisits > iddfsVisits then
        let overhead := (bfVisits - iddfsVisits) * 100 / iddfsVisits
        IO.println s!"  IDDFS: {overhead}% fewer visits"
      else
        IO.println s!"  Equal visit count"

end BimodalTest.Automation.Benchmark

/-!
## Run Benchmarks
-/

-- Run all benchmarks with default configuration
#eval BimodalTest.Automation.Benchmark.runAllBenchmarks

-- Compare weight configurations
#eval do
  let allBenchmarks :=
    BimodalTest.Automation.Benchmark.modalBenchmarks ++
    BimodalTest.Automation.Benchmark.temporalBenchmarks ++
    BimodalTest.Automation.Benchmark.propBenchmarks
  BimodalTest.Automation.Benchmark.compareWeights allBenchmarks
    BimodalTest.Automation.Benchmark.weightConfigs

-- Run timed benchmarks (Task 319 Phase 4)
#eval BimodalTest.Automation.Benchmark.runAllBenchmarksTimed

-- Compare strategies with timing (includes BestFirst)
#eval do
  let allBenchmarks :=
    BimodalTest.Automation.Benchmark.modalBenchmarks ++
    BimodalTest.Automation.Benchmark.temporalBenchmarks ++
    BimodalTest.Automation.Benchmark.propBenchmarks
  BimodalTest.Automation.Benchmark.compareStrategiesTimed allBenchmarks

-- Run learning benchmarks (Task 176)
#eval do
  let allBenchmarks :=
    BimodalTest.Automation.Benchmark.modalBenchmarks ++
    BimodalTest.Automation.Benchmark.temporalBenchmarks ++
    BimodalTest.Automation.Benchmark.propBenchmarks
  BimodalTest.Automation.Benchmark.runLearningBenchmarks allBenchmarks

-- Compare IDDFS vs BestFirst (Task 176)
#eval BimodalTest.Automation.Benchmark.compareIDDFSvsBestFirst
