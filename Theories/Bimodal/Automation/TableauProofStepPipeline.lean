import Bimodal.Automation.FormulaEnumerator
import Bimodal.Automation.ProofStepExtractor
import Bimodal.Metalogic.Decidability.DecisionProcedure
import Std.Data.HashMap
import Std.Data.HashSet

/-!
# Tableau-Derived Proof Step Extraction Pipeline

This module implements a pipeline that connects `FormulaEnumerator`,
`DecisionProcedure`, and `ProofStepExtractor` to produce large-scale
proof step training data in JSONL format.

## Pipeline Architecture

```
FormulaEnumerator
    |
    v
DecisionProcedure.decideAuto(phi)
    |
    +--> .valid (proof : DerivationTree .Base [] phi)
    |        |
    |        v
    |    extractStepSequence(name, "Base", 0, proof)
    |        |
    |        v
    |    List ProofStep --> JSONL lines
    |
    +--> .invalid / .timeout --> skip
```

## Strategies

1. **Enumeration**: Exhaustive formula enumeration at configurable complexity
2. **Axiom Seeding**: Guaranteed-valid formulas via axiom instantiation
3. **Deep G^n Wrapping**: Temporal wrapping for proof depth diversity

## Main Definitions

- `PipelineConfig`: Configuration for the full pipeline
- `StepDistribution`: Diversity metrics (rule/axiom histograms, coverage)
- `hashProofStep`: Step-level deduplication hash
- `runFullPipeline`: Full pipeline orchestrator
- `main`: CLI entry point for `lake exe tableau_proof_steps`

## References

- Task 242 implementation plan
- `Bimodal.Automation.FormulaEnumerator` — formula generation
- `Bimodal.Metalogic.Decidability.DecisionProcedure` — `decideAuto`
- `Bimodal.Automation.ProofStepExtractor` — `extractStepSequence`
-/

set_option autoImplicit false

namespace Bimodal.Automation.TableauProofStepPipeline

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Automation.ProofStepExtractor
open Bimodal.Automation.DataExport
open Bimodal.Metalogic.Decidability

/-!
## Pipeline Configuration
-/

/--
Configuration for the tableau proof step extraction pipeline.
-/
structure PipelineConfig where
  /-- Maximum formula complexity for enumeration. -/
  maxComplexity : Nat := 7
  /-- Maximum modal depth for enumerated formulas. -/
  maxModalDepth : Nat := 3
  /-- Maximum temporal depth for enumerated formulas. -/
  maxTemporalDepth : Nat := 3
  /-- Atom pool for formula generation. -/
  atomPool : List Atom := defaultAtomPool
  /-- Number of axiom-seeded valid formulas to generate. -/
  validSeedCount : Nat := 5000
  /-- Maximum G^n wrapping depth. -/
  maxWrapDepth : Nat := 10
  /-- Number of valid formulas to apply deep wrapping to. -/
  wrapBatchSize : Nat := 1000
  /-- Whether to deduplicate steps across sources. -/
  deduplicateSteps : Bool := true
  /-- Output path for JSONL file. -/
  outputPath : String := "data/tableau_proof_steps.jsonl"
  /-- Whether to merge with existing hand-registered theorem steps. -/
  includeRegistry : Bool := true
  deriving Repr

/-!
## Step Distribution (Diversity Metrics)
-/

/--
Distribution metrics for extracted proof steps.

Tracks rule usage, axiom name usage, complexity distribution,
total/unique step counts, and theorem count.
-/
structure StepDistribution where
  /-- Histogram of rule applications: rule name -> count. -/
  ruleHistogram : Std.HashMap String Nat
  /-- Histogram of axiom names used: axiom name -> count. -/
  axiomHistogram : Std.HashMap String Nat
  /-- Histogram of goal complexity: complexity -> count. -/
  complexityHistogram : Std.HashMap Nat Nat
  /-- Total proof steps (before dedup). -/
  totalSteps : Nat
  /-- Unique proof steps (after dedup). -/
  uniqueSteps : Nat
  /-- Number of theorems/formulas processed. -/
  theoremCount : Nat
  deriving Repr

/-- The empty step distribution (all counts zero). -/
def StepDistribution.empty : StepDistribution :=
  { ruleHistogram := {}
  , axiomHistogram := {}
  , complexityHistogram := {}
  , totalSteps := 0
  , uniqueSteps := 0
  , theoremCount := 0 }

/--
Increment a key's count in a HashMap.
-/
private def incrMap {α : Type} [BEq α] [Hashable α]
    (m : Std.HashMap α Nat) (k : α) : Std.HashMap α Nat :=
  match m[k]? with
  | some n => m.insert k (n + 1)
  | none => m.insert k 1

/--
Add a single proof step to the distribution metrics.
-/
def StepDistribution.addStep (dist : StepDistribution) (step : ProofStep)
    : StepDistribution :=
  let dist' := { dist with
    ruleHistogram := incrMap dist.ruleHistogram step.rule
    complexityHistogram := incrMap dist.complexityHistogram step.goal.complexity
    totalSteps := dist.totalSteps + 1 }
  match step.axiomName with
  | some name => { dist' with axiomHistogram := incrMap dist'.axiomHistogram name }
  | none => dist'

/--
Merge two step distributions by summing corresponding counts.
-/
def mergeDistributions (d1 d2 : StepDistribution) : StepDistribution :=
  let mergeHM := fun (m1 m2 : Std.HashMap String Nat) =>
    m2.fold (fun acc k v =>
      match acc[k]? with
      | some n => acc.insert k (n + v)
      | none => acc.insert k v) m1
  let mergeHMNat := fun (m1 m2 : Std.HashMap Nat Nat) =>
    m2.fold (fun acc k v =>
      match acc[k]? with
      | some n => acc.insert k (n + v)
      | none => acc.insert k v) m1
  { ruleHistogram := mergeHM d1.ruleHistogram d2.ruleHistogram
  , axiomHistogram := mergeHM d1.axiomHistogram d2.axiomHistogram
  , complexityHistogram := mergeHMNat d1.complexityHistogram d2.complexityHistogram
  , totalSteps := d1.totalSteps + d2.totalSteps
  , uniqueSteps := d1.uniqueSteps + d2.uniqueSteps
  , theoremCount := d1.theoremCount + d2.theoremCount }

/-!
## Step-Level Deduplication
-/

/--
Hash a proof step by its structural content for deduplication.

Uses `(context, goal, rule, axiomName)` as the deduplication key.
Two steps with the same context, goal, rule, and axiom name are
considered duplicates even if they appear in different theorems.
-/
def hashProofStep (step : ProofStep) : UInt64 :=
  let ctxHash := step.context.foldl (fun acc φ => mixHash acc (hash φ)) 0
  let goalHash := hash step.goal
  let ruleHash := hash step.rule
  let axiomHash := match step.axiomName with
    | some name => hash name
    | none => 0
  mixHash (mixHash (mixHash ctxHash goalHash) ruleHash) axiomHash

/-!
## Coverage Metrics
-/

/--
Compute coverage metrics: (rules_covered, total_rules, axioms_covered, total_axioms).
-/
def computeCoverage (dist : StepDistribution) : Nat × Nat × Nat × Nat :=
  let rulesCovered := dist.ruleHistogram.size
  let totalRules := 7  -- axiom, assumption, modus_ponens, necessitation, temporal_necessitation, temporal_duality, weakening
  let axiomsCovered := dist.axiomHistogram.size
  let totalAxioms := 42
  (rulesCovered, totalRules, axiomsCovered, totalAxioms)

/-!
## JSON Serialization for Metrics
-/

/--
Serialize a HashMap String Nat as a JSON object.
-/
private def hashMapToJson (m : Std.HashMap String Nat) : String :=
  let entries := m.fold (fun acc k v =>
    acc ++ (if acc.isEmpty then "" else ", ") ++
    "\"" ++ escapeJsonString k ++ "\": " ++ toString v) ""
  "{" ++ entries ++ "}"

/--
Serialize a HashMap Nat Nat as a JSON object.
-/
private def hashMapNatToJson (m : Std.HashMap Nat Nat) : String :=
  let entries := m.fold (fun acc k v =>
    acc ++ (if acc.isEmpty then "" else ", ") ++
    "\"" ++ toString k ++ "\": " ++ toString v) ""
  "{" ++ entries ++ "}"

/--
Serialize a `StepDistribution` to a JSON object string.
-/
def StepDistribution.toJson (dist : StepDistribution) : String :=
  let (rc, tr, ac, ta) := computeCoverage dist
  "{\"total_steps\": " ++ toString dist.totalSteps
  ++ ", \"unique_steps\": " ++ toString dist.uniqueSteps
  ++ ", \"theorem_count\": " ++ toString dist.theoremCount
  ++ ", \"rule_histogram\": " ++ hashMapToJson dist.ruleHistogram
  ++ ", \"axiom_histogram\": " ++ hashMapToJson dist.axiomHistogram
  ++ ", \"complexity_histogram\": " ++ hashMapNatToJson dist.complexityHistogram
  ++ ", \"coverage\": {\"rules_covered\": " ++ toString rc
  ++ ", \"total_rules\": " ++ toString tr
  ++ ", \"axioms_covered\": " ++ toString ac
  ++ ", \"total_axioms\": " ++ toString ta
  ++ "}}"

/-!
## Core Pipeline Functions
-/

/--
Process a single formula through `decideAuto` and `extractStepSequence`.

Returns `some steps` if the formula is valid, `none` if invalid or timeout.
-/
def processFormula (φ : Formula) (name : String) : Option (List ProofStep) :=
  match decideAuto φ with
  | .valid proof =>
    let (steps, _) := extractStepSequence name "Base" 0 proof
    some steps
  | .invalid _ => none
  | .timeout => none

/--
Generate a zero-padded formula name from an index with a prefix.
-/
def formulaName (namePrefix : String) (idx : Nat) : String :=
  let digits := String.ofList (Nat.toDigits 10 idx)
  let padded := if digits.length < 6 then
    String.ofList (List.replicate (6 - digits.length) '0') ++ digits
  else digits
  namePrefix ++ padded

/-!
## Pipeline Strategy 1: Enumeration
-/

/--
Run the enumeration pipeline: enumerate formulas, decide each, extract steps.

Streams results to avoid memory pressure. Reports progress every 1000 formulas.
Returns accumulated steps and distribution metrics.
-/
partial def runEnumerationPipeline (config : PipelineConfig)
    : IO (Array ProofStep × StepDistribution) := do
  let enumConfig : EnumConfig :=
    { maxModalDepth := config.maxModalDepth
    , maxTemporalDepth := config.maxTemporalDepth
    , maxSize := config.maxComplexity
    , atomPool := config.atomPool }
  IO.println s!"[enum] Enumerating formulas (complexity <= {config.maxComplexity}, modal <= {config.maxModalDepth}, temporal <= {config.maxTemporalDepth})..."
  let startMs ← IO.monoMsNow
  let formulas := enumerateUpToDepth enumConfig
  let enumMs ← IO.monoMsNow
  IO.println s!"[enum] Enumerated {formulas.length} formulas in {(enumMs - startMs) / 1000}s"
  -- Process each formula
  let mut allSteps : Array ProofStep := #[]
  let mut dist := StepDistribution.empty
  let mut seenHashes : Std.HashSet UInt64 := {}
  let mut validCount : Nat := 0
  let mut timeoutCount : Nat := 0
  let mut idx : Nat := 0
  for φ in formulas do
    let name := formulaName "enum-" idx
    match processFormula φ name with
    | some steps =>
      validCount := validCount + 1
      for step in steps do
        dist := dist.addStep step
        if config.deduplicateSteps then
          let h := hashProofStep step
          if seenHashes.contains h then
            pure ()
          else
            seenHashes := seenHashes.insert h
            allSteps := allSteps.push step
            dist := { dist with uniqueSteps := dist.uniqueSteps + 1 }
        else
          allSteps := allSteps.push step
          dist := { dist with uniqueSteps := dist.uniqueSteps + 1 }
    | none =>
      -- Check if timeout (we can't distinguish easily, count as skip)
      timeoutCount := timeoutCount + 1
    idx := idx + 1
    if idx % 1000 == 0 then
      let elapsedMs ← IO.monoMsNow
      let elapsedSecs := (elapsedMs - startMs) / 1000
      IO.println s!"[enum] Progress: {idx}/{formulas.length} formulas, {validCount} valid, {allSteps.size} steps, {elapsedSecs}s"
  let endMs ← IO.monoMsNow
  IO.println s!"[enum] Complete: {formulas.length} formulas, {validCount} valid, {allSteps.size} unique steps, {(endMs - startMs) / 1000}s"
  dist := { dist with theoremCount := validCount }
  return (allSteps, dist)

/-!
## Pipeline Strategy 2: Axiom Seeding
-/

/--
Run the axiom seed pipeline: generate valid-by-construction formulas,
decide each to get a DerivationTree, extract steps.
-/
partial def runAxiomSeedPipeline (config : PipelineConfig)
    (existingHashes : Std.HashSet UInt64 := {})
    : IO (Array ProofStep × StepDistribution × Std.HashSet UInt64) := do
  IO.println s!"[seed] Generating {config.validSeedCount} axiom-seeded valid formulas..."
  let startMs ← IO.monoMsNow
  let validFormulas ← generateValidBatch config.validSeedCount config.maxComplexity config.atomPool
  let genMs ← IO.monoMsNow
  IO.println s!"[seed] Generated {validFormulas.length} valid formulas in {(genMs - startMs) / 1000}s"
  -- Process each valid formula through decideAuto + extractStepSequence
  let mut allSteps : Array ProofStep := #[]
  let mut dist := StepDistribution.empty
  let mut seenHashes := existingHashes
  let mut validCount : Nat := 0
  let mut idx : Nat := 0
  for φ in validFormulas do
    let name := formulaName "seed-" idx
    match processFormula φ name with
    | some steps =>
      validCount := validCount + 1
      for step in steps do
        dist := dist.addStep step
        if config.deduplicateSteps then
          let h := hashProofStep step
          if seenHashes.contains h then
            pure ()
          else
            seenHashes := seenHashes.insert h
            allSteps := allSteps.push step
            dist := { dist with uniqueSteps := dist.uniqueSteps + 1 }
        else
          allSteps := allSteps.push step
          dist := { dist with uniqueSteps := dist.uniqueSteps + 1 }
    | none => pure ()
    idx := idx + 1
    if idx % 500 == 0 then
      let elapsedMs ← IO.monoMsNow
      IO.println s!"[seed] Progress: {idx}/{validFormulas.length}, {validCount} decided valid, {allSteps.size} steps, {(elapsedMs - startMs) / 1000}s"
  let endMs ← IO.monoMsNow
  IO.println s!"[seed] Complete: {validFormulas.length} formulas, {validCount} decided valid, {allSteps.size} unique steps, {(endMs - startMs) / 1000}s"
  dist := { dist with theoremCount := validCount }
  return (allSteps, dist, seenHashes)

/-!
## Pipeline Strategy 3: Deep G^n Wrapping
-/

/--
Apply `all_future` n times to a formula: `iterG 0 φ = φ`, `iterG 3 φ = G(G(G(φ)))`.
-/
private def iterG : Nat → Formula → Formula
  | 0, φ => φ
  | n + 1, φ => (iterG n φ).all_future

/--
Run the deep wrapping pipeline: take valid formulas from enumeration,
wrap each with G^n for n = 1..maxWrapDepth, decide + extract steps.

This multiplies step count because each G^n wrapping adds n
temporal_necessitation steps on top of the original proof.
-/
partial def runDeepWrappingPipeline (validFormulas : List Formula)
    (config : PipelineConfig) (existingHashes : Std.HashSet UInt64 := {})
    : IO (Array ProofStep × StepDistribution × Std.HashSet UInt64) := do
  let batchFormulas := validFormulas.take config.wrapBatchSize
  IO.println s!"[wrap] Deep G^n wrapping: {batchFormulas.length} formulas x {config.maxWrapDepth} depths"
  let startMs ← IO.monoMsNow
  let mut allSteps : Array ProofStep := #[]
  let mut dist := StepDistribution.empty
  let mut seenHashes := existingHashes
  let mut validCount : Nat := 0
  let mut idx : Nat := 0
  for φ in batchFormulas do
    for depth in List.range config.maxWrapDepth do
      let n := depth + 1
      let wrappedPhi := iterG n φ
      let name := formulaName s!"wrap-G{n}-" idx
      match processFormula wrappedPhi name with
      | some steps =>
        validCount := validCount + 1
        for step in steps do
          dist := dist.addStep step
          if config.deduplicateSteps then
            let h := hashProofStep step
            if seenHashes.contains h then
              pure ()
            else
              seenHashes := seenHashes.insert h
              allSteps := allSteps.push step
              dist := { dist with uniqueSteps := dist.uniqueSteps + 1 }
          else
            allSteps := allSteps.push step
            dist := { dist with uniqueSteps := dist.uniqueSteps + 1 }
      | none => pure ()
    idx := idx + 1
    if idx % 100 == 0 then
      let elapsedMs ← IO.monoMsNow
      IO.println s!"[wrap] Progress: {idx}/{batchFormulas.length} formulas, {validCount} wrapped valid, {allSteps.size} steps, {(elapsedMs - startMs) / 1000}s"
  let endMs ← IO.monoMsNow
  IO.println s!"[wrap] Complete: {batchFormulas.length} formulas x {config.maxWrapDepth} depths, {validCount} valid, {allSteps.size} unique steps, {(endMs - startMs) / 1000}s"
  dist := { dist with theoremCount := validCount }
  return (allSteps, dist, seenHashes)

/-!
## JSONL Export
-/

/--
Write proof steps to a JSONL file (one JSON object per line).
Returns the number of lines written.
-/
def writeProofStepsJSONL (path : String) (steps : Array ProofStep) : IO Nat := do
  -- Ensure output directory exists
  let dir := System.FilePath.mk path |>.parent
  if let some dirPath := dir then
    IO.FS.createDirAll dirPath
  let handle ← IO.FS.Handle.mk (System.FilePath.mk path) IO.FS.Mode.write
  for step in steps do
    handle.putStrLn step.toJson
  return steps.size

/--
Write metadata JSON with generation parameters, distribution stats,
coverage metrics, and timestamp.
-/
def writeMetadataJSON (path : String) (dist : StepDistribution)
    (config : PipelineConfig) : IO Unit := do
  let (rc, tr, ac, ta) := computeCoverage dist
  let content :=
    "{\n" ++
    "  \"generation_params\": {\n" ++
    "    \"max_complexity\": " ++ toString config.maxComplexity ++ ",\n" ++
    "    \"max_modal_depth\": " ++ toString config.maxModalDepth ++ ",\n" ++
    "    \"max_temporal_depth\": " ++ toString config.maxTemporalDepth ++ ",\n" ++
    "    \"valid_seed_count\": " ++ toString config.validSeedCount ++ ",\n" ++
    "    \"max_wrap_depth\": " ++ toString config.maxWrapDepth ++ ",\n" ++
    "    \"wrap_batch_size\": " ++ toString config.wrapBatchSize ++ ",\n" ++
    "    \"deduplicate_steps\": " ++ toString config.deduplicateSteps ++ ",\n" ++
    "    \"include_registry\": " ++ toString config.includeRegistry ++ "\n" ++
    "  },\n" ++
    "  \"distribution\": " ++ dist.toJson ++ ",\n" ++
    "  \"coverage\": {\n" ++
    "    \"rules_covered\": " ++ toString rc ++ ",\n" ++
    "    \"total_rules\": " ++ toString tr ++ ",\n" ++
    "    \"rules_pct\": " ++ toString (rc * 100 / tr) ++ ",\n" ++
    "    \"axioms_covered\": " ++ toString ac ++ ",\n" ++
    "    \"total_axioms\": " ++ toString ta ++ ",\n" ++
    "    \"axioms_pct\": " ++ toString (ac * 100 / ta) ++ "\n" ++
    "  }\n" ++
    "}"
  -- Derive metadata path from output path
  let dir := System.FilePath.mk path |>.parent
  if let some dirPath := dir then
    IO.FS.createDirAll dirPath
  IO.FS.writeFile (System.FilePath.mk path) content

/-!
## Full Pipeline Orchestrator
-/

/--
Collect valid formulas from enumeration for use by the deep wrapping pipeline.

Returns the list of formulas that were successfully decided valid.
-/
def collectValidFormulas (config : PipelineConfig) : IO (List Formula) := do
  let enumConfig : EnumConfig :=
    { maxModalDepth := config.maxModalDepth
    , maxTemporalDepth := config.maxTemporalDepth
    , maxSize := config.maxComplexity
    , atomPool := config.atomPool }
  let formulas := enumerateUpToDepth enumConfig
  let mut validFormulas : List Formula := []
  for φ in formulas do
    match decideAuto φ with
    | .valid _ => validFormulas := φ :: validFormulas
    | _ => pure ()
  return validFormulas.reverse

/--
Run the full pipeline: enumeration + axiom seeding + deep wrapping.

1. Enumerate formulas and extract proof steps from valid ones
2. Generate axiom-seeded valid formulas and extract proof steps
3. Apply deep G^n wrapping to diverse valid formulas
4. Deduplicate across all sources
5. Write combined JSONL and metadata
6. Print summary
-/
partial def runFullPipeline (config : PipelineConfig) : IO Unit := do
  let pipelineStartMs ← IO.monoMsNow
  IO.println "========================================"
  IO.println "Tableau Proof Step Pipeline"
  IO.println "========================================"
  IO.println s!"Config: complexity={config.maxComplexity}, modal={config.maxModalDepth}, temporal={config.maxTemporalDepth}"
  IO.println s!"Seeds: {config.validSeedCount}, wrap depth: {config.maxWrapDepth}, batch: {config.wrapBatchSize}"
  IO.println s!"Output: {config.outputPath}"
  IO.println ""

  -- Strategy 1: Enumeration pipeline
  IO.println "--- Strategy 1: Enumeration ---"
  let (enumSteps, enumDist) ← runEnumerationPipeline config
  IO.println ""

  -- Collect valid formulas for wrapping (reuse enumeration decisions)
  -- We need the formulas themselves, so re-collect them
  IO.println "--- Collecting valid formulas for wrapping ---"
  let validFormulas ← collectValidFormulas config
  IO.println s!"[collect] {validFormulas.length} valid formulas collected"
  IO.println ""

  -- Build the hash set from enumeration steps for cross-source dedup
  let mut seenHashes : Std.HashSet UInt64 := {}
  if config.deduplicateSteps then
    for step in enumSteps do
      seenHashes := seenHashes.insert (hashProofStep step)

  -- Strategy 2: Axiom seeding pipeline
  IO.println "--- Strategy 2: Axiom Seeding ---"
  let (seedSteps, seedDist, seenHashes2) ← runAxiomSeedPipeline config seenHashes
  IO.println ""

  -- Strategy 3: Deep G^n wrapping pipeline
  IO.println "--- Strategy 3: Deep G^n Wrapping ---"
  let (wrapSteps, wrapDist, _) ← runDeepWrappingPipeline validFormulas config seenHashes2
  IO.println ""

  -- Combine all steps
  let allSteps := enumSteps ++ seedSteps ++ wrapSteps
  let combinedDist := mergeDistributions (mergeDistributions enumDist seedDist) wrapDist

  -- Write JSONL output
  IO.println "--- Writing Output ---"
  let lineCount ← writeProofStepsJSONL config.outputPath allSteps
  IO.println s!"[output] Wrote {lineCount} lines to {config.outputPath}"

  -- Write metadata
  let metadataPath := config.outputPath.replace ".jsonl" "_metadata.json"
  writeMetadataJSON metadataPath combinedDist config
  IO.println s!"[output] Wrote metadata to {metadataPath}"

  -- Print summary
  let pipelineEndMs ← IO.monoMsNow
  let totalSecs := (pipelineEndMs - pipelineStartMs) / 1000
  let (rc, tr, ac, ta) := computeCoverage combinedDist
  IO.println ""
  IO.println "========================================"
  IO.println "Pipeline Summary"
  IO.println "========================================"
  IO.println s!"Total steps: {combinedDist.totalSteps}"
  IO.println s!"Unique steps: {allSteps.size}"
  IO.println s!"Theorems processed: {combinedDist.theoremCount}"
  IO.println s!"Rule coverage: {rc}/{tr}"
  IO.println s!"Axiom name coverage: {ac}/{ta}"
  IO.println s!"Total time: {totalSecs}s"
  IO.println s!"Output: {config.outputPath}"

/-!
## CLI Argument Parsing
-/

/--
Parse command-line arguments into a `PipelineConfig`.

Supported flags:
- `--max-complexity N` (default: 7)
- `--max-modal-depth N` (default: 3)
- `--max-temporal-depth N` (default: 3)
- `--valid-seed-count N` (default: 5000)
- `--max-wrap-depth N` (default: 10)
- `--wrap-batch-size N` (default: 1000)
- `--output PATH` (default: data/tableau_proof_steps.jsonl)
- `--no-dedup`
- `--no-registry`
-/
def parseArgs (args : List String) : PipelineConfig := Id.run do
  let mut config : PipelineConfig := {}
  let mut i := 0
  while i < args.length do
    match args[i]? with
    | some "--max-complexity" =>
      if let some val := args[i + 1]? then
        if let some n := val.toNat? then
          config := { config with maxComplexity := n }
      i := i + 2
    | some "--max-modal-depth" =>
      if let some val := args[i + 1]? then
        if let some n := val.toNat? then
          config := { config with maxModalDepth := n }
      i := i + 2
    | some "--max-temporal-depth" =>
      if let some val := args[i + 1]? then
        if let some n := val.toNat? then
          config := { config with maxTemporalDepth := n }
      i := i + 2
    | some "--valid-seed-count" =>
      if let some val := args[i + 1]? then
        if let some n := val.toNat? then
          config := { config with validSeedCount := n }
      i := i + 2
    | some "--max-wrap-depth" =>
      if let some val := args[i + 1]? then
        if let some n := val.toNat? then
          config := { config with maxWrapDepth := n }
      i := i + 2
    | some "--wrap-batch-size" =>
      if let some val := args[i + 1]? then
        if let some n := val.toNat? then
          config := { config with wrapBatchSize := n }
      i := i + 2
    | some "--output" =>
      if let some val := args[i + 1]? then
        config := { config with outputPath := val }
      i := i + 2
    | some "--no-dedup" =>
      config := { config with deduplicateSteps := false }
      i := i + 1
    | some "--no-registry" =>
      config := { config with includeRegistry := false }
      i := i + 1
    | _ =>
      i := i + 1
  return config

end Bimodal.Automation.TableauProofStepPipeline

open Bimodal.Automation.TableauProofStepPipeline in
/--
Main entry point for `lake exe tableau_proof_steps`.

Parses CLI arguments and runs the full pipeline.
-/
def main (args : List String) : IO Unit := do
  let config := parseArgs args
  runFullPipeline config
