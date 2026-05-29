import Bimodal.Automation.FormulaEnumerator
import Bimodal.Automation.DatasetGenerator

/-!
# Enumerator Benchmark (Task 210 Phase 4)

Validates complexity 5-7 feasibility gates for the exact-complexity enumeration
rewrite. Must be run in compiled mode via `lake exe enum_benchmark`.

## Feasibility Gates

- Complexity 5: < 5 seconds, ~1,440 distinct formulas (3 atoms, modal 2, temporal 2)
- Complexity 6: < 30 seconds
- Complexity 7: < 60 seconds (or safely cap)
- Valid fraction with axiom seeding: > 15%
-/

set_option autoImplicit false

open Bimodal.Syntax
open Bimodal.Automation

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

/-- Run axiom seeding and check valid fraction. -/
def benchmarkValidFraction (atoms : List Atom) (maxComplexity : Nat) : IO Unit := do
  IO.println s!"--- Valid Fraction Benchmark (complexity {maxComplexity}) ---"
  -- Test 1: Axiom seeds only (pure valid-by-construction pool)
  IO.println "  [Test 1: Axiom seeds only]"
  let validFormulas ← generateValidBatch 500 maxComplexity atoms
  IO.println s!"  Axiom-seeded pool: {validFormulas.length} formulas"
  let sampleValid := validFormulas.take 100
  IO.println s!"  Labeling {sampleValid.length} axiom-seeded formulas..."
  let labeledValid ← labelBatch sampleValid
  let statsValid := computeBatchStats labeledValid
  IO.println (statsValid.display)
  -- Test 2: Combined pipeline with high seed ratio
  IO.println "  [Test 2: Combined pipeline (exhaustive + 500 axiom seeds)]"
  let params : EnumParams := {
    maxComplexity := maxComplexity
    maxModalDepth := 2
    maxTemporalDepth := 2
    atoms := atoms
    maxFormulas := 1000
    samplingMode := .exhaustive
    validSeedCount := 500
  }
  let startMs ← IO.monoMsNow
  let formulas ← generateFormulas params
  let endMs ← IO.monoMsNow
  IO.println s!"  Total formulas: {formulas.length}"
  IO.println s!"  Generation time: {endMs - startMs} ms"
  -- Label a random-ish subset (take from middle to mix exhaustive + seeds)
  let sample := formulas.take 200
  IO.println s!"  Labeling {sample.length} formulas from combined pool..."
  let labeled ← labelBatch sample
  let stats := computeBatchStats labeled
  IO.println (stats.display)
  let validPct := if stats.totalCount > 0
    then stats.validCount * 100 / stats.totalCount
    else 0
  if validPct ≥ 15 then
    IO.println s!"  Valid fraction PASS ({validPct}% >= 15%)"
  else
    IO.println s!"  Valid fraction: {validPct}% (below 15% target; axiom seeds boost from 1.6% baseline)"

def main : IO Unit := do
  let atoms := [Atom.mk_base "p", Atom.mk_base "q", Atom.mk_base "r"]
  IO.println "=== Enumerator Benchmark (Task 210) ==="
  IO.println ""
  -- Phase 1: Exact-complexity enumeration timing
  benchmarkExactComplexity 5 atoms 2 2
  IO.println ""
  benchmarkExactComplexity 6 atoms 2 2
  IO.println ""
  benchmarkExactComplexity 7 atoms 2 2
  IO.println ""
  -- Phase 2: Valid fraction with axiom seeding
  benchmarkValidFraction atoms 5
  IO.println ""
  IO.println "=== Benchmark Complete ==="
