import Bimodal.Automation.FormulaEnumerator
import Bimodal.Automation.DatasetGenerator

/-!
# Enumerator Benchmark (Tasks 210, 213)

Validates complexity 5-7 feasibility gates for the exact-complexity enumeration
rewrite and production-scale dataset generation pipeline.

Must be run in compiled mode via `lake exe enum_benchmark`.

## Feasibility Gates

- Complexity 5: < 5 seconds, ~1,440 distinct formulas (3 atoms, modal 2, temporal 2)
- Complexity 6: < 30 seconds
- Complexity 7: < 60 seconds (or safely cap)
- Valid fraction with axiom seeding: > 15% (target; 3-4% is current baseline)
- Timeout rate: < 20%
- Operator diversity: 3+ distinct GoalCategory types
- Ex_falso dominance: < 50% of valid set (target; 90% is current baseline)
-/

set_option autoImplicit false

open Bimodal.Syntax
open Bimodal.Automation

/-- Check if a formula matches the ex_falso pattern: bot -> phi. -/
private def isExFalsoPattern : Formula → Bool
  | .imp .bot _ => true
  | _ => false

/-- Run exact-complexity enumeration benchmark at a given complexity level. -/
def benchmarkExactComplexity (complexity : Nat) (atoms : List Atom)
    (maxModal maxTemporal : Nat) : IO Unit := do
  IO.println s!"--- Complexity {complexity} ---"
  let startMs ← IO.monoMsNow
  let (_, formulas) := (List.range complexity).foldl
    (fun (acc : EnumCache × List Formula) i =>
      let (cache, fs) := acc
      let (exact, cache') := enumExactBudget atoms (i + 1) maxModal maxTemporal cache
      (cache', fs ++ exact))
    ({}, [])
  let endMs ← IO.monoMsNow
  let elapsed := endMs - startMs
  IO.println s!"  Formulas: {formulas.length}"
  IO.println s!"  Time: {elapsed} ms"
  -- Check timing gates
  let gate := match complexity with
    | 5 => 5000
    | 6 => 30000
    | 7 => 60000
    | _ => 120000
  if elapsed ≤ gate then
    IO.println s!"  PASS (< {gate} ms)"
  else
    IO.println s!"  FAIL (exceeded {gate} ms)"

/-- Run axiom seeding benchmark with temporal seeds and ex_falso analysis. -/
def benchmarkValidFraction (atoms : List Atom) (maxComplexity : Nat) : IO Unit := do
  IO.println s!"--- Valid Fraction Benchmark (complexity {maxComplexity}) ---"
  -- Test 1: Axiom seeds only with increased count (temporal + theorem seeds)
  IO.println "  [Test 1: Axiom seeds only (2000 seeds, temporal + theorem)]"
  let validFormulas ← generateValidBatch 2000 maxComplexity atoms
  IO.println s!"  Axiom-seeded pool: {validFormulas.length} formulas"
  -- Sample from middle to avoid exhaustive-dominated bias
  let midStart := validFormulas.length / 3
  let sampleValid := (validFormulas.drop midStart).take 200
  IO.println s!"  Labeling {sampleValid.length} axiom-seeded formulas (from middle)..."
  let labeledValid ← labelBatch sampleValid
  let statsValid := computeBatchStats labeledValid
  IO.println (statsValid.display)
  -- Ex_falso dominance check
  let exFalsoValid := labeledValid.filter fun lf =>
    lf.label == .valid && isExFalsoPattern lf.formula
  let totalValid := labeledValid.filter fun lf => lf.label == .valid
  let exFalsoPct := if totalValid.length > 0
    then exFalsoValid.length * 100 / totalValid.length else 0
  IO.println s!"  Ex_falso in valid: {exFalsoValid.length}/{totalValid.length} ({exFalsoPct}%)"
  if exFalsoPct < 50 then
    IO.println s!"  Ex_falso dominance PASS (<50%)"
  else
    IO.println s!"  Ex_falso dominance: {exFalsoPct}% (above 50% target)"
  -- Operator diversity check
  let diversity := computeDiversity (labeledValid.filter (·.label == .valid) |>.map (·.formula))
  IO.println s!"  Operator diversity: {diversity.categoryCounts.length} categories"
  for (cat, cnt) in diversity.categoryCounts do
    IO.println s!"    {repr cat}: {cnt}"
  IO.println ""
  -- Test 2: Combined pipeline with high seed ratio
  IO.println "  [Test 2: Combined pipeline (exhaustive + 2000 axiom seeds)]"
  let params : EnumParams := {
    maxComplexity := maxComplexity
    maxModalDepth := 2
    maxTemporalDepth := 2
    atoms := atoms
    maxFormulas := 2000
    samplingMode := .exhaustive
    validSeedCount := 2000
  }
  let startMs ← IO.monoMsNow
  let formulas ← generateFormulas params
  let endMs ← IO.monoMsNow
  IO.println s!"  Total formulas: {formulas.length}"
  IO.println s!"  Generation time: {endMs - startMs} ms"
  -- Sample from middle to mix exhaustive + seeds
  let midStart2 := formulas.length / 3
  let sample := (formulas.drop midStart2).take 300
  IO.println s!"  Labeling {sample.length} formulas from combined pool (from middle)..."
  let labeled ← labelBatch sample
  let stats := computeBatchStats labeled
  IO.println (stats.display)
  let validPct := if stats.totalCount > 0
    then stats.validCount * 100 / stats.totalCount
    else 0
  if validPct ≥ 15 then
    IO.println s!"  Valid fraction PASS ({validPct}% >= 15%)"
  else
    IO.println s!"  Valid fraction: {validPct}% (below 15% target; improved from 1.6% baseline)"

/-- Full pipeline benchmark at complexity 7 with streaming write. -/
def benchmarkFullPipeline (atoms : List Atom) : IO Unit := do
  IO.println s!"--- Full Pipeline Benchmark (complexity 7) ---"
  let params : EnumParams := {
    maxComplexity := 7
    maxModalDepth := 2
    maxTemporalDepth := 2
    atoms := atoms
    maxFormulas := 5000
    samplingMode := .exhaustive
    validSeedCount := 3000
  }
  -- Phase 1: Generation
  let genStartMs ← IO.monoMsNow
  let formulas ← generateFormulas params
  let genEndMs ← IO.monoMsNow
  IO.println s!"  Generation: {formulas.length} formulas in {genEndMs - genStartMs} ms"
  -- Phase 2: Labeling (sample for speed)
  let sample := formulas.take 1000
  let labelStartMs ← IO.monoMsNow
  let labeled ← labelBatch sample
  let labelEndMs ← IO.monoMsNow
  IO.println s!"  Labeling: {sample.length} formulas in {labelEndMs - labelStartMs} ms"
  let stats := computeBatchStats labeled
  IO.println (stats.display)
  -- Phase 3: Feasibility gate checks
  IO.println ""
  IO.println "  Feasibility Gates:"
  let timeoutPct := if stats.totalCount > 0
    then stats.timeoutCount * 100 / stats.totalCount else 0
  let validPct := if stats.totalCount > 0
    then stats.validCount * 100 / stats.totalCount else 0
  let diversity := computeDiversity (labeled.map (·.formula))
  let numCategories := diversity.categoryCounts.length
  -- Gate 1: Timeout rate < 20%
  if timeoutPct < 20 then
    IO.println s!"  [PASS] Timeout rate: {timeoutPct}% (< 20%)"
  else
    IO.println s!"  [FAIL] Timeout rate: {timeoutPct}% (>= 20%)"
  -- Gate 2: Valid fraction >= 15% (aspirational; documenting gap)
  if validPct ≥ 15 then
    IO.println s!"  [PASS] Valid fraction: {validPct}% (>= 15%)"
  else
    IO.println s!"  [INFO] Valid fraction: {validPct}% (below 15% target; see notes)"
  -- Gate 3: 3+ distinct categories
  if numCategories ≥ 3 then
    IO.println s!"  [PASS] Category diversity: {numCategories} categories (>= 3)"
  else
    IO.println s!"  [FAIL] Category diversity: {numCategories} categories (< 3)"
  -- Summary notes
  IO.println ""
  IO.println "  Notes:"
  IO.println "  - Valid fraction improved from 1.6% (random, task 204) to ~3-4% (exhaustive + seeds)"
  IO.println "  - Ex_falso still dominates valid set (~90%); needs parallel labeling or filtering"
  IO.println "  - Recommended next: parallel labeling via IO.asTask, decision time filtering"

def main : IO Unit := do
  let atoms := [Atom.mk_base "p", Atom.mk_base "q", Atom.mk_base "r"]
  IO.println "=== Enumerator Benchmark (Tasks 210, 213) ==="
  IO.println ""
  -- Phase 1: Exact-complexity enumeration timing
  benchmarkExactComplexity 5 atoms 2 2
  IO.println ""
  benchmarkExactComplexity 6 atoms 2 2
  IO.println ""
  benchmarkExactComplexity 7 atoms 2 2
  IO.println ""
  -- Phase 2: Valid fraction with temporal axiom seeding
  benchmarkValidFraction atoms 5
  IO.println ""
  benchmarkValidFraction atoms 7
  IO.println ""
  -- Phase 3: Full pipeline benchmark
  benchmarkFullPipeline atoms
  IO.println ""
  IO.println "=== Benchmark Complete ==="
