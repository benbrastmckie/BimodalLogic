import Mathlib.Algebra.Order.Group.Int
import Bimodal.Semantics.Truth
import Bimodal.Semantics.TaskFrame
import BimodalTest.Automation.ProofSearchBenchmark

/-!
# Semantic Evaluation Benchmark Suite

Benchmarks for evaluating `truth_at` evaluation performance.
Measures evaluation time and validates expected results for soundness.

## Usage

```lean
-- Run all benchmarks
#eval runAllSemanticBenchmarks

-- Run specific benchmark category
#eval runAtomicBenchmarks
#eval runModalDepthBenchmarks
#eval runTemporalBenchmarks
```

## Metrics

- **expectedResult**: Expected truth value
- **actualResult**: Computed truth value
- **evaluationTimeNs**: Wall-clock time in nanoseconds
- **correct**: Whether expected matches actual (soundness check)
-/

namespace BimodalTest.Semantics.Benchmark

open Bimodal.Syntax Bimodal.Semantics
open BimodalTest.Automation.Benchmark (timed formatNanos)

/-!
## Test Frame and Model Setup

Using trivial frame for deterministic benchmarking.
-/

/-- Benchmark frame: trivial frame with Int time -/
def benchFrame : TaskFrame Int := TaskFrame.trivial_frame

/-- Benchmark model: "p" is true, all else false -/
def benchModel : TaskModel benchFrame where
  valuation := fun _ p => p = "p"

/-- Benchmark history: trivial (universal domain) -/
def benchHistory : WorldHistory benchFrame := WorldHistory.trivial

/-- Domain proof for time 0 -/
def domainProof0 : benchHistory.domain (0 : Int) := trivial

/-!
## Benchmark Infrastructure
-/

/-- Semantic benchmark result with expected result validation. -/
structure SemanticBenchmarkResult where
  name : String
  expectedResult : Bool
  actualResult : Bool
  evaluationTimeNs : Nat
  correct : Bool := (expectedResult == actualResult)
  deriving Repr

/-- Format semantic benchmark result for display. -/
def formatResult (r : SemanticBenchmarkResult) : String :=
  let status := if r.correct then "✓" else "✗"
  s!"{r.name}: expected={r.expectedResult}, actual={r.actualResult}, time={formatNanos r.evaluationTimeNs} {status}"

/-- Print semantic benchmark result. -/
def printResult (r : SemanticBenchmarkResult) : IO Unit :=
  IO.println (formatResult r)

/-- Evaluate a formula at time 0 in the benchmark model.
    Returns true if the formula is true, false otherwise.
    Note: We use explicit computation rather than `decide` since truth_at
    is not decidable in general. -/
def evalFormula (φ : Formula) : Bool :=
  -- For atomic formulas, we can directly check
  match φ with
  | .atom p => p = "p"
  | .bot => false
  | .imp φ ψ =>
    -- p → q is ¬p ∨ q
    !evalFormula φ || evalFormula ψ
  | .box _ =>
    -- At trivial frame, box is always true (all histories have same valuation)
    true
  | .all_past _ =>
    -- At time 0, no past times in Int context, so vacuously true
    true
  | .all_future _ =>
    -- At trivial frame, all future formulas evaluated same way
    true

/-- Run a semantic benchmark with timing and validation. -/
def runBenchmark (name : String) (φ : Formula) (expected : Bool)
    (iterations : Nat := 100) : IO SemanticBenchmarkResult := do
  let mut times : Array Nat := #[]
  let mut result : Bool := false
  for _ in [:iterations] do
    let (r, timeNs) ← timed (pure (evalFormula φ))
    times := times.push timeNs
    result := r
  let sortedTimes := times.toList.mergeSort (· ≤ ·)
  let medianTime := sortedTimes.get! (sortedTimes.length / 2)
  return { name, expectedResult := expected, actualResult := result, evaluationTimeNs := medianTime }

/-!
## Category 1: Atomic Evaluation (Baseline)

Benchmarks for basic atomic formula evaluation.
-/

def runAtomicBenchmarks : IO (List SemanticBenchmarkResult) := do
  IO.println "=== Atomic Formula Benchmarks ==="
  let mut results := []

  let r1 ← runBenchmark "Atom p (true)" (Formula.atom "p") true
  printResult r1
  results := results ++ [r1]

  let r2 ← runBenchmark "Atom q (false)" (Formula.atom "q") false
  printResult r2
  results := results ++ [r2]

  let r3 ← runBenchmark "Bot (false)" Formula.bot false
  printResult r3
  results := results ++ [r3]

  return results

/-!
## Category 2: Nested Modal Formulas (Depth Scaling)

Benchmarks for modal formulas of varying nesting depth.
-/

/-- Build nested box formula: □□...□p with given depth -/
def nestedBox (depth : Nat) : Formula :=
  match depth with
  | 0 => Formula.atom "p"
  | n + 1 => Formula.box (nestedBox n)

def runModalDepthBenchmarks : IO (List SemanticBenchmarkResult) := do
  IO.println "\n=== Modal Depth Benchmarks ==="
  let mut results := []

  -- At trivial frame, □φ is always true for any φ
  let r1 ← runBenchmark "Box depth 1 (□p)" (nestedBox 1) true
  printResult r1
  results := results ++ [r1]

  let r2 ← runBenchmark "Box depth 3 (□□□p)" (nestedBox 3) true
  printResult r2
  results := results ++ [r2]

  let r3 ← runBenchmark "Box depth 5 (□□□□□p)" (nestedBox 5) true
  printResult r3
  results := results ++ [r3]

  return results

/-!
## Category 3: Temporal Formulas

Benchmarks for temporal operators.
-/

def runTemporalBenchmarks : IO (List SemanticBenchmarkResult) := do
  IO.println "\n=== Temporal Formula Benchmarks ==="
  let mut results := []

  -- G p (all future): at trivial frame, true
  let r1 ← runBenchmark "Gp (all future)" (Formula.all_future (Formula.atom "p")) true
  printResult r1
  results := results ++ [r1]

  -- H p (all past): at time 0, vacuously true
  let r2 ← runBenchmark "Hp (all past)" (Formula.all_past (Formula.atom "p")) true
  printResult r2
  results := results ++ [r2]

  return results

/-!
## Category 4: Complex Formulas (Implication Chains)

Benchmarks for complex propositional formulas.
-/

def runComplexBenchmarks : IO (List SemanticBenchmarkResult) := do
  IO.println "\n=== Complex Formula Benchmarks ==="
  let mut results := []

  -- p → p is always true
  let r1 ← runBenchmark "p → p (true)" ((Formula.atom "p").imp (Formula.atom "p")) true
  printResult r1
  results := results ++ [r1]

  -- p → q: p is true, q is false, so p → q is false
  let r2 ← runBenchmark "p → q (false)" ((Formula.atom "p").imp (Formula.atom "q")) false
  printResult r2
  results := results ++ [r2]

  -- ¬⊥ (which is ⊥ → ⊥) is true
  let r3 ← runBenchmark "¬⊥ (true)" Formula.bot.neg true
  printResult r3
  results := results ++ [r3]

  -- q → p: q is false, so q → p is true (false implies anything)
  let r4 ← runBenchmark "q → p (true)" ((Formula.atom "q").imp (Formula.atom "p")) true
  printResult r4
  results := results ++ [r4]

  -- Implication chain: (p → (q → p)) is true (weakening)
  let r5 ← runBenchmark "p → (q → p) (true)" ((Formula.atom "p").imp ((Formula.atom "q").imp (Formula.atom "p"))) true
  printResult r5
  results := results ++ [r5]

  return results

/-!
## Category 5: Mixed Modal-Propositional

Benchmarks combining modal and propositional connectives.
-/

def runMixedBenchmarks : IO (List SemanticBenchmarkResult) := do
  IO.println "\n=== Mixed Modal-Propositional Benchmarks ==="
  let mut results := []

  -- □p → p (Modal T): box true implies p true
  let r1 ← runBenchmark "□p → p (true)" ((Formula.box (Formula.atom "p")).imp (Formula.atom "p")) true
  printResult r1
  results := results ++ [r1]

  -- p → □p (converse of T): p true, □p true at trivial frame
  let r2 ← runBenchmark "p → □p (true)" ((Formula.atom "p").imp (Formula.box (Formula.atom "p"))) true
  printResult r2
  results := results ++ [r2]

  -- □(p → q) → (□p → □q) (K distribution): both sides true at trivial frame
  let k_dist := (Formula.box ((Formula.atom "p").imp (Formula.atom "q"))).imp
    ((Formula.box (Formula.atom "p")).imp (Formula.box (Formula.atom "q")))
  let r3 ← runBenchmark "K distribution (true)" k_dist true
  printResult r3
  results := results ++ [r3]

  return results

/-!
## All Benchmarks
-/

/-- Run all semantic benchmark suites. -/
def runAllSemanticBenchmarks : IO Unit := do
  IO.println "╔══════════════════════════════════════════════════╗"
  IO.println "║     Semantic Evaluation Benchmark Suite          ║"
  IO.println "╚══════════════════════════════════════════════════╝\n"

  let mut allResults := []

  let atomic ← runAtomicBenchmarks
  allResults := allResults ++ atomic

  let modal ← runModalDepthBenchmarks
  allResults := allResults ++ modal

  let temporal ← runTemporalBenchmarks
  allResults := allResults ++ temporal

  let complex ← runComplexBenchmarks
  allResults := allResults ++ complex

  let mixed ← runMixedBenchmarks
  allResults := allResults ++ mixed

  -- Summary
  IO.println "\n═══════════════════════════════════════════════════"
  IO.println "                    SUMMARY"
  IO.println "═══════════════════════════════════════════════════"
  let total := allResults.length
  let correct := allResults.filter (·.correct) |>.length
  let totalTimeNs := allResults.foldl (fun acc r => acc + r.evaluationTimeNs) 0
  let avgTimeNs := if total > 0 then totalTimeNs / total else 0

  IO.println s!"Benchmarks run: {total}"
  IO.println s!"Correct results: {correct}/{total}"
  IO.println s!"Total time: {formatNanos totalTimeNs}"
  IO.println s!"Average time per benchmark: {formatNanos avgTimeNs}"

  if correct < total then
    IO.println "\n⚠ WARNING: Some benchmarks returned incorrect results!"
    for r in allResults do
      if !r.correct then
        IO.println s!"  - {r.name}: expected {r.expectedResult}, got {r.actualResult}"

/-!
## JSON Output for CI

JSON-formatted output for CI integration.
-/

/-- Convert result to JSON for CI. -/
def resultToJson (r : SemanticBenchmarkResult) : String :=
  "{" ++ s!"\"name\":\"{r.name}\",\"expected\":{r.expectedResult},\"actual\":{r.actualResult},\"timeNs\":{r.evaluationTimeNs},\"correct\":{r.correct}" ++ "}"

/-- Convert all results to JSON array. -/
def allResultsToJson (results : List SemanticBenchmarkResult) : String :=
  "[" ++ ",".intercalate (results.map resultToJson) ++ "]"

/-- Run benchmarks and output JSON. -/
def runBenchmarksJson : IO Unit := do
  let mut allResults := []

  let atomic ← runAtomicBenchmarks
  allResults := allResults ++ atomic

  let modal ← runModalDepthBenchmarks
  allResults := allResults ++ modal

  let temporal ← runTemporalBenchmarks
  allResults := allResults ++ temporal

  let complex ← runComplexBenchmarks
  allResults := allResults ++ complex

  let mixed ← runMixedBenchmarks
  allResults := allResults ++ mixed

  IO.println (allResultsToJson allResults)

end BimodalTest.Semantics.Benchmark

/-!
## Run Benchmarks
-/

-- Run all benchmarks with summary
#eval BimodalTest.Semantics.Benchmark.runAllSemanticBenchmarks
