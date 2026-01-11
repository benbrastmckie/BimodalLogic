import Bimodal.ProofSystem.Derivation
import BimodalTest.Automation.ProofSearchBenchmark

/-!
# Derivation Tree Benchmark Suite

Benchmarks for evaluating derivation tree construction performance.
Measures construction time and tree height for various derivation patterns.

## Usage

```lean
-- Run all benchmarks
#eval runAllDerivationBenchmarks

-- Run specific benchmark category
#eval runSimpleBenchmarks
#eval runMPChainBenchmarks
#eval runModalRuleBenchmarks
```

## Metrics

- **treeHeight**: Height of the constructed derivation tree
- **constructionTimeNs**: Wall-clock time in nanoseconds
- **valid**: Always true if compilation succeeds (type-level correctness)
-/

namespace BimodalTest.ProofSystem.Benchmark

open Bimodal.Syntax Bimodal.ProofSystem
open BimodalTest.Automation.Benchmark (timed formatNanos)

-- Convenience abbreviations (matching ProofSearchBenchmark)
abbrev p : Formula := .atom "p"
abbrev q : Formula := .atom "q"
abbrev r : Formula := .atom "r"

/-- Derivation benchmark result with correctness validation. -/
structure DerivationBenchmarkResult where
  name : String
  treeHeight : Nat
  constructionTimeNs : Nat
  valid : Bool := true  -- Always true if it compiles (type-level correctness)
  deriving Repr

/-- Format derivation benchmark result for display. -/
def formatResult (r : DerivationBenchmarkResult) : String :=
  s!"{r.name}: height={r.treeHeight}, time={formatNanos r.constructionTimeNs}"

/-- Print derivation benchmark result. -/
def printResult (r : DerivationBenchmarkResult) : IO Unit :=
  IO.println (formatResult r)

/-!
## Benchmark Infrastructure
-/

/-- Run a derivation benchmark with timing.
    Takes a function that constructs a derivation, runs it multiple times,
    and returns median timing along with tree height. -/
def runBenchmark {Γ : Context} {φ : Formula}
    (name : String) (mkDeriv : Unit → DerivationTree Γ φ)
    (iterations : Nat := 100) : IO DerivationBenchmarkResult := do
  let mut times : Array Nat := #[]
  let mut tree : Option (DerivationTree Γ φ) := none
  for _ in [:iterations] do
    let (result, timeNs) ← timed (pure (mkDeriv ()))
    times := times.push timeNs
    tree := some result
  let sortedTimes := times.toList.mergeSort (· ≤ ·)
  let medianTime := sortedTimes.get! (sortedTimes.length / 2)
  let height := match tree with
    | some t => t.height
    | none => 0
  return { name, treeHeight := height, constructionTimeNs := medianTime }

/-!
## Category 1: Simple Derivations (Baseline)

Benchmarks for basic axiom and assumption derivations.
These establish the baseline overhead for derivation construction.
-/

/-- Simple axiom derivation: Modal T -/
def mkModalT : DerivationTree [] ((Formula.box p).imp p) :=
  DerivationTree.axiom [] _ (Axiom.modal_t p)

/-- Simple axiom derivation: Modal 4 -/
def mkModal4 : DerivationTree [] ((Formula.box p).imp (Formula.box (Formula.box p))) :=
  DerivationTree.axiom [] _ (Axiom.modal_4 p)

/-- Simple axiom derivation: Modal B -/
def mkModalB : DerivationTree [] (p.imp (Formula.box p.diamond)) :=
  DerivationTree.axiom [] _ (Axiom.modal_b p)

/-- Simple axiom derivation: Temporal 4 -/
def mkTemp4 : DerivationTree [] ((Formula.all_future p).imp (Formula.all_future (Formula.all_future p))) :=
  DerivationTree.axiom [] _ (Axiom.temp_4 p)

/-- Simple assumption derivation: Single assumption -/
def mkAssumption : DerivationTree [p] p :=
  DerivationTree.assumption [p] p (by simp)

/-- Simple assumption derivation: First of multiple -/
def mkAssumption2 : DerivationTree [p, q] p :=
  DerivationTree.assumption [p, q] p (by simp)

def runSimpleBenchmarks : IO (List DerivationBenchmarkResult) := do
  IO.println "=== Simple Derivation Benchmarks ==="
  let mut results := []

  let r1 ← runBenchmark "Axiom (Modal T)" (fun _ => mkModalT)
  printResult r1
  results := results ++ [r1]

  let r2 ← runBenchmark "Axiom (Modal 4)" (fun _ => mkModal4)
  printResult r2
  results := results ++ [r2]

  let r3 ← runBenchmark "Axiom (Modal B)" (fun _ => mkModalB)
  printResult r3
  results := results ++ [r3]

  let r4 ← runBenchmark "Axiom (Temporal 4)" (fun _ => mkTemp4)
  printResult r4
  results := results ++ [r4]

  let r5 ← runBenchmark "Assumption (single)" (fun _ => mkAssumption)
  printResult r5
  results := results ++ [r5]

  let r6 ← runBenchmark "Assumption (multiple)" (fun _ => mkAssumption2)
  printResult r6
  results := results ++ [r6]

  return results

/-!
## Category 2: Modus Ponens Chains

Benchmarks for modus ponens chains of varying depth.
Tests how derivation construction scales with proof depth.
-/

/-- Basic modus ponens from assumptions: p→q, p ⊢ q -/
def mkMP1 : DerivationTree [p.imp q, p] q :=
  DerivationTree.modus_ponens [p.imp q, p] p q
    (DerivationTree.assumption _ _ (by simp))
    (DerivationTree.assumption _ _ (by simp))

/-- MP chain depth 2: p→q, q→r, p ⊢ r -/
abbrev ctxMP2 : Context := [p.imp q, q.imp r, p]

def mkMP2 : DerivationTree ctxMP2 r :=
  let d_p : DerivationTree ctxMP2 p :=
    DerivationTree.assumption _ _ (by simp [ctxMP2])
  let d_pq : DerivationTree ctxMP2 (p.imp q) :=
    DerivationTree.assumption _ _ (by simp [ctxMP2])
  let d_qr : DerivationTree ctxMP2 (q.imp r) :=
    DerivationTree.assumption _ _ (by simp [ctxMP2])
  let d_q : DerivationTree ctxMP2 q :=
    DerivationTree.modus_ponens _ p q d_pq d_p
  DerivationTree.modus_ponens _ q r d_qr d_q

def runMPChainBenchmarks : IO (List DerivationBenchmarkResult) := do
  IO.println "\n=== Modus Ponens Chain Benchmarks ==="
  let mut results := []

  let r1 ← runBenchmark "MP depth 1" (fun _ => mkMP1)
  printResult r1
  results := results ++ [r1]

  let r2 ← runBenchmark "MP depth 2" (fun _ => mkMP2)
  printResult r2
  results := results ++ [r2]

  return results

/-!
## Category 3: Modal and Temporal Rules

Benchmarks for necessitation and temporal rules.
These measure the overhead of modal and temporal inference.
-/

/-- Modal necessitation: □(Modal T) -/
def mkNecessitation : DerivationTree [] (Formula.box ((Formula.box p).imp p)) :=
  DerivationTree.necessitation _ mkModalT

/-- Temporal necessitation: G(Modal T) -/
def mkTemporalNecessitation : DerivationTree [] (Formula.all_future ((Formula.box p).imp p)) :=
  DerivationTree.temporal_necessitation _ mkModalT

/-- Temporal duality on Temporal 4 -/
def mkTemporalDuality : DerivationTree [] ((Formula.all_future p).imp (Formula.all_future (Formula.all_future p))).swap_past_future :=
  DerivationTree.temporal_duality _ mkTemp4

/-- Double necessitation: □□(Modal T) -/
def mkDoubleNecessitation : DerivationTree [] (Formula.box (Formula.box ((Formula.box p).imp p))) :=
  DerivationTree.necessitation _ mkNecessitation

def runModalRuleBenchmarks : IO (List DerivationBenchmarkResult) := do
  IO.println "\n=== Modal/Temporal Rule Benchmarks ==="
  let mut results := []

  let r1 ← runBenchmark "Necessitation (modal)" (fun _ => mkNecessitation)
  printResult r1
  results := results ++ [r1]

  let r2 ← runBenchmark "Necessitation (temporal)" (fun _ => mkTemporalNecessitation)
  printResult r2
  results := results ++ [r2]

  let r3 ← runBenchmark "Temporal duality" (fun _ => mkTemporalDuality)
  printResult r3
  results := results ++ [r3]

  let r4 ← runBenchmark "Double necessitation" (fun _ => mkDoubleNecessitation)
  printResult r4
  results := results ++ [r4]

  return results

/-!
## Category 4: Weakening

Benchmarks for context weakening with varying context sizes.
-/

/-- Weakening: add 1 formula to context -/
def mkWeak1 : DerivationTree [q, p] p :=
  DerivationTree.weakening [p] [q, p] p
    (DerivationTree.assumption [p] p (by simp))
    (by intro x hx; simp at hx; simp [hx])

/-- Weakening: add 2 formulas to context -/
def mkWeak2 : DerivationTree [q, r, p] p :=
  DerivationTree.weakening [p] [q, r, p] p
    (DerivationTree.assumption [p] p (by simp))
    (by intro x hx; simp at hx; simp [hx])

def runWeakeningBenchmarks : IO (List DerivationBenchmarkResult) := do
  IO.println "\n=== Weakening Benchmarks ==="
  let mut results := []

  let r1 ← runBenchmark "Weakening (+1 formula)" (fun _ => mkWeak1)
  printResult r1
  results := results ++ [r1]

  let r2 ← runBenchmark "Weakening (+2 formulas)" (fun _ => mkWeak2)
  printResult r2
  results := results ++ [r2]

  return results

/-!
## Combined Derivation Examples

Benchmarks for more complex derivations combining multiple rules.
-/

/-- Combined: MP with axiom as major premise (□p ⊢ p via Modal T) -/
def mkCombined1 : DerivationTree [(Formula.box p)] p :=
  DerivationTree.modus_ponens [(Formula.box p)] (Formula.box p) p
    (DerivationTree.weakening [] [(Formula.box p)] _ mkModalT
      (by intro x hx; exact False.elim (List.not_mem_nil x hx)))
    (DerivationTree.assumption _ _ (by simp))

def runCombinedBenchmarks : IO (List DerivationBenchmarkResult) := do
  IO.println "\n=== Combined Derivation Benchmarks ==="
  let mut results := []

  let r1 ← runBenchmark "MP with axiom (□p ⊢ p)" (fun _ => mkCombined1)
  printResult r1
  results := results ++ [r1]

  return results

/-!
## All Benchmarks
-/

/-- Run all derivation benchmark suites. -/
def runAllDerivationBenchmarks : IO Unit := do
  IO.println "╔══════════════════════════════════════════════════╗"
  IO.println "║     Derivation Tree Benchmark Suite              ║"
  IO.println "╚══════════════════════════════════════════════════╝\n"

  let mut allResults := []

  let simple ← runSimpleBenchmarks
  allResults := allResults ++ simple

  let mpChain ← runMPChainBenchmarks
  allResults := allResults ++ mpChain

  let modalRules ← runModalRuleBenchmarks
  allResults := allResults ++ modalRules

  let weakening ← runWeakeningBenchmarks
  allResults := allResults ++ weakening

  let combined ← runCombinedBenchmarks
  allResults := allResults ++ combined

  -- Summary
  IO.println "\n═══════════════════════════════════════════════════"
  IO.println "                    SUMMARY"
  IO.println "═══════════════════════════════════════════════════"
  let total := allResults.length
  let totalTimeNs := allResults.foldl (fun acc r => acc + r.constructionTimeNs) 0
  let avgTimeNs := if total > 0 then totalTimeNs / total else 0
  let avgHeight := if total > 0 then
    (allResults.foldl (fun acc r => acc + r.treeHeight) 0) / total else 0
  IO.println s!"Benchmarks run: {total}"
  IO.println s!"Total time: {formatNanos totalTimeNs}"
  IO.println s!"Average time per benchmark: {formatNanos avgTimeNs}"
  IO.println s!"Average tree height: {avgHeight}"

/-!
## JSON Output for CI

JSON-formatted output for CI integration.
-/

/-- Convert result to JSON for CI. -/
def resultToJson (r : DerivationBenchmarkResult) : String :=
  "{" ++ s!"\"name\":\"{r.name}\",\"height\":{r.treeHeight},\"timeNs\":{r.constructionTimeNs},\"valid\":{r.valid}" ++ "}"

/-- Convert all results to JSON array. -/
def allResultsToJson (results : List DerivationBenchmarkResult) : String :=
  "[" ++ ",".intercalate (results.map resultToJson) ++ "]"

/-- Run benchmarks and output JSON. -/
def runBenchmarksJson : IO Unit := do
  let mut allResults := []

  let simple ← runSimpleBenchmarks
  allResults := allResults ++ simple

  let mpChain ← runMPChainBenchmarks
  allResults := allResults ++ mpChain

  let modalRules ← runModalRuleBenchmarks
  allResults := allResults ++ modalRules

  let weakening ← runWeakeningBenchmarks
  allResults := allResults ++ weakening

  let combined ← runCombinedBenchmarks
  allResults := allResults ++ combined

  IO.println (allResultsToJson allResults)

end BimodalTest.ProofSystem.Benchmark

/-!
## Run Benchmarks
-/

-- Run all benchmarks with summary
#eval BimodalTest.ProofSystem.Benchmark.runAllDerivationBenchmarks
